<?php

namespace App\Http\Controllers;

use App\Models\Reminder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Annotations as OA;

class ReminderController extends Controller
{
    /**
     * Get reminders by user ID
     * 
     * @OA\Get(
     *     path="/reminders/{user_id}",
     *     operationId="getReminders",
     *     tags={"Reminders"},
     *     summary="Get all reminders for a specific user",
     *     description="Returns a list of reminders for the specified user",
     *     @OA\Parameter(
     *         name="user_id",
     *         in="path",
     *         required=true,
     *         description="ID of the user to fetch reminders for",
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
     *                 @OA\Items(ref="#/components/schemas/Reminder")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="No reminders found for this user",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="No reminders found")
     *         )
     *     )
     * )
     */
    public function index($user_id)
    {
        $reminders = Reminder::where('user_id', $user_id)
            ->orderBy('reminder_time', 'asc')
            ->get();

        if ($reminders->isEmpty()) {
            return response()->json(['message' => 'No reminders found'], 404);
        }

        return response()->json([
            'data' => $reminders->map(function ($reminder) {
                return array_merge($reminder->toArray(), [
                    'status' => (bool) $reminder->status
                ]);
            })
        ]);
    }

    /**
     * Store a new reminder
     * 
     * @OA\Post(
     *     path="/reminders",
     *     operationId="storeReminder",
     *     tags={"Reminders"},
     *     summary="Create a new reminder",
     *     description="Stores a new reminder for a user",
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"user_id","type","reminder_time"},
     *             @OA\Property(property="user_id", type="integer", format="int64", example=1),
     *             @OA\Property(
     *                 property="type",
     *                 type="string",
     *                 enum={"doctor's appointment", "medicine", "medical tests"},
     *                 example="medicine"
     *             ),
     *             @OA\Property(property="appointment", type="string", example="visit therapist"),
     *             @OA\Property(
     *                 property="reminder_time",
     *                 type="string",
     *                 format="date-time",
     *                 example="2024-03-21 14:30:00"
     *             ),
     *             @OA\Property(
     *                 property="question",
     *                 type="string",
     *                 example="What should I ask my doctor?",
     *                 nullable=true,
     *                 description="Optional question or note for the reminder"
     *             ),
     *             @OA\Property(
     *                 property="dose_unit",
     *                 type="string",
     *                 enum={"tablets", "drops", "capsule"},
     *                 example="tablets"
     *             ),
     *             @OA\Property(
     *                 property="medicine_details",
     *                 type="object",
     *                 @OA\Property(property="name", type="string", example="Vitamin D"),
     *                 @OA\Property(property="dose", type="string", example="2")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Reminder created successfully",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder created successfully"
     *             ),
     *             @OA\Property(
     *                 property="data",
     *                 ref="#/components/schemas/Reminder"
     *             )
     *         )
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer|exists:users,id',
            'type' => 'required|in:doctor\'s appointment,medicine,medical tests',
            'appointment' => 'required_if:type,doctor\'s appointment|string|nullable',
            'reminder_time' => 'required|date',
            'dose_unit' => 'required_if:type,medicine|in:tablets,drops,capsule|nullable',
            'medicine_details' => 'required_if:type,medicine|array|nullable',
            'question' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid',
                'errors' => $validator->errors()
            ], 422);
        }

        // Clean up data based on type
        $data = $validator->validated();
        $data['status'] = true; // Set default status to pending
        
        // Fix: Use exact string comparison for type
        if ($data['type'] === "doctor's appointment") {
            // Keep appointment field if type is doctor's appointment
            $data['dose_unit'] = null;
            $data['medicine_details'] = null;
        } elseif ($data['type'] === 'medicine') {
            // Keep medicine fields if type is medicine
            $data['appointment'] = null;
            if (isset($data['medicine_details']) && is_array($data['medicine_details'])) {
                $data['medicine_details'] = json_encode($data['medicine_details']);
            }
        } else {
            // For medical tests, clear both sets of fields
            $data['appointment'] = null;
            $data['dose_unit'] = null;
            $data['medicine_details'] = null;
        }

        $reminder = Reminder::create($data);

        return response()->json([
            'message' => 'Reminder created successfully',
            'data' => $reminder
        ], 201);
    }

    /**
     * Update a reminder
     * 
     * @OA\Put(
     *     path="/reminders/{id}",
     *     operationId="updateReminder",
     *     tags={"Reminders"},
     *     summary="Update an existing reminder",
     *     description="Updates a reminder's information",
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID of the reminder to update",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(ref="#/components/schemas/Reminder")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Reminder updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder updated successfully"
     *             ),
     *             @OA\Property(
     *                 property="data",
     *                 ref="#/components/schemas/Reminder"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Reminder not found",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder not found"
     *             )
     *         )
     *     )
     * )
     */
    public function update(Request $request, $id)
    {
        $reminder = Reminder::find($id);

        if (!$reminder) {
            return response()->json(['message' => 'Reminder not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'type' => 'sometimes|required|in:doctor\'s appointment,medicine,medical tests',
            'appointment' => 'required_if:type,doctor\'s appointment|string|nullable',
            'reminder_time' => 'sometimes|required|date',
            'dose_unit' => 'required_if:type,medicine|in:tablets,drops,capsule|nullable',
            'medicine_details' => 'required_if:type,medicine|array|nullable'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid',
                'errors' => $validator->errors()
            ], 422);
        }

        // Clean up data based on type
        $data = $validator->validated();
        
        // Fix: Use exact string comparison for type
        if (isset($data['type'])) {
            if ($data['type'] === "doctor's appointment") {
                // Keep appointment field if type is doctor's appointment
                $data['dose_unit'] = null;
                $data['medicine_details'] = null;
            } elseif ($data['type'] === 'medicine') {
                // Keep medicine fields if type is medicine
                $data['appointment'] = null;
                if (isset($data['medicine_details']) && is_array($data['medicine_details'])) {
                    $data['medicine_details'] = json_encode($data['medicine_details']);
                }
            } else {
                // For medical tests, clear both sets of fields
                $data['appointment'] = null;
                $data['dose_unit'] = null;
                $data['medicine_details'] = null;
            }
        }

        $reminder->update($data);

        return response()->json([
            'message' => 'Reminder updated successfully',
            'data' => $reminder
        ]);
    }

    /**
     * Delete a reminder
     * 
     * @OA\Delete(
     *     path="/reminders/{id}",
     *     operationId="deleteReminder",
     *     tags={"Reminders"},
     *     summary="Delete a reminder",
     *     description="Deletes a reminder by its ID",
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID of the reminder to delete",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Reminder deleted successfully",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder deleted successfully"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Reminder not found",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder not found"
     *             )
     *         )
     *     )
     * )
     */
    public function destroy($id)
    {
        $reminder = Reminder::find($id);

        if (!$reminder) {
            return response()->json(['message' => 'Reminder not found'], 404);
        }

        $reminder->delete();

        return response()->json(['message' => 'Reminder deleted successfully']);
    }

    /**
     * Update reminder status
     * 
     * @OA\Patch(
     *     path="/reminders/{id}/status",
     *     operationId="updateReminderStatus",
     *     tags={"Reminders"},
     *     summary="Update a reminder's status",
     *     description="Updates the completion status of a reminder",
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="ID of the reminder to update",
     *         @OA\Schema(type="integer", format="int64")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"status"},
     *             @OA\Property(
     *                 property="status",
     *                 type="boolean",
     *                 example=true,
     *                 description="New status value (false=pending, true=completed)"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Status updated successfully",
     *         @OA\JsonContent(
     *             @OA\Property(
     *                 property="message",
     *                 type="string",
     *                 example="Reminder status updated successfully"
     *             ),
     *             @OA\Property(
     *                 property="data",
     *                 ref="#/components/schemas/Reminder"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Reminder not found"
     *     )
     * )
     */
    public function updateStatus(Request $request, $id)
    {
        $reminder = Reminder::find($id);

        if (!$reminder) {
            return response()->json(['message' => 'Reminder not found'], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid',
                'errors' => $validator->errors()
            ], 422);
        }

        $reminder->status = $request->status;
        $reminder->save();

        return response()->json([
            'message' => 'Reminder status updated successfully',
            'data' => $reminder
        ]);
    }
} 