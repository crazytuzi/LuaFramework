-- FileName: FashionSuitData.lua 
-- Author: licong 
-- Date: 15/8/4 
-- Purpose: 时装套装数据 


module("FashionSuitData", package.seeall)

require "db/DB_Suit_dress"

local _haveDressInfo 			= nil
local _haveActivateSuitId 		= nil
local _haveDressSuitAttr 		= nil

--[[
	@des 	: 设置已有时装数据
	@param 	: 
	@return :
--]]
function setHaveDressInfo( p_info )
	_haveDressInfo = table.hcopy(p_info,{})
	print("_haveDressInfo")
	print_t(_haveDressInfo)
	-- 计算已激活的id
	_haveActivateSuitId = calculateHaveActivateSuitId()
	-- 计算已激活属性
	_haveDressSuitAttr = calculateHaveActivateSuitAttr()
	print("setHaveDressInfo") print_t(_haveDressSuitAttr)
end

--[[
	@des 	: 得到已有时装数据
	@param 	: 
	@return :
--]]
function getHaveDressInfo( ... )
	return _haveDressInfo 
end

--[[
	@des 	: 更新已有时装数据
	@param 	: p_tid 获得新时装tid
	@return :
--]]
function updateHaveDressInfoByTid( p_tid )
	if( p_tid == nil )then
		return
	end
	if( _haveDressInfo[tostring(p_tid)] ~= nil )then
		-- 已获得过 啥也不干
	else
		-- 添加
		_haveDressInfo[tostring(p_tid)] = 1
		-- 计算是否激活套装
		local dbData = ItemUtil.getItemById(p_tid)
		local isActivate = isActivateSuitById(dbData.suit_id)
		if(isActivate)then
			-- 添加激活套装id
			_haveActivateSuitId[dbData.suit_id] = 1

			-- 添加激活属性
			local attrTab = getSuitAttrById(dbData.suit_id)
			for id,num in pairs(attrTab) do
				if( _haveDressSuitAttr[id] == nil  )then
					_haveDressSuitAttr[id] = num
				else
					_haveDressSuitAttr[id] = _haveDressSuitAttr[id] + num
				end
			end

			print("updateHaveDressInfoByTid") print_t(_haveDressSuitAttr)
		end
	end
end

--[[
	@des 	: 是否已有时装数据
	@param 	: p_tid 时装tid
	@return : true or false
--]]
function isHaveDressByTid( p_tid )
	local retData = false
	if( _haveDressInfo[tostring(p_tid)] ~= nil )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 得到套装数据
	@param 	: p_id 套装id
	@return :
--]]
function getDBInfoById( p_id )
	local data = DB_Suit_dress.getDataById(p_id)
	return data
end

--[[
	@des 	: 得到套装组合tid
	@param 	: p_id 套装id
	@return : {tid1,tid2}
--]]
function getSuitItemsById( p_id )
	local data = getDBInfoById(p_id)
	local items = string.split(data.suit_items,",")
	return items
end

--[[
	@des 	: 得到套装属性
	@param 	: p_id 套装id
	@return : {id = value}
--]]
function getSuitAttrById( p_id )
	local retData = {}
	local data = getDBInfoById(p_id)
	local attr = string.split(data.suit_att,",")
	for k,v in pairs(attr) do
		local tem = string.split(v,"|")
		retData[tonumber(tem[1])] = tonumber(tem[2])
	end
	return retData
end

--[[
	@des 	: 得到所有套装数量
	@param 	: 
	@return :num
--]]
function getSuitAllNum()
	local num = table.count(DB_Suit_dress.Suit_dress)
	return num
end

--[[
	@des 	: 是否激活套装
	@param 	: p_id 套装id
	@return : true or false
--]]
function isActivateSuitById( p_id )
	local retData = false
	if(p_id == nil)then
		return retData
	end
	local needTids = getSuitItemsById(p_id)
	local isHave1 = isHaveDressByTid(needTids[1])
	local isHave2 = isHaveDressByTid(needTids[2])
	if( isHave1 and isHave2 )then
		retData = true
	end
	return retData
end

--[[
	@des 	: 计算所有激活套装的id
	@param 	: 
	@return :{id = value}
--]]
function calculateHaveActivateSuitId()
	local retData = {}
	for k,v in pairs(_haveDressInfo) do
		local dbData = ItemUtil.getItemById(k)
		local isActivate = isActivateSuitById(dbData.suit_id)
		if(isActivate)then
			retData[dbData.suit_id] = 1
		end
	end
	return retData
end

--[[
	@des 	: 计算所有激活套装的属性
	@param 	: 
	@return :{id = value}
--]]
function calculateHaveActivateSuitAttr()
	local retData = {}  
	for k,v in pairs( _haveActivateSuitId ) do
		local attrTab = getSuitAttrById(k)
		for id,num in pairs(attrTab) do
			if( retData[id] == nil  )then
				retData[id] = num
			else
				retData[id] = retData[id] + num
			end
		end
	end
	return retData
end

--[[
	@des 	: 得到所有套装激活的属性
	@param 	: 
	@return :{id = value}
--]]
function getHaveActivateSuitAttr()
	print("getHaveActivateSuitAttr")
	print_t(_haveDressSuitAttr)
	return _haveDressSuitAttr
end


