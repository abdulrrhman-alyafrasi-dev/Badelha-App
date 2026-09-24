<?php

namespace App\Services;

use App\Models\Item;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\Request;

class ItemService
{
    /**
     * Search and paginate available marketplace items.
     */
    public function getAvailableItems(Request $request, int $perPage = 20): LengthAwarePaginator
    {
        $query = Item::with(['user', 'category', 'wantedCategory', 'store'])
            ->where('status', 'available')
            ->where('is_active', true);

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->input('category_id'));
        }

        if ($request->filled('city') && $request->input('city') !== 'الكل' && $request->input('city') !== 'all') {
            $query->where('city', $request->input('city'));
        }

        if ($request->filled('condition')) {
            $query->where('condition', $request->input('condition'));
        }

        if ($request->filled('swap_type')) {
            $query->where('swap_type', $request->input('swap_type'));
        }

        if ($request->filled('min_value')) {
            $query->where('estimated_value', '>=', $request->input('min_value'));
        }

        if ($request->filled('max_value')) {
            $query->where('estimated_value', '<=', $request->input('max_value'));
        }

        if ($request->filled('search')) {
            $search = '%' . $request->input('search') . '%';
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', $search)
                  ->orWhere('description', 'like', $search)
                  ->orWhere('wanted_description', 'like', $search);
            });
        }

        return $query->orderBy('last_refresh_at', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->input('per_page', $perPage));
    }

    /**
     * Get all items belonging to a specific user.
     */
    public function getItemsByUser(User $user): Collection
    {
        return Item::with(['category', 'wantedCategory'])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Create a new item listing.
     */
    public function createItem(User $user, array $data): Item
    {
        $data['user_id'] = $user->id;
        $data['status'] = 'available';
        $data['is_active'] = true;
        $data['last_refresh_at'] = now();
        $data['expires_at'] = now()->addDays(30);

        $item = Item::create($data);

        if (!empty($data['images']) && is_array($data['images'])) {
            foreach ($data['images'] as $index => $imagePath) {
                \App\Models\ItemImage::create([
                    'item_id' => $item->id,
                    'image_url' => $imagePath,
                    'is_primary' => $index === 0,
                    'sort_order' => $index,
                ]);
            }
        }

        return $item;
    }

    /**
     * Update an existing item.
     */
    public function updateItem(Item $item, array $data): Item
    {
        $item->update($data);

        if (isset($data['images']) && is_array($data['images'])) {
            \App\Models\ItemImage::where('item_id', $item->id)->delete();
            foreach ($data['images'] as $index => $imagePath) {
                \App\Models\ItemImage::create([
                    'item_id' => $item->id,
                    'image_url' => $imagePath,
                    'is_primary' => $index === 0,
                    'sort_order' => $index,
                ]);
            }
        }

        return $item->fresh(['user', 'category', 'itemImages']);
    }

    /**
     * Delete an item.
     */
    public function deleteItem(Item $item): bool
    {
        return (bool) $item->delete();
    }

    /**
     * Refresh an item listing priority and expiration.
     */
    public function refreshItem(Item $item): Item
    {
        $item->increment('refresh_count');
        $item->update([
            'last_refresh_at' => now(),
            'expires_at' => now()->addDays(30),
        ]);

        return $item->fresh();
    }
}
