<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\Item;
use App\Models\Report;
use App\Models\SwapHistoryLog;
use App\Models\SwapOffer;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    public function stats(Request $request): JsonResponse
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_users' => User::count(),
                'active_users' => User::where('status', 'active')->count(),
                'total_items' => Item::count(),
                'available_items' => Item::where('status', 'available')->count(),
                'total_swaps_completed' => SwapHistoryLog::count(),
                'pending_offers' => SwapOffer::where('status', 'pending')->count(),
                'pending_reports' => Report::where('status', 'pending')->count(),
            ],
        ]);
    }

    public function users(Request $request): JsonResponse
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        $users = User::orderBy('created_at', 'desc')
            ->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => UserResource::collection($users),
        ]);
    }

    public function toggleUserStatus(Request $request, User $user): JsonResponse
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['success' => false, 'message' => 'غير مصرح.'], 403);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:active,suspended,banned'],
        ]);

        $user->update(['status' => $validated['status']]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث حالة المستخدم بنجاح',
            'data' => new UserResource($user),
        ]);
    }
}
