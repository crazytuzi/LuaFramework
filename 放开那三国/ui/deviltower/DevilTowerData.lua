-- FileName: DevilTowerData.lua
-- Author: lgx
-- Date: 2016-07-29
-- Purpose: 试炼梦魇数据处理

module("DevilTowerData", package.seeall)

require "db/DB_Nightmare_layer"
require "db/DB_Nightmare_tower"
require "script/ui/tip/AnimationTip"
require "script/utils/TimeUtil"

-- 模块局部变量 --
local _devilTowerInfo 	= nil -- 试炼梦魇信息


--[[
	@desc	: 设置试炼梦魇信息
    @param	: pInfo 后端返回的试炼信息
    @return	: 
—-]]
function setDevilTowerInfo( pInfo )
	_devilTowerInfo = pInfo
	-- 计算扫荡结束时间
	if ((not table.isEmpty(_devilTowerInfo.va_tower_info)) and (not table.isEmpty(_devilTowerInfo.va_tower_info.sweep_hell_info))) then
		if( _devilTowerInfo.va_tower_info.sweep_hell_info.start_time )then
			local hellInfo = _devilTowerInfo.va_tower_info.sweep_hell_info
			local startTime = tonumber(hellInfo.start_time)
			local startLevel = tonumber(hellInfo.start_level)
			local endLevel = tonumber(hellInfo.end_level)
			_devilTowerInfo.endTime = startTime + getWipeCD() * (endLevel - startLevel + 1)
		end
	end
end

--[[
	@desc	: 获取试炼梦魇信息
    @param	: 
    @return	: 
—-]]
function getDevilTowerInfo()
	return _devilTowerInfo
end

--[[
	@desc	: 获取扫荡开始时间
    @param	: 
    @return	: 
—-]]
function getSweepStartTime()
	local hellInfo = _devilTowerInfo.va_tower_info.sweep_hell_info
	local startTime = tonumber(hellInfo.start_time)
	return startTime
end

--[[
	@desc	: 获取扫荡结束时间
    @param	: 
    @return	: 
—-]]
function getSweepEndTime()
	return _devilTowerInfo.endTime
end

--[[
	@desc	: 是否在扫荡中
    @param	: 
    @return	: 
—-]]
function isDevilTowerSweep()
	local isSweep = false
	local towerInfo = getDevilTowerInfo()
	if( (not table.isEmpty(towerInfo)) and towerInfo.endTime and towerInfo.endTime >= TimeUtil.getSvrTimeByOffset())then
		isSweep = true
	end
	return isSweep
end

--[[
	@desc	: 修改当前扫荡到的塔层数
    @param	: 
    @return	: 
—-]]
function changeCurSweepHell()
	if (isDevilTowerSweep() == true) then
		local hellInfo = _devilTowerInfo.va_tower_info.sweep_hell_info
		local startTime = tonumber(hellInfo.start_time)
		local startLevel = tonumber(hellInfo.start_level)
		local sweepInterval = TimeUtil.getSvrTimeByOffset() - startTime
		local addHell = math.floor(sweepInterval/getWipeCD())
		_devilTowerInfo.cur_hell = startLevel + addHell
	end
end

--[[
	@desc	: 增减当前攻打的塔层
    @param	: pAddNum 增减层数
    @return	: 
—-]]
function addCurHell( pAddNum )
	_devilTowerInfo.cur_hell = tonumber(_devilTowerInfo.cur_hell) + tonumber(pAddNum)

	-- 修改攻打的最高塔层
	changeMaxHell(tonumber(_devilTowerInfo.cur_hell) - 1)

	if (tonumber(_devilTowerInfo.cur_hell) > getMaxDevilTower()) then

		-- 是否已达最大层
		_devilTowerInfo.cur_hell = getMaxDevilTower()

		-- 设置已通关
		setDevilTowerPassedStatus(true)
	end
end

--[[
	@desc	: 修改当前攻打的塔层
    @param	: 
    @return	: 
—-]]
function changeCurHell( pCurHell )
	_devilTowerInfo.cur_hell = pCurHell
end

--[[
	@desc	: 修改攻打过的最高塔层
    @param	: pMaxHell 攻打过的最高塔层
    @return	: 
—-]]
function changeMaxHell( pMaxHell )
	if(tonumber(pMaxHell) > tonumber(_devilTowerInfo.max_hell)) then
		_devilTowerInfo.max_hell = pMaxHell
	end
end

--[[
	@desc	: 获取试炼梦魇是否开启
    @param	: pShowTip 是否显示提示，默认显示
    @return	: 试炼梦魇是否开启
—-]]
function isDevilTowerOpen( pShowTip )
	local isOpen = false
	local needLv = getOpenLevel()
	local userLv = UserModel.getAvatarLevel()
	if (userLv >= needLv) then
		isOpen = true
	end
	if (pShowTip == nil or pShowTip == true) then
		if (isOpen == false) then
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1212",needLv))
		end
	end
	return isOpen
end

--[[
	@desc	: 获取试炼梦魇配置表数据
    @param	: 
    @return	: table 试炼梦魇配置表数据
—-]]
function getDevilTowerDB()
	local devilTowerDB = DB_Nightmare_tower.getDataById(1)
	return devilTowerDB
end

--[[
	@desc	: 获取试炼梦魇系统开启的等级限制
    @param	: 
    @return	: number 开启的等级限制
—-]]
function getOpenLevel()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.level)
end

--[[
	@desc	: 获取最大失败次数
    @param	: 
    @return	: number 最大失败次数
—-]]
function getMaxLoseTimes()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.loseTime)
end

--[[
	@desc	: 获取最大购买失败次数
    @param	: 参数说明
    @return	: 是否有返回值，返回值说明  
—-]]
function getMaxBuyLoseTimes()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.loseMaxTimes)
end

--[[
	@desc	: 获取购买失败次数所需的金币数
    @param	: pTimes 失败次数
    @return	: number 金币数
—-]]
function getCostGoldByTimes( pTimes )
	pTimes = tonumber(pTimes)
	local devilTowerDB = getDevilTowerDB()
	local costGold = devilTowerDB.loseTimeBaseGold + devilTowerDB.loseTimeGrowGold * (pTimes -1)
	return costGold
end

--[[
	@desc	: 增减购买失败次数
    @param	: pNum 购买次数
    @return	: 
—-]]
function addBuyDefeatNumByGold( pNum )
	_devilTowerInfo.gold_buy_hell = tonumber(_devilTowerInfo.gold_buy_hell) + pNum
end

--[[
	@desc	: 增减失败次数
    @param	: pTimes 次数
    @return	: 
—-]]
function addDefeatTimes( pTimes )
	_devilTowerInfo.can_fail_hell = tonumber(_devilTowerInfo.can_fail_hell) + tonumber(pTimes)
end

--[[
	@desc	: 修改失败次数
    @param	: pTimes 次数
    @return	: 
—-]]
function changeDefeatTimes( pTimes )
	_devilTowerInfo.can_fail_hell = tonumber(pTimes)
end

--[[
	@desc	: 获取每层扫荡时间
    @param	: 
    @return	: number 每层扫荡时间
—-]]
function getWipeCD()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.wipeCd)
end

--[[
	@desc	: 获取扫荡每层需要金币数
    @param	: 
    @return	: number 金币数
—-]]
function getWipeGold()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.wipeGold)
end

--[[
	@desc	: 获取每日爬塔次数（可重置的次数）
    @param	: 
    @return	: number 可重置次数
—-]]
function getMaxResetTimes()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.times)
end

--[[
	@desc	: 获取金币重置的最大次数
    @param	: 参数说明
    @return	: 是否有返回值，返回值说明  
—-]]
function getMaxBuyResetTimes()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.resetMaxTimes)
end

--[[
	@desc	: 获取金币重置所需的金币数
    @param	: 
    @return	: number 金币数
—-]]
function getResetCostGold()
	local devilTowerDB = getDevilTowerDB()
	return tonumber(devilTowerDB.TimeBaseGold)
end

--[[
	@desc	: 增减重置次数
    @param	: pTimes 次数
    @return	: 
—-]]
function addResetTimes( pTimes )
	_devilTowerInfo.reset_hell = tonumber(_devilTowerInfo.reset_hell) + tonumber(pTimes)
end

--[[
	@desc	: 增减金币购买重置的次数
    @param	: pTimes 次数
    @return	: 
—-]]
function addResetTimesByGold( pTimes )
	if( _devilTowerInfo.buy_hell_num)then
		_devilTowerInfo.buy_hell_num = tonumber(_devilTowerInfo.buy_hell_num) + pTimes
	else
		_devilTowerInfo.buy_hell_num = pTimes
	end
end


--[[
	@desc	: 是否已通关
    @param	: 
    @return	: 
—-]]
function isDevilTowerHadPassed()
	local isHadPassed = false
	local towerInfo = getDevilTowerInfo()
	if( tonumber(towerInfo.cur_hell) == getMaxDevilTower() and  towerInfo.va_tower_info.cur_hell_status and tonumber(towerInfo.va_tower_info.cur_hell_status) == 1 )then
		isHadPassed = true
	end
	return isHadPassed
end

--[[
	@desc	: 修改通关状态
    @param	: pStatus 通关状态 bool
    @return	: 
—-]]
function setDevilTowerPassedStatus( pStatus )
	if (pStatus == true) then
		_devilTowerInfo.va_tower_info.cur_hell_status = 1
	else
		_devilTowerInfo.va_tower_info.cur_hell_status = 0
	end
end

--[[
	@desc	: 获取试炼梦魇最高塔的层数
    @param	: 
    @return	: number 最高塔的层数
—-]]
function getMaxDevilTower()
	local maxTower = table.count(DB_Nightmare_layer.Nightmare_layer)
	return maxTower
end

--[[
	@desc	: 根据塔层id获取某一层的信息
    @param	: pLayerId 塔层id
    @return	: 
—-]]
function getDevilTowerById( pLayerId )
	return DB_Nightmare_layer.getDataById(tonumber(pLayerId))
end

--[[
	@desc	: 获取通关条件描述
    @param	: pCondition 表中配置的条件 1|15 ...
    @return	: string 通关条件
—-]]
function getPassFloorCondition( pCondition )
	local conditionStr = GetLocalizeStringBy("key_1089")
	if (pCondition) then
		local conditionArr = string.split(pCondition, "|")
		if(not table.isEmpty(conditionArr))then
			conditionStr = getPassConditionStr(conditionArr[1], conditionArr[2])
		end
	end
	return conditionStr
end

--[[
	@desc	: 根据表中配置的id和次数获取条件文字描述
    @param	: pId 条件id 
    @param	: pNum 条件次数
    @return	: 条件文字描述
—-]]
function getPassConditionStr( pId, pNum )
	local conditionStrArr = {}
	table.insert(conditionStrArr, GetLocalizeStringBy("key_1581") .. pNum)
	table.insert(conditionStrArr, GetLocalizeStringBy("key_3350") .. string.format("%.2f", pNum/10000)*100 .. "%")
	table.insert(conditionStrArr, GetLocalizeStringBy("key_2240") .. pNum)
	table.insert(conditionStrArr, GetLocalizeStringBy("key_1614") .. pNum)
	table.insert(conditionStrArr, GetLocalizeStringBy("key_1230") .. pNum .. GetLocalizeStringBy("key_1920"))
	table.insert(conditionStrArr, GetLocalizeStringBy("key_1230") .. pNum .. GetLocalizeStringBy("key_1083"))
	return conditionStrArr[tonumber(pId)]
end


