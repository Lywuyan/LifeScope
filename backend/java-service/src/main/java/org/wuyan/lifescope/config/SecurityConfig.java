package org.wuyan.lifescope.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.wuyan.lifescope.filter.JwtAuthenticationFilter;

@Configuration
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http){
        http
                // 关闭 CSRF（REST API 不需要）
                .csrf(AbstractHttpConfigurer::disable)

                // 无状态会话（JWT 自带过期管理）
                .sessionManagement(sm ->
                        sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // ── 权限规则 ──────────────────────────
                .authorizeHttpRequests(auth -> auth
                        // 允许 OPTIONS 方法（用于CORS预检请求）
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll() // 确保OPTIONS请求被放行
                        // 注册 + 登录 公开
                        .requestMatchers(HttpMethod.POST, "/api/auth/register").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()
                        // Actuator 公开（开发期）
                        .requestMatchers("/actuator/**").permitAll()
                        // 其他所有接口都要认证
                        .anyRequest().authenticated()
                )

                // ── 插入 JWT Filter ─────────────────────
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)

                // 默认关闭表单登录
                .formLogin(Customizer.withDefaults())
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }

    /** BCrypt 密码编码器 */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);  // cost=12，安全且快够用
    }
}
