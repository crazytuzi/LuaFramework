-- Filename：	TowerDefeatNumTip.lua
-- Author：		Cheng Liang
-- Date：		2013-11-11
-- Purpose：		金币购买重置次数

module("TowerDefeatNumTip", package.seeall)


require "script/ui/common/LuaMenuItem"
require "script/ui/main/MainScene"
require "script/ui/tip/AnimationTip"

local _cormfirmCBFunc = nil 

local alertLayer
local _baseid
local _maxAtkTimes
local _copyId
local _costGold = 10
local _isGold = false
local _maxBuyTimes = 0
local _hadBuyTimes = 0

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		-- print("began")

	    return true
    elseif (eventType == "moved") then
    	
    else
        -- print("end")
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -560, true)
		alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		alertLayer:unregisterScriptTouchHandler()
	end
end


function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end
end


function resetAtkNumCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		
		UserModel.addGoldNumber(-_costGold)
		TowerCache.addGoldResetTimesBy(1)
		-- 刷新
		TowerMainLayer.resetAttackRefresh()
	end
end

-- 按钮响应
function menuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	print ("tag==", tag)
	if(tag == 10001) then
		-- 没有就会使用金币
		if(UserModel.getGoldNumber() < _costGold)then
			require "script/ui/tip/LackGoldTip"
			LackGoldTip.showTip()

		elseif(_hadBuyTimes>=_maxBuyTimes) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2543"))

		else
			local args = Network.argsHandler(1)
			RequestCenter.tower_buyAtkNum(resetAtkNumCallback, args)
		end
		
	elseif (tag == 10002) then
		
	end

	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end
end

--
function showAlert()

	confirmTitle = GetLocalizeStringBy("key_1985")
	cancelTitle = GetLocalizeStringBy("key_1202")

	_hadBuyTimes = TowerCache.getTimesByGoldReset()
	_maxBuyTimes = TowerUtil.getMaxGoldBuyResetTimes()

	_costGold = TowerCache.getGoldByResetTimes(_hadBuyTimes + 1)

	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end

	-- layer
	alertLayer = CCLayerColor:create(ccc4(0,0,0,155))
	alertLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(alertLayer, 2000)

	-- 背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	alertBg:setPreferredSize(CCSizeMake(520, 360))
	alertBg:setAnchorPoint(ccp(0.5, 0.5))
	alertBg:setPosition(ccp(alertLayer:getContentSize().width*0.5, alertLayer:getContentSize().height*0.5))
	alertLayer:addChild(alertBg)
	alertBg:setScale(g_fScaleX)	

	local alertBgSize = alertBg:getContentSize()

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	alertBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-561)
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

    -- 金币图标
    local goldSprite = CCSprite:create("images/common/gold.png")
    goldSprite:setAnchorPoint(ccp(0.5,0.5))
    goldSprite:setPosition(ccp(98, 248))
    alertBg:addChild(goldSprite)

	-- 描述
	local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1375") ..  _costGold .. GetLocalizeStringBy("key_2208") .. (_maxBuyTimes - _hadBuyTimes), g_sFontName, 25, CCSizeMake(460, 160), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0.5, 0.5))
	descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.5))
	alertBg:addChild(descLabel)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-561)
	alertBg:addChild(menuBar)

	-- 确认
	-- local confirmBtn = LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png", menuAction )
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))

    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	-- local cancelBtn = LuaMenuItem.createItemImage("images/tip/btn_cancel_n.png", "images/tip/btn_cancel_n.png", menuAction )
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    -- cancelBtn:setPosition(alertBgSize.width*520/640, alertBgSize.height*0.4))
    cancelBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(cancelBtn, 1, 10002)

	
	confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
	cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
	
end




