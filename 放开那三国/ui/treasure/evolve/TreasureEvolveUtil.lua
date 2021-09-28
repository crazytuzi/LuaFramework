-- Filename:TreasureEvolveUtil.lua
-- Author: 	lichenyang
-- Date: 	2014-1-7
-- Purpose: 宝物升级网络处理

module("TreasureEvolveUtil", package.seeall)

--[[
	@des:	判断宝物是否可以精炼
]]
function isUpgrade( treasure_id )
	-- print("treasure_id  is : ", treasure_id)
	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	print_t(treasureInfo)
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	if(tonumber(treasureInfo.itemDesc.isUpgrade) == 1) then
		return true
	else
		return false
	end
end

--[[
	@des:	得到旧属性
	@return:{
		name
		reinforceLeve
		evolveLevel
		affix{
			{
				id:
				name:
				num:
			}
			...
		}
		lockAffix{
			{
				id:
				name:
				level:
				num:
			}
			...
		}
	}
]]
function getOldAffix( treasure_id )
	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	if(treasureInfo.itemDesc == nil) then
		require "db/DB_Item_treasure"
		treasureInfo.itemDesc = DB_Item_treasure.getDataById(treasureInfo.item_template_id)
	end

	local resultTable 			= {}
	-- 橙色宝物换名字
	local nameStr = ItemUtil.getTreasureNameStrByItemInfo( treasureInfo )
	resultTable.name  			= nameStr
	resultTable.reinforceLeve  	= treasureInfo.va_item_text.treasureLevel
	resultTable.evolveLevel		= treasureInfo.va_item_text.treasureEvolve
	resultTable.quality 		= ItemUtil.getTreasureQualityByItemInfo( treasureInfo )
	
	local affixInfo 			= {}
	resultTable.affix 			= {}
	local treasureTable 		= string.split(treasureInfo.itemDesc.upgrade_affix, "|")
	affixInfo.id				= treasureTable[1]
	affixInfo.name				= getAffixNameById(treasureTable[1])
	affixInfo.num				= tonumber(treasureTable[2]) * tonumber(resultTable.evolveLevel)
	table.insert(resultTable.affix, affixInfo)

	local activeAffixTableA		= string.split(treasureInfo.itemDesc.upgrade_active_affix, ",")
	
	local tempActiveInfo 	= {}	-- 取到所有已激活的属性
	resultTable.lockAffix  	= {}	-- 没有解锁的属性
	for k,v in pairs(activeAffixTableA) do
		local activeAffixInfoTable 	= string.split(v, "|")
		local affix 		= {}
		affix.id 			= activeAffixInfoTable[2]
		affix.level 		= activeAffixInfoTable[1]
		affix.name 			= getAffixNameById(activeAffixInfoTable[2])
		affix.num			= activeAffixInfoTable[3]

		if(tonumber(affix.level) <= tonumber(resultTable.evolveLevel)) then
			--已解锁属性
			table.insert(tempActiveInfo, affix)
		else
			if(tonumber(affix.id) ~= tonumber(affixInfo.id)) then
				table.insert(resultTable.lockAffix, affix)
			end
		end
	end

	--将已经解锁的属性加到 基础属性中去
	for k,v in pairs(tempActiveInfo) do
		local isHave = false
		for x,y in pairs(resultTable.affix) do
			if(tonumber(v.id) == tonumber(y.id)) then
				isHave 					 = true
				resultTable.affix[x].num = tonumber(y.num) + v.num
			end
		end
		if(isHave == false) then
			table.insert(resultTable.affix, v)
		end
	end
	return resultTable
end


--[[
	@des:	得到比当前精炼等级高一级属性
	@retrun:{
		name
		reinforceLeve
		evolveLevel
		affix{
			{
				id:
				name:
				num:
				isNew:
			}
			...
		}
	}
]]
function getNewAffix( treasure_id )
	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	local resultTable 			= {}
	resultTable.reinforceLeve  	= treasureInfo.va_item_text.treasureLevel
	resultTable.evolveLevel		= tonumber(treasureInfo.va_item_text.treasureEvolve) + 1
	-- 橙色宝物换名字
	local nameStr = ItemUtil.getTreasureNameStrByItemInfo( treasureInfo )
	resultTable.name  			= nameStr
	resultTable.quality 		= ItemUtil.getTreasureQualityByItemInfo( treasureInfo )
	
	local affixInfo 			= {}
	resultTable.affix 			= {}
	local treasureTable 		= string.split(treasureInfo.itemDesc.upgrade_affix, "|")
	affixInfo.id				= treasureTable[1]
	affixInfo.name				= getAffixNameById(treasureTable[1])
	affixInfo.num				= tonumber(treasureTable[2]) * tonumber(resultTable.evolveLevel)
	table.insert(resultTable.affix, affixInfo)

	local lockAffix 			= {}
	local activeAffixTableA		= string.split(treasureInfo.itemDesc.upgrade_active_affix, ",")
	
	local tempActiveInfo = {}	-- 取到所有已激活的属性
	resultTable.lockAffix = {}	-- 没有解锁的属性
	for k,v in pairs(activeAffixTableA) do
		local activeAffixInfoTable 	= string.split(v, "|")
		local affix 		= {}
		affix.id 			= activeAffixInfoTable[2]
		affix.level 		= activeAffixInfoTable[1]
		affix.name 			= getAffixNameById(activeAffixInfoTable[2])
		affix.num			= activeAffixInfoTable[3]

		if(tonumber(affix.level) <= tonumber(resultTable.evolveLevel)) then
			--已解锁属性
			if(tonumber(affix.level) == tonumber(resultTable.evolveLevel)) then
				affix.isNew	= true
			else
				affix.isNew	= false
			end
			table.insert(tempActiveInfo, affix)
		else
			if(tonumber(affix.id) ~= tonumber(affixInfo.id)) then
				table.insert(resultTable.lockAffix, affix)
			end
		end
	end

	--将已经解锁的属性加到 基础属性中去
	for k,v in pairs(tempActiveInfo) do
		local isHave = false
		for x,y in pairs(resultTable.affix) do
			if(tonumber(v.id) == tonumber(y.id)) then
				isHave 					 = true
				resultTable.affix[x].num = tonumber(y.num) + v.num
			end
		end
		if(isHave == false) then
			table.insert(resultTable.affix, v)
		end
	end
	return resultTable
end

--[[
	@tparam: tparam{
		limitLv, 
		curWasterLv 
		item_temple_id
		affix{
		{
			{
				id:
				name:
				oldNum:
				newNum:
			 	isNew = true
		 	}
		 	...
		}
	}
]]

function getEvolveInfo( treasure_id, old_info, new_info )

	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	local resultTable 			= {}
	resultTable.limitLv  		= treasureInfo.itemDesc.max_upgrade_level
	resultTable.curWasterLv		= tonumber(treasureInfo.va_item_text.treasureEvolve)
	resultTable.item_temple_id  = treasureInfo.item_template_id
	resultTable.item_id  		= treasureInfo.item_id



	print("getEvolveInfo old:")
	print_t(old_info)
	print("getEvolveInfo new:")
	print_t(new_info)
	print(GetLocalizeStringBy("key_1110"))
	print_t(treasureInfo)
	resultTable.affix  = {}
	for k,v in pairs(new_info.affix) do
		local affix_info = {}
		affix_info.id 		= v.id
		affix_info.name 	= v.name
		affix_info.newNum	= v.num
		for k,old in pairs(old_info.affix) do
			if(tonumber(v.id) == tonumber(old.id)) then
				affix_info.oldNum = old.num
			end
		end
		if(affix_info.oldNum == nil) then
			affix_info.oldNum = 0
			affix_info.isNew  = true
		else
			affix_info.isNew  = false
		end
		table.insert(resultTable.affix, affix_info)
	end
	return resultTable
end


--[[
	@des:	得到精炼消耗
]]
function getUpgradeCost( treasure_id )
	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasureId))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasureId))
	end
end

--[[
	@des:	得到属性名称
]]
function getAffixNameById( affix_id )
	require "db/DB_Affix"
	local affixInfo = DB_Affix.getDataById(affix_id)
	return affixInfo.sigleName
end

--[[
	@des:	属性显示方式转换
]]
function AffixDisplayTransform( affix_id, affix_value )
	require "db/DB_Affix"
	local affixInfo = DB_Affix.getDataById(affix_id)
	if(tonumber(affixInfo.type) == 1) then
		return affix_value
	elseif(tonumber(affixInfo.type) == 2) then
		local displayNum = num / 100
		if(displayNum > math.floor(displayNum))then
			displayNum = string.format("%.1f", displayNum)
		end
		return displayNum
	elseif(tonumber(affixInfo.type) == 3) then
		return tonumber(affix_value)/100 .. "%"
	else
		return affix_value
	end
end


--[[
	@para:	
	@des:	得到宝物洗练的基础熟悉
	@return: 
]]
function getTreaEvolevBase( treasData , item_id)
	if(treasData.itemDesc.isUpgrade~= 1) then
		return
	end
	
	local treasureEvolve= 0
	if(tonumber(treasData.va_item_text.treasureEvolve)== 0 or treasData.va_item_text.treasureEvolve== nil) then
		treasureEvolve=0
	else
		treasureEvolve = tonumber(treasData.va_item_text.treasureEvolve)
	end
	local upgrade_affix= string.split(treasData.itemDesc.upgrade_affix, ",")
	print_t(upgrade_affix)
	local baseEvolveInfo= {}
	for i=1,#upgrade_affix do
		local affixInfo= string.split(upgrade_affix[i], "|")
		local baseNum = tonumber(affixInfo[2])*treasureEvolve
		if(treasureEvolve == 0) then
			baseNum = tonumber(affixInfo[2])
		end
		local affixDesc, displayNum, realNum= ItemUtil.getAtrrNameAndNum(tonumber(affixInfo[1]) , baseNum)
		-- print("affixDesc  is : ",  affixDesc.sigleName , "    displayNum is : ", displayNum)
		-- print("affixInfo[1]  is ", affixInfo[1], " baseNum is : ", baseNum)
		local tempBaseInfo= {}
		if(treasureEvolve == 0) then
			tempBaseInfo.desc = affixDesc.sigleName .. "+" .. displayNum  .. GetLocalizeStringBy("key_2355")
			tempBaseInfo.isOpen = false
		else
			tempBaseInfo.desc =  affixDesc.sigleName .. "+" .. displayNum 
			tempBaseInfo.isOpen = true

		end
		table.insert( baseEvolveInfo,tempBaseInfo)
	end	
	return baseEvolveInfo
end

--[[
	@des 	:	得到宝物精炼消耗
	@return	:	{
		silver:
		items:{
			{
				id: 物品id
				tid: 物品模板id
				num: 属性值
			}
			...
		}
	}
]]
function getEvolveCostInfo( treasure_id, evolve_level )
	local  treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	-- print("treasure_tid = ",treasure_tid)
	-- print("evolve_level = ",evolve_level)
	local resultInfo 		= {}
	require "db/DB_Item_treasure"
	local treasure_info 	= treasureInfo.itemDesc
	-- 计算消耗银币
	local cost_silver_table = string.split(treasure_info.cost_silver, ",")
	for k,v in pairs(cost_silver_table) do
		local silver_table = string.split(v, "|")
		if(tonumber(silver_table[1]) == tonumber(evolve_level)) then
			resultInfo.silver  = tonumber(silver_table[2])
			break
		end
	end
	--计算消耗的物品
	resultInfo.items = {}
	for i=1,3 do
		local cost_item_info = treasure_info["cost_item_" .. i]
		if(cost_item_info == nil or cost_item_info == 0) then
			break
		end
		local cost_table = string.split(cost_item_info, ",")
		for k,v in pairs(cost_table) do
			local item_table = string.split(v, "|")
			if(tonumber(item_table[1]) == tonumber(evolve_level)) then
				local item_info = {}
				item_info.tid 	= item_table[2]
				item_info.num 	= item_table[3]
				table.insert(resultInfo.items, item_info)
			end
		end
	end
	--设置消耗物品id
	for k,v in pairs(resultInfo.items) do
		local ids = getCostItemId(tonumber(v.tid), treasure_id, v.num)
		resultInfo.items[tonumber(k)].id = ids
	end
	printTable("resultInfo", resultInfo)
	return resultInfo
end

--[[
	@des:	通过模板id得到背包里面将要消耗的物品id
	@parm:	item_tid:消耗物品的模板id item_id:当前精炼的物品id
	@ret:	item_id
]]
function getCostItemId( item_tid, item_id, count )
	local num = 0
	local ids = {}
	local allBagInfo = DataCache.getRemoteBagInfo()
	local self_id = tonumber(item_id)

	if( not table.isEmpty(allBagInfo)) then
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_tid) then
					num = num + tonumber(item_info.item_num)
					table.insert(ids, item_info.item_id)
					if(tonumber(num) == tonumber(count)) then
						break
					end
				end
			end
		end
		if(not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_tid
					and tonumber(item_info.va_item_text.armReinforceLevel) == 0) then
					num = num + tonumber(item_info.item_num)
					table.insert(ids, item_info.item_id)
					if(tonumber(num) == tonumber(count)) then
						break
					end
				end
			end
		end

		if(not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_tid) then
					num = num + tonumber(item_info.item_num)
					table.insert(ids, item_info.item_id) 
					if(tonumber(num) == tonumber(count)) then
						break
					end
				end
			end
		end

		if(not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				--id相同
				if tonumber(item_info.item_template_id) == tonumber(item_tid) then
					--过滤自己
					if tonumber(item_info.item_id) ~= tonumber(self_id) then
						--白板物品
						if table.isEmpty(item_info.va_item_text) then
							num = num + tonumber(item_info.item_num)
							table.insert(ids, item_info.item_id) 
							if(tonumber(num) == tonumber(count)) then
								break
							end
						else
							if  (item_info.va_item_text.treasureEvolve == nil or tonumber(item_info.va_item_text.treasureEvolve) == 0)
							and (item_info.va_item_text.treasureLevel == nil or tonumber(item_info.va_item_text.treasureLevel) == 0) then
								num = num + tonumber(item_info.item_num)
								table.insert(ids, item_info.item_id) 
								if(tonumber(num) == tonumber(count)) then
									break
								end
							end
						end
					end
				end
			end
		end
	end
	return ids
end


--[[
	@des：得到消耗物品数量
]]
function getItemNumByTid( item_template_id, self_id )
	print(self_id)
	local item_num = 0
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(allBagInfo)) then
		if(item_num<=0 and not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				--id相同
				if tonumber(item_info.item_template_id) == tonumber(item_template_id) then
					--过滤自己
					if tonumber(item_info.item_id) ~= tonumber(self_id) then
						--白板物品
						if table.isEmpty(item_info.va_item_text) then
							item_num = item_num + tonumber(item_info.item_num)
						else
							if  (item_info.va_item_text.treasureEvolve == nil or tonumber(item_info.va_item_text.treasureEvolve) == 0)
							and (item_info.va_item_text.treasureLevel == nil or tonumber(item_info.va_item_text.treasureLevel) == 0) then
								item_num = item_num + tonumber(item_info.item_num)
								print("item_num = ", item_num)
							end
						end
					end
				end
			end
		end
	end
	return item_num
end




------------------------------------------[[修改装备属性]]--------------------------------------------------
--[[
	@des:	修改物品的精炼等级
	@parm:	treasure_id:物品id ,evolve_level:修改等级
	@ret:	void
]]

function setTreasureEvolve( treasure_id, evolve_level )
	local treasure_Info = ItemUtil.getItemInfoByItemId(treasure_id)
    if(treasure_Info   ~= nil )then
    	print("modifyItem treasure evolve bag")
        --背包
        DataCache.setTreasureEvolveLevel( treasure_id, evolve_level )
    else
    	print("modifyItem treasure evolve hero")
    	--在武将身上
		HeroModel.setTreasureEvolveLevel( treasure_id, evolve_level )
    end
end
