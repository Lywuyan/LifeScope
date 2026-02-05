package org.wuyan.lifescope.dto.Request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "用户名不能为空")
    @Pattern(regexp = "^[一-龥a-zA-Z0-9_]{2,20}$", message = "用户名长度2-20位，只能包含中文、英文、数字和下划线")
    private String username;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "密码不能为空")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,32}$", message = "密码必须为8-32位，且包含字母和数字")
    private String password;
}