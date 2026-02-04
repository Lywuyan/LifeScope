package org.wuyan.lifescope.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Component
public class JwtUtil {

    private final SecretKey secretKey;
    private final long expirationHours;

    public JwtUtil(
            @Value("${jwt.secret}")
            String secret,
            @Value("${jwt.expiration-hours}")
            long expirationHours
    ) {
        // 密钥必须至少 32 字节才能用 HS256
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationHours = expirationHours;
    }

    /**
     * 生成 JWT Token
     * @param userId   用户ID
     * @param username  用户名
     */
    public String generateToken(Long userId, String username) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(String.valueOf(userId))       // sub = userId
                .claim("username", username)            // 自定义 claim
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plus(expirationHours, ChronoUnit.HOURS)))
                .signWith(secretKey)
                .compact();
    }

    /**
     * 解析 Token → Claims
     * 如果 Token 无效/过期会抛异常，由全局异常处理器捕获
     */
    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(secretKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 从 Token 中直接提取 userId
     */
    public Long extractUserId(String token) {
        Claims claims = parseClaims(token);
        return Long.valueOf(claims.getSubject());
    }

    /**
     * 从 Token 中直接提取 username
     */
    public String extractUsername(String token) {
        Claims claims = parseClaims(token);
        return claims.get("username", String.class);
    }
}