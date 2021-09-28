-- FileName: PetGuide.lua 
-- Author: Li Cong 
-- Date: 13-9-29 
-- Purpose: function description of module 


module("PetGuide", package.seeall)


local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数

-- 显示步骤
function show( p_stepNum,touchRect )

	require "script/guide/NewGuide"
	NewGuide.saveGuideClass()
	NewGuide.saveGuideStep(p_stepNum)

	print("PetGuide stemp:", p_stepNum)
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
		print("PetGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("PetGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("PetGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("PetGuide stepNum 3")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("PetGuide stepNum 5")
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("PetGuide stepNum 6")
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("PetGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("PetGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("PetGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		print("PetGuide stepNum 9")
		local layer = create9Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 10) then
		print("PetGuide stepNum 10")
		local layer = create10Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 11) then
		print("PetGuide stepNum 11")
		local layer = create11Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 12) then
		print("PetGuide stepNum 12")
		local layer = create12Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 13) then
		print("PetGuide stepNum 13")
		local layer = create13Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 14) then
		print("PetGuide stepNum 14")
		local layer = create14Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 15) then
		print("PetGuide stepNum 15")
		local layer = create15Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 16) then
		print("PetGuide stepNum 16")
		local layer = create16Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 17) then
		print("PetGuide stepNum 17")
		local layer = create17Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 18) then
		print("PetGuide stepNum 18")
		local layer = create18Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 19) then
		print("PetGuide stepNum 19")
		local layer = create19Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 20) then
		print("PetGuide stepNum 20")
		local layer = create20Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 21) then
		print("PetGuide stepNum 21")
		local layer = create21Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 22) then
		print("PetGuide stepNum 22")
		local layer = create22Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 23) then
		print("PetGuide stepNum 23")
		local layer = create23Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)


	end
end


function changLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer = BaseUI.createMaskLayer(-5000)
	runningScene:addChild(maskLayer, 10000, ktChangeLayerTag)
	print("changLayer maskLayer = " , maskLayer, " stepNum = ", stepNum)
end

function cleanLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	runningScene:removeChildByTag(ktChangeLayerTag, true)
end


--  宠物 第1步 点宠物按钮
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
	talkDialog:setContentSize(CCSizeMake(306,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2044"), g_sFontName, 24, CCSizeMake(238, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setPosition(ccp(56,talkDialog:getContentSize().height - 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height*0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")

	return layer
end


-- 宠物 第2步 进入全屏介绍1
function create2Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第3步 进入全屏介绍2
		require "script/guide/NewGuide"
		require "script/guide/PetGuide"
	    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 2) then
	        PetGuide.show(3, touchRect)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,nil,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,187))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2587")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 140),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create2Layer")

	return layer
end

-- 宠物 第3步 进入全屏介绍2
function create3Layer(touchRect)
	local layer = nil
	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.0,0.05))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftTop.png")
	talkDialog:setContentSize(CCSizeMake(290,157))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.3, 0.13))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1148")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(220, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create3Layer")

	return layer
end

-- -- 第4步 上阵按钮引导
function create4Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.32))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_3255")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create4Layer")

	return layer
end

--喂养按钮引导
function create5Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.25))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,107))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.65, 0.45))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2556")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 40),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(36, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	
	print("create5Layer")

	return layer
end


--喂养物品引导6
function create6Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.98,0.25))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,107))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.73, 0.45))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2461")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 40),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(36, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	
	print("create6Layer")

	return layer
end


--喂养物品引导7
function create7Layer(touchRect)
	local layer = nil

	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第3步 进入全屏介绍2
		require "script/guide/NewGuide"
		require "script/guide/PetGuide"
	    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 7) then
	    	require "script/ui/pet/PetFeedLayer"
	    	local button = PetFeedLayer.getFeedBackItem()
	    	local rect   = getSpriteScreenRect(button)
	        PetGuide.show(8, rect)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.98,0.25))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.7, 0.35))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2433")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(18, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	
	print("create7Layer")

	return layer
end

--领悟技能按钮
function create8Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.98,0.35))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.7, 0.55))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	
	local str = GetLocalizeStringBy("key_3274")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(22, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	
	print("create8Layer")

	return layer
end

--点击领悟技能按钮
function create9Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,157))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1050")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 90),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	
	print("create9Layer")

	return layer
end

--领悟技能说明
function create10Layer(touchRect)
	local layer = nil

	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第3步 进入全屏介绍2
		require "script/guide/NewGuide"
		require "script/guide/PetGuide"
	    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 10) then
	    	require "script/ui/pet/PetGraspLayer"
	    	local button = PetGraspLayer.getGraspItem()
	    	local rect   = getSpriteScreenRect(button)
	        PetGuide.show(11, rect)
	    end
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.98,0.35))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,187))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.7, 0.55))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1638")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 120),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(18, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)
	
	print("create9Layer")

	return layer
end

--领悟技能第一下说明
function create11Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
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
	talkDialog:setPosition(ccps(0.45, 0.37))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1766")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create9Layer")

	return layer
end

--领悟技能第二下说明
function create12Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,165))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.37))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2377")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create9Layer")

	return layer
end

--领悟技能返回
function create13Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.98,0.35))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,187))
	talkDialog:setAnchorPoint(ccp(1,1))
	talkDialog:setPosition(ccps(0.7, 0.55))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_3014")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 120),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(18, 20))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width/2, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create9Layer")

	return layer
end

--领悟技能返回
function create14Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第3步 进入全屏介绍2
		require "script/guide/NewGuide"
		require "script/guide/PetGuide"
	    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 14) then
	        PetGuide.show(15, nil)
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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2078")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	print("create9Layer")

	return layer
end

--领悟技能返回
function create15Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		-- 第3步 进入全屏介绍2
		require "script/guide/NewGuide"
		require "script/guide/PetGuide"
	    if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 15) then
	    	require "script/ui/pet/PetMainLayer"
	    	local button = PetMainLayer.getUpBtn()
	    	local rect   = getSpriteScreenRect(button)
	        PetGuide.show(16, rect)
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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1249")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	return layer
end


--领悟技能返回
function create16Layer(touchRect)
	local layer = nil

	layer = BaseUI.createMaskLayer(-5000,touchRect,nil,100)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,137))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_3303")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 70),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height*0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create9Layer")

	return layer
end

--领悟技能返回
function create17Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		-- 结束
		layer:removeFromParentAndCleanup(true)
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		NewGuide.saveGuideClass()
		BTUtil:setGuideState(false)
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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.42))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2386")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)


	return layer
end


