-- ============================================================
-- 04 整体漏斗
-- 先用常规的用户级口径算一遍，发现失效后再改用「用户-商品对」粒度
-- ============================================================

-- ① 用户级漏斗（这一步是为了暴露问题，不是最终口径）
--    结果：浏览 10000 / 加购或收藏 9324 / 购买 8886，全链路 88.86%
--    这个数字不合理。原因是人均行为 1226 条、购买事件占 0.98%，
--    平均每人有 12 次购买记录，"有没有买过"几乎所有人都满足，指标饱和。
SELECT
    SUM(has_pv)                                     AS `浏览用户`,
    SUM(has_intent)                                 AS `加购或收藏用户`,
    SUM(has_buy)                                    AS `购买用户`,
    ROUND(SUM(has_intent) / SUM(has_pv) * 100, 2)   AS `浏览到加购收藏_pct`,
    ROUND(SUM(has_buy) / SUM(has_intent) * 100, 2)  AS `加购收藏到购买_pct`,
    ROUND(SUM(has_buy) / SUM(has_pv) * 100, 2)      AS `浏览到购买_pct`
FROM (
    SELECT
        user_id,
        MAX(behavior = 'pv')             AS has_pv,
        MAX(behavior IN ('cart', 'fav')) AS has_intent,
        MAX(behavior = 'buy')            AS has_buy
    FROM ecommerce.events
    GROUP BY user_id
) t;

-- ② 用户-商品对级漏斗（最终采用的口径）
--    一个用户可能浏览上百万个商品但只买其中几个，换成这个粒度后转化率才回到合理区间
--    口径提醒：buy 是独立事件，购买不一定有加购记录，三层不是严格嵌套
SELECT
    COUNT(*)                                        AS `浏览过的商品数`,
    SUM(has_intent)                                 AS `其中加购或收藏过`,
    SUM(has_buy)                                    AS `其中购买过`,
    ROUND(SUM(has_intent) / COUNT(*) * 100, 2)      AS `浏览到加购收藏_pct`,
    ROUND(SUM(has_buy) / SUM(has_intent) * 100, 2)  AS `加购收藏到购买_pct`,
    ROUND(SUM(has_buy) / COUNT(*) * 100, 2)         AS `浏览到购买_pct`
FROM (
    SELECT
        user_id,
        item_id,
        MAX(behavior = 'pv')             AS has_pv,
        MAX(behavior IN ('cart', 'fav')) AS has_intent,
        MAX(behavior = 'buy')            AS has_buy
    FROM ecommerce.events
    GROUP BY user_id, item_id
) t
WHERE has_pv = 1;

-- 结果：467.75 万 → 48.64 万（10.40%）→ 9.86 万（20.26%），全链路 2.11%
-- 三个转化率都落在电商行业正常区间，说明整体漏斗没有断层，问题在局部

