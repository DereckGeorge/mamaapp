<?php

namespace App\Http\Controllers;

use App\Models\MamaTip;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MamaTipController extends Controller
{
    /**
     * @OA\Get(
     *     path="/mama-tips",
     *     summary="Get all mama tips",
     *     description="Returns list of all mama tips",
     *     operationId="getMamaTips",
     *     tags={"Mama Tips"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(ref="#/components/schemas/MamaTip")
     *             )
     *         )
     *     )
     * )
     */
    public function index()
    {
        $tips = MamaTip::all();
        return response()->json([
            'status' => 'success',
            'data' => $tips
        ]);
    }

    /**
     * @OA\Post(
     *     path="/mama-tips",
     *     summary="Create a new mama tip",
     *     description="Creates a new mama tip with image",
     *     operationId="createMamaTip",
     *     tags={"Mama Tips"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 required={"name","tip_content"},
     *                 @OA\Property(property="name", type="string", example="Healthy Diet Tips"),
     *                 @OA\Property(property="tip_content", type="string", example="Eat plenty of fruits..."),
     *                 @OA\Property(property="image", type="string", format="binary")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Tip created successfully",
     *         @OA\JsonContent(ref="#/components/schemas/MamaTip")
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid input"
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'tip_content' => 'required|string',
            'image' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 400);
        }

        $data = $request->only(['name', 'tip_content']);

        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $imageName = time() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('image'), $imageName);
            $data['image'] = 'image/' . $imageName;
        }

        $tip = MamaTip::create($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Tip created successfully',
            'data' => $tip
        ], 201);
    }

    /**
     * @OA\Get(
     *     path="/mama-tips/{id}",
     *     summary="Get mama tip by ID",
     *     description="Returns a single mama tip",
     *     operationId="getMamaTipById",
     *     tags={"Mama Tips"},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         description="ID of mama tip to return",
     *         required=true,
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(
     *                 property="data",
     *                 type="object",
     *                 ref="#/components/schemas/MamaTip"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Tip not found",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="error"),
     *             @OA\Property(property="message", type="string", example="Tip not found")
     *         )
     *     )
     * )
     */
    public function show($id)
    {
        $tip = MamaTip::find($id);
        
        if (!$tip) {
            return response()->json([
                'status' => 'error',
                'message' => 'Tip not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $tip
        ]);
    }
} 