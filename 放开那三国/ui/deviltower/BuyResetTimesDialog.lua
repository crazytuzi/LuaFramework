-- FileName: BuyResetTimesDialog.lua
-- Author: lgx
-- Date: 2016-08-05
-- Purpose: 试炼梦魇购买重置次数界面

module("BuyResetTimesDialog", package.seeall)

require "script/libs/LuaCC"

-- 模块局部变量 --
local _touchPriority 	= nil -- 触摸优先级
local _zOrder 			= nil -- 显示层级
local _bgLayer			= nil -- 背景层
local _cormfirmCallback	= nil -- 确认回调

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
	@param 	: pCostGold 花费金币数
	@param 	: pMaxBuyTimes 最大购买次数
	@param 	: pHadBuyTimes 已经购买次数
	@param 	: pCallback 确认回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createDialog( pCostGold, pMaxBuyTimes, pHadBuyTimes, pCallback, pTouchPriority, pZorder )
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

	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(CCSizeMake(520, 360))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(alertBg)
	alertBg:setScale(g_fScaleX)	

	local alertBgSize = alertBg:getContentSize()

	-- 菜单
	local closeMenu = CCMenu:create()
	closeMenu:setPosition(ccp(0, 0))
	alertBg:addChild(closeMenu)
	closeMenu:setTouchPriority(_touchPriority-10)

	-- 关闭按钮
	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeItem:registerScriptTapHandler(closeItemCallback)
	closeItem:setAnchorPoint(ccp(0.5, 0.5))
    closeItem:setPosition(ccp(alertBgSize.width*0.95, alertBgSize.height*0.98))
	closeMenu:addChild(closeItem)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
    alertBg:addChild(titleLabel)

    -- 金币图标
    local goldSprite = CCSprite:create("images/common/gold.png")
    goldSprite:setAnchorPoint(ccp(0.5,0.5))
    goldSprite:setPosition(ccp(98, 248))
    alertBg:addChild(goldSprite)

	-- 描述
	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1375") .. pCostGold .. GetLocalizeStringBy("lgx_1099") .. (pMaxBuyTimes - pHadBuyTimes), g_sFontName, 25, CCSizeMake(460, 160), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0.5, 0.5))
	descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.5))
	alertBg:addChild(descLabel)

	-- 确认
	local confirmItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmItem:setAnchorPoint(ccp(0.5, 0.5))
	confirmItem:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
    confirmItem:registerScriptTapHandler(confirmItemCallback)
	closeMenu:addChild(confirmItem, 1)
	
	-- 取消
	local cancelItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelItem:setAnchorPoint(ccp(0.5, 0.5))
	cancelItem:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
    cancelItem:registerScriptTapHandler(closeItemCallback)
	closeMenu:addChild(cancelItem, 1)

	return _bgLayer
end

--[[
	@desc 	: 显示界面方法
	@param 	: pCostGold 花费金币数
	@param 	: pMaxBuyTimes 最大购买次数
	@param 	: pHadBuyTimes 已经购买次数
	@param 	: pCallback 确认回调
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showDialog( pCostGold, pMaxBuyTimes, pHadBuyTimes, pCallback, pTouchPriority, pZorder )
	local layer = createDialog(pCostGold,pMaxBuyTimes,pHadBuyTimes,pCallback,pTouchPriority,pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc	: 点击确认按钮回调
    @param	: 
    @return	: 
—-]]
function confirmItemCallback()
	-- 关闭界面
	closeItemCallback()
	-- 调用回调
    if (_cormfirmCallback ~= nil) then
        _cormfirmCallback()
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

