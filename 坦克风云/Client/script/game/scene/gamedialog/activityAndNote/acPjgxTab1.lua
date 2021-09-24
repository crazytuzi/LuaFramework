acPjgxTab1={

}

function acPjgxTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=nil
    nc.cellHeight=145

    return nc;
end

function acPjgxTab1:init(layerNum,parent)
    self.activeName=acPjgxVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initUp()
    self:initCenter()
    self:initTableView()
    return self.bgLayer
end

function acPjgxTab1:initUp()
    local lbH=self.bgLayer:getContentSize().height-185
    local bgSp
    local function addPlist()
        bgSp = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
        bgSp:setAnchorPoint(ccp(0.5,0))
    end
    G_addResource8888(addPlist)

    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,180))
    clipper:setPosition(G_VisibleSizeWidth/2,lbH+25)
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(G_VisibleSizeWidth-50,180),1,1)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper)

    clipper:addChild(bgSp)
    bgSp:setPosition(clipper:getContentSize().width/2,0)
    bgSp:setOpacity(160)
    bgSp:setFlipX(true)

    local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(G_VisibleSizeWidth/2,lbH-163)
    self.bgLayer:addChild(lineSp,1)
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2+60,lbH-25))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    local acVo = acPjgxVoApi:getAcVo()
    lbH=lbH-30
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+60, lbH-30))
    self.bgLayer:addChild(timeLabel)
    self.timeLabel=timeLabel
    G_updateActiveTime(acVo,self.timeLabel)

    local cfg=acPjgxVoApi:getActiveCfg()
    local nbReward=cfg.icon
    local nbItem=FormatItem(nbReward)
    local icon,scale=G_getItemIcon(nbItem[1],100,true,self.layerNum,nil,nil,getlocal("activity_pjgx_addDesc"),nil,true)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(40,lbH-40)
    self.bgLayer:addChild(icon,2)
    icon:setScale(120/icon:getContentSize().width)

    local pos=ccp(self.bgLayer:getContentSize().width-70,self.bgLayer:getContentSize().height-210)
    local tabStr={" ",getlocal("activity_pjgx_tip4"),getlocal("activity_pjgx_tip3"),getlocal("activity_pjgx_tip2"),getlocal("activity_pjgx_tip1")," "}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,nil)

    lbH=lbH-35
    local acDesLb,desLabe =nil
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        acDesLb=GetTTFLabelWrap(getlocal("activity_pjgx_des"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        acDesLb:setAnchorPoint(ccp(0.5,1))
        self.bgLayer:addChild(acDesLb,1)
        acDesLb:setPosition(235+25+120,lbH-30)
    else
        acDesLb,desLabel=G_LabelTableView(CCSizeMake(400,60),getlocal("activity_pjgx_des"),23,kCCTextAlignmentLeft)
        self.bgLayer:addChild(acDesLb,1)
        acDesLb:setPosition(ccp(230,lbH-90))
        acDesLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        acDesLb:setMaxDisToBottomOrTop(100)
    end

    local desBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    self.bgLayer:addChild(desBg)
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(235+25+120,lbH-25)
    desBg:setScaleX((acDesLb:getContentSize().width+50)/desBg:getContentSize().width)
    desBg:setScaleY((math.max(acDesLb:getContentSize().height+10,40))/desBg:getContentSize().height)
    desBg:setOpacity(180)


end

function acPjgxTab1:initCenter()
    local startH=self.bgLayer:getContentSize().height-185-180+15

    local activeScoreLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab2_des1"),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    activeScoreLb:setAnchorPoint(ccp(0,1))
    activeScoreLb:setPosition(40,startH)
    self.bgLayer:addChild(activeScoreLb)
    self.activeScoreLb=activeScoreLb

    local posY=startH-115
    self.posY=posY

    self:initOrRefreshProgress()

    local desLbH=posY-45
    local desLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab2_des2"),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(desLb)
    desLb:setPosition(G_VisibleSizeWidth/2,desLbH)
    self.desLb=desLb

end

function acPjgxTab1:initOrRefreshProgress(flag)
    local posY=self.posY
    if flag then
        local timerSpriteLv=self.bgLayer:getChildByTag(11)
        if timerSpriteLv then
            timerSpriteLv:removeFromParentAndCleanup(true)
        end
        local timerSpriteBg=self.bgLayer:getChildByTag(13)
        if timerSpriteBg then
            timerSpriteBg:removeFromParentAndCleanup(true)
        end
    end
    local cfg=acPjgxVoApi:getActiveCfg()
    local needPoint=cfg.taskPoint
    local pointPrize=cfg.taskPointReward
    -- local needPoint={50,100,200,300}

    local acPoint=acPjgxVoApi:getPoint()
    -- local acPoint=100
    local percentStr=""
    local centerWidth=G_VisibleSizeWidth/2

    self.activeScoreLb:setString(getlocal("activity_znkh2017_tab2_des1",{acPoint}))

    local barWidth=500
    local per=G_getPercentage(acPoint,needPoint)
    AddProgramTimer(self.bgLayer,ccp(centerWidth-15,posY),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
    local timerSpriteLv=self.bgLayer:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    local timerSpriteBg=self.bgLayer:getChildByTag(13)
    timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
    -- local scalex=barWidth/timerSpriteBg:getContentSize().width
    -- timerSpriteBg:setScaleX(scalex)
    -- timerSpriteLv:setScaleX(scalex)

    local totalWidth=timerSpriteBg:getContentSize().width
    local totalHeight=timerSpriteBg:getContentSize().height
    local everyWidth=totalWidth/SizeOfTable(needPoint)

    -- 当前值
    local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
    acSp:setPosition(ccp(0,totalHeight/2))
    timerSpriteLv:addChild(acSp,2)

    local acPointLb=GetBMLabel(acPoint,G_GoldFontSrc,10)
    acPointLb:setPosition(ccp(acSp:getContentSize().width/2,acSp:getContentSize().height/2-2))
    acSp:addChild(acPointLb,2)
    acPointLb:setScale(0.4)

    for k,v in pairs(needPoint) do
        local acSp1=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
        acSp1:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(acSp1,1)
        acSp1:setScale(1.2)
        local acSp2=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
        acSp2:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(acSp2,1)
        acSp2:setScale(1.2)
        if acPoint>=v then
            acSp2:setVisible(true)
        else
            acSp2:setVisible(false)
        end
        local numLb=GetBMLabel(v,G_GoldFontSrc,10)
        numLb:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(numLb,3)
        numLb:setScale(0.3)

        -- flag 1 未达成 2 可领取 3 已领取
        local flag=acPjgxVoApi:getLuckState(k)

        local function clickBoxHandler( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local titleStr=getlocal("activity_openyear_baoxiang" .. k)
            if flag~=2 then
                local reward={pointPrize[k]}
                -- activity_openyear_baoxiang1
                local titleColor
                if k==1 then
                    titleColor=G_ColorWhite
                elseif k==2 then
                    titleColor=G_ColorGreen
                elseif k==3 then
                    titleColor=G_ColorBlue
                elseif k==4 then
                    titleColor=G_ColorPurple
                elseif k==5 then
                    titleColor=G_ColorOrange
                end
                local desStr=getlocal("activity_openyear_allreward_des")
                acPjgxVoApi:showRewardKu(titleStr,self.layerNum,reward,desStr,titleColor)
                return
            end

            local function refreshFunc()
                self:initOrRefreshProgress(true)
                if k==4 then
                    local desStr
                    desStr="activity_pjgx_chatMessage1"
                    local paramTab={}
                    paramTab.functionStr="pjgx"
                    paramTab.addStr="i_also_want"
                    local message={key=desStr,param={playerVoApi:getPlayerName(),getlocal("activity_pjgx_title"),titleStr}}
                    chatVoApi:sendSystemMessage(message,paramTab)
                end

                -- 此处加弹板
                local rewardItem=FormatItem(pointPrize[k],nil,true)
                for k,v in pairs(rewardItem) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                acPjgxVoApi:showRewardDialog(rewardItem,self.layerNum)
            end
            local action=1
            local tid=k
            acPjgxVoApi:socketPjgx2017(refreshFunc,action,tid)

        end

        local boxScale=0.7
        local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..k..".png",clickBoxHandler)
        boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
        boxSp:setPosition(everyWidth*k,totalHeight+45)
        timerSpriteLv:addChild(boxSp,3)
        boxSp:setScale(boxScale)

        
        if flag==2 then
            local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            lightSp:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(lightSp)
            lightSp:setScale(0.5)

            local time = 0.1--0.07
            local rotate1=CCRotateTo:create(time, 30)
            local rotate2=CCRotateTo:create(time, -30)
            local rotate3=CCRotateTo:create(time, 20)
            local rotate4=CCRotateTo:create(time, -20)
            local rotate5=CCRotateTo:create(time, 0)
            local delay=CCDelayTime:create(1)
            local acArr=CCArray:create()
            acArr:addObject(rotate1)
            acArr:addObject(rotate2)
            acArr:addObject(rotate3)
            acArr:addObject(rotate4)
            acArr:addObject(rotate5)
            acArr:addObject(delay)
            local seq=CCSequence:create(acArr)
            local repeatForever=CCRepeatForever:create(seq)
            boxSp:runAction(repeatForever)
        elseif flag==3 then
            local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
            -- lbBg:setContentSize(CCSizeMake(150,40))
            lbBg:setScaleX(150/lbBg:getContentSize().width)
            lbBg:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(lbBg,4)
            lbBg:setScale(0.7)
            local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
            hasRewardLb:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(hasRewardLb,5)
        end
    end
end

function acPjgxTab1:initTableView()
    local startH=self.posY-50-30-self.desLb:getContentSize().height/2

    local function nilFunc()
    end
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    bottomBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,startH))
    bottomBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
    bottomBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(bottomBg)

    local bottomSize=bottomBg:getContentSize()

    local smallTitleLb1=GetTTFLabel(getlocal("activity_ganenjiehuikui_eveTask"),28)
    -- smallTitleLb1:setColor(G_ColorYellowPro)
    smallTitleLb1:setAnchorPoint(ccp(0.5,0.5))
    smallTitleLb1:setPosition(ccp(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2))
    bottomBg:addChild(smallTitleLb1,1)

    local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
    bottomBg:addChild(titleBg1)
    titleBg1:setPosition(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2)
    titleBg1:setContentSize(CCSizeMake(smallTitleLb1:getContentSize().width+150,math.max(smallTitleLb1:getContentSize().height,50)))


    self.taskTb=acPjgxVoApi:getCurrentTaskState()
    self.cellNum=SizeOfTable(self.taskTb)
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-80,bottomSize.height-75),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(40,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acPjgxTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-80,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local strSize2,strSize3,strWidth2 = 23,20,600
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
            strSize2,strSize3,strWidth2 = 25,22,400
        end

        local function nilFunc()
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
        backSprie:setContentSize(CCSizeMake(
        G_VisibleSizeWidth-80,self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)

        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,backSprie:getContentSize().height/2))
        backSprie:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height/2))
        backSprie:addChild(pointSp2)

        local valueTb=self.taskTb[idx+1].value
        local typeStr=valueTb[1][1]
        local index=self.taskTb[idx+1].index

        local titleStr
        if typeStr=="gb" then
            titleStr=getlocal("activity_chunjiepansheng_" .. typeStr .. "_title",{self.taskTb[idx+1].haveNum .. "/" .. valueTb[1][2]}) .. getlocal("gem")
        else
            titleStr=getlocal("activity_chunjiepansheng_" .. typeStr .. "_title",{self.taskTb[idx+1].haveNum,valueTb[1][2]})

        end

        local lbStarWidth=20
        if G_getCurChoseLanguage() =="ar" then
            strWidth2 = strWidth2 -100
        end
        local titleLb=GetTTFLabelWrap(titleStr,strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-15))
        backSprie:addChild(titleLb,1)

        -- 奖励描述
        local desH=(self.cellHeight - titleLb:getContentSize().height-10)/2
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- 奖励展示
        local rewardItem=FormatItem(valueTb[3],nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*90+20, desH)
            local scale=80/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100


            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
        end

        
        if index>10000 then -- 已完成(已领取)
            local alreadyLb=GetTTFLabel(getlocal("activity_hadReward"),25)
            alreadyLb:setColor(G_ColorWhite)
            alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(alreadyLb,1)
            alreadyLb:setColor(G_ColorGray)
        elseif index>1000 then -- 未完成
            local function goTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    
                    if typeStr=="gg" then
                        self.parent:tabClick(1)
                        return
                    else
                        PlayEffect(audioCfg.mouseClick)
                    end
                    G_goToDialog2(typeStr,4,true)
                end

            end
            local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25/0.8)
            goItem:setScale(0.8)
            local goBtn=CCMenu:createWithItem(goItem);
            goBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            goBtn:setPosition(ccp(backSprie:getContentSize().width-95,backSprie:getContentSize().height/2))
            backSprie:addChild(goBtn)
        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local action=2
                    local tid=index%10
                    local nf=self.taskTb[idx+1].nf

                    local function refreshFunc()
                        self:initOrRefreshProgress(true)
                        self:refresh()
                        -- 此处加弹板
                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        acPjgxVoApi:showRewardDialog(rewardItem,self.layerNum)
                    end
                    acPjgxVoApi:socketPjgx2017(refreshFunc,action,tid,typeStr,nil,nf)

                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),25/0.8)
            rMenuItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rMenuItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-95,backSprie:getContentSize().height/2))
            backSprie:addChild(rewardBtn)
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

function acPjgxTab1:refresh()
    if self.tv then
        self.taskTb=acPjgxVoApi:getCurrentTaskState()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acPjgxTab1:tick()
    if self.timeLabel then
        local acVo = acPjgxVoApi:getAcVo()
        if acVo then
            G_updateActiveTime(acVo,self.timeLabel)
        end
    end
    
end

function acPjgxTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
