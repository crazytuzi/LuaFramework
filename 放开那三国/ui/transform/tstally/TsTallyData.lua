-- FileName: TsTallyData.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换数据处理中心

module("TsTallyData", package.seeall)

require "db/DB_Normal_config"
require "db/DB_Item_bingfu"

local _selectTallyList = {} -- 已经选择的兵符

local dbNormalCfg = DB_Normal_config.getDataById(1)

--[[
	@desc	: 获得功能开启等级
    @param	: 
    @return	: number 开启等级
—-]]
function getOpenNeedLv()
	return tonumber(dbNormalCfg.openChangebingfu)
end

--[[
	@desc	: 是否开启功能
    @param	: 
    @return	: bool 是否开启
—-]]
function isOpen()
	local isOpen = false
	local needLv = getOpenNeedLv()
	if ( UserModel.getHeroLevel() >= needLv ) then 
		isOpen = true
	end
	return isOpen
end

--[[
	@desc	: 获取转换花费金币数
    @param	: pEvolveLv 兵符进阶等级
    @return	: number 转换花费金币数
—-]]
function getTsTallyCostBy( pEvolveLv )
	local costTab = string.split(dbNormalCfg.changebingfuCost, "|")
	return tonumber(costTab[tonumber(pEvolveLv)+1]) or 0
end

--[[
	@desc	: 获取所有可以转换的兵符Tid
    @param	: 
    @return	: 所有可转换兵符Tid数组
—-]]
function getAllTsTallyItemTid()
	local retTab = {}
	local tallyStrTab = string.split(dbNormalCfg.changebingfu, ",")
	for i=1,#tallyStrTab do
		local tallyTab = string.split(tallyStrTab[i], "|")
		for k=1,#tallyTab do
			table.insert(retTab,tonumber(tallyTab[k]))
		end
	end
	return retTab
end

--[[
	@desc	: 获取Tid对应可以转换的其他Tid
    @param	: pTid 兵符模板id
    @return	: 可转换的Tid数组
—-]]
function getTsTallyItemByTid( pTid )
	local retTab = {}
	local tallyStrTab = string.split(dbNormalCfg.changebingfu, ",")
	local tidArr = {}
	for i=1,#tallyStrTab do
		local tallyTab = string.split(tallyStrTab[i], "|")
		for k=1,#tallyTab do
			if ( tonumber(pTid) == tonumber(tallyTab[k]) ) then
				tidArr = tallyTab
				break
			end
		end
	end

	for j=1, #tidArr do
		if ( tonumber(pTid) ~= tonumber(tidArr[j]) ) then
			table.insert(retTab,tonumber(tidArr[j]))
		end
	end
	return retTab
end

--[[
	@desc	: 获取排序后符合条件的兵符
    @param	: 
    @return	: 
—-]]
function getSortChooseItemData()
	local retTab = {}
	-- 背包中符合条件的兵符
	local chooseData = getChooseItemData()
	-- 已选择的兵符
	local selectData = getSelectTallyList()

	-- 排序 已选择的放在最上边
	local selectTab = {}
	local unSelectTab = {}
	for k,v in pairs(chooseData) do
		local isIn = false
		for sk,sv in pairs(selectData) do
			if (tonumber(sv.item_id) == tonumber(v.item_id)) then
				isIn = true
				table.insert(selectTab, v)
				break
			end
		end
		if (isIn == false) then
			table.insert(unSelectTab, v)
		end
	end

	retTab = table.connect({unSelectTab,selectTab})

	return retTab
end

--[[
	@desc	: 获取符合条件的兵符
    @param	: 
    @return	: 
—-]]
function getChooseItemData()
	local retTab = {}
	local bagInfo = DataCache.getBagInfo()
	local needTidTab = getAllTsTallyItemTid()
	if not table.isEmpty(bagInfo.tally) then
		for k,v in pairs(bagInfo.tally) do
			for k,v_tid in pairs(needTidTab) do
				-- Tid相符的
				if( tonumber(v.item_template_id) == tonumber(v_tid) )then
					table.insert(retTab,v)
					break
				end
			end
		end
	end
	table.sort( retTab, BagUtil.tallySortForBag )
	return retTab
end

--[[
	@desc	: 设置选择兵符列表
    @param	: pSelectList 选择的兵符列表
    @return	: 
—-]]
function setSelectTallyList( pSelectList )
	_selectTallyList = pSelectList
end

--[[
	@desc	: 获取已经选择的兵符列表
    @param	: 
    @return	: table 选择的兵符列表
—-]]
function getSelectTallyList()
	return _selectTallyList
end

--[[
	@desc	: 判断列表里是否有兵符id
    @param	: pItemId 兵符id
    @return	: 
—-]]
function getIsInSelectListByItemId( pItemId )
	local isIn = false
	local pos = 0
	local selectTallyList = getSelectTallyList()
	for k,v in pairs(selectTallyList) do
		if(tonumber(v.item_id) == tonumber(pItemId))then
			isIn = true
			pos = k
			break
		end
	end
	return isIn,pos
end

--[[
	@desc	: 添加兵符id到已选择的列表数组中，如果选择列表已有该兵符则删除
    @param	: pItemId 兵符id
    @return	: 
—-]]
function addTallyToSelectList( pItemId )
	local isIn,pos = getIsInSelectListByItemId(pItemId)
	if(isIn)then
		table.remove(_selectTallyList,pos)
	else
		local tab = {}
		tab.item_id = pItemId
		table.insert(_selectTallyList,tab)
	end
end

--[[
	@desc	: 清除选择兵符列表
    @param	: 
    @return	: 
—-]]
function cleanSelectTallyList()
	_selectTallyList = {}
end

--[[
	@desc	: 获取兵符名字
    @param	: pTid 兵符模板id
    @return	: string 兵符名字
—-]]
function getTallyNameByTid( pTid )
	local name = DB_Item_bingfu.getDataById(pTid).name
	return name
end

--[[
	@desc	: 获取兵符品质
    @param	: pTid 兵符模板id
    @return	: number 兵符品质
—-]]
function getTallyQualityByTid( pTid )
	local quality = DB_Item_bingfu.getDataById(pTid).quality
	return tonumber(quality)
end

