<?php

namespace App\Services;

use App\Models\Item;
use App\Models\User;
use Illuminate\Support\Collection;

class MatchingService
{
    /**
     * Calculate 5-criteria match results for a given target item.
     * Weighting:
     * - Category Match: 30%
     * - Value Proximity: 25%
     * - Condition: 15%
     * - Geographic Proximity: 15%
     * - Trust & Rating: 15%
     */
    public function findMatchesForItem(Item $targetItem, float $minScoreThreshold = 0.40): Collection
    {
        // 1. Candidate Set: Active items from other users
        $candidates = Item::with(['user', 'category', 'wantedCategory'])
            ->where('id', '!=', $targetItem->id)
            ->where('user_id', '!=', $targetItem->user_id)
            ->where('status', 'available')
            ->where('is_active', true)
            ->get();

        $results = collect();

        foreach ($candidates as $candidate) {
            $scoreBreakdown = $this->calculateScore($targetItem, $candidate);
            $totalScore = $scoreBreakdown['total_score'];

            if ($totalScore >= $minScoreThreshold) {
                $results->push([
                    'item' => $candidate,
                    'score' => round($totalScore * 100, 1),
                    'raw_score' => $totalScore,
                    'criteria_breakdown' => $scoreBreakdown,
                    'match_type' => $this->resolveMatchType($scoreBreakdown),
                ]);
            }
        }

        return $results->sortByDesc('raw_score')->values();
    }

    public function calculateScore(Item $a, Item $b): array
    {
        // 1. Category Score (30%)
        // Exact wanted category match or matching target category
        $categoryScore = 0.0;
        if ($a->wanted_category_id && $b->category_id === $a->wanted_category_id) {
            $categoryScore += 0.5;
        } elseif ($a->category_id === $b->category_id) {
            $categoryScore += 0.3;
        }

        if ($b->wanted_category_id && $a->category_id === $b->wanted_category_id) {
            $categoryScore += 0.5;
        } elseif (!$b->wanted_category_id && $a->category_id === $b->category_id) {
            $categoryScore += 0.2;
        }
        $categoryScore = min(1.0, $categoryScore);

        // 2. Value Proximity Score (25%)
        $valA = (float) $a->estimated_value;
        $valB = (float) $b->estimated_value;
        $maxVal = max($valA, $valB, 1.0);
        $diff = abs($valA - $valB);
        $valueScore = max(0.0, 1.0 - ($diff / $maxVal));

        // 3. Condition Compatibility (15%)
        $condA = $this->conditionToRank($a->condition);
        $condB = $this->conditionToRank($b->condition);
        $condDiff = abs($condA - $condB);
        $conditionScore = match ($condDiff) {
            0 => 1.0,
            1 => 0.7,
            2 => 0.4,
            default => 0.1,
        };

        // 4. Geographic Proximity (15%)
        $geoScore = ($a->city && $b->city && strcasecmp(trim($a->city), trim($b->city)) === 0) ? 1.0 : 0.3;

        // 5. Trust & Rating (15%)
        $userB = $b->user;
        $ratingPart = $userB ? (((float) $userB->rating) / 5.0) * 0.5 : 0.5;
        $swapPart = $userB ? (min($userB->successful_swaps, 20) / 20.0) * 0.5 : 0.2;
        $trustScore = min(1.0, $ratingPart + $swapPart);

        // Total weighted score
        $totalScore = (0.30 * $categoryScore)
            + (0.25 * $valueScore)
            + (0.15 * $conditionScore)
            + (0.15 * $geoScore)
            + (0.15 * $trustScore);

        return [
            'category_score' => round($categoryScore, 2),
            'value_score' => round($valueScore, 2),
            'condition_score' => round($conditionScore, 2),
            'geo_score' => round($geoScore, 2),
            'trust_score' => round($trustScore, 2),
            'total_score' => round($totalScore, 4),
        ];
    }

    private function conditionToRank(?string $cond): int
    {
        return match ($cond) {
            'new', 'جديد' => 4,
            'like_new', 'شبه جديد', 'ممتاز' => 3,
            'good', 'جيد' => 2,
            'fair', 'مقبول' => 1,
            default => 2,
        };
    }

    private function resolveMatchType(array $breakdown): string
    {
        if ($breakdown['category_score'] >= 0.8 && $breakdown['value_score'] >= 0.8) {
            return 'perfect';
        }
        if ($breakdown['category_score'] >= 0.5) {
            return 'high';
        }
        return 'standard';
    }
}
