<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reminders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                  ->constrained()
                  ->onDelete('cascade');
            $table->enum('type', ['doctor\'s appointment', 'medicine', 'medical tests']);
            $table->string('appointment')->nullable();
            $table->timestamp('reminder_time');
            $table->enum('dose_unit', ['tablets', 'drops', 'capsule'])->nullable();
            $table->json('medicine_details')->nullable(); // Will store array with name and dose
            $table->timestamps();
        });

        // Add check constraints using raw SQL for better compatibility
        DB::statement("ALTER TABLE reminders ADD CONSTRAINT check_medicine_fields 
            CHECK (
                (type = 'medicine' AND dose_unit IS NOT NULL AND medicine_details IS NOT NULL) OR 
                (type != 'medicine' AND dose_unit IS NULL AND medicine_details IS NULL)
            )"
        );

        DB::statement("ALTER TABLE reminders ADD CONSTRAINT check_appointment_field
            CHECK (
                (type = 'doctor\'s appointment' AND appointment IS NOT NULL) OR 
                (type != 'doctor\'s appointment' AND appointment IS NULL)
            )"
        );
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reminders');
    }
}; 