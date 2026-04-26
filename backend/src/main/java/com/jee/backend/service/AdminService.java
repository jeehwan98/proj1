package com.jee.backend.service;

import com.jee.backend.dto.UserResponse;
import com.jee.backend.entity.Role;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Objects;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;

    public Page<UserResponse> getUsers(Pageable pageable) {
        return userRepository.findAll(Objects.requireNonNull(pageable))
                .map(UserResponse::from);
    }

    @Transactional
    public void updateRole(Long userId, Role role) {
        User user = userRepository.findById(Objects.requireNonNull(userId))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        user.assignRole(role);
    }

    @Transactional
    public void deleteUser(Long userId) {
        if (!userRepository.existsById(Objects.requireNonNull(userId))) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");
        }
        userRepository.deleteById(userId);
    }

}
