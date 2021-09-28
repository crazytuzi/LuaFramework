-- Filename: CopyBoxGuide.lua
-- Author: 李晨阳
-- Date: 2013-09-10
-- Purpose: 

--[==[副本箱子 新手引导屏蔽层
---------------------新手引导---------------------------------
	--add by licong 2013.09.11
	require "script/guide/NewGuide"
	if(NewGuide.guideClass ==  ksGuideCopyBox) then
		require "script/guide/CopyBoxGuide"
		CopyBoxGuide.changLayer()
	end
---------------------end-------------------------------------
--]==]

--[==[副本箱子 新手引导清除引导
---------------------新手引导---------------------------------
	--add by licong 2013.09.11
	require "script/guide/NewGuide"
	if(NewGuide.guideClass ==  ksGuideCopyBox) then
		require "script/guide/CopyBoxGuide"
		CopyBoxGuide.cleanLayer()
	end
---------------------end-------------------------------------
--]==]

--[==[  副本箱子 第1步 箱子
---------------------新手引导---------------------------------
    --add by licong 2013.09.11
    print("start CopyBoxGuide")
    require "script/guide/NewGuide"
    NewGuide.guideClass  = ksGuideCopyBox
    if(NewGuide.guideClass ==  ksGuideCopyBox) then
	    require "script/guide/CopyBoxGuide"
	    require "script/ui/copy/FortsLayout"
	    local copyBoxGuide_button = FortsLayout.getGuideObject_2()
	    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	    CopyBoxGuide.show(1, touchRect)
   	end
 ---------------------end-------------------------------------
--]==]

--[==[  副本箱子 第2步 领取奖励
---------------------新手引导---------------------------------
    --add by licong 2013.09.11
    require "script/guide/NewGuide"
	require "script/guide/CopyBoxGuide"
    if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 1) then
	    require "script/ui/copy/CopyRewardLayer"
	    local copyBoxGuide_button = CopyRewardLayer.getGuideObject()
	    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	    CopyBoxGuide.show(2, touchRect)
   	end
 ---------------------end-------------------------------------
--]==]

module ("CopyBoxGuide", package.seeall)

function CopyFirstDidOver( )
	require "script/ui/copy/CopyUtil"
	CopyUtil.isFirstPassCopy_1 = false
	---[==[  副本箱子 第1步 箱子
	---------------------新手引导---------------------------------
	--add by licong 2013.09.11
	print("start CopyBoxGuide")
	require "script/guide/NewGuide"
	
	NewGuide.guideClass = ksGuideCopyBox 
	BTUtil:setGuideState(true)
	require "script/guide/CopyBoxGuide"
   	if(NewGuide.guideClass ==  ksGuideCopyBox and CopyBoxGuide.stepNum == 0 ) then
	    require "script/ui/copy/FortsLayout"
	    local copyBoxGuide_button = FortsLayout.getGuideObject_2()
	    local touchRect = getSpriteScreenRect(copyBoxGuide_button)
	    CopyBoxGuide.show(1, touchRect)
	end

	 ---------------------end-------------------------------------
	--]==]
end


local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数

-- 显示步骤
function show( p_stepNum,touchRect )

	require "script/guide/NewGuide"
	NewGuide.saveGuideClass()
	NewGuide.saveGuideStep(p_stepNum)
	
	print("CopyBoxGuide show")
	if(maskLayer ~= nil) then
		maskLayer:removeFromParentAndCleanup(true)
		print("remove maskLayer")
		maskLayer = nil
	end
	print("maskLayer = " , maskLayer)
	stepNum = p_stepNum
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	if(stepNum == 1) then
		print("CopyBoxGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("CopyBoxGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2.5) then
		print("CopyBoxGuide stepNum 2.5")
		local layer = create2_5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("CopyBoxGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("CopyBoxGuide stepNum 4")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("CopyBoxGuide stepNum 5")
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("CopyBoxGuide stepNum 6")
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("CopyBoxGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("CopyBoxGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	end	
end


function changLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer =  nil

	if(stepNum == 5) then
		maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	else
		maskLayer = BaseUI.createMaskLayer(-5000)
	end

	runningScene:addChild(maskLayer, 10000, ktChangeLayerTag)
	print("maskLayer = " , maskLayer)
end

function cleanLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	runningScene:removeChildByTag(ktChangeLayerTag, true)
end

-- 副本箱子 第1步
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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2435")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")


	local menu = CCMenu:create()
	menu:setTouchPriority(-5005)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	layer:addChild(menu)

	local skipButton = CCMenuItemImage:create("images/intro/skip1.png","images/intro/skip2.png")
    skipButton:setAnchorPoint(ccp(1, 0))
    skipButton:setPosition(ccps(0.95, 0.05))
    skipButton:registerScriptTapHandler(function ( ... )
       	layer:removeFromParentAndCleanup(true)
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		BTUtil:setGuideState(false)
		NewGuide.saveGuideClass()
    end)
    menu:addChild(skipButton)
    skipButton:setScale(g_fElementScaleRatio)

	return layer
end



-- 副本箱子 第2步 点击领取 透明处理
function create2Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2Layer")

	return layer
end


-- 副本箱子 第2.5步 点击领取弹出的框 透明处理
function create2_5Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2_5Layer")

	return layer
end


-- 副本箱子 第3步 返回按钮
function create3Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	-- --girl
	-- local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	-- guidGirl:setAnchorPoint(ccp(0, 0))
	-- guidGirl:setPosition(ccps(0.1,0.2))
	-- layer:addChild(guidGirl)
	-- setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(1 * guidGirl:getScaleX())
	-- --talk
	-- local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	-- talkDialog:setContentSize(CCSizeMake(280,197))
	-- talkDialog:setAnchorPoint(ccp(0,0))
	-- talkDialog:setPosition(ccps(0.45, 0.43))
	-- layer:addChild(talkDialog)
	-- setAdaptNode(talkDialog)

	-- local str = GetLocalizeStringBy("key_1556")
	-- local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	-- talkLabel:setAnchorPoint(ccp(0,0))
	-- talkLabel:setPosition(ccp(56, 20))
	-- talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	-- talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create3Layer")

	return layer
end


-- 副本箱子 第4步 商店 跳过此步骤
function create4Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

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


-- 副本箱子 第5步 招将 跳过此步骤
function create5Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightTop.png")
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.1, 0.2))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkString = GetLocalizeStringBy("key_3318")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 25))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height*0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create5Layer")

	return layer
end

-- 副本箱子 第6步 退出招将 跳过此步骤
function create6Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")

	return layer
end


-- 副本箱子 第7步  副本 跳过此步骤
function create7Layer(touchRect)

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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1932")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create7Layer")

	return layer
end


-- -- 副本箱子 第8步 副本选择 全屏提示
-- function create8Layer(touchRect)
-- 	local layer = nil
-- 	local function callBackFun( ... )
-- 		layer:removeFromParentAndCleanup(true)
-- 		require "script/guide/NewGuide"
-- 		NewGuide.guideClass = ksGuideClose
-- 		NewGuide.saveGuideClass()
-- 		BTUtil:setGuideState(false)
-- 	end
-- 	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun,100)
-- 	--girl
-- 	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
-- 	guidGirl:setAnchorPoint(ccp(0, 0))
-- 	guidGirl:setPosition(ccps(0.1,0.1))
-- 	layer:addChild(guidGirl)
-- 	setAdaptNode(guidGirl)
-- 	guidGirl:setScaleX(1 * guidGirl:getScaleX())
-- 	--talk
-- 	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
-- 	talkDialog:setContentSize(CCSizeMake(320,197))
-- 	talkDialog:setAnchorPoint(ccp(0,0))
-- 	talkDialog:setPosition(ccps(0.45, 0.43))
-- 	layer:addChild(talkDialog)
-- 	setAdaptNode(talkDialog)
	
-- 	local str = GetLocalizeStringBy("key_1932")
-- 	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
-- 	talkLabel:setAnchorPoint(ccp(0,0))
-- 	talkLabel:setPosition(ccp(56, 40))
-- 	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
-- 	talkDialog:addChild(talkLabel)

-- 	print("create8Layer")

-- 	return layer
-- end

-- 副本箱子 第8步  副本选择 
function create8Layer(touchRect)

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
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.30))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_1932")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(250, 130),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create8Layer")

	return layer
end
