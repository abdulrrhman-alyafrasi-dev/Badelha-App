<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_successfully(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'محمد الحيمي',
            'email' => 'mohammed@test.com',
            'password' => 'secret123',
            'city' => 'صنعاء',
            'phone' => '770000000',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'email', 'city', 'role', 'trust_score'],
                    'token',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'mohammed@test.com',
            'name' => 'محمد الحيمي',
        ]);
    }

    public function test_user_can_login_and_retrieve_profile(): void
    {
        $user = User::factory()->create([
            'email' => 'login_user@test.com',
            'password' => bcrypt('password123'),
            'status' => 'active',
        ]);

        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => 'login_user@test.com',
            'password' => 'password123',
        ]);

        $loginResponse->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => ['user', 'token'],
            ]);

        $token = $loginResponse->json('data.token');

        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200)
            ->assertJsonPath('data.email', 'login_user@test.com');
    }

    public function test_banned_user_cannot_access_protected_routes(): void
    {
        $user = User::factory()->create([
            'email' => 'banned@test.com',
            'status' => 'banned',
        ]);

        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(403)
            ->assertJsonPath('status', 'banned');
    }

    public function test_user_can_logout_and_revoke_token(): void
    {
        $user = User::factory()->create(['status' => 'active']);
        $token = $user->createToken('logout_test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/logout');

        $response->assertStatus(200);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
        ]);
    }
}
