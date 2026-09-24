<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreItemRequest;
use App\Http\Requests\UpdateItemRequest;
use App\Http\Resources\ItemResource;
use App\Models\Item;
use App\Services\CircularSwapService;
use App\Services\ItemService;
use App\Services\MatchingService;
use App\Traits\HasIdempotencyCheck;
use App\Traits\HasOwnershipCheck;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    use HasIdempotencyCheck, HasOwnershipCheck;

    public function __construct(
        private readonly ItemService $itemService,
        private readonly MatchingService $matchingService,
        private readonly CircularSwapService $circularSwapService
    ) {}


    public function index(Request $request): JsonResponse
    {
        $items = $this->itemService->getAvailableItems($request);

        return response()->json([
            'success' => true,
            'data' => ItemResource::collection($items),
            'meta' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'per_page' => $items->perPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function myItems(Request $request): JsonResponse
    {
        $items = $this->itemService->getItemsByUser($request->user());

        return response()->json([
            'success' => true,
            'data' => ItemResource::collection($items),
        ]);
    }

    public function store(StoreItemRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        // 🛡️ Debounce / Idempotency check: Prevent duplicate submissions within 10 seconds
        $existing = $this->findRecentDuplicateItem($user, $validated['title'], 10);
        if ($existing) {
            return response()->json([
                'success' => true,
                'message' => 'تم استلام طلب إضافة المنتج مسبقاً بنجاح.',
                'data' => new ItemResource($existing->load(['user', 'category'])),
            ], 200);
        }

        $item = $this->itemService->createItem($user, $validated);

        return response()->json([
            'success' => true,
            'message' => 'تم إضافة المنتج للمقايضة بنجاح',
            'data' => new ItemResource($item->load(['user', 'category'])),
        ], 201);
    }

    public function show(Item $item): JsonResponse
    {
        $item->increment('view_count');

        return response()->json([
            'success' => true,
            'data' => new ItemResource($item->load(['user', 'category', 'wantedCategory', 'store'])),
        ]);
    }

    public function update(UpdateItemRequest $request, Item $item): JsonResponse
    {
        if (!$this->canManageItem($request->user(), $item)) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بتعديل هذا المنتج.',
            ], 403);
        }

        $updated = $this->itemService->updateItem($item, $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث المنتج بنجاح',
            'data' => new ItemResource($updated),
        ]);
    }

    public function destroy(Request $request, Item $item): JsonResponse
    {
        if (!$this->canManageItem($request->user(), $item)) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بحذف هذا المنتج.',
            ], 403);
        }

        $this->itemService->deleteItem($item);

        return response()->json([
            'success' => true,
            'message' => 'تم حذف المنتج بنجاح',
        ]);
    }

    public function refresh(Request $request, Item $item): JsonResponse
    {
        if ((string) $item->user_id !== (string) $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'غير مصرح لك بتحديث هذا المنتج.',
            ], 403);
        }

        $refreshed = $this->itemService->refreshItem($item);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث أولوية ظهور الإعلان بنجاح',
            'data' => new ItemResource($refreshed),
        ]);
    }

    public function getMatches(Item $item): JsonResponse
    {
        $matches = $this->matchingService->findMatchesForItem($item);

        return response()->json([
            'success' => true,
            'data' => $matches->map(function ($match) {
                return [
                    'item' => new ItemResource($match['item']),
                    'score' => $match['score'],
                    'criteria_breakdown' => $match['criteria_breakdown'],
                    'match_type' => $match['match_type'],
                ];
            }),
        ]);
    }

    public function getCircularSwaps(Item $item): JsonResponse
    {
        $swaps = $this->circularSwapService->findCircularSwapsForItem($item);

        return response()->json([
            'success' => true,
            'data' => $swaps->map(function ($swap) {
                return [
                    'item_a' => new ItemResource($swap['item_a']),
                    'item_b' => new ItemResource($swap['item_b']),
                    'item_c' => new ItemResource($swap['item_c']),
                    'user_a' => $swap['user_a'] ? [
                        'id' => (string) $swap['user_a']->id,
                        'name' => $swap['user_a']->name,
                        'rating' => (float) $swap['user_a']->rating,
                        'city' => $swap['user_a']->city,
                    ] : null,
                    'user_b' => $swap['user_b'] ? [
                        'id' => (string) $swap['user_b']->id,
                        'name' => $swap['user_b']->name,
                        'rating' => (float) $swap['user_b']->rating,
                        'city' => $swap['user_b']->city,
                    ] : null,
                    'user_c' => $swap['user_c'] ? [
                        'id' => (string) $swap['user_c']->id,
                        'name' => $swap['user_c']->name,
                        'rating' => (float) $swap['user_c']->rating,
                        'city' => $swap['user_c']->city,
                    ] : null,
                    'value_discrepancy' => $swap['value_discrepancy'],
                    'confidence_score' => $swap['confidence_score'],
                ];
            }),
        ]);
    }
}
