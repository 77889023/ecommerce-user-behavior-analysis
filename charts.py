# -*- coding: utf-8 -*-
"""生成分析报告用的 6 张图。

数据全部写在文件顶部，要换数字只改那一段就行。
运行：python charts.py
产出：figures/ 目录下的 6 张 PNG
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei"]
plt.rcParams["axes.unicode_minus"] = False

OUT = Path(__file__).resolve().parent / "figures"

BLUE = "#2f6fd0"
ORANGE = "#e8833a"
GREEN = "#4c9a72"
GREY = "#b6bfc9"
INK = "#1f2d3d"


# ============================================================ 数据

# 图 1：整体漏斗
FUNNEL_STEPS = ["浏览过的商品", "加购或收藏", "购买"]
FUNNEL_VALUES = [4677501, 486434, 98555]
FUNNEL_RATES = ["", "10.40%", "20.26%"]

# 图 2：各品类（按浏览量降序，共 20 个）
CAT_VIEWS = [147914, 134355, 132813, 126292, 116687, 106449, 72553, 64597, 53061,
             52740, 48691, 45030, 41922, 40363, 38195, 37973, 37702, 33819, 33441, 32861]
CAT_RATES = [1.21, 0.58, 0.68, 0.61, 0.82, 0.88, 0.94, 0.85, 2.36,
             1.44, 1.43, 1.13, 0.68, 1.74, 1.14, 0.38, 1.74, 4.05, 1.15, 2.10]
CAT_OVERALL = 2.11

# 图 3：决策时间窗
GAP_LABELS = ["同一小时内", "1-24 小时", "2-3 天", "4-7 天", "7 天以上", "先买后看"]
GAP_SHARES = [43.02, 33.49, 8.63, 5.63, 5.96, 3.26]

# 图 4：大促 vs 平日
PROMO_LABELS = ["平日", "大促期"]
PROMO_RATES = [0.974, 1.677]

# 图 5：大促前后日趋势
TREND_DATES = ["12-06", "12-07", "12-08", "12-09", "12-10", "12-11",
               "12-12", "12-13", "12-14", "12-15", "12-16"]
TREND_RATES = [0.891, 0.865, 0.939, 0.922, 0.809, 0.701,
               2.377, 0.903, 0.915, 0.999, 1.010]
TREND_BASE = 0.974

# 图 6：复购分布
REP_LABELS = ["只买过 1 天", "2-3 天", "4-7 天", "8-15 天", "15 天以上"]
REP_SHARES = [12.83, 25.13, 36.91, 22.52, 2.61]


# ============================================================ 通用样式

def tidy(ax, axis="y"):
    """去掉上右边框，加浅色网格。"""
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color(GREY)
    ax.spines["bottom"].set_color(GREY)
    ax.tick_params(colors=INK, labelsize=9.5)
    if axis != "none":
        ax.grid(axis=axis, color="#eef1f4", linewidth=0.8)
        ax.set_axisbelow(True)


def save(fig, name):
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print("已生成", path)


# ============================================================ 六张图

def chart1_funnel():
    fig, ax = plt.subplots(figsize=(7.5, 3.4))
    bars = ax.barh(FUNNEL_STEPS, FUNNEL_VALUES,
                   color=[BLUE, ORANGE, GREEN], height=0.55)
    ax.invert_yaxis()          # 让"浏览"排在最上面
    for bar, value, rate in zip(bars, FUNNEL_VALUES, FUNNEL_RATES):
        text = f"{value:,}"
        if rate:
            text += f"      单步转化 {rate}"
        ax.text(bar.get_width() * 1.02, bar.get_y() + bar.get_height() / 2,
                text, va="center", fontsize=9.5, color=INK)
    ax.set_xlim(0, max(FUNNEL_VALUES) * 1.5)
    ax.set_xlabel("用户-商品对数")
    ax.set_title("整体漏斗：全链路转化 2.11%", color=INK, fontsize=12.5)
    tidy(ax, axis="x")
    save(fig, "01_funnel.png")


def chart2_category():
    fig, ax = plt.subplots(figsize=(8.5, 4.8))
    ax.scatter(CAT_VIEWS, CAT_RATES, s=70, color=BLUE, alpha=0.75,
               edgecolor="white", linewidth=1, zorder=3)
    ax.axhline(CAT_OVERALL, color=ORANGE, linestyle="--", linewidth=1.3, zorder=2)
    ax.text(max(CAT_VIEWS), CAT_OVERALL, f"整体 {CAT_OVERALL}%",
            va="bottom", ha="right", fontsize=9.5, color=ORANGE)
    ax.set_xscale("log")
    ax.set_xlabel("浏览过的商品数（对数刻度）")
    ax.set_ylabel("浏览到购买转化率（%）")
    ax.set_ylim(0, max(CAT_RATES) * 1.15)
    ax.set_title("浏览量越大的品类，转化率越低", color=INK, fontsize=12.5)
    tidy(ax, axis="both")
    save(fig, "02_category_scatter.png")


def chart3_gap():
    colors = [BLUE, BLUE, GREY, GREY, GREY, "#d8dde3"]
    fig, ax = plt.subplots(figsize=(8.5, 4.2))
    bars = ax.bar(GAP_LABELS, GAP_SHARES, color=colors, width=0.6)
    for bar, value in zip(bars, GAP_SHARES):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.6,
                f"{value}%", ha="center", fontsize=9.5, color=INK)
    ax.set_ylim(0, max(GAP_SHARES) * 1.22)
    ax.set_ylabel("占全部购买商品对的比例")
    ax.set_title("76.5% 的购买发生在浏览后 24 小时内", color=INK, fontsize=12.5)
    tidy(ax)
    save(fig, "03_time_gap.png")


def chart4_promo():
    fig, ax = plt.subplots(figsize=(5.6, 4.2))
    bars = ax.bar(PROMO_LABELS, PROMO_RATES, color=[GREY, ORANGE], width=0.45)
    for bar, value in zip(bars, PROMO_RATES):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.03,
                f"{value}%", ha="center", fontsize=11.5, color=INK)
    ax.set_ylim(0, max(PROMO_RATES) * 1.25)
    ax.set_ylabel("购买浏览比（%）")
    ax.set_title("大促期转化率是平日的 1.72 倍", color=INK, fontsize=12.5)
    tidy(ax)
    save(fig, "04_promo_vs_normal.png")


def chart5_trend():
    x = list(range(len(TREND_DATES)))
    fig, ax = plt.subplots(figsize=(9.5, 4.4))
    ax.axhline(TREND_BASE, color=GREY, linestyle="--", linewidth=1.2)
    ax.text(len(x) - 1, TREND_BASE, f" 平日 {TREND_BASE}%",
            va="bottom", ha="right", fontsize=9, color="#8a949e")
    ax.plot(x, TREND_RATES, marker="o", color=BLUE,
            linewidth=1.9, markersize=5.5, zorder=3)
    ax.annotate("12-11 蓄水\n0.701%（全期最低）",
                xy=(5, 0.701), xytext=(2.4, 1.62),
                fontsize=9, color=INK,
                arrowprops=dict(arrowstyle="->", color=INK, linewidth=0.9))
    ax.annotate("12-12 爆发\n2.377%",
                xy=(6, 2.377), xytext=(6.9, 2.02),
                fontsize=9, color=INK,
                arrowprops=dict(arrowstyle="->", color=INK, linewidth=0.9))
    ax.set_xticks(x)
    ax.set_xticklabels(TREND_DATES)
    ax.set_ylabel("购买浏览比（%）")
    ax.set_ylim(0.4, max(TREND_RATES) * 1.2)
    ax.set_title("大促前转化率跌至谷底，大促后没有回落", color=INK, fontsize=12.5)
    tidy(ax)
    save(fig, "05_promo_trend.png")


def chart6_repurchase():
    fig, ax = plt.subplots(figsize=(8, 4.2))
    bars = ax.bar(REP_LABELS, REP_SHARES, color=BLUE, width=0.55)
    for bar, value in zip(bars, REP_SHARES):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.6,
                f"{value}%", ha="center", fontsize=9.5, color=INK)
    ax.set_ylim(0, max(REP_SHARES) * 1.22)
    ax.set_ylabel("占购买用户的比例")
    ax.set_title("87.2% 的购买用户在多天有过购买", color=INK, fontsize=12.5)
    tidy(ax)
    save(fig, "06_repurchase.png")


def main():
    chart1_funnel()
    chart2_category()
    chart3_gap()
    chart4_promo()
    chart5_trend()
    chart6_repurchase()
    print()
    print("全部完成，图片在", OUT)


if __name__ == "__main__":
    main()