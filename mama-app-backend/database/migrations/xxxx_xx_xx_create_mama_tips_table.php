<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('mama_tips', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('image')->default('tips/default-tip.png');
            $table->text('tip_content');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mama_tips');
    }
}; 