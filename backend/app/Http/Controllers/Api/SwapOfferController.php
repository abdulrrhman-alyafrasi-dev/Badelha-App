<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSwapOfferRequest;
use App\Http\Resources\SwapOfferResource;
use App\Models\Item;
use App\Models\Notification;
use App\Models\SwapHistoryLog;
use App\Models\SwapOffer;
use App\Services\TrustService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SwapOfferController extends Controller
{
    public function __construct(private readonly TrustService $trustService) {}

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $sentOffers = SwapOffer::with(['receiver', 'offeredItem', 'requestedItem'])
            ->where('sender_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();
        $receivedOffers = SwapOffer::with(['sender', 'offeredItem', 'requestedItem'])
            ->where('receiver_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'sent' => SwapOfferResource::collection($sentOffers),
                'received' => SwapOfferResource::collection($receivedOffers),
            ],
        ]);
    }

    public function store(StoreSwapOfferRequest $request): JsonResponse
    {
        $user = $request->user();
        $offeredItem = Item::findOrFail($request->input('offered_item_id'));
        $requestedItem = Item::findOrFail($request->input('requested_item_id'));

        if ($offeredItem->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'المنتج المعروض للمقايضة لا ينتمي إليك.',
            ], 403);
        }

        if ($requestedItem->user_id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكنك تقديم عرض مقايضة على منتجك الخاص.',
            ], 422);
        }

        $offer = SwapOffer::create([
            'sender_id' => $user->id,
            'receiver_id' => $requestedItem->user_id,
            'offered_item_id' => $offeredItem->id,
            'requested_item_id' => $requestedItem->id,
            'status' => 'pending',
            'cash_difference' => $request->input('cash_difference', 0.00),
            'cash_payer_id' => $request->input('cash_payer_id'),
            'meeting_location' => $request->input('meeting_location'),
            'meeting_time' => $request->input('meeting_time'),
            'notes' => $request->input('notes'),
        ]);

        // Send notification to receiver
        Notification::create([
            'user_id' => $requestedItem->user_id,
            'title' => 'عرض مقايضة جديد 🎁',
            'body' => "قدم {$user->name} عرضاً لمقايضة منتجك [{$requestedItem->title}] بـ [{$offeredItem->title}]",
            'type' => 'swap_offer',
            'data' => ['offer_id' => $offer->id],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال عرض المقايضة بنجاح',
            'data' => new SwapOfferResource($offer->load(['sender', 'receiver', 'offeredItem', 'requestedItem'])),
        ], 201);
    }

    public function updateStatus(Request $request, SwapOffer $swapOffer): JsonResponse
    {
        $offer = $swapOffer;
        $user = $request->user();

        $request->validate([
            'status' => ['required', 'in:accepted,rejected,cancelled,completed'],
            'cancellation_reason' => ['nullable', 'string'],
        ]);

        $newStatus = $request->input('status');

        if ($newStatus === 'accepted' && (int) $offer->receiver_id !== (int) $user->id) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        if ($newStatus === 'rejected' && (int) $offer->receiver_id !== (int) $user->id) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        if ($newStatus === 'completed' && (int) $offer->sender_id !== (int) $user->id && (int) $offer->receiver_id !== (int) $user->id && !$user->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        if ($newStatus === 'cancelled' && (int) $offer->sender_id !== (int) $user->id && (int) $offer->receiver_id !== (int) $user->id && !$user->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        $offer->status = $newStatus;
        if ($request->filled('cancellation_reason')) {
            $offer->cancellation_reason = $request->input('cancellation_reason');
        }

        if ($newStatus === 'completed') {
            $offer->completed_at = now();

            // Mark items as swapped
            $offer->offeredItem->update(['status' => 'swapped']);
            $offer->requestedItem->update(['status' => 'swapped']);

            // Update user swap stats
            $offer->sender->increment('total_swaps');
            $offer->sender->increment('successful_swaps');
            $offer->receiver->increment('total_swaps');
            $offer->receiver->increment('successful_swaps');

            // Log history
            SwapHistoryLog::create([
                'swap_id' => $offer->id,
                'user_a_id' => $offer->sender_id,
                'user_b_id' => $offer->receiver_id,
                'item_a_id' => $offer->offered_item_id,
                'item_b_id' => $offer->requested_item_id,
                'swap_type' => 'direct',
                'cash_difference' => $offer->cash_difference,
                'cash_payer_id' => $offer->cash_payer_id,
                'completed_at' => now(),
            ]);

            $this->trustService->recalculateUserTrust($offer->sender);
            $this->trustService->recalculateUserTrust($offer->receiver);
        }

        $offer->save();

        // Notify other party
        $recipientId = ($offer->sender_id === $user->id) ? $offer->receiver_id : $offer->sender_id;
        Notification::create([
            'user_id' => $recipientId,
            'title' => 'تحديث في حالة عرض المقايضة 🔄',
            'body' => "تم تحديث حالة العرض إلى: {$newStatus}",
            'type' => 'swap_status',
            'data' => ['offer_id' => $offer->id, 'status' => $newStatus],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث حالة العرض بنجاح',
            'data' => new SwapOfferResource($offer->fresh(['sender', 'receiver', 'offeredItem', 'requestedItem'])),
        ]);
    }

    public function confirmSafety(Request $request, SwapOffer $swapOffer): JsonResponse
    {
        $offer = $swapOffer;
        $user = $request->user();

        if ($offer->sender_id === $user->id) {
            $offer->sender_safety_confirmed = true;
        } elseif ($offer->receiver_id === $user->id) {
            $offer->receiver_safety_confirmed = true;
        } else {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        // If both confirmed, mark meeting confirmed
        if ($offer->sender_safety_confirmed && $offer->receiver_safety_confirmed) {
            $offer->meeting_status = 'confirmed';
        }

        $offer->save();

        return response()->json([
            'success' => true,
            'message' => 'تم تأكيد إجراءات السلامة والأمان بنجاح',
            'data' => new SwapOfferResource($offer->fresh()),
        ]);
    }
}
