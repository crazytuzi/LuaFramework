-- Filename：	OneKeyTip.lua
-- Author：		Zhang Zihang
-- Date：		2014-8-24
-- Purpose：		带金币的提示和技能名字等等

module("OneKeyTip", package.seeall)

require "script/utils/BaseUI"
require "script/ui/replaceSkill/ReplaceSkillData"

local _cormfirmCBFunc = nil 

local alertLayer

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


-- 按钮响应
function menuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	print ("tag==", tag)
	if(tag == 10001) then
		-- 回调
		if (_cormfirmCBFunc) then
			_cormfirmCBFunc(true)
		end
	elseif (tag == 10002) then
		
	end

	if(alertLayer) then
		alertLayer:removeFromParentAndCleanup(true)
		alertLayer = nil
	end
end

--
function showAlert(p_goldNum, p_curFlower,confirmCBFunc)
	_cormfirmCBFunc = confirmCBFunc

	confirmTitle = GetLocalizeStringBy("key_1985")
	cancelTitle = GetLocalizeStringBy("key_1202")


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
    -- local goldSprite = CCSprite:create("images/common/gold.png")
    -- goldSprite:setAnchorPoint(ccp(0.5,0.5))
    -- goldSprite:setPosition(ccp(110+5*25, 225))
    -- alertBg:addChild(goldSprite)


	-- 描述
	-- local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2848") ..  gold_num .. tip_text, g_sFontName, 25, CCSizeMake(460, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	-- descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	-- descLabel:setAnchorPoint(ccp(0.5, 0.5))
	-- descLabel:setPosition(ccp(alertBgSize.width * 0.5, alertBgSize.height*0.5))
	-- alertBg:addChild(descLabel)

	local descLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1120") .. p_goldNum,g_sFontName,25)
	descLabel_1:setColor(ccc3(0x78,0x25,0x00))
	local goldSprite = CCSprite:create("images/common/gold.png")
	local descLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1121"),g_sFontName,25)
	descLabel_2:setColor(ccc3(0x78,0x25,0x00))
	local eventSprite = CCSprite:create("images/replaceskill/newflip/flower/" .. p_curFlower .. ".png")
	local descLabel_3 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1122"),g_sFontName,25)
	descLabel_3:setColor(ccc3(0x78,0x25,0x00))

	local node_1 = BaseUI.createHorizontalNode({descLabel_1,goldSprite,descLabel_2,eventSprite,descLabel_3})
	node_1:setAnchorPoint(ccp(0.5,1))
	node_1:setPosition(ccp(alertBg:getContentSize().width/2,250))
	alertBg:addChild(node_1)

	local descLabel_4 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1130"),g_sFontName,25)
	descLabel_4:setColor(ccc3(0x78,0x25,0x00))
	local eventFinalSprite = CCSprite:create("images/replaceskill/newflip/flower/1.png")
	local descLabel_8 = CCLabelTTF:create("(",g_sFontName,25)
	descLabel_8:setColor(ccc3(0x78,0x25,0x00))
	local descLabel_5 = CCRenderLabel:create(GetLocalizeStringBy("zzh_1117"),g_sFontName,25,1,ccc3(0,0,0),type_stroke)
	descLabel_5:setColor(ccc3(0xe4,0x00,0xff))
	local descLabel_6 = CCRenderLabel:create("+" .. ReplaceSkillData.getHonorNumById(1),g_sFontName,25,1,ccc3(0,0,0),type_stroke)
	descLabel_6:setColor(ccc3(0x00,0xff,0x18))
	local descLabel_7 = CCLabelTTF:create(")",g_sFontName,25)
	descLabel_7:setColor(ccc3(0x78,0x25,0x00))

	local node_2 = BaseUI.createHorizontalNode({descLabel_4,eventFinalSprite,descLabel_8,descLabel_5,descLabel_6,descLabel_7})
	node_2:setAnchorPoint(ccp(0.5,1))
	node_2:setPosition(ccp(alertBg:getContentSize().width/2,220))
	alertBg:addChild(node_2)

	-- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-561)
	alertBg:addChild(menuBar)

	-- 确认
	require "script/libs/LuaCC"
	local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), confirmTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	confirmBtn:setAnchorPoint(ccp(0.5, 0.5))

    confirmBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(confirmBtn, 1, 10001)
	
	-- 取消
	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), cancelTitle,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:registerScriptTapHandler(menuAction)
	menuBar:addChild(cancelBtn, 1, 10002)

	
	confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
	cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
	
end




