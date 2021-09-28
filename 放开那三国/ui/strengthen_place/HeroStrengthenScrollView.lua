-- Filename: HeroStrengthenScrollView.lua
-- Author: fang
-- Date: 2013-08-12
-- Purpose: 该文件用于: 强化所系统中“强化”列表

module("HeroStrengthenScrollView", package.seeall)

-- 记忆tableView的偏移量
g_offset = nil

-- tag, 英雄头像起始tag
local _ksTagHeroBegin=3001
local _ksTagTableviewCell=4001
local _ksTagTabelviewMenu=5001
-- 强化按钮起始tag
local _ksTagButtonStrengthenBegin=6001

local _arrHeroesValue
local _nFocusHid

-- 英雄头像按钮事件回调处理
local function fnHandlerOfHeroHeadButtons(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/hero/HeroInfoLayer"
	require "script/ui/main/MainScene"
	local tHeroData = _arrHeroesValue[tag-_ksTagHeroBegin]
	local tArgsOfModule={sign=StrengthenPlaceLayer.m_sign, fnCreate=StrengthenPlaceLayer.createLayer}
	tArgsOfModule.reserved = {index=StrengthenPlaceLayer.m_ksMenuItemIndexOfStrengthen, focusHid=tHeroData.hid}
	MainScene.changeLayer(HeroInfoLayer.createLayer(tHeroData, tArgsOfModule), HeroInfoLayer.m_sign)
end

-- 列表单元中按钮事件回调处理
local function fnHandlerOfCellButtons(tag, obj)
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
-- 以下代码用于测试新手引导
	-- local runningScene = CCDirector:sharedDirector():getRunningScene()
	-- local cmiStrengthen = getStrengthenButtonForGuide()
	-- local rect = getSpriteScreenRect(cmiStrengthen)
	-- local clButton = BaseUI.createMaskLayer(-5000, rect)

	-- runningScene:addChild(clButton, 1000, 1000)
	
	require "script/ui/hero/HeroStrengthenLayer"
	require "script/ui/main/MainScene"
	local tHeroData = _arrHeroesValue[tag-_ksTagButtonStrengthenBegin]
	local tArgsOfModule={sign=StrengthenPlaceLayer.m_sign, fnCreate=StrengthenPlaceLayer.createLayer}
	tArgsOfModule.reserved = {index=StrengthenPlaceLayer.m_ksMenuItemIndexOfStrengthen, focusHid=tHeroData.hid}
	MainScene.changeLayer(HeroStrengthenLayer.createLayer(tHeroData, tArgsOfModule), HeroStrengthenLayer.m_sign)
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
 	local tLabel = {text=GetLocalizeStringBy("key_1269"), fontsize=30, }
 	local ccMenuItemStrengthen = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
 	ccMenuItemStrengthen:setPosition(ccp(480, 20))
	ccMenuItemStrengthen:registerScriptTapHandler(fnHandlerOfCellButtons)
 	ccMenu:addChild(ccMenuItemStrengthen, 0, _ksTagButtonStrengthenBegin+index)
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
	end
	require "script/ui/hero/HeroFightForce"
	require "script/ui/hero/HeroFightSimple"

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
--			value.fight_value = HeroFightForce.getAllForceValues(value).fightForce
			r = HeroPublicCC.createTableViewCell(value)
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
	if _nFocusHid and tonumber(_nFocusHid) > 0 then
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

	-- 新手引导 强制关闭Action by licong 2013.09.07
	require "script/guide/NewGuide"
	if(NewGuide.guideClass ==  ksGuideClose and bIsNotFoucs) then
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
		g_offset = nil
	end

	-- 记忆偏移量 add by licong
	tableView:registerScriptHandler(function ( eventType,node )
	   	if(eventType == "enter") then
	   		if(g_offset ~= nil and table.count(_arrHeroesValue) > 4) then
	   			tableView:setContentOffset(g_offset)
	   		end
	   	elseif(eventType == "exit") then
			g_offset = tableView:getContentOffset()
		end
	end)

	return tableView
end

-- 为新手引导提供“强化所”，”强化“ 按钮对象
function getStrengthenButtonForGuide( ... )
	local nCells = #_arrHeroesValue
	local ccCellObj = _arrHeroesValue[nCells].ccCellObj
	local cellBg = tolua.cast(ccCellObj:getChildByTag(_ksTagTableviewCell), "CCSprite")
	local ccMenu = tolua.cast(cellBg:getChildByTag(_ksTagTabelviewMenu), "CCMenu")
	local cmiStrengthen = tolua.cast(ccMenu:getChildByTag(_ksTagButtonStrengthenBegin+nCells), "CCMenuItem")

	return cmiStrengthen
end
