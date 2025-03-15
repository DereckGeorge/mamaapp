<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;
use OpenApi\Annotations as OA;

/**
 * @OA\Info(
 *     version="1.0.0",
 *     title="Mama na Mwana API Documentation",
 *     description="API documentation for Mama na Mwana application - A comprehensive maternal health tracking system",
 *     @OA\Contact(
 *         email="admin@example.com"
 *     )
 * )
 * 
 * @OA\Server(
 *     url="/api",
 *     description="API Server"
 * )
 * 
 * @OA\SecurityScheme(
 *     type="http",
 *     description="Login with email/phone and password to get the authentication token",
 *     name="Token Based Authentication",
 *     in="header",
 *     scheme="bearer",
 *     bearerFormat="JWT",
 *     securityScheme="bearerAuth"
 * )
 * 
 * @OA\Tag(
 *     name="Authentication",
 *     description="API Endpoints for user authentication"
 * )
 * 
 * @OA\Tag(
 *     name="Mama Data",
 *     description="API Endpoints for managing pregnancy information"
 * )
 */
class Controller extends BaseController
{
    use AuthorizesRequests, ValidatesRequests;

    // Remove any middleware here if present
} 