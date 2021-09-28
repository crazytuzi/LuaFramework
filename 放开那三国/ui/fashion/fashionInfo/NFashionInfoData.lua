-- Filename: NFashionInfoData.lua
-- Author: zhangqiang
-- Date: 2016-05-30
-- Purpose: 时装数据信息

module("NFashionInfoData", package.seeall)

_kFashionInfoOnly = 1       --只有一个关闭按钮
_kFashionInfoOperation = 2  --包含强化、关闭功能，当时装在英雄身上时，还包含卸下功能
_kFashionInfoManual  = 3    --人为控制底部按钮显示状态



local _tbFashionInfo = nil
local _tbFashionAttr = nil
local _nShowType     = nil

--当 _nShowType = _kFashionInfoManual 模式下，下面的状态才起作用
local _bChangeShow = nil
local _bUnequipShow = nil
local _bStrengthenShow = nil
local _bCloseShow = nil

--[[
	desc: 初始化
	param:
	return:
--]]
function init( ... )
	_tbFashionInfo = nil
	_tbFashionAttr = nil
	_nShowType     = _kFashionInfoOnly

	_bChangeShow = false
	_bUnequipShow = false
	_bStrengthenShow = false
	_bCloseShow = false
end

--[[
	desc: 释放
	param:
	return:
--]]
function deinit( ... )
	
end

--[[
	desc: 获取时装信息
	param:
	return:
--]]
function getFashionInfo( ... )
	return _tbFashionInfo
end

--[[
	desc: 设置时装信息
	param:
	return:
--]]
function setFashionInfo( pFashionInfo )
	_tbFashionInfo = pFashionInfo

	--更新属性缓存
	updateFashionAttr()
	
	if not table.isEmpty(_tbFashionInfo) then
		printTable("_tbFashionInfo", _tbFashionInfo)
	end
end

--[[
	desc: 获取时装信息面板类型
	param:
	return:
--]]
function getShowType( ... )
	local nShowType = _nShowType or _kFashionInfoOnly
	return nShowType
end

--[[
	desc: 设置时装信息面板类型
	param:
	return:
--]]
function setShowType( pShowType )
	_nShowType = pShowType
end

function setChangeShow( pShow )
	_bChangeShow = pShow == nil and false or pShow
end

function getChangeShow( ... )
	return _bChangeShow
end

function setUnequipShow( pShow )
	_bUnequipShow = pShow == nil and false or pShow
end

function getUnequipShow( ... )
	return _bUnequipShow
end

function setStrengthenShow( pShow )
	_bStrengthenShow = pShow == nil and false or pShow
end

function getStrengthenShow( ... )
	return _bStrengthenShow
end

function setCloseShow( pShow )
	_bCloseShow = pShow == nil and false or pShow
end

function getCloseShow( ... )
	return _bCloseShow
end

--[[
	desc: 设置时装信息
	param:
	return:
--]]
function setFashionInfoById( pFashionId )
	local tbFashion = getFashionById(pFashionId)
	setFashionInfo(tbFashion)
end

--[[
	desc: 根据时装id, 获取时装信息
	param:
	return:
--]]
function getFashionById( pFashionId )
	local tbFashion = nil, false
	if pFashionId == nil then
		return tbFashion
	end

	local nFashionId = tonumber(pFashionId)
	if(nFashionId)then
		tbFashion = ItemUtil.getItemInfoByItemId(nFashionId)
		if( tbFashion == nil )then
			-- 背包中没有 检查英雄身上
			tbFashion = ItemUtil.getFashionFromHeroByItemId(nFashionId)
			if( not table.isEmpty(tbFashion))then
				require "db/DB_Item_dress"
				tbFashion.itemDesc = DB_Item_dress.getDataById(tbFashion.item_template_id)
			end
		end
 	end

 	return tbFashion
end

--[[
	desc: 根据时装tid, 构造时装信息
	param:
	return:
--]]
function constructFashionByTid( pFashionTid )
	if pFashionTid == nil then
		return
	end

	local tbFashion = {}
	tbFashion.item_num = 1
	tbFashion.fashion_hid = nil
	tbFashion.item_template_id = tonumber(pFashionTid)
	tbFashion.item_id = nil
	tbFashion.hid = nil
	tbFashion.pos = nil   --"1"

	require "db/DB_Item_dress"
	tbFashion.itemDesc = DB_Item_dress.getDataById(tbFashion.item_template_id)

	local tbText = {}
	tbFashion.va_item_text = tbText
	tbText.dressLevel = 0

	return tbFashion
end

--[[
	desc: 根据时装tid, 获取时装信息
	param:
	return:
--]]
function setFashionInfoByTid( pFashionTid )
	local tbFashionInfo = constructFashionByTid(pFashionTid)
	setFashionInfo(tbFashionInfo)
end

--[[
	desc: 时装是否再英雄身上
	param:
	return:
--]]
function isOnHero( ... )
	local tbFashion = getFashionInfo()
	local bOnHero = false
	if not table.isEmpty(tbFashion) and tbFashion.hid ~= nil and tonumber(tbFashion.hid) > 0 then
		bOnHero = true
	end

	return bOnHero
end

--[[
	desc: 获取时装基础信息
	param:
	return:
--]]
function getFashionBaseInfo( ... )
	local tbFashion = getFashionInfo()
	if table.isEmpty(tbFashion) then
		return nil
	end
	local nFashionTid = tbFashion.item_template_id

	local tbBase = {}
	tbBase.icon_big   = "images/base/fashion/big/" .. FashionLayer.getIconPath(nFashionTid,"icon_big")   --图标
	tbBase.name       = FashionLayer.getIconPath(nFashionTid, "name")      --名字
	tbBase.quality    = tonumber(tbFashion.itemDesc.quality)               --星级
	tbBase.score      = tonumber(tbFashion.itemDesc.score)                 --品级
	tbBase.dressLevel = tonumber(tbFashion.va_item_text.dressLevel)        --强化等级

	return tbBase
end

--[[
	desc: 更新时装属性
	param:
	return:
--]]
function updateFashionAttr( ... )
	local tbFashion = getFashionInfo()
	if table.isEmpty(tbFashion) then
		return
	end

	local tbAttr = FashionData.getAttrByItemData(tbFashion, tbFashion.va_item_text.dressLevel)
	printTable("updateFashionAttr tbAttr", tbAttr)

	_tbFashionAttr = tbAttr
end

--[[
	desc: 获取时装属性(字典)
	param:
	return:
--]]
function getFashionAttr( ... )
	return _tbFashionAttr
end

--[[
	desc: 获取当前时装属性（数组）
	param:
	return:
--]]
function getFashionCurAttr( ... )
	local tbAttr = getFashionAttr()
	if table.isEmpty(tbAttr) then
		return
	end

	local tbCur = {}
	for k, v in pairs(tbAttr) do
		table.insert(tbCur, v)
	end

	return tbCur
end

--[[
	desc: 获取时装强化成长属性显示信息（数组）
	param:
	return:
--]]
function getFashionStrenghtenIncrement( ... )
	local tbAttr = getFashionCurAttr()
	if table.isEmpty(tbAttr) then
		return
	end

	local tbIncrement = {}
	for k, v in ipairs(tbAttr) do
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(v.desc.id), v.growData)

		local tbTemp = {}
		tbTemp.desc = affixDesc    --DB_Affix 表数据
		tbTemp.displayNum = displayNum

		tbIncrement[k] = tbTemp
	end


	return tbIncrement
end

--[[
	desc: 获取时装天赋解锁信息
	param:
	return:
--]]
function getFashionTalent( ... )
	local tbFashion = getFashionInfo()
	if table.isEmpty(tbFashion) then
		return
	end

	local tbRet = {}
	local tbAllTalent = lua_string_split(tbFashion.itemDesc.extra_attr, ",")
	for i, sTalent in ipairs(tbAllTalent) do
		--"等级｜属性id｜属性值"
		local tbTalent = lua_string_split(sTalent, "|")
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(tbTalent[2]), tonumber(tbTalent[3]))

		local tbTemp = {}
		tbTemp.unlockLevel = tonumber(tbTalent[1])   --解锁等级
		tbTemp.displayNum = displayNum               --用于显示的数字
		tbTemp.desc = affixDesc                      --属性配置

		table.insert(tbRet, tbTemp)
	end

	return tbRet
end

--[[
	desc: 获取时装等级
	param:
	return:
--]]
function getFashionStrengthenLevel( ... )
	local tbFashionInfo = getFashionInfo()
	local nLevel = 0
	if not table.isEmpty(tbFashionInfo) and tbFashionInfo.va_item_text ~= nil and tbFashionInfo.va_item_text.dressLevel then
		nLevel = tonumber(tbFashionInfo.va_item_text.dressLevel)
	end

	return nLevel
end

--[[
	desc: 获取时装简介信息
	param:
	return:
--]]
function getFashionBrief( ... )
	local tbFashion = getFashionInfo()
	if table.isEmpty(tbFashion) then
		return ""
	end
	
	local sDesc = FashionLayer.getIconPath(tbFashion.item_template_id, "info")

	return sDesc
end