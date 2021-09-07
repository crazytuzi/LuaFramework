-- ---------------
-- 追踪枚举
-- hosr
-- ---------------
TraceEumn = TraceEumn or BaseClass()

-- 按钮类型
TraceEumn.BtnType =  {
    Quest = 1,
    Team = 2,
    Dun = 3,
    Qualify = 4,
    Trial = 5,
    ExamQuestion = 6,
    FairyLand = 7,
    Warrior = 8,
    Parade = 9,
    TopCompete = 10, --巅峰对决
    Marry = 11, --结缘
    GuildFight = 12, --公会战
    GuildEliteFight = 13, --公会精英战
    Hero = 14,  -- 武道大会
    DragonBoat = 15,    -- 赛龙舟
    Masquerade = 16,    -- 精灵幻境
    UnlimitedChallenge = 17,    -- 无尽挑战
    SkyLantern = 18,        -- 孔明灯会
    EnjoyMoon = 19,         -- 中秋赏月
    CanYon = 20,         -- 峡谷之巅
    NationalDay = 21,         -- 国庆活动
    Halloween = 22,         -- 万圣节
    HalloweenReady = 23,    -- 万圣节准备
    GodsWarReady = 24, -- 诸神之战准备
    SnowBall = 25, -- 雪球大战准备
    GuildDungeon = 26, -- 公会副本
    AnimalChess = 27,   -- 斗兽棋
    NewQuestionMatch = 28, -- 新答题
    IngotCrash = 29, -- 元宝争霸
    StarChallenge = 30, -- 星辰挑战
    ExquisiteShelf = 31,    -- 玲珑宝阁
    GuildDragon = 32,       -- 魔龙挑战
    RushTop = 33,     -- 冲顶大会
    GodsWarWorShip = 34, --诸神膜拜
    CrossArena = 35, -- 跨服擂台
    ApocalypseLord = 36, -- 天启领主
}

-- 展示类型, 即当前显示哪两个
TraceEumn.ShowType = {
    Normal = 1,
    Dungeon = 2,
    Qualify = 3, --段位赛
    Trial = 4, -- 试炼
    ExamQuestion = 6, --科举答题
    FairyLand = 7, --幻境寻宝
    Warrior = 8,    -- 勇士试炼
    Parade = 9,  --游行
    TopCompete = 10, --巅峰对决
    Marry = 11, --结缘
    GuildFight = 12, --公会战
    GuildEliteFight = 13, --公会精英战
    Hero = 14,  -- 武道大会
    DragonBoat = 15,    -- 赛龙舟
    Masquerade = 16,    -- 精灵幻境
    UnlimitedChallenge = 17,    -- 无尽挑战
    SkyLantern = 18,            -- 孔明灯会
    EnjoyMoon = 19,         -- 中秋赏月
    CanYon = 20,         -- 峡谷之巅
    NationalDay = 21,         -- 国庆活动
    Halloween = 22,         -- 万圣节
    HalloweenReady = 23,    -- 万圣节准备
    GodsWarReady = 24, -- 诸神之战准备
    SnowBall = 25, -- 雪球大战准备
    GuildDungeon = 26, -- 公会副本
    AnimalChess = 27,   -- 斗兽棋
    NewQuestionMatch = 28, -- 新答题
    IngotCrash = 29, -- 元宝争霸
    StarChallenge = 30, -- 星辰挑战
    ExquisiteShelf = 31, -- 玲珑宝阁
    GuildDragon = 32,       -- 魔龙挑战
    RushTop = 33,     -- 冲顶大会
    GodsWarWorShip = 34, -- 诸神
    CrossArena = 35, -- 跨服擂台
    ApocalypseLord = 36, -- 天启领主
}

TraceEumn.ShowTypeDetail = {
    [TraceEumn.ShowType.FairyLand] = {TraceEumn.BtnType.FairyLand, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Normal] = {TraceEumn.BtnType.Quest, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Dungeon] = {TraceEumn.BtnType.Dun, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Qualify] = {TraceEumn.BtnType.Qualify, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.ExamQuestion] = {TraceEumn.BtnType.ExamQuestion, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Trial] = {TraceEumn.BtnType.Trial, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Warrior] = {TraceEumn.BtnType.Warrior, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Parade] = {TraceEumn.BtnType.Parade, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.TopCompete] = {TraceEumn.BtnType.TopCompete, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Marry] = {TraceEumn.BtnType.Marry, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GuildFight] = {TraceEumn.BtnType.GuildFight, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Hero] = {TraceEumn.BtnType.Hero, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GuildEliteFight] = {TraceEumn.BtnType.GuildEliteFight, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.DragonBoat] = {TraceEumn.BtnType.DragonBoat, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Masquerade] = {TraceEumn.BtnType.Masquerade, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.UnlimitedChallenge] = {TraceEumn.BtnType.UnlimitedChallenge, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.SkyLantern] = {TraceEumn.BtnType.SkyLantern, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.EnjoyMoon] = {TraceEumn.BtnType.EnjoyMoon, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.CanYon] = {TraceEumn.BtnType.CanYon, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.NationalDay] = {TraceEumn.BtnType.NationalDay, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.Halloween] = {TraceEumn.BtnType.Halloween, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.HalloweenReady] = {TraceEumn.BtnType.HalloweenReady, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GodsWarReady] = {TraceEumn.BtnType.GodsWarReady, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.SnowBall] = {TraceEumn.BtnType.SnowBall, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GuildDungeon] = {TraceEumn.BtnType.GuildDungeon, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.AnimalChess] = {TraceEumn.BtnType.AnimalChess, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.NewQuestionMatch] = {TraceEumn.BtnType.NewQuestionMatch, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.IngotCrash] = {TraceEumn.BtnType.IngotCrash, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.StarChallenge] = {TraceEumn.BtnType.StarChallenge, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.ExquisiteShelf] = {TraceEumn.BtnType.ExquisiteShelf, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GuildDragon] = {TraceEumn.BtnType.GuildDragon, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.GodsWarWorShip] = {TraceEumn.BtnType.GodsWarWorShip, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.RushTop] = {TraceEumn.BtnType.RushTop, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.CrossArena] = {TraceEumn.BtnType.CrossArena, TraceEumn.BtnType.Team},
    [TraceEumn.ShowType.ApocalypseLord] = {TraceEumn.BtnType.ApocalypseLord, TraceEumn.BtnType.Team},
}
