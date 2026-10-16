-- ============================================================
-- 03 数据体检
-- 做业务分析之前先确认数据本身：多少人、多少天、行为分布是否合理
-- ============================================================

-- ① 整体规模
SELECT
    COUNT(*)                       AS `总行数`,
    COUNT(DISTINCT user_id)        AS `用户数`,
    COUNT(DISTINCT item_id)        AS `商品数`,
    COUNT(DISTINCT category_id)    AS `品类数`,
    MIN(ts)                        AS `最早时间`,
    MAX(ts)                        AS `最晚时间`,
    DATEDIFF(MAX(ts), MIN(ts)) + 1 AS `观察天数`
FROM ecommerce.events;

-- ② 行为类型分布：购买事件的占比反映数据的量级是否正常
SELECT
    behavior                                         AS `行为`,
    COUNT(*)                                         AS `次数`,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS `占比百分比`
FROM ecommerce.events
GROUP BY behavior
ORDER BY COUNT(*) DESC;

-- ③ 每日行为量与活跃用户：确认观察期连续、有没有断档或异常尖峰
SELECT
    DATE(ts)                AS `日期`,
    COUNT(*)                AS `行为数`,
    COUNT(DISTINCT user_id) AS `活跃用户`
FROM ecommerce.events
GROUP BY DATE(ts)
ORDER BY `日期`;

-- 体检结论（写进报告用）：
--   1225.7 万行 / 1 万用户 / 287.7 万商品 / 8916 个品类，观察期 31 天无缺失
--   行为分布 pv 94.24% / cart 2.80% / fav 1.98% / buy 0.98%，符合真实电商量级
--   人均行为 1226 条，远高于真实场景（几十条），说明只保留了重度用户
--   12-11 与 12-12 是双十二，行为量分别是平日的 1.22 倍和 1.71 倍

