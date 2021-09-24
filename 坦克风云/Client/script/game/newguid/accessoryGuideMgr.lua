accessoryGuideMgr=
{
    curStep=1, --当前小步
    curTask=1, --当前大步
    bgLayer, --透明背景层
    bgLayer1, --透明背景层
    panle, --对话框
    arrow, --箭头
    guidLabel, --引导文字
    selectSp, --选中框
    closeBtn,
    dArrowSp --倒三角箭头
}

function accessoryGuideMgr:setCurStep(cStep)
    self.curStep=cStep
    self:showGuid()
end

function accessoryGuideMgr:showGuid()
    local guidCfg=accessoryGuidCfg[self.curStep]
    
    local startSpTb={}
    
    local function tmpFunc()
        if accessoryGuidCfg[self.curStep].clickToNext==true then --点击屏幕跳入下一步
            PlayEffect(audioCfg.mouseClick)
            self:toNextStep()
        end
    end
    if self.bgLayer==nil then
        self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.bgLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.bgLayer:setTouchPriority(-320)
        self.bgLayer:setOpacity(0)
        sceneGame:addChild(self.bgLayer,8) --背景透明遮挡层，第7层
        
        local function clickAreaHandler()                
        end
        self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
        self.selectSp:setAnchorPoint(ccp(0,0))
        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.bgLayer:addChild(self.selectSp)
        self.selectSp:setVisible(false)
    end
    if guidCfg.clickRect~=nil then
        self.selectSp:setVisible(true)
        self.selectSp:setPosition(ccp(guidCfg.clickRect:getMinX(),guidCfg.clickRect:getMinY()))
        self.selectSp:setContentSize(CCSizeMake(guidCfg.clickRect.size.width,guidCfg.clickRect.size.height))
    else
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
        self.selectSp:setVisible(false)
    end    
    if guidCfg.hasPanle==true then --新手引导面板
        self:showPanle()
        self.panle=tolua.cast(self.panle,"CCNode")
        self.panle:setVisible(true)
    else
        if self.panle~=nil then
            self.panle=tolua.cast(self.panle,"CCNode")
            self.panle:setVisible(false)
        end
        if self.arrow~=nil then
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(false)
        end
    end
end
function accessoryGuideMgr:toNextStep(nextId)
    if self.bgLayer~=nil then
        self.bgLayer:setNoSallowArea(CCRect(-1000,-1000,1,1))
    end    
    if nextId~=nil then
        self.curStep=nextId
    else
        self.curStep=accessoryGuidCfg[self.curStep].toStepId
    end
    if(self.curStep~=nil)then
        self:showGuid()
    else
        accessoryVoApi:setGuideStep(-1)
        self:endNewGuid()
    end
end
function accessoryGuideMgr:showPanle()
    local guidCfg=accessoryGuidCfg[self.curStep]
    if self.panle==nil then
        self.panle=CCNode:create()
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            self.gn=CCSprite:create("public/guide.png")
        else
            self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
        end
        self.gn:setAnchorPoint(ccp(0,0))
        self.gn:setPosition(ccp(30,100))
        self.panle:addChild(self.gn)
         
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
        self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        self.headerSprie:ignoreAnchorPointForPosition(false);
        self.headerSprie:setAnchorPoint(ccp(0,0));
        self.headerSprie:setTouchPriority(0)
        self.panle:addChild(self.headerSprie)
        self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.guidLabel:setAnchorPoint(ccp(0,0.5))
        self.guidLabel:setPosition(ccp(10,self.headerSprie:getContentSize().height/2))
        self.headerSprie:addChild(self.guidLabel) --添加文本框
        local function closeBtnHandler()
            guidCfg=accessoryGuidCfg[self.curStep]
            if guidCfg.hasCloseBtn~=true then
                do return end
            end
            local function callBack()
            end
            PlayEffect(audioCfg.mouseClick)   
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("guide_skip_prompt"),nil,100)
        end
        self.closeBtn= LuaCCSprite:createWithSpriteFrameName("GuideClose.png",closeBtnHandler)
        self.closeBtn:setPosition(self.headerSprie:getContentSize().width-self.closeBtn:getContentSize().width/2,self.headerSprie:getContentSize().height+self.closeBtn:getContentSize().height/2-3)
        self.closeBtn:setTouchPriority(-321)
        self.headerSprie:addChild(self.closeBtn)
         
        ----以下面板上的倒三角----
        self.dArrowSp=CCSprite:createWithSpriteFrameName("DownArow1.png")
        local spcArr=CCArray:create()
        for kk=1,12 do
            local nameStr="DownArow"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            spcArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(spcArr)
        animation:setRestoreOriginalFrame(true);
        animation:setDelayPerUnit(0.08)
        local animate=CCAnimate:create(animation)
        local repeatForever=CCRepeatForever:create(animate)
        self.dArrowSp:runAction(repeatForever)
        self.dArrowSp:setAnchorPoint(ccp(1,0))
        self.dArrowSp:setPosition(ccp(self.headerSprie:getContentSize().width,2))
        self.panle:addChild(self.dArrowSp)
         ----以上面板上的倒三角----
        self.bgLayer:addChild(self.panle)
    end
    if self.dArrowSp~=nil then
        self.dArrowSp=tolua.cast(self.dArrowSp,"CCNode")
        self.dArrowSp:setVisible(false)
    end
    if self.arrow==nil then --箭头
            self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
            self.arrow:setAnchorPoint(ccp(0.5,0.5))
            self.bgLayer:addChild(self.arrow)
    end
    if self.arrow~=nil then --箭头
        self.arrow:setPosition(guidCfg.arrowPos)
    end

    if guidCfg.hasCloseBtn==true then --面板上的关闭按钮
         self.closeBtn:setVisible(true)
    else
         self.closeBtn:setVisible(false)
    end
    self.guidLabel:setString(getlocal("accessory_guide_tip_"..self.curStep))
    self.panle:setPosition(guidCfg.panlePos)
    self.panle:stopAllActions()
    
    if self.headerSprie~=nil then
        self.headerSprie:stopAllActions()
        self.headerSprie:setOpacity(0)
    end
    
    if self.gn~=nil then
         self.gn:stopAllActions()
        self.gn:setOpacity(0)
    end

    if self.arrow~=nil then
        self.arrow:stopAllActions()
        self.arrow:setOpacity(0)
    end
    if self.guidLabel~=nil then
        self.guidLabel:stopAllActions()
        self.guidLabel:setOpacity(0)
        if guidCfg.showGirl~=nil and guidCfg.showGirl==false then
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(false)
        else
            self.gn=tolua.cast(self.gn,"CCNode")
            self.gn:setVisible(true)
        end
        
        if guidCfg.clickRect==nil then
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(false)
        else
            self.arrow=tolua.cast(self.arrow,"CCNode")
            self.arrow:setVisible(true)
        end
    end
    
    if self.selectSp~=nil then
        self.selectSp:stopAllActions()
        self.selectSp:setOpacity(0)
    end

    if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
        self.closeBtn:stopAllActions()
        self.closeBtn:setOpacity(0)
    end
    

    local function showP()
        if self.headerSprie~=nil then
            self.headerSprie:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.headerSprie:setOpacity(0)
            self.headerSprie:runAction(fadeIn)
        end            
        if self.gn~=nil then
            self.gn:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.gn:setOpacity(0)
            self.gn:runAction(fadeIn)
        end
        if self.dArrowSp~=nil then
            if guidCfg.clickToNext==true then
                self.dArrowSp:setVisible(true)
            else
                self.dArrowSp:setVisible(false)
            end
        end
        

        if self.arrow~=nil then
            self.arrow:stopAllActions()
            self.arrow:setVisible(false)
            if guidCfg.arrowDirect==1 then  --下
                guidCfg.arrowPos.y=guidCfg.arrowPos.y-100/2
            elseif guidCfg.arrowDirect==2 then  --上
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+100/2
            elseif guidCfg.arrowDirect==3 then  --右上
                guidCfg.arrowPos.x=guidCfg.arrowPos.x+80/2
                guidCfg.arrowPos.y=guidCfg.arrowPos.y+80/2
            end
            self.arrow:setPosition(guidCfg.arrowPos)
            local function showArrowAction()
                local aimPos
                if guidCfg.arrowDirect==1 then  --下
                    aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y-100/2)
                    self.arrow:setRotation(0)
                elseif guidCfg.arrowDirect==2 then  --上
                    aimPos=ccp(guidCfg.arrowPos.x,guidCfg.arrowPos.y+100/2)
                    self.arrow:setRotation(180)
                elseif guidCfg.arrowDirect==3 then  --右上
                    aimPos=ccp(guidCfg.arrowPos.x+80/2,guidCfg.arrowPos.y+80/2)
                    self.arrow:setRotation(-135)
                end
                if guidCfg.clickRect~=nil then
                    self.arrow:setVisible(true)
                end
                local mvTo=CCMoveTo:create(0.35,aimPos)
                local mvBack=CCMoveTo:create(0.35,guidCfg.arrowPos)
                local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
                self.arrow:runAction(CCRepeatForever:create(seq))
            end
            local fadeIn=CCFadeIn:create(0.3)
            self.arrow:setOpacity(0)
            local ffunc=CCCallFuncN:create(showArrowAction)
            local fseq=CCSequence:createWithTwoActions(fadeIn,ffunc)
            self.arrow:runAction(fseq)
        end
        if self.guidLabel~=nil then
            self.guidLabel:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.guidLabel:setOpacity(0)
            self.guidLabel:runAction(fadeIn)
        end    
        if self.selectSp~=nil then
            local function sdHandler()
                local fadeOut=CCTintTo:create(0.5,150,150,150)
                local fadeIn=CCTintTo:create(0.5,255,255,255)
                local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                self.selectSp:runAction(CCRepeatForever:create(seq))
            end
            self.selectSp:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            local calFunc=CCCallFuncN:create(sdHandler)
            local fseq=CCSequence:createWithTwoActions(fadeIn,calFunc)
            self.selectSp:setOpacity(0)
            self.selectSp:runAction(fseq)
        end
        if self.closeBtn~=nil and self.closeBtn:isVisible()==true then
            self.closeBtn:stopAllActions()
            local fadeIn=CCFadeIn:create(0.3)
            self.closeBtn:setOpacity(0)
            self.closeBtn:runAction(fadeIn)
        end
        if guidCfg.clickRect~=nil then
            self.bgLayer:setNoSallowArea(guidCfg.clickRect)
        end
    end
    local delay=CCDelayTime:create(guidCfg.delayTime==nil and 1 or guidCfg.delayTime)
    local ffunc=CCCallFuncN:create(showP)
    local fseq=CCSequence:createWithTwoActions(delay,ffunc)
    self.panle:runAction(fseq)
end

function accessoryGuideMgr:endNewGuid()
    if self.bgLayer~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.selectSp=nil
    self.panle=nil
    self.arrow=nil
    self.guidLabel=nil
    self.closeBtn=nil
    self.headerSprie=nil
    self.gn=nil
    self.dArrowSp=nil
end
