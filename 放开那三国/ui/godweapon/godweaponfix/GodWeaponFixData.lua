-- FileName: GodWeaponFixData.lua 
-- Author: licong 
-- Date: 15-1-13 
-- Purpose: 神兵洗练的数据


module("GodWeaponFixData", package.seeall)

require "script/ui/item/GodWeaponItemUtil"

--[[
	@des 	:获得神兵可洗练的层数
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid p_itemInfo:神兵的所有信息
	@return :num
--]]
function getGodWeapinFixNum( p_godWeaponTemplId, p_godWeaponItemId, p_itemInfo )
	local itemInfo = nil
	if(p_itemInfo ~= nil)then
		itemInfo = p_itemInfo
	else
		itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	end
	local tab = string.split(itemInfo.itemDesc.awakeopen_quality, ",")
	local retNum = table.count(tab)
	return retNum
end

--[[
	@des 	:获得神兵开启洗练层数需要的品质数组
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid p_itemInfo:神兵的所有信息
	@return :{1层需要品质，21层需要品质，3层需要品质}
--]]
function getGodWeapinFixNeedQualityTab( p_godWeaponTemplId, p_godWeaponItemId, p_itemInfo )
	local itemInfo = nil
	if(p_itemInfo ~= nil)then
		itemInfo = p_itemInfo
	else
		itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	end
	local retTab = string.split(itemInfo.itemDesc.awakeopen_quality, ",")
	return retTab
end

--[[
	@des 	:获得神兵洗练层数是否开启
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid,p_fixNum:洗练第几层 p_itemInfo:神兵的所有信息
	@return :true or false
--]]
function getGodWeapinFixIsOpneByFixNum(p_godWeaponTemplId, p_godWeaponItemId, p_fixNum, p_itemInfo)
	local isOpen = false
	-- 强化神兵的品质,进阶次数，显示阶数
	local quality,evolveNum,evolveShowNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(p_godWeaponTemplId,p_godWeaponItemId,p_itemInfo)
	-- 开启需要的品质
	local openNeedTab = getGodWeapinFixNeedQualityTab(p_godWeaponTemplId,p_godWeaponItemId,p_itemInfo)

	if( quality >= tonumber(openNeedTab[tonumber(p_fixNum)]) )then
		isOpen = true
	end

	return isOpen
end

--[[
	@des 	:获得神该洗练层数可洗练的最大星数
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层 p_itemInfo:神兵的所有信息
	@return :num
--]]
function getGodWeapinFixMaxStar(p_godWeaponTemplId, p_godWeaponItemId, p_fixNum, p_itemInfo )
	local itemInfo = nil
	if(p_itemInfo ~= nil)then
		itemInfo = p_itemInfo
	else
		itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	end
	local tab = string.split(itemInfo.itemDesc.awakestar_max, ",")
	local retNum = tab[tonumber(p_fixNum)]
	return retNum
end


--[[
	@des 	:获得神兵该层普通洗练的消耗数据
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层
	@return :消耗物品id，消耗物品数量
--]]
function getGodWeapinOrdinaryFixCost( p_godWeaponTemplId, p_godWeaponItemId, p_fixNum )
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	local tab = string.split(itemInfo.itemDesc.washawake_item, ",")
	local curCost = string.split(tab[tonumber(p_fixNum)], "|")
	local retTid = tonumber(curCost[1])
	local retNum = tonumber(curCost[2])
	return retTid,retNum
end

--[[
	@des 	:获得神兵该层金币洗练的消耗数据
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层
	@return :消耗物品id，消耗物品数量，金币数量
--]]
function getGodWeapinGoldFixCost( p_godWeaponTemplId, p_godWeaponItemId, p_fixNum )
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	local tab = string.split(itemInfo.itemDesc.washawake_goldcost, ",")
	local curCost = string.split(tab[tonumber(p_fixNum)], "|")
	local retTid = tonumber(curCost[1])
	local retNum = tonumber(curCost[2])
	local retGold = tonumber(curCost[3])
	return retTid,retNum,retGold
end


--[[
	@des 	:获得该神兵每一层可洗练出来的属性
	@param 	:p_godWeaponTemplId神兵模板id,p_godWeaponItemId:神兵itemid
	@return :{ 1{1,2,3}, 2{1,2,3}, 3{1,2,3}, 4{1,2,3} }
--]]
function getGodWeapinCanFixAttrTab(p_godWeaponTemplId, p_godWeaponItemId )
	local retTab = {}
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(p_godWeaponTemplId,p_godWeaponItemId)
	local tab = string.split(itemInfo.itemDesc.awake_display, ",")
	for i=1,#tab do
		local tab1 = string.split(tab[i], "|")
		table.insert(retTab,tab1)
	end
	return retTab
end


--[[
	@des 	:获得神兵洗练属性的信息
	@param 	:p_attrId:神兵洗练属性id
	@return :table
--]]
function getGodWeapinFixAttrInfoById( p_attrId )
	require "db/DB_Godarm_affix"
	local attrInfo = DB_Godarm_affix.getDataById(p_attrId)
	return attrInfo
end

--[[
	@des 	:获得神兵当前洗练层可替换属性id
	@param 	:p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层
	@return :nil or attrId
--]]
function getGodWeapinToConfirmAttr( p_godWeaponItemId, p_fixNum )
	local attrId = nil
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(nil,p_godWeaponItemId)
	if( not table.isEmpty(itemInfo.va_item_text.toConfirm) )then
		attrId = itemInfo.va_item_text.toConfirm[tostring(p_fixNum)]
	end
	return attrId
end

--[[
	@des 	:获得神兵当前洗练层已有属性id
	@param 	:p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层
	@return :nil or attrId
--]]
function getGodWeapinConfirmAttr( p_godWeaponItemId, p_fixNum )
	local attrId = nil
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(nil,p_godWeaponItemId)
	if( not table.isEmpty(itemInfo.va_item_text.confirmed) )then
		attrId = itemInfo.va_item_text.confirmed[tostring(p_fixNum)]
	end
	return attrId
end


--[[
	@des 	:获得神兵当前洗练层已有属性id
	@param 	:p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层,p_attrId属性id p_itemInfo:神兵的所有信息
	@return :color
	-- 公式
	比值X=int（100X神兵当前层星级/神兵当前层最大星级）
	20>=x>=0 白色
	40>=x>=21 绿色
	70>=x>=41 蓝色
	99>=x>=71 紫色
	x>=100 橙色
--]]
local tColors = {
 	{
 		-- 白色
 		starNum = 0,
 	  	endNum = 20, 
 	  	color = ccc3(0xff, 0xff, 0xff)
 	},
 	{
 		-- 绿色
 		starNum = 21,
 	  	endNum = 40, 
 	  	color = ccc3(0x00, 0xeb, 0x21)
 	},
 	{
 		-- 蓝色
 		starNum = 41,
 	  	endNum = 70, 
 	  	color = ccc3(0x51, 0xfb, 0xff)
 	},
 	{
 		-- 紫色
 		starNum = 71,
 	  	endNum = 99, 
 	  	color = ccc3(0xff, 0x00, 0xe1)
 	},
 	{
 		-- 橙色
 		starNum = 100,
 	  	endNum = 100000, 
 	  	color = ccc3(0xff, 0x84, 0x00)
 	}
}
function getGodWeapinFixAttrColor( p_godWeaponItemId, p_fixNum, p_attrId, p_itemInfo )
	local curAttrId = p_attrId
	local curAtrrInfo = getGodWeapinFixAttrInfoById( curAttrId )
	local curStar = tonumber(curAtrrInfo.star)
	local maxStar = getGodWeapinFixMaxStar(nil, p_godWeaponItemId, p_fixNum, p_itemInfo )
	local num = math.floor( curStar/tonumber(maxStar)*100 )
	local retColor = ccc3(0xff, 0xff, 0xff)
	for i=1,#tColors do
		if( tColors[i].starNum <= num and num <= tColors[i].endNum )then
			retColor = tColors[i].color
			break
		end
	end
	return retColor
end

--[[
	@des 	:获得神兵当前洗练属性id是否是高品质属性
	@param 	:p_godWeaponItemId:神兵itemid, p_fixNum:洗练第几层,p_attrId属性id
	@return :true or false   比值>=71即为高品质属性
	-- 公式
	比值X=int（100X神兵当前层星级/神兵当前层最大星级）
	20>=x>=0 白色
	40>=x>=21 绿色
	70>=x>=41 蓝色
	99>=x>=71 紫色
	x>=100 橙色
--]]
function getGodWeapinFixAttrIsGood( p_godWeaponItemId, p_fixNum, p_attrId )
	local isGood = false
	if(p_attrId == nil)then
		return isGood
	end
	local curAttrId = p_attrId
	local curAtrrInfo = getGodWeapinFixAttrInfoById( curAttrId )
	local curStar = tonumber(curAtrrInfo.star)
	local maxStar = getGodWeapinFixMaxStar(nil, p_godWeaponItemId, p_fixNum )
	local num = math.floor( curStar/tonumber(maxStar)*100 )
	if(num >= 71)then
		isGood = true
	else
		isGood = false
	end
	return isGood
end


--[[
	@des 	:获得神兵当前加的所有属性
	@param 	:p_godWeaponItemId:神兵itemid
	@return :{ {id=1,realNum=100},{id=2,realNum=200} ... }
--]]
function getGodWeapinFixAttrForFight( p_godWeaponItemId )
	local retTab = {}
	local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(nil,p_godWeaponItemId)
	if( not table.isEmpty(itemInfo.va_item_text.confirmed) )then
		for k,v in pairs(itemInfo.va_item_text.confirmed) do
			-- 判断该层封印是否开启
			local isOpen = getGodWeapinFixIsOpneByFixNum(nil, p_godWeaponItemId, k)
			if(isOpen)then
				local attrInfo = getGodWeapinFixAttrInfoById( v )
				local tab1 = string.split(attrInfo.attri_ids, "|")
				local tempTab = {}
				tempTab.id = tab1[1]
				tempTab.realNum = tab1[2]
				table.insert(retTab,tempTab)
			end
		end
	end
	return retTab
end


-------------------------------------------------- 神兵传承 ----------------------------------------------------
local _seletGodList = {}  -- 已经选择的神兵材料

--[[
	@des 	:获得神兵当前层传承花费
	@param 	:p_index:传承第几层
	@return :num
--]]
function getGodInheritCostBy( p_index )
	local retNum = 0
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	local tab1 = string.split(dbData.godinherit, ",")
	for i=1,#tab1 do
		local tab2 = string.split(tab1[i], "|")
		if(tonumber(tab2[1]) == tonumber(p_index))then
			retNum = tonumber(tab2[2])
			break
		end
	end
	return retNum
end


--[[
	@des 	:获得神兵传承列表数据
	@param 	:p_srcItemId:强化的原神兵
	@return :
--]]
function getCanInheritGodWeapon( p_srcItemId )
	local srcItemInfo = ItemUtil.getItemByItemId(p_srcItemId)
	if(srcItemInfo == nil)then
		srcItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(p_srcItemId)
	end

	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	if not table.isEmpty(bagInfo.godWp)then
		for k,v in pairs(bagInfo.godWp) do
			if( tonumber(p_srcItemId) ~= tonumber(v.item_id) )then
				-- 是同一类型的 并且不是经验神兵
				if( tonumber(v.itemDesc.type) == tonumber(srcItemInfo.itemDesc.type) and tonumber(v.itemDesc.isgodexp) ~= 1 )then
					table.insert(retTab,v)
				end
			end
		end
	end
	table.sort( retTab, BagUtil.equipGodWeaponSort )

	-- 英雄身上的
	local herosEquips = HeroUtil.getAllGodWeaponOnHeros()
	if not table.isEmpty(herosEquips)then
		for k,v in pairs(herosEquips) do
			if( tonumber(p_srcItemId) ~= tonumber(v.item_id) )then
				-- 是同一类型的
				if( tonumber(v.itemDesc.type) == tonumber(srcItemInfo.itemDesc.type) )then
					table.insert(retTab,v)
				end
			end
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







