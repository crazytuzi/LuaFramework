-- Filename：	AnimationTip.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		一段文字提示，淡出的提示

module("SingleTip", package.seeall)

-- changed by fang. 2013.08.29. it`s a big change.
-- changed by ZQ. 2014.01.11. Avoid create tip repeatedly while buttom tapped continuously.
local tipSprite = nil

function showTip(tipText)
	local fullRect = CCRectMake(0,0,58,58)
	local insetRect = CCRectMake(20,20,18,18)

	local hSpace=30
	local vSpace=40
	local nWidth=510

	-- 描述
	local tLabel = {
		text=tipText, fontsize=28, color=ccc3(255, 255, 255), width=nWidth-hSpace, alignment=kCCTextAlignmentCenter, 
	}
	require "script/libs/LuaCCLabel"
	descLabel = LuaCCLabel.createMultiLineLabels(tLabel)
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	tipSprite = CCScale9Sprite:create("images/tip/animate_tip_bg.png", fullRect, insetRect)

	local nHeight=descLabel:getContentSize().height + vSpace
	descLabel:setPosition(hSpace/2, nHeight-vSpace/2)

	tipSprite:setPreferredSize(CCSizeMake(nWidth, nHeight))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
	-- btnFrameSp:setScale(bgLayer:getBgScale()/bgLayer:getElementScale())
	runningScene:addChild(tipSprite,2000)
	-- tipSprite:setCascadeOpacityEnabled(true)
	tipSprite:setScale(g_fScaleX)	
	tipSprite:addChild(descLabel)

	-- 文字消失效果
	local desActionArr = CCArray:create()
	desActionArr:addObject(CCDelayTime:create(2.0))
	desActionArr:addObject(CCFadeOut:create(1.0))
	descLabel:runAction(CCSequence:create(desActionArr))

	-- 背景消失效果
	local spActionArr = CCArray:create()
	spActionArr:addObject(CCDelayTime:create(2.0))
	spActionArr:addObject(CCFadeOut:create(1.0))
	--spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
	tipSprite:runAction(CCSequence:create(spActionArr))
end

function showSingleTip(tipText)
	if tipSprite ~= nil  then
		tipSprite:removeFromParentAndCleanup(true)
		tipSprite = nil
	end
	showTip(tipText)
end
