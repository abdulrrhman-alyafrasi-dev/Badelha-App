<?php

namespace Tests\Unit;

use App\Models\Category;
use App\Models\Item;
use App\Models\User;
use App\Services\MatchingService;
use Tests\TestCase;

class MatchingEngineTest extends TestCase
{
    public function test_calculates_5_criteria_matching_score_accurately(): void
    {
        $matchingService = new MatchingService();

        $catPhone = new Category(['id' => 1, 'name' => 'هواتف']);
        $catLaptop = new Category(['id' => 2, 'name' => 'لابتوبات']);

        $userA = new User(['id' => 1, 'rating' => 5.00, 'successful_swaps' => 20]);
        $userB = new User(['id' => 2, 'rating' => 4.80, 'successful_swaps' => 10]);

        $itemA = new Item([
            'id' => 10,
            'user_id' => 1,
            'category_id' => 1,
            'wanted_category_id' => 2,
            'estimated_value' => 500.00,
            'city' => 'صنعاء',
            'condition' => 'like_new',
        ]);
        $itemA->setRelation('user', $userA);

        $itemB = new Item([
            'id' => 20,
            'user_id' => 2,
            'category_id' => 2,
            'wanted_category_id' => 1,
            'estimated_value' => 500.00,
            'city' => 'صنعاء',
            'condition' => 'like_new',
        ]);
        $itemB->setRelation('user', $userB);

        $breakdown = $matchingService->calculateScore($itemA, $itemB);

        // Category score: 1.0 (exact mutual match) -> 0.30
        // Value score: 1.0 (500 vs 500) -> 0.25
        // Condition score: 1.0 (like_new vs like_new) -> 0.15
        // Geo score: 1.0 (صنعاء vs صنعاء) -> 0.15
        // Trust score: rating & swaps -> ~0.11
        $this->assertGreaterThanOrEqual(0.90, $breakdown['total_score']);
        $this->assertEquals(1.0, $breakdown['category_score']);
        $this->assertEquals(1.0, $breakdown['value_score']);
        $this->assertEquals(1.0, $breakdown['condition_score']);
        $this->assertEquals(1.0, $breakdown['geo_score']);
    }
}
