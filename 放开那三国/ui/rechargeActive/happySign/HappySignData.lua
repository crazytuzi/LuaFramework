-- FileName: HappySignData.lua 
-- Author: shengyixian
-- Date: 15-9-25
-- Purpose: 欢乐签到数据层

module("HappySignData",package.seeall)
require "db/DB_Bounty_reward"

local _rewardData = nil
-- 已经登陆的信息
local _loginData = nil
-- 当前领取的是第几天的奖励
local _currSignDay = nil
--[[
	@des 	: 返回活动开启时间戳
	@param 	: 
	@return : 活动配置中的活动开始时间戳
--]]
function getStartTime()
	return ActivityConfigUtil.getDataByKey("happySign").start_time
end
--[[
	@des 	: 返回活动结束时间戳
	@param 	: 
	@return : 活动配置中的活动结束时间戳
--]]
function getEndTime()
	return ActivityConfigUtil.getDataByKey("happySign").end_time
end
--[[
	@des 	: 设置奖励数据
	@param 	: 
	@return : 
--]]
function setRewardData( ... )
	-- body
	_rewardData = ActivityConfigUtil.getDataByKey("happySign").data
end
--[[
	@des 	: 获取奖励数据
	@param 	: 
	@return : 
--]]
function getRewardData( ... )
	-- body
	if not _rewardData then
		setRewardData()
	end
	return _rewardData
end
--[[
	@des 	: 根据奖励id获取奖励的数据
	@param 	: 
	@return : 
--]]
function getRewardInfoById(id)
	-- body
	local tReward = ActivityConfigUtil.getDataByKey("happySign").data[id]
	print("tReward~~~~")
	print_t(tReward)
	return tReward
end
--[[
	@des 	: 根据奖励id获取奖励的类型
	@param 	: 
	@return : 1：全选；2：单选
--]]
function getRewardTypeByID( id )
	-- body
	local tReward = getRewardInfoById(id)
	return tReward.type
end
function getIsSelectedByID( id )
	-- body
	return (tonumber(getRewardTypeByID(id)) == 2)
end
--[[
	@des 	: 根据奖励id获取奖励的详细信息
	@param 	: 
	@return : 
--]]
function getRewardById(id)
	-- body
	local tReward = ActivityConfigUtil.getDataByKey("happySign").data[id]
	local rewardInfoAry = string.split(tReward.reward,",")
	return rewardInfoAry
end
--[[
	@des 	: 获取活动持续天数
	@param 	: 
	@return : 
--]]
function getActivityDays( ... )
	-- body
	return table.count(ActivityConfigUtil.getDataByKey("happySign").data)
end
--[[
	@des 	: 设置登陆的数据
	@param 	: 
	@return : 
--]]
function setLoginData( data )
	-- body
	_loginData = data
end
--[[
	@des 	: 获取登陆天数的数据
	@param 	: 
	@return : 
--]]
function getLoginData( ... )
	-- body
	return _loginData
end
--[[
	@des 	: 获取登陆的天数
	@param 	: 
	@return : 
--]]
function getLoginDayNum( ... )
	-- body
	return tonumber(_loginData.loginDayNum)
end
--[[
	@des 	: 获取已经领取的天数数据
	@param 	: 
	@return : 
--]]
function getHadSignIdArr( ... )
	-- body
	local tSignDays = {}
	for i,v in ipairs(_loginData.hadSignIdArr) do
		tSignDays[tonumber(v)] = tonumber(v)
	end
	return tSignDays
end
--[[
	@des 	: 获取是第几天登陆
	@param 	: 
	@return : 
--]]--	add by fuqiongqiong
function getTodayNum( ... )
	return tonumber(_loginData.today)
end

--[[
	@des 	: 获取已经领取的天数
	@param 	: 
	@return : 
--]]
function getSignedDays( ... )
	-- body
	print("_loginData~~~")
	print_t(_loginData)
	return table.count(_loginData.hadSignIdArr)
end
--[[
	@des 	: 添加当前领取的奖励id到已签到列表里
	@param 	: 
	@return : 
--]]
function addSignedDay( day )
	-- body
	day = day or _currSignDay
	table.insert(_loginData.hadSignIdArr,day)
	_currSignDay = nil
end
--[[
	@des 	: 设置当前领取的奖励ID
	@param 	: 
	@return : 
--]]
function setCurrSignDay( id )
	-- body
	_currSignDay = id
end
--[[
	@des 	: 获取当前领取的奖励ID
	@param 	: 
	@return : 
--]]
function getCurrSignDay( id )
	-- body
	return _currSignDay
end
--[[
	@des 	: 接收当前领取的奖励
	@param 	: 
	@return : 
--]]
function receiveReward( reward )
	-- body
	addSignedDay()
	-- 增加金币或银币
	for i,v in ipairs(reward) do
		if (v.type == "silver") then
			UserModel.addSilverNumber(v.num)
		elseif (v.type == "gold") then
			UserModel.addGoldNumber(v.num)
		end
	end
end
--[[
	@des 	: 获取当前可以领取的次数
	@param 	: 
	@return : 
--]]
function getCanReceiveDays( ... )
	-- body
	return getLoginDayNum() - getSignedDays()
end

--判断当天的是否已经被领取了,false为未领取，true为领取
function ishaveGainToday( ... )
	local isHave = false
	local array_list = {}
	local dayNum = getTodayNum()
	local array = getHadSignIdArr()
	for k,v in pairs(array) do
		array_list[tonumber(v)] = tonumber(v)
		if array_list[dayNum] == dayNum then
			isHave = true
		end
	end
	return isHave
end