<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminBannerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'title' => $this->title,
            'image_url' => $this->image_url,
            'target_url' => $this->target_url,
            'is_active' => (bool) $this->is_active,
            'priority' => (int) $this->priority,
            'expires_at' => $this->expires_at?->toIso8601String(),
        ];
    }
}
