<?php

use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\ItemController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\SwapOfferController;
use App\Http\Middleware\EnsureUserIsActive;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // Public Auth
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    // Public Browsing
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/{category}', [CategoryController::class, 'show']);
    Route::get('/items', [ItemController::class, 'index']);
    Route::get('/items/{item}', [ItemController::class, 'show']);
    Route::get('/items/{item}/matches', [ItemController::class, 'getMatches']);
    Route::get('/items/{item}/circular-swaps', [ItemController::class, 'getCircularSwaps']);
    Route::get('/stores', [StoreController::class, 'index']);
    Route::get('/stores/{store}', [StoreController::class, 'show']);
    Route::get('/banners', [BannerController::class, 'index']);

    // Authenticated Routes
    Route::middleware(['auth:sanctum', EnsureUserIsActive::class])->group(function () {
        // User Profile & Session
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::patch('/auth/profile', [AuthController::class, 'updateProfile']);

        // Items Management
        Route::get('/my-items', [ItemController::class, 'myItems']);
        Route::post('/items', [ItemController::class, 'store']);
        Route::put('/items/{item}', [ItemController::class, 'update']);
        Route::delete('/items/{item}', [ItemController::class, 'destroy']);
        Route::post('/items/{item}/refresh', [ItemController::class, 'refresh']);

        // Swap Offers
        Route::get('/swap-offers', [SwapOfferController::class, 'index']);
        Route::post('/swap-offers', [SwapOfferController::class, 'store']);
        Route::patch('/swap-offers/{swapOffer}/status', [SwapOfferController::class, 'updateStatus']);
        Route::post('/swap-offers/{swapOffer}/confirm-safety', [SwapOfferController::class, 'confirmSafety']);

        // Stores
        Route::post('/stores', [StoreController::class, 'store']);

        // Ratings & Favorites
        Route::post('/ratings', [RatingController::class, 'store']);
        Route::get('/favorites', [FavoriteController::class, 'index']);
        Route::post('/favorites/{item}/toggle', [FavoriteController::class, 'toggle']);

        // Notifications
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

        // Admin Routes
        Route::prefix('admin')->group(function () {
            Route::get('/stats', [AdminDashboardController::class, 'stats']);
            Route::get('/users', [AdminDashboardController::class, 'users']);
            Route::patch('/users/{user}/status', [AdminDashboardController::class, 'toggleUserStatus']);
        });
    });
});
