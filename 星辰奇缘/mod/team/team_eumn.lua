TeamEumn = TeamEumn or {}

TeamEumn.MatchStatus = {
    None = 0, -- 无
    Recruiting = 1, -- 招募
    Matching = 2, -- 匹配
}

-- 匹配的等级类型
TeamEumn.MatchLevType = {
    None = 0,
    Fixed = 1,-- 固定
    Dynamic = 2,--动态
}

-- 匹配类型
TeamEumn.MatchType = {
    Boss = 1, -- 世界boss
    Hangup = 2, -- 挂机
    Seal = 3, -- 封妖
    Dungeon = 4, -- 副本
    Offer = 5, -- 悬赏
    Classes = 6, -- 职业挑战
    Treasure = 7, -- 幻境寻宝
    Qualify = 8, -- 段位赛
    Tower = 9, -- 天空塔
    TopComplete = 10, -- 巅峰对决
    Constellation = 11, -- 星座挑战
    DramaQuest = 12, -- 剧情任务
    PetCouple = 13, -- 宠物情缘
    CoupleQuest = 14, -- 情缘任务
}

-- 组队等级段显示
TeamEumn.FlagName = {

}

-- 进队方式类型
TeamEumn.EnterType = {
    None = 0,
    Invite = 1,-- 邀请
    Match = 2,--匹配
}

-- 队伍干嘛类型
TeamEumn.DoType = {
    None = 0,
    Boss = 1, -- boss
    Hangup = 2, -- 挂机
    Seal = 3, -- 封妖
    Dungeon = 4, -- 副本
    Offer = 51, -- 悬赏
    Cycle = 6, -- 职业任务
    Fairyland = 7, -- 幻境
    Match = 8, -- 段位赛
    Tower = 9, -- 天空塔
}

-- 队伍招募广播扩展参数类型
TeamEumn.MatchExtraType = {
    None = 0, -- 无
    Constellation = 1, -- 星座星级
    PetBaseId = 2, -- 宠物基础ID
    Sex = 3, -- 招募性别
}
