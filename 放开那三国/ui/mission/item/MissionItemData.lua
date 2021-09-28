-- FileName: MissionItemData.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: 悬赏榜物品捐献数据层
--[[TODO List]]

module("MissionItemData", package.seeall)

local _itemArray = {}

--[[
	@des:得到可以捐献的物品列表
	@ret:{
		tid = {
			name,
			count,
			num,
			fame，
		}
	}
--]]
function getItemList()
	_itemArray = {}
	local bagInfo = DataCache.getBagInfo()
	--道具背包
	for k,v in pairs(bagInfo.props) do
		if v.itemDesc.isbounty == 1 then
			local itemInfo = {}
			table.hcopy(v, itemInfo)
			table.insert( _itemArray, itemInfo )
		end
	end
	return _itemArray
end

--[[
	@des:得到当前选择的名望值总和
    @parm:物品列表
--]]
function getFameCount( pItemList )
	local fameCount = 0
	for k,v in pairs(pItemList) do
		if v.selectNum then
			fameCount = fameCount + tonumber(v.itemDesc.fame) * v.selectNum
		end
	end
	return fameCount
end

--[[
	@des:得到当前已经选择的数量
--]]
function getSelectNum()
	local num = 0
	for i,v in ipairs(_itemArray) do
		local selectNum = tonumber(v.selectNum) or 0
		num = num + selectNum
	end
	return num
end

--[[
	@des:得到最大捐献数量
--]]
function getMaxDonateNum()
	local donateNum = MissionMainData.getDonateItemNum()
	local donateLimitNum = MissionMainData.getDonateLimit()
	local selectNum = getSelectNum()
	local maxNum = donateLimitNum - donateNum - selectNum
	return  maxNum
end