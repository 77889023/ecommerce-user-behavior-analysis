-- ============================================================
-- 06 决策时间窗
-- 从首次浏览到首次购买隔了多久，回答"促支付动作该在什么时候做"
-- ============================================================

SELECT
    CASE
        WHEN gap_h < 0    THEN '先买后看'
        WHEN gap_h = 0    THEN '同一小时内'
        WHEN gap_h <= 24  THEN '1-24 小时'
        WHEN gap_h <= 72  THEN '2-3 天'
        WHEN gap_h <= 168 THEN '4-7 天'
        ELSE '7 天以上'
    END AS `间隔`,
    COUNT(*) AS `购买商品数`,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS `占比_pct`
FROM (
    SELECT
        TIMESTAMPDIFF(
            HOUR,
            MIN(CASE WHEN behavior = 'pv'  THEN ts END),
            MIN(CASE WHEN behavior = 'buy' THEN ts END)
        ) AS gap_h
    FROM ecommerce.events
    GROUP BY user_id, item_id
    HAVING gap_h IS NOT NULL
) t
GROUP BY `间隔`
ORDER BY MIN(gap_h);

-- 结果：同一小时 43.02% / 1-24 小时 33.49% / 2-3 天 8.63% /
--       4-7 天 5.63% / 7 天以上 5.96% / 先买后看 3.26%
--       合计 98555，与 04 中"购买过的商品数"完全一致
--
-- 结论：76.5% 的购买发生在浏览后 24 小时内，促支付动作必须前移
--
-- ⚠️ 踩过的坑：第一版加了 HAVING gap_h > 0 想过滤"先买后看"的异常值，
--    结果把 gap_h = 0 的"同一小时内购买"也一并删掉了 —— 因为数据时间精度只到小时，
--    当天看当天买的用户间隔算出来就是 0，而这恰恰是最主流的一批人。
--    最终只统计到 52941 条，漏了 46%。教训：分档统计前必须核对各档之和是否等于总数。

