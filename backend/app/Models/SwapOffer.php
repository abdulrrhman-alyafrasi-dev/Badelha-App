<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class SwapOffer extends Model
{
    protected $fillable = [
        'sender_id',
        'receiver_id',
        'offered_item_id',
        'requested_item_id',
        'status',
        'cash_difference',
        'cash_payer_id',
        'meeting_location',
        'meeting_time',
        'meeting_status',
        'sender_safety_confirmed',
        'receiver_safety_confirmed',
        'cancellation_reason',
        'notes',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'cash_difference' => 'decimal:2',
            'sender_safety_confirmed' => 'boolean',
            'receiver_safety_confirmed' => 'boolean',
            'meeting_time' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    public function offeredItem(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'offered_item_id');
    }

    public function requestedItem(): BelongsTo
    {
        return $this->belongsTo(Item::class, 'requested_item_id');
    }

    public function cashPayer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'cash_payer_id');
    }

    public function rating(): HasOne
    {
        return $this->hasOne(Rating::class);
    }
}
