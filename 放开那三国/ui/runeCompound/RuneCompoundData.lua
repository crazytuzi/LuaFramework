-- Filename: RuneCompoundData.lua
-- Author: zhangqiang
-- Date: 2016-07-26
-- Purpose: 符印合成数据

module("RuneCompoundData", package.seeall)
require "script/ui/runeCompound/RuneCompoundConst"
require "script/ui/runeCompound/RuneCompoundService"
require "script/network/PreRequest"
require "script/ui/item/ItemUtil"
require "db/DB_Fuyin_compose"

_tbHorseCompound = nil
_tbBookCompound  = nil

_bRequestWaiting = nil
_bPushWaiting = nil

--[[
	@desc  : 获取所有数据
	@param :
	@return: 
--]]
function load( ... )
	init()

	loadAllCompoundData()

	PreRequest.setBagDataChangedDelete(RuneCompoundData.dealWithBagPush)
end

--[[
	@desc  : 初始化数据
	@param :
	@return: 
--]]
function init( ... )
	_tbHorseCompound = {}
	_tbBookCompound  = {}

	_bRequestWaiting = false
	_bPushWaiting = false
end

function deinit( ... )
	PreRequest.setBagDataChangedDelete(nil)
end

function setRequestWaiting( pWaiting )
	_bRequestWaiting = pWaiting
end

function setPushWaiting( pWaiting )
	_bPushWaiting = pWaiting
end

function getRequestWaiting( ... )
	return _bRequestWaiting
end

function getPushWaiting( ... )
	return _bPushWaiting
end

function isRequestAvailable( ... )
	local bRequestWaiting, bPushWaiting = getRequestWaiting(), getPushWaiting()
	local bAvailable = true
	if bRequestWaiting or bPushWaiting then
		bAvailable = false
	end
	return bAvailable
end

--[[
	@desc  : 获取战马印合成数据
	@param :
	@return: 
--]]
function getHorseCompound( ... )
	return _tbHorseCompound
end

--[[
	@desc  : 获取兵书符合成数据
	@param :
	@return: 
--]]
function getBookCompound( ... )
	return _tbBookCompound
end

--[[
	@desc  : 解析单条数据
	@param : pDBItem 配置表DB_Fuyin_compose中的单条数据
	@return: 
--]]
function parseDB( pDBItem )
	local tbParse = {}

	tbParse.desc = pDBItem
	tbParse.product = parseItem(tbParse.desc.product)


	local tbAllCostItemParsed = lua_string_split(tbParse.desc.cost_item, ",")
	local tbAllCostItem = {}
	if not table.isEmpty(tbAllCostItemParsed) then
		for k, v in ipairs(tbAllCostItemParsed) do
			tbAllCostItem[k] = parseItem(v)
		end
	end
	tbParse.cost_item = tbAllCostItem


	return tbParse
end

--[[
	@desc  : 解析单个物品
	@param : pItemString "7|714005|1"
	@return: 
--]]
function parseItem( pItemString )
	local tbItem = {}
	local tbParse = lua_string_split(pItemString, "|")
	tbItem.type = tonumber(tbParse[1])
	tbItem.tid  = tonumber(tbParse[2])
	tbItem.needNum = tonumber(tbParse[3])
	tbItem.hasNum = ItemUtil.getCacheItemNumBy(tbItem.tid)

	return tbItem
end

--[[
	@desc  : 解析单个物品,并将配方分类
	@param : pItemString "7|714005|1"
	@return: 
--]]
function loadAllCompoundData( ... )
	for k, v in pairs(DB_Fuyin_compose.Fuyin_compose) do
		local tbOne = DB_Fuyin_compose.getDataById(v[1])
		local tbParse = parseDB(tbOne)
		if tbOne.type == RuneCompoundConst.RuneCompoundType.kHorseRuneType then
			table.insert(_tbHorseCompound, tbParse)
		elseif tbOne.type == RuneCompoundConst.RuneCompoundType.kBookRuneType then
			table.insert(_tbBookCompound, tbParse)
		else
			print("RuneCompoundData loadAllCompoundData type: ", tbOne.type)
		end
	end

	table.sort(_tbHorseCompound, RuneCompoundData.sortCompoundData)
	table.sort(_tbBookCompound, RuneCompoundData.sortCompoundData)
end

function sortCompoundData( pData1, pData2 )
	return pData1.desc.id < pData2.desc.id
end

--[[
	@desc  : 根据合成方法id，获取合成数据
	@param : 
	@return: tbRet: nil 或 合成方法数据
--]]
function getCompoundDataById( pMethodId )
	local tbRet = nil
	if pMethodId == nil then
		return tbRet
	end
	local nMethodId = tonumber(pMethodId)

	if tbRet == nil then
		for k, v in ipairs(_tbHorseCompound) do
			if v.desc ~= nil and v.desc.id == nMethodId then
				tbRet = v
				break
			end
		end
	end

	if tbRet == nil then
		for k, v in ipairs(_tbBookCompound) do
			if v.desc ~= nil and v.desc.id == nMethodId then
				tbRet = v
				break
			end
		end
	end

	return tbRet
end

--[[
	@desc  : 更新所有生成物品的剩余数量
	@param : 
	@return: 
--]]
function updateProductItemNum( ... )
	--更新战马印合成配方中的生成物品数量
	if not table.isEmpty(_tbHorseCompound) then
		for nPageIdx, tbPageData in ipairs(_tbHorseCompound) do
			tbPageData.product.hasNum = ItemUtil.getCacheItemNumBy(tbPageData.product.tid)
		end
	end

	--更新兵书符合成配方中的生成物品数量
	if not table.isEmpty(_tbBookCompound) then
		for nPageIdx, tbPageData in ipairs(_tbBookCompound) do
			tbPageData.product.hasNum = ItemUtil.getCacheItemNumBy(tbPageData.product.tid)
		end
	end
end

--[[
	@desc  : 更新所有材料的剩余数量
	@param : 
	@return: 
--]]
function updateCostItemNum( ... )
	--更新战马印合成配方中的材料数量
	if not table.isEmpty(_tbHorseCompound) then
		for nPageIdx, tbPageData in ipairs(_tbHorseCompound) do
			for nIdx, tbCost in ipairs(tbPageData.cost_item) do
				tbCost.hasNum = ItemUtil.getCacheItemNumBy(tbCost.tid)
			end
		end
	end

	--更新兵书符合成配方中的材料数量
	if not table.isEmpty(_tbBookCompound) then
		for nPageIdx, tbPageData in ipairs(_tbBookCompound) do
			for nIdx, tbCost in ipairs(tbPageData.cost_item) do
				tbCost.hasNum = ItemUtil.getCacheItemNumBy(tbCost.tid)
			end
		end
	end
end

--[[
	@desc  : 获取指定菜单索引pMenuItemIdx下的所有页面数据
	@param : 
	@return: 
--]]
function getAllPageByMenuIdx( pMenuItemIdx )
	local tbAllPage = {}
	if pMenuItemIdx == nil then
		return tbAllPage
	end

	-- 战马印
	if pMenuItemIdx == RuneCompoundConst.MenuItemIdx.kHorseRuneIdx then
		tbAllPage = getHorseCompound()
		return tbAllPage
	end

	-- 兵书符
	if pMenuItemIdx == RuneCompoundConst.MenuItemIdx.kBookRuneIdx then
		tbAllPage = getBookCompound()
		return tbAllPage
	end

	return tbAllPage
end

--[[
	@desc  : 获取指定菜单索引pMenuItemIdx,和页码pPageIdx下的页面数据
	@param : 
	@return: 
--]]
function getPageByMenuIdxAndPageIdx( pMenuItemIdx, pPageIdx )
	local tbAllPage = getAllPageByMenuIdx(pMenuItemIdx)
	if table.isEmpty(tbAllPage) then
		return nil
	end

	if pPageIdx == nil then
		return nil
	end

	local tbPage = tbAllPage[tonumber(pPageIdx)]

	return tbPage
end

--[[
	@desc  : 判断是否满足符印配方合成条件
	@param : 
	@return: 
--]]
function canRuneCompound( pMenuItemIdx, pPageIdx, pSortBagCb )
	local tbPageData = getPageByMenuIdxAndPageIdx(pMenuItemIdx, pPageIdx)
	local nRet, sDesc = canRuneCompoundByPageData(tbPageData, pSortBagCb)

	return nRet, sDesc
end

function canRuneCompoundByPageData( pPageData, pSortBagCb )
	local nRet, sDesc = 0, ""

	local tbPageData = pPageData

	--是否能获取到页面数据
	if table.isEmpty(tbPageData) then
		nRet, sDesc = 1, GetLocalizeStringBy("zq_0026")   --请先选择有效的合成配方
		return nRet, sDesc
	end

	--材料是否足够
	local bEnough = true
	if not table.isEmpty(tbPageData.cost_item) then
		for k, v in ipairs(tbPageData.cost_item) do
			if v.needNum > v.hasNum then
				bEnough = false
				break
			end
		end
	end
	if not bEnough then
		nRet, sDesc = 2, GetLocalizeStringBy("zq_0025")   --材料不足，无法合成
		return nRet, sDesc
	end

	--是背包是否已满
	if ItemUtil.isBagFull(false, pSortBagCb) then
		nRet, sDesc = 3, GetLocalizeStringBy("zq_0016")   --"背包已满"
		return nRet, sDesc
	end

	--是否可再次发送网络请求
	local bRequestAvailable = isRequestAvailable()
	if not bRequestAvailable then
		nRet, sDesc = 4, GetLocalizeStringBy("zq_0027")          --“正在处理上一次请求”
		return nRet, sDesc
	end

	return nRet, sDesc
end

function getCostItemIds( pPageData )
	local tbCostItems = pPageData.cost_item
	local tbCostItemIds = {}
	if table.isEmpty(tbCostItems) then
		return tbCostItemIds
	end

	for k, v in ipairs(tbCostItems) do
		local tbItems = ItemUtil.getItemsByNum(v.tid, v.needNum)
		for nIdx, tbItem in ipairs(tbItems) do
			table.insert(tbCostItemIds, tonumber(tbItem.item_id))
		end
	end
	-- print("RuneCompoundData getCostItemIds tbCostItemIds =====================")
	-- print_t(tbCostItemIds)

	return tbCostItemIds
end

---------------------------背包推送处理--------------------------
--[[
	@desc  : 处理背包推送
	@param : 
	@return: 
--]]
function dealWithBagPush( ... )
	updateProductItemNum()
	--更新所有材料的数量（不同配方中可能消耗同样的材料）
	updateCostItemNum()

	--将推送等待状态置为false
	setPushWaiting(false)

	--发送推送消息
	if RuneCompoundCtrl ~= nil and RuneCompoundCtrl.dispatchEvent ~= nil then
		local tbEvent = {name=RuneCompoundConst.EventName.RUNE_COMPOUND_COST_ITEM_PUSH, data={}}
		RuneCompoundCtrl.dispatchEvent(tbEvent)
	end
end


----------------------------网络请求------------------------------
function sendComposeRune( pMenuItemIdx, pPageIdx, pSortBagCb )
	local tbPageData = getPageByMenuIdxAndPageIdx(pMenuItemIdx, pPageIdx)
	local nRet, sDesc = canRuneCompoundByPageData(tbPageData, pSortBagCb)
	if nRet ~= 0 then
		return nRet, sDesc
	end

	local nMethodId = tbPageData.desc.id
	local tbMatIds = getCostItemIds(tbPageData)
	
	RuneCompoundService.composeRune(nMethodId, tbMatIds, RuneCompoundData.composeRuneCallback)

	return nRet, sDesc
end

function composeRuneCallback( pDictData )
	local tbArgs = pDictData.tbArgs
	local nMethodId = tonumber(tbArgs[1])

	
	if RuneCompoundCtrl ~= nil and RuneCompoundCtrl.dispatchEvent ~= nil then
		local tbData = {}
		tbData.nMethodId = nMethodId

		local tbEvent = {name=RuneCompoundConst.EventName.RUNE_COMPOUND_SUCCESS, data=tbData}
		RuneCompoundCtrl.dispatchEvent(tbEvent)
	end
end