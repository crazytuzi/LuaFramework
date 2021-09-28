-- FileName: LevelGiftBagGuide.lua 
-- Author: Li Cong 
-- Date: 13-9-9 
-- Purpose: function description of module 

--[==[等级礼包新手引导屏蔽层
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		require "script/guide/LevelGiftBagGuide"
		LevelGiftBagGuide.changLayer()
	end
	---------------------end-------------------------------------
--]==]

--[==[等级礼包新手引导清除
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/guide/NewGuide"
	if(NewGuide.guideClass == ksGuideFiveLevelGift) then
		require "script/guide/LevelGiftBagGuide"
		LevelGiftBagGuide.cleanLayer()
	end
	---------------------end-------------------------------------
--]==]

--[==[ 第一步主界面等级礼包按钮
---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    print("start LevelGiftBagGuide guide")
    require "script/guide/NewGuide"
    NewGuide.guideClass  = ksGuideFiveLevelGift
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift) then
        require "script/guide/LevelGiftBagGuide"
        require "script/ui/level_reward/LevelRewardBtn"
        local levelGiftBagGuide_button = LevelRewardBtn.getReardBtn()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(1, touchRect)
    end
 ---------------------end-------------------------------------
--]==]

--[==[ 第二步等级礼包领取按钮
	---------------------新手引导---------------------------------
	--add by licong 2013.09.09
	require "script/ui/level_reward/LevelRewardLayer"
	local didCreateTableView = function ( ... )
	    require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 1) then
	        local levelGiftBagGuide_button = LevelRewardLayer.getReceiveBtn(0)
	        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
	        LevelGiftBagGuide.show(2, touchRect)
	    end
	end
	LevelRewardLayer.registerDidTableViewCallBack(didCreateTableView)
	---------------------end-------------------------------------
--]==]

--[==[ 第三步等级礼包关闭按钮
	---------------------新手引导---------------------------------
	    --add by licong 2013.09.09
	local didClickCallback = function ( ... )
	    require "script/guide/NewGuide"
		print("g_guideClass = ", NewGuide.guideClass)
	    require "script/guide/LevelGiftBagGuide"
	    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 2) then
	        require "script/ui/level_reward/LevelRewardLayer"
	        local levelGiftBagGuide_button = LevelRewardLayer.getCloseBtn()
	        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
	        LevelGiftBagGuide.show(3, touchRect)
	    end
	end
	require "script/ui/level_reward/LevelRewardCell"
	LevelRewardCell.registerSelectCopyCallback(didClickCallback)
	---------------------end-------------------------------------
--]==]

--[==[ 第四步等级礼包 商店
	---------------------新手引导---------------------------------
    --add by licong 2013.09.09
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 3) then
        require "script/ui/main/MenuLayer"
        local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(5)
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(4, touchRect)
    end
	---------------------end-------------------------------------
--]==]

--[==[ 第5步等级礼包招将按钮
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/ui/shop/PubLayer"
local didCreateShop = function ( ... )
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 4) then
        local levelGiftBagGuide_button = PubLayer.getGuideObject()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(5, touchRect)
    end
end
PubLayer.registerDidCreateShopCallBack(didCreateShop)
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第6步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/ui/shop/PubLayer"
local didClickFun = function ( ... )
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 5) then
        LevelGiftBagGuide.show(6, nil)
    end
end
PubLayer.registerDidClickCallBack(didClickFun)
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第7步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/ui/shop/SeniorAnimationLayer"
local didClicZhaoFun = function ( ... )
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 6) then
        LevelGiftBagGuide.show(7, nil)
    end
end
SeniorAnimationLayer.registerDidClickZhaoJiangCallBack(didClicZhaoFun)
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第8步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/ui/shop/HeroDisplayerLayer"
local didGetHero = function ( ... )
    require "script/guide/NewGuide"
	print("g_guideClass = ", NewGuide.guideClass)
    require "script/guide/LevelGiftBagGuide"
    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 7) then
        local levelGiftBagGuide_button = HeroDisplayerLayer.getGuideObject()
        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
        LevelGiftBagGuide.show(8, touchRect)
    end
end
HeroDisplayerLayer.registerDidGetHeroCallBack(didGetHero)
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第9步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/guide/NewGuide"
require "script/guide/LevelGiftBagGuide"
if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 8) then
    local levelGiftBagGuide_button = MenuLayer.getMenuItemNode(2)
    local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
    LevelGiftBagGuide.show(9, touchRect)
end
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第10步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/guide/NewGuide"
require "script/guide/LevelGiftBagGuide"
if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 9) then
    local levelGiftBagGuide_button = getGuideTopCell(2)
    local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
    LevelGiftBagGuide.show(10, touchRect)
end
---------------------end-------------------------------------
--]==]

--[==[ 等级礼包第11步 
---------------------新手引导---------------------------------
--add by licong 2013.09.09
require "script/guide/NewGuide"
require "script/guide/LevelGiftBagGuide"
if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 10) then
    LevelGiftBagGuide.changLayer()
    local touchRect = CCRectMake(g_winSize.width * 0.5 - 120 * getScaleParm(), g_winSize.height * 0.5 - 180 * getScaleParm(), 240 * getScaleParm(), 450 * getScaleParm() )
    LevelGiftBagGuide.show(11, touchRect)
end
---------------------end-------------------------------------
--]==]

module("LevelGiftBagGuide", package.seeall)


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
		print("LevelGiftBagGuide stepNum 1")
		local layer = create1Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2) then
		print("LevelGiftBagGuide stepNum 2")
		local layer = create2Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 2.5) then
		print("LevelGiftBagGuide stepNum 2.5")
		local layer = create2_5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 3) then
		print("LevelGiftBagGuide stepNum 3")
		local layer = create3Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 4) then
		print("LevelGiftBagGuide stepNum 4")
		local layer = create4Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 5) then
		print("LevelGiftBagGuide stepNum 5")
		local layer = create5Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 6) then
		print("LevelGiftBagGuide stepNum 6")
		local layer = create6Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 7) then
		print("LevelGiftBagGuide stepNum 7")
		local layer = create7Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 8) then
		print("LevelGiftBagGuide stepNum 8")
		local layer = create8Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 9) then
		print("LevelGiftBagGuide stepNum 9")
		local layer = create9Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 10) then
		print("LevelGiftBagGuide stepNum 10")
		local layer = create10Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 11) then
		print("LevelGiftBagGuide stepNum 11")
		local layer = create11Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 12) then
		print("LevelGiftBagGuide stepNum 12")
		local layer = create12Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 13) then
		print("LevelGiftBagGuide stepNum 13")
		local layer = create13Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 14) then
		print("LevelGiftBagGuide stepNum 14")
		local layer = create14Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 15) then
		print("LevelGiftBagGuide stepNum 15")
		local layer = create15Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 16) then
		print("LevelGiftBagGuide stepNum 16")
		local layer = create16Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 17) then
		print("LevelGiftBagGuide stepNum 17")
		local layer = create17Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 18) then
		print("LevelGiftBagGuide stepNum 18")
		local layer = create18Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 19) then
		print("LevelGiftBagGuide stepNum 19")
		local layer = create19Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 20) then
		print("LevelGiftBagGuide stepNum 20")
		local layer = create20Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 21) then
		print("LevelGiftBagGuide stepNum 21")
		local layer = create21Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	elseif(stepNum == 22) then
		print("LevelGiftBagGuide stepNum 22")
		local layer = create22Layer(touchRect)
		runningScene:addChild(layer,10000,ktGuideLayerTag)
	end	
end


function changLayer( ... )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:removeChildByTag(ktGuideLayerTag, true)
	maskLayer =  nil

	if(stepNum == 5 or stepNum == 6 or stepNum == 16) then
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

-- 等级礼包引导 第1步
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
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.33))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2218"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(26, 40))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y ))
	arrowSprite:setRotation(270)
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


-- 等级礼包引导 第2步 点领取按钮 透明处理
function create2Layer(touchRect)

	-- 领取按钮引导
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

-- 等级礼包引导 第2.5步 点击领取弹出的框 透明处理
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

-- 等级礼包引导 第3步
function create3Layer(touchRect)
	-- 关闭按钮
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

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


-- 等级礼包引导 第4步
function create4Layer(touchRect)
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
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2003"), g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(56, 0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

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


-- 等级礼包引导 第5步
function create5Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	
	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x, touchRect.origin.y + touchRect.size.height*0.5))
	layer:addChild(arrowSprite)
	arrowSprite:setRotation(360)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create5Layer")

	return layer
end

-- 等级礼包引导 第6步 点抽一次  修改跳过此步骤
function create6Layer(touchRect)
	-- local layer = BaseUI.createMaskLayer(-5000,touchRect)
	
	-- local arrowSprite = CCSprite:create("images/guide/arrow.png")
	-- arrowSprite:setAnchorPoint(ccp(1, 0.5))
	-- arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height*0.5))
	-- arrowSprite:setRotation(180)
	-- layer:addChild(arrowSprite)
	-- setAdaptNode(arrowSprite)
	-- runMoveAction(arrowSprite)

	return layer
end


-- 等级礼包引导 第7步 此步骤跳过
function create7Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil,0)
	
	-- local arrowSprite = CCSprite:create("images/guide/arrow.png")
	-- arrowSprite:setAnchorPoint(ccp(1, 0.5))
	-- arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height*0.5))
	-- arrowSprite:setRotation(180)
	-- layer:addChild(arrowSprite)
	-- setAdaptNode(arrowSprite)
	-- runMoveAction(arrowSprite)
	
	-- print("create7Layer")

	return layer
end


-- 等级礼包引导 第8步 透明处理
function create8Layer(touchRect)
	local layer = BaseUI.createMaskLayer(-5000,touchRect,nil,0)
	
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


-- 等级礼包引导 第9步 阵容
function create9Layer(touchRect)
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
	talkDialog:setContentSize(CCSizeMake(320,147))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3279"), g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(26, 40))
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
	print("create9Layer")

	return layer
end


-- 等级礼包引导 第10步
function create10Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x+touchRect.size.width*0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	print("create10Layer")

	return layer
end



-- 等级礼包引导 第11步
function create11Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create11Layer")

	return layer
end


-- 等级礼包引导 第12步 上阵时 透明处理
function create12Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)
	
	print("create12Layer")

	return layer
end


-- 等级礼包引导 第13步
function create13Layer(touchRect)

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
	
	local talkString = GetLocalizeStringBy("key_2099")
	local talkLabel  = CCLabelTTF:create(talkString, g_sFontName, 24, CCSizeMake(250, 80),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setPosition(ccp(25, 20))
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width, touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(180)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create13Layer")

	return layer
end


-- 等级礼包引导 第14步 显示将领信息  
function create14Layer(touchRect)

	-- 强化按钮引导
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.93,0.3))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(280,177))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.21, 0.63))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3139"), g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
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
	print("create14Layer")

	return layer
end


-- 等级礼包引导 第15步 自动添加 透明处理
function create15Layer(touchRect)

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
	talkDialog:setContentSize(CCSizeMake(280,127))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.43))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1947"), g_sFontName, 24, CCSizeMake(200, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(60, 0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create15Layer")
	return layer
end


-- 等级礼包引导 第16步 强化 透明处理
function create16Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)
	--girl
	local guidGirl 	= CCSprite:create("images/guide/guideGirl.png")
	guidGirl:setAnchorPoint(ccp(0, 0))
	guidGirl:setPosition(ccps(0.9,0.2))
	layer:addChild(guidGirl)
	setAdaptNode(guidGirl)
	guidGirl:setScaleX(-1 * guidGirl:getScaleX())
	--talk
	local talkDialog = CCScale9Sprite:create("images/guide/rightBottom.png")
	talkDialog:setContentSize(CCSizeMake(280,177))
	talkDialog:setAnchorPoint(ccp(1,0))
	talkDialog:setPosition(ccps(0.60, 0.53))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1497"), g_sFontName, 24, CCSizeMake(200, 100),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(26, 45))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width*0.5, touchRect.origin.y + touchRect.size.height))
	arrowSprite:setRotation(90)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create16Layer")
	return layer
end


--  等级礼包引导 副本引导 第17步 透明处理
function create17Layer(touchRect)
	local layer 	= BaseUI.createMaskLayer(-5000,touchRect,nil,0)
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
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1978"), g_sFontName, 24, CCSizeMake(200, 150),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
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
	print("create17Layer")

	return layer
end


-- 等级礼包引导 第18步 副本选择
function create18Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x + touchRect.size.width * 0.5, touchRect.origin.y))
	arrowSprite:setRotation(270)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create18Layer")

	return layer
end

-- 等级礼包引导 第19步 第5个据点
function create19Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x , touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(0)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create19Layer")

	return layer
end


-- 等级礼包引导 第20步 第5个据点战斗面板
function create20Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x , touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(0)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create20Layer")

	return layer
end

-- 等级礼包引导 第21步 第6个据点
function create21Layer(touchRect)

	-- 强化按钮引导
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
	talkDialog:setContentSize(CCSizeMake(280,147))
	talkDialog:setAnchorPoint(ccp(0,0))
	talkDialog:setPosition(ccps(0.45, 0.30))
	layer:addChild(talkDialog)
	setAdaptNode(talkDialog)
	
	local talkLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1215"), g_sFontName, 24, CCSizeMake(200, 120),kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	talkLabel:setAnchorPoint(ccp(0,0))
	talkLabel:setPosition(ccp(60, 0))
	talkLabel:setColor(ccc3(0x43, 0x00, 0x00))
	talkDialog:addChild(talkLabel)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x , touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(0)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create21Layer")
	return layer
end


-- 等级礼包引导 第22步 第6个据点战斗面板
function create22Layer(touchRect)

	local layer 	= BaseUI.createMaskLayer(-5000,touchRect)

	local arrowSprite = CCSprite:create("images/guide/arrow.png")
	arrowSprite:setAnchorPoint(ccp(1, 0.5))
	arrowSprite:setPosition(ccp(touchRect.origin.x , touchRect.origin.y + touchRect.size.height * 0.5))
	arrowSprite:setRotation(0)
	layer:addChild(arrowSprite)
	setAdaptNode(arrowSprite)
	runMoveAction(arrowSprite)

	print("create22Layer")

	return layer
end




