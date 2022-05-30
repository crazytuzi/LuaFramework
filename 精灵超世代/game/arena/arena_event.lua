ArenaEvent = ArenaEvent or {}

-- 更新循环赛的个人信息
ArenaEvent.UpdateMyLoopData = "ArenaEvent.UpdateMyLoopData"

-- 更新循环赛挑战次数奖励信息
ArenaEvent.UpdateLoopChallengeTimesList = "ArenaEvent.UpdateLoopChallengeTimesList"

-- 更新循环赛的挑战列表
ArenaEvent.UpdateLoopChallengeList = "ArenaEvent.UpdateLoopChallengeList"

-- 更新循环赛列表单元
ArenaEvent.UpdateLoopChallengeListItem = "ArenaEvent.UpdateLoopChallengeListItem"

-- 更新循环赛前三排行榜数据
ArenaEvent.UpdateLoopChallengeStatueList = "ArenaEvent.UpdateLoopChallengeStatueList"

-- 更新循环赛排行榜数据
ArenaEvent.UpdateLoopChallengeRank = "ArenaEvent:UpdateLoopChallengeRank "

-- 竞技场红点状态
ArenaEvent.UpdateArenaRedStatus = "ArenaEvent.UpdateArenaRedStatus"

--购买挑战劵返回
ArenaEvent.UpdateArena_Number = "ArenaEvent.UpdateArena_Number"

--挑战胜利事件
ArenaEvent.ArenaFightResultEvent = "ArenaEvent.ArenaFightResultEvent"
---------冠军赛

ArenaEvent.CheckFightInfoEvent = "ArenaEvent.CheckFightInfoEvent"
ArenaEvent.ChangeTanFromTop324 = "ArenaEvent.ChangeTanFromTop324"

-- 冠军赛基础信息时间
ArenaEvent.UpdateChampionBaseInfoEvent = "ArenaEvent.UpdateChampionBaseInfoEvent"
-- 个人基础信息
ArenaEvent.UpdateChampionRoleInfoEvent = "ArenaEvent.UpdateChampionRoleInfoEvent"
-- 更新冠军赛top3的数据
ArenaEvent.UpdateChampionTop3Event = "ArenaEvent.UpdateChampionTop3Event"
-- 更新我的选拔赛数据
ArenaEvent.UpdateMyMatchInfoEvent = "ArenaEvent.UpdateMyMatchInfoEvent"
-- 更新竞猜的比赛数据
ArenaEvent.UpdateGuessMatchInfoEvent = "ArenaEvent.UpdateGuessMatchInfoEvent"
-- 押注某场比赛的返回
ArenaEvent.UpdateBetMatchValueEvent = "ArenaEvent.UpdateBetMatchValueEvent"
-- 我的竞猜更新
ArenaEvent.UpdateMyGuessListEvent = "ArenaEvent.UpdateMyGuessListEvent"
-- 冠军赛排行榜
ArenaEvent.UpdateChampionRankEvent = "ArenaEvent.UpdateChampionRankEvent"
-- 32强数据
ArenaEvent.UpdateTop32InfoEvent = "ArenaEvent.UpdateTop32InfoEvent"
-- 4强数据
ArenaEvent.UpdateTop4InfoEvent = "ArenaEvent.UpdateTop4InfoEvent"
-- 32强或者4强赛竞猜位置信息
ArenaEvent.UpdateTop324GuessGroupEvent = "ArenaEvent.UpdateTop324GuessGroupEvent"
-- 32或者4强赛指定位置的信息
ArenaEvent.UpdateTop324GroupPosEvent = "ArenaEvent.UpdateTop324GroupPosEvent"
-- 冠军赛可押注资产变化
ArenaEvent.UpdateRoleInfoBetEvent = "ArenaEvent.UpdateRoleInfoBetEvent"
-- 我的战斗日志
ArenaEvent.UpdateMylogListEvent = "ArenaEvent.UpdateMylogListEvent"

 --- 一些常量
ArenaConst = ArenaConst or {}

-- 竞技场类型，分为循环赛和排名赛
ArenaConst.arena_type = 
{
    loop = 1,
    rank = 2
}

-- 循环赛窗体的标签值
ArenaConst.loop_index = 
{
    challenge = 1,
    activity = 2,
    rank = 3,
    awards = 4,
}

-- 红点状态
ArenaConst.red_type = {
    loop_challenge = 1,
    loop_artivity = 2,
    champion_guess = 3,         -- 冠军赛竞猜阶段红点
    loop_log = 4,
}

-- 冠军赛主窗体的标签
ArenaConst.champion_index = {
    my_match_ready = 1,
    guess = 2,
    match = 3,
    rank = 4,
    my_match = 5,
}

-- 冠军赛阶段状态
ArenaConst.champion_step_status = {
    unopened = 0, -- 未到时间 
    opened = 1,   -- 进行中
    over = 2,     -- 结束
}

ArenaConst.champion_round_status = {
    prepare = 1,        -- 准备阶段
    guess = 2,          -- 竞猜阶段
    fight = 3           -- 对战阶段
}

-- 冠军赛阶段
ArenaConst.champion_step = {
    unopened = 0, -- 未开始
    score = 1, -- 选拔赛
    match_32 = 32, -- 32强赛
    match_4 = 4, --4强赛
    match_64 = 64, -- 64强赛
    match_8 = 8,   -- 8强赛
}

ArenaConst.champion_my_status = {
    unopened = 0,   -- 未开启
    unjoin = 1,     -- 没资格
    in_match = 2,   -- 可pk
}

-- 冠军赛类型
ArenaConst.champion_type = {
    normal = 1,  -- 本服冠军赛
    cross = 2,   -- 跨服冠军赛
}

-- 购买物品界面类型
ArenaConst.view_type = {
    arena = 1,  -- 竞技场和跨服竞技场
    summon = 2, -- 召唤
    elfin = 3,  -- 精灵
}


-- 冠军赛阶段描述
function ArenaConst.getMatchStepDesc(step)
    if step == ArenaConst.champion_step.unopened then
        return TI18N("暂未开始")
    elseif step == ArenaConst.champion_step.score then 
        return TI18N("选拔赛")
    elseif step == ArenaConst.champion_step.match_64 then
        return TI18N("64强赛")
    elseif step == ArenaConst.champion_step.match_32 then
        return TI18N("32强赛")
    elseif step == ArenaConst.champion_step.match_8 then 
        return TI18N("8强赛")
    elseif step == ArenaConst.champion_step.match_4 then 
        return TI18N("4强赛")
    end
    return TI18N("暂未开始")
end

-- 冠军赛阶段描述 16强 8强 这样的
function ArenaConst.getMatchStepDesc2(step, round)
    if step == ArenaConst.champion_step.match_64 then
        if round <= 1 then
            return TI18N("32强赛")
        elseif round == 2 then
            return TI18N("16强赛")
        else
            return TI18N("8强赛")
        end
    elseif step == ArenaConst.champion_step.match_32 then
        if round <= 1 then
            return TI18N("16强赛")
        elseif round == 2 then
            return TI18N("8强赛")
        else
            return TI18N("4强赛")
        end
    elseif step == ArenaConst.champion_step.match_8 then
        if round == 1 then
            return TI18N("4强赛")
        elseif round == 2 then
            return TI18N("半决赛")
        elseif round == 3 then
            return TI18N("决赛")
        else
            return TI18N("本轮冠军赛已结束")
        end
    elseif step == ArenaConst.champion_step.match_4 then
        if round == 1 then
            return TI18N("半决赛")
        elseif round == 2 then
            return TI18N("决赛")
        else
            return TI18N("本轮冠军赛已结束")
        end
    elseif step == ArenaConst.champion_step.score then
        if round == 0 then
            return TI18N("下次冠军赛")
        else
            return string.format(TI18N("%s第%s回合"), ArenaConst.getMatchStepDesc(step), round)
        end
    elseif step == ArenaConst.champion_step.unopened then
        return TI18N("下次冠军赛")
    else
        return TI18N("冠军赛暂未开始")
    end
end

-- 所在组的转换
function ArenaConst.getGroup(group)
    if group == 1 then
        return TI18N("A组")
    elseif group == 2 then
        return TI18N("B组")
    elseif group == 3 then
        return TI18N("C组")
    elseif group == 4 then
        return TI18N("D组")
    elseif group == 5 then
        return TI18N("E组")
    elseif group == 6 then
        return TI18N("F组")
    elseif group == 7 then
        return TI18N("G组")
    elseif group == 8 then
        return TI18N("H组")
    else
        return ""
    end
end