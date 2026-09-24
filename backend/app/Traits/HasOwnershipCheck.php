<?php

namespace App\Traits;

use App\Models\Item;
use App\Models\User;

trait HasOwnershipCheck
{
    /**
     * Check if the given user owns the item or has admin privileges.
     */
    protected function canManageItem(User $user, Item $item): bool
    {
        return (string) $item->user_id === (string) $user->id || $user->isAdmin();
    }
}
