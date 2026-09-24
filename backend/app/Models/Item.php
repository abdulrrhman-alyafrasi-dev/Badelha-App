<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Item extends Model
{
    protected $fillable = [
        'user_id',
        'category_id',
        'store_id',
        'title',
        'description',
        'estimated_value',
        'cash_difference',
        'min_value',
        'max_value',
        'city',
        'condition',
        'swap_type',
        'wanted_category_id',
        'wanted_description',
        'status',
        'is_active',
        'view_count',
        'swap_count',
        'refresh_count',
        'last_refresh_at',
        'expires_at',
        'images',
    ];

    protected function casts(): array
    {
        return [
            'estimated_value' => 'decimal:2',
            'cash_difference' => 'decimal:2',
            'min_value' => 'decimal:2',
            'max_value' => 'decimal:2',
            'is_active' => 'boolean',
            'view_count' => 'integer',
            'swap_count' => 'integer',
            'refresh_count' => 'integer',
            'last_refresh_at' => 'datetime',
            'expires_at' => 'datetime',
            'images' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function wantedCategory(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'wanted_category_id');
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function itemImages(): HasMany
    {
        return $this->hasMany(ItemImage::class)->orderBy('sort_order');
    }

    public function wantedItems(): HasMany
    {
        return $this->hasMany(WantedItem::class);
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    public function scopeAvailable($query)
    {
        return $query->where('status', 'available')->where('is_active', true);
    }
}
