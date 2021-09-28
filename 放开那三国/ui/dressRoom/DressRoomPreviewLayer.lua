-- Filename：	DressRoomPreviewLayer.lua
-- Author：		bzx
-- Date：		2014-11-10
-- Purpose：		时装预览

module("DressRoomPreviewLayer", package.seeall)

require "script/model/utils/HeroUtil"

local _layer
local _touchPriority = -500
local _zOder = 10000
local _dressID

function show(dressID, touchPriority, zOder)
	_layer = create(dressID, touchPriority, zOder)
	CCDirector:sharedDirector():getRunningScene():addChild(_layer, _zOder)
end

function init(dressID, touchPriority, zOder)
	_dressID = dressID
	_touchPriority = touchPriority or _touchPriority
	_zOder = zOder or _zOder
end

function create(dressID, touchPriority, zOder)
	init(dressID, touchPriority, zOder)
	_layer = CCLayerColor:create(ccc4(0, 0, 0, 200))
	_layer:registerScriptHandler(onNodeEvent)
	loadTop()
	loadDress()
	return _layer
end

function loadTop( ... )
	local menu = CCMenu:create()
	_layer:addChild(menu)
	menu:setPosition(ccp(0, 0))

	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	menu:addChild(backItem)
	menu:setTouchPriority(_touchPriority - 1)
	backItem:setScale(MainScene.elementScale)
    backItem:registerScriptTapHandler(backCallback)
    backItem:setScale(MainScene.elementScale)
    backItem:setPosition(ccp(g_winSize.width - 100 * MainScene.elementScale, g_winSize.height - 160 * g_fScaleX))
end

function loadDress( ... )
	local dress = HeroUtil.getHeroBodySpriteByHTID(UserModel.getAvatarHtid(), _dressID)
	_layer:addChild(dress)
	dress:setAnchorPoint(ccp(0.5, 0.5))
	dress:setPosition(ccpsprite(0.5, 0.5, _layer))
	dress:setScale(MainScene.elementScale)
end

function onTouchesHandler( eventType, x, y )
	if eventType == "began" then
	    return true
    elseif eventType == "moved" then
    else
	end
end

function onNodeEvent( event )
	if event == "enter" then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_layer:setTouchEnabled(true)
	elseif event == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

function backCallback()
	_layer:removeFromParentAndCleanup(true)
end