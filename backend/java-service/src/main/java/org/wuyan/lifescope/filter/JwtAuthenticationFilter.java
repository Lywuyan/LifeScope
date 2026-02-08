package org.wuyan.lifescope.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.wuyan.lifescope.utils.JwtUtil;

import java.io.IOException;
import java.util.Collections;

/**
 * 每次请求执行一次：
 *   1. 从 Authorization 头提取 Bearer token
 *   2. 用 JwtUtil 解析验证
 *   3. 把 userId 塞进 SecurityContext，后续 Controller 可以直接拿到
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws IOException, ServletException {

        String authHeader = request.getHeader("Authorization");

        // 没有 token 或格式不对 → 直接放行（公开接口不需要 token）
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7); // 去掉 "Bearer "

        try {
            Long userId   = jwtUtil.extractUserId(token);
            String username = jwtUtil.extractUsername(token);

            // 构造 Authentication 对象，principal = userId
            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(
                            userId,                        // principal → 后续直接 cast 为 Long
                            null,                           // credentials（不需要保存）
                            Collections.emptyList()         // authorities（后续可扩展角色）
                    );
            auth.setDetails(username);                      // 把 username 附加进去
            SecurityContextHolder.getContext().setAuthentication(auth);

        } catch (Exception e) {
            // Token 无效/过期 → 不设置认证，后续 Security 配置会拦截
            // 这里不需要返回 401，让 SecurityFilterChain 去判断
        }

        filterChain.doFilter(request, response);
    }
}
