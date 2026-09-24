<?php

namespace App\Traits;

use App\Models\Item;
use App\Models\User;

trait HasIdempotencyCheck
{
    /**
     * Check if a duplicate item was created by the same user within a short window.
     */
    protected function findRecentDuplicateItem(User $user, string $title, int $seconds = 10): ?Item
    {
        return Item::where('user_id', $user->id)
            ->where('title', $title)
            ->where('created_at', '>=', now()->subSeconds($seconds))
            ->first();
    }
}
