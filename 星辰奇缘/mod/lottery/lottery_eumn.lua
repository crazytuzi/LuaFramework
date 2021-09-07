-- -------------------------------
-- 一闷夺宝枚举
-- hosr
-- -------------------------------
LotteryEumn = LotteryEumn or {}

LotteryEumn.State = {
    None = 0, -- 没状态
    Joining = 1, -- 活动进行中
    Opening = 2, -- 揭晓中
    Showing = 3, -- 展示
    Over = 4, -- 结束
    Hold = 5, --等待结束
}

LotteryEumn.StateName = {
    [LotteryEumn.State.None] = TI18N("已结束"),
    [LotteryEumn.State.Joining] = TI18N("进行中"),
    [LotteryEumn.State.Opening] = TI18N("揭晓中"),
    [LotteryEumn.State.Showing] = TI18N("展示中"),
    [LotteryEumn.State.Over] = TI18N("已结束"),
}

-- 90002:钻石夺宝;90003:金币夺宝;90000:银币夺宝
LotteryEumn.Type = {
    Diamond = 0,
    Gold = 90003,
    Silver = 90000,
}