package com.jee.backend.controller;

import com.jee.backend.dto.UpdateNameRequest;
import com.jee.backend.dto.UserResponse;
import com.jee.backend.entity.Role;
import com.jee.backend.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/users")
    ResponseEntity<Page<UserResponse>> getUsers(@PageableDefault(size = 20, sort = "id") Pageable pageable) {
        return ResponseEntity.ok(adminService.getUsers(pageable));
    }

    @PatchMapping("/users/{id}/name")
    ResponseEntity<Void> updateName(@PathVariable Long id, @RequestBody UpdateNameRequest request) {
        adminService.updateName(id, request.name());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/users/{id}/role")
    ResponseEntity<Void> updateRole(@PathVariable Long id, @RequestParam Role role) {
        adminService.updateRole(id, role);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/users/{id}")
    ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        adminService.deleteUser(id);
        return ResponseEntity.ok().build();
    }
}
