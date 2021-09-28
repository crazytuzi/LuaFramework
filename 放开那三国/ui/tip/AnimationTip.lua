
-- Filename：	AnimationTip.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		一段文字提示，淡出的提示

module("AnimationTip", package.seeall)
require "script/libs/LuaCCLabel"
-- changed by fang. 2013.08.29. it`s a big change.

local function fnEndCallback( tipSprite )
	tipSprite:removeFromParentAndCleanup(true)
	tipSprite = nil
end 

-- scaleY 是相对 runningScene的比例
function showTip(tipText, scaleY)
	local m_scaleY = scaleY or 0.5

	local fullRect = CCRectMake(0,0,58,58)
	local insetRect = CCRectMake(20,20,18,18)

	local hSpace=30
	local vSpace=40
	local nWidth=510

	-- 描述
	local tLabel = {
		text=tipText, fontsize=28, color=ccc3(255, 255, 255), width=nWidth-hSpace, alignment=kCCTextAlignmentCenter, 
	}
	local descLabel = LuaCCLabel.createMultiLineLabels(tLabel)
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	local tipSprite = CCScale9Sprite:create("images/tip/animate_tip_bg.png", fullRect, insetRect)

	local nHeight=descLabel:getContentSize().height + vSpace
	descLabel:setPosition(hSpace/2, nHeight-vSpace/2)

	tipSprite:setPreferredSize(CCSizeMake(nWidth, nHeight))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height*m_scaleY))
	-- btnFrameSp:setScale(bgLayer:getBgScale()/bgLayer:getElementScale())
	runningScene:addChild(tipSprite,30000)
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
	spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
	tipSprite:runAction(CCSequence:create(spActionArr))
end


-- 创建富文本格式
function showRichTextTip(textInfo)
	local fullRect = CCRectMake(0,0,58,58)
	local insetRect = CCRectMake(20,20,18,18)

	local hSpace=30
	local vSpace=10
	local nWidth=510
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	--提示背景
	local totalHeight = 0
	local descLabelArr = {}
	local tipSprite = CCScale9Sprite:create("images/tip/animate_tip_bg.png", fullRect, insetRect)
	local totalHeight = (28+ vSpace) * table.count(textInfo)+vSpace
	for i=1,#textInfo do
		-- 描述
		local tLabel = {
			text=textInfo[i].tipText, fontsize=28, color=textInfo[i].color, width=nWidth-hSpace, alignment=kCCTextAlignmentCenter, 
		}
		local descLabel = LuaCCLabel.createMultiLineLabels(tLabel)
		totalHeight = (descLabel:getContentSize().height+vSpace) * table.count(textInfo)+vSpace
		local posY = totalHeight - (i-1)*descLabel:getContentSize().height - i*vSpace
		descLabel:setPosition(hSpace/2, posY)
		tipSprite:addChild(descLabel)
		descLabelArr[#descLabelArr+1] = descLabel
	end
	tipSprite:setPreferredSize(CCSizeMake(nWidth,totalHeight))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
	runningScene:addChild(tipSprite,2000)
	tipSprite:setScale(g_fScaleX)


	-- 文字消失效果
	for k,v in pairs(descLabelArr) do
		local desActionArr = CCArray:create()
		desActionArr:addObject(CCDelayTime:create(2.0))
		desActionArr:addObject(CCFadeOut:create(1.0))
		v:runAction(CCSequence:create(desActionArr))
	end

	-- 背景消失效果
	local spActionArr = CCArray:create()
	spActionArr:addObject(CCDelayTime:create(2.0))
	spActionArr:addObject(CCFadeOut:create(1.0))
	spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
	tipSprite:runAction(CCSequence:create(spActionArr))
end


