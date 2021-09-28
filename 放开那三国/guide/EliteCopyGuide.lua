-- FileName: EliteCopyGuide.lua 
-- Author: Li Cong 
-- Date: 13-9-26 
-- Purpose: 精英副本新手引导


module("EliteCopyGuide", package.seeall)


--[==[精英副本 新手引导屏蔽层
---------------------新手引导---------------------------------
--add by licong 2013.09.26
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideEliteCopy) then
	require "script/guide/EliteCopyGuide"
	EliteCopyGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[精英副本 清除新手引导
---------------------新手引导---------------------------------
--add by licong 2013.09.26
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideEliteCopy) then
	require "script/guide/EliteCopyGuide"
	EliteCopyGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[精英副本 第一步
---------------------新手引导---------------------------------
function addGuideEliteCopyGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideEliteCopy
	require "script/guide/EliteCopyGuide"
    if(NewGuide.guideClass ==  ksGuideEliteCopy and EliteCopyGuide.stepNum == 0) then
       	require "script/ui/main/MenuLayer"
        local eliteButton = MenuLayer.getMenuItemNode(3)
        local touchRect   = getSpriteScreenRect(eliteButton)
        EliteCopyGuide.show(1, touchRect)
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
		print("EliteCopyGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("EliteCopyGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("EliteCopyGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("EliteCopyGuide stepNum 4")
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


--  精英副本 副本引导 第1步
function create1Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.93,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(280,127))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.21, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1625"), g_sFontName, 24, CCSizeMake(200, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(30, 0))
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


-- 精英副本 第2步 选择精英副本
function create2Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y+touchRect.size.height * 0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2Layer")

	return layer
end


-- 精英副本 第3步 点击副本cell
function create3Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create3Layer")

	return layer
end


-- 精英副本 第4步 战斗按钮
function create4Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y+touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create4Layer")

	return layer
end
















