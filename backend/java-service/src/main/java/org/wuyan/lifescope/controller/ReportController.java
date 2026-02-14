package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/reports")
public class ReportController {

    private final RestTemplate restTemplate;

    private static final String PYTHON_SERVICE_URL = "http://localhost:8001";

    @GetMapping("/daily/{date}")
    public ResponseEntity<?> getDailyReport(
            Authentication auth,
            @PathVariable String date
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/reports/daily/" + userId + "/" + date;
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }

    @GetMapping("/weekly")
    public ResponseEntity<?> getWeeklyReport(
            Authentication auth
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/stats/weekly/" + userId;
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }

    @GetMapping("/monthly")
    public ResponseEntity<?> getMonthlyReport(
            Authentication auth
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/stats/monthly/" + userId;
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }

    @GetMapping("/list")
    public ResponseEntity<?> listReports(
            Authentication auth,
            @RequestParam(defaultValue = "daily") String reportType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/reports/list/" + userId
                + "?report_type=" + reportType
                + "&page=" + page + "&size=" + size;

        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }

    @PostMapping("/generate")
    public ResponseEntity<?> generateReport(
            Authentication auth,
            @RequestParam String targetDate,
            @RequestParam(defaultValue = "funny") String style
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/reports/generate?user_id=" + userId
                + "&target_date=" + targetDate + "&style=" + style;
        return ResponseEntity.ok(restTemplate.postForObject(url, null, Object.class));
    }

    @GetMapping("/top-apps/{targetDate}")
    public ResponseEntity<?> getTopApps(
            Authentication auth,
            @PathVariable String targetDate
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/stats/top-apps/" + userId + "/" + targetDate;
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }
}
