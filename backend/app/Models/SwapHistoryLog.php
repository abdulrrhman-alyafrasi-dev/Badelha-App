<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SwapHistoryLog extends Model
{
    protected $fillable = [
        'swap_id',
        'user_a_id',
        'user_b_id',
        'item_a_id',
        'item_b_id',
        'swap_type',
        'cash_difference',
        'cash_payer_id',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'cash_difference' => 'decimal:2',
            'completed_at' => 'datetime',
        ];
    }

    public function userA(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_a_id');
    }

    public function userB(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_b_id');
    }

    public function itemA(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'item_a_id');
    }

    public function itemB(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'item_b_id');
    }
}
