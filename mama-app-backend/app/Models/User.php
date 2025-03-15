<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Support\Facades\Hash;

/**
 * @OA\Schema(
 *     schema="User",
 *     required={"username", "password"},
 *     @OA\Property(property="id", type="integer", format="int64", example=1),
 *     @OA\Property(property="username", type="string", example="johndoe"),
 *     @OA\Property(property="email", type="string", format="email", example="john@example.com", nullable=true),
 *     @OA\Property(property="phone_number", type="string", example="1234567890", nullable=true),
 *     @OA\Property(property="created_at", type="string", format="datetime", example="2023-01-01T00:00:00.000000Z"),
 *     @OA\Property(property="updated_at", type="string", format="datetime", example="2023-01-01T00:00:00.000000Z")
 * )
 */
class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'username',
        'email',
        'phone_number',
        'password',
        'image',
        'remember_token'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    /**
     * The attributes that should be set when creating a new instance.
     *
     * @var array
     */
    protected $attributes = [
        'image' => 'image/default.png'
    ];

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }

    /**
     * Hash the password when setting it
     */
    public function setPasswordAttribute($value)
    {
        if ($value) {
            $this->attributes['password'] = Hash::make($value);
        }
    }

    /**
     * Get user details by ID
     *
     * @param int $userId
     * @return User|null
     */
    public static function getUserDetails($userId)
    {
        return self::where('id', $userId)
            ->select(['id', 'username', 'email', 'phone_number', 'created_at', 'updated_at'])
            ->first();
    }

    /**
     * Update user details by ID
     *
     * @param int $userId
     * @param array $data
     * @return User|null
     */
    public static function updateUserDetails($userId, array $data)
    {
        $user = self::find($userId);
        if ($user) {
            $user->update($data);
            return self::getUserDetails($userId);
        }
        return null;
    }
}