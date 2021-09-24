dimensionalWarDialog=commonDialog:new()

function dimensionalWarDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.layerNum=layerNum
    nc.signBtn=nil
    nc.battleBtn=nil
    nc.statusLb=nil
    nc.signupCDLb=nil
    nc.cdTime1Lb=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
    spriteController:addPlist("public/serverWarLocal/serverWarLocal2.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

--设置对话框里的tableView
function dimensionalWarDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSize.height-105))

    self:initUI()
    self:initBtn()
    self:tick()

    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end

function dimensionalWarDialog:initUI()
    local posy=self.bgLayer:getContentSize().height-110
    -- local mapSp=CCSprite:create("public/serverWarLocal/serverWarLocalMapBg.jpg")
    -- local scalex=(G_VisibleSizeWidth-60)/mapSp:getContentSize().width
    -- local scaley=(320)/mapSp:getContentSize().height
    -- mapSp:setScaleX(scalex)
    -- mapSp:setScaleY(scaley)
    -- mapSp:setPosition(ccp(G_VisibleSizeWidth/2,posy-mapSp:getContentSize().height/2*scaley))
    -- self.bgLayer:addChild(mapSp)
    local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end

    spriteController:addTexture("public/dimensionalWar/dimenWarMap.jpg")
    local texture=spriteController:getTexture("public/dimensionalWar/dimenWarMap.jpg")
    local mapSp=CCSprite:createWithTexture(texture)
    local scalex=(G_VisibleSizeWidth-80)/mapSp:getContentSize().width
    local scaley=scalex--(320)/mapSp:getContentSize().height
    mapSp:setScaleX(scalex)
    mapSp:setScaleY(scaley)
    -- mapSp:setScaleY(0.92)
    -- mapSp:setScale(0.92)
    mapSp:setPosition(ccp(G_VisibleSizeWidth/2,posy-mapSp:getContentSize().height/2*scaley))
    self.bgLayer:addChild(mapSp)

    local kuangBg=LuaCCScale9Sprite:createWithSpriteFrameName("heroHead1.png",CCRect(50, 50, 10, 10),function ()end)
    kuangBg:setAnchorPoint(ccp(0.5,0.5))
    kuangBg:setContentSize(CCSizeMake(mapSp:getContentSize().width+20,mapSp:getContentSize().height+20))
    mapSp:addChild(kuangBg)
    kuangBg:setPosition(getCenterPoint(mapSp))
    

    -- mapSp:setScaleX(G_VisibleSizeWidth/mapSp:getContentSize().width)
    -- mapSp:setScaleY((G_VisibleSizeHeight - 55 - 100)/mapSp:getContentSize().height)
    -- mapSp:setAnchorPoint(ccp(0,0))
    -- mapSp:setPosition(ccp(0,55))
    -- self.bgLayer:addChild(mapSp)


    local status,statusStr,cdTime=dimensionalWarVoApi:getStatus()
    self.statusLb=GetTTFLabelWrap(statusStr,30,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.statusLb:setColor(G_ColorYellowPro)
    self.statusLb:setPosition(ccp(G_VisibleSizeWidth/2,posy-20))
    self.bgLayer:addChild(self.statusLb,3)
    local function touch(hd,fn,idx)
    end
    local tempLb=GetTTFLabel(statusStr,30)
    local wwidth=tempLb:getContentSize().width+50
    if wwidth>580 then
        wwidth=580
    end
    local statusBg =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),touch)
    statusBg:setContentSize(CCSizeMake(wwidth,38))
    statusBg:ignoreAnchorPointForPosition(false)
    statusBg:setAnchorPoint(ccp(0.5,0.5))
    statusBg:setIsSallow(false)
    statusBg:setTouchPriority(-(self.layerNum-1)*20-1)
    statusBg:setPosition(ccp(G_VisibleSizeWidth/2,posy-20))
    self.bgLayer:addChild(statusBg,1)

    local spacey=20
    local pox=90
    local function openEvent(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        dimensionalWarVoApi:showEventDialog(self.layerNum+1)
    end
    local eventItem=GetButtonItem("letterIconNoRead.png","letterIconRead.png","letterIconRead.png",openEvent,nil,nil,nil)
    eventItem:setAnchorPoint(ccp(0.5,0.5))
    -- eventItem:setScale(0.8)
    local eventMenu=CCMenu:createWithItem(eventItem)
    eventMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    eventMenu:setPosition(ccp(pox,posy-mapSp:getContentSize().height*scaley+70+spacey))
    self.bgLayer:addChild(eventMenu,5)
    local lbSp1=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- lbSp1:setAnchorPoint(ccp(0,0.5))
    lbSp1:setPosition(ccp(pox+5,posy-mapSp:getContentSize().height*scaley+20+spacey))
    lbSp1:setScaleX(120/lbSp1:getContentSize().width)
    lbSp1:setScaleY(35/lbSp1:getContentSize().height)
    self.bgLayer:addChild(lbSp1,5)
    local line1=CCSprite:createWithSpriteFrameName("LineCross.png")
    line1:setScaleX(120/line1:getContentSize().width)
    line1:setPosition(ccp(pox,posy-mapSp:getContentSize().height*scaley+5+spacey))
    self.bgLayer:addChild(line1,5)
    local line2=CCSprite:createWithSpriteFrameName("LineCross.png")
    line2:setScaleX(120/line2:getContentSize().width)
    line2:setPosition(ccp(pox,posy-mapSp:getContentSize().height*scaley+35+spacey))
    self.bgLayer:addChild(line2,5)
    local eventLb=GetTTFLabel(getlocal("alliance_event_event"),25)
    eventLb:setPosition(ccp(pox,posy-mapSp:getContentSize().height*scaley+20+spacey))
    eventLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(eventLb,6)

    local function openInfor(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        dimensionalWarVoApi:showInforDialog(self.layerNum+1)
    end
    local inforItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",openInfor,nil,nil,nil)
    inforItem:setAnchorPoint(ccp(0.5,0.5))
    -- inforItem:setScale(0.8)
    local inforMenu=CCMenu:createWithItem(inforItem)
    inforMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    inforMenu:setPosition(ccp(G_VisibleSizeWidth-pox,posy-mapSp:getContentSize().height*scaley+70+spacey))
    self.bgLayer:addChild(inforMenu,5)
    local lbSp2=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- lbSp2:setAnchorPoint(ccp(0,0.5))
    lbSp2:setPosition(ccp(G_VisibleSizeWidth-pox+5,posy-mapSp:getContentSize().height*scaley+20+spacey))
    lbSp2:setScaleX(120/lbSp2:getContentSize().width)
    lbSp2:setScaleY(35/lbSp2:getContentSize().height)
    self.bgLayer:addChild(lbSp2,5)
    local line3=CCSprite:createWithSpriteFrameName("LineCross.png")
    line3:setScaleX(120/line3:getContentSize().width)
    line3:setPosition(ccp(G_VisibleSizeWidth-pox,posy-mapSp:getContentSize().height*scaley+5+spacey))
    self.bgLayer:addChild(line3,5)
    local line4=CCSprite:createWithSpriteFrameName("LineCross.png")
    line4:setScaleX(120/line4:getContentSize().width)
    line4:setPosition(ccp(G_VisibleSizeWidth-pox,posy-mapSp:getContentSize().height*scaley+35+spacey))
    self.bgLayer:addChild(line4,5)
    local inforLb=GetTTFLabelWrap(getlocal("serverWarLocal_information"),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    inforLb:setPosition(ccp(G_VisibleSizeWidth-pox,posy-mapSp:getContentSize().height*scaley+20+spacey))
    inforLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(inforLb,6)

    local hhei=posy-mapSp:getContentSize().height*scaley-120
    -- posy=posy-mapSp:getContentSize().height*scaley-30
    posy=posy+5-20
    posy=posy-mapSp:getContentSize().height*scaley-hhei/10*1
    self.signupCDLb=GetTTFLabelWrap(getlocal("dimensionalWar_signup_cd"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.signupCDLb:setAnchorPoint(ccp(0,0.5))
    self.signupCDLb:setPosition(70,posy)
    self.bgLayer:addChild(self.signupCDLb)
    local cdTime1=cdTime
    self.cdTime1Lb=GetTTFLabel(G_getTimeStr(cdTime1),25)
    self.cdTime1Lb:setAnchorPoint(ccp(1,0.5))
    self.cdTime1Lb:setColor(G_ColorGreen)
    self.cdTime1Lb:setPosition(ccp(560,posy))
    self.bgLayer:addChild(self.cdTime1Lb,2)

    -- posy=posy-30
    posy=posy-hhei/10*1
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScale((G_VisibleSizeWidth-30)/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(lineSp)

    -- posy=posy-30
    posy=posy-hhei/10*1
    local battleTimeLb=GetTTFLabelWrap(getlocal("serverwar_battleTime"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    battleTimeLb:setAnchorPoint(ccp(0,0.5))
    battleTimeLb:setPosition(70,posy)
    self.bgLayer:addChild(battleTimeLb)
    self.battleTimeLb=battleTimeLb
    local cdTime2=dimensionalWarVoApi:getBattleTime()
    local cdTime2Lb=GetTTFLabel(G_getDataTimeStr(cdTime2),25)
    cdTime2Lb:setAnchorPoint(ccp(1,0.5))
    cdTime2Lb:setColor(G_ColorGreen)
    cdTime2Lb:setPosition(ccp(560,posy))
    self.bgLayer:addChild(cdTime2Lb,2)
    self.cdTime2Lb=cdTime2Lb

    -- posy=posy-30
    posy=posy-hhei/10*1
    local capInSet = CCRect(42, 26, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local serverTxtSp=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",capInSet,cellClick)
    -- serverTxtSp:setContentSize(CCSizeMake(510,G_VisibleSizeHeight-720))
    serverTxtSp:setContentSize(CCSizeMake(510,hhei/10*5.5))
    serverTxtSp:setPosition(ccp(G_VisibleSizeWidth/2,posy-(hhei/10*5.5)/2))
    self.bgLayer:addChild(serverTxtSp,2)

    local descStr=getlocal("dimensionalWar_desc")
    -- local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(serverTxtSp:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- descLb:setAnchorPoint(ccp(0,0.5))
    -- descLb:setPosition(25,serverTxtSp:getContentSize().height/2)
    -- serverTxtSp:addChild(descLb)
    tabelLb = G_LabelTableView(CCSizeMake(serverTxtSp:getContentSize().width-50,serverTxtSp:getContentSize().height-20),descStr,25,kCCTextAlignmentLeft)
    tabelLb:setPosition(ccp(25,10))
    tabelLb:setAnchorPoint(ccp(0,0))
    tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    tabelLb:setMaxDisToBottomOrTop(150)
    serverTxtSp:addChild(tabelLb,5)
end
function dimensionalWarDialog:initBtn()
    local function openShop(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function callback()
            dimensionalWarVoApi:showShopDialog(self.layerNum+1)
        end
        dimensionalWarVoApi:getShopInfo(callback)
        -- dimensionalWarFightVoApi:showMap(self.layerNum+1)
    end
    local shopItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",openShop,nil,getlocal("acMayDay_tab2_title"),25,11)
    shopItem:setAnchorPoint(ccp(0,1))
    -- shopItem:setScale(0.8)
    local shopMenu=CCMenu:createWithItem(shopItem)
    shopMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    shopMenu:setPosition(ccp(100,110))
    self.bgLayer:addChild(shopMenu,5)

    local function signupHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        dimensionalWarVoApi:showSignDialog(self.layerNum+1)
    end
    self.signBtn=GetButtonItem("blueSmallBtn.png","blueSmallBtn_Down.png","blueSmallBtn_Down.png",signupHandler,nil,getlocal("allianceWar_sign"),25,12)
    self.signBtn:setAnchorPoint(ccp(1,1))
    -- self.signBtn:setScale(0.8)
    local signMenu=CCMenu:createWithItem(self.signBtn)
    signMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    signMenu:setPosition(ccp(G_VisibleSizeWidth-100,110))
    self.bgLayer:addChild(signMenu,5)
    -- self.signBtn:setVisible(false)
    -- self.signBtn:setEnabled(false)

    local function battleHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if dimensionalWarVoApi:isHadApply()==true then
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_not_sign_up"),30)
            do return end
        end
        -- if dimensionalWarFightVoApi and dimensionalWarFightVoApi:getResult()~=nil then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_game_over"),30)
        -- else
            dimensionalWarFightVoApi:showMap(self.layerNum+1)
        -- end
    end
    self.battleBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",battleHandler,nil,getlocal("allianceWar_enter"),25,13)
    self.battleBtn:setAnchorPoint(ccp(1,1))
    -- self.battleBtn:setScale(0.8)
    local battleMenu=CCMenu:createWithItem(self.battleBtn)
    battleMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    battleMenu:setPosition(ccp(G_VisibleSizeWidth-100,110))
    self.bgLayer:addChild(battleMenu,5)
    -- self.battleBtn:setVisible(false)
    -- self.battleBtn:setEnabled(false)

    self:tick()
end

--用户处理特殊需求,没有可以不写此方法
function dimensionalWarDialog:doUserHandler()

end

function dimensionalWarDialog:tick()
    local status,statusStr,cdTime=dimensionalWarVoApi:getStatus()
    -- print("status,statusStr,cdTime",status,statusStr,cdTime)
    if self.statusLb then
        self.statusLb:setString(statusStr)
    end
    if self.cdTime1Lb then
        self.cdTime1Lb:setString(G_getTimeStr(cdTime))
    end
    if self.signBtn and self.battleBtn then
        if status==0 then
            self.signBtn:setVisible(true)
            self.signBtn:setEnabled(true)
            self.battleBtn:setVisible(false)
            self.battleBtn:setEnabled(false)
            local lb=tolua.cast(self.signBtn:getChildByTag(12),"CCLabelTTF")
            if lb and dimensionalWarVoApi:isHadApply()==true then
                lb:setString(getlocal("dimensionalWar_has_signup"))
            else
                lb:setString(getlocal("allianceWar_sign"))
            end
            if self.signupCDLb then
                self.signupCDLb:setString(getlocal("allianceWar2_signup_end"))
            end
        elseif status>=1 and status<20 then
            self.signBtn:setVisible(false)
            self.signBtn:setEnabled(false)
            self.battleBtn:setVisible(true)
            -- if dimensionalWarVoApi:isHadApply()==true then
            if status>1 then
                self.battleBtn:setEnabled(true)
            else
                self.battleBtn:setEnabled(false)
            end
            if self.signupCDLb then
                self.signupCDLb:setString(getlocal("dimensionalWar_signup_cd"))
            end

        else
            if dimensionalWarVoApi:battleEndIsShowBtn()==true then
                self.signBtn:setVisible(false)
                self.signBtn:setEnabled(false)
                self.battleBtn:setVisible(true)
                self.battleBtn:setEnabled(true)
            else
                self.signBtn:setVisible(true)
                self.signBtn:setEnabled(false)
                self.battleBtn:setVisible(false)
                self.battleBtn:setEnabled(false)
            end
            if self.signupCDLb then
                self.signupCDLb:setString(getlocal("dimensionalWar_signup_cd"))
            end
        end
    end

    if G_isGlobalServer()==true then
        if self.signupCDLb then
            if status==20 then
                self.signupCDLb:setString(getlocal("dimensionalWar_signup_left"))
            else
                self.signupCDLb:setString(getlocal("world_war_signtime"))
            end
        end
        if self.battleTimeLb then
            if status==1 then
                self.battleTimeLb:setString(getlocal("dimensionalWar_fight_left"))
            else
                self.battleTimeLb:setString(getlocal("dimensionalWar_fight_time"))
            end
        end
        if self.cdTime1Lb then
            if status==0 or status==20 then
                self.cdTime1Lb:setString(G_getTimeStr(cdTime))
            else
                self.cdTime1Lb:setString(getlocal("dimensionalWar_signup_has_end"))
            end
        end
        if self.cdTime2Lb then
            local cdTime2Str=""
            if status==0 then
                cdTime2Str=getlocal("dimensionalWar_fight_signup")
            elseif status==1 then
                cdTime2Str=G_getTimeStr(cdTime)
            elseif status==10 or status==11 then
                cdTime2Str=getlocal("serverwarteam_battleing")
            else
                cdTime2Str=getlocal("world_war_matchStatus2")
            end
            self.cdTime2Lb:setString(cdTime2Str)
        end
    end
end

function dimensionalWarDialog:dispose()
    self.signBtn=nil
    self.battleBtn=nil
    self.statusLb=nil
    self.signupCDLb=nil
    self.cdTime1Lb=nil
    self.battleTimeLb=nil
    self.cdTime2Lb=nil
    heroVoApi:clearTroops()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    spriteController:removePlist("public/serverWarLocal/serverWarLocal2.plist")
    spriteController:removeTexture("public/serverWarLocal/serverWarLocal2.png")
    spriteController:removeTexture("public/dimensionalWar/dimenWarMap.jpg")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/localWar/localWar2.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end