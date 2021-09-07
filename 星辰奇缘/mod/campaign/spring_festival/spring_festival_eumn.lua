-- -----------------------
-- 春节活动代码配置
-- hosr
-- -----------------------
SpringFestivalEumn = SpringFestivalEumn or {}

-- 活动类型
SpringFestivalEumn.Type = {
    BuyBuyBuy = 6, -- 礼包购买
    MonkeyCome = 99, -- 猴王
    HappyTogether = 99, -- 全民
    RiceCake = 5, -- 年糕
    GrowPlants = 2, -- 年糕
    PlantsSprite = 3, -- 年糕
    PlantsSpriteKing = 4, -- 年糕
    KillRober = 99, -- 年糕
    TotleLogin = 1, -- 年糕
    -- GrowPlants = 6, -- 年糕
    Labour = 1, -- 劳动节
}

-- 活动描述
SpringFestivalEumn.Name = {
    [SpringFestivalEumn.Type.RiceCake] = TI18N("年糕制作"),
    [SpringFestivalEumn.Type.HappyTogether] = TI18N("全民过春节"),
    [SpringFestivalEumn.Type.BuyBuyBuy] = TI18N("春节限时礼包"),
    [SpringFestivalEumn.Type.MonkeyCome] = TI18N("猴王闹新春"),
}

-- SpringFestivalEumn.RiceCakeSubName = {
--     [1] = "新春快乐年糕",
--     [2] = "年年有余年糕",
--     [3] = "吉祥如意年糕",
-- }
SpringFestivalEumn.RiceCakeSubName = {
    [1] = TI18N("阳春食盒"),
    [2] = TI18N("繁花似锦"),
}

SpringFestivalEumn.icon = {
    [SpringFestivalEumn.Type.RiceCake] = "SpringIcon4",
    [SpringFestivalEumn.Type.HappyTogether] = "SpringIcon3",
    [SpringFestivalEumn.Type.BuyBuyBuy] = "SpringIcon2",
    [SpringFestivalEumn.Type.MonkeyCome] = "SpringIcon1",
    [SpringFestivalEumn.Type.GrowPlants] = "QingmingIcon1",
    [SpringFestivalEumn.Type.PlantsSprite] = "QingmingIcon2",
    [SpringFestivalEumn.Type.PlantsSpriteKing] = "QingmingIcon6",
    [SpringFestivalEumn.Type.KillRober] = "QingmingIcon3",
    [SpringFestivalEumn.Type.TotleLogin] = "QingmingIcon5",
    [SpringFestivalEumn.Type.Labour] = "SpringIcon2",
}
