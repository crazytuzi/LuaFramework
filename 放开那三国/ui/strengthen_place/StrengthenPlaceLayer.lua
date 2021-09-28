-- Filename: StrengthenPlaceLayer.lua
-- Author: fang
-- Date: 2013-08-10
-- Purpose: 该文件用于: 强化所系统

module("StrengthenPlaceLayer", package.seeall)

-- 当前模块标识
m_sign="StrengthenPlaceLayer"

local _bgLayer 	= nil
-- scrollview高度
local _nScrollviewHeight
-- tag, 武将强化tag
local _ksTagHeroStrengthen=2001
-- tag, 武将进阶tag
local _ksTagHeroTransfer=2002

-- 强化菜单项索引
m_ksMenuItemIndexOfStrengthen=101
-- 进阶菜单项索引
m_ksMenuItemIndexOfTransfer=102
-- 当前菜单项索引
local _nCurrentMenuItemIndex

-- 当前列表控件
local _ccTableviewCurrent

-- 菜单按钮数组
local _arrMenuItemObjs
-- 菜单按钮事件回调处理
local function fnHandlerOfMenuButtons(tag, obj)
	for i=1, #_arrMenuItemObjs do
		_arrMenuItemObjs[i]:unselected()
	end
	obj:selected()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	-- “武将强化”按钮点击事件处理
	if tag == _ksTagHeroStrengthen then
		if _nCurrentMenuItemIndex == m_ksMenuItemIndexOfStrengthen then
			return
		end
		_nCurrentMenuItemIndex = m_ksMenuItemIndexOfStrengthen
		if _ccTableviewCurrent then
			_ccTableviewCurrent:removeFromParentAndCleanup(true)
		end
		require "script/ui/strengthen_place/HeroStrengthenScrollView"
		local tArgs = {}
		tArgs.nScrollviewHeight = _nScrollviewHeight
		tArgs.focusHid = 0
		_ccTableviewCurrent = HeroStrengthenScrollView.create(tArgs)
		_bgLayer:addChild(_ccTableviewCurrent)
	-- GetLocalizeStringBy("key_1137")按钮点击事件处理
	elseif tag == _ksTagHeroTransfer then
		if _nCurrentMenuItemIndex == m_ksMenuItemIndexOfTransfer then
			return
		end
		_nCurrentMenuItemIndex = m_ksMenuItemIndexOfTransfer
		if _ccTableviewCurrent then
			_ccTableviewCurrent:removeFromParentAndCleanup(true)
		end
		require "script/ui/strengthen_place/HeroTransferScrollView"
		local tArgs = {}
		tArgs.nScrollviewHeight = _nScrollviewHeight
		tArgs.focusHid = 0
		_ccTableviewCurrent = HeroTransferScrollView.create(tArgs)
		_bgLayer:addChild(_ccTableviewCurrent)
	end
end

-- 创建菜单中按钮
local function fnCreateMenu()
	require "script/libs/LuaCC"
	
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--条件背景
	local btnFrameSp = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	btnFrameSp:setPreferredSize(CCSizeMake(640, 108))
	btnFrameSp:setAnchorPoint(ccp(0.5, 1))
	btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height+20))
	btnFrameSp:setScale(g_fScaleX/g_fElementScaleRatio)
	_bgLayer:addChild(btnFrameSp)

	local menu = CCMenu:create()
	menu:setPosition(ccp(10, 10))
	btnFrameSp:addChild(menu)

	require "script/libs/LuaCCMenuItem"
	local x = 0
	local y = 0
	local tSprite = {normal="images/active/rob/btn_title_n.png", selected="images/active/rob/btn_title_h.png", focus=true}
	local tLabel = {text=GetLocalizeStringBy("key_2912"), nFontsize=36, sFontsize=30, nColor=ccc3(0xff, 0xe4, 0), sColor=ccc3(0x48, 0x85, 0xb5), yOffset=-4}
	local ccMenuItemStrengthen = LuaCCMenuItem.createMenuItemOfLabelOnSprite(tSprite, tLabel)
	ccMenuItemStrengthen:registerScriptTapHandler(fnHandlerOfMenuButtons)
	ccMenuItemStrengthen:selected()
	menu:addChild(ccMenuItemStrengthen, 0, _ksTagHeroStrengthen)
	table.insert(_arrMenuItemObjs, ccMenuItemStrengthen)

	tSprite.focus = false
	tLabel.text = GetLocalizeStringBy("key_1137")
	x = x + ccMenuItemStrengthen:getContentSize().width + 4
	local ccMenuItemTransfer = LuaCCMenuItem.createMenuItemOfLabelOnSprite(tSprite, tLabel)
	ccMenuItemTransfer:registerScriptTapHandler(fnHandlerOfMenuButtons)
	ccMenuItemTransfer:setPosition(ccp(x, y))
	ccMenuItemTransfer:selected()
	menu:addChild(ccMenuItemTransfer, 0, _ksTagHeroTransfer)
	table.insert(_arrMenuItemObjs, ccMenuItemTransfer)
	if _nCurrentMenuItemIndex == m_ksMenuItemIndexOfStrengthen then
		ccMenuItemTransfer:unselected()
	elseif _nCurrentMenuItemIndex == m_ksMenuItemIndexOfTransfer then
		ccMenuItemStrengthen:unselected()
	end

	_nScrollviewHeight = _bgLayer:getContentSize().height - 80*g_fElementScaleRatio

	return btnFrameSp
end 
local function init( ... )
	_arrMenuItemObjs = {}
end
-- 创建“强化所系统”层
function createLayer(tParam)
	init()
	-- 焦点武将hid
	local nFocusHid=0
	if type(tParam) == "table" then
		_nCurrentMenuItemIndex = tParam.index
		nFocusHid = tParam.focusHid
	else
		_nCurrentMenuItemIndex=m_ksMenuItemIndexOfStrengthen
	end

	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, true, true)
	fnCreateMenu()

	local tArgs = {}
	tArgs.focusHid = nFocusHid
	tArgs.nScrollviewHeight = _nScrollviewHeight
	local tableview
	if _nCurrentMenuItemIndex == m_ksMenuItemIndexOfStrengthen then
		require "script/ui/strengthen_place/HeroStrengthenScrollView"
		tableview = HeroStrengthenScrollView.create(tArgs)
	else
		require "script/ui/strengthen_place/HeroTransferScrollView"
		tableview = HeroTransferScrollView.create(tArgs)
	end
	_ccTableviewCurrent= tableview
	_bgLayer:addChild(tableview)

	return _bgLayer
end




