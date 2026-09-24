<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AdminBanner extends Model
{
    protected $fillable = [
        'title',
        'image_url',
        'target_url',
        'is_active',
        'priority',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'priority' => 'integer',
            'expires_at' => 'datetime',
        ];
    }
}
