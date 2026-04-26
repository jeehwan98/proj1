package com.jee.backend.dto;

public record ChangePasswordRequest(String currentPassword, String newPassword) {}
