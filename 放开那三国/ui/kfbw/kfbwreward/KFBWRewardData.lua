-- FileName: KFBWRewardData.lua 
-- Author: shengyixian
-- Date: 15-10-10
-- Purpose: 跨服比武奖励预览数据层

module("KFBWRewardData", package.seeall)
require "db/DB_Kuafu_contest_reward"

local _tReward = nil

function setRewardData( ... )
	-- body
	_tReward = {}
	for k,v in pairs(DB_Kuafu_contest_reward.Kuafu_contest_reward) do
		local rewardData = DB_Kuafu_contest_reward.getDataById(v[1])
		local rewardAry = string.split(rewardData["reward"],",")
		rewardData["rewardAry"] = rewardAry
		table.insert(_tReward,rewardData)
	end
	table.sort(_tReward,function ( t1,t2 )
		-- body
		return t1.id < t2.id
	end)
end

function getRewardData( ... )
	-- body
	if not(_tReward) then
		setRewardData()
	end
	return _tReward
end
--[[
	@des 	: 获取当前时间是周几
	@param 	: 
--]]
function getCurrWeek( ... )
	-- body
	local timeStr = DB_Kuafu_contest.Kuafu_contest["id_1"][2]
	local timeStrAry = string.split(timeStr,",")
	local day = tonumber((string.split(timeStrAry[2],"|"))[1])
	return day
end