acHxghLottery={}

function acHxghLottery:new()
	local nc={
        touchEnable=true,
        touchArr={},
        isMoved=false,
        selectSpTb={},
        selectIdxTb={},
        placeSpTb={},
        lastIdx=nil,
        pointSpTb={},
        tempPointTb={},
        arrowSpTb={},
        isFinish=false,
        lastLength=0,

        bgLayer=nil,
        isEnd=false,
        freeBtn=nil,
        lotteryBtn=nil,
        multiLotteryBtn=nil,
        isTodayFlag=true,
        actionLayer=nil,
        selectFlag=false,
        guideTime=0,
        lotteryFlag=false,
        pointScale=1.1,
        xianluTb=nil,
        playIdx=0,
        adaH = 0,
    }
    if G_getIphoneType() == G_iphoneX then
        nc.adaH = 1250 - 1136
    end
	setmetatable(nc, self)
	self.__index=self

	return nc
end

function acHxghLottery:init(layerNum,parent)
    self.guideTime=base.serverTime-12
    spriteController:addPlist("public/acHxgh_images.plist")
    spriteController:addTexture("public/acHxgh_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()

    return self.bgLayer
end

function acHxghLottery:initTableView()
    local count=math.floor((G_VisibleSizeHeight-160)/80)
    count = G_getIphoneType() == G_iphoneX and (count+1) or count
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_getIphoneType() == G_iphoneX and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+45))
        elseif G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local desTvAddH,offsetY,timeOffsetY,iconOffsetY=0,0,0,0
    if G_getIphoneType() == G_iphoneX then
        desTvAddH=85
        offsetY=-35
        iconOffsetY=-105
        timeOffsetY=-20
    elseif G_isIphone5()==true then
        desTvAddH=25
        offsetY=-35
        iconOffsetY=-45
        timeOffsetY=-20
    elseif base.hexieMode==1 then
        iconOffsetY=0
        timeOffsetY=0
    end
    local zorder=5
    local item
    local shop=acHxghVoApi:getShop()
    local point=0
    for id,v in pairs(shop) do
        if v.flick and v.needPt>point then
            item=FormatItem(v.reward)[1]
            point=v.needPt
        end
    end
    local function showNewPropInfo()
        G_showNewPropInfo(self.layerNum+1,true,true,nil,item,true,getlocal("activity_phlt_getway"),nil,nil,true)
        return false
    end
    local bigRewardSp=G_getItemIcon(item,100,true,self.layerNum+1,showNewPropInfo)
    if bigRewardSp then
        bigRewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
        bigRewardSp:setPosition(85,G_VisibleSizeHeight-220+iconOffsetY)
        self.bgLayer:addChild(bigRewardSp,zorder)
    end
    local timeLb=GetTTFLabel(acHxghVoApi:getTimeStr(),25)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170+timeOffsetY))
    timeLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(timeLb,zorder)
    self.timeLb=timeLb
    self:updateAcTime()

    if G_isIphone5()==true then
        local desTv,desLabel=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-180,70+desTvAddH),getlocal("activity_hxgh_desc"),25,kCCTextAlignmentLeft)
        self.bgLayer:addChild(desTv)
        desTv:setPosition(ccp(140,G_VisibleSizeHeight-320-desTvAddH))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
    end

    local function infoHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local hxReward=acHxghVoApi:getHexieReward()
        local tabStr={}
        for i=1,6 do
            local str
            if base.hexieMode==1 and (i==1 or i==2) then
                str=getlocal("activity_hxgh_hxrule"..i,{hxReward.name})
            else
                str=getlocal("activity_hxgh_rule"..i)
            end
            if str then
                table.insert(tabStr,str)
            end
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",infoHandler)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-200+timeOffsetY))
    self.bgLayer:addChild(menuDesc,zorder)
    local bgAddHeight=0
    if G_isIphone5()==true then
        bgAddHeight=-80
    end
    local textBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    textBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-290+bgAddHeight-self.adaH/2)
    self.bgLayer:addChild(textBg)
    local hangxianLb=GetTTFLabelWrap(getlocal("activity_hxgh_guihua1"),25,CCSize(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    hangxianLb:setPosition(textBg:getPosition())
    hangxianLb:setColor(G_ColorYellow)
    self.bgLayer:addChild(hangxianLb,1)
    self.hangxianLb=hangxianLb

    self:initLayer()
end

function acHxghLottery:initLayer()
    local addH=0
    if G_getIphoneType() == G_iphoneX then
        addH = -100-self.adaH/2
    elseif G_isIphone5()==true then
        addH=-100
    elseif base.hexieMode==1 then
        addH=0
    end
    local zorder=5
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local mapSp=CCSprite:create("public/hangxianMap.jpg")
    mapSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-320-mapSp:getContentSize().height/2+addH)
    self.mapSp=mapSp
    self.bgLayer:addChild(mapSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local orangeLine1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine1:setPosition(mapSp:getContentSize().width/2,mapSp:getContentSize().height)
    orangeLine1:setScaleX((mapSp:getContentSize().width+40)/orangeLine1:getContentSize().width)
    mapSp:addChild(orangeLine1)
    local orangeLine2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine2:setPosition(mapSp:getContentSize().width/2,0)
    orangeLine2:setScaleX((mapSp:getContentSize().width+40)/orangeLine2:getContentSize().width)
    mapSp:addChild(orangeLine2)

    local touchLayer=CCLayer:create()
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    touchLayer:setTouchEnabled(true)
    touchLayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-8,false)
    self.bgLayer:addChild(touchLayer)
    self.touchLayer=touchLayer
    local posCfg={
        {137.5, 365.5},
        {223.5, 388.5},
        {352.5, 350.5},
        {473.5, 390.5},
        {48.5, 265.5 },
        {202.5, 250.5},
        {408.5, 275.5},
        {555.5, 263.5},
        {95.5, 175.5 },
        {307.5, 205.5},
        {508.5, 186.5},
        {113.5, 66.5 },
        {244.5, 34.5 },
        {334.5, 131.5},
        {417.5, 92.5 },
        {517.5, 62.5 },
    }
    for i=1,16 do
        local placeSp=CCSprite:createWithSpriteFrameName("unselectPoint.png")
        local x,y=posCfg[i][1],posCfg[i][2]
        placeSp:setPosition(x,y)
        placeSp:setScale(self.pointScale)
        mapSp:addChild(placeSp,3)
        self.placeSpTb[i]=placeSp
    end

    local function logHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11)
    logBtn:setScale(0.7)
    logBtn:setAnchorPoint(ccp(1,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-25,G_VisibleSizeHeight-340+addH))
    self.bgLayer:addChild(logMenu,zorder)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    logLb:setAnchorPoint(ccp(0.5,1))
    logLb:setScale(1/logBtn:getScale())
    logLb:setPosition(logBtn:getContentSize().width/2,0)
    logLb:setColor(G_ColorYellowPro)
    logBtn:addChild(logLb)

    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示奖池
        local rewardlist=acHxghVoApi:getRewardPool()
        local desStr=getlocal("super_weapon_challenge_reward_preview")
        acHxghVoApi:showRewardPoolDialog(true,true,self.layerNum+1,desStr,"TankInforPanel.png",CCSizeMake(500,620),CCRect(130, 50, 1, 1),rewardlist)
    end
    local poolBtn=GetButtonItem("CommonBox.png","CommonBox.png","CommonBox.png",rewardPoolHandler,11)
    poolBtn:setScale(0.5)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    poolMenu:setPosition(ccp(30,G_VisibleSizeHeight-340+addH+5))
    self.bgLayer:addChild(poolMenu,zorder)

    local strSize2,strWidth2,strPosX,strAn2 = 20,120,-10,0
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2,strWidth2,strPosX,strAn2 = 22,100,poolBtn:getContentSize().width/2,0.5
    end

    local poolLb=GetTTFLabelWrap(getlocal("award"),strSize2,CCSize(strWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    poolLb:setAnchorPoint(ccp(strAn2,1))
    poolLb:setScale(1/poolBtn:getScale())
    poolLb:setPosition(strPosX,0)
    poolLb:setColor(G_ColorYellowPro)
    poolBtn:addChild(poolLb)

    local btnAddH=0
    if G_isIphone5()==true then
        btnAddH=50
    end
    if base.hexieMode==1 then
        local offsetY=-10
        if G_isIphone5()==true then
            offsetY=30
            btnAddH=btnAddH-30
        end
        local hxReward=acHxghVoApi:getHexieReward()
        local promptLb=GetTTFLabelWrap(getlocal("activity_hxgh_hexiePro",{hxReward.name,getlocal("activity_hxgh_plan")}),25,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        promptLb:setAnchorPoint(ccp(0,1))
        promptLb:setPosition(100,160+offsetY)
        promptLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(promptLb)
    end

    local cost1,cost2=acHxghVoApi:getLotteryCost()
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,60+btnAddH),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,60+btnAddH),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acHxghVoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth/2+120,60+btnAddH),multiLotteryHandler,cost2)


    local shoudongLb=GetTTFLabelWrap(getlocal("activity_hxgh_handguihua"),25,CCSize(G_VisibleSizeWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    shoudongLb:setAnchorPoint(ccp(0,0.5))
    shoudongLb:setPosition(100,80+btnAddH)
    self.bgLayer:addChild(shoudongLb)
    self.shoudongLb=shoudongLb
    local shoudongLb2=GetTTFLabel(getlocal("activity_hxgh_handguihua"),25)
    local lbW=shoudongLb2:getContentSize().width
    if lbW>shoudongLb:getContentSize().width then
        lbW=shoudongLb:getContentSize().width
    end
    local strPosX2,strPosY2 = lbW-50,20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strPosX2,strPosY2 = lbW+5,0
    elseif G_getCurChoseLanguage() =="ru" then
        strPosX2,strPosY2 = strPosX2 + 60 ,0
    end
    local costLb=GetTTFLabelWrap(getlocal("activity_equipSearch_free_btn"),25,CCSize(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    costLb:setAnchorPoint(ccp(0,0.5))
    costLb:setColor(G_ColorYellowPro)
    costLb:setTag(101)
    shoudongLb:addChild(costLb)
    local costLb2=GetTTFLabel(getlocal("activity_equipSearch_free_btn"),25)
    local costLbW=costLb2:getContentSize().width
    if costLbW>costLb:getContentSize().width then
        costLbW=costLb:getContentSize().width
    end
    local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setTag(102)
    shoudongLb:addChild(goldIcon)
    if G_getCurChoseLanguage() =="ar" then
        costLb:setPosition(strPosX2-110,shoudongLb:getContentSize().height/2-strPosY2-10)
        goldIcon:setPosition(lbW+costLbW-210,shoudongLb:getContentSize().height/2-strPosY2-10)
    else
        costLb:setPosition(strPosX2,shoudongLb:getContentSize().height/2-strPosY2)
        goldIcon:setPosition(lbW+costLbW+5,shoudongLb:getContentSize().height/2-strPosY2)
    end
    

    self:refreshLotteryBtn()
    self:tick()

    local function onSelect(object,fn,tag)
        local function changeHandler()
            if G_acHxghAutoFlag==false then
                G_acHxghAutoFlag=true
                self.checkBox:setVisible(true)
                self.uncheckBox:setVisible(false)
            else
                G_acHxghAutoFlag=false
                self.checkBox:setVisible(false)
                self.uncheckBox:setVisible(true)
            end
            self:refreshHangxianLb(1)
            self:refreshLotteryBtn()
            self:removeActionLayer()
            self.playIdx=0
            self.xianluTb=nil
        end
        local promptStr=""
        if G_acHxghAutoFlag==true then
            promptStr=getlocal("activity_hxgh_change",{getlocal("activity_hxgh_auto"),getlocal("activity_hxgh_shoudong")})
        else
            promptStr=getlocal("activity_hxgh_change",{getlocal("activity_hxgh_shoudong"),getlocal("activity_hxgh_auto")})
        end
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),promptStr,nil,changeHandler)
    end
    local background=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),onSelect)
    background:setTouchPriority(-(self.layerNum-1)*20-2)
    background:setAnchorPoint(ccp(0,1))
    background:setPosition(100,mapSp:getPositionY()-mapSp:getContentSize().height/2-self.adaH/2)
    background:setOpacity(0)
    self.bgLayer:addChild(background)
    local function nilFunc()
    end
    local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
    checkBox:setVisible(false)
    background:addChild(checkBox)
    self.checkBox=checkBox
    local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
    background:addChild(uncheckBox)
    self.uncheckBox=uncheckBox

    if G_acHxghAutoFlag==true then
        self.checkBox:setVisible(true)
        self.uncheckBox:setVisible(false)
    else
        self.checkBox:setVisible(false)
        self.uncheckBox:setVisible(true)
    end

    local autoLb=GetTTFLabelWrap(getlocal("activity_hxgh_autoguihua"),25,CCSize(G_VisibleSizeWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    autoLb:setAnchorPoint(ccp(0,0.5))
    -- autoLb:setColor(G_ColorYellowPro)
    background:addChild(autoLb)
    local autoLb2=GetTTFLabel(getlocal("activity_hxgh_autoguihua"),25)
    local realW=autoLb2:getContentSize().width
    if realW>autoLb:getContentSize().width then
        realW=autoLb:getContentSize().width
    end
    background:setContentSize(CCSizeMake(checkBox:getContentSize().width+realW+20,60))
    checkBox:setPosition(ccp(checkBox:getContentSize().width/2,background:getContentSize().height/2))
    uncheckBox:setPosition(ccp(uncheckBox:getContentSize().width/2,background:getContentSize().height/2))
    autoLb:setPosition(60,background:getContentSize().height/2)
end

function acHxghLottery:getLotteryBtn(num,pos,callback,cost)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=""
        if base.hexieMode==1 then
            btnStr=getlocal("activity_qxtw_buy",{num})
        else
            btnStr=getlocal("actitity_hxgh_lottery",{num})
        end
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+8)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acHxghLottery:lotteryHandler(multiFlag)
    self:removeActionLayer()
    self.playIdx=0
    self.xianluTb=nil
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        self.lotteryFlag=true
        local function callback(lotteryTb,pt,point,rewardlist,hxReward)
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                local function realShow()
                    local function showEndHandler()
                        G_showRewardTip(rewardlist,true)
                        self:refreshHangxianLb(1,true)
                    end
                    local addStrTb
                    if pt and SizeOfTable(pt)>0 then
                        addStrTb={}
                        for k,v in pairs(pt) do  
                            table.insert(addStrTb,getlocal("activity_nljj_score",{v or 0}))
                        end
                    end
                    if hxReward then
                        table.insert(rewardlist,1,hxReward)
                        table.insert(addStrTb,1,"")
                    end
                    local titleStr=getlocal("activity_wheelFortune4_reward")
                    local blank = " "
                    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="tw" then
                        blank = ""
                    end
                    local titleStr2=getlocal("activity_tccx_total_score")..blank..getlocal("activity_nljj_score",{point})
                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,addStrTb)
                    self.lotteryFlag=false
                end
                if G_acHxghAutoFlag==true then
                    self:showActionLayer(num,realShow)
                else
                    realShow()
                end
            end
            self:refreshLotteryBtn()
        end
        local freeFlag=acHxghVoApi:isFreeLottery()
        acHxghVoApi:acHxghRequest({action=1,num=num,free=freeFlag},callback)
    end
    local cost1,cost2=acHxghVoApi:getLotteryCost()
    local cost,num=0,1
    if acHxghVoApi:isToday()==false then
        acHxghVoApi:resetFreeLottery()
    end
    local freeFlag=acHxghVoApi:isFreeLottery()
    if cost1 and cost2 then
        if multiFlag==false and freeFlag==0 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acHxghVoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        local function sureClick()
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acHxghVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acHxghVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end

function acHxghLottery:showActionLayer(num,callback,guildFlag,skipFlag)
    if self.actionLayer then
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer=nil
    end
    local skipFlag=skipFlag or false
    local showFlag=false
    self.guildFlag=guildFlag
    local function touchHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if showFlag==false and skipFlag==false then
            self:removeActionLayer()
            self:showActionLayer(num,callback,false,true)
        end
        -- if callback and showFlag==false then
        --     self:removeActionLayer()
        --     callback()
        -- end
    end
    local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),touchHandler)
    actionLayer:setAnchorPoint(ccp(0.5,0))
    actionLayer:setOpacity(0)
    actionLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    actionLayer:setPosition(G_VisibleSizeWidth/2,0)
    if guildFlag and guildFlag==true then
        actionLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self:refreshHangxianLb(1)
    else
        actionLayer:setTouchPriority(-(self.layerNum-1)*20-5)
    end
    self.bgLayer:addChild(actionLayer,3)
    self.actionLayer=actionLayer

    local handSp
    if guildFlag and guildFlag==true then
        handSp=CCSprite:createWithSpriteFrameName("hxghShou.png")
        handSp:setAnchorPoint(ccp(0,1))        
        handSp:setVisible(true)
        self.actionLayer:addChild(handSp)
    end
    if guildFlag and guildFlag==true then
        self.xianluTb={{2,6,10,11,14}}
    else
        if self.xianluTb==nil then
            self.xianluTb={}
            for i=1,num do
                local placeTb={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
                local hangxian={}
                for i=1,5 do
                    local idx=math.random(1,#placeTb)
                    table.insert(hangxian,placeTb[idx])
                    table.remove(placeTb,idx)
                end
                table.insert(self.xianluTb,hangxian)
            end
        end
    end
    local hangxianIdx=1
    if self.playIdx>0 then
        hangxianIdx=self.playIdx+1
        if hangxianIdx>num then
            hangxianIdx=num
        end
    end
    local function drawOneHangxian()
        self:clearHangxian()
        local arrowTb,lineTb,placeSpTb={},{},{}
        local hangxian=self.xianluTb[hangxianIdx]
        local lineIdx=1
        local function drawOneLine()
            local placeIdx=hangxian[lineIdx]
            local placeSp=tolua.cast(self.placeSpTb[placeIdx],"CCSprite")
            table.insert(placeSpTb,placeSp)
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("zqpoint.png")
            if frame then
                placeSp:setDisplayFrame(frame)
            end
            if handSp then
                handSp:setVisible(true)
                local handPos=placeSp:convertToWorldSpaceAR(ccp(0,0))
                handSp:setPosition(handPos.x-10,handPos.y)
            end
            local acArr=CCArray:create()
            local scaleTo1=CCScaleTo:create(0.1,1.2*self.pointScale)
            local scaleTo2=CCScaleTo:create(0.1,self.pointScale)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)
            local function drawEndCallBack()
                local function playBlink()
                    local spTb={arrowTb,lineTb,placeSpTb}
                    for k,v in pairs(spTb) do
                        for kk,sp in pairs(v) do
                            sp=tolua.cast(sp,"CCSprite")
                            if sp then
                                local blink=CCBlink:create(1,2)
                                sp:runAction(blink)
                            end
                        end
                    end
                    self.playIdx=hangxianIdx
                end
                local blinkAc=CCCallFunc:create(playBlink)
                local blinkTime=1.2
                if skipFlag and skipFlag==true and tonumber(num)>1 then
                    blinkTime=0.6
                end
                local delay=CCDelayTime:create(blinkTime)
                local function drawNext()
                    if guildFlag==nil or guildFlag==false then
                        self:refreshHangxianLb(4,{hangxianIdx,num})
                    end
                    if hangxianIdx>=num then
                        self:clearHangxian()
                        showFlag=true
                        local acArr=CCArray:create()
                        local delay=CCDelayTime:create(0.3)
                        acArr:addObject(delay)
                        local function showRewards()
                            if callback then
                                callback()
                            end
                            self.xianluTb=nil
                            self.playIdx=0
                            self:removeActionLayer()
                        end
                        local showFunc=CCCallFunc:create(showRewards)
                        acArr:addObject(showFunc)
                        local seq=CCSequence:create(acArr)
                        placeSp:runAction(seq)
                        do return end
                    end
                    hangxianIdx=hangxianIdx+1
                    drawOneHangxian()
                end
                local blinkCallBack=CCCallFunc:create(drawNext)
                local acArr=CCArray:create()
                acArr:addObject(blinkAc)
                acArr:addObject(delay)
                acArr:addObject(blinkCallBack)
                local seq=CCSequence:create(acArr)
                self.actionLayer:runAction(seq)
            end
            if lineIdx==5 then
                local endFunc=CCCallFunc:create(drawEndCallBack)
                acArr:addObject(endFunc)
            end
            local seq=CCSequence:create(acArr)
            placeSp:runAction(seq)

            if lineIdx<5 then
                local afterIdx=hangxian[lineIdx+1]
                local afterPlace=tolua.cast(self.placeSpTb[afterIdx],"CCSprite")
                local sx,sy=placeSp:getPosition()
                local tx,ty=afterPlace:getPosition()
                local startPoint,targetPoint=ccp(sx,sy),ccp(tx,ty)
                local vec=ccpSub(targetPoint,startPoint)
                local ratate=-math.deg(ccpToAngle(vec))

                local lineSp=CCNode:create()
                lineSp:setAnchorPoint(ccp(0.5,0.5))
                lineSp:setPosition(sx,sy)
                lineSp:setRotation(ratate)
                lineSp:setTag(1000+placeIdx)
                self.mapSp:addChild(lineSp)

                local texwidth=16
                local length=math.floor(ccpDistance(startPoint,targetPoint)/texwidth)
                for i=1,length do
                    local pointSp=CCSprite:createWithSpriteFrameName("zqline.png")
                    pointSp:setAnchorPoint(ccp(0,0.5))
                    pointSp:setPosition((i-1)*texwidth,lineSp:getContentSize().height/2)
                    pointSp:setOpacity(0)
                    lineSp:addChild(pointSp)
                    table.insert(lineTb,pointSp)
                    local acArr=CCArray:create()
                    if skipFlag==false then
                        local time=0
                        if guildFlag and guildFlag==true then
                            time=(i-1)*0.1
                        else
                            time=(i-1)*0.05
                        end
                        local fadetime=0.05
                        local delay=CCDelayTime:create(time)
                        local fade=CCFadeTo:create(fadetime,255)
                        acArr:addObject(delay)
                        acArr:addObject(fade)
                    else
                        pointSp:setOpacity(255)
                    end
   
                    local function drawHand()
                        if handSp then
                            local handPos=pointSp:convertToWorldSpaceAR(ccp(0,0))
                            handSp:setPosition(handPos.x-10,handPos.y)
                        end
                    end
                    if guildFlag and guildFlag==true then
                        local func=CCCallFunc:create(drawHand)
                        acArr:addObject(func)
                    end
                    local function drawLineEndCallBack()
                        local arrowSp=CCSprite:createWithSpriteFrameName("zqarrow.png")
                        table.insert(arrowTb,arrowSp)
                        arrowSp:setPosition(length*texwidth/2,lineSp:getContentSize().height/2)
                        lineSp:addChild(arrowSp)
                        lineIdx=lineIdx+1
                        drawOneLine()
                    end
                    if i==length then
                        local endFunc=CCCallFunc:create(drawLineEndCallBack)
                        acArr:addObject(endFunc)
                    else
                        local function nilFunc()
                        end
                        local endFunc=CCCallFunc:create(nilFunc)
                        acArr:addObject(endFunc)
                    end
                    local seq=CCSequence:create(acArr)
                    pointSp:runAction(seq)

                end
                -- if handSp then
                --     local moveAc=CCMoveBy:create(moveTime,ccp(tx-sx,ty-sy))
                --     handSp:runAction(moveAc)
                -- end
            end
        end
        drawOneLine()
    end
    drawOneHangxian()
end

function acHxghLottery:removeActionLayer()
    self.guildFlag=false
    if self.actionLayer then
        self:clearHangxian()
        self.actionLayer:stopAllActions()
        self.mapSp:stopAllActions()
        self.actionLayer:removeAllChildrenWithCleanup(true)
        self.actionLayer:setPosition(99999,0)
    end
end

function acHxghLottery:logHandler()
    local function showLog()
        local rewardLog=acHxghVoApi:getRewardLog() or {}
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,succ,time,point=v.num,v.reward,v.succ,v.time,v.point
                local title
                if base.hexieMode==1 then
                    title={getlocal("activity_phlt_hx_logt",{num,point})}
                else
                    title={getlocal("activity_hxgh_logt",{num,point})}
                end
                local content={{reward}}
                local log={title=title,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    local rewardLog=acHxghVoApi:getRewardLog()
    if rewardLog then
        showLog()
    else
        acHxghVoApi:acHxghRequest({action=3},showLog)
    end
end

function acHxghLottery:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn and self.shoudongLb then
        local isEnd=acHxghVoApi:isEnd()
        if isEnd==false then
            local freeFlag=acHxghVoApi:isFreeLottery()
            if G_acHxghAutoFlag==true then
                self.shoudongLb:setVisible(false)
                self.multiLotteryBtn:setVisible(true)
                if freeFlag==1 then
                    self.lotteryBtn:setVisible(false)
                    self.freeBtn:setVisible(true)
                    self.multiLotteryBtn:setEnabled(false)
                else
                    self.freeBtn:setVisible(false)
                    self.lotteryBtn:setVisible(true)
                    self.multiLotteryBtn:setEnabled(true)
                end
            else
                self.shoudongLb:setVisible(true)
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(false)
                self.multiLotteryBtn:setVisible(false)
                local costLb=tolua.cast(self.shoudongLb:getChildByTag(101),"CCLabelTTF")
                local goldIcon=tolua.cast(self.shoudongLb:getChildByTag(102),"CCSprite")
                local strPosY = 20
                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ru" then
                    strPosY = 0
                end
                if costLb and goldIcon then
                    local lbStr=""
                    if freeFlag==1 then
                        lbStr=getlocal("activity_equipSearch_free_btn")
                        goldIcon:setVisible(false)
                    else
                        local cost=acHxghVoApi:getLotteryCost()
                        lbStr=tostring(cost)
                        goldIcon:setVisible(true)
                    end
                    costLb:setString(lbStr)
                    local costLb2=GetTTFLabel(lbStr,25)
                    local costLbW=costLb2:getContentSize().width
                    if costLbW>costLb:getContentSize().width then
                        costLbW=costLb:getContentSize().width
                    end
                    if G_getCurChoseLanguage() =="ar" then
                        goldIcon:setPosition(costLb:getPositionX()+costLbW+210,self.shoudongLb:getContentSize().height/2-strPosY-10)
                    else
                        goldIcon:setPosition(costLb:getPositionX()+costLbW,self.shoudongLb:getContentSize().height/2-strPosY)
                    end
                end
            end
        end
    end
end

function acHxghLottery:refreshHangxianLb(stype,valueTb)
    if self.hangxianLb then
        local color=G_ColorYellow
        if stype==2 then
            color=G_ColorGreen
        elseif stype==3 then
            color=G_ColorYellowPro
        elseif stype==4 then
            color=G_ColorGreen
        end
        self.hangxianLb:setString(getlocal("activity_hxgh_guihua"..stype,valueTb))
        self.hangxianLb:setColor(color)
    end
end

function acHxghLottery:touchEvent(fn,x,y,touch)
    if G_acHxghAutoFlag==true then
        do return end
    else
        self.guideTime=base.serverTime    
        if self.guildFlag and self.guildFlag==true then
            self:removeActionLayer()
        end
    end
    if fn=="began" or fn=="moved" then
        local mapPosX,mapW,mapPosY,mapH=self.mapSp:getPositionX(),self.mapSp:getContentSize().width,self.mapSp:getPositionY(),self.mapSp:getContentSize().height
        if self.mapSp==nil or x<(mapPosX-mapW/2) or x>(mapPosX+mapW/2) or y<(mapPosY-mapH/2) or y>(mapPosY+mapH/2) then
            do return end
        end
    end
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=1 then
             return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch

        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        self:handleBeginEvent(x,y)
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or self.multTouch==true or self.isFinish==true then
             do
                return
             end
        end
        self.isMoved=true
        self:handleMoveEvent(x,y)
    elseif fn=="ended" then
        if self.touchEnable==false then
             do
                return
             end
        end
        self:handleEndEvent(x,y)
        self.touchArr={}
    end
end

function acHxghLottery:handleMoveEvent(x,y)
    self:checkSelect(x,y)
end

function acHxghLottery:handleBeginEvent(x,y)
    self.isFinish=false
    self.selectFlag=false
    self.guideTime=base.serverTime
    self:clearHangxian()
    self:removeActionLayer()
    self:refreshHangxianLb(1)
    self:checkSelect(x,y)
end

function acHxghLottery:checkSelect(x,y)
    local cidx=self:findCellIndex(x,y)
    if cidx~=-1 then
        self.selectFlag=true
        local selectSp=self.placeSpTb[cidx]
        selectSp=tolua.cast(selectSp,"CCSprite")
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ptpoint.png")
        if frame then
            selectSp:setDisplayFrame(frame)
            self.selectSpTb[cidx]=selectSp
        end
        
        local tpos=selectSp:convertToWorldSpaceAR(ccp(0,0))
        self:drawLine(tpos,true)
        table.insert(self.selectIdxTb,cidx)

        local acArr=CCArray:create()
        local scaleTo1=CCScaleTo:create(0.1,1.2*self.pointScale)
        local scaleTo2=CCScaleTo:create(0.1,self.pointScale)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        local seq=CCSequence:create(acArr)
        selectSp:runAction(seq)

        if self.lastIdx and self.placeSpTb[self.lastIdx] then
            local lastSelectSp=tolua.cast(self.placeSpTb[self.lastIdx],"CCSprite")
            if lastSelectSp then
                if self.pointSpTb[self.lastIdx] then
                    for k,pointSp in pairs(self.pointSpTb[self.lastIdx]) do
                        local pointSp=tolua.cast(pointSp,"CCSprite")
                        if pointSp then
                            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ptline.png")
                            if frame then
                                pointSp:setDisplayFrame(frame)
                            end
                        end
                    end
                end
                local lineSp=tolua.cast(self.mapSp:getChildByTag(1000+self.lastIdx),"CCNode")
                if lineSp then
                    local texwidth=16
                    local sx,sy=lastSelectSp:getPosition()
                    local startPoint,targetPoint=lastSelectSp:convertToWorldSpaceAR(ccp(0,0)),tpos
                    local length=ccpDistance(startPoint,targetPoint)/texwidth
                    local arrowSp=CCSprite:createWithSpriteFrameName("ptarrow.png")
                    arrowSp:setPosition(length*texwidth/2,lineSp:getContentSize().height/2)
                    lineSp:addChild(arrowSp)
                    self.arrowSpTb[self.lastIdx]=arrowSp
                end
            end
        end
        self.lastIdx=cidx
        if SizeOfTable(self.selectIdxTb)>=5 then
            self.isFinish=true
        end
    else
        self:drawLine(ccp(x,y))
    end
end

function acHxghLottery:handleEndEvent(x,y)
    if self.lineSp then
        self.lineSp:removeFromParentAndCleanup(true)
        self.lineSp=nil
    end
    self:checkResult()

    self.isFinish=true
    self.selectSpTb={}
    self.selectIdxTb={}
    self.lastIdx=nil
    self.pointSpTb={}
    self.tempPointTb={}
    self.lastLength=0
    self.selectFlag=false  
end

function acHxghLottery:findCellIndex(x,y)
    local result=-1
    for i=1,16 do
        if self.selectSpTb[i]==nil then
            local placeSp=self.placeSpTb[i]
            if placeSp then
                local pos=placeSp:convertToWorldSpaceAR(ccp(0,0))
                local tx,ty=pos.x-x,pos.y-y
                local distance=math.sqrt(tx*tx+ty*ty)
                if distance<(placeSp:getContentSize().height/2+10) then
                    result=i
                    do break end
                end
            end
        end
    end
    return result
end

function acHxghLottery:clearHangxian(refreshFlag)
    for k,placeSp in pairs(self.placeSpTb) do
        placeSp=tolua.cast(placeSp,"CCSprite")
        placeSp:stopAllActions()
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("unselectPoint.png")
        if frame then
            placeSp:setDisplayFrame(frame)
            placeSp:setOpacity(255)
            placeSp:setVisible(true)
            placeSp:setScale(self.pointScale)
        end
        local lineSp=tolua.cast(self.mapSp:getChildByTag(1000+k),"CCNode")
        if lineSp then
            lineSp:removeFromParentAndCleanup(true)
        end
    end
    if refreshFlag and refreshFlag==true then
        self:refreshHangxianLb(1)
    end
end

function acHxghLottery:drawLine(targetPoint,ljFlag)
    if self.selectSpTb==nil or SizeOfTable(self.selectSpTb)==0 or self.isFinish==true then
        do return end
    end
    if self.lastIdx and targetPoint then
        local lastPlaceSp=self.placeSpTb[self.lastIdx]
        if lastPlaceSp then
            local texwidth=16
            local startPoint=lastPlaceSp:convertToWorldSpaceAR(ccp(0,0))
            local length=ccpDistance(startPoint,targetPoint)/texwidth
            local vec=ccpSub(targetPoint,startPoint)
            local ratate=-math.deg(ccpToAngle(vec))
            if self.lineSp==nil then
                local lineSp=CCNode:create()
                lineSp:setAnchorPoint(ccp(0.5,0.5))
                lineSp:setPosition(lastPlaceSp:getPosition())
                lineSp:setTag(1000+self.lastIdx)
                self.mapSp:addChild(lineSp)
                self.lineSp=lineSp
            end
            local pointNum=length
            if pointNum<self.lastLength then
                pointNum=self.lastLength
            end
            for i=1,pointNum do
                local pointSp=self.tempPointTb[i]
                if i>length then
                    if pointSp then
                        pointSp:removeFromParentAndCleanup(true)
                        pointSp=nil
                        self.tempPointTb[i]=nil
                    end
                else
                    if pointSp==nil then
                        pointSp=CCSprite:createWithSpriteFrameName("ptline.png")
                        pointSp:setAnchorPoint(ccp(0,0.5))
                        pointSp:setPosition((i-1)*texwidth,self.lineSp:getContentSize().height/2)
                        self.lineSp:addChild(pointSp)
                        self.tempPointTb[i]=pointSp
                    end
                end
            end

            self.lastLength=length
            self.lineSp:setRotation(ratate)
            if ljFlag and ljFlag==true then
                self.pointSpTb[self.lastIdx]=self.tempPointTb
                self.lineSp=nil
                self.tempPointTb={}
                self.lastLength=0
            end
        end
    end
end

function acHxghLottery:checkResult()
    local result=false
    local ljCount=SizeOfTable(self.selectIdxTb)
    local placePic,pointPic,arrowPic="cwpoint.png","cwline.png","cwarrow.png"
    if ljCount>=5 then
        placePic,pointPic,arrowPic="zqpoint.png","zqline.png","zqarrow.png"
        result=true
    end
    for k,idx in pairs(self.selectIdxTb) do
        local placeSp=tolua.cast(self.placeSpTb[idx],"CCSprite")
        if placeSp then
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(placePic)
            if frame then
                placeSp:setDisplayFrame(frame)
            end
            local blink=CCBlink:create(1,2)
            local function clearFunc()
                if k==5 then
                    self:clearHangxian()
                    self:lotteryHandler()
                end
            end
            local func=CCCallFunc:create(clearFunc)
            local seq=CCSequence:createWithTwoActions(blink,func)
            placeSp:runAction(seq)
        end
        if self.pointSpTb[idx] then
            for k,pointSp in pairs(self.pointSpTb[idx]) do
                local pointSp=tolua.cast(pointSp,"CCSprite")
                if pointSp then
                    local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(pointPic)
                    if frame then
                        pointSp:setDisplayFrame(frame)
                    end
                end
            end
        end
        if self.arrowSpTb[idx] then
            local arrowSp=tolua.cast(self.arrowSpTb[idx],"CCSprite")
            if arrowSp then
                local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(arrowPic)
                if frame then
                    arrowSp:setDisplayFrame(frame)
                end
            end
        end 
        local lineSp=tolua.cast(self.mapSp:getChildByTag(1000+idx),"CCNode")
        if lineSp then
            local blink=CCBlink:create(1,2)
            lineSp:runAction(blink)
        end
    end
    if self.selectFlag==true then
        if result==true then
            self:refreshHangxianLb(2)
        else
            self:refreshHangxianLb(3)
        end
    end
    return result
end

function acHxghLottery:updateAcTime()
    local acVo=acHxghVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acHxghLottery:updateUI()
    self:refreshLotteryBtn()
end

function acHxghLottery:showGuide()

end

function acHxghLottery:tick()
    local isEnd=acHxghVoApi:isEnd()
    if isEnd==false then
        local todayFlag=acHxghVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acHxghVoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
        if self then
          self:updateAcTime()
        end
    end
    if self.lotteryFlag==true then
        self.guideTime=base.serverTime
    end
    if base.serverTime-self.guideTime>=15 and G_acHxghAutoFlag==false then
        self.guideTime=base.serverTime
        self:showActionLayer(1,nil,true)
    end
end

function acHxghLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.touchEnable=true
    self.touchArr={}
    self.isMoved=false
    self.selectSpTb={}
    self.selectIdxTb={}
    self.placeSpTb={}
    self.lastIdx=nil
    self.pointSpTb={}
    self.tempPointTb={}
    self.arrowSpTb={}
    self.isFinish=false
    self.lastLength=0
    self.isEnd=false
    self.freeBtn=nil
    self.lotteryBtn=nil
    self.multiLotteryBtn=nil
    self.isTodayFlag=true
    self.actionLayer=nil
    self.selectFlag=false
    self.guideTime=0
    self.lotteryFlag=false
    self.pointScale=1.1
    self.xianluTb=nil
    self.playIdx=0


    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/acHxgh_images.plist")
    spriteController:removeTexture("public/acHxgh_images.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
end