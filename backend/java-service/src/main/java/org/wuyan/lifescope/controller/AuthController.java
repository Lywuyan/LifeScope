package org.wuyan.lifescope.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.wuyan.lifescope.commons.result.ResponseResult;
import org.wuyan.lifescope.dto.Request.LoginRequest;
import org.wuyan.lifescope.dto.Request.RegisterRequest;
import org.wuyan.lifescope.dto.Response.AuthResponse;
import org.wuyan.lifescope.service.UserService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    // 注册
    @PostMapping("/register")
    public ResponseEntity<ResponseResult<AuthResponse>> register(@Valid @RequestBody RegisterRequest req) {
        AuthResponse resp = userService.register(req);
        return ResponseEntity.ok(ResponseResult.success("注册成功",resp));
    }
    // 登录
    @PostMapping("/login")
    public ResponseEntity<ResponseResult<AuthResponse>> login(@Valid @RequestBody LoginRequest req) {
        AuthResponse resp = userService.login(req);
        return ResponseEntity.ok(ResponseResult.success("登录成功", resp));
    }
    // 获取当前用户
    @GetMapping("/me")
    public ResponseEntity<ResponseResult<AuthResponse.UserInfo>> me(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        AuthResponse.UserInfo info = userService.getById(userId);
        return ResponseEntity.ok(ResponseResult.success(info));
    }
}
