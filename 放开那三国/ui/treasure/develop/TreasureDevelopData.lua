-- FileName: TreasureDevelopData.lua 
-- Author: licong 
-- Date: 15/4/22 
-- Purpose: 宝物进阶数据


module("TreasureDevelopData", package.seeall)


--[[
	@des 	: 得到宝物进阶需要的英雄等级
	@param 	: p_developNum 进阶的次数 从0阶开始
	@return : num
--]]
function getDevelopNeedHeroLv( p_developNum )
	local retNum = 0
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local needLvTab = string.split(data.treasure_lv_limit, ",")
	for i=1,#needLvTab do
		if( tonumber(p_developNum) + 1 == i )then
			retNum = tonumber(needLvTab[i])
			break
		end
	end
	return retNum
end

--[[
	@des 	: 得到宝物进阶最大进阶阶数 	进阶的阶数 从0阶开始
	@param 	: p_itemTid 模板id
	@return : num 从0开始所有进阶数-1
--]]
function getDevelopMaxNum( p_itemTid )
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local needLvTab = string.split(data.treasure_lv_limit, ",")
	local retNum = table.count(needLvTab) - 1
	return retNum
end


--[[
	@des 	: 得到宝物进阶需要消耗的数据
	@param 	: p_developNum 进阶的次数 从0阶开始
	@return : table or nil
--]]
function getDevelopNeedCost(p_itemTid, p_developNum )
	local retNeed = nil
	local itemInfo = ItemUtil.getItemById(p_itemTid)
	if(p_developNum<=5)then
		needStr = itemInfo["up_cost_" .. ItemUtil.getRealEnvolLevel(p_developNum)]
	else
		needStr = itemInfo["up_cost2_" .. ItemUtil.getRealEnvolLevel(p_developNum-6)]
	end
	if( needStr == nil)then
		retNeed = nil
	else
		retNeed = ItemUtil.getItemsDataByStr(needStr)
	end
	return retNeed
end

--[[
	@des 	: 得到宝物进阶需要消耗的数据itemId
	@param 	: p_oldTab:原来属性组 p_newTab:新属性组
	@return : table {id=value}
--]]
function getDevelopAddAttrTab( p_oldTab, p_newTab )
	local retTab = {}
	if( p_newTab == nil)then
		return retTab
	end
	for n_id,n_v in pairs(p_newTab) do
		local isNew = true
		for o_id,o_v in pairs(p_oldTab) do
			if( tonumber(n_id) == tonumber(o_id) and tonumber(n_v) == tonumber(o_v) )then
				isNew = false
				break
			end
		end
		if(isNew)then
			retTab[n_id] = n_v
		end
	end
	return retTab
end


--[[
	@des 	: 得到宝物进阶增加的属性
	@param 	: p_developNum 进阶的次数 从0阶开始
	@return : table
--]]
function getDevelopAttrTab(p_itemTid, p_developNum )
	local retAdd = {}
	local itemInfo = ItemUtil.getItemById(p_itemTid)
	local addStr = nil
	if(p_developNum<6)then
		addStr = itemInfo["extra_affix_" .. p_developNum]
	else
		local num = p_developNum-6
		addStr = itemInfo["extra_affix2_" .. num]
	end
	
	if( addStr == nil)then
		retAdd = {}
	else
		local temp = string.split(addStr, "|")
		local affixInfo,dealNum,realNum = ItemUtil.getAtrrNameAndNum(temp[1],temp[2])
		local attrTab = {}
		attrTab.id = temp[1]
		attrTab.showNum = dealNum
		attrTab.realNum = realNum
		attrTab.name = affixInfo.sigleName
		table.insert(retAdd,attrTab)
	end
	return retAdd
end


--[[
	@des 	: 得到属性按id大小排列
	@param 	: p_table { 2=1,4=1,3=1 }
	@return : { {k=2,v=1} {k=3,v=1} {k=4,v=1} }
--]]
function getAttrSortTab( p_table )
	local retTab = {}
	for k,v in pairs(p_table) do
		local temp = {}
		temp.attrId = k
		temp.attrNum = v
		table.insert(retTab,temp)
	end

	local sortFun = function ( p_data1, p_data2 )
		return tonumber(p_data1.attrId) < tonumber(p_data2.attrId)
	end 
	table.sort(retTab,sortFun)
	return retTab
end







































