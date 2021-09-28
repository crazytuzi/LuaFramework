-- FileName: MissionGoldData.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionGoldData", package.seeall)
require "script/ui/mission/MissionMainData"

--[[
	@des:计算指定金币得到的名望
--]]
function getFameByGold( pGoldNum )
	local activityData = MissionMainData.getActivityData()
	local goldFame = tonumber(activityData.data[1].gold_fame)
	return goldFame*pGoldNum
end

--[[
	@des:得到捐献金币的档位
--]]
function getDonationList()
	local activityData = MissionMainData.getActivityData()
	local goldTpye = activityData.data[1].gold_tpye
	local goldList = string.split(goldTpye, ",")
	return goldList
end