<?php
/**
 * @OA\Info(
 *     title="Mama App API",
 *     version="1.0.0",
 *     description="API documentation for Mama App authentication"
 * )
 * 
 * @OA\Server(
 *     url="/api",
 *     description="API Server"
 * )
 * 
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */