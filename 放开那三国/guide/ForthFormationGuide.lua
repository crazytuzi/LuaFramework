-- FileName: ForthFormationGuide.lua 
-- Author: Li Cong 
-- Date: 13-9-11 
-- Purpose: function description of module 

--[==[第4个上阵栏位开启 新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideForthFormation) then
		require "script/guide/ForthFormationGuide"
		ForthFormationGuide.changLayer()
	end
	---------------------end-------------------------------------
--]==]

--[==[第4个上阵栏位开启 新手引导清除
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideForthFormation) then
		require "script/guide/ForthFormationGuide"
		ForthFormationGuide.cleanLayer()
	end
	---------------------end-------------------------------------
--]==]

--[==[ 第4个上阵栏位开启 第1步 阵容
---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    print("start ForthFormationGuide guide")
    require "script/guide/NewGuide"
    NewGuide.guideClass  = ksGuideForthFormation
    if(NewGuide.guideClass ==  ksGuideForthFormation) then
        require "script/guide/ForthFormationGuide"
        require "script/ui/main/MenuLayer"
        local forthFormationGuide_button = MenuLayer.getMenuItemNode(2)
        local touchRect = getSpriteScreenRect(forthFormationGuide_button)
        ForthFormationGuide.show(1, touchRect)
    end
 ---------------------end-------------------------------------
--]==]

--[==[ 第4个上阵栏位开启 第2步 第四个加号
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/ui/level_reward/LevelRewardLayer"
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/ForthFormationGuide"
    if(NewGuide.guideClass ==  ksGuideForthFormation and ForthFormationGuide.stepNum == 1) then
        local forthFormationGuide_button = getGuideTopCell(3)
        local touchRect = getSpriteScreenRect(forthFormationGuide_button)
        ForthFormationGuide.show(2, touchRect)
    end
	---------------------end-------------------------------------
--]==]

module("ForthFormationGuide", package.seeall)

local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002

local maskLayer = nil
stepNum = 0 				--引导步数
fightTimes = 0              --战斗次数

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
		print("ForthFormationGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("ForthFormationGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("ForthFormationGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	end
end


function changLayer( ... )

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer = BaseUI.createMaskLayer(-5000)
	runningScene:addChild(maskLayer, 10000, ktChangeLayerTag)
	print("maskLayer = " , maskLayer)
end

function cleanLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	runningScene:removeChildByTag(ktChangeLayerTag, true)
end


-- 等级礼包引导 第1步 阵容
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
	talkDialog:setContentSize(CCSizeMake(310,127))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3247"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(30, 20))
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
	print("create1Layer")

	return layer
end


-- 等级礼包引导 第2步 都4个位置
function create2Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create2Layer")

	return layer
end



-- 等级礼包引导 第3步 提示
function create3Layer(touchRect)
	local layer = nil
	local function callBackFun( ... )
		layer:removeFromParentAndCleanup(true)
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		BTUtil:setGuideState(false)
		NewGuide.saveGuideClass()
	end
	layer = BaseUI.createMaskLayer(-5000,touchRect,callBackFun)
	
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
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2459"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(26, 40))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create3Layer")

	require "script/guide/NewGuide"
	NewGuide.guideClass = ksGuideClose
	BTUtil:setGuideState(false)
	NewGuide.saveGuideClass()
	return layer
end







