-- Filename: EquipAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 装备属性计算

module("EquipAffixModel", package.seeall)

require "db/DB_Item_arm"
require "db/DB_Suit"

local _affixCache = {}

--[[
	@parm: p_hid 武将id
	@parm: p_isForce 强制刷新
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid, p_isForce )
	--先从缓存取
	if _affixCache[tonumber(p_hid)] and p_isForce ~= true then
		return _affixCache[tonumber(p_hid)]
	end
	--装备加成 = 武将身上的所有装备属性 + 套装属性
	local heroInfo 	  = HeroModel.getHeroByHid(tostring(p_hid))
	local heroDBInfo  = DB_Heroes.getDataById(heroInfo.htid)
	local affix = {}
	-- 装备加成系统战斗力加成
	local arming = heroInfo.equip.arming or {}
	for k, v in pairs(arming) do
		if tonumber(v) ~= 0 then
			local equipAffixInfo  = getEquipAffixByEquipInfo(v)
			for k,v in pairs(equipAffixInfo) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
			local fixedAffixInfo = getEquipFixedAffix(v)
			for k,v in pairs(fixedAffixInfo) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
			local developAffixInfo = getDevelopAffixByInfo(v)
			printTable("developAffixInfo", developAffixInfo)
			for k,v in pairs(developAffixInfo) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
			local developLockInfo = getDevelopLockAffixByInfo(v)
			printTable("developLockInfo", developLockInfo)
			print("developLockInfo", v.item_id)			
			for k,v in pairs(developLockInfo) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
		end
	end
	-- 套装属性
	local suitAffix = getSuitAffix(heroInfo.equip.arming)
	for k,v in pairs(suitAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	-- 进阶套装属性
	local developSuitAffix = getDevelopSuitAffixByArmInfo(heroInfo.equip.arming)
	for k,v in pairs(developSuitAffix) do
		if affix[k] == nil then
			affix[k] = v
		else
			affix[k] = affix[k] + v
		end
	end
	printTable("developSuitAffix", developSuitAffix)

	_affixCache[tonumber(p_hid)] = affix
	return affix
end

--[[
	@des: 根据属性字段得到装备属性id
	@parm: string-属性字段
	@ret: int-属性id  
--]]
function getEquipAffixIdByDesStr( p_AffixStr )
	local affixDes = {
		-- 生命id
		baseLife      = 1,
		-- 武将基础通用攻击
		baseGenAtt    = 9,
		-- 英雄基础物理攻击
		basePhyAtt    = 2,
		-- 英雄基础魔法攻击
		baseMagAtt    = 3,
		-- 英雄基础物理防御
		basePhyDef    = 4,
		-- 英雄基础魔法防御
		baseMagDef    = 5,
		-- 强化1级增加生命值百分比
		hpRatioPL     = 11,
		-- 强化1级增加物理攻击百分比
		phyAttRatioPL = 12,
		-- 强化1级增加魔法攻击百分比
		phyDefRatioPL = 13,
		-- 强化1级增加物理防御百分比
		magAttRatioPL = 14,
		-- 强化1级增加魔法防御百分比
		magDefRatioPL = 15,
		-- 强化1级增加通用攻击百分比
		genAttRatioPL = 19,
	}
	return affixDes[p_AffixStr]
end

--[[
	@des  :计算单个装备基础属性
	@parm :p_tid
	@ret  :属性tab
--]]
function getEquipBaseAffixByTid( p_itemTid )
	local equipInfo = DB_Item_arm.getDataById(p_itemTid)
	local affix = {}
	-- 生命id
	affix[getEquipAffixIdByDesStr("baseLife")] = tonumber(equipInfo.baseLife)
	-- 武将基础通用攻击
	affix[getEquipAffixIdByDesStr("baseGenAtt")] = tonumber(equipInfo.baseGenAtt)
	-- 英雄基础物理攻击
	affix[getEquipAffixIdByDesStr("basePhyAtt")] = tonumber(equipInfo.basePhyAtt)
	-- 英雄基础魔法攻击
	affix[getEquipAffixIdByDesStr("baseMagAtt")] = tonumber(equipInfo.baseMagAtt)
	-- 英雄基础物理防御
	affix[getEquipAffixIdByDesStr("basePhyDef")] = tonumber(equipInfo.basePhyDef)
	-- 英雄基础魔法防御
	affix[getEquipAffixIdByDesStr("baseMagDef")] = tonumber(equipInfo.baseMagDef)
	return affix
end
--[[
	@des  :计算单个装备基础属性,包括强化等级属性
	@parm :p_equipInfo 后端装备信息
	@ret  :属性tab
--]]
function getEquipAffixByEquipInfo( p_equipInfo )
	-- printTable("p_equipInfo", p_equipInfo)
	local dbInfo = DB_Item_arm.getDataById(p_equipInfo.item_template_id)
    --强化等级
    local level = tonumber(p_equipInfo.va_item_text.armReinforceLevel) or 0

    local affix = {}
	-- 普通属性总值 = 基础属性 + 强化等级 * 强化属性增量/100
	-- 生命id
	affix[getEquipAffixIdByDesStr("baseLife")] = (dbInfo.baseLife or 0) + level*(dbInfo.lifePL or 0)/100
	-- 武将基础通用攻击
	affix[getEquipAffixIdByDesStr("baseGenAtt")] = (dbInfo.baseGenAtt or 0) + level*(dbInfo.genAttPL or 0)/100
	-- 英雄基础物理攻击
	affix[getEquipAffixIdByDesStr("basePhyAtt")] = (dbInfo.basePhyAtt or 0) + level*(dbInfo.phyAttPL or 0)/100
	-- 英雄基础魔法攻击
	affix[getEquipAffixIdByDesStr("baseMagAtt")] = (dbInfo.baseMagAtt or 0) + level*(dbInfo.magAttPL or 0)/100
	-- 英雄基础物理防御
	affix[getEquipAffixIdByDesStr("basePhyDef")] = (dbInfo.basePhyDef or 0) + level*(dbInfo.phyDefPL or 0)/100
	-- 英雄基础魔法防御
	affix[getEquipAffixIdByDesStr("baseMagDef")] = (dbInfo.baseMagDef or 0) + level*(dbInfo.magDefPL or 0)/100
	
	--百分比属性总值 = 强化等级 * 强化属性增量/10000
	-- 武将基础通用攻击
	affix[getEquipAffixIdByDesStr("genAttRatioPL")] = level*(dbInfo.genAttRatioPL or 0)/10000
	-- 英雄基础物理攻击
	affix[getEquipAffixIdByDesStr("phyAttRatioPL")] = level*(dbInfo.phyAttRatioPL or 0)/10000
	-- 英雄基础魔法攻击
	affix[getEquipAffixIdByDesStr("magAttRatioPL")] = level*(dbInfo.magAttRatioPL or 0)/10000
	-- 英雄基础物理防御
	affix[getEquipAffixIdByDesStr("phyDefRatioPL")] = level*(dbInfo.phyDefRatioPL or 0)/10000
	-- 英雄基础魔法防御
	affix[getEquipAffixIdByDesStr("magDefRatioPL")] = level*(dbInfo.magDefRatioPL or 0)/10000
	return affix
end

--[[
	@des:得到装备洗练属性
--]]
function getEquipFixedAffix( p_equipInfo )
	--统一加洗练属性
	local affix = {}
	local equipFixInfo = p_equipInfo.va_item_text.armPotence or {}
	for k,v in pairs(equipFixInfo) do
		if affix[tonumber(k)] == nil then
			affix[tonumber(k)] = tonumber(v)
		else
			affix[tonumber(k)] = affix[tonumber(k)] + tonumber(v)
		end
	end
	return affix
end


--[[
	@des  :计算单个装备基础属性,包括强化等级属性
	@parm :p_hid
	@ret  :属性tab
--]]
function getEquipAffixById( p_itemId )
	local equipInfo = ItemUtil.getItemInfoByItemId(p_itemId)
    if(equipInfo   == nil )then
        equipInfo   = ItemUtil.getEquipInfoFromHeroByItemId(p_itemId)
    end
    
   	local affix = getEquipAffixByEquipInfo(equipInfo)
   	return affix
end

--[[
	@des:得到装备进阶属性
--]]
function getDevelopAffixByInfo( p_equipInfo )
	local developLevel = p_equipInfo.va_item_text.armDevelop
	local level = tonumber(p_equipInfo.va_item_text.armReinforceLevel) or 0
	if not developLevel then
		return {}
	end
	developLevel = tonumber(developLevel) or 0
	local affix = {}
	local equipDB = DB_Item_arm.getDataById(p_equipInfo.item_template_id)
	local developAttrConfig = string.split(equipDB.extra_levelupattr, ",")

	if table.count(developAttrConfig) > 0 then
		for k,v in pairs(developAttrConfig) do
			local attrInfo = string.split(v, "|")
			local needLevel = tonumber(attrInfo[1])
			local affixId   = tonumber(attrInfo[2])
			local affixValue = level*tonumber(attrInfo[3])/100
			if developLevel >= needLevel then
				if not affix[affixId] then
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
	@des:得到装备进阶解锁属性
--]]
function getDevelopLockAffixByInfo( p_equipInfo )
	local developLevel = p_equipInfo.va_item_text.armDevelop
	local level = tonumber(p_equipInfo.va_item_text.armReinforceLevel) or 0
	if not developLevel then
		return {}
	end
	developLevel = tonumber(developLevel) or 0
	local affix = {}
	local equipDB = DB_Item_arm.getDataById(p_equipInfo.item_template_id)
	local lockAttrConfig = string.split(equipDB.evolve_attr, ",")
	if table.count(lockAttrConfig) >0 then
		printTable("lockAttrConfig:"..p_equipInfo.item_id, lockAttrConfig)
		for k,v in pairs(lockAttrConfig) do
			local attrInfo = string.split(v, "|")
			local needLevel = tonumber(attrInfo[1])
			local affixId   = tonumber(attrInfo[2])
			local affixValue = tonumber(attrInfo[3])
			if developLevel >= needLevel then
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
	@des :得到套装属性
--]]
function getSuitAffix( p_ArmInfo )
	local suitMap = {}
	for k,v in pairs(p_ArmInfo) do
		if tonumber(v)~=0 then
			local suitId = DB_Item_arm.getDataById(v.item_template_id).jobLimit
			if suitId ~= nil then
				if suitMap[suitId] == nil then
					suitMap[suitId] = 1
				else
					suitMap[suitId] = suitMap[suitId] + 1
				end
			end
		end
	end
	local affix = {}
	for k,v in pairs(suitMap) do
		local dbInfo = DB_Suit.getDataById(k)
		for i=1,10 do
			-- TODO : for 1 ,v
			local lockNum = tonumber(dbInfo["lock_num" .. i]) or 99
			if v >= lockNum then
				local suitAttr = dbInfo["astAttr" .. i]
				local suitAttrInfo = string.split(suitAttr, ",")
				for k1,v1 in pairs(suitAttrInfo) do
					local suitAffixTable = string.split(v1, "|")
					if not table.isEmpty(suitAffixTable) then
						local affixId = tonumber(suitAffixTable[1])
						local affixValue = tonumber(suitAffixTable[2])
						if affix[affixId] == nil then
							affix[affixId] = affixValue
						else
							affix[affixId] = affix[affixId] + affixValue
						end
					end
				end

			end
		end
	end
	printTable("suilt Affix", affix)
	return affix
end

--[[
	@des  :得到进阶套装属性
	@parm :武将装备信息
--]]
function getDevelopSuitAffixByArmInfo( p_ArmInfo )
	local minDevelopLevel = nil
	for k,v in pairs(p_ArmInfo) do
		if tonumber(v) ~= 0 then
			local developLevel = tonumber(v.va_item_text.armDevelop)
			if not minDevelopLevel and developLevel then
				minDevelopLevel = developLevel
			end
			if developLevel and developLevel <= minDevelopLevel then
				minDevelopLevel = developLevel
			end
			if developLevel == nil then
				minDevelopLevel = -1
				break
			end
		else
			minDevelopLevel = -1
			break
		end
	end
	if minDevelopLevel and minDevelopLevel < 0 then
		return {}
	end
	minDevelopLevel = minDevelopLevel or 0
	local affix = {}
	require "db/DB_Arm_suit"
	for i=1,table.count(DB_Arm_suit.Arm_suit) do
		local suitInfo = DB_Arm_suit.getDataById(i)
		if tonumber(suitInfo.level)<=minDevelopLevel then
			local affixConfig = string.split(suitInfo.affix, ",")
			for k,v in pairs(affixConfig) do
				local affixInfo = string.split(v, "|")
				local affixId = tonumber(affixInfo[1])
				local affixValue = tonumber(affixInfo[2])
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
	@des 	:得到进阶套装属性
	@parm 	:武将id
--]]
function getDevelopSuitAffixByHid( p_hid )
	local heroInfo = HeroModel.getHeroByHid(tostring(p_hid))
	local affix = getDevelopSuitAffixByArmInfo(heroInfo.equip.arming)
	return affix
end
