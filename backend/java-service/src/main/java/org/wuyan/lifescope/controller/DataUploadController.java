package org.wuyan.lifescope.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.wuyan.lifescope.commons.result.ResponseResult;
import org.wuyan.lifescope.dto.Request.BehaviorDataRequest;
import org.wuyan.lifescope.service.KafkaProducerService;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/data")
public class DataUploadController {

    private final KafkaProducerService kafkaProducerService;

    /**
     * 上传单条行为数据
     */
    @PostMapping("/upload")
    public ResponseEntity<ResponseResult<String>> upload(@Valid @RequestBody BehaviorDataRequest request, Authentication auth){
        Long userId = (Long) auth.getPrincipal();
        kafkaProducerService.send(userId, request);
        return ResponseEntity.ok(ResponseResult.success("数据已提交"));
    }

    /**
     * 批量上传行为数据
     */
    @PostMapping("/batch")
    public ResponseEntity<ResponseResult<String>> batchUpload(@Valid @RequestBody List<BehaviorDataRequest> requests, Authentication auth){
        Long userId = (Long) auth.getPrincipal();
        for(BehaviorDataRequest request : requests){
            kafkaProducerService.send(userId, request);
        }
        return ResponseEntity.ok(ResponseResult.success("已提交" + requests.size() + "条数据"));
    }
}
