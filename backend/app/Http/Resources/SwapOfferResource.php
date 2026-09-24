<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SwapOfferResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'sender_id' => (string) $this->sender_id,
            'receiver_id' => (string) $this->receiver_id,
            'offered_item_id' => (string) $this->offered_item_id,
            'requested_item_id' => (string) $this->requested_item_id,
            'status' => $this->status,
            'cash_difference' => (float) $this->cash_difference,
            'cash_payer_id' => $this->cash_payer_id ? (string) $this->cash_payer_id : null,
            'meeting_location' => $this->meeting_location,
            'meeting_time' => $this->meeting_time?->toIso8601String(),
            'meeting_status' => $this->meeting_status,
            'sender_safety_confirmed' => (bool) $this->sender_safety_confirmed,
            'receiver_safety_confirmed' => (bool) $this->receiver_safety_confirmed,
            'cancellation_reason' => $this->cancellation_reason,
            'notes' => $this->notes,
            'completed_at' => $this->completed_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'sender' => new UserResource($this->whenLoaded('sender')),
            'receiver' => new UserResource($this->whenLoaded('receiver')),
            'offered_item' => new ItemResource($this->whenLoaded('offeredItem')),
            'requested_item' => new ItemResource($this->whenLoaded('requestedItem')),
        ];
    }
}
