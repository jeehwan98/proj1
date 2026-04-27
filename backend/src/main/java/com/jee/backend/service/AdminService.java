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
    private final UserService userService;

    public Page<UserResponse> getUsers(Pageable pageable) {
        return userRepository.findAll(Objects.requireNonNull(pageable))
                .map(UserResponse::from);
    }

    @Transactional
    public void updateName(Long userId, String name) {
        User user = userService.findUserByIdOrThrow(userId);
        user.updateName(name);
    }

    @Transactional
    public void updateRole(Long userId, Role role) {
        User user = userService.findUserByIdOrThrow(userId);
        user.assignRole(role);
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = userService.findUserByIdOrThrow(userId);
        userRepository.delete(user);
    }

}
