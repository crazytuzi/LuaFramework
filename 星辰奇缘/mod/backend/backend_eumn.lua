BackendEumn = BackendEumn or {}

BackendEumn.PanelType = {
    BgList = 1,             -- 背景+列表
    TextList = 2,           -- 纯文字+列表
    Exchange = 3,           -- 列表兑换
    Continue = 4,           -- 连续登录（特殊处理）
    ImageDesc = 5,          -- 文字+背景
    Hiden = 6,              -- 隐藏
    Jump = 7,               -- 转跳
    MultiExchange = 8,      -- 多页兑换
    BgShort = 9,            -- 背景+短标题列表
    HorizontalList = 10,    -- 横向列表
    MarryEasy = 11,         -- 结缘优惠（特殊处理）
    Rank = 12,              -- 活动排行榜
    RechargeReturn = 13,    -- 充值返利
}

BackendEumn.ButtonType = {
    Hiden = 0,              -- 隐藏按钮
    Normal = 1,             -- 正常按钮
    Progress = 2,           -- 未完成则显示进度条
    Times = 3,              -- 未完成则显示次数
    Countdown = 4,          -- 倒计时
    Buy = 5,                -- 购买，其实就是已完成未领取的状态不能加特效
}

BackendEumn.MoneyId = {
    [90000] = "coin",
    [90001] = "bind",
    [90002] = "gold",
    [90003] = "gold_bind",
}

BackendEumn.PanelNoRed = {
    [BackendEumn.PanelType.Exchange] = true,
    [BackendEumn.PanelType.MultiExchange] = true,
    [BackendEumn.PanelType.MarryEasy] = true,
    [BackendEumn.PanelType.HorizontalList] = true,
}

