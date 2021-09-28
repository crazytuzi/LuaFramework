-- FileName: CountryWarEncourageData.lua
-- Author: yangrui
-- Date: 2015-11-18
-- Purpose: 国战鼓舞

module("CountryWarEncourageData", package.seeall)

require "db/DB_National_war"

local _autoBattle            = false  -- 自动战斗勾选框状态
local _autoRecoveryBlood     = false  -- 自动回满血怒到指定的数值勾选框状态
local _autoRecoveryBloodNum  = 0      -- 自动回满血怒到指定的数值
local _isHaveBattleCD        = nil    -- 清除参战CD时间
local _forceUpValue          = 0      -- 攻击提升的值
local _defenceUpValue        = 0      -- 防御提升的值
local _encourageForceTimes   = 0      -- 鼓舞攻击次数
local _encourageDefenceTimes = 0      -- 鼓舞防御次数

--[[
	@des 	: 增加攻击提升的值
	@param 	: 
	@return : 
--]]
function addForceUpValue( pNum )
	_forceUpValue = _forceUpValue+tonumber(pNum)
end

--[[
	@des 	: 设置攻击提升的值
	@param 	: 
	@return : 
--]]
function setForceUpValue( ... )
	_forceUpValue = nil
	local upPercent = getEncourageUpForcePercent()
	local encouragedLv = getEncourageForceTimes()
	_forceUpValue = encouragedLv*tonumber(upPercent)
end

--[[
	@des 	: 获取攻击提升的值
	@param 	: 
	@return : 
--]]
function getForceUpValue( ... )
	return _forceUpValue
end

--[[
	@des 	: 增加防御提升的值
	@param 	: 
	@return : 
--]]
function addDefenceUpValue( pNum )
	_defenceUpValue = _defenceUpValue+tonumber(pNum)
end

--[[
	@des 	: 获取防御提升的值
	@param 	: 
	@return : 
--]]
function getDefenceUpValue( ... )
	return _defenceUpValue
end

--[[
	@des 	: 设置清除参战CD时间
	@param 	: 
	@return : 
--]]
function setBattleCDTime( pTime )
	_isHaveBattleCD = tonumber(pTime)
end

--[[
	@des 	: 获取清除参战CD时间
	@param 	: 
	@return : 
--]]
function getBattleCDTime( ... )
	return _isHaveBattleCD
end

--[[
	@des 	: 设置自动战斗勾选框状态
	@param 	: 
	@return : 
--]]
function setAutoBattleState( pState )
	_autoBattle = pState
end

--[[
	@des 	: 获取自动战斗勾选框状态
	@param 	: 
	@return : 
--]]
function getAutoBattleState( ... )
	return _autoBattle
end

--[[
	@des 	: 设置自动回满血怒到指定的数值勾选框状态
	@param 	: 
	@return : 
--]]
function setAutoRecoveryBlood( pState )
	_autoRecoveryBlood = pState
end

--[[
	@des 	: 获取自动回满血怒到指定的数值勾选框状态
	@param 	: 
	@return : 
--]]
function getAutoRecoveryBlood( ... )
	return _autoRecoveryBlood
end

--[[
	@des 	: 设置自动回满血怒到指定的数值
	@param 	: 
	@return : 
--]]
function setAutoRecoveryBloodNum( pNum )
	_autoRecoveryBloodNum = tonumber(pNum)
end

--[[
	@des 	: 获取自动回满血怒到指定的数值
	@param 	: 
	@return : 
--]]
function getAutoRecoveryBloodNum( ... )
	if _autoRecoveryBloodNum == 0 then
		_autoRecoveryBloodNum = getAutoRecoveryBloodRange()
	end
	return _autoRecoveryBloodNum
end

--[[
	@des 	: 增加鼓舞攻击次数
	@param 	: 
	@return : 
--]]
function addEncourageForceTimes( pNum )
	_encourageForceTimes = _encourageForceTimes+tonumber(pNum)
end

--[[
	@des 	: 获取鼓舞次数
	@param 	: 
	@return : 
--]]
function getEncourageForceTimes( ... )
	return _encourageForceTimes
end

--[[
	@des 	: 设置鼓舞次数
	@param 	: 
	@return : 
--]]
function setEncourageForceTimes( ... )
	_encourageForceTimes = CountryWarPlaceData.getAttkackLevel()
end

--[[
	@des 	: 增加鼓舞防御次数
	@param 	: 
	@return : 
--]]
function addEncourageDefenceTimes( pNum )
	_encourageDefenceTimes = _encourageDefenceTimes+tonumber(pNum)
end

--[[
	@des 	: 获取鼓舞防御次数
	@param 	: 
	@return : 
--]]
function getEncourageDefenceTimes( ... )
	return _encourageDefenceTimes
end

--[[
	@des 	: 判断是否需要回血
	@param 	: 
	@return : 
--]]
function judgeIsNeedRecoveryBlood( ... )
	local userInfo = CountryWarPlaceData.getUserInfoOnRoad()
	if userInfo ~= nil then
		local maxHp = tonumber(userInfo.maxHp)
		local curHp = tonumber(userInfo.curHp)
		return (curHp < maxHp)
	else
		return false
	end
end

------------------------------------------------------配置------------------------------------------------------
-- national_war
--[[
	@des 	: 获取鼓舞消耗
	@param 	: 
	@return : 
--]]
function getEncourageCost( ... )
	local encourageCost = DB_National_war.getDataById(1).cheer_cost
	return encourageCost
end

--[[
	@des 	: 获取鼓舞提升百分比
	@param 	: 
	@return : 
--]]
function getEncourageUpPercent( ... )
	local encourageUpPercentData = DB_National_war.getDataById(1).cheer_percent
	local encourageTab = string.split(encourageUpPercentData,";")
	local forceUpTab = string.split(encourageTab[1],"|")
	local defenceUpTab = string.split(encourageTab[2],",")
	local defenceUpDetailTab = {}
	for index,data in pairs(defenceUpTab) do
		local defenceUpDetailData = string.split(data,"|")
		table.insert(defenceUpDetailTab,defenceUpDetailData)
	end
	return forceUpTab,defenceUpDetailTab
end

--[[
	@des 	: 获取鼓舞 攻击提升百分比
	@param 	: 
	@return : 
--]]
function getEncourageUpForcePercent( ... )
	local forceUpTab = getEncourageUpPercent()
	return tonumber(forceUpTab[2])/100
end

--[[
	@des 	: 获取鼓舞 防御提升百分比
	@param 	: 
	@return : 
--]]
function getEncourageUpDefencePercent( ... )
	local _,defenceUpDetailTab = getEncourageUpPercent()
	local upVal = 0
	for index,data in pairs(defenceUpDetailTab) do
		if upVal < tonumber(data[2]) then
			upVal = tonumber(data[2])
		end
	end
	return upVal/100
end

--[[
	@des 	: 获取鼓舞上限等级
	@param 	: 
	@return : 
--]]
function getEncourageUpperLevel( ... )
	local encourageUpperLevel = DB_National_war.getDataById(1).cheer_level
	return encourageUpperLevel
end

--[[
	@des 	: 获取参战冷却CD
	@param 	: 
	@return : 
--]]
function getBattleCD( ... )
	local battleCD = DB_National_war.getDataById(1).cd
	return battleCD
end

--[[
	@des 	: 获取清除冷却国战币消耗
	@param 	: 
	@return : 
--]]
function getRemoveBattleCDCost( ... )
	local battleCDCost = DB_National_war.getDataById(1).resetcd_cost
	return battleCDCost
end

--[[
	@des 	: 获取回满血怒国战币消耗
	@param 	: 
	@return : 
--]]
function getRecoveryBloodCost( ... )
	local recoveryBloodCost = DB_National_war.getDataById(1).recover_cost
	return recoveryBloodCost
end

--[[
	@des 	: 获取自动回血范围
	@param 	: 
	@return : 
--]]
function getAutoRecoveryBloodRange( ... )
	local rangeData = DB_National_war.getDataById(1).recover_range
    local rangeTab = string.split(rangeData,"|")
    local lower = tonumber(rangeTab[1])
    local upper = tonumber(rangeTab[2])
	return lower/100,upper/100
end
