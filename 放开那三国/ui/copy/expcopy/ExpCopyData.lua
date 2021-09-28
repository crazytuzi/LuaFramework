-- Filename: ExpCopyData.lua
-- Author: lichenyang
-- Date: 2015-03-31
-- Purpose: 主角经验副本数据处理类

module("ExpCopyData", package.seeall)
require "script/model/DataCache"

--[[
	@des: 得到经验副本列表
--]]
function getCopyList()
	require "db/DB_Expcopy"
	local copyList = {}
	local userLevel = UserModel.getHeroLevel()
	for i=1,table.count(DB_Expcopy.Expcopy) do
		local expCopyInfo = DB_Expcopy.getDataById(i)
		if expCopyInfo and i <= getOpenFrontId() + 1 then
			if i <= getOpenFrontId() and tonumber(expCopyInfo.strongholdlv) <= userLevel then
				expCopyInfo.isOpen = true
			else
				expCopyInfo.isOpen = false
			end
			table.insert( copyList, expCopyInfo )
		end
	end
	-- copyList = table.reverse(copyList)
	return copyList
end

--[[
	@des:得到经验副本信息
--]]
function getExpCopyInfo()
	local aCopyInfo = DataCache.getAcopyData()
	local expCopyInfo = aCopyInfo["300005"]
	return expCopyInfo
end

--[[
	@des:得到剩余攻打次数
--]]
function getCanDefeatNum()
	if DataCache.getSwitchNodeState(ksExpCopy, false) then
		local expInfo = getExpCopyInfo()
		return tonumber(expInfo.can_defeat_num)
	else
		return 0
	end
end

--[[
	@des:设置剩余攻打次数
--]]
function setCanDefeatNum( p_num )
	local expInfo = getExpCopyInfo()
	expInfo.can_defeat_num = p_num
end

--[[
	@des:得到最大开启副本id
--]]
function getOpenFrontId()
	local expInfo = getExpCopyInfo()
	local baseId = expInfo.va_copy_info.base_id
	return tonumber(baseId)
end

function setOpenFrontId(p_baseId)
	local expInfo = getExpCopyInfo()
	expInfo.va_copy_info.base_id =p_baseId or expInfo.va_copy_info.base_id
end

--[[
	@des:得到可以购买的攻打次数
--]]
function getCanBuyAtkNum( ... )
	local expInfo = getExpCopyInfo()
	local atkNum = tonumber(expInfo.buy_atk_num)
	return atkNum
end

--[[
	@des:得到购买攻打次数花费
--]]
function getAttackCost( ... )
	local curVipId= UserModel.getVipLevel()+1
	local dbCopyCost= DB_Vip.getDataById(curVipId).LeadExpCopyCost
	local copyCost = lua_string_split( dbCopyCost , "|")
	_copyCostTab.maxBuyNumber = tonumber(copyCost[1])
	_copyCostTab.costGold= tonumber(copyCost[2])
	_copyCostTab.addGold = tonumber(copyCost[3])
	_copyCostTab.dbCopyName= dbCopyName
end

