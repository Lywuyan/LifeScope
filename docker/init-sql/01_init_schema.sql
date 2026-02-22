USE lifescope_db;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for achievements
-- ----------------------------
DROP TABLE IF EXISTS `achievements`;
CREATE TABLE `achievements`  (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `badge_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'å¾½ç« å”¯ä¸€æ ‡è¯†',
  `badge_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'å¾½ç« åç§°',
  `badge_icon` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'å¾½ç« å›¾æ ‡emojiæˆ–URL',
  `earned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_user_badge`(`user_id` ASC, `badge_code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'ç”¨æˆ·æˆå°±' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ai_reports
-- ----------------------------
DROP TABLE IF EXISTS `ai_reports`;
CREATE TABLE `ai_reports`  (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `report_date` date NOT NULL COMMENT 'æŠ¥å‘Šæ—¥æœŸ',
  `report_type` enum('daily','weekly','monthly') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'æŠ¥å‘Šç±»åž‹',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'AIç”Ÿæˆçš„å¹½é»˜æŠ¥å‘Šæ–‡å­—',
  `chart_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'é…å¥—å›¾è¡¨å›¾ç‰‡URL',
  `style` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'funny' COMMENT 'é£Žæ ¼: funny/sarcastic/encouraging',
  `is_liked` tinyint(1) NULL DEFAULT 0 COMMENT 'ç”¨æˆ·æ˜¯å¦ç‚¹èµž',
  `is_shared` tinyint(1) NULL DEFAULT 0 COMMENT 'ç”¨æˆ·æ˜¯å¦åˆ†äº«',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_type_date`(`user_id` ASC, `report_type` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AIåˆ†æžæŠ¥å‘Š' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for badges
-- ----------------------------
DROP TABLE IF EXISTS `badges`;
CREATE TABLE `badges`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `icon` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `condition_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `condition_value` int NOT NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for challenge_participants
-- ----------------------------
DROP TABLE IF EXISTS `challenge_participants`;
CREATE TABLE `challenge_participants`  (
  `id` bigint NOT NULL,
  `challenge_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `joined_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `result` enum('PENDING','SUCCESS','FAILED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `progress_pct` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_participant`(`challenge_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for challenges
-- ----------------------------
DROP TABLE IF EXISTS `challenges`;
CREATE TABLE `challenges`  (
  `id` bigint NOT NULL,
  `creator_id` bigint NOT NULL,
  `challenge_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `target_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `target_operator` enum('<','>','=') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '<',
  `target_value` int NOT NULL,
  `duration_days` int NOT NULL DEFAULT 1,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('ACTIVE','COMPLETED','FAILED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'ACTIVE',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for daily_metrics
-- ----------------------------
DROP TABLE IF EXISTS `daily_metrics`;
CREATE TABLE `daily_metrics`  (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `metric_date` date NOT NULL COMMENT 'æ•°æ®æ—¥æœŸ',
  `total_active_mins` int NULL DEFAULT NULL COMMENT 'æ€»æ´»è·ƒæ—¶é—´(åˆ†é’Ÿ)',
  `social_mins` int NULL DEFAULT NULL COMMENT 'ç¤¾äº¤APPæ—¶é•¿',
  `game_mins` int NULL DEFAULT NULL COMMENT 'æ¸¸æˆæ—¶é•¿',
  `work_mins` int NULL DEFAULT NULL COMMENT 'å·¥ä½œ/å­¦ä¹ æ—¶é•¿',
  `browser_mins` int NULL DEFAULT NULL COMMENT 'æµè§ˆå™¨æ—¶é•¿',
  `top_app` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'ä½¿ç”¨æœ€å¤šçš„APP',
  `peak_hour` tinyint NULL DEFAULT NULL COMMENT 'é«˜å³°ä½¿ç”¨æ—¶æ®µ(0-23)',
  `task_completion_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT 'ä»»åŠ¡å®ŒæˆçŽ‡',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_user_date`(`user_id` ASC, `metric_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'æ¯æ—¥æ±‡æ€»æŒ‡æ ‡' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for friendships
-- ----------------------------
DROP TABLE IF EXISTS `friendships`;
CREATE TABLE `friendships`  (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `friend_id` bigint NOT NULL,
  `status` enum('PENDING','ACCEPTED','BLOCKED') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'PENDING',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_friendship`(`user_id` ASC, `friend_id` ASC) USING BTREE,
  INDEX `idx_friend`(`friend_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for raw_behavior_data
-- ----------------------------
DROP TABLE IF EXISTS `raw_behavior_data`;
CREATE TABLE `raw_behavior_data`  (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `record_date` date NOT NULL COMMENT 'æ•°æ®æ—¥æœŸ',
  `app_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'APPåç§°',
  `usage_mins` int NOT NULL DEFAULT 0 COMMENT 'ä½¿ç”¨æ—¶é•¿(åˆ†é’Ÿ)',
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'APPåˆ†ç±»: social/game/work/browser/other',
  `recorded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始使用时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束使用时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `record_date` ASC) USING BTREE,
  INDEX `idx_user_date_app`(`user_id` ASC, `record_date` ASC, `app_name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'åŽŸå§‹è¡Œä¸ºæ•°æ®' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_badges
-- ----------------------------
DROP TABLE IF EXISTS `user_badges`;
CREATE TABLE `user_badges`  (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `badge_id` int NOT NULL,
  `earned_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniq_user_badge`(`user_id` ASC, `badge_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL,
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'ç”¨æˆ·å',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'é‚®ç®±',
  `password_hash` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt å“ˆå¸Œå¯†ç ',
  `avatar_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'å¤´åƒåœ°å€',
  `fcm_token` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'FirebaseæŽ¨é€Token',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'ç”¨æˆ·ä¿¡æ¯' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
