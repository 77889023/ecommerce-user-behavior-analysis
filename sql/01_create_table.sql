-- ============================================================
-- 01 建库建表
-- 原始数据：阿里天池「移动推荐算法」训练集
-- 字段：user_id, item_id, behavior_type, user_geohash, item_category, time
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce
    DEFAULT CHARACTER SET utf8mb4;

USE ecommerce;

DROP TABLE IF EXISTS events;

CREATE TABLE events (
    id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    user_id      BIGINT          NOT NULL COMMENT '用户 ID',
    item_id      BIGINT          NOT NULL COMMENT '商品 ID',
    category_id  BIGINT              NULL COMMENT '品类 ID',
    behavior     VARCHAR(10)     NOT NULL COMMENT 'pv=浏览 fav=收藏 cart=加购 buy=购买',
    ts           DATETIME        NOT NULL COMMENT '行为时间，原始数据只到小时',
    user_geohash VARCHAR(32)         NULL COMMENT '地理位置哈希，原始数据大部分为空',
    PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COMMENT='天池移动推荐算法 用户行为明细';

-- 建表时不建二级索引：1200 万行先灌数据，导完再建索引会快很多。
-- 索引语句见 02_load_data.sql 末尾。

