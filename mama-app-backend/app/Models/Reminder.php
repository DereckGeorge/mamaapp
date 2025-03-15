<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="Reminder",
 *     required={"user_id", "type", "reminder_time"},
 *     @OA\Property(property="id", type="integer", format="int64", example=1),
 *     @OA\Property(property="user_id", type="integer", format="int64", example=1),
 *     @OA\Property(
 *         property="type",
 *         type="string",
 *         enum={"doctor's appointment", "medicine", "medical tests"},
 *         example="medicine"
 *     ),
 *     @OA\Property(
 *         property="appointment",
 *         type="string",
 *         example="visit therapist",
 *         nullable=true
 *     ),
 *     @OA\Property(
 *         property="reminder_time",
 *         type="string",
 *         format="date-time",
 *         example="2024-03-21 14:30:00"
 *     ),
 *     @OA\Property(
 *         property="dose_unit",
 *         type="string",
 *         enum={"tablets", "drops", "capsule"},
 *         example="tablets",
 *         nullable=true
 *     ),
 *     @OA\Property(
 *         property="medicine_details",
 *         type="object",
 *         nullable=true,
 *         @OA\Property(property="name", type="string", example="Vitamin D"),
 *         @OA\Property(property="dose", type="string", example="2")
 *     ),
 *     @OA\Property(
 *         property="created_at",
 *         type="string",
 *         format="date-time",
 *         example="2024-03-21T12:00:00Z"
 *     ),
 *     @OA\Property(
 *         property="updated_at",
 *         type="string",
 *         format="date-time",
 *         example="2024-03-21T12:00:00Z"
 *     )
 * )
 */
class Reminder extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'appointment',
        'reminder_time',
        'dose_unit',
        'medicine_details'
    ];

    protected $casts = [
        'reminder_time' => 'datetime',
        'medicine_details' => 'array'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
} 