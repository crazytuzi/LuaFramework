-- Filename：	RechargeBigRunData.lua
-- Author：		Zhang Zihang
-- Date：		2014-7-8
-- Purpose：		充值大放送数据处理

module("RechargeBigRunData", package.seeall)

require "script/model/utils/ActivityConfigUtil"
require "script/utils/TimeUtil"
require "script/ui/item/ItemUtil"

local _bigRunInfo = nil	--充值大放送后端信息

--[[
	@des 	:设置活动信息
	@param 	:UI回调
	@return :
--]]
function setBigRunInfo(p_bigRunInfo)
	_bigRunInfo = p_bigRunInfo
end

--[[
	@des 	:返回活动开始时间戳
	@param 	:
	@return :活动开始时间戳
--]]
function getStartTime()
	return ActivityConfigUtil.getDataByKey("topupReward").start_time
end

--[[
	@des 	:得到活动结束时间戳
	@param 	:
	@return :活动结束时间戳
--]]
function getEndTime()
	return ActivityConfigUtil.getDataByKey("topupReward").end_time
end

--[[
	@des 	:返回转换后的剩余时间
	@param 	:
	@return :日-小时-分-秒
--]]
function getRemainTimeFormat()
	--得到比服务器慢1秒的服务器时间
	local serverTime = TimeUtil.getSvrTimeByOffset()
	--剩余时间
	local remainTime = getEndTime() - serverTime

	--天数
	local DNum = math.floor(remainTime/(3600*24))
	remainTime = remainTime - DNum*3600*24
	--小时数
	local HNum = math.floor(remainTime/3600)
	remainTime = remainTime - HNum*3600
	--分数
	local MNum = math.floor(remainTime/60)
	remainTime = remainTime - MNum*60
	--秒数
	local SNum = remainTime

	--用于存储时间格式
	local timeString = ""

	--如果够一天
	if DNum > 0 then
		timeString = DNum .. GetLocalizeStringBy("key_10194") .. HNum .. GetLocalizeStringBy("key_10195") .. MNum .. GetLocalizeStringBy("key_10196") .. SNum .. GetLocalizeStringBy("key_10197")
	--如果够一小时
	elseif HNum > 0 then
		timeString = HNum .. GetLocalizeStringBy("key_10195") .. MNum .. GetLocalizeStringBy("key_10196") .. SNum .. GetLocalizeStringBy("key_10197")
	--如果够一分钟
	elseif MNum > 0 then
		timeString = MNum .. GetLocalizeStringBy("key_10196") .. SNum .. GetLocalizeStringBy("key_10197")
	--如果够一秒
	else
		timeString = SNum .. GetLocalizeStringBy("key_10197")
	end

	return timeString
end

--[[
	@des 	:返回当日需要充值的钱数
	@param 	:
	@return :当日需要充值的钱数
--]]
function getRechargeNum()
	--_bigRunInfo.day是当前是第几天，从0开始
	return ActivityConfigUtil.getDataByKey("topupReward").data[_bigRunInfo.day + 1].payNum
end

--[[
	@des 	:返回第几天
	@param 	:
	@return :第几天
--]]
function getToday()
	--因为天数从0开始
	return _bigRunInfo.day + 1
end

--[[
	@des 	:根据天数返回奖励的数据
	@param 	:哪一天（从1开始）
	@return :当天的奖励数据
--]]
function getDataByDay(dayNum)
	--从表中得到的奖励数据
	--格式是   
	--		物品类型|物品id|物品数量,物品类型|物品id|物品数量
	local originalData = ActivityConfigUtil.getDataByKey("topupReward").data[dayNum].payReward
	
	--得到方便创造物品图片的数据
	return ItemUtil.getItemsDataByStr(originalData)
end

--[[
	@des 	:返回今日是否可以领奖
	@param 	:
	@return :今日是否可以领奖
--]]
function canGetReward()
	--是否能领奖，false不能，true能
	local canGet = false
	if tonumber(_bigRunInfo.data[_bigRunInfo.day+1][1]) == 1 then
		canGet = true
	end

	return canGet
end

--[[
	@des 	:返回今日是否可以领奖
	@param 	:
	@return :今日是否可以领奖
--]]
function haveGetReward()
	local haveGet = false
	if tonumber(_bigRunInfo.data[_bigRunInfo.day+1][2]) == 1 then
		haveGet = true
	end

	return haveGet
end

--[[
	@des 	:增加奖励的物品
	@param 	:
	@return :
--]]
function addReward()
	ItemUtil.addRewardByTable(getDataByDay(getToday()))
end

--[[
	@des 	:得到礼包数量
	@param 	:
	@return :礼包数量（也就是活动开多少天）
--]]
function getDayNum()
	--开始活动时间
	local date = os.date("*t", getStartTime())
	--开活动当天还剩多长时间
	local dayRemainTime = 24*3600 - date.sec - date.min*60 - date.hour*3600
	--增加的天数
	local plusDay = 0
	--如果第一天有剩余时间（即活动不是0点准时开的），则余下的天数再加1
	--具体逻辑往后看就懂了
	if tonumber(dayRemainTime) > 0 then
		plusDay = 1
	end
	--活动持续时间，从第一个整天开始算
	local timeMinus = getEndTime() - getStartTime() - dayRemainTime
	--返回活动多少天
	--防止策划手抖配活动超出奖励表的范围
	if (math.ceil(timeMinus/(3600*24)) + plusDay) > table.count(ActivityConfigUtil.getDataByKey("topupReward").data) then
		return table.count(ActivityConfigUtil.getDataByKey("topupReward").data)
	else
		return math.ceil(timeMinus/(3600*24)) + plusDay
	end
end

--[[
	@des 	:得到当前充值金额
	@param 	:
	@return :当前充值金额
--]]
function getCurrentGold()
	return _bigRunInfo.gold
end

--[[
	@des 	:判断今日充值是否够
	@param 	:
	@return :够返回true 		不够返回false
--]]
function goldEnough()
	if tonumber(getCurrentGold()) >= tonumber(getRechargeNum()) then
		return true
	else
		return false
	end
end