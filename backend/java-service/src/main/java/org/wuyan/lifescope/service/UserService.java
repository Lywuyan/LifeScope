package org.wuyan.lifescope.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.wuyan.lifescope.dto.Request.LoginRequest;
import org.wuyan.lifescope.dto.Request.RegisterRequest;
import org.wuyan.lifescope.dto.Response.AuthResponse;
import org.wuyan.lifescope.entity.User;

public interface UserService extends IService<User> {
    /**
     * 注册
     * @param request 注册请求
     * @return 响应
     */
    AuthResponse register(RegisterRequest request);

    /**
     * 登录
     * @param request 登录请求
     * @return 响应
     */
    AuthResponse login(LoginRequest request);

    /**
     * 获取用户信息
     * @param userId 用户ID
     * @return 用户信息
     */
    AuthResponse.UserInfo getById(Long userId);
}
