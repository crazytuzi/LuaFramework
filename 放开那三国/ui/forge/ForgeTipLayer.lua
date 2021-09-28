-- FileName: ForgeTipLayer.lua 
-- Author: licong 
-- Date: 14-6-24 
-- Purpose: function description of module 


module("ForgeTipLayer", package.seeall)

local alertLayer 				= nil
local kTagyes 					= 10001
local kTagCancel				= 10002
local _sender 					= nil
local _yesCallFun 				= nil

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
		alertLayer:registerScriptTouchHandler(onTouchesHandler, false, -5600, true)
		alertLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		alertLayer:unregisterScriptTouchHandler()
        alertLayer = nil
	end
end


local function closeAction()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end
end

-- 按钮响应
local function menuAction( tag, itemBtn )
	-- 关闭
	closeAction()

	if(tag == kTagyes) then
		if(_yesCallFun ~= nil)then
			_yesCallFun(_sender,_retCostNum)
		end
	elseif(tag == kTagCancel)then
	else
	end
end

-- 提示界面
-- srcData:要消耗的装备信息
-- disData:要铸造的装备信息
-- yesCallFun:确定按钮回调
function showTipLayer( p_srcData, p_disData, sender, p_yesCallFun, p_disQuality )
	_sender = sender
	_yesCallFun = p_yesCallFun
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
	-- 确定将
	local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1094"), g_sFontName, 25)
    font1:setColor(ccc3(0x78, 0x25, 0x00))
    font1:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font1)
    -- 消耗的装备名字
    local srcQuality = ItemUtil.getEquipQualityByItemInfo( p_srcData )
   	local srcNameColor = HeroPublicLua.getCCColorByStarLevel(srcQuality)
	local srcItemName = CCRenderLabel:create(p_srcData.itemDesc.name, g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	srcItemName:setColor(srcNameColor)
	srcItemName:setAnchorPoint(ccp(0, 0.5))
	alertBg:addChild(srcItemName)
	-- 铸造成
	local font2 = CCLabelTTF:create(GetLocalizeStringBy("lic_1095"), g_sFontName, 25)
    font2:setColor(ccc3(0x78, 0x25, 0x00))
    font2:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font2)
    -- 铸造出装备的名字
    local disQuality = p_disQuality or p_disData.quality
    local desNameColor = HeroPublicLua.getCCColorByStarLevel(disQuality)
	local desItemName = CCRenderLabel:create(p_disData.name, g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	desItemName:setColor(desNameColor)
	desItemName:setAnchorPoint(ccp(0, 0.5))
	alertBg:addChild(desItemName)
    -- ？
    local font3 = CCLabelTTF:create(GetLocalizeStringBy("lic_1096"), g_sFontName, 25)
    font3:setColor(ccc3(0x78, 0x25, 0x00))
    font3:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font3)

    -- 第一行居中
    local posX = (alertBg:getContentSize().width-font1:getContentSize().width-srcItemName:getContentSize().width-font2:getContentSize().width-desItemName:getContentSize().width-font3:getContentSize().width)/2
    font1:setPosition(ccp(posX, alertBgSize.height*0.68))
    srcItemName:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width, font1:getPositionY()))
    font2:setPosition(ccp(srcItemName:getPositionX()+srcItemName:getContentSize().width, font1:getPositionY()))
    desItemName:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width, font1:getPositionY()))
    font3:setPosition(ccp(desItemName:getPositionX()+desItemName:getContentSize().width, font1:getPositionY()))

-- 第二行    
	-- （铸造后的
	local font4 = CCLabelTTF:create(GetLocalizeStringBy("lic_1099"), g_sFontName, 25)
    font4:setColor(ccc3(0x78, 0x25, 0x00))
    font4:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font4)
    -- 铸造出的装备名字
    local desItemName1 = CCRenderLabel:create(p_disData.name, g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	desItemName1:setColor(desNameColor)
	desItemName1:setAnchorPoint(ccp(0, 0.5))
	alertBg:addChild(desItemName1)
	-- 强化等级为0且保留原有
	local font5 = CCLabelTTF:create(GetLocalizeStringBy("lic_1100"), g_sFontName, 25)
    font5:setColor(ccc3(0x78, 0x25, 0x00))
    font5:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font5)
    -- 第二行居中
    local posX = (alertBg:getContentSize().width-font4:getContentSize().width-desItemName1:getContentSize().width-font5:getContentSize().width)/2
    font4:setPosition(ccp(posX, alertBgSize.height*0.55))
    desItemName1:setPosition(ccp(font4:getPositionX()+font4:getContentSize().width, font4:getPositionY()))
    font5:setPosition(ccp(desItemName1:getPositionX()+desItemName1:getContentSize().width, font4:getPositionY()))
-- 第三行
	-- 且保留原有洗练属性，
	local font6 = CCLabelTTF:create(GetLocalizeStringBy("lic_1101"), g_sFontName, 25)
    font6:setColor(ccc3(0x78, 0x25, 0x00))
    font6:setAnchorPoint(ccp(0.5, 0.5))
    alertBg:addChild(font6)
    -- 第三行居中
    font6:setPosition(ccp(alertBg:getContentSize().width*0.5,alertBg:getContentSize().height*0.45))
-- 第四行
    -- 返还
	local font7 = CCLabelTTF:create(GetLocalizeStringBy("lic_1102"), g_sFontName, 25)
    font7:setColor(ccc3(0x78, 0x25, 0x00))
    font7:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font7)
    -- 消耗装备的名字
	local srcItemName1 = CCRenderLabel:create(p_srcData.itemDesc.name, g_sFontName,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	srcItemName1:setColor(srcNameColor)
	srcItemName1:setAnchorPoint(ccp(0, 0.5))
	alertBg:addChild(srcItemName1)
	-- 强化费用
	local font8 = CCLabelTTF:create(GetLocalizeStringBy("lic_1103"), g_sFontName, 25)
    font8:setColor(ccc3(0x78, 0x25, 0x00))
    font8:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font8)
    -- 强化的费用数字
    local retCostNum = CCRenderLabel:create(p_srcData.va_item_text.armReinforceCost, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    retCostNum:setColor(ccc3(0x00, 0xff, 0x18))
    retCostNum:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(retCostNum)
    -- 银币）
	local font9 = CCLabelTTF:create(GetLocalizeStringBy("lic_1104"), g_sFontName, 25)
    font9:setColor(ccc3(0x78, 0x25, 0x00))
    font9:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font9)

    -- 第四行居中
    local posX = (alertBg:getContentSize().width-font7:getContentSize().width-srcItemName1:getContentSize().width-font8:getContentSize().width-retCostNum:getContentSize().width-font9:getContentSize().width)/2
    font7:setPosition(ccp(posX, alertBgSize.height*0.35))
    srcItemName1:setPosition(ccp(font7:getPositionX()+font7:getContentSize().width, font7:getPositionY()))
    font8:setPosition(ccp(srcItemName1:getPositionX()+srcItemName1:getContentSize().width, font7:getPositionY()))
    retCostNum:setPosition(ccp(font8:getPositionX()+font8:getContentSize().width, font7:getPositionY()))
    font9:setPosition(ccp(retCostNum:getPositionX()+retCostNum:getContentSize().width, font7:getPositionY()))


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







