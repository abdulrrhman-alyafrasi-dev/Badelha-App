<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ItemResource;
use App\Http\Resources\StoreResource;
use App\Models\Store;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $stores = Store::with('user')
            ->orderBy('rating', 'desc')
            ->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => StoreResource::collection($stores),
        ]);
    }

    public function show(Store $store): JsonResponse
    {
        $items = $store->items()
            ->where('status', 'available')
            ->where('is_active', true)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'store' => new StoreResource($store->load('user')),
                'items' => ItemResource::collection($items),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->store) {
            return response()->json([
                'success' => false,
                'message' => 'لديك متجر مسجل بالفعل.',
            ], 422);
        }

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'bio' => ['nullable', 'string'],
            'logo_url' => ['nullable', 'string'],
            'cover_url' => ['nullable', 'string'],
            'city' => ['required', 'string'],
            'phone' => ['nullable', 'string'],
            'commercial_register' => ['nullable', 'string'],
        ]);

        $validated['user_id'] = $user->id;
        $validated['rating'] = 5.00;
        $validated['total_swaps'] = 0;

        $store = Store::create($validated);
        $user->update(['role' => 'merchant']);

        return response()->json([
            'success' => true,
            'message' => 'تم إنشاء متجر التاجر بنجاح',
            'data' => new StoreResource($store),
        ], 201);
    }
}
