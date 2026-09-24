<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSwapOfferRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'offered_item_id' => ['required', 'exists:items,id'],
            'requested_item_id' => ['required', 'exists:items,id', 'different:offered_item_id'],
            'cash_difference' => ['nullable', 'numeric'],
            'cash_payer_id' => ['nullable', 'exists:users,id'],
            'meeting_location' => ['nullable', 'string', 'max:255'],
            'meeting_time' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
        ];
    }
}
