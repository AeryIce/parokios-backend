<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'ok' => true,
        'app' => config('app.name'),
        'env' => app()->environment(),
        'time' => now()->toIso8601String(),
        'test' => 'branch-protection',
        allalalalalalala
    ]);
});
