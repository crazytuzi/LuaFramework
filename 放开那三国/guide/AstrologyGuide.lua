-- FileName: AstrologyGuide.lua 
-- Author: Li Cong 
-- Date: 13-10-8 
-- Purpose: function description of module 


module("AstrologyGuide", package.seeall)

--[==[占星 新手引导屏蔽层
---------------------新手引导---------------------------------
--add by licong 2013.09.29
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideAstrology) then
	require "script/guide/AstrologyGuide"
	AstrologyGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[占星 清除新手引导
---------------------新手引导---------------------------------
--add by licong 2013.09.29
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideAstrology) then
	require "script/guide/AstrologyGuide"
	AstrologyGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[占星 第一步
---------------------新手引导---------------------------------
function addGuideAstrologyGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideAstrology
	require "script/guide/AstrologyGuide"
    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
        local astrologyButton = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHoroscope)
        local touchRect   = getSpriteScreenRect(astrologyButton)
        AstrologyGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数

-- 显示步骤
function show( p_stepNum,touchRect,touchRect2)

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
		print("AstrologyGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("AstrologyGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("AstrologyGuide stepNum 3")
		local layer = create3Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("AstrologyGuide stepNum 4")
		local layer = create4Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("AstrologyGuide stepNum 5")
		local layer = create5Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("AstrologyGuide stepNum 6")
		local layer = create6Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("AstrologyGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("AstrologyGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		print("AstrologyGuide stepNum 9")
		local layer = create9Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 10) then
		print("AstrologyGuide stepNum 10")
		local layer = create10Layer(touchRect)
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


--  占星 第1步 点占星按钮
function create1Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(280,137))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2256"), g_sFontName, 24, CCSizeMake(200, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")

	return layer
end


-- 占星 第2步 进入占星介绍
function create2Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 占星 第3步 
		require "script/guide/NewGuide"
		require "script/guide/AstrologyGuide"
	    if(NewGuide.guideClass ==  ksGuideAstrology and AstrologyGuide.stepNum == 2) then
	       	require "script/ui/astrology/AstrologyLayer"
	        local astrologyButton1 = AstrologyLayer.getAstroButtonByIndex(2)
	        local astrologyButton2 = AstrologyLayer.getTargetAstroByIndex(2)
	        local touchRect1 = getSpriteScreenRect(astrologyButton1)
	        local touchRect2 = getSpriteScreenRect(astrologyButton2)
	        AstrologyGuide.show(3, touchRect1,touchRect2)
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
	
	local str = GetLocalizeStringBy("key_2144")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create2Layer")

	return layer
end


-- 占星 第3步 两步提示语 第一次点击
function create3Layer(touchRect1,touchRect2)
	local layer = BaseUI.createMaskLayer(-5000,touchRect1,nil,nil,touchRect2)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect1.origin.x + touchRect1.size.width*0.5, touchRect1.origin.y + touchRect1.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	-- 第一次提示语
	local layer1 = nil
	local function callBackFun( ... )
		layer1:removeFromParentAndCleanup(true)

		-- 第二次提示语
		local layer2 = nil
		local function callBackFun2( ... )
			layer2:removeFromParentAndCleanup(true)
		end
		layer2 = BaseUI.createMaskLayer(-5001,nil,callBackFun2,100)
		layer:addChild(layer2)

		--girl
		local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
		guidGirl:setAnchorPoint(ccp(0, 0))
		guidGirl:setPosition(ccps(0.9,0.4))
		layer2:addChild(guidGirl)
		setAdaptNode(guidGirl)
		guidGirl:setScaleX(-1 * guidGirl:getScaleX())
		--talk
		local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
		talkDialog:setContentSize(CCSizeMake(320,167))
		talkDialog:setAnchorPoint(ccp(0,0))
		talkDialog:setPosition(ccps(0.08, 0.5))
		layer2:addChild(talkDialog)
		setAdaptNode(talkDialog)
		
		local talkString = GetLocalizeStringBy("key_2319")
		local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		talkLabel:setPosition(ccp(25, 25))
		talkLabel:setAnchorPoint(ccp(0,0))
		talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
		talkDialog:addChild(talkLabel)
	end
	layer1 = BaseUI.createMaskLayer(-5001,nil,callBackFun,100)
	layer:addChild(layer1)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.4))
	layer1:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.5))
	layer1:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("key_1260")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 25))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create3Layer")

	return layer
end


-- 占星 第4步 第2次点击
function create4Layer(touchRect1,touchRect2)
	local layer = BaseUI.createMaskLayer(-5000,touchRect1,nil,nil,touchRect2)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect1.origin.x + touchRect1.size.width*0.5, touchRect1.origin.y + touchRect1.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create4Layer")

	return layer
end


-- 占星 第5步 第3次点击
function create5Layer(touchRect1,touchRect2)
	local layer = BaseUI.createMaskLayer(-5000,touchRect1,nil,nil,touchRect2)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect1.origin.x + touchRect1.size.width*0.5, touchRect1.origin.y + touchRect1.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create5Layer")

	return layer
end


-- 占星 第6步 第4次点击
function create6Layer(touchRect1,touchRect2)
	local layer = BaseUI.createMaskLayer(-5000,touchRect1,nil,nil,touchRect2)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect1.origin.x + touchRect1.size.width*0.5, touchRect1.origin.y + touchRect1.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create6Layer")

	return layer
end


--  名将 第7步 点击查看奖励
function create7Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.53))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1430")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(57, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create7Layer")

	return layer
end


--  名将 第8步 点击领奖
function create8Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.53))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2968")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x , touchRect.origin.y + touchRect.size.height*0.5))
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create8Layer")

	return layer
end

-- 占星 第9步 关闭奖励预览版子
function create9Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create9Layer")

	return layer
end

--  名将 第10步 最后提示语
function create10Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		---[==[占星 清除新手引导
		---------------------新手引导---------------------------------
		--add by licong 2013.09.29
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideAstrology) then
			require "script/guide/AstrologyGuide"
			AstrologyGuide.cleanLayer()
			NewGuide.guideClass = ksGuideClose
			BTUtil:setGuideState(false)
			NewGuide.saveGuideClass()
		end
		---------------------end-------------------------------------
		--]==]
	end
	layer = BaseUI.createMaskLayer(-5000,nil,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.63))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2797")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create10Layer")

	return layer
end


















