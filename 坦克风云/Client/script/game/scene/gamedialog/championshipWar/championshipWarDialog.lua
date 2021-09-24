championshipWarDialog = commonDialog:new()

function championshipWarDialog:new(layerNum)
    local nc = {
        layerNum = layerNum
    }
    setmetatable(nc, self)
    self.__index = self
    
    spriteController:addPlist("public/championshipWar/championshipImage.plist")
    spriteController:addTexture("public/championshipWar/championshipImage.png")
    local function addPlist()
        spriteController:addPlist("public/newButton180711.plist")
        spriteController:addTexture("public/newButton180711.png")
    end
    G_addResource8888(addPlist)
    
    return nc
end

function championshipWarDialog:initData()
    self.itemData = {
        {
            title = getlocal("championshipWar_personal"),
            image = "csi_personal.png",
            isOpen = function (isShowTips)
                local state, time = championshipWarVoApi:getWarState()
                if state ~= 10 then
                    if isShowTips then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
                    end
                    do return false end
                end
                return true
            end,
            onClick = function()
                championshipWarVoApi:showPersonalDialog(self.layerNum + 1)
            end
        },
        {
            title = getlocal("market"),
            image = "csi_shop.png",
            isOpen = true,
            onClick = function()
                championshipWarVoApi:showShopDialog(self.layerNum + 1)
            end
        },
        {
            title = getlocal("championshipWar_alliance"),
            image = "csi_alliance.png",
            onGiftBoxClick = function()
                championshipWarVoApi:showRankRewardDialog(self.layerNum + 1)
            end,
            isOpen = function(isShowTips)
                local state, time = championshipWarVoApi:getWarState()
                if state > 10 and state < 40 then
                    if state == 20 then
                        if isShowTips == true then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_battle_listouting"), 30)
                        end
                        return false
                    else
                        if championshipWarVoApi:isAllianceCanJoinBattle() == false then --军团未到参赛资格
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_check_alliancewar_disable"), 30)
                            return false
                        end
                    end
                    return true
                end
                if isShowTips == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_allianceWar_nostart"), 30)
                end
                return false
            end,
            onClick = function()
                local function realShow()
                    championshipWarVoApi:showAllianceWarDialog(self.layerNum + 1)
                end
                championshipWarVoApi:championshipWarScheduleGet(realShow)
            end
        },
    }
end

function championshipWarDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local topBgHeight = 170
    if G_getIphoneType() == G_iphone5 then
        topBgHeight = 190
    elseif G_getIphoneType() == G_iphoneX then
        topBgHeight = 200
    end
    local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function()end)
    topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, topBgHeight))
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 92)
    self.bgLayer:addChild(topBg)
    
    local lightSp = CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5, 0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(topBg:getContentSize().width / 2, topBg:getContentSize().height - 40)
    topBg:addChild(lightSp)
    
    local nameStr = getlocal("championshipWar_gradeMatch", {championshipWarVoApi:getCurrentSeasonGrade()})
    local nameFontSize = 28
    local nameLb = GetTTFLabelWrap(nameStr, nameFontSize, CCSizeMake(320, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    nameLb:setAnchorPoint(ccp(0.5, 0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(topBg:getContentSize().width / 2, lightSp:getPositionY() + 10)
    topBg:addChild(nameLb)
    local nameLb2 = GetTTFLabel(nameStr, nameFontSize)
    local realNameW = nameLb2:getContentSize().width
    if realNameW > nameLb:getContentSize().width then
        realNameW = nameLb:getContentSize().width
    end
    for i = 1, 2 do
        local pointSp = CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX = 1
        local posX = topBg:getContentSize().width / 2 - (realNameW / 2 + 20)
        local pointX = -7
        if i == 2 then
            anchorX = 0
            posX = topBg:getContentSize().width / 2 + (realNameW / 2 + 20)
            pointX = 15
        end
        pointSp:setAnchorPoint(ccp(anchorX, 0.5))
        pointSp:setPosition(posX, nameLb:getPositionY())
        topBg:addChild(pointSp)
        
        local pointLineSp = CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0, 0.5))
        pointLineSp:setPosition(pointX, pointSp:getContentSize().height / 2)
        pointSp:addChild(pointLineSp)
        if i == 1 then
            pointLineSp:setRotation(180)
        end
    end
    
    local topContentH = topBg:getContentSize().height - nameLb:getContentSize().height - 20
    
    local allianceIcon = CCSprite:createWithSpriteFrameName("helpAlliance.png")
    allianceIcon:setPosition(10 + allianceIcon:getContentSize().width * allianceIcon:getScale() / 2, topContentH - allianceIcon:getContentSize().height * allianceIcon:getScale() / 2)
    if base.isAf == 1 then
        allianceIcon:setVisible(false)
    end
    topBg:addChild(allianceIcon)
    local alliance = allianceVoApi:getSelfAlliance()
    if base.isAf == 1 then
        local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
        local allianceIconNew = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.45)
        allianceIconNew:setPosition(10 + allianceIcon:getContentSize().width * allianceIcon:getScale() / 2, topContentH - allianceIcon:getContentSize().height * allianceIcon:getScale() / 2)
        topBg:addChild(allianceIconNew)
    end
    local allianceNameLbW = allianceIcon:getContentSize().width * allianceIcon:getScale() + 20
    local allianceName = GetTTFLabelWrap(alliance.name, 24, CCSizeMake(allianceNameLbW, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    allianceName:setAnchorPoint(ccp(0.5, 1))
    if base.isAf == 1 then
        allianceName:setPosition(allianceIcon:getPositionX(), allianceIcon:getPositionY() - allianceIcon:getContentSize().height * allianceIcon:getScale() / 2 - 18)
    else
        allianceName:setPosition(allianceIcon:getPositionX(), allianceIcon:getPositionY() - allianceIcon:getContentSize().height * allianceIcon:getScale() / 2)
    end
    topBg:addChild(allianceName)
    
    local function touchSearchHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        championshipWarVoApi:showRankDialog(self.layerNum + 1)
    end
    local searchBtn = GetButtonItem("csi_searchBtn.png", "csi_searchBtn_down.png", "csi_searchBtn.png", touchSearchHandler)
    local searchMenu = CCMenu:createWithItem(searchBtn)
    searchMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    searchMenu:setPosition(topBg:getContentSize().width - 20 - searchBtn:getContentSize().width / 2, topContentH / 2)
    topBg:addChild(searchMenu)
    
    local barWidth = topBg:getContentSize().width - allianceIcon:getContentSize().width * allianceIcon:getScale() - searchBtn:getContentSize().width - 50 - 6
    local barHeight = 26
    local progressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("csi_progressBar.png"))
    progressBar:setMidpoint(ccp(0, 1))
    progressBar:setBarChangeRate(ccp(1, 0))
    progressBar:setType(kCCProgressTimerTypeBar)
    progressBar:setScaleX(barWidth / progressBar:getContentSize().width)
    progressBar:setScaleY(barHeight / progressBar:getContentSize().height)
    local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
    progressBarBg:setContentSize(CCSizeMake(barWidth + 6, barHeight + 5))
    progressBarBg:setAnchorPoint(ccp(0, 0.5))
    progressBarBg:setPosition(allianceIcon:getPositionX() + allianceIcon:getContentSize().width * allianceIcon:getScale() / 2 + 5, topContentH / 2 - 15)
    progressBar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressBar)
    topBg:addChild(progressBarBg)
    local cfg = championshipWarVoApi:getWarCfg()
    local apply = championshipWarVoApi:getApply()
    progressBar:setPercentage(apply / cfg.allianceJoinNum * 100)
    local progressLb = GetTTFLabel(apply .. "/" .. cfg.allianceJoinNum, 22)
    progressLb:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressLb, 1)
    local descStr, descLbColor = getlocal("championshipWar_dissatisfy_apply"), G_ColorWhite
    if apply >= cfg.allianceJoinNum then
        descStr = getlocal("championshipWar_sureJoinMatch")
        descLbColor = G_ColorRed
        progressLb:setColor(descLbColor)
    end
    local descLbBottomSpace = 0
    if G_getIphoneType() == G_iphone5 then
        descLbBottomSpace = 15
    elseif G_getIphoneType() == G_iphoneX then
        descLbBottomSpace = 20
    end
    local descLb = GetTTFLabelWrap(descStr, 24, CCSizeMake(progressBarBg:getContentSize().width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
    descLb:setAnchorPoint(ccp(0, 0))
    descLb:setPosition(progressBarBg:getPositionX(), progressBarBg:getPositionY() + progressBarBg:getContentSize().height / 2 + descLbBottomSpace)
    descLb:setColor(descLbColor)
    topBg:addChild(descLb)
    
    self.eventListener = function(evetn, data)
        local apply = championshipWarVoApi:getApply()
        progressBar:setPercentage(apply / cfg.allianceJoinNum * 100)
        progressLb:setString(apply .. "/" .. cfg.allianceJoinNum)
        local descStr = getlocal("championshipWar_dissatisfy_apply")
        if apply >= cfg.allianceJoinNum then
            descStr = getlocal("championshipWar_sureJoinMatch")
            progressLb:setColor(G_ColorRed)
            descLb:setColor(G_ColorRed)
        end
        descLb:setString(descStr)
        if self and self.battleLb then
            if championshipWarVoApi:isApplyAllianceWar() == true then
                self.battleLb:setString(getlocal("championshipWar_grantGoldTips"))
                self.battleLb:setColor(G_ColorGreen)
                if self.goldSp then
                    self.goldSp:setVisible(false)
                end
            end
        end
    end
    eventDispatcher:addEventListener("championshipWarDialog.refreshApplyInfo", self.eventListener)
    
    self:initCenter(topBg)
    
    self:initBottom()
    
    self.popFlag = false
end

function championshipWarDialog:initCenter(topBg)
    local leftFrameBg = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    local bottomSpace = 210
    if G_getIphoneType() == G_iphone5 then
        bottomSpace = 280
    elseif G_getIphoneType() == G_iphoneX then
        bottomSpace = 300
    end
    local centerHeight = topBg:getPositionY() - topBg:getContentSize().height - bottomSpace
    if centerHeight < leftFrameBg:getContentSize().height + 20 then
        centerHeight = leftFrameBg:getContentSize().height + 20
    end
    local centerSize = CCSizeMake(G_VisibleSizeWidth - 40, centerHeight)
    local centerBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    centerBg:setContentSize(centerSize)
    centerBg:setAnchorPoint(ccp(0.5, 1))
    centerBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height - 15)
    self.bgLayer:addChild(centerBg)
    
    local bgTexture = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png", CCRect(5, 5, 1, 1), function ()end)
    bgTexture:setContentSize(CCSizeMake(centerSize.width - 6, centerSize.height - 6))
    bgTexture:setPosition(centerSize.width / 2, centerSize.height / 2)
    centerBg:addChild(bgTexture)
    
    leftFrameBg:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg:setPosition(10, centerSize.height / 2)
    centerBg:addChild(leftFrameBg)
    local leftFrame = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrame:setAnchorPoint(ccp(0, 0.5))
    leftFrame:setPosition(2, centerSize.height / 2)
    centerBg:addChild(leftFrame)
    
    local rightFrameBg = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg:setFlipX(true)
    -- rightFrameBg:setFlipY(true)
    rightFrameBg:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg:setPosition(centerSize.width - 10, centerSize.height / 2)
    centerBg:addChild(rightFrameBg)
    local rightFrame = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrame:setFlipX(true)
    rightFrame:setAnchorPoint(ccp(1, 0.5))
    rightFrame:setPosition(centerSize.width - 2, centerSize.height / 2)
    centerBg:addChild(rightFrame)
    
    local function createCard(imageName)
        local cardSize = CCSizeMake(454, 312)
        if G_getIphoneType() == G_iphoneX then
            cardSize = CCSizeMake(530, 364)
        end
        local personalBg, titleBg, titleLb = G_getNewDialogBg3(cardSize, "", 25, nil, self.layerNum, nil, nil, nil, true)
        local jpgBg = CCSprite:createWithSpriteFrameName(imageName)
        jpgBg:setAnchorPoint(ccp(0.5, 1))
        jpgBg:setPosition(personalBg:getContentSize().width / 2, personalBg:getContentSize().height - 40)
        if G_getIphoneType() == G_iphoneX then
            jpgBg:setScale((personalBg:getContentSize().width - 10) / jpgBg:getContentSize().width)
        end
        jpgBg:setTag(111)
        personalBg:addChild(jpgBg)
        local giftBox = CCSprite:createWithSpriteFrameName("friendBtn.png")
        giftBox:setAnchorPoint(ccp(1, 1))
        giftBox:setPosition(personalBg:getContentSize().width, personalBg:getContentSize().height)
        giftBox:setTag(112)
        personalBg:addChild(giftBox)
        local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(37, 1, 2, 21), function ()end)
        mLine:setPosition(ccp(personalBg:getContentSize().width / 2, 25))
        mLine:setContentSize(CCSizeMake(personalBg:getContentSize().width - 10, mLine:getContentSize().height))
        personalBg:addChild(mLine)
        local shadeSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        shadeSp:setContentSize(personalBg:getContentSize())
        shadeSp:setPosition(personalBg:getContentSize().width / 2, personalBg:getContentSize().height / 2)
        shadeSp:setTag(110)
        personalBg:addChild(shadeSp, 10)
        return personalBg, titleLb
    end
    
    local touchLayer = CCLayer:create()
    -- local touchLayer = CCLayerColor:create(ccc4(255, 0, 0, 100))
    touchLayer:setContentSize(centerSize)
    
    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(centerSize.width - 6, centerSize.height - 6))
    clipper:setAnchorPoint(ccp(0.5, 0.5))
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    clipper:setPosition(centerBg:getPositionX(), centerBg:getPositionY() - centerSize.height / 2)
    self.bgLayer:addChild(clipper)
    
    local itemSpace = 120
    local itemScale = 0.77
    local itemOpacity = 185
    if G_getIphoneType() == G_iphone5 then
        itemSpace = 140
    elseif G_getIphoneType() == G_iphoneX then
        itemSpace = 160
    end
    local midPosY = clipper:getContentSize().height / 2
    local upPosY = midPosY + itemSpace
    local downPosY = midPosY - itemSpace
    
    local upSp, upTitleLb = createCard("csi_personal.png")
    clipper:addChild(upSp)
    local midSp, midTitleLb = createCard("csi_personal.png")
    clipper:addChild(midSp)
    local downSp, downTitleLb = createCard("csi_personal.png")
    clipper:addChild(downSp)
    
    local state, time = championshipWarVoApi:getWarState()
    if state >= 20 and state <= 30 then --军团战期间
        self.currentShowIndex = 3
    else --个人战期间
        self.currentShowIndex = 1
    end
    self:initData()
    local itemSize = SizeOfTable(self.itemData)
    
    local function resetItem()
        
        local midData = self.itemData[self.currentShowIndex]
        local upData = self.itemData[self.currentShowIndex - 1]
        if self.currentShowIndex - 1 <= 0 then
            upData = self.itemData[itemSize]
        end
        local downData = self.itemData[self.currentShowIndex + 1]
        if self.currentShowIndex + 1 > itemSize then
            downData = self.itemData[1]
        end
        
        local upGiftBox = upSp:getChildByTag(112)
        local midGiftBox = midSp:getChildByTag(112)
        local downGiftBox = downSp:getChildByTag(112)
        if upData.onGiftBoxClick then
            upGiftBox:setVisible(true)
        else
            upGiftBox:setVisible(false)
        end
        if midData.onGiftBoxClick then
            midGiftBox:setVisible(true)
        else
            midGiftBox:setVisible(false)
        end
        if downData.onGiftBoxClick then
            downGiftBox:setVisible(true)
        else
            downGiftBox:setVisible(false)
        end
        
        upTitleLb:setString(upData.title)
        midTitleLb:setString(midData.title)
        downTitleLb:setString(downData.title)
        local upJpgBg = upSp:getChildByTag(111)
        local midJpgBg = midSp:getChildByTag(111)
        local downJpgBg = downSp:getChildByTag(111)
        if upJpgBg then
            upJpgBg = tolua.cast(upJpgBg, "CCSprite")
            upJpgBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(upData.image))
        end
        if midJpgBg then
            midJpgBg = tolua.cast(midJpgBg, "CCSprite")
            midJpgBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(midData.image))
        end
        if downJpgBg then
            downJpgBg = tolua.cast(downJpgBg, "CCSprite")
            downJpgBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(downData.image))
        end
        
        midSp:setPosition(clipper:getContentSize().width / 2, clipper:getContentSize().height / 2)
        upSp:setPosition(clipper:getContentSize().width / 2, midSp:getPositionY() + itemSpace)
        downSp:setPosition(clipper:getContentSize().width / 2, midSp:getPositionY() - itemSpace)
        midSp:setScale(1)
        upSp:setScale(itemScale)
        downSp:setScale(itemScale)
        local upShade = upSp:getChildByTag(110)
        local midShade = midSp:getChildByTag(110)
        local downShade = downSp:getChildByTag(110)
        if midShade then
            midShade = tolua.cast(midShade, "CCSprite")
            midShade:setOpacity(0)
        end
        if upShade then
            upShade = tolua.cast(upShade, "CCSprite")
            upShade:setOpacity(itemOpacity)
        end
        if downShade then
            downShade = tolua.cast(downShade, "CCSprite")
            downShade:setOpacity(itemOpacity)
        end
        clipper:reorderChild(upSp, 1)
        clipper:reorderChild(midSp, 3)
        clipper:reorderChild(downSp, 1)
    end
    resetItem()
    
    local giftBoxIsClick = false
    local isRunningAction = false
    local isClick = false
    local touchArray = {}
    local beganPos, movedPos
    local isMoved = nil
    local function touchHandler(fn, x, y, touch)
        if fn == "began" then
            if isRunningAction == true then
                return false
            end
            local pos = touchLayer:getParent():convertToWorldSpace(ccp(touchLayer:getPositionX(), touchLayer:getPositionY()))
            if x >= pos.x and x <= pos.x + touchLayer:getContentSize().width and y >= pos.y and y <= pos.y + touchLayer:getContentSize().height then
                table.insert(touchArray, touch)
                if SizeOfTable(touchArray) > 1 then
                    touchArray = {}
                    return false
                else
                    if isClick == false and x >= pos.x + (touchLayer:getContentSize().width - midSp:getContentSize().width) / 2 and
                        x <= pos.x + midSp:getPositionX() + midSp:getContentSize().width / 2 and
                        y >= pos.y + (touchLayer:getContentSize().height - midSp:getContentSize().height) / 2 and
                        y <= pos.y + midPosY + midSp:getContentSize().height / 2 then
                        isClick = true
                        local giftBox = midSp:getChildByTag(112)
                        if giftBox and x >= pos.x + (touchLayer:getContentSize().width - midSp:getContentSize().width) / 2 + (midSp:getContentSize().width - giftBox:getContentSize().width) and
                            y >= pos.y + (touchLayer:getContentSize().height - midSp:getContentSize().height) / 2 + (midSp:getContentSize().height - giftBox:getContentSize().height) then
                            giftBoxIsClick = true
                        end
                    end
                    beganPos = ccp(x, y)
                    -- print("cjl ------->>>  began", x, y)
                    return true
                end
            end
            return false
        elseif fn == "moved" then
            -- if not (beganPos.x == x and beganPos.y == y and isMoved == nil) then
            if (not (beganPos.x == x and beganPos.y == y and isMoved == nil)) and math.abs(y - beganPos.y) > 3 then --针对安卓某些机型做的3像素偏移
                isMoved = true
                isClick = false
                local pos = touchLayer:getParent():convertToWorldSpace(ccp(touchLayer:getPositionX(), touchLayer:getPositionY()))
                if x >= pos.x and x <= pos.x + touchLayer:getContentSize().width and y >= pos.y and y <= pos.y + touchLayer:getContentSize().height then
                    -- print("cjl ------->>>  moved", x, y)
                    
                    if movedPos == nil then
                        movedPos = beganPos
                    end
                    local moveDis = ccpSub(ccp(x, y), movedPos)
                    
                    if math.abs(y - beganPos.y) >= itemSpace then
                        moveDis.y = 0
                    end
                    
                    upSp:setPositionY(upSp:getPositionY() + moveDis.y)
                    midSp:setPositionY(midSp:getPositionY() + moveDis.y)
                    downSp:setPositionY(downSp:getPositionY() + moveDis.y)
                    local midMoveDis = midSp:getPositionY() - midPosY
                    local upMoveDis = upSp:getPositionY() - upPosY
                    local downMoveDis = downSp:getPositionY() - downPosY
                    local midScale = math.abs(midMoveDis) / itemSpace * (1 - itemScale)
                    local upScale = upMoveDis / itemSpace * (1 - itemScale)
                    local downScale = downMoveDis / itemSpace * (1 - itemScale)
                    midSp:setScale(1 - midScale)
                    upSp:setScale(itemScale - upScale)
                    downSp:setScale(itemScale + downScale)
                    
                    local upShade = upSp:getChildByTag(110)
                    local midShade = midSp:getChildByTag(110)
                    local downShade = downSp:getChildByTag(110)
                    if midShade then
                        midShade = tolua.cast(midShade, "CCSprite")
                        midShade:setOpacity(math.abs(midMoveDis) / itemSpace * itemOpacity)
                    end
                    if upShade then
                        upShade = tolua.cast(upShade, "CCSprite")
                        upShade:setOpacity(math.abs(itemOpacity - math.abs(upMoveDis) / itemSpace * itemOpacity))
                    end
                    if downShade then
                        downShade = tolua.cast(downShade, "CCSprite")
                        downShade:setOpacity(math.abs(itemOpacity - math.abs(downMoveDis) / itemSpace * itemOpacity))
                    end
                    
                    if math.abs(midMoveDis) > itemSpace / 2 then
                        if midMoveDis > 0 then --往上滑
                            clipper:reorderChild(upSp, 1)
                            clipper:reorderChild(midSp, 2)
                            clipper:reorderChild(downSp, 3)
                        else --往下滑
                            clipper:reorderChild(upSp, 3)
                            clipper:reorderChild(midSp, 2)
                            clipper:reorderChild(downSp, 1)
                        end
                    else
                        clipper:reorderChild(upSp, 1)
                        clipper:reorderChild(midSp, 3)
                        clipper:reorderChild(downSp, 1)
                    end
                    
                    movedPos = ccp(x, y)
                end
            end
        elseif fn == "ended" then
            -- print("cjl ------->>>  ended", x, y)
            
            isMoved = nil
            touchArray = {}
            movedPos = nil
            
            if isClick == true then
                if giftBoxIsClick == true and type(self.itemData[self.currentShowIndex].onGiftBoxClick) == "function" then
                    self.itemData[self.currentShowIndex].onGiftBoxClick()
                else
                    if (type(self.itemData[self.currentShowIndex].isOpen) == "function" and self.itemData[self.currentShowIndex].isOpen(true) == true) or self.itemData[self.currentShowIndex].isOpen == true then
                        if type(self.itemData[self.currentShowIndex].onClick) == "function" then
                            self.itemData[self.currentShowIndex].onClick()
                        end
                    end
                end
            else
                local moveDis = midSp:getPositionY() - midPosY
                if moveDis == 0 then
                    resetItem()
                else
                    isRunningAction = true
                    local upMovePosY, midMovePosY, downMovePosY
                    if math.abs(moveDis) > itemSpace / 2 then
                        if moveDis > 0 then --往上滑
                            self.currentShowIndex = self.currentShowIndex + 1
                            if self.currentShowIndex > itemSize then
                                self.currentShowIndex = 1
                            end
                            upMovePosY = upPosY + itemSpace
                            midMovePosY = midPosY + itemSpace
                            downMovePosY = downPosY + itemSpace
                        else --往下滑
                            self.currentShowIndex = self.currentShowIndex - 1
                            if self.currentShowIndex <= 0 then
                                self.currentShowIndex = itemSize
                            end
                            upMovePosY = upPosY - itemSpace
                            midMovePosY = midPosY - itemSpace
                            downMovePosY = downPosY - itemSpace
                        end
                    else
                        upMovePosY, midMovePosY, downMovePosY = upPosY, midPosY, downPosY
                    end
                    
                    local speed = 1000 --速度
                    local upTime = math.abs((upMovePosY - upSp:getPositionY()) / speed)
                    local midTime = math.abs((midMovePosY - midSp:getPositionY()) / speed)
                    local downTime = math.abs((downMovePosY - downSp:getPositionY()) / speed)
                    local upMoveTo = CCMoveTo:create(upTime, CCPointMake(upSp:getPositionX(), upMovePosY))
                    local midMoveTo = CCMoveTo:create(midTime, CCPointMake(midSp:getPositionX(), midMovePosY))
                    local downMoveTo = CCMoveTo:create(downTime, CCPointMake(downSp:getPositionX(), downMovePosY))
                    local function updateFunc()
                        upSp:stopAllActions()
                        midSp:stopAllActions()
                        downSp:stopAllActions()
                        resetItem()
                        isRunningAction = false
                    end
                    upSp:runAction(upMoveTo)
                    midSp:runAction(CCSequence:createWithTwoActions(midMoveTo, CCCallFunc:create(updateFunc)))
                    downSp:runAction(downMoveTo)
                end
            end
            isClick = false
            giftBoxIsClick = false
        else
            -- print("cjl ------->>>  fn", fn)
        end
    end
    touchLayer:setTouchEnabled(true)
    touchLayer:setBSwallowsTouches(true)
    touchLayer:registerScriptTouchHandler(touchHandler, false, -(self.layerNum - 1) * 20 - 3, true)
    centerBg:addChild(touchLayer)
end

function championshipWarDialog:initBottom()
    local btnBottomSpace = 40
    if G_getIphoneType() == G_iphone5 then
        btnBottomSpace = 65
    elseif G_getIphoneType() == G_iphoneX then
        btnBottomSpace = 75
    end
    local function touchShopHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- print("cjl --------->>> 商店")
        championshipWarVoApi:showShopDialog(self.layerNum + 1)
    end
    local btnScale = 0.8
    local shopBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touchShopHandler, nil, getlocal("market"), 24 / btnScale)
    shopBtn:setScale(btnScale)
    local shopMenu = CCMenu:createWithItem(shopBtn)
    shopMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    shopMenu:setPosition(G_VisibleSizeWidth / 2 - shopBtn:getContentSize().width * btnScale / 2 - 50, btnBottomSpace + shopBtn:getContentSize().height * btnScale / 2)
    self.bgLayer:addChild(shopMenu)
    
    local function touchBattleHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local state, _ = championshipWarVoApi:getWarState()
        if state == 30 then
            -- print("cjl --------->>> 领奖")
            local flag, rewardState = championshipWarVoApi:isCanReceiveAllianceWarReward()
            if flag == true or (flag == false and rewardState == 3) then
                championshipWarVoApi:showSettleDialog(self.layerNum + 1)
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_reward_disable"), 30)
            end
        else
            if state ~= 10 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notset_troop"), 30)
                do return end
            end
            -- print("cjl --------->>> 征战 设置部队，报名军团战")
            championshipWarVoApi:showAllianceWarTroopDialog(self.layerNum + 1)
        end
    end
    local battleBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", touchBattleHandler, nil, getlocal("ltzdz_campaign"), 24 / btnScale, 10)
    battleBtn:setScale(btnScale)
    local battleMenu = CCMenu:createWithItem(battleBtn)
    battleMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    battleMenu:setPosition(G_VisibleSizeWidth / 2 + battleBtn:getContentSize().width * btnScale / 2 + 50, btnBottomSpace + battleBtn:getContentSize().height * btnScale / 2)
    self.bgLayer:addChild(battleMenu)
    self.battleBtn = battleBtn

    local glod = 0
    local cfgWar = championshipWarVoApi:getWarCfg()
    local rewardItem = FormatItem(cfgWar.settingTroopsReward[2])
    if rewardItem and rewardItem[1] and rewardItem[1].num then
        glod = rewardItem[1].num
    end
    if glod > 0 then
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        local battleLb = GetTTFLabel(getlocal("championshipWar_settingTroopTips")..tostring(glod), 20)
        if championshipWarVoApi:isApplyAllianceWar() == true then
            battleLb:setString(getlocal("championshipWar_grantGoldTips"))
            battleLb:setColor(G_ColorGreen)
            goldSp:setVisible(false)
        else
            battleLb:setColor(G_ColorYellowPro)
        end
        battleLb:setAnchorPoint(ccp(0.5, 1))
        battleLb:setPosition(battleMenu:getPositionX(), battleMenu:getPositionY() - battleBtn:getContentSize().height / 2)
        self.bgLayer:addChild(battleLb)
        goldSp:setAnchorPoint(ccp(0, 0.5))
        goldSp:setPosition(battleLb:getPositionX() + battleLb:getContentSize().width / 2, battleLb:getPositionY() - battleLb:getContentSize().height / 2)
        self.bgLayer:addChild(goldSp)
        self.battleLb = battleLb
        self.goldSp = goldSp
    end
    
    local lineBottomSpace = 10
    if G_getIphoneType() == G_iphone5 then
        lineBottomSpace = 45
    elseif G_getIphoneType() == G_iphoneX then
        lineBottomSpace = 55
    end
    local line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(37, 1, 2, 21), function ()end)
    line:setContentSize(CCSizeMake(G_VisibleSizeWidth, line:getContentSize().height))
    line:setAnchorPoint(ccp(0.5, 0))
    line:setPosition(ccp(G_VisibleSizeWidth / 2, battleMenu:getPositionY() + battleBtn:getContentSize().height * btnScale / 2 + lineBottomSpace))
    self.bgLayer:addChild(line)
    
    local state, time = championshipWarVoApi:getWarState()
    if state == 30 then
        local btnLb = tolua.cast(self.battleBtn:getChildByTag(10), "CCLabelTTF")
        btnLb:setString(getlocal("activity_continueRecharge_reward"))
        if self.battleLb then
            self.battleLb:setVisible(false)
        end
        if self.goldSp then
            self.goldSp:setVisible(false)
        end
    end
    local lbStr = ""
    if state == 10 then
        lbStr = getlocal("championshipWar_startSurplusTime")
    elseif state == 21 then
        lbStr = getlocal("championshipWar_rankTime", {8})
    elseif state == 22 then
        lbStr = getlocal("championshipWar_rankTime", {4})
    elseif state == 23 then
        lbStr = getlocal("championshipWar_rankTime", {2})
    elseif state == 24 then
        lbStr = getlocal("championshipWar_championTime")
    elseif state == 30 or state == 20 then
        lbStr = getlocal("championshipWar_endSurplusTime")
    end
    local timeLb = GetTTFLabel(tostring(G_formatActiveDate(time)), 20)
    timeLb:setPosition(G_VisibleSizeWidth / 2, line:getPositionY() + 10 + timeLb:getContentSize().height / 2)
    timeLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(timeLb)
    local timeTitleLb = GetTTFLabel(lbStr, 20)
    timeTitleLb:setAnchorPoint(ccp(0.5, 0))
    timeTitleLb:setPosition(timeLb:getPositionX(), timeLb:getPositionY() + timeLb:getContentSize().height / 2 + 2)
    self.bgLayer:addChild(timeTitleLb)
    self.timeTitleLb = timeTitleLb
    self.timeLb = timeLb
    
    local function onTouchInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local warCfg = championshipWarVoApi:getWarCfg()
        -- print("cjl -------->>> 详情")
        local args = {
            [1] = {tostring(1) .. ":"..warCfg.tankeTransRate},
            [2] = {(warCfg.attrReduceRate * 100) .. "%%"},
            [4] = {warCfg.warGradeLevel},
            [5] = {warCfg.warGradelvlUp[2] - warCfg.warGradelvlUp[1] + 1, warCfg.warGradeLvlDown[2] - warCfg.warGradeLvlDown[1] + 1},
            [7] = {warCfg.winScore},
        }
        local textFormatTb = {
            [1] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}},
            [2] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}},
            [4] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}},
            [5] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}},
            [7] = {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}},
        }
        local tabStr = {}
        for k = 1, 12 do
            local str = getlocal("championshipWar_tip"..k, args[k])
            table.insert(tabStr, str)
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onTouchInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(G_VisibleSizeWidth - 35 - infoBtn:getContentSize().width / 2, line:getPositionY() + 10 + infoBtn:getContentSize().height / 2))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoMenu)
end

function championshipWarDialog:tick()
    if self then
        if self.timeLb and self.timeTitleLb and tolua.cast(self.timeLb, "CCLabelTTF") and tolua.cast(self.timeTitleLb, "CCLabelTTF") then
            local timeLb = tolua.cast(self.timeLb, "CCLabelTTF")
            local timeTitleLb = tolua.cast(self.timeTitleLb, "CCLabelTTF")
            local state, time = championshipWarVoApi:getWarState()
            local lbStr = ""
            if state == 10 then
                lbStr = getlocal("championshipWar_startSurplusTime")
            elseif state == 21 then
                lbStr = getlocal("championshipWar_rankTime", {8})
            elseif state == 22 then
                lbStr = getlocal("championshipWar_rankTime", {4})
            elseif state == 23 then
                lbStr = getlocal("championshipWar_rankTime", {2})
            elseif state == 24 then
                lbStr = getlocal("championshipWar_championTime")
            elseif state == 30 or state == 20 then
                lbStr = getlocal("championshipWar_endSurplusTime")
            end
            timeTitleLb:setString(lbStr)
            if lbStr == "" then
                timeLb:setString("")
            else
                timeLb:setString(tostring(G_formatActiveDate(time)))
            end
            if state == 30 and self.battleBtn then
                local btnLb = tolua.cast(self.battleBtn:getChildByTag(10), "CCLabelTTF")
                btnLb:setString(getlocal("activity_continueRecharge_reward"))
                if self.battleLb then
                    self.battleLb:setVisible(false)
                end
                if self.goldSp then
                    self.goldSp:setVisible(false)
                end
            end
        end
        if self.popFlag == false and championshipWarVoApi:isCanReceiveAllianceWarReward() == true then
            local state = championshipWarVoApi:getWarState()
            if state == 30 then --已到结算期
                local function callback()
                    self.popFlag = true
                    championshipWarVoApi:showSettleDialog(self.layerNum + 4)
                end
                championshipWarVoApi:championshipWarGet(callback, false)
            end
        end
    end
end

function championshipWarDialog:dispose()
    eventDispatcher:removeEventListener("championshipWarDialog.refreshApplyInfo", self.eventListener)
    self.popFlag = false
    self = nil
    spriteController:removePlist("public/championshipWar/championshipImage.plist")
    spriteController:removeTexture("public/championshipWar/championshipImage.png")
    spriteController:removePlist("public/newButton180711.plist")
    spriteController:removeTexture("public/newButton180711.png")
    championshipWarVoApi:clearReport()
end
