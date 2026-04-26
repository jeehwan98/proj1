package com.jee.backend.dto;

public record PendingRegistration(String name, String encodedPassword, String code) {}
