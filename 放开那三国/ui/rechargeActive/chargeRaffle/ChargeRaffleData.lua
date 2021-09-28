-- Filename：	ChargeRaffleData.lua
-- Author：		lichenyang
-- Date：		2014-6-12
-- Purpose：		数据缓存

module ("ChargeRaffleData", package.seeall)
require "script/model/utils/ActivityConfig"
require "script/utils/TimeUtil"
require "script/model/user/UserModel"
local _DataCache = {}

---
--#function setInfo 设置缓存数据
--#param  #table p_data 缓冲数据
function setInfo( p_data )
	if(p_data ~= nil) then
		_DataCache = p_data
	else
		_DataCache = {}
	end
end

---
--#function setCanRaffleNum 设置可抽奖次数
--#param  #number p_index 档次
--#param  #number p_index 新的抽奖次数
function setCanRaffleNum( p_index, p_num )
	_DataCache["can_raffle_num_" .. p_index] = tonumber(p_num)

end

---
--#function getCanRaffleNum 得到可抽奖次数
--#param   #number p_index 档次
--#return  #number  该档次的抽奖次数
function getCanRaffleNum( p_index )
	return tonumber(_DataCache["can_raffle_num_" .. p_index])
end


--#function setRewardStatus 设置当前领奖状态
--#param   p_isReward 状态
--#return  #number  该档次的抽奖次数
function setRewardStatus( p_isReward )
	_DataCache["reward_status"] = tonumber(p_isReward)
end


--#function setRewardStatus 设置当前领奖状态
--#param   p_isReward 状态
--#return  #number  该档次的抽奖次数
function getRewardStatus()
	return tonumber(_DataCache["reward_status"])
end

---
--#function getRaffleItems 得到指定档次的抽奖物品
--#param   #number p_index 档次
--#return {
	-- itemTid:{
		-- num:
		-- type:
		-- db: 表信息
	-- }
-- }
function getRaffleItems( p_index )
	local dropShow = ActivityConfig.ConfigCache.chargeRaffle.data[1]["dropShow_" .. p_index]
	require "script/ui/item/ItemUtil"
	local raffleItems = {}
	local dropItems = string.split(dropShow, ",")
	for k,v in pairs(dropItems) do
		local itemInfo                          = string.split(v, "|")
		local item      = {}
		item.tid  = tonumber(itemInfo[2])
		item.num  = tonumber(itemInfo[3])
		item.type = tonumber(itemInfo[1])                     
		item.db   = ItemUtil.getItemById(tostring(itemInfo[2]))
		table.insert(raffleItems, item)
	end
	return raffleItems
end


---
--#function getFirstChargeReward 得到每日首冲奖励
--#return {
	-- :{
		-- tid:
		-- num:
		-- type:
		-- db: 表信息
	-- }
-- }
function getFirstChargeReward( )
	local firstReward = ActivityConfig.ConfigCache.chargeRaffle.data[1]["firstReward"]
	local itemInfo    = string.split(firstReward, "|")
	raffleItems       = {}
	raffleItems.tid   = tostring(itemInfo[2])
	raffleItems.num   = tonumber(itemInfo[3])
	raffleItems.type  = tonumber(itemInfo[1])
	local itemDbInfo  = ItemUtil.getItemById(tostring(itemInfo[2]))
	raffleItems.db    = itemDbInfo

	print("getFirstChargeReward")
	print_table("getFirstChargeReward", raffleItems)
	return raffleItems
end

function getFirstChargeRewardForItemList( )
	local firstReward = ActivityConfig.ConfigCache.chargeRaffle.data[1]["firstReward"]
	local itemInfo    = string.split(firstReward, "|")
	local itemData    =	ItemUtil.getItemsDataByStr(firstReward)
	
	print("getFirstChargeRewardForItemList")
	print_t("getFirstChargeRewardForItemList", itemData)
	return itemData
end


---
--#function getOpenTimeDes 得到开启时间描述
function getOpenTimeDes( ... )
	local timeInteral = ActivityConfig.ConfigCache.chargeRaffle.start_time
	return TimeUtil.getInternationalDateFormat(timeInteral)
end

---
--#function setCanRaffleNum 得到结束时间描述
function getEndTimeDes( ... )
	local timeInteral = ActivityConfig.ConfigCache.chargeRaffle.end_time
	return TimeUtil.getInternationalDateFormat(timeInteral)
end

---
--#function setCanRaffleNum 得到剩余时间描述
function getHaveTimeDes( ... )
	local haveTimeInteral = getHaveTimeInteral()
	return TimeUtil.getInternationalRemainFormat(getHaveTimeInteral())
end

function getHaveTimeInteral( ... )
	local endTimeInteral  = ActivityConfig.ConfigCache.chargeRaffle.end_time
	local haveTimeInteral = endTimeInteral - BTUtil:getSvrTimeInterval()
	return haveTimeInteral
end

function getCostMoney( p_index)
	local goldField = ActivityConfig.ConfigCache.chargeRaffle.data[1]["costNum"]
	local goldInfo = string.split(goldField, ",")
	return tonumber(goldInfo[p_index])
end



function addReward( ... )
	local rewardInfo = getFirstChargeReward()
	if(rewardInfo.type ==1) then
		-- 银币
		UserModel.addSilverNumber(rewardInfo.num)
	elseif(rewardInfo.type ==2) then
		-- 将魂
		UserModel.addSoulNum(rewardInfo.num)
	elseif(rewardInfo.type ==3) then
		-- 金币
		UserModel.addGoldNumber(rewardInfo.num)
	elseif(rewardInfo.type ==7 or 14) then
		-- 物品

	elseif(rewardInfo.type ==10) then
		-- 英雄

	elseif(rewardInfo.type ==12) then
		-- 声望
		UserModel.addPrestigeNum(rewardInfo.num)
    elseif(rewardInfo.type ==11) then
		-- 魂玉
		UserModel.addJewelNum(rewardInfo.num)
    elseif(rewardInfo.type ==4) then
		-- 体力
		UserModel.addEnergyValue(rewardInfo.num)
    elseif(rewardInfo.type ==5) then
		-- 耐力
		UserModel.addStaminaNumber(rewardInfo.num)
	end

end



