-- Filename: GuildWarSupportData.lua
-- Author: bzx
-- Date: 2015-1-19
-- Purpose: 助威数据

module("GuildWarSupportData", package.seeall)

require "db/DB_Kuafu_legionchallengereward"
require "db/DB_Kuafu_legionchallenge"

local _cheerRewards
local _mySupportList


--[[
    @desc:  获取助威的奖励
--]]
function getCheerRewards()
    if _cheerRewards == nil then
        -- require "script/model/utils/ActivityConfig"
        -- local data = ActivityConfig.ConfigCache.lordwar.data[1]
        -- local cheerRewardsDb = string.split(data.cheerReward, ",")
        -- print("dataReward=", data.cheerReward)
        -- print_t(cheerRewardsDb)
        local cheerRewardId = tonumber(ActivityConfig.ConfigCache.guildwar.data[1].cheerPrize)
        _cheerRewards = ItemUtil.getItemsDataByStr(DB_Kuafu_legionchallengereward.getDataById(cheerRewardId).reward)
    end
    return _cheerRewards
end

function getCheerCost()
	local costData = {}
	costData.costType = 1
	local costBaseCount = tonumber(ActivityConfig.ConfigCache.guildwar.data[1].cheerCost)
	local costCount = costBaseCount * UserModel.getHeroLevel()
	costData.costCount = costCount
	return costData
end

--[[
    @desc:                              得到指定轮次助威结束的时刻
    @param:     number      p_rank      轮次
    @return:    number 
--]]
function getSupportEndTime( p_rank )
    local rankRound = GuildWarPromotionData.getRoundByRank(p_rank)
    local roundStartTime = GuildWarMainData.getStartTime(rankRound)
    local cheerFreezeTime = tonumber(ActivityConfig.ConfigCache.guildwar.data[1].cheerFreezeTime)
    print("cheerFreezeTime ====", cheerFreezeTime)
    local supportEndTime = roundStartTime - cheerFreezeTime
    return supportEndTime
end

--[[
	@desc:										设置已经助威的table
	@param:		table		p_mySupportList		
	@return:	nil
--]]
function setMySupportList( p_mySupportList )
	_mySupportList = p_mySupportList
end

--[[
	@desc:							得到已经助威的列表
	@return:		table
--]]
function getMySupportList( ... )
	return _mySupportList
end

--[[
    @des: 得到支持列表数据
--]]
function getMySupportTableData( ... )
    local supportInfo = getMySupportList()
    local retTable = {}
    for k,v in pairs(supportInfo) do
        v.round = k
        table.insert(retTable, v)
    end
    table.sort(retTable, function ( h1, h2 )
        return tonumber(h1.round) > tonumber(h2.round)
    end)
    return retTable
end

