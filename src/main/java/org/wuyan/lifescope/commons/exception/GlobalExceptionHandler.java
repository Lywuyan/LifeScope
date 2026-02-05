package org.wuyan.lifescope.commons.exception;

import io.jsonwebtoken.JwtException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.wuyan.lifescope.commons.result.ResponseResult;

/**
 * 全局异常处理器
 * 所有 Controller 抛出的异常都会被这里捕获，统一返回 ApiResponse 格式。
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    // ── JWT 异常（Token 无效/过期）─────────────────
    @ExceptionHandler(JwtException.class)
    public ResponseEntity<ResponseResult<?>> handleJwt(JwtException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ResponseResult.fail("Token 无效或已过期"));
    }

    // ── 业务异常（RuntimeException）───────────────
    @ExceptionHandler(ServiceException.class)
    public ResponseEntity<ResponseResult<?>> handleBusiness(ServiceException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ResponseResult.fail(ex.getMessage()));
    }

    // ── 兜底异常 ───────────────────────────────────
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ResponseResult<?>> handleDefault(Exception ex) {
        log.info(ex.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ResponseResult.fail(500, "服务器内部错误，请稍后重试"));
    }
}
