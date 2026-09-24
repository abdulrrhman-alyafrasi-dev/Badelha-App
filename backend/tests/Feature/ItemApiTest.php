<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Item;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ItemApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_available_marketplace_items(): void
    {
        $category = Category::create(['name' => 'إلكترونيات', 'is_active' => true]);
        $user = User::factory()->create(['status' => 'active']);

        Item::create([
            'user_id' => $user->id,
            'category_id' => $category->id,
            'title' => 'لابتوب ديل XPS',
            'estimated_value' => 800.00,
            'city' => 'صنعاء',
            'status' => 'available',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/items');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'title', 'estimated_value', 'city', 'status'],
                ],
            ]);
    }

    public function test_authenticated_user_can_create_item(): void
    {
        $user = User::factory()->create(['status' => 'active']);
        $category = Category::create(['name' => 'هواتف', 'is_active' => true]);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/items', [
                'category_id' => $category->id,
                'title' => 'آيفون 15 برو',
                'description' => 'هاتف بحالة الوكالة',
                'estimated_value' => 1100.00,
                'city' => 'عدن',
                'condition' => 'like_new',
                'swap_type' => 'exact_match',
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.title', 'آيفون 15 برو');

        $this->assertDatabaseHas('items', [
            'title' => 'آيفون 15 برو',
            'user_id' => $user->id,
        ]);
    }
}
