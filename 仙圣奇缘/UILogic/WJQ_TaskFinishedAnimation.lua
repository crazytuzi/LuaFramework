--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_TaskFinishedAnimation = class("Game_TaskFinishedAnimation")
Game_TaskFinishedAnimation.__index = Game_TaskFinishedAnimation

function Game_TaskFinishedAnimation:showDisappearedAnimation()
	self.Image_Light1:stopAllActions()
	self.Image_Light2:stopAllActions()
	self.Image_Flag:stopAllActions()
	self.Image_FlagDragon:stopAllActions()
	self.Image_FlagMaskBottom:stopAllActions()
	self.Image_BladeLeft:stopAllActions()
	self.Image_BladeRight:stopAllActions()
	self.Image_FlagMask:stopAllActions()
	
	local arryActFlagMask = CCArray:create()
	local actionFadeToFlagMask1 = CCFadeTo:create(0.5, 255)
	local actionFadeToFlagMask2 = CCFadeTo:create(0.4, 0)
	arryActFlagMask:addObject(actionFadeToFlagMask1)
	arryActFlagMask:addObject(CCDelayTime:create(0.4))
	local function hideAnimationContent()
		g_SetBlendFuncWidget(self.Image_FlagMask, 3)
		self.Image_BladeLightLeft:setVisible(false)
		self.Image_BladeLightRight:setVisible(false)
		self.Image_Char:setVisible(false)
		self.Button_Return:setVisible(false)
		self.ImageView_MsgContentPNL:setVisible(false)
		if self.funcDisappearedCallBack then
			self.funcDisappearedCallBack()
		end
	end
	--爆炸达到最大幅度，回调隐藏动画内容
	arryActFlagMask:addObject(CCCallFuncN:create(hideAnimationContent))
	arryActFlagMask:addObject(CCDelayTime:create(0.4))
	arryActFlagMask:addObject(actionFadeToFlagMask2)
	local actionFlagMask = CCSequence:create(arryActFlagMask)
	
	local actionFadeToFlag = CCFadeTo:create(0.5, 0)
	local actionFadeToFlagMaskBottom = CCFadeTo:create(0.5, 0)
	local actionFadeToBladeLeft = CCFadeTo:create(0.5, 0)
	local actionFadeToBladeRight = CCFadeTo:create(0.5, 0)
	
	local arryActFlagDragon = CCArray:create()
	local actionFadeToFlagDragon1 = CCFadeTo:create(0.4, 255)
	local actionFadeToFlagDragon2 = CCFadeTo:create(0.4, 0)
	arryActFlagDragon:addObject(actionFadeToFlagDragon1)
	arryActFlagDragon:addObject(CCDelayTime:create(0.8))
	arryActFlagDragon:addObject(actionFadeToFlagDragon2)
	local actionFlagDragon = CCSequence:create(arryActFlagDragon)
	
	local arryActLight1 = CCArray:create()
	local actionFadeToLight1_1 = CCFadeTo:create(0.5, 0)
	local actionScaleToLight1_1 = CCScaleTo:create(0.5, 0)
	local actionSpwanLight1_1 = CCSpawn:createWithTwoActions(actionFadeToLight1_1,actionScaleToLight1_1)
	local actionScaleToLight1_2 = CCScaleTo:create(0.4, 14)
	local actionFadeToLight1_2 = CCFadeTo:create(0.4, 255)
	local actionSpwanLight1_2 = CCSpawn:createWithTwoActions(actionScaleToLight1_2,actionFadeToLight1_2)
	local actionScaleToLight1_3 = CCScaleTo:create(0.4,2)
	local actionFadeToLight1_3 = CCFadeTo:create(0.4, 0)
	arryActLight1:addObject(actionSpwanLight1_1)
	local function setZOrderLight1()
		g_playSoundEffect("Sound/Ani_EventEnd.mp3")
		self.Image_Light1:setZOrder(11)
	end
	arryActLight1:addObject(CCCallFuncN:create(setZOrderLight1))
	arryActLight1:addObject(actionSpwanLight1_2)
	arryActLight1:addObject(actionScaleToLight1_3)
	arryActLight1:addObject(actionFadeToLight1_3)
	local actionLight1 = CCSequence:create(arryActLight1)
	
	local arryActLight2 = CCArray:create()
	local actionFadeToLight2_1 = CCFadeTo:create(0.5, 0)
	local actionScaleToLight2_1 = CCScaleTo:create(0.5, 0)
	local actionSpwanLight2_1 = CCSpawn:createWithTwoActions(actionFadeToLight2_1,actionScaleToLight2_1)
	local actionScaleToLight2_2 = CCScaleTo:create(0.4, 14)
	local actionFadeToLight2_2 = CCFadeTo:create(0.4, 255)
	local actionSpwanLight2_2 = CCSpawn:createWithTwoActions(actionScaleToLight2_2,actionFadeToLight2_2)
	local actionScaleToLight2_3 = CCScaleTo:create(0.4, 2)
	local actionFadeToLight2_3 = CCFadeTo:create(0.4, 0)
	arryActLight2:addObject(actionSpwanLight2_1)
	local function setZOrderLight2()
		self.Image_Light2:setZOrder(12)
	end
	arryActLight2:addObject(CCCallFuncN:create(setZOrderLight2))
	arryActLight2:addObject(actionSpwanLight2_2)
	arryActLight2:addObject(actionScaleToLight2_3)
	arryActLight2:addObject(actionFadeToLight2_3)
	local actionLight2 = CCSequence:create(arryActLight2)
	
	local arryActMask = CCArray:create()
	local actionFadeToMask = CCFadeTo:create(0.4, 0)
	arryActMask:addObject(CCDelayTime:create(1.2))
	arryActMask:addObject(actionFadeToMask)
	local function executeCloseAction()
		g_WndMgr:closeWnd("Game_TaskFinishedAnimation")
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "Game_TaskFinishedAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	arryActMask:addObject(CCCallFuncN:create(executeCloseAction))
	local actionMask = CCSequence:create(arryActMask)
	
	self.Image_FlagMaskBottom:runAction(actionFadeToFlagMaskBottom)
	self.Image_Flag:runAction(actionFadeToFlag)
	self.Image_FlagDragon:runAction(actionFlagDragon)
	self.Image_BladeLeft:runAction(actionFadeToBladeLeft)
	self.Image_BladeRight:runAction(actionFadeToBladeRight)
	self.Image_FlagMask:runAction(actionFlagMask)
	self.Image_Light1:runAction(actionLight1)
	self.Image_Light2:runAction(actionLight2)
	self.ImageView_Mask:runAction(actionMask)
end

function Game_TaskFinishedAnimation:initWnd()
	
end

function Game_TaskFinishedAnimation:closeWnd()
	self.rootWidget:removeAllNodes()
	g_Timer:destroyTimerByID(self.nTimerID_Game_TaskFinishedAnimation_1)
	if self.funcEndCallBack then
		cclog("==================Game_TaskFinishedAnimation====================funcEndCallBack")
		self.funcEndCallBack()
	end
end

function Game_TaskFinishedAnimation:openWnd(tbAniParams)
	if g_bReturn then return end
	
	self.rootWidget:removeAllNodes()
	self.bCanCloseWnd = false
	self.tbUIInfo = tbAniParams.tbUIInfo
	self.funcDisappearedCallBack = tbAniParams.funcDisappearedCallBack
	self.funcEndCallBack = tbAniParams.funcEndCallBack
	
	self.ImageView_Mask = tolua.cast(self.rootWidget:getChildByName("ImageView_Mask"), "ImageView")
	self.Button_Return = tolua.cast(self.rootWidget:getChildByName("Button_Return"), "Button")
	
	self.ImageView_MsgContentPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_MsgContentPNL"), "ImageView")
	self.ImageView_MsgContentPNL:setCascadeOpacityEnabled(true)
	self.ImageView_TaskFinishedPNL = tolua.cast(self.ImageView_MsgContentPNL:getChildByName("ImageView_TaskFinishedPNL"), "ImageView")
	
	self.Image_Light1 = tolua.cast(self.rootWidget:getChildByName("Image_Light1"), "ImageView")
	self.Image_Light2 = tolua.cast(self.rootWidget:getChildByName("Image_Light2"), "ImageView")
	self.Image_Flag = tolua.cast(self.rootWidget:getChildByName("Image_Flag"), "ImageView")
	self.Image_FlagMaskBottom = tolua.cast(self.rootWidget:getChildByName("Image_FlagMaskBottom"), "ImageView")
	self.Image_FlagDragon = tolua.cast(self.rootWidget:getChildByName("Image_FlagDragon"), "ImageView")
	self.Image_FlagMask = tolua.cast(self.rootWidget:getChildByName("Image_FlagMask"), "ImageView")
	self.Image_BladeLeft = tolua.cast(self.rootWidget:getChildByName("Image_BladeLeft"), "ImageView")
	self.Image_BladeLightLeft = tolua.cast(self.Image_BladeLeft:getChildByName("Image_BladeLightLeft"), "ImageView")
	self.Image_BladeRight = tolua.cast(self.rootWidget:getChildByName("Image_BladeRight"), "ImageView")
	self.Image_BladeLightRight = tolua.cast(self.Image_BladeRight:getChildByName("Image_BladeLightRight"), "ImageView")
	self.Image_Char = tolua.cast(self.rootWidget:getChildByName("Image_Char"), "ImageView")
	
	self.Image_Light1:setVisible(true)
	self.Image_Light2:setVisible(true)
	self.Image_Flag:setVisible(true)
	self.Image_FlagMaskBottom:setVisible(true)
	self.Image_FlagDragon:setVisible(true)
	self.Image_FlagMask:setVisible(true)
	self.Image_BladeLeft:setVisible(true)
	self.Image_BladeRight:setVisible(true)
	self.Image_Char:setVisible(true)
	
	self.Image_Light1:setZOrder(12)
	self.Image_Light2:setZOrder(13)
	self.Image_Flag:setZOrder(3)
	self.Image_FlagMaskBottom:setZOrder(4)
	self.Image_FlagDragon:setZOrder(5)
	self.Image_FlagMask:setZOrder(11)
	self.Image_BladeLeft:setZOrder(6)
	self.Image_BladeRight:setZOrder(8)
	self.Image_Char:setZOrder(10)
	
	g_SetBlendFuncWidget(self.Image_Light1, 3)
	g_SetBlendFuncWidget(self.Image_Light2, 3)
	g_SetBlendFuncWidget(self.Image_FlagMaskBottom, 3)
	g_SetBlendFuncWidget(self.Image_FlagDragon, 3)
	g_SetBlendFuncWidget(self.Image_FlagMask, 3)
		
	self.Image_Light1:setPosition(ccp(640,380))
	self.Image_Light2:setPosition(ccp(640,380))
	self.Image_Flag:setPosition(ccp(640,380))
	self.Image_FlagMaskBottom:setPosition(ccp(640,380))
	self.Image_FlagDragon:setPosition(ccp(641,465))
	self.Image_FlagMask:setPosition(ccp(640,380))
	self.Image_Char:setPosition(ccp(640,380))
	self.Image_BladeLeft:setPosition(ccp(40,960))
	self.Image_BladeLightLeft:setPosition(ccp(13,12))
	self.Image_BladeRight:setPosition(ccp(1240,960))
	self.Image_BladeLightRight:setPosition(ccp(13,12))
	
	self.Image_Light1:setScale(0)
	self.Image_Light2:setScale(0)
	self.Image_Flag:setScale(2)
	self.Image_FlagMaskBottom:setScale(2)
	self.Image_FlagDragon:setScale(2)
	self.Image_FlagMask:setScale(2)
	self.Image_BladeRight:setScaleX(-1)
	
	self.Image_Light1:setZOrder(12)
	self.Image_Light2:setZOrder(13)
	self.Image_Flag:setZOrder(3)
	self.Image_FlagMaskBottom:setZOrder(4)
	self.Image_FlagDragon:setZOrder(5)
	self.Image_FlagMask:setZOrder(11)
	self.Image_BladeLeft:setZOrder(6)
	self.Image_BladeRight:setZOrder(8)
	self.Image_Char:setZOrder(10)
	
	self.Image_Light1:setOpacity(255)
	self.Image_Light2:setOpacity(255)
	self.Image_Flag:setOpacity(255)
	self.Image_FlagMaskBottom:setOpacity(0)
	self.Image_FlagDragon:setOpacity(255)
	self.Image_FlagMask:setOpacity(0)
	self.Image_BladeLeft:setOpacity(255)
	self.Image_BladeRight:setOpacity(255)
	self.Image_Char:setOpacity(255)
	
	self.Image_BladeLeft:setRotation(-45)
	self.Image_BladeRight:setRotation(45)

	self.ImageView_Mask:setOpacity(0)
	self.ImageView_Mask:setVisible(true)
	self.Button_Return:setVisible(false)
	self.Button_Return:setTouchEnabled(false)
	self.ImageView_MsgContentPNL:setVisible(false)
	self.ImageView_TaskFinishedPNL:setVisible(false)
	

	self.ImageView_TaskFinishedPNL:setVisible(true)
	self.Image_Char:loadTexture(getCocoAnimationImg("UpgradeEvent_Char31"))

	self.Image_Flag:setVisible(false)
	self.Image_Char:setVisible(false)
	
	local arryActLight1 = CCArray:create()
	local actionScaleToLight1_1 = CCScaleTo:create(0.4, 18)
	local actionScaleToLight1_2 = CCScaleTo:create(0.4, 5.6)
	local actionFadeToLight1_2 = CCFadeTo:create(0.4, 0)
	local actionSpwanLight1_2 = CCSpawn:createWithTwoActions(actionScaleToLight1_2,actionFadeToLight1_2)
	local actionFadeToLight1_3 = CCFadeTo:create(0.5, 255)
	arryActLight1:addObject(actionScaleToLight1_1)
	arryActLight1:addObject(actionSpwanLight1_2)
	local function setZOrderLight1()
		self.Image_Light1:setZOrder(1)
	end
	arryActLight1:addObject(CCCallFuncN:create(setZOrderLight1))
	arryActLight1:addObject(actionFadeToLight1_3)
	local function repeatRotateLight1()
		local actionRotateLight1 = CCRotateBy:create(15, 360) 
		local actionForeverLight1 = CCRepeatForever:create(actionRotateLight1)
		self.Image_Light1:runAction(actionForeverLight1)
	end
	arryActLight1:addObject(CCCallFuncN:create(repeatRotateLight1))
	local actionLight1 = CCSequence:create(arryActLight1)
	
	local arryActLight2 = CCArray:create()
	local actionScaleToLight2_1 = CCScaleTo:create(0.4, 18)
	local actionScaleToLight2_2 = CCScaleTo:create(0.4,4.8)
	local actionFadeToLight2_2 = CCFadeTo:create(0.4, 0)
	local actionSpwanLight2_2 = CCSpawn:createWithTwoActions(actionScaleToLight2_2,actionFadeToLight2_2)
	local actionFadeToLight2_3 = CCFadeTo:create(0.5, 255)
	arryActLight2:addObject(actionScaleToLight2_1)
	arryActLight2:addObject(actionSpwanLight2_2)
	local function setZOrderLight2()
		self.Image_Light2:setZOrder(2)
	end
	arryActLight2:addObject(CCCallFuncN:create(setZOrderLight2))
	arryActLight2:addObject(actionFadeToLight2_3)
	local function repeatRotateLight2()
		local actionRotateLight2 = CCRotateBy:create(15, -360) 
		local actionForeverLight2 = CCRepeatForever:create(actionRotateLight2)
		self.Image_Light2:runAction(actionForeverLight2)
	end
	arryActLight2:addObject(CCCallFuncN:create(repeatRotateLight2))
	local actionLight2 = CCSequence:create(arryActLight2)
	
	local arryActFlagMaskBottom = CCArray:create()
	local actionFadeToFlagMaskBottom = CCFadeTo:create(0.4, 255)
	arryActFlagMaskBottom:addObject(actionFadeToFlagMaskBottom)
	arryActFlagMaskBottom:addObject(CCDelayTime:create(0.4))
	local function repeatFlagMaskBottomLight()
		local arryActFlagMaskBottomLight = CCArray:create()
		local actionFadeToFlagMaskBottom1 = CCFadeTo:create(1.5, 100)
		local actionFadeToFlagMaskBottom2 = CCFadeTo:create(1.5, 255)
		arryActFlagMaskBottomLight:addObject(actionFadeToFlagMaskBottom1)
		arryActFlagMaskBottomLight:addObject(actionFadeToFlagMaskBottom2)
		local actionFlagMaskBottomLight = CCSequence:create(arryActFlagMaskBottomLight)
		local actionForeverFlagMaskBottomLight = CCRepeatForever:create(actionFlagMaskBottomLight)
		self.Image_FlagMaskBottom:runAction(actionForeverFlagMaskBottomLight)
	end
	arryActFlagMaskBottom:addObject(CCCallFuncN:create(repeatFlagMaskBottomLight))
	local actionFlagMaskBottom = CCSequence:create(arryActFlagMaskBottom)
	
	local arryActFlagDragon = CCArray:create()
	arryActFlagDragon:addObject(CCDelayTime:create(0.4))
	arryActFlagDragon:addObject(CCDelayTime:create(0.4))
	local function repeatFlagDragonLight()
		self.bCanCloseWnd = true
		local arryActFlagDragonLight = CCArray:create()
		local actionFadeToFlagDragon1 = CCFadeTo:create(1.5, 100)
		local actionFadeToFlagDragon2 = CCFadeTo:create(1.5, 255)
		arryActFlagDragonLight:addObject(actionFadeToFlagDragon1)
		arryActFlagDragonLight:addObject(actionFadeToFlagDragon2)
		local actionFlagDragonLight = CCSequence:create(arryActFlagDragonLight)
		local actionForeverFlagDragonLight = CCRepeatForever:create(actionFlagDragonLight)
		self.Image_FlagDragon:runAction(actionForeverFlagDragonLight)
	end
	arryActFlagDragon:addObject(CCCallFuncN:create(repeatFlagDragonLight))
	local actionFlagDragon = CCSequence:create(arryActFlagDragon)
	
	local arryActFlagMask = CCArray:create()
	local actionFadeToFlagMask = CCFadeTo:create(0.4, 255)
	arryActFlagMask:addObject(actionFadeToFlagMask)
	arryActFlagMask:addObject(CCDelayTime:create(0.4))
	local function repeatFlagMaskLight()
		local arryActFlagMaskLight = CCArray:create()
		local actionFadeToFlagMask1 = CCFadeTo:create(1.5, 100)
		local actionFadeToFlagMask2 = CCFadeTo:create(1.5, 255)
		arryActFlagMaskLight:addObject(actionFadeToFlagMask1)
		arryActFlagMaskLight:addObject(actionFadeToFlagMask2)
		local actionFlagMaskLight = CCSequence:create(arryActFlagMaskLight)
		local actionForeverFlagMaskLight = CCRepeatForever:create(actionFlagMaskLight)
		self.Image_FlagMask:runAction(actionForeverFlagMaskLight)
	end
	arryActFlagMask:addObject(CCCallFuncN:create(repeatFlagMaskLight))
	local actionFlagMask = CCSequence:create(arryActFlagMask)
	
	local arryActBladeLeft = CCArray:create()
	local actionFadeToBladeLeft = CCFadeTo:create(0.4, 255)
	local actionMoveToBladeLeft = CCMoveTo:create(0.1, ccp(640,380))
	arryActBladeLeft:addObject(actionFadeToBladeLeft)
	arryActBladeLeft:addObject(CCDelayTime:create(0.3))
	local function playBladeSound()
		g_playSoundEffect("Sound/Battle_Start_Blade.mp3")
	end
	arryActBladeLeft:addObject(CCCallFuncN:create(playBladeSound))
	arryActBladeLeft:addObject(actionMoveToBladeLeft)
	local function repeatBladeLightLeft()
		local arryActBladeLightLeft = CCArray:create()
		local actionFadeToBladeLeft1 = CCFadeTo:create(1.5, 100)
		local actionFadeToBladeLeft2 = CCFadeTo:create(1.5, 255)
		arryActBladeLightLeft:addObject(actionFadeToBladeLeft1)
		arryActBladeLightLeft:addObject(actionFadeToBladeLeft2)
		local actionBladeLightLeft = CCSequence:create(arryActBladeLightLeft)
		local actionForeverBladeLightLeft = CCRepeatForever:create(actionBladeLightLeft)
		self.Image_BladeLightLeft:runAction(actionForeverBladeLightLeft)
	end
	arryActBladeLeft:addObject(CCCallFuncN:create(repeatBladeLightLeft))
	local actionBladeLeft = CCSequence:create(arryActBladeLeft)
	
	local arryActBladeRight = CCArray:create()
	local actionFadeToBladeRight = CCFadeTo:create(0.4, 255)
	local actionMoveToBladeRight = CCMoveTo:create(0.1, ccp(640,380))
	arryActBladeRight:addObject(actionFadeToBladeRight)
	arryActBladeRight:addObject(CCDelayTime:create(0.3))
	arryActBladeRight:addObject(actionMoveToBladeRight)
	local function repeatBladeLightRight()
		local arryActBladeLightRight = CCArray:create()
		local actionFadeToBladeRight1 = CCFadeTo:create(1.5, 100)
		local actionFadeToBladeRight2 = CCFadeTo:create(1.5, 255)
		arryActBladeLightRight:addObject(actionFadeToBladeRight1)
		arryActBladeLightRight:addObject(actionFadeToBladeRight2)
		local actionBladeLightRight = CCSequence:create(arryActBladeLightRight)
		local actionForeverBladeLightRight = CCRepeatForever:create(actionBladeLightRight)
		self.Image_BladeLightRight:runAction(actionForeverBladeLightRight)
	end
	arryActBladeRight:addObject(CCCallFuncN:create(repeatBladeLightRight))
	local actionBladeRight = CCSequence:create(arryActBladeRight)
	
	

	local actionFadeToMask = CCFadeTo:create(0.4, 255)
	self.ImageView_Mask:runAction(actionFadeToMask)
	self.Image_Light1:runAction(actionLight1)
	self.Image_Light2:runAction(actionLight2)
	self.Image_FlagMaskBottom:runAction(actionFlagMaskBottom)
	self.Image_FlagDragon:runAction(actionFlagDragon)
	self.Image_FlagMask:runAction(actionFlagMask)
	self.Image_BladeLeft:runAction(actionBladeLeft)
	self.Image_BladeRight:runAction(actionBladeRight)
	
	g_playSoundEffect("Sound/Ani_RewardEnd.mp3")
	if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "Game_TaskFinishedAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	--爆炸达到最大幅度，回调显示动画内容
	local function showAnimationContent()
		if not g_WndMgr:getWnd("Game_TaskFinishedAnimation") then return end
		
		self.Image_Flag:setVisible(true)
		self.Image_Char:setVisible(true)
		self.Button_Return:setVisible(true)
		self.bCanCloseWnd = true
		if self.tbUIInfo then
			self.ImageView_MsgContentPNL:setVisible(true)
		end
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationShow", "Game_TaskFinishedAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	self.nTimerID_Game_TaskFinishedAnimation_1 = g_Timer:pushTimer(0.4, showAnimationContent)

	local function onTouchScreen(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			if self.bCanCloseWnd then
				self.bCanCloseWnd = false
				self:showDisappearedAnimation()
			end
		end
	end 
	self.rootWidget:addTouchEventListener(onTouchScreen)

end

g_AniParamsTaskFinished = {}
function g_ShowTaskFinishedEventAnimation(tbParams, funcEndCallBack, funcDisappearedCallBack)
	g_AniParamsTaskFinished = {}
	g_AniParamsTaskFinished.funcEndCallBack = funcEndCallBack
	g_AniParamsTaskFinished.funcDisappearedCallBack = funcDisappearedCallBack
	g_AniParamsTaskFinished.tbUIInfo = tbParams
	g_WndMgr:showWnd("Game_TaskFinishedAnimation", g_AniParamsTaskFinished)
end
