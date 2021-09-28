-- Filename：	RichAnimationTip.lua
-- Author：		bzx
-- Date：		2013-9-24
-- Purpose：		一段文字提示，淡出的提示

module("RichAnimationTip", package.seeall)
require "script/libs/LuaCCLabel"

local function fnEndCallback( tipSprite )
	tipSprite:removeFromParentAndCleanup(true)
	tipSprite = nil
end 
-- p_posX，p_posY 悬浮框屏幕坐坐标，默认居中 例如：0.5，0.5
function showTip(richInfo,p_posX,p_posY, p_zOrder)
	local fullRect = CCRectMake(0,0,58,58)
	local insetRect = CCRectMake(20,20,18,18)
	p_zOrder = p_zOrder or 2000

	local hSpace=30
	local vSpace=40
	local nWidth=510
    
    richInfo.width = nWidth-hSpace
    richInfo.alignment = 2                       -- 对齐方式  1 左对齐，2 居中， 3右对齐
    richInfo.labelDefaultFont = g_sFontName      -- 默认字体
    richInfo.labelDefaultSize = 28               -- 默认字体大小
    local descLabel = LuaCCLabel.createRichLabel(richInfo)
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	local tipSprite = CCScale9Sprite:create("images/tip/animate_tip_bg.png", fullRect, insetRect)
    local nHeight=descLabel:getContentSize().height + vSpace
	tipSprite:setPreferredSize(CCSizeMake(nWidth, nHeight))
    descLabel:setAnchorPoint(ccp(0.5, 0.5))
    descLabel:setPosition(ccpsprite(0.5, 0.5, tipSprite))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	local posX = nil
	local posY = nil
	if(p_posX == nil)then 
		posX = runningScene:getContentSize().width/2
	else
		posX = runningScene:getContentSize().width*p_posX
	end
	if(p_posY == nil)then 
		posY = runningScene:getContentSize().height/2
	else
		posY = runningScene:getContentSize().height*p_posY
	end
	tipSprite:setPosition(ccp( posX, posY))
	-- btnFrameSp:setScale(bgLayer:getBgScale()/bgLayer:getElementScale())
	runningScene:addChild(tipSprite, p_zOrder)
	-- tipSprite:setCascadeOpacityEnabled(true)
	tipSprite:setScale(g_fScaleX)	
	tipSprite:addChild(descLabel)

	-- 文字消失效果
	local desActionArr = CCArray:create()
	desActionArr:addObject(CCDelayTime:create(2.0))
	desActionArr:addObject(CCFadeOut:create(1.0))
	descLabel:runAction(CCSequence:create(desActionArr))
    descLabel:setCascadeOpacityEnabled(true)

	-- 背景消失效果
	local spActionArr = CCArray:create()
	spActionArr:addObject(CCDelayTime:create(2.0))
	spActionArr:addObject(CCFadeOut:create(1.0))
	spActionArr:addObject(CCCallFuncN:create(fnEndCallback))
	tipSprite:runAction(CCSequence:create(spActionArr))
end