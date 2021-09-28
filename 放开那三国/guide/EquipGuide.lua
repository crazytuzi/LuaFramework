-- FileName: EquipGuide.lua 
-- Author: Li Cong 
-- Date: 13-11-25 
-- Purpose: function description of module 


module("EquipGuide", package.seeall)


--[==[铁匠铺 新手引导屏蔽层
---------------------新手引导---------------------------------
--add by licong 2013.09.26
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideSmithy) then
	require "script/guide/EquipGuide"
	EquipGuide.changLayer()
end
---------------------end-------------------------------------
--]==]

--[==[铁匠铺 清除新手引导
---------------------新手引导---------------------------------
--add by licong 2013.09.26
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideSmithy) then
	require "script/guide/EquipGuide"
	EquipGuide.cleanLayer()
end
---------------------end-------------------------------------
--]==]

--[==[铁匠铺 第一步
---------------------新手引导---------------------------------
function addGuideEquipGuide1( ... )
	require "script/guide/NewGuide"
	NewGuide.guideClass  = ksGuideSmithy
	require "script/guide/EquipGuide"
    if(NewGuide.guideClass ==  ksGuideSmithy and EquipGuide.stepNum == 0) then
		BTUtil:setGuideState(true)
		require "script/guide/EquipGuide"
       	require "script/ui/main/MenuLayer"
     	local equipButton = MenuLayer.getMenuItemNode(2)
        local touchRect   = getSpriteScreenRect(equipButton)
        EquipGuide.show(1, touchRect)
    end
end
---------------------end-------------------------------------
--]==]

-- 铁匠铺 引导结束
--[==[铁匠铺 清除新手引导
---------------------新手引导---------------------------------
--add by licong 2013.09.26
require "script/guide/NewGuide"
if(NewGuide.guideClass == ksGuideSmithy) then
	require "script/guide/EquipGuide"
	EquipGuide.cleanLayer()
	NewGuide.guideClass = ksGuideClose
	BTUtil:setGuideState(false)
	NewGuide.saveGuideClass()
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
		print("EquipGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("EquipGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("EquipGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("EquipGuide stepNum 4")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("EquipGuide stepNum 5")
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("EquipGuide stepNum 6")
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("EquipGuide stepNum 7")
		local layer = create7Layer(touchRect)
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
end



--  铁匠铺 第1步 点击阵容
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
	talkDialog:setContentSize(CCSizeMake(280,177))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.21, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2714"), g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
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
 
-- 铁匠铺 第2步  点击一键装备按钮 透明处理
function create2Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(280,197))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2206")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 15))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)


	print("create2Layer")

	return layer
end


-- 铁匠铺 第3步  点击武器装备
function create3Layer(touchRect)
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
	talkDialog:setContentSize(CCSizeMake(280,177))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local str = GetLocalizeStringBy("key_2378")
	local talkLabel = CCLabelTTF:create(str, g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x, touchRect.origin.y + touchRect.size.height*0.5))
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)


	print("create3Layer")

	return layer
end


-- 铁匠铺 第4步 点击装备信息上强化按钮 透明处理
function create4Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil,0)

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


-- 铁匠铺 第5步 点击装备强化上 自动强化按钮
function create5Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y+touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create5Layer")

	return layer
end


-- 铁匠铺 第6步 指向副本
function create6Layer(touchRect)

	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil,0)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y+touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")

	return layer
end

-- 铁匠铺 第7步 副本选择
function create7Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create7Layer")

	return layer
end

