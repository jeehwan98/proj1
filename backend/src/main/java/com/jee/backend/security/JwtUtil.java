package com.jee.backend.security;

import com.jee.backend.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseCookie;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.time.Duration;
import java.util.Date;
import java.util.Objects;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    private final JwtProperties jwtProperties;

    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtProperties.getSecret()));
    }

    public String generateAccessToken(User user) {
        return Jwts.builder()
                .subject(user.getEmail())
                .claim("name", user.getName())
                .claim("type", "access")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtProperties.getAccessExpiration()))
                .signWith(getKey())
                .compact();
    }

    public String generateRefreshToken(User user) {
        return Jwts.builder()
                .subject(user.getEmail())
                .claim("type", "refresh")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtProperties.getRefreshExpiration()))
                .signWith(getKey())
                .compact();
    }

    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean isValid(String token, String expectedType) {
        try {
            Claims claims = extractClaims(token);
            return expectedType.equals(claims.get("type", String.class));
        } catch (Exception e) {
            return false;
        }
    }

    public ResponseCookie generateAccessCookie(User user) {
        return ResponseCookie.from("auth-token", Objects.requireNonNull(generateAccessToken(user)))
                .httpOnly(true)
                .secure(false)
                .sameSite("Lax")
                .path("/")
                .maxAge(Objects.requireNonNull(Duration.ofMillis(jwtProperties.getAccessExpiration())))
                .build();
    }

    public ResponseCookie generateRefreshCookie(User user) {
        return ResponseCookie.from("refresh-token", Objects.requireNonNull(generateRefreshToken(user)))
                .httpOnly(true)
                .secure(false)
                .sameSite("Lax")
                .path("/api/auth/refresh")
                .maxAge(Objects.requireNonNull(Duration.ofMillis(jwtProperties.getRefreshExpiration())))
                .build();
    }

    public ResponseCookie clearAccessCookie() {
        return ResponseCookie.from("auth-token", "")
                .httpOnly(true).secure(false).sameSite("Lax").path("/").maxAge(0).build();
    }

    public ResponseCookie clearRefreshCookie() {
        return ResponseCookie.from("refresh-token", "")
                .httpOnly(true).secure(false).sameSite("Lax").path("/api/auth/refresh").maxAge(0).build();
    }
}
