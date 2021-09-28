  -- FileName: XunLongGuide.lua 
-- Author: licong 
-- Date: 14-6-25 
-- Purpose: 寻龙新手


module("XunLongGuide", package.seeall)

--[==[寻龙 新手引导屏蔽层
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideFindDragon) then
	require "script/guide/XunLongGuide"
	XunLongGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[寻龙 清除新手引导
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideFindDragon) then
	require "script/guide/XunLongGuide"
	XunLongGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[寻龙 第一步
---------------------新手引导---------------------------------
function addGuideXunLongGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideFindDragon
	require "script/guide/XunLongGuide"
    if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local button = MenuLayer.getMenuItemNode(4)
        local touchRect   = getSpriteScreenRect(button)
        XunLongGuide.show(1, touchRect)
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
		print("XunLongGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("XunLongGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2001) then
		print("XunLongGuide stepNum 2001")
		local layer = create2001Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2002) then
		print("XunLongGuide stepNum 2002")
		local layer = create2002Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("XunLongGuide stepNum 3")
		local layer = create3Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("XunLongGuide stepNum 4")
		local layer = create4Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("XunLongGuide stepNum 5")
		local layer = create5Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("XunLongGuide stepNum 6")
		local layer = create6Layer(touchRect,touchRect2)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("XunLongGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("XunLongGuide stepNum 8")
		local layer = create8Layer(touchRect)
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


--  寻龙 第1步 活动按钮
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
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1105"), g_sFontName, 24, CCSizeMake(200, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(90)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")

	return layer
end


-- 寻龙 第2步 进入活动点寻龙按钮
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
	
	local str = GetLocalizeStringBy("lic_1106")
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

--显示寻龙说明
-- 寻龙 第2步 进入活动点寻龙按钮
function create2001Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,nil,function ( ... )
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
	    if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 2001) then
	    	changLayer()
	    	require "script/ui/forge/FindTreasureResetDialog"
	    	local touchRect   = getSpriteScreenRect(FindTreasureResetDialog.getNormalItem())
	        XunLongGuide.show(2002, touchRect)
	    end
	end)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,210))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	require "db/DB_Normal_config"
	local str = GetLocalizeStringBy("lcyx_151", DB_Normal_config.getDataById(1).explorelongtestneed)
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 25))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	-- local arrowSprite = CCSprite:create("images/guide/arrow.png")
	-- arrowSprite:setAnchorPoint(ccp(1, 0.5))
	-- arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y))
	-- layer:addChild(arrowSprite)
	-- arrowSprite:setRotation(270)
	-- setAdaptNode(arrowSprite)
	-- runMoveAction(arrowSprite)

	print("create2001Layer")

	return layer
end


--选择寻龙模式
function create2002Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(250,157))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.65, 0.15))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("lic_1106")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(150, 125),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(16, 0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y+touchRect.size.height))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(90)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2002Layer")

	return layer
end

-- 寻龙 第3步 进入寻龙界面提示1
function create3Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第4步
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
		if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 3) then
	        XunLongGuide.show(4, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
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
	
	local str = GetLocalizeStringBy("lic_1107")
	local talkLabel  = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create3Layer")

	return layer
end


-- 寻龙 第4步 
function create4Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第4步
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
		if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 4) then
			require "script/ui/forge/FindTreasureLayer"
			local button = FindTreasureLayer.getActTitle()
       		local touchRect   = getSpriteScreenRect(button)
	        XunLongGuide.show(5, touchRect)
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
	talkDialog:setContentSize(CCSizeMake(320,230))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1108")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 170),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create4Layer")

	return layer
end


-- 寻龙 第5步 
function create5Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第6步
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
		if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 5) then
	        XunLongGuide.show(6, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
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
	
	local talkString = GetLocalizeStringBy("lic_1109")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create5Layer")

	return layer
end


-- 寻龙 第6步 
function create6Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第7步
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
		if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 6) then
			require "script/ui/forge/FindTreasureLayer"
			local button = FindTreasureLayer.getHpBg()
       		local touchRect   = getSpriteScreenRect(button)
	        XunLongGuide.show(7, touchRect)
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
	talkDialog:setContentSize(CCSizeMake(320,230))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1110")
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
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第8步
		require "script/guide/NewGuide"
		require "script/guide/XunLongGuide"
		if(NewGuide.guideClass ==  ksGuideFindDragon and XunLongGuide.stepNum == 7) then
	        XunLongGuide.show(8, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
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
	
	local talkString = GetLocalizeStringBy("lic_1111")
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
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		---[==[寻龙 清除新手引导
		---------------------新手引导---------------------------------
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		NewGuide.saveGuideClass()
		BTUtil:setGuideState(false)
		---------------------end-------------------------------------
		--]==]
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	-- guidGirl
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
	
	local talkString = GetLocalizeStringBy("lic_1112")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create8Layer")

	return layer
end







































































































