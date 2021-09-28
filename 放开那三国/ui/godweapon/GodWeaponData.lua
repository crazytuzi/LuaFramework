-- FileName: GodWeaponData.lua 
-- Author: licong 
-- Date: 14-12-18 
-- Purpose: 神兵数据文件


module("GodWeaponData", package.seeall)

require "script/ui/item/ItemUtil"	
require "db/DB_Item_godarm"

local _serviceBookInfo = {} 	--神兵录后端返回的数据

-------------------------------------------------------------------------- 神兵强化数据 by licong ----------------------------------------------------------------------------
local _seletMaterialList = {}  -- 已经选择的神兵材料


--[[
	@des 	:获得神兵的强化材料数据
	@param 	:p_disItemId:强化的目标神兵
	@return :
--]]
function getMaterialForGodWeapon( p_disItemId )
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	if not table.isEmpty(bagInfo.godWp)then
		for k,v in pairs(bagInfo.godWp) do
			if( tonumber(p_disItemId) ~= tonumber(v.item_id) )then
				-- 是材料的
				if( tonumber(v.itemDesc.isgodexp) == 1 )then
					table.insert(retTab,v)
				end
			end
		end
	end
	table.sort( retTab, BagUtil.expGodWeaponSort )
	return retTab
end

--[[
	@des 	:清除选择材料列表里的材料
	@param 	:
	@return :
--]]
function cleanMaterialSelectList()
	_seletMaterialList = {}
end

--[[
	@des 	:获得已经选择的神兵强化材料数据
	@param 	:
	@return :
--]]
function getMaterialSelectList()
	return _seletMaterialList
end

--[[
	@des 	:往选择列表里添加材料 已选择列表有改材料就做删除该材料
	@param 	:p_itemId:材料id
	@return :
--]]
function addMaterialToSelectList( p_itemId, p_num )
	local isIn = false
	local pos = 0
	for k,v in pairs(_seletMaterialList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			pos = k
			break
		end
	end
	local itemInfo = ItemUtil.getItemByItemId(p_itemId)
	if(isIn)then
		if( tonumber(itemInfo.itemDesc.maxStacking) > 1 )then
			if(p_num >= 1)then
				_seletMaterialList[pos].num = p_num
			else
				table.remove(_seletMaterialList,pos)
			end
		else
			table.remove(_seletMaterialList,pos)
		end
	else
		if( tonumber(itemInfo.itemDesc.maxStacking) > 1 )then
			if(p_num >= 1)then
				local tab = {}
				tab.num = p_num
				tab.item_id = p_itemId
				table.insert(_seletMaterialList,tab)
			end
		else
			local tab = {}
			tab.num = p_num
			tab.item_id = p_itemId
			table.insert(_seletMaterialList,tab)
		end
	end
end

--[[
	@des 	:从已选择的列表里删除一个材料
	@param 	:p_itemId:材料id
	@return :
--]]
function removeMaterialInSelectList( p_itemId )
	if(table.isEmpty(_seletMaterialList))then
		return
	end
	for k,v in pairs(_seletMaterialList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			table.remove(_seletMaterialList,k)
		end
	end
end

--[[
	@des 	:判断列表里是否有这个材料
	@param 	:p_itemId:材料id
	@return :
--]]
function getIsInSelectListByItemId( p_itemId )
	local isIn = false
	for k,v in pairs(_seletMaterialList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			break
		end
	end
	return isIn
end

--[[
	@des 	:计算材料提供的经验
	@param 	:p_listData:材料列表
	@return :
--]]
function getOfferExpBySelectList( p_listData )
	local totalExp = 0
	for k, v in pairs(p_listData) do
		local itemInfo = ItemUtil.getItemByItemId(v.item_id)
		local add_exp = tonumber(itemInfo.itemDesc.giveexp) * v.num
		if(itemInfo.va_item_text and itemInfo.va_item_text.reinForceExp)then
			add_exp = add_exp + tonumber(itemInfo.va_item_text.reinForceExp)
		end
		totalExp = totalExp + add_exp
	end
	return totalExp
end

--[[
	@des 	:得到神兵当前可强化的等级上限
	@param 	:p_itemId:装备itemId  p_itemInfo:装备完整信息
	@return :
--]]
function getCurMaxLv( p_itemId, p_itemInfo )
	local itemInfo = nil
	local retNum = 0
	if(p_itemInfo ~= nil)then
		itemInfo = p_itemInfo
	else
		itemInfo = ItemUtil.getItemByItemId(p_itemId)
	end
	local evolveNum = tonumber(itemInfo.va_item_text.evolveNum)
	local strTab = string.split(itemInfo.itemDesc.evolveenhance, ",")
	for i=1, #strTab do
		local tab = string.split(strTab[i], "|")
		if(  tonumber(tab[1]) <= evolveNum )then
			retNum = tonumber(tab[2])
		end
	end
	return retNum
end

--[[
	@des 	:得到神兵当前强化的费用
	@param 	:p_itemId:装备itemId  p_itemInfo:装备完整信息 p_addExpNum:增加的经验
	@return :
--]]
function getCurReinforceCost( p_itemId, p_itemInfo, p_addExpNum)
	local itemInfo = nil
	local retNum = 0
	if(p_itemInfo ~= nil)then
		itemInfo = p_itemInfo
	else
		itemInfo = ItemUtil.getItemByItemId(p_itemId)
	end
	retNum = tonumber(p_addExpNum) * tonumber(itemInfo.itemDesc.consumeratio)/10000
	return retNum
end

--[[
	@des 	:得到表2中和表1不一样的元素
	@param 	:p_tab1:表1  p_tab2:表2
	@return :
--]]
function getDifferentInTab2(p_tab1,p_tab2)
	local retTab = {}
	for k,v in pairs(p_tab2) do
		local isIn = false
		for k1,v1 in pairs(p_tab1) do
			if( tonumber(v.item_id) == tonumber(v1.item_id) )then
				isIn = true
				break
			end
		end
		if(isIn == false)then
			table.insert(retTab,v)
		end
	end
	return retTab
end

--[[
	@des 	:获得神兵的强化材料数据
	@param 	:p_disItemId:强化的目标神兵
	@return :
--]]
function getReinforceTenNeedLv()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local retData = tonumber(data.enhance_godarm)
	return retData
end
------------------------------------------------------------------------------------------------------------------------------------------------

--[[
	@des 	:获得可装备的神兵数据
	@param 	:
	@return :
--]]
function getGodWeaponDataForEquipInBag()
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	if not table.isEmpty(bagInfo.godWp)then
		for k,v in pairs(bagInfo.godWp) do
			-- 不是材料的神兵
			if( tonumber(v.itemDesc.isgodexp) ~= 1 )then
				table.insert(retTab,v)
			end
		end
	end
	table.sort( retTab, BagUtil.equipGodWeaponSort )
	return retTab
end

--[[
	@des 	:得到神兵录的db信息
	@return :要显示的神兵录
--]]
function getDBBookInfo()
	local returnTable = {}
	returnTable.common = {}
	returnTable.special = {}
	returnTable.lord = {}
	for k,v in pairs(DB_Item_godarm.Item_godarm) do
		local tempId = v[1]
		local itemInfo = DB_Item_godarm.getDataById(tempId)
		local recordNum = itemInfo.Record
		if recordNum ~= nil then
			local tempTable = itemInfo
			if tonumber(recordNum) == 1 then
				table.insert(returnTable.common,tempTable)
			elseif tonumber(recordNum) == 2 then
				table.insert(returnTable.special,tempTable)
			else
				table.insert(returnTable.lord,tempTable)
			end
		end
	end

	return returnTable
end

--[[
	@des 	:设置后端返回的神兵信息，并设置为tid为key的形式
	@param 	:后端返回的数据
--]]
function setServiceBookInfo(p_info)
	_serviceBookInfo = p_info
end

--[[
	@des 	:得到后端返回的神兵录信息
	@return :神兵录信息
--]]
function getServiceBookInfo()
	return _serviceBookInfo
end

--[[
	@des 	:加入新的神兵录
	@param 	:新的神兵录信息
--]]
function addNewBook(p_newBookInfo)
	for i = 1,#p_newBookInfo do
		table.insert(_serviceBookInfo,p_newBookInfo[i])
	end

	-- 缓存神兵录属性
	getWeaponBookAtrr( true )
end

--------------------------------------------------------------------------- 神兵录战斗力计算方法 ------------------------------------------------------------------
local _allGodBookAttr 				= {} -- 缓存 { id = value, }  key全部都number类型

--[[
	@param 	: p_isForce 是否重新计算 true重新计算
	@des 	:得到給战斗力准备的神兵录信息
	@return :准备好的战斗力数据
--]]
function getWeaponBookAtrr( p_isForce )
	-- local atrrTable = {}
	-- for i = 1,#_serviceBookInfo do
	-- 	local tid = tonumber(_serviceBookInfo[i])
	-- 	local itemInfo = DB_Item_godarm.getDataById(tid)
	-- 	local itemAddTable = string.split(itemInfo.Recordability,",")
	-- 	for j = 1,#itemAddTable do
	-- 		local subString = string.split(itemAddTable[j],"|")
	-- 		if atrrTable[tonumber(subString[1])] == nil then
	-- 			atrrTable[tonumber(subString[1])] = tonumber(subString[2])
	-- 		else
	-- 			atrrTable[tonumber(subString[1])] = tonumber(subString[2]) + atrrTable[tonumber(subString[1])]
	-- 		end
	-- 	end
	-- end 
	-- local returnTable = {}
	-- local formationInfo = DataCache.getFormationInfo() or {}
	-- for k,v in pairs(formationInfo) do
	-- 	local hid = tonumber(v)
	-- 	--如果在这个位置上有武将
	-- 	if hid > 0 then
	-- 		returnTable[hid] = atrrTable
	-- 	end
	-- end

	-- return returnTable

    local retTab = {}
	if(p_isForce ~= true and not table.isEmpty(_allGodBookAttr) )then
		-- 优先返回缓存
		retTab = _allGodBookAttr
		return retTab
	end

	-- 重新计算
	for i = 1,#_serviceBookInfo do
		local tid = tonumber(_serviceBookInfo[i])
		local itemInfo = DB_Item_godarm.getDataById(tid)
		local itemAddTable = string.split(itemInfo.Recordability,",")
		for j = 1,#itemAddTable do
			local subString = string.split(itemAddTable[j],"|")
			if retTab[tonumber(subString[1])] == nil then
				retTab[tonumber(subString[1])] = tonumber(subString[2])
			else
				retTab[tonumber(subString[1])] = tonumber(subString[2]) + retTab[tonumber(subString[1])]
			end
		end
	end 

	_allGodBookAttr = retTab

	return retTab

end

--[[
	@des 	:得到v-k结构的后端返回的神兵录信息
	@return :神兵录信息
--]]
function getCounterBookInfo()
	local returnTable = {}
	for k,v in pairs(_serviceBookInfo) do
		returnTable[tonumber(v)] = k
	end
	return returnTable
end