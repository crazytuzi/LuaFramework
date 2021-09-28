-- Filename：	TowerCache.lua
-- Author：		Cheng Liang
-- Date：		2013-1-7
-- Purpose：		爬塔缓存

module("TowerCache", package.seeall)

require "script/ui/tower/TowerUtil"
require "script/utils/TimeUtil"

local _towerInfo = nil 	-- 爬塔的信息

-- 设置
function setTowerInfo(towerInfo)
	_towerInfo = towerInfo
	-- 处理扫荡
	if((not table.isEmpty(_towerInfo.va_tower_info)) and (not table.isEmpty(_towerInfo.va_tower_info.sweep_info)) )then
		if( _towerInfo.va_tower_info.sweep_info.start_time )then
			_towerInfo.end_time = tonumber(_towerInfo.va_tower_info.sweep_info.start_time) + TowerUtil.getWipeCD() * (tonumber(_towerInfo.va_tower_info.sweep_info.end_level) - tonumber(_towerInfo.va_tower_info.sweep_info.start_level) + 1)
		end
	end
end

-- 设置神秘层数据
function setSpeTowerInfo(towerInfo)
	_towerInfo.va_tower_info.special_tower.specail_tower_list = towerInfo
	-- body
end


-- 获得塔的信息
function getTowerInfo()
	return _towerInfo
end

-- 判断有没有神秘塔层
function haveSceretTower()
	-- body
	local towerInfo = getTowerInfo()
	if(towerInfo~=nil)then
		if(not table.isEmpty(towerInfo.va_tower_info.special_tower.specail_tower_list))then
			return true	
		else
			return false
		end
	end
end

-- 判断是否还有神秘层
function haveOrNotSceret()
	-- body
	local _towerInfo = getTowerInfo()
	if(_towerInfo==nil)then
		return false
	end
    local _secretNum = 0
    if(_towerInfo.va_tower_info.special_tower ~= nil)then
        if(not table.isEmpty(_towerInfo.va_tower_info.special_tower.specail_tower_list))then
            for k,v in pairs (_towerInfo.va_tower_info.special_tower.specail_tower_list) do
                _secretNum = _secretNum + 1
            end
        end
    end
    if(_secretNum==0)then
        return false
    else
    	return true
    end
end

-- 修改当前攻打的层
function changeCurFloorLevel(level)
	_towerInfo.cur_level = level
end

-- 得到金币购买重置的次数
function getTimesByGoldReset()
	local reset_times = 0
	if(_towerInfo and _towerInfo.buy_atk_num)then
		reset_times = tonumber(_towerInfo.buy_atk_num)
	end
	return reset_times
end

-- 得到金币某次购买的金币数
function getGoldByResetTimes( cur_times)
	local gold_cost = 0
	require "db/DB_Vip"
	local vipInfo = DB_Vip.getDataById(UserModel.getVipLevel() +1)
	if(vipInfo and vipInfo.towerCost)then
		local towerCostArr = string.split(vipInfo.towerCost, "|")
		gold_cost = tonumber(towerCostArr[2] ) + (cur_times -1) * tonumber(towerCostArr[3])
	end
	return gold_cost
end

-- 增减金币购买重置的次数
function addGoldResetTimesBy( add_times )
	if( _towerInfo.buy_atk_num)then
		_towerInfo.buy_atk_num = tonumber(_towerInfo.buy_atk_num) + add_times
	else
		_towerInfo.buy_atk_num = add_times
	end
end

-- 增减当前攻打的层
function addCurFloorLevel(addLv)
	_towerInfo.cur_level = tonumber(_towerInfo.cur_level) + tonumber(addLv)
	changeMaxLevel(tonumber(_towerInfo.cur_level) - 1)
	if(tonumber(_towerInfo.cur_level)>TowerUtil.getMaxTower())then
		-- 是否已达最大层
		_towerInfo.cur_level = TowerUtil.getMaxTower()
		-- 设置已通关
		setCurTowerPassedStatus(true)
	end
end

-- 增减挑战次数
function addAttackTowerTimes(add_times)
	_towerInfo.can_fail_num = tonumber(_towerInfo.can_fail_num) + tonumber(add_times)
end

-- 修改挑战次数
function changeAttackTowerTimes(c_times)
	_towerInfo.can_fail_num = tonumber(c_times)
end

-- 增减重置次数
function addResetTowerTimes(add_times)
	_towerInfo.reset_num = tonumber(_towerInfo.reset_num) + tonumber(add_times)
end

-- 获得试练塔剩余重置次数
function getResetTowerTimes()
	local leftTimes = 0
	if(not table.isEmpty(_towerInfo) )then
		leftTimes = tonumber(_towerInfo.reset_num)
	end
	return leftTimes
end

-- 修改最大层
function changeMaxLevel( cur_level )
	if(tonumber(cur_level) > tonumber(_towerInfo.max_level)) then
		_towerInfo.max_level = cur_level
	end
end

-- 扫荡
function isTowerSweep()
	local isSweep = false
	if( (not table.isEmpty(_towerInfo)) and _towerInfo.end_time and _towerInfo.end_time >= TimeUtil.getSvrTimeByOffset())then
		isSweep = true
	end
	return isSweep
end

-- 修改当前扫荡到的层数
function changeCurSweepFloor()
	if(isTowerSweep() == true)then
		local sweepInterval = TimeUtil.getSvrTimeByOffset() - tonumber(_towerInfo.va_tower_info.sweep_info.start_time)
		local add_floor = math.floor(sweepInterval/TowerUtil.getWipeCD())
		_towerInfo.cur_level = tonumber(_towerInfo.va_tower_info.sweep_info.start_level) + add_floor
	end
end

-- 获取扫荡结束时间
function getSweepEndTime()
	return _towerInfo.end_time
end

-- 获取扫荡开始时间
function getSweepStartTime()
	return tonumber(_towerInfo.va_tower_info.sweep_info.start_time)
end

-- 修改通关状态
function setCurTowerPassedStatus(m_status)
	if(m_status == true)then
		_towerInfo.va_tower_info.cur_status = 1
	else
		_towerInfo.va_tower_info.cur_status = 0
	end
end

-- 增减金币购买攻打次数
function addBuyDefeatNumByGold( add_times )
	_towerInfo.gold_buy_num = tonumber(_towerInfo.gold_buy_num) + add_times
end

-- 是否已通关
function isCurTowerHadPassed()
	local isHad = false

	if( tonumber(_towerInfo.cur_level) == TowerUtil.getMaxTower() and  _towerInfo.va_tower_info.cur_status and tonumber(_towerInfo.va_tower_info.cur_status) == 1 )then
		isHad = true
	end

	return isHad
end

-- 回调
function getTowerInfoCallback( cbFlag, dictData, bRet  )
	if(dictData.err == "ok")then
		if(not table.isEmpty(dictData.ret))then

			print_t(dictData.ret)
			TowerCache.setTowerInfo(dictData.ret)

			-- 初始化试炼梦魇 add by lgx 20160804
			require "script/ui/deviltower/DevilTowerData" 
			if (DevilTowerData.isDevilTowerOpen(false)) then
				DevilTowerData.setDevilTowerInfo(dictData.ret)
			end

			if(TowerCache.isTowerSweep()==true )then
				-- 开始启动
				startScheduler()
			end
		end
	end
end

------------------

-- 登录即拉取试练塔信息
function preRequestTowerInfo( ... )
	-- 获取信息
	RequestCenter.tower_getTowerInfo(getTowerInfoCallback)
end


-- 倒计时
function updateTimeFunc( ... )
	print("TowerCache.updateTimeFunc----")
	if(TowerCache.getSweepEndTime())then
		local leftTimeInterval = TowerCache.getSweepEndTime() - TimeUtil.getSvrTimeByOffset()
		if(leftTimeInterval>0)then
		else
			stopScheduler()
			if(g_network_status==g_network_connected)then
			-- 重新拉取爬塔信息
				RequestCenter.tower_getTowerInfo(getTowerInfoCallback)
			end
		end
	else
		stopScheduler()
	end
end

-------- 定时程序
local _updateTimeScheduler 	= nil	-- scheduler

-- 停止scheduler
function stopScheduler()
	if(_updateTimeScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 启动scheduler
function startScheduler()
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, 1, false)
	end
end




