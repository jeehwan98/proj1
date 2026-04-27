package com.jee.backend.dto;

public record ResetPasswordRequest(String email, String code, String newPassword) {}
