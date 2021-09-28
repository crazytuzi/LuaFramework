-- Filename：	BaseAlertTip.lua
-- Author：		chengliang
-- Date：		2014-11-22
-- Purpose：		月卡充值提示

module("BaseAlertTip", package.seeall)


local _bgLayer
local _bgSprite
local _zOrder 	
local _bgSprite 

local _layerSize 
local _title 

function init()
	_bgLayer 	= nil
	_priority 	= nil
	_zOrder 	= nil
	_bgSprite 	= nil
	_layerSize	= nil
	_title 		= nil
end

function getBgSprite()
	return _bgSprite
end

local function onTouchesHandler( eventType, x, y )
	return true
end

 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
	end
end

-- 关闭按钮的回调函数
function closeCb()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

-- 
local function createBgSprite()
	local myScale = MainScene.elementScale
	local mySize = _layerSize
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    _bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _bgSprite:setContentSize(mySize)
    _bgSprite:setScale(myScale)
    _bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_bgSprite)

    if( _title ~= nil )then
	    local titleBg= CCSprite:create("images/common/viewtitle1.png")
		titleBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height-6))
		titleBg:setAnchorPoint(ccp(0.5, 0.5))
		_bgSprite:addChild(titleBg)

		 --标题文本
		local labelTitle = CCRenderLabel:create(_title, g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
		labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
		labelTitle:setColor(ccc3(0xff,0xe4,0x00))
		labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	    labelTitle:setAnchorPoint(ccp(0.5,0.5))
		titleBg:addChild(labelTitle)
	end
	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_priority-1)
    _bgSprite:addChild(menu,99)
    closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)
end

-- 创建
function createLayer( layerSize, title, priority, zOrder )
	init()
	_priority = priority or -460
	_zOrder = zOrder or  999
	_layerSize = layerSize or CCSizeMake(550, 300)
	_title = title

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)

	createBgSprite()

	return _bgLayer
end



