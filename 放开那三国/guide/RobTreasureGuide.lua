-- Filename: RobTreasureGuide.lua
-- Author: 李晨阳
-- Date: 2013-09-10
-- Purpose: 10级等级礼包新手引导

require "script/utils/BaseUI"
module ("RobTreasureGuide", package.seeall)

local ktGuideLayerTag 	= 9000001
local ktChangeLayerTag 	= 9000002


stepNum = 0 				--引导步数
local maskLayer = nil 		

function show( p_stepNum,touchRect )

	require "script/guide/NewGuide"
	NewGuide.saveGuideClass()
	NewGuide.saveGuideStep(p_stepNum)
	
	print("RobTreasureGuide show step num = ", p_stepNum)
	stepNum = p_stepNum
	print(" stepNum 1 = ", stepNum)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	print(" stepNum 2 = ", stepNum)
	if(maskLayer ~= nil) then
		print("remove maskLayer")
		maskLayer:removeFromParentAndCleanup(true)
		maskLayer = nil
	end
	print("show stepNum = " .. stepNum)
	if(stepNum == 1) then
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5.5) then
		local layer = create5_5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("elseif(stepNum == 7) then")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7.5) then
		print("elseif(stepNum == 7.5) then")
		local layer = create75Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		local layer = create9Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 10) then
		local layer = create10Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 11) then
		local layer = create11Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 12) then
		local layer = create12Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 13) then
		local layer = create13Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	end
end

function changLayer( layerOpacity )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer = BaseUI.createMaskLayer(-5000, nil, nil, nil or layerOpacity)
	runningScene:addChild(maskLayer, 10000, ktChangeLayerTag)
	print("maskLayer = " , maskLayer, " stepNum = ", stepNum)
end

function cleanLayer()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	if(maskLayer ~= nil) then
		maskLayer:removeFromParentAndCleanup(true)
		maskLayer = nil
	end
end

function closeGuide( ... )
	require "script/guide/NewGuide"
	cleanLayer()
	NewGuide.guideClass = ksGuideClose
	NewGuide.saveGuideClass()
	BTUtil:setGuideState(false)
end

--[[
	@des:	活动列表进入夺宝引导
]]
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
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setPosition(ccps(0.65, 0.3))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2921"), g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(25, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create1Layer")
	return layer
end

--[[
	@des:	点击碎片图标引导
]]
function create2Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil, 0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setContentSize(CCSizeMake(320,167))
	talkDialog:setPosition(ccps(0.35, 0.55))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2188"), g_sFontName, 24, CCSizeMake(250, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(48, 40))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create2Layer")
	return layer
end

--[[
	@des:	碎片详情面版上的抢夺按钮引导
]]
function create3Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000, touchRect, nil, 0)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.35))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.65, 0.58))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3117"), g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 20))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	return layer
end


--[[
	@des:	玩家列表抢夺按钮引导
]]
function create4Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.1,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,130))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.35, 0.33))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1025"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(48, 20))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	return layer
end


--[[
	@des:	战斗结算面板 翻盘引导
]]
function create5Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.4))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(320,197))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.65, 0.73))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2777"), g_sFontName, 24, CCSizeMake(250, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 20))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	return layer
end

--[[
	@des:	战斗结算面板 确定引导
]]
function create6Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.4))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.65, 0.73))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2049"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(26, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")

	return layer
end

--[[
	@des:	合成宝物按钮引导
]]
function create7Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect ,nil, 0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.05,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.45, 0.33))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1596"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(48, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end


--[[
	@des:	宝物信息面板确定按钮
]]
function create75Layer(touchRect)
	
	local layer 	= BaseUI.BaseUI.createMaskLayer(-5000, touchRect, nil, 0)
	--girl
	-- local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	-- guidGirl:setAnchorPoint(ccp(0, 0))
	-- guidGirl:setPosition(ccps(0.9,0.3))
	-- layer:addChild(guidGirl)
	-- setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	-- --talk
	-- local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	-- talkDialog:setAnchorPoint(ccp(1,0))
	-- talkDialog:setContentSize(CCSizeMake(320, 147))
	-- talkDialog:setPosition(ccps(0.65, 0.53))
	-- layer:addChild(talkDialog)
	-- setAdaptNode(talkDialog)
	
	-- local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1191"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	-- talkLabel:setPosition(ccp(26, 120))
	-- talkLabel:setAnchorPoint(ccp(0,1))
	-- talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	-- talkDialog:addChild(talkLabel)-

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end

--[[
	@des:	点击阵容按钮引导
]]
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
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.65, 0.33))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1120"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(26, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end

--[[
	@:des	战马装备栏引导
]]
function create9Layer(touchRect)
	
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.3, 0.35))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3096"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(48, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end


--[[
	@:des	装备列表引导
]]
function create10Layer(touchRect)
	
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.3, 0.35))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2002"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(48, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end

--[[
	@des:	活动按钮引导
]]
function create11Layer(touchRect)
	
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end

--[[
	@des:	活动按钮引导
]]
function create12Layer(touchRect)
	
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create6Layer")
	return layer
end




--[[
	@des:	活动按钮引导
]]
function create13Layer(touchRect)
	
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,function ( ... )
		cleanLayer()
		require "script/guide/NewGuide"
		NewGuide.guideClass = ksGuideClose
		BTUtil:setGuideState(false)
		NewGuide.saveGuideClass()
	end,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0,0.1))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	-- guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/leftBottom.png")
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setContentSize(CCSizeMake(320, 147))
	talkDialog:setPosition(ccps(0.3, 0.35))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1665"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(48, 120))
	talkLabel:setAnchorPoint(ccp(0,1))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	print("create6Layer")
	return layer
end

