package com.jee.backend.controller;

import com.jee.backend.dto.ChangePasswordRequest;
import com.jee.backend.dto.UpdateNameRequest;
import com.jee.backend.dto.UserResponse;
import com.jee.backend.security.JwtUtil;
import com.jee.backend.service.UserService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final JwtUtil jwtUtil;

    @GetMapping("/me")
    ResponseEntity<UserResponse> getMe(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(userService.getMe(userDetails.getUsername()));
    }

    @PatchMapping("/me/name")
    ResponseEntity<Void> updateName(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody UpdateNameRequest request) {
        userService.updateName(userDetails.getUsername(), request);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/me/password")
    ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody ChangePasswordRequest request) {
        userService.changePassword(userDetails.getUsername(), request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/me")
    ResponseEntity<Void> deleteAccount(
            @AuthenticationPrincipal UserDetails userDetails,
            HttpServletResponse response) {
        userService.deleteAccount(userDetails.getUsername());
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearAccessCookie().toString());
        response.addHeader(HttpHeaders.SET_COOKIE, jwtUtil.clearRefreshCookie().toString());
        return ResponseEntity.ok().build();
    }
}
