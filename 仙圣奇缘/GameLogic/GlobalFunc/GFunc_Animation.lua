--------------------------------------------------------------------------------------
-- 文件名:	g_function.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	王家麒
-- 日  期:	2013-3-4 9:37
-- 版  本:	1.0
-- 描  述:	专门用来存放动画相关的公用函数
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--创建多个帧回调的Json动画
function g_CreateCoCosAnimationWithCallBacks(strAniName, tbFrameCallBack, funcEndCallBack, nPathType, bIgnore, bIsInBattle, bIsLoop)
	-- create animation
	local strPathFile = nil
	if nPathType == 1 then
		strPathFile = getEffectSkillJson(strAniName)
	elseif nPathType == 2 then
		strPathFile = getCocoAnimationJson(strAniName)
	elseif nPathType == 3 then
		--
	elseif nPathType == 4 then
		--
	elseif nPathType == 5 then
		strPathFile = getCocoAnimationJson(strAniName)
	end
    if not bIgnore then
	    g_tbCocoAnimationResouce[strPathFile] = true
	end

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(strPathFile)
	local armature = CCArmature:create(strAniName)
	--cclog("g_CreateCoCosAnimationWithCallBacks CCArmature:create----->"..strAniName)

	if(not armature)then
		cclog("g_CreateCoCosAnimationWithCallBacks:g_CreateCoCosAnimationWithCallBacks nil"..strAniName)
		strAniName()
		return nil
	end

	local userAnimation = armature:getAnimation()
    --local tbSoundRef
    if not tbSoundRef then
        tbSoundRef = {}
    end 
	local function AnimationFrameCallBack(armatureBack, strFrameEvent,  nOriginFrameIndex, nCurrentFrameIndex)
		local strPrefix = string.sub(strFrameEvent,1,10)
		if strPrefix == "PlaySound_" then
			local nStrLen = string.len(strFrameEvent)
			--这里未来要判断平台
			local strSound = "Sound/"..string.sub(strFrameEvent,11,nStrLen)..".mp3"
            tbSoundRef[strSound] = tbSoundRef[strSound] and tbSoundRef[strSound] + 1 or 1
            if tbSoundRef[strSound] <= 5 then
			    if bIsInBattle then
				    g_playSoundEffectBattle(strSound)
			    else
				    g_playSoundEffect(strSound)
			    end             
            end
            local function refRelease()
                tbSoundRef[strSound] = tbSoundRef[strSound] -1
            end  
            g_Timer:pushLimtCountTimer(1, 0.01, refRelease)
		else
			if( tbFrameCallBack and tbFrameCallBack[strFrameEvent])then
				tbFrameCallBack[strFrameEvent](armature,userAnimation)
			end
		end
	end
	userAnimation:setFrameEventCallFunc(AnimationFrameCallBack)
	
	local function AnimationEndCallBack(armatureBack,movementType,movementID)
		if(movementType == ccs.MovementEventType.COMPLETE)then --完成
			if(funcEndCallBack)then
				funcEndCallBack()
			end
			if not bIsLoop then
				armatureBack:removeFromParentAndCleanup(true)
			end
		end
	end
	userAnimation:setMovementEventCallFunc(AnimationEndCallBack)
	
	return armature,userAnimation
end

--翻转对象
function g_RevertObject(object)
	local camera = object:getCamera()
	local x,y,z = 0,0,0
	x,y,z = camera:getEyeXYZ(x,y,z)
	camera:setEyeXYZ(x,y,-z)
end

---------------------左右按钮闪烁--------------------------------------------
function LandRActionButton(mSprite, Delaytime, nStartScaleX, nStartScaleY, bIsNotFade)
	Delaytime = Delaytime or 0.1
	local nScaleX = mSprite:getScaleX()
	local nScaleY = mSprite:getScaleY()
	if nStartScaleX then
		nScaleX = nStartScaleX or 1
	end
	if nStartScaleY then
		nScaleY = nStartScaleY or 1
	end
	mSprite:setScaleX(nScaleX)
	mSprite:setScaleY(nScaleY)
	local actionScaleBy = CCScaleTo:create(0.8, nScaleX - 0.1, nScaleY - 0.1)  
	local actionScaleTo = CCScaleTo:create(0.8, nScaleX, nScaleY)    
	 
	local arrAct = CCArray:create()
	arrAct:addObject(actionScaleBy)
	arrAct:addObject(actionScaleTo)
	arrAct:addObject(CCDelayTime:create(0.3))
	local mActionSeqfa1= CCSequence:create(arrAct)  

	local nFadeValue = 120
	if bIsNotFade then
		nFadeValue = 255
	end
	local actionFadeTo = CCFadeTo:create(0.8, nFadeValue) 
	local actionFadeBack = CCFadeTo:create(0.8,255) 
	local arrAct = CCArray:create()
	--arrAct:addObject(CCDelayTime:create(Delaytime))
	arrAct:addObject(actionFadeTo)
	arrAct:addObject(actionFadeBack)
	arrAct:addObject(CCDelayTime:create(0.3))
	local mActionSeqfa2= CCSequence:create(arrAct)  
	local mActionSpa = CCSpawn:createWithTwoActions( mActionSeqfa1 ,mActionSeqfa2 )
	local action = CCRepeatForever:create(mActionSpa)
	mSprite:runAction(action)
end

--上下来回浮动动画
function g_CreateUpAndDownAnimation(widget, fTime, nRange, nReverseFlag)
	if not widget then return end
	local fTime = fTime or 0.75
	local nRange = nRange or 10
	local nReverseFlag = nReverseFlag or 1
	nRange = nRange * nReverseFlag
	
	local arryAct  = CCArray:create()
	local actionMoveBy1 = CCMoveBy:create(fTime, CCPointMake(0,-nRange/2))
	local actionMoveBy2 = CCMoveBy:create(fTime, CCPointMake(0,nRange/2))
	local actionMoveBy3 = CCMoveBy:create(fTime, CCPointMake(0,nRange/2))
	local actionMoveBy4 = CCMoveBy:create(fTime, CCPointMake(0,-nRange/2))
	arryAct:addObject(actionMoveBy1)
	arryAct:addObject(actionMoveBy2)
	arryAct:addObject(actionMoveBy3)
	arryAct:addObject(actionMoveBy4)
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	widget:runAction(actionForever)
end

-- 数值增加动画
function g_CreateIncreaseAnimation(fShowSecs, nBeginValue, nEndValue, callback)
	local nChangeNum = nBeginValue
	local nChange = (nEndValue - nBeginValue)/(fShowSecs*(1/g_Cfg.fFps))
	local function DynamicLabel(fShowSecs, bTimerIsEnd)
		nChangeNum = nChangeNum + nChange
		local nCurNum = bTimerIsEnd and nEndValue or nChangeNum
		callback(nCurNum, bTimerIsEnd)
	end
	
	return g_Timer:pushLimtCountTimer(math.ceil((1/g_Cfg.fFps)*fShowSecs), 1/(1/g_Cfg.fFps), DynamicLabel)
end

-- 数值增加动画
function g_CreatePropDynamic(widget, fShowSecs, nBeginValue, nEndValue, szFormat, ccsBeginColor, ccsEndColor)
	local ccsBeginColor = ccsBeginColor or g_getColor(ccs.COLOR.LIME_GREEN)
	local ccsEndColor = ccsEndColor or g_getColor(ccs.COLOR.WHITE)
	widget:setColor(ccsBeginColor)
	
	local nTimerId = g_CreateIncreaseAnimation(fShowSecs, nBeginValue, nEndValue, function(nCurNum, bTimerIsEnd)
		widget:setText(string.format(szFormat, nCurNum))
		if bTimerIsEnd then
			local actionTintTo = CCTintTo:create(0.4, ccsEndColor.r, ccsEndColor.g, ccsEndColor.b)
			widget:runAction(actionTintTo)
		end
	end)
	return nTimerId
end

--伙伴头像等级淡入淡出动画
function g_CreateLevelFadeInOutAction(widgetLevel, widgetEvoluteLevel)
	if not widgetLevel then return end
	if not widgetEvoluteLevel then return end
	widgetLevel:setOpacity(0)
	widgetEvoluteLevel:setOpacity(0)

	local arryAct_Level  = CCArray:create()
	local actionFateTo_Level1 = CCFadeTo:create(0.4, 255)
	local actionFateTo_Level2 = CCFadeTo:create(0.4, 0)
	arryAct_Level:addObject(actionFateTo_Level1)
	arryAct_Level:addObject(CCDelayTime:create(1))
	arryAct_Level:addObject(actionFateTo_Level2)
	arryAct_Level:addObject(CCDelayTime:create(1.8))
	local action_Level = CCSequence:create(arryAct_Level)
	local actionForever_Level = CCRepeatForever:create(action_Level)
	
	local arryAct_EvoluteLevel  = CCArray:create()
	local actionFateTo_EvoluteLevel1 = CCFadeTo:create(0.4, 255)
	local actionFateTo_EvoluteLevel2 = CCFadeTo:create(0.4, 0)
	arryAct_EvoluteLevel:addObject(CCDelayTime:create(1.8))
	arryAct_EvoluteLevel:addObject(actionFateTo_EvoluteLevel1)
	arryAct_EvoluteLevel:addObject(CCDelayTime:create(1))
	arryAct_EvoluteLevel:addObject(actionFateTo_EvoluteLevel2)
	local action_EvoluteLevel = CCSequence:create(arryAct_EvoluteLevel)
	local actionForever_EvoluteLevel = CCRepeatForever:create(action_EvoluteLevel)
	
	widgetLevel:runAction(actionForever_Level)
	widgetEvoluteLevel:runAction(actionForever_EvoluteLevel)
end

--淡入淡出动画
function g_CreateFadeInOutAction(widget, fDelayTime, nFadeOutValue, fFadeTime)
	if not widget then return end
	widget:stopAllActions()
	widget:setOpacity(0)
	local fDelayTime = fDelayTime or 1
	local nFadeOutValue = nFadeOutValue or 120
	local fFadeTime = fFadeTime or 0.75

	local arryAct  = CCArray:create()
	local actionFateTo = CCFadeTo:create(fFadeTime, 255)
	arryAct:addObject(actionFateTo)
	local function repeatFadeInOutAction()
		local arryAct  = CCArray:create()
		local actionFadeOut = CCFadeTo:create(fFadeTime, nFadeOutValue)
		local actionFadeIn = CCFadeTo:create(fFadeTime, 255)
		arryAct:addObject(actionFadeOut)
		arryAct:addObject(actionFadeIn)
		arryAct:addObject(CCDelayTime:create(0.3))
		local action = CCSequence:create(arryAct)
		local actionForever = CCRepeatForever:create(action)
		widget:runAction(actionForever)
	end
	arryAct:addObject(CCCallFuncN:create(repeatFadeInOutAction))
	local action = CCSequence:create(arryAct)
	widget:runAction(action)
end

--放大缩小动画带停顿
function g_CreateScaleInOutActionWithPause(widget, fTime, fScaleX, fScaleY)
	local fTime = fTime or 1.8
	local fScaleX = fScaleX or 0.85
	local fScaleY = fScaleY or 0.85
	if not widget then return end
	
	local arrAct = CCArray:create()
	local actionScaleTo = CCScaleTo:create(fTime,fScaleX, fScaleY) 
	local actionScaleToEasing = CCEaseOut:create(actionScaleTo, 1.8)
	local actionScaleBack = CCScaleTo:create(0.2, 1) 
	arrAct:addObject(actionScaleToEasing)
	arrAct:addObject(actionScaleBack)
	local actionWidget= CCSequence:create(arrAct)
	local action = CCRepeatForever:create(actionWidget)
	widget:runAction(action)
end

--放大缩小动画不带停顿
function g_CreateScaleInOutAction(widget, fTime, fScaleX, fScaleY, fScaleEnd)
	local fTime = fTime or 0.85
	local fScaleX = fScaleX or 1.1
	local fScaleY = fScaleY or 1.1
	local fScaleEnd = fScaleEnd or 0.95
	if not widget then return end
	
	widget:stopAllActions()
	
	local arrAct = CCArray:create()
	local actionScaleTo = CCScaleTo:create(fTime,fScaleX, fScaleY) 
	local actionScaleBack = CCScaleTo:create(fTime, fScaleEnd, fScaleEnd) 
	arrAct:addObject(actionScaleTo)
	arrAct:addObject(actionScaleBack)
	local actionWidget= CCSequence:create(arrAct)
	local action = CCRepeatForever:create(actionWidget)
	widget:runAction(action)
end

-----飘叶
--例子 g_CreateLeaf(self.layerZhenFa,ccp(400,500),ccp(800,700),5,5,-10,10,4)   --父节点，起始位置，结束位置，播放次数,间隔时间, 移动的时间，旋转时间，旋转角度1，反转角度2
function  g_CreateLeaf(parent,BeginPos,EndPos,RepeatTimes,fInterval,ftime,rTime,fAngle_1,fAngle_2,leafType,nLayer)
	parent:removeAllNodes()
	
	local RepeatTimes = RepeatTimes or 1
	local fInterval = fInterval or 5
	
	local function AnimpushLoopTimer()
		g_setLeaf(parent,BeginPos,EndPos,RepeatTimes,ftime,rTime,fAngle_1,fAngle_2,leafType,nLayer)
		if (not parent:isVisible())then
			return true
		end
    end 
	if parent and (parent:isVisible())then
		if RepeatTimes == -1 then
			local nTimerID = g_Timer:pushLoopTimer(fInterval, AnimpushLoopTimer)
			return nTimerID
		else
			local nTimerID = g_Timer:pushLimtCountTimer(RepeatTimes, fInterval, AnimpushLoopTimer)
			return nTimerID
		end
	end
	
end

function  g_setLeaf(parent,BeginPos,EndPos,RepeatTimes,ftime,rTime,fAngle_1,fAngle_2,leafType,nLayer)
	if not parent then
		parent = g_WndMgr.rootWndMgrLayer
	end
	if parent and parent:isExsit() then
		local BeginPos = BeginPos or ccp(450, 500)
		local leafType = leafType or 1
		local nLayer = nLayer or 1000
		
		local spriteLeaf1 = CCSprite:create(getCocoAnimationImg("Image_TaoHua"..leafType))
		spriteLeaf1:setRotation(30)
		spriteLeaf1:setAnchorPoint(ccp(0.5, 3))
		spriteLeaf1:setPosition(BeginPos)
		parent:addNode(spriteLeaf1,nLayer,leafType)
		g_playLeafAnim(spriteLeaf1,EndPos,ftime,rTime,fAngle_1,fAngle_2,RepeatTimes)
	end
	
end

function  g_playLeafAnim(spriteLeaf,tbPos,fromtime,roTime,fAngle1,fAngle2,RepeatTimes)
	local tbPos = tbPos or ccp(640,360)  
	local fromtime = fromtime or 20  
	local roTime = roTime or 2.5 
	local fAngle1 = fAngle1 or -80
	local fAngle2 = fAngle2 or 80 
	local RepeatTimes = RepeatTimes or 3
	
	function  g_resetLeafPos(sender)
		sender:removeFromParentAndCleanup(true)
	end
	math.randomseed(os.time())  
	local iRandPosX =  math.random(800);
	local iRandPosY =  math.random(250);
	
	local moveTo = CCMoveTo:create(fromtime, ccp(tbPos.x - iRandPosX,tbPos.y - iRandPosY))

	local arrAct = CCArray:create()
	arrAct:addObject(moveTo)		
	arrAct:addObject(CCCallFuncN:create(g_resetLeafPos))
	local putdown = CCSequence:create(arrAct)

	local rotaBy1 = CCRotateBy:create(roTime, fAngle1);
	local rotaBy2 = CCRotateBy:create(roTime, fAngle2);

	spriteLeaf:setVertexZ(60)

	local orbit = CCOrbitCamera:create(8, 1, 0, 0, 360, 45, 0)
	local fz3d = CCRepeat:create(orbit, INT_MAX)

	local ease1 = CCEaseInOut:create(rotaBy1, 3)
	local ease2 = CCEaseInOut:create(rotaBy2, 3)
	
	local seq2 = CCSequence:createWithTwoActions(ease1, ease2)
	local baidong = CCRepeat:create(seq2, INT_MAX)
	
	local arrActSpawn = CCArray:create()
	arrActSpawn:addObject(putdown)		
	arrActSpawn:addObject(baidong)	
	arrActSpawn:addObject(fz3d)	
	local actionSpawn = CCSpawn:create(arrActSpawn)
	spriteLeaf:runAction(actionSpawn)
end

--循环飘动动画
function g_CreateCircularMove(widget, ccpStartPos, ccpEndPos, fMoveTime)
	if not widget then return end
	local ccpStartPos = ccpStartPos or CCPointMake(-640,360)
	local ccpEndPos = ccpEndPos or CCPointMake(640,360)
	local fMoveTime = fMoveTime or 40
	
	widget:setPosition(ccpStartPos)
	local arryAct  = CCArray:create()
	local actionMoveTo = CCMoveTo:create(fMoveTime, ccpEndPos)
	arryAct:addObject(actionMoveTo)
	local function resetPosition()
		widget:setPosition(ccpStartPos)
	end
	arryAct:addObject(CCCallFuncN:create(resetPosition))
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	widget:runAction(actionForever)
end

local function CreateSpritebyFrameName(FileName)
	 local ccspriteCache = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(FileName)
    if not ccspriteCache then
        local sprite = CCSprite:create(FileName)
        return sprite
    else
        local sprite = CCSprite:createWithSpriteFrameName(FileName)
        return sprite
    end
end

--布阵界面动画
function g_InitBuZhenBackgroundAnimation(parent)
	parent:removeAllNodes()
	
	local blendFuncMinusDstColor = ccBlendFunc()
	blendFuncMinusDstColor.src = GL_ONE_MINUS_DST_COLOR
	blendFuncMinusDstColor.dst = GL_ONE
	local blendFuncDstColor = ccBlendFunc()
	blendFuncDstColor.src = GL_DST_COLOR
	blendFuncDstColor.dst = GL_ONE
	local blendFuncSrcAlpha = ccBlendFunc()
	blendFuncSrcAlpha.src = GL_SRC_ALPHA
	blendFuncSrcAlpha.dst = GL_ONE
	
	local Buzhen_Light_Environment = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_Environment"))
	local Buzhen_Light_MoonL = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_MoonL"))
	local Buzhen_Light_MoonM = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_MoonM"))
	local Buzhen_Light_MoonR = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_MoonR"))
	local Buzhen_Light_DingL = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_Ding"))
	local Buzhen_Light_DingR = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_Ding"))
	local Buzhen_Light_FrontL = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_FrontL"))
	local Buzhen_Light_FrontR = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_FrontR"))
	local Buzhen_Light_Center1 = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_Center1"))
	local Buzhen_Light_Center2 = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Light_Center2"))
	local Buzhen_Cloud1 = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Cloud1"))
	local Buzhen_Cloud2 = CreateSpritebyFrameName(getBuZhenImg("Buzhen_Cloud2"))
	
	Buzhen_Light_Environment:setPosition(ccp(-118,169))
	Buzhen_Light_MoonL:setPosition(ccp(-145,125))
	Buzhen_Light_MoonM:setPosition(ccp(-75,150))
	Buzhen_Light_MoonR:setPosition(ccp(-35,149))
	Buzhen_Light_DingL:setPosition(ccp(-535,30))
	Buzhen_Light_DingR:setPosition(ccp(535,30))
	Buzhen_Light_FrontL:setPosition(ccp(-508,35))
	Buzhen_Light_FrontR:setPosition(ccp(493,70))
	Buzhen_Light_Center1:setPosition(ccp(-25,75))
	Buzhen_Light_Center2:setPosition(ccp(95,85))
	Buzhen_Cloud1:setPosition(ccp(-640, 250))
	Buzhen_Cloud2:setPosition(ccp(-640, 250))
	
	Buzhen_Light_Environment:setScale(2)
	Buzhen_Light_MoonL:setScale(2)
	Buzhen_Light_MoonM:setScale(2)
	Buzhen_Light_MoonR:setScale(2)
	Buzhen_Light_DingL:setScale(2)
	Buzhen_Light_DingR:setScale(2)
	Buzhen_Light_FrontL:setScale(2)
	Buzhen_Light_FrontR:setScale(2)
	Buzhen_Light_Center1:setScale(2)
	Buzhen_Light_Center2:setScale(2)
	Buzhen_Cloud1:setScale(2)
	Buzhen_Cloud2:setScale(2)
	
	Buzhen_Light_Environment:setBlendFunc(blendFuncDstColor)
	Buzhen_Light_MoonL:setBlendFunc(blendFuncMinusDstColor)
	Buzhen_Light_MoonM:setBlendFunc(blendFuncMinusDstColor)
	Buzhen_Light_MoonR:setBlendFunc(blendFuncMinusDstColor)
	--Buzhen_Light_DingL:setBlendFunc(blendFuncDstColor)
	--Buzhen_Light_DingR:setBlendFunc(blendFuncDstColor)
	--Buzhen_Light_FrontL:setBlendFunc(blendFuncDstColor)
	--Buzhen_Light_FrontR:setBlendFunc(blendFuncDstColor)
	--Buzhen_Light_Center1:setBlendFunc(blendFuncDstColor)
	--Buzhen_Light_Center2:setBlendFunc(blendFuncDstColor)
	Buzhen_Cloud1:setBlendFunc(blendFuncMinusDstColor)
	Buzhen_Cloud2:setBlendFunc(blendFuncMinusDstColor)
	
	parent:addNode(Buzhen_Light_Environment, 3)
	parent:addNode(Buzhen_Light_MoonL, 8)
	parent:addNode(Buzhen_Light_MoonM, 8)
	parent:addNode(Buzhen_Light_MoonR, 8)
	parent:addNode(Buzhen_Light_DingL, 7)
	parent:addNode(Buzhen_Light_DingR, 7)
	parent:addNode(Buzhen_Light_FrontL, 6)
	parent:addNode(Buzhen_Light_FrontR, 6)
	parent:addNode(Buzhen_Light_Center1, 5)
	parent:addNode(Buzhen_Light_Center2, 5)
	parent:addNode(Buzhen_Cloud1, -2)
	parent:addNode(Buzhen_Cloud2, -3)

	g_CreateFadeInOutAction(Buzhen_Light_Environment,0,0.8)
	g_CreateFadeInOutAction(Buzhen_Light_MoonL, 0)
	g_CreateFadeInOutAction(Buzhen_Light_MoonM, 0.33)
	g_CreateFadeInOutAction(Buzhen_Light_MoonR, 0.66)
	g_CreateFadeInOutAction(Buzhen_Light_DingL, 0,150,0.6)
	g_CreateFadeInOutAction(Buzhen_Light_DingR, 0.3,150,0.6)
	g_CreateFadeInOutAction(Buzhen_Light_FrontL, 0,150,0.6)
	g_CreateFadeInOutAction(Buzhen_Light_FrontR, 0.3,150,0.6)
	g_CreateFadeInOutAction(Buzhen_Light_Center1, 0.3,150,0.6)
	g_CreateFadeInOutAction(Buzhen_Light_Center2, 0.6,150,0.6)
	g_CreateCircularMove(Buzhen_Cloud1, ccp(-640, 250), ccp(640, 250), 15)
	g_CreateCircularMove(Buzhen_Cloud2, ccp(-340, 250), ccp(980, 250), 15)
end

function g_SetBlendFuncSprite(ccSprite, nType)
	if not ccSprite then return end
	local nType = nType or 1
	
	--正常
	if nType == 0 then
		local blendFuncNormal = ccBlendFunc()
		blendFuncNormal.src = GL_ONE
		blendFuncNormal.dst = GL_SRC_ALPHA
		ccSprite:setBlendFunc(blendFuncNormal)
	--滤色
	elseif nType == 1 then
		local blendFuncMinusDstColor = ccBlendFunc()
		blendFuncMinusDstColor.src = GL_ONE_MINUS_DST_COLOR
		blendFuncMinusDstColor.dst = GL_ONE
		ccSprite:setBlendFunc(blendFuncMinusDstColor)
	--叠加
	elseif nType == 2 then
		local blendFuncDstColor = ccBlendFunc()
		blendFuncDstColor.src = GL_DST_COLOR
		blendFuncDstColor.dst = GL_ONE
		ccSprite:setBlendFunc(blendFuncDstColor)
	--增强1
	elseif nType == 3 then
		local blendFuncSrcAlpha = ccBlendFunc()
		blendFuncSrcAlpha.src = GL_SRC_ALPHA
		blendFuncSrcAlpha.dst = GL_ONE
		ccSprite:setBlendFunc(blendFuncSrcAlpha)
	--增强2
	elseif nType == 4 then
		local blendFuncOne = ccBlendFunc()
		blendFuncOne.src = GL_ONE
		blendFuncOne.dst = GL_ONE
		ccSprite:setBlendFunc(blendFuncOne)
	end
end

function g_SetBlendFuncWidget(widget, nType)
	if not widget then return end
	local ccSprite = tolua.cast(widget:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite, nType)
end

--拾取 动画 
function fateSucceedAction(fate,pointX,pointY,funcCallBack,speed)
	local function actionFinish()
		fate:removeFromParentAndCleanup(true)
	end
	
	if not pointX then pointX = 67 end
	if not pointY then pointY = 656 end
	
	speed = speed or 1000
	local startPiont = fate:getPosition()
    local px = startPiont.x - pointX
    local py = startPiont.y - pointY
    local xy = px*px + py*py
    local mtime = math.sqrt (xy) / speed 
    -------------actionSequence1---------FadeOut------------------
	local actionFadeOut = CCFadeOut:create(mtime / 4)
	local arrAct1 = CCArray:create()
	arrAct1:addObject(CCDelayTime:create(mtime*3 / 4))
	arrAct1:addObject(actionFadeOut)
	if(funcCallBack)then
		arrAct1:addObject(CCCallFuncN:create(funcCallBack))
	end
	arrAct1:addObject(CCCallFuncN:create(actionFinish))
	local actionSequence1 = CCSequence:create(arrAct1)
	-------------actionSequence2---------CCScaleTo------------------
	local actionScaleTo = CCScaleTo:create(mtime*3 / 4,0.1)
	local arrAct2 = CCArray:create()
	arrAct2:addObject(CCDelayTime:create(mtime / 4))
	arrAct2:addObject(actionScaleTo)
	local actionSequence2 = CCSequence:create(arrAct2)
	-------------actionSequence3------MoveTo-------------------
	local bezier = ccBezierConfig()
    bezier.controlPoint_1 = ccp(100,-50)
    bezier.controlPoint_2 = ccp(pointX + 216,pointY + 288 )
    bezier.endPosition = ccp(pointX, pointY)
    local bezierTo1 = CCBezierTo:create(mtime, bezier)
	local actionMoveToEasing = CCEaseSineOut:create(bezierTo1)
	
	-- local moveto = CCMoveTo:create(mtime,ccp(pointX,pointY))
    -- local actionMoveToEasing = CCEaseSineOut:create(moveto)

	local arrActAwp = CCArray:create()
	arrActAwp:addObject(actionSequence1)
	arrActAwp:addObject(actionSequence2)
	arrActAwp:addObject(actionMoveToEasing)
	local mSpawn = CCSpawn:create(arrActAwp)
	
	fate:runAction(mSpawn)
end

--出售
function fateFailureAction(fateBack,fate,funcCallBack)
	local function actionFinish()
		if fateBack then 
			fateBack:removeFromParentAndCleanup(true)
			fateBack = nil
		end
	end 
	
	-------------actionSequence1---------FadeOut------------------
	local actionFadeOut = CCFadeOut:create(0.45)
	local arrAct1 = CCArray:create()
	arrAct1:addObject(CCDelayTime:create(0.4))
	arrAct1:addObject(actionFadeOut)
	if(funcCallBack)then
		arrAct1:addObject(CCCallFuncN:create(funcCallBack))
	end
	arrAct1:addObject(CCCallFuncN:create(actionFinish))
	local actionSequence1 = CCSequence:create(arrAct1)
	-------------actionSequence2---------CCScaleBy------------------
	local actionScaleBy = CCScaleBy:create(0.05,1.4) 
	local actionScaleBack = CCScaleBy:create(0.8,0.7) 
	local arrAct = CCArray:create()
	arrAct:addObject(actionScaleBy)
	arrAct:addObject(actionScaleBack)
	local actionSequence2 = CCSequence:create(arrAct)

	local mSpawn = CCSpawn:createWithTwoActions(actionSequence1,actionSequence2)
	fate:runAction(mSpawn)
end

---猎命 动画 渐隐消失
function fateFailureOutAction(Image_HuntFateItem, funcCallBack)
	local function actionFinish()
		Image_HuntFateItem:setVisible(false)
		if(funcCallBack)then
			funcCallBack()
		end
	end
	
	local arrAct_HuntFateItem = CCArray:create()
	local actionFadeTo_HuntFateItem = CCFadeTo:create(0.5, 0)
	arrAct_HuntFateItem:addObject(actionFadeTo_HuntFateItem)
	arrAct_HuntFateItem:addObject(CCCallFuncN:create(actionFinish))
	local action_HuntFateItem = CCSequence:create(arrAct_HuntFateItem)
	Image_HuntFateItem:runAction(action_HuntFateItem)

end

--召唤，猎妖出现的光圈 动画
function g_AnimationHaloAction(layout, fScale, funcEndCallBack)
    if layout == nil then return end
	local fScale = fScale or 1
	local tbSpriteName = {
		"UpgradeEvent_Light2_1",
		"UpgradeEvent_Light2_2",
		"Summon_Explode1",
		"Summon_Explode1",
		"Summon_CrossLightBig",
		"Summon_CrossLightBig",
		"Summon_CircleOutSideBig1",
		"Summon_CircleOutSideBig1",
		"Summon_CircleOutSideSmall1"
	}

	local action_RayInSide = {
		CCScaleTo:create(0.35,2.28*fScale),CCScaleTo:create(0.35,0)
	}
	local action_RayOutSide = {
		CCScaleTo:create(0.35,2.28*fScale),CCScaleTo:create(0.4,0)
	}
	local action_ExplodeOutSide = {
		CCScaleTo:create(0.35,0.8*fScale),CCScaleTo:create(0.4,0.42*fScale),
		CCFadeTo:create(0.2,0)
	}
	local action_ExplodeInSide = {
		CCScaleTo:create(0.35,0.67*fScale),CCScaleTo:create(0.4,0.35*fScale),
		CCFadeTo:create(0.2,0)
	}
	local action_CrossLightHorizontal = {
		CCScaleTo:create(0.35,2.57*fScale, 0.72*fScale),CCScaleTo:create(0.4, 0)
	}
	local action_CrossLightVertical = {
		CCScaleTo:create(0.35,2.57,0.72*fScale),CCScaleTo:create(0.4,0)
	}
	local action_CircleInSideSmall = {
		CCScaleTo:create(0.35,0.52*fScale),CCScaleTo:create(0.4,0.27*fScale),
		CCFadeTo:create(0.2,0)
	}
	local action_CircleOutSideBig = {
		CCScaleTo:create(0.35,0.73*fScale),CCScaleTo:create(0.4,0.38*fScale),
		CCFadeTo:create(0.2,0)
	}

	local function executeEndAction()
		if funcEndCallBack then
			funcEndCallBack()
		end
	end
	local function endActionFunc()
		layout:removeAllNodes()
	end	
	local action_CircleOutSideSmall = {
		CCScaleTo:create(0.35,0.68*fScale),
		CCCallFuncN:create(executeEndAction),
		CCScaleTo:create(0.4,0.35*fScale),
		CCFadeTo:create(0.2,0),
		CCCallFuncN:create(endActionFunc),
	}
	local tbAction = {
		action_RayInSide,
		action_RayOutSide,
		action_ExplodeOutSide,
		action_ExplodeInSide,
		action_CrossLightHorizontal,
		action_CrossLightVertical,
		action_CircleInSideSmall,
		action_CircleOutSideBig,
		action_CircleOutSideSmall
	}
	local spriteSlot = {}
	local blendNum = 3
	local z = 81
	for key,value in pairs(tbSpriteName) do
		local sprite = CCSprite:create(getCocoAnimationImg(value))
		if key == 6 then 
			sprite:setRotation(90)
			blendNum = 1
		end
		--增加效果 滤色 叠加 增强1 等
		g_SetBlendFuncSprite(sprite,blendNum)
		sprite:setPosition(ccp(0,0))
		sprite:setScale(0)
		layout:addNode(sprite,z)
		z = z + 1
		local action = sequenceAction(tbAction[key])
		sprite:runAction(action)
	end

end

--[[
	--进度条动画 
	--需要注意的是 进度条结束的时候要记得删除定时器
	local param = {
		nBeginPercent,	--开始时的百分比
		nEndPercent=,	--结束时的百分比
		nMaxCount = ,--进度条满级次数,传入增加的等级即可
		fInterval = ,--定时器循环间隔
		
		funcLoadingIntervalCall, 
		funcLoadingFullCall = , --每一条进度条结束时执行函数
		funcLoadingEndCall = , --进度条结束函数 可以在这删除定时器
	}
]]--
function g_loadingBarAnimation(param)
	local nBeginPercent = param.nBeginPercent	--开始时的百分比
	local nEndPercent = param.nEndPercent	--结束时的百分比
	local nMaxCount = param.nMaxCount or 0	--进度条满级次数
	local fInterval = param.fInterval or 0	--Loop定时器执行间隔
	local nCount = 0
	local nCurPercent = nBeginPercent
	
	local function funcLoopCallBack()
		nCurPercent = nCurPercent + 14
	
		if nCount < nMaxCount then
			if nCurPercent >= 100 then
				nCurPercent = 0
				nCount = nCount + 1
				if param.funcLoadingFullCall then
					param.funcLoadingFullCall(nCount)
				end
			end
		else
			if nCurPercent >= nEndPercent then
				nCurPercent = nEndPercent
				if param.funcLoadingEndCall then
					param.funcLoadingEndCall()
				end 
			end
		end
		
		if param.funcLoadingIntervalCall then
			-- if nCurPercent > 100 then nCurPercent = 100 end
			param.funcLoadingIntervalCall(nCurPercent)
		end 
	end
	local nTimerID = g_Timer:pushLoopTimer(fInterval, funcLoopCallBack)
	return nTimerID
end

--[[
	循环亮起动画
	@param return nTimerId 定时器ID 在结束的时候要记得清楚
	local param = {
		numAward =, --"有多少个奖励物品 box "--这个不添默认为5 农田抽奖在使用
		executeConst =, --"再停到获得奖励之前 会有一点次数的 循环亮起动画 这个数需是 numAward 的倍数"
		rewardLev =,--"品质等级 动画最终停止的地方"
		totalTime = ,--总时间
		easeTime = ,--缓冲时间
		func = ,--回调函数带 count 每累加到numAward后重置为1 
		endFunc =,--动画结束后的回调函数
	}
	g_AnimationAward(param)
]]

function g_AnimationAward(param)
	local numAward = param.numAward or 5
	local executeConst = param.executeConst or 35
	local rewardLev = param.rewardLev or 1
	local total = executeConst + rewardLev
	local count = 1 --计算执行执行到第几次
	local totalTime = param.totalTime or 3 --总时间
	local easeTime = param.easeTime or 6 --缓冲时间
	local func = param.func
	local endFunc = param.endFunc
	local nTimerId = nil
	nTimerId = g_Timer:pushLimtCountTimer(total,0,function(dt,flag) 	
		local t = totalTime * (total-(count-1))/total
		local t2 = 1/easeTime
		local t3 = totalTime * (total-count)/total
		local actiontiem = math.pow(t,t2) - math.pow(t3,t2)
		local nTimer = g_Timer:getTimerByID(nTimerId)
		nTimer.fInterval = actiontiem--改变计时器的速度
		if func then func( math.floor( (count-1)% numAward ) +1,actiontiem) end
		if flag then 
			if endFunc then endFunc() end
		end
		count = count + 1
	end)
	return nTimerId
end

--[[
	界面展示出现的动画 ，两个界面从中间向两边移动
	local param = {
		object =,
		moveToX =,
		func = ,
	}
]]
function g_AnimationShow(param)
	local object = param.object
	local moveToX = param.moveToX or 270
	local func = param.func
	-- local objectSize = object:getContentSize().width / 2 
	
	local objectPos = object:getPosition()
	local moveTo = CCMoveTo:create(0.3,ccp(objectPos.x + moveToX,objectPos.y))
	local action = sequenceAction({moveTo,CCCallFuncN:create(function() 
		if func then 
			func()
		end
	end)})
	object:runAction(action)
end

function g_AnimationFlyStar(spriteStar, timeFlyDelay, func)
	local timeFlyDelay = timeFlyDelay or 0.2
	local function actionShow(image)
		if image:isVisible() then 
			image:setVisible(false)
		end
		
		local function imageVisible()
			image:setVisible(true)
		end
		local function endFunc()
			g_playSoundEffectBattle("Sound/Battle_Win_StarImpact.mp3")
			if func then 
				func()
			end
		end
		image:setScale(4)
		local scaleToAction = CCScaleTo:create(0.25,1)
		local action = sequenceAction({
			CCDelayTime:create(timeFlyDelay),
			CCCallFuncN:create(imageVisible),
			scaleToAction,
			CCCallFuncN:create(endFunc),
		})
		image:runAction(action)
	end
	
	if not spriteStar then 
		spriteStar = CCSprite:create(getBattleImg("Icon_Star"))
		actionShow(spriteStar)
		return spriteStar
	else
		actionShow(spriteStar)
	end
end
--按钮开启，回调表现
function g_AnimationOpenButton(sprite)
	local actionScaleTo1 = CCScaleTo:create(0.5, 1.2)
	local actionScaleTo2 = CCScaleTo:create(0.5, 1)
	local arryAct  = CCArray:create()
	arryAct:addObject(actionScaleTo1)
	arryAct:addObject(actionScaleTo2)
	
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	sprite:runAction(actionForever)
end

--[[
	@param param = { button = , image = , flag = ,light =  }
技能丹药合成按钮效果	可以合成时 显示为 黄光高亮
]]
function g_AnimationAlert(param)
	local button = param.button
	local image = param.image
	local need = param.need 
	local flag = param.flag
	local light = param.light
	local ccSpriteCheck = tolua.cast(image:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(spriteCheck,4)
	button:stopAllActions()
	if flag and ( need <= g_Hero:getCoins() )--[[铜钱足]]  then
		image:setVisible(true)
		button:loadTextureNormal(getUIImg("Btn_CommonYellow1"))
		button:loadTexturePressed(getUIImg("Btn_CommonYellow1_Press"))
		button:loadTextureDisabled(getUIImg("Btn_CommonYellow1_Disabled"))
		g_CreateFadeInOutAction(image, 0.75, 100, 0.5)
		if light then 
			light:playWithIndex(1)
		end
	else
		image:setVisible(false)
		button:loadTextureNormal(getUIImg("Btn_Common1"))
		button:loadTexturePressed(getUIImg("Btn_Common1_Press"))
		button:loadTextureDisabled(getUIImg("Btn_Common1_Disabled"))
		if light then 
			light:playWithIndex(0)
		end
	end
end

function g_CreateCircularMoveX(widget, nStartPosX, nEndPosX, nPosY, fTotalTime, fNotFadePercent, nShakeNum, nMinAlpha, nMaxAlpha, nOffsetY)
	if not widget then return end
	local nStartPosX = nStartPosX or -640
	local nEndPosX = nEndPosX or 640
	local nPosY = nPosY or 360
	local fTotalTime = fTotalTime or 40
	local nShakeNum = nShakeNum or 0
	local nMaxAlpha = nMaxAlpha or 255
	local nMinAlpha = nMinAlpha or 0
	local nOffsetY = nOffsetY or 0
	
	widget:setOpacity(0)
	widget:setPositionXY(nStartPosX, nPosY)
	local nDistanceX = nEndPosX - nStartPosX
	local fFadeTime = fTotalTime*(1-fNotFadePercent)/2
	local nFadeDistanceX = nDistanceX*(1-fNotFadePercent)/2
	local fStepTime = fTotalTime*fNotFadePercent/(nShakeNum)
	local nStepDistanceX = nDistanceX*fNotFadePercent/nShakeNum

	local arryAct  = CCArray:create()
	local actionMoveBy1 = CCMoveBy:create(fFadeTime, ccp(nFadeDistanceX, 0))
	local actionFade1 = CCFadeTo:create(fFadeTime, nMaxAlpha)
	local actionSpawn1 = CCSpawn:createWithTwoActions(actionMoveBy1, actionFade1)
	local actionMoveTo3 = CCMoveTo:create(fFadeTime, ccp(nEndPosX, nPosY))
	local actionFade3 = CCFadeTo:create(fFadeTime, 0)
	local actionSpawn3 = CCSpawn:createWithTwoActions(actionMoveTo3, actionFade3)
	arryAct:addObject(actionSpawn1)
	local nMoveByY = 0
	local nAlpha = 0
	for nStep = 1, nShakeNum do
		if (nStep-1)%2 == 1 then
			nMoveByY = math.random(0, nOffsetY)
			nAlpha = math.random(nMinAlpha, nMaxAlpha)
			local arryActThree  = CCArray:create()
			local actionMoveByStep = CCMoveBy:create(fStepTime, ccp(nStepDistanceX, nMoveByY))
			local actionFadeStep = CCFadeTo:create(fStepTime, nAlpha)
			arryActThree:addObject(actionMoveByStep)
			arryActThree:addObject(actionFadeStep)
			local actionSpawnStep = CCSpawn:create(arryActThree)
			arryAct:addObject(actionSpawnStep)
		else
			local arryActThree  = CCArray:create()
			local actionMoveByStep = CCMoveBy:create(fStepTime, ccp(nStepDistanceX, -nMoveByY))
			local actionFadeStep = CCFadeTo:create(fStepTime, nMaxAlpha)
			arryActThree:addObject(actionMoveByStep)
			arryActThree:addObject(actionFadeStep)
			local actionSpawnStep = CCSpawn:create(arryActThree)
			arryAct:addObject(actionSpawnStep)
		end
	end
	arryAct:addObject(actionSpawn3)
	local function resetPosition()
		widget:setOpacity(0)
		widget:setPositionXY(nStartPosX, nPosY)
	end
	arryAct:addObject(CCCallFuncN:create(resetPosition))
	arryAct:addObject(CCDelayTime:create(math.random(2,6)))
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	widget:runAction(actionForever)
end

function g_CreateCircularMoveXY(widget, nStartPosX, nStartPosY, nEndPosX, nEndPosY, fTotalTime)
	if not widget or widget:isExsit() == false then return end
	local nStartPosX = nStartPosX or -640
	local nEndPosX = nEndPosX or 640
	local nStartPosY = nStartPosY or 0
	local nEndPosY = nEndPosY or 720
	local fTotalTime = fTotalTime or 40
	
	widget:setPositionXY(nStartPosX, nStartPosY)
	local arryAct  = CCArray:create()
	local actionMoveTo1 = CCMoveTo:create(fTotalTime, ccp(nEndPosX, nEndPosY))
	arryAct:addObject(actionMoveTo1)
	local function resetPosition()
		widget:setPositionXY(nStartPosX, nStartPosY)
	end
	arryAct:addObject(CCCallFuncN:create(resetPosition))
	arryAct:addObject(CCDelayTime:create(math.random(2,6)))
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	widget:runAction(actionForever)
end

function g_CreateCircularSwingMove(widget, nOffsetX, fStepTime, nMinAlpha, nMaxAlpha)
	if (not widget) or (not widget:isExsit()) then return end
	
	local nOffsetX = nOffsetX or 50
	local fStepTime = fStepTime or 5
	local nMinAlpha = nMinAlpha or 0
	local nMaxAlpha = nMaxAlpha or 255
	
	widget:setOpacity(nMinAlpha)
	widget:setPositionX(widget:getPositionX()-nOffsetX)
	local arryAct  = CCArray:create()
	local actionMoveBy1 = CCMoveBy:create(fStepTime, ccp(nOffsetX, 0))
	local actionFade1 = CCFadeTo:create(fStepTime, nMaxAlpha)
	local actionSpawn1 = CCSpawn:createWithTwoActions(actionMoveBy1, actionFade1)
	local actionMoveBy2 = CCMoveBy:create(fStepTime, ccp(nOffsetX, 0))
	local actionFade2 = CCFadeTo:create(fStepTime, nMinAlpha)
	local actionSpawn2 = CCSpawn:createWithTwoActions(actionMoveBy2, actionFade2)
	
	local actionMoveBy3 = CCMoveBy:create(fStepTime, ccp(-nOffsetX, 0))
	local actionFade3 = CCFadeTo:create(fStepTime, nMaxAlpha)
	local actionSpawn3 = CCSpawn:createWithTwoActions(actionMoveBy3, actionFade3)
	local actionMoveBy4 = CCMoveBy:create(fStepTime, ccp(-nOffsetX, 0))
	local actionFade4 = CCFadeTo:create(fStepTime, nMinAlpha)
	local actionSpawn4 = CCSpawn:createWithTwoActions(actionMoveBy4, actionFade4)
	arryAct:addObject(actionSpawn1)
	arryAct:addObject(actionSpawn2)
	arryAct:addObject(actionSpawn3)
	arryAct:addObject(actionSpawn4)
	arryAct:addObject(CCDelayTime:create(math.random(2,6)))
	local action = CCSequence:create(arryAct)
	local actionForever = CCRepeatForever:create(action)
	widget:runAction(actionForever)
end

-- 窗口放大动画
function g_CreateUIAppearAnimation_Scale(childWidget, funcEndCallBack, fMaxScale, fStartScale, fadeWidget)
	if (not childWidget) or (not childWidget:isExsit()) then return end
	
	local fStartScale = fStartScale or 0.2
	local fMaxScale = fMaxScale or 1.2
	
	childWidget:setCascadeOpacityEnabled(true)
	childWidget:setOpacity(0)
	childWidget:setScale(fStartScale)
	
	local arrAct = CCArray:create()
	local action_FadeTo1 = CCFadeTo:create(0.15, 255)
	local action_ScaleTo1 = CCScaleTo:create(0.15, fMaxScale)
	local action_Spwan1 = CCSpawn:createWithTwoActions(action_FadeTo1, action_ScaleTo1)
	local action_SpwanEase1 = CCEaseOut:create(action_Spwan1, 3)
	local action_ScaleTo2 = CCScaleTo:create(0.15, 1)
	arrAct:addObject(action_SpwanEase1)
	arrAct:addObject(action_ScaleTo2)
	local function executeActionEndCall()
		if funcEndCallBack then
			funcEndCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeActionEndCall))
	local actionSequence = CCSequence:create(arrAct)
	childWidget:runAction(actionSequence)
	
	if fadeWidget and fadeWidget:isExsit() then
		local arrAct = CCArray:create()
		local action_FadeTo = CCFadeTo:create(0.15, 120)
		arrAct:addObject(action_FadeTo)
		arrAct:addObject(CCDelayTime:create(0.15))
		local actionSequence = CCSequence:create(arrAct)
		fadeWidget:runAction(actionSequence)
	end
end

-- 窗口缩小动画
function g_CreateUIDisappearAnimation_Scale(childWidget, funcEndCallBack, fMaxScale, fEndScale, fadeWidget)
	if (not childWidget) or (not childWidget:isExsit()) then return end
	
	local fEndScale = fEndScale or 0.2
	local fMaxScale = fMaxScale or 1.2
	
	childWidget:setCascadeOpacityEnabled(true)
	
	local arrAct = CCArray:create()
	local action_ScaleTo1 = CCScaleTo:create(0.15, fMaxScale)
	local action_FadeTo2 = CCFadeTo:create(0.15, 0)
	local action_ScaleTo2 = CCScaleTo:create(0.15, fEndScale)
	local action_Spwan2 = CCSpawn:createWithTwoActions(action_FadeTo2, action_ScaleTo2)
	local action_SpwanEase2 = CCEaseOut:create(action_Spwan2, 2)
	arrAct:addObject(action_ScaleTo1)
	arrAct:addObject(action_SpwanEase2)
	local function executeActionEndCall()
		childWidget:setScale(1)
		if funcEndCallBack then
			funcEndCallBack()
		end
	end
	arrAct:addObject(CCCallFuncN:create(executeActionEndCall))
	local actionSequence = CCSequence:create(arrAct)
	childWidget:runAction(actionSequence)
	
	if fadeWidget and fadeWidget:isExsit() then
		local arrAct = CCArray:create()
		local action_FadeTo = CCFadeTo:create(0.15, 0)
		arrAct:addObject(CCDelayTime:create(0.15))
		arrAct:addObject(action_FadeTo)
		local actionSequence = CCSequence:create(arrAct)
		fadeWidget:runAction(actionSequence)
	end
end
--[[
	公告
]]
--淡出动画
function g_AnimationFadeOut(widget1)
	-- widget1:setVisible(true)
	local function funcFadeOut()
		widget1:setScale(0.6)
		widget1:setVisible(false)
	end
	local arrAct = CCArray:create()
	local actionFadeto = CCFadeTo:create(0.4, 0)
	arrAct:addObject(actionFadeto)
	arrAct:addObject(CCCallFuncN:create(funcFadeOut))
	local action = CCSequence:create(arrAct)
	widget1:runAction(action)

end

--淡入动画 并 有小放大到 1
function g_AnimationFadeTo(widget1)
	widget1:setVisible(true)
	widget1:setOpacity(0)
	widget1:setScale(0.8)
	widget1:setZOrder(INT_MAX)
	local actionScaleTo = CCScaleTo:create(0.2,1)
	local actionFadeto = CCFadeTo:create(0.4,255)
	local spawnAction = CCSpawn:createWithTwoActions(actionFadeto, actionScaleTo)
	widget1:runAction(spawnAction)

end



