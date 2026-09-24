<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('swap_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('receiver_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('offered_item_id')->constrained('items')->cascadeOnDelete();
            $table->foreignId('requested_item_id')->constrained('items')->cascadeOnDelete();
            $table->enum('status', ['pending', 'accepted', 'completed', 'cancelled', 'rejected'])->default('pending')->index();
            $table->decimal('cash_difference', 12, 2)->default(0.00);
            $table->foreignId('cash_payer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('meeting_location')->nullable();
            $table->timestamp('meeting_time')->nullable();
            $table->string('meeting_status')->default('pending');
            $table->boolean('sender_safety_confirmed')->default(false);
            $table->boolean('receiver_safety_confirmed')->default(false);
            $table->text('cancellation_reason')->nullable();
            $table->text('notes')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['sender_id', 'status'], 'idx_swap_sender_status');
            $table->index(['receiver_id', 'status'], 'idx_swap_receiver_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('swap_offers');
    }
};
