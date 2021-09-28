-- Filename：	AccumulateData.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-18
-- Purpose：		合服登录累积 & 合服充值回馈 数据层

module("AccumulateData", package.seeall)

require "db/DB_Hefu_accumulateactive"
require "db/DB_Hefu_recharge_back"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/utils/TimeUtil"

local _accumulateInfo = nil 		--累积登录后端返回信息
local _rechargeInfo = nil 			--充值回馈后端返回信息
local _accumulateTable = {} 		--记录累积登录领奖情况
local _rechargeTable = {} 			--记录充值回馈领奖情况

--[[
	@des 	:得到累计登录配置表长度信息
	@param 	:
	@return :累计登录配置表长度
--]]
function getAccumulateNum()
	return table.count(DB_Hefu_accumulateactive.Hefu_accumulateactive)
end

--[[
	@des 	:得到消费回馈配置表长度信息
	@param 	:
	@return :消费回馈配置表长度
--]]
function getRechargeNum()
	return table.count(DB_Hefu_recharge_back.Hefu_recharge_back)
end

--[[
	@des 	:得到需要充值的数量
	@param 	:天数
	@return :充值数量
--]]
function getConfigRechargeNum(p_day)
	local rechargeInfo = DB_Hefu_recharge_back.getDataById(tonumber(p_day))

	return rechargeInfo.expenseGold
end

--[[
	@des 	:得到奖励信息
	@param 	:$ p_kind 	:活动种类
	@param 	:$ p_day 	:当前活动index
	@return :转换后的奖励信息
--]]
function getRewardInfo(p_kind,p_index)
	local rewardInfo
	if p_kind == 1 then
		rewardInfo = DB_Hefu_accumulateactive.getDataById(tonumber(p_index)).reward
	else
		rewardInfo = DB_Hefu_recharge_back.getDataById(tonumber(p_index)).reward
	end

	return ItemUtil.getItemsDataByStr(rewardInfo)
end

--[[
	@des 	:得到奖励名称
	@param 	:天数
	@return :奖励名称
--]]
function getRewardName(p_day)
	local accumulateInfo = DB_Hefu_accumulateactive.getDataById(tonumber(p_day))

	return accumulateInfo.des
end

--[[
	@des 	:根据活动名称判断活动开没开
	@param 	:活动名称
	@return :活动是否开启
--]]
function gameOpenEndTime(p_name)
	local mergeTime = UserModel.getMergeServerTime() or 0
	--将开启时间转换为时，分，秒格式，便于计算当日零点时间戳
	local transFormTime = os.date("*t", mergeTime)
	--当日零点时间戳
	local zeroTime = mergeTime - transFormTime.sec - transFormTime.min*60 - transFormTime.hour*3600

	--下面加上一天的时间，得到合服后的第一天的零点时间
	local nextZeroTime = tonumber(zeroTime) + 24*3600

	--该活动开始时间
	local openTime = nextZeroTime + openTimeOffset(p_name)
	--该活动结束时间
	local endTime = nextZeroTime + endTimeOffset(p_name)

	return openTime,endTime
end

--[[
	@des 	:根据活动名称判断活动开没开
	@param 	:活动名称
	@return :活动是否开启
--]]
function isMergeActivityOpen(p_name)
	print("合服时间",UserModel.getMergeServerTime())
	print("当前时间",TimeUtil.getSvrTimeByOffset())
	local isOpen = false
	--如果合服时间返回的不为nil且不为0，则表示已经合服
	if (UserModel.getMergeServerTime() ~= nil) and (tonumber(UserModel.getMergeServerTime()) ~= 0) then
		--活动开始，结束时间戳
		local openTime,endTime = gameOpenEndTime(p_name)
		print("开始时间",openTime)
		print("结束时间",endTime)

		--当前时间
		local curTime = TimeUtil.getSvrTimeByOffset()

		--如果当前时间在活动持续时间内
		if (curTime >= openTime) and (curTime <= endTime) then
			isOpen = true
		end 
	end
	return isOpen
end

--[[
	@des 	:设置累积登录活动信息
	@param 	:累积登录信息
	@return :
--]]
function setAccumulateInfo(p_accumulateInfo)
	_accumulateInfo = p_accumulateInfo

	--已领取的档位置为1
	for k,v in pairs(_accumulateInfo.res.got) do
		_accumulateTable[tonumber(v)] = 1
	end

	--可以领取的档位置为2
	for k,v in pairs(_accumulateInfo.res.can) do
		_accumulateTable[tonumber(v)] = 2
	end
end

--[[
	@des 	:设置充值回馈活动信息
	@param 	:充值回馈信息
	@return :
--]]
function setRechargeInfo(p_rechargeInfo)
	_rechargeInfo = p_rechargeInfo

	--已领取的档位置为1
	for k,v in pairs(_rechargeInfo.res.got) do
		_rechargeTable[tonumber(v)] = 1
	end

	--可以领取的档位置为2
	for k,v in pairs(_rechargeInfo.res.can) do
		_rechargeTable[tonumber(v)] = 2
	end
end

--[[
	@des 	:得到栏位奖励领取情况信息
	@param 	:$ p_type 	: 活动类型 	1 累积登录 	2 充值回馈
	@param 	:$ p_index 	: 栏位index
	@return :奖励领取情况
			 1 	已领取
			 2  可领取
			 3 	不可领取
--]]
function getGotOrCan(p_type,p_index)
	local returnNum
	if p_type == 1 then
		if _accumulateTable[p_index] ~= nil then
			returnNum = _accumulateTable[p_index]
		else
			returnNum = 3
		end
	else
		if _rechargeTable[p_index] ~= nil then
			returnNum = _rechargeTable[p_index]
		else
			returnNum = 3
		end
	end

	return returnNum
end

--[[
	@des 	:增加奖励
	@param 	:奖励物品表
	@return :
--]]
function addReward(p_rewardTable)
	ItemUtil.addRewardByTable(p_rewardTable)
end

--[[
	@des 	:得到冲了多少钱
	@param 	:
	@return :钱的数量
--]]
function getMoneyNum()
	return _rechargeInfo.res.recharge
end

--[[
	@des 	:得到开始活动时间相对于合服时间的偏移量
	@param 	:活动名称
	@return :开始时间偏移量
--]]
function openTimeOffset(p_name)
	--如果是登录累积活动
	if p_name == "mergeAccumulate" then
		return 0
	--如果是充值回馈活动
	elseif p_name == "mergeRecharge" then
		return 0
	end
end

--[[
	@des 	:得到结束活动时间相对于合服时间的偏移量
	@param 	:活动名称
	@return :结束时间偏移量
--]]
function endTimeOffset(p_name)
	--如果是登录累积活动
	if p_name == "mergeAccumulate" then
		return 7*24*3600
	--如果是充值回馈活动
	elseif p_name == "mergeRecharge" then
		return 3*24*3600
	end
end

--[[
	@des 	:领奖完成后把按钮置为已领取状态
	@param 	:$ p_type 		:活动类型 	1 累积登录 	2 充值回馈
	@param 	:$ p_tag 		:按钮tag 	
	@return :
--]]
function setButtomStatus(p_type,p_tag)
	if p_type == 1 then
		_accumulateTable[p_tag] = 1
	else
		_rechargeTable[p_tag] = 1
	end
end