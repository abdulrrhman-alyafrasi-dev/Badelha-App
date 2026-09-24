<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateItemRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => ['sometimes', 'exists:categories,id'],
            'store_id' => ['nullable', 'exists:stores,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'estimated_value' => ['sometimes', 'numeric', 'min:0'],
            'cash_difference' => ['nullable', 'numeric'],
            'min_value' => ['nullable', 'numeric', 'min:0'],
            'max_value' => ['nullable', 'numeric', 'min:0'],
            'city' => ['sometimes', 'string', 'max:100'],
            'condition' => ['nullable', 'string'],
            'swap_type' => ['nullable', 'string'],
            'wanted_category_id' => ['nullable', 'exists:categories,id'],
            'wanted_description' => ['nullable', 'string'],
            'status' => ['nullable', 'in:available,reserved,swapped,hidden'],
            'is_active' => ['nullable', 'boolean'],
            'images' => ['nullable', 'array'],
            'images.*' => ['string'],
        ];
    }
}
