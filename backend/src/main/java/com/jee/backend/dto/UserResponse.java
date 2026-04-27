package com.jee.backend.dto;

import com.jee.backend.entity.AuthProvider;
import com.jee.backend.entity.Role;
import com.jee.backend.entity.User;

public record UserResponse(Long id, String name, String email, Role role, AuthProvider provider) {

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getName(), user.getEmail(), user.getRole(), user.getProvider());
    }
}
