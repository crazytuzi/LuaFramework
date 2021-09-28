-- Filename：	TipByNode.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-5
-- Purpose：		为了应对越来越多的带有图片，不同字体，不同字体颜色的提示板子而做的

module("TipByNode", package.seeall)

local _confirmCallBack
local _touchPriority
local _zOrder
local _alertLayer
local _closeCallBack
----------------------------------------初始化函数----------------------------------------
local function init()
	_confirmCallBack = nil
	_touchPriority = nil
	_zOrder = nil
	_alertLayer = nil
	_closeCallBack = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
    	print("otherEventType")
	end
end

local function onNodeEvent(event)
	if (event == "enter") then
		_alertLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_alertLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------回调函数----------------------------------------
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_alertLayer:removeFromParentAndCleanup(true)
	_alertLayer = nil
	if(_closeCallBack~=nil)then
		_closeCallBack()
	end
end

--[[
	@des 	:按钮回调
	@param 	:
	@return :
--]]
local function menuAction(tag,itemBtn)
	if(tag == 10001) then
		-- 回调
		if (_confirmCallBack) then
			_confirmCallBack(true)
		end
	end

	--关闭
	closeAction()
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:入口函数
	@param 	:$ p_comingNode 		: 传入的要添加到板子上的node
	@param  :$ p_confirmCallBack 	: 点击确定后的回调
	@param  :$ p_tipSize 			: 板子大小
	@param  :$ p_touchPriority 		: 触摸优先级
	@param  :$ p_zOrder 			: 板子Z轴
	@return :
--]]
function showLayer(p_comingNode,p_confirmCallBack,p_tipSize,p_touchPriority,p_zOrder,p_closeCallBack)
	init()
	_closeCallBack = p_closeCallBack
	_touchPriority = p_touchPriority or -1000
	_zOrder = p_zOrder or 2000
	_confirmCallBack = p_confirmCallBack
	
	local tipSize = p_tipSize or CCSizeMake(520,360)

	--确定按钮文字
	local confirmTitle = GetLocalizeStringBy("key_1985")
	--取消按钮文字
	local cancelTitle = GetLocalizeStringBy("key_1202")

	--触摸屏蔽层
	_alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_alertLayer, _zOrder)

	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(tipSize)
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(_alertLayer:getContentSize().width*0.5,_alertLayer:getContentSize().height*0.5))
	alertBg:setScale(g_fScaleX)
	_alertLayer:addChild(alertBg)

	local alertBgSize = alertBg:getContentSize()
	
	-- 标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 1))
    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBg:getContentSize().height-45))
    alertBg:addChild(titleLabel)

	--要显示的话
	local addingNode = p_comingNode
	addingNode:setAnchorPoint(ccp(0.5,1))
	addingNode:setPosition(ccp(alertBgSize.width/2,titleLabel:getPositionY()-titleLabel:getContentSize().height-20))
	alertBg:addChild(addingNode)

	-- 关闭按钮bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	menuBar:setTouchPriority(_touchPriority - 1)
	alertBg:addChild(menuBar)
	-- 关闭按钮
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:registerScriptTapHandler(closeAction)
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(alertBgSize.width*0.95, alertBgSize.height*0.98))
	menuBar:addChild(closeBtn)

    -- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
	confirmBtn:setPosition(ccp(alertBgSize.width*0.3,70))
    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
	cancelBtn:setPosition(ccp(alertBgSize.width*0.7,70))
    cancelBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(cancelBtn, 1, 10002)
end