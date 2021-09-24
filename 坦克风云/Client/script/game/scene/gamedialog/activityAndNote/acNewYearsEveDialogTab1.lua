acNewYearsEveDialogTab1={}

function acNewYearsEveDialogTab1:new( ... )
    local nc={
        bestDamageLabel = nil, --最高伤害标签
        attackNumLabel = nil,--剩余攻击次数标签
        attackBtn = nil,--带部队打击的按钮
        crackerBtn = nil, --爆竹打击按钮
        crackerMultiBtn = nil, --爆竹连击按钮
        saluteAttackBtn = nil,--礼炮打击按钮
        saluteAttackNumLabel = nil, --礼炮打击剩余的攻击次数标签
        tankHpProcessSprite = nil, --坦克当前血量的进度标签
        progressHpSprite = nil,--坦克血量进度条前景色
        hpIndexSprite = nil, --当前坦克夕血量的第几管血的标签
        reviveTimeLabel = nil, --复活时间的标签
        stateCfg = nil,
        tankHp = 0,
        oldAttackTime = 0,
        processBg = nil,
        destoryPaotou={},
        bossState = nil,
        reviveTime = nil,
        tankSprite= nil,
        reviveAnim = nil,
        infoHeight = 150,
        bestDamageNode=nil,
        bestDamagePrompt=nil,
        attackNumPrompt=nil,
        crackerStartY = {300,370},
        damageChangedListener = nil,
        forbidLayer = nil,
        rewardDialog = nil,
        animSpriteTab = {},
        attackFlicker = nil,
        requestCount = 0,
        acEndStr = nil,
        moveBgStarStr = nil,
        needRefresh = false,
        crackerEndPos = {G_VisibleSize.width/2 - 120,G_VisibleSize.width/2 + 120,G_VisibleSize.height/2 - 100,G_VisibleSize.height/2},
    }
    setmetatable(nc,self)
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 40
    end
    self.__index=self
    self.parent=nil
    return nc
end

function acNewYearsEveDialogTab1:init(layerNum,parent)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        spriteController:addPlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:addTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
    else
        spriteController:addPlist("public/acChrisEveImage2.plist")
        spriteController:addTexture("public/acChrisEveImage2.png")
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self.stateCfg = acNewYearsEveVoApi.tankState
    self.tankHp = acNewYearsEveVoApi:getTankHp()
    self.bossState,self.reviveTime= acNewYearsEveVoApi:checkTankState()


    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()

    local function damageChanged(event,data)
        if self then
            self:refreshAcView()
            self:showDamgeChangeLabel()
            -- print("======== refresh boss damge value ========")
            -- print("======== current hp ======== ",acNewYearsEveVoApi:getTankHp())
        end
    end
    self.damageChangedListener = damageChanged
    eventDispatcher:addEventListener("newyeareva.damageChanged",damageChanged)

    return self.bgLayer
end

function acNewYearsEveDialogTab1:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    self:initAcInfo()
    self:initTankInfo()
    self:initAttackBtns()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acNewYearsEveDialogTab1:initAcInfo()
    local function nilFunc( ... )
        -- body
    end

    if(G_isIphone5()) then
       self.infoHeight = 200
    end

    local introduceBg
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        self.infoHeight = 170
        introduceBg = CCNode:create()
        introduceBg:setAnchorPoint(ccp(0.5,1))
        introduceBg:setContentSize(CCSizeMake(616, self.infoHeight))
        introduceBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - 160))
    else
        introduceBg = LuaCCScale9Sprite:createWithSpriteFrameName("redFadeLine.png",CCRect(0, 0, 602, 10),nilFunc)
        introduceBg:setAnchorPoint(ccp(0.5,1))
        introduceBg:setContentSize(CCSizeMake(G_VisibleSize.width - 70, self.infoHeight))
        -- introduceBg:setOpacity(180)
        introduceBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - 180))
    end
    self.bgLayer:addChild(introduceBg,1)

    local function touchHandle( )
         if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local allRewardContent = acNewYearsEveVoApi:composeRewardPool()
        acNewYearsEveSmallDialog:showRewardItemsWithDiffTitleDialog("PanelPopup.png",CCSizeMake(550,650),nil,false,false,false,false,self.layerNum + 1,allRewardContent,nil)
    end 
    local rewardShowBg 
    local posx,posy = 85,25
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        rewardShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandle)
        rewardShowBg:setContentSize(CCSizeMake(85,90))
        rewardShowBg:setOpacity(0)
        posx = introduceBg:getContentSize().width - 9
        posy = 0
    else
        rewardShowBg = LuaCCSprite:createWithSpriteFrameName("acChrisBox.png",touchHandle)
        local scaleNum = G_isIphone5() and 0.7 or 0.5
        rewardShowBg:setScale(scaleNum)
    end
    rewardShowBg:setAnchorPoint(ccp(1,0))
    rewardShowBg:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardShowBg:setPosition(posx,posy)
    introduceBg:addChild(rewardShowBg,2)



    local bgWidth = introduceBg:getContentSize().width
    local bgHeight = introduceBg:getContentSize().height

-- "acChunjiepansheng_orangeLine.png"
    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setAnchorPoint(ccp(0.5,1))
    orangeLine:setPosition(ccp(introduceBg:getContentSize().width/2,0-self.adaH))
    introduceBg:addChild(orangeLine,3)

    local goldLineSprite = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite:setAnchorPoint(ccp(0.5,0))
    goldLineSprite:setPosition(ccp(introduceBg:getContentSize().width/2,introduceBg:getContentSize().height - 5))
    introduceBg:addChild(goldLineSprite)

    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        introduceBg:setPositionY(G_VisibleSize.height - 160)
        local function onLoadIcon(fn,sprite)
            if (self and introduceBg and tolua.cast(introduceBg,"CCNode")) then
                sprite:setAnchorPoint(ccp(0.5,1))
                sprite:setPosition(ccp(introduceBg:getContentSize().width/2,introduceBg:getContentSize().height))
                introduceBg:addChild(sprite)
            end
        end
        LuaCCWebImage:createWithURL(G_downloadUrl("active/acSecretshop_bg.jpg"),onLoadIcon)
        goldLineSprite:setPositionY(-goldLineSprite:getContentSize().height)
        introduceBg:reorderChild(goldLineSprite,1)
    else
        local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
        orangeLine:setAnchorPoint(ccp(0.5,1))
        orangeLine:setPosition(ccp(introduceBg:getContentSize().width/2,0))
        introduceBg:addChild(orangeLine,3)

        local lanternSprite1 = CCSprite:createWithSpriteFrameName("pumpkinA22.png")
        lanternSprite1:setAnchorPoint(ccp(0.5,1))
        lanternSprite1:setScale(0.9)
        lanternSprite1:setPosition(ccp(25,goldLineSprite:getContentSize().height + 10))
        goldLineSprite:addChild(lanternSprite1)

        local lanternSprite2 = CCSprite:createWithSpriteFrameName("pumpkinA22.png")
        lanternSprite2:setAnchorPoint(ccp(0.5,1))
        lanternSprite2:setScale(0.9)
        lanternSprite2:setPosition(ccp(goldLineSprite:getContentSize().width - 25,goldLineSprite:getContentSize().height + 10))
        goldLineSprite:addChild(lanternSprite2)
    end

    local strSize2 = 25
    if G_getCurChoseLanguage() =="in" then
        strSize2 =22
    end
    local descStr=getlocal("activity_equipSearch_time_end")
    local acEndStr=GetTTFLabelWrap(descStr,strSize2,CCSizeMake(bgWidth-100,30),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acEndStr:setAnchorPoint(ccp(0.5,0))
    acEndStr:setColor(G_ColorYellow)
    acEndStr:setPosition(ccp(bgWidth/2,bgHeight - acEndStr:getContentSize().height))
    introduceBg:addChild(acEndStr,2)
    self.acEndStr = acEndStr

    local descStr1=acNewYearsEveVoApi:getTimeStr()
    local descStr2=acNewYearsEveVoApi:getRewardTimeStr()
    local fontSize = 23
    local spaceX = -7
    if G_isAsia() then
        fontSize = 25
        spaceX = 0
    end
    local moveBgStarStr,timeLb,rewardLb
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        moveBgStarStr,timeLb,rewardLb = G_LabelRollView(CCSizeMake(bgWidth - 140,35),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        moveBgStarStr:setPosition(100 + spaceX,bgHeight - moveBgStarStr:getContentSize().height - 15)
    else
        moveBgStarStr,timeLb,rewardLb = G_LabelRollView(CCSizeMake(bgWidth - 100,35),descStr1,fontSize,kCCTextAlignmentLeft,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        moveBgStarStr:setPosition(ccp(bgWidth - moveBgStarStr:getContentSize().width - 17 + spaceX,bgHeight - moveBgStarStr:getContentSize().height - 5))
    end
    introduceBg:addChild(moveBgStarStr,2)
    self.moveBgStarStr = moveBgStarStr
    self.timeLb=timeLb
    self.rewardLb=rewardLb
    self:updateAcTime()

    if acNewYearsEveVoApi:acIsStop()==true then
        moveBgStarStr:setVisible(false)
        acEndStr:setVisible(true)
    else
        acEndStr:setVisible(false)
        moveBgStarStr:setVisible(true)
        needRefresh = true
    end

    local desLbStr = getlocal("activity_newyearseve_des")
    local desTvSize = CCSizeMake(bgWidth - 200, bgHeight - 50)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        desLbStr = getlocal("activity_newyearseve_des_1")
        desTvSize = CCSizeMake(bgWidth - 220, bgHeight - 80)
    end
    local desTv, desLabel = G_LabelTableView(desTvSize,desLbStr,20,kCCTextAlignmentLeft)
    introduceBg:addChild(desTv,1)
    desTv:setPosition(ccp((bgWidth - desTv:getContentSize().width)/2,15))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        desTv:setPositionX(desTv:getPositionX()+10)
    end

    local function showAcInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function getRewardStr(rewardTb)
            local rewardStr=""
            if rewardTb then
                local award = FormatItem(rewardTb,false,true)
                rewardStr = G_showRewardTip(award,false,true)
            end
            return rewardStr
        end

        local customRewards = acNewYearsEveVoApi:getCustomRewards()
        local specialRewards = acNewYearsEveVoApi:getSpecialRewards()
        local serverRewards = acNewYearsEveVoApi:getAllServerRewards()
        local customRewardStr = getRewardStr(customRewards)
        local specialRewardStr = getRewardStr(specialRewards)
        local serverRewardStr = getRewardStr(serverRewards)
        -- print("customRewardStr ====== ",customRewardStr)
        -- print("specialRewardStr ====== ",specialRewardStr)
        local tabStr
        if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
            tabStr = {serverRewardStr,"\n",getlocal("activity_newyearseve_rank_desc5"),"\n",getlocal("activity_newyearseve_rule_10_1"),"\n",getlocal("activity_newyearseve_rule_9_1"),"\n",getlocal("activity_newyearseve_rule_8_1",{acNewYearsEveVoApi:getReviveHour()}),"\n",getlocal("activity_newyearseve_rule_7_1"),"\n",getlocal("activity_newyearseve_rule_6_1"),"\n",getlocal("activity_newyearseve_rule_5_1"),"\n",getlocal("activity_newyearseve_rule_4_1"),"\n",getlocal("activity_newyearseve_rule_3_1"),"\n",getlocal("activity_newyearseve_rule_2_1"),"\n",getlocal("activity_newyearseve_rule_1")}
        else
            tabStr = {serverRewardStr,"\n",getlocal("activity_newyearseve_rank_desc5"),"\n",getlocal("activity_newyearseve_rule_10"),"\n",getlocal("activity_newyearseve_rule_9"),"\n",getlocal("activity_newyearseve_rule_8",{acNewYearsEveVoApi:getReviveHour()}),"\n",getlocal("activity_newyearseve_rule_7"),"\n",getlocal("activity_newyearseve_rule_6"),"\n",getlocal("activity_newyearseve_rule_5"),"\n",getlocal("activity_newyearseve_rule_4"),"\n",getlocal("activity_newyearseve_rule_3"),"\n",getlocal("activity_newyearseve_rule_2"),"\n",getlocal("activity_newyearseve_rule_1")}
        end
        local tabColor={nil,nil,G_ColorYellow}
        local sizeTab = {nil,nil,23}
        smallDialog:showTableViewSureWithColorTb("TankInforPanel.png",CCSizeMake(500,750),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_ruleLabel"),tabStr,tabColor,false,self.layerNum+1,nilFunc,sizeTab)

    end
    local infoItem
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showAcInfo,11,nil,nil)
    else
        infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showAcInfo,11,nil,nil)
    end
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        infoBtn:setPosition(introduceBg:getContentSize().width - infoItem:getContentSize().width*infoItem:getScale()/2-10,140)
    else
        local posy = G_isIphone5() and 70 or 55
        infoBtn:setPosition(ccp(introduceBg:getContentSize().width - infoItem:getContentSize().width/2 - 10,posy))
    end
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    introduceBg:addChild(infoBtn,1)
end

function acNewYearsEveDialogTab1:initTankInfo()
    local scaleY = 1
    local scaleX = 0.97
    local tankScale = 0.65
    if(G_isIphone5()) then
       scaleY = 1.25
       tankScale = 0.7
    end

    local tankBg, tankBgPosY
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        scaleY = 1
        scaleX = 1
        if(G_isIphone5()) then
            scaleY = 1.25
        end
        tankBg = CCNode:create()
        tankBg:setContentSize(CCSizeMake(616,490))
        tankBgPosY = G_VisibleSize.height - (160 + self.infoHeight) - self.adaH

        local function onLoadIcon(fn,sprite)
            if (self and tankBg and tolua.cast(tankBg,"CCNode")) then
                sprite:setAnchorPoint(ccp(0.5,1))
                sprite:setPosition(ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height))
                tankBg:addChild(sprite)
            end
        end
        LuaCCWebImage:createWithURL(G_downloadUrl("active/acNewYearEva_bg.jpg"),onLoadIcon)
    else
        tankBg = CCSprite:create("public/acNewYearTankBg.jpg")
        tankBgPosY = G_VisibleSize.height - (180 + self.infoHeight) - self.adaH
    end
    tankBg:setAnchorPoint(ccp(0.5,1))
    tankBg:setScaleX(scaleX)
    tankBg:setScaleY(scaleY)
    tankBg:setPosition(ccp(G_VisibleSize.width/2,tankBgPosY))
    self.bgLayer:addChild(tankBg)
    local bgWidth = tankBg:getContentSize().width*scaleX
    local bgHeight = tankBg:getContentSize().height*scaleY

    local tankInfoLayer = CCNode:create()
    tankInfoLayer:setContentSize(CCSizeMake(bgWidth,bgHeight))
    tankInfoLayer:setAnchorPoint(ccp(0.5,1))
    -- tankInfoLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - (180 + self.infoHeight)))
    tankInfoLayer:setPosition(tankBg:getPosition())
--     tankInfoLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - (180 + self.infoHeight)))
--     tankInfoLayer:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height - (180 + self.infoHeight)-self.adaH))
    self.bgLayer:addChild(tankInfoLayer)

    local function nilFunc( ... )
        -- body
    end
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
    else
        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),nilFunc)
        nameBg:setContentSize(CCSizeMake(150,35))
        nameBg:setAnchorPoint(ccp(0.5,1))
        nameBg:setOpacity(150)
        nameBg:setPosition(ccp(bgWidth/2,bgHeight - 120))
        tankInfoLayer:addChild(nameBg,1)

        local nameLabel = GetTTFLabel(getlocal("activity_newyearseve_bossname"),30)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(ccp(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2))
        nameBg:addChild(nameLabel)
    end

    local tankImageName="t99998_1.png"
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        tankImageName="t99999_1.png"
    end
    -- local tankSprite = CCSprite:createWithSpriteFrameName("t10123_1.png")
    local tankSprite = CCSprite:createWithSpriteFrameName(tankImageName)
    tankSprite:setScale(tankScale)
    tankSprite:setPosition(ccp(bgWidth/2 + 5,bgHeight/2 - 15))
    tankInfoLayer:addChild(tankSprite)
    self.tankSprite = tankSprite

    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        tankSprite:setPositionY(tankSprite:getPositionY()+35)

        local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
        lightSp:setAnchorPoint(ccp(0.5,0.5))
        lightSp:setScaleX(3)
        lightSp:setPosition(bgWidth/2,75)
        tankInfoLayer:addChild(lightSp)
    else
        local leftLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        leftLineSP:setFlipX(true)
        leftLineSP:setPosition(ccp(80,bgHeight - 30))
        tankInfoLayer:addChild(leftLineSP,1)

        local rightLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        rightLineSP:setPosition(ccp(tankInfoLayer:getContentSize().width-80,bgHeight - 30))
        tankInfoLayer:addChild(rightLineSP,1)

        local damageBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
        damageBg:setAnchorPoint(ccp(0.5,0.5))
        damageBg:setScaleX(4)
        damageBg:setScaleY(3)
        damageBg:setPosition(ccp(bgWidth/2 + 20,bgHeight - 30))
        tankInfoLayer:addChild(damageBg)
    end

    local bestDamageNode = CCNode:create()
    bestDamageNode:setAnchorPoint(ccp(0.5,0.5))
    self.bestDamageNode = bestDamageNode

    local bestDamagePrompt = GetTTFLabel(getlocal("activity_newyearseve_bestdamage_name"),22)
    bestDamagePrompt:setAnchorPoint(ccp(0,0.5))
    bestDamagePrompt:setPosition(ccp(0,15))
    bestDamageNode:addChild(bestDamagePrompt,1)
    self.bestDamagePrompt = bestDamagePrompt

    local bestDamageLabel = GetTTFLabel(FormatNumber(acNewYearsEveVoApi:getMyBestDamage()),22)
    bestDamageLabel:setAnchorPoint(ccp(0,0.5))
    bestDamageLabel:setColor(G_ColorYellowPro)
    bestDamageLabel:setPosition(ccp(self.bestDamagePrompt:getContentSize().width,15))
    bestDamageNode:addChild(bestDamageLabel,1)
    self.bestDamageLabel = bestDamageLabel
    
    local bestDamageNodeWidth = bestDamagePrompt:getContentSize().width + bestDamageLabel:getContentSize().width
    bestDamageNode:setContentSize(CCSizeMake(bestDamageNodeWidth,30))
    bestDamageNode:setPosition(ccp(bgWidth/2,bgHeight - 30))
    tankInfoLayer:addChild(bestDamageNode,1)

    local processBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    processBg:setAnchorPoint(ccp(0.5,0))
    processBg:setPosition(ccp(bgWidth/2,bgHeight - 120))
    tankInfoLayer:addChild(processBg)
    self.processBg = processBg

    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        bestDamageNode:setPositionY(83)
        self.processBg:setPositionY(self.processBg:getPositionY()+40)
    end

    local percent,hpIndex = acNewYearsEveVoApi:getHpPercent()
    local barSpriteName = self:getTankHpSpriteName(hpIndex)

    local timerSprite,progressHpSprite = AddProgramTimer(processBg,ccp(processBg:getContentSize().width/2 - 20,processBg:getContentSize().height/2),100,12,nil,"platWarProgressBg.png",barSpriteName,131,1,1)
    -- function AddProgramTimer(node,point,tagPro,tagLabel,labelText,spriteNameBg,spriteNamePro,tagBg,scaleX,scaleY,barOpacity)
    timerSprite:setPercentage(percent)
    self.tankHpProcessSprite = timerSprite
    self.progressHpSprite = progressHpSprite
    local XSprite = CCSprite:createWithSpriteFrameName("xPic.png")
    XSprite:setPosition(ccp(self.tankHpProcessSprite:getContentSize().width + 30,self.tankHpProcessSprite:getContentSize().height/2))
    XSprite:setScale(0.25)
    self.tankHpProcessSprite:addChild(XSprite)
    local numPicName = "numb_"..math.floor(hpIndex)..".png"
    local hpIndexSprite = CCSprite:createWithSpriteFrameName(numPicName)
    hpIndexSprite:setAnchorPoint(ccp(0,0.5))
    hpIndexSprite:setScale(0.25)
    hpIndexSprite:setPosition(ccp(XSprite:getPositionX() + 10,XSprite:getPositionY()))
    self.tankHpProcessSprite:addChild(hpIndexSprite)
    self.hpIndexSprite = hpIndexSprite


    local atkNumBg = CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    atkNumBg:setAnchorPoint(ccp(0.5,0))
    atkNumBg:setPosition(ccp(bgWidth/2,-10))
    tankInfoLayer:addChild(atkNumBg)
    local atkNumNode = CCNode:create()
    atkNumNode:setAnchorPoint(ccp(0.5,0.5))
    atkNumBg:addChild(atkNumNode)

    local anpStr=getlocal("activity_newyearseve_prompt1")
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        anpStr=getlocal("activity_newyearseve_prompt1_new1")
    end
    local strSizeN = 25
    if G_getCurChoseLanguage() == "de" then
        strSizeN = 20
    end
    local attackNumPrompt = GetTTFLabel(anpStr,strSizeN)
    attackNumPrompt:setAnchorPoint(ccp(0,0.5))
    attackNumPrompt:setPosition(ccp(0,15))
    atkNumNode:addChild(attackNumPrompt)
    self.attackNumPrompt = attackNumPrompt

    local attackNumLabel = GetTTFLabel(getlocal("activity_newyearseve_prompt1_1",{acNewYearsEveVoApi:getFreeAttackCount()}),25)
    attackNumLabel:setAnchorPoint(ccp(0,0.5))
    attackNumLabel:setPosition(ccp(attackNumPrompt:getContentSize().width,15))
    attackNumLabel:setColor(G_ColorYellowPro)
    atkNumNode:addChild(attackNumLabel)
    self.attackNumLabel = attackNumLabel

    atkNumNode:setContentSize(CCSizeMake(attackNumPrompt:getContentSize().width + attackNumLabel:getContentSize().width,30))
    atkNumNode:setPosition(ccp(atkNumBg:getContentSize().width/2,atkNumBg:getContentSize().height/2))
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        atkNumBg:setOpacity(0)
        atkNumBg:setPositionY(10)
    end

    local function attackBoss()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:attackBoss()
    end
    local attackBtnItem = GetButtonItem("alien_mines_attack_on.png","alien_mines_attack.png","alien_mines_attack.png",attackBoss,nil,"",25,nil)
    local attackBtn = CCMenu:createWithItem(attackBtnItem)
    attackBtn:setTouchPriority(-(self.layerNum-1)*20-1)
    attackBtn:setPosition(ccp(bgWidth - attackBtnItem:getContentSize().width/2 - 30,120))
    tankInfoLayer:addChild(attackBtn)
    self.attackBtn = attackBtnItem

    local attackLabelBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),nilFunc)
    attackLabelBg:setContentSize(CCSizeMake(100,35))
    attackLabelBg:setAnchorPoint(ccp(0.5,1))
    attackLabelBg:setOpacity(150)
    attackLabelBg:setPosition(ccp(attackBtnItem:getContentSize().width/2,10))
    attackBtnItem:addChild(attackLabelBg,1)

    local attackLabel = GetTTFLabel(getlocal("city_info_attack"),25)
    attackLabel:setAnchorPoint(ccp(0.5,0.5))
    attackLabel:setPosition(ccp(attackLabelBg:getContentSize().width/2,attackLabelBg:getContentSize().height/2))
    attackLabel:setColor(G_ColorYellowPro)
    attackLabelBg:addChild(attackLabel)

    local reviveTimeLabel = GetTTFLabel(getlocal("activity_newyearseve_prompt3",{GetTimeForItemStrState(self.reviveTime)}),25)
    reviveTimeLabel:setPosition(ccp(atkNumBg:getContentSize().width/2,atkNumBg:getContentSize().height/2))
    atkNumBg:addChild(reviveTimeLabel)
    reviveTimeLabel:setVisible(false)
    self.reviveTimeLabel = reviveTimeLabel

    -- if self.bossState == self.stateCfg.REVIVING then
    --     processBg:setVisible(false)
    --     attackNumLabel:setVisible(false)
    --     attackNumPrompt:setVisible(false)
    --     reviveTimeLabel:setVisible(true)
    -- else
    --     reviveTimeLabel:setVisible(false)
    --     processBg:setVisible(true)
    --     attackNumLabel:setVisible(true)
    --     attackNumPrompt:setVisible(true)
    -- end
    self:refreshAcView()

    local function showRewardsInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function showLog(rewardLog)
            if #rewardLog == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            else
                local logNum=SizeOfTable(rewardLog)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},rewardLog,false,self.layerNum+1,nil,true,10,true,true)
            end
        end
        acNewYearsEveVoApi:getLog(showLog) 
    end
    local rewardInfoItem
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        rewardInfoItem = GetButtonItem("bless_record.png","bless_record.png","bless_record.png",showRewardsInfo,11,nil,nil)
    else
        rewardInfoItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",showRewardsInfo,11,nil,nil)
    end
    -- rewardInfoItem:setScale(0.8)
    local rewardInfoBtn = CCMenu:createWithItem(rewardInfoItem)
    rewardInfoBtn:setPosition(ccp(30 + rewardInfoItem:getContentSize().width/2,120))
    rewardInfoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    tankInfoLayer:addChild(rewardInfoBtn)

    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        local loglLabel = GetTTFLabel(getlocal("serverwar_point_record"),25)
        loglLabel:setAnchorPoint(ccp(0.5,1))
        loglLabel:setPosition(ccp(rewardInfoItem:getContentSize().width/2,0))
        rewardInfoItem:addChild(loglLabel)
        local bomGoldLineSprite = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
        bomGoldLineSprite:setFlipY(true)
        bomGoldLineSprite:setAnchorPoint(ccp(0.5,0))
        bomGoldLineSprite:setPosition(tankInfoLayer:getContentSize().width/2,0)
        tankInfoLayer:addChild(bomGoldLineSprite,3)
    else
        local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
        orangeLine:setAnchorPoint(ccp(0.5,1))
        orangeLine:setPosition(ccp(tankInfoLayer:getContentSize().width/2,-2))
        tankInfoLayer:addChild(orangeLine,3)

        local loglLabel = GetTTFLabel(getlocal("serverwar_point_record"),25)
        loglLabel:setAnchorPoint(ccp(0.5,1))
        loglLabel:setPosition(ccp(rewardInfoItem:getContentSize().width/2,0))
        rewardInfoItem:addChild(loglLabel,1)

        local attackLabelBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 10, 20, 10),function() end)
        attackLabelBg:setContentSize(CCSizeMake(100,35))
        attackLabelBg:setAnchorPoint(ccp(0.5,1))
        attackLabelBg:setOpacity(150)
        attackLabelBg:setPosition(ccp(rewardInfoItem:getContentSize().width/2,0))
        rewardInfoItem:addChild(attackLabelBg)
    end
end

function acNewYearsEveDialogTab1:initAttackBtns()
    local strSize2 = 22
    local strSize3 = 19
    local strSize4 = 25
    if G_isAsia() then
        strSize2 =25
        strSize3 =25
    end
    if G_getCurChoseLanguage() =="it" or G_getCurChoseLanguage() =="fr" then
        strSize2 =25
        strSize3 =22
        strSize4 =22
    end
    local _prompt12Key="activity_newyearseve_prompt12"
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        _prompt12Key="activity_newyearseve_prompt12_1"
    end
    local function crackerAttack()
        if G_checkClickEnable()==false then
        do
            return
        end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local hasAttacked = acNewYearsEveVoApi:hasAttacked()

        if hasAttacked == false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal(_prompt12Key),30)            
            return
        end
        self:crackerAttack()
    end
    local function crackerMultiAttack()
        if G_checkClickEnable()==false then
        do
            return
        end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local hasAttacked = acNewYearsEveVoApi:hasAttacked()
        if hasAttacked == false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal(_prompt12Key),30)            
            return
        end   
        self:crackerMultiAttack()
    end
    local function saluteAttack()
        if G_checkClickEnable()==false then
        do
            return
        end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local hasAttacked = acNewYearsEveVoApi:hasAttacked()
        if hasAttacked == false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal(_prompt12Key),30)            
            return
        end
        self:saluteAttack()
    end
    local crackerCost,crackerMultiCost,saluteCost = acNewYearsEveVoApi:getAttackCostNum()
    local saluteRemainAtkNum,saluteTotalAtkNum = acNewYearsEveVoApi:getSaluteAttackNum()
    local remainAttackStr = "(" .. saluteRemainAtkNum .. "/" .. saluteTotalAtkNum .. ")"

    local btnScale = 1
    local btnStr1,btnStr2,btnStr3 = getlocal("activity_newyearseve_btnname1"),getlocal("activity_newyearseve_btnname2"),getlocal("activity_newyearseve_btnname3")
    local btnImage1,btnImage2,btnImage3 = "BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnGraySmall_Down.png"
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        btnScale = 0.8
        btnStr1,btnStr2,btnStr3 = getlocal("activity_newyearseve_btnname1_1"),getlocal("activity_newyearseve_btnname2_1"),getlocal("activity_newyearseve_btnname3_1")
        btnImage1,btnImage2,btnImage3 = "creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    local crackerBtn,btnItem1,crackerCostIcon,crackerAttackNumLabel = self:createAttackButton(self.bgLayer,btnImage1,btnImage2,btnImage3,crackerAttack,100,btnStr1,strSize2/btnScale,nil,nil,nil,true,crackerCost)
    crackerBtn:setAnchorPoint(ccp(0,0.5))
    crackerBtn:setPosition(ccp(120,60+self.adaH/4))
    self.crackerBtn = btnItem1
    local crackerMultiBtn,btnItem2,multiCostIcon,multiAttackNumLabel = self:createAttackButton(self.bgLayer,btnImage1,btnImage2,btnImage3,crackerMultiAttack,100,btnStr2,strSize3/btnScale,nil,nil,nil,true,crackerMultiCost)
    crackerMultiBtn:setPosition(ccp(G_VisibleSize.width/2,60+self.adaH/4))
    self.crackerMultiBtn = btnItem2
    local saluteAttackBtn,btnItem3,saluteCostIcon,saluteAttackNumLabel = self:createAttackButton(self.bgLayer,btnImage1,btnImage2,btnImage3,saluteAttack,100,btnStr3,strSize4/btnScale,nil,nil,nil,true,saluteCost,true,remainAttackStr)
    saluteAttackBtn:setAnchorPoint(ccp(1,0.5))
    saluteAttackBtn:setPosition(ccp(G_VisibleSize.width - 120,60+self.adaH/4))
    self.saluteAttackBtn = btnItem3
    if G_getIphoneType() == G_iphoneX then
        btnItem1:setScale(0.8)
        btnItem2:setScale(0.8)
        btnItem3:setScale(0.8)
    else
        btnItem1:setScale(0.7)
        btnItem2:setScale(0.7)
        btnItem3:setScale(0.7)
    end
    self.saluteAttackNumLabel = saluteAttackNumLabel
    self.crackerBtn:setScale(btnScale)
    self.crackerMultiBtn:setScale(btnScale)
    self.saluteAttackBtn:setScale(btnScale)

    self:refreshAttackBtns(self.bossState)
end

function acNewYearsEveDialogTab1:refreshAttackBtns(state)
    if self.crackerBtn and self.crackerMultiBtn and self.saluteAttackBtn and self.attackBtn then
        if acNewYearsEveVoApi:acIsStop()==true then
            self.crackerBtn:setEnabled(false)
            self.crackerMultiBtn:setEnabled(false)
            self.saluteAttackBtn:setEnabled(false)
            self.attackBtn:setEnabled(false)
            if self.attackFlicker ~= nil then
                G_removeFlicker(self.attackBtn)
                self.attackFlicker = nil
            end
            return
        end

        local hasAttacked = acNewYearsEveVoApi:hasAttacked()
        if state == self.stateCfg.REVIVING then
            if self.crackerBtn:isEnabled() == true then
                self.crackerBtn:setEnabled(false)
            end
            if self.crackerMultiBtn:isEnabled() == true then
                self.crackerMultiBtn:setEnabled(false)
            end
            if self.saluteAttackBtn:isEnabled() == true then
                self.saluteAttackBtn:setEnabled(false)
            end
            if self.attackBtn:isEnabled() == true then
                self.attackBtn:setEnabled(false)
                if self.attackFlicker ~= nil then
                    G_removeFlicker(self.attackBtn)
                    self.attackFlicker = nil
                end
            end
        else
            if self.crackerBtn:isEnabled() == false then
                self.crackerBtn:setEnabled(true)
            end
            if self.crackerMultiBtn:isEnabled() == false then
                self.crackerMultiBtn:setEnabled(true)
            end
            if self.saluteAttackBtn:isEnabled() == false then
                self.saluteAttackBtn:setEnabled(true)
            end

            if self.attackBtn:isEnabled() == false then
                self.attackBtn:setEnabled(true)
            end
            if self.attackFlicker == nil and acNewYearsEveVoApi:getFreeAttackCount() > 0 then
                self.attackFlicker = G_addFlicker(self.attackBtn,2.5,2.5,ccp(self.attackBtn:getContentSize().width/2,self.attackBtn:getContentSize().height/2))
            elseif self.attackFlicker ~= nil and acNewYearsEveVoApi:getFreeAttackCount() <= 0 then
                G_removeFlicker(self.attackBtn)
                self.attackFlicker = nil
            end
        end
    end 
end

function acNewYearsEveDialogTab1:createAttackButton(parent,selectNName,selectSName,selectDName,handler,menuItemTag,menuLabelText,labelsize,lbTag,capInSet,fullRect,hasCost,costNum,hasAttackNum,attackNum)
    if parent == nil then
        return nil
    end
    local attackBtnItem
    attackBtnItem = GetButtonItem(selectNName,selectSName,selectDName,handler,menuItemTag,menuLabelText,labelsize,lbTag)
    local attackBtn = CCMenu:createWithItem(attackBtnItem)
    attackBtn:setTouchPriority(-(self.layerNum - 1)*20-1)
    parent:addChild(attackBtn)

    local goldIconSp = nil
    local goldLb = nil
    local remainAttackNumLabel = nil
    local moneyNode = CCNode:create()
    attackBtnItem:addChild(moneyNode)

    if hasCost and hasCost == true then
        goldIconSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIconSp:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(goldIconSp)

        goldLb = GetTTFLabel(costNum,25)
        goldLb:setAnchorPoint(ccp(0,0.5))
        moneyNode:addChild(goldLb)

        local moneyLabelWidth = goldIconSp:getContentSize().width + goldLb:getContentSize().width
        moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldLb:getContentSize().height))
        goldLb:setPosition(ccp(0,moneyNode:getContentSize().height/2 + 5))
        goldIconSp:setPosition(ccp(goldLb:getContentSize().width,moneyNode:getContentSize().height/2 + 5))

        moneyNode:setAnchorPoint(ccp(0,0.5))
    end

    if hasAttackNum and hasAttackNum == true then
        remainAttackNumLabel = GetTTFLabel(attackNum,25)
        remainAttackNumLabel:setAnchorPoint(ccp(0,0.5))
        remainAttackNumLabel:setColor(G_ColorGreen2)
        
        if moneyNode then
            local labelWidth = moneyNode:getContentSize().width + remainAttackNumLabel:getContentSize().width
            moneyNode:setContentSize(CCSizeMake(labelWidth,moneyNode:getContentSize().height))
            remainAttackNumLabel:setPosition(ccp(goldIconSp:getPositionX() + goldIconSp:getContentSize().width,moneyNode:getContentSize().height/2 + 5))
            moneyNode:addChild(remainAttackNumLabel)
        end  
    end

    moneyNode:setPosition(ccp((attackBtnItem:getContentSize().width - moneyNode:getContentSize().width)/2,attackBtnItem:getContentSize().height+10))

    return attackBtn,attackBtnItem,goldLb,remainAttackNumLabel
end

function acNewYearsEveDialogTab1:refreshAcView()
    if self == nil then
        return
    end
    if self.processBg and self.reviveTimeLabel and self.processBg and self.attackNumLabel and self.attackNumPrompt then
        if acNewYearsEveVoApi:acIsStop()==true then
            self.reviveTimeLabel:setVisible(false)
            self.reviveTimeLabel:getParent():setVisible(false)
            self.moveBgStarStr:setVisible(false)
            self.processBg:setVisible(false)
            self.acEndStr:setVisible(true)
        else
            local state = self.bossState
            if state == self.stateCfg.REVIVING then
                self.reviveTimeLabel:setVisible(true)
                self.processBg:setVisible(false)
                self.attackNumLabel:setVisible(false)
                self.attackNumPrompt:setVisible(false)
            else
                self.reviveTimeLabel:setVisible(false)
                self.processBg:setVisible(true)
                self.attackNumLabel:setVisible(true)
                self.attackNumPrompt:setVisible(true)
            end
        end
    end
    if self.bestDamageLabel then
        self.bestDamageLabel:setString(FormatNumber(acNewYearsEveVoApi:getMyBestDamage()))
        local contentWidth = self.bestDamagePrompt:getContentSize().width + self.bestDamageLabel:getContentSize().width
        self.bestDamageNode:setContentSize(CCSizeMake(contentWidth,30))
    end

    if self.tankHpProcessSprite and self.processBg and self.processBg:isVisible() == true then
        local percent,hpIndex = acNewYearsEveVoApi:getHpPercent()
        -- print("percent ===== " .. percent .. "hpIndex ======= " .. hpIndex)
        local barSpriteName = self:getTankHpSpriteName(hpIndex)
        local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(barSpriteName)
        if frame1 then
            self.progressHpSprite:setDisplayFrame(frame1)
        end
        self.tankHpProcessSprite:setPercentage(percent)
        local numPicName = "numb_"..math.floor(hpIndex)..".png"
        local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(numPicName)
        if frame2 then
            self.hpIndexSprite:setDisplayFrame(frame2)
        end
    end

    if self.saluteAttackNumLabel then
        local saluteRemainAtkNum,saluteTotalAtkNum = acNewYearsEveVoApi:getSaluteAttackNum()
        local remainAttackStr = "(" .. saluteRemainAtkNum .. "/" .. saluteTotalAtkNum .. ")"
        self.saluteAttackNumLabel:setString(remainAttackStr)
    end

    self:refreshAttackNumLabel()
end

function acNewYearsEveDialogTab1:refreshAttackNumLabel()
    if self.attackNumLabel then
        self.attackNumLabel:setString(getlocal("activity_newyearseve_prompt1_1",{acNewYearsEveVoApi:getFreeAttackCount()}))
    end
end

function acNewYearsEveDialogTab1:refreshReviveTimeLabel(remainTime)
    if self.reviveTimeLabel then
        if self.reviveTimeLabel:isVisible() == true then
            local timeStr = GetTimeForItemStrState(remainTime)
            self.reviveTimeLabel:setString(getlocal("activity_newyearseve_prompt3",{timeStr}))
        end
    end
end

-- function acNewYearsEveDialogTab1:playReviveAnim()
--     if self.tankSprite and self.reviveAnim == nil then
--         self.reviveAnim = CCParticleSystemQuad:create("public/acNewYearEvaAni/tankeguang.plist")
--         self.reviveAnim.positionType=kCCPositionTypeFree
--         self.reviveAnim:setScale(2.5)
--         self.reviveAnim:setPosition(ccp(self.tankSprite:getContentSize().width/2,self.tankSprite:getContentSize().height/2))
--         self.tankSprite:addChild(self.reviveAnim,2)
--     end
-- end

-- function acNewYearsEveDialogTab1:clearReviveAnim()
--     if self.reviveAnim ~= nil then
--         self.reviveAnim:removeFromParentAndCleanup(true)
--         self.reviveAnim = nil
--     end
-- end

function acNewYearsEveDialogTab1:getTankHpSpriteName(hpIndex)
    local index = tonumber(math.floor(hpIndex))
    local spriteName = "platWarProgress1.png"
    if index == 1 then
        spriteName = "platWarProgress1.png"
    elseif index == 2 then
        spriteName = "barCyan.png"
    elseif index == 3 then
        spriteName = "barGreen.png"
    elseif index == 4 then
        spriteName = "barOrange.png"
    elseif index == 5 then
        spriteName = "barPurple.png"
    elseif index == 6 then
        spriteName = "platWarProgress2.png"
    end
    return spriteName
end

function acNewYearsEveDialogTab1:tick()
    local state,remaintime = acNewYearsEveVoApi:checkTankState()
    -- print("state ======== ",state)
    if state ~= self.bossState then
        local function infoCallback(fn,data)
        local ret,sData=base:checkServerData(data)
            if ret==true then
                self.bossState = state
                self.requestCount = 0
                if sData and sData.data then
                    acNewYearsEveVoApi:updateData(sData.data)
                    self:refreshAcView()
                end
                self:refreshAttackBtns(state)
            end
        end
        if self.requestCount < 5 then
            socketHelper:getNewYearEvaInfo(infoCallback)
            self.requestCount = self.requestCount + 1      
        end
    end

    if state == self.stateCfg.REVIVING and self.reviveTimeLabel then
        if self.reviveTimeLabel:isVisible() == true then
            self:refreshReviveTimeLabel(remaintime)
        end
    end

    if acNewYearsEveVoApi:acIsStop() == false then
        local lastAttackTime = acNewYearsEveVoApi:getLastAttackTime()
        if lastAttackTime then
            local isToday = G_isToday(tonumber(lastAttackTime))
            if isToday == false and tonumber(self.oldAttackTime) ~= tonumber(lastAttackTime) then
                -- print("隔天重置攻击次数")
                acNewYearsEveVoApi:resetAttackNum()
                self:refreshAttackNumLabel()
                if self.saluteAttackNumLabel then
                    local saluteRemainAtkNum,saluteTotalAtkNum = acNewYearsEveVoApi:getSaluteAttackNum()
                    local remainAttackStr = "(" .. saluteRemainAtkNum .. "/" .. saluteTotalAtkNum .. ")"
                    self.saluteAttackNumLabel:setString(remainAttackStr)
                end
                self.oldAttackTime = tonumber(lastAttackTime)
            end
        end
    else
        if self.needRefresh == true then
            self:refreshAcView()
            self.needRefresh = false
        end
    end
    self:updateAcTime()
end

function acNewYearsEveDialogTab1:updateAcTime()
    -- local acVo=acNewYearsEveVoApi:getAcVo()
    -- if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    --     G_updateActiveTime(acVo,self.timeLb,self.rewardLb)
    -- end
    if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        self.timeLb:setString(acNewYearsEveVoApi:getTimeStr())
    end
    if self.rewardLb and tolua.cast(self.rewardLb,"CCLabelTTF") then
        self.rewardLb:setString(acNewYearsEveVoApi:getRewardTimeStr())
    end
end

function acNewYearsEveDialogTab1:showDamgeChangeLabel()
    if self.tankSprite then
      local tankWidth = self.tankSprite:getContentSize().width
      local tankHeight = self.tankSprite:getContentSize().height

      local bossNowHp = acNewYearsEveVoApi:getTankHp()
      if bossNowHp<self.tankHp then
        local damage = self.tankHp-bossNowHp
        self.tankHp = bossNowHp
        local subLifeLb=GetBMLabel(-damage,G_FontSrc,20)
        subLifeLb:setAnchorPoint(ccp(0.5,0.5))
        -- subLifeLb:setPosition(tankWidth/2,tankHeight/2)
        -- self.tankSprite:addChild(subLifeLb)
        local _pos = self.tankSprite:getParent():convertToWorldSpace(ccp(self.tankSprite:getPositionX(),self.tankSprite:getPositionY()))
        subLifeLb:setPosition(_pos)
        self.bgLayer:addChild(subLifeLb,10)

        local function subMvEnd()
          if subLifeLb then
            subLifeLb:removeFromParentAndCleanup(true)
            subLifeLb=nil
          end
        end
        -- local subMvTo=CCMoveTo:create(0.2,ccp(tankWidth/2,tankHeight/2))
        local subMvTo=CCMoveTo:create(0.2,_pos)
        local delayTime=CCDelayTime:create(0.3)
        -- local subMvTo2=CCMoveTo:create(0.4,ccp(tankWidth/2,tankHeight))
        local subMvTo2=CCMoveTo:create(0.4,ccp(_pos.x,_pos.y+tankHeight/2))
        local  subfunc=CCCallFuncN:create(subMvEnd)
        local fadeOut=CCFadeTo:create(0.4,0)
        local fadeArr=CCArray:create()
        fadeArr:addObject(subMvTo2)
        fadeArr:addObject(fadeOut)
        local spawn=CCSpawn:create(fadeArr)
        local acArr=CCArray:create()
        acArr:addObject(subMvTo)
        local wzScaleTo=CCScaleTo:create(0.2,1.5)
        local wzScaleBack=CCScaleTo:create(0.2,1.1)
        acArr:addObject(wzScaleTo)
        acArr:addObject(wzScaleBack)
        acArr:addObject(delayTime)
        acArr:addObject(spawn)
        acArr:addObject(subfunc)
        local  subseq=CCSequence:create(acArr)
        subLifeLb:runAction(subseq)
      end
    end
end

function acNewYearsEveDialogTab1:attackBoss()
    local attackEnable,attackCost=acNewYearsEveVoApi:judgeAttackEnable()
    if attackEnable == true and tonumber(attackCost) == 0 then
        --免费攻击，进入战斗页面
        self:attackBossRequest(attackCost)
    elseif attackEnable == true and tonumber(attackCost) > 0 then
        --付费攻击
        --提示玩家购买攻击次数一次
        local function onConfirm()
            --判断金币是否充足
            local isEnough = acNewYearsEveVoApi:isGemsEnough(attackCost)
            if isEnough == true then
                --购买攻击次数一次，并进入战斗页面
                self:attackBossRequest(attackCost)
            else
                --提示金币不足
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)

            end
        end
        local _msgStr=getlocal("activity_newyearseve_prompt2",{attackCost})
        if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
            _msgStr=getlocal("activity_newyearseve_prompt2_1",{attackCost})
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),_msgStr,nil,self.layerNum+1)
    elseif attackEnable == false then
        --今日攻击次数已用完
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_prompt4"),30)
    end
end

function acNewYearsEveDialogTab1:crackerAttack()
    local crackerCost,crackerMultiCost,saluteCost = acNewYearsEveVoApi:getAttackCostNum()
    self:firecrackerAttack(1,crackerCost)
end

function acNewYearsEveDialogTab1:crackerMultiAttack()
    local crackerCost,crackerMultiCost,saluteCost = acNewYearsEveVoApi:getAttackCostNum()
    self:firecrackerAttack(2,crackerMultiCost)
end

function acNewYearsEveDialogTab1:saluteAttack()
    local attackedCount,totalCount = acNewYearsEveVoApi:getSaluteAttackNum()
    if tonumber(attackedCount) >= tonumber(totalCount) then
        local isVipTop = acNewYearsEveVoApi:isVipReachTop()
        if isVipTop == true then
            --提示次数已经用完
            local _msgStr=getlocal("activity_newyearseve_prompt6")
            if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
                _msgStr=getlocal("activity_newyearseve_prompt6_1")
            end
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),_msgStr,30)
        else
            --提示升级vip
            local function upgradeVip()
                --跳转至充值页面
                vipVoApi:showRechargeDialog(self.layerNum+1)
            end
            local _msgStr=getlocal("activity_newyearseve_prompt5",{playerVoApi:getVipLevel() + 1})
            if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
                _msgStr=getlocal("activity_newyearseve_prompt5_1",{playerVoApi:getVipLevel() + 1})
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),upgradeVip,getlocal("dialog_title_prompt"),_msgStr,nil,self.layerNum+1)
        end
        return
    end
    local crackerCost,crackerMultiCost,saluteCost = acNewYearsEveVoApi:getAttackCostNum()
    self:firecrackerAttack(3,saluteCost)
end

function acNewYearsEveDialogTab1:attackBossRequest(attackCost)
    local attackEnable = acNewYearsEveVoApi:checkNoTroops()
    if attackEnable == false then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("arena_noTroops"),nil,self.layerNum+1,nil)
        return
    end

    local attackTroops,heros,emblemID,planePos,aitroops,airship = acNewYearsEveVoApi:getTroopsData()
    emblemID=emblemVoApi:getTmpEquip()
    planePos=planeVoApi:getTmpEquip()
    airship = airShipVoApi:getTempLineupId()
    local function attackCallBack(fn,data)
    local ret,sData=base:checkServerData(data)
        self:removeForbidLayer()
        if ret==true then
            if sData.data then
                acNewYearsEveVoApi:updateData(sData.data)
                self:attackCallBack(sData.data)
                --更新玩家本地金币数
                if attackCost > 0 then
                    local curGems = playerVoApi:getGems()
                    curGems = curGems - attackCost
                    playerVoApi:setGems(curGems)
                end
                if sData.data.eva then
                    local bossDamage=sData.data.eva[6]-(sData.data.eva[2]-sData.data.eva[3])
                    if sData.data.sn and sData.data.sn == true then
                        -- print("发送玩家超越排行榜的公告")
                        acNewYearsEveVoApi:sendDamageNote(bossDamage)
                    end
                end
            end
            --初始化战报数据
            if sData.data.report then
                local attackData={data=sData.data,isAttacker=true,isReport=false,destoryPaotou=self.destoryPaotou}
                BossBattleScene:initData(attackData,2)
            end
        end
    end
    --发送带部队攻击年兽的协议
    socketHelper:attackEvaTank(heros,attackTroops,attackCost,attackCallBack,emblemID,planePos,aitroops,airship)
    self:addForbidLayer(nil)
end

function acNewYearsEveDialogTab1:firecrackerAttack(attackType,attackCost)
    -- print("method ===== ".. attackType .. " attackCost ==== " .. attackCost)
    --判断金币是否充足
    local isEnough = acNewYearsEveVoApi:isGemsEnough(attackCost)
    if isEnough == true then
        local function attackCallBack(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data then
                    acNewYearsEveVoApi:updateData(sData.data)
                    self:attackCallBack(sData.data)

                    if sData.data.reward then
                        local bossDamage=sData.data.eva[6]-(sData.data.eva[2]-sData.data.eva[3])
                        local content,rewardList = acNewYearsEveVoApi:getBattleRewards(bossDamage,sData.data.reward,sData.data.kill)
              
                        --本地添加奖励
                        for index,item in pairs(rewardList) do
                            G_addPlayerAward(item.type,item.key,item.id,item.num,false,true)   
                        end

                        local function showRewardsDialog()
                            local function showRewardsTip()
                                --显示获取到的奖励的飘窗
                                G_showRewardTip(rewardList, true)
                                 --清除遮挡层
                                self:removeForbidLayer()
                                self.rewardDialog = nil
                            end
                            if self.rewardDialog == nil then
                               self.rewardDialog = acNewYearsEveSmallDialog:showRewardItemsWithDiffTitleDialog("PanelPopup.png",CCSizeMake(550,650),nil,false,true,true,true,self.layerNum + 1,content,showRewardsTip)
                            end
                        end
                        self:addForbidLayer(showRewardsDialog)
                        if attackType == 1 then
                            self:playOneCrackerAnim(showRewardsDialog)
                        elseif attackType == 2 then
                            self:playMultiCrackerAnim(showRewardsDialog)
                        elseif attackType == 3 then
                            self:playSaluteAnim(showRewardsDialog)    
                        end
                    end
                    --更新玩家本地金币数
                    -- print("扣除金币")
                    local curGems = playerVoApi:getGems()
                    curGems = curGems - attackCost
                    playerVoApi:setGems(curGems)
                end        
            end
        end
        --发送爆竹连击抽奖的协议
        socketHelper:firecrackerAttack(attackType,attackCallBack)
    else
        --提示金币不足
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)

    end
end

function acNewYearsEveDialogTab1:attackCallBack(data)
    if data then
      local params={}
      if data.eva then
        if data.eva[3] then
            params.damage = data.eva[3]
        end
      end
      if params.damage > 0 then
          chatVoApi:sendUpdateMessage(32,params)
      end
      self.destoryPaotou = acNewYearsEveVoApi:getDestoryPaotouByHP((data.eva[2]-data.eva[3]),data.eva[6])
      if self.destoryPaotou and type(self.destoryPaotou)=="table" and SizeOfTable(self.destoryPaotou)>0 then
        local monsterName = ""
        if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
            monsterName=getlocal("activity_newyearseve_bossname_1")
        else
            monsterName=getlocal("activity_newyearseve_bossname")
        end
        local isKill = false
        local paotouCfg = acNewYearsEveVoApi:getTankPaotouCfg()
        for k,v in pairs(self.destoryPaotou) do
          if paotouCfg[v] == 6 then
            isKill = true
          else
            local message={key="BossBattle_destory_chatSystemMessage",param={playerVoApi:getPlayerName(),monsterName}}
            chatVoApi:sendSystemMessage(message)
          end
        end
        if isKill==true then
            local message={key="BossBattle_kill_chatSystemMessage",param={playerVoApi:getPlayerName(),monsterName}}
            chatVoApi:sendSystemMessage(message)
        end
      end

      local state = acNewYearsEveVoApi:checkTankState()
      self:refreshAttackBtns(state)
      self:refreshAcView()
    end
end

function acNewYearsEveDialogTab1:playOneCrackerAnim(animEndCallBack)
    self.animSpriteTab = {}
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        self:playCrackerAnim(-150,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2-30,0,1,1,animEndCallBack)
    else
        self:playCrackerAnim(-35,349,320,G_VisibleSize.height - 572,0,1,1,animEndCallBack)
    end
end

function acNewYearsEveDialogTab1:playMultiCrackerAnim(animEndCallBack)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        self.animSpriteTab = {}
        local posTab = {}
        posTab[1] = {-130,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-30}
        posTab[2] = {-180,G_VisibleSizeHeight-300,G_VisibleSizeWidth/2-50,G_VisibleSizeHeight/2-50}
        posTab[3] = {-150,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2-30}
        posTab[4] = {-100,G_VisibleSizeHeight-300,G_VisibleSizeWidth/2+10,G_VisibleSizeHeight/2-50}
        posTab[5] = {-150,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2-30}
        posTab[6] = {-130,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-30}
        posTab[7] = {-180,G_VisibleSizeHeight-300,G_VisibleSizeWidth/2-50,G_VisibleSizeHeight/2-50}
        posTab[8] = {-150,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2-30}
        posTab[9] = {-100,G_VisibleSizeHeight-300,G_VisibleSizeWidth/2+10,G_VisibleSizeHeight/2-50}
        posTab[10] = {-150,G_VisibleSizeHeight-280,G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2-30}
        for k, v in pairs(posTab) do
            local delaytime = 0
            if k < 4 then
                delaytime = 0.3
            elseif k < 6 then
                    delaytime = 0.5
            elseif k < 8 then
                delaytime = 0.6
            end
            self:playCrackerAnim(v[1],v[2],v[3],v[4],delaytime,2,k,animEndCallBack)
        end
    else
        local num = 0
        local posTab = {}
        repeat
            local startY = math.random(self.crackerStartY[1],self.crackerEndPos[2])
            local endX = math.random(self.crackerEndPos[1],self.crackerEndPos[2])
            local endY = math.random(self.crackerEndPos[3],self.crackerEndPos[4])
            local startX = -35
            local index = math.random(1,2)
            if index == 2 then
                startX = G_VisibleSize.width + 35
            end
            local pos = {}
            table.insert(pos,startX)
            table.insert(pos,startY)
            table.insert(pos,endX)
            table.insert(pos,endY)
            table.insert(posTab,pos)

            num = num + 1
        until(num>=10)

        self.animSpriteTab = {}
        for i=1,10 do
            local delaytime = 0
            if i < 4 then
                delaytime = 0.3
            elseif i < 6 then
                    delaytime = 0.5
            elseif i < 8 then
                delaytime = 0.6
            end
            self:playCrackerAnim(posTab[i][1],posTab[i][2],posTab[i][3],posTab[i][4],delaytime,2,i,animEndCallBack)
        end
    end
end

function acNewYearsEveDialogTab1:playCrackerAnim(startX,startY,endX,endY,delaytime,crackerType,crackerIndex,animEndCallBack)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        local bulletSp = CCSprite:createWithSpriteFrameName("newbullet_effect_7_2.png")
        bulletSp:setPosition(startX,startY)
        bulletSp:setRotation(70)
        self.bgLayer:addChild(bulletSp)
        table.insert(self.animSpriteTab,bulletSp)
        local arr=CCArray:create()
        arr:addObject(CCDelayTime:create(delaytime))
        arr:addObject(CCMoveTo:create(0.5,ccp(endX,endY)))
        arr:addObject(CCCallFunc:create(function()
            bulletSp:removeFromParentAndCleanup(true)
            self:removeAnimSpriteFromTab(bulletSp)
            bulletSp = nil
            local tankFireSp=CCSprite:createWithSpriteFrameName("fire4_1.png")
            tankFireSp:setPosition(endX,endY)
            local fireArr=CCArray:create()
            for kk=1,11 do
                local nameStr="fire4_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                fireArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(fireArr)
            animation:setDelayPerUnit(0.1)
            local animate=CCAnimate:create(animation)
            local ffunc=CCCallFuncN:create(function()
                tankFireSp:removeFromParentAndCleanup(true)
                self:removeAnimSpriteFromTab(tankFireSp)
                tankFireSp = nil
                if animEndCallBack then
                    if crackerType == 1 and crackerIndex == 1 then
                        animEndCallBack()
                    elseif crackerType == 2 and crackerIndex == 10 then
                        animEndCallBack()
                    end
                end
            end)
            local fseq=CCSequence:createWithTwoActions(animate,ffunc)
            tankFireSp:runAction(fseq)
            self.bgLayer:addChild(tankFireSp)
            table.insert(self.animSpriteTab,tankFireSp)
        end))
        bulletSp:runAction(CCSequence:create(arr))
    else
        local crackerSprite = CCSprite:createWithSpriteFrameName("newYearCracker.png")
        table.insert(self.animSpriteTab,crackerSprite)
        if startX > 0 then
            crackerSprite:setRotation(270)
        end
        crackerSprite:setPosition(ccp(startX,startY))
        self.bgLayer:addChild(crackerSprite)
        local acArr=CCArray:create()
        local bezier = ccBezierConfig()
        -- bezier.controlPoint_1 = ccp(117, G_VisibleSize.height - 386)
        -- bezier.controlPoint_2 = ccp(246,G_VisibleSize.height -462)
        local ex=endX+50  
        local ey=endY+150
        bezier.controlPoint_1 = ccp(startX,startY)
        bezier.controlPoint_2 = ccp(startX+(ex-startX)*0.5 - 100, startY+(ey-startY)*0.5 + 200)
        bezier.endPosition = ccp(endX + 30,endY)
        local bezierForward = CCBezierTo:create(1, bezier)
        -- local rotateAc = CCRotateTo:create(1,1080)
        local rotateAc = CCRotateTo:create(1,135)
        local delay = CCDelayTime:create(tonumber(delaytime))
        acArr:addObject(bezierForward)
        acArr:addObject(rotateAc)
        local swpanAc = CCSpawn:create(acArr)
        local function baozha()
            crackerSprite:removeFromParentAndCleanup(true)
            self:removeAnimSpriteFromTab(crackerSprite)
            crackerSprite = nil
            local crackerLight = CCSprite:createWithSpriteFrameName("crackerLight.png")
            table.insert(self.animSpriteTab,crackerSprite)
            crackerLight:setPosition(ccp(endX,endY))
            self.bgLayer:addChild(crackerLight)

            local acArr1=CCArray:create()
            local fadeAc = CCFadeOut:create(0.5)
            local scaleAc = CCScaleTo:create(0.5,2.0)
            acArr1:addObject(fadeAc)
            acArr1:addObject(scaleAc)
            local swpanAc1 = CCSpawn:create(acArr1)
            local function clearLight()
                crackerLight:removeFromParentAndCleanup(true)
                self:removeAnimSpriteFromTab(crackerLight)
                crackerLight = nil
                if animEndCallBack then
                    if crackerType == 1 and crackerIndex == 1 then
                        animEndCallBack()
                    elseif crackerType == 2 and crackerIndex == 10 then
                        animEndCallBack()
                    end
                end
            end
            local callBack = CCCallFuncN:create(clearLight)
            local finalAc =CCSequence:createWithTwoActions(swpanAc1,callBack)
            crackerLight:runAction(finalAc)
        end
        local baozhaCallBack = CCCallFuncN:create(baozha)
        local acArray = CCArray:create()
        acArray:addObject(delay)
        acArray:addObject(swpanAc)
        acArray:addObject(baozhaCallBack)
        local  subseq=CCSequence:create(acArray)
        crackerSprite:runAction(subseq)
    end
end

function acNewYearsEveDialogTab1:playSaluteAnim(callback)
    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        for i=1,3 do
            local boomSp = CCSprite:createWithSpriteFrameName("plane_bigShells_1.png")
            local fireArr=CCArray:create()
            for kk=1,16 do
                local nameStr="plane_bigShells_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                fireArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(fireArr)
            animation:setDelayPerUnit(0.08)
            local animate=CCAnimate:create(animation)
            if i==1 then
                boomSp:setScale(0.8)
                boomSp:setPosition(G_VisibleSizeWidth/2-55, G_VisibleSizeHeight/2-45)
            elseif i==2 then
                boomSp:setScale(0.6)
                boomSp:setPosition(G_VisibleSizeWidth/2+35, G_VisibleSizeHeight/2-20)
            else
                boomSp:setScale(0.4)
                boomSp:setPosition(G_VisibleSizeWidth/2+105, G_VisibleSizeHeight/2+5)
            end
            self.bgLayer:addChild(boomSp)
            table.insert(self.animSpriteTab,boomSp)
            local ffunc=CCCallFuncN:create(function()
                boomSp:removeFromParentAndCleanup(true)
                self:removeAnimSpriteFromTab(boomSp)
                boomSp = nil
                if callback then
                    callback()
                end
            end)
            local arr=CCArray:create()
            arr:addObject(CCDelayTime:create((i-1)*0.3))
            arr:addObject(animate)
            arr:addObject(ffunc)
            boomSp:runAction(CCSequence:create(arr))
        end
    else
        local acArr=CCArray:create()
        local function showyanhua1()
            local yanhua01 = CCParticleSystemQuad:create("public/acNewYearEvaAni/yanhuahuang.plist")
            yanhua01.positionType=kCCPositionTypeFree
            local endX = math.random(self.crackerEndPos[1],self.crackerEndPos[2])
            local endY = math.random(self.crackerEndPos[3],self.crackerEndPos[4])
            yanhua01:setPosition(ccp(endX - yanhua01:getContentSize().width/2,endY - yanhua01:getContentSize().height/2))
            self.bgLayer:addChild(yanhua01,2)
            table.insert(self.animSpriteTab,yanhua01)
        end
        local yanhuaCallFunc1=CCCallFunc:create(showyanhua1)
        acArr:addObject(yanhuaCallFunc1)

        local yanhuaDelay2=CCDelayTime:create(0.5)
        acArr:addObject(yanhuaDelay2)
        local function showyanhua2()
            local yanhua02 = CCParticleSystemQuad:create("public/acNewYearEvaAni/yanhualv.plist")
            yanhua02.positionType=kCCPositionTypeFree
            local endX = math.random(self.crackerEndPos[1],self.crackerEndPos[2])
            local endY = math.random(self.crackerEndPos[3],self.crackerEndPos[4])
            yanhua02:setPosition(ccp(endX - yanhua02:getContentSize().width/2,endY - yanhua02:getContentSize().height/2))       
            self.bgLayer:addChild(yanhua02,2)
            table.insert(self.animSpriteTab,yanhua02)
        end
        local yanhuaCallFunc2=CCCallFunc:create(showyanhua2)
        acArr:addObject(yanhuaCallFunc2)

        local yanhuaDelay3=CCDelayTime:create(0.5)
        acArr:addObject(yanhuaDelay3)
        local function showyanhua3()
            local yanhua03 = CCParticleSystemQuad:create("public/acNewYearEvaAni/yanhuazi.plist")
            yanhua03.positionType=kCCPositionTypeFree
            local endX = math.random(self.crackerEndPos[1],self.crackerEndPos[2])
            local endY = math.random(self.crackerEndPos[3],self.crackerEndPos[4])
            yanhua03:setPosition(ccp(endX - yanhua03:getContentSize().width/2,endY - yanhua03:getContentSize().height/2))       
            self.bgLayer:addChild(yanhua03,2)
            table.insert(self.animSpriteTab,yanhua03)
        end
        local yanhuaCallFunc3=CCCallFunc:create(showyanhua3)
        acArr:addObject(yanhuaCallFunc3)
        if callback then
            local yanhuaCallFunc4=CCCallFunc:create(callback)
            acArr:addObject(yanhuaCallFunc4)
        end
        local sequence=CCSequence:create(acArr)
        self.bgLayer:runAction(sequence)
    end
end

function acNewYearsEveDialogTab1:addForbidLayer(touchCallBack)
    local function touch()
       self:stopAllAnimSpriteActions()
       self.bgLayer:stopAllActions()
       if touchCallBack then
            touchCallBack()
       end
    end
    if self.forbidLayer == nil then
        -- self.forbidLayer = CCLayer:create()
        -- self.forbidLayer:setContentSize(G_VisibleSize)
        -- self.forbidLayer:setTouchEnabled(true)
        -- -- self.forbidLayer:setBSwallowsTouches(true)
        -- -- self.forbidLayer:setTouchPriority(-(self.layerNum - 1)*20-)
        -- self.forbidLayer:registerScriptTouchHandler(touch,false,-(self.layerNum - 1)*20-8,true)
        -- self.bgLayer:addChild(self.forbidLayer,1000)
        self.forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        self.forbidLayer:setTouchPriority(-(self.layerNum-1)*20-8)
        self.forbidLayer:setContentSize(G_VisibleSize)
        self.forbidLayer:setOpacity(0)
        self.forbidLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(self.forbidLayer,10);
    end
end

function acNewYearsEveDialogTab1:removeForbidLayer()
    if self.forbidLayer then
        -- self.forbidLayer:unregisterScriptTouchHandler()
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer = nil
    end
end

function acNewYearsEveDialogTab1:stopAllAnimSpriteActions()
    for k,animSprite in pairs(self.animSpriteTab) do
        if animSprite ~= nil then
            animSprite:removeFromParentAndCleanup(true)
            animSprite = nil
        end
    end
    self.animSpriteTab = {}
end

function acNewYearsEveDialogTab1:removeAnimSpriteFromTab(sprite)
    for k,animSprite in pairs(self.animSpriteTab) do
        if animSprite ~= nil and animSprite == sprite then
            table.remove(self.animSpriteTab,k)
        end
    end
end

function acNewYearsEveDialogTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer = nil

    self.bestDamageLabel = nil --最高伤害标签
    self.attackNumLabel = nil--剩余攻击次数标签
    self.attackBtn = nil--带部队打击的按钮
    self.crackerBtn = nil--爆竹打击按钮
    self.crackerMultiBtn = nil--爆竹连击按钮
    self.saluteAttackBtn = nil--礼炮打击按钮
    self.saluteAttackNumLabel = nil --礼炮打击剩余的攻击次数标签
    self.tankHpProcessSprite = nil --坦克当前血量的进度标签
    self.progressHpSprite = nil--坦克血量进度条前景色
    self.hpIndexSprite = nil --当前坦克夕血量的第几管血的标签
    self.reviveTimeLabel = nil --复活时间的标签
    self.stateCfg = nil
    self.tankHp = 0
    self.oldAttackTime = 0
    self.processBg = nil
    self.destoryPaotou={}
    self.bossState = nil
    self.reviveTime = nil
    self.tankSprite = nil
    self.reviveAnim = nil
    self.attackNumPrompt=nil
    self.bestDamagePrompt=nil
    self.bestDamageNode=nil
    self.crackerStartY = {300,370}
    self.crackerEndPos = {200,440,400,800}
    self.forbidLayer = nil
    self.rewardDialog = nil
    self.requestCount = 0
    self.acEndStr = nil
    self.moveBgStarStr = nil
    self.needRefresh = false
    eventDispatcher:removeEventListener("newyeareva.damageChanged",self.damageChangedListener)
    self.damageChangedListener = nil
    self = nil

    if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        spriteController:removePlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
    end
end