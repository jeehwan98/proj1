package com.jee.backend.service;

import com.jee.backend.config.MailProperties;
import com.jee.backend.entity.AuthProvider;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Duration;

@Service
@RequiredArgsConstructor
public class PasswordService {

    private static final String KEY_PREFIX = "reset:";

    private final StringRedisTemplate redisTemplate;
    private final JavaMailSender mailSender;
    private final MailProperties mailProperties;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public void sendResetCode(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No account found with this email"));

        if (user.getProvider() != AuthProvider.LOCAL) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "This account uses " + user.getProvider().name().toLowerCase() + " login. Password reset is not available.");
        }

        String code = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        redisTemplate.opsForValue().set(
                KEY_PREFIX + email,
                code,
                Duration.ofSeconds(mailProperties.getVerifyExpirationSeconds())
        );

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailProperties.getFrom());
        message.setTo(email);
        message.setSubject("Password Reset Code");
        message.setText(
                "Your password reset code is: " + code + "\n\n" +
                "This code expires in " + (mailProperties.getVerifyExpirationSeconds() / 60) + " minutes.\n\n" +
                "If you didn't request this, you can safely ignore this email."
        );
        mailSender.send(message);
    }

    @Transactional
    public void resetPassword(String email, String code, String newPassword) {
        String key = KEY_PREFIX + email;
        String storedCode = redisTemplate.opsForValue().get(key);

        if (storedCode == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Reset code expired or not found");
        }
        if (!storedCode.equals(code)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid reset code");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        user.updatePassword(passwordEncoder.encode(newPassword));
        redisTemplate.delete(key);
    }

    public void validateCurrentPassword(String rawPassword, String encodedPassword) {
        if (!passwordEncoder.matches(rawPassword, encodedPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Current password is incorrect");
        }
    }

    public String encodePassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    public boolean matches(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
