-- FileName: StarHeroGuide.lua 
-- Author: Li Cong 
-- Date: 13-10-9 
-- Purpose: function description of module 


module("StarHeroGuide", package.seeall)

--[==[名将 新手引导屏蔽层
---------------------新手引导---------------------------------
--add by licong 2013.09.29
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideGreatSoldier) then
	require "script/guide/StarHeroGuide"
	StarHeroGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[名将 清除新手引导
---------------------新手引导---------------------------------
--add by licong 2013.09.29
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideGreatSoldier) then
	require "script/guide/StarHeroGuide"
	StarHeroGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[名将 第一步
---------------------新手引导---------------------------------
function addGuideStarHeroGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideGreatSoldier
	require "script/guide/StarHeroGuide"
    if(NewGuide.guideClass ==  ksGuideGreatSoldier and StarHeroGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local starHeroButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagFair)
        local touchRect   = getSpriteScreenRect(starHeroButton)
        StarHeroGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数

-- 显示步骤
function show( p_stepNum,touchRect )

	require "script/guide/NewGuide"
	NewGuide.saveGuideClass()
	NewGuide.saveGuideStep(p_stepNum)

	if(touchRect ~= nil)then
		print("touchRect = (" .. touchRect.origin.x .. "," .. touchRect.origin.y .. "," .. touchRect.size.width .. "," .. touchRect.size.height .. ")")
	end
	if(maskLayer ~= nil) then
		maskLayer:removeFromParentAndCleanup(true)
		maskLayer = nil
	end
	print("maskLayer = " , maskLayer)
	stepNum = p_stepNum
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if(stepNum == 1) then
		print("StarHeroGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("StarHeroGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("StarHeroGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("StarHeroGuide stepNum 4")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	end
end


function changLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer = BaseUI.createMaskLayer(-5000)
	runningScene:addChild(maskLayer, 10000, ktChangeLayerTag)
	print("maskLayer = " , maskLayer, " stepNum = ", stepNum)
end

function cleanLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	runningScene:removeChildByTag(ktChangeLayerTag, true)
end


--  名将 第1步 点名将按钮
function create1Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1503"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	talkLabel:setPosition(ccp(28, 40))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")

	return layer
end

-- 名将 第2步
function create2Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 名将第3步
		require "script/guide/NewGuide"
		require "script/guide/StarHeroGuide"
	    if(NewGuide.guideClass ==  ksGuideGreatSoldier and StarHeroGuide.stepNum == 2) then
	        StarHeroGuide.show(3, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,177))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1520")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create2Layer")

	return layer
end


-- 名将 第3步
function create3Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		---[==[名将 第4步 点击礼物
		---------------------新手引导---------------------------------
		require "script/guide/NewGuide"
		require "script/guide/StarHeroGuide"
	    if(NewGuide.guideClass ==  ksGuideGreatSoldier and StarHeroGuide.stepNum == 3) then
	    	require "script/ui/star/StarLayer"
	        local starHeroButton = StarLayer.getGuideObject_2()
	        local touchRect   = getSpriteScreenRect(starHeroButton)
	        StarHeroGuide.show(4, touchRect)
	    end
		---------------------end-------------------------------------
		--]==]
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.2))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("key_1264")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create3Layer")
	return layer
end


--  名将 第4步 点击送礼
function create4Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2717"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	talkLabel:setPosition(ccp(28, 40))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create4Layer")

	return layer
end












