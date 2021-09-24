
acFirstRechargeDialog=smallDialog:new()

function acFirstRechargeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.des = nil
    self.desH = nil
    self.flag = nil  -- 状态判断
    self.rewardMenu = nil
    self.rewardRow = nil
    self.reward = nil
    self.url=G_downloadUrl("active/".."acFirstRechargeBg.jpg")
    return nc
end

function acFirstRechargeDialog:initVo(acVo)
   self.acVo = acVo
end

function acFirstRechargeDialog:init(layerNum)
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
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- spriteController:addPlist("public/acNewYearsEva.plist")
    -- spriteController:addTexture("public/acNewYearsEva.png")
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")

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
        strSize2 = 13
    elseif G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2 = 30
    end
    local titleLb=GetTTFLabelWrap(getlocal("firstRechargeReward"),strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setColor(G_ColorYellowPro2)
    titleLb:setPosition(bgSize.width/2,bgSize.height+15)
    self.bgLayer:addChild(titleLb,zorder+3)

    local tipLb=GetTTFLabelWrap(getlocal("getRewardAnyRechargeNew"),24,CCSizeMake(bgSize.width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5,1))
    tipLb:setPosition(bgSize.width/2,bgSize.height-60)
    self.bgLayer:addChild(tipLb,zorder)

    local giftData=FormatItem(self.acVo.reward,true,true)
    local isReward,isShowDouble=false,false
    local isHadRewardGems=false
    local doubleFlag=true
    if acFirstRechargeVoApi then
        isReward,isShowDouble=acFirstRechargeVoApi:canReward()
        isHadRewardGems=acFirstRechargeVoApi:isHadRewardGems()
    end
    if base.newRechargeSwitch==1 then
        if isReward==false or (isReward==true and isShowDouble==false) then
           doubleFlag=false
        end
    elseif base.newRechargeSwitch==0 then
        if isHadRewardGems==true then
            doubleFlag=false
        end
    end

    -- if doubleFlag==true then
        local titleBgWidth=bgSize.width-80
        local titleBgHeight=60
        local titleDownBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
        local scalex,scaley=titleBgWidth/titleDownBg:getContentSize().width,titleBgHeight/titleDownBg:getContentSize().height
        titleDownBg:setPosition(ccp(bgSize.width/2,tipLb:getPositionY()-tipLb:getContentSize().height-10-titleBgHeight/2))
        titleDownBg:setScaleX(scalex)
        titleDownBg:setScaleY(scaley)
        self.bgLayer:addChild(titleDownBg,zorder)
        local lineSpDown1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
        lineSpDown1:setScaleX(titleBgWidth/lineSpDown1:getContentSize().width)
        -- lineSpDown1:setScaleY(10/lineSpDown1:getContentSize().height)
        lineSpDown1:setPosition(ccp(bgSize.width/2,titleDownBg:getPositionY()+titleBgHeight/2))
        self.bgLayer:addChild(lineSpDown1,zorder)
        local lineSpDown2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
        lineSpDown2:setScaleX(titleBgWidth/lineSpDown2:getContentSize().width)
        -- lineSpDown2:setScaleY(10/lineSpDown2:getContentSize().height)
        lineSpDown2:setPosition(ccp(bgSize.width/2,titleDownBg:getPositionY()-titleBgHeight/2))
        self.bgLayer:addChild(lineSpDown2,zorder)

        local goldIcon=CCSprite:createWithSpriteFrameName("iconGold1.png")
        goldIcon:setAnchorPoint(ccp(1,0.5))
        goldIcon:setScale(1.2)
        goldIcon:setPosition(bgSize.width/2-30,titleDownBg:getPositionY())
        self.bgLayer:addChild(goldIcon,zorder+1)
        self:addLightBlinker(goldIcon)

        local valueLb=GetTTFLabel("200%",50)
        valueLb:setAnchorPoint(ccp(0,0.5))
        valueLb:setColor(G_ColorYellowPro2)
        valueLb:setPosition(bgSize.width/2+10,titleDownBg:getPositionY())
        self.bgLayer:addChild(valueLb,zorder+1)
    -- end
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
        return self:close()
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

    self:doSomething()
    local rewardLayer=self:initFirstRecharge()
    rewardLayer:setPosition(ccp(self.bgSize.width/2,140))
    self.bgLayer:addChild(rewardLayer,zorder)

    self.des:setPosition(ccp(self.bgSize.width/2,120))
    self.bgLayer:addChild(self.des,zorder) 
end

function acFirstRechargeDialog:doSomething( ... )
    self.desH,self.des = self:getDes(getlocal("activity_firstRecharge_newdes"))
  
    if self == nil then
        return
    end
    if self.rewardMenu ~= nil then
        self.bgLayer:removeChild(self.rewardMenu,true)
        self.rewardMenu = nil
    end
    local function hadReward(tag,object)
    end

    local function getReward(tag,object)
        self:getFirstRechargeReward()
    end
  
    local function gotoCharge(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        vipVoApi:showRechargeDialog(self.layerNum+1)
        self:close()
    end

    self.flag = tonumber(self.acVo.c)
    self.reward = self.acVo.r
    local rewardBtn
    local isReward,isShowDouble,isCanReward=false,false,true
    if acFirstRechargeVoApi then
        isReward,isShowDouble,isCanReward=acFirstRechargeVoApi:canReward()
    end
    -- if self.flag >= tonumber(self.acVo.v) then
    if isReward==true then
        rewardBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",getReward,nil,getlocal("newGiftsReward"),28)
        if isCanReward==false then
            rewardBtn:setEnabled(false)
        else
            -- G_addRectFlicker(rewardBtn,2.3,1,getCenterPoint(rewardBtn))
            self:playRechargeEffect(rewardBtn)
        end
    else
        -- if self.flag < 0 then
        --   rewardBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",hadReward,nil,getlocal("activity_hadReward"),28)
        --   rewardBtn:setEnabled(false)
        -- else
        --   rewardBtn =GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",gotoCharge,nil,getlocal("recharge"),28);
        -- end
        if (self.flag<0 and self.acVo.r==nil) or (self.acVo.r and self.acVo.r==1) then
            rewardBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",hadReward,nil,getlocal("activity_hadReward"),28)
            rewardBtn:setEnabled(false)
        else
            rewardBtn =GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",gotoCharge,nil,getlocal("recharge"),28);
            -- G_addRectFlicker(rewardBtn,2.3,1,getCenterPoint(rewardBtn))
            self:playRechargeEffect(rewardBtn)
        end
    end

    self.rewardMenu=CCMenu:createWithItem(rewardBtn)
    self.rewardMenu:setPosition(ccp(self.bgSize.width/2,60))
    self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(self.rewardMenu,10) 


    local giftData=FormatItem(self.acVo.reward,true,true)
    self.rewardRow =   math.ceil(SizeOfTable(giftData)/5)
end

function acFirstRechargeDialog:playRechargeEffect(parent)
    if parent==nil then
        return
    end
    local spcSp=CCSprite:createWithSpriteFrameName("buy_light_0.png")
    local  spcArr=CCArray:create()
    for kk=0,11 do
        local nameStr="buy_light_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        spcArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(spcArr)
    animation:setDelayPerUnit(0.06)
    local animate=CCAnimate:create(animation)
    spcSp:setAnchorPoint(ccp(0.5,0.5))
    spcSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height/2))
    spcSp:setScaleX(parent:getContentSize().width/spcSp:getContentSize().width)
    spcSp:setScaleY(parent:getContentSize().height/spcSp:getContentSize().height)
    parent:addChild(spcSp)
    local delayAction=CCDelayTime:create(3)
    local seq=CCSequence:createWithTwoActions(animate,delayAction)
    local repeatForever=CCRepeatForever:create(seq)
    spcSp:runAction(repeatForever)
end

function acFirstRechargeDialog:addLightBlinker(parent)
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
-- function acFirstRechargeDialog:setTv(titleX, timeY)
--   local function callBack(...)
--        return self:eventHandler(...)
--   end
--   local hd= LuaEventHandler:createHandler(callBack)
--   self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
--   self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, timeY - 110))
--   self.panelLineBg:setPosition(ccp(titleX, 100))
 
--   self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,timeY - 130),nil)
--   self.bgLayer:addChild(self.tv)
--   self.tv:setPosition(ccp(10,110))
--   self.tv:setAnchorPoint(ccp(0,0))
--   self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
--   self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
--   self.tv:setMaxDisToBottomOrTop(120)
-- end

-- function acFirstRechargeDialog:eventHandler(handler,fn,idx,cel)
--   if fn=="numberOfCellsInTableView" then
--     return 2
--   elseif fn=="tableCellSizeForIndex" then
--     local tmpSize
--     if idx == 1 then
--       tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,self.desH)
--     else
--       tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,220 * self.rewardRow + 10)
--     end
--      return  tmpSize
--   elseif fn=="tableCellAtIndex" then
--     local cell=CCTableViewCell:new()
--     cell:autorelease()

--     if idx == 0 then
--       local rewardLayer = self:initFirstRecharge()
--       rewardLayer:setPosition(ccp(10, 10))
--       cell:addChild(rewardLayer)
--     elseif idx == 1 then
--       self.des:setAnchorPoint(ccp(0,1))
--       self.des:setPosition(ccp(10, self.desH))
--       cell:addChild(self.des)  
--     end
--     return cell
--   elseif fn=="ccTouchBegan" then
--     self.isMoved=false
--     return true
--   elseif fn=="ccTouchMoved" then
--     self.isMoved=true
--   elseif fn=="ccTouchEnded"  then
   
--   end
-- end

function acFirstRechargeDialog:initFirstRecharge()
    -- local itemH=180
    -- if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
    --     itemH=150
    -- end
    local iconSize=80
    local function cellClick( ... )
    end
    local firstRechargeBg = LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20, 20, 10, 10),cellClick)
    firstRechargeBg:setAnchorPoint(ccp(0.5,0))
    local layerWidth=self.bgSize.width-20
    local rewardLayer=CCNode:create()
    rewardLayer:setAnchorPoint(ccp(0.5,1))
    rewardLayer:setContentSize(CCSizeMake(layerWidth,1))
    firstRechargeBg:addChild(rewardLayer)

    local giftData=FormatItem(self.acVo.reward,true,true)
    for k,v in pairs(giftData) do
        if v and (v.key=="gems" or v.key=="gem") then
            table.remove(giftData,k)
        end
    end
    -- local isReward,isShowDouble=false,false
    -- local isHadRewardGems=false
    -- if acFirstRechargeVoApi then
    --     isReward,isShowDouble=acFirstRechargeVoApi:canReward()
    --     isHadRewardGems=acFirstRechargeVoApi:isHadRewardGems()
    -- end
    -- if base.newRechargeSwitch==1 then
    --     if isReward==false or (isReward==true and isShowDouble==false) then
    --         for k,v in pairs(giftData) do
    --             if v and (v.key=="gems" or v.key=="gem") then
    --                 table.remove(giftData,k)
    --             end
    --         end
    --     end
    -- elseif base.newRechargeSwitch==0 then
    --     if isHadRewardGems==true then
    --         for k,v in pairs(giftData) do
    --             if v and (v.key=="gems" or v.key=="gem") then
    --                 table.remove(giftData,k)
    --             end
    --         end
    --     end
    -- end

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
    local nameH=0
    for k,v in pairs(giftData) do
        if v and v.name then
            -- local function showInfoHandler()
            --   if G_checkClickEnable()==false then
            --         do
            --             return
            --         end
            --     else
            --         base.setWaitTime=G_getCurDeviceMillTime()
            --     end
            --     if v and v.name and v.pic and v.num and v.desc then
            --       if v.key=="gems" or v.key=="gem" then
            --       else
            --         propInfoDialog:create(sceneGame,v,self.layerNum+1)
            --       end
            --     end
            -- end
            local icon,scale = G_getItemIcon(v,iconSize,true,self.layerNum+1)
            iconX = 10 + w * index+ w/2
            icon:setAnchorPoint(ccp(0.5, 1))
            icon:setPosition(ccp(iconX, iconY))
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            rewardLayer:addChild(icon,1)

            local flickerScale=1.15
            if v.type=="o" then
                flickerScale=1.75
            end
            if index==0 then
                G_addRectFlicker2(icon,flickerScale,flickerScale,2,"p",nil,nil,true)
            else
                G_addRectFlicker2(icon,flickerScale,flickerScale,1,"b",nil,nil,true)
            end

            local numLb=GetTTFLabel("x"..FormatNumber(v.num),23)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(ccp(icon:getContentSize().width-5,0))
            icon:addChild(numLb,4)
        
            local name  
            if v.key == "gems" or (v.type=="p" and v.key=="p235") then
                if v.key == "gems" then
                    name = getlocal("doubleGems")
                else
                    name = v.name
                end
            else
                name = v.name
            end
            local nameLable = GetTTFLabelWrap(name,20,CCSizeMake(iconSize+20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLable:setAnchorPoint(ccp(0.5,1))
            nameLable:setPosition(ccp(iconX, icon:getPositionY()-iconSize-10))
            rewardLayer:addChild(nameLable,1)
            nameLable:setColor(G_ColorYellowPro)
            index = index + 1
            if nameH<nameLable:getContentSize().height then
                nameH=nameLable:getContentSize().height
            end
            local function addline()
                index = 0
                rowIndex = rowIndex + 1
                rewardBgH=rewardBgH+nameH
                iconY=iconY-nameH-iconSize-10
                nameH=0
            end
            if rewardCount<4 then
                if index==rewardCount then
                    addline()
                end
            else
                if index >= 4 then
                    addline()
                end
            end
        end
    end
    rewardBgH=rewardBgH+self.rewardRow*(iconSize+10)+(self.rewardRow-1)*20+10
    firstRechargeBg:setContentSize(CCSizeMake(layerWidth,rewardBgH))
    rewardLayer:setPosition(layerWidth/2,rewardBgH-35)


    local subTitleSp=CCSprite:createWithSpriteFrameName("hotSaleStrip.png")
    subTitleSp:setFlipX(true)
    subTitleSp:setAnchorPoint(ccp(0,0.5))
    subTitleSp:setPosition(ccp(0,firstRechargeBg:getContentSize().height-5))
    firstRechargeBg:addChild(subTitleSp,2)

    local rewardTitleLb=GetTTFLabel(getlocal("activity_SendGeneral_value",{self.acVo.totalPrice}),25)
    rewardTitleLb:setAnchorPoint(ccp(0,0.5))
    rewardTitleLb:setPosition(10,subTitleSp:getContentSize().height/2)
    subTitleSp:addChild(rewardTitleLb,2)

    local goldIcon=CCSprite:createWithSpriteFrameName("iconGold1.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(rewardTitleLb:getPositionX()+rewardTitleLb:getContentSize().width+10,rewardTitleLb:getPositionY())
    subTitleSp:addChild(goldIcon,2)
    self:addLightBlinker(goldIcon)
    
    return firstRechargeBg
end

function acFirstRechargeDialog:getFirstRechargeReward()

  local function getRewardSuccess(fn,data)
    -- local isReward,isShowDouble=false,false
    -- if acFirstRechargeVoApi then
    --     isReward,isShowDouble=acFirstRechargeVoApi:canReward()
    -- end
    -- local isRewardDouble=true
    -- if base.newRechargeSwitch==1 then
    --     if isReward==false or (isReward==true and isShowDouble==false) then
    --         isRewardDouble=false
    --     end
    -- end
    local acVo=G_clone(self.acVo)
    local ret,sData=base:checkServerData(data)
    if ret==true then
        PlayEffect(audioCfg.mouseClick)
        local awardTab=FormatItem(acVo.reward,true,true)
        -- 添加奖励
        for k,v in pairs(awardTab) do
            print("数值是",k,v.key,v.num)
            if v.key=="gem" or v.key=="gems" then
                -- print("acVo",acVo.c,acVo.v,acVo.r)
                if (acVo.c >= acVo.v and (acVo.r==nil or acVo.r==0)) then
                -- if isRewardDouble==true then
                    awardTab[k].num=tonumber(acVo.c)
                else
                    awardTab[k].num=0
                end
            end
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
        end

        if sData.data and sData.data.useractive then
            activityVoApi:updateVoByType(sData.data.useractive)
        end
        self.acVo=acFirstRechargeVoApi:getAcVo()
        -- self.acVo.c = -1
        -- self.acVo.r = 1
        -- print("self.acVo",self.acVo.c,self.acVo.r)
        self.acVo.over = true
        self.acVo.hasData=false
        eventDispatcher:dispatchEvent("activity.firstRechargeComplete")
        eventDispatcher:dispatchEvent("activity.firstRechargeComplete2")
        self:tick()
        if awardTab then
            for k,v in pairs(awardTab) do
                if v and v.num<=0 then
                    table.remove(awardTab,k)
                end
            end
        end
        smallDialog:showRewardDialog("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,{getlocal("activity_getReward")},25,awardTab)
        G_showRewardTip(awardTab,true)
          
    end
  end
  socketHelper:activityFinished("firstRecharge", getRewardSuccess)
end

function acFirstRechargeDialog:tick()
  if self ~= nil and self.acVo ~= nil then
    local flag = tonumber(self.acVo.c)
    local reward = self.acVo.r
    -- print("flag,self.flag",flag,self.flag)
    -- print("reward,self.reward",reward,self.reward)
    if flag ~= self.flag or reward ~= self.reward then
      activityVoApi:updateShowState(self.acVo)
      self:doSomething()
    end
  end 
end

function acFirstRechargeDialog:update()
  -- body
end

function acFirstRechargeDialog:getDes(content)
  local showMsg=content or ""
  local width=self.bgSize.width-20
  local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function acFirstRechargeDialog:dispose()
    self.acVo = nil
    self.flag = nil
    self.rewardMenu = nil
    self.des = nil
    self.desH = nil
    self.reward = nil
    self=nil
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
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/iconGoldImage.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/iconGoldImage.pvr.ccz")
end





