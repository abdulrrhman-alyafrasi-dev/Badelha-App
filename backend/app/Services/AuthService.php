<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function register(array $data): array
    {
        $phone = $data['phone'] ?? null;
        $email = !empty($data['email']) ? $data['email'] : ($phone ? $phone . '@badelha.ye' : 'user_' . uniqid() . '@badelha.ye');

        $user = User::create([
            'name' => $data['name'],
            'email' => $email,
            'phone' => $phone,
            'password' => Hash::make($data['password']),
            'role' => $data['role'] ?? 'customer',
            'city' => $data['city'] ?? 'صنعاء',
            'bio' => $data['bio'] ?? null,
            'avatar' => $data['avatar'] ?? null,
            'status' => 'active',
            'is_verified' => false,
            'total_swaps' => 0,
            'successful_swaps' => 0,
            'rating' => 5.00,
            'trust_score' => 100,
            'last_seen_at' => now(),
        ]);

        $token = $user->createToken('badelha_mobile_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    public function login(string $login, string $password): array
    {
        $user = User::where('email', $login)->orWhere('phone', $login)->first();

        if (!$user || !Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['رقم الهاتف / البريد الإلكتروني أو كلمة المرور غير صحيحة.'],
            ]);
        }

        if ($user->status !== 'active') {
            throw ValidationException::withMessages([
                'login' => ['هذا الحساب معطل أو محظور من قبل الإدارة.'],
            ]);
        }

        $user->update(['last_seen_at' => now()]);
        $token = $user->createToken('badelha_mobile_token')->plainTextToken;

        return [
            'user' => $user->load('store'),
            'token' => $token,
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }
}
