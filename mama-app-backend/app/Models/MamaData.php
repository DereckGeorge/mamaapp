<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="MamaData",
 *     required={"user_id", "age_group", "due_date", "gestational_period"},
 *     @OA\Property(
 *         property="id",
 *         type="integer",
 *         format="int64",
 *         example=1,
 *         description="The unique identifier of the mama data record"
 *     ),
 *     @OA\Property(
 *         property="user_id",
 *         type="integer",
 *         format="int64",
 *         example=1,
 *         description="The ID of the user this data belongs to"
 *     ),
 *     @OA\Property(
 *         property="first_child",
 *         type="boolean",
 *         example=true,
 *         description="Whether this is the first child"
 *     ),
 *     @OA\Property(
 *         property="age_group",
 *         type="string",
 *         enum={"18-24 years old", "25-34 years old", "35-44 years old", "44 years old or above"},
 *         example="25-34 years old",
 *         description="Mother's age group"
 *     ),
 *     @OA\Property(
 *         property="due_date",
 *         type="string",
 *         format="date",
 *         example="2024-12-31",
 *         description="Expected delivery date"
 *     ),
 *     @OA\Property(
 *         property="gestational_period",
 *         type="integer",
 *         minimum=1,
 *         maximum=42,
 *         example=28,
 *         description="Current pregnancy week (1-42 weeks)"
 *     ),
 *     @OA\Property(
 *         property="baby_gender",
 *         type="string",
 *         enum={"boy", "girl", "i don't know yet"},
 *         example="i don't know yet",
 *         description="Known or expected gender of the baby"
 *     ),
 *     @OA\Property(
 *         property="created_at",
 *         type="string",
 *         format="datetime",
 *         example="2024-03-13T00:00:00.000000Z",
 *         description="Timestamp when the record was created"
 *     ),
 *     @OA\Property(
 *         property="updated_at",
 *         type="string",
 *         format="datetime",
 *         example="2024-03-13T00:00:00.000000Z",
 *         description="Timestamp when the record was last updated"
 *     )
 * )
 */
class MamaData extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'first_child',
        'age_group',
        'due_date',
        'gestational_period',
        'baby_gender'
    ];

    protected $casts = [
        'first_child' => 'boolean',
        'due_date' => 'date',
        'gestational_period' => 'integer'
    ];

    /**
     * Get the user that owns the mama data.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}