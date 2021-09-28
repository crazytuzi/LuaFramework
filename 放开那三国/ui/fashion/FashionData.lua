-- Filename：	FashionData.lua
-- Author：		Li Pan
-- Date：		2014-2-11
-- Purpose：		时装

module("FashionData", package.seeall)

--是否穿，卸成功
local isSuccess = nil

------------------------- 时装强化 解析DB_Item_dress表 --------------------------------------
--  分解表中物品字符串数据
function analyzeStr( str )
    if(str == nil)then
        return
    end
    local needData = {}
    local strTab = string.split(str, ",")
    for k,v in pairs(strTab) do
        local data = {}
        local tab = string.split(v, "|")
        data.coin 		= tab[1]
        data.id   		= tab[2]
        data.num  		= tab[3]
        data.heroLv     = tab[4]
        needData[tostring(k)] 	= data
    end
    return needData
end

-- 存储每一级别所需的条件
function getNeedCondition( item_template_id, level )
	require "db/DB_Item_dress"
	local data = DB_Item_dress.getDataById(item_template_id)
	local needTab = analyzeStr(data.enforeCost)
	return needTab[tostring(level)]
end

-- 得到可以强化到的最大等级
function getMaxLvForEnhance( item_template_id )
	require "db/DB_Item_dress"
	local data = DB_Item_dress.getDataById(item_template_id)
	local needTab = analyzeStr(data.enforeCost)
	return table.count(needTab)
end


-- 解析战魂属性
--[[ 以属性id为key  属性值为value
	arr = {
		"1" = 10,
		"2" = 20,
	}
--]]
function getAttrIdAndValue( str_arr )
	local arrData = {}
	local arr_1 = string.split(str_arr, ",")
	for k,v in pairs(arr_1) do
		local arr_2 = string.split(v, "|")
		-- 以属性id为key  属性值为value
		arrData[arr_2[1]] = arr_2[2]
	end
	return arrData
end


--获得的基本属性
function getAttrByTemplateId( template_id )
	local tData = {}
	local itemData = ItemUtil.getItemById(template_id)
	-- 基础值
	local arr_1 = getAttrIdAndValue(itemData.baseAffix)
	-- 成长值
	local arr_2 = getAttrIdAndValue(itemData.growAffix)
	-- 合并
	for k1,v1 in pairs(arr_1) do
		for k2,v2 in pairs(arr_2) do
			if( tonumber(k1) == tonumber(k2) )then
				tData[k1] = {}
				tData[k1].baseData = tonumber(v1)
				tData[k1].growData = tonumber(v2)
			end
		end
	end
	return tData
end


-- 获得属性 key:属性 value: desc 描述,displayNum 数值
-- item_id: itemid
-- itemLv: 等级
function getAttrByItemData( itmeData, itemLv )
	local tData = {}
	local item_template_id = itmeData.item_template_id or itmeData.id
	local t_arrt = getAttrByTemplateId(item_template_id)
	for k,v in pairs(t_arrt) do
		-- 最终显示数值
		local fsLevel = tonumber(itemLv) or tonumber(itmeData.va_item_text.fsLevel) or 0
		local num = tonumber(v.baseData) + tonumber(v.growData) * fsLevel
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),num)
		tData[k] = {}
		tData[k].desc = affixDesc
		tData[k].realNum = num
		tData[k].displayNum = displayNum
		tData[k].growData = v.growData
	end
	return tData
end


































