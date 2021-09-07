IngotCrashEumn = IngotCrashEumn or {}

IngotCrashEumn.Phase = IngotCrashEumn.Phase or {
    Close = 0,              -- 关闭
    Predict = 1,              -- 预告广播
    Ready = 2,              -- 准备
    Qualifier = 3,          -- 资格赛
    Kickout = 4,            -- 淘汰赛
    Guess = 5,              -- 竞猜
    Champion = 6,           -- 冠军展示
    GlobalPreview = 7,      -- 全天预告
}

IngotCrashEumn.Level = IngotCrashEumn.Level or {
    Qualifier = 1,          -- 预选赛
    LastSixteen = 2,        -- 十六强
    LastEight = 3,          -- 八强
    SemiFinal = 4,          -- 四强
    Final = 5,              -- 决赛
    ThirdPlace = 6,         -- 季军
    Champions = 7,          -- 冠军
}

IngotCrashEumn.LevelText = IngotCrashEumn.LevelText or {
    [1] = TI18N("决赛"),
    [2] = TI18N("季军赛"),
    [3] = TI18N("半决赛"),
    [4] = TI18N("8进4"),
    [5] = TI18N("16进8"),
    [6] = TI18N("32进16"),
    [7] = TI18N("64进32"),
    [8] = TI18N("128进64"),
    [9] = TI18N("预选赛"),
}

IngotCrashEumn.Area = IngotCrashEumn.Area or {
    Walk = 1,
    Block = 2,
}

