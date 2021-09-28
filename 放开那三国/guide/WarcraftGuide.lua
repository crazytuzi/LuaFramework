-- FileName: WarcraftGuide.lua 
-- Author: licong 
-- Date: 14-11-27 
-- Purpose: 阵法新手引导


module("WarcraftGuide", package.seeall)


--[==[阵法 新手引导屏蔽层
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideWarcraft) then
	require "script/guide/WarcraftGuide"
	WarcraftGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[阵法 清除新手引导
---------------------新手引导---------------------------------
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideWarcraft) then
	require "script/guide/WarcraftGuide"
	WarcraftGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[阵法 第一步
---------------------新手引导---------------------------------
function addGuideWarcraftGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideWarcraft
	require "script/guide/WarcraftGuide"
    if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 0) then
    	BTUtil:setGuideState(true)
       	require "script/ui/main/MenuLayer"
        local button = MenuLayer.getMenuItemNode(2)
        local touchRect   = getSpriteScreenRect(button)
        WarcraftGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]


local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数

-- 显示步骤
function show( p_stepNum,touchRect)

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
		print("WarcraftGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("WarcraftGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("WarcraftGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("WarcraftGuide stepNum 4")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("WarcraftGuide stepNum 5")
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("WarcraftGuide stepNum 6")
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("WarcraftGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("WarcraftGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		print("WarcraftGuide stepNum 9")
		local layer = create9Layer(touchRect)
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


--  阵法 第1步 阵容按钮
function create1Layer(touchRect)
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
	talkDialog:setContentSize(CCSizeMake(280,137))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.53))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1348"), g_sFontName, 24, CCSizeMake(200, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
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


-- 阵法 第2步 进入阵容阵法按钮
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
	
	local str = GetLocalizeStringBy("lic_1349")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x, touchRect.origin.y))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(315)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2Layer")

	return layer
end

-- 阵法 第3步 选择阵法
function create3Layer(touchRect)
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
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("lic_1350")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width, touchRect.origin.y+touchRect.size.height*0.5))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(180)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create3Layer")

	return layer
end

-- 阵法 第4步 启用阵法
function create4Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.4))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,150))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.4))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("lic_1351")
	local talkLabel  = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y+touchRect.size.height))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(90)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create4Layer")

	return layer
end


-- 阵法 第5步 
function create5Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第6步
		require "script/guide/NewGuide"
		require "script/guide/WarcraftGuide"
		if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 5) then
	        WarcraftGuide.show(6, nil)
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
	talkDialog:setContentSize(CCSizeMake(320,170))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1352")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create5Layer")

	return layer
end


-- 阵法 第6步 
function create6Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第7步
		require "script/guide/NewGuide"
		require "script/guide/WarcraftGuide"
		if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 6) then
	        WarcraftGuide.show(7, nil)
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
	
	local talkString = GetLocalizeStringBy("lic_1353")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 160),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create6Layer")

	return layer
end


-- 阵法 第7步 
function create7Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第8步
		require "script/guide/NewGuide"
		require "script/guide/WarcraftGuide"
		if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 7) then
	        WarcraftGuide.show(8, nil)
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
	talkDialog:setContentSize(CCSizeMake(320,170))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1354")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 15))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	print("create7Layer")

	return layer
end


--  阵法 第8步 
function create8Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第9步
		require "script/guide/NewGuide"
		require "script/guide/WarcraftGuide"
		if(NewGuide.guideClass ==  ksGuideWarcraft and WarcraftGuide.stepNum == 8) then
	        WarcraftGuide.show(9, nil)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,190))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.08, 0.4))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1355")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create8Layer")

	return layer
end


--  阵法 第9步 
function create9Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		---[==[阵法 清除新手引导
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
	talkDialog:setContentSize(CCSizeMake(320,170))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("lic_1356")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(50, 5))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create9Layer")

	return layer
end

















































































