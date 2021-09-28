--------------------------------------------------------------------------------------
-- 文件名:	Glittering.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-5-2 9:37
-- 版  本:	1.0
-- 描  述:	装备闪光功能
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

g_tbCocoAnimationResouce = g_tbCocoAnimationResouce or {}
--创建只有销毁回调的Json动画

function g_CreateCoCosAnimation(strAniName, funcEndCallBack,nPathType)
	-- create animation
	local strPathFile = nil
	if nPathType == 1 then
		strPathFile = getEffectSkillJson(strAniName)
	elseif nPathType == 3 then
		--
	elseif nPathType == 4 then
		--
	elseif nPathType == 2 or nPathType == 5 or nPathType == 6 then
		strPathFile = getCocoAnimationJson(strAniName)
	end
	
	g_tbCocoAnimationResouce[strPathFile] = true
	
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(strPathFile)
	local armature =  CCArmature:create(strAniName)

	if(not armature)then
		cclog("CPlayer:g_CreateCoCosAnimation nil=========>"..strAniName)
		return nil
	end

	local userAnimation = armature:getAnimation()
	local function AnimationEndCallBack(armatureBack,movementType,movementID)
		if(movementType == 1)then --完成 ccs.MovementEventType.COMPLETE
			armatureBack:removeFromParentAndCleanup(true)
			if(funcEndCallBack)then
				funcEndCallBack()
			end
		end
	end
	userAnimation:setMovementEventCallFunc(AnimationEndCallBack)
	return armature,userAnimation
end


function g_GlitteringWidget(widget, nType, nDirection, nLayer, fTime, fDelayTime, fScale, bRepeat)
	local nType = nType or 1
	local nDirection = nDirection or 1
	local fTime = fTime or 0.5
	local fDelayTime = fDelayTime or 2
	local nLayer = nLayer or 0
	local fScale = fScale or 1
	local bRepeat = bRepeat or 1
	
	local blendFuncDstColor = ccBlendFunc()
	blendFuncDstColor.src = GL_DST_COLOR
	blendFuncDstColor.dst = GL_ONE
	
	local ccSpriteStencil = CCSprite:create(getCocoAnimationImg("Summon_CardFlashLight"))
	ccSpriteStencil:setAnchorPoint(ccp(0.5,0.5))
	ccSpriteStencil:setBlendFunc(blendFuncDstColor)
	ccSpriteStencil:setPosition(ccp(0, 0))
	ccSpriteStencil:setVisible(false)
	
	local widgetClone = widget:clone()
	local ccSpriteofWidget = tolua.cast(widgetClone:getVirtualRenderer(),"CCSprite")
	ccSpriteofWidget:setAnchorPoint(ccp(0.5,0.5))
	ccSpriteofWidget:setPosition(ccp(0, 0))
	
	local tbSize = widget:getSize()
	local clippingNode = CCClippingNode:create()
	clippingNode:setStencil(ccSpriteofWidget)
	clippingNode:setAlphaThreshold(0)
	clippingNode:setPosition(ccp(0,0))
	clippingNode:setInverted(false)
	clippingNode:setScale(fScale)
	clippingNode:addChild(ccSpriteStencil)
	clippingNode:setTag(11)
	widget:removeAllNodes()
	widget:addNode(clippingNode, nLayer)
	
	local ccpStartPos = nil
	local ccpEndPos = nil
	local nOffset = 0
	--上下滑动
	if nType == 1 then
		if nDirection == 1 then
			--向上
			ccpStartPos = ccp(0, -tbSize.height)
			ccpEndPos = ccp(0 , tbSize.height)
		else
			--向下
			ccpStartPos = ccp(0, tbSize.height)
			ccpEndPos = ccp(0, -tbSize.height)
		end
	--左右滑动
	elseif nType == 2 then
		ccSpriteStencil:setRotation(90)
		if nDirection == 1 then
			--向右
			ccpStartPos = ccp(-tbSize.width, 0)
			ccpEndPos = ccp(tbSize.width, 0)
		else
			--向左
			ccpStartPos = ccp(tbSize.width, 0)
			ccpEndPos = ccp(-tbSize.width, 0)
		end
	--左下角往右上角
	elseif nType == 3 then
		ccSpriteStencil:setRotation(45)
		if nDirection == 1 then
			--往右上角
			ccpStartPos = ccp(-tbSize.width, -tbSize.height)
			ccpEndPos = ccp(tbSize.width, tbSize.height)
		else
			--往左下角
			ccpStartPos = ccp(tbSize.width, tbSize.height)
			ccpEndPos = ccp(-tbSize.width, -tbSize.height)
		end
	--左上角往右下角
	elseif nType == 4 then
		ccSpriteStencil:setRotation(-45)
		if nDirection == 1 then
			--往右下角
			ccpStartPos = ccp(-tbSize.width, tbSize.height)
			ccpEndPos = ccp(tbSize.width, -tbSize.height)
		else
			--往左上角
			ccpStartPos = ccp(tbSize.width, -tbSize.height)
			ccpEndPos = ccp(-tbSize.width, tbSize.height)
		end
	end
	
	function resetPosition()
		ccSpriteStencil:setPosition(ccpStartPos)
		ccSpriteStencil:setVisible(true)
	end
	
	function startFlashLight()
		local actionMoveTo1 =  CCMoveTo:create(fTime, ccpEndPos)
		local actionMoveTo2 =  CCMoveTo:create(fTime, ccpEndPos)
		local arrActLight = CCArray:create()
		arrActLight:addObject(CCCallFuncN:create(resetPosition))
		arrActLight:addObject(actionMoveTo1)
		arrActLight:addObject(CCDelayTime:create(0.2))
		arrActLight:addObject(CCCallFuncN:create(resetPosition))
		arrActLight:addObject(actionMoveTo1)
		arrActLight:addObject(CCDelayTime:create(fDelayTime))
		
		local function removechildCallBack(sender)
			sender:removeFromParentAndCleanup(true)
		end

		if bRepeat == 1 then
			local actionLight = CCSequence:create(arrActLight)
			local actionForeverLight = CCRepeatForever:create(actionLight)
			ccSpriteStencil:runAction(actionForeverLight)
		else
			arrActLight:addObject(CCCallFuncN:create(removechildCallBack))
			local actionLight = CCSequence:create(arrActLight)
			ccSpriteStencil:runAction(actionLight)
		end
	end
	startFlashLight()
	
	return clippingNode
end

function g_GlitteringCCSprite(ccSpriteParent, strPath, nType, nDirection, nLayer, fScale, fTime)
	local nType = nType or 1
	local nDirection = nDirection or 1
	local fTime = fTime or 0.5
	local nLayer = nLayer or 0
	local fScale = fScale or 1
	
	local blendFuncDstColor = ccBlendFunc()
	blendFuncDstColor.src = GL_DST_COLOR
	blendFuncDstColor.dst = GL_ONE
	
	local ccSpriteStencil = CCSprite:create(getCocoAnimationImg("Summon_CardFlashLight"))
	ccSpriteStencil:setBlendFunc(blendFuncDstColor)
	local ccSpriteClone = CCSprite:create(strPath)

	local tbSize = ccSpriteParent:getContentSize()
	local clippingNode = CCClippingNode:create()
	ccSpriteClone:setAnchorPoint(ccp(0.5, 0.5))
	ccSpriteClone:setPosition(ccp(0,0))
	ccSpriteStencil:setVisible(false)
	clippingNode:setStencil(ccSpriteClone)
	clippingNode:setAlphaThreshold(0)
	clippingNode:setAnchorPoint(ccp(0.5, 0.5))
	clippingNode:setPosition(ccp(tbSize.width/2,tbSize.height/2))
	clippingNode:setInverted(false)
	clippingNode:addChild(ccSpriteStencil)
	ccSpriteParent:removeAllChildrenWithCleanup(true)
	clippingNode:setScale(fScale)
	ccSpriteParent:addChild(clippingNode,nLayer)
	
	local ccpStartPos = nil
	local ccpEndPos = nil
	local nOffset = 60
	--上下滑动
	if nType == 1 then
		if nDirection == 1 then
			--向上
			ccpStartPos = ccp(tbSize.width/2, 0 - nOffset)
			ccpEndPos = ccp(tbSize.width/2 , tbSize.height + nOffset)
		else
			--向下
			ccpStartPos = ccp(tbSize.width/2, tbSize.height + nOffset)
			ccpEndPos = ccp(tbSize.width/2, 0 - nOffset)
		end
	--左右滑动
	elseif nType == 2 then
		ccSpriteStencil:setRotation(90)
		if nDirection == 1 then
			--向右
			ccpStartPos = ccp(0 - nOffset, tbSize.height/2)
			ccpEndPos = ccp(tbSize.width + nOffset, tbSize.height/2)
		else
			--向左
			ccpStartPos = ccp(tbSize.width + nOffset, tbSize.height/2)
			ccpEndPos = ccp(0 - nOffset, tbSize.height/2)
		end
	--左下角往右上角
	elseif nType == 3 then
		ccSpriteStencil:setRotation(45)
		if nDirection == 1 then
			--往右上角
			ccpStartPos = ccp(0 - nOffset, -0 - nOffset)
			ccpEndPos = ccp(tbSize.width + nOffset, tbSize.height + nOffset)
		else
			--往左下角
			ccpStartPos = ccp(tbSize.width + nOffset, tbSize.height + nOffset)
			ccpEndPos = ccp(0 - nOffset, -0 - nOffset)
		end
	--左上角往右下角
	elseif nType == 4 then
		ccSpriteStencil:setRotation(-45)
		if nDirection == 1 then
			--往右下角
			ccpStartPos = ccp(0 - nOffset, tbSize.height + nOffset)
			ccpEndPos = ccp(tbSize.width + nOffset, -0 - nOffset)
		else
			--往左上角
			ccpStartPos = ccp(tbSize.width + nOffset, -0 - nOffset)
			ccpEndPos = ccp(0 - nOffset, tbSize.height + nOffset)
		end
	end
	
	function resetPosition()
		ccSpriteStencil:setPosition(ccpStartPos)
		ccSpriteStencil:setVisible(true)
	end
	
	function startFlashLight()
		local actionMoveTo1 =  CCMoveTo:create(fTime, ccpEndPos)
		local actionMoveTo2 =  CCMoveTo:create(fTime, ccpEndPos)
		local arrActLight = CCArray:create()
		arrActLight:addObject(CCCallFuncN:create(resetPosition))
		arrActLight:addObject(actionMoveTo1)
		arrActLight:addObject(CCDelayTime:create(0.2))
		arrActLight:addObject(CCCallFuncN:create(resetPosition))
		arrActLight:addObject(actionMoveTo1)
		arrActLight:addObject(CCDelayTime:create(2))
		
		local actionLight = CCSequence:create(arrActLight)
		local actionForeverLight = CCRepeatForever:create(actionLight)
		ccSpriteStencil:runAction(actionForeverLight)
	end
	startFlashLight()
	
	return clippingNode
end