-- FileName: DevilTowerSweepDialog.lua
-- Author: lgx
-- Date: 2016-08-05
-- Purpose: 梦魇试炼扫荡界面

module("DevilTowerSweepDialog", package.seeall)

require "script/utils/BaseUI"

-- 模块局部变量 --
local _touchPriority 	= nil -- 触摸优先级
local _zOrder 			= nil -- 显示层级
local _bgLayer			= nil -- 背景层
local _cormfirmCallback	= nil -- 确认回调
local _levelInputBox 	= nil -- 输入框

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 		= nil
	_zOrder 			= nil
	_bgLayer			= nil
	_cormfirmCallback 	= nil
	_levelInputBox		= nil
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc 	: 创建Dialog及UI
	@param 	: pMaxLevel 可扫荡的最高层
	@param 	: pCallback 确认回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createDialog( pMaxLevel, pCallback, pTouchPriority, pZorder )
	-- 初始化
	init()

	_touchPriority = pTouchPriority or -550
	_zOrder = pZorder or 500
	_cormfirmCallback = pCallback

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:setAnchorPoint(ccp(0, 0))

	local bgSize = CCSizeMake(450,300)
	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    bgSprite:setContentSize(bgSize)
    bgSprite:setScale(g_fElementScaleRatio)
    bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(bgSprite)

    -- 菜单
    local closeMenu = CCMenu:create()
    closeMenu:setPosition(ccp(0,0))
    closeMenu:setTouchPriority(_touchPriority-10)
    bgSprite:addChild(closeMenu,99)

    -- 关闭按钮
	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeItem:registerScriptTapHandler(closeItemCallback)
	closeItem:setAnchorPoint(ccp(1, 1))
    closeItem:setPosition(ccp(bgSize.width*1.03, bgSize.height*1.03))
	closeMenu:addChild(closeItem)

	-- 描述
	local content = CCLabelTTF:create(GetLocalizeStringBy("key_3216"), g_sFontName ,24)
    content:setColor(ccc3(0x78,0x25,0x00))

    -- 输入框
    _levelInputBox = CCEditBox:create(CCSizeMake(70,50), CCScale9Sprite:create("images/common/bg/search_bg.png"))
    _levelInputBox:setTouchPriority(_touchPriority-1)
    _levelInputBox:setText(pMaxLevel)
    _levelInputBox:setFont(g_sFontPangWa,25)
    _levelInputBox:setFontColor(ccc3(0xff,0xff,0xff))
    _levelInputBox:setPlaceholderFontColor(ccc3(0xff,0xff,0xff))
    _levelInputBox:setMaxLength(3)
    _levelInputBox:setInputMode(kEditBoxInputModeNumeric)

    local content2 = CCLabelTTF:create(GetLocalizeStringBy("key_1659"), g_sFontName ,24)
    content2:setColor(ccc3(0x78,0x25,0x00))
    
    local aleteNode = BaseUI.createHorizontalNode({content,_levelInputBox,content2})
    aleteNode:setAnchorPoint(ccp(0.5, 0.5))
    aleteNode:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height-80))
    bgSprite:addChild(aleteNode)

    local descLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1173"), g_sFontPangWa, 25, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    descLabel:setColor(ccc3(0x78,0x25,0x00))
    descLabel:setAnchorPoint(ccp(0.5,0.5))
    descLabel:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
    bgSprite:addChild(descLabel)

	-- 确认
	local confirmItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png",CCSizeMake(119, 64), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmItem:setAnchorPoint(ccp(0.5, 0))
	confirmItem:setPosition(ccp(bgSize.width*0.25, 35))
    confirmItem:registerScriptTapHandler(confirmItemCallback)
	closeMenu:addChild(confirmItem, 1)
	
	-- 取消
	local cancelItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png",CCSizeMake(119, 64), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelItem:setAnchorPoint(ccp(0.5, 0))
	cancelItem:setPosition(ccp(bgSize.width*0.75, 35))
    cancelItem:registerScriptTapHandler(closeItemCallback)
	closeMenu:addChild(cancelItem, 1)

	return _bgLayer
end

--[[
	@desc 	: 显示界面方法
	@param 	: pMaxLevel 可扫荡的最高层
	@param 	: pCallback 确认回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showDialog( pMaxLevel, pCallback, pTouchPriority, pZorder )
	local layer = createDialog(pMaxLevel,pCallback,pTouchPriority,pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc	: 点击确认按钮回调
    @param	: 
    @return	: 
—-]]
function confirmItemCallback()
	-- 调用回调
    if (_cormfirmCallback ~= nil) then
    	local levelText = _levelInputBox:getText()
        local isSend = _cormfirmCallback(levelText)
        if (isSend) then
        	-- 关闭界面
			closeItemCallback()
        end
    else
    	-- 关闭界面
		closeItemCallback()
    end
end

--[[
	@desc	: 点击关闭按钮回调
    @param	: 
    @return	: 
—-]]
function closeItemCallback()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end
