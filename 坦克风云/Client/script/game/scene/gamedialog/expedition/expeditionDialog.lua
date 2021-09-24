--require "luascript/script/componet/commonDialog"
expeditionDialog = {
    
}

function expeditionDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.expandIdx = {}
    self.layerNum = nil
    self.dialogLayer = nil
    self.bgLayer = nil
    self.closeBtn = nil
    self.bgSize = nil
    self.tv = nil
    self.expandHeight = 1800
    self.normalHeight = 150
    self.extendSpTag = 113
    self.timeLbTab = {}
    self.isCloseing = false
    self.buffTab = {}
    self.xinAn = {}
    self.xinLiang = {}
    self.raidType = 1
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("serverWar/serverWar2.plist")
    spriteController:addPlist("public/expedition_newUI.plist")
    spriteController:addTexture("public/expedition_newUI.png")
    spriteController:addPlist("scene/world_map_mi_new.plist")
    spriteController:addTexture("scene/world_map_mi_new.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/world_map_mi_new.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    --CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/kuangnuImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    if platCfg.platCfgNewWayAddTankImage then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/newTankImage/t16newImage.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/newTankImage/t5newImage.plist")
    end
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    
    return nc
end

function expeditionDialog:init(layerNum)
    self.layerNum = layerNum
    base:setWait()
    
    spriteController:addPlist("public/expeditionRevive.plist")
    spriteController:addTexture("public/expeditionRevive.png")
    local size = CCSizeMake(640, G_VisibleSize.height)
    
    self.isTouch = false
    self.isUseAmi = true
    if layerNum then
        self.layerNum = layerNum
    else
        self.layerNum = 4
    end
    local rect = size
    local function touchHander()
        
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png", CCRect(144, 53, 1, 1), touchHander)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    
    local function touchDialog()
        
    end
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, nil, nil, nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
    
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.closeBtn:setPosition(ccp(rect.width - closeBtnItem:getContentSize().width, rect.height - closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn, 10)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png", CCRect(168, 86, 10, 10), touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, 960)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg, 1);
    
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    
    self:initTableView()
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width / 2, -self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer, self.layerNum)
    
    local bgSp1 = CCSprite:createWithSpriteFrameName("expedition_up_new.png")
    bgSp1:setAnchorPoint(ccp(0.5, 1))
    bgSp1:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(bgSp1, 2)
    
    local bgSp2 = CCSprite:createWithSpriteFrameName("expedition_up_new.png")
    bgSp2:setFlipY(true)
    bgSp2:setAnchorPoint(ccp(0.5, 0))
    bgSp2:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 0))
    self.bgLayer:addChild(bgSp2, 2)

    local bgSp2_light = CCSprite:createWithSpriteFrameName("expedition_bottom.png")
    bgSp2_light:setAnchorPoint(ccp(0.5,0))
    bgSp2_light:setPosition(ccp(bgSp2:getContentSize().width/2,0))
    self.bgLayer:addChild(bgSp2_light, 2)

    
    
    local bgTitleSp = LuaCCScale9Sprite:createWithSpriteFrameName("expeditionTitle_Bg.png", CCRect(25, 25, 1, 1),  function () end)
    bgTitleSp:setContentSize(CCSizeMake(300,60))
    bgTitleSp:setAnchorPoint(ccp(0.5, 1))
    bgTitleSp:setPosition(ccp(self.bgLayer:getContentSize().width / 2, G_VisibleSizeHeight - bgSp1:getContentSize().height+15))
    self.bgLayer:addChild(bgTitleSp, 6)
    
    local lbSize = 40
    if G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "de" then
        lbSize = 25
    end
    local titleLb = GetTTFLabel(getlocal("expedition"), 24, true)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - 25))
    self.bgLayer:addChild(titleLb, 7)
    
    -- local function touchLuaSpr()
        
    -- end
    -- local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    -- touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 3)
    -- local rect = CCSizeMake(640, 100)
    -- touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    -- touchDialogBg:setAnchorPoint(ccp(0.5, 0))
    -- touchDialogBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 0))
    -- touchDialogBg:setIsSallow(true)
    -- self.bgLayer:addChild(touchDialogBg, 2)
    
    self:show()
    
    local btnScale, priority = 1, -(self.layerNum - 1) * 20 - 4
    local function revive()
        local function touch()
            local flag = expeditionVoApi:isCanRevive()
            if flag ~= 1 then
                do return end
            end
            expeditionVoApi:showReviveHeroDialog(self.layerNum + 1)
        end
        G_touchedItem(self.reviveItem, touch, 0.7)
    end
    self.reviveItem, self.reviveMenu = G_createBotton(self.bgLayer, ccp(80, G_VisibleSizeHeight - 130), {}, "heroReviveBtn.png", "heroReviveBtn.png", "heroReviveBtn.png", revive, btnScale, priority, 1)
    
    self.rlightSp1, self.rlightSp2 = G_playShineEffect(self.bgLayer, ccp(self.reviveMenu:getPosition()), 1)
    
    --刷新复活功能
    local function refreshReviveHandler(event, data)
        if self.reviveItem == nil or self.reviveMenu == nil or self.rlightSp1 == nil or self.rlightSp2 == nil then
            do return end
        end
        local flag = expeditionVoApi:isCanRevive()
        if flag ~= 1 then
            self.reviveItem:setEnabled(false)
            self.reviveMenu:setVisible(false)
            self.rlightSp1:setVisible(false)
            self.rlightSp2:setVisible(false)
        else
            self.reviveItem:setEnabled(true)
            self.reviveMenu:setVisible(true)
            self.rlightSp1:setVisible(true)
            self.rlightSp2:setVisible(true)
        end
    end
    self.reviveRefreshListener = refreshReviveHandler
    eventDispatcher:addEventListener("expedition.reviveRefresh", refreshReviveHandler)
    
    refreshReviveHandler()

    self:showAdditionalGift()


    self.overDayEventListener = function()
        self:refresh()
    end
    if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
        eventDispatcher:addEventListener("overADay", self.overDayEventListener)
    end

end

function expeditionDialog:showAdditionalGift( ... )
    if self.node then
        self.node:removeFromParentAndCleanup(true)
        self.node=nil
    end
    local function touchHander()
        
    end
    local size = CCSizeMake(640, G_VisibleSize.height)
    self.node = CCNode:create()
    self.node:setContentSize(size)
    -- self.node:setAnchorPoint(ccp(0,0))
    self.node:setPosition(ccp(0,0))
    self.bgLayer:addChild(self.node,6)

    local bgSp2_title = GetTTFLabel(getlocal("expeditionAlready",{expeditionVoApi:getVictoryNum()}),24)
    bgSp2_title:setAnchorPoint(ccp(0.5,0.5))
    bgSp2_title:setPosition(ccp(G_VisibleSizeWidth/2 , 30))
    bgSp2_title:setColor(G_ColorGreen)
    self.node:addChild(bgSp2_title,3)

    local boxNum = expeditionVoApi:boxCfg( )
    local nameStr,boxImage,boxBtn,haveReward,numBg,iconHeight
    local heightScale = expeditionVoApi:expeditionSchedule( )
    local nameStrTb = {
        "allianceGift03.png",
        "allianceGift04.png",
        "allianceGift06.png",
    }
    for i=1,boxNum do
        local boxState = expeditionVoApi:ifCanReward(i)
        local boxRealNum = expeditionVoApi:boxStage( i )
        local showTb = FormatItem(expeditionVoApi:boxCfg(boxRealNum),nil,true)
        showTb[1].num = math.floor(showTb[1].num*expeditionVoApi:getGrade()^0.4)
        local titleStr1 = getlocal("expeditionBoxTitle")
        local titleStr2 = getlocal("expeditionBox_info",{boxRealNum})
        nameStr = nameStrTb[i]
        -- print("i,nameStr=====>",i,nameStr)
        if boxState == 1  then --不可领取
            local function bukelingqu(  )
                -- require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                -- rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,showTb,function () end,titleStr,nil,nil,nil,"yzbx")

                -- require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
                -- local needTb = {"yzbx",titleStr,nil,showTb,boxNum}
                -- local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
                -- sd:init()

                require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
                local sd=acChunjiepanshengSmallDialog:new()
                sd:init(true,true,self.layerNum+1,titleStr1,nil,CCSizeMake(500,500),CCRect(130, 50, 1, 1),showTb,nil,nil,nil,true,"yzbx",titleStr2)
            end
            boxImage = GetButtonItem(nameStr, nameStr, nameStr, bukelingqu, nil, nil,1, 101)
            boxBtn = CCMenu:createWithItem(boxImage)
            
            boxBtn:setAnchorPoint(ccp(0.5,0.5))
            boxBtn:setPosition(ccp(G_VisibleSizeWidth-boxImage:getContentSize().width/2-100 , (boxImage:getContentSize().height/3*4)*i-90))
            boxBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            self.node:addChild(boxBtn)

            boxBtn:setScale(0.8)
        elseif boxState == 2 then  --可领取
            local function kelingqu( ... )
                local function refreshFunc(showTb)
                    -- 此处加弹板
                    if showTb then
                        G_showRewardTip(showTb, true)
                    end
                    self:refresh()
                end
                -- 兑换逻辑
                expeditionVoApi:socketExpedition(boxRealNum,showTb,refreshFunc)
            end
            boxImage = GetButtonItem(nameStr, nameStr, nameStr, kelingqu, nil, nil,1, 101)
            boxBtn = CCMenu:createWithItem(boxImage)
            boxBtn:setAnchorPoint(ccp(0.5,0.5))
            boxBtn:setPosition(ccp(G_VisibleSizeWidth-boxImage:getContentSize().width/2-100 , (boxImage:getContentSize().height/3*4)*i-90))
            boxBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            boxBtn:setScale(0.8)
            self.node:addChild(boxBtn)

            local rewardCenterBtnBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            rewardCenterBtnBg:setScale(0.8)
            rewardCenterBtnBg:setOpacity(0)
            rewardCenterBtnBg:setAnchorPoint(ccp(0.5,0.5))
            self.node:addChild(rewardCenterBtnBg,-1)
            rewardCenterBtnBg:setPosition(ccp(G_VisibleSizeWidth-boxImage:getContentSize().width/2-38 , (boxImage:getContentSize().height/3*4)*i+23))
            for i=1,2 do
              local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
              realLight:setAnchorPoint(ccp(0.5,0.5))
              realLight:setScale(0.8)
              realLight:setPosition(getCenterPoint(rewardCenterBtnBg))
              rewardCenterBtnBg:addChild(realLight)  
              local roteSize = i ==1 and 360 or -360
              local rotate1=CCRotateBy:create(4, roteSize)
              local repeatForever = CCRepeatForever:create(rotate1)
              realLight:runAction(repeatForever)
            end

            self:awardBoxAction(boxImage,true)
            -- rewardCenterBtnBg:setVisible(false)
        elseif boxState == 3 then  --已领取
            boxImage = GraySprite:createWithSpriteFrameName(nameStr)
            boxImage:setAnchorPoint(ccp(0.5,0.5))
            boxImage:setPosition(ccp(G_VisibleSizeWidth-boxImage:getContentSize().width/2-37 , (boxImage:getContentSize().height/3*4)*i+24))
            

            haveReward = CCSprite:createWithSpriteFrameName("IconCheck.png")
            haveReward:setScale(0.8)
            haveReward:setAnchorPoint(ccp(0.5,0.5))
            haveReward:setPosition(getCenterPoint(boxImage))
            self.node:addChild(boxImage)
            boxImage:addChild(haveReward,2)

            local haveRewardBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png");
            haveRewardBg:setAnchorPoint(ccp(0.5,0.5))
            haveRewardBg:setOpacity(0.7*255)
            haveRewardBg:setScaleX( (haveReward:getContentSize().width+10) / haveRewardBg:getContentSize().width)
            haveRewardBg:setScaleY((haveReward:getContentSize().height+2) / haveRewardBg:getContentSize().height)
            haveRewardBg:setPosition(getCenterPoint(boxImage))
            boxImage:addChild(haveRewardBg,1)

            boxImage:setScale(0.8)
        end
        
        iconHeight=boxImage:getContentSize().height/3*4
        numBg = CCSprite:createWithSpriteFrameName("expeditionNumBg.png")
        numBg:setScale(1.3)
        numBg:setAnchorPoint(ccp(0.5,0.5))
        numBg:setPosition(ccp(G_VisibleSizeWidth-numBg:getContentSize().width/2-15,20+iconHeight*i))
        self.node:addChild(numBg,7)

        local numLb = GetTTFLabel(boxRealNum,12,true)
        numLb:setAnchorPoint(ccp(0.5,0.5))
        numLb:setPosition(getCenterPoint(numBg))
        numBg:addChild(numLb)

    end
    --右边进度条
    local expeditionschedule_Bg = LuaCCScale9Sprite:createWithSpriteFrameName("expedition_schedule_Bg.png",CCRect(7, 7, 1, 1), function ()end)
    expeditionschedule_Bg:setContentSize(CCSizeMake(14,iconHeight*(boxNum-1)))
    expeditionschedule_Bg:setAnchorPoint(ccp(0.5,1))
    expeditionschedule_Bg:setPosition(ccp(numBg:getPositionX(),numBg:getPositionY()))
    self.node:addChild(expeditionschedule_Bg,5)

    local expedition_schedule = LuaCCScale9Sprite:createWithSpriteFrameName("expedition_schedule.png",CCRect(7, 7, 1, 1), function ()end)
    expedition_schedule:setContentSize(CCSizeMake(18,(iconHeight*(boxNum-1)*heightScale)))
    expedition_schedule:setAnchorPoint(ccp(0.5,0))
    expedition_schedule:setPosition(ccp(expeditionschedule_Bg:getPositionX(),expeditionschedule_Bg:getPositionY()-expeditionschedule_Bg:getContentSize().height))
    self.node:addChild(expedition_schedule,6)
end

function expeditionDialog:awardBoxAction( awardBox,isAction )
    if isAction then
        local time = 0.14
        local rotate1=CCRotateTo:create(time, 20)
        local rotate2=CCRotateTo:create(time, -20)
        local rotate3=CCRotateTo:create(time, 10)
        local rotate4=CCRotateTo:create(time, -10)
        local rotate5=CCRotateTo:create(time, 0)

        local delay=CCDelayTime:create(1)
        local acArr=CCArray:create()
        acArr:addObject(rotate1)
        acArr:addObject(rotate2)
        acArr:addObject(rotate3)
        acArr:addObject(rotate4)
        acArr:addObject(rotate5)
        acArr:addObject(delay)
        local seq=CCSequence:create(acArr)
        local repeatForever=CCRepeatForever:create(seq)
        awardBox:runAction(repeatForever)
    else
        awardBox:stopAllActions()
        awardBox:setRotation(0)
    end
end

function expeditionDialog:setDisplay(bool)
    
    if bool == true then
        self.bgLayer:setVisible(true)
    else
        self.bgLayer:setVisible(false)
    end
    
end

--设置对话框里的tableView
function expeditionDialog:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width, self.bgLayer:getContentSize().height), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.tv:setPosition(ccp(0, 0))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(0)
    base:addNeedRefresh(self)
    
    local strSize2 = 24
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "tw" then
        strSize2 = 28
    end
    local function showInfo()
        local tabStr = {}
        for k = 1, 6 do
            table.insert(tabStr, getlocal("expeditionInfo"..k))
        end
        if base.ea == 1 then
            for k = 7, 15 do
                local args = {}
                if k == 8 then
                    args = {expeditionCfg.acount or 3}
                elseif k == 11 then
                    args = {expeditionCfg.startRevive, expeditionCfg.reviveCount}
                elseif k == 15 then
                    args = {expeditionVoApi:getGradeDown( )}
                elseif k == 10 then
                    args = {expeditionCfg.resetRatio*100}
                end
                table.insert(tabStr, getlocal("expeditionInfo"..k, args))
            end
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr)
    end
    
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo, 11, nil, nil)
    infoItem:setAnchorPoint(ccp(1, 1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoItem:setScale(0.7)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setPosition(ccp(55, G_VisibleSizeHeight - 25))
    infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(infoBtn, 3)
    
    local btnScale = 0.8
    local function goShop()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        -- local function reCallback(fn,data)
        --     local ret,sData=base:checkServerData(data)
        --     if ret==true then
        -- require "luascript/script/game/scene/gamedialog/expedition/expeditionShopDialog"
        -- local dialog=expeditionShopDialog:new()
        -- local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("expeditionShop"),true,self.layerNum+1)
        
        -- sceneGame:addChild(layer,self.layerNum+1)
        -- print("self.layerNum + 1=====>>>>",self.layerNum + 1)
        local td = allShopVoApi:showAllPropDialog(self.layerNum + 1, "expe")
        --     end
        -- end
        
        -- socketHelper:expeditionGetshop(reCallback)
        
    end
    local shopItem = GetButtonItem("expeditionShop.png", "expeditionShop_down.png", "expeditionShop.png", goShop, nil, nil, 24 / btnScale, 101)
    -- shopItem:setScale(btnScale)
    -- local btnLb = shopItem:getChildByTag(101)
    -- if btnLb then
    --     btnLbL = tolua.cast(btnLb, "CCLabelTTF")
    --     btnLb:setFontName("Helvetica-bold")
    -- end
    local shopBtn = CCMenu:createWithItem(shopItem)
    shopBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    shopBtn:setAnchorPoint(ccp(1, 0.5))
    shopBtn:setPosition(ccp(80, 40))
    self.bgLayer:addChild(shopBtn, 5)
    
    local function fightRecord()
        require "luascript/script/game/scene/gamedialog/expedition/expeditionReportDialog"
        local dialog = expeditionReportDialog:new()
        local layer = dialog:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("arena_fightRecord"), true, self.layerNum + 1)
        sceneGame:addChild(layer, self.layerNum + 1)
    end
    local fightRecordItem = GetButtonItem("bless_record.png", "bless_record.png", "bless_record.png", fightRecord, nil, nil, 24 / btnScale, 101)
    fightRecordItem:setScale(0.7)
    -- local btnLb = fightRecordItem:getChildByTag(101)
    -- if btnLb then
    --     btnLb = tolua.cast(btnLb, "CCLabelTTF")
    --     btnLb:setFontName("Helvetica-bold")
    -- end
    local fightRecordBtn = CCMenu:createWithItem(fightRecordItem)
    fightRecordBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    fightRecordBtn:setAnchorPoint(ccp(1, 0.5))
    fightRecordBtn:setPosition(ccp(G_VisibleSizeWidth-50, G_VisibleSizeHeight-130))
    self.bgLayer:addChild(fightRecordBtn, 5)

    local fightRecordBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png");
    fightRecordBg:setAnchorPoint(ccp(0.5,0.5))
    fightRecordBg:setOpacity(0.5*255)
    fightRecordBg:setPosition(ccp(fightRecordBtn:getPositionX(), fightRecordBtn:getPositionY()-fightRecordItem:getContentSize().height/2))
    self.bgLayer:addChild(fightRecordBg,5)

    local fightRecordFontSize = 20
    if G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "it" or G_getCurChoseLanguage() == "ar" then
        fightRecordFontSize = 16
    end

    local fightRecordTitle = GetTTFLabel(getlocal("arena_fightRecord"),fightRecordFontSize)
    fightRecordTitle:setAnchorPoint(ccp(0.5,0.5))
    fightRecordTitle:setPosition(getCenterPoint(fightRecordBg))
    fightRecordBg:addChild(fightRecordTitle)
    fightRecordBg:setScaleX((fightRecordTitle:getContentSize().width+10)/fightRecordBg:getContentSize().width)
    fightRecordBg:setScaleY((fightRecordTitle:getContentSize().height+5)/fightRecordBg:getContentSize().height)

    
    local function signAgainBtn()
        local acount = expeditionVoApi:getAcount() or 0
        if expeditionVoApi:getWin() == false and acount >= expeditionCfg.acount then
            G_showTipsDialog(getlocal("expedition_reset_notip"))
            do return end
        end
        local function onConfirm(flag)
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("expeditionRestartSuccess"), 30)
                    self:refresh()
                end
            end
            socketHelper:expeditionReset(callback,flag or 0)
        end

        if expeditionVoApi:getFailNum() >= (expeditionVoApi:getFailTimeCfg()-1)  and expeditionVoApi:getWin() == false then
            -- smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("expeditionFailGradeSure"), nil, self.layerNum + 1)
            local contentStr = getlocal("expeditionHaveTroopsSure")
            if expeditionVoApi:isAllReward() == false then
                contentStr = getlocal("expeditionNoRewardSure")
            elseif expeditionVoApi:isHaveLeftTanks() == false then
                contentStr = getlocal("expeditionFailureSure")
            end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),contentStr,true,nil,onConfirm,nil,nil,nil,nil,nil,nil,nil,nil,getlocal("expeditionFailGradeCheck"),getlocal("expeditionFailGradeSure",{expeditionVoApi:getFailTimeCfg(),expeditionVoApi:getGradeDown()}))
            do return end
        end
        
        if expeditionVoApi:isAllReward() == false then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("expeditionNoRewardSure"), nil, self.layerNum + 1)
            do return end

        end
        
        if expeditionVoApi:isHaveLeftTanks() and expeditionVoApi:getWin() == false then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("expeditionHaveTroopsSure"), nil, self.layerNum + 1)
            do return end

        end
        
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("expeditionRestart"), nil, self.layerNum + 1)
    end
    self.signAgainItem = GetButtonItem("expeditionSignAgain.png", "expeditionSignAgain_down.png", "expeditionSignAgain.png", signAgainBtn, nil, nil, 24 / btnScale, 101)
    -- self.signAgainItem:setScale(btnScale)
    -- local btnLb = self.signAgainItem:getChildByTag(101)
    -- if btnLb then
    --     btnLb = tolua.cast(btnLb, "CCLabelTTF")
    --     btnLb:setFontName("Helvetica-bold")
    -- end
    local signAgainBtn = CCMenu:createWithItem(self.signAgainItem)
    signAgainBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    signAgainBtn:setAnchorPoint(ccp(1, 0.5))
    signAgainBtn:setPosition(ccp(G_VisibleSizeWidth-80, 40))
    self.bgLayer:addChild(signAgainBtn, 5)
    self.signAgainBtn = signAgainBtn
    
    if expeditionVoApi:getLeftNum() <= 0 then
        self.signAgainItem:setEnabled(false)
    end
    
    if base.ea == 1 then
        -- 新增加的扫荡  需修改
        local function raid()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function reCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    self.raidType = 2
                    self:initLoading(sData.data.report)
                    -- self:refresh()
                end
            end
            
            -- local acount = expeditionVoApi:getAcount() or 0
            -- if acount>=expeditionCfg.acount then
            socketHelper:expeditionRaid(reCallback)
            -- else
            -- end
        end
        local raidItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", raid, nil, getlocal("elite_challenge_raid_btn"), 24 / btnScale, 101)
        raidItem:setScale(btnScale)
        local btnLb = raidItem:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb, "CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local raidBtn = CCMenu:createWithItem(raidItem)
        raidBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        raidBtn:setAnchorPoint(ccp(0.5, 0))
        raidBtn:setPosition(ccp(G_VisibleSizeWidth/2, 100))
        self.bgLayer:addChild(raidBtn, 6)
        self.raidBtn = raidBtn
        
        -- local scale = 50/80
        -- local function nilFunc(hd,fn,idx)
        -- end
        -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 80))
        -- backSprie:ignoreAnchorPointForPosition(false)
        -- backSprie:setAnchorPoint(ccp(0.5,0))
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        -- backSprie:setPosition(ccp((self.bgLayer:getContentSize().width)/2,100))
        -- self.bgLayer:addChild(backSprie,5)
        -- backSprie:setScaleY(scale)
        
        -- local dengjieLb=GetTTFLabelWrap(getlocal("expendition_dengjie",{expeditionVoApi:getGrade()}),25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- dengjieLb:setAnchorPoint(ccp(0,0.5))
        -- dengjieLb:setPosition(ccp(10,backSprie:getContentSize().height/2))
        -- backSprie:addChild(dengjieLb)
        -- dengjieLb:setScaleY(1/scale)
        -- self.dengjieLb=dengjieLb
        
        local lbBgWidth, lbBgHeight = 500, 50
        local function touchLuaSpr()
            
        end
        -- local lbBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
        -- lbBg:setScaleX(lbBgWidth / lbBg:getContentSize().width)
        -- lbBg:setScaleY(lbBgHeight / lbBg:getContentSize().height)
        -- -- local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),touchLuaSpr);
        -- -- lbBg:setTouchPriority(-(self.layerNum-1)*20-1)
        -- -- local rect=CCSizeMake(250,50)
        -- -- lbBg:setContentSize(rect)
        -- -- lbBg:setOpacity(180)
        -- lbBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2 + 20, self.bgLayer:getContentSize().height - 150 - 10 + 20))
        -- self.bgLayer:addChild(lbBg, 3)
        -- local lbBgx, lbBgy = lbBg:getPositionX() - 20, lbBg:getPositionY()
        -- local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp1:setPosition(ccp(lbBgx, lbBgy + lbBgHeight / 2))
        -- self.bgLayer:addChild(lineSp1, 4)
        -- lineSp1:setScaleX((lbBgWidth - 200) / lineSp1:getContentSize().width)
        -- local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp2:setPosition(ccp(lbBgx, lbBgy - lbBgHeight / 2))
        -- self.bgLayer:addChild(lineSp2, 4)
        -- lineSp2:setScaleX((lbBgWidth - 200) / lineSp2:getContentSize().width)
        local dengjieLb = GetTTFLabel(getlocal("expendition_dengjie", {expeditionVoApi:getGrade()}), 24)
        -- dengjieLb:setAnchorPoint(ccp(0,0.5))
        dengjieLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2 , self.bgLayer:getContentSize().height - 103))
        self.bgLayer:addChild(dengjieLb, 7)
        -- dengjieLb:setScaleY(1/scale)
        self.dengjieLb = dengjieLb
        
        local starScale = 1.5
        local xinWid, xinHei = self.bgLayer:getContentSize().width / 2 - 60, self.bgLayer:getContentSize().height - 65
        for i = 1, 3 do
            local liangStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
            -- backSprie:addChild(liangStar)
            self.bgLayer:addChild(liangStar, 8)
            liangStar:setPosition(ccp(xinWid + (i - 1) * 60, xinHei+1))
            liangStar:setScale(37/liangStar:getContentSize().width)
            -- liangStar:setPosition(xinWid+(i-1)*50, backSprie:getContentSize().height/2)
            -- liangStar:setScaleY(1/scale)
            
            local anStar = CCSprite:createWithSpriteFrameName("gameoverstar_black_new.png")
            -- backSprie:addChild(anStar)
            self.bgLayer:addChild(anStar, 7)
            anStar:setPosition(ccp(xinWid + (i - 1) * 60, xinHei))
            -- anStar:setPosition(xinWid+(i-1)*50, backSprie:getContentSize().height/2)
            -- anStar:setScaleY(liangStar:getContentSize().width/anStar:getContentSize().width/scale)
            anStar:setScaleY(liangStar:getContentSize().height / anStar:getContentSize().height * starScale)
            anStar:setScaleX(liangStar:getContentSize().width / anStar:getContentSize().width * starScale)
            
            self.xinAn[i] = anStar
            self.xinLiang[i] = liangStar
        end
        self:setdengjieAndxin()
        self:setRaidAndsignAgainBtnPos()
        
        --新增新的扫荡按钮
        local bgWidth
        local function nilFunc()
        end
        local descBg = CCSprite:createWithSpriteFrameName("groupSelf.png")
        descBg:setScaleX(lbBgWidth / descBg:getContentSize().width)
        descBg:setScaleY(lbBgHeight / descBg:getContentSize().height)
        -- local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc);
        -- descBg:setTouchPriority(-(self.layerNum-1)*20-1)
        -- local rect=CCSizeMake(250,50)
        -- descBg:setContentSize(rect)
        -- descBg:setOpacity(180)
        descBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2 + 20, 200 - 10))
        self.bgLayer:addChild(descBg, 3)
        local descBgx, descBgy = descBg:getPositionX() - 20, descBg:getPositionY()
        -- local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp3:setPosition(ccp(descBgx,descBgy+lbBgHeight/2))
        -- self.bgLayer:addChild(lineSp3,4)
        -- lineSp3:setScaleX(lbBgWidth/lineSp3:getContentSize().width)
        -- self.lineSp3=lineSp3
        -- local lineSp4=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp4:setPosition(ccp(descBgx,descBgy-lbBgHeight/2))
        -- self.bgLayer:addChild(lineSp4,4)
        -- lineSp4:setScaleX(lbBgWidth/lineSp4:getContentSize().width)
        -- self.lineSp4=lineSp4
        local raidDescStr = getlocal("expeditionRaidDesc", {""})
        -- raidDescStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local raidDescLb = GetTTFLabelWrap(raidDescStr, 22, CCSizeMake(self.bgLayer:getContentSize().width - 300, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        raidDescLb:setAnchorPoint(ccp(0.5, 0.5))
        raidDescLb:setPosition(ccp(descBgx, descBgy))
        self.bgLayer:addChild(raidDescLb, 7)
        self.raidDescLb = raidDescLb
        self.descBg = descBg
        local leftLineSP = CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        leftLineSP:setFlipX(true)
        leftLineSP:setPosition(ccp(80, descBgy))
        self.bgLayer:addChild(leftLineSP, 5)
        local rightLineSP = CCSprite:createWithSpriteFrameName("lineAndPoint.png")
        rightLineSP:setPosition(ccp(self.bgLayer:getContentSize().width - 80, descBgy))
        self.bgLayer:addChild(rightLineSP, 5)
        self.leftLineSP = leftLineSP
        self.rightLineSP = rightLineSP
        
        local function raid2(...)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function reCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    self.raidType = 1
                    self:initLoading(sData.data.report)
                    -- self:refresh()
                    -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("expeditionRaidSuccess"),nil,self.layerNum+1)
                end
            end
            socketHelper:expeditionRaid(reCallback)
        end
        local btnScale = 1.5
        local raidItem2 = GetButtonItem("alien_mines_attack_on.png", "alien_mines_attack.png", "alien_mines_attack.png", raid2, nil, nil, 0)
        raidItem2:setScale(btnScale)
        local raidBtn2 = CCMenu:createWithItem(raidItem2)
        raidBtn2:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        raidBtn2:setAnchorPoint(ccp(0.5, 0.5))
        raidBtn2:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 285))
        self.bgLayer:addChild(raidBtn2, 5)
        self.raidBtn2 = raidBtn2
        local function nilFunc1()
        end
        local btnLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(60, 20, 1, 1), nilFunc1);
        btnLbBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        local rect = CCSizeMake(120, 40)
        btnLbBg:setContentSize(rect)
        -- btnLbBg:setOpacity(180)
        btnLbBg:setPosition(ccp(raidItem2:getContentSize().width / 2 - 3, 15))
        raidItem2:addChild(btnLbBg, 6)
        btnLbBg:setScale(1 / btnScale)
        local raidLb = GetTTFLabel(getlocal("elite_challenge_raid_btn"), 28)
        raidLb:setPosition(getCenterPoint(btnLbBg))
        btnLbBg:addChild(raidLb, 1)
        raidLb:setColor(G_ColorYellowPro)
        
        local isShowRaid, raidIndex = expeditionVoApi:isShowNewRaidBtn()
        if isShowRaid == true and raidIndex and raidIndex > 0 then
            if self.descBg then
                self.descBg:setVisible(true)
            end
            local raidDescStr = getlocal("expeditionRaidDesc", {raidIndex})
            -- raidDescStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            if self.raidDescLb then
                self.raidDescLb:setVisible(true)
                self.raidDescLb:setString(raidDescStr)
            end
            if self.raidBtn2 then
                self.raidBtn2:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 285))
            end
            if self.lineSp3 then
                self.lineSp3:setVisible(true)
            end
            if self.lineSp4 then
                self.lineSp4:setVisible(true)
            end
            if self.leftLineSP then
                self.leftLineSP:setVisible(true)
            end
            if self.rightLineSP then
                self.rightLineSP:setVisible(true)
            end
        else
            if self.descBg then
                self.descBg:setVisible(false)
            end
            if self.raidDescLb then
                self.raidDescLb:setVisible(false)
            end
            if self.raidBtn2 then
                self.raidBtn2:setPosition(ccp(999333, 0))
            end
            if self.lineSp3 then
                self.lineSp3:setVisible(false)
            end
            if self.lineSp4 then
                self.lineSp4:setVisible(false)
            end
            if self.leftLineSP then
                self.leftLineSP:setVisible(false)
            end
            if self.rightLineSP then
                self.rightLineSP:setVisible(false)
            end
        end
    end
    
    local function touchLuaSpr()
        
    end

    local movga_fontSize = 16
    if G_isAsia() then
        movga_fontSize = 20
    end
    self.numLbTitle = GetTTFLabel(getlocal("expeditionRaidLeftNum_new"), movga_fontSize)
    self.numLbTitle:setAnchorPoint(ccp(0.5,0.5))
    self.numLbTitle:setPosition(ccp(G_VisibleSizeWidth - 60,50))
    self.bgLayer:addChild(self.numLbTitle, 5)

    self.numLb = GetTTFLabel(expeditionVoApi:getLeftNum(),movga_fontSize)
    self.numLb:setAnchorPoint(ccp(0.5,0.5))
    self.numLb:setPosition(ccp(G_VisibleSizeWidth - 60,30))
    self.bgLayer:addChild(self.numLb, 5)
    
    self.pointLbTitle = GetTTFLabel(getlocal("expeditionPoint_leftDown"), movga_fontSize)
    self.pointLbTitle:setAnchorPoint(ccp(0.5,0.5))
    self.pointLbTitle:setPosition(ccp(50,50))
    self.bgLayer:addChild(self.pointLbTitle, 5)

    self.pointLb = GetTTFLabel(expeditionVoApi:getPoint(), movga_fontSize)
    self.pointLb:setAnchorPoint(ccp(0.5, 0.5))
    self.pointLb:setPosition(ccp(50 ,30))
    self.bgLayer:addChild(self.pointLb, 5)
    -- self.pointLb:setColor(G_ColorYellowPro)
end

--防止找不到图片卡死，跳过动画
function expeditionDialog:raidCallback()
    -- local function reCallback(fn,data)
    --     local ret,sData=base:checkServerData(data)
    --     if ret==true then
    self:refresh()
    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("expeditionRaidSuccess"), nil, self.layerNum + 1)
    --     end
    -- end
    -- socketHelper:expeditionRaid(reCallback)
end
function expeditionDialog:initLoading(_report)
    local layer2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function ()end)
    -- local loadingTexture2=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
    -- local loadingBg2=CCSprite:createWithTexture(loadingTexture2)
    local loadingBg2 = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    local tankBg2 = CCSprite:createWithSpriteFrameName("dwLoading4.png")
    local tankSp12 = CCSprite:createWithSpriteFrameName("dwLoading2.png")
    local tankSp22 = CCSprite:createWithSpriteFrameName("dwLoading3.png")
    local wheelSp2 = CCSprite:createWithSpriteFrameName("dwLoading1.png")
    local roundPoint2 = CCSprite:createWithSpriteFrameName("dwLoading5.png")
    local progressBg2 = CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
    local progress2 = CCSprite:createWithSpriteFrameName("platWarProgress1.png")
    -- print("layer2,loadingBg2,tankBg2,tankSp12,tankSp22,wheelSp2,roundPoint2,progressBg2,progress2",layer2,loadingBg2,tankBg2,tankSp12,tankSp22,wheelSp2,roundPoint2,progressBg2,progress2)
    if layer2 and loadingBg2 and tankBg2 and tankSp12 and tankSp22 and wheelSp2 and roundPoint2 and progressBg2 and progress2 then
    else
        self:raidCallback()
        do return end
    end
    
    self.cLayer1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function ()end)
    self.cLayer1:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.cLayer1:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    self.cLayer1:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.bgLayer:addChild(self.cLayer1, 9)
    
    self._report = _report
    
    self.cLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function ()end)
    self.cLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.cLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- self.cLayer:setOpacity(200)
    -- self.cLayer:setAnchorPoint(ccp(0,0))
    -- self.cLayer:setPosition(ccp(G_VisibleSizeWidth,0))
    -- self.cLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))
    self.cLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.cLayer:setScale(0.1)
    self.cLayer:runAction(CCScaleTo:create(0.5, 1, 1))
    self.cLayer:setOpacity(0)
    
    -- local loadingTexture=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
    -- local loadingBg=CCSprite:createWithTexture(loadingTexture)
    local loadingBg = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    loadingBg:setColor(ccc3(220, 220, 220))
    loadingBg:setScale(G_VisibleSizeWidth / loadingBg:getContentSize().width)
    loadingBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.cLayer:addChild(loadingBg)
    self.loadingBg = loadingBg
    local tankBg = CCSprite:createWithSpriteFrameName("dwLoading4.png")
    tankBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.cLayer:addChild(tankBg)
    self.tankBg = tankBg
    self.tankSp1 = CCSprite:createWithSpriteFrameName("dwLoading2.png")
    self.tankSp1:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.cLayer:addChild(self.tankSp1)
    self.tankSp2 = CCSprite:createWithSpriteFrameName("dwLoading3.png")
    self.tankSp2:setVisible(false)
    self.tankSp2:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.cLayer:addChild(self.tankSp2)
    self.wheelTb = {}
    for i = 1, 4 do
        local wheelSp = CCSprite:createWithSpriteFrameName("dwLoading1.png")
        wheelSp:setPosition(G_VisibleSizeWidth / 2 - 32 + 16 * (i - 1) + 8, G_VisibleSizeHeight / 2 - 22)
        self.cLayer:addChild(wheelSp)
        local rotateBy = CCRotateBy:create(0.4, -360)
        wheelSp:runAction(CCRepeatForever:create(rotateBy))
        table.insert(self.wheelTb, wheelSp)
    end
    local roundPoint = CCSprite:createWithSpriteFrameName("dwLoading5.png")
    roundPoint:setAnchorPoint(ccp(-3.8, 0.5))
    roundPoint:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    self.cLayer:addChild(roundPoint)
    local rotateBy = CCRotateBy:create(1, 360)
    roundPoint:runAction(CCRepeatForever:create(rotateBy))
    self.roundPoint = roundPoint
    local progressBg = CCSprite:createWithSpriteFrameName("platWarProgressBg.png")
    progressBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 70))
    self.cLayer:addChild(progressBg)
    self.progressBg = progressBg
    self.progress = CCSprite:createWithSpriteFrameName("platWarProgress1.png")
    self.progress = CCProgressTimer:create(self.progress)
    self.progress:setType(kCCProgressTimerTypeBar)
    self.progress:setMidpoint(ccp(0, 0))
    self.progress:setBarChangeRate(ccp(1, 0))
    self.progress:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 70))
    self.cLayer:addChild(self.progress)
    -- local countDown=dimensionalWarFightVoApi:getCountDown()
    self.countDown = 3
    self.isPlayAnim = true
    local maxSec = 3
    local percent = (maxSec - self.countDown) / maxSec * 100
    self.progress:setPercentage(percent)
    -- self.txtTb={getlocal("dimensionalWar_loadingTxt1"),getlocal("dimensionalWar_loadingTxt2")}
    -- local tmpTb={}
    -- for i=3,10 do
    --     table.insert(tmpTb,getlocal("dimensionalWar_loadingTxt"..i))
    -- end
    -- while #tmpTb>0 do
    --     math.randomseed(os.time())
    --     local random = math.random(1,#tmpTb)
    --     local str=table.remove(tmpTb,random)
    --     table.insert(self.txtTb,str)
    -- end
    local txtBg = LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png", CCRect(213, 0, 2, 47), function ()end)
    txtBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, 50))
    txtBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 130)
    self.cLayer:addChild(txtBg)
    self.loadingTxt = GetTTFLabel(getlocal("expeditionRaidLoadDesc"), 25)
    self.loadingTxt:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 130)
    self.cLayer:addChild(self.loadingTxt)
    self.bgLayer:addChild(self.cLayer, 10)
    
    local function closeCLayer()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if self.cLayer then
            self.cLayer:removeFromParentAndCleanup(true)
            self.cLayer = nil
        end
        if self.cLayer1 then
            self.cLayer1:removeFromParentAndCleanup(true)
            self.cLayer1 = nil
        end
    end
    local closeItem = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnOkSmall_Down.png", closeCLayer, 11, getlocal("fight_close"), 25)
    local closeMenu = CCMenu:createWithItem(closeItem)
    -- closeMenu:setPosition(ccp(self.cLayer:getContentSize().width/2,120))
    closeMenu:setPosition(ccp(999333, 0))
    closeMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 11)
    self.cLayer:addChild(closeMenu, 3)
    self.closeMenu = closeMenu
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function expeditionDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
        
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width, self.expandHeight)
        
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local function cellClick(hd, fn, idx)
            
        end
        
        local width = (self.bgLayer:getContentSize().width) / 2
        local challengeNum = expeditionVoApi:getChallengeNum()
        
        for i = 1, 10 do
            local mapSp = CCSprite:createWithSpriteFrameName("world_map_mi_new.jpg")
            local scale = (self.bgLayer:getContentSize().width) / mapSp:getContentSize().width
            mapSp:setScale(scale)
            mapSp:setAnchorPoint(ccp(0.5, 1))
            mapSp:setPosition(width, self.expandHeight - (i - 1) * mapSp:getContentSize().height * scale)
            cell:addChild(mapSp)
        end
        
        local yy = 150
        
        local tb = {
            {pos = {150, self.expandHeight - 50 - yy}, type = 1, },
            {pos = {430, self.expandHeight - 50 - yy}, type = 1, },
            {pos = {260, self.expandHeight - 190 - yy}, type = 2, },
            {pos = {490, self.expandHeight - 290 - yy}, type = 1, },
            {pos = {490, self.expandHeight - 460 - yy}, type = 1, },
            {pos = {120, self.expandHeight - 370 - yy}, type = 2, },
            {pos = {120, self.expandHeight - 600 - yy}, type = 1, },
            {pos = {370, self.expandHeight - 600 - yy}, type = 1, },
            {pos = {510, self.expandHeight - 780 - yy}, type = 2, },
            {pos = {220, self.expandHeight - 860 - yy}, type = 1, },
            {pos = {120, self.expandHeight - 1040 - yy}, type = 1, },
            {pos = {380, self.expandHeight - 1040 - yy}, type = 2, },
            {pos = {500, self.expandHeight - 1210 - yy}, type = 1, },
            {pos = {200, self.expandHeight - 1220 - yy}, type = 1, },
            {pos = {340, self.expandHeight - 1400 - yy}, type = 2, },
            
        }
        local function callBack(object, name, tag)
            if self.tv:getIsScrolled() == true then
                do return end
            end
            print("tag=", tag)
            if (battleScene and battleScene.isBattleing == true) then
                do return end
            end
            if tag == expeditionVoApi:getEid() and playerVoApi:getPlayerLevel() >= expeditionCfg.unlockExpUserLvl[expeditionVoApi:getEid()] and expeditionVoApi:getWin() == false then
                require "luascript/script/game/scene/gamedialog/expedition/expeditionTargetDialog"
                local dialog = expeditionTargetDialog:new(expeditionVoApi:getEid(), self)
                local layer = dialog:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("targetDetails"), true, self.layerNum + 1)
                sceneGame:addChild(layer, self.layerNum + 1)
            end
            
        end
        for k, v in pairs(tb) do
            local bgStr = "expedition_bg2_new.png"
            -- if v.type == 2 then
            --     bgStr = "expedition_bg1.png"
            -- end
            if k == expeditionVoApi:getEid() then
                bgStr = "expedition_bg1_new.png"
            end
            local bgSp = LuaCCSprite:createWithSpriteFrameName(bgStr, callBack)
            bgSp:setTag(k)
            bgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            bgSp:setAnchorPoint(ccp(0.5, 1))
            bgSp:setPosition(ccp(v.pos[1], v.pos[2]))
            cell:addChild(bgSp, 5)
            if k == expeditionVoApi:getEid() then
                local bgsp_downLight = LuaCCSprite:createWithSpriteFrameName("bgsp_downLight.png", callBack)
                bgsp_downLight:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                bgsp_downLight:setAnchorPoint(ccp(0.5, 0))
                bgsp_downLight:setPosition(ccp(bgSp:getContentSize().width/2,13))
                bgSp:addChild(bgsp_downLight)
            end
            if k > expeditionVoApi:getEid() + 2 then
                bgSp:setVisible(false)
            end
        end
        
        local roadTb = {
            {pos = {290, self.expandHeight - 90 - yy}, rotation = -90, num = 2},
            {pos = {370, self.expandHeight - 155 - yy}, rotation = 50, num = 2.5},
            {pos = {365, self.expandHeight - 285 - yy}, rotation = -60, num = 2.3},
            {pos = {485, self.expandHeight - 397 - yy}, rotation = 0, num = 1.7},
            {pos = {300, self.expandHeight - 450 - yy}, rotation = 105, num = 4.6},
            {pos = {112, self.expandHeight - 495 - yy}, rotation = 0, num = 2.5},
            {pos = {250, self.expandHeight - 640 - yy}, rotation = 270, num = 1.5},
            {pos = {440, self.expandHeight - 720 - yy}, rotation = -30, num = 2.4},
            {pos = {360, self.expandHeight - 840 - yy}, rotation = 70, num = 2.8},
            {pos = {195, self.expandHeight - 975 - yy}, rotation = 30, num = 1.9},
            {pos = {255, self.expandHeight - 1080 - yy}, rotation = -90, num = 1.6},
            {pos = {440, self.expandHeight - 1150 - yy}, rotation = -30, num = 2},
            {pos = {350, self.expandHeight - 1240 - yy}, rotation = 90, num = 2},
            {pos = {250, self.expandHeight - 1340 - yy}, rotation = -30, num = 2},
            
        }
        for k, v in pairs(roadTb) do
            local bgStr = "highway2_new.png"
            local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName(bgStr,CCRect(0,34,1,1),function ()end)
            local height = bgSp:getContentSize().height
            if k == expeditionVoApi:getEid()-1 then
                bgStr = "highway1_new.png"
                bgSp = LuaCCScale9Sprite:createWithSpriteFrameName(bgStr,CCRect(5,37,1,1),function ()end)
            end
            if v.num then
                bgSp:setContentSize(CCSizeMake(40,height*v.num))
            end
            -- bgSp:setAnchorPoint(ccp(0,0))
            bgSp:setRotation(v.rotation)
            bgSp:setPosition(ccp(v.pos[1], v.pos[2]))
            cell:addChild(bgSp, 3)
        end
        if playerVoApi:getPlayerLevel() >= expeditionCfg.unlockExpUserLvl[expeditionVoApi:getEid()] then
            if expeditionVoApi:getWin() == false then
                local sp = expeditionVoApi:getShowTank()
                local bg = cell:getChildByTag(expeditionVoApi:getEid())
                --sp:setScale(0.8)
                sp:setPosition(ccp(bg:getContentSize().width / 2+10, bg:getContentSize().height / 2 + 20))
                bg:addChild(sp)
            end
        else
            if cell:getChildByTag(expeditionVoApi:getEid()) then
                local sp = CCSprite:createWithSpriteFrameName("cloud.png")
                sp:setScale(2)
                local bg = cell:getChildByTag(expeditionVoApi:getEid())
                sp:setPosition(ccp(bg:getPositionX() - 30, bg:getPositionY() - 40))
                cell:addChild(sp, 6)
            end
        end
        
        local unLockX = self.bgLayer:getContentSize().width / 2
        local unlockTb = {
            {lv = 30, pos = {unLockX, self.expandHeight - 750}},
            -- {lv=35,pos={unLockX,self.expandHeight-1180}},
            -- {lv=40,pos={unLockX,self.expandHeight-1400}},
            {lv = 35, pos = {unLockX, self.expandHeight - 1400}},
        }
        
        for k, v in pairs(unlockTb) do
            
            if playerVoApi:getPlayerLevel() < v.lv then
                local function touchLuaSpr()
                    
                end
                local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr);
                blackBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                local bgWidth = 210
                if G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "de" then
                    bgWidth = 350
                end
                local rect = CCSizeMake(bgWidth, 50)
                blackBg:setContentSize(rect)
                blackBg:setOpacity(180)
                blackBg:setPosition(ccp(v.pos[1], v.pos[2]))
                cell:addChild(blackBg, 10)
                
                local unlockLb = GetTTFLabel(getlocal("expeditionunlockLv", {v.lv}), 28)
                unlockLb:setPosition(ccp(blackBg:getContentSize().width / 2, blackBg:getContentSize().height / 2))
                blackBg:addChild(unlockLb, 7)
                break
            end
            
        end
        local zhuangshiTb = {
            {pos = {525, self.expandHeight - 370}, image = "smoke_10.png", scale = 1.1},
            {pos = {530, self.expandHeight - 320}, image = "die_6.png", scale = 0.7},
            {pos = {100, self.expandHeight - 465}, image = "shi_you_building_1.png", scale = 1.1},
            {pos = {110, self.expandHeight - 400}, image = "die_8.png", scale = 0.7},
            {pos = {325, self.expandHeight - 563}, image = "t16_2_die.png", scale = 1},
            {pos = {330, self.expandHeight - 510}, image = "die_16.png", scale = 0.6, op = 200},
            {pos = {275, self.expandHeight - 683}, image = "world_ground_4.png", scale = 1.8},
            {pos = {245, self.expandHeight - 733}, image = "world_ground_4.png", scale = 1.8},
            {pos = {100, self.expandHeight - 980}, image = "t5_2_die.png", scale = 0.9},
            {pos = {110, self.expandHeight - 920}, image = "die_16.png", scale = 0.6, op = 200},
            {pos = {480, self.expandHeight - 1100}, image = "world_ground_1.png", scale = 2},
            {pos = {530, self.expandHeight - 1170}, image = "world_ground_4.png", scale = 1.8, isFx = true},
            {pos = {110, self.expandHeight - 1590}, image = "tie_kuang_building_1.png", scale = 1.1},
            {pos = {110, self.expandHeight - 1510}, image = "die_6.png", scale = 0.7},
            
        }
        for k, v in pairs(zhuangshiTb) do
            local sp = CCSprite:createWithSpriteFrameName(v.image)
            sp:setPosition(ccp(v.pos[1], v.pos[2]))
            sp:setScale(v.scale)
            if v.op then
                sp:setOpacity(v.op)
            end
            if v.isFx then
                sp:setFlipX(true)
            end
            cell:addChild(sp, 1)
            
        end
        
        if expeditionVoApi:getEid() + 2 < challengeNum then
            
            for i = expeditionVoApi:getEid() + 3, challengeNum do
                local sp = CCSprite:createWithSpriteFrameName("cloud.png")
                sp:setScale(2)
                local bg = cell:getChildByTag(i)
                sp:setPosition(ccp(bg:getPositionX() - 30, bg:getPositionY() - 40))
                cell:addChild(sp, 6)
            end
        end
        
        for i = expeditionVoApi:getEid() + 1, expeditionVoApi:getEid() + 2 do
            if i <= challengeNum and playerVoApi:getPlayerLevel() >= expeditionCfg.unlockExpUserLvl[i] then
                local sp = CCSprite:createWithSpriteFrameName("tankQuestionMark.png")
                local bg = cell:getChildByTag(i)
                sp:setPosition(ccp(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 30))
                bg:addChild(sp)
            else
                if cell:getChildByTag(i) then
                    local sp = CCSprite:createWithSpriteFrameName("cloud.png")
                    sp:setScale(2)
                    local bg = cell:getChildByTag(i)
                    sp:setPosition(ccp(bg:getPositionX() - 30, bg:getPositionY() - 40))
                    cell:addChild(sp, 6)
                end
            end
        end
        
        local function rewardCallBack(object, name, tag)
            if self.tv:getIsScrolled() == true then
                do return end
            end
            if expeditionVoApi:isReward(tag) then
                do return end
            else
                local function reCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        local award = FormatItem(sData.data.reward) or {}
                        for k, v in pairs(award) do
                            -- G_addPlayerAward(v.type,v.key,v.id,v.num)
                            if v.type == "h" then
                                heroVoApi:addSoul(v.key, v.num)
                            else
                                G_addPlayerAward(v.type, v.key, v.id, v.num)
                            end
                        end
                        local point = expeditionVoApi:getRewardPoint(tag)
                        --print("addrewardpoint=",point)
                        local reStr = G_showRewardTip(award, false)
                        reStr = reStr..","..getlocal("expeditionPoints", {point})
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), reStr, 30)
                        
                        expeditionVoApi:reward(tag)
                        self:refresh()
                        
                    end
                end
                socketHelper:expeditionReward(tag, reCallback)
            end
        end
        
        if expeditionVoApi:getEid() > 1 then
            
            local num = expeditionVoApi:getEid() - 1
            if expeditionVoApi:getWin() then
                num = challengeNum
            end
            for i = 1, num do
                local spStr = ""
                if i % 3 == 0 then
                    spStr = "SpecialBox.png"
                    if expeditionVoApi:isReward(i) then
                        spStr = "SpecialBoxOpen.png"
                    end
                else
                    spStr = "silverBox.png"
                    if expeditionVoApi:isReward(i) then
                        spStr = "silverBoxOpen.png"
                    end
                end
                local sp = LuaCCSprite:createWithSpriteFrameName(spStr, rewardCallBack)
                local bg = cell:getChildByTag(i)
                sp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
                if spStr == "silverBoxOpen.png" or spStr == "SpecialBoxOpen.png" then
                    sp:setPosition(ccp(bg:getContentSize().width / 2-10, bg:getContentSize().height / 2 + 40))
                else
                    sp:setPosition(ccp(bg:getContentSize().width / 2, bg:getContentSize().height / 2 + 30))
                end
                sp:setTag(i)
                bg:addChild(sp)
            end
        end
        
        return cell
        
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end
--点击了cell或cell上某个按钮
function expeditionDialog:cellClick(idx)
    if self.tv == nil then
        do
            return
        end
    end
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k" .. (idx - 1000)] == nil then
            self.expandIdx["k" .. (idx - 1000)] = idx - 1000
            self.tv:openByCellIndex(idx - 1000, self.normalHeight)
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k" .. (idx - 1000)] = nil
            self.tv:closeByCellIndex(idx - 1000, self.expandHeight)
        end
    end
end

function expeditionDialog:refresh()
    
    if(self and self.tv)then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end

    self:showAdditionalGift()
    if expeditionVoApi:getLeftNum() <= 0 and self.signAgainItem then
        self.signAgainItem:setEnabled(false)
    end
    
    -- self.numLb = tolua.cast(self.numLb, "CCLabelTTF")
    if(self.numLb)then
        self.numLb:setString(expeditionVoApi:getLeftNum())
    end
    self:setdengjieAndxin()
    self:setRaidAndsignAgainBtnPos()

    if self.pointLb then
        self.pointLb:setString(expeditionVoApi:getPoint())
    end
    local isShowRaid, raidIndex = expeditionVoApi:isShowNewRaidBtn()
    if isShowRaid == true and raidIndex and raidIndex > 0 then
        if self.descBg then
            self.descBg:setVisible(true)
        end
        local raidDescStr = getlocal("expeditionRaidDesc", {raidIndex})
        if self.raidDescLb then
            self.raidDescLb:setVisible(true)
            self.raidDescLb:setString(raidDescStr)
        end
        if self.raidBtn2 then
            self.raidBtn2:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 285))
        end
        if self.lineSp3 then
            self.lineSp3:setVisible(true)
        end
        if self.lineSp4 then
            self.lineSp4:setVisible(true)
        end
        if self.leftLineSP then
            self.leftLineSP:setVisible(true)
        end
        if self.rightLineSP then
            self.rightLineSP:setVisible(true)
        end
    else
        if self.descBg then
            self.descBg:setVisible(false)
        end
        if self.raidDescLb then
            self.raidDescLb:setVisible(false)
        end
        if self.raidBtn2 then
            self.raidBtn2:setPosition(ccp(999333, 0))
        end
        if self.lineSp3 then
            self.lineSp3:setVisible(false)
        end
        if self.lineSp4 then
            self.lineSp4:setVisible(false)
        end
        if self.leftLineSP then
            self.leftLineSP:setVisible(false)
        end
        if self.rightLineSP then
            self.rightLineSP:setVisible(false)
        end
    end
end

-- 设置等阶和星星
function expeditionDialog:setdengjieAndxin()
    if base.ea == 1 then
        local acount = expeditionVoApi:getAcount() or 0
        for i = 1, 3 do
            if acount >= i then
                if self.xinAn[i] and self.xinAn[i].setVisible then
                    self.xinAn[i]:setVisible(true)
                end
                if self.xinLiang[i] and self.xinLiang[i].setVisible then
                    self.xinLiang[i]:setVisible(true)
                end
                
            else
                if self.xinLiang[i] and self.xinLiang[i].setVisible then
                    self.xinLiang[i]:setVisible(false)
                end
                if self.xinAn[i] and self.xinAn[i].setVisible then
                    self.xinAn[i]:setVisible(true)
                end
            end
        end
        
        if self.dengjieLb then
            self.dengjieLb:setString(getlocal("expendition_dengjie", {expeditionVoApi:getGrade()}))
        end
    end
end

-- 设置扫荡的位置
function expeditionDialog:setRaidAndsignAgainBtnPos()
    if base.ea == 1 then
        local acount = expeditionVoApi:getAcount() or 0
        if expeditionVoApi:getWin() or acount < expeditionCfg.acount then
            self.raidBtn:setPosition(ccp(999333, 0))
            -- self.signAgainBtn:setPosition(ccp(G_VisibleSizeWidth-80, 40))
            -- self.signAgainBtn:setVisible(true)
            self.raidBtn:setVisible(false)
        else
            self.raidBtn:setPosition(ccp(G_VisibleSizeWidth/2, 100))
            -- self.signAgainBtn:setPosition(ccp(999333, 0))
            -- self.signAgainBtn:setVisible(false)
            self.raidBtn:setVisible(true)
        end
    end
end
--创建或刷新CCTableViewCell
function expeditionDialog:loadCCTableViewCell(cell, idx, refresh)
    
end

function expeditionDialog:tick()
    if self.isPlayAnim == true then
        if self.countDown and self.countDown > 0 then
            self.countDown = self.countDown - 1
            if self.progress then
                local maxSec = 3
                local percent = (maxSec - self.countDown) / maxSec * 100
                self.progress:setPercentage(percent)
            end
        else
            self.isPlayAnim = false
            if self.cLayer then
                -- self.cLayer:removeFromParentAndCleanup(true)
                -- self.cLayer=nil
                
                -- if self.loadingBg then
                --     self.loadingBg:setVisible(false)
                -- end
                if self.tankBg then
                    self.tankBg:setVisible(false)
                end
                if self.tankSp1 then
                    self.tankSp1:setVisible(false)
                end
                if self.tankSp2 then
                    self.tankSp2:setVisible(false)
                end
                if self.wheelTb and SizeOfTable(self.wheelTb) > 0 then
                    for k, v in pairs(self.wheelTb) do
                        if v and v.setVisible then
                            v:setVisible(false)
                        end
                    end
                end
                if self.roundPoint then
                    self.roundPoint:setVisible(false)
                end
                if self.progressBg then
                    self.progressBg:setVisible(false)
                end
                if self.progress then
                    self.progress:setVisible(false)
                end
                
                -- local function reCallback(fn,data)
                --     local ret,sData=base:checkServerData(data)
                --     if ret==true then
                local raidStr = getlocal("expeditionRaidSuccess")
                if self.raidType == 2 then
                    raidStr = getlocal("expeditionRaidAllSuccess")
                end
                -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),raidStr,nil,self.layerNum+1)
                if self.loadingTxt then
                    self.loadingTxt:setString(raidStr)
                end
                
                -- self.addParticleTb={}
                local function callback1()
                    local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
                    particleS:setPositionType(kCCPositionTypeFree)
                    particleS:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
                    particleS:setAutoRemoveOnFinish(true) -- 自动移除
                    self.cLayer:addChild(particleS, 10)
                    -- table.insert(self.addParticleTb,particleS)
                    local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
                    particleS2:setPositionType(kCCPositionTypeFree)
                    particleS2:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
                    particleS2:setAutoRemoveOnFinish(true) -- 自动移除
                    self.cLayer:addChild(particleS2, 11)
                    -- table.insert(self.addParticleTb,particleS2)
                end
                local function callback2()
                    local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
                    particleS:setPositionType(kCCPositionTypeFree)
                    particleS:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
                    particleS:setAutoRemoveOnFinish(true) -- 自动移除
                    self.cLayer:addChild(particleS, 12)
                    -- table.insert(self.addParticleTb,particleS)
                end
                local function callback3()
                    local function touchHander1()
                    end
                    local raidLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(60, 20, 1, 1), touchHander1)
                    raidLbBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                    local rect = CCSizeMake(250, 60)
                    raidLbBg:setContentSize(rect)
                    raidLbBg:setOpacity(150)
                    raidLbBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
                    self.cLayer:addChild(raidLbBg, 1)
                    
                    local raidFinishLb = GetTTFLabelWrap(getlocal("expeditionRaidFinish"), 42, CCSizeMake(self.cLayer:getContentSize().width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                    raidFinishLb:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
                    self.cLayer:addChild(raidFinishLb, 7)
                    raidFinishLb:setColor(G_ColorYellowPro)
                    
                    local acArr1 = CCArray:create()
                    local scaleTo1 = CCScaleTo:create(0.2, 2, 2)
                    local scaleTo2 = CCScaleTo:create(0.3, 1, 1)
                    acArr1:addObject(scaleTo1)
                    acArr1:addObject(scaleTo2)
                    local seq1 = CCSequence:create(acArr1)
                    raidFinishLb:runAction(seq1)
                    
                    self.closeMenu:setPosition(ccp(self.cLayer:getContentSize().width / 2, 140))
                    
                    if self._report then                        
                        local rewardlist = {}
                        for k, v in pairs(self._report) do
                            local reward = FormatItem(v, nil, true)[1]
                            table.insert(rewardlist, reward)
                        end
                        if self._report.ac and type(self._report.ac) == "table" then --处理活动产出
                            local ac = G_clone(self._report.ac)
                            self._report.ac = nil
                            for k,v in pairs(ac) do
                                local reward = FormatItem(v, nil, true)[1]
                                table.insert(rewardlist, reward)
                            end
                        end
                        G_showRewardTip(rewardlist, true)
                    end
                    self._report = nil
                    
                    self:refresh()
                end
                local acArr = CCArray:create()
                local callFunc1 = CCCallFunc:create(callback1)
                local callFunc2 = CCCallFunc:create(callback2)
                local callFunc3 = CCCallFunc:create(callback3)
                local delay = CCDelayTime:create(0.5)
                acArr:addObject(callFunc1)
                acArr:addObject(delay)
                acArr:addObject(callFunc2)
                acArr:addObject(delay)
                acArr:addObject(callFunc3)
                local seq = CCSequence:create(acArr)
                self.cLayer:runAction(seq)
                --     end
                -- end
                -- socketHelper:expeditionRaid(reCallback)
            end
        end
    end
end
function expeditionDialog:close()
    if self.isCloseing == true then
        do return end
    end
    if self.isCloseing == false then
        self.isCloseing = true
    end
    
    if hasAnim == nil then
        hasAnim = true
    end
    base.allShowedCommonDialog = base.allShowedCommonDialog - 1
    for k, v in pairs(base.commonDialogOpened_WeakTb) do
        if v == self then
            table.remove(base.commonDialogOpened_WeakTb, k)
            break
        end
    end
    if base.allShowedCommonDialog < 0 then
        base.allShowedCommonDialog = 0
    end
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep == 9 or newGuidMgr.curStep == 46 or newGuidMgr.curStep == 17 or newGuidMgr.curStep == 35 or newGuidMgr.curStep == 42) then --新手引导
        newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog == 0 and storyScene.isShowed == false then
        if portScene.clayer ~= nil then
            if sceneController.curIndex == 0 then
                portScene:setShow()
            elseif sceneController.curIndex == 1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex == 2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
    base:removeFromNeedRefresh(self) --停止刷新
    local fc = CCCallFunc:create(realClose)
    local moveTo = CCMoveTo:create((hasAnim == true and 0.3 or 0), CCPointMake(G_VisibleSize.width / 2, -self.bgLayer:getContentSize().height))
    local acArr = CCArray:create()
    acArr:addObject(moveTo)
    acArr:addObject(fc)
    local seq = CCSequence:create(acArr)
    self.bgLayer:runAction(seq)
    
end

function expeditionDialog:realClose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
    
end
--显示面板,加效果
function expeditionDialog:show()
    local moveTo = CCMoveTo:create(0.3, CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    local function callBack()
        if portScene.clayer ~= nil then
            if sceneController.curIndex == 0 then
                portScene:setHide()
            elseif sceneController.curIndex == 1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex == 2 then
                worldScene:setHide()
            end
            
            mainUI:setHide()
            --self:getDataByType() --只有Email使用这个方法
        end
        base:cancleWait()
    end
    base.allShowedCommonDialog = base.allShowedCommonDialog + 1
    table.insert(base.commonDialogOpened_WeakTb, self)
    local callFunc = CCCallFunc:create(callBack)
    local seq = CCSequence:createWithTwoActions(moveTo, callFunc)
    self.bgLayer:runAction(seq)
end
function expeditionDialog:dispose()
    self.expandIdx = nil
    self.layerNum = nil
    self.dialogLayer = nil
    self.bgLayer = nil
    self.closeBtn = nil
    self.bgSize = nil
    self.tv = nil
    self.expandHeight = nil
    self.normalHeight = nil
    self.extendSpTag = nil
    self.timeLbTab = nil
    self.buffTab = nil
    self.signAgainBtn = nil
    self.raidBtn = nil
    self.xinAn = nil
    self.xinLiang = nil
    if self.overDayEventListener then
        eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
    end
    self.overDayEventListener=nil
    base:removeFromNeedRefresh(self) --停止刷新
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
    spriteController:removePlist("public/expedition_newUI.plist")
    spriteController:removeTexture("public/expedition_newUI.png")
    spriteController:removePlist("scene/world_map_mi_new.plist")
    spriteController:removeTexture("scene/world_map_mi_new.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
    
    if platCfg.platCfgNewWayAddTankImage then
        
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/newTankImage/t16newImage.plist")
        
        CCTextureCache:sharedTextureCache():removeTextureForKey("ship/newTankImage/t16newImage.plist")
        
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/newTankImage/t5newImage.plist")
        
        CCTextureCache:sharedTextureCache():removeTextureForKey("ship/newTankImage/t5newImage.plist")
    end
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    -- spriteController:removeTexture("public/serverWarLocal/sceneBg.jpg")
    -- self=nil
    spriteController:removePlist("public/expeditionRevive.plist")
    spriteController:removeTexture("public/expeditionRevive.png")
    
    if self.reviveRefreshListener then
        eventDispatcher:removeEventListener("expedition.reviveRefresh", self.reviveRefreshListener)
        self.reviveRefreshListener = nil
    end
end
