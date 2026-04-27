package com.jee.backend.controller;

import com.jee.backend.dto.ForgotPasswordRequest;
import com.jee.backend.dto.LoginRequest;
import com.jee.backend.dto.RegisterRequest;
import com.jee.backend.dto.ResetPasswordRequest;
import com.jee.backend.dto.VerifyRequest;
import com.jee.backend.entity.User;
import com.jee.backend.security.JwtUtil;
import com.jee.backend.service.AuthService;
import com.jee.backend.service.PasswordService;
import com.jee.backend.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UserService userService;
    private final PasswordService passwordService;
    private final JwtUtil jwtUtil;

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
        String refreshToken = authService.validateRefreshTokenFromRequest(request);
        String email = jwtUtil.extractClaims(refreshToken).getSubject();
        User user = userService.getUserByEmail(email);
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.generateAccessCookie(user).toString());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/forgot-password")
    ResponseEntity<Void> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        passwordService.sendResetCode(request.email());
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/reset-password")
    ResponseEntity<Void> resetPassword(@RequestBody ResetPasswordRequest request) {
        passwordService.resetPassword(request.email(), request.code(), request.newPassword());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/logout")
    ResponseEntity<Void> logout(HttpServletResponse response) {
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearAccessCookie().toString());
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearRefreshCookie().toString());
        return ResponseEntity.ok().build();
    }
}
