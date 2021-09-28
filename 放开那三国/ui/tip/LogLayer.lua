-- Filename：	LogLayer.lua
-- Author：		bzx
-- Date：		2015-04-10
-- Purpose：		显示日志

module("LogLayer", package.seeall)

require "script/libs/LuaCCLabel"

local _layer
local _touchPriority
local _zOrder
local _log

function show(p_log, p_touchPriority, p_zOrder)
	_layer = create(p_log, p_touchPriority, p_zOrder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOrder)
end

function initData(p_log, p_touchPriority, p_zOrder )
	_log = p_log
	_touchPriority = p_touchPriority or -5700
	_zOrder = p_zOrder or 2000
end

function create(p_log, p_touchPriority, p_zOrder )
	initData(p_log, p_touchPriority, p_zOrder)
	_layer = CCLayerColor:create(ccc4(0x00, 0x00, 0x00, 0x88))
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority)
	local normal = CCLayer:create()
	local menuItem = CCMenuItemSprite:create(normal, mormal)
	menu:addChild(menuItem)
	loadLog()
	loadMenu()
	return _layer
end

function loadLog( ... )
	local scrollView = CCScrollView:create()
	_layer:addChild(scrollView)
	scrollView:setViewSize(g_winSize)
	scrollView:setTouchPriority(_touchPriority - 10)
	local richInfo = {
		width = g_winSize.width,
		labelDefaultColor = ccc3(0x00, 0xff, 0x00),
		elements = {
			{
				text = _log
			}
		}
	}
	local label = LuaCCLabel.createRichLabel(richInfo)
	local contentSize = label:getContentSize()
	if contentSize.width < g_winSize.width then
		contentSize.width = g_winSize.width
	end
	if contentSize.height < g_winSize.height then
		contentSize.height = g_winSize.height
	end
	scrollView:setBounceable(false)
	scrollView:setContentSize(contentSize)
	local container = scrollView:getContainer()
	container:addChild(label)
	label:setAnchorPoint(ccp(0, 0.5))
	label:setPosition(ccpsprite(0, 0.5, container))
end

function loadMenu( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu, 10)
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 20)
	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	menu:addChild(closeItem)
	closeItem:setAnchorPoint(ccp(1, 0))
	closeItem:setPosition(ccps(1, 0))
	closeItem:setScale(MainScene.elementScale)
	closeItem:registerScriptTapHandler(closeCallback)
end

function closeCallback( ... )
	_layer:removeFromParentAndCleanup(true)
end