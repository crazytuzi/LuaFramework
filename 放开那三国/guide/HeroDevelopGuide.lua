-- FileName: HeroDevelopGuide.lua 
-- Author: licong 
-- Date: 14-9-18 
-- Purpose: 武将进化


module("HeroDevelopGuide", package.seeall)

--[==[武将进化 新手引导屏蔽层
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideHeroDevelop) then
	require "script/guide/HeroDevelopGuide"
	HeroDevelopGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[武将进化 清除新手引导
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideHeroDevelop) then
	require "script/guide/HeroDevelopGuide"
	HeroDevelopGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[武将进化 第一步
---------------------新手引导---------------------------------
function addGuideHeroDevelopGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideHeroDevelop
	require "script/guide/HeroDevelopGuide"
    if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 0) then
       	require "script/ui/main/MainBaseLayer"
     	local button = MainBaseLayer.getMainMenuItem(MainBaseLayer._ksTagHero)
        local touchRect   = getSpriteScreenRect(button)
        HeroDevelopGuide.show(1, touchRect)
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
		print("HeroDevelopGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("HeroDevelopGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("HeroDevelopGuide stepNum 3")
		local layer = create3Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("HeroDevelopGuide stepNum 4")
		local layer = create4Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("HeroDevelopGuide stepNum 5")
		local layer = create5Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("HeroDevelopGuide stepNum 6")
		local layer = create6Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("HeroDevelopGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("HeroDevelopGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		print("HeroDevelopGuide stepNum 9")
		local layer = create9Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 10) then
		print("HeroDevelopGuide stepNum 10")
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


--  武将进化 第1步 活动按钮
function create1Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.25))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setPosition(ccps(0.65, 0.6))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1236"), g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")

	return layer
end


-- 武将进化 第2步 进入武将界面点武将进化按钮
function create2Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil)
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
	
	local str = GetLocalizeStringBy("lic_1237")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(270)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2Layer")

	return layer
end


-- 武将进化 第3步 进入武将进化界面提示1
function create3Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第4步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 3) then
	        HeroDevelopGuide.show(4, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.5))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,200))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.45))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("lic_1238")
	local talkLabel  = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create3Layer")

	return layer
end


-- 武将进化 第4步 
function create4Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第5步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 4) then
	        HeroDevelopGuide.show(5, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,230))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1239")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 170),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create4Layer")

	return layer
end


-- 武将进化 第5步 
function create5Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第6步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 5) then
	        HeroDevelopGuide.show(6, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.2))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,200))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.3))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1240")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create5Layer")

	return layer
end


-- 武将进化 第6步 
function create6Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第7步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 6) then
	        HeroDevelopGuide.show(7, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,230))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1241")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create6Layer")

	return layer
end


--  名将 第7步 
function create7Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第8步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 7) then
	        HeroDevelopGuide.show(8, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,200))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.2))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1242")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create7Layer")

	return layer
end

--  名将 第8步 
function create8Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第9步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 8) then
	        HeroDevelopGuide.show(9, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setPosition(ccps(0.65, 0.5))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1243"), g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create8Layer")

	return layer
end

--  名将 第9步 
function create9Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第10步
		require "script/guide/NewGuide"
		require "script/guide/HeroDevelopGuide"
		if(NewGuide.guideClass ==  ksGuideHeroDevelop and HeroDevelopGuide.stepNum == 9) then
	        HeroDevelopGuide.show(10, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.5))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,200))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.6))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1244")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create9Layer")

	return layer
end

--  名将 第10步 
function create10Layer(touchRect)
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		---[==[武将进化 清除新手引导
		---------------------新手引导---------------------------------
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		---------------------end-------------------------------------
		--]==]
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,0)
	-- guidGirl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,170))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1245")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create10Layer")

	return layer
end
