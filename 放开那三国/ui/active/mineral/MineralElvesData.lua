-- Filename：	MineralElvesData.lua
-- Author：		bzx
-- Date：		2016-05-13
-- Purpose：		资源矿宝藏数据

module ("MineralElvesData", package.seeall)

-- 活动没有开启
ksNotOpened  		= -1
-- 还没有开始
ksNotStart 			= 0
-- 宝藏出现中
ksFighting 			= 1
-- 宝藏等待出现中
ksWaiting 			= 2
-- 活动结束
ksEnded 			= 3
-- 当前页的宝藏数据
local _curMineralElvesDatas = {}
local _selfMineralElvesData = {}

function setCurMineralElvesDatas(mineralElvesDatas)
	_curMineralElvesDatas = mineralElvesDatas
end

function getCurMineralElvesDatas( ... )
	return _curMineralElvesDatas
end

function setSelfMineralElvesData( mineralElvesData )
	_selfMineralElvesData = mineralElvesData
end

function getSelfMineralElvesData( ... )
	return _selfMineralElvesData
end

function isShow( ... )
	local switchIsOpened = DataCache.getSwitchNodeState( ksSwitchResource, false )
	if not switchIsOpened then
		return false
	end
	local status = getElvesStatus()
	return status > ksNotStart and status < ksEnded
end

function isOpen( ... )
	local ret = ActivityConfigUtil.isActivityOpen("mineralelves")
	if not ret then
		return ret
	end
	local db = getElvesDb()
	local openDay = parseField(db.openDay, 2)
	if type(openDay) == "number" then
		openDay = {openDay}
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	local weekday = tonumber(os.date("%w", curTime))
	if weekday == 0 then
		weekday = 7
	end
	ret = false
	for i = 1, #openDay do
		local day = openDay[i]
		if day == weekday then
			ret = true
			break
		end
	end
	return ret
end

function getElvesStatus( ... )
	local status = ksNotOpened
	if isOpen() then
		local curTime = TimeUtil.getSvrTimeByOffset()
		local todaySecond = TimeUtil.getTimeAtDay(curTime)
		if todaySecond < tonumber(getElvesDb().startTime) then
			status = ksNotStart
		elseif todaySecond < getElvesDb().endTime - tonumber(getElvesDb().waitTime) then
			local onceTime = tonumber(getElvesDb().lastTime) + tonumber(getElvesDb().waitTime)
			if math.mod(todaySecond - tonumber(getElvesDb().startTime), onceTime) < tonumber(getElvesDb().lastTime) then
				status = ksFighting
			else
				status = ksWaiting
			end
		else
			status = ksEnded
		end
	end
	return status
end

function getElvesDb( ... )
	return ActivityConfigUtil.getDataByKey("mineralelves").data[1]
end

-- 得到今天距离宝藏出现的开始剩余时间
function getTodayStartRemainTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local todaySecond = TimeUtil.getTimeAtDay(curTime)
	local remainTime = getElvesDb().startTime - todaySecond
	return remainTime
end

-- 得到本波结束倒计时
function getCurElvesEndRemainTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local todaySecond = TimeUtil.getTimeAtDay(curTime)
	local onceTime = tonumber(getElvesDb().lastTime) + tonumber(getElvesDb().waitTime)
	local remainTime = getElvesDb().lastTime - math.mod(todaySecond - tonumber(getElvesDb().startTime), onceTime)
	return remainTime
end

-- 得到下波开始倒计时
function getNextElvesStartRemainTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local todaySecond = TimeUtil.getTimeAtDay(curTime)
	local onceTime = tonumber(getElvesDb().lastTime) + tonumber(getElvesDb().waitTime)
	local remainTime = onceTime - math.mod(todaySecond - tonumber(getElvesDb().startTime), onceTime)
	return remainTime
end

-- 得到今天距离宝藏活动结束的剩余时间
function getTodayEndRemainTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local todaySecond = TimeUtil.getTimeAtDay(curTime)
	local remainTime = getElvesDb().endTime - todaySecond - tonumber(getElvesDb().waitTime)
	return remainTime
end


function getElvesStartTime( ... )
	
end

function getNextStartTime()
	
end