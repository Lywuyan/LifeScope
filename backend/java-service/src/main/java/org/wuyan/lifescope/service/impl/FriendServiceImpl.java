package org.wuyan.lifescope.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.wuyan.lifescope.commons.enums.FriendStatus;
import org.wuyan.lifescope.commons.exception.ServiceException;
import org.wuyan.lifescope.dto.Response.FriendInfoResponse;
import org.wuyan.lifescope.entity.Friendship;
import org.wuyan.lifescope.entity.User;
import org.wuyan.lifescope.mapper.FriendMapper;
import org.wuyan.lifescope.mapper.UserMapper;
import org.wuyan.lifescope.service.FriendService;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl extends ServiceImpl<FriendMapper, Friendship> implements FriendService {

    private final UserMapper userMapper;

    @Override
    public void sendRequest(Long userId, Long friendId) {
        if(userId.equals(friendId)){
            throw new ServiceException("不能添加自己为好友");
        }
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getFriendId, friendId);
        Friendship friendship = baseMapper.selectOne(queryWrapper);
        if(friendship != null){
            if(friendship.getStatus() == FriendStatus.PENDING){
                throw new ServiceException("已发送好友请求");
            }else if(friendship.getStatus() == FriendStatus.ACCEPTED){
                throw new ServiceException("已经是好友");
            }else if(friendship.getStatus() == FriendStatus.BLOCKED){
                friendship.setStatus(FriendStatus.PENDING);
                baseMapper.update(friendship, queryWrapper);
            }
        } else{
            Friendship newFriendship = Friendship.builder()
                    .userId(userId)
                    .friendId(friendId)
                    .status(FriendStatus.PENDING)
                    .build();
            baseMapper.insert(newFriendship);
        }
    }

    @Override
    public void acceptRequest(Long requestId, Long userId) {
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Friendship::getUserId, requestId)
                .eq(Friendship::getFriendId, userId);
        Friendship friendship = baseMapper.selectOne(queryWrapper);
        if(friendship == null){
            throw new ServiceException("不存在该好友请求");
        }
        if(!friendship.getFriendId().equals(userId)){
            throw new ServiceException("无权操作");
        }
        friendship.setStatus(FriendStatus.ACCEPTED);
        baseMapper.update(friendship, queryWrapper);

        // 双向绑定
        LambdaQueryWrapper<Friendship> userQueryWrapper = new LambdaQueryWrapper<>();
        userQueryWrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getFriendId, requestId);
        if(baseMapper.selectOne(userQueryWrapper) == null){
            Friendship newFriendship = Friendship.builder()
                    .userId(userId)
                    .friendId(requestId)
                    .status(FriendStatus.ACCEPTED)
                    .build();
            baseMapper.insert(newFriendship);
        } else{
            Friendship userFriendship = baseMapper.selectOne(userQueryWrapper);
            userFriendship.setStatus(FriendStatus.ACCEPTED);
            baseMapper.update(userFriendship, userQueryWrapper);
        }
    }

    @Override
    public void rejectRequest(Long requestId, Long userId) {
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Friendship::getUserId, requestId)
                .eq(Friendship::getFriendId, userId);
        Friendship friendship = baseMapper.selectOne(queryWrapper);
        if(friendship == null){
            throw new ServiceException("不存在该好友请求");
        }
        if(!friendship.getFriendId().equals(userId)){
            throw new ServiceException("无权操作");
        }
        friendship.setStatus(FriendStatus.BLOCKED);
        baseMapper.update(friendship, queryWrapper);
    }

    @Override
    public void removeFriend(Long userId, Long friendId) {
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper
                .nested(wrapper -> wrapper
                        .eq(Friendship::getUserId, userId)
                        .eq(Friendship::getFriendId, friendId))
                .or(wrapper -> wrapper
                        .eq(Friendship::getUserId, friendId)
                        .eq(Friendship::getFriendId, userId));

        // 直接批量更新，无需先查询
        Friendship updateEntity = Friendship.builder()
                .status(FriendStatus.BLOCKED)
                .build();

        int updatedRows = baseMapper.update(updateEntity, queryWrapper);
        if(updatedRows == 0){
            throw new ServiceException("不存在该好友关系");
        }
    }


    @Override
    public List<FriendInfoResponse> getFriendList(Long userId) {
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getStatus, FriendStatus.ACCEPTED);
        List<Friendship> friendships = baseMapper.selectList(queryWrapper);
        if (friendships.isEmpty()){
            throw new ServiceException("用户没有好友");
        }
        List<Long> friendIds = friendships.stream().map(Friendship::getFriendId).toList();
        List<User> users = userMapper.selectByIds(friendIds);
        return users.stream()
                .map(user -> FriendInfoResponse.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .avatarUrl(user.getAvatarUrl())
                        .build()
                ).toList();
    }

    @Override
    public List<FriendInfoResponse> getPendingRequests(Long userId) {
        LambdaQueryWrapper<Friendship> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getStatus, FriendStatus.PENDING);
        List<Friendship> friendships = baseMapper.selectList(queryWrapper);
        return friendships.stream().map(friendship -> {
            User user = userMapper.selectById(friendship.getFriendId());
            return FriendInfoResponse.builder()
                    .id(user.getId())
                    .username(user.getUsername())
                    .avatarUrl(user.getAvatarUrl())
                    .createdAt(friendship.getCreatedAt().toString())
                    .build();
        }).toList();
    }

    @Override
    public List<FriendInfoResponse> searchUsers(String keyword,Long userId) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.like(User::getUsername, keyword)
                .ne(User::getId, userId);
        List<User> users = userMapper.selectList(queryWrapper);
        return users.stream().map(user -> FriendInfoResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .avatarUrl(user.getAvatarUrl())
                .build()
        ).toList();
    }
}
