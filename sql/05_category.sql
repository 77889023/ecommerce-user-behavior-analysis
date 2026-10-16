-- ============================================================
-- 05 品类拆解
-- 整体健康，所以找表现明显偏离平均水平的局部
-- ============================================================

-- 浏览量最大的 20 个品类及其转化率
SELECT
    category_id                             AS `品类`,
    COUNT(*)                                AS `浏览过商品数`,
    SUM(has_buy)                            AS `购买过商品数`,
    ROUND(SUM(has_buy) / COUNT(*) * 100, 2) AS `浏览到购买_pct`
FROM (
    SELECT
        user_id,
        item_id,
        category_id,
        MAX(behavior = 'pv')  AS has_pv,
        MAX(behavior = 'buy') AS has_buy
    FROM ecommerce.events
    GROUP BY user_id, item_id, category_id
) t
WHERE has_pv = 1
GROUP BY category_id
ORDER BY `浏览过商品数` DESC
LIMIT 20;

-- 结果与结论：
--   前 20 大品类占 29.9% 流量，转化率 1.09%，不足长尾品类（2.54%）的一半
--   前 8 个品类的转化率全部低于 1.21%，没有一个超过整体 2.11%
--   ⚠️ 这是相关性不是因果：大品类曝光面广会稀释转化，小品类多为主动搜索、意图更强
--   ⚠️ 数据只有品类 ID 没有名称，无法知道具体是什么商品

