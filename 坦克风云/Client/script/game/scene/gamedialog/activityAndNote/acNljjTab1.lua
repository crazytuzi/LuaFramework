acNljjTab1={
}

function acNljjTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acNljjTab1:init()
    self.bgLayer=CCLayer:create()
    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acNljjTab1:initUI()
    local strSize2 = 20
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
    -- local actTime=GetTTFLabel(getlocal("activity_timeLabel"),28)
    -- actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    -- self.bgLayer:addChild(actTime,5)
    -- actTime:setColor(G_ColorGreen)

    local descStr1=acNljjVoApi:getTimeStr()
    local descStr2=acNljjVoApi:getRewardTimeStr()
    local moveBgStarStr,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(self.bgLayer:getContentSize().width-120,70),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    moveBgStarStr:setPosition(ccp(120/2,lbH-55))
    self.bgLayer:addChild(moveBgStarStr)
    self.timeLb1=timeLb1
    self.timeLb2=timeLb2
    self:updateAcTime()

    local acVo = acNljjVoApi:getAcVo()
    lbH=lbH-35
    -- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    -- local timeLabel=GetTTFLabel(timeStr,25)
    -- timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    -- self.bgLayer:addChild(timeLabel,1)

    lbH=lbH-35
    
    local pos=ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-210+7)

    -- if(G_isIphone5())then
    --     actTime:setPositionY(actTime:getPositionY()-10)
    --     timeLabel:setPositionY(timeLabel:getPositionY()-10)
    --     pos.y=pos.y-10
    -- end

    local tabStr={" ",getlocal("activity_nljj_info5"),getlocal("activity_nljj_info4"),getlocal("activity_nljj_info3"),getlocal("activity_nljj_info2"),getlocal("activity_nljj_info1")," "}
    local colorTab={}
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,colorTab,nil)

    local descBgH=lbH-25+10
    local function nilFunc()
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,descBgH))
    descBg:setPosition(ccp(G_VisibleSizeWidth/2,25))
    descBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(descBg)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    blueBg:setScaleX((self.bgLayer:getContentSize().width-65)/blueBg:getContentSize().width)
    descBg:addChild(blueBg)
    blueBg:setScaleY((descBgH-10)/blueBg:getContentSize().height)
    blueBg:setPosition(getCenterPoint(descBg))

    local picArr = {"crystal_1_1.png","crystal_10_2.png","crystal_3_1.png","crystal_5_3.png","crystal_7_2.png","crystal_4_3.png","crystal_2_1.png","crystal_6_3.png","crystal_9_2.png"}
    local posArr = {ccp(180,200),ccp(100,180),ccp(200,500),ccp(503,475),ccp(530,400),ccp(540,200),ccp(500,180),ccp(100,490)}
    if G_isIphone5()==true then
        posArr = {ccp(180,240),ccp(100,200),ccp(90,580),ccp(503,550),ccp(510,400),ccp(420,260),ccp(500,180),ccp(160,630),ccp(160,570)}
    end
    for k,v in pairs(posArr) do
        local pic = picArr[k]
        local crystalIcon=CCSprite:createWithSpriteFrameName(pic)
        crystalIcon:setPosition(v)
        descBg:addChild(crystalIcon)
        crystalIcon:setRotation(k%3*10)
        crystalIcon:setOpacity(100)
    end


    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(0,descBg:getContentSize().height/2))
    descBg:addChild(leftFrameBg1,2)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(descBg:getContentSize().width,descBg:getContentSize().height/2))
    descBg:addChild(rightFrameBg1,2)

    

    local bigReward=acVo.activeCfg.reward[3]
    local bigItem=FormatItem(bigReward,nil,true)
    local cellHight=80
    local jigeW=10
    if(G_isIphone5())then
        cellHight=100
        jigeW=20
    end
    local tv=self:addHorizontalTv(CCSizeMake(descBg:getContentSize().width-40,cellHight),CCSizeMake(cellHight+jigeW,cellHight),bigItem,self.layerNum)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(20,descBgH-cellHight-10))
    tv:setMaxDisToBottomOrTop(80)
    descBg:addChild(tv,2)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setPosition(descBg:getContentSize().width/2,descBgH-cellHight-15)
    descBg:addChild(lineSp,2)

    -- descBgH 大奖展示
    local sbLb=GetTTFLabelWrap("",strSize2,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setScaleX(500/titleBg:getContentSize().width)
    titleBg:setScaleY(60/titleBg:getContentSize().height)
    titleBg:setPosition(descBg:getContentSize().width/2,descBgH-cellHight-45-sbLb:getContentSize().height/2)
    descBg:addChild(titleBg,2)

    descBg:addChild(sbLb,2)
    -- sbLb:setAnchorPoint(ccp(0.5,1))
    sbLb:setPosition(descBg:getContentSize().width/2,descBgH-cellHight-45-sbLb:getContentSize().height/2)
    self.sbLb=sbLb

    


    
    local function sureHandler(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end
        if acNljjVoApi:acIsStop() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_kuangnuzhishi_endToReward"),30)
            do return end
        end

        local rand
        local needCost=0
        if tag==1 then
            local flag=acNljjVoApi:isDailyFree()
            if flag==0 then
                rand=1
            else
                rand=2
                needCost=acNljjVoApi:getCostByType(1)
            end
        else
            rand=3
            needCost=acNljjVoApi:getCostByType(2)
        end
        local gems=playerVoApi:getGems()
        if needCost>gems then
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,needCost-gems,self.layerNum+1,needCost,onSure)
            return
        end

        local cmd="active.nengliangjiejing.rand"
        local function refreshFunc(reward,report,getPoint)
            -- 扣除金币
            playerVoApi:setGems(playerVoApi:getGems()-needCost)
            self.touchDialogBg:setIsSallow(true)
            self:refreshCostLb()
            self.state=2
            self.reward=reward
            self.report=report
            self.getPoint=getPoint

            self:startAction()
        end
        -- socketHelper:activityNljj(cmd,rand,rank,callback)
        acNljjVoApi:socketNljj(cmd,rand,nil,refreshFunc)
        
    end
    self.sbCallback=sureHandler

    local subAddH=30
    if(G_isIphone5())then
        subAddH=30
    end
    local function callback1()
        sureHandler(1)
    end
    local function callback2()
        sureHandler(2)
    end
    local menuPosY=40
    local menuItem={}
    menuItem[1]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback1,nil,getlocal("activity_nljj_btn",{1}),strSize2)
    menuItem[2]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback2,nil,getlocal("activity_nljj_btn",{10}),strSize2)
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

    local freeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",callback1,nil,getlocal("activity_nljj_btn",{1}),strSize2)
    local freeBtn=CCMenu:createWithItem(freeItem)
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.freeItem=freeItem
    freeBtn:setPosition(G_VisibleSizeWidth/2-80-freeItem:getContentSize().width/2,menuPosY)
    self.bgLayer:addChild(freeBtn)
    freeBtn:setPositionY(menuPosY+subAddH)

    local costLbPosY=90
    self.costLb={}
    for i=1,2 do
        local costNum=acNljjVoApi:getCostByType(i)
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

    if acNljjVoApi:acIsStop() then
        self:refreshRewardTime()
    end
end


function acNljjTab1:refreshCostLb()

    if self.freeLb then
        if acNljjVoApi:isDailyFree()==0 then
            self.freeLb:setVisible(true)
            self.costLb[1]:setVisible(false)
            self.freeItem:setVisible(true)
            
            self.menuItem1:setVisible(false)
            
            if not acNljjVoApi:acIsStop() then
                self.menuItem1:setEnabled(false)
                self.freeItem:setEnabled(true)
            end
            -- self.menuItem2:setEnabled(false)
        else
            self.freeLb:setVisible(false)
            self.costLb[1]:setVisible(true)
            self.freeItem:setVisible(false)
            self.menuItem1:setVisible(true)
            if not acNljjVoApi:acIsStop() then
                self.freeItem:setEnabled(false)
                self.menuItem1:setEnabled(true)
            end
            -- self.menuItem2:setEnabled(true)
        end
        -- 设置颜色
        local cost1=acNljjVoApi:getCostByType(1)
        local cost2=acNljjVoApi:getCostByType(2)
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

function acNljjTab1:startAction()
    --温度值改变
    local vNum=acNljjVoApi:getV()
    self.nowVLb:setString(vNum)

    -- 进度条动画
    self:runProgressAction()
end

function acNljjTab1:runProgressAction()
    local oldPer=self.timerSpriteLv:getPercentage()
    local nowPer,nowCent=acNljjVoApi:getPer()

    local everyTime=0.01

    local acArr=CCArray:create()
    -- local delayTime=CCDelayTime:create(0.05)
    -- acArr:addObject(delayTime)

    -- 产生奖励动画
    local function actionP1()
        local pAc=CCParticleSystemQuad:create("public/acNljj_p1.plist")
        pAc:setPositionType(kCCPositionTypeFree)
        -- pAc:setScale(2)
        pAc:setPosition(ccp(323, 379))
        self.bgLayer:addChild(pAc,6)
        pAc:setPositionY(pAc:getPositionY()-self.subH)
        pAc:setTag(901)
    end
    local function actionP2()
        local pAc=CCParticleSystemQuad:create("public/acNljj_p2.plist")
        pAc:setPositionType(kCCPositionTypeFree)
        -- pAc:setScale(2)
        pAc:setPosition(ccp(323, 379))
        self.bgLayer:addChild(pAc,6)
        pAc:setPositionY(pAc:getPositionY()-self.subH)
        pAc:setTag(902)
    end
    local function actionP3()
        local pAc=CCParticleSystemQuad:create("public/acNljj_p3.plist")
        pAc:setPositionType(kCCPositionTypeFree)
        -- pAc:setScale(2)
        pAc:setPosition(ccp(323, 379))
        self.bgLayer:addChild(pAc,6)
        pAc:setPositionY(pAc:getPositionY()-self.subH)
        pAc:setTag(903)
    end
    local callfunc1=CCCallFunc:create(actionP1)
    local callfunc2=CCCallFunc:create(actionP2)
    local callfunc3=CCCallFunc:create(actionP3)

    acArr:addObject(callfunc1)
    local delay1=CCDelayTime:create(0.2)
    acArr:addObject(delay1)

    acArr:addObject(callfunc2)
    local delay2=CCDelayTime:create(0.3)
    acArr:addObject(delay2)

    acArr:addObject(callfunc3)
    local delay3=CCDelayTime:create(0.5)

    -- 相隔几层

    local subCent=nowCent-self.lastCent
    if subCent==-1 then
        subCent=3
    elseif subCent==-2 then
        subCent=2
    else
        subCent=subCent+1
    end

    self.lastCent1=self.lastCent
    local changePer=oldPer
    for i=1,subCent do
        local function changeAc()
            local oldPer=self.timerSpriteLv:getPercentage()

            if oldPer==100 then
                self.timerSpriteLv:setPercentage(0)

                -- 层改变的逻辑
                self.lastCent=self.lastCent+1
                if self.lastCent>3 then
                    self.lastCent=1
                end
                
                self:refreshDeng(self.lastCent,true)
                self:runKaiOrHe(self.lastCent)
            else
                self.timerSpriteLv:setPercentage(oldPer+1)
            end
        end
        local callFunc=CCCallFunc:create(changeAc)
        

        local oldPer=changePer
        if i==subCent then
            for j=oldPer,nowPer do
                acArr:addObject(callFunc)
                if changePer==100 then
                    changePer=0
                    -- 展开或者合  延时长一些
                    local delayTime=CCDelayTime:create(0.3)
                    acArr:addObject(delayTime)
                else
                    changePer=changePer+1
                    local delayTime=CCDelayTime:create(everyTime)
                    acArr:addObject(delayTime)
                end
                
            end
        else
            for j=oldPer,100 do
                acArr:addObject(callFunc)
                if changePer==100 then
                    changePer=0
                    -- 展开或者合  延时长一些
                    local delayTime=CCDelayTime:create(0.3)
                    acArr:addObject(delayTime)
                else
                    changePer=changePer+1
                    local delayTime=CCDelayTime:create(everyTime)
                    acArr:addObject(delayTime)
                end
                
            end
        end
        
    end

    local delay3=CCDelayTime:create(0.8)
    acArr:addObject(delay3)
    
    local function endAc()
       self:endAction(self.reward,self.report)
    end
    
    local callfunc4=CCCallFunc:create(endAc)

    
    

    acArr:addObject(callfunc4)

    local seq=CCSequence:create(acArr)
    self.bgLayer:runAction(seq)

end

function acNljjTab1:removeP()
    local p1=self.bgLayer:getChildByTag(901)
    local p2=self.bgLayer:getChildByTag(902)
    local p3=self.bgLayer:getChildByTag(903)
    if p1 then
        p1:removeFromParentAndCleanup(true)
    end
    if p2 then
        p2:removeFromParentAndCleanup(true)
    end
    if p3 then
        p3:removeFromParentAndCleanup(true)
    end
end

function acNljjTab1:runKaiOrHe(cent)
    local time=0.3
    if cent==1 then
        local moveAc1=CCMoveTo:create(time,self.leftPosTb[1])
        local moveAc2=CCMoveTo:create(time,self.rightPosTb[1])
        local moveAc3=CCMoveTo:create(time,self.upPosTb[1])
        self.leftSp:runAction(moveAc1)
        self.rightSp:runAction(moveAc2)
        self.upSp:runAction(moveAc3)

        for k,v in pairs(self.neiSpTb) do
            local moveAc=CCMoveTo:create(time,self.neiTb[k][1])
            v:runAction(moveAc)
        end
    elseif cent==2 then
        local moveAc1=CCMoveTo:create(time,self.leftPosTb[2])
        local moveAc2=CCMoveTo:create(time,self.rightPosTb[2])
        local moveAc3=CCMoveTo:create(time,self.upPosTb[2])
        self.leftSp:runAction(moveAc1)
        self.rightSp:runAction(moveAc2)
        self.upSp:runAction(moveAc3)
    else
        for k,v in pairs(self.neiSpTb) do
            local moveAc=CCMoveTo:create(time,self.neiTb[k][2])
            v:runAction(moveAc)
        end
    end
end


function acNljjTab1:endAction(reward,report,time)
    
    self.state=0
    self.touchDialogBg:setIsSallow(false)

    -- 移除粒子动画
    self:removeP()

    -- 进度条动画结束（左）
    self.bgLayer:stopAllActions()
    local nowPer,nowCent=acNljjVoApi:getPer()
    self.lastCent=nowCent
    self.timerSpriteLv:setPercentage(nowPer)
    -- （右）
    local flag=false
    if self.lastCent1 then
        if self.lastCent<self.lastCent1 then
            flag=true
        end
    end
    self:refreshDeng(self.lastCent,flag)
    -- 位置
    self:setActionPos(self.lastCent)

    if SizeOfTable(report)==1 then
        if acNljjVoApi:isAddHuangguang(reward[1].key,reward[1].num) then
            local paramTab={}
            paramTab.functionStr=acNljjVoApi:getActiveName()
            paramTab.addStr="i_also_want"
            local str=reward[1].name .. "x" .. reward[1].num
            local message={key="activity_nljj_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_nljj_title"),str}}
            chatVoApi:sendSystemMessage(message,paramTab)
        end
       
        local rewardPromptStr=getlocal("activity_nljj_score",{self.getPoint})
        acNljjVoApi:showRewardDialog(reward,self.layerNum,rewardPromptStr)
    else
        self:showTenSearch(report,time,self.getPoint)
        local function confirmHandler()
        end
    end
end

function acNljjTab1:showTenSearch(report,time,getPoint)
    local strSize2 = 18
    local subPos = 5
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =22
        subPos = -5
    end
    local layerNum=self.layerNum+1
    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
    end
   
    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)

    local iconSpTb={}
    local guangSpTb={}

    local function endCallback()
        if self.isAction==false then
            self.isAction=true
            for k,v in pairs(iconSpTb) do
                v:stopAllActions()
                v:setScale(100/v:getContentSize().width)
            end
            for k,v in pairs(guangSpTb) do
                v[1]:stopAllActions()
                v[1]:setScale(1.6)
                local rotateBy = CCRotateBy:create(4,360)
                local reverseBy = rotateBy:reverse()
                v[1]:runAction(CCRepeatForever:create(reverseBy))

                v[2]:stopAllActions()
                v[2]:setScale(1.6)
                local rotateBy = CCRotateBy:create(4,360)
                v[2]:runAction(CCRepeatForever:create(rotateBy))
            end
            local menu=layer:getChildByTag(101)
            if menu then
                menu:setVisible(true)
            end

        end
    end
    local diPic = "public/superWeapon/weaponBg.jpg"
    if scenePic then
        diPic = scenePic
    end
    local sceneSp=LuaCCSprite:createWithFileName(diPic,endCallback)
    sceneSp:setAnchorPoint(ccp(0,0))
    sceneSp:setPosition(ccp(0,0))
    sceneSp:setTouchPriority(-(layerNum-1)*20-1)
    self.myLayer:addChild(sceneSp)
    sceneSp:setColor(ccc3(150, 150, 150))
    sceneSp:setTouchPriority(-(self.layerNum-1)*20-10)

    sceneSp:setScaleY(G_VisibleSizeHeight/sceneSp:getContentSize().height)
    sceneSp:setScaleX(G_VisibleSizeWidth/sceneSp:getContentSize().width)

    -- activity_chunjiepansheng_getReward
    local subH1=0
    local subH2=0
    if(G_isIphone5())then
        subH1=80
        subH2=120
    end
    local titleLb = GetTTFLabelWrap(getlocal("activity_nljj_getReward",{getPoint}),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-70-subH1))
    titleLb:setColor(G_ColorYellowPro)
    layer:addChild(titleLb)

    local function runGuangAction(targetSp,delaytime,isReverse)
        local delay=CCDelayTime:create(delaytime)
        local scaleTo1 = CCScaleTo:create(0.2,2)
        local scaleTo2 = CCScaleTo:create(0.05,1.6)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)

        local function callback()
            local rotateBy = CCRotateBy:create(4,360)
            if isReverse then
                local reverseBy = rotateBy:reverse()
                targetSp:runAction(CCRepeatForever:create(reverseBy))
            else
                targetSp:runAction(CCRepeatForever:create(rotateBy))
            end
            
        end
        local callFunc=CCCallFunc:create(callback)
        acArr:addObject(callFunc)

        local seq=CCSequence:create(acArr)
        targetSp:runAction(seq)
    end

    local function runIconAction(targetSp,delaytime,numFlag)
        local delay=CCDelayTime:create(delaytime)
        local scale1=120/targetSp:getContentSize().width
        local scale2=100/targetSp:getContentSize().width
        local scaleTo1 = CCScaleTo:create(0.2,scale1)
        local scaleTo2 = CCScaleTo:create(0.05,scale2)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        if numFlag==10 then
            local function callback()
                self.isAction=true
                local menu=layer:getChildByTag(101)
                if menu then
                    menu:setVisible(true)
                end
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        targetSp:runAction(seq)
    end

    local subH = 170
    subH=subH+subH2
    local jiageH=160
    if(G_isIphone5())then
        jiageH=170
    end
    for k,v in pairs(report) do
        local i=math.ceil(k/3)
        local j=k%3
        if j==0 then
            j=3
        end

        local pos=ccp(68+(j-1)*200+50, G_VisibleSizeHeight-subH-(i-1)*jiageH)
        if k==10 then
            pos=ccp(68+(2-1)*200+50, G_VisibleSizeHeight-subH-(i-1)*jiageH)
        end

        local awardItem=FormatItem(v[2])[1]

        local icon,scale = G_getItemIcon(awardItem,100,true,layerNum)
        layer:addChild(icon,4)
        icon:setPosition(pos)
        icon:setTouchPriority(-(layerNum-1)*20-4)

        iconSpTb[k]=icon

        local nameStr=awardItem.name
        if awardItem.type=="w" then
            local eType=string.sub(awardItem.key,1,1)
            if eType=="c" then--能量结晶 
                local sbItem=superWeaponCfg.crystalCfg[awardItem.key]
                nameStr=getlocal(sbItem.name)

                local lvStr=getlocal("fightLevel",{sbItem.lvl})
                local lvLb=GetTTFLabel(lvStr,25)
                lvLb:setPosition(icon:getContentSize().width/2,80)
                icon:addChild(lvLb,1)
                lvLb:setScale(1/scale)
            end
        end
        local nameLb = GetTTFLabelWrap(nameStr,strSize2,CCSizeMake(190,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(ccp(icon:getContentSize().width/2,0))
        icon:addChild(nameLb)
        nameLb:setScale(1/scale)

        -- activity_nljj_score
        local scoreLb=GetTTFLabelWrap(getlocal("activity_nljj_score",{v[1]}),strSize2,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        scoreLb:setAnchorPoint(ccp(0.5,1))
        scoreLb:setPosition(ccp(icon:getContentSize().width/2,0-nameLb:getContentSize().height+subPos))
        icon:addChild(scoreLb)
        scoreLb:setScale(1/scale)

        icon:setScale(0.0001)

        
        -- delaytime
        local delayTime = (k-1)*0.2

        runIconAction(icon,delayTime,k)

        local flag = acNljjVoApi:isAddHuangguang(awardItem.key,awardItem.num)
        if flag == true then
            local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
            layer:addChild(guangSp1,1)
            guangSp1:setPosition(pos)
            guangSp1:setScale(0.0001)

            runGuangAction(guangSp1,delayTime,true)

            local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
            layer:addChild(guangSp2,1)
            guangSp2:setPosition(pos)
            guangSp2:setScale(0.0001)

            runGuangAction(guangSp2,delayTime)

            table.insert(guangSpTb,{guangSp1,guangSp2})

            local paramTab={}
            paramTab.functionStr=acNljjVoApi:getActiveName()
            paramTab.addStr="i_also_want"
            local str=awardItem.name .. "x" .. awardItem.num
            local message={key="activity_nljj_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_nljj_title"),str}}
            chatVoApi:sendSystemMessage(message,paramTab)
        end

    end

    local function callback1()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
    end
    local function callback2()
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self.sbCallback(3)
    end
    local menuItem={}
    menuItem[1]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback1,nil,getlocal("confirm"),25)
    menuItem[2]=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callback2,nil,getlocal("activity_nljj_btn",{10}),25)

    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[2])
    btnMenu:addChild(menuItem[1])
    
    btnMenu:alignItemsHorizontallyWithPadding(160)
    layer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(140) 
    btnMenu:setTag(101)

    if(G_isIphone5())then
        btnMenu:setPositionY(btnMenu:getPositionY()+10) 
    end


    local costLbPosY=90
    local costNum=acNljjVoApi:getCostByType(2)
    local costLb=GetTTFLabel(costNum .. "  ",25)
    costLb:setAnchorPoint(ccp(0,0.5))
    menuItem[2]:addChild(costLb)

    local gems=playerVoApi:getGems() or 0
    if costNum>gems then
        costLb:setColor(G_ColorRed)
    end

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
    costLb:addChild(goldIcon,1)

    costLb:setPosition(menuItem[2]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,costLbPosY)

    self.isAction = false

    btnMenu:setVisible(false)

    if time then
        endCallback()
    end
end


function acNljjTab1:initTableView()
    -- weaponBg
    self:addRecord()

    self.leftPosTb={ccp(202, 348.5),ccp(189, 348.5)}
    self.rightPosTb={ccp(389.5, 284),ccp( 409.5, 284)}
    self.upPosTb={ccp(312, 493),ccp(312, 512)}

    local subH=25
    if(G_isIphone5())then
        subH=-50
    end
    self.subH=subH
    for i=1,2 do
        self.leftPosTb[i].y=self.leftPosTb[i].y-subH
        self.rightPosTb[i].y=self.rightPosTb[i].y-subH
        self.upPosTb[i].y=self.upPosTb[i].y-subH
    end

    local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
    spriteShapeInfor:setScale(1.5)
    spriteShapeInfor:setOpacity(200)
    spriteShapeInfor:setPosition(ccp(318.5, 382.5))
    self.bgLayer:addChild(spriteShapeInfor,2)
    spriteShapeInfor:setPositionY(spriteShapeInfor:getPositionY()-subH)

    local diSp1=CCSprite:createWithSpriteFrameName("acNljj_di1.png")
    self.bgLayer:addChild(diSp1,2)
    diSp1:setPosition(318.5, 382.5)
    diSp1:setPositionY(diSp1:getPositionY()-subH)

    self.quanSpTb={}
    for i=1,2 do
        local quanSp=CCSprite:createWithSpriteFrameName("acNljj_guang.png")
        self.bgLayer:addChild(quanSp,2)
        quanSp:setPosition(318.5, 382.5)
        self.quanSpTb[i]=quanSp
        if i==2 then
            quanSp:setScale(321/quanSp:getContentSize().width)
        end
        quanSp:setVisible(false)
        quanSp:setPositionY(quanSp:getPositionY()-subH)
    end
    
    local diSp2=CCSprite:createWithSpriteFrameName("acNljj_di2.png")
    self.bgLayer:addChild(diSp2,3)
    diSp2:setPosition(322, 379)
    diSp2:setPositionY(diSp2:getPositionY()-subH)

    local upSp=CCSprite:createWithSpriteFrameName("acNljj_up.png")
    self.bgLayer:addChild(upSp,3)
    -- upSp:setPosition(312, 493)
    -- diSp2:setPositionY(diSp2:getPositionY()-subH)
    self.upSp=upSp

    
    -- 左
    local leftSp=CCSprite:createWithSpriteFrameName("acNljj_left.png")
    self.bgLayer:addChild(leftSp,3)
    -- leftSp:setPosition(202, 348.5)
    self.leftSp=leftSp

    -- 温度进度条
    AddProgramTimer(leftSp,ccp(82, 112.5),11,nil,nil,"acNljj_pbg1.png","acNljj_p1.png",13,1,1,nil,ccp(0,1))
    local timerSpriteLv=leftSp:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPosition(65, 117)
    timerSpriteLv:setMidpoint(ccp(1,0))
    local nowPer,nowCent=acNljjVoApi:getPer()
    self.lastCent=nowCent
    timerSpriteLv:setPercentage(nowPer)
    self.timerSpriteLv=timerSpriteLv

    local nowVNum=acNljjVoApi:getV()
    local nowVLb=GetTTFLabel(nowVNum,20)
    leftSp:addChild(nowVLb)
    nowVLb:setPosition(ccp(37.5, 246))
    self.nowVLb=nowVLb
    self.nowVLb:setVisible(false)

    -- 右
    local rightSp=CCSprite:createWithSpriteFrameName("acNljj_right.png")
    self.bgLayer:addChild(rightSp,3)
    -- rightSp:setPosition(389.5, 284)
    self.rightSp=rightSp

    AddProgramTimer(rightSp,ccp(136, 104.5),11,nil,nil,"acNljj_pbg2.png","acNljj_p2.png",13,1,1,nil,ccp(0,1))
    local timerSpriteLv2=rightSp:getChildByTag(11)
    timerSpriteLv2=tolua.cast(timerSpriteLv2,"CCProgressTimer")
    timerSpriteLv2:setPosition(135.5, 105)
    timerSpriteLv2:setMidpoint(ccp(1,0))

    timerSpriteLv2:setPercentage(50)
    self.timerSpriteLv2=timerSpriteLv2

    

    local dengTb={ccp(184, 71),ccp(222.5, 126.5),ccp(249, 199)}

    self.dengSp={}
    for k,v in pairs(dengTb) do
        local dPic
        if k==1 then
            dPic="acNljj_dSmall.png"
        elseif k==2 then
            dPic="acNljj_dMiddle.png"
        else
            dPic="acNljj_dBig.png"
        end
        local dengSpGray = GraySprite:createWithSpriteFrameName(dPic)
        rightSp:addChild(dengSpGray,3)
        dengSpGray:setPosition(v)

        local dengSp=CCSprite:createWithSpriteFrameName(dPic)
        rightSp:addChild(dengSp,3)
        dengSp:setPosition(v)
        self.dengSp[k]=dengSp
    end

    self:refreshDeng(self.lastCent)

    local neiTb={{ccp(322, 449),ccp(322, 465)},{ccp(262, 344),ccp(248, 336)},{ccp(382, 344),ccp(396, 336)}}

    for k,v in pairs(neiTb) do
        v[1].y=v[1].y-subH
        v[2].y=v[2].y-subH
    end

    self.neiTb=neiTb
    self.neiSpTb={}
    for k,v in pairs(neiTb) do
        local neiSp=CCSprite:createWithSpriteFrameName("acNljj_nei.png")
        self.bgLayer:addChild(neiSp,3)

        if k==2 then
            neiSp:setRotation(-120)
        elseif k==3 then
            neiSp:setRotation(120)
        end
        self.neiSpTb[k]=neiSp
    end

    self:setActionPos(self.lastCent)
end

function acNljjTab1:setActionPos(cent)
    if cent==1 then
        self.leftSp:setPosition(self.leftPosTb[1])
        self.rightSp:setPosition(self.rightPosTb[1])
        self.upSp:setPosition(self.upPosTb[1])

        -- 内层
        for k,v in pairs(self.neiSpTb) do
            v:setPosition(self.neiTb[k][1])
        end

    else
        self.leftSp:setPosition(self.leftPosTb[2])
        self.rightSp:setPosition(self.rightPosTb[2])
        self.upSp:setPosition(self.upPosTb[2])

        if cent==2 then
            for k,v in pairs(self.neiSpTb) do
                v:setPosition(self.neiTb[k][1])
            end

            
        else
            for k,v in pairs(self.neiSpTb) do
                v:setPosition(self.neiTb[k][2])
            end
            
        end
    end

end

function acNljjTab1:refreshDeng(cent,flag)
    for k,v in pairs(self.dengSp) do
        if k>cent then
            v:setVisible(false)
        else
            v:setVisible(true)
        end
    end
    if cent==1 then
        self.timerSpriteLv2:setPercentage(30)

        -- 光
        for k,v in pairs(self.quanSpTb) do
            v:setVisible(false)
        end
    elseif cent==2 then
        self.timerSpriteLv2:setPercentage(55)

        -- 光
        for k,v in pairs(self.quanSpTb) do
            if k==2 then
                v:setVisible(true)
            else
                v:setVisible(false)
            end
        end
    else
        self.timerSpriteLv2:setPercentage(100)
        -- 光
        for k,v in pairs(self.quanSpTb) do
            v:setVisible(true)
        end
    end
    local desStr=getlocal("activity_nljj_rwDes" .. cent)
    if flag and  cent==1 then
        desStr=getlocal("activity_nljj_rwDes4") .. desStr
    end
    self.sbLb:setString(desStr)
end

function acNljjTab1:addRecord()
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 22
    end
    self.addH=50
    if(G_isIphone5())then
        self.addH=190
    end
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
           acNljjVoApi:showLogRecord(self.layerNum+1)
        end
        acNljjVoApi:getLog(showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(570, 500))
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
           acNljjVoApi:showAllreward(self.layerNum+1)
        -- end
        -- acNljjVoApi:getLog(showReward)
    end
    local rewardItem=GetButtonItem("SeniorBox.png","SeniorBox.png","SeniorBox.png",rewardRecordsHandler,11,nil,nil)
    rewardItem:setScale(0.5)
    local rewardBtn=CCMenu:createWithItem(rewardItem)
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardBtn:setPosition(ccp(80, 500))
    self.bgLayer:addChild(rewardBtn,4)
    rewardBtn:setPositionY(rewardBtn:getPositionY()+self.addH)

    local recordLb=GetTTFLabelWrap(getlocal("local_war_help_title9"),strSize2,CCSize(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(rewardItem:getContentSize().width/2,8)
    recordLb:setScale(1/rewardItem:getScale())
    rewardItem:addChild(recordLb)

end


function acNljjTab1:refresh()
    self:refreshCostLb()
end

function acNljjTab1:tick()
    if acNljjVoApi:acIsStop() then
        self:refreshRewardTime()
    end
    self:updateAcTime()
end

function acNljjTab1:refreshRewardTime()
    if self.menuItem1 and self.menuItem2 and self.freeItem then
        if self.freeItem:isEnabled() or self.menuItem1:isEnabled() then
            self.freeItem:setEnabled(false)
            self.menuItem1:setEnabled(false)
            self.menuItem2:setEnabled(false)
        end
    end
end

function acNljjTab1:addHorizontalTv(tvSize,cellSize,content,layerNum)
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(content)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            tmpSize=cellSize
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local awardItem=content[idx+1]

            local icon,scale=G_getItemIcon(awardItem,cellSize.height,true,layerNum)
            icon:setTouchPriority(-(layerNum-1)*20-2)
            cell:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(0,cellSize.height/2)

            if acNljjVoApi:isAddHuangguang(awardItem.key,awardItem.num) then
                -- G_addRectFlicker(icon,1.3,1.3)
                G_addRectFlicker2(icon,1.3,1.3,2,"p")
            end
            

            if awardItem.type=="w" then
                local eType=string.sub(awardItem.key,1,1)
                if eType=="c" then--能量结晶 
                    local sbItem=superWeaponCfg.crystalCfg[awardItem.key]

                    local lvStr=getlocal("fightLevel",{sbItem.lvl})
                    local lvLb=GetTTFLabel(lvStr,25)
                    lvLb:setPosition(icon:getContentSize().width/2,80)
                    icon:addChild(lvLb,1)
                    lvLb:setScale(1/scale)
                end
            end

            local numLb=GetTTFLabel("x"..FormatNumber(content[idx+1].num),20)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(ccp(icon:getContentSize().width-5,0))
            icon:addChild(numLb,4)
            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            return cell
        elseif fn=="ccTouchBegan" then
            -- self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            -- self.isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end

    local function callBack(...)
        return eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local tv=LuaCCTableView:createHorizontalWithEventHandler(hd,tvSize,nil)
    -- tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- tv:setPosition(ccp(30,posY - 95))
    -- tv:setMaxDisToBottomOrTop(80)
    -- self.bgLayer:addChild(tv)
    return tv
end



function acNljjTab1:fastTick()
    if self.state==3 then
        self:endAction(self.reward,self.report,0)
    end      
end

function acNljjTab1:updateAcTime()
    local acVo=acNljjVoApi:getAcVo()
    if acVo and self.timeLb1 and self.timeLb2 then
        G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true,true)
    end
end

function acNljjTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.state = 0 
    self.timeLb1=nil
    self.timeLb2=nil
end
