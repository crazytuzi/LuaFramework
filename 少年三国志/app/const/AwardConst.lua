require("app.cfg.arena_reward_info")

local AwardConst = {

--出售类型时也调用这个
    AWARD_TYPE = {
        AWARD_TYPE_MONEY              = 1,
        AWARD_TYPE_GOLD               = 2,
        AWARD_TYPE_ITEM               = 3,
        AWARD_TYPE_KNIGHT             = 4,
        AWARD_TYPE_EQUIPMENT          = 5,
        AWARD_TYPE_Fragment           = 6,
        AWARD_TYPE_SPECIAL_EQUIPMENT  = 7,
        AWARD_TYPE_PRESTIGE           = 8,
    },
    --战斗成功 获取声望
    PRESTIGE_SUCCESS = 20,
    --战斗失败获取声望
    PRESTIGE_FAILED = 10,
    --挑战成功 根据等级奖励
    CHALLENGE_AWARDS_MONEY_FACTOR = 200,
}



--竞技场排行奖励1
function AwardConst.getAwardGoods01(rank)
    for i=1,arena_reward_info.getLength() do
        local perData = arena_reward_info.indexOf(i)
        if perData.rank_type == 1 then
            if rank >= perData.min_rank and rank <= perData.max_rank then
                local goods = G_Goods.convert(perData.day_type1,perData.day_value1)
                goods["size"] = perData.day_size1
                return goods
            end
            
        end
    end
    return nil
end
--竞技场排行奖励2
function AwardConst.getAwardGoods02(rank)
    for i=1,arena_reward_info.getLength() do
        local perData = arena_reward_info.indexOf(i)
        if perData.rank_type == 1 then
            if rank >= perData.min_rank and rank <= perData.max_rank then
                local goods = G_Goods.convert(perData.day_type2,perData.day_value2)
                goods["size"] = perData.day_size2
                return goods
            end
        end
    end
    return nil
end

--竞技场排行奖励3
function AwardConst.getAwardGoods03(rank)
    for i=1,arena_reward_info.getLength() do
        local perData = arena_reward_info.indexOf(i)
        if perData.rank_type == 1 then
            if rank >= perData.min_rank and rank <= perData.max_rank then
                local goods = G_Goods.convert(perData.day_type3,perData.day_value3)
                goods["size"] = perData.day_size3
                return goods
            end
        end
    end
    return nil
end

-- 获取当前排行的下一个目标排行
function AwardConst.getNextAwardsRank( rank )    
    -- 已经是第一名了
    if rank == 1 then 
        return 0
    end
    -- 还没达到最低排行标准
    if rank > AwardConst.getMaxAwardsRank() then 
        return AwardConst.getMaxAwardsRank()
    end

    for i = 1, arena_reward_info.getLength() do
        local perData = arena_reward_info.indexOf(i)
        if perData.rank_type == 1 then
            if rank >= perData.min_rank and rank <= perData.max_rank then
                local nextRank = perData.min_rank - 1
                return nextRank
            end
        end
    end
    return nil
end

-- 配置中能够获得排行奖励的最大排行
function AwardConst.getMaxAwardsRank( ... )
    -- 所有rank_type=1的条目，因为有别的rank_type所以不方便直接获取
    local rankAwardsList = {}
    for i = 1, arena_reward_info.getLength() do
        local data = arena_reward_info.indexOf(i)
        if data.rank_type == 1 then
            table.insert(rankAwardsList, data)
        end
    end
    local maxRankData = rankAwardsList[#rankAwardsList]
    return maxRankData.max_rank 
end

function AwardConst.getAwardsExp(rank)
    return rank*10
end

return AwardConst

