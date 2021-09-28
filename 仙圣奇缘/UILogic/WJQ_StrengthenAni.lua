--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_EquipStrengthenAni = class("Game_EquipStrengthenAni")
Game_EquipStrengthenAni.__index = Game_EquipStrengthenAni

local tbAnimationScaleConfig1 = {
	Image_RayInside = 5,
	Image_RayOutSide = 5,
	Image_ExplodeOutSide = 2.7,
	Image_ExplodeInSide = 2,
	Image_CircleInSideBig = 1.02,
	Image_CircleInSideSmall = 0.9,
	Image_CircleOutSideBig = 1.2,
	Image_CircleOutSideSmall = 1.1
}

function Game_EquipStrengthenAni:initWnd()
	self.rootWidget:setTouchEnabled(false)
	self.Image_RayInside = tolua.cast(self.rootWidget:getChildByName("Image_RayInside"), "ImageView")
	self.Image_RayOutSide = tolua.cast(self.rootWidget:getChildByName("Image_RayOutSide"), "ImageView")
	self.Image_ExplodeOutSide = tolua.cast(self.rootWidget:getChildByName("Image_ExplodeOutSide"), "ImageView")
	self.Image_ExplodeInSide = tolua.cast(self.rootWidget:getChildByName("Image_ExplodeInSide"), "ImageView")
	self.Image_CircleInSideBig = tolua.cast(self.rootWidget:getChildByName("Image_CircleInSideBig"), "ImageView")
	self.Image_CircleInSideSmall = tolua.cast(self.rootWidget:getChildByName("Image_CircleInSideSmall"), "ImageView")
	self.Image_CircleOutSideBig = tolua.cast(self.rootWidget:getChildByName("Image_CircleOutSideBig"), "ImageView")
	self.Image_CircleOutSideSmall = tolua.cast(self.rootWidget:getChildByName("Image_CircleOutSideSmall"), "ImageView")
	self.Image_RayTop = tolua.cast(self.rootWidget:getChildByName("Image_RayTop"), "ImageView")
	
	self.Image_RayInside:setZOrder(10)
	self.Image_RayOutSide:setZOrder(11)
	self.Image_ExplodeOutSide:setZOrder(12)
	self.Image_ExplodeInSide:setZOrder(13)
	self.Image_CircleInSideBig:setZOrder(14)
	self.Image_CircleInSideSmall:setZOrder(15)
	self.Image_CircleOutSideBig:setZOrder(16)
	self.Image_CircleOutSideSmall:setZOrder(17)
	self.Image_RayTop:setZOrder(50)
	
	self.Image_RayInside:setVisible(true)
	self.Image_RayOutSide:setVisible(true)
	self.Image_ExplodeOutSide:setVisible(true)
	self.Image_ExplodeInSide:setVisible(true)
	self.Image_CircleInSideBig:setVisible(true)
	self.Image_CircleInSideSmall:setVisible(true)
	self.Image_CircleOutSideBig:setVisible(true)
	self.Image_CircleOutSideSmall:setVisible(true)
	self.Image_RayTop:setVisible(true)
	
	g_SetBlendFuncWidget(self.Image_RayInside, 4)
	g_SetBlendFuncWidget(self.Image_RayOutSide, 4)
	g_SetBlendFuncWidget(self.Image_ExplodeOutSide, 2)
	g_SetBlendFuncWidget(self.Image_ExplodeInSide, 2)
	g_SetBlendFuncWidget(self.Image_CircleInSideBig, 4)
	g_SetBlendFuncWidget(self.Image_CircleInSideSmall, 4)
	g_SetBlendFuncWidget(self.Image_CircleOutSideBig, 4)
	g_SetBlendFuncWidget(self.Image_CircleOutSideSmall, 4)
	g_SetBlendFuncWidget(self.Image_RayTop, 3)
	
	self.Image_RayInside:setOpacity(100)
	self.Image_RayOutSide:setOpacity(100)
	self.Image_ExplodeOutSide:setOpacity(255)
	self.Image_ExplodeInSide:setOpacity(255)
	self.Image_CircleInSideBig:setOpacity(255)
	self.Image_CircleInSideSmall:setOpacity(255)
	self.Image_CircleOutSideBig:setOpacity(255)
	self.Image_CircleOutSideSmall:setOpacity(255)
	self.Image_RayTop:setOpacity(255)
	
	self.Image_RayInside:setPositionXY(640, 360)
	self.Image_RayOutSide:setPositionXY(640, 360)
	self.Image_ExplodeOutSide:setPositionXY(640, 360)
	self.Image_ExplodeInSide:setPositionXY(640, 360)
	self.Image_CircleInSideBig:setPositionXY(640, 360)
	self.Image_CircleInSideSmall:setPositionXY(640, 360)
	self.Image_CircleOutSideBig:setPositionXY(640, 360)
	self.Image_CircleOutSideSmall:setPositionXY(640, 360)
	self.Image_RayTop:setPositionXY(640, 360)
	
	self.Image_RayInside:setScale(0)
	self.Image_RayOutSide:setScale(0)
	self.Image_ExplodeOutSide:setScale(0)
	self.Image_ExplodeInSide:setScale(0)
	self.Image_CircleInSideBig:setScale(0)
	self.Image_CircleInSideSmall:setScale(0)
	self.Image_CircleOutSideBig:setScale(0)
	self.Image_CircleOutSideSmall:setScale(0)
	self.Image_RayTop:setScale(0)
	
	self.Image_RayInside:setRotation(90)
end

function Game_EquipStrengthenAni:closeWnd()
	if self.tbParams.funcEndCall then
		self.tbParams.funcEndCall()
	end
end

function Game_EquipStrengthenAni:openWnd(tbParams)
	if not tbParams then return end
	if not tbParams.widgetParent then return end
	self.tbParams = tbParams
	
	local tbWorldPos = self.tbParams.widgetParent:getWorldPosition()
	self.Image_RayInside:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_RayOutSide:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_ExplodeOutSide:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_ExplodeInSide:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_CircleInSideBig:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_CircleInSideSmall:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_CircleOutSideBig:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_CircleOutSideSmall:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	self.Image_RayTop:setPositionXY(tbWorldPos.x, tbWorldPos.y)

	local widgetClone = self.tbParams.widgetParent:clone()
	widgetClone:setPositionXY(tbWorldPos.x, tbWorldPos.y)
	g_SetBlendFuncWidget(widgetClone, 2)
	self.rootWidget:addChild(widgetClone, 30)
	
	local arrAct_RayInside = CCArray:create()
	local actionScaleTo_RayInside1 = CCScaleTo:create(0.2, tbAnimationScaleConfig1.Image_RayInside*0.7)
	local actionFadeTo_RayInside1 = CCFadeTo:create(0.4, 0)
	local actionFadeTo_RayInsideEase1 = CCEaseIn:create(actionFadeTo_RayInside1, 2)
	local actionSpawn_RayInside1 = CCSpawn:createWithTwoActions(actionScaleTo_RayInside1, actionFadeTo_RayInsideEase1)
	arrAct_RayInside:addObject(actionSpawn_RayInside1)
	local action_RayInside = CCSequence:create(arrAct_RayInside)
	
	local arrAct_RayOutSide = CCArray:create()
	local actionScaleTo_RayOutSide1 = CCScaleTo:create(0.2, tbAnimationScaleConfig1.Image_RayOutSide*0.7)
	local actionFadeTo_RayOutSide1 = CCFadeTo:create(0.4, 0)
	local actionFadeTo_RayOutSideEase1 = CCEaseIn:create(actionFadeTo_RayOutSide1, 2)
	local actionSpawn_RayOutSide1 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide1, actionFadeTo_RayOutSideEase1)
	arrAct_RayOutSide:addObject(actionSpawn_RayOutSide1)
	local action_RayOutSide = CCSequence:create(arrAct_RayOutSide)
	
	local arrAct_ExplodeOutSide = CCArray:create()
	local actionScaleTo_ExplodeOutSide1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_ExplodeOutSide*0.5)
	local actionScaleTo_ExplodeOutSideEase1 = CCEaseOut:create(actionScaleTo_ExplodeOutSide1, 2)
	local actionFadeTo_ExplodeOutSide2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_ExplodeOutSide2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_ExplodeOutSide*0.6)
	local actionSpawn_ExplodeOutSide2 = CCSpawn:createWithTwoActions(actionFadeTo_ExplodeOutSide2, actionScaleTo_ExplodeOutSide2)
	arrAct_ExplodeOutSide:addObject(actionScaleTo_ExplodeOutSideEase1)
	arrAct_ExplodeOutSide:addObject(actionSpawn_ExplodeOutSide2)
	local action_ExplodeOutSide = CCSequence:create(arrAct_ExplodeOutSide)
	
	local arrAct_ExplodeInSide = CCArray:create()
	local actionScaleTo_ExplodeInSide1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_ExplodeInSide*0.5)
	local actionScaleTo_ExplodeInSideEase1 = CCEaseOut:create(actionScaleTo_ExplodeInSide1, 2)
	local actionFadeTo_ExplodeInSide2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_ExplodeInSide2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_ExplodeInSide*0.6)
	local actionSpawn_ExplodeInSide2 = CCSpawn:createWithTwoActions(actionFadeTo_ExplodeInSide2, actionScaleTo_ExplodeInSide2)
	arrAct_ExplodeInSide:addObject(actionScaleTo_ExplodeInSideEase1)
	arrAct_ExplodeInSide:addObject(actionSpawn_ExplodeInSide2)
	local action_ExplodeInSide = CCSequence:create(arrAct_ExplodeInSide)
	
	local arrAct_CircleInSideBig = CCArray:create()
	local actionScaleTo_CircleInSideBig1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_CircleInSideBig*0.5)
	local actionScaleTo_CircleInSideBigEase1 = CCEaseOut:create(actionScaleTo_CircleInSideBig1, 2)
	local actionFadeTo_CircleInSideBig2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_CircleInSideBig2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_CircleInSideBig*0.6)
	local actionSpawn_CircleInSideBig2 = CCSpawn:createWithTwoActions(actionFadeTo_CircleInSideBig2, actionScaleTo_CircleInSideBig2)
	arrAct_CircleInSideBig:addObject(actionScaleTo_CircleInSideBigEase1)
	arrAct_CircleInSideBig:addObject(actionSpawn_CircleInSideBig2)
	local action_CircleInSideBig = CCSequence:create(arrAct_CircleInSideBig)
	
	local arrAct_CircleInSideSmall = CCArray:create()
	local actionScaleTo_CircleInSideSmall1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_CircleInSideSmall*0.5)
	local actionScaleTo_CircleInSideSmallEase1 = CCEaseOut:create(actionScaleTo_CircleInSideSmall1, 2)
	local actionFadeTo_CircleInSideSmall2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_CircleInSideSmall2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_CircleInSideSmall*0.6)
	local actionSpawn_CircleInSideSmall2 = CCSpawn:createWithTwoActions(actionFadeTo_CircleInSideSmall2, actionScaleTo_CircleInSideSmall2)
	arrAct_CircleInSideSmall:addObject(actionScaleTo_CircleInSideSmallEase1)
	arrAct_CircleInSideSmall:addObject(actionSpawn_CircleInSideSmall2)
	local action_CircleInSideSmall = CCSequence:create(arrAct_CircleInSideSmall)
	
	local arrAct_CircleOutSideBig = CCArray:create()
	local actionScaleTo_CircleOutSideBig1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_CircleOutSideBig*0.5)
	local actionScaleTo_CircleOutSideBigEase1 = CCEaseOut:create(actionScaleTo_CircleOutSideBig1, 2)
	local actionFadeTo_CircleOutSideBig2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_CircleOutSideBig2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_CircleOutSideBig*0.6)
	local actionSpawn_CircleOutSideBig2 = CCSpawn:createWithTwoActions(actionFadeTo_CircleOutSideBig2, actionScaleTo_CircleOutSideBig2)
	arrAct_CircleOutSideBig:addObject(actionScaleTo_CircleOutSideBigEase1)
	arrAct_CircleOutSideBig:addObject(actionSpawn_CircleOutSideBig2)
	local action_CircleOutSideBig = CCSequence:create(arrAct_CircleOutSideBig)
	
	local arrAct_CircleOutSideSmall = CCArray:create()
	local actionScaleTo_CircleOutSideSmall1 = CCScaleTo:create(0.3, tbAnimationScaleConfig1.Image_CircleOutSideSmall*0.5)
	local actionScaleTo_CircleOutSideSmallEase1 = CCEaseOut:create(actionScaleTo_CircleOutSideSmall1, 2)
	local actionFadeTo_CircleOutSideSmall2 = CCFadeTo:create(0.4, 0)
	local actionScaleTo_CircleOutSideSmall2 = CCScaleTo:create(0.4, tbAnimationScaleConfig1.Image_CircleOutSideSmall*0.6)
	local actionSpawn_CircleOutSideSmall2 = CCSpawn:createWithTwoActions(actionFadeTo_CircleOutSideSmall2, actionScaleTo_CircleOutSideSmall2)
	arrAct_CircleOutSideSmall:addObject(actionScaleTo_CircleOutSideSmallEase1)
	arrAct_CircleOutSideSmall:addObject(actionSpawn_CircleOutSideSmall2)
	local action_CircleOutSideSmall = CCSequence:create(arrAct_CircleOutSideSmall)
	
	local arrAct_RayTop = CCArray:create()
	local actionScaleTo_RayTop1 = CCScaleTo:create(0.01, 5) 
	local actionFadeTo_RayTop2 = CCFadeOut:create(0.4) 
	arrAct_RayTop:addObject(actionScaleTo_RayTop1)
	arrAct_RayTop:addObject(actionFadeTo_RayTop2)
	arrAct_RayTop:addObject(CCDelayTime:create(0.4))
	local function executeCleanupEvent()	
		g_WndMgr:closeWnd("Game_EquipStrengthenAni")
	end
	arrAct_RayTop:addObject(CCCallFuncN:create(executeCleanupEvent))
	local action_RayTop = CCSequence:create(arrAct_RayTop)
	
	self.Image_RayInside:runAction(action_RayInside)
	self.Image_RayOutSide:runAction(action_RayOutSide)
	self.Image_ExplodeOutSide:runAction(action_ExplodeOutSide)
	self.Image_ExplodeInSide:runAction(action_ExplodeInSide)
	self.Image_CircleInSideBig:runAction(action_CircleInSideBig)
	self.Image_CircleInSideSmall:runAction(action_CircleInSideSmall)
	self.Image_CircleOutSideBig:runAction(action_CircleOutSideBig)
	self.Image_CircleOutSideSmall:runAction(action_CircleOutSideSmall)
	self.Image_RayTop:runAction(action_RayTop)
	
	local actionFadeTo_widgetClone = CCFadeOut:create(0.8) 
	widgetClone:runAction(actionFadeTo_widgetClone)
	
	g_playSoundEffect("Sound/Ani_RewardStart.mp3")
end

function g_ShowEquipDaZaoAnimation(widgetParent, funcEndCall)
	if not widgetParent then return end
	local tbParams = {}
	tbParams.widgetParent = widgetParent
	tbParams.funcEndCall = funcEndCall
	g_WndMgr:showWnd("Game_EquipStrengthenAni", tbParams)
end
