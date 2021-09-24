touchScene={
    clayer,
    sceneSp,
    touchArr={},
}
--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function touchScene:show()
    --加载资源
    self.time=0
    self.showTime=30
    self.isShow=false
    self.guidId=0
    self.bgLayer=CCLayer:create()
    
    sceneGame:addChild(self.bgLayer,9999)
    self.bgLayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end

    self.bgLayer:registerScriptTouchHandler(tmpHandler,false,-9999,false)
    self.bgLayer:setTouchPriority(-9999)



end



function touchScene:touchEvent(fn,x,y,touch)
    if fn=="began" then

        if self.guidId==1005 then
            mainUI:changeToWorld()
            self.guidId=0
        end

        self:setVisible()
        self:setNormal()
    elseif fn=="moved" then
        
    elseif fn=="ended" then
        
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function touchScene:showGuide(id,sp)
    if self.selectSp then
        self.selectSp:stopAllActions()
        self.selectSp:removeFromParentAndCleanup(true)
        self.selectSp=nil
    end
    if self.selectSp==nil and sp then

        local function touchCallBack( ... )        
        end
        self.cLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchCallBack)
        self.cLayer:setAnchorPoint(ccp(0.5,0.5))
        self.cLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.cLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.cLayer:setTouchPriority(-9999)
        self.cLayer:setIsSallow(true)
        self.cLayer:setOpacity(0)
        sceneGame:addChild(self.cLayer,9999) --背景透明遮挡层，第7层

        local function clickAreaHandler()               
        end
        self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
        --self.selectSp:setAnchorPoint(ccp(0,0))
        self.selectSp:setTouchPriority(-1)
        self.selectSp:setIsSallow(false)
        self.selectSp:setContentSize(CCSizeMake(sp:getContentSize().width,sp:getContentSize().height))
        self.selectSp:setPosition(getCenterPoint(sp))
        sp:addChild(self.selectSp,999)


        self.panel=CCNode:create()
        self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
        self.gn:setAnchorPoint(ccp(0,0))
        self.gn:setPosition(ccp(30,100))
        self.panel:addChild(self.gn)
         
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
        self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        self.headerSprie:ignoreAnchorPointForPosition(false);
        self.headerSprie:setAnchorPoint(ccp(0,0))
        self.headerSprie:setTouchPriority(0)
        self.panel:addChild(self.headerSprie)
        self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.guidLabel:setAnchorPoint(ccp(0,0.5))
        self.guidLabel:setPosition(ccp(10,self.headerSprie:getContentSize().height/2))
        self.headerSprie:addChild(self.guidLabel) --添加文本框
         
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
        self.panel:addChild(self.dArrowSp)
         ----以上面板上的倒三角----
        self.panel:setPosition(ccp(10,100))
        self.bgLayer:addChild(self.panel)


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

        self.arrow=CCSprite:createWithSpriteFrameName("GuideArow.png")
        self.arrow:setAnchorPoint(ccp(0.5,0.5))
        self.selectSp:addChild(self.arrow)
        self.arrow:setPosition(-50,self.selectSp:getContentSize().height/2)
        self.arrow:setRotation(-90)

        local aimPos=ccp(self.arrow:getPositionX()-100,self.arrow:getPositionY())
        local arrowPos=ccp(self.arrow:getPositionX()-50,self.arrow:getPositionY())

        local mvTo=CCMoveTo:create(0.35,aimPos)
        local mvBack=CCMoveTo:create(0.35,arrowPos)
        local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
        self.arrow:runAction(CCRepeatForever:create(seq))
    
    end


    if self.headerSprie==nil and sp==nil then

        local function touchCallBack( ... )        
        end
        self.cLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchCallBack)
        self.cLayer:setAnchorPoint(ccp(0.5,0.5))
        self.cLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
        self.cLayer:setContentSize(CCSizeMake(G_VisibleSize.width,G_VisibleSize.height))
        self.cLayer:setTouchPriority(-9999)
        self.cLayer:setIsSallow(true)
        self.cLayer:setOpacity(0)
        sceneGame:addChild(self.cLayer,9999) --背景透明遮挡层，第7层

        self.panel=CCNode:create()
        self.gn=CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
        self.gn:setAnchorPoint(ccp(0,0))
        self.gn:setPosition(ccp(30,100))
        self.panel:addChild(self.gn)

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        self.headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
        self.headerSprie:setContentSize(CCSizeMake(G_VisibleSize.width-20,120))
        self.headerSprie:ignoreAnchorPointForPosition(false);
        self.headerSprie:setAnchorPoint(ccp(0,0))
        self.headerSprie:setTouchPriority(0)
        self.panel:addChild(self.headerSprie)
        self.guidLabel=GetTTFLabelWrap("",25,CCSize(G_VisibleSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.guidLabel:setAnchorPoint(ccp(0,0.5))
        self.guidLabel:setPosition(ccp(10,self.headerSprie:getContentSize().height/2))
        self.headerSprie:addChild(self.guidLabel) --添加文本框
         
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
        self.panel:addChild(self.dArrowSp)
         ----以上面板上的倒三角----
        self.panel:setPosition(ccp(10,100))
        self.bgLayer:addChild(self.panel)

    end



    if self.headerSprie~=nil then
        self.panel:setVisible(true)
        self.headerSprie:stopAllActions()
        local fadeIn=CCFadeIn:create(0.3)
        self.headerSprie:setOpacity(0)
        self.headerSprie:runAction(fadeIn)
    end         
    if self.gn~=nil then
        self.gn:stopAllActions()

        local function sdHandler( ... )
            if self.cLayer then
                self.cLayer:removeFromParentAndCleanup(true)
                self.cLayer=nil
            end
        end
        local fadeIn=CCFadeIn:create(0.3)
        local calFunc=CCCallFuncN:create(sdHandler)
        local fseq=CCSequence:createWithTwoActions(fadeIn,calFunc)
        self.gn:setOpacity(0)
        self.gn:runAction(fseq)
    end

    if self.guidLabel~=nil then


        self.guidLabel:stopAllActions()
        local fadeIn=CCFadeIn:create(0.3)
        self.guidLabel:setOpacity(0)
        self.guidLabel:runAction(fadeIn)
    end

    local guideStr=getlocal("phased_guide_tip_"..id)
    self.guidLabel:setString(guideStr)

end

function touchScene:setVisible()
    if self.panel then
        if self.selectSp then
            self.selectSp=tolua.cast(self.selectSp,"CCNode")
            self.selectSp:setVisible(false)
        end
        self.panel=tolua.cast(self.panel,"CCNode")
        if self.panel then
            self.panel:setVisible(false)
        end
    end
end


function touchScene:getShowId()
    local showId = 0
    --建造坦克空闲
    local tankTab1=tankSlotVoApi:getSoltByBid(11)
    local tankTab2=tankSlotVoApi:getSoltByBid(12)
    local isShow = false

    local tab5=buildingVoApi:getBuildingVoHaveByBtype(6)
    local tankTab1=tankSlotVoApi:getTankSlotTab(11)
    local tankTab2=tankSlotVoApi:getTankSlotTab(12)
    local num=SizeOfTable(tankTab1)+SizeOfTable(tankTab2)
    --print("num=====",SizeOfTable(tab5),num)
    if SizeOfTable(tab5)>0 and num<SizeOfTable(tab5)then
        isShow=true
    end

    if isShow then
        showId = 1001
        return showId
    end

    --建造建筑空闲
    local buildingSlotNum=SizeOfTable(buildingSlotVoApi:getAllBuildingSlots())
    local maxBuildNum=playerVoApi:getBuildingSlotNum()

    if buildingVoApi:isHasNOBuild() and buildingSlotNum<maxBuildNum then
        showId = 1002
        return showId
    end

    --升级建筑空闲
    local buildingTb=buildingVoApi:getBuildingsEnableUpgrade()
    if SizeOfTable(buildingTb)>0 and buildingSlotNum<maxBuildNum then
        showId = 1003
        return showId
    end

    --科技
    if technologyVoApi:isAllTechnologyMaxLv()==false and SizeOfTable(technologySlotVoApi:getAllSlotSortBySt())==0 then
        showId = 1004
        return showId
    end

    --空间部队
    local fleetsNums=tonumber(Split(playerCfg.actionFleets,",")[playerVoApi:getVipLevel()+1])
    if attackTankSoltVoApi:getAllTankSlotsNum()<fleetsNums and tankVoApi:isHasTank() then
        showId = 1005
        return showId
    end



    return showId
end

function touchScene:setNormal()
    self.isShow=false
    self.time=0

end

function touchScene:tick()

    --do return end
    if(newGuidMgr.isGuiding or phasedGuideMgr.isGuiding)then
        do return end
    end
     if storyScene.isShow then
        do return end
     end

    self.time=self.time+1
    --print("self.time=",self.time)

    if base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 and self.time>=self.showTime and self.isShow==false then
        self.time=0
        self.isShow=true
        print("self:getShowId()=",self:getShowId())
        if self:getShowId()==1001 then
            local sp=mainUI.m_luaSp5
            if sp then
                mainUI:showAllList()
                self:showGuide(self:getShowId(),sp)
            end
        elseif self:getShowId()==1002 then
            local sp=mainUI.m_luaSp6
            if sp then
                mainUI:showAllList()
                self:showGuide(self:getShowId(),sp)
            end
        elseif self:getShowId()==1003 then
            local sp=mainUI.m_luaSp6
            if sp then
                mainUI:showAllList()
                self:showGuide(self:getShowId(),sp)
            end
        elseif self:getShowId()==1004 then
            local sp=mainUI.m_luaSp4
            if sp then
                mainUI:showAllList()
                self:showGuide(self:getShowId(),sp)
            end
        elseif self:getShowId()==1005 then
                self.guidId=1005
                self:showGuide(self:getShowId())

        end

        --phasedGuideMgr:showGuide(self:getShowId())

    end

end


function touchScene:clear()
    self.clayer=nil
    self.panel=nil
    self.selectSp=nil
    self.bgLayer=nil
    self.headerSprie=nil
    self.touchArr={}
    
end
