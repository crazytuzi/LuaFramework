-- FileName: ApplyOlympicDialog.lua 
-- Author: licong 
-- Date: 14-7-19 
-- Purpose: 报名确认提示框


module("ApplyOlympicDialog", package.seeall)

local kTagyes 					= 10001
local kTagCancel				= 10002

local _bgLayer 					= nil
local _costNum 					= nil
local _callbackFunc 			= nil
function init( ... )
	_bgLayer 					= nil
	_costNum 					= nil
	_callbackFunc 				= nil
end

--[[
	@des 	:处理touches事件
	@param 	:
	@return :
--]]
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    else
	end
end

--[[
	@des 	:处理enter和exit事件
	@param 	:
	@return :
--]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -5600, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
        _bgLayer = nil
	end
end

--[[
	@des 	:关闭函数
	@param 	:
	@return :
--]]
local function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:确定 取消  按钮回调
	@param 	:
	@return :
--]]
local function menuAction( tag, itemBtn )
	-- 关闭提示框
	closeAction()
	-- 按钮事件
	if(tag == kTagyes) then
		-- 确定
		if(_callbackFunc) then
			_callbackFunc()
		end
	elseif(tag == kTagCancel)then
		-- 取消
	else
	end
end

--[[
	@des 	:显示提示界面
	@param 	:p_CostNum 花费
	@return :
--]]
function showTipLayer( p_CostNum, p_callbackFunc )
	init()
	_callbackFunc = p_callbackFunc
	_costNum = tonumber(p_CostNum)
	-- layer
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 2000)

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

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	alertBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-5601)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(alertBg:getContentSize().width*0.95, alertBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
    alertBg:addChild(titleLabel)

    -- 描述
-- 第一行
    -- 花费
    local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1165"), g_sFontName, 25)
    font1:setColor(ccc3(0x78, 0x25, 0x00))
    font1:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font1)
     -- 银币图标
    local coinSp = CCSprite:create("images/common/coin.png")
    coinSp:setAnchorPoint(ccp(0,0.5))
    alertBg:addChild(coinSp)
    -- 花费价格
    local costNumFont = CCLabelTTF:create(_costNum, g_sFontName,25)
    costNumFont:setColor(ccc3(0x78, 0x25, 0x00))
    costNumFont:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(costNumFont)
    -- 后可报名参赛，
    local font2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1166"), g_sFontName, 25)
    font2:setColor(ccc3(0x78, 0x25, 0x00))
    font2:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font2)
    -- 第一行居中
    local posX = (alertBg:getContentSize().width-font1:getContentSize().width-coinSp:getContentSize().width-costNumFont:getContentSize().width-font2:getContentSize().width)/2
    font1:setPosition(ccp(posX, alertBgSize.height*0.6))
    coinSp:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width, font1:getPositionY()))
    costNumFont:setPosition(ccp(coinSp:getPositionX()+coinSp:getContentSize().width, font1:getPositionY()))
    font2:setPosition(ccp(costNumFont:getPositionX()+costNumFont:getContentSize().width, font1:getPositionY()))

-- 第二行    
    -- 确定参赛？
    local font3 = CCLabelTTF:create(GetLocalizeStringBy("lic_1167"), g_sFontName, 25)
    font3:setColor(ccc3(0x78, 0x25, 0x00))
    font3:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font3)
    font3:setPosition(ccp(font1:getPositionX(),alertBgSize.height*0.45))
   
    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-5601)
    alertBg:addChild(menuBar)

    -- 确认
    require "script/libs/LuaCC"
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
    confirmBtn:registerScriptTapHandler(menuAction)
    menuBar:addChild(confirmBtn, 1, kTagyes)
    
    -- 取消
    local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1098"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
    cancelBtn:registerScriptTapHandler(menuAction)
    menuBar:addChild(cancelBtn, 1, kTagCancel)
end


