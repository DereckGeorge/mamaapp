<?php

namespace App\Http\Controllers;

use App\Models\Journal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Annotations as OA;

class JournalController extends Controller
{
    /**
     * Get journals by user ID
     * 
     * @OA\Get(
     *     path="/journals/{user_id}",
     *     operationId="getJournals",
     *     tags={"Journals"},
     *     summary="Get all journals for a specific user",
     *     description="Returns a list of journal entries for the specified user",
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         description="ID of the user to fetch journals for",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="data",
     *                 type="array",
     *                 @OA\Items(ref="#/components/schemas/Journal")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="No journals found for this user",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="No journals found")
     *         )
     *     )
     * )
     */
    public function index($user_id)
    {
        $journals = Journal::where('user_id', $user_id)->get();

        if ($journals->isEmpty()) {
            return response()->json(['message' => 'No journals found'], 404);
        }

        return response()->json(['data' => $journals]);
    }

    /**
     * Store a new journal entry
     * 
     * @OA\Post(
     *     path="/journals",
     *     operationId="storeJournal",
     *     tags={"Journals"},
     *     summary="Create a new journal entry",
     *     description="Stores a new journal entry for a user",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"user_id","content"},
     *             @OA\Property(
     *                 property="user_id",
     *                 type="integer",
     *                 format="int64",
     *                 example=1,
     *                 description="ID of the user creating the journal"
     *             ),
     *             @OA\Property(
     *                 property="content",
     *                 type="string",
     *                 example="Today I felt the baby kick for the first time!",
     *                 description="The journal entry content"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Journal created successfully",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Journal created successfully"
     *             ),
     *             @OA\Property(
     *                 property="data",
     *                 ref="#/components/schemas/Journal"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="The given data was invalid"
     *             ),
     *             @OA\Property(
     *                 property="errors",
     *                 type="object",
     *                 @OA\Property(
     *                     property="content",
     *                     type="array",
     *                     @OA\Items(type="string", example="The content field is required")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:users,id',
            'content' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid',
                'errors' => $validator->errors()
            ], 422);
        }

        $journal = Journal::create($validator->validated());

        return response()->json([
            'message' => 'Journal created successfully',
            'data' => $journal
        ], 201);
    }

    /**
     * Delete a journal entry
     * 
     * @OA\Delete(
     *     path="/journals/{id}",
     *     operationId="deleteJournal",
     *     tags={"Journals"},
     *     summary="Delete a journal entry",
     *     description="Deletes a journal entry by its ID",
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID of the journal to delete",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Journal deleted successfully",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Journal deleted successfully"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Journal not found",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Journal not found"
     *             )
     *         )
     *     )
     * )
     */
    public function destroy($id)
    {
        $journal = Journal::find($id);

        if (!$journal) {
            return response()->json(['message' => 'Journal not found'], 404);
        }

        $journal->delete();

        return response()->json(['message' => 'Journal deleted successfully']);
    }
} 