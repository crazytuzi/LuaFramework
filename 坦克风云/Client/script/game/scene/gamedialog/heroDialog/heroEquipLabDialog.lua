heroEquipLabDialog = commonDialog:new()

function heroEquipLabDialog:new(ifOpenShop,callback)
	local  nc = {
        eventCallback = callback
    }
	setmetatable(nc,self)
	self.__index=self
    self.isToday=true
    self.ifOpenShop=ifOpenShop
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acDiancitanke.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
	return nc
end

--初始化对话框面板
function heroEquipLabDialog:initTableView( )
    local strSize2 = 20
    local strSize3 = 22
    local strSize4 = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =22
        strSize3 = 25
    elseif G_getCurChoseLanguage() =="ru" then
        strSize2 =17
        strSize3 =20
        strSize4 = 18
    end
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))

    local spriteShapeH = 150
    local desTvH = 90
    local desTvY = 40
    local characterScale = 0.75
    local CharacterY1 = 540
    local CharacterY2 = 310
    local subTitleY = 50
    if G_getIphoneType() == G_iphoneX then
        CharacterY1 =  750
        CharacterY2 =  450 
        spriteShapeH = 250
        desTvH = 190
        desTvY = 75
        subTitleY = 180
    elseif G_getIphoneType() == G_iphone5 then
        spriteShapeH = 200
        desTvH = 140
        -- characterScale=0.9
        CharacterY1=650
        CharacterY2=370
        desTvY = 57
        subTitleY = 90
    end
    local spriteShapeInforY = self.bgLayer:getContentSize().height-85
    local spriteShapeInforH = spriteShapeH

    local descBgSp= CCSprite:create("public/hero/heroequip/equipLabBigBg.jpg")
    descBgSp:setAnchorPoint(ccp(0.5,1))
    descBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,spriteShapeInforY))
    self.bgLayer:addChild(descBgSp)
    descBgSp:setScaleY((spriteShapeInforY-15)/descBgSp:getContentSize().height)
    -- descBgSp:setScaleX(1)

    
	local buildIcon = CCSprite:createWithSpriteFrameName("equipBtn.png")
    buildIcon:setAnchorPoint(ccp(0.5,0.5))
    buildIcon:setPosition(ccp(buildIcon:getContentSize().width/2+40,spriteShapeInforY-70))
    -- spriteShapeInfor:addChild(buildIcon,1)
    self.bgLayer:addChild(buildIcon,1)

    local desStr = getlocal("equip_lab_desc")
    local desTv, desLabel= G_LabelTableView(CCSizeMake(450, desTvH),desStr,23,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(buildIcon:getPositionX()+buildIcon:getContentSize().width/2+5, spriteShapeInforY-desTvY-spriteShapeH/2+10))
    desTv:setAnchorPoint(ccp(0,0.5))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)
    -- spriteShapeInfor:addChild(desTv)
    self.bgLayer:addChild(desTv)

    local guidSp1= CCSprite:createWithSpriteFrameName("NewCharacter01.png")
    guidSp1:setAnchorPoint(ccp(0.5,0))
	guidSp1:setPosition(ccp(100,CharacterY1))    
    self.bgLayer:addChild(guidSp1,3)
    guidSp1:setScale(characterScale)

    local guidSp2= CCSprite:createWithSpriteFrameName("NewCharacter02.png")
    guidSp2:setAnchorPoint(ccp(0.5,0))
    guidSp2:setPosition(ccp(100,CharacterY2))
    self.bgLayer:addChild(guidSp2,3)
    guidSp2:setFlipX(true)
    guidSp2:setScale(characterScale)

    local function touch2( ... )
        -- body
    end
    
    local descLbSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    descLbSp1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,150))
    descLbSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,guidSp1:getPositionY()))
    descLbSp1:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(descLbSp1,2)
    local hotSp1=CCSprite:createWithSpriteFrameName("platWarNameBg2.png")
    hotSp1:setAnchorPoint(ccp(1,0.5))
    hotSp1:setFlipX(true)
    hotSp1:setPosition(ccp(descLbSp1:getContentSize().width+40,descLbSp1:getPositionY()+descLbSp1:getContentSize().height))
    self.bgLayer:addChild(hotSp1,2)

    local titleStr = getlocal("get_prop_title1")
    local ifFree,timeStr = heroEquipVoApi:checkIfHasFreeLottery()
    if ifFree==false then
        titleStr=getlocal("get_prop_title3",{timeStr})
    end
    local titleLb1 = GetTTFLabelWrap(titleStr,22,CCSizeMake(hotSp1:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setPosition(ccp(10+hotSp1:getContentSize().width/2, hotSp1:getContentSize().height/2+2))
    hotSp1:addChild(titleLb1)
    self.titleLb1=titleLb1

    local lotteryGold = heroEquipAwakeShopCfg.payTicketCost
    local lotteryTenGold = heroEquipAwakeShopCfg.payTicketTenCost
    self.lotteryTenGold=lotteryTenGold
    local function studyHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if tag==11 then
            local prop_pid = heroEquipAwakeShopCfg.payitem
            local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))
            local pid = nil
            if bagVoApi:getItemNumId(id)>0 then
                pid=1
            end
            local flag = heroEquipVoApi:checkIfHasFreeLottery()
            local function lotteryHandler(fn,data)
                local oldHeroList=heroVoApi:getHeroList()
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.equip and sData.data.equip.report then
                        self:showHero(sData.data.equip.report[1][1],oldHeroList)
                    end
                    local getid = tonumber(heroEquipAwakeShopCfg.buyitem) or tonumber(RemoveFirstChar(heroEquipAwakeShopCfg.buyitem))
                    
                    if sData and sData.data and sData.data.equip then
                        heroEquipVoApi:formatData(sData.data.equip)
                    end
       
                    if flag==true then
                        self.isToday=true
                    elseif pid==nil then
                        playerVoApi:setGems(playerVoApi:getGems() - lotteryGold)
                    else
                        bagVoApi:useItemNumId(id,1)

                    end
                    bagVoApi:addBag(getid,1)
     
                    self:refreshVisible()
                    self:refreshScorelb()

                end
            end
            if flag==true then
                socketHelper:equipLottery(1,nil,lotteryHandler)
            else
                if pid==nil then
                    
                    if playerVoApi:getGems()<lotteryGold then 
                        GemsNotEnoughDialog(nil,nil,lotteryGold-playerVoApi:getGems(),self.layerNum+1,lotteryGold)
                        do
                            return
                        end
                    end
                    local function lottery()
                        socketHelper:equipLottery(2,nil,lotteryHandler)                    
                    end
                    G_dailyConfirm("equipLab.oneLottery",getlocal("equipLab_lotteryTip",{lotteryGold}),lottery,self.layerNum+1)
                else
                    socketHelper:equipLottery(2,pid,lotteryHandler)
                end
                
            end
            
        elseif tag==12 then
            if playerVoApi:getGems()<lotteryTenGold then 
                GemsNotEnoughDialog(nil,nil,lotteryTenGold-playerVoApi:getGems(),self.layerNum+1,lotteryTenGold)
                do
                    return
                end
            end
            local function lottery()
                local function lotteryHandler(fn,data)
                    local oldHeroList=heroVoApi:getHeroList()
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                    if sData and sData.data and sData.data.equip and sData.data.equip.report then
                        local reward = {}
                        for k,v in pairs(sData.data.equip.report) do
                                local item = FormatItem(v[1])
                                table.insert(reward,item[1])
                                G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num)
                            end
                            self:showTenSearch(reward)
                        end
                        local id = tonumber(heroEquipAwakeShopCfg.buyitem) or tonumber(RemoveFirstChar(heroEquipAwakeShopCfg.buyitem))
                        bagVoApi:addBag(id,10)
                        if sData and sData.data and sData.data.equip then
                            heroEquipVoApi:formatData(sData.data.equip)
                        end

                        playerVoApi:setGems(playerVoApi:getGems() - lotteryTenGold)

                        self:refreshVisible()
                        self:refreshScorelb()
                    end
                end
                socketHelper:equipLottery(3,nil,lotteryHandler)
            end
            G_dailyConfirm("equipLab.tenLottery",getlocal("equipLab_lotteryTip",{lotteryTenGold}),lottery,self.layerNum+1)
        end
    end


    local studyBtn1 = GetButtonItem("acDctk_BtnUp.png","acDctk_BtnDown.png","acDctk_BtnDown.png",studyHandler,1,getlocal("startResearch"),strSize2,51)
    studyBtn1:setAnchorPoint(ccp(1,0))
    local studyBtnMenu1 = CCMenu:createWithItem(studyBtn1)
    studyBtnMenu1:setPosition(ccp(descLbSp1:getContentSize().width-10,10));
    studyBtnMenu1:setTouchPriority(-(self.layerNum-1)*20-4);
    descLbSp1:addChild(studyBtnMenu1,3);
    studyBtn1:setTag(11)
    studyBtn1:setScaleX(1.32)
    studyBtn1:setScaleY(1.2)
    local studyBtnLb1=tolua.cast(studyBtn1:getChildByTag(51),"CCLabelTTF")
    if studyBtnLb1 then
        studyBtnLb1:setScaleX(0.78)
        studyBtnLb1:setScaleY(0.82)
    end

    local freeLb = GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),22,CCSizeMake(120, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    freeLb:setAnchorPoint(ccp(0.5,0.5))
    freeLb:setScaleX(1/studyBtn1:getScaleX())
    freeLb:setScaleY(1/studyBtn1:getScaleY())
    studyBtn1:addChild(freeLb)
    freeLb:setPosition(ccp(studyBtn1:getContentSize().width/2,studyBtn1:getContentSize().height + 15))

    self.freeLb=freeLb

    local propSp=CCSprite:createWithSpriteFrameName("icon_equip_lab.png")
    propSp:setPosition(ccp(descLbSp1:getContentSize().width-110,90))
    descLbSp1:addChild(propSp)
    self.propSp=propSp
    propSp:setScale(0.4)

    local prop_pid = heroEquipAwakeShopCfg.payitem
    local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))

    local propStr = "1" .. "/" .. bagVoApi:getItemNumId(id)
    local propNumLb = GetTTFLabelWrap(propStr,22,CCSizeMake(80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    propNumLb:setAnchorPoint(ccp(0,0.5))
    descLbSp1:addChild(propNumLb)
    propNumLb:setPosition(ccp(propSp:getPositionX()+propSp:getContentSize().width*0.4/2,propSp:getPositionY()))
    self.propNumLb=propNumLb

    local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp:setPosition(ccp(descLbSp1:getContentSize().width-100,90))
    descLbSp1:addChild(goldSp)
    self.goldSp=goldSp

    local goldNumLb = GetTTFLabelWrap(lotteryGold,22,CCSizeMake(80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    goldNumLb:setAnchorPoint(ccp(0,0.5))
    descLbSp1:addChild(goldNumLb)
    goldNumLb:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width/2,goldSp:getPositionY()))
    self.goldNumLb=goldNumLb


    self:refreshVisible()





    local descLbSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    descLbSp2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,150))
    descLbSp2:setAnchorPoint(ccp(0.5,0))
	descLbSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,guidSp2:getPositionY()))
    self.bgLayer:addChild(descLbSp2,2)

    local hotSp2=CCSprite:createWithSpriteFrameName("platWarNameBg1.png")
    hotSp2:setAnchorPoint(ccp(1,0.5))
    hotSp2:setFlipX(true)
    hotSp2:setPosition(ccp(descLbSp2:getContentSize().width+40,descLbSp2:getPositionY()+descLbSp2:getContentSize().height))
    self.bgLayer:addChild(hotSp2,2)

    local titleLb2 = GetTTFLabelWrap(getlocal("get_prop_title2"),22,CCSizeMake(hotSp2:getContentSize().width-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setPosition(ccp(10+hotSp2:getContentSize().width/2, hotSp2:getContentSize().height/2+2))
    hotSp2:addChild(titleLb2)

    local goldIconSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIconSp2:setPosition(ccp(descLbSp2:getContentSize().width-100,90))
    descLbSp2:addChild(goldIconSp2)

    local goldLb2 = GetTTFLabelWrap(lotteryTenGold.."",22,CCSizeMake(80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    goldLb2:setAnchorPoint(ccp(0,0.5))
    goldLb2:setPosition(ccp(goldIconSp2:getPositionX()+goldIconSp2:getContentSize().width/2,goldIconSp2:getPositionY()))
    descLbSp2:addChild(goldLb2)

    local studyBtn2 = GetButtonItem("acDctk_BtnUp.png","acDctk_BtnDown.png","acDctk_BtnDown.png",studyHandler,1,getlocal("equip_lab_study"),strSize2,52)
    studyBtn2:setAnchorPoint(ccp(1,0))
    local studyBtnMenu2 = CCMenu:createWithItem(studyBtn2)
    studyBtnMenu2:setPosition(ccp(descLbSp2:getContentSize().width-10,10));
    studyBtnMenu2:setTouchPriority(-(self.layerNum-1)*20-4);
    descLbSp2:addChild(studyBtnMenu2,3);
    studyBtn2:setScaleX(1.32)
    studyBtn2:setScaleY(1.2)
    studyBtn2:setTag(12)
    local studyBtnLb2=tolua.cast(studyBtn2:getChildByTag(52),"CCLabelTTF")
    if studyBtnLb2 then
        studyBtnLb2:setScaleX(0.78)
        studyBtnLb2:setScaleY(0.82)
    end


    local desTv1, desLabel1= G_LabelTableView(CCSizeMake(290, 115),getlocal("equip_lab_desc1"),21,kCCTextAlignmentLeft)
    desTv1:setPosition(ccp(guidSp1:getContentSize().width*characterScale+8, descLbSp1:getPositionY()+35))
    desTv1:setAnchorPoint(ccp(0,0.5))
    desTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv1:setMaxDisToBottomOrTop(100)
    self.bgLayer:addChild(desTv1,3)

    local desTv2, desLabel2= G_LabelTableView(CCSizeMake(290, 115),getlocal("equip_lab_desc2"),21,kCCTextAlignmentLeft)
    desTv2:setPosition(ccp(guidSp2:getContentSize().width*characterScale+5, descLbSp2:getPositionY()+30))
    desTv2:setAnchorPoint(ccp(0,0.5))
    desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv2:setMaxDisToBottomOrTop(100)
    self.bgLayer:addChild(desTv2,3)

    local canReward = heroEquipAwakeShopCfg.canReward
    self.reward = FormatItem(canReward)
    local function callBack( ... )
        return self:eventHandler(...)
    end
    

    -- local rewardBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch2)
    -- rewardBgSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,180))
    -- rewardBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
    -- rewardBgSp:setAnchorPoint(ccp(0.5,0))
    -- self.bgLayer:addChild(rewardBgSp,3)

    local subTileLb = GetTTFLabel(getlocal("hasChanceGet"),strSize4)
    subTileLb:setAnchorPoint(ccp(0.5,0.5))
    subTileLb:setPosition(ccp(self.bgLayer:getContentSize().width/2, CharacterY2 -subTitleY))
    self.bgLayer:addChild(subTileLb,2)
    subTileLb:setColor(G_ColorYellowPro)

    -- local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    -- lineSP:setAnchorPoint(ccp(0.5,0.5))
    -- lineSP:setScaleX(self.bgLayer:getContentSize().width/lineSP:getContentSize().width)
    -- lineSP:setScaleY(1.2)
    -- lineSP:setPosition(ccp(self.bgLayer:getContentSize().width/2,subTileLb:getPositionY()-subTileLb:getContentSize().height-10))
    -- self.bgLayer:addChild(lineSP)

    local subTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
    subTitleBg:setContentSize(CCSizeMake(150,45))
    subTitleBg:setScaleX((self.bgLayer:getContentSize().width-400)/subTitleBg:getContentSize().width)
    subTitleBg:setPosition(ccp((G_VisibleSizeWidth)/2,CharacterY2 -subTitleY))
    self.bgLayer:addChild(subTitleBg)

    local leftLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    leftLineSP:setFlipX(true)
    leftLineSP:setPosition(ccp(120,CharacterY2 -subTitleY))
    self.bgLayer:addChild(leftLineSP)

    local rightLineSP =CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    rightLineSP:setPosition(ccp(self.bgLayer:getContentSize().width-120,CharacterY2 -subTitleY))
    self.bgLayer:addChild(rightLineSP)

    local hd = LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,150),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,120))
    self.bgLayer:addChild(self.tv)

    -- 觉醒商店
    local function goShop()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local function closeCallback( ... )
            if self then
                self:refreshScorelb()
            end
        end
        heroEquipVoApi:showAwakeShop(self.layerNum+1,closeCallback)
    end
    -- local shopItem = GetButtonItem("btnBlue1.png","btnBlue2.png","btnBlue1.png",goShop,1,getlocal("equip_awakenShop"),25)
    -- shopItem:setAnchorPoint(ccp(1,0))
    local function nilFunc()
    end
    local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",CCRect(44,33,1,1),nilFunc)
    local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",CCRect(44,33,1,1),nilFunc)
    local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",CCRect(44,33,1,1),nilFunc)
    sNormal:setContentSize(CCSizeMake(200,60))
    sSelected:setContentSize(CCSizeMake(200,60))
    sDisabled:setContentSize(CCSizeMake(200,60))

    local item = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
    item:registerScriptTapHandler(goShop)
    item:setAnchorPoint(ccp(1,0))
    local titleLb=GetTTFLabel(getlocal("equip_awakenShop"),strSize3)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(getCenterPoint(item))
    item:addChild(titleLb)

    local shopMenu = CCMenu:createWithItem(item)
    shopMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30,25));
    shopMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(shopMenu,3);

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
    spcSp:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
    item:addChild(spcSp,5)
    spcSp:setScaleX(1.1)
    spcSp:setScaleY(0.5)

    local delayAction=CCDelayTime:create(1)
    local seq=CCSequence:createWithTwoActions(animate,delayAction)
    local repeatForever=CCRepeatForever:create(seq)
    spcSp:runAction(repeatForever)

    local scoreIcon = CCSprite:createWithSpriteFrameName("icon_awaken_fragment.png")
    scoreIcon:setAnchorPoint(ccp(0.5,0))
    scoreIcon:setPosition(ccp(60,25))
    self.bgLayer:addChild(scoreIcon,1)
    scoreIcon:setScale(0.7)

    local scoreLbSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function ()end)
    scoreLbSp:setContentSize(CCSizeMake(100,45))
    scoreLbSp:setPosition(ccp(130,50))
    self.bgLayer:addChild(scoreLbSp)
    local propKey = heroEquipAwakeShopCfg.buyitem
    local id = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
    local num = bagVoApi:getItemNumId(id)
    local scoreLb = GetTTFLabel(num,23)
    scoreLb:setAnchorPoint(ccp(0.5,0.5))
    scoreLb:setPosition(getCenterPoint(scoreLbSp))
    scoreLbSp:addChild(scoreLb)
    self.scoreLb=scoreLb


    if self.ifOpenShop and self.ifOpenShop==true then
        local function closeCallback( ... )
            if self then
                self:refreshScorelb()
            end
        end
        heroEquipVoApi:showAwakeShop(self.layerNum+1,closeCallback)
    end
end

function heroEquipLabDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.reward)
	elseif fn =="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(120,120)
		return tmpSize
	elseif fn =="tableCellAtIndex" then
		local  cell = CCTableViewCell:new()
		cell:autorelease()
		cell:setAnchorPoint(ccp(0,0))
		local item=self.reward[idx+1]
		if item then
			local iconSp=G_getItemIcon(item,nil,true,self.layerNum+1,nil,self.tv)
            
			iconSp:setPosition(ccp(5,20))
			iconSp:setAnchorPoint(ccp(0,0.5))
			cell:addChild(iconSp)
			iconSp:setTouchPriority(-(self.layerNum-1)*20-2)

            local numLb = GetTTFLabel("X"..item.num,25)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(iconSp:getContentSize().width-10, 5))
            iconSp:addChild(numLb)
		end

		
		return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then

   end
end

function heroEquipLabDialog:tick()
    
    if heroEquipVoApi:checkIfHasFreeLottery()==true and self.isToday==true then
        self.isToday=false
        self:refreshVisible()
        self:refreshVisible2()
    end
    if self and self.titleLb1 then
        local titleStr = getlocal("get_prop_title1")
        local ifFree,timeStr = heroEquipVoApi:checkIfHasFreeLottery()
        if ifFree==false then
            titleStr=getlocal("get_prop_title3",{timeStr})
        end
        self.titleLb1:setString(titleStr)
    end
end

function heroEquipLabDialog:update()

end

function heroEquipLabDialog:refreshScorelb()
    print("----dmj----heroEquipLabDialog:refreshScorelb")
    local propKey = heroEquipAwakeShopCfg.buyitem
    local id = tonumber(propKey) or tonumber(RemoveFirstChar(propKey))
    local num = bagVoApi:getItemNumId(id) or 0
    if self.scoreLb then
        self.scoreLb:setString(num)
    end
end

function heroEquipLabDialog:refreshVisible()

    local prop_pid = heroEquipAwakeShopCfg.payitem
    local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))

    if heroEquipVoApi:checkIfHasFreeLottery()==true then
        self.freeLb:setVisible(true)

        self.propSp:setVisible(false)
        self.propNumLb:setVisible(false)

        self.goldSp:setVisible(false)
        self.goldNumLb:setVisible(false)

    elseif bagVoApi:getItemNumId(id)>0 then
        self.freeLb:setVisible(false)

        self.propSp:setVisible(true)
        self.propNumLb:setVisible(true)

        self.goldSp:setVisible(false)
        self.goldNumLb:setVisible(false)

        local propStr = "1" .. "/" .. bagVoApi:getItemNumId(id)
        self.propNumLb:setString(propStr)
    else
        self.freeLb:setVisible(false)

        self.propSp:setVisible(false)
        self.propNumLb:setVisible(false)

        self.goldSp:setVisible(true)
        self.goldNumLb:setVisible(true)

    end

end

function heroEquipLabDialog:showHero(reward,oldHeroList)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                self:showOneSearch(4,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder,nil,"public/hero/heroequip/equipLabBigBg.jpg")

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
                self:showOneSearch(4,award,self.layerNum+1,nil,nil,nil,nil,nil,"public/hero/heroequip/equipLabBigBg.jpg")
            end
        end
    end
end

function heroEquipLabDialog:showTenSearch(reward)

    if self.tenHuaBg==nil then
        local function callback()
            if self.isAction==false then
                for k,v in pairs(self.spTb) do
                    v:stopAllActions()
                    v:setScale(1)
                    self.isAction=true

                    if self.guangSpTb[k] then
                        self.guangSpTb[k]:stopAllActions()
                        self.guangSpTb[k]:setScale(1.6)
                        local rotateBy = CCRotateBy:create(4,360)
                        local reverseBy = rotateBy:reverse()
                        self.guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                        -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
                    end

                    if self.guangSpTb2[k] then
                        self.guangSpTb2[k]:stopAllActions()
                        self.guangSpTb2[k]:setScale(1.6)
                        local rotateBy = CCRotateBy:create(4,360)
                        -- local reverseBy = rotateBy:reverse()
                        -- self.guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                        self.guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
                    end
                    
                end
                self.againBtn:setVisible(true)
                self.okBtn:setVisible(true)
            end
        end
        self.tenHuaBg=LuaCCSprite:createWithFileName("public/hero/heroequip/equipLabBigBg.jpg",callback)
        -- self.tenHuaBg:setAnchorPoint(ccp(0,0))
        -- self.tenHuaBg:setPosition(ccp(0,0))
        self.bgLayer:addChild(self.tenHuaBg,10)
        self.tenHuaBg:setColor(ccc3(150, 150, 150))
        self.tenHuaBg:setScaleX(G_VisibleSize.width/self.tenHuaBg:getContentSize().width)
        self.tenHuaBg:setScaleY(G_VisibleSize.height/self.tenHuaBg:getContentSize().height)

        self.tenHuaBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenHuaBg:setTouchPriority(-(self.layerNum-1)*20-10)

        self.tenSearchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),callback)
        self.bgLayer:addChild(self.tenSearchBg,10)
        -- self.tenSearchBg:setColor(ccc3(150, 150, 150))
        self.tenSearchBg:setContentSize(CCSizeMake(620,G_VisibleSize.height))
        self.tenSearchBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenSearchBg:setTouchPriority(-(self.layerNum-1)*20-10)
        self.tenSearchBg:setOpacity(0)

        --[[self.titleBG = LuaCCScale9Sprite:createWithSpriteFrameName("equip_titleBg.png",CCRect(55, 41, 1, 1),callback)
        self.titleBG:setContentSize(CCSizeMake(640,100))
        self.bgLayer:addChild(self.titleBG,10)
        self.titleBG:setAnchorPoint(ccp(0,1))
        self.titleBG:setPosition(0, self.bgLayer:getContentSize().height)
        self.titleBG:setTouchPriority(-(self.layerNum-1)*20-10)

        local titleStr = getlocal("equip_lab_title")
        if titleStr~=nil then
            if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
                self.titlb = GetTTFLabelWrap(titleStr,33,CCSizeMake(self.bgLayer:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
            else
                self.titlb = GetTTFLabel(titleStr,40)
            end
            self.titlb:setPosition(ccp(self.titleBG:getContentSize().width/2,self.titleBG:getContentSize().height/2))
            self.titleBG:addChild(self.titlb,10);
        end]]

    else
        self.tenSearchBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenSearchBg:setVisible(true)

        self.tenHuaBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
        self.tenHuaBg:setVisible(true)

        -- self.titleBG:setPosition(0, self.bgLayer:getContentSize().height)
        -- self.titleBG:setVisible(true)

    end

    local propKey = heroEquipAwakeShopCfg.buyitem
    local name,pic,desc=getItem(propKey,"p")
    local titleLb = GetTTFLabelWrap(getlocal("equip_getReward",{name .. "*" .. 10}),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(320,self.tenSearchBg:getContentSize().height-70))
    self.tenSearchBg:addChild(titleLb)

    self.isAction = false

    local spTb={}
    local guangSpTb={}
    local guangSpTb2={}
    local subH = 170
    if G_isIphone5()==true then
        subH=190
    end
    for k,v in pairs(reward) do
        
        local i=math.ceil(k/3)
        local j=k%3
        if j==0 then
            j=3
        end

        local sp = G_getItemIcon(v,100,false)
        self.tenSearchBg:addChild(sp,4)
       
        -- sp:setAnchorPoint(ccp(0,0.5))
        sp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
        if k==10 then
            sp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
        end

        local nameLb = GetTTFLabelWrap(v.name .. "x" .. v.num,22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(ccp(sp:getContentSize().width/2,-30))
        sp:addChild(nameLb)
        sp:setScale(0.0001)
        table.insert(spTb,sp)

       

        local flag = self:isAddHuangguang(v.key)
        if flag == true then
            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.tenSearchBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            if k==10 then
                guangSp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            end
            guangSp:setScale(0.0001)
            guangSpTb[k]=guangSp

            local guangSp = CCSprite:createWithSpriteFrameName("equipShine.png")
            self.tenSearchBg:addChild(guangSp,1)
            guangSp:setPosition(68+(j-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            if k==10 then
                guangSp:setPosition(68+(2-1)*200+50, self.tenSearchBg:getContentSize().height-subH-(i-1)*160)
            end
            guangSp:setScale(0.0001)
            guangSpTb2[k]=guangSp
        end
    end

    for k,v in pairs(spTb) do
        local time = (k-1)*0.7

         if guangSpTb[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                local reverseBy = rotateBy:reverse()
                guangSpTb[k]:runAction(CCRepeatForever:create(reverseBy))
                -- guangSpTb[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb[k]:runAction(seq)
        end


         if guangSpTb2[k] then
            local delay=CCDelayTime:create(time)
            local scaleTo1 = CCScaleTo:create(0.6,2)
            local scaleTo2 = CCScaleTo:create(0.1,1.6)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)

            local function callback()
                local rotateBy = CCRotateBy:create(4,360)
                -- local reverseBy = rotateBy:reverse()
                -- guangSpTb2[k]:runAction(CCRepeatForever:create(reverseBy))
                guangSpTb2[k]:runAction(CCRepeatForever:create(rotateBy))
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)

            local seq=CCSequence:create(acArr)
            guangSpTb2[k]:runAction(seq)
        end



        local delay=CCDelayTime:create(time)
        local scaleTo1 = CCScaleTo:create(0.3,1.2)
        local scaleTo2 = CCScaleTo:create(0.05,1)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        if k==10 then
            local function callback()
                self.isAction=true
                self.againBtn:setVisible(true)
                self.okBtn:setVisible(true)
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        v:runAction(seq)
    end

    self.guangSpTb=guangSpTb
    self.guangSpTb2=guangSpTb2
    self.spTb=spTb

    local function ok()
        self.tenSearchBg:setPosition(ccp(0,999999))
        self.tenSearchBg:setVisible(false)
        self.tenSearchBg:removeAllChildrenWithCleanup(true)

        -- self.titleBG:setPosition(ccp(0,999999))
        -- self.titleBG:setVisible(false)

        self.tenHuaBg:setPosition(ccp(0,999999))
        self.tenHuaBg:setVisible(false)
    end

    local subWidth=160
    local okItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",ok,nil,getlocal("confirm"),25,100)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum+1)*20-1)
    okBtn:setAnchorPoint(ccp(0.5,0.5))
    okBtn:setPosition(ccp(320+subWidth,50))
    self.tenSearchBg:addChild(okBtn)
    okBtn:setVisible(false)
    self.okBtn=okBtn
    local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
    okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))

    local function tenCallback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if playerVoApi:getGems()<self.lotteryTenGold then 
            GemsNotEnoughDialog(nil,nil,self.lotteryTenGold-playerVoApi:getGems(),self.layerNum+1,self.lotteryTenGold)
            do
                return
            end
        end

        local function lottery()
            local function lotteryHandler(fn,data)
                local oldHeroList=heroVoApi:getHeroList()
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.equip and sData.data.equip.report then
                        local reward = {}
                        for k,v in pairs(sData.data.equip.report) do
                            local item = FormatItem(v[1])
                            table.insert(reward,item[1])
                            G_addPlayerAward(item[1].type,item[1].key,item[1].id,item[1].num)
                        end
                        self:showTenSearch(reward)
                    end
                    local id = tonumber(heroEquipAwakeShopCfg.buyitem) or tonumber(RemoveFirstChar(heroEquipAwakeShopCfg.buyitem))
                    bagVoApi:addBag(id,10)
                    if sData and sData.data and sData.data.equip then
                        heroEquipVoApi:formatData(sData.data.equip)
                    end

                    playerVoApi:setGems(playerVoApi:getGems() - self.lotteryTenGold)

                    self:refreshVisible()
                    self:refreshScorelb()
                end
            end
            self.tenSearchBg:removeAllChildrenWithCleanup(true)
            socketHelper:equipLottery(3,nil,lotteryHandler)
        end
        G_dailyConfirm("equipLab.tenLottery",getlocal("equipLab_lotteryTip",{self.lotteryTenGold}),lottery,self.layerNum+2)
    end

    local againItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",tenCallback,nil,getlocal("heroEquip_again"),25,100)
    local againBtn=CCMenu:createWithItem(againItem)
    againBtn:setTouchPriority(-(self.layerNum+1)*20-1)
    againBtn:setAnchorPoint(ccp(0.5,0.5))
    againBtn:setPosition(ccp(320-subWidth,50))
    self.tenSearchBg:addChild(againBtn)
    againBtn:setVisible(false)
    self.againBtn=againBtn
    local againLabel = tolua.cast(againItem:getChildByTag(100),"CCLabelTTF")
    againLabel:setPosition(ccp(againItem:getContentSize().width/2,againItem:getContentSize().height/2 + 5))

    local moneyNode = CCNode:create()

    local goldIconSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIconSp2:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldIconSp2)

    local goldLb2 = GetTTFLabel(self.lotteryTenGold,22)
    goldLb2:setAnchorPoint(ccp(0,0.5))
    moneyNode:addChild(goldLb2)

    local moneyLabelWidth = goldIconSp2:getContentSize().width + goldLb2:getContentSize().width
    moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldLb2:getContentSize().height))
    goldIconSp2:setPosition(ccp(0,moneyNode:getContentSize().height/2))
    goldLb2:setPosition(ccp(goldIconSp2:getContentSize().width,moneyNode:getContentSize().height/2))

    moneyNode:setPosition(ccp((againItem:getContentSize().width - moneyLabelWidth)/2,againItem:getContentSize().height+10))
    moneyNode:setAnchorPoint(ccp(0,0.5))
    againItem:addChild(moneyNode)


    if G_isIphone5()==true then
        okBtn:setPosition(ccp(320+subWidth,150))
        againBtn:setPosition(ccp(320-subWidth,150))
    end

end

function heroEquipLabDialog:showOneSearch(type,item,layerNum,heroIsExist,addSoulNum,callback,newProductOrder,score,scenePic)
    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,layerNum)
    end
    

    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)

    local function callback()
     
    end
    local diPic = "story/CheckpointBg.jpg"
    if scenePic then
        diPic = scenePic
    end
    local sceneSp=LuaCCSprite:createWithFileName(diPic,callback)
    sceneSp:setAnchorPoint(ccp(0,0))
    sceneSp:setPosition(ccp(0,0))
    sceneSp:setTouchPriority(-(layerNum)*20-1)
    self.myLayer:addChild(sceneSp)
    sceneSp:setColor(ccc3(150, 150, 150))
    if G_isIphone5()==true then
        sceneSp:setScaleY(1.2)
    end

    if scenePic then
        sceneSp:setScaleY(G_VisibleSizeHeight/sceneSp:getContentSize().height)
        sceneSp:setScaleX(G_VisibleSizeWidth/sceneSp:getContentSize().width)
    end



    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/1.plist")
        particleS:setScale(1)
        particleS.positionType=kCCPositionTypeFree
        particleS:setPosition(ccp(320,G_VisibleSizeHeight/2+100))
        layer:addChild(particleS,10)
    end
    local function callback2()
        local mIcon
        if item.type=="h" then
            if item.eType=="h" then
                mIcon=heroVoApi:getHeroIcon(item.key,item.num,nil,nil,nil,nil,nil,{adjutants={}})
            else
                mIcon=heroVoApi:getHeroIcon(item.key,1,false)
            end
        else
            mIcon=G_getItemIcon(item,100,false,layerNum)
        end
        if mIcon then
            local function callback3()
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                -- local lightSp = CCSprite:createWithSpriteFrameName("BgSelect.png")
                lightSp:setAnchorPoint(ccp(0.5,0.5))
                lightSp:setPosition(ccp(320+7,G_VisibleSizeHeight/2+100))
                layer:addChild(lightSp,10)
                lightSp:setScale(2)

                local descStr=""
                local nameStr=item.name or ""
                if item.type=="h" and item.eType=="h" then
                else
                    nameStr=nameStr.."x"..item.num
                end
                if type==1 then
                    descStr=getlocal("getNewHeroDesc")
                elseif type==2 then
                    descStr=getlocal("getNewSoulDesc")
                elseif type==4 then
                    local propKey = heroEquipAwakeShopCfg.buyitem
                    local name,pic,desc=getItem(propKey,"p")
                    descStr=getlocal("equip_getReward",{name .. "*" .. 1})
                else
                    descStr=getlocal("getNewPropDesc")
                end
                local lb=GetTTFLabelWrap(descStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                lb:setPosition(ccp(320,G_VisibleSizeHeight-150))
                lb:setColor(G_ColorYellowPro)
                layer:addChild(lb,11)

                local nameLb=GetTTFLabelWrap(nameStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                nameLb:setPosition(ccp(320,G_VisibleSizeHeight/2-80))
                nameLb:setColor(G_ColorYellowPro)
                layer:addChild(nameLb,11)

                if addSoulNum and addSoulNum>0 then
                    local hid
                    if item.type=="h" then
                        if item.eType=="h" then
                            hid=item.key
                        elseif item.eType=="s" then
                            hid=heroCfg.soul2hero[item.key]
                        end
                    end
                    local existStr=""
                    if hid and heroVoApi:getIsHonored(hid)==true and heroVoApi:heroHonorIsOpen()==true then
                        existStr=getlocal("hero_honor_recruit_honored_hero",{addSoulNum})
                    elseif type==1 and heroIsExist==true then
                        if newProductOrder then
                            existStr=getlocal("hero_breakthrough_desc",{newProductOrder})
                        else
                            existStr=getlocal("alreadyHasDesc",{addSoulNum})
                        end
                    end
                    if existStr and existStr~="" then
                        local existLb=GetTTFLabelWrap(existStr,25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        existLb:setPosition(ccp(320,300))
                        existLb:setColor(G_ColorYellowPro)
                        layer:addChild(existLb,11)
                    end
                end
                if score and score~="" then
                        local scoreLb=GetTTFLabelWrap(getlocal("serverwar_get_point")..score,28,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        scoreLb:setPosition(ccp(320,350))
                        scoreLb:setColor(G_ColorYellowPro)
                        layer:addChild(scoreLb,777)
                end
                local function ok( ... )
                    self.myLayer:removeFromParentAndCleanup(true)
                    self.freeLb1=nil

                    self.propSp1=nil
                    self.propNumLb1=nil

                    self.goldSp1=nil
                    self.goldNumLb1=nil
                    self.myLayer=nil
                    if callback then
                        callback()
                    end
                end

                local subWidth=160
                local okItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",ok,nil,getlocal("confirm"),25,100)
                local okBtn=CCMenu:createWithItem(okItem)
                okBtn:setTouchPriority(-(layerNum)*20-2)
                okBtn:setAnchorPoint(ccp(1,0.5))
                okBtn:setPosition(ccp(320+subWidth,150))
                layer:addChild(okBtn,11)
                local okLabel = tolua.cast(okItem:getChildByTag(100),"CCLabelTTF")
                okLabel:setPosition(ccp(okItem:getContentSize().width/2,okItem:getContentSize().height/2 + 5))

                local lotteryGold = heroEquipAwakeShopCfg.payTicketCost
                local function oneCallback()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end


                    local prop_pid = heroEquipAwakeShopCfg.payitem
                    local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))
                    local pid = nil
                    if bagVoApi:getItemNumId(id)>0 then
                        pid=1
                    end
                    local flag = heroEquipVoApi:checkIfHasFreeLottery()
                    local function lotteryHandler(fn,data)
                        local oldHeroList=heroVoApi:getHeroList()
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.equip and sData.data.equip.report then
                                self:showHero(sData.data.equip.report[1][1],oldHeroList)
                            end
                            local getid = tonumber(heroEquipAwakeShopCfg.buyitem) or tonumber(RemoveFirstChar(heroEquipAwakeShopCfg.buyitem))
                            
                            if sData and sData.data and sData.data.equip then
                                heroEquipVoApi:formatData(sData.data.equip)
                            end
               
                            if flag==true then
                                self.isToday=true
                            elseif pid==nil then
                                playerVoApi:setGems(playerVoApi:getGems() - lotteryGold)
                            else
                                bagVoApi:useItemNumId(id,1)

                            end
                            bagVoApi:addBag(getid,1)
             
                            self:refreshVisible()
                            self:refreshScorelb()

                        end
                    end
                    if flag==true then
                        layer:removeFromParentAndCleanup(true)
                        self.freeLb1=nil

                        self.propSp1=nil
                        self.propNumLb1=nil

                        self.goldSp1=nil
                        self.goldNumLb1=nil
                        socketHelper:equipLottery(1,nil,lotteryHandler)
                    else
                        if pid==nil then
                            
                            if playerVoApi:getGems()<lotteryGold then 
                                GemsNotEnoughDialog(nil,nil,lotteryGold-playerVoApi:getGems(),layerNum+1,lotteryGold)
                                do
                                    return
                                end
                            end
                            local function lottery()
                                layer:removeFromParentAndCleanup(true)
                                self.freeLb1=nil

                                self.propSp1=nil
                                self.propNumLb1=nil

                                self.goldSp1=nil
                                self.goldNumLb1=nil
                                socketHelper:equipLottery(2,nil,lotteryHandler)
                            end
                            G_dailyConfirm("equipLab.oneLottery",getlocal("equipLab_lotteryTip",{lotteryGold}),lottery,self.layerNum+2)
                        else
                            layer:removeFromParentAndCleanup(true)
                            self.freeLb1=nil

                            self.propSp1=nil
                            self.propNumLb1=nil

                            self.goldSp1=nil
                            self.goldNumLb1=nil
                            socketHelper:equipLottery(2,pid,lotteryHandler)
                        end
                        
                    end
                end

                local againItem=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn_Down.png",oneCallback,nil,getlocal("heroEquip_again"),25,100)
                local againBtn=CCMenu:createWithItem(againItem)
                againBtn:setTouchPriority(-(self.layerNum+1)*20-2)
                againBtn:setAnchorPoint(ccp(0.5,0.5))
                againBtn:setPosition(ccp(320-subWidth,150))
                layer:addChild(againBtn,11)
                local againLabel = tolua.cast(againItem:getChildByTag(100),"CCLabelTTF")
                againLabel:setPosition(ccp(againItem:getContentSize().width/2,againItem:getContentSize().height/2 + 5))

                local height=againItem:getContentSize().height+10
                local freeLb = GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),22,CCSizeMake(120, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                freeLb:setAnchorPoint(ccp(0.5,0.5))
                againItem:addChild(freeLb)
                freeLb:setPosition(ccp(againItem:getContentSize().width-140,height))
                self.freeLb1=freeLb


                local propSp=CCSprite:createWithSpriteFrameName("icon_equip_lab.png")
                propSp:setPosition(ccp(againItem:getContentSize().width-150,height))
                againItem:addChild(propSp)
                propSp:setScale(0.4)
                self.propSp1=propSp

                local prop_pid = heroEquipAwakeShopCfg.payitem
                local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))

                local propStr = "1" .. "/" .. bagVoApi:getItemNumId(id)
                local propNumLb = GetTTFLabelWrap(propStr,22,CCSizeMake(80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                propNumLb:setAnchorPoint(ccp(0,0.5))
                againItem:addChild(propNumLb)
                propNumLb:setPosition(ccp(propSp:getPositionX()+propSp:getContentSize().width*0.4/2,propSp:getPositionY()))
                self.propNumLb1=propNumLb

                local moneyNode = CCNode:create()

                local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
                goldSp:setAnchorPoint(ccp(0,0.5))
                moneyNode:addChild(goldSp)
                self.goldSp1=goldSp

                local goldNumLb = GetTTFLabel(lotteryGold,22)
                goldNumLb:setAnchorPoint(ccp(0,0.5))
                moneyNode:addChild(goldNumLb)
                self.goldNumLb1=goldNumLb

                local moneyLabelWidth = goldSp:getContentSize().width + goldNumLb:getContentSize().width
                moneyNode:setContentSize(CCSizeMake(moneyLabelWidth,goldNumLb:getContentSize().height))
                goldSp:setPosition(ccp(0,moneyNode:getContentSize().height/2))
                goldNumLb:setPosition(ccp(goldSp:getContentSize().width,moneyNode:getContentSize().height/2))

                moneyNode:setPosition(ccp((againItem:getContentSize().width - moneyLabelWidth)/2,againItem:getContentSize().height+10))
                moneyNode:setAnchorPoint(ccp(0,0.5))
                againItem:addChild(moneyNode)

                self:refreshVisible2()
            end
            mIcon:setScale(0)
            mIcon:setPosition(ccp(320,G_VisibleSizeHeight/2+100))
            layer:addChild(mIcon,11)
            local ccScaleTo = CCScaleTo:create(0.6,150/mIcon:getContentSize().width)
            local ccScaleTo1 = CCScaleTo:create(0.1,(150+100)/mIcon:getContentSize().width)
            local ccScaleTo2 = CCScaleTo:create(0.1,150/mIcon:getContentSize().width)
            local callFunc3=CCCallFunc:create(callback3)
            local acArr=CCArray:create()
            acArr:addObject(ccScaleTo)
            acArr:addObject(ccScaleTo1)
            acArr:addObject(ccScaleTo2)
            acArr:addObject(callFunc3)
            local seq=CCSequence:create(acArr)
            mIcon:runAction(seq)
        end
    end
    local callFunc1=CCCallFunc:create(callback1)
    local callFunc2=CCCallFunc:create(callback2)

    local delay=CCDelayTime:create(0.2)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc1)
    acArr:addObject(callFunc2)
    local seq=CCSequence:create(acArr)
    sceneSp:runAction(seq)
end

function heroEquipLabDialog:refreshVisible2()

    local prop_pid = heroEquipAwakeShopCfg.payitem
    local id = tonumber(prop_pid) or tonumber(RemoveFirstChar(prop_pid))

    if self.freeLb1==nil or self.propSp1==nil or self.propNumLb1==nil or self.goldSp1==nil or self.goldNumLb1==nil then
        return
    end

    if heroEquipVoApi:checkIfHasFreeLottery()==true then
        self.freeLb1:setVisible(true)

        self.propSp1:setVisible(false)
        self.propNumLb1:setVisible(false)

        self.goldSp1:setVisible(false)
        self.goldNumLb1:setVisible(false)

    elseif bagVoApi:getItemNumId(id)>0 then
        self.freeLb1:setVisible(false)

        self.propSp1:setVisible(true)
        self.propNumLb1:setVisible(true)

        self.goldSp1:setVisible(false)
        self.goldNumLb1:setVisible(false)

        local propStr = "1" .. "/" .. bagVoApi:getItemNumId(id)
        self.propNumLb1:setString(propStr)
    else
        self.freeLb1:setVisible(false)

        self.propSp1:setVisible(false)
        self.propNumLb1:setVisible(false)

        self.goldSp1:setVisible(true)
        self.goldNumLb1:setVisible(true)

    end

end

function heroEquipLabDialog:isAddHuangguang(key)
    for k,v in pairs(self.reward) do
        if v.key==key then
            return true
        end
    end
    return false
end

function heroEquipLabDialog:dispose( ... )
    self.tv = nil
    self.scoreLb = nil
    if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.tenHuaBg=nil
    self.tenSearchBg=nil
    --self.titleBG=nil
    --self.titlb=nil

    if self.eventCallback then
        self.eventCallback()
        self.eventCallback = nil
    end

    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acDiancitanke.plist")
	
end