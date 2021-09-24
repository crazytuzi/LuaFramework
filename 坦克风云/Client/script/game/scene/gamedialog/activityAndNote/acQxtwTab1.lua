acQxtwTab1={
}

function acQxtwTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acQxtwTab1:init()

    
    self.bgLayer=CCLayer:create()

    self.addH=0
    if G_getIphoneType() == G_iphoneX then
        self.addH = 150
    elseif(G_isIphone5())then
        self.addH=120
    end
    self.startPos=ccp(57.5, 282.5)
    self.startPos.y=self.startPos.y+self.addH
    -- 路线1，2，3
    -- {tb,num,pos} num:这条线的第几步  pos:对应的点的序号
    self.linePos1={{ccp(127.5, 273.5),1,1},{ccp(107.5, 302.5)},{ccp(102.5, 319.5)},{ccp(105.5, 335.5)},{ccp(113.5, 350.5)},{ccp(135.5, 379.5)},{ccp(149.5, 404.5)},{ccp(158.5, 433.5),2,2},{ccp(166.5, 449.5)},{ccp(183.5, 463.5)},{ccp(202.5, 470.5)},{ccp(222.5, 471.5)},{ccp(240.5, 469.5)},{ccp(261.5, 463.5)},{ccp(287.5, 457.5)},{ccp(323.5, 453.5)},{ccp(352.5, 455.5),3,4},{ccp(381.5, 454.5)},{ccp(396.5, 448.5)},{ccp(434.5, 421.5)},{ccp(472.5, 395.5)},{ccp(503.5, 383.5)},{ccp( 527.5, 384.5)},{ccp(548.5, 388.5),4,8}}
    self.linePos2={{ccp(127.5, 273.5),1,1},{ccp(161.5, 288.5)},{ccp(202.5, 303.5)},{ccp(239.5, 309.5)},{ccp(269.5, 311.5)},{ccp(309.5, 305.5)},{ccp(334.5, 297.5),2,5},{ccp(368.5, 292.5)},{ccp(410.5, 295.5)},{ccp(458.5, 309.5)},{ccp(508.5, 338.5)},{ccp(533.5, 364.5)},{ccp(548.5, 388.5),3,8}}
    self.linePos3={{ccp(127.5, 273.5),1,1},{ccp(135.5, 240.5)},{ccp(145.5, 224.5)},{ccp(159.5, 214.5)},{ccp(188.5, 205.5),2,3},{ccp(224.5, 196.5)},{ccp(253.5, 190.5)},{ccp(282.5, 188.5)},{ccp(318.5, 190.5)},{ccp(357.5, 199.5),3,6},{ccp(389.5, 215.5)},{ccp(427.5, 232.5)},{ccp(477.5, 245.5)},{ccp(539.5, 251.5),4,7},{ccp(559.5, 276.5)},{ccp(568.5, 298.5)},{ccp(573.5, 320.5)},{ccp(571.5, 345.5)},{ccp(564.5, 368.5)},{ccp(548.5, 388.5),5,8}}


    for k,v in pairs(self.linePos1) do
        v[1].y=v[1].y+self.addH
    end
    for k,v in pairs(self.linePos2) do
        v[1].y=v[1].y+self.addH
    end
    for k,v in pairs(self.linePos3) do
        v[1].y=v[1].y+self.addH
    end

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acQxtwTab1:initUI()
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    local function touchDialog()
        if self.state == 2 then
            PlayEffect(audioCfg.mouseClick)
            self.state=3 
        end
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.touchDialogBg,1)

    -- 活动 时间 描述
    local lbH=self.bgLayer:getContentSize().height-185
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)

    local acVo = acQxtwVoApi:getAcVo()
    lbH=lbH-35
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel,1)
    self.timeLb=timeLabel
    self:updateAcTime()


    lbH=lbH-35


    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210+7)

    if(G_isIphone5())then
        actTime:setPositionY(actTime:getPositionY()-10)
        timeLabel:setPositionY(timeLabel:getPositionY()-10)
        pos.y=pos.y-10
    end

    local tabStr={" ",getlocal("activity_qxtw_info5"),getlocal("activity_qxtw_info4"),getlocal("activity_qxtw_info3"),getlocal("activity_qxtw_info2"),getlocal("activity_qxtw_info1")," "}
    local colorTab={}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,colorTab,nil,nil,nil,1)

    local bsH=150
    if(G_isIphone5())then
        bsH=180
    end
    local function nilFunc()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png",CCRect(20, 20, 10, 10),nilFunc)
    backSprie:setContentSize(CCSizeMake(298*2,bsH))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(G_VisibleSizeWidth/2,lbH)
    self.bgLayer:addChild(backSprie,1)
    backSprie:setOpacity(0)

    if(G_isIphone5())then
        backSprie:setPositionY(backSprie:getPositionY()-15)
    end
    -- acQxtw_titleBg
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 30
    end
    local titleBg1=CCSprite:createWithSpriteFrameName("acQxtw_titleBg.png")
    backSprie:addChild(titleBg1)
    titleBg1:setAnchorPoint(ccp(1,0.5))
    titleBg1:setPosition(backSprie:getContentSize().width,backSprie:getContentSize().height/2-adaH)


    local titleBg2=CCSprite:createWithSpriteFrameName("acQxtw_titleBg.png")
    backSprie:addChild(titleBg2)
    titleBg2:setAnchorPoint(ccp(1,0.5))
    titleBg2:setFlipX(true)
    titleBg2:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2-adaH)

    if(G_isIphone5())then
        titleBg1:setScaleY(180/titleBg1:getContentSize().height)
        titleBg2:setScaleY(180/titleBg2:getContentSize().height)
    end

    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    backSprie:addChild(guangSp)
    guangSp:setPosition(80,backSprie:getContentSize().height/2-adaH)
    guangSp:setScale(1.2)

    
    local exchange=acQxtwVoApi:getExchange()
    if not exchange then
        return
    end
    local getkey
    for k,v in pairs(exchange.get[2]) do
        getkey=k
    end

    local function emblemInfo()
        local cfg = emblemVoApi:getEquipCfgById(getkey)
        local eVo = emblemVo:new(cfg)
        if(eVo)then
            eVo:initWithData(getkey,0,0)
            emblemVoApi:showInfoDialog(eVo,self.layerNum + 1,true)
        end
    end
    local icon=emblemVoApi:getEquipIconNoBg(getkey,28,nil,emblemInfo)
    backSprie:addChild(icon)
    icon:setPosition(80,backSprie:getContentSize().height/2-adaH)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    local scale=100/icon:getContentSize().width
    icon:setScale(scale)

    local nameLb=tolua.cast(icon:getChildByTag(1),"CCLabelTTF")
    nameLb:setDimensions(CCSizeMake(400,0))
    nameLb:setHorizontalAlignment(kCCTextAlignmentLeft)
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(140,icon:getContentSize().height-35-adaH/2)
    nameLb:setScale(1/scale)
    -- nameLb:setColor(G_ColorOrange)

    local needLb=GetTTFLabel(getlocal("activity_qxtw_need"),25)
    needLb:setAnchorPoint(ccp(0,0))
    icon:addChild(needLb)
    needLb:setPosition(140,0)
    needLb:setScale(1/scale)

    local needItem=FormatItem(exchange.need[2])[1]
    self.needItem=needItem
    local needIcon,scale=G_getItemIcon(needItem,100,true,self.layerNum,nil,nil,nil,nil,true)
    scale=60/needIcon:getContentSize().width
    needIcon:setAnchorPoint(ccp(0,0))
    needLb:addChild(needIcon)
    needIcon:setPosition(needLb:getContentSize().width,0)
    needIcon:setScale(scale)
    needIcon:setTouchPriority(-(self.layerNum-1)*20-4)

    self.starPosX=needLb:getContentSize().width+65

    local haveNum=bagVoApi:getItemNumId(needItem.id)
    local haveLb=GetTTFLabel(haveNum,25)
    needLb:addChild(haveLb)
    haveLb:setAnchorPoint(ccp(0,0))
    haveLb:setPosition(self.starPosX,0)
    self.haveLb=haveLb
    if needItem.num>haveNum then
        haveLb:setColor(G_ColorRed)
    end

    local totalLb=GetTTFLabel("/" .. needItem.num,25)
    needLb:addChild(totalLb)
    totalLb:setAnchorPoint(ccp(0,0))
    totalLb:setPosition(self.starPosX+haveLb:getContentSize().width,0)
    self.totalLb=totalLb

    local function composeFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end
        local haveNum=bagVoApi:getItemNumId(self.needItem.id)
        local needNum=self.needItem.num
        if needNum>haveNum then
            return
        end

        local function refreshFunc(reward)
            local paramTab={}
            paramTab.functionStr=acQxtwVoApi:getActiveName()
            paramTab.addStr="i_also_want"
            local message={key="activity_qxtw_message",param={playerVoApi:getPlayerName(),getlocal("activity_qxtw_title"),self.needItem.name,getlocal("emblem_name_"..getkey)}}
            chatVoApi:sendSystemMessage(message,paramTab)

            bagVoApi:useItemNumId(self.needItem.id,needNum)
            self:refreshSuipian()
            self:showGetReward(reward,self.layerNum+1)
        end
        acQxtwVoApi:emblemCompose(refreshFunc)
    end
    local composeItem=GetButtonItem("acQxtw_btn.png","acQxtw_btn_down.png","acQxtw_btn.png",composeFunc,nil,getlocal("compose"),25)
    -- rewardItem:setScale(0.8)
    self.composeItem=composeItem
    local composeBtn=CCMenu:createWithItem(composeItem);
    composeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    composeBtn:setPosition(ccp(backSprie:getContentSize().width-110,backSprie:getContentSize().height/2-adaH))
    backSprie:addChild(composeBtn)
    composeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    if(acQxtwVoApi:getVersion()==3)then
        local function onReport()
            local exchange=acQxtwVoApi:getExchange()
            if not exchange then
                return
            end
            local getkey
            for k,v in pairs(exchange.get[2]) do
                getkey=k
            end
            local report=acQxtwVoApi:getShowReport(getkey)
            if(report)then
                report=G_Json.decode(report)
                local isAttacker=true
                local data={data={report=report},isAttacker=isAttacker,isReport=true}
                local playerData=data.data.report.p
                local nameStr1 = (tostring(playerData[1][1]))
                local nameStr2 = (tostring(playerData[2][1]))
                data.data.report.p[1][1]=nameStr1
                data.data.report.p[2][1]=nameStr2
                battleScene:initData(data,true)
            end
        end
        self.reportItem=GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn_down.png",onReport)
        local reportBtn=CCMenu:createWithItem(self.reportItem)
        reportBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        reportBtn:setPosition(backSprie:getContentSize().width - 110,backSprie:getContentSize().height/2)
        backSprie:addChild(reportBtn)
    end
    self:refreshSuipian()

    
    local function sureHandler(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end

        local rand
        local needCost=0
        if tag==1 then
            local flag=acQxtwVoApi:isDailyFree()
            if flag==0 then
                rand=1
            else
                rand=2
                needCost=acQxtwVoApi:getCostByType(1)
            end
        else
            rand=3
            needCost=acQxtwVoApi:getCostByType(2)
        end
        local gems=playerVoApi:getGems()
        if needCost>gems then
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,needCost-gems,self.layerNum+1,needCost,onSure)
            return
        end

        local cmd="active.quanxiantuwei.rand"
        local function refreshFunc(reward,report)
            -- 扣除金币
            playerVoApi:setGems(playerVoApi:getGems()-needCost)
            self.touchDialogBg:setIsSallow(true)
            self:refreshCostLb()
            self:refreshSuipian()
            self.state=2
            self.reward=reward
            self.report=report
            self:runTuweiAction(reward,report)
            self:runZhenAction(rand,report)
        end

        acQxtwVoApi:socketQxtw(cmd,rand,nil,refreshFunc)
        

    end

    local subAddH=30
    if(G_isIphone5())then
        subAddH=60
    end
    local function callback1()
        sureHandler(1)
    end
    local function callback2()
        sureHandler(2)
    end
    local menuPosY=40
    local menuItem={}
    menuItem[1]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback1,nil,getlocal("activity_qxtw_btn1"),strSize2)
    menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback2,nil,getlocal("activity_qxtw_btn2"),strSize2)
    self.menuItem1=menuItem[1]
    self.menuItem2=menuItem[2]
    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    btnMenu:alignItemsHorizontallyWithPadding(160)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(menuPosY+subAddH)

    local freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback1,nil,getlocal("activity_qxtw_btn1"),strSize2)
    local freeBtn=CCMenu:createWithItem(freeItem)
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.freeItem=freeItem
    freeBtn:setPosition(G_VisibleSizeWidth/2-80-freeItem:getContentSize().width/2,menuPosY)
    self.bgLayer:addChild(freeBtn)
    freeBtn:setPositionY(menuPosY+subAddH)

    local costLbPosY=90
    self.costLb={}
    for i=1,2 do
        local costNum=acQxtwVoApi:getCostByType(i)
        local costLb=GetTTFLabel(costNum .. "  ",25)
        costLb:setAnchorPoint(ccp(0,0.5))
        menuItem[i]:addChild(costLb)
        self.costLb[i]=costLb

        if i==1 then
            local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 25)
            freeLb:setPosition(ccp(menuItem[i]:getContentSize().width/2, costLbPosY))
            freeLb:setColor(G_ColorGreen)
            freeItem:addChild(freeLb)
            self.freeLb=freeLb
        end

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setAnchorPoint(ccp(0,0.5))
        goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
        costLb:addChild(goldIcon,1)

        costLb:setPosition(menuItem[i]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,costLbPosY)
    end
    self:refreshCostLb()
end


function acQxtwTab1:refreshCostLb()
    if self.freeLb then
        if acQxtwVoApi:isDailyFree()==0 then
            self.freeLb:setVisible(true)
            self.costLb[1]:setVisible(false)
            self.freeItem:setVisible(true)
            self.freeItem:setEnabled(true)
            self.menuItem1:setVisible(false)
            self.menuItem1:setEnabled(false)
            self.menuItem2:setEnabled(false)
        else
            self.freeLb:setVisible(false)
            self.costLb[1]:setVisible(true)
            self.freeItem:setVisible(false)
            self.freeItem:setEnabled(false)
            self.menuItem1:setVisible(true)
            self.menuItem1:setEnabled(true)
            self.menuItem2:setEnabled(true)
        end
        -- 设置颜色
        local cost1=acQxtwVoApi:getCostByType(1)
        local cost2=acQxtwVoApi:getCostByType(2)
        local gems=playerVoApi:getGems() or 0
        if cost1>gems then
            self.costLb[1]:setColor(G_ColorRed)
        else
            self.costLb[1]:setColor(G_ColorWhite)
        end
        if cost2>gems then
            self.costLb[2]:setColor(G_ColorRed)
        else
            self.costLb[2]:setColor(G_ColorWhite)
        end
    end
    
end

function acQxtwTab1:refreshSuipian()
    if self.haveLb then
        local haveNum=bagVoApi:getItemNumId(self.needItem.id)
        self.haveLb:setString(haveNum)
        self.totalLb:setPosition(self.starPosX+self.haveLb:getContentSize().width,0)
        if self.needItem.num>haveNum then
            self.haveLb:setColor(G_ColorRed)
            self.composeItem:setEnabled(false)
            if(self.reportItem)then
                self.composeItem:setVisible(false)
                self.reportItem:setEnabled(true)
                self.reportItem:setVisible(true)
            end
        else
            self.haveLb:setColor(G_ColorWhite)
            self.composeItem:setEnabled(true)
            if(self.reportItem)then
                self.composeItem:setVisible(true)
                self.reportItem:setEnabled(false)
                self.reportItem:setVisible(false)
            end
        end
    end
   
end

function acQxtwTab1:endAction(reward,report)
    self.touchDialogBg:setIsSallow(false)
    -- self.tankTb
    for k,v in pairs(self.tankTb) do
        if v then
            v:stopAllActions()
            v:removeFromParentAndCleanup(true)
        end
    end
    for k,v in pairs(self.lineLiangTb) do
        if v then
            v:setVisible(false)
        end
    end
    self.tankTb={}
    self.state=0
    for i=1,5 do
        self:removeFlicker(self.bgLayer,1000+i)
    end
    
    if SizeOfTable(report)==1 then
        -- self.colorTb
        local color=self:getColor(report[1])
        local colorType
        if color==1 then
            colorType=G_ColorGreen
        elseif color==2 then
            colorType=G_ColorBlue
        elseif color==3 then
            colorType=G_ColorPurple
        else
            colorType=G_ColorOrange
        end
        local award1=FormatItem(report[1][3])[1]

        local subStr=getlocal("activity_qxtw_rewardDes" .. color)
        local rewardPromptStr=getlocal("activity_qxtw_twDes" .. report[1][1],{subStr,award1.name .. "*" .. award1.num})
        acQxtwVoApi:showRewardDialog(reward,self.layerNum,rewardPromptStr,colorType)
    else
        local content={}
        local msgContent={}
        for k,v in pairs(report) do
            local color=self:getColor(v)
            local award1=FormatItem(v[3])[1]

            local subStr=getlocal("activity_qxtw_rewardDes" .. color)
            local desStr=getlocal("activity_qxtw_twDes1" .. v[1],{subStr,award1.name .. "*" .. award1.num})

            table.insert(content,{award=award1})
            local colorType
            if color==1 then
                colorType=G_ColorGreen
            elseif color==2 then
                colorType=G_ColorBlue
            elseif color==3 then
                colorType=G_ColorPurple
            else
                colorType=G_ColorOrange
            end
            table.insert(msgContent,{desStr,colorType})
        end
        local function confirmHandler()
        end
        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_qxtw_title"),content,nil,true,self.layerNum+1,confirmHandler,nil,nil,nil,nil,nil,msgContent,nil,nil,nil,nil,nil,nil,nil,nil,180,true)
    end
    
    self.zhenSp:stopAllActions()
    self.zhenSp:setRotation(0)
    self.tankSp:setVisible(true)
    for k,v in pairs(self.kdSp) do
        v:setVisible(true)
        if self.huSp[k] then
            self.huSp[k]:setVisible(true)
        end
        
    end
    self.reward=nil

end

function acQxtwTab1:getColor(report)
    local lineTb
    if report[1]==1 then
        lineTb=self.linePos1
    elseif report[1]==2 then
        lineTb=self.linePos2
    else
        lineTb=self.linePos3
    end
    local subStr=""
    for k,v in pairs(lineTb) do
        if v[2]==report[2] and v[3] then
            return self.colorTb[v[3]]
        end
    end
    return 1
end

function acQxtwTab1:runZhenAction(rand,report)
    local acArr=CCArray:create()
    -- self.zhenSp
    local time=0.5
    if rand==3 then
        local rotate1=CCRotateTo:create(time, 180)
        local rotate2=CCRotateTo:create(time, 0)
        acArr:addObject(rotate1)
        acArr:addObject(rotate2)
        local seq=CCSequence:create(acArr)
        local repeatForever=CCRepeatForever:create(seq)
        self.zhenSp:runAction(repeatForever)
        for k,v in pairs(self.kdSp) do
            -- if k<=stepNum then
                v:setVisible(false)
                if self.huSp[k] then
                    self.huSp[k]:setVisible(false)
                end
                
            -- end
        end
    else
        time=0.3
        local stepNum=report[1][2]
        local rotate1=CCRotateTo:create(time, stepNum*36+20)
        local rotate2=CCRotateTo:create(time, stepNum*36-20)
        local rotate3=CCRotateTo:create(time, stepNum*36)
        acArr:addObject(rotate1)
        acArr:addObject(rotate2)
        acArr:addObject(rotate3)
        -- local function visivleFunc()
            for k,v in pairs(self.kdSp) do
                if k<=stepNum+1 then
                    v:setVisible(false)
                end
                if k<=stepNum then
                    if self.huSp[k] then
                        self.huSp[k]:setVisible(false)
                    end
                end
            end
        -- end
        -- local callFunc=CCCallFunc:create(visivleFunc)
        -- acArr:addObject(callFunc)

        local seq=CCSequence:create(acArr)
        self.zhenSp:runAction(seq)
    end

end

function acQxtwTab1:runTuweiAction(reward,report)
    local totalTime=0
    local rewardk=1
    local everyAcTime=0.3
    local jiangeTime=1
    for k,v in pairs(report) do
        local delayTime=(k-1)*jiangeTime

        local linePos
        if v[1]==1 then
            linePos=self.linePos1
        elseif v[1]==2 then
            linePos=self.linePos2
        else
            linePos=self.linePos3
        end

        for kk,vv in pairs(linePos) do
            delayTime=delayTime+everyAcTime
            if vv[2]==v[2] then
                if delayTime>totalTime then
                    totalTime=delayTime
                    rewardk=k
                end
                break
            end
        end
    end
    self.tankTb={}
    for k,v in pairs(report) do
        local tankSp=CCSprite:createWithSpriteFrameName("acQxtw_tank.png")
        self.bgLayer:addChild(tankSp,5)
        tankSp:setPosition(self.startPos)
        tankSp:setScale(0.4)
        tankSp:setVisible(false)
        self.tankTb[k]=tankSp
        -- tankSp:setRotation(90)

        local linePos
        if v[1]==1 then
            linePos=self.linePos1
        elseif v[1]==2 then
            linePos=self.linePos2
        else
            linePos=self.linePos3
        end
        local stepNum=v[2]

        local acArr=CCArray:create()

        local acDelay=CCDelayTime:create((k-1)*jiangeTime)
        acArr:addObject(acDelay)

        for kk,vv in pairs(linePos) do
            local function rotateCallack()
                local statPos
                local linNum=1
                if kk==1 then
                    self.tankSp:setVisible(false)
                    statPos=ccp(tankSp:getPosition())
                    linNum=1
                else
                    statPos=linePos[kk-1][1]

                    if vv[2] then
                        if v[1]==1 then
                            linNum=vv[2]+6
                        elseif v[1]==2 then
                            linNum=vv[2]
                        else
                            linNum=vv[2]+2
                        end
                    end
                end
                self.lineLiangTb[linNum]:setVisible(true)

                local difPos=ccpSub(vv[1],statPos)
                local angleRadians =ccpToAngle(difPos)
                local  angleDegrees = math.deg(angleRadians)
                tankSp:setRotation(-1.0*angleDegrees)
                tankSp:setVisible(true)
            end
            local rotateFunc=CCCallFunc:create(rotateCallack)
            acArr:addObject(rotateFunc)
            local moveTo=CCMoveTo:create(everyAcTime,vv[1])
            acArr:addObject(moveTo)

            -- 通过的点放大缩小
            if vv[2] and vv[3] and vv[2]~=stepNum then
                local function bigScale()
                    local scaleBig = CCScaleTo:create(0.3,1.5)
                    local scaleSmall = CCScaleTo:create(0.3,1)
                    local seq = CCSequence:createWithTwoActions(scaleBig,scaleSmall)
                    self.dotSpTb[vv[3]]:runAction(seq)
                end
                local bigFunc=CCCallFunc:create(bigScale)
                acArr:addObject(bigFunc)
            end

            -- 到达的点爆炸
            if vv[2]==stepNum then
                -- 点放大
                local function boomAction()
                    tankSp:setVisible(false)
                    self:addFlicker(self.bgLayer,vv[1],1000+k)
                end
                local boomFunc=CCCallFunc:create(boomAction)
                acArr:addObject(boomFunc)
                break
            end
        end

        local acDelay2=CCDelayTime:create(0.8)
        acArr:addObject(acDelay2)

        local function removePlist()
            self:removeFlicker(self.bgLayer,1000+k)
        end
        local removeFunc=CCCallFunc:create(removePlist)
        acArr:addObject(removeFunc)

        if k==rewardk then
            if reward and SizeOfTable(reward)~=0 then
                local function endFunc()
                    tankSp:setVisible(false)
                    self:endAction(reward,report)
                end
                local callFunc=CCCallFunc:create(endFunc)
                acArr:addObject(callFunc)
            end
        else
            local function removeSelf()
                tankSp:setVisible(false)
            end
            local callFunc=CCCallFunc:create(removeSelf)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        tankSp:runAction(seq)
    end

end



function acQxtwTab1:initTableView()

    self:addRecord()

    self.tankSp=CCSprite:createWithSpriteFrameName("acQxtw_tank.png")
    self.bgLayer:addChild(self.tankSp,5)
    self.tankSp:setPosition(self.startPos)
    self.tankSp:setScale(0.4)

    local mapSp=CCSprite:create("public/acQxtw_map.jpg")
    self.bgLayer:addChild(mapSp)
    mapSp:setScaleX(590/mapSp:getContentSize().width)
    mapSp:setPosition(320, 337)
    mapSp:setPositionY(mapSp:getPositionY()+self.addH)

    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,0))
    goldLineSprite1:setPosition(ccp(mapSp:getContentSize().width/2,mapSp:getContentSize().height-7))
    mapSp:addChild(goldLineSprite1)
    goldLineSprite1:setScaleX(600/goldLineSprite1:getContentSize().width)

    local goldLineSprite2 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite2:setAnchorPoint(ccp(0.5,0.5))
    goldLineSprite2:setRotation(180)
    goldLineSprite2:setPosition(ccp(mapSp:getContentSize().width/2,-goldLineSprite2:getContentSize().height/2+7))
    mapSp:addChild(goldLineSprite2)
    goldLineSprite2:setScaleX(600/goldLineSprite2:getContentSize().width)

    local spriteBatch = CCSpriteBatchNode:create("public/acQxtwImage.png")
    self.bgLayer:addChild(spriteBatch,2)

    local linePosTb={ccp(91, 277.5),ccp(234.5, 293),ccp(445, 336.5),ccp(158, 235),ccp(277, 197),ccp(452.5, 226.5),ccp(558.5, 322),ccp(131, 357.5),ccp(255.5, 456.5),ccp(454, 420.5)}
    self.lineLiangTb={}
    for k,v in pairs(linePosTb) do
        local lineSp=CCSprite:createWithSpriteFrameName("acQxtw_line" .. k .. ".png")
        spriteBatch:addChild(lineSp,2)
        lineSp:setPosition(v)
        lineSp:setPositionY(lineSp:getPositionY()+self.addH)

        local lineLiangSp=CCSprite:createWithSpriteFrameName("acQxtw_Lline" .. k .. ".png")
        spriteBatch:addChild(lineLiangSp,2)
        lineLiangSp:setPosition(v)
        lineLiangSp:setPositionY(lineLiangSp:getPositionY()+self.addH)
        lineLiangSp:setVisible(false)
        self.lineLiangTb[k]=lineLiangSp
    end

    local dotTb={ccp(127.5, 273.5),ccp(158.5, 433.5),ccp(188.5, 205.5),ccp(352.5, 455.5),ccp(334.5, 297.5),ccp(357.5, 199.5),ccp(539.5, 251.5),ccp(548.5, 388.5)}
    local map=acQxtwVoApi:getMap()
    self.dotSpTb={}
    self.colorTb={}
    for k,v in pairs(dotTb) do
        local pointSp=CCSprite:createWithSpriteFrameName("localWar_miniMap_point.png")
        self.bgLayer:addChild(pointSp,3)
        pointSp:setPosition(v)
        pointSp:setPositionY(pointSp:getPositionY()+self.addH)
        self.dotSpTb[k]=pointSp
        local dotPic
        for kk,vv in pairs(map) do
            for kkk,vvv in pairs(vv.include) do
                if k==vvv then
                    if vv.random[kkk]==1 then
                        pointSp:setColor(G_ColorGreen)
                    elseif vv.random[kkk]==2 then
                        pointSp:setColor(G_ColorBlue)
                    elseif vv.random[kkk]==3 then
                        pointSp:setColor(G_ColorPurple)
                    elseif vv.random[kkk]==4 then
                        pointSp:setColor(G_ColorOrange)
                    end
                    self.colorTb[k]=vv.random[kkk]
                    break
                end
            end
        end
    end

    -- 油盘
    local function onClickPan()

        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_qxtw_pan"),getlocal("activity_qxtw_pan_des"),nil,self.layerNum+1)
    end
    local diPan=LuaCCSprite:createWithSpriteFrameName("acQxtw_pan.png",onClickPan)
    diPan:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(diPan)
    diPan:setPosition(G_VisibleSizeWidth/2, 75)

    if(G_isIphone5())then
        diPan:setPositionY(diPan:getPositionY()+110)
    end

    local zhenSp=CCSprite:createWithSpriteFrameName("acQxtw_zhen.png")
    diPan:addChild(zhenSp)
    zhenSp:setPosition(61, 63)
    self.zhenSp=zhenSp
    local keduTb={ccp(16, 61),ccp(25, 86),ccp(47, 103),ccp(76, 103),ccp(97, 88),ccp(106, 61)}

    self.kdSp={}
    for k,v in pairs(keduTb) do
        local orangeSp=CCSprite:createWithSpriteFrameName("acQxtw_kedu_orange.png")
        diPan:addChild(orangeSp)
        orangeSp:setPosition(v)
        orangeSp:setRotation(-180+(k-1)*36)

        local whiteSp=CCSprite:createWithSpriteFrameName("acQxtw_kedu_white.png")
        diPan:addChild(whiteSp)
        whiteSp:setPosition(v)
        whiteSp:setRotation(-180+(k-1)*36)

        self.kdSp[k]=whiteSp
    end

    self.huSp={}
    local huTb={ccp(15, 76),ccp(32, 100),ccp(60, 109),ccp(90, 100),ccp(107, 76)}
    for k,v in pairs(huTb) do
        local huSp=CCSprite:createWithSpriteFrameName("acQxtw_hu.png")
        diPan:addChild(huSp)
        huSp:setPosition(v)
        huSp:setRotation(-(5-k)*36)
        self.huSp[k]=huSp
        if k==3 then
            huSp:setRotation(-(5-k)*35)
        end
    end

end

function acQxtwTab1:addRecord()
    -- 记录
    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function showLog()
           acQxtwVoApi:showLogRecord(self.layerNum+1)
        end
        acQxtwVoApi:getLog(showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(584, 480.5))
    self.bgLayer:addChild(recordMenu,4)
    recordMenu:setPositionY(recordMenu:getPositionY()+self.addH)

    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,8)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- local function showReward()
           acQxtwVoApi:showAllreward(self.layerNum+1)
        -- end
        -- acQxtwVoApi:getLog(showReward)
    end
    local rewardItem=GetButtonItem("SeniorBox.png","SeniorBox.png","SeniorBox.png",rewardRecordsHandler,11,nil,nil)
    rewardItem:setScale(0.5)
    local rewardBtn=CCMenu:createWithItem(rewardItem)
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardBtn:setPosition(ccp(68, 480.5))
    self.bgLayer:addChild(rewardBtn,4)
    rewardBtn:setPositionY(rewardBtn:getPositionY()+self.addH)

    local strSize3,addPosX2 = 22,0
    if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage() =="fr" then
        strSize3,addPosX2 = 16,10
    end

    local recordLb=GetTTFLabelWrap(getlocal("local_war_help_title9"),strSize3,CCSize(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(rewardItem:getContentSize().width/2+addPosX2,8)
    recordLb:setScale(1/rewardItem:getScale())
    rewardItem:addChild(recordLb)

end


function acQxtwTab1:refresh()
    self:refreshCostLb()
    self:refreshSuipian()
end

-- 组装动画
function acQxtwTab1:showGetReward(item,layerNum)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =28
    end
    if self.rewardLayer == nil then
        self.rewardLayer = CCLayer:create()
        sceneGame:addChild(self.rewardLayer,layerNum)

        local function callback()
         
        end
        local sceneSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,6,6),function ()end)
        sceneSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        sceneSp:setAnchorPoint(ccp(0,0))
        sceneSp:setPosition(ccp(0,0))
        sceneSp:setTouchPriority(-(layerNum-1)*20-1)
        self.rewardLayer:addChild(sceneSp)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local bigBg=LuaCCSprite:createWithFileName("public/emblem/emblemBlackBg.jpg",callback)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        bigBg:setAnchorPoint(ccp(0.5,0.5))
        bigBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
        self.rewardLayer:addChild(bigBg)
        local fadeTo = CCFadeTo:create(1.5, 100)
        local fadeBack = CCFadeTo:create(1.5, 255)
        local acArr = CCArray:create()
        acArr:addObject(fadeTo)
        acArr:addObject(fadeBack)
        local seq = CCSequence:create(acArr)
        bigBg:runAction(CCRepeatForever:create(seq))
        
        
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGetBg.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2 - 200))
        particleS:setAutoRemoveOnFinish(true) -- 自动移除
        self.rewardLayer:addChild(particleS)
    end
    self:clearChildLayer()
    self.childLayer = CCLayer:create()
    self.rewardLayer:addChild(self.childLayer)
    self.addParticleTb = {}

    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
        particleS:setAutoRemoveOnFinish(true) -- 自动移除
        self.rewardLayer:addChild(particleS,10)
        table.insert(self.addParticleTb,particleS)
        local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
        particleS2:setPositionType(kCCPositionTypeFree)
        particleS2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
        particleS2:setAutoRemoveOnFinish(true) -- 自动移除
        self.rewardLayer:addChild(particleS2,11)
        table.insert(self.addParticleTb,particleS2)
    end

    local function callback2()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
        particleS:setAutoRemoveOnFinish(true) -- 自动移除
        self.rewardLayer:addChild(particleS,12)
        table.insert(self.addParticleTb,particleS)
    end

    -- 抽奖的亮晶晶特效
    local function showBgParticle(parent,pos,equipID,order)
        if parent then
            local equipCfg = emblemVoApi:getEquipCfgById(equipID)
            local color = equipCfg.color
            local particleName = "public/emblem/emblemGet"..color..".plist"
            local starParticleS = CCParticleSystemQuad:create(particleName)
            starParticleS:setPosition(pos)
            parent:addChild(starParticleS,order)
            table.insert(self.addParticleTb,starParticleS)
        end
    end
    
    
    local callFunc1=CCCallFunc:create(callback1)
    local callFunc2=CCCallFunc:create(callback2)
    

    local acArr=CCArray:create()
    local function callback3()
        local titleBg = CCSprite:createWithSpriteFrameName("awTitleBg.png")
        titleBg:setScale(1.2)
        titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 80)
        self.childLayer:addChild(titleBg)
    
        local titleLb=GetTTFLabel(getlocal("congratulationsGet",{""}),strSize2)
        titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 73)
        self.childLayer:addChild(titleLb)

        local function callback31()
            local function ok( ... )
                self:disposeRewardLayer()
            end

            local btnName,btnNameDown
            if(self.lastGetType==1)then
                btnName="BtnCancleSmall.png"
                btnNameDown="BtnCancleSmall_Down.png"
            else
                btnName="BtnOkSmall.png"
                btnNameDown="BtnOkSmall_Down.png"
            end
            local okItem=GetButtonItem(btnName,btnNameDown,btnNameDown,ok,nil,getlocal("coverFleetBack"),25)
            local okBtn=CCMenu:createWithItem(okItem)
            okBtn:setTouchPriority(-(layerNum-1)*20-2)
            okBtn:setAnchorPoint(ccp(1,0.5))
            okBtn:setPosition(ccp(G_VisibleSizeWidth/2,150))
            self.childLayer:addChild(okBtn,11)
        end
        local posCfg,iconSc
        if SizeOfTable(item)==1 and item[1].num==1 then
            posCfg = {{G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+50}}
            iconSc= 1.2
        else
            posCfg = {
            {G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight/2 + 100 + 30},
            {G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+250 + 30},
            {G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight/2+100 + 30},
            {G_VisibleSizeWidth/2-130,G_VisibleSizeHeight/2-120 + 30},
            {G_VisibleSizeWidth/2+130,G_VisibleSizeHeight/2-120 + 30}
            }
            iconSc= 1.2
        end

        local index = 1
        local equipIdTb = {}

        local function showItemInfo(tag)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            local cfg = emblemVoApi:getEquipCfgById(item[1].key)
            local eVo = emblemVo:new(cfg)
            if(eVo)then
                eVo:initWithData(item[1].key,0,0)
                emblemVoApi:showInfoDialog(eVo,self.layerNum + 1,true)
            end

        end
        for k,v in pairs(item) do
            for i=1,v.num do
                local mIcon
                if v.type == "se" then
                    mIcon=emblemVoApi:getEquipIconNoBg(v.key,strSize2,nil,showItemInfo)
                    mIcon:setTouchPriority(-(layerNum-1)*20-5)
                    table.insert(equipIdTb,v.key)
                end
                mIcon:setTag(index)
                if mIcon then
                    mIcon:setScale(0)
                    mIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
                    self.childLayer:addChild(mIcon,20+index)
                    local ccMoveTo = CCMoveTo:create(0.2,CCPointMake(posCfg[index][1],posCfg[index][2]))
                    local ccScaleTo = CCScaleTo:create(0.2,iconSc)
                    local callFunc3=CCCallFuncN:create(callback31)
                    local moveAndScaleArr=CCArray:create()
                    moveAndScaleArr:addObject(ccMoveTo)
                    moveAndScaleArr:addObject(ccScaleTo)
                    local moveAndScaleSpawn=CCSpawn:create(moveAndScaleArr)
                    local function addParticle(icon)
                        local tag = icon:getTag()
                        showBgParticle(self.childLayer,ccp(icon:getPosition()),equipIdTb[tag],10+tag)
                    end
                    local callFunParticle = CCCallFuncN:create(addParticle)
                    local iconAcArr=CCArray:create()
                    iconAcArr:addObject(moveAndScaleSpawn)
                    iconAcArr:addObject(callFunParticle)
                    index = index + 1
                    if index > SizeOfTable(posCfg) then
                        index = 1
                        iconAcArr:addObject(callFunc3)
                    end  
                    local seq=CCSequence:create(iconAcArr)
                    mIcon:runAction(seq)
                end
            end
        end
        
    end
    local callFunc3=CCCallFunc:create(callback3)
    local delay = CCDelayTime:create(0.5)
    acArr:addObject(callFunc1)
    acArr:addObject(delay)
    acArr:addObject(callFunc2)
    acArr:addObject(callFunc3)
    local seq=CCSequence:create(acArr)
    self.rewardLayer:runAction(seq)

end

function acQxtwTab1:clearChildLayer()
    if self.addParticleTb then
        for k,v in pairs(self.addParticleTb) do
            if v and v.parent then
                v:removeFromParentAndCleanup(true)
                v = nil
            end 
        end
        self.addParticleTb = nil
    end
    
    if self.childLayer then
        self.childLayer:removeAllChildrenWithCleanup(true)
        self.childLayer:removeFromParentAndCleanup(true)
        self.childLayer = nil
    end
end

function acQxtwTab1:disposeRewardLayer()
    if self.addParticleTb then
        for k,v in pairs(self.addParticleTb) do
            if v and v.parent then
                v:removeFromParentAndCleanup(true)
                v = nil
            end 
        end
        self.addParticleTb = nil
    end
    if self.childLayer then
        self.childLayer:removeAllChildrenWithCleanup(true)
        self.childLayer:removeFromParentAndCleanup(true)
        self.childLayer = nil
    end
    if self.rewardLayer then
        self.rewardLayer:removeAllChildrenWithCleanup(true)                
        self.rewardLayer:removeFromParentAndCleanup(true)
        self.rewardLayer = nil
    end
    self.getTimeTick = nil
end

function acQxtwTab1:fastTick()
    if self.state==3 then
        self:endAction(self.reward,self.report)

    end      
end

function acQxtwTab1:tick()
    self:updateAcTime()
end

function acQxtwTab1:updateAcTime()
    local acVo=acQxtwVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acQxtwTab1:addFlicker(parentBg,flickerPos,tag)
    if parentBg then
        local pzFrameName="acQxtw_boom1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr=CCArray:create()
        for kk=1,8 do
            local nameStr="acQxtw_boom"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate=CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5,0.5))

        metalSp:setPosition(flickerPos)

        metalSp:setTag(tag)
        parentBg:addChild(metalSp,4)
        metalSp:runAction(animate)
        return metalSp
    end
end

function acQxtwTab1:removeFlicker(parentBg,tag)
    if parentBg~=nil then
        local temSp=tolua.cast(parentBg,"CCNode")
        local metalSp=nil;
        if temSp~=nil then
            metalSp=tolua.cast(temSp:getChildByTag(tag),"CCSprite")
        end
        if metalSp~=nil then
            metalSp:removeFromParentAndCleanup(true)
            metalSp=nil
        end
    end
end


function acQxtwTab1:dispose()
    -- eventDispatcher:removeEventListener("activity.recharge",self.wsjdzzListener)
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.url=nil
    self.layerNum=nil
end
