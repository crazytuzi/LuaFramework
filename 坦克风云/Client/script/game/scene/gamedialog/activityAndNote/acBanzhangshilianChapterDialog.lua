acBanzhangshilianChapterDialog=commonDialog:new()

function acBanzhangshilianChapterDialog:new(chapterIndex)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.chapterIndex=chapterIndex
    self.cellHight=180
    self.chapterCfg={}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    return nc
end

function acBanzhangshilianChapterDialog:initTableView()
    local acVo=acBanzhangshilianVoApi:getAcVo()
    if self.chapterIndex and acVo and acVo.challengeCfg and SizeOfTable(acVo.challengeCfg)>0 then
        local cCfg=G_clone(acVo.challengeCfg)
        for k,v in ipairs(cCfg) do
            if v.chapter==self.chapterIndex then
                v.cIndex=k
                table.insert(self.chapterCfg,v)
            end
        end
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-120),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setPosition(ccp(30,30))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acBanzhangshilianChapterDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.chapterCfg)
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-60,self.cellHight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local cfg=self.chapterCfg[idx+1]
        local landType=cfg.land
        local iconStr=cfg.style
        local reward=cfg.reward
        local cIndex=cfg.cIndex
        local nameStr=acBanzhangshilianVoApi:getChallengeName(cIndex)
        local acVo=acBanzhangshilianVoApi:getAcVo()
        local challengeInfo=acVo.challengeInfo
        local starNum=0
        local isComplete=false
        if challengeInfo and challengeInfo[self.chapterIndex] and SizeOfTable(challengeInfo[self.chapterIndex])>0 then
            for k,v in pairs(challengeInfo[self.chapterIndex]) do
                if cIndex==v then
                    isComplete=true
                end
            end
        end
        if reward and reward.star then
            starNum=reward.star
        end

        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if (battleScene and battleScene.isBattleing==true) then
                    do return end
                end
                PlayEffect(audioCfg.mouseClick)

                acBanzhangshilianVoApi:showTroopsInfoDialog(self.layerNum+1,cfg.cIndex)
            end
        end
        local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),cellClick)
        background:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHight-10))
        background:setAnchorPoint(ccp(0,0))
        background:setPosition(ccp(0,5))
        background:setIsSallow(false)
        background:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(background)

        local nameWidth=250
        local icon=CCSprite:createWithSpriteFrameName(iconStr)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(20,self.cellHight/2))
        cell:addChild(icon)
        icon:setScale(0.8)
        -- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local nameLb=GetTTFLabelWrap(nameStr,28,CCSizeMake(nameWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(30+icon:getContentSize().width,self.cellHight/2))
        cell:addChild(nameLb)
        nameLb:setColor(G_ColorGreen)
        local tempLb=GetTTFLabel(nameStr,28)
        local iconPosX=tempLb:getContentSize().width+20
        if iconPosX>nameWidth then
            iconPosX=nameWidth
        end
        -- local checkIcon=CCSprite:createWithSpriteFrameName("IconWarRedFlage.png")
        local checkIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
        checkIcon:setAnchorPoint(ccp(0,0.5))
        checkIcon:setPosition(ccp(30+icon:getContentSize().width+iconPosX,self.cellHight/2))
        cell:addChild(checkIcon)
        if isComplete==true then
            checkIcon:setVisible(true)
        else
            checkIcon:setVisible(false)
        end

        local landSp=CCSprite:createWithSpriteFrameName("world_ground_"..landType..".png")
        landSp:setPosition(ccp(background:getContentSize().width-70,self.cellHight/2))
        cell:addChild(landSp)
        
        local starNumLb=GetTTFLabel(starNum,28)
        starNumLb:setPosition(ccp(background:getContentSize().width-90,40))
        cell:addChild(starNumLb)
        local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
        starSp:setAnchorPoint(ccp(0.5,0.5))
        starSp:setPosition(ccp(background:getContentSize().width-50,40))
        cell:addChild(starSp)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function acBanzhangshilianChapterDialog:tick()
    local vo=acBanzhangshilianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if acBanzhangshilianVoApi:getCFlag()==0 then
        acBanzhangshilianVoApi:setCFlag(1)
        if self and self.tv then
            local recordPoint=self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end

    local unlockNewIndex=acBanzhangshilianVoApi:getUnlockNewIndex()
    if unlockNewIndex and unlockNewIndex>0 and battleScene.isBattleing==false then
        local chapterName=getlocal("activity_banzhangshilian_chapter_name_"..unlockNewIndex)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_complete_tip",{chapterName}),30)
        acBanzhangshilianVoApi:setUnlockNewIndex(0)
    end
end

function acBanzhangshilianChapterDialog:refresh()

end

function acBanzhangshilianChapterDialog:dispose()
    self.chapterIndex=nil
    self.cellHight=nil
    self.chapterCfg={}
end