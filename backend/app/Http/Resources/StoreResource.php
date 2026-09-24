<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'user_id' => (string) $this->user_id,
            'name' => $this->name,
            'bio' => $this->bio,
            'logo_url' => $this->logo_url,
            'cover_url' => $this->cover_url,
            'city' => $this->city,
            'rating' => (float) $this->rating,
            'total_swaps' => (int) $this->total_swaps,
            'phone' => $this->phone,
            'is_verified' => (bool) $this->is_verified,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
