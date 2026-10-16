-- ============================================================
-- 02 导入数据
-- 执行前确认 DataGrip 数据源已允许本地导入（见 00_说明.md）
-- 这一步大约需要几分钟，1200 万行、507 MB 的文件要传给 MySQL
-- ============================================================

LOAD DATA LOCAL INFILE 'F:/数分项目/tianchi_mobile_recommend_train_user/tianchi_mobile_recommend_train_user.csv'
INTO TABLE ecommerce.events
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(user_id, item_id, @behavior_type, @user_geohash, @item_category, @raw_time)
SET
    -- 1/2/3/4 编码换成可读的行为名，读 SQL 时不用查文档
    behavior     = CASE @behavior_type
                       WHEN '1' THEN 'pv'
                       WHEN '2' THEN 'fav'
                       WHEN '3' THEN 'cart'
                       WHEN '4' THEN 'buy'
                   END,
    -- 空字符串存成 NULL，避免后续聚合把它当成有效值
    user_geohash = NULLIF(@user_geohash, ''),
    category_id  = NULLIF(@item_category, ''),
    -- 原始时间形如 "2014-12-06 02"，只到小时，分钟秒补 00
    ts           = STR_TO_DATE(@raw_time, '%Y-%m-%d %H');

-- 导入完成后核对行数，应该是 12256906
SELECT COUNT(*) AS `总行数` FROM ecommerce.events;

-- 建二级索引（放在导入之后，比导入之前建快很多）
CREATE INDEX idx_user_behavior     ON ecommerce.events (user_id, behavior);
CREATE INDEX idx_ts_user           ON ecommerce.events (ts, user_id);
CREATE INDEX idx_category_behavior ON ecommerce.events (category_id, behavior);

