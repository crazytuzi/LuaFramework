function smallDialog:showMineInfoDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
	local sd=smallDialog:new()
  	sd:initMineInfoDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
end

function smallDialog:showMineGatherDialog(bgSrc,size,fullRect,inRect,callback,istouch,isuseami,layerNum)
  	local sd=smallDialog:new()
	sd:initMineGatherDialog(bgSrc,size,fullRect,inRect,callback,istouch,isuseami,layerNum)
end

function smallDialog:initMineInfoDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
    local strSize2 = 22
    local needPosH = 7
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        strSize2 =25
        needPosH =0
    end
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function tmpFunc()
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local resCount=0
    if data then
         resCount=SizeOfTable(data)
    end
    if titleColor==nil then
        titleColor=G_ColorWhite
    end
    if baseAdd==nil then
        baseAdd=0
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,CCRect(20, 20, 10, 10),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    local layerHeight=0
    if resCount>1 then
        local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
        tipBg:setContentSize(CCSizeMake(size.width,60))
        tipBg:setAnchorPoint(ccp(0.5,0))
        tipBg:setPosition(ccp(size.width/2,10))
        self.bgLayer:addChild(tipBg,2)

        strSize2 = 20
        local str=getlocal("goldmine_pro3")
        local descLb=GetTTFLabelWrap(str,strSize2,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0.5,0.5))
        descLb:setPosition(ccp(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2+needPosH))
        descLb:setColor(G_ColorYellowPro)
        tipBg:addChild(descLb)
        layerHeight=layerHeight+tipBg:getContentSize().height
    end
    layerHeight=layerHeight+30
    
    local downBgSp = CCSprite:createWithSpriteFrameName("expedition_down.png")
    downBgSp:setAnchorPoint(ccp(0.5,0))
    downBgSp:setScaleX(self.bgLayer:getContentSize().width/downBgSp:getContentSize().width)
    downBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,0))
    self.bgLayer:addChild(downBgSp,6)

    local function initResInfo(picName,resName,num,scale)
        local resSp = CCSprite:createWithSpriteFrameName(picName)
        resSp:setScale(scale)
        resSp:setPosition(ccp(40,layerHeight))
        resSp:setAnchorPoint(ccp(0.5,0))
        self.bgLayer:addChild(resSp)

        local resNameLb=GetTTFLabel(resName.."：",20)
        resNameLb:setAnchorPoint(ccp(0,0.5))
        resNameLb:setPosition(ccp(80,resSp:getPositionY()+resSp:getContentSize().height*resSp:getScaleY()/2))
        self.bgLayer:addChild(resNameLb)
        local countStr=FormatNumber(num).."/h"
        countStr=replaceIllegal(countStr)
        local resCountLb=GetTTFLabel(countStr,20)
        resCountLb:setAnchorPoint(ccp(0,0.5))
        resCountLb:setPosition(ccp(resNameLb:getPositionX()+resNameLb:getContentSize().width+10,resNameLb:getPositionY()))
        self.bgLayer:addChild(resCountLb)

        local resHeight=resSp:getContentSize().height*resSp:getScaleY()
        layerHeight=layerHeight+resHeight
    end

    if data then
        if resCount>1 then
            for i=resCount,2,-1 do
                local res=data[i]
                if res then
                    scale=1
                    if res.key=="gems" then
                        scale=1.2
                    else
                        scale=0.5
                    end
                    initResInfo(res.pic,res.name,res.speed,scale)
                end
            end

            local itembgSp2 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
            itembgSp2:setAnchorPoint(ccp(0.5,0))
            itembgSp2:setPosition(ccp(size.width/2,layerHeight+10))
            itembgSp2:setScaleX(0.8)
            itembgSp2:setScaleY(0.5)
            self.bgLayer:addChild(itembgSp2)
            local itemLb2 = GetTTFLabel(getlocal("mine_special_output"),24,true)
            itemLb2:setPosition(ccp(itembgSp2:getContentSize().width/2,itembgSp2:getContentSize().height/2))
            itemLb2:setColor(G_ColorYellowPro)
            itemLb2:setScaleX(1/itembgSp2:getScaleX())
            itemLb2:setScaleY(1/itembgSp2:getScaleY())
            itembgSp2:addChild(itemLb2)
            layerHeight=layerHeight+itembgSp2:getContentSize().height*itembgSp2:getScaleY()+20
        end
        if data[1] then
            local baseRes=data[1]
            initResInfo(baseRes.pic,baseRes.name,baseRes.speed,1.2)
            layerHeight=layerHeight+10

            local itembgSp1 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
            itembgSp1:setAnchorPoint(ccp(0.5,0))
            itembgSp1:setPosition(ccp(size.width/2,layerHeight))
            itembgSp1:setScaleX(0.8)
            itembgSp1:setScaleY(0.5)
            self.bgLayer:addChild(itembgSp1)
            local itemLb1 = GetTTFLabel(getlocal("mine_base_output"),24,true)
            itemLb1:setPosition(ccp(itembgSp1:getContentSize().width/2,itembgSp1:getContentSize().height/2))
            itemLb1:setColor(G_ColorYellowPro)
            itemLb1:setScaleX(1/itembgSp1:getScaleX())
            itemLb1:setScaleY(1/itembgSp1:getScaleY())
            itembgSp1:addChild(itemLb1)
            layerHeight=layerHeight+itembgSp1:getContentSize().height*itembgSp1:getScaleY()+10
        end
    end

    layerHeight=layerHeight+20
    self:show()

    bgLayerSize =CCSizeMake(size.width,layerHeight)
    self.bgLayer:setContentSize(bgLayerSize)

    local upBgSp = CCSprite:createWithSpriteFrameName("expedition_up.png")
    upBgSp:setAnchorPoint(ccp(0.5,1))
    upBgSp:setScaleX(self.bgLayer:getContentSize().width/upBgSp:getContentSize().width)
    upBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height+5))
    self.bgLayer:addChild(upBgSp,6)

    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
            CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
        end
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end

function smallDialog:initMineGatherDialog(bgSrc,size,fullRect,inRect,callback,istouch,isuseami,layerNum)
    local strSize2 = 22
    local needPosH = 7
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        strSize2 =25
        needPosH =0
    end
	self.isTouch=istouch
    self.isUseAmi=isuseami
  	local function tmpFunc()
  	end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,CCRect(20, 20, 10, 10),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    local resTb,resCount=goldMineVoApi:getGatherResList()
    local layerHeight=0
    local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
    tipBg:setContentSize(CCSizeMake(size.width,60))
    tipBg:setAnchorPoint(ccp(0.5,0))
    tipBg:setPosition(ccp(size.width/2,10))
    self.bgLayer:addChild(tipBg,2)

    local str=getlocal("goldmine_pro3")
    local descLb=GetTTFLabelWrap(str,20,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2+needPosH))
    descLb:setColor(G_ColorYellowPro)
    tipBg:addChild(descLb)
    layerHeight=layerHeight+tipBg:getContentSize().height+30

    local downBgSp = CCSprite:createWithSpriteFrameName("expedition_down.png")
    downBgSp:setAnchorPoint(ccp(0.5,0))
    downBgSp:setScaleX(self.bgLayer:getContentSize().width/downBgSp:getContentSize().width)
    downBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,0))
    self.bgLayer:addChild(downBgSp,6)

    if resTb.r then
        local resCount=SizeOfTable(resTb.r)
        local resIdx=resCount-1
        local resHeight=0
        for key,res in pairs(resTb.r) do
            local item=alienTechCfg.resource[key]
            local id=RemoveFirstChar(key)
            local picName="alien_mines"..id.."_"..id..".png"
            local resSp = CCSprite:createWithSpriteFrameName(picName)
            resSp:setScale(0.5)
            resSp:setAnchorPoint(ccp(0.5,0))
            resHeight=resSp:getContentSize().height*resSp:getScaleY()+10
            resSp:setPosition(ccp(40,layerHeight+resIdx*resHeight))
            self.bgLayer:addChild(resSp)
            local resNameLb=GetTTFLabel(getlocal(item.name).."：",20)
            resNameLb:setAnchorPoint(ccp(0,0.5))
            resNameLb:setPosition(ccp(80,resSp:getPositionY()+resSp:getContentSize().height*resSp:getScaleY()/2))
            self.bgLayer:addChild(resNameLb)
            local countColor=G_ColorWhite
            if res.cur>=res.max then
                res.cur=res.max
                countColor=G_ColorRed
            end
            local resCountLb=GetTTFLabel(FormatNumber(res.cur).."/"..FormatNumber(res.max),20)
            resCountLb:setAnchorPoint(ccp(0,0.5))
            resCountLb:setPosition(ccp(resNameLb:getPositionX()+resNameLb:getContentSize().width+10,resNameLb:getPositionY()))
            self.bgLayer:addChild(resCountLb)
            resCountLb:setColor(countColor)
            if resIdx~=0 then
                local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setScaleX(size.width/lineSp:getContentSize().width)
                lineSp:setPosition(ccp(size.width/2,resCountLb:getPositionY()-resCountLb:getContentSize().height/2-10))
                self.bgLayer:addChild(lineSp)
            end
            resIdx=resIdx-1
        end
        layerHeight=layerHeight+resCount*resHeight

        local itembgSp3 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
        itembgSp3:setAnchorPoint(ccp(0.5,0))
        itembgSp3:setPosition(ccp(size.width/2,layerHeight))
        itembgSp3:setScaleX(0.8)
        itembgSp3:setScaleY(0.5)
        self.bgLayer:addChild(itembgSp3)
        local itemLb3 = GetTTFLabel(getlocal("goldmine_gather_aliens_pro"),24,true)
        itemLb3:setPosition(ccp(itembgSp3:getContentSize().width/2,itembgSp3:getContentSize().height/2))
        itemLb3:setColor(G_ColorYellowPro)
        itemLb3:setScaleX(1/itembgSp3:getScaleX())
        itemLb3:setScaleY(1/itembgSp3:getScaleY())
        itembgSp3:addChild(itemLb3)
        layerHeight=layerHeight+itembgSp3:getContentSize().height*itembgSp3:getScaleY()+10
    end

    if resTb.u then
        local gemsData=resTb.u["gems"]

        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldSp:setAnchorPoint(ccp(0.5,0))
        goldSp:setPosition(ccp(40,layerHeight))
        goldSp:setScale(1.2)
        self.bgLayer:addChild(goldSp)

        local gemsProLb=GetTTFLabel(getlocal("activity_vipAction_had").."：",20)
        gemsProLb:setAnchorPoint(ccp(0,0.5))
        gemsProLb:setPosition(ccp(80,goldSp:getPositionY()+goldSp:getContentSize().height/2))
        self.bgLayer:addChild(gemsProLb)
        local color=G_ColorWhite
        if gemsData.cur>=gemsData.max then
            gemsData.cur=gemsData.max
            color=G_ColorRed
        end
        local gemsCountLb=GetTTFLabel(FormatNumber(gemsData.cur).."/"..FormatNumber(gemsData.max),20)
        gemsCountLb:setAnchorPoint(ccp(0,0.5))
        gemsCountLb:setPosition(ccp(gemsProLb:getPositionX()+gemsProLb:getContentSize().width+10,gemsProLb:getPositionY()))
        self.bgLayer:addChild(gemsCountLb)
        gemsCountLb:setColor(color)

        layerHeight=layerHeight+gemsProLb:getContentSize().height+10

        local itembgSp2 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
        itembgSp2:setAnchorPoint(ccp(0.5,0))
        itembgSp2:setPosition(ccp(size.width/2,layerHeight))
        itembgSp2:setScaleX(0.8)
        itembgSp2:setScaleY(0.5)
        self.bgLayer:addChild(itembgSp2)
        local itemLb2 = GetTTFLabel(getlocal("goldmine_gather_gold_pro"),24,true)
        itemLb2:setPosition(ccp(itembgSp2:getContentSize().width/2,itembgSp2:getContentSize().height/2))
        itemLb2:setColor(G_ColorYellowPro)
        itemLb2:setScaleX(1/itembgSp2:getScaleX())
        itemLb2:setScaleY(1/itembgSp2:getScaleY())
        itembgSp2:addChild(itemLb2)
        layerHeight=layerHeight+itembgSp2:getContentSize().height*itembgSp2:getScaleY()+10
    end

    local worldLvDesLb=GetTTFLabelWrap(getlocal("goldmine_pro1"),20,CCSizeMake(size.width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    worldLvDesLb:setAnchorPoint(ccp(0,0))
    worldLvDesLb:setPosition(ccp(20,layerHeight))
    self.bgLayer:addChild(worldLvDesLb)
    layerHeight=layerHeight+worldLvDesLb:getContentSize().height+10

    local worldSp = CCSprite:createWithSpriteFrameName("worldLvIcon.png")
    worldSp:setAnchorPoint(ccp(0,0))
    worldSp:setPosition(ccp(30,layerHeight-10))
    self.bgLayer:addChild(worldSp)

    local worldLv=playerVoApi:getWorldLv()
    local worldLvLb = GetTTFLabel(getlocal("goldmine_worldLv_pro")..worldLv,20)
    worldLvLb:setAnchorPoint(ccp(0,0))
    worldLvLb:setPosition(ccp(worldSp:getPositionX()+worldSp:getContentSize().width+10,layerHeight+40))
    self.bgLayer:addChild(worldLvLb)
    layerHeight=layerHeight+worldSp:getContentSize().height+10

    if playerVoApi:isWorldLvTop()==true then
        local topLb = GetTTFLabel("("..getlocal("worldlv_reached_top")..")",20)
        topLb:setAnchorPoint(ccp(0,0))
        topLb:setColor(G_ColorYellowPro)
        topLb:setPosition(ccp(worldSp:getPositionX()+worldSp:getContentSize().width+10,worldLvLb:getPositionY()-40))
        self.bgLayer:addChild(topLb)
    else
        local timerSprite,progressSp=AddProgramTimer(self.bgLayer,ccp(worldLvLb:getPositionX()+431*0.7/2,worldLvLb:getPositionY()-20),110,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",111,0.7,1,nil)
        local percent=playerVoApi:getWorldExpPercent()
        timerSprite:setPercentage(percent)
        local worldExpLb = GetTTFLabel(percent.."%",20)
        worldExpLb:setScaleX(1/timerSprite:getScaleX())
        worldExpLb:setScaleY(1/timerSprite:getScaleY())
        worldExpLb:setPosition(ccp(timerSprite:getContentSize().width/2,timerSprite:getContentSize().height*timerSprite:getScaleY()/2))
        timerSprite:addChild(worldExpLb)
    end

    local itembgSp1 = CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
    itembgSp1:setPosition(ccp(size.width/2,layerHeight))
    itembgSp1:setScaleX(0.8)
    itembgSp1:setScaleY(0.5)
    self.bgLayer:addChild(itembgSp1)
    local itemLb1 = GetTTFLabel(getlocal("goldmine_world"),24,true)
    itemLb1:setPosition(ccp(itembgSp1:getContentSize().width/2,itembgSp1:getContentSize().height/2))
    itemLb1:setColor(G_ColorYellowPro)
    itemLb1:setScaleX(1/itembgSp1:getScaleX())
    itemLb1:setScaleY(1/itembgSp1:getScaleY())
    itembgSp1:addChild(itemLb1)
    layerHeight=layerHeight+itembgSp1:getContentSize().height*itembgSp1:getScaleY()+10

    self:show()

    bgLayerSize =CCSizeMake(size.width,layerHeight)
    self.bgLayer:setContentSize(bgLayerSize)

    local upBgSp = CCSprite:createWithSpriteFrameName("expedition_up.png")
    upBgSp:setAnchorPoint(ccp(0.5,1))
    upBgSp:setScaleX(self.bgLayer:getContentSize().width/upBgSp:getContentSize().width)
    upBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height+5))
    self.bgLayer:addChild(upBgSp,6)

    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
            CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
        end
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end