--------------------------------------------------------------------------------------
-- 文件名:	WJQ_SummonCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	王家麒
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	装备合成的动画
-- 应  用:
---------------------------------------------------------------------------------------
Game_RewardMsgConfirm = class("Game_RewardMsgConfirm")
Game_RewardMsgConfirm.__index = Game_RewardMsgConfirm

local tbAnimationScaleConfig1 = {
	fScaleRayInSide = 6*0.4,
	fScaleRayOutSide = 6*0.4,
	fScaleExplodeOutSide = 3.16*0.4,
	fScaleExplodeInSide = 2.81*0.4,
	fScaleCrossLightHorizontalX = 10*0.4,
	fScaleCrossLightHorizontalY = 2.95*0.4,
	fScaleCrossLightVerticalX = 5*0.4,
	fScaleCrossLightVerticalY = 2.95*0.4,
	fScaleCircleInSideSmall = 2.24*0.4,
	fScaleCircleOutSideBig = 2.51*0.4,
	fScaleCircleOutSideSmall = 2.35*0.4
}
local tbAniConfigStep1 = {
	fTime = 0.35,
	fScale = 2,
	fEaseTime = 5,
	fAngle = 45
}
local tbAniConfigStep2 = {
	fTime = 0.35,
	fScale = 0.5,
	fEaseTime = 5,
	fAngle = 45
}
local tbAniConfigStep3 = {
	fTime = 0.35,
	fScale = 1,
	fAngle = 45
}
local tbAniConfigStep4 = {
	fTime = 0.35,
	fScale = 3,
	fAngle = 45
}
local tbAniConfigStep5 = {
	fTime = 0.1,
	fScale = 0
}
local tbAniConfigStep6 = {
	fTime = 0.35,
	fScale = 2,
	fAngle = 45
}
local tbAniConfigStep7 = {
	fTime = 0.4,
	fScale = 0.7
}
local tbAniConfigStep8 = {
	fTime = 0.2
}
local tbElementText = {_T("金"), _T("木"), _T("水"), _T("火"), _T("土"), _T("风"),_T("雷")}
local element ={
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL,		    --金元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE,	        --木元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER,		    --水元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE,           --火元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH,           --土元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR,            --风元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING,         --雷元素 
}
function Game_RewardMsgConfirm:playResourceObtainSound()
	if self.nDropType == macro_pb.ITEM_TYPE_MASTER_EXP then	--主角经验
		g_playSoundEffect("Sound/Drop_YueLi.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_MASTER_ENERGY then	--体力
		g_playSoundEffect("Sound/Drop_Energy.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_COUPONS then	--元宝
		g_playSoundEffect("Sound/Drop_YuanBao.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_GOLDS then	--铜钱
		g_playSoundEffect("Sound/Drop_Money.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_PRESTIGE then	--声望
		g_playSoundEffect("Sound/Drop_XianLing.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_KNOWLEDGE then	--阅历
		g_playSoundEffect("Sound/Drop_JingJiChang.mp3")
	elseif self.nDropType == macro_pb.ITEM_TYPE_ARENA_TIME then	--竞技场挑战次数
		g_playSoundEffect("Sound/Drop_JingJiChang.mp3")
	else
		g_playSoundEffect("Sound/Drop_Money.mp3")
	end
end

function Game_RewardMsgConfirm:showDisappearedAnimation()
	
	self.Image_RayInSide:stopAllActions()
	self.Image_RayOutSide:stopAllActions()
	self.Image_ExplodeOutSide:stopAllActions()
	self.Image_ExplodeInSide:stopAllActions()
	self.Image_CrossLightHorizontal:stopAllActions()
	self.Image_CrossLightVertical:stopAllActions()
	self.Image_CircleInSideSmall:stopAllActions()
	self.Image_CircleOutSideBig:stopAllActions()
	self.Image_CircleOutSideSmall:stopAllActions()
	self.Image_ResourceIconShape:stopAllActions()
	self.Image_ResourceIcon:removeAllChildrenWithCleanup(true)

	local arrAct_RayInSide = CCArray:create()
	local actionFadeTo_RayInSide5 = CCFadeTo:create(tbAniConfigStep5.fTime, 0)
	local actionScaleTo_RayInSide5 = CCScaleTo:create(tbAniConfigStep5.fTime, tbAniConfigStep5.fScale*tbAnimationScaleConfig1.fScaleRayInSide)
	local actionSpwan_RayInSide5 = CCSpawn:createWithTwoActions(actionFadeTo_RayInSide5, actionScaleTo_RayInSide5)
	local actionScaleTo_RayInSide6 = CCScaleTo:create(tbAniConfigStep6.fTime, tbAniConfigStep6.fScale*tbAnimationScaleConfig1.fScaleRayInSide)
	local actionFadeTo_RayInSide6 = CCFadeTo:create(tbAniConfigStep6.fTime, 255)
	local actionSpwan_RayInSide6 = CCSpawn:createWithTwoActions(actionScaleTo_RayInSide6, actionFadeTo_RayInSide6)
	local actionScaleTo_RayInSide7 = CCScaleTo:create(tbAniConfigStep7.fTime, 1)
	local actionFadeTo_RayInSide8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_RayInSide:addObject(actionSpwan_RayInSide5)
	local function setZOrderRayInSide()
		g_SetBlendFuncWidget(self.Image_RayInSide, 3)
		self.Image_RayInSide:setZOrder(21)
	end
	arrAct_RayInSide:addObject(CCCallFuncN:create(setZOrderRayInSide))
	arrAct_RayInSide:addObject(actionSpwan_RayInSide6)
	arrAct_RayInSide:addObject(actionScaleTo_RayInSide7)
	arrAct_RayInSide:addObject(actionFadeTo_RayInSide8)
	local action_RayInSide = CCSequence:create(arrAct_RayInSide)

	local arrAct_RayOutSide = CCArray:create()
	local actionFadeTo_RayOutSide5 = CCFadeTo:create(tbAniConfigStep5.fTime, 0)
	local actionScaleTo_RayOutSide5 = CCScaleTo:create(tbAniConfigStep5.fTime, tbAniConfigStep5.fScale*tbAnimationScaleConfig1.fScaleRayOutSide)
	local actionSpwan_RayOutSide5 = CCSpawn:createWithTwoActions(actionFadeTo_RayOutSide5, actionScaleTo_RayOutSide5)
	local actionScaleTo_RayOutSide6 = CCScaleTo:create(tbAniConfigStep6.fTime, tbAniConfigStep6.fScale*tbAnimationScaleConfig1.fScaleRayOutSide)
	local actionFadeTo_RayOutSide6 = CCFadeTo:create(tbAniConfigStep6.fTime, 255)
	local actionSpwan_RayOutSide6 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide6, actionFadeTo_RayOutSide6)
	local actionScaleTo_RayOutSide7 = CCScaleTo:create(tbAniConfigStep7.fTime, 1)
	local actionFadeTo_RayOutSide8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_RayOutSide:addObject(actionSpwan_RayOutSide5)
	local function setZOrderRayOutSide()
		g_SetBlendFuncWidget(self.Image_RayInSide, 3)
		self.Image_RayOutSide:setZOrder(22)
	end
	arrAct_RayOutSide:addObject(CCCallFuncN:create(setZOrderRayOutSide))
	arrAct_RayOutSide:addObject(actionSpwan_RayOutSide6)
	arrAct_RayOutSide:addObject(actionScaleTo_RayOutSide7)
	arrAct_RayOutSide:addObject(actionFadeTo_RayOutSide8)
	local action_RayOutSide = CCSequence:create(arrAct_RayOutSide)

	local arrAct_ExplodeOutSide = CCArray:create()
	local actionScaleTo_ExplodeOutSide7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleExplodeOutSide)
	local actionFadeTo_ExplodeOutSide8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_ExplodeOutSide:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_ExplodeOutSide:addObject(actionScaleTo_ExplodeOutSide7)
	arrAct_ExplodeOutSide:addObject(actionFadeTo_ExplodeOutSide8)
	local action_ExplodeOutSide = CCSequence:create(arrAct_ExplodeOutSide)

	local arrAct_ExplodeInSide = CCArray:create()
	local actionScaleTo_ExplodeInSide7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleExplodeInSide)
	local actionFadeTo_ExplodeInSide8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_ExplodeInSide:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_ExplodeInSide:addObject(actionScaleTo_ExplodeInSide7)
	arrAct_ExplodeInSide:addObject(actionFadeTo_ExplodeInSide8)
	local action_ExplodeInSide = CCSequence:create(arrAct_ExplodeInSide)

	local arrAct_CrossLightHorizontal = CCArray:create()
	local actionScaleTo_CrossLightHorizontal7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleCrossLightHorizontalX,tbAnimationScaleConfig1.fScaleCrossLightHorizontalY)
	local actionFadeTo_CrossLightHorizontal8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_CrossLightHorizontal:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_CrossLightHorizontal:addObject(actionScaleTo_CrossLightHorizontal7)
	arrAct_CrossLightHorizontal:addObject(actionFadeTo_CrossLightHorizontal8)
	local action_CrossLightHorizontal = CCSequence:create(arrAct_CrossLightHorizontal)

	local arrAct_CrossLightVertical = CCArray:create()
	local actionScaleTo_CrossLightVertical7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleCrossLightVerticalX,tbAnimationScaleConfig1.fScaleCrossLightVerticalY)
	local actionFadeTo_CrossLightVertical8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_CrossLightVertical:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_CrossLightVertical:addObject(actionScaleTo_CrossLightVertical7)
	arrAct_CrossLightVertical:addObject(actionFadeTo_CrossLightVertical8)
	local action_CrossLightVertical = CCSequence:create(arrAct_CrossLightVertical)

	local arrAct_CircleInSideSmall = CCArray:create()
	local actionScaleTo_CircleInSideSmall7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleCircleInSideSmall)
	local actionFadeTo_CircleInSideSmall8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_CircleInSideSmall:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_CircleInSideSmall:addObject(actionScaleTo_CircleInSideSmall7)
	arrAct_CircleInSideSmall:addObject(actionFadeTo_CircleInSideSmall8)
	local action_CircleInSideSmall = CCSequence:create(arrAct_CircleInSideSmall)

	local arrAct_CircleOutSideBig = CCArray:create()
	local actionScaleTo_CircleOutSideBig7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideBig)
	local actionFadeTo_CircleOutSideBig8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_CircleOutSideBig:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_CircleOutSideBig:addObject(actionScaleTo_CircleOutSideBig7)
	arrAct_CircleOutSideBig:addObject(actionFadeTo_CircleOutSideBig8)
	local action_CircleOutSideBig = CCSequence:create(arrAct_CircleOutSideBig)

	local arrAct_CircleOutSideSmall = CCArray:create()
	local actionScaleTo_CircleOutSideSmall7 = CCScaleTo:create(tbAniConfigStep7.fTime, tbAniConfigStep7.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideSmall)
	local actionFadeTo_CircleOutSideSmall8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_CircleOutSideSmall:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	arrAct_CircleOutSideSmall:addObject(actionScaleTo_CircleOutSideSmall7)
	arrAct_CircleOutSideSmall:addObject(actionFadeTo_CircleOutSideSmall8)
	local action_CircleOutSideSmall = CCSequence:create(arrAct_CircleOutSideSmall)

	local arrAct_ResourceIconShape = CCArray:create()
	local actionFadeTo_ResourceIconShape6 = CCFadeTo:create(tbAniConfigStep6.fTime, 255)
	local actionFadeTo_ResourceIconShape8 = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_ResourceIconShape:addObject(CCDelayTime:create(tbAniConfigStep5.fTime))
	local function playSound()
		self:playResourceObtainSound(self.nDropType)
	end
	arrAct_ResourceIconShape:addObject(CCCallFuncN:create(playSound))
	arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape6)
	arrAct_ResourceIconShape:addObject(CCDelayTime:create(tbAniConfigStep7.fTime))
	arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape8)
	local action_ResourceIconShape = CCSequence:create(arrAct_ResourceIconShape)

	local arrAct_MsgConfirmPNL = CCArray:create()
	local actionFadeTo_MsgConfirmPNL = CCFadeTo:create(tbAniConfigStep7.fTime, 0)
	arrAct_MsgConfirmPNL:addObject(CCDelayTime:create(tbAniConfigStep5.fTime+tbAniConfigStep6.fTime))
	arrAct_MsgConfirmPNL:addObject(actionFadeTo_MsgConfirmPNL)
	local action_MsgConfirmPNL = CCSequence:create(arrAct_MsgConfirmPNL)

	local arrAct_Mask = CCArray:create()
	local actionFadeTo_Mask = CCFadeTo:create(tbAniConfigStep8.fTime, 0)
	arrAct_Mask:addObject(CCDelayTime:create(tbAniConfigStep5.fTime + tbAniConfigStep6.fTime))
	local function hideAnimationContent()
		self.Image_ResourceIcon:setVisible(false)
		g_SetBlendFuncWidget(self.Image_ResourceIconShape, 2)
	end
	arrAct_Mask:addObject(CCCallFuncN:create(hideAnimationContent))
	arrAct_Mask:addObject(CCDelayTime:create(tbAniConfigStep7.fTime))
	arrAct_Mask:addObject(actionFadeTo_Mask)
	local function deleteGame_RewardMsgConfirm()
		g_WndMgr:closeWnd("Game_RewardMsgConfirm")
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "Game_RewardMsgConfirm") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	arrAct_Mask:addObject(CCCallFuncN:create(deleteGame_RewardMsgConfirm))
	local action_Mask = CCSequence:create(arrAct_Mask)

	self.Image_RayInSide:runAction(action_RayInSide)
	self.Image_RayOutSide:runAction(action_RayOutSide)
	self.Image_ExplodeOutSide:runAction(action_ExplodeOutSide)
	self.Image_ExplodeInSide:runAction(action_ExplodeInSide)
	self.Image_CrossLightHorizontal:runAction(action_CrossLightHorizontal)
	self.Image_CrossLightVertical:runAction(action_CrossLightVertical)
	self.Image_CircleInSideSmall:runAction(action_CircleInSideSmall)
	self.Image_CircleOutSideBig:runAction(action_CircleOutSideBig)
	self.Image_CircleOutSideSmall:runAction(action_CircleOutSideSmall)
	self.Image_ResourceIconShape:runAction(action_ResourceIconShape)
	self.ImageView_Mask:runAction(action_Mask)
	self.Image_MsgConfirmPNL:runAction(action_MsgConfirmPNL)
end

function Game_RewardMsgConfirm:initWnd()
	self.ImageView_AnimationContent = tolua.cast(self.rootWidget:getChildByName("ImageView_AnimationContent"), "ImageView")
	self.ImageView_AnimationContent:setVisible(true)
	self.ImageView_AnimationContent:setPosition(ccp(450,360))
	self.Image_MsgConfirmPNL = tolua.cast(self.rootWidget:getChildByName("Image_MsgConfirmPNL"), "ImageView")
	self.Image_MsgConfirmPNL:setCascadeOpacityEnabled(true)
	self.Image_MsgConfirmPNL:setOpacity(0)
	self.ImageView_Mask = tolua.cast(self.rootWidget:getChildByName("ImageView_Mask"), "ImageView")
	self.ImageView_Mask:setOpacity(0)
	
	self.Image_RayInSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_RayInSide"), "ImageView")
	self.Image_RayOutSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_RayOutSide"), "ImageView")
	self.Image_ExplodeOutSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ExplodeOutSide"), "ImageView")
	self.Image_ExplodeInSide = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ExplodeInSide"), "ImageView")
	self.Image_CrossLightHorizontal = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CrossLightHorizontal"), "ImageView")
	self.Image_CrossLightVertical = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CrossLightVertical"), "ImageView")
	self.Image_CircleInSideSmall = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleInSideSmall"), "ImageView")
	self.Image_CircleOutSideBig = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleOutSideBig"), "ImageView")
	self.Image_CircleOutSideSmall = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_CircleOutSideSmall"), "ImageView")
	self.Image_ResourceIconShape = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ResourceIconShape"), "ImageView")
	self.Image_ResourceIcon = tolua.cast(self.ImageView_AnimationContent:getChildByName("Image_ResourceIcon"), "ImageView")
	
	self.Image_RayInSide:setVisible(true)
	self.Image_RayOutSide:setVisible(true)
	self.Image_ExplodeOutSide:setVisible(true)
	self.Image_ExplodeInSide:setVisible(true)
	self.Image_CrossLightHorizontal:setVisible(true)
	self.Image_CrossLightVertical:setVisible(true)
	self.Image_CircleInSideSmall:setVisible(true)
	self.Image_CircleOutSideBig:setVisible(true)
	self.Image_CircleOutSideSmall:setVisible(true)
	self.Image_ResourceIconShape:setVisible(true)
	self.Image_ResourceIcon:setVisible(true)
	
	self.Image_RayInSide:setZOrder(21)
	self.Image_RayOutSide:setZOrder(22)
	self.Image_ExplodeOutSide:setZOrder(3)
	self.Image_ExplodeInSide:setZOrder(4)
	self.Image_CrossLightHorizontal:setZOrder(5)
	self.Image_CrossLightVertical:setZOrder(6)
	self.Image_CircleInSideSmall:setZOrder(8)
	self.Image_CircleOutSideBig:setZOrder(9)
	self.Image_CircleOutSideSmall:setZOrder(10)
	self.Image_ResourceIconShape:setZOrder(14)
	self.Image_ResourceIcon:setZOrder(15)
	
	g_SetBlendFuncWidget(self.Image_RayInSide, 1)
	g_SetBlendFuncWidget(self.Image_RayOutSide, 1)
	g_SetBlendFuncWidget(self.Image_ExplodeOutSide, 3)
	g_SetBlendFuncWidget(self.Image_ExplodeInSide, 3)
	g_SetBlendFuncWidget(self.Image_CrossLightHorizontal, 1)
	g_SetBlendFuncWidget(self.Image_CrossLightVertical, 1)
	g_SetBlendFuncWidget(self.Image_CircleInSideSmall, 1)
	g_SetBlendFuncWidget(self.Image_CircleOutSideBig, 1)
	g_SetBlendFuncWidget(self.Image_CircleOutSideSmall, 1)
	g_SetBlendFuncWidget(self.Image_ResourceIconShape, 3)

	self.Image_RayInSide:setPosition(ccp(0,0))
	self.Image_RayOutSide:setPosition(ccp(0,0))
	self.Image_ExplodeOutSide:setPosition(ccp(0,0))
	self.Image_ExplodeInSide:setPosition(ccp(0,0))
	self.Image_CrossLightVertical:setRotation(90)
	self.Image_CrossLightHorizontal:setPosition(ccp(0,0))
	self.Image_CrossLightVertical:setPosition(ccp(0,0))
	self.Image_CircleInSideSmall:setPosition(ccp(0,0))
	self.Image_CircleOutSideBig:setPosition(ccp(0,0))
	self.Image_CircleOutSideSmall:setPosition(ccp(0,0))
	self.Image_ResourceIconShape:setPosition(ccp(0,0))
	self.Image_ResourceIcon:setPosition(ccp(0,0))

	self.Image_RayInSide:setOpacity(255)
	self.Image_RayOutSide:setOpacity(255)
	self.Image_ExplodeOutSide:setOpacity(0)
	self.Image_ExplodeInSide:setOpacity(0)
	self.Image_CrossLightHorizontal:setOpacity(255)
	self.Image_CrossLightVertical:setOpacity(255)
	self.Image_CircleInSideSmall:setOpacity(0)
	self.Image_CircleOutSideBig:setOpacity(0)
	self.Image_CircleOutSideSmall:setOpacity(0)
	self.Image_ResourceIconShape:setOpacity(0)
	self.Image_ResourceIcon:setOpacity(0)

	self.Image_RayInSide:setScale(0)
	self.Image_RayOutSide:setScale(0)
	self.Image_ExplodeOutSide:setScale(0)
	self.Image_ExplodeInSide:setScale(0)
	self.Image_CrossLightHorizontal:setScaleX(0)
	self.Image_CrossLightHorizontal:setScaleY(1)
	self.Image_CrossLightVertical:setScaleX(0)
	self.Image_CrossLightVertical:setScaleY(1)
	self.Image_CircleInSideSmall:setScale(0)
	self.Image_CircleOutSideBig:setScale(0)
	self.Image_CircleOutSideSmall:setScale(0)
	self.Image_ResourceIconShape:setScale(1)
	self.Image_ResourceIcon:setScale(1)
end

function Game_RewardMsgConfirm:openWnd(tbParam)
	if not tbParam then return end
	if tbParam.nDropType and tbParam.nDropType < 8 then return end
	--接口数据初始化
	self.nDropType = tbParam.nDropType
	self.nObtainResourceValue = tbParam.nObtainResourceValue
	self.funcEndCallBack = tbParam.funcEndCallBack

	self.bCanCloseWnd = false

	local Label_RewardStr1 = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RewardStr1"), "Label")
	local Label_RewardValue = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RewardValue"), "Label")
	local Label_RewardStr2 = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RewardStr2"), "Label")
	local Label_RemainStr1 = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RemainStr1"), "Label")
	local Label_RemainValue = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RemainValue"), "Label")
	local Label_RemainStr2 = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RemainStr2"), "Label")
	local Label_RemainStr3 = tolua.cast(self.Image_MsgConfirmPNL:getChildByName("Label_RemainStr3"), "Label")

	local ccSpritePath = getUIImg("Icon_PlayerInfo_EnergyBig")
	local fGlitterScale = 1
	if self.nDropType == macro_pb.ITEM_TYPE_MASTER_EXP then	--主角经验
		ccSpritePath = getUIImg("Icon_PlayerInfo_YueLiBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点主角经验"))
		Label_RemainStr1:setText(_T("现在主角经验为"))
		Label_RemainValue:setText(g_Hero:getMasterCardCurExpInNewLevByAddExp(self.nObtainResourceValue))
		Label_RemainStr2:setText("/")
		Label_RemainStr3:setText(g_Hero:getMasterCardFullExpInNewLevByAddExp(self.nObtainResourceValue))
	elseif self.nDropType == macro_pb.ITEM_TYPE_MASTER_ENERGY then	--体力
		ccSpritePath = getUIImg("Icon_PlayerInfo_EnergyBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点体力"))
		Label_RemainStr1:setText(_T("现在体力值为"))
		Label_RemainValue:setText(g_Hero:getEnergy())
		Label_RemainStr2:setText("/")
		Label_RemainStr3:setText(g_Hero:getMaxEnergy())
	elseif self.nDropType == macro_pb.ITEM_TYPE_COUPONS then	--元宝
		ccSpritePath = getUIImg("Icon_PlayerInfo_YuanBaoBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("个元宝"))
		Label_RemainStr1:setText(_T("现总共拥有"))
		Label_RemainValue:setText(g_Hero:getYuanBao())
		Label_RemainStr2:setText(_T("个元宝"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_GOLDS then	--铜钱
		ccSpritePath = getUIImg("Icon_PlayerInfo_TongQianBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("个铜钱"))
		Label_RemainStr1:setText(_T("现总共拥有"))
		Label_RemainValue:setText(g_Hero:getCoins())
		Label_RemainStr2:setText(_T("个铜钱"))
		Label_RemainStr3:setText("")
		fGlitterScale = 0.9
	elseif self.nDropType == macro_pb.ITEM_TYPE_PRESTIGE then	--声望/仙令
		ccSpritePath = getUIImg("Icon_PlayerInfo_PrestigeBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点声望"))
		Label_RemainStr1:setText(_T("现声望值总共为"))
		Label_RemainValue:setText(g_Hero:getPrestige())
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_KNOWLEDGE then	--阅历
		ccSpritePath = getUIImg("Icon_PlayerInfo_XueShiBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点阅历"))
		Label_RemainStr1:setText(_T("现阅历值总共为"))
		Label_RemainValue:setText(g_Hero:getKnowledge())
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_INCENSE then	--香贡
		ccSpritePath = getUIImg("Icon_PlayerInfo_IncenseBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点香贡"))
		Label_RemainStr1:setText(_T("现香贡值总共为"))
		Label_RemainValue:setText(g_Hero:getIncense())
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_POWER then	--神力/神识
		ccSpritePath = getUIImg("Icon_PlayerInfo_EnergyBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("点神力"))
		Label_RemainStr1:setText(_T("现神力值总共为"))
		Label_RemainValue:setText(g_Hero:getGodPower())
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_ARENA_TIME then	--竞技场挑战次数
		ccSpritePath = getUIImg("Icon_PlayerInfo_AreaTimesBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("次天榜挑战次数"))
		Label_RemainStr1:setText(_T("现天榜挑战次数总共为"))
		Label_RemainValue:setText(g_Hero:getArenaTimes())
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_ESSENCE then	--元素精华、灵力
		ccSpritePath = getUIImg("Icon_PlayerInfo_ElementsBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("灵力"))
		Label_RemainStr1:setText(_T("现灵力总共为"))
		Label_RemainValue:setText(g_Hero:getEssence())
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_FRIENDHEART then --友情之心
		ccSpritePath = getUIImg("Icon_PlayerInfo_PriendPointsBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("爱心"))
		Label_RemainStr1:setText(_T("现爱心总共为"))
		Label_RemainValue:setText(g_Hero:getFriendPoints())
		Label_RemainStr2:setText(_T("个"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then --伙伴经验
		ccSpritePath = getUIImg("Icon_PlayerInfo_YueLiBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("伙伴经验"))
		Label_RemainStr1:setText(_T("所有伙伴的经验增加"))
		Label_RemainValue:setText(self.nObtainResourceValue)
		Label_RemainStr2:setText(_T("点"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIAN_LING then --仙令
		ccSpritePath = getUIImg("Icon_PlayerInfo_XianLingBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("仙令"))
		Label_RemainStr1:setText(_T("现仙令总共为"))
		Label_RemainValue:setText(g_Hero:getXianLing())
		Label_RemainStr2:setText(_T("个"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_DRAGON_BALL then --神龙令
		ccSpritePath = getUIImg("Icon_PlayerInfo_DragonTokenBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("神龙令"))
		Label_RemainStr1:setText(_T("现神龙令总共为"))
		Label_RemainValue:setText(g_Hero:getDragonBall())
		Label_RemainStr2:setText(_T("个"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then --一键消除
		ccSpritePath = getUIImg("Icon_PlayerInfo_XiaoChuSkill1")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("一键消除技能使用次数"))
		Label_RemainStr1:setText(_T("现一键消除技能使用次数"))
		Label_RemainValue:setText(g_Hero:getXiaoChuSkill(0, macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY))
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then --霸者横栏
		ccSpritePath = getUIImg("Icon_PlayerInfo_XiaoChuSkill2")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("霸者横栏技能使用次数"))
		Label_RemainStr1:setText(_T("现霸者横栏技能使用次数"))
		Label_RemainValue:setText(g_Hero:getXiaoChuSkill(0, macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE))
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then --消除连锁
		ccSpritePath = getUIImg("Icon_PlayerInfo_XiaoChuSkill3")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("消除连锁技能使用次数"))
		Label_RemainStr1:setText(_T("现消除连锁技能使用次数"))
		Label_RemainValue:setText(g_Hero:getXiaoChuSkill(0, macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO))
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then --斗转星移
		ccSpritePath = getUIImg("Icon_PlayerInfo_XiaoChuSkill4")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("斗转星移技能使用次数"))
		Label_RemainStr1:setText(_T("现斗转星移技能使用次数"))
		Label_RemainValue:setText(g_Hero:getXiaoChuSkill(0, macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN))
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then --颠倒乾坤
		ccSpritePath = getUIImg("Icon_PlayerInfo_XiaoChuSkill5")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("颠倒乾坤技能使用次数"))
		Label_RemainStr1:setText(_T("现颠倒乾坤技能使用次数"))
		Label_RemainValue:setText(g_Hero:getXiaoChuSkill(0, macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO))
		Label_RemainStr2:setText(_T("次"))
		Label_RemainStr3:setText("")
    elseif  self.nDropType >= macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL 
		and self.nDropType <= macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then --觉醒元素属性数量
        for i = 1, #element do 
            if self.nDropType == element[i] then
				ccSpritePath = getUIImg("Icon_PlayerInfo_LingHe"..i)
		        Label_RewardStr1:setText(_T("获得"))
		        Label_RewardValue:setText(self.nObtainResourceValue)
		        Label_RewardStr2:setText(string.format(_T("个%s灵核"), tbElementText[i]) )
		        Label_RemainStr1:setText(string.format(_T("现总拥有%s灵核"), tbElementText[i]) )
                local elementData = g_XianMaiInfoData:getTbElementList()
		        Label_RemainValue:setText(elementData[i])
		        Label_RemainStr2:setText(_T("个"))
		        Label_RemainStr3:setText("")
				break
            end
        end
	elseif self.nDropType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then --将魂石
		ccSpritePath = getUIImg("Icon_PlayerInfo_JiangHunShiBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("将魂石"))
		Label_RemainStr1:setText(_T("现将魂石总共为"))
		Label_RemainValue:setText(g_Hero:getJiangHunShi())
		Label_RemainStr2:setText(_T("个"))
		Label_RemainStr3:setText("")
	elseif self.nDropType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then --将魂令
		ccSpritePath = getUIImg("Icon_PlayerInfo_RefreshTokenBig")
		Label_RewardStr1:setText(_T("获得"))
		Label_RewardValue:setText(self.nObtainResourceValue)
		Label_RewardStr2:setText(_T("将魂令"))
		Label_RemainStr1:setText(_T("现将魂令总共为"))
		Label_RemainValue:setText(g_Hero:getRefreshToken())
		Label_RemainStr2:setText(_T("个"))
		Label_RemainStr3:setText("")
	end

	g_AdjustWidgetsPosition({Label_RewardStr1, Label_RewardValue, Label_RewardStr2},5)
	g_AdjustWidgetsPosition({Label_RemainStr1, Label_RemainValue, Label_RemainStr2, Label_RemainStr3},5)
	g_playSoundEffect("Sound/Ani_RewardStart.mp3")
	
	self.Image_ResourceIconShape:loadTexture(ccSpritePath)
	self.Image_ResourceIcon:loadTexture(ccSpritePath)

	local arrAct_RayInSide = CCArray:create()
	local actionScaleTo_RayInSide1 = CCScaleTo:create(tbAniConfigStep1.fTime*0.5, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleRayInSide)
	local actionScaleTo_RayInSide2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleRayInSide)
	local actionFadeTo_RayInSide2 = CCFadeTo:create(tbAniConfigStep2.fTime, 255)
	local actionSpawn_RayInSide2 = CCSpawn:createWithTwoActions(actionScaleTo_RayInSide2, actionFadeTo_RayInSide2)
	local actionScaleTo_RayInSide3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleRayInSide)
	local actionFadeTo_RayInSide3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_RayInSide3 = CCSpawn:createWithTwoActions(actionScaleTo_RayInSide3, actionFadeTo_RayInSide3)
	arrAct_RayInSide:addObject(actionScaleTo_RayInSide1)
	arrAct_RayInSide:addObject(actionSpawn_RayInSide2)
	local function resetRayInSide()
		g_SetBlendFuncWidget(self.Image_RayInSide, 2)
		self.Image_RayInSide:setZOrder(1)
	end
	arrAct_RayInSide:addObject(CCCallFuncN:create(resetRayInSide))
	arrAct_RayInSide:addObject(actionSpawn_RayInSide3)
	local function repeatRayInSide()
		local actionRotateBy_RayInSide = CCRotateBy:create(15,360)
		local actionForever_RayInSide = CCRepeatForever:create(actionRotateBy_RayInSide)
		self.Image_RayInSide:runAction(actionForever_RayInSide)
	end
	arrAct_RayInSide:addObject(CCCallFuncN:create(repeatRayInSide))
	local action_RayInSide = CCSequence:create(arrAct_RayInSide)

	local arrAct_RayOutSide = CCArray:create()
	local actionScaleTo_RayOutSide1 = CCScaleTo:create(tbAniConfigStep1.fTime*0.5, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleRayOutSide)
	local actionScaleTo_RayOutSide2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleRayOutSide)
	local actionFadeTo_RayOutSide2 = CCFadeTo:create(tbAniConfigStep2.fTime, 255)
	local actionSpawn_RayOutSide2 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide2, actionFadeTo_RayOutSide2)
	local actionScaleTo_RayOutSide3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleRayOutSide)
	local actionFadeTo_RayOutSide3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_RayOutSide3 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide3, actionFadeTo_RayOutSide3)
	arrAct_RayOutSide:addObject(actionScaleTo_RayOutSide1)
	arrAct_RayOutSide:addObject(actionSpawn_RayOutSide2)
	local function resetRayOutSide()
		g_SetBlendFuncWidget(self.Image_RayOutSide, 2)
		self.Image_RayOutSide:setZOrder(2)
	end
	arrAct_RayOutSide:addObject(CCCallFuncN:create(resetRayOutSide))
	arrAct_RayOutSide:addObject(actionSpawn_RayOutSide3)
	local function repeatRayOutSide()
		local actionRotateBy_RayOutSide = CCRotateBy:create(15,-360)
		local actionForever_RayOutSide = CCRepeatForever:create(actionRotateBy_RayOutSide)
		self.Image_RayOutSide:runAction(actionForever_RayOutSide)
	end
	arrAct_RayOutSide:addObject(CCCallFuncN:create(repeatRayOutSide))
	local action_RayOutSide = CCSequence:create(arrAct_RayOutSide)

	local arrAct_CrossLightHorizontal = CCArray:create()
	local actionScaleTo_CrossLightHorizontal1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleCrossLightHorizontalX, tbAnimationScaleConfig1.fScaleCrossLightHorizontalY)
	local actionFadeTo_CrossLightHorizontal1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_CrossLightHorizontal1 = CCSpawn:createWithTwoActions(actionScaleTo_CrossLightHorizontal1, actionFadeTo_CrossLightHorizontal1)
	local actionSpawn_CrossLightHorizontalEase1 = CCEaseIn:create(actionSpawn_CrossLightHorizontal1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_CrossLightHorizontal2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleCrossLightHorizontalX, tbAnimationScaleConfig1.fScaleCrossLightHorizontalY)
	local actionScaleTo_CrossLightHorizontal3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleCrossLightHorizontalX, tbAnimationScaleConfig1.fScaleCrossLightHorizontalY)
	local actionFadeTo_CrossLightHorizontal3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_CrossLightHorizontal3 = CCSpawn:createWithTwoActions(actionScaleTo_CrossLightHorizontal3, actionFadeTo_CrossLightHorizontal3)
	arrAct_CrossLightHorizontal:addObject(actionSpawn_CrossLightHorizontalEase1)
	arrAct_CrossLightHorizontal:addObject(actionScaleTo_CrossLightHorizontal2)
	arrAct_CrossLightHorizontal:addObject(actionSpawn_CrossLightHorizontal3)
	local function repeatCrossLightHorizontal()
		local arrAct_CrossLightHorizontal = CCArray:create()
		local actionFadeTo_CrossLightHorizontal1 = CCFadeTo:create(1, 150)
		local actionFadeTo_CrossLightHorizontal2 = CCFadeTo:create(1, 255)
		arrAct_CrossLightHorizontal:addObject(actionFadeTo_CrossLightHorizontal1)
		arrAct_CrossLightHorizontal:addObject(actionFadeTo_CrossLightHorizontal2)
		local action_CrossLightHorizontal = CCSequence:create(arrAct_CrossLightHorizontal)
		local actionForever_CrossLightHorizontal = CCRepeatForever:create(action_CrossLightHorizontal)
		self.Image_CrossLightHorizontal:runAction(actionForever_CrossLightHorizontal)
	end
	arrAct_CrossLightHorizontal:addObject(CCCallFuncN:create(repeatCrossLightHorizontal))
	local action_CrossLightHorizontal = CCSequence:create(arrAct_CrossLightHorizontal)

	local arrAct_CrossLightVertical = CCArray:create()
	local actionScaleTo_CrossLightVertical1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleCrossLightVerticalX, tbAnimationScaleConfig1.fScaleCrossLightVerticalY)
	local actionFadeTo_CrossLightVertical1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_CrossLightVertical1 = CCSpawn:createWithTwoActions(actionScaleTo_CrossLightVertical1, actionFadeTo_CrossLightVertical1)
	local actionSpawn_CrossLightVerticalEase1 = CCEaseIn:create(actionSpawn_CrossLightVertical1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_CrossLightVertical2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleCrossLightVerticalX, tbAnimationScaleConfig1.fScaleCrossLightVerticalY)
	local actionScaleTo_CrossLightVertical3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleCrossLightVerticalX, tbAnimationScaleConfig1.fScaleCrossLightVerticalY)
	local actionFadeTo_CrossLightVertical3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_CrossLightVertical3 = CCSpawn:createWithTwoActions(actionScaleTo_CrossLightVertical3, actionFadeTo_CrossLightVertical3)
	arrAct_CrossLightVertical:addObject(actionSpawn_CrossLightVerticalEase1)
	arrAct_CrossLightVertical:addObject(actionScaleTo_CrossLightVertical2)
	arrAct_CrossLightVertical:addObject(actionSpawn_CrossLightVertical3)
	local function repeatCrossLightVertical()
		local arrAct_CrossLightVertical = CCArray:create()
		local actionFadeTo_CrossLightVertical1 = CCFadeTo:create(1, 150)
		local actionFadeTo_CrossLightVertical2 = CCFadeTo:create(1, 255)
		arrAct_CrossLightVertical:addObject(actionFadeTo_CrossLightVertical1)
		arrAct_CrossLightVertical:addObject(actionFadeTo_CrossLightVertical2)
		local action_CrossLightVertical = CCSequence:create(arrAct_CrossLightVertical)
		local actionForever_CrossLightVertical = CCRepeatForever:create(action_CrossLightVertical)
		self.Image_CrossLightVertical:runAction(actionForever_CrossLightVertical)
	end
	arrAct_CrossLightVertical:addObject(CCCallFuncN:create(repeatCrossLightVertical))
	local action_CrossLightVertical = CCSequence:create(arrAct_CrossLightVertical)

	local arrAct_ExplodeOutSide = CCArray:create()
	local actionScaleTo_ExplodeOutSide1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleExplodeOutSide)
	local actionFadeTo_ExplodeOutSide1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_ExplodeOutSide1 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeOutSide1, actionFadeTo_ExplodeOutSide1)
	local actionSpawn_ExplodeOutSideEase1 = CCEaseIn:create(actionSpawn_ExplodeOutSide1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_ExplodeOutSide2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleExplodeOutSide)
	local actionScaleTo_ExplodeOutSideEase2 = CCEaseOut:create(actionScaleTo_ExplodeOutSide2, tbAniConfigStep2.fEaseTime)
	local actionScaleTo_ExplodeOutSide3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleExplodeOutSide)
	local actionFadeTo_ExplodeOutSide3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_ExplodeOutSide3 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeOutSide3, actionFadeTo_ExplodeOutSide3)
	arrAct_ExplodeOutSide:addObject(actionSpawn_ExplodeOutSideEase1)
	arrAct_ExplodeOutSide:addObject(actionScaleTo_ExplodeOutSideEase2)
	arrAct_ExplodeOutSide:addObject(actionSpawn_ExplodeOutSide3)
	local function repeatExplodeOutSide()
		local actionRotateBy_ExplodeOutSide = CCRotateBy:create(15,-360)
		local actionForever_ExplodeOutSide = CCRepeatForever:create(actionRotateBy_ExplodeOutSide)
		self.Image_ExplodeOutSide:runAction(actionForever_ExplodeOutSide)
	end
	arrAct_ExplodeOutSide:addObject(CCCallFuncN:create(repeatExplodeOutSide))
	local action_ExplodeOutSide = CCSequence:create(arrAct_ExplodeOutSide)

	local arrAct_ExplodeInSide = CCArray:create()
	local actionScaleTo_ExplodeInSide1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleExplodeInSide)
	local actionFadeTo_ExplodeInSide1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_ExplodeInSide1 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeInSide1, actionFadeTo_ExplodeInSide1)
	local actionSpawn_ExplodeInSideEase1 = CCEaseIn:create(actionSpawn_ExplodeInSide1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_ExplodeInSide2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleExplodeInSide)
	local actionScaleTo_ExplodeInSideEase2 = CCEaseOut:create(actionScaleTo_ExplodeInSide2, tbAniConfigStep2.fEaseTime)
	local actionScaleTo_ExplodeInSide3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleExplodeInSide)
	local actionFadeTo_ExplodeInSide3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_ExplodeInSide3 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeInSide3, actionFadeTo_ExplodeInSide3)
	arrAct_ExplodeInSide:addObject(actionSpawn_ExplodeInSideEase1)
	arrAct_ExplodeInSide:addObject(actionScaleTo_ExplodeInSide2)
	arrAct_ExplodeInSide:addObject(actionSpawn_ExplodeInSide3)
	local function repeatExplodeInSide()
		local actionRotateBy_ExplodeInSide = CCRotateBy:create(15,360)
		local actionForever_ExplodeInSide = CCRepeatForever:create(actionRotateBy_ExplodeInSide)
		self.Image_ExplodeInSide:runAction(actionForever_ExplodeInSide)
	end
	arrAct_ExplodeInSide:addObject(CCCallFuncN:create(repeatExplodeInSide))
	local action_ExplodeInSide = CCSequence:create(arrAct_ExplodeInSide)

	local arrAct_CircleInSideSmall = CCArray:create()
	local actionScaleTo_CircleInSideSmall1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleCircleInSideSmall)
	local actionFadeTo_CircleInSideSmall1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_CircleInSideSmall1 = CCSpawn:createWithTwoActions(actionScaleTo_CircleInSideSmall1, actionFadeTo_CircleInSideSmall1)
	local actionSpawn_CircleInSideSmallEase1 = CCEaseIn:create(actionSpawn_CircleInSideSmall1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_CircleInSideSmall2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleCircleInSideSmall)
	local actionScaleTo_CircleInSideSmallEase2 = CCEaseOut:create(actionScaleTo_CircleInSideSmall2, tbAniConfigStep2.fEaseTime)
	local actionScaleTo_CircleInSideSmall3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleCircleInSideSmall)
	local actionFadeTo_CircleInSideSmall3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_CircleInSideSmall3 = CCSpawn:createWithTwoActions(actionScaleTo_CircleInSideSmall3, actionFadeTo_CircleInSideSmall3)
	arrAct_CircleInSideSmall:addObject(actionSpawn_CircleInSideSmallEase1)
	arrAct_CircleInSideSmall:addObject(actionScaleTo_CircleInSideSmallEase2)
	arrAct_CircleInSideSmall:addObject(actionSpawn_CircleInSideSmall3)
	local function repeatCircleInSideSmall()
		local actionRotateBy_CircleInSideSmall = CCRotateBy:create(15,-360)
		local actionForever_CircleInSideSmall = CCRepeatForever:create(actionRotateBy_CircleInSideSmall)
		self.Image_CircleInSideSmall:runAction(actionForever_CircleInSideSmall)
	end
	arrAct_CircleInSideSmall:addObject(CCCallFuncN:create(repeatCircleInSideSmall))
	local action_CircleInSideSmall = CCSequence:create(arrAct_CircleInSideSmall)

	local arrAct_CircleOutSideBig = CCArray:create()
	local actionScaleTo_CircleOutSideBig1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideBig)
	local actionFadeTo_CircleOutSideBig1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_CircleOutSideBig1 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideBig1, actionFadeTo_CircleOutSideBig1)
	local actionSpawn_CircleOutSideBigEase1 = CCEaseIn:create(actionSpawn_CircleOutSideBig1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_CircleOutSideBig2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideBig)
	local actionScaleTo_CircleOutSideBigEase2 = CCEaseOut:create(actionScaleTo_CircleOutSideBig2, tbAniConfigStep2.fEaseTime)
	local actionScaleTo_CircleOutSideBig3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideBig)
	local actionFadeTo_CircleOutSideBig3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_CircleOutSideBig3 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideBig3, actionFadeTo_CircleOutSideBig3)
	arrAct_CircleOutSideBig:addObject(actionSpawn_CircleOutSideBig1)
	arrAct_CircleOutSideBig:addObject(actionScaleTo_CircleOutSideBig2)
	arrAct_CircleOutSideBig:addObject(actionSpawn_CircleOutSideBig3)
	local function repeatCircleOutSideBig()
		local actionRotateBy_CircleOutSideBig = CCRotateBy:create(15,360)
		local actionForever_CircleOutSideBig = CCRepeatForever:create(actionRotateBy_CircleOutSideBig)
		self.Image_CircleOutSideBig:runAction(actionForever_CircleOutSideBig)
	end
	arrAct_CircleOutSideBig:addObject(CCCallFuncN:create(repeatCircleOutSideBig))
	local action_CircleOutSideBig = CCSequence:create(arrAct_CircleOutSideBig)

	local arrAct_CircleOutSideSmall = CCArray:create()
	local actionScaleTo_CircleOutSideSmall1 = CCScaleTo:create(tbAniConfigStep1.fTime, tbAniConfigStep1.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideSmall)
	local actionFadeTo_CircleOutSideSmall1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionSpawn_CircleOutSideSmall1 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideSmall1, actionFadeTo_CircleOutSideSmall1)
	local actionSpawn_CircleOutSideSmallEase1 = CCEaseIn:create(actionSpawn_CircleOutSideSmall1, tbAniConfigStep1.fEaseTime)
	local actionScaleTo_CircleOutSideSmall2 = CCScaleTo:create(tbAniConfigStep2.fTime, tbAniConfigStep2.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideSmall)
	local actionScaleTo_CircleOutSideSmallEase2 = CCEaseOut:create(actionScaleTo_CircleOutSideSmall2, tbAniConfigStep2.fEaseTime)
	local actionScaleTo_CircleOutSideSmall3 = CCScaleTo:create(tbAniConfigStep3.fTime, tbAniConfigStep3.fScale*tbAnimationScaleConfig1.fScaleCircleOutSideSmall)
	local actionFadeTo_CircleOutSideSmall3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	local actionSpawn_CircleOutSideSmall3 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideSmall3, actionFadeTo_CircleOutSideSmall3)
	arrAct_CircleOutSideSmall:addObject(actionSpawn_CircleOutSideSmall1)
	arrAct_CircleOutSideSmall:addObject(actionScaleTo_CircleOutSideSmallEase2)
	arrAct_CircleOutSideSmall:addObject(actionSpawn_CircleOutSideSmall3)
	local function repeatCircleOutSideSmall()
		local actionRotateBy_CircleOutSideSmall = CCRotateBy:create(15,-360)
		local actionForever_CircleOutSideSmall = CCRepeatForever:create(actionRotateBy_CircleOutSideSmall)
		self.Image_CircleOutSideSmall:runAction(actionForever_CircleOutSideSmall)
	end
	arrAct_CircleOutSideSmall:addObject(CCCallFuncN:create(repeatCircleOutSideSmall))
	local action_CircleOutSideSmall = CCSequence:create(arrAct_CircleOutSideSmall)

	local arrAct_ResourceIconShape = CCArray:create()
	local actionFadeTo_ResourceIconShape1 = CCFadeTo:create(tbAniConfigStep1.fTime, 255)
	local actionFadeTo_ResourceIconShape3 = CCFadeTo:create(tbAniConfigStep3.fTime, 0)
	arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape1)
	arrAct_ResourceIconShape:addObject(CCDelayTime:create(tbAniConfigStep2.fTime))
	arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape3)
	local function deleteResourceIconShape()
		g_SetBlendFuncWidget(self.Image_ResourceIconShape, 1)
		local arrAct_ResourceIconShape = CCArray:create()
		local actionFadeTo_ResourceIconShape1 = CCFadeTo:create(1.7, 255)
		local actionFadeTo_ResourceIconShape2 = CCFadeTo:create(1.7, 0)
		arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape1)
		arrAct_ResourceIconShape:addObject(actionFadeTo_ResourceIconShape2)
		local action_ResourceIconShape = CCSequence:create(arrAct_ResourceIconShape)
		local actionForever_ResourceIconShape = CCRepeatForever:create(action_ResourceIconShape)
		self.Image_ResourceIconShape:runAction(actionForever_ResourceIconShape)
	end
	arrAct_ResourceIconShape:addObject(CCCallFuncN:create(deleteResourceIconShape))
	local action_ResourceIconShape = CCSequence:create(arrAct_ResourceIconShape)

	local arrAct_ResourceIcon = CCArray:create()
	local actionFadeTo_ResourceIcon3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	arrAct_ResourceIcon:addObject(CCDelayTime:create(tbAniConfigStep1.fTime))
	arrAct_ResourceIcon:addObject(CCDelayTime:create(tbAniConfigStep2.fTime))
	arrAct_ResourceIcon:addObject(actionFadeTo_ResourceIcon3)
	local function showGlitteringLight()
		g_GlitteringWidget(self.Image_ResourceIcon, 3, 1, 100, nil, nil, fGlitterScale)
	end
	arrAct_ResourceIcon:addObject(CCCallFuncN:create(showGlitteringLight))
	local action_ResourceIcon = CCSequence:create(arrAct_ResourceIcon)

	local arrAct_MsgConfirmPNL = CCArray:create()
	local actionFadeTo_MsgConfirmPNL3 = CCFadeTo:create(tbAniConfigStep3.fTime, 255)
	arrAct_MsgConfirmPNL:addObject(CCDelayTime:create(tbAniConfigStep1.fTime+tbAniConfigStep2.fTime))
	arrAct_MsgConfirmPNL:addObject(actionFadeTo_MsgConfirmPNL3)
	local function executeFuncEndCall()
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationShow", "Game_RewardMsgConfirm") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	arrAct_MsgConfirmPNL:addObject(CCCallFuncN:create(executeFuncEndCall))
	local action_MsgConfirmPNL = CCSequence:create(arrAct_MsgConfirmPNL)


	self.rootWidget:setVisible(true)

	local actionFadeToMask = CCFadeTo:create(0.4, 100)
	self.ImageView_Mask:runAction(actionFadeToMask)
	self.Image_MsgConfirmPNL:runAction(action_MsgConfirmPNL)
	self.Image_RayInSide:runAction(action_RayInSide)
	self.Image_RayOutSide:runAction(action_RayOutSide)
	self.Image_ExplodeOutSide:runAction(action_ExplodeOutSide)
	self.Image_ExplodeInSide:runAction(action_ExplodeInSide)
	self.Image_CrossLightHorizontal:runAction(action_CrossLightHorizontal)
	self.Image_CrossLightVertical:runAction(action_CrossLightVertical)
	self.Image_CircleInSideSmall:runAction(action_CircleInSideSmall)
	self.Image_CircleOutSideBig:runAction(action_CircleOutSideBig)
	self.Image_CircleOutSideSmall:runAction(action_CircleOutSideSmall)
	self.Image_ResourceIcon:runAction(action_ResourceIcon)
	self.Image_ResourceIconShape:runAction(action_ResourceIconShape)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "Game_RewardMsgConfirm") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end

	local function setCanCloseWnd()
		self.bCanCloseWnd = true
	end
	self.nTimerID_Game_RewardMsgConfirm_1 = g_Timer:pushTimer(tbAniConfigStep1.fTime+tbAniConfigStep2.fTime+tbAniConfigStep3.fTime,setCanCloseWnd)
	
	local function onTouchScreen(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if self.bCanCloseWnd then
				self.bCanCloseWnd = false
				self:showDisappearedAnimation()
			end
		end
	end 
	self.rootWidget:addTouchEventListener(onTouchScreen)
end

function Game_RewardMsgConfirm:closeWnd()
	if self.funcEndCallBack then
		self.funcEndCallBack()
	end
	self.rootWidget:removeAllNodes()
	g_Timer:destroyTimerByID(self.nTimerID_Game_RewardMsgConfirm_1)
	self.nTimerID_Game_RewardMsgConfirm_1 = nil
end

--因为该接口最后会显示g_Hero里面的当前拥有数值，因此注意要先Update g_Hero里面的数据再弹出这个动画
function g_ShowRewardMsgConfrim(nDropType, nObtainResourceValue, funcEndCallBack)
	local tbAniParams = {
		nDropType = nDropType or 0,
		nObtainResourceValue = nObtainResourceValue or 0,
		funcEndCallBack = funcEndCallBack,
	}
	g_WndMgr:showWnd("Game_RewardMsgConfirm", tbAniParams)
end