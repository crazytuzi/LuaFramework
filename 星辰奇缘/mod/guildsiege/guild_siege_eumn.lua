-- 公会攻城战的枚举

GuildSiegeEumn = GuildSiegeEumn or {}

GuildSiegeEumn.Status = {
    Disactive = 0,
    Ready = 1,
    Acceptable = 2,
}

GuildSiegeEumn.CastleType = {
    [0] = TI18N("城堡"),
    [1] = TI18N("瞭望塔"),
    [2] = TI18N("保护塔"),
    [3] = TI18N("要塞"),
}

GuildSiegeEumn.ResultType = {
    None = 0,       -- 未有结果
    Loss = 1,       -- 失败
    Fail = 2,       -- 惜败
    Draw = 3,       -- 平局
    Win = 4,        -- 险胜
    Victory = 5,    -- 完胜
}
