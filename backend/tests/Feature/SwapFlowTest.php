<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Item;
use App\Models\SwapOffer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SwapFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_complete_swap_flow_and_audit_history(): void
    {
        $cat = Category::create(['name' => 'عام', 'is_active' => true]);
        $userA = User::factory()->create(['status' => 'active', 'total_swaps' => 0, 'successful_swaps' => 0]);
        $userB = User::factory()->create(['status' => 'active', 'total_swaps' => 0, 'successful_swaps' => 0]);

        $itemA = Item::create([
            'user_id' => $userA->id,
            'category_id' => $cat->id,
            'title' => 'كاميرا كانون',
            'estimated_value' => 300.00,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        $itemB = Item::create([
            'user_id' => $userB->id,
            'category_id' => $cat->id,
            'title' => 'ساعة ذكية',
            'estimated_value' => 280.00,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        // User A sends offer to User B
        $createResponse = $this->actingAs($userA, 'sanctum')
            ->postJson('/api/v1/swap-offers', [
                'offered_item_id' => $itemA->id,
                'requested_item_id' => $itemB->id,
                'cash_difference' => 20.00,
            ]);

        $createResponse->assertStatus(201);
        $offerId = $createResponse->json('data.id');

        // User B accepts offer
        $acceptResponse = $this->actingAs($userB, 'sanctum')
            ->patchJson("/api/v1/swap-offers/{$offerId}/status", [
                'status' => 'accepted',
            ]);

        $acceptResponse->assertStatus(200)
            ->assertJsonPath('data.status', 'accepted');

        // Complete the swap
        $completeResponse = $this->actingAs($userB, 'sanctum')
            ->patchJson("/api/v1/swap-offers/{$offerId}/status", [
                'status' => 'completed',
            ]);

        $completeResponse->assertStatus(200)
            ->assertJsonPath('data.status', 'completed');

        // Verify items marked swapped
        $this->assertDatabaseHas('items', ['id' => $itemA->id, 'status' => 'swapped']);
        $this->assertDatabaseHas('items', ['id' => $itemB->id, 'status' => 'swapped']);

        // Verify history log created
        $this->assertDatabaseHas('swap_history_logs', [
            'swap_id' => $offerId,
            'user_a_id' => $userA->id,
            'user_b_id' => $userB->id,
        ]);

        // Verify user swaps count incremented
        $this->assertEquals(1, $userA->fresh()->successful_swaps);
        $this->assertEquals(1, $userB->fresh()->successful_swaps);
    }
}
