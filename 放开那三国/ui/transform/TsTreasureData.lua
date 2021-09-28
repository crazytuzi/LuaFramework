-- FileName: TsTreasureData.lua 
-- Author: licong 
-- Date: 16/3/4 
-- Purpose: 宝物转换数据 


module("TsTreasureData", package.seeall)

local _seletList = {}  -- 已经选择的材料

--[[
	@des 	:获得符合的物品
	@param 	:
	@return :
--]]
function getChooseItemData()
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	local needTidTab = getAllTransformItemTid()
	if not table.isEmpty(bagInfo.treas)then
		for k,v in pairs(bagInfo.treas) do
			for k,v_tid in pairs(needTidTab) do
				-- tid相符的
				if( tonumber(v.item_template_id) == tonumber(v_tid) )then
					table.insert(retTab,v)
					break
				end
			end
		end
	end
	table.sort( retTab, BagUtil.treasSort )
	return retTab
end

--[[
	@des 	:获得功能开启等级
	@param 	:
	@return :num
--]]
function getOpenNeedLv()
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	return tonumber(dbData.openChangeTreasure)
end

--[[
	@des 	:是否开启功能
	@param 	:
	@return :num
--]]
function isOpen()
	local ret = false
	local needLv = getOpenNeedLv()
	if( UserModel.getHeroLevel() >= needLv )then 
		ret = true
	end
	return ret
end

--[[
	@des 	:获得转换花费
	@param 	:
	@return :num
--]]
function getTransformCost()
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	return tonumber(dbData.changeTreasureCost)
end

--[[
	@des 	:获得所有可以转换tid
	@param 	:
	@return :{}
--]]
function getAllTransformItemTid()
	local retTab = {}
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	local tab1 = string.split(dbData.changeTreasure, ",")
	for i=1,#tab1 do
		local tab2 = string.split(tab1[i], "|")
		for k=1,#tab2 do
			table.insert(retTab,tonumber(tab2[k]))
		end
	end
	return retTab
end

--[[
	@des 	:获得一个tid可以转换的其他tid
	@param 	:
	@return :{}
--]]
function getTransformItemByTid(p_tid)
	local retTab = {}
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	local tab1 = string.split(dbData.changeTreasure, ",")
	local tempInde = nil
	for i=1,#tab1 do
		local tab2 = string.split(tab1[i], "|")
		for k=1,#tab2 do
			if( tonumber(p_tid) == tonumber(tab2[k]) )then
				tempInde = i
				break
			end
		end
		if( tempInde ~= nil )then
			break
		end
	end

	local arr = string.split(tab1[tempInde], "|")
	for j=1, #arr do
		if( tonumber(p_tid) ~= tonumber(arr[j]) )then
			table.insert(retTab,tonumber(arr[j]))
		end
	end
	return retTab
end

--[[
	@des 	:清除选择物品列表
	@param 	:
	@return :
--]]
function cleanSelectList()
	_seletList = {}
end

--[[
	@des 	:获得已经选择的物品列表
	@param 	:
	@return :
--]]
function getSelectList()
	return _seletList
end

--[[
	@des 	:设置已经选择的物品列表
	@param 	:
	@return :
--]]
function setSelectList( p_list )
	_seletList = p_list
end

--[[
	@des 	:往选择列表里添加物品 已选择列表有该物品就删除该物品
	@param 	:p_itemId:物品id
	@return :
--]]
function addToSelectList( p_itemId )
	local isIn = false
	local pos = 0
	for k,v in pairs(_seletList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			pos = k
			break
		end
	end
	if(isIn)then
		table.remove(_seletList,pos)
	else
		local tab = {}
		tab.item_id = p_itemId
		table.insert(_seletList,tab)
	end
end

--[[
	@des 	:判断列表里是否有这个物品
	@param 	:p_itemId:材料id
	@return :
--]]
function getIsInSelectListByItemId( p_itemId )
	local isIn = false
	for k,v in pairs(_seletList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			break
		end
	end
	return isIn
end