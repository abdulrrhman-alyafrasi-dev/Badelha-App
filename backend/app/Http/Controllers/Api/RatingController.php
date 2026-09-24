<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rating;
use App\Models\User;
use App\Services\TrustService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RatingController extends Controller
{
    public function __construct(private readonly TrustService $trustService) {}

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'swap_offer_id' => ['nullable', 'exists:swap_offers,id'],
            'rated_user_id' => ['required', 'exists:users,id', 'different:' . $user->id],
            'score' => ['required', 'numeric', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:500'],
        ]);

        $rating = Rating::create([
            'swap_offer_id' => $validated['swap_offer_id'] ?? null,
            'rater_id' => $user->id,
            'rated_user_id' => $validated['rated_user_id'],
            'score' => $validated['score'],
            'comment' => $validated['comment'] ?? null,
        ]);

        $ratedUser = User::findOrFail($validated['rated_user_id']);
        $this->trustService->recalculateUserTrust($ratedUser);

        return response()->json([
            'success' => true,
            'message' => 'تم إضافة التقييم بنجاح',
            'data' => $rating,
        ], 201);
    }
}
