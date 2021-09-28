-- FileName: RuneData.lua 
-- Author: licong 
-- Date: 15/4/30 
-- Purpose: 符印数据


module("RuneData", package.seeall)
require "script/model/utils/HeroUtil"


--[[
	@des 	:得到所有的符印
	@param 	:
	@return :tab
--]]
function getAllRune()
	-- 符印
	local retData = {}
	local bagInfo = DataCache.getBagInfo()
	for k,v in pairs(bagInfo.rune) do
		table.insert(retData, v)
	end
	-- 阵上已镶嵌的
	local herosEquips = HeroUtil.getAllRuneOnHeros()
	for k,v in pairs(herosEquips) do
		table.insert(retData,v)
	end
	-- 宝物背包已镶嵌的
	local treasEquips = DataCache.getAllRuneInTreasureBag()
	for k,v in pairs(treasEquips) do
		table.insert(retData,v)
	end
	return retData
end

--[[
	@des 	:得到已拥有符印信息
	@param 	:p_item_id
	@return :tab
--]]
function getRuneInfoByItemId( p_item_id )
	local retData = nil
	local allRune = getAllRune()
	for k,v in pairs(allRune) do
		if( tonumber(v.item_id) == tonumber(p_item_id) )then
			retData = v
			break
		end
	end
	return retData
end

--[[
	@des 	:得到符印基础属性值
	@param 	: $p_item_templ_id 		:模板id
	@return :tab
--]]
function getRuneAbilityByTid(p_item_templ_id)
	-- 物品信息
	local itemInfo = ItemUtil.getItemById(p_item_templ_id)
	-- 属性
	local retTable = {}
	local attrStrTab = string.split(itemInfo.base_attr,",")
	for i=1,#attrStrTab do
		local tempTab = string.split(attrStrTab[i],"|")
		local affixInfo,dealNum,realNum = ItemUtil.getAtrrNameAndNum(tempTab[1],tempTab[2])
		local attrTab = {}
		attrTab.id = tempTab[1]
		attrTab.showNum = dealNum
		attrTab.realNum = realNum
		attrTab.name = affixInfo.sigleName
		table.insert(retTable,attrTab)
	end
	return retTable
end

--[[
	@des 	:得到符印属性值
	@param 	: $p_item_info 		:item_info
	@return :tab
--]]
function getRuneAbilityByItemInfo(p_item_info)
	local retTable = getRuneAbilityByTid(p_item_info.item_template_id)
	return retTable
end

--[[
	@des 	:得到符印属性值
	@param 	: $p_item_id 		:item_id
	@return :tab
--]]
function getRuneAbilityByItemId(p_item_id)
	-- 物品信息
	local itemInfo = getRuneInfoByItemId(p_item_id)
	-- 属性
	local retTable = getRuneAbilityByItemInfo(itemInfo)
	return retTable
end






















