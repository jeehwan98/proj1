package com.jee.backend.service;

import com.jee.backend.dto.ChangePasswordRequest;
import com.jee.backend.dto.UpdateNameRequest;
import com.jee.backend.dto.UserResponse;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Objects;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordService passwordService;

    public UserResponse getMe(String email) {
        return userRepository.findByEmail(Objects.requireNonNull(email))
                .map(UserResponse::from)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    @Transactional
    public void updateName(String email, UpdateNameRequest request) {
        User user = getUserByEmail(email);
        user.updateName(request.name());
    }

    @Transactional
    public void changePassword(String email, ChangePasswordRequest request) {
        User user = getUserByEmail(email);
        passwordService.validateCurrentPassword(request.currentPassword(), user.getPassword());
        user.updatePassword(passwordService.encodePassword(request.newPassword()));
    }

    @Transactional
    public void deleteAccount(String email) {
        User user = getUserByEmail(email);
        userRepository.deleteById(Objects.requireNonNull(user.getId()));
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(Objects.requireNonNull(email))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, " User not found"));
    }

    public User findUserByIdOrThrow(Long userId) {
        return userRepository.findById(Objects.requireNonNull(userId))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
