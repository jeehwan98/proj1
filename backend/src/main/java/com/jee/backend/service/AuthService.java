package com.jee.backend.service;

import com.jee.backend.dto.LoginRequest;
import com.jee.backend.dto.PendingRegistration;
import com.jee.backend.dto.RegisterRequest;
import com.jee.backend.entity.AuthProvider;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import com.jee.backend.security.JwtUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;
import java.util.Objects;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;


@Service
@RequiredArgsConstructor
public class AuthService {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    private final PasswordService passwordService;
    private final EmailVerificationService emailVerificationService;

    public void register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already in use");
        }
        emailVerificationService.sendCode(request);
    }

    public void verifyAndRegister(String email, String code) {
        PendingRegistration pending = emailVerificationService.confirm(email, code);

        User user = Objects.requireNonNull(User.builder()
                .name(pending.name())
                .email(email)
                .password(pending.encodedPassword())
                .build());

        userRepository.save(user);
    }

    public User login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User doesn't exist"));

        if (user.getProvider() != AuthProvider.LOCAL) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "This account uses " + user.getProvider().name().toLowerCase() + " login");
        }

        if (!passwordService.matches(request.password(), user.getPassword())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        return user;
    }

    public String validateRefreshTokenFromRequest(HttpServletRequest request) {
        String refreshToken = extractCookie(request, "refresh-token");

        if (refreshToken == null || !jwtUtil.isValid(refreshToken, "refresh")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token");
        }

        return refreshToken;
    }

    private String extractCookie(HttpServletRequest request, String name) {
        if (request.getCookies() == null) return null;
        return Arrays.stream(request.getCookies())
                .filter(c -> name.equals(c.getName()))
                .map(Cookie::getValue)
                .findFirst()
                .orElse(null);
    }
}
