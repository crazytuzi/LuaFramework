-- FileName: DevelopSoulData.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂进阶数据


module("DevelopSoulData", package.seeall)

--[[
	@des 	: 得到战魂的表数据
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulDBDataByTid( p_tid )
	require "db/DB_Item_fightsoul"
	local data = DB_Item_fightsoul.getDataById(p_tid)
	return data
end

--[[
	@des 	: 得到战魂的可以进阶的等级
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulDevelopNeedLvByTid( p_tid )
	local data = getSoulDBDataByTid(p_tid)
	local retLv = tonumber(data.needSoreLevel) 
	return retLv
end

--[[
	@des 	: 得到战魂的可以进阶的新id
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulDevelopNewTid( p_tid )
	local data = getSoulDBDataByTid(p_tid)
	local retTid = tonumber(data.afteRevolveTid) 
	return retTid
end

--[[
	@des 	: 得到战魂的可以进阶消耗的材料
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulDevelopCostData( p_tid )
	local data = getSoulDBDataByTid(p_tid)
	local retData = nil 
	if(data.costItems ~= nil)then
		retData = ItemUtil.getItemsDataByStr(data.costItems)
	end
	return retData
end

--[[
	@des 	: 得到战魂的是否可以进阶
	@param 	: p_tid 模板id
	@return : 是否可以进化，需要的银币
--]]
function isCanDevelopSoul( p_tid, p_materialData )
	local materialData = nil
	if( not table.isEmpty( p_materialData ) )then 
		materialData = p_materialData
	else
		materialData = getSoulDevelopCostData(p_tid)
	end
	local retData = false 
	local needSilver = 0
	if( not table.isEmpty( materialData ) )then 
		local isCan = true
		for k,v in pairs(materialData) do
			if( v.type == "silver" )then
				local haveNum = UserModel.getSilverNumber()
				needSilver = v.num
				if( haveNum < v.num )then
					isCan = false
					break
				end
			else
				local haveNum = ItemUtil.getCacheItemNumBy(v.tid)
				if( haveNum < v.num )then
					isCan = false
					break
				end
			end
		end
		if( isCan == true )then
			retData = true 
		end	
	end
	return retData, needSilver
end

--[[
	@des 	: 得到战魂的可以进阶后的预算数据
	@param 	: p_itemInfo 
	@return :
--]]
function getSoulDevelopExpectData( p_itemInfo )
	local retData = table.hcopy(p_itemInfo, {})
	local newTid = getSoulDevelopNewTid( p_itemInfo.item_template_id )
	retData.item_template_id = newTid
	retData.itemDesc = getSoulDBDataByTid( retData.item_template_id )
	local newLv,_,_ = LevelUpUtil.getLvByExp(retData.itemDesc.upgradeID,retData.va_item_text.fsExp)
	retData.va_item_text.fsLevel = newLv

	return retData
end








