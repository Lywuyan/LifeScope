package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/badges")
public class BadgeController {

    private final RestTemplate restTemplate;

    private static final String PYTHON_SERVICE_URL = "http://localhost:8001";

    @GetMapping()
    public ResponseEntity<?> getBadges(
            Authentication auth
    ) {
        Long userId = (Long) auth.getPrincipal();
        String url = PYTHON_SERVICE_URL + "/api/badges/" + userId;
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllBadges() {

        String url = PYTHON_SERVICE_URL + "/api/badges/all";
        return ResponseEntity.ok(restTemplate.getForObject(url, Object.class));
    }
}
