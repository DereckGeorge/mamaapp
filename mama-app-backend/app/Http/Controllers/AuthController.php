<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Create a new AuthController instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth:api', ['except' => ['login', 'register', 'logout', 'updateUser', 'updateUserImage', 'getUserImage']]);
    }

    /**
     * @OA\Post(
     *     path="/auth/register",
     *     summary="Register a new user",
     *     description="Registers a new user with username, email or phone number",
     *     operationId="register",
     *     tags={"Authentication"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"username","password","password_confirmation"},
     *             @OA\Property(property="username", type="string", example="johndoe"),
     *             @OA\Property(
     *                 property="email",
     *                 type="string",
     *                 format="email",
     *                 example="john@example.com",
     *                 description="Email is required if phone_number is not provided"
     *             ),
     *             @OA\Property(
     *                 property="phone_number",
     *                 type="string",
     *                 example="+255123456789",
     *                 description="Phone number is required if email is not provided"
     *             ),
     *             @OA\Property(property="password", type="string", format="password", example="password123"),
     *             @OA\Property(property="password_confirmation", type="string", format="password", example="password123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="User registered successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User successfully registered"),
     *             @OA\Property(property="user", type="object",
     *                 @OA\Property(property="username", type="string", example="johndoe"),
     *                 @OA\Property(property="email", type="string", example="john@example.com"),
     *                 @OA\Property(property="phone_number", type="string", example="+255123456789"),
     *                 @OA\Property(property="updated_at", type="string", format="datetime"),
     *                 @OA\Property(property="created_at", type="string", format="datetime"),
     *                 @OA\Property(property="id", type="integer", example=1)
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="The given data was invalid."),
     *             @OA\Property(
     *                 property="errors",
     *                 type="object",
     *                 @OA\Property(
     *                     property="email",
     *                     type="array",
     *                     @OA\Items(type="string", example="The email has already been taken.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|string|between:3,100|unique:users',
            'email' => 'required_without:phone_number|nullable|string|email|max:100|unique:users',
            'phone_number' => 'required_without:email|nullable|string|unique:users',
            'password' => 'required|string|confirmed|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Ensure at least email or phone_number is provided
        if (empty($request->email) && empty($request->phone_number)) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => [
                    'login' => ['Either email or phone number is required']
                ]
            ], 422);
        }

        $user = User::create([
            'username' => $request->username,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'password' => $request->password // Will be hashed by the model
        ]);

        return response()->json([
            'message' => 'User successfully registered',
            'user' => $user
        ], 201);
    }

    /**
     * @OA\Post(
     *     path="/auth/login",
     *     summary="Login a user",
     *     description="Authenticates a user with email/phone and returns a JWT token",
     *     operationId="login",
     *     tags={"Authentication"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"login","password"},
     *             @OA\Property(
     *                 property="login",
     *                 type="string",
     *                 example="john@example.com or +255123456789",
     *                 description="Email or phone number"
     *             ),
     *             @OA\Property(property="password", type="string", format="password", example="password123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Login successful",
     *         @OA\JsonContent(
     *             @OA\Property(property="access_token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."),
     *             @OA\Property(property="token_type", type="string", example="bearer"),
     *             @OA\Property(property="expires_in", type="integer", example=3600),
     *             @OA\Property(
     *                 property="user",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="username", type="string", example="johndoe"),
     *                 @OA\Property(property="email", type="string", example="john@example.com"),
     *                 @OA\Property(property="phone_number", type="string", example="+255123456789")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Invalid credentials",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Invalid credentials")
     *         )
     *     )
     * )
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'login' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // Try to find user by email or phone number
        $user = User::where('email', $request->login)
                    ->orWhere('phone_number', $request->login)
                    ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = auth()->login($user);
        
        // Store token in remember_token field
        $user->remember_token = $token;
        $user->save();

        return $this->respondWithToken($token);
    }

    /**
     * @OA\Post(
     *     path="/auth/logout/{user_id}",
     *     summary="Logout a user",
     *     description="Logs out user by clearing their remember_token",
     *     operationId="logout",
     *     tags={"Authentication"},
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         description="ID of the user to logout",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successfully logged out",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Successfully logged out")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="User not found",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="User not found")
     *         )
     *     )
     * )
     */
    public function logout($user_id)
    {
        $user = User::find($user_id);
        
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Clear the remember token
        $user->remember_token = null;
        $user->save();
        
        return response()->json(['message' => 'Successfully logged out']);
    }

    /**
     * Get the token array structure.
     *
     * @param string $token
     * @return \Illuminate\Http\JsonResponse
     */
    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => config('jwt.ttl') * 60,
            'user' => auth()->user()
        ]);
    }

    /**
     * @OA\Get(
     *     path="/auth/user-profile",
     *     summary="Get authenticated user",
     *     description="Returns the currently authenticated user's data",
     *     operationId="userProfile",
     *     tags={"Authentication"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             @OA\Property(property="id", type="integer", example=1),
     *             @OA\Property(property="name", type="string", example="John Doe"),
     *             @OA\Property(property="email", type="string", example="john@example.com"),
     *             @OA\Property(property="created_at", type="string", format="datetime"),
     *             @OA\Property(property="updated_at", type="string", format="datetime")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Unauthenticated",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Unauthenticated")
     *         )
     *     )
     * )
     */
    public function userProfile()
    {
        return response()->json(auth()->user());
    }

    /**
     * @OA\Post(
     *     path="/auth/refresh",
     *     summary="Refresh token",
     *     description="Refreshes the current authentication token",
     *     operationId="refresh",
     *     tags={"Authentication"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Token successfully refreshed",
     *         @OA\JsonContent(
     *             @OA\Property(property="access_token", type="string", example="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."),
     *             @OA\Property(property="token_type", type="string", example="bearer"),
     *             @OA\Property(property="expires_in", type="integer", example=3600),
     *             @OA\Property(
     *                 property="user",
     *                 type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="name", type="string", example="John Doe"),
     *                 @OA\Property(property="email", type="string", example="john@example.com")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Unauthenticated",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="Unauthenticated")
     *         )
     *     )
     * )
     */
    public function refresh()
    {
        return $this->respondWithToken(auth()->refresh());
    }

    /**
     * @OA\Put(
     *     path="/users/{user_id}",
     *     summary="Update user profile",
     *     description="Updates a user's profile information. Only provided fields will be updated.",
     *     operationId="updateUser",
     *     tags={"Users"},
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\RequestBody(
     *         @OA\JsonContent(
     *             @OA\Property(property="username", type="string"),
     *             @OA\Property(property="email", type="string", format="email"),
     *             @OA\Property(property="phone_number", type="string"),
     *             @OA\Property(property="password", type="string", format="password"),
     *             @OA\Property(property="password_confirmation", type="string", format="password")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="User updated successfully"
     *     )
     * )
     */
    public function updateUser(Request $request, $user_id)
    {
        $user = User::find($user_id);
        
        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Only validate fields that are actually provided
        $rules = [];
        $inputData = array_filter($request->all(), function ($value) {
            return $value !== null && $value !== '';
        });

        if (isset($inputData['username'])) {
            $rules['username'] = 'string|between:3,100|unique:users,username,'.$user->id;
        }
        
        if (isset($inputData['email'])) {
            $rules['email'] = 'string|email|max:100|unique:users,email,'.$user->id;
        }
        
        if (isset($inputData['phone_number'])) {
            $rules['phone_number'] = 'string|unique:users,phone_number,'.$user->id;
        }

        if (!empty($rules)) {
            $validator = Validator::make($inputData, $rules);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'The given data was invalid.',
                    'errors' => $validator->errors()
                ], 422);
            }
        }

        // Validate password separately if provided
        if ($request->filled('password')) {
            $passwordValidator = Validator::make($request->all(), [
                'password' => 'required|string|confirmed|min:6'
            ]);

            if ($passwordValidator->fails()) {
                return response()->json([
                    'message' => 'The given data was invalid.',
                    'errors' => $passwordValidator->errors()
                ], 422);
            }
        }

        // Only update fields that were provided with non-empty values
        foreach ($inputData as $field => $value) {
            if ($field === 'password') {
                $user->password = bcrypt($value);
            } elseif (in_array($field, ['username', 'email', 'phone_number'])) {
                $user->$field = $value;
            }
        }

        $user->save();

        return response()->json([
            'message' => 'User updated successfully',
            'data' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'phone_number' => $user->phone_number
            ]
        ]);
    }

    /**
     * @OA\Post(
     *     path="/users/{user_id}/image",
     *     summary="Update user profile image",
     *     description="Updates user profile image",
     *     operationId="updateUserImage",
     *     tags={"Users"},
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         description="ID of the user",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 @OA\Property(
     *                     property="image",
     *                     type="string",
     *                     format="binary",
     *                     description="Image file"
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Image updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(property="message", type="string", example="Image updated successfully"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="image_path", type="string", example="image/profile123.png")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid image",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="error"),
     *             @OA\Property(property="message", type="string", example="Please upload a valid image")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="User not found",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="error"),
     *             @OA\Property(property="message", type="string", example="User not found")
     *         )
     *     )
     * )
     */
    public function updateUserImage(Request $request, $user_id)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Please upload a valid image',
                'errors' => $validator->errors()
            ], 400);
        }

        $user = User::find($user_id);
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        if ($request->hasFile('image')) {
            // Delete old image if exists and is not default.png
            if ($user->image && 
                file_exists(public_path($user->image)) && 
                basename($user->image) !== 'default.png') {
                unlink(public_path($user->image));
            }

            $image = $request->file('image');
            $imageName = time() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('image'), $imageName);

            $user->image = 'image/' . $imageName;
            $user->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Image updated successfully',
                'data' => [
                    'image_path' => $user->image
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'No image file uploaded'
        ], 400);
    }

    /**
     * @OA\Get(
     *     path="/users/{user_id}/image",
     *     summary="Get user profile image",
     *     description="Returns user profile image path",
     *     operationId="getUserImage",
     *     tags={"Users"},
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         description="ID of the user",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Success",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="image_path", type="string", example="image/profile123.png")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="User not found or no image available",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="error"),
     *             @OA\Property(property="message", type="string", example="User not found or no image available")
     *         )
     *     )
     * )
     */
    public function getUserImage($user_id)
    {
        $user = User::find($user_id);
        
        if (!$user || !$user->image) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found or no image available'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'image_path' => $user->image
            ]
        ], 200);
    }

} 