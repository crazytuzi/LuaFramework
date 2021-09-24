worldAirShipTabOne = {}

function worldAirShipTabOne:new(parentLayer)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.parentLayer = parentLayer
    if parentLayer then
        self.landData = parentLayer.landData
        self.layerNum = parentLayer.layerNum
    end
    G_addResource8888(function()
        spriteController:addPlist("public/squaredImgs.plist")
        spriteController:addTexture("public/squaredImgs.png")
        spriteController:addPlist("public/airShip_omegaImages.plist")
        spriteController:addTexture("public/airShip_omegaImages.png")
        spriteController:addPlist("public/acFlashSaleImage.plist")
        spriteController:addTexture("public/acFlashSaleImage.png")
    end)
    return nc
end

function worldAirShipTabOne:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    local recoverTimer = airShipVoApi:getBossAtkRecoverTimer()
    if recoverTimer and recoverTimer < 0 then
        airShipVoApi:requestInit(function() self:refreshAttackNumUI() end, false)
    end
    return self.bgLayer
end

function worldAirShipTabOne:initUI()
    local function onLoadWebImage(fn, webImage)
        if self and tolua.cast(self.bgLayer, "CCSprite") then
            webImage:setAnchorPoint(ccp(0.5, 0))
            local imageHeight = self.parentLayer.allTabs[1]:getPositionY() - self.parentLayer.allTabs[1]:getContentSize().height / 2
            webImage:setScaleY(imageHeight / webImage:getContentSize().height)
            webImage:setPosition(ccp(G_VisibleSizeWidth / 2, 0))
            self.bgLayer:addChild(webImage)
        end
    end
    G_addResource8888(function()
        LuaCCWebImage:createWithURL(G_downloadUrl("airShip/airShip_omegaBg.png"), onLoadWebImage)
    end)
    
    local topBg = CCSprite:createWithSpriteFrameName("aso_infoBg.png")
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 160))
    self.bgLayer:addChild(topBg, 1)
    local bossType = self.landData.extendData.b[2]
    local iconSp = CCSprite:createWithSpriteFrameName(airShipVoApi:getBossIconPic(bossType))
    iconSp:setAnchorPoint(ccp(0, 0.5))
    iconSp:setScale(90 / iconSp:getContentSize().width)
    iconSp:setPosition(ccp(25, topBg:getContentSize().height / 2))
    topBg:addChild(iconSp)
    local troopsNameLb = GetTTFLabel(getlocal("airShip_bossNameType" .. bossType), 24)
    troopsNameLb:setAnchorPoint(ccp(0, 0))
    troopsNameLb:setPosition(ccp(iconSp:getPositionX() + iconSp:getContentSize().width * iconSp:getScale() + 10, iconSp:getPositionY() + 15))
    topBg:addChild(troopsNameLb)
    
    local first = 1000 --初始值1000先手值
    local boss = airShipVoApi:getAirShipCfg().serverreward.Boss[self.landData.extendData.b[1]]
    if boss then
        first = first + boss.att.first
    end
    local firstValueLb = GetTTFLabel(getlocal("firstValue") .. ":"..first, 22)
    firstValueLb:setAnchorPoint(ccp(0, 0))
    firstValueLb:setPosition(ccp(troopsNameLb:getPositionX(), iconSp:getPositionY() - 45))
    topBg:addChild(firstValueLb)
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local textFormatTb = {}
        local tabStr = {}
        local asCfg = airShipVoApi:getAirShipCfg()
        for i = 1, 6 do
            local strParam
            if i == 4 then
                strParam = {asCfg.bMax, asCfg.bCD}
            elseif i == 5 then
                strParam = {asCfg.bLoc / 3600}
            end
            table.insert(tabStr, getlocal("airShip_worldBossTabOne_i_desc" .. i, strParam))
            textFormatTb[i] = {
                alignment = kCCTextAlignmentLeft,
                richFlag = true,
                richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil},
                ws = 10
            }
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25, textFormatTb)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 0.5))
    infoBtn:setScale(0.8)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(topBg:getContentSize().width - 20, topBg:getContentSize().height / 2))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    topBg:addChild(infoMenu)
    
    local rewardBox
    local function onClickReward(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        G_touchedItem(rewardBox, function ()
            PlayEffect(audioCfg.mouseClick)
            local rewardTb = airShipVoApi:getBossAttackReward(bossType)
            require "luascript/script/game/scene/gamedialog/worldAirShipSmallDialog"
            worldAirShipSmallDialog:showAttackReward(self.layerNum + 1, rewardBtnStr, rewardTb)
        end)
    end
    rewardBox = LuaCCSprite:createWithSpriteFrameName("acFS_boxIcon.png", onClickReward)
    rewardBox:setAnchorPoint(ccp(0.5, 0.5))
    rewardBox:setScale(0.8)
    rewardBox:setPosition(G_VisibleSizeWidth - rewardBox:getContentSize().width * rewardBox:getScale() / 2 - 30, topBg:getPositionY() - topBg:getContentSize().height - rewardBox:getContentSize().height * rewardBox:getScale() / 2 - 20)
    rewardBox:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(rewardBox, 2)
    local rewardLb = GetTTFLabelWrap(getlocal("RankScene_attack") .. getlocal("award"), 20, CCSizeMake(rewardBox:getContentSize().width * rewardBox:getScale() + 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    local rewardBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    rewardBg:setScaleX((rewardLb:getContentSize().width + 40) / rewardBg:getContentSize().width)
    rewardBg:setScaleY((rewardLb:getContentSize().height + 10) / rewardBg:getContentSize().height)
    rewardBg:setPosition(rewardBox:getPositionX(), rewardBox:getPositionY() - rewardBox:getContentSize().height * rewardBox:getScale() / 2 - rewardBg:getContentSize().height * rewardBg:getScaleY() / 2 - 5)
    self.bgLayer:addChild(rewardBg, 2)
    rewardLb:setAnchorPoint(ccp(0.5, 0.5))
    rewardLb:setColor(G_ColorYellowPro)
    rewardLb:setPosition(ccp(rewardBg:getPositionX(), rewardBg:getPositionY()))
    self.bgLayer:addChild(rewardLb, 3)
    local offsetPosY = 40
    local landBgOffsetPosY = 15
    if G_getIphoneType() == G_iphone4 then
        offsetPosY = 25
        landBgOffsetPosY = -15
    end
    offsetPosY = offsetPosY + 200
    local bossIndex = self.landData.extendData.b[1]
    local troopsTb = airShipVoApi:getBossTroops(bossIndex)
    local posY = topBg:getPositionY() - topBg:getContentSize().height - offsetPosY
    for i = 1, 6 do
        local landBg = CCSprite:createWithSpriteFrameName("aso_landBg.png")
        if i == 1 or i == 4 then
            landBg:setPositionX(G_VisibleSizeWidth / 2 - landBg:getContentSize().width + 80)
        elseif i == 2 or i == 5 then
            landBg:setPositionX(G_VisibleSizeWidth / 2)
        elseif i == 3 or i == 6 then
            landBg:setPositionX(G_VisibleSizeWidth / 2 + landBg:getContentSize().width - 80)
        end
        landBg:setPositionY(posY - landBg:getContentSize().height / 2 - landBgOffsetPosY)
        if i ~= 3 then
            posY = landBg:getPositionY()
        else
            posY = landBg:getPositionY() + 1.5 * landBg:getContentSize().height + ((G_getIphoneType() == G_iphone4) and 155 or 250)
        end
        self.bgLayer:addChild(landBg, 1)
        local numberSp = CCSprite:createWithSpriteFrameName("aso_number" .. i .. ".png")
        numberSp:setPosition(ccp(landBg:getContentSize().width / 2, 15))
        landBg:addChild(numberSp, 1)
        if troopsTb and troopsTb[i] and troopsTb[i][1] then
            local tankId = tonumber(RemoveFirstChar(troopsTb[i][1]))
            local tankNum = troopsTb[i][2]
            local tankIcon = G_getTankPic(tankId)
            tankIcon:setScale(0.8)
            tankIcon:setPosition(ccp(landBg:getContentSize().width / 2, landBg:getContentSize().height / 2 + 10))
            landBg:addChild(tankIcon)
            local tankNameBg = CCSprite:createWithSpriteFrameName("aso_nameBg.png")
            tankNameBg:setPosition(ccp(landBg:getContentSize().width / 2, landBg:getContentSize().height - ((G_getIphoneType() == G_iphone4) and 15 or 0)))
            landBg:addChild(tankNameBg, 1)
            local tankNumLb = GetTTFLabel(tostring(tankNum), 18)
            tankNumLb:setPosition(ccp(20, tankNameBg:getContentSize().height / 2 + 5))
            tankNameBg:addChild(tankNumLb)
            local tankNameLb = GetTTFLabel(getlocal(tankCfg[tankId].name), 18)
            tankNameLb:setAnchorPoint(ccp(0, 0.5))
            tankNameLb:setPosition(ccp(55, tankNameBg:getContentSize().height / 2 + 5))
            tankNameBg:addChild(tankNameLb)
        else
            local lockSp = CCSprite:createWithSpriteFrameName("aso_lock.png")
            lockSp:setPosition(ccp(landBg:getContentSize().width / 2, landBg:getContentSize().height / 2 + 10))
            landBg:addChild(lockSp)
        end
    end
    
    local atkNumBg = LuaCCScale9Sprite:createWithSpriteFrameName("aso_tipsBg.png", CCRect(146, 25, 2, 3), function()end)
    atkNumBg:setContentSize(CCSizeMake(405, (G_getIphoneType() == G_iphone4) and 80 or 110))
    atkNumBg:setAnchorPoint(ccp(0.5, 0))
    atkNumBg:setPosition(ccp(G_VisibleSizeWidth / 2, (G_getIphoneType() == G_iphone4) and 70 or 100))
    self.bgLayer:addChild(atkNumBg, 1)
    local numBg = CCSprite:createWithSpriteFrameName("aso_tipsTitleBg.png")
    numBg:setAnchorPoint(ccp(0.5, 1))
    numBg:setPosition(ccp(atkNumBg:getContentSize().width / 2, atkNumBg:getContentSize().height))
    atkNumBg:addChild(numBg)
    local curAttackNum = airShipVoApi:getBossCurAttackNum()
    local maxAttackNum = airShipVoApi:getBossMaxAttackNum()
    local attackNumLb = GetTTFLabel(getlocal("airShip_attackNum"), 16)
    local attackNumLb1 = GetTTFLabel(tostring(curAttackNum), 16)
    local attackNumLb2 = GetTTFLabel("/" .. maxAttackNum, 16)
    attackNumLb1:setColor((curAttackNum > 0) and G_ColorGreen or G_ColorRed)
    local buyBtn, numLbFirsPosX
    if curAttackNum < maxAttackNum then
        buyBtn = LuaCCSprite:createWithSpriteFrameName("believerAddBtn.png", function()
            if airShipVoApi:getBossCurAttackNum() < maxAttackNum then
                local needGold = airShipVoApi:getBossAttackOfBuyCost()
                local rewardAtkNum = airShipVoApi:getBossAttackOfBuyNum()
                G_showSureAndCancle(getlocal("airShip_buyAttackNumTips", {needGold, rewardAtkNum}), function()
                    airShipVoApi:requestBuyAttackNum(function()
                        playerVoApi:setGems(playerVoApi:getGems() - needGold)
                        self:refreshAttackNumUI()
                    end)
                end)
            end
        end)
        buyBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        numLbFirsPosX = (numBg:getContentSize().width - (attackNumLb:getContentSize().width + attackNumLb1:getContentSize().width + attackNumLb2:getContentSize().width + 10 + buyBtn:getContentSize().width)) / 2
        buyBtn:setColor(ccc3(135, 253, 139))
        numBg:addChild(buyBtn)
        self.buyBtn = buyBtn
    else
        numLbFirsPosX = (numBg:getContentSize().width - (attackNumLb:getContentSize().width + attackNumLb1:getContentSize().width + attackNumLb2:getContentSize().width)) / 2
    end
    attackNumLb:setAnchorPoint(ccp(0, 0.5))
    attackNumLb1:setAnchorPoint(ccp(0, 0.5))
    attackNumLb2:setAnchorPoint(ccp(0, 0.5))
    attackNumLb:setPosition(ccp(numLbFirsPosX, numBg:getContentSize().height / 2))
    attackNumLb1:setPosition(ccp(attackNumLb:getPositionX() + attackNumLb:getContentSize().width, numBg:getContentSize().height / 2))
    attackNumLb2:setPosition(ccp(attackNumLb1:getPositionX() + attackNumLb1:getContentSize().width, numBg:getContentSize().height / 2))
    numBg:addChild(attackNumLb)
    numBg:addChild(attackNumLb1)
    numBg:addChild(attackNumLb2)
    if buyBtn then
        buyBtn:setAnchorPoint(ccp(0, 0.5))
        buyBtn:setPosition(ccp(attackNumLb2:getPositionX() + attackNumLb2:getContentSize().width + 10, numBg:getContentSize().height / 2))
    end
    self.attackNumLb = attackNumLb
    self.attackNumLb1 = attackNumLb1
    self.attackNumLb2 = attackNumLb2
    local recoverTimer = airShipVoApi:getBossAtkRecoverTimer()
    if recoverTimer then
        local timerFontSize = (G_getIphoneType() == G_iphone4) and 20 or 22
        local recoverTimeLb = GetTTFLabelWrap(getlocal("airShip_recoverTime") .. GetTimeStr(recoverTimer), 22, CCSizeMake(atkNumBg:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        recoverTimeLb:setPosition(ccp(atkNumBg:getContentSize().width / 2, atkNumBg:getContentSize().height / 2))
        recoverTimeLb:setColor(G_ColorRed)
        atkNumBg:addChild(recoverTimeLb)
        self.recoverTimeLb = recoverTimeLb
    end
    local function onClickAttack(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local curAttackNum = airShipVoApi:getBossCurAttackNum()
        local atkNum
        if tag == 101 then
            atkNum = 1
        elseif tag == 102 then
            local maxAttackNum = airShipVoApi:getBossMaxAttackNum()
            atkNum = (curAttackNum == 0 or curAttackNum > maxAttackNum) and maxAttackNum or curAttackNum
        end
        if atkNum then
            if curAttackNum < atkNum then
                local needGold = airShipVoApi:getBossAttackOfBuyCost()
                local rewardAtkNum = airShipVoApi:getBossAttackOfBuyNum()
                G_showSureAndCancle(getlocal("backstage65016") .. getlocal("airShip_buyAttackNumTips", {needGold, rewardAtkNum}), function()
                    airShipVoApi:requestBuyAttackNum(function()
                        playerVoApi:setGems(playerVoApi:getGems() - needGold)
                        self:refreshAttackNumUI()
                    end)
                end)
                return
            end
            local function onAttack()
                print("cjl ----->>> 攻击欧米伽小队:", atkNum)
                require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
                local td = tankAttackDialog:new(self.landData.type, self.landData, self.layerNum + 1, nil, atkNum)
                local tbArr = {getlocal("AEFFighting"), getlocal("dispatchCard"), getlocal("repair")}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("AEFFighting"), true, 7)
                sceneGame:addChild(dialog, self.layerNum + 1)
                self.parentLayer:close()
            end
            if atkNum > 1 then
                G_showSureAndCancle(getlocal("airShip_worldBossAttackTipsText"), onAttack)
            else
                onAttack()
            end
        end
    end
    local btnScale = 0.8
    local attackBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickAttack, 101, getlocal("airShip_worldAttackNum", {1}), 24 / btnScale)
    local attackNumN = (curAttackNum == 0 or curAttackNum > maxAttackNum) and maxAttackNum or curAttackNum
    local attackBtnN = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickAttack, 102, getlocal("airShip_worldAttackNum", {attackNumN}), 24 / btnScale, 10)
    attackBtn:setScale(btnScale)
    attackBtnN:setScale(btnScale)
    attackBtn:setAnchorPoint(ccp(1, 0))
    attackBtnN:setAnchorPoint(ccp(0, 0))
    local btnPosY = 35
    if G_getIphoneType() == G_iphone4 then
        btnPosY = 5
    end
    attackBtn:setPosition(ccp(G_VisibleSizeWidth / 2 - 55, btnPosY))
    attackBtnN:setPosition(ccp(G_VisibleSizeWidth / 2 + 55, btnPosY))
    local menuArr = CCArray:create()
    menuArr:addObject(attackBtn)
    menuArr:addObject(attackBtnN)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(btnMenu, 1)
    self.attackBtnNLabel = tolua.cast(attackBtnN:getChildByTag(10), "CCLabelTTF")
end

function worldAirShipTabOne:refreshAttackNumUI()
    if self then
        local maxAttackNum = airShipVoApi:getBossMaxAttackNum()
        local curAttackNum = airShipVoApi:getBossCurAttackNum()
        local attackNumLb1 = tolua.cast(self.attackNumLb1, "CCLabelTTF")
        local attackNumLb2 = tolua.cast(self.attackNumLb2, "CCLabelTTF")
        local buyBtn = tolua.cast(self.buyBtn, "CCSprite")
        if attackNumLb1 and attackNumLb2 then
            attackNumLb1:setString(tostring(curAttackNum))
            attackNumLb1:setColor((curAttackNum > 0) and G_ColorGreen or G_ColorRed)
            attackNumLb2:setPositionX(attackNumLb1:getPositionX() + attackNumLb1:getContentSize().width)
            if buyBtn then
                buyBtn:setPositionX(attackNumLb2:getPositionX() + attackNumLb2:getContentSize().width + 10)
                if curAttackNum >= maxAttackNum then
                    buyBtn:setVisible(false)
                end
            end
        end
        local attackBtnNLabel = tolua.cast(self.attackBtnNLabel, "CCLabelTTF")
        if attackBtnNLabel then
            local curMaxAttackNum = curAttackNum
            if curAttackNum == 0 or curAttackNum > maxAttackNum then
                curMaxAttackNum = maxAttackNum
            end
            attackBtnNLabel:setString(getlocal("airShip_worldAttackNum", {curMaxAttackNum}))
        end
    end
end

function worldAirShipTabOne:tick()
    if self then
        local recoverTimeLb = tolua.cast(self.recoverTimeLb, "CCLabelTTF")
        if recoverTimeLb then
            local recoverTimer = airShipVoApi:getBossAtkRecoverTimer()
            if recoverTimer then
                if recoverTimer >= 0 then
                    recoverTimeLb:setString(getlocal("airShip_recoverTime") .. GetTimeStr(recoverTimer))
                else
                    airShipVoApi:requestInit(function() self:refreshAttackNumUI() end, false)
                end
            else
                recoverTimeLb:removeFromParentAndCleanup(true)
                recoverTimeLb = nil
            end
        end
    end
end

function worldAirShipTabOne:dispose()
    self = nil
    spriteController:removePlist("public/squaredImgs.plist")
    spriteController:removeTexture("public/squaredImgs.png")
    spriteController:removePlist("public/airShip_omegaImages.plist")
    spriteController:removeTexture("public/airShip_omegaImages.png")
    spriteController:removePlist("public/acFlashSaleImage.plist")
    spriteController:removeTexture("public/acFlashSaleImage.png")
end
