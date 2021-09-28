-- FileName: EvolveSoulData.lua 
-- Author: licong 
-- Date: 15/8/31 
-- Purpose: 战魂精炼数据


module("EvolveSoulData", package.seeall)

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
	@des 	: 得到战魂可以精炼的最大等级
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulEvolveMaxLvByTid( p_tid )
	local data = getSoulDBDataByTid(p_tid)
	local maxLv = tonumber(data.upgrade_level)
	return maxLv
end

--[[
	@des 	: 得到战魂属性成长百分比
	@param 	: p_tid 模板id
	@return :
--]]
function getEvolveAttrByItemInfo( p_tid, p_curEvolveLv )
	local data = getSoulDBDataByTid(p_tid)
	local retData = tonumber(data.upgrade_affix)/100*p_curEvolveLv
	return retData
end

--[[
	@des 	: 得到战魂精炼消耗的材料
	@param 	: p_tid 模板id
	@return :
--]]
function getSoulEvolveCostData( p_tid, p_evolveLv )
	local data = getSoulDBDataByTid(p_tid)
	local retData = nil 
	if(data.upgrade_cost ~= nil)then
		local materialTab = {}
		local temp1 = string.split(data.upgrade_cost,",")
		for k,v in pairs(temp1) do
			local temp2 = string.split(v,"|")
			if(tonumber(temp2[1]) == tonumber(p_evolveLv) )then
				local tab = {}
				tab.type = temp2[2]
		        tab.id   = temp2[3]
		        tab.num  = temp2[4]
		        table.insert(materialTab,tab)
			end
		end
		if( not table.isEmpty(materialTab) )then
			retData = ItemUtil.getItemsDataByStr(nil,materialTab)
		end
	end
	return retData
end

--[[
	@des 	: 得到战魂的是否可以精炼
	@param 	: p_tid 模板id
	@return : 是否可以进化，需要的银币
--]]
function isCanEvolveSoul( p_tid, p_evolveLv, p_materialData )
	local materialData = nil
	if( not table.isEmpty( p_materialData ) )then 
		materialData = p_materialData
	else
		materialData = getSoulEvolveCostData( p_tid, p_evolveLv )
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
	@des:得到精炼等级图标
	@ret:sprite
--]]
function getEvolveLvSprite( pEvolveLv )
	local icons = {
		[-1] = "images/common/fs_j.png",
		[0] = "images/common/fs_j.png",
		[1] = "images/hunt/effect/huntsouljl/huntsouljl"
	}
	local level = math.floor(tonumber(pEvolveLv-1)/10) 
	local path = icons[level]
	local sprite = XMLSprite:create(path)
	print("itemLevel", pEvolveLv)
	print("path", path)
	return sprite
end



