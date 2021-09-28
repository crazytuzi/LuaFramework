-- FileName: DevilTowerShopData.lua 
-- Author: fuqiongqiong
-- Date: 2016-7-29
-- Purpose:试练塔商店数据层

module("DevilTowerShopData",package.seeall)
require "db/DB_Nightmare_shop"
local _shopInfo

function getItemList( ... )
	local itemArray = {}
	local index = 1
	for k,v in pairs(DB_Nightmare_shop.Nightmare_shop) do
		local str = string.split(tostring(k),"_")
		local data = DB_Nightmare_shop.getDataById(tonumber(str[2]))
		if(tonumber(data.isSold) == 1)then
			itemArray[index] = data
			index = index + 1 
		end
	end
	local function keySort( itemArray1, itemArray2 )
		return tonumber(itemArray1.sortType) < tonumber(itemArray2.sortType)
	end
	table.sort(itemArray, keySort)
	return itemArray
end

function getItemById( pId )
	local itemArray = getItemList()
	return itemArray[pId]
end

-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end

function setShopInfo(pData )
	_shopInfo = pData
end

--获取梦魇积分
function getDevilTowerScore( ... )
	return tonumber(_shopInfo.point)
end

--修改梦魇积分
function setDevilTowerScore( pScore )
	_shopInfo.point = tonumber(_shopInfo.point) - pScore
end
--修改物品的购买信息
function setInfoOfGoods( pIndex,num)
	local itemArray = getItemList()
	local pId = tonumber(itemArray[pIndex].id) 
	local goodsInfoArray = _shopInfo.info
	local isExit = false
	if(not table.isEmpty(goodsInfoArray))then
		for k,v in pairs(goodsInfoArray) do
			if(tonumber(k) == tonumber(pId))then
				goodsInfoArray[k] = tonumber(v) + num
				isExit = true
				break
			end
		end
		if(not isExit)then
			_shopInfo.info[pId] = num
		end
	else
		_shopInfo.info[pId] = num
	end	
	print("_shopInfo.info")
	print_t(_shopInfo.info)
end
--物品的购买信息(已购买次数)
function getInfoOfGoods( pId )
	local num = 0
	local goodsInfoArray = _shopInfo.info
	if(not table.isEmpty(goodsInfoArray))then
		for k,v in pairs(goodsInfoArray) do
			if(tonumber(k) == tonumber(pId))then
				num = tonumber(v)
				break
			end
		end
	end
	
	return num
end