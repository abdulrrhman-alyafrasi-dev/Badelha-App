<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && $user->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'الحساب معطل أو محظور. يرجى التواصل مع الدعم الفني.',
                'status' => $user->status,
            ], 403);
        }

        return $next($request);
    }
}
