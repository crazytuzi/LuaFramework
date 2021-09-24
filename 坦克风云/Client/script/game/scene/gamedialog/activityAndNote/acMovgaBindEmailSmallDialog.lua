--movga绑定邮箱给奖励的面板
acMovgaBindEmailSmallDialog=smallDialog:new()

function acMovgaBindEmailSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.des = nil
    nc.desH = nil
    nc.flag = nil  -- 状态判断
    nc.rewardRow = nil
    nc.reward = nil
    nc.url=G_downloadUrl("active/acFirstRechargeBg.jpg")
    return nc
end

function acMovgaBindEmailSmallDialog:init(layerNum)
    self.layerNum=layerNum
    local zorder=2
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    spriteController:addTexture("public/allianceWar2/allianceWar2.png")
    spriteController:addPlist("public/acChunjiepansheng3.plist")
    spriteController:addTexture("public/acChunjiepansheng3.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self.dialogLayer=CCLayer:create()
    local function touchHander()
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20,20,10,10),touchHander)
    dialogBg:setContentSize(CCSizeMake(515,700))
    self.bgLayer=dialogBg
    local bgSize=dialogBg:getContentSize()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,3)
    self.bgSize=bgSize

    local upBgSp=CCSprite:createWithSpriteFrameName("expedition_up.png")
    upBgSp:setAnchorPoint(ccp(0.5,1))
    upBgSp:setScaleX(self.bgLayer:getContentSize().width/upBgSp:getContentSize().width)
    upBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,bgSize.height+5))
    self.bgLayer:addChild(upBgSp,zorder)
    local downBgSp=CCSprite:createWithSpriteFrameName("expedition_down.png")
    downBgSp:setAnchorPoint(ccp(0.5,0))
    downBgSp:setScaleX(self.bgLayer:getContentSize().width/downBgSp:getContentSize().width)
    downBgSp:setPosition(ccp(bgSize.width/2,0))
    self.bgLayer:addChild(downBgSp,zorder)
    local function onLoadIcon(fn,icon)
        if self and self.dialogLayer and tolua.cast(self.dialogLayer,"CCLayer") then
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
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    -- local rechargeBg=CCSprite:create("public/acFirstRechargeBg.jpg")
    -- rechargeBg:setPosition(getCenterPoint(dialogBg))
    -- self.bgLayer:addChild(rechargeBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local ribbonSp1=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
    ribbonSp1:setPosition(bgSize.width/2,bgSize.height)
    self.bgLayer:addChild(ribbonSp1,zorder)
    local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
    lightSp:setPosition(bgSize.width/2,bgSize.height+60)
    self.bgLayer:addChild(lightSp,zorder)
    local titleBg=CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg:setScaleX(1.2)
    titleBg:setPosition(ccp(bgSize.width/2,bgSize.height+10))
    self.bgLayer:addChild(titleBg,zorder)

    local strSize2 = 21
    if G_getCurChoseLanguage() =="de" then
        strSize2 = 18
    elseif G_getCurChoseLanguage() =="fr" then
        strSize2 = 17
    elseif G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 = 30
    end
    local titleLb=GetTTFLabelWrap(getlocal("activity_movgaBind_title"),strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setColor(G_ColorYellowPro2)
    titleLb:setPosition(bgSize.width/2,bgSize.height+15)
    self.bgLayer:addChild(titleLb,zorder+3)

    local tipLb=GetTTFLabelWrap(getlocal("activity_movgaBind_tip"),24,CCSizeMake(bgSize.width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5,1))
    tipLb:setPosition(bgSize.width/2,bgSize.height-60)
    self.bgLayer:addChild(tipLb,zorder + 1)

    self.rewardCfg={u={{gems=100,index=1}},p={{p16=1,index=2},{p5=1,index=3}},o={{a10004=10,index=4}}}
    local tipHeight=tipLb:getContentSize().height
    local tipCenterY=tipLb:getPositionY() - tipHeight/2

    local titleBgWidth=bgSize.width-80
    local titleDownBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
    local scalex,scaley=titleBgWidth/titleDownBg:getContentSize().width,(tipHeight + 20)/titleDownBg:getContentSize().height
    titleDownBg:setPosition(ccp(bgSize.width/2,tipCenterY))
    titleDownBg:setScaleX(scalex)
    titleDownBg:setScaleY(scaley)
    self.bgLayer:addChild(titleDownBg,zorder)
    local lineSpDown1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSpDown1:setScaleX(titleBgWidth/lineSpDown1:getContentSize().width)
    -- lineSpDown1:setScaleY(10/lineSpDown1:getContentSize().height)
    lineSpDown1:setPosition(ccp(bgSize.width/2,titleDownBg:getPositionY()+(tipHeight + 20)/2))
    self.bgLayer:addChild(lineSpDown1,zorder)
    local lineSpDown2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSpDown2:setScaleX(titleBgWidth/lineSpDown2:getContentSize().width)
    -- lineSpDown2:setScaleY(10/lineSpDown2:getContentSize().height)
    lineSpDown2:setPosition(ccp(bgSize.width/2,titleDownBg:getPositionY()-(tipHeight + 20)/2))
    self.bgLayer:addChild(lineSpDown2,zorder)
    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem=GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil)
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn=CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(bgSize.width-closeBtnItem:getContentSize().width+5,bgSize.height-closeBtnItem:getContentSize().height+40))
    self.bgLayer:addChild(self.closeBtn,zorder+1)


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

    local rewardLayer=self:initReward()
    rewardLayer:setPosition(ccp(self.bgSize.width/2,160))
    self.bgLayer:addChild(rewardLayer,zorder)
    self.desH,self.des = self:getDes(getlocal("activity_movgaBind_tip2"))
    self.des:setPosition(ccp(self.bgSize.width/2,130))
    self.bgLayer:addChild(self.des,zorder) 
    self:initBtn()
    self:show()
    local function eventListener(event,data)
        self:eventHandler(event,data)
    end
    self.eventListener=eventListener
    eventDispatcher:addEventListener("movga.bind.success",eventListener)
end

function acMovgaBindEmailSmallDialog:initBtn()
    local tmpTb={}
    tmpTb["action"]="customAction"
    tmpTb["parms"]={}
    tmpTb["parms"]["value"]="isUserBindEmail"
    local cjson=G_Json.encode(tmpTb)
    self.isBind=tonumber(G_accessCPlusFunction(cjson))
    local btnStr
    if(dailyActivityVoApi.movgaBindFlag==1)then
        btnStr=getlocal("activity_hadReward")
    elseif(self.isBind==1)then
        btnStr=getlocal("daily_scene_get")
    else
        btnStr=getlocal("activity_movgaBind_goto")
    end
    local function onClick()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:goto()
    end
    self.btnItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onClick,nil,btnStr,25,101)
    local btnMenu=CCMenu:createWithItem(self.btnItem)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnMenu:setPosition(ccp(self.bgSize.width/2,60))
    self.bgLayer:addChild(btnMenu,3)
    if(dailyActivityVoApi.movgaBindFlag==1)then
        self.btnItem:setEnabled(false)
    end
end

function acMovgaBindEmailSmallDialog:goto()
    if(self.isBind==0)then
        local tmpTb={}
        tmpTb["action"]="customAction"
        tmpTb["parms"]={}
        tmpTb["parms"]["value"]="bindEmail"
        local cjson=G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    else
        local function onRequestEnd(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local award=FormatItem(self.rewardCfg) or {}
                for k,v in pairs(award) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                G_showRewardTip(award)
                dailyActivityVoApi:removeMovgaBind()
                self:close()
            end
        end
        socketHelper:movgaBindGet(onRequestEnd)
    end
end

function acMovgaBindEmailSmallDialog:addLightBlinker(parent)
    if parent==nil then
        return
    end
    local posCfg={ccp(50,26),ccp(26,23),ccp(52,10)}
    local lightSp=CCSprite:createWithSpriteFrameName("gold_whitelight.png")
    lightSp:setPosition(posCfg[1])
    lightSp:setScale(1.5)
    lightSp:setOpacity(0)
    parent:addChild(lightSp)
    local arr=CCArray:create()
    local fadeIn=CCFadeIn:create(0.4)
    local fadeOut=CCFadeOut:create(0.4)
    local function resetPos()
       local idx=math.random(1,3)
       local pos=posCfg[idx]
       lightSp:setPosition(pos)
    end
    local callFunc=CCCallFunc:create(resetPos)
    local delay=CCDelayTime:create(2)
    arr:addObject(fadeIn)
    arr:addObject(fadeOut)
    arr:addObject(callFunc)
    arr:addObject(delay)
    local seq=CCSequence:create(arr)
    local repeatForever=CCRepeatForever:create(seq)
    lightSp:runAction(repeatForever)
end

function acMovgaBindEmailSmallDialog:initReward()
    local iconSize=80
    local function cellClick( ... )
    end
    local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20, 20, 10, 10),cellClick)
    rewardBg:setAnchorPoint(ccp(0.5,0))
    local layerWidth=self.bgSize.width-20
    local rewardLayer=CCNode:create()
    rewardLayer:setAnchorPoint(ccp(0.5,1))
    rewardLayer:setContentSize(CCSizeMake(layerWidth,1))
    rewardBg:addChild(rewardLayer)

    local giftData=FormatItem(self.rewardCfg,true,true)
    local rewardCount=SizeOfTable(giftData)
    self.rewardRow=math.ceil(rewardCount/4)
    local w
    if self.rewardRow > 1 then
      w = (layerWidth - 20) / 4
    else
      w = (layerWidth - 20) / (SizeOfTable(giftData))
    end

    local cost=0
    local index = 0
    local rowIndex = 0
    local iconX = nil
    local iconY=0
    local rewardBgH=35
    for k,v in pairs(giftData) do
        if v and v.name then
            local icon,scale = G_getItemIcon(v,iconSize,true,self.layerNum+1)
            iconX = 10 + w * index+ w/2
            icon:setAnchorPoint(ccp(0.5, 1))
            icon:setPosition(ccp(iconX, iconY))
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            rewardLayer:addChild(icon,1)

            local flickerScale=1.3
            if v.type=="o" then
                flickerScale=2
            end
            if index==0 then
                G_addRectFlicker2(icon,flickerScale,flickerScale,2,"p")
            else
                G_addRectFlicker2(icon,flickerScale,flickerScale,1,"b")
            end

            local numLb=GetTTFLabel("x"..FormatNumber(v.num),23)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(ccp(icon:getContentSize().width-5,0))
            icon:addChild(numLb,4)        
            index = index + 1
        end
    end
    rewardBgH=rewardBgH+self.rewardRow*(iconSize+10)+(self.rewardRow-1)*20+10
    rewardBg:setContentSize(CCSizeMake(layerWidth,rewardBgH))
    rewardLayer:setPosition(layerWidth/2,rewardBgH-35)


    local subTitleSp=CCSprite:createWithSpriteFrameName("hotSaleStrip.png")
    subTitleSp:setFlipX(true)
    subTitleSp:setAnchorPoint(ccp(0,0.5))
    subTitleSp:setPosition(ccp(0,rewardBg:getContentSize().height-5))
    rewardBg:addChild(subTitleSp,2)

    local rewardTitleLb=GetTTFLabel(getlocal("activity_SendGeneral_value",{999}),25)
    rewardTitleLb:setAnchorPoint(ccp(0,0.5))
    rewardTitleLb:setPosition(10,subTitleSp:getContentSize().height/2)
    subTitleSp:addChild(rewardTitleLb,2)

    local goldIcon=CCSprite:createWithSpriteFrameName("iconGold1.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(rewardTitleLb:getPositionX()+rewardTitleLb:getContentSize().width+10,rewardTitleLb:getPositionY())
    subTitleSp:addChild(goldIcon,2)
    self:addLightBlinker(goldIcon)
    
    return rewardBg
end


function acMovgaBindEmailSmallDialog:update()
  -- body
end

function acMovgaBindEmailSmallDialog:getDes(content)
  local showMsg=content or ""
  local width=self.bgSize.width-20
  local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+40
  messageLabel:setDimensions(CCSizeMake(width, height+60))
  return height, messageLabel
end

function acMovgaBindEmailSmallDialog:eventHandler(event,data)
    self.isBind=1
    if(self.btnItem)then
        local lb=tolua.cast(self.btnItem:getChildByTag(101),"CCLabelTTF")
        if(lb)then
            lb:setString(getlocal("daily_scene_get"))
        end
    end
end

function acMovgaBindEmailSmallDialog:dispose()
    self.isBind=nil
    self.reward = nil
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
    spriteController:removePlist("public/acChunjiepansheng3.plist")
    spriteController:removeTexture("public/acChunjiepansheng3.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
    eventDispatcher:removeEventListener("movga.bind.success",self.eventListener)
end