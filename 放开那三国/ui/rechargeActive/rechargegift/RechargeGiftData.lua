-- FileName: RechargeGiftData.lua 
-- Author: yangrui 
-- Date: 15-10-30
-- Purpose: function description of module 

module("RechargeGiftData", package.seeall)

local _rechargeGiftData = nil

--[[
	@des 	: 返回活动开启时间戳
	@param 	: 
	@return : 活动配置中的活动开始时间戳
--]]
function getStartTime()
	return ActivityConfigUtil.getDataByKey("rechargeGift").start_time
end

--[[
	@des 	: 返回活动结束时间戳
	@param 	: 
	@return : 活动配置中的活动结束时间戳
--]]
function getEndTime()
	return ActivityConfigUtil.getDataByKey("rechargeGift").end_time
end

--[[
	@des 	: 设置领取奖励信息
	@param 	: pId  奖励ID
	@return : 
--]]
function setRechargeGiftInfo( pData )
	_rechargeGiftData = pData
end

--[[
	@des 	: 获取领取奖励信息
	@param 	: 
	@return : 
--]]
function getReceivedRewardData( ... )
	return _rechargeGiftData.hadRewardArr
end

--[[
	@des 	: 设置领取奖励信息
	@param 	: 
	@return : 
--]]
function setReceivedRewardData( pId )
	local id = tonumber(pId)
	table.insert(_rechargeGiftData.hadRewardArr,id)
end

--[[
	@des 	: 该奖励是否被领取
	@param 	: 
	@return : 
--]]
function isReceivedRewardById( pId )
	local id = tonumber(pId)
	local receivedRewardData = RechargeGiftData.getReceivedRewardData()
	for index,receivedRewardId in pairs(receivedRewardData) do
		if id == tonumber(receivedRewardId) then
			return true
		end
	end
	return false
end

--[[
	@des 	: 获取玩家已经充值的金币数
	@param 	: 
	@return : 
--]]
function getRechargedGoldNum( ... )
	local accGold = 0
	if not table.isEmpty(_rechargeGiftData) then
		accGold = tonumber(_rechargeGiftData.acc_gold)
	end

	return accGold
end

--[[
	@des 	: 获取奖励所需充值金币
	@param 	: pId  奖励ID
	@return : 
--]]
function getExpenseGoldById( pId )
	local id = tonumber(pId)
	return ActivityConfigUtil.getDataByKey("rechargeGift").data[id].expenseGold
end

--[[
	@des 	: 获取奖励信息
	@param 	: pId  奖励ID
	@return : 
--]]
function getRewardById( pId )
	local id = tonumber(pId)
	return ActivityConfigUtil.getDataByKey("rechargeGift").data[id].reward
end

--[[
	@des 	: 获取选择奖励信息
	@param 	: pId  奖励ID  pSelect  选择的奖励
	@return : 
--]]
function getSelectRewardById( pId, pSelect )
	local id = tonumber(pId)
	local mSelect = tonumber(pSelect)
	local rewardData = string.split(ActivityConfigUtil.getDataByKey("rechargeGift").data[id].reward,",")
	for index,reward in pairs(rewardData) do
		if index == mSelect then
			return reward
		end
	end
end

--[[
	@des 	: 获取奖励类型
	@param 	: pId  奖励ID
	@return : 
--]]
function getRewardTypeById( Pid )
	local id = tonumber(pId)
	return tonumber(ActivityConfigUtil.getDataByKey("rechargeGift").data[id].type)
end

--[[
	@des 	: 获取一条整条奖励信息
	@param 	: pId  奖励ID
	@return : 
--]]
function getSingleRewardDataById( pId )
	local id = tonumber(pId)
	return ActivityConfigUtil.getDataByKey("rechargeGift").data[id]
end

--[[
	@des 	: 获取所有奖励信息
	@param 	: 
	@return : 
--]]
function getAllRewardData( ... )
	return ActivityConfigUtil.getDataByKey("rechargeGift").data
end
