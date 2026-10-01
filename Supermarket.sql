/*
 Supermarket ERP - Schema Definition (No Data)
 Database : supermarket_erp
 Engine   : InnoDB
 Charset  : utf8mb4 / utf8mb4_0900_ai_ci
 Version  : MySQL 8.0.33
 Notes    :
   - DDL only. No seed data included.
   - Foreign keys enabled on core relationships.
   - Composite indexes tuned for common access patterns.
   - All identifiers and comments in English.
 Date     : 2026-10-01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ============================================================================
-- DROP TABLES (reverse dependency order)
-- ============================================================================
DROP TABLE IF EXISTS `rpt_monthly_sales`;
DROP TABLE IF EXISTS `rpt_daily_sales`;
DROP TABLE IF EXISTS `wms_stock_check_item`;
DROP TABLE IF EXISTS `wms_stock_check`;
DROP TABLE IF EXISTS `wms_stock_log`;
DROP TABLE IF EXISTS `wms_stock_out_item`;
DROP TABLE IF EXISTS `wms_stock_out`;
DROP TABLE IF EXISTS `wms_purchase_in_item`;
DROP TABLE IF EXISTS `wms_purchase_in`;
DROP TABLE IF EXISTS `wms_stock`;
DROP TABLE IF EXISTS `oms_cashier_transaction`;
DROP TABLE IF EXISTS `oms_refund`;
DROP TABLE IF EXISTS `oms_order_payment`;
DROP TABLE IF EXISTS `oms_order_item`;
DROP TABLE IF EXISTS `oms_order`;
DROP TABLE IF EXISTS `ums_member_recharge_log`;
DROP TABLE IF EXISTS `ums_member_points_log`;
DROP TABLE IF EXISTS `ums_member_card`;
DROP TABLE IF EXISTS `ums_member`;
DROP TABLE IF EXISTS `ums_member_level`;
DROP TABLE IF EXISTS `pms_product`;
DROP TABLE IF EXISTS `pms_supplier`;
DROP TABLE IF EXISTS `pms_brand`;
DROP TABLE IF EXISTS `pms_category`;
DROP TABLE IF EXISTS `sys_payment_method`;
DROP TABLE IF EXISTS `sys_operation_log`;
DROP TABLE IF EXISTS `sys_login_log`;
DROP TABLE IF EXISTS `sys_dict`;
DROP TABLE IF EXISTS `sys_config`;
DROP TABLE IF EXISTS `sys_user_role`;
DROP TABLE IF EXISTS `sys_role_menu`;
DROP TABLE IF EXISTS `sys_menu`;
DROP TABLE IF EXISTS `sys_role`;
DROP TABLE IF EXISTS `sys_user`;
DROP TABLE IF EXISTS `sys_store`;
DROP TABLE IF EXISTS `sys_tenant_config`;
DROP TABLE IF EXISTS `sys_tenant`;

-- ============================================================================
-- MODULE 1: TENANT MANAGEMENT
-- ============================================================================

CREATE TABLE `sys_tenant` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_no` varchar(32) NOT NULL COMMENT 'Tenant code',
  `tenant_name` varchar(100) NOT NULL COMMENT 'Tenant name (supermarket brand)',
  `contact_name` varchar(50) NOT NULL COMMENT 'Contact person name',
  `contact_phone` varchar(20) NOT NULL COMMENT 'Contact phone',
  `contact_email` varchar(100) NULL DEFAULT NULL COMMENT 'Contact email',
  `logo` varchar(500) NULL DEFAULT NULL COMMENT 'Company logo URL',
  `address` varchar(200) NULL DEFAULT NULL COMMENT 'Address',
  `license_no` varchar(50) NULL DEFAULT NULL COMMENT 'Business license number',
  `plan_type` tinyint NOT NULL DEFAULT 1 COMMENT 'Plan: 1-Basic 2-Pro 3-Enterprise',
  `max_stores` int NOT NULL DEFAULT 1 COMMENT 'Maximum number of stores',
  `max_users` int NOT NULL DEFAULT 5 COMMENT 'Maximum number of users',
  `expire_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Subscription expiry time',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active 2-Expired',
  `admin_user_id` bigint NULL DEFAULT NULL COMMENT 'Administrator user ID',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_no` (`tenant_no`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_expire_time` (`expire_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Tenant information' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_tenant_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `config_key` varchar(100) NOT NULL COMMENT 'Config key',
  `config_value` text NULL COMMENT 'Config value (JSON)',
  `config_type` varchar(20) NOT NULL DEFAULT 'string' COMMENT 'Type: string/number/boolean/json',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_config` (`tenant_id`, `config_key`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Tenant configuration' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 2: STORE MANAGEMENT
-- ============================================================================

CREATE TABLE `sys_store` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `store_no` varchar(32) NOT NULL COMMENT 'Store code',
  `store_name` varchar(100) NOT NULL COMMENT 'Store name',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `address` varchar(200) NULL DEFAULT NULL COMMENT 'Address',
  `contact_phone` varchar(20) NULL DEFAULT NULL COMMENT 'Contact phone',
  `manager_id` bigint NULL DEFAULT NULL COMMENT 'Store manager user ID',
  `store_type` tinyint NOT NULL DEFAULT 1 COMMENT 'Type: 1-Direct 2-Franchise',
  `business_hours` varchar(50) NULL DEFAULT NULL COMMENT 'Business hours (e.g. 08:00-22:00)',
  `logo` varchar(500) NULL DEFAULT NULL COMMENT 'Store logo URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Preparing 1-Open 2-Suspended 3-Closed',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_store_no` (`store_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_tenant_status` (`tenant_id`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Store information' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 3: USER & PERMISSION
-- ============================================================================

CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID (0 = super admin)',
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password (BCrypt)',
  `name` varchar(50) NOT NULL COMMENT 'Real name',
  `phone` varchar(20) NULL DEFAULT NULL COMMENT 'Phone',
  `email` varchar(100) NULL DEFAULT NULL COMMENT 'Email',
  `avatar` varchar(200) NULL DEFAULT NULL COMMENT 'Avatar URL',
  `store_id` bigint NULL DEFAULT NULL COMMENT 'Store ID',
  `user_type` tinyint NOT NULL DEFAULT 1 COMMENT 'Type: 1-Regular 2-System Admin 3-Super Admin',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT 'Last login time',
  `last_login_ip` varchar(50) NULL DEFAULT NULL COMMENT 'Last login IP',
  `login_count` int NOT NULL DEFAULT 0 COMMENT 'Login count',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_username` (`tenant_id`, `username`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_phone` (`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'System users' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `role_name` varchar(50) NOT NULL COMMENT 'Role name',
  `role_code` varchar(50) NOT NULL COMMENT 'Role code',
  `description` varchar(200) NULL DEFAULT NULL COMMENT 'Description',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_role_code` (`tenant_id`, `role_code`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Roles' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT 'Parent menu ID (0 = top-level)',
  `menu_name` varchar(50) NOT NULL COMMENT 'Menu name',
  `menu_type` tinyint NOT NULL COMMENT 'Type: 0-Directory 1-Menu 2-Button',
  `path` varchar(200) NULL DEFAULT NULL COMMENT 'Route path',
  `component` varchar(200) NULL DEFAULT NULL COMMENT 'Component path',
  `permission` varchar(100) NULL DEFAULT NULL COMMENT 'Permission code (e.g. product:add)',
  `icon` varchar(100) NULL DEFAULT NULL COMMENT 'Icon',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `visible` tinyint NOT NULL DEFAULT 1 COMMENT 'Visible: 0-Hidden 1-Shown',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id` (`parent_id`) USING BTREE,
  INDEX `idx_permission` (`permission`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Menu & permissions' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `role_id` bigint NOT NULL COMMENT 'Role ID',
  `menu_id` bigint NOT NULL COMMENT 'Menu ID',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_menu` (`role_id`, `menu_id`) USING BTREE,
  INDEX `idx_role_id` (`role_id`) USING BTREE,
  INDEX `idx_menu_id` (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Role-menu mapping' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_user_role` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `user_id` bigint NOT NULL COMMENT 'User ID',
  `role_id` bigint NOT NULL COMMENT 'Role ID',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role` (`user_id`, `role_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_role_id` (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'User-role mapping' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 4: SYSTEM CONFIG & LOGS
-- ============================================================================

CREATE TABLE `sys_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `config_name` varchar(100) NOT NULL COMMENT 'Config name',
  `config_key` varchar(100) NOT NULL COMMENT 'Config key',
  `config_value` text NULL COMMENT 'Config value',
  `config_type` varchar(20) NOT NULL DEFAULT 'string' COMMENT 'Type: string/number/boolean/json',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key` (`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'System configuration' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_dict` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `dict_type` varchar(50) NOT NULL COMMENT 'Dictionary type',
  `dict_code` varchar(50) NOT NULL COMMENT 'Dictionary code',
  `dict_name` varchar(100) NOT NULL COMMENT 'Dictionary name',
  `dict_value` varchar(200) NOT NULL COMMENT 'Dictionary value',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dict_type_code` (`dict_type`, `dict_code`) USING BTREE,
  INDEX `idx_dict_type` (`dict_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Data dictionary' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_login_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT 'Tenant ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT 'User ID',
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `login_type` tinyint NOT NULL COMMENT 'Login type: 1-Admin 2-POS',
  `login_ip` varchar(50) NULL DEFAULT NULL COMMENT 'Login IP',
  `login_location` varchar(100) NULL DEFAULT NULL COMMENT 'Login location',
  `browser` varchar(50) NULL DEFAULT NULL COMMENT 'Browser',
  `os` varchar(50) NULL DEFAULT NULL COMMENT 'Operating system',
  `status` tinyint NOT NULL COMMENT 'Status: 0-Failed 1-Success',
  `msg` varchar(200) NULL DEFAULT NULL COMMENT 'Message',
  `login_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Login time',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_login_time` (`login_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Login logs' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT 'Tenant ID',
  `module` varchar(50) NOT NULL COMMENT 'Module',
  `operation` varchar(50) NOT NULL COMMENT 'Operation type (CREATE/UPDATE/DELETE/QUERY)',
  `method` varchar(200) NOT NULL COMMENT 'Request method',
  `url` varchar(200) NOT NULL COMMENT 'Request URL',
  `params` text NULL COMMENT 'Request params',
  `result` text NULL COMMENT 'Response result',
  `status` tinyint NOT NULL COMMENT 'Status: 0-Failed 1-Success',
  `error_msg` text NULL COMMENT 'Error message',
  `ip` varchar(50) NULL DEFAULT NULL COMMENT 'Client IP',
  `user_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `username` varchar(50) NULL DEFAULT NULL COMMENT 'Operator username',
  `duration` bigint NULL DEFAULT NULL COMMENT 'Duration in ms',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_user_id` (`user_id`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE,
  INDEX `idx_module` (`module`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Operation logs' ROW_FORMAT = Dynamic;

CREATE TABLE `sys_payment_method` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `name` varchar(50) NOT NULL COMMENT 'Payment method name',
  `code` varchar(30) NOT NULL COMMENT 'Code: cash/wechat/alipay/card/stored',
  `icon` varchar(100) NULL DEFAULT NULL COMMENT 'Icon',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Account balance',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_code` (`tenant_id`, `code`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Payment methods' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 5: PRODUCT MANAGEMENT
-- ============================================================================
CREATE TABLE `pms_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `name` varchar(50) NOT NULL COMMENT 'Category name',
  `code` varchar(32) NULL DEFAULT NULL COMMENT 'Category code',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT 'Parent category ID (0 = top-level)',
  `level` tinyint NOT NULL COMMENT 'Level (1/2/3)',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `icon` varchar(200) NULL DEFAULT NULL COMMENT 'Category icon',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_parent_id` (`parent_id`) USING BTREE,
  INDEX `idx_tenant_parent` (`tenant_id`, `parent_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Product categories' ROW_FORMAT = Dynamic;

CREATE TABLE `pms_brand` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `name` varchar(100) NOT NULL COMMENT 'Brand name',
  `logo` varchar(500) NULL DEFAULT NULL COMMENT 'Brand logo URL',
  `description` varchar(500) NULL DEFAULT NULL COMMENT 'Brand description',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_name` (`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Brands' ROW_FORMAT = Dynamic;

CREATE TABLE `pms_supplier` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `supplier_no` varchar(32) NOT NULL COMMENT 'Supplier code',
  `name` varchar(100) NOT NULL COMMENT 'Supplier name',
  `contact` varchar(50) NULL DEFAULT NULL COMMENT 'Contact person',
  `phone` varchar(20) NULL DEFAULT NULL COMMENT 'Phone',
  `address` varchar(200) NULL DEFAULT NULL COMMENT 'Address',
  `bank_account` varchar(50) NULL DEFAULT NULL COMMENT 'Bank account',
  `bank_name` varchar(100) NULL DEFAULT NULL COMMENT 'Bank name',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_supplier_no` (`tenant_id`, `supplier_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Suppliers' ROW_FORMAT = Dynamic;

CREATE TABLE `pms_product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `product_no` varchar(32) NOT NULL COMMENT 'Product code',
  `barcode` varchar(64) NOT NULL COMMENT 'Barcode',
  `name` varchar(200) NOT NULL COMMENT 'Product name',
  `pinyin` varchar(200) NULL DEFAULT NULL COMMENT 'Search keyword',
  `short_name` varchar(50) NULL DEFAULT NULL COMMENT 'Short name (for receipts)',
  `category_id` bigint NOT NULL COMMENT 'Category ID',
  `brand_id` bigint NULL DEFAULT NULL COMMENT 'Brand ID',
  `supplier_id` bigint NULL DEFAULT NULL COMMENT 'Supplier ID',
  `spec` varchar(100) NULL DEFAULT NULL COMMENT 'Spec (e.g. 500ml, 1kg)',
  `unit` varchar(20) NOT NULL COMMENT 'Unit (pcs/bottle/bag/kg)',
  `purchase_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Purchase price',
  `sale_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Retail price',
  `vip_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'VIP price',
  `weight` decimal(10,3) NULL DEFAULT NULL COMMENT 'Weight (kg)',
  `image` text NULL COMMENT 'Image URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Off shelf 1-On shelf',
  `is_weight` tinyint NOT NULL DEFAULT 0 COMMENT 'Weighed product: 0-No 1-Yes',
  `is_promotion` tinyint NOT NULL DEFAULT 0 COMMENT 'On promotion: 0-No 1-Yes',
  `sale_count` int NOT NULL DEFAULT 0 COMMENT 'Units sold',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_product_no` (`tenant_id`, `product_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_barcode` (`barcode`) USING BTREE,
  INDEX `idx_pinyin` (`pinyin`) USING BTREE,
  INDEX `idx_category_id` (`category_id`) USING BTREE,
  INDEX `idx_brand_id` (`brand_id`) USING BTREE,
  INDEX `idx_supplier_id` (`supplier_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_sale_count` (`sale_count`) USING BTREE,
  INDEX `idx_tenant_status` (`tenant_id`, `status`) USING BTREE,
  INDEX `idx_tenant_category` (`tenant_id`, `category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Products' ROW_FORMAT = Dynamic;
-- ============================================================================
-- MODULE 6: MEMBER MANAGEMENT
-- ============================================================================

CREATE TABLE `ums_member_level` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `name` varchar(50) NOT NULL COMMENT 'Level name',
  `code` varchar(32) NOT NULL COMMENT 'Level code',
  `min_points` int NOT NULL DEFAULT 0 COMMENT 'Minimum points threshold',
  `discount` decimal(3,2) NOT NULL DEFAULT 1.00 COMMENT 'Discount rate (0.90 = 10% off)',
  `description` varchar(200) NULL DEFAULT NULL COMMENT 'Description',
  `sort` int NOT NULL DEFAULT 0 COMMENT 'Sort order',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_min_points` (`min_points`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Member levels' ROW_FORMAT = Dynamic;

CREATE TABLE `ums_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `member_no` varchar(32) NOT NULL COMMENT 'Member code',
  `name` varchar(50) NOT NULL COMMENT 'Member name',
  `phone` varchar(20) NOT NULL COMMENT 'Phone',
  `gender` tinyint NOT NULL DEFAULT 0 COMMENT 'Gender: 0-Unknown 1-Male 2-Female',
  `birthday` date NULL DEFAULT NULL COMMENT 'Birthday',
  `level_id` bigint NULL DEFAULT NULL COMMENT 'Member level ID',
  `points` int NOT NULL DEFAULT 0 COMMENT 'Current points',
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Stored-value balance',
  `total_consume` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total spend',
  `total_points` int NOT NULL DEFAULT 0 COMMENT 'Total points earned',
  `email` varchar(100) NULL DEFAULT NULL COMMENT 'Email',
  `address` varchar(200) NULL DEFAULT NULL COMMENT 'Address',
  `avatar` varchar(200) NULL DEFAULT NULL COMMENT 'Avatar URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Disabled 1-Active',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Registered at',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_member_no` (`tenant_id`, `member_no`) USING BTREE,
  UNIQUE INDEX `uk_tenant_phone` (`tenant_id`, `phone`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_level_id` (`level_id`) USING BTREE,
  INDEX `idx_name` (`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Members' ROW_FORMAT = Dynamic;

CREATE TABLE `ums_member_card` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `member_id` bigint NOT NULL COMMENT 'Member ID',
  `member_no` varchar(32) NOT NULL COMMENT 'Member code',
  `card_no` varchar(32) NOT NULL COMMENT 'Card number',
  `card_type` tinyint NOT NULL DEFAULT 1 COMMENT 'Card type: 1-Normal 2-Silver 3-Gold 4-Diamond',
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Card balance',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Frozen 1-Active 2-Lost',
  `expire_time` datetime NULL DEFAULT NULL COMMENT 'Expiry time',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_card_no` (`card_no`) USING BTREE,
  INDEX `idx_member_id` (`member_id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Member cards' ROW_FORMAT = Dynamic;

CREATE TABLE `ums_member_points_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `member_id` bigint NOT NULL COMMENT 'Member ID',
  `member_name` varchar(50) NOT NULL COMMENT 'Member name',
  `type` tinyint NOT NULL COMMENT 'Type: 1-Earned 2-Used 3-Adjustment 4-Expired',
  `points` int NOT NULL COMMENT 'Points change (+earned / -used)',
  `before_points` int NOT NULL COMMENT 'Balance before change',
  `after_points` int NOT NULL COMMENT 'Balance after change',
  `description` varchar(200) NULL DEFAULT NULL COMMENT 'Description',
  `related_order_no` varchar(32) NULL DEFAULT NULL COMMENT 'Related order number',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `operator_name` varchar(50) NULL DEFAULT NULL COMMENT 'Operator name',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_member_id` (`member_id`) USING BTREE,
  INDEX `idx_type` (`type`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Points change log' ROW_FORMAT = Dynamic;

CREATE TABLE `ums_member_recharge_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `member_id` bigint NOT NULL COMMENT 'Member ID',
  `member_name` varchar(50) NOT NULL COMMENT 'Member name',
  `type` tinyint NOT NULL COMMENT 'Type: 1-Recharge 2-Consume 3-Refund 4-Adjustment',
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount changed',
  `gift_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Gift amount',
  `before_balance` decimal(10,2) NOT NULL COMMENT 'Balance before change',
  `after_balance` decimal(10,2) NOT NULL COMMENT 'Balance after change',
  `pay_method` varchar(32) NULL DEFAULT NULL COMMENT 'Payment method code',
  `related_order_no` varchar(32) NULL DEFAULT NULL COMMENT 'Related order number',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `operator_name` varchar(50) NULL DEFAULT NULL COMMENT 'Operator name',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_member_id` (`member_id`) USING BTREE,
  INDEX `idx_type` (`type`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stored-value change log' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 7: ORDER MANAGEMENT
-- ============================================================================

CREATE TABLE `oms_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `order_no` varchar(32) NOT NULL COMMENT 'Order number',
  `order_type` tinyint NOT NULL DEFAULT 1 COMMENT 'Type: 1-Sale 2-Return 3-Exchange',
  `member_id` bigint NULL DEFAULT NULL COMMENT 'Member ID (NULL for walk-in)',
  `total_amount` decimal(10,2) NOT NULL COMMENT 'Order total',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Discount',
  `pay_amount` decimal(10,2) NOT NULL COMMENT 'Amount payable',
  `profit_amount` decimal(10,2) NULL DEFAULT 0.00 COMMENT 'Profit',
  `change_amount` decimal(10,2) NULL DEFAULT 0.00 COMMENT 'Change given',
  `pay_method` varchar(32) NULL DEFAULT NULL COMMENT 'Payment method code',
  `is_combined_pay` tinyint NOT NULL DEFAULT 0 COMMENT 'Combined payment: 0-No 1-Yes',
  `pay_status` tinyint NOT NULL DEFAULT 0 COMMENT 'Pay status: 0-Unpaid 1-Paid 2-Partial refund 3-Full refund',
  `order_status` tinyint NOT NULL DEFAULT 0 COMMENT 'Order status: 0-Pending 1-Completed 2-Cancelled 3-Refunded',
  `total_quantity` int NOT NULL DEFAULT 0 COMMENT 'Total units (kept in sync with items)',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `cashier_id` bigint NULL DEFAULT NULL COMMENT 'Cashier user ID',
  `order_time` datetime NULL DEFAULT NULL COMMENT 'Order placed at',
  `pay_time` datetime NULL DEFAULT NULL COMMENT 'Paid at',
  `complete_time` datetime NULL DEFAULT NULL COMMENT 'Completed at',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_order_no` (`tenant_id`, `order_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_member_id` (`member_id`) USING BTREE,
  INDEX `idx_pay_status` (`pay_status`) USING BTREE,
  INDEX `idx_order_status` (`order_status`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE,
  INDEX `idx_cashier_id` (`cashier_id`) USING BTREE,
  INDEX `idx_tenant_store` (`tenant_id`, `store_id`) USING BTREE,
  INDEX `idx_tenant_create` (`tenant_id`, `create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Orders' ROW_FORMAT = Dynamic;

CREATE TABLE `oms_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NULL DEFAULT NULL COMMENT 'Tenant ID',
  `store_id` bigint NULL DEFAULT NULL COMMENT 'Store ID',
  `order_id` bigint NOT NULL COMMENT 'Order ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `product_name` varchar(200) NOT NULL COMMENT 'Product name (snapshot)',
  `barcode` varchar(64) NULL DEFAULT NULL COMMENT 'Barcode (snapshot)',
  `spec` varchar(100) NULL DEFAULT NULL COMMENT 'Spec (snapshot)',
  `unit` varchar(20) NOT NULL COMMENT 'Unit (snapshot)',
  `quantity` decimal(10,2) NOT NULL COMMENT 'Quantity',
  `sale_price` decimal(10,2) NOT NULL COMMENT 'Retail price',
  `discount_price` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Discounted unit price',
  `total_price` decimal(10,2) NOT NULL COMMENT 'Subtotal',
  `cost_amount` decimal(10,2) NULL DEFAULT 0.00 COMMENT 'Cost amount',
  `is_weight` tinyint NOT NULL DEFAULT 0 COMMENT 'Weighed product: 0-No 1-Yes',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id` (`order_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Order items' ROW_FORMAT = Dynamic;

CREATE TABLE `oms_order_payment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NULL DEFAULT NULL COMMENT 'Tenant ID',
  `store_id` bigint NULL DEFAULT NULL COMMENT 'Store ID',
  `payment_no` varchar(32) NULL DEFAULT NULL COMMENT 'Payment number',
  `order_id` bigint NOT NULL COMMENT 'Order ID',
  `payment_method` varchar(32) NOT NULL COMMENT 'Payment method code',
  `amount` decimal(10,2) NOT NULL COMMENT 'Payment amount',
  `received_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount received (cash)',
  `change_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Change given (cash)',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `pay_time` datetime NULL DEFAULT NULL COMMENT 'Paid at',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_payment_no` (`payment_no`) USING BTREE,
  INDEX `idx_order_id` (`order_id`) USING BTREE,
  INDEX `idx_payment_method` (`payment_method`) USING BTREE,
  INDEX `idx_operator_id` (`operator_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_pay_time` (`pay_time`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_paytime` (`store_id`, `pay_time`) USING BTREE,
  INDEX `idx_store_method_time` (`store_id`, `payment_method`, `pay_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Order payments' ROW_FORMAT = Dynamic;

CREATE TABLE `oms_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `refund_no` varchar(32) NOT NULL COMMENT 'Refund number',
  `order_id` bigint NOT NULL COMMENT 'Original order ID',
  `order_no` varchar(32) NOT NULL COMMENT 'Original order number',
  `refund_amount` decimal(10,2) NOT NULL COMMENT 'Refund amount',
  `refund_method` tinyint NOT NULL COMMENT 'Refund method: 1-Cash 2-Original route',
  `refund_reason` varchar(200) NULL DEFAULT NULL COMMENT 'Refund reason',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT 'Status: 0-Pending 1-Refunded 2-Failed',
  `operator_id` bigint NOT NULL COMMENT 'Operator user ID',
  `refund_time` datetime NULL DEFAULT NULL COMMENT 'Refunded at',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_refund_no` (`tenant_id`, `refund_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_order_id` (`order_id`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Refunds' ROW_FORMAT = Dynamic;

CREATE TABLE `oms_cashier_transaction` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `txn_no` varchar(32) NOT NULL COMMENT 'Transaction number',
  `cashier_id` bigint NOT NULL COMMENT 'Cashier user ID',
  `shift_id` bigint NULL DEFAULT NULL COMMENT 'Shift ID',
  `payment_method` tinyint NOT NULL COMMENT 'Payment method: 1-Cash 2-WeChat 3-Alipay 4-UnionPay 5-Stored value',
  `transaction_type` tinyint NOT NULL COMMENT 'Type: 1-Income 2-Refund',
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount (positive)',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'Related order ID',
  `payment_id` bigint NULL DEFAULT NULL COMMENT 'Related payment detail ID',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `txn_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Transaction time',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_txn_no` (`txn_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_cashier_id` (`cashier_id`) USING BTREE,
  INDEX `idx_payment_method` (`payment_method`) USING BTREE,
  INDEX `idx_transaction_type` (`transaction_type`) USING BTREE,
  INDEX `idx_order_id` (`order_id`) USING BTREE,
  INDEX `idx_txn_time` (`txn_time`) USING BTREE,
  INDEX `idx_store_paytime` (`store_id`, `txn_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cashier transactions' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 8: INVENTORY MANAGEMENT
-- ============================================================================
  CREATE TABLE `wms_stock` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `warehouse_quantity` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total warehouse quantity',
  `shelf_quantity` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Quantity on display shelf',
  `avg_cost` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Average cost',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_product_store` (`tenant_id`, `product_id`, `store_id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock levels' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_purchase_in` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `in_no` varchar(32) NOT NULL COMMENT 'Inbound number',
  `supplier_id` bigint NULL DEFAULT NULL COMMENT 'Supplier ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total amount',
  `total_quantity` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total quantity',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT 'Status: 0-Draft 1-Approved 2-Received',
  `in_time` datetime NULL DEFAULT NULL COMMENT 'Inbound time',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `reviewer_id` bigint NULL DEFAULT NULL COMMENT 'Reviewer user ID',
  `review_time` datetime NULL DEFAULT NULL COMMENT 'Reviewed at',
  `review_remark` varchar(500) NULL DEFAULT NULL COMMENT 'Review remarks',
  `stock_in_user_id` bigint NULL DEFAULT NULL COMMENT 'Stock-in user ID',
  `stock_in_time` datetime NULL DEFAULT NULL COMMENT 'Stocked-in at',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_in_no` (`tenant_id`, `in_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_supplier_id` (`supplier_id`) USING BTREE,
  INDEX `idx_tenant_status` (`tenant_id`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Purchase inbound orders' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_purchase_in_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `in_id` bigint NOT NULL COMMENT 'Inbound order ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `quantity` decimal(10,2) NOT NULL COMMENT 'Inbound quantity',
  `purchase_price` decimal(10,2) NOT NULL COMMENT 'Purchase unit price',
  `total_price` decimal(12,2) NOT NULL COMMENT 'Subtotal',
  `batch_no` varchar(32) NULL DEFAULT NULL COMMENT 'Batch number',
  `expire_time` date NULL DEFAULT NULL COMMENT 'Expiry date',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_in_id` (`in_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Purchase inbound items' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_stock_out` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `out_no` varchar(32) NOT NULL COMMENT 'Outbound number',
  `out_type` tinyint NOT NULL COMMENT 'Type: 1-Sale 2-Transfer 3-Damage 4-Other',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `target_store_id` bigint NULL DEFAULT NULL COMMENT 'Target store ID (for transfer)',
  `order_id` bigint NULL DEFAULT NULL COMMENT 'Related order ID (for sale)',
  `total_quantity` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total outbound quantity',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT 'Status: 0-Pending 1-Completed',
  `out_time` datetime NULL DEFAULT NULL COMMENT 'Outbound time',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `reviewer_id` bigint NULL DEFAULT NULL COMMENT 'Reviewer user ID',
  `review_time` datetime NULL DEFAULT NULL COMMENT 'Reviewed at',
  `stock_out_user_id` bigint NULL DEFAULT NULL COMMENT 'Stock-out user ID',
  `stock_out_time` datetime NULL DEFAULT NULL COMMENT 'Stocked-out at',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_out_no` (`tenant_id`, `out_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_order_id` (`order_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock outbound orders' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_stock_out_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `out_id` bigint NOT NULL COMMENT 'Outbound order ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `quantity` decimal(10,2) NOT NULL COMMENT 'Outbound quantity',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_out_id` (`out_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock outbound items' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_stock_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `log_type` tinyint NOT NULL COMMENT 'Type: 1-Purchase 2-Sale 3-Transfer 4-Damage 5-Check 6-Return',
  `quantity` decimal(10,2) NOT NULL COMMENT 'Change (+in / -out)',
  `before_stock` decimal(10,2) NOT NULL COMMENT 'Stock before',
  `after_stock` decimal(10,2) NOT NULL COMMENT 'Stock after',
  `related_no` varchar(32) NULL DEFAULT NULL COMMENT 'Related document number',
  `related_id` bigint NULL DEFAULT NULL COMMENT 'Related document ID',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE,
  INDEX `idx_create_time` (`create_time`) USING BTREE,
  INDEX `idx_log_type` (`log_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock change log' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_stock_check` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `check_no` varchar(32) NOT NULL COMMENT 'Stock check number',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT 'Status: 0-Pending 1-In progress 2-Completed 3-Cancelled',
  `total_system` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total system quantity',
  `total_actual` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total actual quantity',
  `total_diff` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Total difference',
  `operator_id` bigint NULL DEFAULT NULL COMMENT 'Operator user ID',
  `remark` varchar(500) NULL DEFAULT NULL COMMENT 'Remarks',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_check_no` (`tenant_id`, `check_no`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock check orders' ROW_FORMAT = Dynamic;

CREATE TABLE `wms_stock_check_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `check_id` bigint NOT NULL COMMENT 'Stock check ID',
  `product_id` bigint NOT NULL COMMENT 'Product ID',
  `system_stock` decimal(10,2) NOT NULL COMMENT 'System stock',
  `actual_stock` decimal(10,2) NOT NULL COMMENT 'Actual stock',
  `difference` decimal(10,2) NOT NULL COMMENT 'Difference (actual - system)',
  `remark` varchar(200) NULL DEFAULT NULL COMMENT 'Remarks',
  `deleted` int NULL DEFAULT 0 COMMENT 'Soft delete: 0-No 1-Yes',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_check_id` (`check_id`) USING BTREE,
  INDEX `idx_product_id` (`product_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Stock check items' ROW_FORMAT = Dynamic;

-- ============================================================================
-- MODULE 9: REPORTS
-- ============================================================================

CREATE TABLE `rpt_daily_sales` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `stat_date` date NOT NULL COMMENT 'Statistics date',
  `order_count` int NOT NULL DEFAULT 0 COMMENT 'Number of orders',
  `total_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total sales',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total discount',
  `pay_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount received',
  `cost_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Total cost',
  `profit_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Gross profit',
  `cash_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Cash income',
  `wechat_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'WeChat income',
  `alipay_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Alipay income',
  `unionpay_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'UnionPay income',
  `stored_value_amount` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Stored-value spend',
  `member_count` int NOT NULL DEFAULT 0 COMMENT 'Member transactions',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_store_date` (`tenant_id`, `store_id`, `stat_date`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_stat_date` (`stat_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Daily sales summary' ROW_FORMAT = Dynamic;

CREATE TABLE `rpt_monthly_sales` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `tenant_id` bigint NOT NULL COMMENT 'Tenant ID',
  `store_id` bigint NOT NULL COMMENT 'Store ID',
  `stat_year` int NOT NULL COMMENT 'Year',
  `stat_month` int NOT NULL COMMENT 'Month',
  `order_count` int NOT NULL DEFAULT 0 COMMENT 'Number of orders',
  `total_amount` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Total sales',
  `discount_amount` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Total discount',
  `pay_amount` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount received',
  `cost_amount` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Total cost',
  `profit_amount` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Gross profit',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created at',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_tenant_store_month` (`tenant_id`, `store_id`, `stat_year`, `stat_month`) USING BTREE,
  INDEX `idx_tenant_id` (`tenant_id`) USING BTREE,
  INDEX `idx_store_id` (`store_id`) USING BTREE,
  INDEX `idx_stat_year_month` (`stat_year`, `stat_month`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Monthly sales summary' ROW_FORMAT = Dynamic;

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================================================
  SET FOREIGN_KEY_CHECKS = 1;

-- Product relationships
ALTER TABLE `pms_product`
  ADD CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `pms_category` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_brand`    FOREIGN KEY (`brand_id`)    REFERENCES `pms_brand`    (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `pms_supplier` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- Order relationships
ALTER TABLE `oms_order_item`
  ADD CONSTRAINT `fk_order_item_order`   FOREIGN KEY (`order_id`)   REFERENCES `oms_order`   (`id`) ON DELETE CASCADE  ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_order_item_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `oms_order_payment`
  ADD CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `oms_order` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `oms_refund`
  ADD CONSTRAINT `fk_refund_order` FOREIGN KEY (`order_id`) REFERENCES `oms_order` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `oms_cashier_transaction`
  ADD CONSTRAINT `fk_txn_order`   FOREIGN KEY (`order_id`)   REFERENCES `oms_order`          (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_txn_payment` FOREIGN KEY (`payment_id`) REFERENCES `oms_order_payment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- Member relationships
ALTER TABLE `ums_member_card`
  ADD CONSTRAINT `fk_card_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `ums_member_points_log`
  ADD CONSTRAINT `fk_points_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `ums_member_recharge_log`
  ADD CONSTRAINT `fk_recharge_member` FOREIGN KEY (`member_id`) REFERENCES `ums_member` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- Inventory relationships
ALTER TABLE `wms_stock`
  ADD CONSTRAINT `fk_stock_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `wms_purchase_in_item`
  ADD CONSTRAINT `fk_purchase_item_in`      FOREIGN KEY (`in_id`)      REFERENCES `wms_purchase_in` (`id`) ON DELETE CASCADE  ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_purchase_item_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product`     (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `wms_stock_out_item`
  ADD CONSTRAINT `fk_out_item_out`     FOREIGN KEY (`out_id`)     REFERENCES `wms_stock_out` (`id`) ON DELETE CASCADE  ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_out_item_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product`   (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `wms_stock_log`
  ADD CONSTRAINT `fk_stock_log_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `wms_stock_check_item`
  ADD CONSTRAINT `fk_check_item_check`   FOREIGN KEY (`check_id`)   REFERENCES `wms_stock_check` (`id`) ON DELETE CASCADE  ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_check_item_product` FOREIGN KEY (`product_id`) REFERENCES `pms_product`     (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- Permission relationships
ALTER TABLE `sys_role_menu`
  ADD CONSTRAINT `fk_role_menu_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_role_menu_menu` FOREIGN KEY (`menu_id`) REFERENCES `sys_menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sys_user_role`
  ADD CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

SET SQL_MODE = @OLD_SQL_MODE;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
```
