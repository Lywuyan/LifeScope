package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.wuyan.lifescope.commons.result.ResponseResult;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/reports")
public class ReportController {

    private final RestTemplate restTemplate;

    @GetMapping("/daily/{date}")
    public ResponseEntity<ResponseResult<Map<String, Object>>> getDailyReport(
            @PathVariable LocalDate date,
            Authentication auth
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = "http://localhost:8001/api/reports/daily/" + userId + "/" + date;

        Map<String, Object> pythonResp = restTemplate.getForObject(url, Map.class);

        if (pythonResp == null) {
            return ResponseEntity.ok(ResponseResult.fail("Python 服务无响应"));
        }

        Object dataObj = pythonResp.get("data");
        if (!(dataObj instanceof Map)) {
            return ResponseEntity.ok(ResponseResult.fail("Python 返回数据结构异常"));
        }

        Map<String, Object> outerData = (Map<String, Object>) dataObj;


        return ResponseEntity.ok(ResponseResult.success(outerData));
    }

}
