package org.wuyan.lifescope.commons.result;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 统一 API 响应包装器
 * 所有接口都用这个结构返回，前端一个 if 就可以判断成功失败。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResponseResult<T> {

    private boolean success;
    private int     code;
    private String  message;
    private T       data;

    // ── 静态工厂方法 ──────────────────────────────
    public static <T> ResponseResult<T> ok(T data) {
        return new ResponseResult<>(true, 200, "OK", data);
    }

    public static <T> ResponseResult<T> ok(String message, T data) {
        return new ResponseResult<>(true, 200, message, data);
    }

    public static <T> ResponseResult<T> error(int code, String message) {
        return new ResponseResult<>(false, code, message, null);
    }

    public static <T> ResponseResult<T> badRequest(String message) {
        return error(400, message);
    }

    public static <T> ResponseResult<T> unauthorized(String message) {
        return error(401, message);
    }

    public static <T> ResponseResult<T> notFound(String message) {
        return error(404, message);
    }
}
