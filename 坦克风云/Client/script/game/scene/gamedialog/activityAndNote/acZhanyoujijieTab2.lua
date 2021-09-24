acZhanyoujijieTab2={}

function acZhanyoujijieTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    -- nc.isToday=true
    nc.listTv={}
    nc.expandIdx={}
    nc.expandHeight=G_VisibleSize.height-460+85
    nc.normalHeight=160
    nc.contentBg=nil
    nc.hasRewardTb={}
    nc.listBgTb={}
    nc.rewardDescLb=nil
    nc.rechargeList={}
    return nc
end

function acZhanyoujijieTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    local acVo=acZhanyoujijieVoApi:getAcVo()
    if acVo then
        if acVo.isAfk==2 and acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>0 then
            local initFlag=acZhanyoujijieVoApi:getInitFlag()
            if initFlag==0 then
                local function rechargeInfoCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.rechargeInfo then
                            local rechargeInfo=sData.data.rechargeInfo
                            acZhanyoujijieVoApi:updateData({rechargeInfo=rechargeInfo})
                            self:initHead()
                            self:initContent()
                            acZhanyoujijieVoApi:setInitFlag(1)
                        end
                    end
                end
                socketHelper:activeZhanyoujijieRechargeInfo(rechargeInfoCallback)
            else
                self:initHead()
                self:initContent()
            end
        else
            self:initHead()
            self:initContent()
        end
    end
    return self.bgLayer
end

function acZhanyoujijieTab2:initHead()
    local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    local isLevelLimit=acZhanyoujijieVoApi:isLevelLimit()
    local posy=G_VisibleSizeHeight-180
    -- local isShowList=false
    -- if isLevelLimit==false then
    --     local acVo=acZhanyoujijieVoApi:getAcVo()
    --     if acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>0 then
    --         if acZhanyoujijieVoApi:isShowRechargeList()==true then
    --             isShowList=true
    --         end
    --     end
    -- end
    
    if isLevelLimit==false then
        local characterSp
        if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
            characterSp = CCSprite:create("public/guide.png")
        else
            characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png")
        end
        characterSp:setAnchorPoint(ccp(0,1))
        characterSp:setPosition(ccp(25,posy))
        characterSp:setScale(0.6)
        self.bgLayer:addChild(characterSp,5)
    end

    posy=posy+5
    -- 活动时间
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(acLabel,5)
    acLabel:setColor(G_ColorGreen)

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local tabStr={"\n",getlocal("activity_zhanyoujijie_tip2"),"\n"}
        local tabColor={nil,G_ColorYellowPro,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local itemScale=1
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(itemScale)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,posy-infoItem:getContentSize().height*itemScale/2+10))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn,5)

    posy=posy-acLabel:getContentSize().height-10
    local acVo = acZhanyoujijieVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(timeLabel,5)

    posy=posy-timeLabel:getContentSize().height-10
    local str=getlocal("activity_zhanyoujijie_desc2")
    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        if isLevelLimit==true then
            local descLb=GetTTFLabelWrap(str,strSize2,CCSizeMake(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0.5,1))
            descLb:setPosition(ccp(G_VisibleSizeWidth/2,posy))
            self.bgLayer:addChild(descLb,5)
        else
            local descLb=GetTTFLabelWrap(str,strSize2,CCSizeMake(420,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(180,posy))
            self.bgLayer:addChild(descLb,5)
        end
    else
        local desTv,desLabel=G_LabelTableView(CCSizeMake(420,100),str,strSize2,kCCTextAlignmentLeft)
        self.bgLayer:addChild(desTv,5)
        desTv:setPosition(ccp(180,posy-85))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
    end
end

function acZhanyoujijieTab2:initContent()
    local isAfk
    local acVo=acZhanyoujijieVoApi:getAcVo()
    if acVo then
        isAfk=acVo.isAfk
    end
    local acCfg=acZhanyoujijieVoApi:getAcCfg()
    if acCfg==nil then
        do return end
    end

    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,1,1),function ( ... )end)
    -- local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20,20,10,10),function ( ... )end)
    contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-375))
    contentBg:setAnchorPoint(ccp(0,0))
    contentBg:setPosition(30,35)
    self.bgLayer:addChild(contentBg,1)
    self.contentBg=contentBg

    local bgWidth,bgHeight=contentBg:getContentSize().width,contentBg:getContentSize().height
    if acZhanyoujijieVoApi:isLevelLimit()==true then
        contentBg:setOpacity(0)
        local count=math.floor((G_VisibleSizeHeight-160)/80)
        for i=1,count do
            local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
            bgSp:setAnchorPoint(ccp(0.5,1))
            bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
            bgSp:setScaleY(80/bgSp:getContentSize().height)
            bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
            self.bgLayer:addChild(bgSp)
            if G_isIphone5()==false and i==count then
                bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
            end
        end
        local tankSp=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
        tankSp:setAnchorPoint(ccp(0.5,0.5))
        tankSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-60))
        self.bgLayer:addChild(tankSp,1)

        local levelLimitLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_level_limit",{acCfg.limitLv}),25,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        levelLimitLb:setAnchorPoint(ccp(0.5,0.5))
        levelLimitLb:setPosition(ccp(bgWidth/2,160))
        contentBg:addChild(levelLimitLb,2)
        levelLimitLb:setColor(G_ColorRed)

        local function gotoHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            activityAndNoteDialog:closeAllDialog()
            local td=playerVoApi:showPlayerDialog(1,self.layerNum+1)
            td:tabClick(2)
        end
        local levelUpItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoHandler,nil,getlocal("activity_zhanyoujijie_level_up",{acCfg.limitLv}),25)
        -- levelUpItem:setScale(0.7)
        local levelUpMenu=CCMenu:createWithItem(levelUpItem)
        levelUpMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        levelUpMenu:setPosition(bgWidth/2,80)
        contentBg:addChild(levelUpMenu,2)
        G_addRectFlicker(levelUpItem,2.2,1)
        do return end
    end

    if isAfk==nil then
        do return end
    end
    -- local colorBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjianpansheng_redLine.png",CCRect(20,0,552,42),function ( ... )end)
    -- colorBg:setContentSize(CCSizeMake(colorBg:getContentSize().width,contentBg:getContentSize().height))
    -- colorBg:setPosition(getCenterPoint(contentBg))
    -- contentBg:addChild(colorBg)

    if isAfk==2 then
        -- contentBg:setOpacity(0)
        local acVo=acZhanyoujijieVoApi:getAcVo()
        if acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>0 and acZhanyoujijieVoApi:isShowRechargeList()==true then
            self.listBgTb={}
            self:updateBindPlayers()
            local function callBack1(...)
                return self:eventHandler1(...)
            end
            local hd= LuaEventHandler:createHandler(callBack1)
            self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth,bgHeight),nil)
            self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
            self.tv1:setPosition(ccp(0,0))
            contentBg:addChild(self.tv1,2)
            self.tv1:setMaxDisToBottomOrTop(120)

            -- local rewardDescLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_reward_desc",{1000,100}),25,CCSizeMake(bgWidth-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            -- rewardDescLb:setAnchorPoint(ccp(0,0.5))
            -- rewardDescLb:setPosition(ccp(25,120))
            -- contentBg:addChild(rewardDescLb,2)

            -- local function rewardAllHandler()
            --     if G_checkClickEnable()==false then
            --         do
            --             return
            --         end
            --     else
            --         base.setWaitTime=G_getCurDeviceMillTime()
            --     end
            --     PlayEffect(audioCfg.mouseClick)

            -- end
            -- local rewardAllItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardAllHandler,nil,getlocal("activity_zhanyoujijie_reward_all"),25)
            -- -- rewardAllItem:setScale(0.7)
            -- local rewardAllMenu=CCMenu:createWithItem(rewardAllItem)
            -- rewardAllMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            -- rewardAllMenu:setPosition(bgWidth-100,50)
            -- contentBg:addChild(rewardAllMenu,2)

            self:initGetAllRewardsView()
        else
            local noticeStr,btnStr
            if acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)==0 then
                noticeStr=getlocal("activity_zhanyoujijie_no_bind")
                btnStr=getlocal("activity_zhanyoujijie_bind_btn")
            else
                noticeStr=getlocal("activity_zhanyoujijie_bind_no_recharge")
                btnStr=getlocal("activity_zhanyoujijie_no_bind_btn")
            end
            local noListLb=GetTTFLabelWrap(noticeStr,25,CCSizeMake(bgWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            noListLb:setAnchorPoint(ccp(0.5,0.5))
            noListLb:setPosition(ccp(bgWidth/2,bgHeight/2))
            contentBg:addChild(noListLb,2)

            local function gotoHandler()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                if self.parent and self.parent.tabClick then
                    self.parent:tabClick(0,false)
                end
            end
            local gotoItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoHandler,nil,btnStr,25)
            -- gotoItem:setScale(0.7)
            local gotoMenu=CCMenu:createWithItem(gotoItem)
            gotoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            gotoMenu:setPosition(bgWidth/2,80)
            contentBg:addChild(gotoMenu,2)
        end
    else
        -- local lbPosy=bgHeight-300
        -- local buyLb=GetTTFLabel(getlocal("activity_zhanyoujijie_buy_gems",{1111,111}),25)
        -- buyLb:setAnchorPoint(ccp(0,0.5))
        -- buyLb:setPosition(ccp(40,lbPosy))
        -- contentBg:addChild(buyLb,1)

        self.tvHeight=contentBg:getContentSize().height-100
        local function callBack2(...)
            return self:eventHandler2(...)
        end
        local hd= LuaEventHandler:createHandler(callBack2)
        self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.contentBg:getContentSize().width-10,self.tvHeight),nil)
        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv2:setPosition(ccp(0,90))
        contentBg:addChild(self.tv2,2)
        self.tv2:setMaxDisToBottomOrTop(0)

        local function rechargeHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            G_goToDialog("gb",self.layerNum+1,true)
        end
        local rechargeItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rechargeHandler,nil,getlocal("recharge"),25)
        -- rechargeItem:setScale(0.7)
        local rechargeMenu=CCMenu:createWithItem(rechargeItem)
        rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        rechargeMenu:setPosition(bgWidth/2,50)
        contentBg:addChild(rechargeMenu,2)
    end
end

function acZhanyoujijieTab2:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        -- local acVo=acZhanyoujijieVoApi:getAcVo()
        -- if acVo and acVo.bindPlayers then
            local playerList=self.bindPlayers or {}--acVo.bindPlayers or {}
            return SizeOfTable(playerList)
        -- end
        -- return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.contentBg:getContentSize().width,self.normalHeight)
        local playerList=self.bindPlayers or {}
        if playerList and playerList[idx+1] and playerList[idx+1].uid then
            local uid=playerList[idx+1].uid
            local addHeight=self:getAddHeight(idx,uid)
            if self.expandIdx["k"..idx]~=nil then
                tmpSize=CCSizeMake(self.contentBg:getContentSize().width,self.expandHeight+addHeight)
            else
                tmpSize=CCSizeMake(self.contentBg:getContentSize().width,self.normalHeight+addHeight)
            end
        end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local acVo=acZhanyoujijieVoApi:getAcVo()
        local acCfg=acZhanyoujijieVoApi:getAcCfg()
        if acVo==nil or acCfg==nil then
            do return cell end
        end
        local bindPlayers=self.bindPlayers or {}--acVo.bindPlayers or {}
        local reInfo=bindPlayers[idx+1] or {}
        if reInfo==nil or SizeOfTable(reInfo)==0 then
            do return cell end
        end
        local uid=reInfo.uid
        local name=reInfo.name or ""
        local hasRewardNum=reInfo.hasRewardNum or 0
        local buyTotalNum=reInfo.buyTotalNum or 0
        local pic=reInfo.pic or 1
        local isShow1,canRewardNum=acZhanyoujijieVoApi:canRewardState(uid)

        local addHeight=self:getAddHeight(idx,uid)
        local expanded=false
        if self.expandIdx["k"..idx]==nil then
            expanded=false
        else
            expanded=true
        end
        if expanded then
            cell:setContentSize(CCSizeMake(self.contentBg:getContentSize().width, self.expandHeight+addHeight))
        else
            cell:setContentSize(CCSizeMake(self.contentBg:getContentSize().width, self.normalHeight+addHeight))
        end

        local cellWidth=cell:getContentSize().width
        local cellHeight=cell:getContentSize().height
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
            self:cellClick(idx,uid)
        end
        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,1,1),cellClick)
        backSprie:setContentSize(CCSizeMake(cellWidth-10, cellHeight-2))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setTag(1000+idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        backSprie:setPosition(ccp(5,0))
        cell:addChild(backSprie,1)
        local bgWidth=backSprie:getContentSize().width
        local bgHeight=backSprie:getContentSize().height
        
        local personPhotoName=playerVoApi:getPersonPhotoName(pic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
        playerPic:setAnchorPoint(ccp(0,0.5))
        playerPic:setPosition(ccp(20,bgHeight-self.normalHeight/2))
        backSprie:addChild(playerPic,1)
        local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
        tipSp:setPosition(ccp(20+70,bgHeight-self.normalHeight/2+70/2))
        backSprie:addChild(tipSp,2)
        if isShow1==true then
            tipSp:setVisible(true)
        else
            tipSp:setVisible(false)
        end
        local nameLb=GetTTFLabel(name,22)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(120,bgHeight-self.normalHeight/2+25))
        backSprie:addChild(nameLb,1)
        nameLb:setColor(G_ColorYellowPro)
        local totalLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_buy_total",{buyTotalNum,acCfg.limitMoney}),22,CCSizeMake(bgWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        totalLb:setAnchorPoint(ccp(0,0.5))
        totalLb:setPosition(ccp(120,bgHeight-self.normalHeight/2-25))
        backSprie:addChild(totalLb,1)
        local btn
        if expanded==true then
            btn=CCSprite:createWithSpriteFrameName("lessBtn.png")
        else
            btn=CCSprite:createWithSpriteFrameName("moreBtn.png")
        end
        btn:setPosition(ccp(bgWidth-50,bgHeight-self.normalHeight/2))
        backSprie:addChild(btn,1)

        local rewardmenu
        if addHeight and addHeight>0 then
            local poy=bgHeight-self.normalHeight-addHeight/2+1
            local lineSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
            -- lineSp:setScaleX(titleBgWidth/lineSp:getContentSize().width)
            lineSp:setPosition(ccp(bgWidth/2,bgHeight-self.normalHeight))
            backSprie:addChild(lineSp,1)

            local tmpWidth=0
            local hasRewardStr=getlocal("activity_zhanyoujijie_has_reward",{hasRewardNum})
            local hasRewardLb1=GetTTFLabel(hasRewardStr,22)
            tmpWidth=hasRewardLb1:getContentSize().width
            local hasRewardLb=GetTTFLabelWrap(hasRewardStr,22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            hasRewardLb:setAnchorPoint(ccp(0,0.5))
            hasRewardLb:setPosition(ccp(20,poy))
            backSprie:addChild(hasRewardLb,1)
            local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            if tmpWidth<hasRewardLb:getContentSize().width then
                gemIcon:setPosition(ccp(20+tmpWidth+25,poy))
            else
                gemIcon:setPosition(ccp(20+hasRewardLb:getContentSize().width+25,poy))
            end
            backSprie:addChild(gemIcon,1)
            
            local canRewardStr=getlocal("activity_zhanyoujijie_can_reward",{canRewardNum})
            local canRewardLb1=GetTTFLabel(canRewardStr,22)
            tmpWidth=canRewardLb1:getContentSize().width
            local canRewardLb=GetTTFLabelWrap(canRewardStr,22,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            canRewardLb:setAnchorPoint(ccp(0,0.5))
            canRewardLb:setPosition(ccp(230,poy))
            backSprie:addChild(canRewardLb,1)
            local gemIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
            if tmpWidth<canRewardLb:getContentSize().width then
                gemIcon2:setPosition(ccp(230+tmpWidth+25,poy))
            else
                gemIcon2:setPosition(ccp(230+canRewardLb:getContentSize().width+25,poy))
            end
            backSprie:addChild(gemIcon2,1)

            local function rewardHandler( ... )
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local isCan,canRewardNum=acZhanyoujijieVoApi:canRewardState(uid)
                if isCan==true then
                    local function rewardCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData.data and sData.data.zhanyoujijie then
                                acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                                self:refreshTv1()
                                if self.rewardShow==true and acZhanyoujijieVoApi:isShowRewardAll()==false then
                                    self:hideRewardWidget()
                                end
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                            end
                        end
                    end
                    socketHelper:activeZhanyoujijieTakeUserGems(uid,canRewardNum,rewardCallback)
                end
            end
            local iScale=0.8
            local rewardItem = GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,12,nil,nil)
            rewardItem:setScale(iScale)
            rewardmenu = CCMenu:createWithItem(rewardItem)
            rewardmenu:setPosition(ccp(bgWidth-70,poy))
            rewardmenu:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(rewardmenu,2)
        end
        if expanded==true then
            local function addExpand( ... )
                backSprie:setTouchPriority(-(self.layerNum-1)*20-5)
                if rewardmenu then
                    rewardmenu:setTouchPriority(-(self.layerNum-1)*20-7)
                end
                local function tthandler()
                end
                local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(19,19,1,1),tthandler)
                touchBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
                touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
                touchBg:setIsSallow(true)
                touchBg:setAnchorPoint(ccp(0,0))
                touchBg:setPosition(ccp(0,0))
                touchBg:setOpacity(0)
                cell:addChild(touchBg)
                local listBg=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(19,19,1,1),tthandler)
                listBg:setContentSize(CCSizeMake(cellWidth-20,cellHeight-2-self.normalHeight-addHeight))
                listBg:setTouchPriority(-(self.layerNum-1)*20-6)
                listBg:setIsSallow(true)
                listBg:setAnchorPoint(ccp(0,0))
                listBg:setPosition(ccp(10,0))
                listBg:setTag(2)
                cell:addChild(listBg,2)
                self.listBgTb[idx+1]=listBg

                local posy=listBg:getContentSize().height-20
                local lbTb={
                    {getlocal("alliance_event_time"),22,ccp(0.5,0.5),ccp(150,posy),listBg,2,G_ColorWhite,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
                    {getlocal("activity_zhanyoujijie_buy_gold"),22,ccp(0.5,0.5),ccp(400,posy),listBg,2,G_ColorWhite,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
                    -- {getlocal("award"),22,ccp(0.5,0.5),ccp(460,posy),listBg,2,G_ColorWhite,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
                }
                for k,v in pairs(lbTb) do
                    GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
                end

                local cellWidth1,cellHeight1=backSprie:getContentSize().width,40
                local isMoved
                local function tvCallBack1(handler,fn,idx1,cel)
                    if fn=="numberOfCellsInTableView" then
                        -- local acVo=acZhanyoujijieVoApi:getAcVo()
                        -- print("acVo",acVo)
                        -- if acVo then
                        --     local bindPlayers=acVo.bindPlayers or {}
                        --     local reInfo=bindPlayers[idx+1] or {}
                        --     print("reInfo",reInfo)
                            if reInfo and reInfo.reList then
                                return SizeOfTable(reInfo.reList)
                            end
                        -- end
                        return 0
                    elseif fn=="tableCellSizeForIndex" then
                        local tmpSize=CCSizeMake(cellWidth1,cellHeight1)
                        return tmpSize
                    elseif fn=="tableCellAtIndex" then
                        local cell1=CCTableViewCell:new()
                        cell1:autorelease()
                        local rechargeData
                        -- local bindPlayers=acVo.bindPlayers or {}
                        -- local reInfo=bindPlayers[idx+1] or {}
                        if reInfo and reInfo.reList and reInfo.reList[idx1+1] then
                            rechargeData=reInfo.reList[idx1+1]
                        end
                        if rechargeData then
                            local num=rechargeData[1] or 0
                            local time=rechargeData[2] or 0
                            local overflow=rechargeData[3]
                            local color=G_ColorWhite
                            if overflow and overflow>=0 then
                                color=G_ColorYellowPro
                            end

                            local lbTb1={
                                {G_getDateStr(time),22,ccp(0.5,0.5),ccp(150,cellHeight1/2),cell1,2,G_ColorWhite},
                                {num,22,ccp(0,0.5),ccp(400-50,cellHeight1/2),cell1,2,color},
                                -- {math.ceil(num*acCfg.ratio),22,ccp(0,0.5),ccp(460-40,cellHeight1/2),cell1,2,color},
                            }
                            for k,v in pairs(lbTb1) do
                                local lb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
                                if k==2 or k==3 then
                                    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
                                    gemIcon:setPosition(ccp(lb:getPositionX()+90,cellHeight1/2))
                                    cell1:addChild(gemIcon,2)
                                end
                            end
                        end

                        return cell1
                    elseif fn=="ccTouchBegan" then
                        isMoved=false
                        return true
                    elseif fn=="ccTouchMoved" then
                        isMoved=true
                    elseif fn=="ccTouchEnded"  then

                    end
                end
                local hd=LuaEventHandler:createHandler(tvCallBack1)
                local listTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth1,listBg:getContentSize().height-40),nil)
                listTv:setPosition(ccp(0,5))
                listTv:setTag(2)
                listTv:setTableViewTouchPriority(-(self.layerNum-1)*20-8)
                listBg:addChild(listTv,2)
                listTv:setMaxDisToBottomOrTop(80)
                if self.listTv==nil then
                    self.listTv={}
                end
                self.listTv[idx+1]=listTv
            end
            local list=acZhanyoujijieVoApi:getRechargeList(uid)
            if list and SizeOfTable(list)>0 then
                addExpand()
            else
                local function listCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.rechargeList then
                            local rechargeList=sData.data.rechargeList
                            acZhanyoujijieVoApi:setRechargeList(uid,rechargeList)
                            addExpand()
                        end
                    end
                end
                socketHelper:activeZhanyoujijieRechargeList(uid,listCallback)
            end
        end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acZhanyoujijieTab2:getAddHeight(idx,uid)
    local addHeight=0
    if self.hasRewardTb==nil then
        self.hasRewardTb={}
    end
    if self.hasRewardTb[idx+1]==nil then
        local isCan=acZhanyoujijieVoApi:canRewardState(uid)
        if isCan==true then
            self.hasRewardTb[idx+1]=1
            addHeight=80
        else
            self.hasRewardTb[idx+1]=0
        end
    elseif self.hasRewardTb[idx+1]==1 then
        addHeight=80
    end
    return addHeight
end


function acZhanyoujijieTab2:updateBindPlayers()
    if self.bindPlayers==nil then
        self.bindPlayers={}
    end
    local num1=SizeOfTable(self.bindPlayers)
    self.bindPlayers={}
    local acVo=acZhanyoujijieVoApi:getAcVo()
    if acVo and acVo.bindPlayers then
        local bindPlayers=acVo.bindPlayers or {}
        for k,v in pairs(bindPlayers) do
            if v and v.buyTotalNum and v.buyTotalNum>0 then
                table.insert(self.bindPlayers,v)
            end
        end
    end
    local num2=SizeOfTable(self.bindPlayers)
    local addNum=num2-num1
    return addNum
end

--显示一键领取奖励的面板
function acZhanyoujijieTab2:initGetAllRewardsView()
    if self.rewardWidget==nil then
        local function nilFun()
        end
        local rewardBgSP=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),nilFun)
        rewardBgSP:setContentSize(CCSizeMake(G_VisibleSize.width-40,100))
        rewardBgSP:setAnchorPoint(ccp(0.5,0))
        rewardBgSP:setPosition(self.bgLayer:getContentSize().width/2,-3*rewardBgSP:getContentSize().height)
        rewardBgSP:setTouchPriority(-(self.layerNum-1)*20-5)
        rewardBgSP:setIsSallow(false)
        self.bgLayer:addChild(rewardBgSP,3)

        local fadeBg=CCSprite:createWithSpriteFrameName("brown_fade1.png")
        fadeBg:setAnchorPoint(ccp(0.5,0.5))
        fadeBg:setPosition(ccp(rewardBgSP:getContentSize().width/2,rewardBgSP:getContentSize().height/2))
        fadeBg:setRotation(180)
        fadeBg:setScaleX((rewardBgSP:getContentSize().width-6)/fadeBg:getContentSize().width)
        fadeBg:setScaleY((rewardBgSP:getContentSize().height-10)/fadeBg:getContentSize().height)
        rewardBgSP:addChild(fadeBg)

        local isShow,rewardNum=acZhanyoujijieVoApi:isShowRewardAll()
        self.rewardDescLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_reward_desc",{rewardNum}),22,CCSizeMake(rewardBgSP:getContentSize().width-160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.rewardDescLb:setAnchorPoint(ccp(0,0.5))
        self.rewardDescLb:setPosition(ccp(30,rewardBgSP:getContentSize().height/2))
        rewardBgSP:addChild(self.rewardDescLb,2)

        local function rewardAllHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local isShow,rewardNum=acZhanyoujijieVoApi:isShowRewardAll()
            if isShow==true then
                local function rewardAllCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.zhanyoujijie then
                            acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                            self:refreshTv1()
                            self:hideRewardWidget()
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                        end
                    end
                end
                socketHelper:activeZhanyoujijieTakeUsersGems(rewardNum,rewardAllCallback)
            end
        end
        local iScale=0.8
        -- local rewardAllItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardAllHandler,nil,getlocal("activity_zhanyoujijie_reward_all"),25)
        local rewardAllItem=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardAllHandler,12,nil,nil)
        rewardAllItem:setScale(iScale)
        local rewardAllMenu=CCMenu:createWithItem(rewardAllItem)
        rewardAllMenu:setTouchPriority(-(self.layerNum-1)*20-9)
        rewardAllMenu:setPosition(rewardBgSP:getContentSize().width-70,rewardBgSP:getContentSize().height/2)
        rewardBgSP:addChild(rewardAllMenu,2)
        self.rewardWidget=rewardBgSP
    end
    if acZhanyoujijieVoApi:isShowRewardAll()==true then
        self:showRewardWidget()
    else
        self:hideRewardWidget()
    end
end
function acZhanyoujijieTab2:showRewardWidget()
    if self.rewardWidget then
        -- self:resetTv(false)
        self.rewardWidget:setVisible(true)
        local moveTo=CCMoveTo:create(1,CCPointMake(G_VisibleSize.width/2,20))
        self.rewardWidget:runAction(moveTo)
        self.rewardShow=true
    end
end
function acZhanyoujijieTab2:hideRewardWidget()
    if self.rewardWidget then
        -- self:resetTv(true)
        self.rewardWidget:setVisible(true)
        local moveTo=CCMoveTo:create(1,CCPointMake(G_VisibleSize.width/2,-3*self.rewardWidget:getContentSize().height))
        self.rewardWidget:runAction(moveTo)
        self.rewardShow=false
    end
end

function acZhanyoujijieTab2:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.contentBg:getContentSize().width-10,self.tvHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local numberCell=4
        local height = 100
        if G_isIphone5()==true then
            height = 140
        end
        local totalW = self.contentBg:getContentSize().width-10
        local totalH = self.tvHeight
        local spaceH = (self.tvHeight-numberCell*height)/2
        local acVo=acZhanyoujijieVoApi:getAcVo()
        local acCfg=acZhanyoujijieVoApi:getAcCfg()
        if acVo==nil or acCfg==nil then
            do return cell end
        end

        for i=1,numberCell do
            local rewards
            local acCfg=acZhanyoujijieVoApi:getAcCfg()
            if acCfg and acCfg.reward and acCfg.reward[i] then
                rewards=FormatItem(acCfg.reward[i],false,true)
            end

            local spWidth=500
            local posY=height/2+(i-1)*height+spaceH
            local state=acZhanyoujijieVoApi:getStateByRechargeLv(i)
            -- 判断 条件不足  可领取  已领取
            if state==0 then
                local hasRewardLb = GetTTFLabelWrap(getlocal("noReached"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                hasRewardLb:setPosition(ccp(spWidth,posY))
                cell:addChild(hasRewardLb)
            elseif state==1 then
                local function receiveHandler(tag,object)
                    if self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                        end
                        PlayEffect(audioCfg.mouseClick)

                        local function callBack(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if sData.data and sData.data.zhanyoujijie then
                                    acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                                    if self.tv2 then
                                        self.tv2:reloadData()
                                    end
                                    if rewards then
                                        for k,v in pairs(rewards) do
                                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                        end
                                        G_showRewardTip(rewards,true)
                                    end
                                end
                            end
                        end
                        local rid=i
                        socketHelper:activeZhanyoujijieRechargeReward(rid,callBack)
                    end               
                end
                local getBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnGraySmall_Down.png",receiveHandler,i,getlocal("daily_scene_get"),30)
                getBtn:setScale(0.7)
                local btnMenu=CCMenu:createWithItem(getBtn)
                btnMenu:setPosition(ccp(spWidth,posY))
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
                cell:addChild(btnMenu,1)
            else
                -- local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ( ... )end)
                -- lbBg:setContentSize(CCSizeMake(300,50))
                -- lbBg:setPosition(300,posY)
                -- lbBg:setOpacity(200)
                -- cell:addChild(lbBg,3)
                -- local hasRewardLb = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                -- hasRewardLb:setPosition(ccp(lbBg:getContentSize().width/2,lbBg:getContentSize().height/2))
                -- hasRewardLb:setColor(G_ColorGray)
                -- lbBg:addChild(hasRewardLb)

                local rightIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
                rightIcon:setAnchorPoint(ccp(0.5,0.5))
                rightIcon:setPosition(ccp(spWidth,posY))
                cell:addChild(rightIcon,1)
            end
            
            -- 刻度线
            local keduSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_fengexian.png")
            keduSp:setPosition(60,i*height+spaceH)
            cell:addChild(keduSp,3)

            --充值等级
            local numBgSp = CCSprite:createWithSpriteFrameName("recharge_numlabel.png")
            numBgSp:setAnchorPoint(ccp(0,1))
            numBgSp:setPosition(70,i*height+8+spaceH)
            cell:addChild(numBgSp,3)
            -- numBgSp:setPosition(53,numberCell*height*per+addH)

            local numLb=GetTTFLabel(acCfg.cost[i],22)
            numLb:setPosition(numBgSp:getContentSize().width/2+5,numBgSp:getContentSize().height/2)
            numBgSp:addChild(numLb)
                    
            local lineSprite = CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,0+(i-1)*height+spaceH))
            cell:addChild(lineSprite)

            if rewards then
                for k,v in pairs(rewards) do
                    local icon,scale=G_getItemIcon(v,80,true,self.layerNum)
                    if icon and scale then
                        icon:setTouchPriority(-(self.layerNum-1)*20-3)
                        cell:addChild(icon,2)
                        icon:setPosition(200+(k-1)*90, posY)

                        local numLabel=GetTTFLabel("x"..v.num,21)
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(icon:getContentSize().width-5, 5)
                        numLabel:setScale(1/scale)
                        icon:addChild(numLabel,1)
                    end 
                end
            end
        end

        local barWidth=numberCell*height
        local barBgH=totalH
        local function click(hd,fn,idx)
        end

        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_progressBg.png", CCRect(42,42,2,2),click)
        barSprie:setContentSize(CCSizeMake(86,barBgH-10))
        barSprie:setPosition(ccp(60,barBgH/2))
        cell:addChild(barSprie,1)

        AddProgramTimer(cell,ccp(60,barWidth/2+spaceH),11,12,nil,"acChunjiepansheng_progress2.png","acChunjiepansheng_progress1.png",13,1,1,nil,ccp(0,1))
        local per=acZhanyoujijieVoApi:getRechargePercent()
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setScaleY((barWidth)/timerSpriteLv:getContentSize().height)
        timerSpriteLv:setRotation(180)
        local bg = cell:getChildByTag(13)
        bg:setScaleY((barWidth)/bg:getContentSize().height)

        local moneyNode=CCNode:create()
        moneyNode:setAnchorPoint(ccp(0.5,0))
        cell:addChild(moneyNode)
        local goldIconSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIconSp:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(goldIconSp)
        local rechargeLabel = GetTTFLabel(getlocal("activity_baifudali_totalMoney"),25)
        rechargeLabel:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(rechargeLabel)
        local totalMoney=acVo.buyGems
        local moneyLabel=GetTTFLabel(tostring(totalMoney),25)
        moneyLabel:setAnchorPoint(ccp(0,0.5))
        moneyLabel:setColor(G_ColorYellowPro)
        moneyNode:addChild(moneyLabel)
        local mwidth=rechargeLabel:getContentSize().width+moneyLabel:getContentSize().width+goldIconSp:getContentSize().width
        local mheight=rechargeLabel:getContentSize().height
        moneyNode:setContentSize(CCSizeMake(mwidth,mheight))
        moneyNode:setPosition(ccp(totalW/2,totalH-mheight))
        rechargeLabel:setPosition(ccp(0,mheight/2))
        goldIconSp:setPosition(ccp(rechargeLabel:getContentSize().width,mheight/2))
        moneyLabel:setPosition(ccp(goldIconSp:getPositionX()+goldIconSp:getContentSize().width,mheight/2))

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded" then
    end
end

function acZhanyoujijieTab2:cellClick(idx,uid)
    if self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
        local addHeight=self:getAddHeight(idx-1000,uid)
        -- print("addHeight",addHeight)
        if self.expandIdx["k"..(idx-1000)]==nil then
            self.expandIdx["k"..(idx-1000)]=idx-1000
            self.tv1:openByCellIndex(idx-1000,self.normalHeight+addHeight)
        else
            -- if self.listBgTb[idx-1000+1] and self.listBgTb[idx-1000+1].setVisible then
            --     local bg=tolua.cast(self.listBgTb[idx-1000+1],"LuaCCScale9Sprite")
            --     bg:setVisible(false)
            -- end
            if self.listTv and self.listTv[idx-1000+1] and self.listTv[idx-1000+1].setVisible then
                self.listTv[idx-1000+1]:setVisible(false)
            end
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv1:closeByCellIndex(idx-1000,self.expandHeight+addHeight)
        end
    end
end

function acZhanyoujijieTab2:updateBuyGemsLb()
    if self.buyGemsLb then
        local acVo=acZhanyoujijieVoApi:getAcVo()
        self.buyGemsLb:setString(acVo.buyGems)
        if self.goldSp then
            local px,py=self.buyGemsLb:getPosition()
            self.goldSp:setPosition(ccp(px+self.buyGemsLb:getContentSize().width+20,py))
        end
    end
end

function acZhanyoujijieTab2:refreshTv1()
    local num1=0
    local tmpTb=G_clone(self.hasRewardTb)
    for k,v in pairs(self.hasRewardTb) do
        if v and v==1 then
            num1=num1+1
        end
    end
    self.hasRewardTb={}
    local addNum=self:updateBindPlayers()
    local num=SizeOfTable(self.bindPlayers)
    if self.tv1 then
        if num==1 or self.expandIdx==nil or (self.expandIdx and SizeOfTable(self.expandIdx)==0) then
            self.tv1:reloadData()
        else
            local tmpIndex
            for k,v in pairs(self.expandIdx) do
                if v then
                    tmpIndex=v+1
                end
            end
            local recordPoint=self.tv1:getRecordPoint()
            self.tv1:reloadData()
            if addNum and addNum>0 then
                recordPoint.y=recordPoint.y-(addNum*(self.normalHeight+80))
            else
                local num2=0
                for k,v in pairs(self.hasRewardTb) do
                    if v and v==1 then
                        if tmpTb[k]==0 and tmpIndex and tmpIndex>k then
                        else
                            num2=num2+1
                        end
                    elseif v and v==0 then
                        if tmpTb[k]==1 and tmpIndex and tmpIndex>k then
                            num2=num2+1
                        end
                    end
                end
                local addRewardNum=num2-num1
                if addRewardNum then
                    recordPoint.y=recordPoint.y-(addRewardNum*80)
                end
            end
            self.tv1:recoverToRecordPoint(recordPoint)
        end
    end
end

function acZhanyoujijieTab2:tick()
    if acZhanyoujijieVoApi:getRefreshFlag()==1 then
        acZhanyoujijieVoApi:setRefreshFlag(0)
        self:refreshTv1()
        local isShow,rewardNum=acZhanyoujijieVoApi:isShowRewardAll()
        if self.rewardDescLb then
            self.rewardDescLb:setString(getlocal("activity_zhanyoujijie_reward_desc",{rewardNum}))
        end
        if self.rewardShow==false and isShow==true then
            self:showRewardWidget()
        end
    end
end

function acZhanyoujijieTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.listTv=nil
    self.expandIdx=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.contentBg=nil
    self.hasRewardTb=nil
    self.listBgTb=nil
    self.rewardDescLb=nil
    self.rechargeList=nil
    self.isMoved=nil
end