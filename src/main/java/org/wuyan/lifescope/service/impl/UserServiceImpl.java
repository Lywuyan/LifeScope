package org.wuyan.lifescope.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.wuyan.lifescope.commons.exception.ServiceException;
import org.wuyan.lifescope.dto.Request.LoginRequest;
import org.wuyan.lifescope.dto.Request.RegisterRequest;
import org.wuyan.lifescope.dto.Response.AuthResponse;
import org.wuyan.lifescope.entity.User;
import org.wuyan.lifescope.mapper.UserMapper;
import org.wuyan.lifescope.service.UserService;
import org.wuyan.lifescope.utils.JwtUtil;

@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final JwtUtil jwtUtil;

    private final PasswordEncoder passwordEncoder;

    @Transactional
    @Override
    public AuthResponse register(RegisterRequest request) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, request.getUsername());
        Long count = baseMapper.selectCount(queryWrapper);
        if(count > 0){
            throw new ServiceException("用户名已存在");
        }
        queryWrapper.eq(User::getEmail, request.getEmail());
        count = baseMapper.selectCount(queryWrapper);
        if(count > 0){
            throw new ServiceException("邮箱已存在");
        }
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .build();
        baseMapper.insert(user);
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUsername, request.getUsername());
        User user = baseMapper.selectOne(queryWrapper);
        if(user == null){
            throw new ServiceException("用户不存在");
        }
        if(!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())){
            throw new ServiceException("密码错误");
        }
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse.UserInfo getById(Long userId) {
        User user = baseMapper.selectById(userId);
        if(user == null){
            throw new ServiceException("用户不存在");
        }
        return convert(user);
    }

    private AuthResponse buildAuthResponse(User user){
        AuthResponse.UserInfo userInfo = convert(user);
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        return new AuthResponse(token, userInfo);
    }

    private AuthResponse.UserInfo convert(User user){
        return AuthResponse.UserInfo.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .build();
    }
}
