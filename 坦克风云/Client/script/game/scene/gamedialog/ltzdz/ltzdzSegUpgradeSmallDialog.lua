ltzdzSegUpgradeSmallDialog=smallDialog:new()

function ltzdzSegUpgradeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzSegUpgradeSmallDialog:showSegUpgradeDialog(lastSeg,lastSmallLv,seg,smallLv,callBack,layerNum)  
    local function addPlist()
        spriteController:addPlist("public/ltzdz/ltzdzSegUpImgs.plist")
        spriteController:addTexture("public/ltzdz/ltzdzSegUpImgs.png")
    end
    G_addResource8888(addPlist)
	local sd=ltzdzSegUpgradeSmallDialog:new()
    sd:initSegUpgradeDialog(lastSeg,lastSmallLv,seg,smallLv,callBack,layerNum)
    return sd
end

function ltzdzSegUpgradeSmallDialog:initSegUpgradeDialog(lastSeg,lastSmallLv,seg,smallLv,callBack,layerNum)
	self.isTouch=true
    self.isUseAmi=true
    self.layerNum=layerNum

    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local upgradeFlag=false
    if lastSeg<seg then
        upgradeFlag=true
    elseif smallLv and lastSmallLv and smallLv>lastSmallLv then
        upgradeFlag=true
    end
    local resultStr,color="",G_ColorWhite
    if upgradeFlag==true then
        resultStr=getlocal("ltzdz_seg_upgrade")
        color=G_ColorYellowPro
    else
        resultStr=getlocal("ltzdz_seg_down")
    end
    local resultLb=GetTTFLabelWrap(resultStr,30,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    resultLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-80)
    resultLb:setColor(color)
    resultLb:setVisible(false)
    self.dialogLayer:addChild(resultLb,3)

    local startScale,targetScale=1.8,1.2
    local segIconSp,segNameStr
    -- ltzdzVoApi:getSegIcon(seg,smallLevel,callback,itype,effcFlag,noEffect)
    if upgradeFlag==true then
        segIconSp=ltzdzVoApi:getSegIcon(seg,smallLv,nil,nil,nil,true)
        segNameStr=ltzdzVoApi:getSegName(seg,smallLv)
    else
        segIconSp=ltzdzVoApi:getSegIcon(lastSeg,lastSmallLv,nil,nil,nil,true)
        segNameStr=ltzdzVoApi:getSegName(lastSeg,lastSmallLv)
    end
    if segIconSp and segNameStr then
        segIconSp:setScale(0)
        segIconSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+50)
        self.dialogLayer:addChild(segIconSp,3)
        local segNameLb=GetTTFLabelWrap(segNameStr,28,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        segNameLb:setPosition(G_VisibleSizeWidth/2,segIconSp:getPositionY()-segIconSp:getContentSize().height*targetScale/2-60)
        segNameLb:setColor(G_ColorYellowPro)
        segNameLb:setVisible(false)
        self.dialogLayer:addChild(segNameLb,3)

        if upgradeFlag==true then --升级效果
            segIconSp:setScale(5)
            segIconSp:setVisible(false)
            local function showNewSegEffect()
                local frameSp=CCSprite:createWithSpriteFrameName("tisheng1.png")
                local frameArr=CCArray:create()
                for k=1,10 do
                    local nameStr="tisheng"..k..".png"
                    local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    frameArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(frameArr)
                animation:setDelayPerUnit(0.1)
                local animate=CCAnimate:create(animation)
                frameSp:setAnchorPoint(ccp(0.5,0.5))
                frameSp:setPosition(G_VisibleSizeWidth/2+20,G_VisibleSizeHeight/2+10)
                frameSp:setScale(3.5)
                self.dialogLayer:addChild(frameSp,5)
                local blendFunc=ccBlendFunc:new()
                blendFunc.src=GL_ONE
                blendFunc.dst=GL_ONE_MINUS_SRC_COLOR
                frameSp:setBlendFunc(blendFunc)
                local function showSp()
                    frameSp:setOpacity(255)
                end
                local function removeSp()
                    frameSp:removeFromParentAndCleanup(true)
                end
                local showCallFunc=CCCallFuncN:create(showSp)
                local removeCallFunc=CCCallFuncN:create(removeSp)
                local acArr=CCArray:create()
                acArr:addObject(showCallFunc)
                acArr:addObject(animate)
                acArr:addObject(removeCallFunc)
                local seq=CCSequence:create(acArr)
                frameSp:runAction(seq)

                local acArr2=CCArray:create()
                -- local delayAction=CCDelayTime:create(0.05)
                -- acArr2:addObject(delayAction)
                local function playEnd()
                    segIconSp:setVisible(true)
                    local segacArr=CCArray:create()
                    local scaleTo1=CCScaleTo:create(0.2,0.9)
                    local scaleTo2=CCScaleTo:create(0.2,1.2)
                    local scaleTo3=CCScaleTo:create(0.1,1)
                    segacArr:addObject(scaleTo1)
                    segacArr:addObject(scaleTo2)
                    segacArr:addObject(scaleTo3)
                    local function showSeg()
                        local spx,spy=segIconSp:getPosition()
                        segIconSp:removeFromParentAndCleanup(true)
                        segIconSp=ltzdzVoApi:getSegIcon(seg,smallLv)
                        segIconSp:setPosition(spx,spy)
                        self.dialogLayer:addChild(segIconSp,3)

                        segNameLb:setVisible(true)
                        resultLb:setVisible(true)
                    end
                    local callFunc=CCCallFuncN:create(showSeg)
                    segacArr:addObject(callFunc)
                    local segSeq=CCSequence:create(segacArr)
                    segIconSp:runAction(segSeq)
                end
                local endCallBack=CCCallFuncN:create(playEnd)
                acArr2:addObject(endCallBack)
                local seq2=CCSequence:create(acArr2)
                self.dialogLayer:runAction(seq2)
            end
            local lastSegIconSp=ltzdzVoApi:getSegIcon(lastSeg,lastSmallLv,nil,nil,nil,true)
            lastSegIconSp:setPosition(segIconSp:getPosition())
            lastSegIconSp:setScale(0)
            self.dialogLayer:addChild(lastSegIconSp,3)

            local lspTotalTime,lspTargetScale=1,1.5
            local lastSegacArr=CCArray:create()
            local lspScaleTo=CCScaleTo:create(lspTotalTime,lspTargetScale)
            lastSegacArr:addObject(lspScaleTo)
            local function lspActionEnd()
                lastSegIconSp:stopAllActions()
                lastSegIconSp:removeFromParentAndCleanup(true)
                lastSegIconSp=nil
                showNewSegEffect() --新段位动画效果
            end
            local lspFunc=CCCallFunc:create(lspActionEnd)
            lastSegacArr:addObject(lspFunc)
            local lspSeq=CCSequence:create(lastSegacArr)
            lastSegIconSp:runAction(lspSeq)

            local function playLastSegEffect(target)
                if target==nil then
                    do return end
                end
                local delayAc=CCDelayTime:create(lspTotalTime/lspTargetScale)
                local fadeTo=CCFadeTo:create(lspTotalTime-(lspTotalTime/lspTargetScale)*(lspTargetScale-1),0)
                local seq=CCSequence:createWithTwoActions(delayAc,fadeTo)
                target:runAction(seq)
            end
            local segSp=tolua.cast(lastSegIconSp:getChildByTag(101),"CCSprite")
            if segSp then
                playLastSegEffect(segSp)
                local smallSegSp=tolua.cast(segSp:getChildByTag(103),"CCNode")
                local caidaiSp=tolua.cast(segSp:getChildByTag(102),"CCSprite")
                if smallSegSp then
                    playLastSegEffect(smallSegSp)
                end
                if caidaiSp then
                    local smallSegSp=tolua.cast(caidaiSp:getChildByTag(103),"CCNode")
                    if smallSegSp then
                        playLastSegEffect(smallSegSp)
                    end
                    playLastSegEffect(caidaiSp)
                end
            end
            -- local repeatForever=CCRepeatForever:create(seq)
            -- frameSp:runAction(repeatForever)
        else --降低段位效果
            -- local arr={-105,-95,-85,-75}
            -- local action=CCOrbitCamera:create(0.25,1,0,0,arr[1],0,0)
            -- local seqArr=CCArray:create()
            -- seqArr:addObject(action)
            -- local function callback( ... )
               
            -- end
            -- seqArr:addObject(CCCallFunc:create(callback))
            -- local action2=CCOrbitCamera:create(0.25,1,0,arr[1],-(180+arr[1]),0,0)
            -- seqArr:addObject(action2)
            -- -- seqArr:addObject(CCCallFunc:create(resetdataCallback))
            -- local seq_action=CCSequence:create(seqArr)
            -- segIconSp:runAction(seq_action)
            segIconSp:setScale(targetScale)
            segNameLb:setVisible(true)

            local arr={105,95,85,75}
            local action=CCOrbitCamera:create(0.25,1,0,-180,180-arr[1],0,0)
            local seqArr=CCArray:create()
            seqArr:addObject(action)
            local function callback( ... )
                local x,y=segIconSp:getPosition()
                segIconSp:removeFromParentAndCleanup(true)
                segIconSp=nil
                local segNameStr=ltzdzVoApi:getSegName(seg,smallLv)
                segNameLb:setString(segNameStr)
                resultLb:setVisible(true)
                segIconSp=ltzdzVoApi:getSegIcon(seg,smallLv)
                segIconSp:setScale(targetScale)
                segIconSp:setPosition(x,y)
                self.dialogLayer:addChild(segIconSp,3)
                local seqArr=CCArray:create()
                local action2=CCOrbitCamera:create(0.25,1,0,180-arr[1],arr[1],0,0)
                seqArr:addObject(action2)
                local seq_action=CCSequence:create(seqArr)
                segIconSp:runAction(seq_action)
            end
            seqArr:addObject(CCCallFunc:create(callback))
            -- seqArr:addObject(CCCallFunc:create(callback2))
            local seq_action=CCSequence:create(seqArr)
            segIconSp:runAction(seq_action)
        end
    end

    local function touchLuaSpr()
        if callBack then
            callBack()
        end
        return self:close()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
    sceneGame:addChild(self.dialogLayer,layerNum)

    G_addArrowPrompt(self.dialogLayer,nil,100)
    
    return self.dialogLayer
end

function ltzdzSegUpgradeSmallDialog:dispose()
    spriteController:removePlist("public/ltzdz/ltzdzSegUpImgs.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegUpImgs.png")
end