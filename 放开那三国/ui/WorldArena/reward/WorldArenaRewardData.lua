-- FileName: WorldArenaRewardData.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 奖励预览数据
--[[TODO List]]

module("WorldArenaRewardData", package.seeall)

require "script/ui/WorldArena/WorldArenaMainData"

--[[
	@des 	: 排行名次
	@param 	: 
	@return : 
--]]
function getRankDesData( ... )
	local retData = nil
	local configData = WorldArenaMainData.getworldArenaConfig()

	local rankStr = configData.reward_des
	retData = string.split(rankStr, ",")
	return retData
end

--[[
	@des 	: 排行奖励数据 1,12|0|1000,3|0|1000;2,12|0|950,3|0|950
	@param 	: p_type 1:击杀排行奖励，2:连杀排行奖励 3:对决排行奖励
	@return : { {rankDes = "xx", maxRank = 1, rewardTab = { {type=12,id=0,num=1000}, }, }, }
--]]
function getRankRewardData( p_type )
	local rankDesTab = getRankDesData()
	local retData = {}
	local configData = WorldArenaMainData.getworldArenaConfig()

	local rewardKeyTab = { configData.kill_reward, configData.continue_reward, configData.rank_reward }
	local rewardStrTab = string.split(rewardKeyTab[p_type], ";")
	for i=1,#rewardStrTab do
		local tab = {}
		tab.rankDes = rankDesTab[i]
		tab.rewardTab = {}
		local temStr = string.split(rewardStrTab[i], ",")
		tab.maxRank = tonumber(temStr[1])
		for n=2,#temStr do
			local temStr2 = string.split(temStr[n], "|")
			local tab2 = {}
			tab2.type = temStr2[1]
	        tab2.id   = temStr2[2]
	        tab2.num  = temStr2[3]
	        table.insert(tab.rewardTab,tab2)
		end
		table.insert(retData,tab)
	end
	return retData
end


--[[
	@des 	: 奖励数据 1,12|0|1000,3|0|1000;2,12|0|950,3|0|950
	@param 	: p_type 1:连杀奖励，2:终结连杀排行奖励 
	@return : { {rankDes = "xx", maxNum = 1, rewardTab = { {type=12,id=0,num=1000}, }, }, }
--]]
function getKillRewardDataByType( p_type )
	local retData = {}
	local configData = WorldArenaMainData.getworldArenaConfig()

	local rewardKeyTab = { configData.streak, configData.break_streak }
	local rewardStrTab = string.split(rewardKeyTab[p_type], ";")
	for i=1,#rewardStrTab do
		local tab = {}
		tab.rewardTab = {}
		local temStr = string.split(rewardStrTab[i], ",")
		tab.maxNum = tonumber(temStr[1])
		for n=2,#temStr do
			local temStr2 = string.split(temStr[n], "|")
			local tab2 = {}
			tab2.type = temStr2[1]
	        tab2.id   = temStr2[2]
	        tab2.num  = temStr2[3]
	        table.insert(tab.rewardTab,tab2)
		end
		table.insert(retData,tab)
	end
	return retData
end

--[[
	@des 	: 得到当前连杀奖励 或者 终结连杀奖励
	@param 	: p_type 1:连杀奖励，2:终结连杀排行奖励  p_curNum 当前连杀数
	@return : {  }
--]]
function getCurKillReward( p_type, p_curNum )
	local rewardData = nil
	local data = getKillRewardDataByType(p_type)
	for i=1,#data do
		if( tonumber(p_curNum) <= data[i].maxNum )then
			rewardData = data[i].rewardTab
			break
		end
	end
	if(rewardData == nil)then
		rewardData = {}
	end
	return rewardData
end










