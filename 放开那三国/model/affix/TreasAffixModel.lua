-- Filename: TreasAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 武将数据

module("TreasAffixModel", package.seeall)

local _affixCache = {}
--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid, p_isForce)
	--先从缓存取
	if _affixCache[tonumber(p_hid)] and p_isForce ~= true then
		return _affixCache[tonumber(p_hid)]
	end
	local heroInfo 	  = HeroModel.getHeroByHid(tostring(p_hid))
	local heroDBInfo  = DB_Heroes.getDataById(heroInfo.htid)
	local affix = {}
	-- 宝物系统战斗力加成
	local treasure = heroInfo.equip.treasure or {}
	for k, v in pairs(treasure) do
		if type(v) == "table" then
			local treasureInfo  = getAllAffixByInfo(v)
			for k,v in pairs(treasureInfo ) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
		end
	end
	_affixCache[tonumber(p_hid)] = affix
	return affix
end

--[[
	@des:得到宝物的基础属性
	@parm:p_itemTid 宝物模板id
	@ret:{
		affixId => id
	}
--]]
function getTreasureBaseAffix( p_itemTid )
	local db_data = DB_Item_treasure.getDataById(p_itemTid)
	local affix = {}
	-- 宝物基础加成值 
	for i=1, 5 do
		local base = db_data["base_attr"..i]
		local typeValue = string.split(base, "|")
		if not table.isEmpty(typeValue) then 
			local affixId = tonumber(typeValue[1])
			local affixValue = tonumber(typeValue[2])
			if affix[affixId] == nil then
				affix[affixId] = affixValue
			else
				affix[affixId] = affix[affixId] + affixValue
			end
		end
	end
	return affix
end

--[[
	@des:得到宝物所有属性总和
	@pram:p_info 宝物信息
	@ret:{
		affixId => id
	}
--]]
function getAllAffixByInfo( p_treasInfo )
	local affix = {}
	--基础属性和成长属性
	local increaseAffix   = getIncreaseAffixByInfo(p_treasInfo)
	for k,v in pairs(increaseAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	--精炼属性
	local upgradeAffix    = getUpgradeAffixByInfo(p_treasInfo)
	for k,v in pairs(upgradeAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	--解锁属性
	local extActivesAffix = getExtactiveAffixByInfo(p_treasInfo)
	for k,v in pairs(extActivesAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	--镶嵌属性
	local inlayAffix      = getInlayAffixByInfo(p_treasInfo)
	for k,v in pairs(inlayAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	return affix
end

--[[
	@des:得到宝物的基本属性和成长属性包括宝物进橙
	@pram:p_info 宝物信息
	@ret:{
		affixId => id
	}
--]]
function getIncreaseAffixByInfo( p_info )
	require "db/DB_Item_treasure"
	local db_data = DB_Item_treasure.getDataById(p_info.item_template_id)
    --强化等级
    local level = tonumber(p_info.va_item_text.treasureLevel) or 0
  
	local affix = getTreasureBaseAffix(p_info.item_template_id)
	-- 宝物等级成长属性 
	-- TODO: While
	for i=1, 5 do
		local base = db_data["increase_attr"..i]
		local typeValue = string.split(base, "|")
		if not table.isEmpty(typeValue) then 
			local affixId = tonumber(typeValue[1])
			local affixValue = tonumber(typeValue[2]) * level
			if affix[affixId] == nil then
				affix[affixId] = affixValue
			else
				affix[affixId] = affix[affixId] + affixValue
			end
		end
	end

	if p_info.va_item_text.treasureDevelop and tonumber(p_info.va_item_text.treasureDevelop) > -1 then
		local developLevel = 0
		local treasureNum = p_info.va_item_text.treasureDevelop
		while developLevel <= tonumber(treasureNum) do
			local develop = nil
			if( developLevel <= 5 )then
				develop = string.split(db_data["extra_affix_"..developLevel], "|")
			else
				local num = (developLevel-6)
				develop = string.split(db_data["extra_affix2_"..num], "|")
			end
			local affixId = tonumber(develop[1])
			local affixValue = tonumber(develop[2])
			if affix[affixId] == nil then
				affix[affixId] = affixValue 
			else
				affix[affixId] = affix[affixId] + affixValue
			end
			developLevel = developLevel + 1
		end
	end
	return affix
end

--[[
	@des:宝物精炼属性
	@pram:p_info 宝物信息
	@ret:{
		affixId => id
	}
--]]
function getUpgradeAffixByInfo( p_info )
	require "db/DB_Item_treasure"
	local db_data = DB_Item_treasure.getDataById(p_info.item_template_id)
	--精炼等级
    local evolveLevel = tonumber(p_info.va_item_text.treasureEvolve) or 0
	-- 宝物精炼属性
	local affix = {}
	local upgradeAffix = string.split(db_data.upgrade_affix, ",")
	for k,v in pairs(upgradeAffix) do
		local values     = string.split(v, "|")
		if not table.isEmpty(values) then 
			local affixId    = tonumber(values[1])
			local affixValue = tonumber(values[2]) * evolveLevel
			if affix[affixId] == nil then
				affix[affixId] = affixValue 
			else
				affix[affixId] = affix[affixId] + affixValue
			end
		end
	end
	return affix
end

--[[
	@des:宝物解锁属性
	@pram:p_info 宝物信息
	@ret:{
		affixId => id
	}
--]]
function getExtactiveAffixByInfo( p_info )
	require "db/DB_Item_treasure"
	local db_data = DB_Item_treasure.getDataById(p_info.item_template_id)
    --强化等级
    local level = tonumber(p_info.va_item_text.treasureLevel) or 0
	-- 宝物普通解锁属性
	local extActives = string.split(db_data.ext_active_arr, ",")
	local affix = {}
	for k,v in pairs(extActives) do
		local values     = string.split(v, "|")
		if not table.isEmpty(values) then 
			local needLevel  = tonumber(values[1])
			local affixId    = tonumber(values[2])
			local affixValue = tonumber(values[3])
			if level >= needLevel then
				if affix[affixId] == nil then
					affix[affixId] = affixValue 
				else
					affix[affixId] = affix[affixId] + affixValue
				end
			end
		end
	end
	--橙色宝物解锁属性
	if p_info.va_item_text.treasureDevelop and tonumber(p_info.va_item_text.treasureDevelop) > -1 and tonumber(p_info.va_item_text.treasureDevelop) <= 5 then
		local developLevel = tonumber(p_info.va_item_text.treasureDevelop)
		local developExtActives = string.split(db_data.extra_active_affix, ",")
		for k,v in pairs(developExtActives) do
			local values     = string.split(v, "|")
			local needLevel 		= tonumber(values[1])
			local needDevelopLevel 	= tonumber(values[2])
			local affixId 			= tonumber(values[3])
			local affixValue 		= tonumber(values[4])
			if level >= needLevel and developLevel >= needDevelopLevel then
				if affix[affixId] == nil then
					affix[affixId] = affixValue 
				else
					affix[affixId] = affix[affixId] + affixValue
				end
			end
		end
	end

	--红色宝物解锁属性
	if p_info.va_item_text.treasureDevelop  and tonumber(p_info.va_item_text.treasureDevelop) > 5 then
		local developLevelMin = tonumber(p_info.va_item_text.treasureDevelop)
		local developExtActives = string.split(db_data.extra_active_affix, ",")
		for k,v in pairs(developExtActives) do
			local values     = string.split(v, "|")
			local needLevel 		= tonumber(values[1])
			local needDevelopLevel 	= tonumber(values[2])
			local affixId 			= tonumber(values[3])
			local affixValue 		= tonumber(values[4])
			if level >= needLevel and developLevelMin >= needDevelopLevel then
				if affix[affixId] == nil then
					affix[affixId] = affixValue 
				else
					affix[affixId] = affix[affixId] + affixValue
				end
			end
		end

		local developLevel = tonumber(p_info.va_item_text.treasureDevelop)
		local developExtActives = string.split(db_data.extra_active_affix2, ",")
		for k,v in pairs(developExtActives) do
			local values     = string.split(v, "|")
			local needLevel 		= tonumber(values[1])
			local needDevelopLevel 	= tonumber(values[2])+6
			local affixId 			= tonumber(values[3])
			local affixValue 		= tonumber(values[4])
			if level >= needLevel and developLevel >= needDevelopLevel then
				if affix[affixId] == nil then
					affix[affixId] = affixValue 
				else
					affix[affixId] = affix[affixId] + affixValue
				end
			end
		end
	end

	return affix
end

--[[
	@des:宝物镶嵌属性
	@pram:p_info 宝物信息
	@ret:{
		affixId => id
	}
--]]
function getInlayAffixByInfo( p_info )
	local affix = {}
	--宝物镶嵌属性
	if not table.isEmpty(p_info.va_item_text.treasureInlay) then
		require "script/ui/bag/RuneData"
		print_t(p_info.va_item_text.treasureInlay)
		for k,v in pairs(p_info.va_item_text.treasureInlay) do
			local inlayAffix = RuneData.getRuneAbilityByItemId(v.item_id)
			for _,affixData in pairs(inlayAffix) do
				if affix[tonumber(affixData.id)] == nil then
					affix[tonumber(affixData.id)] = tonumber(affixData.realNum) 
				else
					affix[tonumber(affixData.id)] = affix[tonumber(affixData.id)] + tonumber(affixData.realNum)
				end
			end
		end
	end
	return affix
end

--[[
	@des:得到宝物的属性
	@parm:p_itemTid 宝物模板id
	@ret:{
		affixId => id
	}
--]]
function getTreasureAffixById( p_ItemId )

	local treasInfo = ItemUtil.getItemInfoByItemId(p_ItemId)
    if(treasInfo   == nil )then
        treasInfo   = ItemUtil.getTreasInfoFromHeroByItemId(p_ItemId)
    end
    local affix = getAllAffixByInfo(treasInfo)
	return affix
end



