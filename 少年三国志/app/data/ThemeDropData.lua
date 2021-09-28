require("app.cfg.theme_drop_info")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local ThemeDropConst = require("app.const.ThemeDropConst")
local ThemeDropData = class("ThemeDropData")


function ThemeDropData:ctor()
	self._tInitInfo = {
	    _nGroupCycle = 0,	-- 当前抽将的阵营
	    _nStarValue = 0, -- 星运值
	    _nRemainDropTimes = 0, -- 一天剩余抽将次数
	    _nFreeTimes = 0, -- 一天免费次数
    }

    self._nOncePrice = 268 -- 占星一次花费268元宝
    self._nTenPrice = 2518 -- 占星十次花费268元宝

    self._szDate = nil -- 当前日期
end

function ThemeDropData:storeInitializeInfo(data)
	self._szDate = G_ServerTime:getDate()

	local tInfo = {}
	tInfo._nGroupCycle = data.zy_cycle
	tInfo._nStarValue = data.star_value
	tInfo._nRemainDropTimes = data.left_consume_times
	tInfo._nFreeTimes = data.left_free_times

	self._tInitInfo = tInfo
end

function ThemeDropData:getInitializeInfo()
	return self._tInitInfo
end

-- 是否隔天了
function ThemeDropData:isAnotherDay()
	local isAnotherDay = self._szDate ~= nil and self._szDate ~= G_ServerTime:getDate()
	if isAnotherDay then
		self._szDate = G_ServerTime:getDate()
	end
	return isAnotherDay
end

function ThemeDropData:updateRemainDropTimes(nTimes)
	nTimes = nTimes or 0
	self._tInitInfo._nRemainDropTimes = nTimes
end

function ThemeDropData:getRemainDropTimes()
	return self._tInitInfo._nRemainDropTimes
end

function ThemeDropData:updateFreeDropTimes(nTimes)
	nTimes = nTimes or 0
	self._tInitInfo._nFreeTimes = nTimes
end

function ThemeDropData:getFreeTimes()
	return self._tInitInfo._nFreeTimes
end

function ThemeDropData:updateStarValue(nStarValue)
	nStarValue = nStarValue or 0
	self._tInitInfo._nStarValue = nStarValue
end

function ThemeDropData:getStarValue()
	return self._tInitInfo._nStarValue
end

-- 有没有免费抽碎片次数
function ThemeDropData:hasFreeTimes()
	return self._tInitInfo._nFreeTimes > 0
end

-- 是不是可以领取红将
function ThemeDropData:couldExtractKnight()
	return self._tInitInfo._nStarValue >= ThemeDropConst.TOTAL_SCHEDULE
end

function ThemeDropData:getOnceAstrologyCost()
	return self._nOncePrice
end

function ThemeDropData:getTenAstrologyCost()
	return self._nTenPrice
end

function ThemeDropData:getChangeGroupRemainTime()
	if self._tInitInfo._nGroupCycle % 2 == 0 then
		self._nChangeTime = G_ServerTime:getTime() + G_ServerTime:getCurrentDayLeftSceonds() + 24*60*60 + 1
	else
		self._nChangeTime = G_ServerTime:getTime() + G_ServerTime:getCurrentDayLeftSceonds() + 1
	end
	return self._nChangeTime or 0
end

return ThemeDropData