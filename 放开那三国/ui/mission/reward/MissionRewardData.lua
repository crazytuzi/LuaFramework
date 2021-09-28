-- FileName: MissionRewardData
-- Author: shengyixian
-- Date: 2015-09-06
-- Purpose: 奖励数据

module("MissionRewardData",package.seeall)
-- 悬赏榜活动标识
local kBounty = "bounty"
-- 国战活动标识
local kCountryWar = "countryWar"
-- 排行奖励的数据
local _rankData = nil
-- 俸禄奖励的数据
local _payData = nil
-- 国战初赛奖励的数据
local _preliminaryData =  nil
-- 国战决赛奖励的数据
local _finalsData = nil
--[[
	@des 	: 根据活动名称获取奖励的数据
	@param 	: 
	@return : 
--]]
function getDataByActName( pActName )
	if pActName == kBounty then
		if not _rankData then
			setTaskInfoByDB()
		end
	else
		if not _preliminaryData then
			setCountryWarRewardDataByDB()
		end
	end
end
--[[
	@des 	: 根据配置获取悬赏榜奖励的数据
	@param 	: 
	@return : 
--]]
function setTaskInfoByDB()
	_rankData = {}
	_payData = {}
	for k,v in pairs(DB_Bounty_reward.Bounty_reward) do
		local rewardData = DB_Bounty_reward.getDataById(v[1])
		local rewardAry = string.split(rewardData["reward"],",")
		rewardData["rewardAry"] = rewardAry
		if v[1] < 11 then
			table.insert(_rankData,rewardData)
		else
			table.insert(_payData,rewardData)
		end
	end
	local sortFun = function (v1,v2)
		return v1.id < v2.id
	end
	table.sort(_rankData,sortFun)
	table.sort(_payData,sortFun)
end
--[[
	@des 	: 根据配置获取国战奖励的数据
	@param 	: 
	@return : 
--]]
function setCountryWarRewardDataByDB()
	require "db/DB_National_war_reward"
	_preliminaryData = {}
	_finalsData = {}
	for k,v in pairs(DB_National_war_reward.National_war_reward) do
		local rewardData = DB_National_war_reward.getDataById(v[1])
		rewardData.rewardAry = string.split(rewardData.reward,",")
		if tonumber(rewardData.first_final) == 1 then
		 	-- 初赛奖励
		 	table.insert(_preliminaryData,rewardData)
		else
			-- 决赛奖励
			table.insert(_finalsData,rewardData)
		end
	end
	local sortFun = function (v1,v2)
		return v1.id < v2.id
	end
	table.sort(_preliminaryData,sortFun)
	table.sort(_finalsData,sortFun)
end
--[[
	@des 	: 获取排行奖励的数据
	@param 	: 
	@return : 
--]]
function getRankData( ... )
	return _rankData
end
--[[
	@des 	: 获取俸禄奖励的数据
	@param 	: 
	@return : 
--]]
function getPayData( ... )
	return _payData
end
--[[
	@des 	: 获取国战初赛奖励的数据
	@param 	: 
	@return : 
--]]
function getPreliminaryData( ... )
	return _preliminaryData
end
--[[
	@des 	: 获取国战决赛奖励的数据
	@param 	: 
	@return : 
--]]
function getFinalsData( ... )
	return _finalsData
end