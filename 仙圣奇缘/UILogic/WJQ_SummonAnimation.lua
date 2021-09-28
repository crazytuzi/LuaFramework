--------------------------------------------------------------------------------------
-- 文件名:	WJQ_SummonAnimation.lu
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_SummonAnimation = class("Game_SummonAnimation")
Game_SummonAnimation.__index = Game_SummonAnimation

-- local tbAniConfigStep1 = {
	-- fTimeStep = 0.6,
	-- fStartScaleStep = 1.8,
	-- fEndScaleStep = 1,
	-- fEaseTimeStep = 0.3,
	-- fAngleStep = 45
-- }

-- local tbAniConfigStep2 = {
	-- fTimeStep = 0.6,
	-- fStartScaleStep = 0.5,
	-- fEndScaleStep = 1,
	-- fEaseTimeStep = 1,
	-- fAngleStep = 60
-- }

-- local tbAniConfigStep3 = {
	-- fTimeStep = 1,
	-- fStartScaleStep = 1.5,
	-- fEndScaleStep = 0.5,
	-- fEaseTimeStep = 2,
	-- fAngleStep = 45
-- }

-- local tbAniConfigStep4 = {
	-- fTimeStep = 0.5,
	-- fStartScaleStep = 3,
	-- fEndScaleStep = 1,
	-- fEaseTimeStep = 5,
	-- fAngleStep = 45
-- }

-- local tbAniConfigStep5 = {
	-- fTimeStep = 0.5,
	-- fStartScaleStep = 0.3,
	-- fEaseTimeStep = 4,
	-- fAngleStep = 45
-- }

-- local tbAniConfigStep6 = {
	-- fTimeStep = 0.5,
	-- fStartScaleStep = 1
-- }

-- local tbAniConfigStep7 = {
	-- fTimeStep = 0.5,
	-- fStartScaleStep = 1
-- }

-- local tbAniConfigStep8 = {
	-- fTimeStep = 0.4,
	-- fStartScaleStep = 3,
	-- fEaseTimeStep = 4,
	-- fAngleStep = 45
-- }

-- local tbAniConfigStep9 = {
	-- fTimeStep = 0.4,
	-- fStartScaleStep = 1
-- }

-- local tbAniConfigStep10 = {
	-- fTimeStep = 0.4
-- }

-- local tbAnimationScaleConfig1 = {
	-- fScaleCrossLightHorizontal = 3,
	-- fScaleCrossLightVertical = 2,
	-- fScaleRayInSide = 12,
	-- fScaleRayOutSide = 12,
	-- fScaleCardLight = 1.7,
	-- fScaleExplodeBig = 5.86,
	-- fScaleExplodeSmall = 4.10,
	-- fScaleCircleXuanWo = 4.6,
	-- fScaleCircleInSideBig = 3.75,
	-- fScaleCircleInSideSmall = 3.6,
	-- fScaleCircleOutSideBig = 4.37,
	-- fScaleCircleOutSideSmall = 4.31
-- }

-- local tbAnimationScaleConfig2 = {
	-- fScaleCrossLightHorizontal = 5.6,
	-- fScaleCrossLightVertical = 5.6,
	-- fScaleRayInSide = 7.4,
	-- fScaleRayOutSide = 7.4,
	-- fScaleCardLight = 2.4,
	-- fScaleExplodeBig = 4.10,
	-- fScaleExplodeSmall = 3.75,
	-- fScaleCircleXuanWo = 4,
	-- fScaleCircleInSideBig = 3.33,
	-- fScaleCircleInSideSmall = 3.6,
	-- fScaleCircleOutSideBig = 4.58,
	-- fScaleCircleOutSideSmall = 4.31
-- }

-- local tbAnimationScaleConfig3 = {
	-- fScaleCrossLightHorizontal = 3,
	-- fScaleCrossLightVertical = 2,
	-- fScaleRayInSide = 6,
	-- fScaleRayOutSide = 6,
	-- fScaleCardLight = 1.7,
	-- fScaleExplodeBig = 5.86,
	-- fScaleExplodeSmall = 4.10,
	-- fScaleCircleXuanWo = 4.6,
	-- fScaleCircleInSideBig = 3.75,
	-- fScaleCircleInSideSmall = 3.6,
	-- fScaleCircleOutSideBig = 4.37,
	-- fScaleCircleOutSideSmall = 4.31
-- }

local function EmitRandomCardShape(parent, ccpStartPos, nBlendType, nLayer, nDirection)
	local nDistance = 250 + math.random(50)
	local nSpan = math.random(10, 30)
	local nIndex = math.random(-10, 10)
	local nOffsetY = nSpan*nIndex
	local nOffsetYDelta = nOffsetY / 25
	local fAngleZ = 20 * nDirection
	
	local Summon_CardFly = CCSprite:create(getCocoAnimationImg("Summon_CardFly"))
	Summon_CardFly:setPosition(ccp(ccpStartPos.x, ccpStartPos.y + nOffsetY))
	g_SetBlendFuncSprite(Summon_CardFly, nBlendType)
		
	local arrActCardFly = CCArray:create()
	local actionOrbitCardFly = CCOrbitCamera:create(1.2, 1, 0, 0, fAngleZ, 0, 0)
	local actionOrbitCardFlyEase = CCEaseOut:create(actionOrbitCardFly, 3)
	local actionScaleToCardFly = CCScaleTo:create(1.2, 0.4)
	local actionFadeToCardFly = CCFadeTo:create(1.2, 50)
	local actionMoveToCardFly = CCMoveTo:create(1.2, ccp(ccpStartPos.x + nDistance*nDirection, ccpStartPos.y + nOffsetY))
	local actionMoveToCardFlyEase = CCEaseIn:create(actionMoveToCardFly, 3)
	local arrActSpwanCardFly = CCArray:create()
	arrActSpwanCardFly:addObject(actionOrbitCardFlyEase)
	arrActSpwanCardFly:addObject(actionScaleToCardFly)
	arrActSpwanCardFly:addObject(actionFadeToCardFly)
	arrActSpwanCardFly:addObject(actionMoveToCardFlyEase)

	local actionSpwanCardFly = CCSpawn:create(arrActSpwanCardFly)
	arrActCardFly:addObject(actionSpwanCardFly)
	local function deleteCardFly()
		Summon_CardFly:removeFromParentAndCleanup(true)
	end
	arrActCardFly:addObject(CCCallFuncN:create(deleteCardFly))
	local actionCardFly = CCSequence:create(arrActCardFly)
	parent:addNode(Summon_CardFly, nLayer)
	Summon_CardFly:runAction(actionCardFly)
end

local function SetCrossRay(parent, ccpStartPos, nBlendType, nLayer)
	local Summon_CrossRayHorizontal = CCSprite:create(getCocoAnimationImg("Summon_CrossRayHorizontal"))
	local Summon_CrossRayVertical = CCSprite:create(getCocoAnimationImg("Summon_CrossRayHorizontal"))
	Summon_CrossRayHorizontal:setPosition(ccpStartPos)
	Summon_CrossRayVertical:setPosition(ccpStartPos)
	g_SetBlendFuncSprite(Summon_CrossRayHorizontal, nBlendType)
	g_SetBlendFuncSprite(Summon_CrossRayVertical, nBlendType)
	Summon_CrossRayHorizontal:setScaleY(2)
	Summon_CrossRayVertical:setScaleY(2)
	Summon_CrossRayVertical:setRotation(90)
	
	local arrActCrossRayHorizontal = CCArray:create()
	local actionScaleToCrossRayHorizontal1 = CCScaleTo:create(1, 0.8, 1)
	local actionScaleToCrossRayHorizontal2 = CCScaleTo:create(1, 1.5, 2)
	arrActCrossRayHorizontal:addObject(actionScaleToCrossRayHorizontal1)
	arrActCrossRayHorizontal:addObject(actionScaleToCrossRayHorizontal2)
	local actionCrossRayHorizontal = CCSequence:create(arrActCrossRayHorizontal)
	local actionForeverCrossRayHorizontal = CCRepeatForever:create(actionCrossRayHorizontal)
	
	local arrActCrossRayVertical = CCArray:create()
	local actionScaleToCrossRayVertical1 = CCScaleTo:create(1, 0.8, 1)
	local actionScaleToCrossRayVertical2 = CCScaleTo:create(1, 1.5, 2)
	arrActCrossRayVertical:addObject(actionScaleToCrossRayVertical1)
	arrActCrossRayVertical:addObject(actionScaleToCrossRayVertical2)
	local actionCrossRayVertical = CCSequence:create(arrActCrossRayVertical)
	local actionForeverCrossRayVertical = CCRepeatForever:create(actionCrossRayVertical)

	parent:addNode(Summon_CrossRayHorizontal, nLayer)
	parent:addNode(Summon_CrossRayVertical, nLayer)
	Summon_CrossRayHorizontal:runAction(actionForeverCrossRayHorizontal)
	Summon_CrossRayVertical:runAction(actionForeverCrossRayVertical)
end

local function createRayInSideAction(parent, nBlendType)
	local arrActRayInSide = CCArray:create()
	local actionScaleToRayInSide4 = CCScaleTo:create(1, 1.5*12)
	local actionFadeToRayInSide4 = CCFadeTo:create(1, 100)
	local actionSpawnRayInSide4 = CCSpawn:createWithTwoActions(actionScaleToRayInSide4, actionFadeToRayInSide4)
	local actionSpawnRayInSideEase4 = CCEaseOut:create(actionSpawnRayInSide4, 2)
	local actionScaleToRayInSide5 = CCScaleTo:create(0.5, 12*3)
	local actionScaleToRayInSide6 = CCScaleTo:create(0.5, 0.3*7.4)
	local actionFadeToRayInSide6 = CCFadeTo:create(0.5, 0)
	local actionSpawnRayInSide6 = CCSpawn:createWithTwoActions(actionScaleToRayInSide6, actionFadeToRayInSide6)
	local actionScaleToRayInSide7 = CCScaleTo:create(0.5, 7.4)
	local actionFadeToRayInSide7 = CCFadeTo:create(0.5, 100)
	local actionSpawnRayInSide7 = CCSpawn:createWithTwoActions(actionScaleToRayInSide7, actionFadeToRayInSide7)
	arrActRayInSide:addObject(CCDelayTime:create(0.6+0.6))
	arrActRayInSide:addObject(actionSpawnRayInSideEase4)
	arrActRayInSide:addObject(CCDelayTime:create(0.2))
	local function resetRayInSide1()
		g_playSoundEffect("Sound/LevelUp2.mp3")
		parent:setScale(0)
		parent:setZOrder(22)
	end
	arrActRayInSide:addObject(CCCallFuncN:create(resetRayInSide1))
	arrActRayInSide:addObject(actionScaleToRayInSide5)
	arrActRayInSide:addObject(actionSpawnRayInSide6)
	local function resetRayInSide2()
		parent:setZOrder(2)
	end
	arrActRayInSide:addObject(CCCallFuncN:create(resetRayInSide2))
	arrActRayInSide:addObject(actionSpawnRayInSide7)
	local function repeatRayInSide()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateRayInSide = CCRotateBy:create(15, 360) 
		local actionForeverRayInSide = CCRepeatForever:create(actionRotateRayInSide)
		parent:runAction(actionForeverRayInSide)
	end
	arrActRayInSide:addObject(CCCallFuncN:create(repeatRayInSide))
	local actionRayInSide = CCSequence:create(arrActRayInSide)
	return actionRayInSide
end

local function createRayOutSideAction(parent, nBlendType)
	local arrActRayOutSide = CCArray:create()
	local actionScaleToRayOutSide4 = CCScaleTo:create(1, 1.5*12)
	local actionFadeToRayOutSide4 = CCFadeTo:create(1, 50)
	local actionSpawnRayOutSide4 = CCSpawn:createWithTwoActions(actionScaleToRayOutSide4, actionFadeToRayOutSide4)
	local actionSpawnRayOutSideEase4 = CCEaseOut:create(actionSpawnRayOutSide4, 2)
	local actionScaleToRayOutSide5 = CCScaleTo:create(0.5, 12*3)
	local actionScaleToRayOutSide6 = CCScaleTo:create(0.5, 0.3*7.4)
	local actionFadeToRayOutSide6 = CCFadeTo:create(0.5, 0)
	local actionSpawnRayOutSide6 = CCSpawn:createWithTwoActions(actionScaleToRayOutSide6, actionFadeToRayOutSide6)
	local actionScaleToRayOutSide7 = CCScaleTo:create(0.5, 7.4)
	local actionFadeToRayOutSide7 = CCFadeTo:create(0.5, 100)
	local actionSpawnRayOutSide7 = CCSpawn:createWithTwoActions(actionScaleToRayOutSide7, actionFadeToRayOutSide7)
	arrActRayOutSide:addObject(CCDelayTime:create(0.6+0.6))
	arrActRayOutSide:addObject(actionSpawnRayOutSideEase4)
	local function resetRayOutSide1()
		parent:setScale(0)
		parent:setOpacity(255)
		parent:setZOrder(21)
	end
	arrActRayOutSide:addObject(CCCallFuncN:create(resetRayOutSide1))
	arrActRayOutSide:addObject(actionScaleToRayOutSide5)
	arrActRayOutSide:addObject(actionSpawnRayOutSide6)
	local function resetRayOutSide2()
		parent:setZOrder(1)
	end
	arrActRayOutSide:addObject(CCCallFuncN:create(resetRayOutSide2))
	arrActRayOutSide:addObject(actionSpawnRayOutSide7)
	local function repeatRayOutSide()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateRayOutSide = CCRotateBy:create(15, -360)
		local actionForeverRayOutSide = CCRepeatForever:create(actionRotateRayOutSide)
		parent:runAction(actionForeverRayOutSide)
	end
	arrActRayOutSide:addObject(CCCallFuncN:create(repeatRayOutSide))
	local actionRayOutSide = CCSequence:create(arrActRayOutSide)
	return actionRayOutSide
end

local function createCircleXuanWoAction(parent, nBlendType)
	local arrActCircleXuanWo = CCArray:create()
	local actionScaleToCircleXuanWo1 = CCScaleTo:create(0.6, 4.6*1.8)
	local actionRotateToCircleXuanWo1 = CCRotateBy:create(0.6, 10*45)
	local actionSpawnCircleXuanWo1 = CCSpawn:createWithTwoActions(actionScaleToCircleXuanWo1, actionRotateToCircleXuanWo1)
	local actionScaleToCircleXuanWo3 = CCScaleTo:create(0.6, 4.6*0.5)
	local actionRotateToCircleXuanWo3 = CCRotateBy:create(0.6, 10*60)
	local actionSpawnCircleXuanWo3 = CCSpawn:createWithTwoActions(actionScaleToCircleXuanWo3, actionRotateToCircleXuanWo3)
	local actionScaleToCircleXuanWo4 = CCScaleTo:create(1, 4.6*1.5)
	local actionRotateToCircleXuanWo4 = CCRotateBy:create(1, 10*45)
	local actionSpawnCircleXuanWo4 = CCSpawn:createWithTwoActions(actionScaleToCircleXuanWo4, actionRotateToCircleXuanWo4)
	local actionFadeToCircleXuanWo5 = CCFadeTo:create(0.5, 0)
	local actionRotateToCircleXuanWo5 = CCRotateBy:create(0.5, 10*3)
	local actionSpawnCircleXuanWo5 = CCSpawn:createWithTwoActions(actionFadeToCircleXuanWo5, actionRotateToCircleXuanWo5)
	local actionScaleToCircleXuanWo6 = CCScaleTo:create(0.5, 0)
	local actionFadeToCircleXuanWo6 = CCFadeTo:create(0.5, 255)
	local actionSpawnCircleXuanWo6 = CCSpawn:createWithTwoActions(actionScaleToCircleXuanWo6, actionFadeToCircleXuanWo6)
	local actionSpawnCircleXuanWoEase6 = CCEaseOut:create(actionSpawnCircleXuanWo6, 4)
	arrActCircleXuanWo:addObject(actionSpawnCircleXuanWo1)
	arrActCircleXuanWo:addObject(actionSpawnCircleXuanWo3)
	arrActCircleXuanWo:addObject(actionSpawnCircleXuanWo4)
	arrActCircleXuanWo:addObject(actionSpawnCircleXuanWo5)
	arrActCircleXuanWo:addObject(actionSpawnCircleXuanWoEase6)
	local actionCircleXuanWo = CCSequence:create(arrActCircleXuanWo)
	return actionCircleXuanWo
end

local function createExplodeSmallAction(parent, nBlendType)
	local arrActExplodeSmall = CCArray:create()
	local actionScaleToExplodeSmall1 = CCScaleTo:create(0.6, 4.10*1.8)
	local actionRotateToExplodeSmall1 = CCRotateBy:create(0.6, 8*45)
	local actionSpawnExplodeSmall1 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall1, actionRotateToExplodeSmall1)
	local actionSpawnExplodeSmallEase1 = CCEaseOut:create(actionSpawnExplodeSmall1, 0.3)
	local actionScaleToExplodeSmall3 = CCScaleTo:create(0.6, 4.10*0.5)
	local actionRotateToExplodeSmall3 = CCRotateBy:create(0.6, 4*60)
	local actionSpawnExplodeSmall3 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall3, actionRotateToExplodeSmall3)
	local actionScaleToExplodeSmall4_1 = CCScaleTo:create(1/4, 0.5*1.5*4.10)
	local actionRotateToExplodeSmall4_1 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnExplodeSmall4_1 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall4_1, actionRotateToExplodeSmall4_1)
	local actionScaleToExplodeSmall4_2 = CCScaleTo:create(1/4, 0.5*4.10)
	local actionRotateToExplodeSmall4_2 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnExplodeSmall4_2 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall4_2, actionRotateToExplodeSmall4_2)
	local actionRotateToExplodeSmall4_3 = CCRotateBy:create(1/2, 2*45)
	local actionScaleToExplodeSmall5 = CCScaleTo:create(0.5, 3*4.10)
	local actionRotateToExplodeSmall5 = CCRotateBy:create(0.5, 2*3)
	local actionSpawnExplodeSmall5 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall5, actionRotateToExplodeSmall5)
	local actionSpawnExplodeSmallEase5 = CCEaseIn:create(actionSpawnExplodeSmall5, 3)
	local actionScaleToExplodeSmall6 = CCScaleTo:create(0.5, 3.75)
	local actionRotateToExplodeSmall6 = CCRotateBy:create(0.5, 8*45)
	local actionSpawnExplodeSmall6 = CCSpawn:createWithTwoActions(actionScaleToExplodeSmall6, actionRotateToExplodeSmall6)
	local actionSpawnExplodeSmallEase6 = CCEaseOut:create(actionSpawnExplodeSmall6, 4)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmallEase1)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmall3)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmall4_1)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmall4_2)
	arrActExplodeSmall:addObject(actionRotateToExplodeSmall4_3)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmallEase5)
	arrActExplodeSmall:addObject(actionSpawnExplodeSmallEase6)
	local function repeatExplodeSmall()
		parent:setOpacity(200)
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateExplodeSmall = CCRotateBy:create(15, -360) 
		local actionForeverExplodeSmall = CCRepeatForever:create(actionRotateExplodeSmall)
		parent:runAction(actionForeverExplodeSmall)
	end
	arrActExplodeSmall:addObject(CCCallFuncN:create(repeatExplodeSmall))
	local actionExplodeSmall = CCSequence:create(arrActExplodeSmall)
	return actionExplodeSmall
end

local function createExplodeBigAction(parent, nBlendType)
	local arrActExplodeBig = CCArray:create()
	local actionScaleToExplodeBig1 = CCScaleTo:create(0.6, 5.86*1.8)
	local actionRotateToExplodeBig1 = CCRotateBy:create(0.6, -5*45)
	local actionSpawnExplodeBig1 = CCSpawn:createWithTwoActions(actionScaleToExplodeBig1, actionRotateToExplodeBig1)
	local actionScaleToExplodeBig3 = CCScaleTo:create(0.6, 5.86*0.5)
	local actionRotateToExplodeBig3 = CCRotateBy:create(1, -5*60)
	local actionSpawnExplodeBig3 = CCSpawn:createWithTwoActions(actionScaleToExplodeBig3, actionRotateToExplodeBig3)
	local actionScaleToExplodeBig4 = CCScaleTo:create(1, 5.86*1.5)
	local actionRotateToExplodeBig4 = CCRotateBy:create(1, -5*45)
	local actionSpawnExplodeBig4 = CCSpawn:createWithTwoActions(actionScaleToExplodeBig4, actionRotateToExplodeBig4)
	local actionFadeToExplodeBig5 = CCFadeTo:create(0.5, 0)
	local actionRotateToExplodeBig5 = CCRotateBy:create(0.5, -5*3)
	local actionSpawnExplodeBig5 = CCSpawn:createWithTwoActions(actionFadeToExplodeBig5, actionRotateToExplodeBig5)
	local actionScaleToExplodeBig6 = CCScaleTo:create(0.5, 4.10)
	local actionFadeToExplodeBig6 = CCFadeTo:create(0.5, 255)
	local actionSpawnExplodeBig6 = CCSpawn:createWithTwoActions(actionScaleToExplodeBig6, actionFadeToExplodeBig6)
	local actionSpawnExplodeBigEase6 = CCEaseOut:create(actionSpawnExplodeBig6, 4)
	arrActExplodeBig:addObject(actionSpawnExplodeBig1)
	arrActExplodeBig:addObject(actionSpawnExplodeBig3)
	arrActExplodeBig:addObject(actionSpawnExplodeBig4)
	arrActExplodeBig:addObject(actionSpawnExplodeBig5)
	arrActExplodeBig:addObject(actionSpawnExplodeBigEase6)
	local function repeatExplodeBig()
		parent:setOpacity(200)
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateExplodeBig = CCRotateBy:create(15, 360) 
		local actionForeverExplodeBig = CCRepeatForever:create(actionRotateExplodeBig)
		parent:runAction(actionForeverExplodeBig)
	end
	arrActExplodeBig:addObject(CCCallFuncN:create(repeatExplodeBig))
	local actionExplodeBig = CCSequence:create(arrActExplodeBig)
	return actionExplodeBig
end

local function createCrossLightHorizontalAction(parent, nBlendType)
	local arrActCrossLightHorizontal = CCArray:create()
	local actionScaleToCrossLightHorizontal1_1 = CCScaleTo:create(0.6/2, 1.8*3, 3)
	local actionScaleToCrossLightHorizontal1_2 = CCScaleTo:create(0.6/2, 1*3, 3)
	local actionScaleToCrossLightHorizontal4_1 = CCScaleTo:create(1/4, 2*1.5*3, 3)
	local actionScaleToCrossLightHorizontal4_2 = CCScaleTo:create(1/4, 3, 3)
	local actionScaleToCrossLightHorizontal5 = CCScaleTo:create(0.5, 5.6)
	local actionScaleToCrossLightHorizontalEase5 = CCEaseIn:create(actionScaleToCrossLightHorizontal5, 3)
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontal1_1)
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontal1_2)
	arrActCrossLightHorizontal:addObject(CCDelayTime:create(0.6))
	local function playSound()
		g_playSoundEffect("Sound/Skill/Fire_FrostNova.mp3")
	end
	arrActCrossLightHorizontal:addObject(CCCallFuncN:create(playSound))
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontal4_1)
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontal4_2)
	arrActCrossLightHorizontal:addObject(CCDelayTime:create(1/2))
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontalEase5)
	local function repeatCrossLightHorizontal()
		g_SetBlendFuncWidget(parent, nBlendType)
		local arrActCrossLightHorizontal = CCArray:create()
		local actionFadeToCrossLightHorizontal1 = CCFadeTo:create(0.6, 150)
		local actionFadeToCrossLightHorizontal2 = CCFadeTo:create(0.6, 255)
		arrActCrossLightHorizontal:addObject(actionFadeToCrossLightHorizontal1)
		arrActCrossLightHorizontal:addObject(actionFadeToCrossLightHorizontal2)
		local actionCrossLightHorizontal = CCSequence:create(arrActCrossLightHorizontal)
		local actionForeverCrossLightHorizontal = CCRepeatForever:create(actionCrossLightHorizontal)
		parent:runAction(actionForeverCrossLightHorizontal)
	end
	arrActCrossLightHorizontal:addObject(CCCallFuncN:create(repeatCrossLightHorizontal))
	local actionCrossLightHorizontal = CCSequence:create(arrActCrossLightHorizontal)
	return actionCrossLightHorizontal
end

local function createCrossLightVerticalAction(parent, nBlendType)
	local arrActCrossLightVertical = CCArray:create()
	local actionScaleToCrossLightVertical1_1 = CCScaleTo:create(0.6/2, 1.8*2, 2)
	local actionScaleToCrossLightVertical1_2 = CCScaleTo:create(0.6/2, 1*2, 2)
	local actionScaleToCrossLightVertical4_1 = CCScaleTo:create(0.6/4, 2*1.5*2, 2)
	local actionScaleToCrossLightVertical4_2 = CCScaleTo:create(0.6/4, 2, 2)
	local actionScaleToCrossLightVertical5 = CCScaleTo:create(0.5, 5.6, 0.7*5.6)
	local actionScaleToCrossLightVerticalEase5 = CCEaseIn:create(actionScaleToCrossLightVertical5, 3)
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVertical1_1)
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVertical1_2)
	arrActCrossLightVertical:addObject(CCDelayTime:create(0.6))
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVertical4_1)
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVertical4_2)
	arrActCrossLightVertical:addObject(CCDelayTime:create(1/2))
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVerticalEase5)
	local function repeatCrossLightVertical()
		g_SetBlendFuncWidget(parent, nBlendType)
		local arrActCrossLightVertical = CCArray:create()
		local actionFadeToCrossLightVertical1 = CCFadeTo:create(0.6, 150)
		local actionFadeToCrossLightVertical2 = CCFadeTo:create(0.6, 255)
		arrActCrossLightVertical:addObject(actionFadeToCrossLightVertical1)
		arrActCrossLightVertical:addObject(actionFadeToCrossLightVertical2)
		local actionCrossLightVertical = CCSequence:create(arrActCrossLightVertical)
		local actionForeverCrossLightVertical = CCRepeatForever:create(actionCrossLightVertical)
		parent:runAction(actionForeverCrossLightVertical)
	end
	arrActCrossLightVertical:addObject(CCCallFuncN:create(repeatCrossLightVertical))
	local actionCrossLightVertical = CCSequence:create(arrActCrossLightVertical)
	return actionCrossLightVertical
end

local function createCardLightAction(parent, nBlendType)
	local arrActCardLight = CCArray:create()
	local actionScaleToCardLight1_1 = CCScaleTo:create(0.6/2, 1.8*1.7)
	local actionMoveToCardLight1_1 = CCMoveTo:create(0.6/2, ccp(20, 0))
	local actionSpawnCardLight1_1 = CCSpawn:createWithTwoActions(actionScaleToCardLight1_1, actionMoveToCardLight1_1)
	local actionScaleToCardLight1_2 = CCScaleTo:create(0.6/4, 1.7)
	local actionMoveToCardLight1_2 = CCMoveTo:create(0.6/4, ccp(0, 0))
	local actionSpawnCardLight1_2 = CCSpawn:createWithTwoActions(actionScaleToCardLight1_2, actionMoveToCardLight1_2)
	local actionScaleToCardLight4_1 = CCScaleTo:create(1/4, 1.5*2.4)
	local actionScaleToCardLight4_2 = CCScaleTo:create(1/4, 2.4)
	local actionScaleToCardLight5 = CCScaleTo:create(0.5, 2.4)
	arrActCardLight:addObject(actionSpawnCardLight1_1)
	arrActCardLight:addObject(actionSpawnCardLight1_2)
	arrActCardLight:addObject(CCDelayTime:create(0.6))
	arrActCardLight:addObject(actionScaleToCardLight4_1)
	arrActCardLight:addObject(actionScaleToCardLight4_2)
	arrActCardLight:addObject(CCDelayTime:create(1/2))
	arrActCardLight:addObject(actionScaleToCardLight5)
	local function repeatCardLight()
		g_SetBlendFuncWidget(parent, nBlendType)
		local arrActCardLight = CCArray:create()
		local actionFadeToCardLight1 = CCFadeTo:create(0.6, 150)
		local actionFadeToCardLight2 = CCFadeTo:create(0.6, 255)
		arrActCardLight:addObject(actionFadeToCardLight1)
		arrActCardLight:addObject(actionFadeToCardLight2)
		local actionCardLight = CCSequence:create(arrActCardLight)
		local actionForeverCardLight = CCRepeatForever:create(actionCardLight)
		parent:runAction(actionForeverCardLight)
	end
	arrActCardLight:addObject(CCCallFuncN:create(repeatCardLight))
	local actionCardLight = CCSequence:create(arrActCardLight)
	return actionCardLight
end

local function createCircleInSideBigAction(parent, nBlendType)
	local arrActCircleInSideBig = CCArray:create()
	local actionScaleToCircleInSideBig1 = CCScaleTo:create(0.6, 3.75*1.8)
	local actionRotateToCircleInSideBig1 = CCRotateBy:create(0.6, 8*45)
	local actionSpawnCircleInSideBig1 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig1, actionRotateToCircleInSideBig1)
	local actionSpawnCircleInSideBigEase1 = CCEaseOut:create(actionSpawnCircleInSideBig1, 0.3)
	local actionScaleToCircleInSideBig3 = CCScaleTo:create(0.6, 3.75*0.5)
	local actionRotateToCircleInSideBig3 = CCRotateBy:create(0.6, 4*60)
	local actionSpawnCircleInSideBig3 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig3, actionRotateToCircleInSideBig3)
	local actionScaleToCircleInSideBig4_1 = CCScaleTo:create(1/4, 0.5*1.5*3.75)
	local actionRotateToCircleInSideBig4_1 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnCircleInSideBig4_1 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig4_1, actionRotateToCircleInSideBig4_1)
	local actionScaleToCircleInSideBig4_2 = CCScaleTo:create(1/4, 0.5*3.75)
	local actionRotateToCircleInSideBig4_2 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnCircleInSideBig4_2 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig4_2, actionRotateToCircleInSideBig4_2)
	local actionRotateToCircleInSideBig4_3 = CCRotateBy:create(1/2, 4*45)
	local actionScaleToCircleInSideBig5 = CCScaleTo:create(0.5, 3*3.75)
	local actionRotateToCircleInSideBig5 = CCRotateBy:create(0.5, 2*3)
	local actionSpawnCircleInSideBig5 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig5, actionRotateToCircleInSideBig5)
	local actionSpawnCircleInSideBigEase5 = CCEaseIn:create(actionSpawnCircleInSideBig5, 3)
	local actionScaleToCircleInSideBig6 = CCScaleTo:create(0.5, 3.33)
	local actionRotateToCircleInSideBig6 = CCRotateBy:create(0.5, 8*45)
	local actionSpawnCircleInSideBig6 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideBig6, actionRotateToCircleInSideBig6)
	local actionSpawnCircleInSideBigEase6 = CCEaseOut:create(actionSpawnCircleInSideBig6, 4)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBigEase1)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBig3)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBig4_1)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBig4_2)
	arrActCircleInSideBig:addObject(actionRotateToCircleInSideBig4_3)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBigEase5)
	arrActCircleInSideBig:addObject(actionSpawnCircleInSideBigEase6)
	local function repeatCircleInSideBig()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateCircleInSideBig = CCRotateBy:create(15, 360) 
		local actionForeverCircleInSideBig = CCRepeatForever:create(actionRotateCircleInSideBig)
		parent:runAction(actionForeverCircleInSideBig)
	end
	arrActCircleInSideBig:addObject(CCCallFuncN:create(repeatCircleInSideBig))
	local actionCircleInSideBig = CCSequence:create(arrActCircleInSideBig)
	return actionCircleInSideBig
end

local function createCircleInSideSmallAction(parent, nBlendType)
	local arrActCircleInSideSmall = CCArray:create()
	local actionScaleToCircleInSideSmall1 = CCScaleTo:create(0.6, 3.6*1.8)
	local actionRotateToCircleInSideSmall1 = CCRotateBy:create(0.6, 8*45)
	local actionSpawnCircleInSideSmall1 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall1, actionRotateToCircleInSideSmall1)
	local actionSpawnCircleInSideSmallEase1 = CCEaseOut:create(actionSpawnCircleInSideSmall1, 0.3)
	local actionScaleToCircleInSideSmall3 = CCScaleTo:create(0.6, 3.6*0.5)
	local actionRotateToCircleInSideSmall3 = CCRotateBy:create(0.6, 4*60)
	local actionSpawnCircleInSideSmall3 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall3, actionRotateToCircleInSideSmall3)
	local actionScaleToCircleInSideSmall4_1 = CCScaleTo:create(1/4, 0.5*1.5*3.6)
	local actionRotateToCircleInSideSmall4_1 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnCircleInSideSmall4_1 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall4_1, actionRotateToCircleInSideSmall4_1)
	local actionScaleToCircleInSideSmall4_2 = CCScaleTo:create(1/4, 0.5*3.6)
	local actionRotateToCircleInSideSmall4_2 = CCRotateBy:create(1/4, 2*45)
	local actionSpawnCircleInSideSmall4_2 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall4_2, actionRotateToCircleInSideSmall4_2)
	local actionRotateToCircleInSideSmall4_3 = CCRotateBy:create(1/2, 2*45)
	local actionScaleToCircleInSideSmall5 = CCScaleTo:create(0.5, 3*3.6)
	local actionRotateToCircleInSideSmall5 = CCRotateBy:create(0.5, 2*3)
	local actionSpawnCircleInSideSmall5 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall5, actionRotateToCircleInSideSmall5)
	local actionSpawnCircleInSideSmallEase5 = CCEaseIn:create(actionSpawnCircleInSideSmall5, 3)
	local actionScaleToCircleInSideSmall6 = CCScaleTo:create(0.5, 3.6)
	local actionRotateToCircleInSideSmall6 = CCRotateBy:create(0.5, 8*45)
	local actionSpawnCircleInSideSmall6 = CCSpawn:createWithTwoActions(actionScaleToCircleInSideSmall6, actionRotateToCircleInSideSmall6)
	local actionSpawnCircleInSideSmallEase6 = CCEaseOut:create(actionSpawnCircleInSideSmall6, 4)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmallEase1)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmall3)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmall4_1)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmall4_2)
	arrActCircleInSideSmall:addObject(actionRotateToCircleInSideSmall4_3)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmallEase5)
	arrActCircleInSideSmall:addObject(actionSpawnCircleInSideSmallEase6)
	local function repeatCircleInSideSmall()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateCircleInSideSmall = CCRotateBy:create(15, -360) 
		local actionForeverCircleInSideSmall = CCRepeatForever:create(actionRotateCircleInSideSmall)
		parent:runAction(actionForeverCircleInSideSmall)
	end
	arrActCircleInSideSmall:addObject(CCCallFuncN:create(repeatCircleInSideSmall))
	local actionCircleInSideSmall = CCSequence:create(arrActCircleInSideSmall)
	return actionCircleInSideSmall
end

local function createCircleOutSideBigAction(parent, nBlendType)
	local arrActCircleOutSideBig = CCArray:create()
	local actionScaleToCircleOutSideBig1 = CCScaleTo:create(0.6, 4.37*1.8)
	local actionRotateToCircleOutSideBig1 = CCRotateBy:create(0.6, -8*45)
	local actionSpawnCircleOutSideBig1 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig1, actionRotateToCircleOutSideBig1)
	local actionSpawnCircleOutSideBigEase1 = CCEaseOut:create(actionSpawnCircleOutSideBig1, 0.3)
	local actionScaleToCircleOutSideBig3 = CCScaleTo:create(0.6, 4.37*0.5)
	local actionRotateToCircleOutSideBig3 = CCRotateBy:create(0.6, -4*60)
	local actionSpawnCircleOutSideBig3 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig3, actionRotateToCircleOutSideBig3)
	local actionScaleToCircleOutSideBig4_1 = CCScaleTo:create(1/4, 0.5*1.5*4.37)
	local actionRotateToCircleOutSideBig4_1 = CCRotateBy:create(1/4, -2*45)
	local actionSpawnCircleOutSideBig4_1 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig4_1, actionRotateToCircleOutSideBig4_1)
	local actionScaleToCircleOutSideBig4_2 = CCScaleTo:create(1/4, 0.5*4.37)
	local actionRotateToCircleOutSideBig4_2 = CCRotateBy:create(1/4, -2*45)
	local actionSpawnCircleOutSideBig4_2 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig4_2, actionRotateToCircleOutSideBig4_2)
	local actionRotateToCircleOutSideBig4_3 = CCRotateBy:create(1/2, -2*45)
	local actionScaleToCircleOutSideBig5 = CCScaleTo:create(0.5, 3*4.37)
	local actionRotateToCircleOutSideBig5 = CCRotateBy:create(0.5, -2*3)
	local actionSpawnCircleOutSideBig5 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig5, actionRotateToCircleOutSideBig5)
	local actionSpawnCircleOutSideBigEase5 = CCEaseIn:create(actionSpawnCircleOutSideBig5, 3)
	local actionScaleToCircleOutSideBig6 = CCScaleTo:create(0.5, 4.58)
	local actionRotateToCircleOutSideBig6 = CCRotateBy:create(0.5, -8*45)
	local actionSpawnCircleOutSideBig6 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideBig6, actionRotateToCircleOutSideBig6)
	local actionSpawnCircleOutSideBigEase6 = CCEaseOut:create(actionSpawnCircleOutSideBig6, 4)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBigEase1)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBig3)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBig4_1)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBig4_2)
	arrActCircleOutSideBig:addObject(actionRotateToCircleOutSideBig4_3)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBigEase5)
	arrActCircleOutSideBig:addObject(actionSpawnCircleOutSideBigEase6)
	local function repeatCircleOutSideBig()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateCircleOutSideBig = CCRotateBy:create(30, 360) 
		local actionForeverCircleOutSideBig = CCRepeatForever:create(actionRotateCircleOutSideBig)
		parent:runAction(actionForeverCircleOutSideBig)
	end
	arrActCircleOutSideBig:addObject(CCCallFuncN:create(repeatCircleOutSideBig))
	local actionCircleOutSideBig = CCSequence:create(arrActCircleOutSideBig)
	return actionCircleOutSideBig
end

local function createCircleOutSideSmallAction(parent, nBlendType)
	local arrActCircleOutSideSmall = CCArray:create()
	local actionScaleToCircleOutSideSmall1 = CCScaleTo:create(0.6, 4.31*1.8)
	local actionRotateToCircleOutSideSmall1 = CCRotateBy:create(0.6, -8*45)
	local actionSpawnCircleOutSideSmall1 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall1, actionRotateToCircleOutSideSmall1)
	local actionSpawnCircleOutSideSmallEase1 = CCEaseOut:create(actionSpawnCircleOutSideSmall1, 0.3)
	local actionScaleToCircleOutSideSmall3 = CCScaleTo:create(0.6, 4.31*0.5)
	local actionRotateToCircleOutSideSmall3 = CCRotateBy:create(0.6, -4*60)
	local actionSpawnCircleOutSideSmall3 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall3, actionRotateToCircleOutSideSmall3)
	local actionScaleToCircleOutSideSmall4_1 = CCScaleTo:create(1/4, 0.5*1.5*4.31)
	local actionRotateToCircleOutSideSmall4_1 = CCRotateBy:create(1/4, -2*45)
	local actionSpawnCircleOutSideSmall4_1 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall4_1, actionRotateToCircleOutSideSmall4_1)
	local actionScaleToCircleOutSideSmall4_2 = CCScaleTo:create(1/4, 0.5*4.31)
	local actionRotateToCircleOutSideSmall4_2 = CCRotateBy:create(1/4, -2*45)
	local actionSpawnCircleOutSideSmall4_2 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall4_2, actionRotateToCircleOutSideSmall4_2)
	local actionRotateToCircleOutSideSmall4_3 = CCRotateBy:create(1/2, -2*45)
	local actionScaleToCircleOutSideSmall5 = CCScaleTo:create(0.5, 3*4.31)
	local actionRotateToCircleOutSideSmall5 = CCRotateBy:create(0.5, -2*3)
	local actionSpawnCircleOutSideSmall5 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall5, actionRotateToCircleOutSideSmall5)
	local actionSpawnCircleOutSideSmallEase5 = CCEaseIn:create(actionSpawnCircleOutSideSmall5, 3)
	local actionScaleToCircleOutSideSmall6 = CCScaleTo:create(0.5, 4.31)
	local actionRotateToCircleOutSideSmall6 = CCRotateBy:create(0.5, -8*45)
	local actionSpawnCircleOutSideSmall6 = CCSpawn:createWithTwoActions(actionScaleToCircleOutSideSmall6, actionRotateToCircleOutSideSmall6)
	local actionSpawnCircleOutSideSmallEase6 = CCEaseOut:create(actionSpawnCircleOutSideSmall6, 4)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmallEase1)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmall3)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmall4_1)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmall4_2)
	arrActCircleOutSideSmall:addObject(actionRotateToCircleOutSideSmall4_3)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmallEase5)
	arrActCircleOutSideSmall:addObject(actionSpawnCircleOutSideSmallEase6)
	local function repeatCircleOutSideSmall()
		g_SetBlendFuncWidget(parent, nBlendType)
		local actionRotateCircleOutSideSmall = CCRotateBy:create(30, -360) 
		local actionForeverCircleOutSideSmall = CCRepeatForever:create(actionRotateCircleOutSideSmall)
		parent:runAction(actionForeverCircleOutSideSmall)
	end
	arrActCircleOutSideSmall:addObject(CCCallFuncN:create(repeatCircleOutSideSmall))
	local actionCircleOutSideSmall = CCSequence:create(arrActCircleOutSideSmall)
	return actionCircleOutSideSmall
end

--伙伴
function Game_SummonAnimation:setCardPNL(CSV_Data, nItemEvoluteLevel)
	self.ImageView_CardPNL:setVisible(true)

	--伙伴名称
	local Label_Name = tolua.cast(self.ImageView_CardPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_Data.Name)
	g_SetCardNameColorByEvoluteLev(Label_Name, nItemEvoluteLevel)
	
	--伙伴类型
	local AtlasLabel_Profession = tolua.cast(Label_Name:getChildByName("AtlasLabel_Profession"),"LabelAtlas")
	AtlasLabel_Profession:setStringValue(CSV_Data.Profession)
	
	local professionSize = AtlasLabel_Profession:getContentSize()
	local labelSize = Label_Name:getContentSize()
	
	Label_Name:setPositionX(5 -(labelSize.width+professionSize.width*0.7)/2)
	AtlasLabel_Profession:setPositionX(labelSize.width + 5)
	
	local star = "1"
	for i = 2, CSV_Data.StarLevel do
		star = star.."1"	
	end
	--伙伴星级
	local LabelAtlas_StarLevel = tolua.cast(self.ImageView_CardPNL:getChildByName("LabelAtlas_StarLevel"),"LabelAtlas")
	LabelAtlas_StarLevel:setStringValue(star)
	--生命 文字
	local Label_HPMaxLB = tolua.cast(self.ImageView_CardPNL:getChildByName("Label_HPMaxLB"),"Label")
	--生命 数值
	local Label_HPMax = tolua.cast(Label_HPMaxLB:getChildByName("Label_HPMax"),"Label")
	Label_HPMax:setText(CSV_Data.BaseHPMax)
	Label_HPMax:setPositionX(Label_HPMaxLB:getSize().width)
	--武力 文字
	local Label_ForcePointsLB = tolua.cast(self.ImageView_CardPNL:getChildByName("Label_ForcePointsLB"),"Label")
	--武力 数值
	local Label_ForcePoints = tolua.cast(Label_ForcePointsLB:getChildByName("Label_ForcePoints"),"Label")
	Label_ForcePoints:setText(CSV_Data.ForcePoints)
	Label_ForcePoints:setPositionX(Label_ForcePointsLB:getSize().width)
	--法术 文字
	local Label_MagicPointsLB = tolua.cast(self.ImageView_CardPNL:getChildByName("Label_MagicPointsLB"),"Label")
	--法术 数值
	local Label_MagicPoints = tolua.cast(Label_MagicPointsLB:getChildByName("Label_MagicPoints"),"Label")		
	Label_MagicPoints:setText(CSV_Data.MagicPoints)
	Label_MagicPoints:setPositionX(Label_MagicPointsLB:getSize().width)
	--绝技 文字
	local Label_SkillPointsLB = tolua.cast(self.ImageView_CardPNL:getChildByName("Label_SkillPointsLB"),"Label")
	--绝技 数值
	local Label_SkillPoints = tolua.cast(Label_SkillPointsLB:getChildByName("Label_SkillPoints"),"Label")
	Label_SkillPoints:setText(CSV_Data.SkillPoints)
	Label_SkillPoints:setPositionX(Label_SkillPointsLB:getSize().width)
	
	g_AdjustWidgetsPosition({Label_HPMaxLB, Label_ForcePointsLB, Label_MagicPointsLB, Label_SkillPointsLB},80)
	
	local tbSoundFileSuffix = string.split(CSV_Data.DialogueSound, "|")
	local nMax = #tbSoundFileSuffix
	local nSoundIndex = math.random(1, nMax)
	g_playSoundEffect("Sound/Dialogue/"..CSV_Data.SpineAnimation.."_"..tbSoundFileSuffix[nSoundIndex]..".mp3")
end

--装备
function Game_SummonAnimation:setEquipPNL(CSV_Data, nItemID)
	self.ImageView_EquipPNL:setVisible(true)

	--装备名称
	local Label_Name = tolua.cast(self.ImageView_EquipPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_Data.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Data.ColorType)
	--增加的属性 比如 （物理攻击+1000）
	local Label_MainProp = tolua.cast(self.ImageView_EquipPNL:getChildByName("Label_MainProp"),"Label")
	Label_MainProp:setText(g_tbEquipMainProp[CSV_Data.SubType].."+"..CSV_Data.BaseMainProp)
	local tbEquip = g_Hero:getEquipObjByServID(nItemID)
	local tbProp = tbEquip:getEquipTbProp()
	--增加的属性 
	for i = 1,3 do 
		local Label_AdditionalProp = tolua.cast(self.ImageView_EquipPNL:getChildByName("Label_AdditionalProp"..i),"Label")		
		local tbSubProp = tbProp[i]
		local nType = tbSubProp.Prop_Type
		local fProp = tbSubProp.Prop_Value/100
		Label_AdditionalProp:setText(g_PropName[nType].."+"..fProp.."%")
		setRandomPropColor(Label_AdditionalProp,tbSubProp.Prop_Value, CSV_Data.PropTypeRandID)
	end
	
	local Label_Desc = tolua.cast(self.ImageView_EquipPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(CSV_Data.Desc)
end

--妖兽
function Game_SummonAnimation:setFatePNL(CSV_Data)	
	self.ImageView_FatePNL:setVisible(true)
	local nItemNum = self.tbParams.nItemNum

	--妖兽名称
	local Label_Name = tolua.cast(self.ImageView_FatePNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_Data.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Data.ColorType)
	-- CSV_Data.ColorType
	--增加的属性
	local Label_MainProp = tolua.cast(self.ImageView_FatePNL:getChildByName("Label_MainProp"),"Label")
	Label_MainProp:setText(g_tbFatePropName[CSV_Data.Type].."+"..CSV_Data.PropValue)
	--经验 （0/100）
	local Label_FateExp = tolua.cast(self.ImageView_FatePNL:getChildByName("Label_FateExp"),"Label")
	Label_FateExp:setText(_T("经验 0/")..CSV_Data.FullLevelExp)
	--描述
	local Label_Desc = tolua.cast(self.ImageView_FatePNL:getChildByName("Label_Desc"),"Label")	
	Label_Desc:setText(CSV_Data.Desc)
end

function Game_SummonAnimation:setHunpoPNL(CSV_Data)	
	self.ImageView_OtherItemsPNL:setVisible(true)
	local nItemNum = self.tbParams.nItemNum
	local name = CSV_Data.Name
	if nItemNum then 
		name = CSV_Data.Name.."×"..nItemNum
	end
	--物品名称
	local Label_Name = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Data.CardStarLevel)
	--星级
	local Image_StarLevel = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Image_StarLevel"),"ImageView")
	Image_StarLevel:loadTexture(getUIImg("Icon_StarLevel"..CSV_Data.CardStarLevel))
	--描述
	local Label_Desc = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Label_Desc"),"Label")
	Label_Desc:setText(CSV_Data.Desc)
	
end

function Game_SummonAnimation:setItemsPNL(CSV_Data)
	self.ImageView_OtherItemsPNL:setVisible(true)
	local nItemNum = self.tbParams.nItemNum
	local name = CSV_Data.Name
	if nItemNum then 
		name = CSV_Data.Name.."×"..nItemNum
	end
	--物品名称
	local Label_Name = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Data.ColorType)
	--星级
	local Image_StarLevel = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Image_StarLevel"),"ImageView")
	Image_StarLevel:loadTexture(getUIImg("Icon_StarLevel"..CSV_Data.ColorType))
	--描述
	local Label_Desc = tolua.cast(self.ImageView_OtherItemsPNL:getChildByName("Label_Desc"),"Label")
	Label_Desc:setText(CSV_Data.Desc)
	
end

function Game_SummonAnimation:setImage_SummonItemShowPNL()
	local CSV_Data = self.tbParams.CSV_Data
	local nItemID = self.tbParams.nItemID
	local nItemType = self.tbParams.nItemType
	local nItemEvoluteLevel = self.tbParams.nItemEvoluteLevel
	local strItemIcon = self.tbParams.strItemIcon

	if nItemType == macro_pb.ITEM_TYPE_CARD then 		--伙伴
		local Panel_CardPos = self.Image_SummonItemShowPNL:getChildByName("Panel_CardPos")
		Panel_CardPos:setVisible(true)
		
		local Image_Card = tolua.cast(Panel_CardPos:getChildByName("Image_Card"),"ImageView")
		local CCNode_Skeleton = g_CocosSpineAnimation(CSV_Data.SpineAnimation, 1)
		Image_Card:removeAllNodes()
		Image_Card:loadTexture(getUIImg("Blank"))
		Image_Card:setPositionXY(CSV_Data.Pos_X*Panel_CardPos:getScale()/0.6, CSV_Data.Pos_Y*Panel_CardPos:getScale()/0.6)
		Image_Card:addNode(CCNode_Skeleton)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)

		self:setCardPNL(CSV_Data, nItemEvoluteLevel)
	elseif nItemType == macro_pb.ITEM_TYPE_EQUIP then 		--装备
		local Panel_Equip = self.Image_SummonItemShowPNL:getChildByName("Panel_Equip")
		Panel_Equip:setVisible(true)
		local Image_EquipIcon = tolua.cast(Panel_Equip:getChildByName("Image_EquipIcon"),"ImageView")
		Image_EquipIcon:loadTexture(strItemIcon)
		
		g_SetEquipSacle(Image_EquipIcon,CSV_Data.SubType)
		
		self:setEquipPNL(CSV_Data, nItemID)
	elseif nItemType == macro_pb.ITEM_TYPE_FATE then 		--异兽
		local Panel_Fate = self.Image_SummonItemShowPNL:getChildByName("Panel_Fate")
		Panel_Fate:setVisible(true)
		local Image_FateIcon = tolua.cast(Panel_Fate:getChildByName("Image_FateIcon"),"ImageView")
		Image_FateIcon:setPosition(ccp(0+CSV_Data.OffsetX, 10+CSV_Data.OffsetY))
		Image_FateIcon:loadTexture(strItemIcon)
		CSV_Data.Name = CSV_Data.Name
		self:setFatePNL(CSV_Data)
	elseif nItemType == macro_pb.ITEM_TYPE_CARD_GOD then 	--元神(魂魄)
		local Panel_HunPo = self.Image_SummonItemShowPNL:getChildByName("Panel_HunPo")
		Panel_HunPo:setVisible(true)
		local Image_Icon = tolua.cast(Panel_HunPo:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:setVisible(false)
		
		local Image_Cover = tolua.cast(Panel_HunPo:getChildByName("Image_Cover"),"ImageView")
		Image_Cover:loadTexture(getUIImg("SummonHunPoCover"..CSV_Data.CardStarLevel))
		
		local Image_HunPo = tolua.cast(Panel_HunPo:getChildByName("Image_HunPo"),"ImageView")
		Image_HunPo:loadTexture(getUIImg("SummonHunPoBase"..CSV_Data.CardStarLevel))
		local spriteCover = SpriteCoverlipping(strItemIcon,getUIImg("SummonHunPoBase"..CSV_Data.CardStarLevel))
		if spriteCover ~= nil then
			Image_HunPo:removeAllNodes()
			Image_HunPo:addNode(spriteCover,2)
		end
		
		
		local Label_ExchangeTip = tolua.cast(Panel_HunPo:getChildByName("Label_ExchangeTip"),"Label")
		Label_ExchangeTip:setVisible(false)
		local cfgId =  self.tbParams.cfgId 
		if cfgId > 0 then 
			Label_ExchangeTip:setVisible(true)
			local name  = CSV_Data.Name
			local cardsName =  g_DataMgr:getCardBaseCsv(cfgId,1).Name
			Label_ExchangeTip:setText("["..cardsName.."]".._T("已召唤, 已转换为魂魄。"))
		end
	
		self:setHunpoPNL(CSV_Data)
	elseif nItemType == macro_pb.ITEM_TYPE_MATERIAL then 	--ItemBase(道具)
		local itemTypes = CSV_Data.Type
		if itemTypes == 0 then		--打造材料
			local Panel_Material = self.Image_SummonItemShowPNL:getChildByName("Panel_Material")
			Panel_Material:setVisible(true)
			local Image_MaterialIcon = tolua.cast(Panel_Material:getChildByName("Image_MaterialIcon"),"ImageView")
			Image_MaterialIcon:loadTexture(strItemIcon)

		elseif itemTypes == 1 then	--技能碎片
			local Panel_SkillFrag = self.Image_SummonItemShowPNL:getChildByName("Panel_SkillFrag")
			Panel_SkillFrag:setVisible(true)
			local Image_SkillFragIcon = tolua.cast(Panel_SkillFrag:getChildByName("Image_SkillFragIcon"),"ImageView")
			Image_SkillFragIcon:loadTexture(strItemIcon)
			local Image_Symbol = tolua.cast(Panel_SkillFrag:getChildByName("Image_Symbol"),"ImageView")
			Image_Symbol:loadTexture(getFrameSymbolSkillFrag(CSV_Data.ColorType))
		elseif itemTypes == 2 or itemTypes == 6 then	--可使用道具 --增加经验道具
			local Panel_UseItem = self.Image_SummonItemShowPNL:getChildByName("Panel_UseItem")
			Panel_UseItem:setVisible(true)
			local Image_UseItemIcon = tolua.cast(Panel_UseItem:getChildByName("Image_UseItemIcon"),"ImageView")
			Image_UseItemIcon:loadTexture(strItemIcon)
		elseif itemTypes == 3 then	--装备卷轴
			local Panel_Formula = self.Image_SummonItemShowPNL:getChildByName("Panel_Formula")
			Panel_Formula:setVisible(true)
			local Image_EquipIcon = tolua.cast(Panel_Formula:getChildByName("Image_EquipIcon"),"ImageView")
			Image_EquipIcon:loadTexture(strItemIcon)
			local Image_Base = tolua.cast(Panel_Formula:getChildByName("Image_Base"),"ImageView")
			Image_Base:loadTexture(getUIImg("SummonBook"..CSV_Data.ColorType))
			
			g_SetEquipSacle(Image_EquipIcon,CSV_Data.SubType)
		end
		
		self:setItemsPNL(CSV_Data)
		
	elseif nItemType == macro_pb.ITEM_TYPE_SOUL then 		--元神
		local nStarLevel = CSV_Data.StarLevel
		local Panel_Soul = self.Image_SummonItemShowPNL:getChildByName("Panel_Soul")
		Panel_Soul:setVisible(true)
		
		local strItemIcon = CSV_Data.SpineAnimation
		local Image_Soul = tolua.cast(Panel_Soul:getChildByName("Image_Soul"),"ImageView")
		Image_Soul:loadTexture(getUIImg("SummonSoulBase"..nStarLevel))
		local spriteCover = SpriteCoverlipping(getIconImg(strItemIcon),getUIImg("SummonSoulBase"..nStarLevel))
		if spriteCover ~= nil then
			Image_Soul:removeAllNodes()
			Image_Soul:addNode(spriteCover,2)
		end
		
		local Image_Icon = tolua.cast(Panel_Soul:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:setVisible(false)
		
		local Image_Cover = tolua.cast(Panel_Soul:getChildByName("Image_Cover"),"ImageView")
		Image_Cover:loadTexture(getUIImg("SummonSoulCover"..nStarLevel))

		local nStrLen = string.len(CSV_Data.Name)
		local strName = string.sub(CSV_Data.Name, 10, nStrLen)
		CSV_Data.Desc = strName.._T("的元神，被伙伴吞噬后可为伙伴增加境界经验，从而提高伙伴的境界。")
		
		self:setItemsPNL(CSV_Data)
	end

end

function Game_SummonAnimation:showDisappearedAnimation()
	self.Image_RayInSide:stopAllActions()
	self.Image_RayOutSide:stopAllActions()
	self.Image_CrossLightHorizontal:stopAllActions()
	self.Image_CrossLightVertical:stopAllActions()
	self.Image_ExplodeBig:stopAllActions()
	self.Image_ExplodeSmall:stopAllActions()
	self.Image_CircleInSideBig:stopAllActions()
	self.Image_CircleInSideSmall:stopAllActions()
	self.Image_CircleOutSideBig:stopAllActions()
	self.Image_CircleOutSideSmall:stopAllActions()
	self.Image_CardLight:stopAllActions()
	
	local arrActRayInSide = CCArray:create()
	local actionFadeToRayInSide1 = CCFadeTo:create(0.5, 0)
	local actionScaleToRayInSide1 = CCScaleTo:create(0.5, 1)
	local actionSpwanRayInSide1 = CCSpawn:createWithTwoActions(actionFadeToRayInSide1,actionScaleToRayInSide1)
	local actionScaleToRayInSide2 = CCScaleTo:create(0.4, 3*6)
	local actionFadeToRayInSide2 = CCFadeTo:create(0.4, 255)
	local actionSpwanRayInSide2 = CCSpawn:createWithTwoActions(actionScaleToRayInSide2,actionFadeToRayInSide2)
	local actionScaleToRayInSide3 = CCScaleTo:create(0.4, 1)
	local actionFadeToRayInSide4 = CCFadeTo:create(0.4, 0)
	arrActRayInSide:addObject(actionSpwanRayInSide1)
	local function setZOrderRayInSide()
		g_playSoundEffect("Sound/Ani_RewardStart.mp3")
		self.Image_RayInSide:setZOrder(31)
	end
	arrActRayInSide:addObject(CCCallFuncN:create(setZOrderRayInSide))
	arrActRayInSide:addObject(actionSpwanRayInSide2)
	arrActRayInSide:addObject(actionScaleToRayInSide3)
	arrActRayInSide:addObject(actionFadeToRayInSide4)
	local actionRayInSide = CCSequence:create(arrActRayInSide)
	
	local arrActRayOutSide = CCArray:create()
	local actionFadeToRayOutSide1 = CCFadeTo:create(0.5, 0)
	local actionScaleToRayOutSide1 = CCScaleTo:create(0.5, 1)
	local actionSpwanRayOutSide1 = CCSpawn:createWithTwoActions(actionFadeToRayOutSide1,actionScaleToRayOutSide1)
	local actionScaleToRayOutSide2 = CCScaleTo:create(0.4, 3*6)
	local actionFadeToRayOutSide2 = CCFadeTo:create(0.4, 255)
	local actionSpwanRayOutSide2 = CCSpawn:createWithTwoActions(actionScaleToRayOutSide2,actionFadeToRayOutSide2)
	local actionScaleToRayOutSide3 = CCScaleTo:create(0.4, 1)
	local actionFadeToRayOutSide4 = CCFadeTo:create(0.4, 0)
	arrActRayOutSide:addObject(actionSpwanRayOutSide1)
	local function setZOrderRayOutSide()
		self.Image_RayOutSide:setZOrder(32)
	end
	arrActRayOutSide:addObject(CCCallFuncN:create(setZOrderRayOutSide))
	arrActRayOutSide:addObject(actionSpwanRayOutSide2)
	arrActRayOutSide:addObject(actionScaleToRayOutSide3)
	arrActRayOutSide:addObject(actionFadeToRayOutSide4)
	local actionRayOutSide = CCSequence:create(arrActRayOutSide)
		
	local arrActCrossLightHorizontal = CCArray:create()
	local actionFadeToCrossLightHorizontal1 = CCFadeTo:create(0.5, 255)
	local actionScaleToCrossLightHorizontal1 = CCScaleTo:create(0.5, 1*3, 1*3)
	local actionSpwanCrossLightHorizontal1 = CCSpawn:createWithTwoActions(actionFadeToCrossLightHorizontal1,actionScaleToCrossLightHorizontal1)
	local actionScaleToCrossLightHorizontal2 = CCScaleTo:create(0.4, 3*3, 3*3)
	local actionFadeToCrossLightHorizontal2 = CCFadeTo:create(0.4, 255)
	local actionSpwanCrossLightHorizontal2 = CCSpawn:createWithTwoActions(actionScaleToCrossLightHorizontal2,actionFadeToCrossLightHorizontal2)
	local actionScaleToCrossLightHorizontal3 = CCScaleTo:create(0.4, 1*3, 1*3)
	local actionFadeToCrossLightHorizontal4 = CCFadeTo:create(0.4, 0)
	arrActCrossLightHorizontal:addObject(actionSpwanCrossLightHorizontal1)
	arrActCrossLightHorizontal:addObject(actionSpwanCrossLightHorizontal2)
	arrActCrossLightHorizontal:addObject(actionScaleToCrossLightHorizontal3)
	arrActCrossLightHorizontal:addObject(actionFadeToCrossLightHorizontal4)
	local actionCrossLightHorizontal = CCSequence:create(arrActCrossLightHorizontal)
	
	local arrActCrossLightVertical = CCArray:create()
	local actionFadeToCrossLightVertical1 = CCFadeTo:create(0.5, 255)
	local actionScaleToCrossLightVertical1 = CCScaleTo:create(0.5, 1*2, 1*2)
	local actionSpwanCrossLightVertical1 = CCSpawn:createWithTwoActions(actionFadeToCrossLightVertical1,actionScaleToCrossLightVertical1)
	local actionScaleToCrossLightVertical2 = CCScaleTo:create(0.4, 3*2, 3*2)
	local actionFadeToCrossLightVertical2 = CCFadeTo:create(0.4, 255)
	local actionSpwanCrossLightVertical2 = CCSpawn:createWithTwoActions(actionScaleToCrossLightVertical2,actionFadeToCrossLightVertical2)
	local actionScaleToCrossLightVertical3 = CCScaleTo:create(0.4, 1*2, 1*2)
	local actionFadeToCrossLightVertical4 = CCFadeTo:create(0.4, 0)
	arrActCrossLightVertical:addObject(actionSpwanCrossLightVertical1)
	arrActCrossLightVertical:addObject(actionSpwanCrossLightVertical2)
	arrActCrossLightVertical:addObject(actionScaleToCrossLightVertical3)
	arrActCrossLightVertical:addObject(actionFadeToCrossLightVertical4)
	local actionCrossLightVertical = CCSequence:create(arrActCrossLightVertical)
	
	local arrActExplodeBig = CCArray:create()
	local actionScaleToExplodeBig3 = CCScaleTo:create(0.4, 0)
	local actionScaleToExplodeBigEase3 = CCEaseIn:create(actionScaleToExplodeBig3, 4)
	local actionFadeToExplodeBig3 = CCFadeTo:create(0.4, 0)
	local actionRotateToExplodeBig3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanExplodeBig3 = CCArray:create()
	arrActSpwanExplodeBig3:addObject(actionScaleToExplodeBigEase3)
	arrActSpwanExplodeBig3:addObject(actionFadeToExplodeBig3)
	arrActSpwanExplodeBig3:addObject(actionRotateToExplodeBig3)
	local actionSpwanExplodeBig3 = CCSpawn:create(arrActSpwanExplodeBig3)
	arrActExplodeBig:addObject(CCDelayTime:create(0.5))
	arrActExplodeBig:addObject(CCDelayTime:create(0.4))
	arrActExplodeBig:addObject(actionSpwanExplodeBig3)
	local actionExplodeBig = CCSequence:create(arrActExplodeBig)
	
	local arrActExplodeSmall = CCArray:create()
	local actionScaleToExplodeSmall3 = CCScaleTo:create(0.4, 0)
	local actionScaleToExplodeSmallEase3 = CCEaseIn:create(actionScaleToExplodeSmall3, 4)
	local actionFadeToExplodeSmall3 = CCFadeTo:create(0.4, 0)
	local actionRotateToExplodeSmall3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanExplodeSmall3 = CCArray:create()
	arrActSpwanExplodeSmall3:addObject(actionScaleToExplodeSmallEase3)
	arrActSpwanExplodeSmall3:addObject(actionFadeToExplodeSmall3)
	arrActSpwanExplodeSmall3:addObject(actionRotateToExplodeSmall3)
	local actionSpwanExplodeSmall3 = CCSpawn:create(arrActSpwanExplodeSmall3)
	arrActExplodeSmall:addObject(CCDelayTime:create(0.5))
	arrActExplodeSmall:addObject(CCDelayTime:create(0.4))
	arrActExplodeSmall:addObject(actionSpwanExplodeSmall3)
	local actionExplodeSmall = CCSequence:create(arrActExplodeSmall)
	
	local arrActCircleInSideBig = CCArray:create()
	local actionScaleToCircleInSideBig3 = CCScaleTo:create(0.4, 0)
	local actionScaleToCircleInSideBigEase3 = CCEaseIn:create(actionScaleToCircleInSideBig3, 4)
	local actionFadeToCircleInSideBig3 = CCFadeTo:create(0.4, 0)
	local actionRotateToCircleInSideBig3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanCircleInSideBig3 = CCArray:create()
	arrActSpwanCircleInSideBig3:addObject(actionScaleToCircleInSideBigEase3)
	arrActSpwanCircleInSideBig3:addObject(actionFadeToCircleInSideBig3)
	arrActSpwanCircleInSideBig3:addObject(actionRotateToCircleInSideBig3)
	local actionSpwanCircleInSideBig3 = CCSpawn:create(arrActSpwanCircleInSideBig3)
	arrActCircleInSideBig:addObject(CCDelayTime:create(0.5))
	arrActCircleInSideBig:addObject(CCDelayTime:create(0.4))
	arrActCircleInSideBig:addObject(actionSpwanCircleInSideBig3)
	local actionCircleInSideBig = CCSequence:create(arrActCircleInSideBig)
	
	local arrActCircleInSideSmall = CCArray:create()
	local actionScaleToCircleInSideSmall3 = CCScaleTo:create(0.4, 0)
	local actionScaleToCircleInSideSmallEase3 = CCEaseIn:create(actionScaleToCircleInSideSmall3, 4)
	local actionFadeToCircleInSideSmall3 = CCFadeTo:create(0.4, 0)
	local actionRotateToCircleInSideSmall3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanCircleInSideSmall3 = CCArray:create()
	arrActSpwanCircleInSideSmall3:addObject(actionScaleToCircleInSideSmallEase3)
	arrActSpwanCircleInSideSmall3:addObject(actionFadeToCircleInSideSmall3)
	arrActSpwanCircleInSideSmall3:addObject(actionRotateToCircleInSideSmall3)
	local actionSpwanCircleInSideSmall3 = CCSpawn:create(arrActSpwanCircleInSideSmall3)
	arrActCircleInSideSmall:addObject(CCDelayTime:create(0.5))
	arrActCircleInSideSmall:addObject(CCDelayTime:create(0.4))
	arrActCircleInSideSmall:addObject(actionSpwanCircleInSideSmall3)
	local actionCircleInSideSmall = CCSequence:create(arrActCircleInSideSmall)
	
	local arrActCircleOutSideBig = CCArray:create()
	local actionScaleToCircleOutSideBig3 = CCScaleTo:create(0.4, 0)
	local actionScaleToCircleOutSideBigEase3 = CCEaseIn:create(actionScaleToCircleOutSideBig3, 4)
	local actionFadeToCircleOutSideBig3 = CCFadeTo:create(0.4, 0)
	local actionRotateToCircleOutSideBig3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanCircleOutSideBig3 = CCArray:create()
	arrActSpwanCircleOutSideBig3:addObject(actionScaleToCircleOutSideBigEase3)
	arrActSpwanCircleOutSideBig3:addObject(actionFadeToCircleOutSideBig3)
	arrActSpwanCircleOutSideBig3:addObject(actionRotateToCircleOutSideBig3)
	local actionSpwanCircleOutSideBig3 = CCSpawn:create(arrActSpwanCircleOutSideBig3)
	arrActCircleOutSideBig:addObject(CCDelayTime:create(0.5))
	arrActCircleOutSideBig:addObject(CCDelayTime:create(0.4))
	arrActCircleOutSideBig:addObject(actionSpwanCircleOutSideBig3)
	local actionCircleOutSideBig = CCSequence:create(arrActCircleOutSideBig)
	
	local arrActCircleOutSideSmall = CCArray:create()
	local actionScaleToCircleOutSideSmall3 = CCScaleTo:create(0.4, 0)
	local actionScaleToCircleOutSideSmallEase3 = CCEaseIn:create(actionScaleToCircleOutSideSmall3, 4)
	local actionFadeToCircleOutSideSmall3 = CCFadeTo:create(0.4, 0)
	local actionRotateToCircleOutSideSmall3 = CCRotateBy:create(0.4, 45)
	local arrActSpwanCircleOutSideSmall3 = CCArray:create()
	arrActSpwanCircleOutSideSmall3:addObject(actionScaleToCircleOutSideSmallEase3)
	arrActSpwanCircleOutSideSmall3:addObject(actionFadeToCircleOutSideSmall3)
	arrActSpwanCircleOutSideSmall3:addObject(actionRotateToCircleOutSideSmall3)
	local actionSpwanCircleOutSideSmall3 = CCSpawn:create(arrActSpwanCircleOutSideSmall3)
	arrActCircleOutSideSmall:addObject(CCDelayTime:create(0.5))
	arrActCircleOutSideSmall:addObject(CCDelayTime:create(0.4))
	arrActCircleOutSideSmall:addObject(actionSpwanCircleOutSideSmall3)
	local actionCircleOutSideSmall = CCSequence:create(arrActCircleOutSideSmall)
	
	local arryActCardLight = CCArray:create()
	local actionFadeToCardLight1 = CCFadeTo:create(0.5, 255)
	local actionFadeToCardLight2 = CCFadeTo:create(0.4, 0)
	arryActCardLight:addObject(actionFadeToCardLight1)
	arryActCardLight:addObject(actionFadeToCardLight2)
	local function hideAnimationContent()
		self.Button_Return:setVisible(false)
		self.Panel_SummonBase:setVisible(false)
		self.Image_SummonInfoPNL:setVisible(false)
		self.Image_SummonItemShowPNL:setVisible(false)
		if self.tbParams.funcDisappearedCallBack then
			self.tbParams.funcDisappearedCallBack()
		end
		if self.clippingNode then
			self.clippingNode:removeFromParentAndCleanup(true)
		end
	end
	--爆炸达到最大幅度，回调隐藏动画内容
	arryActCardLight:addObject(CCCallFuncN:create(hideAnimationContent))
	local actionCardLight = CCSequence:create(arryActCardLight)
	
	local arrActMask = CCArray:create()
	local actionFadeToMask = CCFadeTo:create(0.4, 0)
	arrActMask:addObject(CCDelayTime:create(0.5 + 0.4 + 0.4))
	arrActMask:addObject(actionFadeToMask)
	local function executeCloseAction()
		g_playSoundEffect("Sound/Equip_Disarm.mp3")
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "Game_SummonAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		g_WndMgr:closeWnd("Game_SummonAnimation")
	end
	arrActMask:addObject(CCCallFuncN:create(executeCloseAction))
	local actionMask = CCSequence:create(arrActMask)
	
	self.Image_RayInSide:runAction(actionRayInSide)
	self.Image_RayOutSide:runAction(actionRayOutSide)
	self.Image_CrossLightHorizontal:runAction(actionCrossLightHorizontal)
	self.Image_CrossLightVertical:runAction(actionCrossLightVertical)
	self.Image_ExplodeBig:runAction(actionExplodeBig)
	self.Image_ExplodeSmall:runAction(actionExplodeSmall)
	self.Image_CircleInSideBig:runAction(actionCircleInSideBig)
	self.Image_CircleInSideSmall:runAction(actionCircleInSideSmall)
	self.Image_CircleOutSideBig:runAction(actionCircleOutSideBig)
	self.Image_CircleOutSideSmall:runAction(actionCircleOutSideSmall)
	self.Image_CardLight:runAction(actionCardLight)
	self.ImageView_Mask:runAction(actionMask)
end

function Game_SummonAnimation:initWnd()
	self.ImageView_AnimationContent = tolua.cast(self.rootWidget:getChildByName("ImageView_AnimationContent"), "ImageView")
	self.ImageView_AnimationContent:removeAllNodes()
	self.ImageView_AnimationContent:setVisible(true)
	self.ImageView_Mask = tolua.cast(self.rootWidget:getChildByName("ImageView_Mask"), "ImageView")
	self.ImageView_Mask:setOpacity(0)
	self.Panel_SummonBase = tolua.cast(self.ImageView_AnimationContent:getChildByName("Panel_SummonBase"), "Layout")
	self.Panel_SummonBase:setVisible(false)
	self.Button_Return = tolua.cast(self.ImageView_AnimationContent:getChildByName("Button_Return"), "Button")
	self.Button_Return:setVisible(false)
	
	self.Image_SummonInfoPNL = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_SummonInfoPNL"), "ImageView")
	self.Image_SummonInfoPNL:setVisible(false)
	self.ImageView_CardPNL = tolua.cast(self.Image_SummonInfoPNL:getChildByName("ImageView_CardPNL"), "ImageView")
	self.ImageView_CardPNL:setVisible(false)
	self.ImageView_EquipPNL = tolua.cast(self.Image_SummonInfoPNL:getChildByName("ImageView_EquipPNL"), "ImageView")
	self.ImageView_EquipPNL:setVisible(false)
	self.ImageView_FatePNL = tolua.cast(self.Image_SummonInfoPNL:getChildByName("ImageView_FatePNL"), "ImageView")
	self.ImageView_FatePNL:setVisible(false)
	self.ImageView_OtherItemsPNL = tolua.cast(self.Image_SummonInfoPNL:getChildByName("ImageView_OtherItemsPNL"), "ImageView")
	self.ImageView_OtherItemsPNL:setVisible(false)
	
	self.Image_SummonItemShowPNL = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_SummonItemShowPNL"), "ImageView")
	self.Image_SummonItemShowPNL:setVisible(false)
	local Panel_CardPos = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_CardPos"), "Layout")
	Panel_CardPos:setVisible(false)
	local Panel_Equip = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_Equip"), "Layout")
	Panel_Equip:setVisible(false)
	local Panel_Fate = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_Fate"), "Layout")
	Panel_Fate:setVisible(false)
	local Panel_HunPo = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_HunPo"), "Layout")
	Panel_HunPo:setVisible(false)
	local Panel_Material = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_Material"), "Layout")
	Panel_Material:setVisible(false)
	local Panel_SkillFrag = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_SkillFrag"), "Layout")
	Panel_SkillFrag:setVisible(false)
	local Panel_UseItem = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_UseItem"), "Layout")
	Panel_UseItem:setVisible(false)
	local Panel_Formula = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_Formula"), "Layout")
	Panel_Formula:setVisible(false)
	local Panel_Soul = tolua.cast(self.Image_SummonItemShowPNL:getChildByName("Panel_Soul"), "Layout")
	Panel_Soul:setVisible(false)
	
	self.Image_RayInSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_RayInSide"), "ImageView")
	self.Image_RayOutSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_RayOutSide"), "ImageView")
	self.Image_CircleXuanWo = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleXuanWo"), "ImageView")
	self.Image_ExplodeBig = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ExplodeBig"), "ImageView")
	self.Image_ExplodeSmall = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ExplodeSmall"), "ImageView")
	self.Image_CrossLightHorizontal = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CrossLightHorizontal"), "ImageView")
	self.Image_CrossLightVertical = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CrossLightVertical"), "ImageView")
	self.Image_CardLight = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CardLight"), "ImageView")
	self.Image_CircleInSideBig = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleInSideBig"), "ImageView")
	self.Image_CircleInSideSmall = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleInSideSmall"), "ImageView")
	self.Image_CircleOutSideBig = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleOutSideBig"), "ImageView")
	self.Image_CircleOutSideSmall = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleOutSideSmall"), "ImageView")
	
	self.Image_RayInSide:setVisible(true)
	self.Image_RayOutSide:setVisible(true)
	self.Image_CircleXuanWo:setVisible(true)
	self.Image_CrossLightHorizontal:setVisible(true)
	self.Image_CrossLightVertical:setVisible(true)
	self.Image_ExplodeBig:setVisible(true)
	self.Image_ExplodeSmall:setVisible(true)
	self.Image_CardLight:setVisible(true)
	self.Image_CircleInSideBig:setVisible(true)
	self.Image_CircleInSideSmall:setVisible(true)
	self.Image_CircleOutSideBig:setVisible(true)
	self.Image_CircleOutSideSmall:setVisible(true)
	
	self.Image_RayInSide:setZOrder(1)
	self.Image_RayOutSide:setZOrder(2)
	self.Image_CircleXuanWo:setZOrder(3)
	self.Image_CrossLightHorizontal:setZOrder(4)
	self.Image_CrossLightVertical:setZOrder(5)
	self.Image_ExplodeBig:setZOrder(6)
	self.Image_ExplodeSmall:setZOrder(7)
	self.Image_CardLight:setZOrder(8)
	self.Image_CircleInSideBig:setZOrder(9)
	self.Image_CircleInSideSmall:setZOrder(10)
	self.Image_CircleOutSideBig:setZOrder(11)
	self.Image_CircleOutSideSmall:setZOrder(12)
	
	g_SetBlendFuncWidget(self.Image_RayInSide, 3)
	g_SetBlendFuncWidget(self.Image_RayOutSide, 3)
	g_SetBlendFuncWidget(self.Image_CircleXuanWo, 3)
	g_SetBlendFuncWidget(self.Image_ExplodeBig, 3)
	g_SetBlendFuncWidget(self.Image_ExplodeSmall, 3)
	g_SetBlendFuncWidget(self.Image_CrossLightHorizontal, 3)
	g_SetBlendFuncWidget(self.Image_CrossLightVertical, 3)
	g_SetBlendFuncWidget(self.Image_CardLight, 3)
	g_SetBlendFuncWidget(self.Image_CircleInSideBig, 3)
	g_SetBlendFuncWidget(self.Image_CircleInSideSmall, 3)
	g_SetBlendFuncWidget(self.Image_CircleOutSideBig, 3)
	g_SetBlendFuncWidget(self.Image_CircleOutSideSmall, 3)
	
	self.Image_RayInSide:setPosition(ccp(0,0))
	self.Image_RayOutSide:setRotation(90)
	self.Image_RayOutSide:setPosition(ccp(0,0))
	self.Image_CircleXuanWo:setPosition(ccp(0,0))
	self.Image_ExplodeBig:setPosition(ccp(0,0))
	self.Image_ExplodeSmall:setPosition(ccp(0,0))
	self.Image_CrossLightHorizontal:setPosition(ccp(0,0))
	self.Image_CrossLightVertical:setRotation(90)
	self.Image_CrossLightVertical:setPosition(ccp(0,0))
	self.Image_CardLight:setPosition(ccp(0,0))
	self.Image_CircleInSideBig:setPosition(ccp(0,0))
	self.Image_CircleInSideSmall:setPosition(ccp(0,0))
	self.Image_CircleOutSideBig:setPosition(ccp(0,0))
	self.Image_CircleOutSideSmall:setPosition(ccp(0,0))
	
	
	self.Image_RayInSide:setOpacity(255)
	self.Image_RayOutSide:setOpacity(255)
	self.Image_CircleXuanWo:setOpacity(255)
	self.Image_CrossLightHorizontal:setOpacity(255)
	self.Image_CrossLightVertical:setOpacity(255)
	self.Image_ExplodeBig:setOpacity(255)
	self.Image_ExplodeSmall:setOpacity(255)
	self.Image_CardLight:setOpacity(255)
	self.Image_CircleInSideBig:setOpacity(255)
	self.Image_CircleInSideSmall:setOpacity(255)
	self.Image_CircleOutSideBig:setOpacity(255)
	self.Image_CircleOutSideSmall:setOpacity(255)
	
	
	self.Image_RayInSide:setScale(0)
	self.Image_RayOutSide:setScale(0)
	self.Image_CircleXuanWo:setScale(0)
	self.Image_CrossLightHorizontal:setScaleX(0)
	self.Image_CrossLightHorizontal:setScaleY(1.5)
	self.Image_CrossLightVertical:setScaleX(0)
	self.Image_CrossLightVertical:setScaleY(1)
	self.Image_ExplodeBig:setScale(0)
	self.Image_ExplodeSmall:setScale(0)
	self.Image_CardLight:setScale(0)
	self.Image_CircleInSideBig:setScale(0)
	self.Image_CircleInSideSmall:setScale(0)
	self.Image_CircleOutSideBig:setScale(0)
	self.Image_CircleOutSideSmall:setScale(0)
	

	self.actionRayInSide =  createRayInSideAction(self.Image_RayInSide, 3)
	self.actionRayOutSide =  createRayOutSideAction(self.Image_RayOutSide, 3)
	self.actionCircleXuanWo =  createCircleXuanWoAction(self.Image_CircleXuanWo, 3)
	self.actionCrossLightHorizontal = createCrossLightHorizontalAction(self.Image_CrossLightHorizontal, 3)
	self.actionCrossLightVertical =  createCrossLightVerticalAction(self.Image_CrossLightVertical, 3)
	self.actionExplodeBig =  createExplodeBigAction(self.Image_ExplodeBig, 3)
	self.actionExplodeSmall =  createExplodeSmallAction(self.Image_ExplodeSmall,3 )
	self.actionCardLight =  createCardLightAction(self.Image_CardLight, 3)
	self.actionCircleInSideBig =  createCircleInSideBigAction(self.Image_CircleInSideBig, 1)
	self.actionCircleInSideSmall =  createCircleInSideSmallAction(self.Image_CircleInSideSmall, 1)
	self.actionCircleOutSideBig =  createCircleOutSideBigAction(self.Image_CircleOutSideBig, 1)
	self.actionCircleOutSideSmall =  createCircleOutSideSmallAction(self.Image_CircleOutSideSmall, 1)
end

function Game_SummonAnimation:closeWnd()
	if self.tbParams.funcEndCallBack then
		self.tbParams.funcEndCallBack()
	end
	
	g_Timer:destroyTimerByID(self.nTimerID_Game_SummonAnimation_1)
	self.nTimerID_Game_SummonAnimation_1 = nil
	g_Timer:destroyTimerByID(self.nTimerID_Game_SummonAnimation_2)
	self.nTimerID_Game_SummonAnimation_2 = nil
	g_Timer:destroyTimerByID(self.nTimerID_Game_SummonAnimation_3)
	self.nTimerID_Game_SummonAnimation_3 = nil
	self.bSummonAnimationLock = nil
	self.tbParams = nil
end

--[[local tbParams ={
	nDropSourceType = tbDropSourceType[dropSrc],
	CSV_Data = CSV_Data,
	strItemIcon = strDropItemIcon,
	nItemID = nDropItemID,
	nItemType = nDropItemType,
	nItemEvoluteLevel = nDropItemEvoluteLevel
	callBackFunc = hidePlayerGuid,
	callBackFuncEnd = nil, 
}
]]--
function Game_SummonAnimation:openWnd(tbParams)
	if g_bReturn then return end
	--避免窗口重复打开
	if self.bSummonAnimationLock then return end

	self.bSummonAnimationLock = true
	self.Button_Return:setTouchEnabled(false)
	self.bCanCloseWnd = false
	self.tbParams = tbParams
	
	local bCanCardFlyRight = true
	local bCanCardFlyLeft = true
	
	self.clippingNode = nil
	local function showSummonDetail()
		self.Button_Return:setVisible(true)
		local function EmitRandomCardShapeLoopRight()
			if not g_WndMgr:getWnd("Game_SummonAnimation") then return true end
			
			if bCanCardFlyRight then
				EmitRandomCardShape(self.ImageView_AnimationContent, ccp(200, 0), 3, 7, 1)
			else
				return true
			end
		end
		local function EmitRandomCardShapeLoopLeft()
			if not g_WndMgr:getWnd("Game_SummonAnimation") then return true end
			if bCanCardFlyLeft then
				EmitRandomCardShape(self.ImageView_AnimationContent, ccp(-200, 0), 3, 7, -1)
			else
				return true
			end
		end
		self.nTimerID_Game_SummonAnimation_1 = g_Timer:pushLimtCountTimer(10000, 0.12, EmitRandomCardShapeLoopRight)
		self.nTimerID_Game_SummonAnimation_2 = g_Timer:pushLimtCountTimer(10000, 0.12, EmitRandomCardShapeLoopLeft)
		
		local Image_SummonBasePNL = tolua.cast(self.Panel_SummonBase:getChildByName("Image_SummonBasePNL"),"ImageView")
		local Image_Glass = tolua.cast(Image_SummonBasePNL:getChildByName("Image_Glass"),"ImageView")
		local Image_Claw = tolua.cast(Image_SummonBasePNL:getChildByName("Image_Claw"),"ImageView")

		if self.tbParams then
			if self.tbParams.nDropSourceType then
				if self.tbParams.nDropSourceType == g_DropSourceType[macro_pb.DS_SUMMONCARD_COPPER] then
					Image_Glass:loadTexture(getSummonImg("Normal_Glass1"))
					Image_Claw:loadTexture(getSummonImg("Normal_Claw1"))
				elseif self.tbParams.nDropSourceType == g_DropSourceType[macro_pb.DS_SUMMONCARD_COUPONS] then
					Image_Glass:loadTexture(getSummonImg("Normal_Glass2"))
					Image_Claw:loadTexture(getSummonImg("Normal_Claw2"))
				end
			else
				Image_Glass:loadTexture(getSummonImg("Normal_Glass1"))
				Image_Claw:loadTexture(getSummonImg("Normal_Claw1"))
			end
		else
			Image_Glass:loadTexture(getSummonImg("Normal_Glass1"))
			Image_Claw:loadTexture(getSummonImg("Normal_Claw1"))
		end
		
		--不同类型的物品显示 
		
		self:setImage_SummonItemShowPNL()
		
		local ccSpriteGoldenLight = CCSprite:create(getCocoAnimationImg("Summon_CardFlashLight"))
		g_SetBlendFuncSprite(ccSpriteGoldenLight, 2)
		ccSpriteGoldenLight:setPosition(ccp(0,0))
		ccSpriteGoldenLight:setOpacity(60)
		
		g_playSoundEffect("Sound/Ani_SummonCard1.mp3")
		local arrActGoldenLight = CCArray:create()
		local actionScaleToGoldenLight = CCScaleTo:create(0.25, 1, 20)
		local actionFadeToGoldenLight = CCFadeTo:create(0.25, 0)
		arrActGoldenLight:addObject(actionScaleToGoldenLight)
		arrActGoldenLight:addObject(actionFadeToGoldenLight)
		local function cleanupGoldenLight()
			self.clippingNode = g_GlitteringWidget(Image_Glass, 1, 1, 100)
			ccSpriteGoldenLight:removeFromParentAndCleanup(true)
		end
		arrActGoldenLight:addObject(CCCallFuncN:create(cleanupGoldenLight))
		local actiontGoldenLight = CCSequence:create(arrActGoldenLight)
		
		Image_Glass:removeAllNodes()
		Image_Glass:addNode(ccSpriteGoldenLight,1)
		ccSpriteGoldenLight:runAction(actiontGoldenLight)
		self.Panel_SummonBase:setVisible(true)
		self.Image_SummonInfoPNL:setVisible(true)
		self.Image_SummonItemShowPNL:setVisible(true)
	end

	local arrActAnimationContent = CCArray:create()
	local actionOrbitCameraAnimationContent1 = CCOrbitCamera:create(0.6, 0, 1, -90,90, 0, 0)
	local actionScaleToAnimationContent1 = CCScaleTo:create(0.6, 0.7)
	local actionSpawnAnimationContent1 = CCSpawn:createWithTwoActions(actionOrbitCameraAnimationContent1, actionScaleToAnimationContent1)
	local actionScaleToAnimationContent3 = CCScaleTo:create(1 + 0.5, 1)
	arrActAnimationContent:addObject(actionSpawnAnimationContent1)
	arrActAnimationContent:addObject(CCDelayTime:create(0.6))
	arrActAnimationContent:addObject(actionScaleToAnimationContent3)
	arrActAnimationContent:addObject(CCCallFuncN:create(showSummonDetail))
	local actiontAnimationContent = CCSequence:create(arrActAnimationContent)
	
	local actionFadeToMask = CCFadeTo:create(0.4, 255)
	self.ImageView_Mask:runAction(actionFadeToMask)
	self.Image_CardLight:runAction(self.actionCardLight)
	self.Image_CrossLightHorizontal:runAction(self.actionCrossLightHorizontal)
	self.Image_CrossLightVertical:runAction(self.actionCrossLightVertical)
	self.Image_RayInSide:runAction(self.actionRayInSide)
	self.Image_RayOutSide:runAction(self.actionRayOutSide)
	self.Image_ExplodeBig:runAction(self.actionExplodeBig)
	self.Image_ExplodeSmall:runAction(self.actionExplodeSmall)
	self.Image_CircleXuanWo:runAction(self.actionCircleXuanWo)
	self.Image_CircleInSideBig:runAction(self.actionCircleInSideBig)
	self.Image_CircleInSideSmall:runAction(self.actionCircleInSideSmall)
	self.Image_CircleOutSideBig:runAction(self.actionCircleOutSideBig)
	self.Image_CircleOutSideSmall:runAction(self.actionCircleOutSideSmall)
	self.ImageView_AnimationContent:runAction(actiontAnimationContent)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "Game_SummonAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	g_playSoundEffect("Sound/Ani_ReputationLevelUp.mp3")
	
	local function showAnimationContent()
		self.bCanCloseWnd = true
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationShow", "Game_SummonAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	self.nTimerID_Game_SummonAnimation_3 = g_Timer:pushTimer(3.2, showAnimationContent)
	
	local function onTouchScreen(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			if self.bCanCloseWnd then
				bCanCardFlyRight = nil
				bCanCardFlyLeft = nil
				self.bCanCloseWnd = false
				self:showDisappearedAnimation()
			end
		end
	end 
	self.rootWidget:addTouchEventListener(onTouchScreen)
end

function g_ShowSummonCardAnimation(tbParams)
	g_WndMgr:showWnd("Game_SummonAnimation", tbParams)
end
