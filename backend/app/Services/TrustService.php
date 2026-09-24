<?php

namespace App\Services;

use App\Models\Rating;
use App\Models\User;

class TrustService
{
    public function recalculateUserTrust(User $user): void
    {
        $ratings = Rating::where('rated_user_id', $user->id)->get();

        $avgRating = $ratings->isNotEmpty() ? $ratings->avg('score') : 5.00;
        $totalSwaps = $user->total_swaps;
        $successfulSwaps = $user->successful_swaps;

        // Trust score calculation: base (50) + verified (20) + rating ratio (20) + completion ratio (10)
        $score = 50;
        if ($user->is_verified) {
            $score += 20;
        }

        $score += (int) (($avgRating / 5.0) * 20);

        if ($totalSwaps > 0) {
            $completionRatio = $successfulSwaps / $totalSwaps;
            $score += (int) ($completionRatio * 10);
        } else {
            $score += 10;
        }

        $user->update([
            'rating' => round($avgRating, 2),
            'trust_score' => min(100, max(0, $score)),
        ]);
    }
}
