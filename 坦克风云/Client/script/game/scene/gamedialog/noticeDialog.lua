noticeDialog=smallDialog:new()

function noticeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function noticeDialog:showNoticeDialog(layerNum)
    self:show()
    noticeMgr:setHasShow()
    
    self.layerNum=layerNum
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    

    self.dialogLayer=CCLayer:create()
    local function touchHander()
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),touchHander)
    dialogBg:setContentSize(CCSizeMake(510,700))
    self.bgLayer=dialogBg
    local bgSize=dialogBg:getContentSize()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,3)

    local upBgSp=CCSprite:createWithSpriteFrameName("expedition_up.png")
    upBgSp:setAnchorPoint(ccp(0.5,1))
    upBgSp:setScaleX(self.bgLayer:getContentSize().width/upBgSp:getContentSize().width)
    upBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,bgSize.height+5))
    self.bgLayer:addChild(upBgSp,10)
    local downBgSp=CCSprite:createWithSpriteFrameName("expedition_down.png")
    downBgSp:setAnchorPoint(ccp(0.5,0))
    downBgSp:setScaleX(self.bgLayer:getContentSize().width/downBgSp:getContentSize().width)
    downBgSp:setPosition(ccp(bgSize.width/2,0))
    self.bgLayer:addChild(downBgSp,5)
    local function onLoadIcon(fn,icon)
        if self and self.dialogLayer then
            if self.bgLayer then
                icon:setAnchorPoint(ccp(0.5,0.5))
                self.bgLayer:addChild(icon)
                icon:setPosition(getCenterPoint(self.bgLayer))
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local url=noticeMgr:getDownloadUrl()
    local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)
    -- local noticeSp=CCSprite:create("public/notice_advertise.jpg")
    -- noticeSp:setPosition(getCenterPoint(dialogBg))
    -- self.bgLayer:addChild(noticeSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local titleNode=CCNode:create()
    titleNode:setContentSize(CCSizeMake(bgSize.width,1))
    titleNode:setAnchorPoint(ccp(0.5,0.5))
    titleNode:setPosition(ccp(bgSize.width/2,bgSize.height+120))
    self.bgLayer:addChild(titleNode,10)
    local ribbonSp1=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
    ribbonSp1:setPosition(bgSize.width/2,-140)
    titleNode:addChild(ribbonSp1)
    local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
    lightSp:setPosition(bgSize.width/2,-70)
    titleNode:addChild(lightSp)
    local titleBg=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,0))
    titleBg:setScaleX(1.2)
    titleBg:setPosition(ccp(bgSize.width/2,-155))
    titleNode:addChild(titleBg)
    -- if(G_getCurChoseLanguage()=="cn")then
        -- local sp1=CCSprite:createWithSpriteFrameName("crackerLight.png")
        -- sp1:setPosition(bgSize.width/2,-115)
        -- titleNode:addChild(sp1)
        local posX = 140
        local subWidth = 25
        local strSize2 = 16
        local strSize3 = 17
        local strSize4 = 32
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
             posX =180  
             subWidth =10
             strSize2 =30
             strSize3 =25
        elseif G_getCurChoseLanguage() =="ru" then
            strSize4 = 24
        end
        local sp2=CCSprite:createWithSpriteFrameName("threenum.png")
        if G_getCurChoseLanguage() =="ar" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
            sp2 = GetBMLabel("2",G_GoldFontSrc,30)
        end
        sp2:setPosition(posX,-115)
        sp2:setScale(1.2)
        titleNode:addChild(sp2)
        local lb=GetTTFLabel(getlocal("activity_threeyear_title"),strSize4)
        lb:setColor(G_ColorYellowPro2)
        lb:setAnchorPoint(ccp(0,0.5))
        lb:setPosition(sp2:getPositionX()+sp2:getContentSize().width-subWidth,-115)
        titleNode:addChild(lb)
    -- else
    --     local lb=GetTTFLabel(getlocal("activity_anniversary_birthday"),30)
    --     lb:setColor(G_ColorYellowPro2)
    --     lb:setPosition(bgSize.width/2,-115)
    --     titleNode:addChild(lb)
    -- end

    local titleBg2=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    titleBg2:setPosition(bgSize.width/2,280)
    self.bgLayer:addChild(titleBg2,10)
    local subStr=""
    if (G_curPlatName()=="androidtencent" or G_curPlatName()=="androidtencentysdk" or G_curPlatName()=="androidtencently") then
        subStr=getlocal("threeyear_tencent_subhead")
    else
        subStr=getlocal("threeyear_subhead")
    end
    local subHeadLb=GetTTFLabelWrap(subStr,strSize2,CCSizeMake(bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    subHeadLb:setAnchorPoint(ccp(0.5,0.5))
    subHeadLb:setColor(G_ColorYellowPro2)
    subHeadLb:setPosition(ccp(bgSize.width/2,280))
    self.bgLayer:addChild(subHeadLb,10)
    local subHeadLb2=GetTTFLabel(subStr,strSize2)
    local realW=subHeadLb2:getContentSize().width
    if realW>subHeadLb:getContentSize().width then
        realW=subHeadLb:getContentSize().width
    end
    local spcSp=CCSprite:createWithSpriteFrameName("buy_light_0.png")
    local spcArr=CCArray:create()
    for kk=0,11 do
        local nameStr="buy_light_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        spcArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(spcArr)
    animation:setDelayPerUnit(0.06)
    local animate=CCAnimate:create(animation)
    spcSp:setScaleX((realW+40)/spcSp:getContentSize().width)
    spcSp:setScaleY(subHeadLb:getContentSize().height/spcSp:getContentSize().height)
    spcSp:setPosition(getCenterPoint(subHeadLb))
    subHeadLb:addChild(spcSp)
    local delayAction=CCDelayTime:create(1)
    local seq=CCSequence:createWithTwoActions(animate,delayAction)
    local repeatForever=CCRepeatForever:create(seq)
    spcSp:runAction(repeatForever)

    local titleLb1=GetTTFLabelWrap(getlocal("threeyear_task1"),strSize3,CCSizeMake(bgSize.width-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setColor(G_ColorYellowPro2)
    titleLb1:setPosition(ccp(bgSize.width/2,220))
    self.bgLayer:addChild(titleLb1,10)
    local titleLb2=GetTTFLabelWrap(getlocal("threeyear_task2"),strSize3,CCSizeMake(bgSize.width-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setColor(G_ColorYellowPro2)
    titleLb2:setPosition(ccp(bgSize.width/2,titleLb1:getPositionY()-titleLb1:getContentSize().height/2-30))
    self.bgLayer:addChild(titleLb2,10)
    local titleLb3=GetTTFLabelWrap(getlocal("threeyear_task3"),strSize3,CCSizeMake(bgSize.width-300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb3:setAnchorPoint(ccp(0.5,0.5))
    titleLb3:setColor(G_ColorYellowPro2)
    titleLb3:setPosition(ccp(bgSize.width/2,titleLb2:getPositionY()-titleLb2:getContentSize().height/2-30))
    self.bgLayer:addChild(titleLb3,10)
    local textH=titleLb1:getContentSize().height+titleLb2:getContentSize().height+titleLb3:getContentSize().height+20

    for i=1,4 do
        local frameSp=CCSprite:createWithSpriteFrameName("notice_frame.png")
        frameSp:setAnchorPoint(ccp(0,1))
        self.bgLayer:addChild(frameSp,10)
        local posX=120
        if i%2==0 then
            posX=bgSize.width-120
        end
        local posY=titleLb1:getPositionY()+frameSp:getContentSize().height/2
        local angle=0
        if i==2 then
            angle=90
        elseif i==3 then
            angle=-90
            posY=220-textH
        elseif i==4 then
            angle=180
            posY=220-textH
        end
        frameSp:setRotation(angle)
        frameSp:setPosition(ccp(posX,posY))
    end
   
    local function goHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        -- noticeMgr:setHasShow()
        jump_judgment("threeyear")
        self:close()
    end
    local goItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",goHandler,nil,getlocal("go_join"),25)
    local goBtn=CCMenu:createWithItem(goItem)
    goBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    goBtn:setPosition(bgSize.width/2,60)
    self.bgLayer:addChild(goBtn,10)
    G_addRectFlicker(goItem,2.3,1,getCenterPoint(goItem))

    local function touchLuaSpr()      
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function noticeDialog:tick()
end

function noticeDialog:dispose()
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png") 
end
