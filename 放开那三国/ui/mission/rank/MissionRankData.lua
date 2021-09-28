-- FileName: MissionRankData.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionRankData", package.seeall)

local _rankInfo = nil

function setInfo( pInfo )
	_rankInfo = pInfo
end

function getInfo( pInfo )
	return _rankInfo
end

function getMineFame()
	return  tonumber(_rankInfo.mine.fame)
end

function getMineRank()
	return  _rankInfo.mine.rank
end

function getRankList()
	local rankArray = {}
	for k,v in pairs(_rankInfo.list) do
		v.rank = tonumber(k)
		table.insert(rankArray, v)		
	end
	table.sort(rankArray, function ( h1, h2 )
		return h1.rank < h2.rank
	end)
	return rankArray
end

function getCDTime()
	local activityData = MissionMainData.getActivityData()
	local retNum = 10
	local configStr = activityData.data[1].cd or ""
	if string.len(configStr) < 1 then
		--为了兼容线上，给出了默认配置
		configStr = "0|60,1|30,2|30,3|30,4|30,5|20,6|20,7|15,8|15,9|10,10|10,11|5,12|4,13|3,14|2"
	end
	print("configStr",configStr)
	local configInfo = string.split(configStr, ",")
	local userVipLevel = UserModel.getVipLevel()
	for k,v in pairs(configInfo) do
		local timeInfo = string.split(v, "|")
		local needVipLevel = tonumber(timeInfo[1])
		local cdTime = tonumber(timeInfo[2])
		if userVipLevel >= needVipLevel then
			retNum = cdTime
		end
	end
	print("getCDTime", retNum)
	return retNum
end