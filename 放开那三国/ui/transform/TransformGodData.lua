-- FileName: TransformGodData.lua 
-- Author: licong 
-- Date: 16/3/1 
-- Purpose: 转换神兵数据


module("TransformGodData", package.seeall)

local _seletGodList = {}  -- 已经选择的神兵材料

--[[
	@des 	:获得符合的物品
	@param 	:
	@return :
--]]
function getChooseItemData()
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	local needTidTab = getAllTransformItemTid()
	if not table.isEmpty(bagInfo.godWp)then
		for k,v in pairs(bagInfo.godWp) do
			for k,v_tid in pairs(needTidTab) do
				-- tid相符的
				if( tonumber(v.item_template_id) == tonumber(v_tid) and tonumber(v.va_item_text.lock) ~= 1 )then
					table.insert(retTab,v)
					break
				end
			end
		end
	end
	table.sort( retTab, BagUtil.equipGodWeaponSort )
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
	return tonumber(dbData.openChangeGodarm)
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
	@param 	:p_evolveNum:进阶等级 从0开始
	@return :num
--]]
function getTransformCostBy( p_evolveNum )
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	local tab = string.split(dbData.changeGodarmCost, "|")
	return tonumber(tab[tonumber(p_evolveNum)+1]) or 0
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
	local tab1 = string.split(dbData.changeGodarm, ",")
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
	local tab1 = string.split(dbData.changeGodarm, ",")
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
	@des 	:清除选择神兵列表
	@param 	:
	@return :
--]]
function cleanSelectGodList()
	_seletGodList = {}
end

--[[
	@des 	:获得已经选择的神兵列表
	@param 	:
	@return :
--]]
function getSelectGodList()
	return _seletGodList
end

--[[
	@des 	:设置已经选择的神兵列表
	@param 	:
	@return :
--]]
function setSelectGodList( p_list )
	_seletGodList = p_list
end

--[[
	@des 	:往选择列表里添加神兵 已选择列表有该神兵就删除该神兵
	@param 	:p_itemId:神兵id
	@return :
--]]
function addGodToSelectList( p_itemId )
	local isIn = false
	local pos = 0
	for k,v in pairs(_seletGodList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			pos = k
			break
		end
	end
	if(isIn)then
		table.remove(_seletGodList,pos)
	else
		local tab = {}
		tab.item_id = p_itemId
		table.insert(_seletGodList,tab)
	end
end

--[[
	@des 	:判断列表里是否有这个神兵
	@param 	:p_itemId:材料id
	@return :
--]]
function getIsInSelectListByItemId( p_itemId )
	local isIn = false
	for k,v in pairs(_seletGodList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			break
		end
	end
	return isIn
end