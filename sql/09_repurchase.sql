-- ============================================================
-- 09 用户复购分布
-- 在这 31 天里，用户是买一次就走，还是会回来再买
-- ============================================================

SELECT
    CASE
        WHEN buy_days = 1   THEN '只买过 1 天'
        WHEN buy_days <= 3  THEN '2-3 天'
        WHEN buy_days <= 7  THEN '4-7 天'
        WHEN buy_days <= 15 THEN '8-15 天'
        ELSE '15 天以上'
    END AS `购买天数`,
    COUNT(*) AS `用户数`,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS `占比_pct`
FROM (
    SELECT
        user_id,
        -- 按天去重：同一天买 5 次也只算 1 天
        COUNT(DISTINCT DATE(ts)) AS buy_days
    FROM ecommerce.events
    WHERE behavior = 'buy'
    GROUP BY user_id
) t
GROUP BY `购买天数`
ORDER BY MIN(buy_days);

-- 结果：只买过 1 天 12.83% / 2-3 天 25.13% / 4-7 天 36.91% /
--       8-15 天 22.52% / 15 天以上 2.61%，合计 8886 人
--
-- 结论：87.17% 的购买用户在多个日期有过购买，复购是常态。
-- ⚠️ 但真实电商复购率通常在 20%-40%，87% 显然不是平台真实水平 ——
--    原因仍是样本偏差（数据只保留重度用户）。只能说"在这批用户里复购普遍"，
--    不能推广为"平台复购率 87%"。
