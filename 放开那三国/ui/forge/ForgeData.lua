-- FileName: ForgeData.lua 
-- Author: licong 
-- Date: 14-6-12 
-- Purpose: 锻造数据处理层 


module("ForgeData", package.seeall)
require "script/ui/item/ItemUtil"

--- 
-- @des    :得到铸造配方数据
-- @param  :p_type  配方类型。0:非套装  1:套装 , p_quality合成装备品质
-- @return :该类型的所有配方
function getFoundryMethodByType( p_type, p_quality )
	local retTab = {}
	require "db/DB_Foundry_equipment"
	local tData = {}
	for k, v in pairs(DB_Foundry_equipment.Foundry_equipment) do
		table.insert(tData, v)
	end
	for k,v in pairs(tData) do
		if(tonumber(DB_Foundry_equipment.getDataById(v[1]).equipmentType) == p_type and tonumber(p_quality) == tonumber(DB_Foundry_equipment.getDataById(v[1]).orange_quality) )then
			-- 红装
			table.insert(retTab, DB_Foundry_equipment.getDataById(v[1]))
		else
		end
	end
	local function fnSortFun( a, b )
        return tonumber(a.id) < tonumber(b.id)
    end 
	table.sort( retTab, fnSortFun )
	for i=1,#retTab do
		retTab[i].index = i
	end
	return retTab
end

--- 
-- @des    :得到铸造显示的所有配方材料
-- @param  :p_MethoodData  配方数据
-- @return :
function getShowMethoodDataId( p_MethoodData )
	local listTab = {}
	local count = 0
	for i=1,#p_MethoodData do
		local itemId = string.split(p_MethoodData[i].materialId,",")
		for j=1,#itemId do
			local tab = {}
			tab.methoodId = tonumber(p_MethoodData[i].id)
			tab.needItemId = tonumber(itemId[j])
			count = count + 1
			tab.showIndex = count
			table.insert(listTab,tab)
		end
	end
	return listTab
end


--- 
-- @des    :得到铸造配方表数据
-- @param  :p_id  配方id
-- @return :该配方表数据
function getDBdataByMethoodId( p_id )
	require "db/DB_Foundry_equipment"
	local tData = DB_Foundry_equipment.getDataById(p_id)
	return tData
end

--- 
-- @des    :得到铸造配方需要的基础装备id数据
-- @param  :p_id  配方id
-- @return :基础id table
function getEquipIdByMethoodId( p_id )
	require "db/DB_Foundry_equipment"
	local tData = DB_Foundry_equipment.getDataById(p_id)
	local dataTab = string.split(tData.materialId,",")
	return dataTab
end

--- 
-- @des    :得到基础装备的具体消耗材料数据
-- @param  :p_id  配方id, p_srcId:基础装备id
-- @return :该配方的材料数据 {材料id，需要数量，拥有数量}
function getMaterialsByMethoodIdAndSrcId( p_id, p_srcId )
	require "db/DB_Foundry_equipment"
	local tData = DB_Foundry_equipment.getDataById(p_id)
	local srcIdTab = string.split(tData.materialId,",")
	local materialKey = 1
	for i=1,#srcIdTab do
		if(tonumber(p_srcId) == tonumber(srcIdTab[i]))then
			materialKey = i
			break
		end
	end
	local materialTab = string.split(tData["material" .. materialKey],",")
	local retTab = {}
	for k,v in pairs(materialTab) do
		local tab = {}
		local dataTab = string.split(v,"|")
		tab.tid = dataTab[1]
		tab.needNum = tonumber(dataTab[2])
		tab.haveNum = ItemUtil.getCacheItemNumBy(dataTab[1])
		table.insert(retTab,tab)
	end
	return retTab
end

--- 
-- @des    :可以铸造的个数
-- @param  :p_id  配方id,p_srcId:基础装备id
-- @return :可以铸造的个数  num
function getCanForgeNumByMethoodId( p_id, p_srcId )
	-- local retNum = 0
	local materialTab = getMaterialsByMethoodIdAndSrcId( p_id, p_srcId )
	local isCan = true
	for k,v in pairs(materialTab) do
		local haveNum = ItemUtil.getCacheItemNumBy(v.tid)
		if( haveNum < v.needNum )then
			isCan = false
			break
		end
	end
	-- while(isCan)do
	-- 	for k,v in pairs(materialTab) do
	-- 		if( v.haveNum - v.needNum < 0 )then
	-- 			isCan = false
	-- 			break
	-- 		else
	-- 			v.haveNum = v.haveNum - v.needNum
	-- 		end
	-- 	end
	-- 	if(isCan)then
	-- 		retNum = retNum + 1
	-- 	end
	-- end
	return isCan
end

--- 
-- @des    :得到锻造花费的数据
-- @param  :p_id  配方id, p_srcId:基础装备id
-- @return :(num1,num2) num1 花费类型,num2费用  货币类型：1魂玉，2金币，3银币
function getCostDataByMethoodId( p_id, p_srcId )
	local tData = getDBdataByMethoodId(p_id)
	local srcIdTab = string.split(tData.materialId,",")
	local materialKey = 1
	for i=1,#srcIdTab do
		if(tonumber(p_srcId) == tonumber(srcIdTab[i]))then
			materialKey = i
			break
		end
	end
	local dataTab = string.split(tData.materialCost,",")
	local costTab = string.split(dataTab[materialKey],"|")
	return tonumber(costTab[1]),tonumber(costTab[2])
end

--- 
-- @des    :得到锻造花费的是否足够
-- @param  :p_type类型，costNum花费  货币类型：1魂玉，2金币，3银币
-- @return :true够 false不够 
function isEnoughForForge( p_type, costNum )
	local ret = false
	if(p_type == 1 ) then
		-- 魂玉
        if(UserModel.getJewelNum() >= costNum )then
        	ret = true
        end
    elseif(p_type == 2 ) then
        -- 金币
      	if(UserModel.getGoldNumber() >= costNum )then
        	ret = true
        end
    elseif(p_type == 3 ) then
        -- 银币
        if(UserModel.getSilverNumber() >= costNum )then
        	ret = true
        end
    end
    return ret
end

--- 
-- @des    :扣除花费数据
-- @param  :p_type类型，costNum花费  货币类型：1魂玉，2金币，3银币
-- @return :
function deductForgeCost( p_type, costNum )
	if(p_type == 1 ) then
		-- 加魂玉
        UserModel.addJewelNum(-costNum)
    elseif(p_type == 2 ) then
        -- 加金币
        UserModel.addGoldNumber(-costNum)
    elseif(p_type == 3 ) then
        -- 加银币
        UserModel.addSilverNumber(-costNum)
    end
end

--------------------------------- 选择装备数据 ------------------
local _chooseListData 			= nil

--- 
-- @des    :设置选择的列表
-- @param  :p_list  选择的列表  是一个table
-- @return :
function setChooseListData( p_list )
	-- print("p_list")
	-- print_t(p_list)
	_chooseListData = p_list
end

--- 
-- @des    :得到选择的列表
-- @param  :
-- @return :得到选择的列表 {gid}
function getChooseListData()
	-- print("_chooseListData +++")
	-- print_t(_chooseListData)
	return _chooseListData
end

--- 
-- @des    :清空选择的列表
-- @param  :
-- @return :
function cleanChooseListData()
	_chooseListData = {}
end

-- 装备排序算法 （策划需求的 评分>强化等级）
function equipSort( equip_1, equip_2 )
	local isPre = false
	local t_equip_score_1 = tonumber(equip_1.itemDesc.base_score) + tonumber(equip_1.va_item_text.armReinforceLevel) * tonumber(equip_1.itemDesc.grow_score)
	local t_equip_score_2 = tonumber(equip_2.itemDesc.base_score) + tonumber(equip_2.va_item_text.armReinforceLevel) * tonumber(equip_2.itemDesc.grow_score)
	if(t_equip_score_1 < t_equip_score_2)then
		isPre = true
	elseif(t_equip_score_1 == t_equip_score_2 )then
		if( tonumber(equip_1.va_item_text.armReinforceLevel) < tonumber(equip_2.va_item_text.armReinforceLevel) )then
			isPre = true
		else
			isPre = false
		end
	else
		isPre = false
	end
	
	return isPre
end

------------------------ 一键兑换材料

--[[
	@des 	:得到材料积分
	@param 	: p_itemTid
	@return : 
]]
function getNeedPointByTid( p_itemTid )
	local retData = nil
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
    local dataArr = string.split(data.founding_materials_points,",")
    for i,v in ipairs(dataArr) do
    	local dataTab = string.split(v,"|")
    	if( tonumber(p_itemTid) == tonumber(dataTab[1]) )then
    		retData = tonumber(dataTab[2])
    		break
    	end
    end
    return retData
end

--[[
	@des 	: 得到需要兑换的材料
	@param 	: pMethoodId,pNeedItemTid
	@return : 
]]
function getNeedFragmentsArr( pMethoodId,pNeedItemTid )
	local fragments = ForgeData.getMaterialsByMethoodIdAndSrcId(pMethoodId,pNeedItemTid)
	local retTab = {}
	for i,v in ipairs(fragments) do
		if( v.haveNum < v.needNum )then
			local tab = {}
			tab.type = "item"
			tab.tid = v.tid
			tab.num = v.needNum - v.haveNum
			table.insert(retTab,tab)
		end
	end
	return retTab
end

--[[
	@des 	: 得到需要消耗的总积分
	@param 	: pNeedItemTab
	@return : 
]]
function getNeedAllPoint( pNeedItemTab )
	local retData = 0
	for i,v in ipairs(pNeedItemTab) do
		local data = getNeedPointByTid( v.tid )
		retData = retData + data*v.num
	end
	return retData
end



























