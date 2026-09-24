<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ItemResource;
use App\Models\Favorite;
use App\Models\Item;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $favorites = Favorite::with('item.user', 'item.category')
            ->where('user_id', $user->id)
            ->get()
            ->pluck('item');

        return response()->json([
            'success' => true,
            'data' => ItemResource::collection($favorites),
        ]);
    }

    public function toggle(Request $request, Item $item): JsonResponse
    {
        $user = $request->user();

        $existing = Favorite::where('user_id', $user->id)
            ->where('item_id', $item->id)
            ->first();

        if ($existing) {
            $existing->delete();
            $isFavorited = false;
        } else {
            Favorite::create([
                'user_id' => $user->id,
                'item_id' => $item->id,
            ]);
            $isFavorited = true;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'item_id' => (string) $item->id,
                'is_favorited' => $isFavorited,
            ],
        ]);
    }
}
