<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Item;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CircularSwapApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_finds_triangular_circular_swaps(): void
    {
        $catA = Category::create(['name' => 'إلكترونيات', 'is_active' => true]);
        $catB = Category::create(['name' => 'أثاث', 'is_active' => true]);
        $catC = Category::create(['name' => 'ألعاب', 'is_active' => true]);

        $userA = User::factory()->create(['status' => 'active']);
        $userB = User::factory()->create(['status' => 'active']);
        $userC = User::factory()->create(['status' => 'active']);

        $itemA = Item::create([
            'user_id' => $userA->id,
            'category_id' => $catA->id,
            'wanted_category_id' => $catB->id,
            'title' => 'لابتوب ديل',
            'estimated_value' => 500,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        $itemB = Item::create([
            'user_id' => $userB->id,
            'category_id' => $catB->id,
            'wanted_category_id' => $catC->id,
            'title' => 'طقم صالون',
            'estimated_value' => 500,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        $itemC = Item::create([
            'user_id' => $userC->id,
            'category_id' => $catC->id,
            'wanted_category_id' => $catA->id,
            'title' => 'بلايستيشن 5',
            'estimated_value' => 500,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/items/' . $itemA->id . '/circular-swaps');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['item_a', 'item_b', 'item_c', 'confidence_score'],
                ],
            ]);

        $this->assertCount(1, $response->json('data'));
    }
}
