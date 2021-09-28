-- Filename：	EquipFixedData.lua
-- Author：		李晨阳
-- Date：		2013-7-26
-- Purpose：		装备洗练


module("EquipFixedData", package.seeall)

require "script/model/hero/HeroModel"
require "script/model/DataCache"

potentialityConfig = {
 	{1, "baseLife",   "lifePL" , AffixDef.LIFE},
 	{2, "basePhyAtt", "phyAttPL", AffixDef.PHYSICAL_ATTACK},
 	{3, "baseMagAtt", "magAttPL", AffixDef.MAGIC_ATTACK},
 	{4, "basePhyDef", "phyDefPL", AffixDef.PHYSICAL_DEFEND},
 	{5, "baseMagDef", "magDefPL", AffixDef.MAGIC_DEFEND},
 	{9, "baseGenAtt", "genAttPL", AffixDef.GENERAL_ATTACK},
}


fixedStoneNum = nil

--[[
	@des:   得到当前vip 可洗练的级别
]]
function getVipFixedAble( fixed_type )
	require "db/DB_Vip"
	require "script/model/user/UserModel"
	local vipLevel = UserModel.getVipLevel()
	local vipInfo  = DB_Vip.getDataById(vipLevel+1)
	local fixedTable = string.split(tostring(vipInfo.baPrizeLevel), "|")
	-- print("vipInfo.baPrizeLevel = ", vipInfo.baPrizeLevel)

	-- print("vipInfo")
	-- print_t(vipInfo)
	-- print("fixedTable")
	-- print_t(fixedTable)
	for i,v in pairs(fixedTable) do
		if(tonumber(v) == tonumber(fixed_type)) then
			return true
		end
	end
	return false
end

--[[
	@des: 判断洗练花费
	{
		item:{
			tid: 
			num:
		}
		silver:
		gold:
	}
]]
function getFixedCost( potentiality_id, fixed_type )
	
	require "db/DB_Potentiality"
	local potentiality_info  = DB_Potentiality.getDataById(potentiality_id)
	local potentiality_cost = nil
	local costStr = potentiality_info["baprizeCost" .. fixed_type]
	potentiality_cost = string.split(tostring(costStr), ",")

	if(potentiality_cost == nil) then
		print(GetLocalizeStringBy("key_2110"))
		return false
	end
	local costTable = {}
	costTable.item  = {}
	local itemTableStr = string.split(potentiality_cost[1], "|")
	costTable.item.tid = itemTableStr[1]
	costTable.item.num = tonumber(itemTableStr[2])

	costTable.silver   = potentiality_cost[2]
	costTable.gold	   = potentiality_cost[3]
	return costTable
end


--[[
	@des:计算潜能上限
]]
function getPotentialityMax( potentiality_id, affix_id, item_info )
	-- 该装备的潜能价值上限=装备潜能价值初始+int（装备强化等级/潜能价值等级系数）*潜能价值上限系数
	-- 每条属性的数值的上限=该装备的潜能价值上限/该属性的价值
	-- 该属性价值在潜能表中取到
	local potentiality_worth = tonumber(item_info.itemDesc.baseValuePotentiality) + math.floor(tonumber(item_info.va_item_text.armReinforceLevel)/tonumber(item_info.itemDesc.levelRatioPotentiality)) * tonumber(item_info.itemDesc.growValuePotentiality)
	
	-- print("tonumber(item_info.itemDesc.baseValuePotentiality) =", tonumber(item_info.itemDesc.baseValuePotentiality))
	-- print("(tonumber(item_info.va_item_text.armReinforceLevel)", tonumber(item_info.va_item_text.armReinforceLevel))
	-- print("(tonumber(item_info.va_item_text.armReinforceLevel)", tonumber(item_info.itemDesc.levelRatioPotentiality))
	-- print("22222222222 =", math.floor(tonumber(item_info.va_item_text.armReinforceLevel)/tonumber(item_info.itemDesc.levelRatioPotentiality)))
	-- print("tonumber(item_info.itemDesc.growValuePotentiality =", tonumber(item_info.itemDesc.growValuePotentiality))
	-- print("fixedPotentialityID = ", item_info.itemDesc.fixedPotentialityID)
	-- print("potentiality_id = ", potentiality_id)
	-- print("potentiality_worth = ", potentiality_worth)
	potentiality_worth = math.floor(potentiality_worth)
	require "db/DB_Potentiality"
	local potentiality_info  = DB_Potentiality.getDataById(potentiality_id)
	-- print("potentiality_info")
	-- print_t(potentiality_info)
	local potentiality_value = 0
	for i=1,100 do
		if(potentiality_info["type" .. i] ~= nil and tonumber(potentiality_info["type" .. i])  == tonumber(affix_id)) then
			potentiality_value =tonumber( potentiality_info["value" .. i])
			break
		end
	end
	-- potentiality_value = potentiality_info["value" .. fixed_type]
	print("potentiality_value = ", potentiality_value)
	return math.floor(potentiality_worth/potentiality_value)
end


--[[
	@des:	检测是否满足洗练条件
]]
function checkFixedRefreshLogic( item_id, fixed_type, times)
	print("checkFixedRefreshLogic : = ", item_id)
	local fixedTimes= times or 1
	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo   == nil )then
        equipInfo   = ItemUtil.getEquipInfoFromHeroByItemId(item_id)
    end
    print()

    --可否是洗练装备
    if(tonumber(equipInfo.itemDesc.fixedPropertyRefreshable) == 0) then
    	 AnimationTip.showTip(GetLocalizeStringBy("key_1459"))
    	 return false
   	end
   	--是否满足vip 要求
   	if(getVipFixedAble(fixed_type) == false) then
   		 AnimationTip.showTip(GetLocalizeStringBy("key_3284"))
   		 return false
   	end
   	--检测是否有足够的物品和金钱用来洗练
   	local costTable = getFixedCost(equipInfo.itemDesc.fixedPotentialityID, fixed_type)
   	if(costTable.item.tid ~= nil) then
   		local itemNum = ItemUtil.getCacheItemNumBy(costTable.item.tid) 
   		if(itemNum == nil or itemNum < tonumber(costTable.item.num) * fixedTimes) then
   			AnimationTip.showTip(GetLocalizeStringBy("key_1532"))
   			return false
   		end
   	end
   	if(costTable.silver ~= nil) then
   		if(UserModel.getSilverNumber() < tonumber(costTable.silver) * fixedTimes) then
   			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
   			return false
   		end
   	end
   	if(costTable.gold ~= nil) then
   		if(UserModel.getGoldNumber() < tonumber(costTable.gold) * fixedTimes) then
   			AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
   			return false
   		end
   	end
    return true 
end

--[[
	@des:	得到剩余洗练石的数量
]]
function getFixedItemCount( ... )

	if(fixedStoneNum ~= nil) then
		return fixedStoneNum
	end

	require "db/DB_Potentiality"
	local potentiality_info  = nil
	for k,v in pairs(DB_Potentiality.Potentiality) do
		potentiality_info = v
		break
	end
	-- print("potentiality_info:")
	-- print_t(potentiality_info)
	local itemCost = getFixedCost(potentiality_info[1], 1)
	-- print("itemCost")
	-- print_t(itemCost)
	local resultNum = ItemUtil.getCacheItemNumBy(itemCost.item.tid)
	fixedStoneNum = resultNum
	return fixedStoneNum
end


--[[
	@des:	修改固定物品固定洗练潜能
]]
function modifyItemFixedPotentiality( item_id, potentiality_info )

	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo   ~= nil )then
        --背包
 		DataCache.setBagItemFixedPotentiality( item_id ,potentiality_info )
    else
    	--在武将身上
		HeroModel.setHeroFixedPotentiality( item_id ,potentiality_info )
    end
end


--[[
	@des: 修改物品洗练潜能
]]
function modifyItemPotentiality( item_id )
	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo   ~= nil )then
    	print("modifyItemPotentiality bag")
        --背包
        DataCache.setBagItemPotentiality( item_id )
    else
    	print("modifyItemPotentiality hero")
    	--在武将身上
		HeroModel.setHeroPotentiality( item_id )
    end
end


--[[
	@des: 得到物品洗练信息
	itemInfo：
	name:	
	level:
	isHaveFixed:
	fixedInfo{
		id:
		name:
		baseValue:
		potentiality:
		fixedPotentiality:
		maxFixed:
	}
]]
function getEquipFixedInfo( item_id, fixed_mode )
	print("getEquipFixedInfo item_id" .. item_id)
	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo == nil )then
        --背包
        equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( item_id )
    end

	local itemInfo = {}
	itemInfo.desc  = equipInfo.itemDesc
	itemInfo.name  = equipInfo.itemDesc.name
	itemInfo.level = equipInfo.va_item_text.armReinforceLevel
	if(equipInfo.va_item_text.armFixedPotence ~= nil) then
		itemInfo.isHaveFixed = true
	else
		itemInfo.isHaveFixed = false
	end
	require "script/model/affix/EquipAffixModel"
	local equipAffixInfo  = EquipAffixModel.getEquipAffixByEquipInfo(equipInfo)
	local developAffixInfo = EquipAffixModel.getDevelopAffixByInfo(equipInfo)
	local itemAffix = table.add(equipAffixInfo, developAffixInfo)

	itemInfo.fixedInfo = {}
	for k,v in pairs(equipInfo.itemDesc) do
		for i=1,6 do
			local strKey = potentialityConfig[i][2]
			local factor = potentialityConfig[i][3]
			local affixId = potentialityConfig[i][4]
			if(tonumber(equipInfo.itemDesc[tostring(strKey)]) > 0) then
				local itemValueKey   = potentialityConfig[i][1]
				if(itemInfo.fixedInfo[tostring(itemValueKey)] == nil) then
					itemInfo.fixedInfo[tostring(itemValueKey)] = {}
				end
				local baseValue	= tonumber(equipInfo.itemDesc[tostring(strKey)])
				local valuePl 	= tonumber(equipInfo.itemDesc[tostring(factor)])
				-- local value 	= baseValue + tonumber(itemInfo.level) * valuePl/100
				local value = itemAffix[affixId]
				
				itemInfo.fixedInfo[tostring(itemValueKey)].baseValue 	= value
				itemInfo.fixedInfo[tostring(itemValueKey)].name 		= getPotentNameById(potentialityConfig[i][1])
				itemInfo.fixedInfo[tostring(itemValueKey)].id   		= potentialityConfig[i][1]
				itemInfo.fixedInfo[tostring(itemValueKey)].maxFixed		= getPotentialityMax(equipInfo.itemDesc.fixedPotentialityID, potentialityConfig[i][1], equipInfo)
			end
		end
	end
	if(equipInfo.va_item_text.armPotence ~= nil) then
		for k,v in pairs(equipInfo.va_item_text.armPotence) do
			if(itemInfo.fixedInfo[tostring(k)] == nil) then
				itemInfo.fixedInfo[tostring(k)] = {}
			end
			itemInfo.fixedInfo[tostring(k)].potentiality = tonumber(v)
			itemInfo.fixedInfo[tostring(k)].name 		 = getPotentNameById(k)
			itemInfo.fixedInfo[tostring(k)].id   		 = k
			itemInfo.fixedInfo[tostring(k)].maxFixed	 = getPotentialityMax(equipInfo.itemDesc.fixedPotentialityID, k, equipInfo)
		end
	end

	if(equipInfo.va_item_text.armFixedPotence ~= nil) then
		for k,v in pairs(equipInfo.va_item_text.armFixedPotence) do
			if(itemInfo.fixedInfo[tostring(k)] == nil) then
				itemInfo.fixedInfo[tostring(k)] = {}
			end
			local potentialityValue  = (tonumber(v) or 0 )- (tonumber(itemInfo.fixedInfo[tostring(k)].potentiality) or 0)
			local potentialityString = tostring(potentialityValue)
			if(potentialityValue > 0) then
				potentialityString = "+" .. potentialityValue
			elseif(potentialityValue < 0) then
				potentialityString = potentialityValue
			end
			itemInfo.fixedInfo[tostring(k)].fixedPotentiality 	= potentialityString
			itemInfo.fixedInfo[tostring(k)].name 		 		= getPotentNameById(k)
			itemInfo.fixedInfo[tostring(k)].id   		 		= k
			itemInfo.fixedInfo[tostring(k)].maxFixed			= getPotentialityMax(equipInfo.itemDesc.fixedPotentialityID, k, equipInfo)
		end
	end	

	--排序
	local fixedTempInfo = {}
	for k,v in pairs(itemInfo.fixedInfo) do
		table.insert(fixedTempInfo, v)
	end

	-- print("fixedTempInfo")
	-- print_t(fixedTempInfo)

	table.sort( fixedTempInfo, function ( a,b )
		return tonumber(b.id) > tonumber(a.id)
	end )
	itemInfo.fixedInfo = fixedTempInfo
	-- print(GetLocalizeStringBy("key_2234"))
	-- print_t(itemInfo.fixedInfo[1])
	-- print_t(itemInfo.fixedInfo[2])
	return itemInfo
end

--[[
	@des:	得到潜能名称
]]
function getPotentNameById( potentiality_id )
	require "db/DB_Affix"
	local affixInfo = DB_Affix.getDataById(potentiality_id)
	return affixInfo.displayName
end

--[[
	@des:	潜能显示方式转换
]]
function potentialityDisplayTransform( potentiality_id, potentiality_value )
	require "db/DB_Affix"
	local affixInfo = DB_Affix.getDataById(potentiality_id)
	if(tonumber(affixInfo.type) == 1) then
		return "+" .. potentiality_value
	elseif(tonumber(affixInfo.type) == 2) then
		return "+" .. potentiality_value .. "/100"
	elseif(tonumber(affixInfo.type) == 3) then
		return "+" .. potentiality_value .. "/100%"
	else
		return "+" .. potentiality_value
	end
end

--[[
	@des:清楚装备的洗练信息
]]
function clearEquipFixedInfo( item_id )

	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
	if(equipInfo == nil )then
        --背包
        equipInfo = ItemUtil.getEquipInfoFromHeroByItemId( item_id )
    end
	print("item_id:", item_id)
	print("equipInfo:")
	print_t(equipInfo)

	equipInfo.va_item_text.armFixedPotence = nil


end



