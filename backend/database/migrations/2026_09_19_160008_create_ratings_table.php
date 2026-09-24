<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('swap_offer_id')->nullable()->constrained('swap_offers')->nullOnDelete();
            $table->foreignId('rater_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('rated_user_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('score', 3, 2);
            $table->text('comment')->nullable();
            $table->timestamps();

            $table->index(['rated_user_id', 'score']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
