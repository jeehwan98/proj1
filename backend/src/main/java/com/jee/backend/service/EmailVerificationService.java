package com.jee.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jee.backend.config.MailProperties;
import com.jee.backend.dto.PendingRegistration;
import com.jee.backend.dto.RegisterRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class EmailVerificationService {

    private static final String KEY_PREFIX = "verify:";

    private final StringRedisTemplate redisTemplate;
    private final JavaMailSender mailSender;
    private final PasswordEncoder passwordEncoder;
    private final MailProperties mailProperties;
    private final ObjectMapper objectMapper;

    public void sendCode(RegisterRequest request) {
        String code = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        String encodedPassword = passwordEncoder.encode(request.password());
        PendingRegistration pending = new PendingRegistration(request.name(), encodedPassword, code);

        try {
            String json = objectMapper.writeValueAsString(pending);
            redisTemplate.opsForValue().set(
                    KEY_PREFIX + request.email(),
                    Objects.requireNonNull(json),
                    Objects.requireNonNull(Duration.ofSeconds(mailProperties.getVerifyExpirationSeconds()))
            );
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to store verification code");
        }

        sendVerificationEmail(request.email(), code);
    }

    public PendingRegistration confirm(String email, String code) {
        String key = KEY_PREFIX + email;
        String json = redisTemplate.opsForValue().get(key);

        if (json == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Verification code expired or not found");
        }

        PendingRegistration pending;
        try {
            pending = objectMapper.readValue(json, PendingRegistration.class);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to read verification data");
        }

        if (!pending.code().equals(code)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid verification code");
        }

        redisTemplate.delete(key);
        return pending;
    }

    private void sendVerificationEmail(String to, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(mailProperties.getFrom());
        message.setTo(to);
        message.setSubject("Your verification code");
        message.setText(
                "Your verification code is: " + code + "\n\n" +
                "This code expires in " + (mailProperties.getVerifyExpirationSeconds() / 60) + " minutes."
        );
        mailSender.send(message);
    }
}
