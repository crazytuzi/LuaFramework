-- FileName: SoulRebornData.lua 
-- Author: licong 
-- Date: 15/9/24 
-- Purpose: 战魂重生数据 


module("SoulRebornData", package.seeall)

local _haveRebornNum 			= 0

--[[
	@des 	:获得可以重生配置表
	@param 	:
	@return :
--]]
function getRebornConfig()
	local configData = ActivityConfigUtil.getDataByKey("fsReborn").data[1]
	return configData
end

--[[
	@des 	:获得重生开始时间
	@param 	:
	@return :
--]]
function getRebornStartTime()
	local data = ActivityConfigUtil.getDataByKey("fsReborn")
	return tonumber(data.start_time)
end

--[[
	@des 	:获得重生结束时间
	@param 	:
	@return :
--]]
function getRebornEndTime()
	local data = ActivityConfigUtil.getDataByKey("fsReborn")
	return tonumber(data.end_time)
end

--[[
	@des 	:获得可以重生的次数
	@param 	:
	@return :
--]]
function getRebornAllNum()
	local data = getRebornConfig()
	local numStr = string.split(data.vip_times,",")
	local curVip = UserModel.getVipLevel()
	local retData = 0
	for i=1,#numStr do
		local tem = string.split(numStr[i],"|")
		if( curVip == tonumber(tem[1]) )then
			retData = tonumber(tem[2])
			break
		end
	end
	return retData
end

--[[
	@des 	:设置已经重生的次数
	@param 	:
	@return :
--]]
function setHaveRebornNum( p_num )
	_haveRebornNum = tonumber(p_num)
end

--[[
	@des 	:获得已经重生的次数
	@param 	:
	@return :
--]]
function getHaveRebornNum()
	return _haveRebornNum
end

-------------------------------------------------- 选择战魂 ----------------------------------------------------
local _seletList = {}  -- 已经选择的材料

--[[
	@des 	:获得选择列表数据
	@param 	:列表中只显示紫色战魂并且大于1级的战魂，并且该战魂未装备在任何武将身上
	@return :
--]]
function getCanRebornSoul()
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	for k,v in pairs(bagInfo.fightSoul) do
		if(  not table.isEmpty(v.va_item_text) and v.va_item_text.fsLevel and tonumber(v.va_item_text.fsLevel) > 1
			and tonumber(v.itemDesc.quality) == 5 )then
			table.insert(retTab, v)
		end
	end
	table.sort( retTab, BagUtil.fightSoulSort )
	return retTab
end


--[[
	@des 	:清除选择列表
	@param 	:
	@return :
--]]
function cleanSelectList()
	_seletList = {}
end

--[[
	@des 	:获得已经选择的列表
	@param 	:
	@return :
--]]
function getSelectList()
	return _seletList
end

--[[
	@des 	:设置已经选择的列表
	@param 	:
	@return :
--]]
function setSelectList( p_list )
	_seletList = p_list
end

--[[
	@des 	:往选择列表里添加材料 已选择列表有该材料就删除该材料
	@param 	:p_itemId
	@return :
--]]
function addItemToSelectList( p_itemId )
	local isIn = false
	local pos = 0
	for k,v in pairs(_seletList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			pos = k
			break
		end
	end
	if(isIn)then
		table.remove(_seletList,pos)
	else
		local tab = {}
		tab.item_id = p_itemId
		table.insert(_seletList,tab)
	end
end

--[[
	@des 	:判断列表里是否有这个神兵
	@param 	:p_itemId:材料id
	@return :
--]]
function getIsInSelectListByItemId( p_itemId )
	local isIn = false
	for k,v in pairs(_seletList) do
		if(tonumber(v.item_id) == tonumber(p_itemId))then
			isIn = true
			break
		end
	end
	return isIn
end

--[[
	@des 	:得到选择的itemid
	@param 	:
	@return :
--]]
function getChooseItemId()
	local retItemId = nil
	if( not table.isEmpty(_seletList) )then 
		retItemId = tonumber( _seletList[1].item_id )
	end
	return retItemId
end



