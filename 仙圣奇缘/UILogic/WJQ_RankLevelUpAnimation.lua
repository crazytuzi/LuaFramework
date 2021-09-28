--------------------------------------------------------------------------------------
-- 文件名:	WJQ_UpgradeAnimation.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_RankLevelUpAnimation = class("Game_RankLevelUpAnimation")
Game_RankLevelUpAnimation.__index = Game_RankLevelUpAnimation

local function setCardIcon(widget,tbCardTarget)
	if not tbCardTarget then return end
	
	local Image_Head = tolua.cast(widget:getChildByName("Image_Head"), "ImageView")
	Image_Head:loadTexture(getCardBackByEvoluteLev(tbCardTarget:getEvoluteLevel()))
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCardTarget:getEvoluteLevel()))
	
	local Image_StarLevel = tolua.cast(Image_Head:getChildByName("Image_StarLevel"), "ImageView")
	if Image_StarLevel then
		Image_StarLevel:loadTexture(getIconStarLev(tbCardTarget:getStarLevel()))
	end
	
	local LabelBMFont_Level = tolua.cast(Image_Head:getChildByName("LabelBMFont_Level"), "LabelBMFont")
	if LabelBMFont_Level then
		LabelBMFont_Level:setText(string.format(_T("Lv.%d"),tbCardTarget:getLevel()))
	end
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(tbCardTarget:getCsvBase().SpineAnimation))
end

--竞技场名次提高 ImageView_RankUpgradePNL
function Game_RankLevelUpAnimation:setImageView_RankUpgradePNL()
	--胜利方
	local Image_PlayerLeftPNL = tolua.cast(self.ImageView_RankUpgradePNL:getChildByName("Image_PlayerLeftPNL"), "ImageView")
	--玩家名称
	local Label_Name = tolua.cast(Image_PlayerLeftPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tostring(self.tbAniParams.name))
	--排名
	local Label_Rank = tolua.cast(Image_PlayerLeftPNL:getChildByName("Label_Rank"), "Label")
	Label_Rank:setText(tonumber(self.tbAniParams.rank))
	--战力
	local BitmapLabel_TeamStrength = tolua.cast(Image_PlayerLeftPNL:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(tonumber(self.tbAniParams.reamStrength))
	--上升名次
	local Label_RankChange = tolua.cast(Image_PlayerLeftPNL:getChildByName("Label_RankChange"), "Label")
	Label_RankChange:setText(_T("排名上升至")..tonumber(self.tbAniParams.rankChange))
	--文字对齐方向 右边为点 向左推进
	g_adjustWidgetsRightPosition({Label_Rank, Image_PlayerLeftPNL:getChildByName("Label_RankLB")})
	g_adjustWidgetsRightPosition({BitmapLabel_TeamStrength, Image_PlayerLeftPNL:getChildByName("Label_TeamStrengthLB")})
	
	local Image_RankChangeStatus = tolua.cast(Image_PlayerLeftPNL:getChildByName("Image_RankChangeStatus"), "ImageView")
	g_adjustWidgetsRightPosition({Label_RankChange, Image_RankChangeStatus})
	
	--失败方
	local Image_PlayerRightPNL = tolua.cast(self.ImageView_RankUpgradePNL:getChildByName("Image_PlayerRightPNL"), "ImageView")
	--玩家名称 
	local Label_Name = tolua.cast(Image_PlayerRightPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tostring(self.tbAniParams.back_Name))
	--排名 
	local Label_Rank = tolua.cast(Image_PlayerRightPNL:getChildByName("Label_Rank"), "Label")
	Label_Rank:setText(tonumber(self.tbAniParams.back_Rank))
	--战力 
	local BitmapLabel_TeamStrength = tolua.cast(Image_PlayerRightPNL:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(tonumber(self.tbAniParams.back_ReamStrength))
	--下升名次 
	local Label_RankChange = tolua.cast(Image_PlayerRightPNL:getChildByName("Label_RankChange"), "Label")
	Label_RankChange:setText(_T("排名下降至")..tonumber(self.tbAniParams.back_RankChange))
	
	--	--文字对齐方向 左边为点 向右推进
	g_AdjustWidgetsPosition({Label_Rank,Image_PlayerRightPNL:getChildByName("Label_RankLB") })
	g_AdjustWidgetsPosition({BitmapLabel_TeamStrength,Image_PlayerRightPNL:getChildByName("Label_TeamStrengthLB")})
	
	local Image_RankChangeStatus = tolua.cast(Image_PlayerRightPNL:getChildByName("Image_RankChangeStatus"), "ImageView")
	g_AdjustWidgetsPosition({Label_RankChange, Image_RankChangeStatus})
	
	self.ImageView_RankUpgradePNL:setVisible(true)
end 

function Game_RankLevelUpAnimation:showDisappearedAnimation()
	if self.Image_Light1 then 
		self.Image_Light1:stopAllActions()
	end
	if self.Image_Light2 then 
		self.Image_Light2:stopAllActions()
	end
	if self.Image_ShieldMaskBottom then
		self.Image_ShieldMaskBottom:stopAllActions()
	end 
	if self.Image_ShieldDragon then
		self.Image_ShieldDragon:stopAllActions()
	end
	if self.Image_ShieldMask then 
		self.Image_ShieldMask:stopAllActions()
	end
	local arryActShieldMaskBottom = CCArray:create()
	local actionFadeToShieldMaskBottom1 = CCFadeTo:create(0.5, 255)
	local actionFadeToShieldMaskBottom2 = CCFadeTo:create(0.4, 0)
	arryActShieldMaskBottom:addObject(actionFadeToShieldMaskBottom1)
	arryActShieldMaskBottom:addObject(CCDelayTime:create(0.4))
	local function hideAnimationContent()
		g_SetBlendFuncWidget(self.Image_ShieldMaskBottom, 3)
		self.Image_Flower1:setVisible(false)
		self.Image_Flower2:setVisible(false)
		self.Image_Char1:setVisible(false)
		self.Button_Return:setVisible(false)
		self.ImageView_MsgContentPNL:setVisible(false)
		if self.funcDisappearedCallBack then
			self.funcDisappearedCallBack()
		end
	end
	--爆炸达到最大幅度，回调隐藏动画内容
	arryActShieldMaskBottom:addObject(CCCallFuncN:create(hideAnimationContent))
	arryActShieldMaskBottom:addObject(CCDelayTime:create(0.4))
	arryActShieldMaskBottom:addObject(actionFadeToShieldMaskBottom2)
	local actionShieldMaskBottom = CCSequence:create(arryActShieldMaskBottom)
	
	local actionFadeToShield = CCFadeTo:create(0.5, 0)
	local actionFadeToShieldMask = CCFadeTo:create(0.5, 0)
	
	local arryActShieldDragon = CCArray:create()
	local actionFadeToShieldDragon1 = CCFadeTo:create(0.4, 255)
	local actionFadeToShieldDragon2 = CCFadeTo:create(0.4, 0)
	arryActShieldDragon:addObject(actionFadeToShieldDragon1)
	arryActShieldDragon:addObject(CCDelayTime:create(0.8))
	arryActShieldDragon:addObject(actionFadeToShieldDragon2)
	local actionShieldDragon = CCSequence:create(arryActShieldDragon)
	
	local arryActLight1 = CCArray:create()
	local actionFadeToLight1_1 = CCFadeTo:create(0.5, 0)
	local actionScaleToLight1_1 = CCScaleTo:create(0.5, 0)
	local actionSpwanLight1_1 = CCSpawn:createWithTwoActions(actionFadeToLight1_1,actionScaleToLight1_1)
	local actionScaleToLight1_2 = CCScaleTo:create(0.4, 14)
	local actionFadeToLight1_2 = CCFadeTo:create(0.4, 255)
	local actionSpwanLight1_2 = CCSpawn:createWithTwoActions(actionScaleToLight1_2,actionFadeToLight1_2)
	local actionScaleToLight1_3 = CCScaleTo:create(0.4, 2)
	local actionFadeToLight1_3 = CCFadeTo:create(0.4, 0)
	arryActLight1:addObject(actionSpwanLight1_1)
	local function setZOrderLight1()
		g_playSoundEffect("Sound/Ani_EventEnd1.mp3")
		self.Image_Light1:setZOrder(12)
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
		self.Image_Light2:setZOrder(13)
	end
	arryActLight2:addObject(CCCallFuncN:create(setZOrderLight2))
	arryActLight2:addObject(actionSpwanLight2_2)
	arryActLight2:addObject(actionScaleToLight2_3)
	arryActLight2:addObject(actionFadeToLight2_3)
	local actionLight2 = CCSequence:create(arryActLight2)
	
	local arryActMask = CCArray:create()
	local actionFadeToMask = CCFadeTo:create(0.4, 0)
	arryActMask:addObject(CCDelayTime:create(1.3))
	arryActMask:addObject(actionFadeToMask)
	local function executeCloseAction()
		g_WndMgr:closeWnd("Game_RankLevelUpAnimation")
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "Game_RankLevelUpAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	arryActMask:addObject(CCCallFuncN:create(executeCloseAction))
	local actionMask = CCSequence:create(arryActMask)
	
	self.Image_ShieldMaskBottom:runAction(actionShieldMaskBottom)
	self.Image_Shield:runAction(actionFadeToShield)
	self.Image_ShieldDragon:runAction(actionShieldDragon)
	self.Image_ShieldMask:runAction(actionFadeToShieldMask)
	self.Image_Light1:runAction(actionLight1)
	self.Image_Light2:runAction(actionLight2)
	self.ImageView_Mask:runAction(actionMask)
end

function Game_RankLevelUpAnimation:initWnd()
	
end

function Game_RankLevelUpAnimation:closeWnd()
	cclog("============Game_RankLevelUpAnimation==============closeWnd")
	if self.funcEndCallBack then
		cclog("============Game_RankLevelUpAnimation==============funcEndCallBack")
		self.funcEndCallBack()
	end
	g_Timer:destroyTimerByID(self.nTimerID_Game_HeroLevelUpAnimation_1)
	self.nTimerID_Game_HeroLevelUpAnimation_1 = nil
end

function Game_RankLevelUpAnimation:openWnd(tbAniParams)

	if g_bReturn then
		return
	end

	self.bCanCloseWnd = false
	
	self.tbAniParams = tbAniParams
	if self.tbAniParams and self.tbAniParams ~= {} then
		self.funcDisappearedCallBack = self.tbAniParams.funcDisappearedCallBack
		self.funcEndCallBack = self.tbAniParams.funcEndCallBack
	end
	
	self.ImageView_Mask = tolua.cast(self.rootWidget:getChildByName("ImageView_Mask"), "ImageView")
	self.Button_Return = tolua.cast(self.rootWidget:getChildByName("Button_Return"), "Button")
	
	self.ImageView_MsgContentPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_MsgContentPNL"), "ImageView")
	self.ImageView_RankUpgradePNL = tolua.cast(self.ImageView_MsgContentPNL:getChildByName("ImageView_RankUpgradePNL"), "ImageView")
	
	self.Image_Light1 = tolua.cast(self.rootWidget:getChildByName("Image_Light1"), "ImageView")
	self.Image_Light2 = tolua.cast(self.rootWidget:getChildByName("Image_Light2"), "ImageView")
	self.Image_Shield = tolua.cast(self.rootWidget:getChildByName("Image_Shield"), "ImageView")
	self.Image_Flower1 = tolua.cast(self.rootWidget:getChildByName("Image_Flower1"), "ImageView")
	self.Image_Flower2 = tolua.cast(self.rootWidget:getChildByName("Image_Flower2"), "ImageView")
	self.Image_ShieldMaskBottom = tolua.cast(self.rootWidget:getChildByName("Image_ShieldMaskBottom"), "ImageView")
	self.Image_ShieldDragon = tolua.cast(self.rootWidget:getChildByName("Image_ShieldDragon"), "ImageView")
	self.Image_ShieldMask = tolua.cast(self.rootWidget:getChildByName("Image_ShieldMask"), "ImageView")
	self.Image_Char1 = tolua.cast(self.rootWidget:getChildByName("Image_Char1"), "ImageView")
	
	self.Image_Light1:setVisible(true)
	self.Image_Light2:setVisible(true)
	self.Image_Shield:setVisible(true)
	self.Image_Flower1:setVisible(true)
	self.Image_Flower2:setVisible(true)
	self.Image_ShieldMaskBottom:setVisible(true)
	self.Image_ShieldDragon:setVisible(true)
	self.Image_ShieldMask:setVisible(true)
	self.Image_Char1:setVisible(true)
	
	self.Image_Light1:setZOrder(12)
	self.Image_Light2:setZOrder(13)
	self.Image_Shield:setZOrder(6)
	self.Image_Flower1:setZOrder(4)
	self.Image_Flower2:setZOrder(4)
	self.Image_ShieldMaskBottom:setZOrder(5)
	self.Image_ShieldDragon:setZOrder(7)
	self.Image_ShieldMask:setZOrder(9)
	self.Image_Char1:setZOrder(8)
	
	g_SetBlendFuncWidget(self.Image_Light1, 3)
	g_SetBlendFuncWidget(self.Image_Light2, 3)
	g_SetBlendFuncWidget(self.Image_ShieldMaskBottom, 1)
	g_SetBlendFuncWidget(self.Image_ShieldDragon, 3)
	g_SetBlendFuncWidget(self.Image_ShieldMask, 3)
		
	self.Image_Light1:setPosition(ccp(640,425))
	self.Image_Light2:setPosition(ccp(640,425))
	self.Image_Shield:setPosition(ccp(640,425))
	self.Image_Flower1:setPosition(ccp(422,400))
	self.Image_Flower2:setPosition(ccp(858,400))
	self.Image_ShieldMaskBottom:setPosition(ccp(640,425))
	self.Image_ShieldDragon:setPosition(ccp(641,443))
	self.Image_ShieldMask:setPosition(ccp(640,425))
	self.Image_Char1:setPosition(ccp(640,400))
	
	self.Image_Light1:setScale(0)
	self.Image_Light2:setScale(0)
	self.Image_Shield:setScale(2)
	self.Image_Flower1:setScale(2)
	self.Image_Flower2:setScaleX(-2)
	self.Image_Flower2:setScaleY(2)
	self.Image_ShieldMaskBottom:setScale(2)
	self.Image_ShieldDragon:setScale(2)
	self.Image_ShieldMask:setScale(2)
	self.Image_Char1:setScale(1)

	self.Image_Light1:setOpacity(255)
	self.Image_Light2:setOpacity(255)
	self.Image_Shield:setOpacity(255)
	self.Image_Flower1:setOpacity(255)
	self.Image_Flower1:setOpacity(255)
	self.Image_ShieldMaskBottom:setOpacity(0)
	self.Image_ShieldDragon:setOpacity(255)
	self.Image_ShieldMask:setOpacity(0)
	self.Image_Char1:setOpacity(255)
	
	self.ImageView_Mask:setOpacity(0)
	self.ImageView_Mask:setVisible(true)
	self.Button_Return:setVisible(false)
	self.Button_Return:setTouchEnabled(false)
	self.ImageView_MsgContentPNL:setVisible(false)
	
	
	--没有在使用 先隐藏 
	self.ImageView_RankUpgradePNL:setVisible(false)
	
	self.strSound = "Sound/Ani_ReputationLevelUp.mp3"
	self.Image_Char1:loadTexture(getCocoAnimationImg("UpgradeEvent_Char12"))
		
	--金色盾牌
	if self.tbAniParams and self.tbAniParams ~= {} then
		self:setImageView_RankUpgradePNL()
	end

	self.Image_Flower1:setVisible(false)
	self.Image_Flower2:setVisible(false)
	self.Image_Shield:setVisible(false)
	self.Image_Char1:setVisible(false)
	
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
	
	local arryActShieldMaskBottom = CCArray:create()
	local actionFadeToShieldMaskBottom = CCFadeTo:create(0.4, 255)
	arryActShieldMaskBottom:addObject(actionFadeToShieldMaskBottom)
	local function playSound()
		g_playSoundEffect("Sound/Ani_EventShield.mp3")
	end
	arryActShieldMaskBottom:addObject(CCCallFuncN:create(playSound))
	arryActShieldMaskBottom:addObject(CCDelayTime:create(0.4))
	local function repeatShieldMaskBottomLight()
		local arryActShieldMaskBottomLight = CCArray:create()
		local actionFadeToShieldMaskBottom1 = CCFadeTo:create(1.5, 100)
		local actionFadeToShieldMaskBottom2 = CCFadeTo:create(1.5, 255)
		arryActShieldMaskBottomLight:addObject(actionFadeToShieldMaskBottom1)
		arryActShieldMaskBottomLight:addObject(actionFadeToShieldMaskBottom2)
		local actionShieldMaskBottomLight = CCSequence:create(arryActShieldMaskBottomLight)
		local actionForeverShieldMaskBottomLight = CCRepeatForever:create(actionShieldMaskBottomLight)
		self.Image_ShieldMaskBottom:runAction(actionForeverShieldMaskBottomLight)
	end
	arryActShieldMaskBottom:addObject(CCCallFuncN:create(repeatShieldMaskBottomLight))
	local actionShieldMaskBottom = CCSequence:create(arryActShieldMaskBottom)
	
	local arryActShieldMask = CCArray:create()
	local actionFadeToShieldMask = CCFadeTo:create(0.4, 255)
	arryActShieldMask:addObject(actionFadeToShieldMask)
	arryActShieldMask:addObject(CCDelayTime:create(0.4))
	local function repeatShieldMaskLight()
		local arryActShieldMaskLight = CCArray:create()
		local actionFadeToShieldMask1 = CCFadeTo:create(1.5, 80)
		local actionFadeToShieldMask2 = CCFadeTo:create(1.5, 255)
		arryActShieldMaskLight:addObject(actionFadeToShieldMask1)
		arryActShieldMaskLight:addObject(actionFadeToShieldMask2)
		local actionShieldMaskLight = CCSequence:create(arryActShieldMaskLight)
		local actionForeverShieldMaskLight = CCRepeatForever:create(actionShieldMaskLight)
		self.Image_ShieldMask:runAction(actionForeverShieldMaskLight)
	end
	arryActShieldMask:addObject(CCCallFuncN:create(repeatShieldMaskLight))
	local actionShieldMask = CCSequence:create(arryActShieldMask)
	
	local arryActShieldDragon = CCArray:create()
	arryActShieldDragon:addObject(CCDelayTime:create(0.4))
	arryActShieldDragon:addObject(CCDelayTime:create(0.4))
	local function repeatShieldDragonLight()
		local arryActShieldDragonLight = CCArray:create()
		local actionFadeToShieldDragon1 = CCFadeTo:create(1.5, 100)
		local actionFadeToShieldDragon2 = CCFadeTo:create(1.5, 255)
		arryActShieldDragonLight:addObject(actionFadeToShieldDragon1)
		arryActShieldDragonLight:addObject(actionFadeToShieldDragon2)
		local actionShieldDragonLight = CCSequence:create(arryActShieldDragonLight)
		local actionForeverShieldDragonLight = CCRepeatForever:create(actionShieldDragonLight)
		self.Image_ShieldDragon:runAction(actionForeverShieldDragonLight)
	end
	arryActShieldDragon:addObject(CCCallFuncN:create(repeatShieldDragonLight))
	local actionShieldDragon = CCSequence:create(arryActShieldDragon)

	local actionFadeToMask = CCFadeTo:create(0.4, 255)
	self.ImageView_Mask:runAction(actionFadeToMask)
	
	self.Image_Light1:runAction(actionLight1)
	self.Image_Light2:runAction(actionLight2)
	self.Image_ShieldMaskBottom:runAction(actionShieldMaskBottom)
	self.Image_ShieldDragon:runAction(actionShieldDragon)
	self.Image_ShieldMask:runAction(actionShieldMask)
	
	g_playSoundEffect(self.strSound)
	if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "Game_RankLevelUpAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	--爆炸达到最大幅度，回调显示动画内容
	local function showAnimationContent()
		if not g_WndMgr:getWnd("Game_RankLevelUpAnimation") then return end
		if self.Image_Flower1 then
			self.Image_Flower1:setVisible(true)
		end
		self.Image_Flower2:setVisible(true)
		self.Image_Shield:setVisible(true)
		self.Image_Char1:setVisible(true)
		self.Button_Return:setVisible(true)
		self.bCanCloseWnd = true
		if self.tbAniParams and self.tbAniParams ~= {} then
			self.ImageView_MsgContentPNL:setVisible(true)
		end
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationShow", "Game_RankLevelUpAnimation") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	self.nTimerID_Game_HeroLevelUpAnimation_1 = g_Timer:pushTimer(0.4, showAnimationContent)
	
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

function g_ShowRankLevelUpAnimation(tbAniParams)
	g_WndMgr:showWnd("Game_RankLevelUpAnimation", tbAniParams)
end
