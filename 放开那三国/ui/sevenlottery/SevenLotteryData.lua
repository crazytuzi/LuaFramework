-- Filename：	SevenLotteryData.lua
-- Author：		LLP
-- Date：		2016-8-3
-- Purpose：		七星潭


module("SevenLotteryData", package.seeall)

local _totalData = nil

function setData( pInfo )
	_totalData = pInfo
end

function getData( ... )
	return _totalData
end

function isShow( ... )
	local canShow = false
	if DataCache.getSwitchNodeState(ksSwitchSevenLottery,false) then
		canShow = true
	end
	return canShow
end