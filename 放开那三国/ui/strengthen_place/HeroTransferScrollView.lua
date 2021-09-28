-- Filename: HeroTransferScrollView.lua
-- Author: fang
-- Date: 2013-08-12
-- Purpose: 该文件用于: 强化所系统中“进阶”列表

module("HeroTransferScrollView", package.seeall)

-- 记忆tableView的偏移量
g_offset = nil

-- tag, 英雄头像起始tag
local _ksTagHeroBegin=3001
local _ksTagTableviewCell=4001
local _ksTagTabelviewMenu=5001
-- 进阶按钮起始tag
local _ksTagButtonTransferBegin=7001

local _arrHeroesValue
-- 焦点武将hid
local _nFocusHid

-- 英雄头像按钮事件回调处理
local function fnHandlerOfHeroHeadButtons(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/hero/HeroInfoLayer"
	require "script/ui/main/MainScene"
	local tArgsOfModule={sign=StrengthenPlaceLayer.m_sign, fnCreate=StrengthenPlaceLayer.createLayer}
	tArgsOfModule.reserved=StrengthenPlaceLayer.m_ksMenuItemIndexOfTransfer
	MainScene.changeLayer(HeroInfoLayer.createLayer(_arrHeroesValue[tag-_ksTagHeroBegin], tArgsOfModule), HeroInfoLayer.m_sign)
end
-- 列表单元中按钮事件回调处理
local function fnHandlerOfCellButtons(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/hero/HeroTransferLayer"
	require "script/ui/main/MainScene"

	local tArgsOfModule={sign=StrengthenPlaceLayer.m_sign, fnCreate=StrengthenPlaceLayer.createLayer}
	tArgsOfModule.selectedHeroes = _arrHeroesValue[tag-_ksTagButtonTransferBegin]
	tArgsOfModule.reserved = StrengthenPlaceLayer.m_ksMenuItemIndexOfTransfer
	MainScene.changeLayer(HeroTransferLayer.createLayer(tArgsOfModule), HeroTransferLayer.m_sign)
end

-- 附加元素至Tableview单元
local function fnAppendElementsToCell(ccCell, index)
	local cellBg = tolua.cast(ccCell:getChildByTag(_ksTagTableviewCell), "CCSprite")
	-- 增加战斗力值
	local ccLabelFightForce = CCLabelTTF:create(GetLocalizeStringBy("key_2122") .. _arrHeroesValue[index].fight_value, g_sFontName, 25, CCSizeMake(200, 30), kCCTextAlignmentLeft)
	ccLabelFightForce:setPosition(ccp(120, 43))
	ccLabelFightForce:setColor(ccc3(0x48, 0x1b, 0))
	cellBg:addChild(ccLabelFightForce)

	-- 增加按钮
	local ccMenu = tolua.cast(cellBg:getChildByTag(_ksTagTabelviewMenu), "CCMenu")
	require "script/libs/LuaCCMenuItem"
 	local tSprite = {normal="images/common/btn/purple01_n.png", selected="images/common/btn/purple01_n.png"}
 	local tLabel = {text=GetLocalizeStringBy("key_1730"), fontsize=30,}
 	local ccMenuItemTransfer = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
 	ccMenuItemTransfer:setPosition(ccp(480, 20))
	ccMenuItemTransfer:registerScriptTapHandler(fnHandlerOfCellButtons)
 	ccMenu:addChild(ccMenuItemTransfer, 0, _ksTagButtonTransferBegin+index)
end  

-- 创建
function create(tParam)
	local nScrollviewHeight = tParam.nScrollviewHeight
	_nFocusHid = tParam.focusHid
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	local cellSize = cellBg:getContentSize()
	cellSize.width = cellSize.width * g_fScaleX/g_fElementScaleRatio
	cellSize.height = cellSize.height * g_fScaleX/g_fElementScaleRatio
	cellBg = nil

	local nVisiableCellCount = math.floor(nScrollviewHeight/cellSize.height)

	require "script/ui/hero/HeroPublicLua"
	require "script/ui/hero/HeroPublicCC"
	require "script/ui/hero/HeroFightForce"
	require "script/ui/hero/HeroFightSimple"
	local tArgs = {heroTagBegin=_ksTagHeroBegin}
	tArgs.filters ={20001, 20002}
	local arrHeroesValue = HeroPublicLua.getAllHeroValues(tArgs)

	require "script/ui/hero/HeroSort"
	_arrHeroesValue = HeroSort.fnSortOfHero(arrHeroesValue)
	_arrHeroesValue = table.reverse(_arrHeroesValue)

	for i=1, #_arrHeroesValue do
		_arrHeroesValue[i].tag_hero = _ksTagHeroBegin+i
		_arrHeroesValue[i].tag_bg = _ksTagTableviewCell
		_arrHeroesValue[i].tag_menu = _ksTagTabelviewMenu
		_arrHeroesValue[i].cb_hero = fnHandlerOfHeroHeadButtons
		_arrHeroesValue[i].isBusy = HeroPublicLua.isBusyWithHid(_arrHeroesValue[i].hid)
	end

	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			local value = _arrHeroesValue[a1+1]
			if value.fight_value == nil or value.fight_value==0 then
				if value.isBusy then
					value.force_values =  HeroFightForce.getAllForceValues(value)
				else
					value.force_values =  HeroFightSimple.getAllForceValues(value)
				end
				value.fight_value = value.force_values.fightForce
			end
			r = HeroPublicCC.createTableViewCell(_arrHeroesValue[a1+1])
			_arrHeroesValue[a1+1].ccCellObj = r
			fnAppendElementsToCell(r, a1+1)
			r:setScale(g_fScaleX/g_fElementScaleRatio)
		elseif (fn == "numberOfCells") then
			r = #_arrHeroesValue
		end
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(g_winSize.width/g_fElementScaleRatio, nScrollviewHeight/g_fElementScaleRatio))
	tableView:setAnchorPoint(ccp(0, 0))
	tableView:setBounceable(true)

	local bIsNotFoucs = true
	if tonumber(_nFocusHid) > 0 then
		local nIndex = 0
        for i=1, #_arrHeroesValue do
        	if tonumber(_arrHeroesValue[i].hid) == tonumber(_nFocusHid) then
        		nIndex = i
        		bIsNotFoucs = false
        		break
        	end
        end
		local nOffset = nScrollviewHeight - (#_arrHeroesValue-nIndex+1)*cellSize.height
		tableView:setContentOffset(ccp(0, nOffset))
	end

	if bIsNotFoucs then
		local maxAnimateIndex = nVisiableCellCount
		if (nVisiableCellCount > #_arrHeroesValue) then
			maxAnimateIndex = #_arrHeroesValue
		end
		for i=1, maxAnimateIndex do
			local cell = tableView:cellAtIndex(maxAnimateIndex - i)
			if (cell) then
				local cellBg = tolua.cast(cell:getChildByTag(_ksTagTableviewCell), "CCSprite")
				cellBg:setPosition(ccp(cellBg:getContentSize().width, 0))
				cellBg:runAction(CCMoveTo:create(g_cellAnimateDuration * i ,ccp(0,0)))
			end
		end
	end
	-- 记忆偏移量 add by licong
	tableView:registerScriptHandler(function ( eventType,node )
	   		if(eventType == "enter") then
	   			if(g_offset ~= nil and table.count(_arrHeroesValue) > 4)then
	   				tableView:setContentOffset(g_offset)
	   			end
	   		end
			if(eventType == "exit") then
				g_offset = tableView:getContentOffset()
			end
		end)

	return tableView
end
