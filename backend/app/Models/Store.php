<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Store extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'bio',
        'logo_url',
        'cover_url',
        'city',
        'rating',
        'total_swaps',
        'phone',
        'commercial_register',
        'is_verified',
    ];

    protected function casts(): array
    {
        return [
            'rating' => 'decimal:2',
            'total_swaps' => 'integer',
            'is_verified' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(Item::class);
    }
}
