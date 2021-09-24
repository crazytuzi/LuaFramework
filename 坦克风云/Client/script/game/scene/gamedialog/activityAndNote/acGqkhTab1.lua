acGqkhTab1 = {}

function acGqkhTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
    self.isDouble=false
    self.isToday=true
    self.kuanSp={}
    self.tank={}
    self.tankBarrel={}
    self.state = 0 
    self.lingquLbTb={}
    self.costLb={}
	return nc
end

function acGqkhTab1:init(layerNum)
    self.activeName=acGqkhVoApi:getActiveName()
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	return self.bgLayer
end

function acGqkhTab1:initLayer()
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
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
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local acBg=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    acBg:setAnchorPoint(ccp(0.5,0.5))
    acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50)
    acBg:setOpacity(180)
    acBg:setScale(0.96)
    if (G_isIphone5()) then
        acBg:setScaleY(1.3)
    end
    self.bgLayer:addChild(acBg)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
    titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,45))
    titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180)
    self.bgLayer:addChild(titleBg)
    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180 + 45/2))
    self.bgLayer:addChild(orangeLine)
    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180 - 45/2))
    self.bgLayer:addChild(orangeLine)

    local titleLb=GetTTFLabel(getlocal("activity_timeLabel") .. " ",strSize2)
    titleLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(titleLb)
    local acVo = acGqkhVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,strSize2)
    timeLabel:setAnchorPoint(ccp(0,0.5))
    titleLb:addChild(timeLabel)
    timeLabel:setPosition(titleLb:getContentSize().width,titleLb:getContentSize().height/2)
    self.timeLb=timeLabel
    self:updateAcTime()
    titleLb:setPosition(G_VisibleSizeWidth/2-timeLabel:getContentSize().width/2,G_VisibleSizeHeight-180)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("activity_gqkh_tip5"),getlocal("activity_gqkh_tip4"), getlocal("activity_gqkh_tip3"),getlocal("activity_gqkh_tip2"),getlocal("activity_gqkh_tip1"),"\n"}
        local tabColor={nil,nil,nil,nil,nil}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoBtnImage1,infoBtnImage2,infoBtnImage3="BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png"
    if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
        infoBtnImage1,infoBtnImage2,infoBtnImage3="i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png"
    end
    local menuItemDesc=GetButtonItem(infoBtnImage1,infoBtnImage2,infoBtnImage3,touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-25, self.bgLayer:getContentSize().height-195))
    self.bgLayer:addChild(menuDesc,2)

    local subH=0
    if (G_isIphone5()) then
        subH=20
    end
    local roundLb=GetTTFLabelWrap(getlocal("activity_gqkh_rounds",{acGqkhVoApi:getR()}),25,CCSizeMake(145,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    roundLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(roundLb)
    roundLb:setPosition(35,G_VisibleSizeHeight-300+50-subH)
    self.roundLb=roundLb


    AddProgramTimer(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-300-subH),100,12,nil,"platWarProgressBg.png","platWarProgress1.png",131,1,1)
    self:setProgressPer()

    local bg = self.bgLayer:getChildByTag(131)
    local lvUp=acGqkhVoApi:getlvUp()
    local numLvUp=SizeOfTable(lvUp)
    local roundNum=acGqkhVoApi:getR()

    local function touchReward(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)

            local cfg=acGqkhVoApi:getVersionCfg()
            local reward=cfg.roundReward[lvUp[tag]].reward
            local item=FormatItem(reward,nil,true)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
            local sd = acChunjiepanshengSmallDialog:new()
            local desStr=getlocal("activity_gqkh_logDes3",{lvUp[tag]})
            sd:init(true,true,self.layerNum+1,desStr,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),item)
        end
    end

    local bgWidth=bg:getContentSize().width
    for i=1,numLvUp do
        if i<numLvUp then
            local subW=0
            if i==1 then
                subW=4
            elseif i==numLvUp-1 then
                subW=-4
            end
            local keduSp = CCSprite:createWithSpriteFrameName("acChunjiepansheng_fengexian.png")
            keduSp:setRotation(90)
            bg:addChild(keduSp)
            keduSp:setScale(0.8)
            keduSp:setPosition(bgWidth/5*i+subW,bg:getContentSize().height/2)
        end
        if i==numLvUp then
            local size=bg:getContentSize()
            local x,y=bg:getPosition()
            local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
            guangSp1:setPosition((G_VisibleSizeWidth-size.width)/2+size.width/5*i,y+60-size.height/2)
            self.bgLayer:addChild(guangSp1)
            -- guangSp1:setScale(0.85)

        end
        

        local rewardSp = LuaCCSprite:createWithSpriteFrameName("friendBtn.png",touchReward)
        rewardSp:setTouchPriority(-(self.layerNum-1)*20-4)
        rewardSp:setPosition(bgWidth/5*i,60)
        rewardSp:setTag(i)
        bg:addChild(rewardSp)
        rewardSp:setScale(0.8)



        local lingquLb=GetTTFLabel(getlocal("activity_hadReward"),25)
        lingquLb:setPosition(rewardSp:getContentSize().width/2,rewardSp:getContentSize().height/2)
        rewardSp:addChild(lingquLb,2)

        local lingquBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
        lingquBg:setScaleX((lingquLb:getContentSize().width+5)/lingquBg:getContentSize().width)
        lingquBg:setPosition(rewardSp:getContentSize().width/2,rewardSp:getContentSize().height/2)
        rewardSp:addChild(lingquBg)
        lingquBg:setOpacity(160)

        if roundNum>=lvUp[i] then
            lingquBg:setVisible(true)
            lingquLb:setVisible(true)
        else
            lingquBg:setVisible(false)
            lingquLb:setVisible(false)
        end

        self.lingquLbTb[lvUp[i]]={lingquBg,lingquLb}

        local numLb=GetTTFLabel(lvUp[i],25)
        numLb:setPosition(bgWidth/5*i,-20)
        bg:addChild(numLb)
    end

    local subH2=0
    if (G_isIphone5()) then
        subH2=20
    end

    local function nilFunc()
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-380-subH-subH2))
    descBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
    descBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(descBg)

    local goldLineSp=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSp:setAnchorPoint(ccp(0.5,1))
    goldLineSp:setPosition(ccp(descBg:getContentSize().width/2,descBg:getContentSize().height-5))
    descBg:addChild(goldLineSp)

    local throwNumLb=GetTTFLabelWrap(getlocal("activity_gqkh_numLimit",{}),25,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    throwNumLb:setAnchorPoint(ccp(0,1))
    throwNumLb:setPosition(10,descBg:getContentSize().height-40)
    descBg:addChild(throwNumLb)
    self.throwNumLb=throwNumLb
    self:setThrowNumLb()

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
            acGqkhVoApi:showLogRecord(self.layerNum+1)
        end
        acGqkhVoApi:getLog(self.activeName,showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(G_VisibleSizeWidth-recordBtn:getContentSize().width*recordBtn:getScaleX()-15,G_VisibleSizeHeight-420-subH-subH2))
    self.bgLayer:addChild(recordMenu)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,-5)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)
    

    self:addMap()

    self:addTouchBtn()
    self:addDoubleMenu()
    
end

function acGqkhTab1:setProgressPer()
    local per = acGqkhVoApi:getPercentage()
    local timerSpriteLv = self.bgLayer:getChildByTag(100)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)

    local roundNum=acGqkhVoApi:getR()
    self.roundLb:setString(getlocal("activity_gqkh_rounds",{roundNum}))
end



function acGqkhTab1:setThrowNumLb()
    -- self.throwNumLb
    if self.throwNumLb then
        local limit=acGqkhVoApi:getLimit()
        local throwNum=acGqkhVoApi:getC()
        self.throwNumLb:setString(getlocal("activity_gqkh_numLimit",{throwNum .. "/" .. limit}))
    end
end

function acGqkhTab1:addMap()
    local spriteBatch = CCSpriteBatchNode:create("public/acGqkh.png")
    self.bgLayer:addChild(spriteBatch)
    self.spriteBatch=spriteBatch
    local currentPos=acGqkhVoApi:getS()

    local rewardTb,roundNum,cfg,rewardNum=acGqkhVoApi:getRoundReward()
    self.oldRewardNum=rewardNum
    self:getMoveTank()

    local mapTb={ccp(322, 178),ccp(378, 206),ccp(434, 234),ccp(490, 262),ccp(546, 290),ccp(490, 318),ccp(434, 346),ccp(490, 374),ccp(546, 402),ccp(490, 430),ccp(434, 458),ccp(378, 486),ccp(322, 514),ccp(266, 486),ccp(210, 458),ccp(134.5, 430),ccp(210, 402),ccp(266, 374),ccp(210, 346),ccp(154, 318),ccp(98, 290),ccp(154, 262),ccp(210, 234),ccp(266, 206)}
    local guangTb1={[1]=ccp(321.5, 175),[7]=ccp(433.5, 343),[13]=ccp(321.5, 511),[16]=ccp(134, 426),[21]=ccp(97.5, 287)}
    local guangTb2={[1]=ccp(321.5, 201),[7]=ccp(433.5, 369),[13]=ccp(321.5, 537),[16]=ccp(134, 461),[21]=ccp(97.5, 313)}
    for i=1,24 do
        local pic
        local color=cfg.map[i].color
        if color==1 then
            pic="acGqkh_green2.png"
        elseif color==2 then
            pic="acGqkh_green1.png"
        elseif color==3 then
            pic="acGqkh_yellow.png"
        elseif color==4 then
            pic="acGqkh_blue.png"
        elseif color==5 then
            pic="acGqkh_bigGreen.png"
        elseif color==6 then
            pic="acGqkh_green2.png"
        else
            pic="acGqkh_yellow.png"
        end
        
        
        local x,y
        local addH=0
        if G_getIphoneType() == G_iphoneX then
            addH = 150
        elseif(G_isIphone5())then
            addH=100
        end
        x,y=mapTb[i].x,mapTb[i].y+addH

        local byPic
        if color==5 then
            byPic="acGqkh_bigBlack.png"
        else
            byPic="acGqkh_smallBlack.png"
        end
        local bySp=CCSprite:createWithSpriteFrameName(byPic)
        bySp:setPosition(x,y-5)
        self.spriteBatch:addChild(bySp)

        local kuanSp=CCSprite:createWithSpriteFrameName(pic)
        kuanSp:setPosition(x,y)
        self.bgLayer:addChild(kuanSp)
        self.kuanSp[i]=kuanSp

        local smallIcon,scale=G_getItemIcon(rewardTb[i],100)
        smallIcon:setScale(40/smallIcon:getContentSize().width)
        kuanSp:addChild(smallIcon,3)
        smallIcon:setPosition(kuanSp:getContentSize().width/2,kuanSp:getContentSize().height/2)


        local bigIcon,scale=G_getItemIcon(rewardTb[i],100,true,self.layerNum)
        bigIcon:setScale(56/bigIcon:getContentSize().width)
        kuanSp:addChild(bigIcon,3)
        bigIcon:setPosition(kuanSp:getContentSize().width/2,kuanSp:getContentSize().height/2)
        bigIcon:setVisible(false)
        if roundNum==0 and i==1 and currentPos==1 then
            smallIcon:setVisible(false)
            self.iconPropSp1=smallIcon
            self.iconPropSp2=bigIcon
        else
            bigIcon:setTouchPriority(-(self.layerNum-1)*20-3)
        end
        if color>4 then
            local lightR1
            local lightR2
            if color==5 then
                lightR1="acGqkh_bigLight1.png"
                lightR2="acGqkh_bigLight2.png"
            else
                lightR1="acGqkh_smallLight1.png"
                lightR2="acGqkh_smallLight2.png"
            end
            local lightSp1=CCSprite:createWithSpriteFrameName(lightR1)
            self.bgLayer:addChild(lightSp1,3)
            lightSp1:setPosition(guangTb1[i].x,guangTb1[i].y+addH)
            -- lightSp1:setOpacity(180)

            local lightSp2=CCSprite:createWithSpriteFrameName(lightR2)
            self.bgLayer:addChild(lightSp2,1)
            lightSp2:setPosition(guangTb2[i].x,guangTb2[i].y+addH)
            -- lightSp2:setOpacity(180)
        end
        if i==1 then
            local qiziSp=CCSprite:createWithSpriteFrameName("platWarFlag1.png")
            self.kuanSp[i]:addChild(qiziSp)
            qiziSp:setPosition(self.kuanSp[i]:getContentSize().width/2+10,self.kuanSp[i]:getContentSize().height)
            self.qiziSp=qiziSp
            qiziSp:setScale(0.5)
            qiziSp:setAnchorPoint(ccp(0.5,0))
            if roundNum==0 and currentPos==1 then
                self.qiziSp:setVisible(false)
            else
                self.qiziSp:setVisible(true)
            end
        end
        
        if i==currentPos then
            self:setMoveTank(cfg.map[i].direction,ccp(x,y+4))
            self:tankStopAction()
        end
    end
end

function acGqkhTab1:addTouchBtn()
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
            strSize2 =25
    end
    local function sureHandler(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)

            local free=false
            if tag==1 then
                free=acGqkhVoApi:canReward()
            end
            if free==false then
                local limit=acGqkhVoApi:getLimit()
                local throwNum=acGqkhVoApi:getC()
                if throwNum>=limit then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gqkh_limitNum"),30)
                    do return end
                end
            end
            
            if tag==1 and  free and self.isDouble==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gqkh_notFreeDouble"),30)
                do return end
            end
            local needCost=0
            if free==false then
                needCost=acGqkhVoApi:getCostByType(tag,self.isDouble)
            end
            local haveCost=playerVoApi:getGems() or 0
            if haveCost<needCost then
                GemsNotEnoughDialog(nil,nil,needCost-haveCost,self.layerNum+1,needCost)
                return
            end
            local rate=0
            if self.isDouble then
                rate=1
            end
            
            local function refreshFunc()
                if tag==1 and free then
                    self.isToday=true
                end
                self.touchDialogBg:setIsSallow(true)
                self:setThrowNumLb()
                self:refreshCostLb()
                self:runThrowAction()
            end
            self.oldS=acGqkhVoApi:getS()
            local function callBack(point)
                acGqkhVoApi:throwDice(point,free,rate,self.activeName,refreshFunc,needCost)
            end
            if tag==1 then
                callBack(0)
            else
                require "luascript/script/game/scene/gamedialog/activityAndNote/acGqkhSPSmallDialog"
                acGqkhSPSmallDialog:showScrollDialog("TankInforPanel.png",CCRect(130, 50, 1, 1),CCSizeMake(550,380),self.layerNum+1,nil,true,callBack,self.bgLayer)
            end
        end
    end

    local function callback1()
        sureHandler(1)
    end
    local function callback2()
        sureHandler(2)
    end

    local addH=0
    if(G_isIphone5())then
        addH=20
    end
    local menuItemImage1,menuItemImage2,menuItemImage3="BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png"
    if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
        menuItemImage1,menuItemImage2,menuItemImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    local menuItem={}
    menuItem[1]=GetButtonItem(menuItemImage1,menuItemImage2,menuItemImage3,callback1,nil,getlocal("activity_gqkh_btn1"),25)
    menuItem[2]=GetButtonItem(menuItemImage1,menuItemImage2,menuItemImage3,callback2,nil,getlocal("activity_gqkh_btn2"),strSize2)
    self.menuItem1=menuItem[1]
    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    btnMenu:alignItemsHorizontallyWithPadding(150)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(80+addH)

    local freeItemImage1,freeItemImage2,freeItemImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png"
    if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
        freeItemImage1,freeItemImage2,freeItemImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
    end
    local freeItem=GetButtonItem(freeItemImage1,freeItemImage2,freeItemImage3,callback1,nil,getlocal("activity_gqkh_btn1"),25)
    local freeBtn=CCMenu:createWithItem(freeItem)
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.freeItem=freeItem
    freeBtn:setPosition(G_VisibleSizeWidth/2-75-freeItem:getContentSize().width/2,80+addH)
    self.bgLayer:addChild(freeBtn)

    self.costLb={}
    for i=1,2 do
        local costNum=acGqkhVoApi:getCostByType(i)
        local costLb=GetTTFLabel(costNum .. "  ",25)
        costLb:setAnchorPoint(ccp(0,0.5))
        menuItem[i]:addChild(costLb)
        self.costLb[i]=costLb

        if i==1 then
            local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 25)
            freeLb:setPosition(ccp(menuItem[i]:getContentSize().width/2, 90))
            freeLb:setColor(G_ColorGreen)
            freeItem:addChild(freeLb)
            self.freeLb=freeLb
        end

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setAnchorPoint(ccp(0,0.5))
        goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
        costLb:addChild(goldIcon,1)

        costLb:setPosition(menuItem[i]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,90)
    end
    self:refreshCostLb()

end

function acGqkhTab1:runThrowAction()
    self.dice1Sp=CCSprite:createWithSpriteFrameName("DicePlay01.png")
    self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 80
    elseif G_getIphoneType() == G_iphone4 then
        adaH = 50
    end
    self.dice1Sp:setPosition(ccp(self.bgLayer:getContentSize().width/2+adaH/4,self.bgLayer:getContentSize().height/2-40-adaH))
    self.bgLayer:addChild(self.dice1Sp)
    self:playDice()
end


function acGqkhTab1:refreshCostLb()
    if self.freeLb then
        if acGqkhVoApi:canReward()==true then
            self.freeLb:setVisible(true)
            self.costLb[1]:setVisible(false)
            self.freeItem:setVisible(true)
            self.freeItem:setEnabled(true)
            self.menuItem1:setVisible(false)
            self.menuItem1:setEnabled(false)
        else
            self.freeLb:setVisible(false)
            self.costLb[1]:setVisible(true)
            self.freeItem:setVisible(false)
            self.freeItem:setEnabled(false)
            self.menuItem1:setVisible(true)
            self.menuItem1:setEnabled(true)
        end
    end
    
end

function acGqkhTab1:refreshCostNum()
    for i=1,2 do
        if self.costLb[i] then
            local costNum=acGqkhVoApi:getCostByType(i,self.isDouble)
            self.costLb[i]:setString(costNum)
        end
    end

end

function acGqkhTab1:addDoubleMenu()
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    local addH=0
    if(G_isIphone5())then
        addH=35
    end
    local strWidth2 = 140
    if G_getCurChoseLanguage() =="ar" then
        strWidth2 =110
    end
    local function touchDoubleSp()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
            if self.isDouble==false then
                self.isDouble=true
                G_addRectFlicker(self.menuBg,2.5,0.75)
                self.doubleSp:setVisible(true)
                self:refreshCostNum()
            else
                self.isDouble=false
                G_removeFlicker(self.menuBg)
                self.doubleSp:setVisible(false)
                self:refreshCostNum()
            end
        end
    end
    local function nilFunc()
    end
    local menuBg =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),touchDoubleSp)
    menuBg:setContentSize(CCSizeMake(170,50))
    menuBg:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(menuBg)
    menuBg:setAnchorPoint(ccp(1,0.5))
    menuBg:setPosition(G_VisibleSizeWidth-30,180+addH)
    menuBg:setOpacity(0)
    self.menuBg=menuBg

    local unDoubleSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
    menuBg:addChild(unDoubleSp)
    unDoubleSp:setAnchorPoint(ccp(0,0.5))
    -- unDoubleSp:setTouchPriority(-(self.layerNum-1)*20-3);
    unDoubleSp:setPosition(0,menuBg:getContentSize().height/2)

    local doubleLb=GetTTFLabelWrap(getlocal("activity_gqkh_double"),strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    doubleLb:setAnchorPoint(ccp(0,0.5))
    unDoubleSp:addChild(doubleLb)
    doubleLb:setPosition(unDoubleSp:getContentSize().width,unDoubleSp:getContentSize().height/2)

    local doubleSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    unDoubleSp:addChild(doubleSp)
    doubleSp:setPosition(unDoubleSp:getContentSize().width/2,unDoubleSp:getContentSize().height/2)
    doubleSp:setVisible(false)
    self.doubleSp=doubleSp

    -- G_addRectFlicker(menuBg,2.5,0.75)
end



function acGqkhTab1:eventHandler(handler,fn,idx,cel)
end

function acGqkhTab1:refreshVisible()
end

function acGqkhTab1:playDice()
    local pzArr1=CCArray:create()
    for kk=1,6 do
        local nameStr="DicePlay0"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr1:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr1)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local acRepeat=CCRepeat:create(animate,2)

    local acArray=CCArray:create()
    acArray:addObject(acRepeat)

    local function acFunc()
        self.dice1Sp:removeFromParentAndCleanup(true)
        self.dice1Sp=nil
        self:tankRemoveAction()
        local curPos=acGqkhVoApi:getS()
        local point=acGqkhVoApi:getPoint()
        local cfg=acGqkhVoApi:getVersionCfg()
        local roundNum=acGqkhVoApi:getR()
        if curPos-point<=0 and cfg.roundReward[roundNum] then
        else
            self.state=2
        end
        
        self:setDiceSp(point)
        self:moveAction(point)
    end
    local callFunc=CCCallFunc:create(acFunc)
    acArray:addObject(callFunc)
    local seq=CCSequence:create(acArray)
    self.dice1Sp:runAction(seq)
end

function acGqkhTab1:moveAction(point)
    local tankSp=self:getCurrentTank()
    if self.oldS+1>24 then
        self.oldS=self.oldS+1-24
    else
        self.oldS=self.oldS+1
    end
    local x,y=self.kuanSp[self.oldS]:getPosition()
    local moveTo=CCMoveTo:create(0.3,CCPointMake(x,y+4))
    local arrAc=CCArray:create()
    arrAc:addObject(moveTo)
    local function onMoveEnd()
        local cfg=acGqkhVoApi:getVersionCfg()
        self:setMoveTank(cfg.map[self.oldS].direction,ccp(x,y+4))
        local function nextMove()
            if point-1>0 then
                self:moveAction(point-1)
                self:createDiceSp(point-1)
            else
                self:setDiceSp(point-1)
                self:runGeziAc()
            end
        end
        if self.oldS==1 then
            self:changeReward()
            self:showRoundReward(nextMove)
        else
            nextMove()
        end
        
    end
    local moveEndFunc=CCCallFunc:create(onMoveEnd)
    arrAc:addObject(moveEndFunc)
    local seq=CCSequence:create(arrAc)
    tankSp:runAction(seq)
end

function acGqkhTab1:showGeziReward()
    local cfg=acGqkhVoApi:getVersionCfg()
    local roundNum = acGqkhVoApi:getR()
    local rewardNum=acGqkhVoApi:gerRewardNum(roundNum)
    local geziNum=acGqkhVoApi:getS()
    local reward
    if rewardNum==0 then
        reward=cfg.map[geziNum].reward[SizeOfTable(cfg.map[geziNum].reward)]
    else
        reward=cfg.map[geziNum].reward[rewardNum]
    end
    local rewardItem=FormatItem(reward)
    if self.isDouble then
        for k,v in pairs(rewardItem) do
            v.num=v.num*2
        end
    end
    
    if cfg.map[geziNum].color==5 then
        local paramTab={}
        paramTab.functionStr=self.activeName
        paramTab.addStr="i_also_want"
        local str=self:getRewardStr(rewardItem)
        local _acTitleKey="activity_gqkh_title"
        if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
            _acTitleKey="activity_gqkh_title_1"
        end
        local message={key="activity_gqkh_notice1",param={playerVoApi:getPlayerName(),getlocal(_acTitleKey),str}}
        chatVoApi:sendSystemMessage(message,paramTab)
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardItemDialog("TankInforPanel.png",CCSizeMake(550,450),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),rewardItem,false,self.layerNum+1)
    self.touchDialogBg:setIsSallow(false)
end

function acGqkhTab1:runGeziAc()
    local nowPos=acGqkhVoApi:getS()
    local cfg=acGqkhVoApi:getVersionCfg()
    if cfg.map[nowPos].color<5 then
        local arrAc=CCArray:create()
        for i=1,3 do
            local opacity
            if i==1 then
                opacity=60
            elseif i==2 then
                opacity=255
            else
                opacity=0
            end
            local fadeAc=CCFadeTo:create(0.3, opacity)
            arrAc:addObject(fadeAc)
        end
        local function fadeEnd()
            self:stopAllAction()
            local acNode=self.kuanSp[nowPos]:getChildByTag(101)
            if acNode then
                acNode:removeFromParentAndCleanup(true)
            end
        end
        local fadeEndFunc=CCCallFunc:create(fadeEnd)
        arrAc:addObject(fadeEndFunc)
        local seq=CCSequence:create(arrAc)

        local acSp=CCSprite:createWithSpriteFrameName("acGqkh_white.png")
        self.kuanSp[nowPos]:addChild(acSp)
        acSp:setPosition(self.kuanSp[nowPos]:getContentSize().width/2,self.kuanSp[nowPos]:getContentSize().height/2)
        acSp:setTag(101)
        acSp:runAction(seq)
    else
        local numP=1
        if cfg.map[nowPos].color==5 then
            numP=3
        end
        local arrAc=CCArray:create()
        
        local delay=CCDelayTime:create(2)
        local function addPlist(i)
            local pResource
            if i==1 then
                pResource="public/acGqkh_red.plist"
            elseif i==2 then
                pResource="public/acGqkh_yellow.plist"
            else
                pResource="public/acGqkh_green.plist"
            end
            local pos
            if i==1 then
                pos=ccp(300,600)
            elseif i==2 then
                pos=ccp(200,350)
            else
                pos=ccp(400,400)
            end
            if numP==1 then
                pos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
            end
            local particleSystem=CCParticleSystemQuad:create(pResource)
            particleSystem:setPosition(pos)
            particleSystem:setTag(i+201)
            -- particleSystem:setScale(0.5)
            self.bgLayer:addChild(particleSystem,5)
        end
        for i=1,numP do
            local function callAc()
                addPlist(i)
            end
            local callFunc=CCCallFunc:create(callAc)
            local delay=CCDelayTime:create(0.4)
            arrAc:addObject(callFunc)
            arrAc:addObject(delay)
        end
        local function fadeEnd()
            self:stopAllAction()
            local acNode=self.kuanSp[nowPos]:getChildByTag(101)
            if acNode then
                acNode:removeFromParentAndCleanup(true)
            end
            for i=202,204 do
                local particleNode=self.bgLayer:getChildByTag(i)
                if particleNode then
                    particleNode:removeFromParentAndCleanup(true)
                end
            end
        end
        local delay=CCDelayTime:create(0.4)
        arrAc:addObject(delay)
        local fadeEndFunc=CCCallFunc:create(fadeEnd)
        arrAc:addObject(fadeEndFunc)
        local seq=CCSequence:create(arrAc)
        self.bgLayer:runAction(seq)
    end
   
end

function acGqkhTab1:showRoundReward(nextMove)
    local roundNum = acGqkhVoApi:getR()
    local cfg=acGqkhVoApi:getVersionCfg()
    if cfg and cfg.roundReward and cfg.roundReward[roundNum] then
        local function showReward()
            local reward=cfg.roundReward[roundNum].reward
            local rewardItem=FormatItem(reward,nil,true)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
            acMingjiangpeiyangSmallDialog:showRewardItemDialog("TankInforPanel.png",CCSizeMake(550,450),CCRect(130, 50, 1, 1),getlocal("activity_gqkh_logDes3",{roundNum}),rewardItem,false,self.layerNum+1,nextMove)
            for i=1,24 do
                for j=1,2 do
                    local particleNode=self.kuanSp[i]:getChildByTag(j)
                    if particleNode then
                        particleNode:removeFromParentAndCleanup(true)
                    end
                end
            end

            if self.lingquLbTb[roundNum] then
                self.lingquLbTb[roundNum][1]:setVisible(true)
                self.lingquLbTb[roundNum][2]:setVisible(true)
            end
            local paramTab={}
            paramTab.functionStr=self.activeName
            paramTab.addStr="i_also_want"
            local str=self:getRewardStr(rewardItem)
            local _acTitleKey="activity_gqkh_title"
            if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
                _acTitleKey="activity_gqkh_title_1"
            end
            local message={key="activity_gqkh_notice2",param={playerVoApi:getPlayerName(),getlocal(_acTitleKey),roundNum,str}}
            chatVoApi:sendSystemMessage(message,paramTab)
        end
        local delay=CCDelayTime:create(0.7)
        local callFunc=CCCallFunc:create(showReward)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

        for i=1,24 do
            for j=1,2 do
                local particleSystem=CCParticleSystemQuad:create("public/textShine" ..  j .. ".plist")
                particleSystem:setPosition(ccp(self.kuanSp[i]:getContentSize().width/2,self.kuanSp[i]:getContentSize().height/2))
                particleSystem:setTag(j)
                self.kuanSp[i]:addChild(particleSystem,2)
            end
        end
    else
        if nextMove then
            nextMove()
        end
    end
end

function acGqkhTab1:changeReward()
    local roundNum = acGqkhVoApi:getR()
    local rewardNum=acGqkhVoApi:gerRewardNum(roundNum)
    if rewardNum~=self.oldRewardNum then
        self.oldRewardNum=rewardNum
        local rewardTb=acGqkhVoApi:getRoundReward()
        for i=1,24 do
            self.kuanSp[i]:removeAllChildrenWithCleanup(true)
            local bigIcon,scale=G_getItemIcon(rewardTb[i],100,true,self.layerNum)
            bigIcon:setTouchPriority(-(self.layerNum-1)*20-3)
            bigIcon:setScale(56/bigIcon:getContentSize().width)
            self.kuanSp[i]:addChild(bigIcon)
            bigIcon:setPosition(self.kuanSp[i]:getContentSize().width/2,self.kuanSp[i]:getContentSize().height/2)
            bigIcon:setVisible(false)

            local smallIcon,scale=G_getItemIcon(rewardTb[i],100)
            smallIcon:setScale(40/smallIcon:getContentSize().width)
            self.kuanSp[i]:addChild(smallIcon)
            smallIcon:setPosition(self.kuanSp[i]:getContentSize().width/2,self.kuanSp[i]:getContentSize().height/2)
            if i==1 then
                local qiziSp=CCSprite:createWithSpriteFrameName("platWarFlag1.png")
                self.kuanSp[i]:addChild(qiziSp)
                qiziSp:setPosition(self.kuanSp[i]:getContentSize().width/2+10,self.kuanSp[i]:getContentSize().height)
                self.qiziSp=qiziSp
                qiziSp:setScale(0.5)
                qiziSp:setAnchorPoint(ccp(0.5,0))
            end
            
        end
    end
    
end



function acGqkhTab1:setDiceSp(num)
    if num==0 then
        self.dice1Sp:removeFromParentAndCleanup(true)
        self.dice1Sp=nil
    else
        self:createDiceSp(num)
    end
end

function acGqkhTab1:createDiceSp(num)
    if self.dice1Sp~=nil then
        self.dice1Sp:removeFromParentAndCleanup(true)
        self.dice1Sp=nil
    end
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 80
    elseif G_getIphoneType() == G_iphone4 then
        adaH = 50
    end
    self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice" .. num .. ".png")
    self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
    self.dice1Sp:setPosition(ccp(self.bgLayer:getContentSize().width/2+adaH/4,self.bgLayer:getContentSize().height/2-40-adaH))
    self.bgLayer:addChild(self.dice1Sp)
    
end

function acGqkhTab1:tick()
    if acGqkhVoApi:isToday()==false and self.isToday==true then
        self.isToday=false
        acGqkhVoApi:setF(0)
        acGqkhVoApi:setC(0)
        self:refresh()
    end
    self:updateAcTime()
end

function acGqkhTab1:updateAcTime()
    local acVo=acGqkhVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acGqkhTab1:refresh()
    self.isDouble=false
    if self.doubleSp then
        self.doubleSp:setVisible(false)
    end
    self:refreshCostNum()
    self:refreshCostLb()
    self:setThrowNumLb()
    if self.menuBg then
        G_removeFlicker(self.menuBg)
    end
    
end

function acGqkhTab1:getMoveTank()
    local orderId=GetTankOrderByTankId(tonumber(10001))
    local tankStr="t"..orderId.."_1.png"
    local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
    for i=1,2 do
        local tankStr="t"..orderId.."_" .. i .. ".png"
        local tankBarrel="t"..orderId.."_" .. i .. "_1.png"
        tankSp=CCSprite:createWithSpriteFrameName(tankStr)
        local scale=0.7
        tankSp:setScale(scale)
        self.bgLayer:addChild(tankSp,3)
        local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
        if tankBarrelSP then
            tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
            tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
            tankSp:addChild(tankBarrelSP)
            self.tankBarrel[i]=tankBarrelSP
        end
        local arrawSp=CCSprite:createWithSpriteFrameName("dwArrow.png")
        tankSp:addChild(arrawSp)
        arrawSp:setScale(1/scale)
        arrawSp:setRotation(180)
        arrawSp:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*scale+20))
        arrawSp:setTag(1)
        arrawSp:setVisible(false)
        self.tank[i]=tankSp
    end
end

function acGqkhTab1:setMoveTank(flag,pos)
    if flag==1 then
        self.tank[2]:setPosition(pos)
        self.tank[2]:setFlipX(false)
        self.tank[2]:setVisible(true)
        self.tank[1]:setVisible(false)
        if self.tankBarrel[2] then
            self.tankBarrel[2]:setFlipX(false)
        end
    elseif flag==2 then
        self.tank[2]:setPosition(pos)
        self.tank[2]:setFlipX(true)
        self.tank[2]:setVisible(true)
        self.tank[1]:setVisible(false)
        if self.tankBarrel[2] then
            self.tankBarrel[2]:setFlipX(true)
        end
    elseif flag==3 then
        self.tank[1]:setPosition(pos)
        self.tank[1]:setFlipX(false)
        self.tank[1]:setVisible(true)
        self.tank[2]:setVisible(false)
        if self.tankBarrel[1] then
            self.tankBarrel[1]:setFlipX(false)
        end
    else
        self.tank[1]:setPosition(pos)
        self.tank[1]:setFlipX(true)
        self.tank[1]:setVisible(true)
        self.tank[2]:setVisible(false)
        if self.tankBarrel[1] then
            self.tankBarrel[1]:setFlipX(true)
        end
    end
end

function acGqkhTab1:getCurrentTank()
    if self.tank[1]:isVisible() then
        return self.tank[1]
    else
        return self.tank[2]
    end
end


function acGqkhTab1:fastTick()
    if self.state==3 then
        self:stopAllAction()
    end
            
end
function acGqkhTab1:stopAllAction()
    self.state=0
    self.touchDialogBg:setIsSallow(false)
    self.bgLayer:stopAllActions()
    self.tank[2]:stopAllActions()
    self.tank[1]:stopAllActions()
    local curPos=acGqkhVoApi:getS()
    local acNode=self.kuanSp[curPos]:getChildByTag(101)
    if acNode then
        acNode:stopAllActions()
        acNode:removeFromParentAndCleanup(true)
    end
    if self.dice1Sp then
        self.dice1Sp:removeFromParentAndCleanup(true)
        self.dice1Sp=nil
    end
    self:showGeziReward()
    local cfg=acGqkhVoApi:getVersionCfg()
    local x,y=self.kuanSp[curPos]:getPosition()
    self:setMoveTank(cfg.map[curPos].direction,ccp(x,y+4))
    self:tankStopAction()
    self:setProgressPer()
    if self.qiziSp then
        self.qiziSp:setVisible(true)
        self.qiziSp=nil
    end
    if self.iconPropSp1 then
        self.iconPropSp1:setVisible(true)
        self.iconPropSp2:setTouchPriority(-(self.layerNum-1)*20-3)
        self.iconPropSp1=nil
        self.iconPropSp2=nil
    end
    
end

function acGqkhTab1:tankStopAction()
    local tankSp=self:getCurrentTank()
    local arrawSp=tankSp:getChildByTag(1)
    arrawSp:setVisible(true)
    local moveAc1=CCMoveTo:create(0.3,CCPointMake(tankSp:getContentSize().width/2,tankSp:getContentSize().height+50))
    local moveAc2=CCMoveTo:create(0.3,CCPointMake(tankSp:getContentSize().width/2,tankSp:getContentSize().height+20))
    local arrAc=CCArray:create()
    arrAc:addObject(moveAc1)
    arrAc:addObject(moveAc2)
    local seq=CCSequence:create(arrAc)
    arrawSp:runAction(CCRepeatForever:create(seq))
end

function acGqkhTab1:tankRemoveAction()
    local tankSp=self:getCurrentTank()
    local arrawSp=tankSp:getChildByTag(1)
    arrawSp:setVisible(false)
    arrawSp:stopAllActions()
    arrawSp:setPosition(tankSp:getContentSize().width/2,tankSp:getContentSize().height+60)
end

function acGqkhTab1:getRewardStr(rewardItem)
    local str=""
    for k,v in pairs(rewardItem) do
        if k==SizeOfTable(rewardItem) then
            str = str .. v.name .. " x" .. v.num
        else
            str = str .. v.name .. " x" .. v.num .. ","
        end
    end
    return str
end


function acGqkhTab1:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.isDouble=false
    self.kuanSp={}
    self.tank={}
    self.tankBarrel={}
end

