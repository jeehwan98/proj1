package com.jee.backend.controller;

import com.jee.backend.dto.LoginRequest;
import com.jee.backend.dto.RegisterRequest;
import com.jee.backend.dto.VerifyRequest;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import com.jee.backend.security.JwtUtil;
import com.jee.backend.service.AuthService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Arrays;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    @PostMapping("/register")
    ResponseEntity<Void> register(@RequestBody RegisterRequest request) {
        authService.register(request);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/verify")
    ResponseEntity<Void> verify(@RequestBody VerifyRequest request) {
        authService.verifyAndRegister(request.email(), request.code());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/login")
    ResponseEntity<Void> login(@RequestBody LoginRequest request, HttpServletResponse response) {
        User user = authService.login(request);
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.generateAccessCookie(user).toString());
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.generateRefreshCookie(user).toString());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    ResponseEntity<Void> refresh(HttpServletRequest request, HttpServletResponse response) {
        String refreshToken = extractCookie(request, "refresh-token");

        if (refreshToken == null || !jwtUtil.isValid(refreshToken, "refresh")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token");
        }

        String email = jwtUtil.extractClaims(refreshToken).getSubject();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));

        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.generateAccessCookie(user).toString());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/logout")
    ResponseEntity<Void> logout(HttpServletResponse response) {
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearAccessCookie().toString());
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearRefreshCookie().toString());
        return ResponseEntity.ok().build();
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
