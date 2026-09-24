<?php

namespace App\Services;

use App\Models\Item;
use Illuminate\Support\Collection;

class CircularSwapService
{
    /**
     * Find 3-way triangular circular swap loops:
     * A gives to B, B gives to C, C gives to A.
     */
    public function findCircularSwapsForItem(Item $itemA): Collection
    {
        $userAId = $itemA->user_id;

        // Fetch all candidates from other users
        $availableItems = Item::with(['user', 'category', 'wantedCategory'])
            ->where('status', 'available')
            ->where('is_active', true)
            ->where('user_id', '!=', $userAId)
            ->get();

        $loops = collect();

        // 1. Items B that User A might want (Item B category matches Item A wanted category)
        $candidatesB = $availableItems->filter(function ($itemB) use ($itemA) {
            return $itemA->wanted_category_id && $itemB->category_id === $itemA->wanted_category_id;
        });

        foreach ($candidatesB as $itemB) {
            $userBId = $itemB->user_id;

            // 2. Items C that User B might want (Item C category matches Item B wanted category)
            $candidatesC = $availableItems->filter(function ($itemC) use ($itemB, $userAId, $userBId) {
                return $itemC->user_id !== $userAId
                    && $itemC->user_id !== $userBId
                    && $itemB->wanted_category_id
                    && $itemC->category_id === $itemB->wanted_category_id;
            });

            foreach ($candidatesC as $itemC) {
                // 3. Check loop closure: Does User C want Item A?
                $closesLoop = ($itemC->wanted_category_id && $itemA->category_id === $itemC->wanted_category_id)
                    || (!$itemC->wanted_category_id && abs((float)$itemC->estimated_value - (float)$itemA->estimated_value) <= 0.25 * (float)$itemC->estimated_value);

                if ($closesLoop) {
                    $totalValueDiff = abs((float)$itemA->estimated_value - (float)$itemB->estimated_value)
                        + abs((float)$itemB->estimated_value - (float)$itemC->estimated_value)
                        + abs((float)$itemC->estimated_value - (float)$itemA->estimated_value);

                    $loops->push([
                        'item_a' => $itemA,
                        'item_b' => $itemB,
                        'item_c' => $itemC,
                        'user_a' => $itemA->user,
                        'user_b' => $itemB->user,
                        'user_c' => $itemC->user,
                        'value_discrepancy' => round($totalValueDiff, 2),
                        'confidence_score' => 85,
                    ]);
                }
            }
        }

        return $loops->values();
    }
}
