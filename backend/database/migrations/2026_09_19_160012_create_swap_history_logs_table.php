<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('swap_history_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('swap_id')->nullable()->constrained('swap_offers')->nullOnDelete();
            $table->foreignId('user_a_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('user_b_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('item_a_id')->constrained('items')->cascadeOnDelete();
            $table->foreignId('item_b_id')->constrained('items')->cascadeOnDelete();
            $table->string('swap_type')->default('direct');
            $table->decimal('cash_difference', 12, 2)->default(0.00);
            $table->foreignId('cash_payer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('completed_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('swap_history_logs');
    }
};
