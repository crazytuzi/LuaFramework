acQxtwTabNew1={
}

function acQxtwTabNew1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum
    self.state = 0 

    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")

    local function addPlist()
        spriteController:addPlist("public/acNewYearsEva.plist")
        spriteController:addTexture("public/acNewYearsEva.png")
    end
    G_addResource8888(addPlist)
    

    return nc;
end

function acQxtwTabNew1:init()

    self.bgLayer=CCLayer:create()

    local mustReward=acQxtwVoApi:getMustRewardByTag(1)
    self.mustR1=FormatItem(mustReward)[1]

    local mustReward=acQxtwVoApi:getMustRewardByTag(2)
    self.mustR2=FormatItem(mustReward)[1]

    self:initUI()
    -- self:initTableView()
    return self.bgLayer
end


function acQxtwTabNew1:initUI()
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

    self.jiangeH=0
    if(G_isIphone5())then
        self.jiangeH=10
    end

    -- 活动 时间 描述
    local lbH=self.bgLayer:getContentSize().height-185
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)

    local acVo = acQxtwVoApi:getAcVo()
    lbH=lbH-35-self.jiangeH
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel,1)

    lbH=lbH-35-self.jiangeH
    local acDesLb=GetTTFLabelWrap(getlocal("activity_qxtw_des"),25,CCSize(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.bgLayer:addChild(acDesLb)
    acDesLb:setAnchorPoint(ccp(0.5,1))
    acDesLb:setPosition(G_VisibleSizeWidth/2,lbH)

    lbH=lbH-acDesLb:getContentSize().height-10
    if(G_isIphone5())then
        lbH=lbH-30
    else
        lbH=lbH-30
    end
    -- local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    -- goldLineSprite1:setAnchorPoint(ccp(0.5,1))
    -- goldLineSprite1:setPosition(ccp(G_VisibleSizeWidth/2,lbH))
    -- self.bgLayer:addChild(goldLineSprite1,1)
    -- lbH=lbH-20-goldLineSprite1:getContentSize().height

    if(G_isIphone5())then
        lbH=lbH+20
    else
        lbH=lbH+15
    end

    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210+7)

    if(G_isIphone5())then
        actTime:setPositionY(actTime:getPositionY()-10)
        timeLabel:setPositionY(timeLabel:getPositionY()-10)
        pos.y=pos.y-10
    end

    local tabStr={" ",getlocal("activity_qxtw_tipNew3"),getlocal("activity_qxtw_tipNew2"),getlocal("activity_qxtw_tipNew1")," "}
    local colorTab={}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,colorTab,nil)

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
    local titleBg1=CCSprite:createWithSpriteFrameName("acQxtw_titleBg.png")
    backSprie:addChild(titleBg1)
    titleBg1:setAnchorPoint(ccp(1,0.5))
    titleBg1:setPosition(backSprie:getContentSize().width,backSprie:getContentSize().height/2)


    local titleBg2=CCSprite:createWithSpriteFrameName("acQxtw_titleBg.png")
    backSprie:addChild(titleBg2)
    titleBg2:setAnchorPoint(ccp(1,0.5))
    titleBg2:setFlipX(true)
    titleBg2:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2)

    if(G_isIphone5())then
        titleBg1:setScaleY(180/titleBg1:getContentSize().height)
        titleBg2:setScaleY(180/titleBg2:getContentSize().height)
    end

    local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
    backSprie:addChild(guangSp)
    guangSp:setPosition(80,backSprie:getContentSize().height/2)
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
    icon:setPosition(80,backSprie:getContentSize().height/2)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    local scale=100/icon:getContentSize().width
    icon:setScale(scale)

    local nameLb=tolua.cast(icon:getChildByTag(1),"CCLabelTTF")
    nameLb:setDimensions(CCSizeMake(400,0))
    nameLb:setHorizontalAlignment(kCCTextAlignmentLeft)
    nameLb:setAnchorPoint(ccp(0,0))
    nameLb:setPosition(140,icon:getContentSize().height-35)
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
    composeBtn:setPosition(ccp(backSprie:getContentSize().width-110,backSprie:getContentSize().height/2))
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

    local lbH=lbH-bsH-63

    if(G_isIphone5())then
        lbH=lbH-65
        self.recordH=lbH+50
    else
        self.recordH=lbH
    end
    
    local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
    lightSp:setPosition(G_VisibleSizeWidth/2,lbH)
    self.bgLayer:addChild(lightSp)

    local fadeBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    fadeBg:setAnchorPoint(ccp(0.5,0))
    fadeBg:setPosition(ccp(lightSp:getContentSize().width/2,-20))
    lightSp:addChild(fadeBg)

    local starBg=CCSprite:createWithSpriteFrameName("heroBg.png")
    starBg:setAnchorPoint(ccp(0.5,1))
    starBg:setPosition(ccp(G_VisibleSizeWidth/2,lbH+10))
    self.bgLayer:addChild(starBg,1)
    starBg:setScale(1.2)

    local floorLb=GetTTFLabelWrap(getlocal("activity_qxtw_buyTitle"),25,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    floorLb:setPosition(getCenterPoint(starBg))
    self.floorLb=floorLb
    starBg:addChild(floorLb)

    local bsMH=40
    local bsHeight=150
    if(G_isIphone5())then
        bsMH=50
        bsHeight=170
    end
    
    local bsWidth=G_VisibleSizeWidth - 60
    local function  bgClick()
    end
    local backSprie1 = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    backSprie1:setContentSize(CCSizeMake(bsWidth, bsHeight))
    backSprie1:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(backSprie1,1)
    backSprie1:setPosition(G_VisibleSizeWidth/2,bsMH)

    local bsSize=backSprie1:getContentSize()

    local rIcon1=G_getItemIcon(self.mustR2,100,true,self.layerNum+1)
    backSprie1:addChild(rIcon1)
    rIcon1:setAnchorPoint(ccp(0,0.5))
    rIcon1:setPosition(10,bsSize.height/2)
    rIcon1:setTouchPriority(-(self.layerNum-1)*20-4)

    local nameLb=GetTTFLabelWrap(
    self.mustR2.name .. "x" .. self.mustR2.num,25,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0,0))
    backSprie1:addChild(nameLb)
    nameLb:setPosition(ccp(120,bsSize.height/2+20))

    local desLb=GetTTFLabelWrap(
    getlocal("activity_qxtw_buyDes",{self.mustR2.name .. "x" .. self.mustR2.num,5}),22,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desLb:setAnchorPoint(ccp(0,1))
    backSprie1:addChild(desLb)
    desLb:setPosition(ccp(120,bsSize.height/2+5)
    )

    local sbH=10
    if(G_isIphone5())then
        sbH=30
    end
    local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    backSprie2:setContentSize(CCSizeMake(bsWidth, bsHeight))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(backSprie2,1)
    backSprie2:setPosition(G_VisibleSizeWidth/2,bsMH+backSprie1:getContentSize().height+sbH)

    local rIcon2=G_getItemIcon(self.mustR1,100,true,self.layerNum+1)
    backSprie2:addChild(rIcon2)
    rIcon2:setAnchorPoint(ccp(0,0.5))
    rIcon2:setPosition(10,bsSize.height/2)
    rIcon2:setTouchPriority(-(self.layerNum-1)*20-4)

    local nameLb2=GetTTFLabelWrap(
    self.mustR1.name .. "x" .. self.mustR1.num,25,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    nameLb2:setAnchorPoint(ccp(0,0))
    backSprie2:addChild(nameLb2)
    nameLb2:setPosition(ccp(120,bsSize.height/2+20))

    local desLb2=GetTTFLabelWrap(
    getlocal("activity_qxtw_buyDes",{self.mustR1.name .. "x" .. self.mustR1.num,1}),22,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    desLb2:setAnchorPoint(ccp(0,1))
    backSprie2:addChild(desLb2)
    desLb2:setPosition(ccp(120,bsSize.height/2+5)
    )

    
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
            if rand==3 then
                G_addPlayerAward(self.mustR2.type,self.mustR2.key,self.mustR2.id,self.mustR2.num,nil,true)
            else
                G_addPlayerAward(self.mustR1.type,self.mustR1.key,self.mustR1.id,self.mustR1.num,nil,true)
            end
            
            -- self.touchDialogBg:setIsSallow(true)
            self:refreshCostLb()
            self:refreshSuipian()
            self.state=2
            self.reward=reward
            self.report=report

            self:endAction(reward,report)
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
    menuItem[1]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback1,nil,getlocal("activity_qxtw_buy",{1}),strSize2)
    menuItem[2]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback2,nil,getlocal("activity_qxtw_buy",{5}),strSize2)
    self.menuItem1=menuItem[1]
    self.menuItem2=menuItem[2]

    local menuBtn1=CCMenu:createWithItem(self.menuItem2)
    menuBtn1:setTouchPriority(-(self.layerNum-1)*20-4)
    menuBtn1:setPosition(backSprie1:getContentSize().width-90,backSprie1:getContentSize().height/2-10)
    backSprie1:addChild(menuBtn1)


    local menuBtn2=CCMenu:createWithItem(self.menuItem1)
    menuBtn2:setTouchPriority(-(self.layerNum-1)*20-4)
    menuBtn2:setPosition(backSprie2:getContentSize().width-90,backSprie2:getContentSize().height/2-10)
    backSprie2:addChild(menuBtn2)

    local freeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",callback1,nil,getlocal("buy"),strSize2)
    local freeBtn=CCMenu:createWithItem(freeItem)
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.freeItem=freeItem
    freeBtn:setPosition(backSprie2:getContentSize().width-90,backSprie2:getContentSize().height/2-10)
    backSprie2:addChild(freeBtn)

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

    self:addRecord(self.recordH)
end


function acQxtwTabNew1:refreshCostLb()
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

function acQxtwTabNew1:refreshSuipian()
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

function acQxtwTabNew1:endAction(reward,report)
    local tipStrTb={{},{}}
    tipStrTb[1][1]=getlocal("activity_mineexploreG_storeReward")
    tipStrTb[2][1]=getlocal("activity_mineExploreG_otherReward")
    local titleStr
    local rewardlist={}
    local mustReward={}
    if SizeOfTable(report)==1 then
        titleStr=getlocal("buy")..self.mustR1.name
        mustReward[1]=self.mustR1
    else
        titleStr=getlocal("buy")..self.mustR2.name
        mustReward[1]=self.mustR2
    end
    rewardlist[1]=mustReward
    rewardlist[2]=reward

    local function callBackHandler()
        local otherReward={}
        table.insert(otherReward,mustReward[1])
        for k,v in pairs(reward) do
            table.insert(otherReward,v)
        end
        G_showRewardTip(otherReward,true)
    end

    acQxtwVoApi:showRewardSmallDialog("PanelHeaderPopup.png",CCSizeMake(550,560),CCRect(168,86,10,10),titleStr,rewardlist,tipStrTb,false,true,self.layerNum+1,callBackHandler)
end

function acQxtwTabNew1:addRecord(recordH)
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
           -- acQxtwVoApi:showLogRecord(self.layerNum+1)
           acQxtwVoApi:showLogRecordNew(self.layerNum+1,self.mustR1,self.mustR2)
        end
        acQxtwVoApi:getLog(showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(580, recordH))
    self.bgLayer:addChild(recordMenu,4)

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
           -- acQxtwVoApi:showAllreward(self.layerNum+1)
           acQxtwVoApi:rewardShowH(self.layerNum+1)
        -- end
        -- acQxtwVoApi:getLog(showReward)
    end
    local rewardItem=GetButtonItem("SeniorBox.png","SeniorBox.png","SeniorBox.png",rewardRecordsHandler,11,nil,nil)
    rewardItem:setScale(0.5)
    local rewardBtn=CCMenu:createWithItem(rewardItem)
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardBtn:setPosition(ccp(68, recordH+4))
    self.bgLayer:addChild(rewardBtn,4)

    local recordLb=GetTTFLabelWrap(getlocal("local_war_help_title9"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(rewardItem:getContentSize().width/2,8)
    recordLb:setScale(1/rewardItem:getScale())
    rewardItem:addChild(recordLb)

end


function acQxtwTabNew1:refresh()
    self:refreshCostLb()
    self:refreshSuipian()
end

-- 组装动画
function acQxtwTabNew1:showGetReward(item,layerNum)
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

function acQxtwTabNew1:clearChildLayer()
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

function acQxtwTabNew1:disposeRewardLayer()
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

function acQxtwTabNew1:fastTick()   
end

function acQxtwTabNew1:dispose()
    -- eventDispatcher:removeEventListener("activity.recharge",self.wsjdzzListener)
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.url=nil
    self.layerNum=nil
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    -- acNewYearsEva
end
