--伙伴吞噬动画 
function g_ShowCardConsumeAnimation(layerWidget, fParticaleScale, fKeepTime, funcDisappearCall, funcEndCallBack)
	if not layerWidget then return end
	local fParticaleScale = fParticaleScale or 1
	local fKeepTime = fKeepTime or 1
	local tbPos = ccp(0,0)
	
	layerWidget:stopAllActions()
	layerWidget:removeAllNodes()
	
	local fTimeStep2 = 0.4
	local fTimeStep3 = 0.4
	local fTimeStep4 = 0.4
	local fTimeStep5 = 0.2
	local fEaseTime4 = 4
	local nAngleSpeed = 120
	
	local blendFuncMinusDstColor = ccBlendFunc()
	blendFuncMinusDstColor.src = GL_ONE_MINUS_DST_COLOR
	blendFuncMinusDstColor.dst = GL_ONE
	local blendFuncDstColor = ccBlendFunc()
	blendFuncDstColor.src = GL_DST_COLOR
	blendFuncDstColor.dst = GL_ONE
	local blendFuncSrcAlpha = ccBlendFunc()
	blendFuncSrcAlpha.src = GL_SRC_ALPHA
	blendFuncSrcAlpha.dst = GL_ONE
	
	local armatureSpark =  CCParticleSystemQuad:create(getCocoAnimationPlist("LevelUpAnimation2"))
	g_SetBlendFuncSprite(armatureSpark,4)
	armatureSpark:setAutoRemoveOnFinish(true)
	armatureSpark:setPosition(tbPos)
	armatureSpark:setScale(fParticaleScale)
	armatureSpark:setDuration(fKeepTime+fTimeStep2+fTimeStep3); 
	
	layerWidget:addNode(armatureSpark, 19)
	
	local tbAnimationScaleConfig1 = {
		Summon_RayInSide = 6,
		Summon_RayOutSide = 6,
		Summon_ExplodeOutSide = 2.7,
		Summon_ExplodeInSide = 2.3,
		Summon_CircleInSideSmall = 2.24,
		Summon_CircleOutSideBig = 2.5,
		Summon_CircleOutSideSmall = 2.34
	}
	
	local Summon_RayInSide = CCSprite:create(getCocoAnimationImg("UpgradeEvent_Light2_1"))
	local Summon_RayOutSide = CCSprite:create(getCocoAnimationImg("UpgradeEvent_Light2_2"))
	local Summon_ExplodeOutSide = CCSprite:create(getCocoAnimationImg("Summon_Explode1"))
	local Summon_ExplodeInSide = CCSprite:create(getCocoAnimationImg("Summon_Explode1"))
	local Summon_CircleInSideSmall = CCSprite:create(getCocoAnimationImg("Summon_CircleInSideSmall"))
	local Summon_CircleOutSideBig = CCSprite:create(getCocoAnimationImg("Summon_CircleOutSideBig1"))
	local Summon_CircleOutSideSmall = CCSprite:create(getCocoAnimationImg("Summon_CircleOutSideSmall1"))
	
	g_SetBlendFuncSprite(Summon_RayInSide,4)
	g_SetBlendFuncSprite(Summon_RayOutSide,4)
	g_SetBlendFuncSprite(Summon_ExplodeOutSide,3)
	g_SetBlendFuncSprite(Summon_ExplodeInSide,3)
	g_SetBlendFuncSprite(Summon_CircleInSideSmall,1)
	g_SetBlendFuncSprite(Summon_CircleOutSideBig,1)
	g_SetBlendFuncSprite(Summon_CircleOutSideSmall,1)
	
	Summon_RayInSide:setScale(tbAnimationScaleConfig1.Summon_RayInSide*0.6)
	Summon_RayOutSide:setScale(tbAnimationScaleConfig1.Summon_RayOutSide*0.6)
	Summon_ExplodeOutSide:setScale(tbAnimationScaleConfig1.Summon_ExplodeOutSide*0.6)
	Summon_ExplodeInSide:setScale(tbAnimationScaleConfig1.Summon_ExplodeInSide*0.6)
	Summon_CircleInSideSmall:setScale(tbAnimationScaleConfig1.Summon_CircleInSideSmall*0.6)
	Summon_CircleOutSideBig:setScale(tbAnimationScaleConfig1.Summon_CircleOutSideBig*0.6)
	Summon_CircleOutSideSmall:setScale(tbAnimationScaleConfig1.Summon_CircleOutSideSmall*0.6)
	
	Summon_RayInSide:setOpacity(100)
	Summon_RayOutSide:setOpacity(100)
	Summon_ExplodeOutSide:setOpacity(100)
	Summon_ExplodeInSide:setOpacity(100)
	Summon_CircleInSideSmall:setOpacity(200)
	Summon_CircleOutSideBig:setOpacity(255)
	Summon_CircleOutSideSmall:setOpacity(200)
	
	Summon_RayInSide:setPosition(tbPos)
	Summon_RayOutSide:setPosition(tbPos)
	Summon_ExplodeOutSide:setPosition(tbPos)
	Summon_ExplodeInSide:setPosition(tbPos)
	Summon_CircleInSideSmall:setPosition(tbPos)
	Summon_CircleOutSideBig:setPosition(tbPos)
	Summon_CircleOutSideSmall:setPosition(tbPos)
	
	local arrAct_RayInSide = CCArray:create()
	local actionRotateBy_RayInSide1 = CCRotateBy:create(fKeepTime, -0.5*nAngleSpeed*fKeepTime)
	local actionScaleTo_RayInSide2 = CCScaleTo:create(fTimeStep2, 0)
	local actionFadeTo_RayInSide2 = CCFadeTo:create(fTimeStep2, 100)
	local actionSpawn_RayInSide2 = CCSpawn:createWithTwoActions(actionScaleTo_RayInSide2, actionFadeTo_RayInSide2)
	local actionScaleTo_RayInSide3 = CCScaleTo:create(fTimeStep3, tbAnimationScaleConfig1.Summon_RayInSide*1.3)
	local actionScaleTo_RayInSide4 = CCScaleTo:create(fTimeStep4, 0)
	local actionFadeTo_RayInSide4 = CCFadeTo:create(fTimeStep4, 150)
	local actionSpawn_RayInSide4 = CCSpawn:createWithTwoActions(actionScaleTo_RayInSide4, actionFadeTo_RayInSide4)
	arrAct_RayInSide:addObject(actionRotateBy_RayInSide1)
	arrAct_RayInSide:addObject(actionSpawn_RayInSide2)
	local function resetOpacity_RayInSide()
		g_SetBlendFuncSprite(Summon_RayInSide,4)
		Summon_RayInSide:setOpacity(255)
	end
	arrAct_RayInSide:addObject(CCCallFuncN:create(resetOpacity_RayInSide))
	arrAct_RayInSide:addObject(actionScaleTo_RayInSide3)
	arrAct_RayInSide:addObject(actionSpawn_RayInSide4)
	local action_RayInSide = CCSequence:create(arrAct_RayInSide)
	
	local arrAct_RayOutSide = CCArray:create()
	local actionRotateBy_RayOutSide1 = CCRotateBy:create(fKeepTime, 0.5*nAngleSpeed*fKeepTime)
	local actionScaleTo_RayOutSide2 = CCScaleTo:create(fTimeStep2, 0)
	local actionFadeTo_RayOutSide2 = CCFadeTo:create(fTimeStep2, 100)
	local actionSpawn_RayOutSide2 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide2, actionFadeTo_RayOutSide2)
	local actionScaleTo_RayOutSide3 = CCScaleTo:create(fTimeStep3, tbAnimationScaleConfig1.Summon_RayOutSide*1.3)
	local actionScaleTo_RayOutSide4 = CCScaleTo:create(fTimeStep4, 0)
	local actionFadeTo_RayOutSide4 = CCFadeTo:create(fTimeStep4, 150)
	local actionSpawn_RayOutSide4 = CCSpawn:createWithTwoActions(actionScaleTo_RayOutSide4, actionFadeTo_RayOutSide4)
	arrAct_RayOutSide:addObject(actionRotateBy_RayOutSide1)
	arrAct_RayOutSide:addObject(actionSpawn_RayOutSide2)
	local function resetOpacity_RayOutSide()
		g_SetBlendFuncSprite(Summon_RayInSide,4)
		Summon_RayOutSide:setOpacity(255)
	end
	arrAct_RayOutSide:addObject(CCCallFuncN:create(resetOpacity_RayOutSide))
	arrAct_RayOutSide:addObject(actionScaleTo_RayOutSide3)
	local function cleanupParticle()
		g_playSoundEffect("Sound/Ani_RewardStart.mp3")
	end
	arrAct_RayOutSide:addObject(CCCallFuncN:create(cleanupParticle))
	arrAct_RayOutSide:addObject(actionSpawn_RayOutSide4)
	local action_RayOutSide = CCSequence:create(arrAct_RayOutSide)
	
	local arrAct_ExplodeOutSide = CCArray:create()
	local actionRotateBy_ExplodeOutSide1 = CCRotateBy:create(fKeepTime+fTimeStep2+fTimeStep3, -1.5*nAngleSpeed*fKeepTime)
	local actionScaleTo_ExplodeOutSide4 = CCScaleTo:create(fTimeStep4+fTimeStep5, 0)
	local actionFadeTo_ExplodeOutSide4 = CCFadeTo:create(fTimeStep4+fTimeStep5, 150)
	local actionSpawn_ExplodeOutSide4 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeOutSide4, actionFadeTo_ExplodeOutSide4)
	local actionSpawn_ExplodeOutSideEase4 = CCEaseIn:create(actionSpawn_ExplodeOutSide4, fEaseTime4)
	arrAct_ExplodeOutSide:addObject(actionRotateBy_ExplodeOutSide1)
	arrAct_ExplodeOutSide:addObject(actionSpawn_ExplodeOutSideEase4)
	local action_ExplodeOutSide = CCSequence:create(arrAct_ExplodeOutSide)
	
	local arrAct_ExplodeInSide = CCArray:create()
	local actionRotateBy_ExplodeInSide1 = CCRotateBy:create(fKeepTime+fTimeStep2+fTimeStep3, 1.5*nAngleSpeed*fKeepTime)
	local actionScaleTo_ExplodeInSide4 = CCScaleTo:create(fTimeStep4+fTimeStep5, 0)
	local actionFadeTo_ExplodeInSide4 = CCFadeTo:create(fTimeStep4+fTimeStep5, 150)
	local actionSpawn_ExplodeInSide4 = CCSpawn:createWithTwoActions(actionScaleTo_ExplodeInSide4, actionFadeTo_ExplodeInSide4)
	local actionSpawn_ExplodeInSideEase4 = CCEaseIn:create(actionSpawn_ExplodeInSide4, fEaseTime4)
	arrAct_ExplodeInSide:addObject(actionRotateBy_ExplodeInSide1)
	arrAct_ExplodeInSide:addObject(actionSpawn_ExplodeInSideEase4)
	local action_ExplodeInSide = CCSequence:create(arrAct_ExplodeInSide)
	
	local arrAct_CircleInSideSmall = CCArray:create()
	local actionRotateBy_CircleInSideSmall1 = CCRotateBy:create(fKeepTime+fTimeStep2+fTimeStep3, -2*nAngleSpeed*fKeepTime)
	local actionScaleTo_CircleInSideSmall4 = CCScaleTo:create(fTimeStep4+fTimeStep5, 0)
	local actionFadeTo_CircleInSideSmall4 = CCFadeTo:create(fTimeStep4+fTimeStep5, 150)
	local actionSpawn_CircleInSideSmall4 = CCSpawn:createWithTwoActions(actionScaleTo_CircleInSideSmall4, actionFadeTo_CircleInSideSmall4)
	local actionSpawn_CircleInSideSmallEase4 = CCEaseIn:create(actionSpawn_CircleInSideSmall4, fEaseTime4)
	arrAct_CircleInSideSmall:addObject(actionRotateBy_CircleInSideSmall1)
	arrAct_CircleInSideSmall:addObject(actionSpawn_CircleInSideSmallEase4)
	local action_CircleInSideSmall = CCSequence:create(arrAct_CircleInSideSmall)
	
	local arrAct_CircleOutSideBig = CCArray:create()
	local actionRotateBy_CircleOutSideBig1 = CCRotateBy:create(fKeepTime+fTimeStep2+fTimeStep3, nAngleSpeed*fKeepTime)
	local actionScaleTo_CircleOutSideBig4 = CCScaleTo:create(fTimeStep4+fTimeStep5, 0)
	local actionFadeTo_CircleOutSideBig4 = CCFadeTo:create(fTimeStep4+fTimeStep5, 150)
	local actionSpawn_CircleOutSideBig4 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideBig4, actionFadeTo_CircleOutSideBig4)
	local actionSpawn_CircleOutSideBigEase4 = CCEaseIn:create(actionSpawn_CircleOutSideBig4, fEaseTime4)
	arrAct_CircleOutSideBig:addObject(actionRotateBy_CircleOutSideBig1)
	arrAct_CircleOutSideBig:addObject(actionSpawn_CircleOutSideBigEase4)
	local action_CircleOutSideBig = CCSequence:create(arrAct_CircleOutSideBig)
	
	local arrAct_CircleOutSideSmall = CCArray:create()
	local actionRotateBy_CircleOutSideSmall1 = CCRotateBy:create(fKeepTime+fTimeStep2+fTimeStep3, -2*nAngleSpeed*fKeepTime)
	local actionScaleTo_CircleOutSideSmall4 = CCScaleTo:create(fTimeStep4+fTimeStep5, 0)
	local actionFadeTo_CircleOutSideSmall4 = CCFadeTo:create(fTimeStep4+fTimeStep5, 150)
	local actionSpawn_CircleOutSideSmall4 = CCSpawn:createWithTwoActions(actionScaleTo_CircleOutSideSmall4, actionFadeTo_CircleOutSideSmall4)
	local actionSpawn_CircleOutSideSmallEase4 = CCEaseIn:create(actionSpawn_CircleOutSideSmall4, fEaseTime4)
	arrAct_CircleOutSideSmall:addObject(actionRotateBy_CircleOutSideSmall1)
	arrAct_CircleOutSideSmall:addObject(actionSpawn_CircleOutSideSmallEase4)
	local function cleanupAction()
		if funcEndCallBack then
			funcEndCallBack()
		end
		layerWidget:removeAllNodes()
	end
	arrAct_CircleOutSideSmall:addObject(CCCallFuncN:create(cleanupAction))
	local action_CircleOutSideSmall = CCSequence:create(arrAct_CircleOutSideSmall)
	
	layerWidget:addNode(Summon_RayInSide, 12)
	layerWidget:addNode(Summon_RayOutSide, 13)
	layerWidget:addNode(Summon_ExplodeOutSide, 4)
	layerWidget:addNode(Summon_ExplodeInSide, 5)
	layerWidget:addNode(Summon_CircleInSideSmall, 6)
	layerWidget:addNode(Summon_CircleOutSideBig, 7)
	layerWidget:addNode(Summon_CircleOutSideSmall, 8)
	
	Summon_RayInSide:runAction(action_RayInSide)
	Summon_RayOutSide:runAction(action_RayOutSide)
	Summon_ExplodeOutSide:runAction(action_ExplodeOutSide)
	Summon_ExplodeInSide:runAction(action_ExplodeInSide)
	Summon_CircleInSideSmall:runAction(action_CircleInSideSmall)
	Summon_CircleOutSideBig:runAction(action_CircleOutSideBig)
	Summon_CircleOutSideSmall:runAction(action_CircleOutSideSmall)
	
	local function executeEndCallBack()
		if funcDisappearCall then
			funcDisappearCall()
		end
	end
	g_playSoundEffect("Sound/Ani_EventZhenFa.mp3")
	
	return g_Timer:pushTimer(fKeepTime+fTimeStep2+fTimeStep3+fTimeStep4/2, executeEndCallBack)
end


--战斗力增加动画，nBegin开始的数字，nEnd结束的数字， func结束回调动画
function g_showTeamStrengthAnimation(nBegin, nEnd, func)
    if not nBegin or nBegin < 0 or not nEnd or nEnd < 0 then
        if func then func() end
        return
    end

    local armature, userAnimation
    local function fadeIn(widget, funcCallBack)
        widget:setOpacity(0)
        local arrAct = CCArray:create()
        local fadein = CCFadeIn:create(0.3)
	    arrAct:addObject(fadein)
        if(funcCallBack)then
		    arrAct:addObject(CCCallFuncN:create(funcCallBack))
	    end   
	    local action = CCSequence:create(arrAct) 
   
        widget:runAction(action)
    end

    local function fadeOut(widget, funcCallBack)
        local function remove()
            widget:setVisible(false)
        end
        funcCallBack = funcCallBack or remove
        local arrAct = CCArray:create()
        local fadeout = CCFadeOut:create(0.2)
	    arrAct:addObject(fadeout)
        if(funcCallBack)then
		    arrAct:addObject(CCCallFuncN:create(funcCallBack))
	    end 

	    local action = CCSequence:create(arrAct) 
   
        widget:runAction(action)
    end

    local function calcDataNum(nData)
        local tbNum = {}
	    while true do
		    local nNum = math.mod(nData, 10)
		    nData = math.floor(nData/10)
		    table.insert(tbNum, 1, nNum)
		    if(nData == 0)then
			    break
		    end
	    end

        return tbNum
    end

    local batchNode = Layout:create() 
    local function animationEnd()
        local function delayToEnd()
              if userAnimation then
                userAnimation:resume()
                userAnimation = nil
            end
            fadeOut(batchNode, func)
        end

        g_Timer:pushTimer(0.5, delayToEnd)
    end
         
    local function fadeInCallBack()
        local nDif = nEnd - nBegin
        local nMaxCount  = 30
        local nIncrease = math.floor(nDif/nMaxCount)
        if nDif < nMaxCount then
            nIncrease = 1
        end
       
        local function showIncreaseNumAnimation()
            batchNode:removeAllChildren()
            nBegin = nBegin + nIncrease
            if nBegin > nEnd then nBegin = nEnd end

            local tbNum = calcDataNum(nBegin)
            local nMax = #tbNum
            local nWidth = 0
            for i=1, nMax do
                local imageNum = ImageView:create()
                imageNum:loadTexture(string.format("TeamStrengthAnimation%d.png", tbNum[i]), 1)
                imageNum:setPositionXY(nWidth,0)
                batchNode:addChild(imageNum)
                nWidth = nWidth + imageNum:getSize().width - 10
            end
     
            batchNode:setPositionXY(- nWidth/2, -10)

            if nBegin >= nEnd then animationEnd() return true end    
        end
        g_Timer:pushLoopTimer(0, showIncreaseNumAnimation)
    end

    --支持递减
    local function fadeInDecreaseCallBack()
        local nDif = nEnd - nBegin
        local nMaxCount  = 30
        local nIncrease = math.floor(nDif/nMaxCount)
        if nDif > nMaxCount then
            nIncrease = -1
        end
       
        local function showIncreaseNumAnimation()
            batchNode:removeAllChildren()
            nBegin = nBegin + nIncrease
            if nBegin <= nEnd then nBegin = nEnd end

            local tbNum = calcDataNum(nBegin)
            local nMax = #tbNum
            local nWidth = 0
            for i=1, nMax do
                local imageNum = ImageView:create()
                imageNum:loadTexture(string.format("TeamStrengthAnimation%d.png", tbNum[i]), 1)
                imageNum:setPositionXY(nWidth,0)
                batchNode:addChild(imageNum)
                nWidth = nWidth + imageNum:getSize().width - 10
            end
     
            batchNode:setPositionXY(- nWidth/2, -10)

            if nBegin <= nEnd then animationEnd() return true end    
        end
        g_Timer:pushLoopTimer(0, showIncreaseNumAnimation)
    end

    local function showWordsAnimation()
        local fucFadeIn = fadeInCallBack
        if nBegin > nEnd then
            fucFadeIn = fadeInDecreaseCallBack
        end
        userAnimation:pause()
        local tbNum = calcDataNum(nBegin)
        local nMax = #tbNum
        local nWidth = 0
        for i=1, nMax do
            local imageNum = ImageView:create()
            imageNum:loadTexture(string.format("TeamStrengthAnimation%d.png", tbNum[i]), 1)
            imageNum:setPositionX(nWidth)
            batchNode:addChild(imageNum)
  
            fadeIn(imageNum, fucFadeIn )
            nWidth = nWidth + imageNum:getContentSize().width - 10
            fucFadeIn = nil
        end
     
        batchNode:setPositionXY(- nWidth/2, -10)
    end
                   
    local tbFrameCallBack = {
	    ShowTeamStrength = showWordsAnimation            
    }
    
    armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("TeamStrengthAnimation", tbFrameCallBack,nil, 2, true)	
    armature:addChild(batchNode,100)
    armature:setPositionXY(640, 90)
    g_WndMgr.rootWndMgrLayer:addChild(armature)
    userAnimation:playWithIndex(0)
end