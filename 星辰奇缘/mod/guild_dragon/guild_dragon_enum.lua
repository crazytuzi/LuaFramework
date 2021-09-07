GuildDragonEnum = GuildDragonEnum or {}

GuildDragonEnum.State = GuildDragonEnum.State or {
    Close = 1,          -- 未开启
    Ready = 2,          -- 准备
    Countdown = 3,      -- 进入前的倒计时
    First = 4,          -- 第一阶段
    Second = 5,         -- 第二阶段
    Third = 6,          -- 第三阶段
    Reward = 7,         -- 奖励
}

GuildDragonEnum.Power = GuildDragonEnum.Power or {
    [GuildDragonEnum.State.Close] = 1,
    [GuildDragonEnum.State.Ready] = 1,
    [GuildDragonEnum.State.Countdown] = 1,
    [GuildDragonEnum.State.First] = 1,
    [GuildDragonEnum.State.Second] = 1.5,
    [GuildDragonEnum.State.Third] = 2,
    [GuildDragonEnum.State.Reward] = 2,
}

GuildDragonEnum.Rank = GuildDragonEnum.Rank or {
    Personal = 1,
    Guild = 2,
}

GuildDragonEnum.Log = GuildDragonEnum.Log or {
    Dragon = 1,
    Attack = 2,
    Defend = 3,
}

GuildDragonEnum.Area = GuildDragonEnum.Area or {
    None = 0,
    Jump = 1,
    Land = 2,
    Walk = 3,
    Block = 4,
}

GuildDragonEnum.DamakuType = GuildDragonEnum.DamakuType or {
    System = 1,
    Player = 2,
}
