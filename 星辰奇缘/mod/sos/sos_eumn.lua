-- -----------------------
-- 求助枚举
-- hosr
-- -----------------------
SosEumn = SosEumn or {}

-- 求助类型
SosEumn.Type = {
    Guild = 1, -- 公会
    Friend = 2, -- 好友
}

-- 功能类型
SosEumn.FuncType = {
    Plot = 1, -- 剧情任务
    Chain = 2, -- 任务练
    FruitPlant = 5, --水果种植好友求助
}

-- 求助数据枚举
SosEumn.DigitKey = {
    QuestId = 1, -- 任务id
}

-- 求助字符串枚举
SosEumn.StrKey = {
    Default = 1000, -- 直接显示内容
    Name = 1001, -- 求助者名字
    UnitName = 1002, -- 单位名字
}
