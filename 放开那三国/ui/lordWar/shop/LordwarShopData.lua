-- Filename: LordwarShopData.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店数据层

module("LordwarShopData", package.seeall)

local _shopServerInfo = {}

function getItemList( ... )
	local itemArray = {}
	local shopConfigs = ActivityConfigUtil.getDataByKey("lordwar").data[1].shop_items
	local itemConfigs = string.split(shopConfigs, ",")
	for k,v in pairs(itemConfigs) do
		local itemInfo = getItemInfo(v, k)
		table.insert(itemArray, itemInfo)
	end
	return itemArray
end

function getItemInfo( p_itemConfig , p_index)
	local itemConfig = string.split(p_itemConfig, "|")
	-- 物品类型|ID|物品数量|货币数量|兑换数量
	local itemInfo         = {}
	itemInfo.type          = itemConfig[1]
	itemInfo.tid           = itemConfig[2]
	itemInfo.itemNum       = itemConfig[3]
	itemInfo.costNum       = itemConfig[4]
	itemInfo.exchangeCount = itemConfig[5]
	itemInfo.exchangeNum   = getItemExchangeNum(p_index)
	return itemInfo
end


function getShopServerInfo( ... )
	return _shopServerInfo
end

function setShopServerInfo( p_shopInfo )
	_shopServerInfo = p_shopInfo or {}
end

function getItemExchangeNum( p_index )
	print("getItemExchangeNum", p_index)
	print_t(_shopServerInfo)
	if _shopServerInfo[tostring(p_index)] then
		return tonumber(_shopServerInfo[tostring(p_index)].num) or 0
	else
		return 0
	end
end

function setItemExchangeNum( p_index, pNum )
	if _shopServerInfo[tostring(p_index)] == nil then
		_shopServerInfo[tostring(p_index)] = {}
	end
	_shopServerInfo[tostring(p_index)].num = tonumber(pNum)
	printTable("_shopServerInfo", _shopServerInfo)
end

function isShopOpen()
	local itemArray = getItemList()
	if table.count(itemArray) > 0 then
		return true
	else
		return false
	end
end
