-- Filename：	StepCounterData.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-11
-- Purpose：		计步活动数据缓存

module ("StepCounterData", package.seeall)

require "script/utils/TimeUtil"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"

local _haveReward = nil 		--是否已领奖
local _canReward = false 		--是否可以领奖

local _ifFirst = true 			--是否第一次调用计步注册函数

local _curBeginTime = 0  		--今日开始倒计时时间戳

--[[
	@des 	:处理后端返回的是否已领奖数据
	@param 	:后端返回的dictData.ret
	@return :
--]]
function setWetherReward(p_ret)
	if p_ret == "yes" then
		_haveReward = true
	elseif p_ret == "no" then
		_haveReward = false
	--设置这个nil值是因为零点前用户登录，没有领取，在页面停留到第二天领取（其实领的是第二天的），避免再登录重复领取
	else
		_haveReward = nil
	end
end

--[[
	@des 	:返回是否已领奖
	@param 	:
	@return :true 已领  false 未领
--]]
function getWetherReward()
	return _haveReward
end

--[[
	@des 	:返回是否可以领奖
	@param 	:
	@return :true 可以  false 不可以
--]]
function getCanReward()
	return _canReward
end

--[[
	@des 	:返回活动开启时间戳
	@param 	:
	@return :活动配置中的活动开始时间戳
--]]
function getStartTime()
	return ActivityConfigUtil.getDataByKey("stepCounter").start_time
end

--[[
	@des 	:返回活动结束时间戳
	@param 	:
	@return :活动配置中的活动结束时间戳
--]]
function getEndTime()
	return ActivityConfigUtil.getDataByKey("stepCounter").end_time
end

--[[
	@des 	:返回活动开启的第多少天
	@param 	:
	@return :活动开启的第多少天（第一天为1，过了24点为第二天）
--]]
function whichDay()
	--活动开启时间
	local openTime = getStartTime()
	--将开启时间转换为时，分，秒格式，便于计算当日零点时间戳
	local transFormTime = os.date("*t", openTime)
	--当日零点时间戳
	local zeroTime = openTime - transFormTime.sec - transFormTime.min*60 - transFormTime.hour*3600

	--当前时间
	local curTime = TimeUtil.getSvrTimeByOffset()

	--第多少天
	local dayNumber = math.ceil((curTime - zeroTime)/86400)

	return dayNumber
end

--[[
	@des 	:活动配置中需要达到的步数
	@param 	:
	@return :需要达到的步数
--]]
function configStep()
	local stepData = ActivityConfigUtil.getDataByKey("stepCounter").data
	return stepData[whichDay()].steps
end

--[[
	@des 	:活动配置中需要完成的时间
	@param 	:
	@return :需要完成的时间，单位秒
--]]
function configTime()
	local stepData = ActivityConfigUtil.getDataByKey("stepCounter").data
	--需要完成的在线时间，单位秒
	return stepData[whichDay()].timeperstep
end

--[[
	@des 	:返回格式转换后的目标在线时间
	@param 	:需要转换的时间，单位秒
	@return :转换后的时间string
--]]
function transFormConfigTime(p_durTime)
	local durTime = p_durTime
	--小时数
	local hourNum = math.floor(durTime/3600)
	local hourString
	if hourNum < 10 then
		hourString = "0" .. hourNum
	else
		hourString = tostring(hourNum)
	end
	durTime = durTime - hourNum*3600
	local minNum = math.floor(durTime/60)
	local minString
	if minNum < 10 then
		minString = "0" .. minNum
	else
		minString = tostring(minNum)
	end
	durTime = durTime - minNum*60
	local secString
	if durTime < 10 then
		secString = "0" .. durTime
	else
		secString = durTime
	end

	return hourString .. ":" .. minString .. ":" .. secString
end

--[[
	@des 	:得到当日奖励
	@param 	:
	@return :当日奖励
--]]
function getCurDayGift()
	--从表中得到的奖励数据
	--格式是   
	--		物品类型|物品id|物品数量,物品类型|物品id|物品数量
	local originalData = ActivityConfigUtil.getDataByKey("stepCounter").data[whichDay()].rewards

	return ItemUtil.getItemsDataByStr(originalData)
end

--[[
	@des 	:增加奖励的物品
	@param 	:
	@return :
--]]
function addReward()
	ItemUtil.addRewardByTable(getCurDayGift())
end

--[[
	@des 	:得到走的步数
	@param 	:
	@return :步数
--]]
local stepNum = 0
local isOverCallback = true
function getStepNum()
	if(Platform.getPlName() == "appstore" and string.checkScriptVersion(NSBundleInfo:getAppVersion(), "4.1.0") >= 0 and NSBundleInfo:getSysVersion()~=nil and string.checkScriptVersion(NSBundleInfo:getSysVersion(), "8.0.0") >=0 ) then
		local healthCallback = function (steps)
			stepNum = steps
			--下面用于朱波录视频用
			--stepNum = stepNum + tonumber(configStep())
			print("isSuccess,steps==", isSuccess,steps)
			isOverCallback = true
		end
		if _ifFirst == true then
			-- BTHealthKit:shareBTHealthKit():regisertHealthHandle(healthCallback)
			_ifFirst = false
		end

		if( isOverCallback == true )then
			isOverCallback = false
			-- BTHealthKit:shareBTHealthKit():calTodaySteps()
		end
	end
	print("stepNum==",stepNum)
	return stepNum
end

--[[
	@des 	:记下登录时间戳，如果没有则新建一个
	@param 	:
	@return :
--]]
function setKeyForUserDefault()
	--当前时间
	local curTime = TimeUtil.getSvrTimeByOffset()
	local curStamp = os.date("*t",curTime)
	local keyString = UserModel.getUserUid() .. "stepCounter" .. curStamp.year .. curStamp.month .. curStamp.day
	if tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(keyString)) == 0 then
		_curBeginTime = curTime
		CCUserDefault:sharedUserDefault():setIntegerForKey(keyString,tonumber(curTime))
	else
		_curBeginTime = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(keyString))
	end
end

--[[
	@des 	:得到当天累积登录时间
	@param 	:
	@return :累计登录时间
--]]
function getAccumulateTime()
	local curTime = TimeUtil.getSvrTimeByOffset()
	local timeMinus = curTime - _curBeginTime

	return tonumber(timeMinus)
end

--[[
	@des 	:如果可以领取，设置_canReward为true
	@param 	:
	@return :
--]]
function setCanReward()
	if tonumber(getStepNum()) >= tonumber(configStep()) or tonumber(getAccumulateTime()) >= tonumber(configTime()) then
		_canReward = true
	end
end