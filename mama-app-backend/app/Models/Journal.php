<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Journal",
 *     required={"user_id", "content"},
 *     @OA\Property(property="id", type="integer", format="int64", example=1),
 *     @OA\Property(property="user_id", type="integer", format="int64", example=1),
 *     @OA\Property(property="content", type="string", example="Today I felt the baby kick for the first time!"),
 *     @OA\Property(property="created_at", type="string", format="datetime", example="2024-03-21T12:00:00Z"),
 *     @OA\Property(property="updated_at", type="string", format="datetime", example="2024-03-21T12:00:00Z")
 * )
 */
class Journal extends Model
{
    protected $fillable = [
        'user_id',
        'content'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
} 