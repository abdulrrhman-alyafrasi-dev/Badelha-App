<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'city' => $this->city,
            'bio' => $this->bio,
            'avatar' => $this->avatar,
            'status' => $this->status,
            'is_verified' => (bool) $this->is_verified,
            'total_swaps' => (int) $this->total_swaps,
            'successful_swaps' => (int) $this->successful_swaps,
            'rating' => (float) $this->rating,
            'trust_score' => (int) $this->trust_score,
            'last_seen_at' => $this->last_seen_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'store' => new StoreResource($this->whenLoaded('store')),
        ];
    }
}
