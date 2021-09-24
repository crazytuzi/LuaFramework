guideTipMgr={
    isTiping=false,
    showFlag=false,
}


function guideTipMgr:showGuideTipDialog(descStr,color,layerNum,panelPos,clickRect,delayTime,parent)
    self.isTiping=true    
  	self.layerNum=layerNum
    if parent==nil then
        parent=sceneGame
    end
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(0,0)
    parent:addChild(self.dialogLayer,layerNum)


    local function touchLuaSpr()
        if self.showFlag==true then
            if self.closeCallBack then
                self.closeCallBack()
            end
            self:clear()
        end
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    dialogBg:setTouchPriority(-(layerNum-1)*20-10)
    dialogBg:setContentSize(G_VisibleSize)
    dialogBg:setOpacity(0)
    dialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(dialogBg)
    self.bgLayer=dialogBg

    local function showPanel()
        local tipPanelPos
        if self.panelPos then
            tipPanelPos=self.panelPos
        else
            tipPanelPos=panelPos or ccp(10,G_VisibleSize.height/2-120)
        end
        local panel=CCNode:create()
        local girlSp
        if(G_curPlatName()=="5" or G_curPlatName()=="58")then
            girlSp=CCSprite:create("flBaiduImage/GuideCharacter_fl.png")
        elseif platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            girlSp=CCSprite:create("public/guide.png") --姑娘
        else
            girlSp=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
        end
        if girlSp then
            girlSp:setAnchorPoint(ccp(0,0))
            girlSp:setPosition(ccp(30,115))
            girlSp:setOpacity(0)
            panel:addChild(girlSp)
        end

        local rect=CCRect(0, 0, 50, 50);
        local capInSet=CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("GuideNewPanel.png",capInSet,cellClick)--对话背景GuidePanel
        tipBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        tipBg:ignoreAnchorPointForPosition(false)
        tipBg:setAnchorPoint(ccp(0,0))
        tipBg:setTouchPriority(0)
        tipBg:setOpacity(0)
        panel:addChild(tipBg)

        local descLb=GetTTFLabelWrap(descStr,25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(20,tipBg:getContentSize().height/2))
        descLb:setOpacity(0)
        tipBg:addChild(descLb) --添加文本框

        panel:setPosition(tipPanelPos)

        local dArrowSp=CCSprite:createWithSpriteFrameName("DownArow1.png")
        local spcArr=CCArray:create()
                   
        for kk=1,12 do
            local nameStr="DownArow"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            spcArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(spcArr)
        animation:setRestoreOriginalFrame(true)
        animation:setDelayPerUnit(0.08)
        local animate=CCAnimate:create(animation)
        local repeatForever=CCRepeatForever:create(animate)
        dArrowSp:runAction(repeatForever)
        dArrowSp:setAnchorPoint(ccp(1,0))
        dArrowSp:setPosition(ccp(tipBg:getContentSize().width,2))
        dArrowSp:setVisible(false)
        panel:addChild(dArrowSp)
         ----以上面板上的倒三角----
        self.bgLayer:addChild(panel,10)

        local function realShow(target)
            if target then
                target:stopAllActions()
                local fadeIn=CCFadeIn:create(0.3)
                target:setOpacity(0)
                target:runAction(fadeIn)
            end
        end
        realShow(girlSp)
        realShow(tipBg)
        realShow(descLb)
        if dArrowSp~=nil then
            dArrowSp:setVisible(true)
        end
    end

    local function showSelect()
        local function touchHandler(fn,x,y,touch)
            if fn=="began" then
                return 1
            elseif fn=="ended" then
                if clickRect then
                    local touchFlag=clickRect:containsPoint(ccp(x,y))
                    -- if touchFlag==true then
                        if self.showFlag==true then
                            self:clear()
                        end
                    -- end
                end
            end           
        end
        local touchLayer=CCLayer:create()
        touchLayer:setTouchEnabled(true)
        touchLayer:registerScriptTouchHandler(touchHandler,false,-320,false)
        touchLayer:setPosition(0,0)
        touchLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.dialogLayer:addChild(touchLayer)

        -- self.bgLayer:setNoSallowArea(clickRect)
        self.bgLayer:setNoSallowArea(CCRectMake(0,0,G_VisibleSize.width,G_VisibleSize.height))
        local function clickAreaHandler()
        end
        local selectSp=LuaCCSprite:createWithSpriteFrameName("guildExternal.png",clickAreaHandler)
        local scale=1
        if clickRect then
            local width=clickRect.size.width
            local height=clickRect.size.height
            if width<height then
                width=height
            end
            local spW=selectSp:getContentSize().width
            scale=width/spW
            if scale>1.5 then
                scale=1.5
            end
        end
        selectSp:setScale(scale)
        selectSp:setAnchorPoint(ccp(0.5,0.5))
        selectSp:setOpacity(0)
        selectSp:setTouchPriority(-1)
        local sx=clickRect:getMinX()+clickRect.size.width/2
        local sy=clickRect:getMinY()+clickRect.size.height/2
        selectSp:setPosition(sx,sy)
        self.bgLayer:addChild(selectSp,4)

        local internalSp=CCSprite:createWithSpriteFrameName("guildInternal.png")
        internalSp:setPosition(getCenterPoint(selectSp))
        internalSp:setTag(1001)
        internalSp:setOpacity(0)
        selectSp:addChild(internalSp)

        local shadeLayer=CCClippingNode:create() --遮罩层
        shadeLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        shadeLayer:setAnchorPoint(ccp(0.5,0.5))
        shadeLayer:setInverted(true)
        shadeLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)

        local back=CCLayerColor:create(ccc4(0,0,0,125))
        shadeLayer:addChild(back)
        local circleSp=CCSprite:createWithSpriteFrameName("guidShade.png")
        circleSp:setScale(scale)
        circleSp:setPosition(sx,sy)
        shadeLayer:setStencil(circleSp)
        self.bgLayer:addChild(shadeLayer,3)

        local clipLayer=CCClippingNode:create() --裁切层
        clipLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        clipLayer:setAnchorPoint(ccp(0.5,0.5))
        clipLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)

        local stencil=CCSprite:createWithSpriteFrameName("guidShade.png")
        stencil:setOpacity(0)
        stencil:setScale(scale)
        stencil:setPosition(sx,sy)
        clipLayer:setStencil(stencil)

        local shadeSp=CCSprite:createWithSpriteFrameName("guidShade_big.png")
        shadeSp:setOpacity(125)
        shadeSp:setScale(scale)
        shadeSp:setPosition(sx,sy) 
        clipLayer:addChild(shadeSp)

        self.bgLayer:addChild(clipLayer,2)

        self.shadeLayer=shadeLayer
        self.clipLayer=clipLayer
        self.circleSp=circleSp
        self.shadeSp=shadeSp
        self.stencil=stencil
        self.selectSp=selectSp

        local function realShowSelect()
            self.selectSp:setOpacity(255)
            local internalSp=tolua.cast(self.selectSp:getChildByTag(1001),"CCSprite")
            if internalSp then
                internalSp:setOpacity(255)
                self:playSelectEffect(internalSp,720)
            end
            self:playSelectEffect(self.selectSp,-360,true)
        end
  
        self:playCircleEffect(realShowSelect)
    end

    local function realShow()
        if clickRect~=nil then
            showSelect()
        end
        if clickRect~=nil and panelPos==nil then
        else
            self.bgLayer:setOpacity(125)
            showPanel()
        end
        if self.showCallBack then
            self.showCallBack()
        end
    end
    local delayTime=delayTime or 0.3
    local delay=CCDelayTime:create(delayTime)
    local ffunc=CCCallFuncN:create(realShow)
    local fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.bgLayer:runAction(fseq)

    local closeDelayTime=0.8
    local function setShowFlag()
        self.showFlag=true
    end
    local closeDelay=CCDelayTime:create(closeDelayTime)
    local callFunc=CCCallFuncN:create(setShowFlag)
    local closeFseq=CCSequence:createWithTwoActions(closeDelay,callFunc)
    self.dialogLayer:runAction(closeFseq)
end

function guideTipMgr:setCallBackFunc(showCallBack,closeCallBack)
    self.showCallBack=showCallBack
    self.closeCallBack=closeCallBack
end

function guideTipMgr:playSelectEffect(target,angle,isScale)
    if target and self.selectSp then
        local rotateAc=CCRotateBy:create(2,angle)
        if isScale and isScale==true then
            local scale=self.selectSp:getScale()
            local maxScale=1.3*scale
            local scaleAc1=CCScaleTo:create(0.5,maxScale)
            local scaleAc2=CCScaleTo:create(0.5,scale)
            local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
            local effectArr=CCArray:create()
            effectArr:addObject(rotateAc)
            effectArr:addObject(scaleSeq)
            local spawnAc=CCSpawn:create(effectArr)
            target:runAction(CCRepeatForever:create(scaleSeq))
            target:runAction(CCRepeatForever:create(rotateAc))
        else
            target:runAction(CCRepeatForever:create(rotateAc))
        end
    end
end

function guideTipMgr:playCircleEffect(callBack)
    local function realPlay(target,callBack)
       if target and self.selectSp then
            target:stopAllActions()
            local scale=self.selectSp:getScale()
            local maxScale=1.1*scale
            local beginScale=10*scale
            target:setScale(beginScale)
            local arr=CCArray:create()
            local scaleAc=CCScaleTo:create(0.3,scale)
            arr:addObject(scaleAc)
            local function scaleHandler()
                local scaleAc1=CCScaleTo:create(0.3,maxScale)
                local scaleAc2=CCScaleTo:create(0.3,scale)
                local scaleSeq=CCSequence:createWithTwoActions(scaleAc1,scaleAc2)
                -- target:runAction(CCRepeatForever:create(scaleSeq))
                if callBack then
                    callBack()
                end
            end
            local func=CCCallFuncN:create(scaleHandler)
            arr:addObject(func)
            local scaleSeq=CCSequence:create(arr)
            target:runAction(scaleSeq)
       end
    end
    if self.circleSp then
        realPlay(self.circleSp,callBack)
    end
    if self.shadeSp then
        self.shadeSp:setVisible(true)
        realPlay(self.shadeSp)
    end
    if self.stencil then
        realPlay(self.stencil)
    end
end

function guideTipMgr:setPanelPos(panelPos)
    self.panelPos=panelPos
end

function guideTipMgr:clear()
    self.isTiping=false
    self.showCallBack=nil
    self.closeCallBack=nil
    if self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    self.bgLayer=nil
    self.shadeLayer=nil
    self.clipLayer=nil
    self.circleSp=nil
    self.shadeSp=nil
    self.stencil=nil
    self.selectSp=nil
    self.panelPos=nil
    self.showFlag=false
end