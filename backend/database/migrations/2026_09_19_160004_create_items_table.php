<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('category_id')->constrained('categories')->cascadeOnDelete();
            $table->foreignId('store_id')->nullable()->constrained('stores')->nullOnDelete();
            $table->string('title')->index();
            $table->text('description')->nullable();
            $table->decimal('estimated_value', 12, 2)->index();
            $table->decimal('cash_difference', 12, 2)->default(0.00);
            $table->decimal('min_value', 12, 2)->nullable();
            $table->decimal('max_value', 12, 2)->nullable();
            $table->string('city')->index();
            $table->string('condition')->default('like_new')->index();
            $table->string('swap_type')->default('exact_match')->index();
            $table->foreignId('wanted_category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->text('wanted_description')->nullable();
            $table->enum('status', ['available', 'reserved', 'swapped', 'hidden'])->default('available')->index();
            $table->boolean('is_active')->default(true)->index();
            $table->unsignedInteger('view_count')->default(0);
            $table->unsignedInteger('swap_count')->default(0);
            $table->unsignedInteger('refresh_count')->default(0);
            $table->timestamp('last_refresh_at')->nullable();
            $table->timestamp('expires_at')->nullable()->index();
            $table->jsonb('images')->nullable();
            $table->timestamps();

            $table->index(['status', 'is_active', 'city', 'category_id'], 'idx_items_feed_lookup');
            $table->index(['user_id', 'status'], 'idx_items_user_status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};
