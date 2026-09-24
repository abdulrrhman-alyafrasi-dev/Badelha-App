<?php

namespace App\Http\Resources;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $images = $this->images;
        if (empty($images) && $this->relationLoaded('itemImages')) {
            $images = $this->itemImages->pluck('image_url')->toArray();
        }

        // Calculate listing expiry dynamically
        $effectiveDate = $this->last_refresh_at ?? $this->created_at ?? now();
        $expiresAt = $this->expires_at ?? Carbon::parse($effectiveDate)->addDays(30);
        $daysRemaining = max(0, (int) now()->diffInDays($expiresAt, false));
        $isExpired = now()->greaterThan($expiresAt);

        return [
            'id' => (string) $this->id,
            'user_id' => (string) $this->user_id,
            'category_id' => (string) $this->category_id,
            'store_id' => $this->store_id ? (string) $this->store_id : null,
            'title' => $this->title,
            'description' => $this->description,
            'estimated_value' => (float) $this->estimated_value,
            'cash_difference' => (float) $this->cash_difference,
            'min_value' => $this->min_value ? (float) $this->min_value : null,
            'max_value' => $this->max_value ? (float) $this->max_value : null,
            'city' => $this->city,
            'condition' => $this->condition,
            'swap_type' => $this->swap_type,
            'wanted_category_id' => $this->wanted_category_id ? (string) $this->wanted_category_id : null,
            'wanted_description' => $this->wanted_description,
            'status' => $this->status,
            'is_active' => (bool) $this->is_active,
            'view_count' => (int) $this->view_count,
            'swap_count' => (int) $this->swap_count,
            'refresh_count' => (int) $this->refresh_count,
            'last_refresh_at' => $this->last_refresh_at?->toIso8601String(),
            'expires_at' => $expiresAt->toIso8601String(),
            'days_remaining' => $daysRemaining,
            'is_expired' => $isExpired,
            'images' => $images ?? [],
            'created_at' => $this->created_at?->toIso8601String(),
            'user' => new UserResource($this->whenLoaded('user')),
            'category' => new CategoryResource($this->whenLoaded('category')),
            'wanted_category' => new CategoryResource($this->whenLoaded('wantedCategory')),
            'store' => new StoreResource($this->whenLoaded('store')),
        ];
    }
}
