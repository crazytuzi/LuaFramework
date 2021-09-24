acFlashSaleDialog = commonDialog:new()

function acFlashSaleDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/acFlashSaleImage.plist")
        spriteController:addTexture("public/acFlashSaleImage.png")
        spriteController:addPlist("public/acFlashSaleEffect1.plist")
        spriteController:addTexture("public/acFlashSaleEffect1.png")
        spriteController:addPlist("public/acFlashSaleEffect2.plist")
        spriteController:addTexture("public/acFlashSaleEffect2.png")
        spriteController:addPlist("public/acFlashSaleEffect3.plist")
        spriteController:addTexture("public/acFlashSaleEffect3.png")
        spriteController:addPlist("public/accessoryImage.plist")
        spriteController:addPlist("public/accessoryImage2.plist")
        spriteController:addPlist("public/acThfb.plist")
        spriteController:addTexture("public/acThfb.png")
    end)
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addPlist("public/greenFlicker.plist")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addPlist("public/redFlicker.plist")
    return nc
end

function acFlashSaleDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function acFlashSaleDialog:initTableView()
    local bannerSp = CCSprite:createWithSpriteFrameName("acFS_banner.png")
    bannerSp:setAnchorPoint(ccp(0.5, 1))
    bannerSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85))
    self.bgLayer:addChild(bannerSp)
    self.bannerSp = bannerSp
    local recordBtn
    local function onClickRecord()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        G_touchedItem(recordBtn, function ()
            PlayEffect(audioCfg.mouseClick)
            acFlashSaleVoApi:netRequest("getlog", nil, function(sData)
                acFlashSaleVoApi:showRecordSmallDialog(self.layerNum + 1, sData.log)
            end)
        end)
    end
    recordBtn = LuaCCSprite:createWithSpriteFrameName("acFS_recordBtn.png", onClickRecord)
    recordBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    recordBtn:setScale(1.5)
    recordBtn:setPosition(ccp(20 + recordBtn:getContentSize().width * recordBtn:getScale() / 2, bannerSp:getContentSize().height - recordBtn:getContentSize().height * recordBtn:getScale() / 2 - 5))
    bannerSp:addChild(recordBtn)
    local recordLb = GetTTFLabel(getlocal("serverwar_point_record"), 16, true)
    recordLb:setAnchorPoint(ccp(0.5, 1))
    recordLb:setPosition(ccp(recordBtn:getPositionX(), recordBtn:getPositionY() - recordBtn:getContentSize().height * recordBtn:getScale() / 2))
    bannerSp:addChild(recordLb)
    local infoBtn
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        G_touchedItem(infoBtn, function ()
            PlayEffect(audioCfg.mouseClick)
            local tabStr = {
                getlocal("acFlashSale_i_desc1", {acFlashSaleVoApi:freeLimitLv()}),
                getlocal("acFlashSale_i_desc2"),
                getlocal("acFlashSale_i_desc3", {acFlashSaleVoApi:getGiveNum()}),
                getlocal("acFlashSale_i_desc4", {acFlashSaleVoApi:getOverDayDelayTime()}),
                getlocal("acFlashSale_i_desc5"),
                getlocal("acFlashSale_i_desc6"),
            }
            require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
            tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
        end)
    end
    infoBtn = LuaCCSprite:createWithSpriteFrameName("acFS_infoBtn.png", showInfo)
    infoBtn:setScale(1.6)
    infoBtn:setPosition(ccp(bannerSp:getContentSize().width - 15 - infoBtn:getContentSize().width * infoBtn:getScale() / 2, bannerSp:getContentSize().height - 10 - infoBtn:getContentSize().height * infoBtn:getScale() / 2))
    infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    bannerSp:addChild(infoBtn)
    
    self.curLvGiftData, self.curLvRewardData = acFlashSaleVoApi:getCurLvGiftData()
    self:showThemeAndFreeGift()
    
    local giftTvSize = CCSizeMake(G_VisibleSizeWidth - 20, bannerSp:getPositionY() - bannerSp:getContentSize().height - 230)
    self.giftTv = G_createTableView(giftTvSize, SizeOfTable(self.curLvGiftData), function(idx, cellNum)
        local height = 330
        if self.giftTvCellState and self.giftTvCellState[idx + 1] == 1 then
            height = 415
        end
        return CCSizeMake(giftTvSize.width, height)
    end, function(...) self:showGiftList(...) end)
    self.giftTv:setPosition(ccp((G_VisibleSizeWidth - giftTvSize.width) / 2, bannerSp:getPositionY() - bannerSp:getContentSize().height - 10 - giftTvSize.height))
    self.giftTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(self.giftTv)
    
    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(self.bgSize.width / 2, self.giftTv:getPositionY() + giftTvSize.height)
    upShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    self.bgLayer:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(self.bgSize.width / 2, self.giftTv:getPositionY())
    downShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    self.bgLayer:addChild(downShiedldBg)
    
    self:showTodayListUI()
    
    local acVo = acFlashSaleVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = function(getFlag, callBackFunc)
            local function refreshTV()
                if getFlag == 1 then
                    self.curLvGiftData, self.curLvRewardData = acFlashSaleVoApi:getCurLvGiftData()
                    if type(callBackFunc) == "function" then
                        callBackFunc()
                    end
                end
                if self.giftTv then
                    local recordPoint = self.giftTv:getRecordPoint()
                    self.giftTv:reloadData()
                    self.giftTv:recoverToRecordPoint(recordPoint)
                end
            end
            if getFlag == 1 then
                acFlashSaleVoApi:netRequest("get", nil, refreshTV)
            else
                refreshTV()
            end
        end
    end
    self:showForbidUI()
    local curOverDayTime = G_getWeeTs(base.serverTime)
    local overDayDelayTime = acFlashSaleVoApi:getOverDayDelayTime()
    if base.serverTime ~= curOverDayTime and (base.serverTime - curOverDayTime) < overDayDelayTime then
        local dt = overDayDelayTime - (base.serverTime - curOverDayTime)
        self:overDayEvent(dt)
    end
end

function acFlashSaleDialog:showThemeAndFreeGift()
    if self.bannerSp == nil then
        do return end
    end
    if self.curLvRewardData then
        if self.themeNameSp then
            local todayThemeIdx = self.curLvRewardData.up or 1
            self.themeNameSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFS_themeName" .. todayThemeIdx .. ".png"))
        else
            local todayThemeSp = CCSprite:createWithSpriteFrameName("acFS_todayTheme.png")
            todayThemeSp:setAnchorPoint(ccp(0.5, 1))
            todayThemeSp:setPosition(ccp(self.bannerSp:getContentSize().width / 2 + 110, self.bannerSp:getContentSize().height - 10))
            todayThemeSp:setTag(2001)
            self.bannerSp:addChild(todayThemeSp)
            local todayThemeIdx = self.curLvRewardData.up or 1
            local themeNameSp = CCSprite:createWithSpriteFrameName("acFS_themeName" .. todayThemeIdx .. ".png")
            themeNameSp:setAnchorPoint(ccp(0.5, 1))
            themeNameSp:setPosition(ccp(todayThemeSp:getPositionX(), todayThemeSp:getPositionY() - todayThemeSp:getContentSize().height + 10))
            self.bannerSp:addChild(themeNameSp)
            self.themeNameSp = themeNameSp
        end
    end
    local function freeBoxSpAction()
        local seqArr = CCArray:create()
        seqArr:addObject(CCRotateTo:create(0.1, 20))
        seqArr:addObject(CCRotateTo:create(0.2, -20))
        seqArr:addObject(CCRotateTo:create(0.2, 15))
        seqArr:addObject(CCRotateTo:create(0.2, -15))
        seqArr:addObject(CCRotateTo:create(0.1, 0))
        seqArr:addObject(CCDelayTime:create(1.5))
        self.freeBoxSp:runAction(CCRepeatForever:create(CCSequence:create(seqArr)))
    end
    local isFree = acFlashSaleVoApi:isFreeGift()
    if self.freeBoxSp then
        if isFree then
            self.freeBoxSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFS_freeBoxClosed.png"))
            freeBoxSpAction()
        else
            self.freeBoxSp:stopAllActions()
            self.freeBoxSp:setRotation(0)
            self.freeBoxSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFS_freeBoxOpen.png"))
        end
    else
        local function onClickFreeBox()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            if acFlashSaleVoApi:isFreeGift() == false then
                G_showTipsDialog(getlocal("backstage1976"))
                do return end
            end
            G_touchedItem(self.freeBoxSp, function ()
                PlayEffect(audioCfg.mouseClick)
                if playerVoApi:getPlayerLevel() < acFlashSaleVoApi:freeLimitLv() then
                    G_showTipsDialog(getlocal("lv_not_enough"))
                    do return end
                end
                acFlashSaleVoApi:netRequest("free", nil, function(sData)
                    print("cjl ----->>> 领取免费礼包成功！")
                    self.freeBoxSp:stopAllActions()
                    self.freeBoxSp:setRotation(0)
                    self.freeBoxSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFS_freeBoxOpen.png"))
                    if sData and sData.reward then
                        local rewardTipTb = FormatItem(sData.reward)
                        for k, v in pairs(rewardTipTb) do
                            if v.isGive ~= true then
                                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                if v.type == "h" then --添加将领魂魄
                                    if v.key and string.sub(v.key, 1, 1) == "s" then
                                        heroVoApi:addSoul(v.key, tonumber(v.num))
                                    end
                                end
                            end
                        end
                        G_showRewardTip(rewardTipTb)
                    end
                end)
            end)
        end
        self.freeBoxSp = LuaCCSprite:createWithSpriteFrameName(isFree and "acFS_freeBoxClosed.png" or "acFS_freeBoxOpen.png", onClickFreeBox)
        self.freeBoxSp:setPosition(ccp(self.bannerSp:getContentSize().width - 5 - self.freeBoxSp:getContentSize().width / 2, self.freeBoxSp:getContentSize().height / 2))
        self.freeBoxSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bannerSp:addChild(self.freeBoxSp)
        if isFree then
            freeBoxSpAction()
        end
    end
end

function acFlashSaleDialog:showGiftList(cell, cellSize, idx, cellNum)
    local data = self.curLvGiftData[idx + 1]
    if data == nil then
        do return end
    end
    local rData = acFlashSaleVoApi:getRechargeData(data.rechargeId)
    local rState, rNum = 0, 0
    if rData then
        rState = (rData[1] or 0) --充值状态  默认 0 未充值； 1 已充值； 2 已领取
        rNum = (rData[2] or 0) --充值次数
    end
    local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("acFS_cellBg.png", CCRect(146, 18, 2, 3), function()
        if self.giftTv:getIsScrolled() == false and data.pool2 then
            if self.giftTvCellState == nil then
                self.giftTvCellState = {}
            end
            self.giftTvCellState[idx + 1] = (self.giftTvCellState[idx + 1] == 1) and 0 or 1
            local recordPoint = self.giftTv:getRecordPoint()
            self.giftTv:reloadData()
            self.giftTv:recoverToRecordPoint(recordPoint)
        end
    end)
    if data.pool2 then
        cellBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    end
    cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 10))
    cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
    cell:addChild(cellBg)
    local cellUpBg = CCSprite:createWithSpriteFrameName("acFS_cellBgSp1.png")
    cellUpBg:setAnchorPoint(ccp(0.5, 1))
    cellUpBg:setPosition(ccp(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 6))
    cellBg:addChild(cellUpBg)
    local cellDownBg = CCSprite:createWithSpriteFrameName("acFS_cellBgSp2.png")
    cellDownBg:setAnchorPoint(ccp(0.5, 0))
    cellDownBg:setPosition(ccp(cellBg:getContentSize().width / 2, 0))
    cellBg:addChild(cellDownBg)
    local allReward
    if data.pool2 then
        allReward = FormatItem(data.pool2, nil, true)
        local previewBtn
        local function onClickPreview(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            G_touchedItem(previewBtn, function ()
                PlayEffect(audioCfg.mouseClick)
                if self.giftTv:getIsScrolled() == false then
                    acFlashSaleVoApi:showPreviewSmallDialog(self.layerNum + 1, allReward, data.bd)
                end
            end)
        end
        previewBtn = LuaCCSprite:createWithSpriteFrameName("acFS_previewBtn.png", onClickPreview)
        previewBtn:setPosition(ccp(20 + previewBtn:getContentSize().width / 2, cellBg:getContentSize().height - 15 - previewBtn:getContentSize().height / 2))
        previewBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cellBg:addChild(previewBtn)
        local previewLb = GetTTFLabel(getlocal("chatEmoji_previewText"), 16, true)
        previewLb:setAnchorPoint(ccp(0.5, 1))
        previewLb:setPosition(ccp(previewBtn:getPositionX(), previewBtn:getPositionY() - previewBtn:getContentSize().height / 2))
        cellBg:addChild(previewLb)
    end
    if acFlashSaleVoApi:isCanGiveOut(data.rechargeId) then
        local giveSp = CCSprite:createWithSpriteFrameName("acFS_giveAsIcon.png")
        giveSp:setAnchorPoint(ccp(1, 1))
        giveSp:setPosition(ccp(cellBg:getContentSize().width, cellBg:getContentSize().height))
        cellBg:addChild(giveSp, 3)
    end
    local giftSp = CCSprite:createWithSpriteFrameName("acFS_box" .. (idx + 1) .. "_closed.png")
    giftSp:setAnchorPoint(ccp(0.5, 1))
    giftSp:setPosition(ccp(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 15))
    cellBg:addChild(giftSp)
    local giftNameBg = CCSprite:createWithSpriteFrameName("acFS_nameBg.png")
    giftNameBg:setPosition(ccp(giftSp:getPositionX(), giftSp:getPositionY() - giftSp:getContentSize().height))
    cellBg:addChild(giftNameBg)
    local giftNameLb = GetTTFLabel(acFlashSaleVoApi:getGiftName(idx + 1), 20, true)
    giftNameLb:setPosition(ccp(giftNameBg:getContentSize().width / 2, giftNameBg:getContentSize().height / 2))
    giftNameBg:addChild(giftNameLb)
    local limitBuyLb = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule", {rNum, data.max}), 18)
    limitBuyLb:setAnchorPoint(ccp(0.5, 1))
    limitBuyLb:setPosition(ccp(giftNameBg:getPositionX(), giftNameBg:getPositionY() - giftNameBg:getContentSize().height / 2))
    limitBuyLb:setColor(G_TabLBColorGreen)
    cellBg:addChild(limitBuyLb)
    local mysteryItem = {pic = "mysteryItemIcon.png", name = getlocal("mysteryProp_name"), num = data.pNum, desc = "mysteryProp_desc"}
    local iconSize = 55
    local iconSpaceW = 20
    local posY = limitBuyLb:getPositionY() - limitBuyLb:getContentSize().height - 10
    local giveLbStr = getlocal("acFlashSale_giveOutText")
    local isUnfold = false
    if self.giftTvCellState and self.giftTvCellState[idx + 1] == 1 then
        isUnfold = true
        local tempReward = {}
        for k, v in pairs(allReward) do
            if type(v.extend) == "string" then
                if tempReward[v.extend] == nil then
                    tempReward[v.extend] = {}
                end
                table.insert(tempReward[v.extend], v)
            else
                if tempReward["item"] == nil then
                    tempReward["item"] = {}
                end
                table.insert(tempReward["item"], v)
            end
        end
        local showItemCount = 4
        --g-绿色，b-蓝色，p-紫色，y-黄色，r-红色
        local quality = {"r", "y", "p", "b", "g", "item"}
        local tempIndex, qIndex, itemCount = 1, 1, 0
        local qualityCount = (#quality)
        local mysteryRewardTb = {}
        while itemCount < showItemCount and qIndex <= qualityCount do
            if tempReward[quality[qIndex]] then
                local v = tempReward[quality[qIndex]][tempIndex]
                if v then
                    table.insert(mysteryRewardTb, v)
                    tempIndex = tempIndex + 1
                    itemCount = itemCount + 1
                else
                    tempIndex = 1
                    qIndex = qIndex + 1
                end
            else
                qIndex = qIndex + 1
            end
        end
        local includeLb = GetTTFLabel(getlocal("acFlashSale_includeRewardText"), 16, true)
        local totalWidth = iconSize + iconSpaceW + includeLb:getContentSize().width + 5 + itemCount * iconSize + (itemCount - 1) * iconSpaceW
        local iconFirstPosX = (cellBg:getContentSize().width - totalWidth) / 2
        local extraIcon = LuaCCSprite:createWithSpriteFrameName(mysteryItem.pic, function()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, mysteryItem, nil, nil, nil, nil, true)
        end)
        extraIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        extraIcon:setScale(iconSize / extraIcon:getContentSize().width)
        extraIcon:setPosition(ccp(iconFirstPosX + iconSize / 2, posY - iconSize / 2))
        cellBg:addChild(extraIcon)
        local numLb = GetTTFLabel("x" .. FormatNumber(data.pNum), 16)
        local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
        numBg:setAnchorPoint(ccp(0, 1))
        numBg:setRotation(180)
        numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
        numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
        numBg:setPosition(ccp(extraIcon:getPositionX() + iconSize / 2 - 5, extraIcon:getPositionY() - iconSize / 2 + 5))
        cellBg:addChild(numBg, 1)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setPosition(numBg:getPosition())
        cellBg:addChild(numLb, 1)
        includeLb:setAnchorPoint(ccp(1, 0.5))
        includeLb:setPosition(ccp(extraIcon:getPositionX() + iconSize / 2 + iconSpaceW + includeLb:getContentSize().width, extraIcon:getPositionY()))
        cellBg:addChild(includeLb)
        iconFirstPosX = includeLb:getPositionX() + 5
        for index, v in pairs(mysteryRewardTb) do
            local function showNewPropDialog()
                if self.giftTv:getIsScrolled() == false then
                    if v.type == "at" and v.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                    else
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                    end
                end
            end
            local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setAnchorPoint(ccp(0, 0.5))
            icon:setPosition(ccp(iconFirstPosX + (index - 1) * (iconSize + iconSpaceW), extraIcon:getPositionY()))
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            cellBg:addChild(icon)
            if type(v.extend) == "string" then
                local flickerScale = (v.type == "o" or v.type == "troops" or (v.type == "p" and propCfg[v.key].useGetHero)) and 1.65 or 1.15
                G_addRectFlicker2(icon, flickerScale, flickerScale, 1, v.extend, nil, 10)
            end
            local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 16)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize / 2 + 5)
            cellBg:addChild(numBg, 1)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            cellBg:addChild(numLb, 1)
        end
        posY = extraIcon:getPositionY() - iconSize / 2 - 10
        local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("acFS_spaceLine.png", CCRect(9, 1, 1, 1), function()end)
        spaceLineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width * 0.85, spaceLineSp:getContentSize().height))
        spaceLineSp:setPosition(ccp(cellBg:getContentSize().width / 2, posY))
        cellBg:addChild(spaceLineSp)
        local rebateIcon = CCSprite:createWithSpriteFrameName("acFS_arrowUp.png")
        rebateIcon:setAnchorPoint(ccp(1, 1))
        rebateIcon:setPosition(ccp(spaceLineSp:getPositionX() + spaceLineSp:getContentSize().width / 2 - 3, spaceLineSp:getPositionY() - spaceLineSp:getContentSize().height / 2))
        cellBg:addChild(rebateIcon)
        local rebateLb = GetTTFLabel((data.percent * 100) .. "%", 16, true)
        rebateLb:setAnchorPoint(ccp(1, 0.5))
        rebateLb:setPosition(ccp(rebateIcon:getPositionX() - rebateIcon:getContentSize().width, rebateIcon:getPositionY() - rebateIcon:getContentSize().height / 2))
        rebateLb:setColor(G_ColorRed)
        cellBg:addChild(rebateLb)
        posY = rebateIcon:getPositionY() - rebateIcon:getContentSize().height
        giveLbStr = getlocal("acFlashSale_giftIncludeText")
    end
    local giveLb = GetTTFLabel(giveLbStr, 16, true)
    giveLb:setAnchorPoint(ccp(1, 0.5))
    if self.curLvRewardData then
        local rewardTbData = self.curLvRewardData[tostring(data.rechargeId)]
        if rewardTbData then
            local rewardTb = {}
            local rewardTbCount = 0
            for k, v in pairs(rewardTbData) do
                local itemTb = FormatItem(v, nil, true)
                if itemTb then
                    for kk, vv in pairs(itemTb) do
                        rewardTbCount = rewardTbCount + 1
                        if idx == 1 or idx == 2 then
                            vv.extend = (idx == 1) and "y" or "p"
                        end
                        table.insert(rewardTb, vv)
                    end
                end
            end
            local totalWidth = rewardTbCount * iconSize + (rewardTbCount - 1) * iconSpaceW
            if allReward then
                totalWidth = totalWidth + iconSpaceW + giveLb:getContentSize().width + 5 + iconSize
            end
            local iconFirstPosX = (cellBg:getContentSize().width - totalWidth) / 2
            if isUnfold then
                giveLb:setPosition(ccp(iconFirstPosX + giveLb:getContentSize().width, posY - iconSize / 2))
                iconFirstPosX = giveLb:getPositionX() + 5 + iconSize + iconSpaceW
            end
            for index, reward in pairs(rewardTb) do
                local function showNewPropDialog()
                    if self.giftTv:getIsScrolled() == false then
                        if reward.type == "at" and reward.eType == "a" then --AI部队
                            local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(reward.key, true)
                            AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                        else
                            G_showNewPropInfo(self.layerNum + 1, true, true, nil, reward, nil, nil, nil, nil, true)
                        end
                    end
                end
                local icon, scale = G_getItemIcon(reward, 100, false, self.layerNum, showNewPropDialog)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setPosition(ccp(iconFirstPosX + iconSize / 2 + (index - 1) * (iconSize + iconSpaceW), posY - iconSize / 2))
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cellBg:addChild(icon)
                if type(reward.extend) == "string" then
                    local flickerScale = (reward.type == "o" or reward.type == "troops" or (reward.type == "p" and propCfg[reward.key].useGetHero)) and 1.65 or 1.15
                    G_addRectFlicker2(icon, flickerScale, flickerScale, 1, reward.extend, nil, 10)
                end
                local numLb = GetTTFLabel("x" .. FormatNumber(reward.num), 16)
                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                numBg:setAnchorPoint(ccp(0, 1))
                numBg:setRotation(180)
                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
                cellBg:addChild(numBg, 1)
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setPosition(numBg:getPosition())
                cellBg:addChild(numLb, 1)
                if not isUnfold then
                    giveLb:setPosition(ccp(icon:getPositionX() + iconSize / 2 + iconSpaceW + giveLb:getContentSize().width, icon:getPositionY()))
                end
            end
            if rewardTbCount > 0 then
                posY = posY - iconSize - 10
            end
        end
    end
    
    if allReward then
        if giveLb:getPositionX() == 0 and giveLb:getPositionY() == 0 then
            local giveLbPosX = (cellBg:getContentSize().width - (giveLb:getContentSize().width + 5 + iconSize)) / 2 + giveLb:getContentSize().width
            giveLb:setPosition(ccp(giveLbPosX, posY - iconSize / 2))
        end
        cellBg:addChild(giveLb)
        local extraIcon = LuaCCSprite:createWithSpriteFrameName(mysteryItem.pic, function()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, mysteryItem, nil, nil, nil, nil, true)
        end)
        extraIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        extraIcon:setScale(iconSize / extraIcon:getContentSize().width)
        extraIcon:setPosition(ccp(giveLb:getPositionX() + 5 + iconSize / 2, giveLb:getPositionY()))
        cellBg:addChild(extraIcon)
        local numLb = GetTTFLabel("x" .. FormatNumber(data.pNum), 16)
        local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
        numBg:setAnchorPoint(ccp(0, 1))
        numBg:setRotation(180)
        numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
        numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
        numBg:setPosition(extraIcon:getPositionX() + iconSize / 2 - 5, extraIcon:getPositionY() - iconSize / 2 + 5)
        cellBg:addChild(numBg, 1)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setPosition(numBg:getPosition())
        cellBg:addChild(numLb, 1)
    end
    
    local function onClickButton(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.giftTv:getIsScrolled() == false then
            if rState == 1 then
                print("cjl ----->>> 领取")
                local pos = giftSp:getParent():convertToWorldSpace(ccp(giftSp:getPositionX() + giftSp:getContentSize().width / 2, giftSp:getPositionY() - giftSp:getContentSize().height / 2))
                acFlashSaleVoApi:netRequest("receive", {tid = tostring(data.rechargeId)}, function(sData)
                    self:playBoxEffect(pos, sData, idx + 1)
                end)
            else
                if base.serverTime - G_getWeeTs(base.serverTime) < acFlashSaleVoApi:getOverDayDelayTime() then
                    G_showTipsDialog(getlocal("notCanBuyTipText"))
                else
                    print("cjl ----->>> 充值")
                    G_rechargeHandler(data.rechargeId, data.RMB, giftNameLb:getString(), self.layerNum)
                end
            end
        end
    end
    local btnStr = G_getPlatStoreCfg()["moneyType"][GetMoneyName()] .. data.RMB
    if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
        btnStr = data.RMB .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
    end
    local btnEnabled = true
    local btnImage1, btnImage2 = "creatRoleBtn.png", "creatRoleBtn_Down.png"
    if rState == 1 then --可领取
        btnStr = getlocal("daily_scene_get")
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
    elseif rState == 2 or rNum >= data.max then --已领取
        btnStr = getlocal("activity_hadReward")
        btnEnabled = false
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
    end
    local btnScale = 0.6
    local button = GetButtonItem(btnImage1, btnImage2, btnImage1, onClickButton, nil, btnStr, 22 / btnScale)
    button:setScale(btnScale)
    button:setAnchorPoint(ccp(0.5, 0))
    button:setPosition(ccp(cellBg:getContentSize().width / 2, 10))
    button:setEnabled(btnEnabled)
    local btnMenu = CCMenu:createWithItem(button)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    cellBg:addChild(btnMenu)
    
    local vipPoint = 0
    local vipCfg = acFlashSaleVoApi:getAcVo().activeCfg.VIP
    if vipCfg and vipCfg[tostring(data.rechargeId)] then
        vipPoint = vipCfg[tostring(data.rechargeId)]
    end
    local vipAddLb, lbheight = G_getRichTextLabel(getlocal("prop_vip_point") .. ": " .. "<rayimg>+"..vipPoint.."<rayimg>", {nil, G_ColorGreen, nil}, 20, 200, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    vipAddLb:setAnchorPoint(ccp(0, 1))
    vipAddLb:setPosition(ccp(cellBg:getContentSize().width / 2 + button:getContentSize().width * btnScale * 0.5 + 20, 12 + button:getContentSize().height * btnScale * 0.5 + lbheight / 2))
    cellBg:addChild(vipAddLb)
end

function acFlashSaleDialog:showForbidUI()
    if acFlashSaleVoApi:isRewardTime() then
        local forbidBg = tolua.cast(self.bgLayer:getChildByTag(50001), "CCSprite")
        if forbidBg == nil then
            forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
            forbidBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85))
            forbidBg:setAnchorPoint(ccp(0.5, 1))
            forbidBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85))
            forbidBg:setTouchPriority(-(self.layerNum - 1) * 20 - 15)
            forbidBg:setTag(50001)
            self.bgLayer:addChild(forbidBg, 15)
            local forbidTipsLb = GetTTFLabelWrap(getlocal("acOver"), 25, CCSizeMake(G_VisibleSizeWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            forbidTipsLb:setPosition(ccp(forbidBg:getContentSize().width / 2, forbidBg:getContentSize().height / 2))
            forbidTipsLb:setColor(G_ColorYellowPro)
            forbidBg:addChild(forbidTipsLb)
        end
    end
end

function acFlashSaleDialog:playBoxEffect(startPos, sData, giftIdx)
    local layerNum = self.layerNum + 1
    self.effectLayer = tolua.cast(self.bgLayer:getChildByTag(-100), "CCSprite")
    if self.effectLayer then
        self.effectLayer:removeFromParentAndCleanup(true)
        self.effectLayer = nil
    end
    self.effectLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    self.effectLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    self.effectLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.effectLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.effectLayer:setTag(-100)
    self.bgLayer:addChild(self.effectLayer, 10)
    local curGiftData = self.curLvGiftData[giftIdx]
    local rechargeId = curGiftData.rechargeId
    local function showReward(boxSpPos)
        if sData and sData.creward and sData.creward[tostring(rechargeId)] and sData.creward[tostring(rechargeId)][3] then
            local rewardData, rewardDataSize = {}, 0
            for k, v in pairs(sData.creward[tostring(rechargeId)][3]) do
                for kk, vv in pairs(v) do
                    local tempItem = FormatItem(vv.p)[1]
                    if k == 1 then --固定礼包 查找光圈物品
                        if giftIdx == 2 or giftIdx == 3 then
                            tempItem.extend = (giftIdx == 2) and "y" or "p"
                        end
                    elseif k == 2 then --神秘礼包 查找光圈物品
                        for kkk, vvv in pairs(vv.p) do
                            if curGiftData and curGiftData.pool2 and curGiftData.pool2[kkk] then
                                for km, kn in pairs(vvv) do
                                    for kkkk, vvvv in pairs(curGiftData.pool2[kkk]) do
                                        if vvvv and vvvv[km] and vvvv.extend then
                                            tempItem.extend = vvvv.extend
                                        end
                                    end
                                end
                            end
                        end
                    end
                    table.insert(rewardData, {type = k, s = vv.s, item = tempItem, itemIndex = kk})
                    rewardDataSize = rewardDataSize + 1
                end
            end
            local itemData = {}
            local iconSize = 100
            local function showBtn()
                local isCanGive = acFlashSaleVoApi:isCanGiveOut(rechargeId)
                if itemData then
                    for k, v in pairs(itemData) do
                        local item = v.rewardData.item
                        local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 18)
                        local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                        numBg:setAnchorPoint(ccp(0, 1))
                        numBg:setRotation(180)
                        numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                        numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                        numBg:setPosition(v.icon:getPositionX() + iconSize - 5, v.icon:getPositionY() - iconSize + 5)
                        v.icon:getParent():addChild(numBg, 1)
                        numLb:setAnchorPoint(ccp(1, 0))
                        numLb:setPosition(numBg:getPosition())
                        v.icon:getParent():addChild(numLb, 1)
                        if type(item.extend) == "string" then
                            local flickerScale = (item.type == "o" or item.type == "troops" or (item.type == "p" and propCfg[item.key].useGetHero)) and 1.65 or 1.15
                            G_addRectFlicker2(v.icon, flickerScale, flickerScale, 1, item.extend, nil, 10)
                        end
                        if isCanGive then
                            local giveBtn
                            local function giveCallback()
                                giveBtn:setEnabled(false)
                                local giveBtnLb = tolua.cast(giveBtn:getChildByTag(10), "CCLabelTTF")
                                giveBtnLb:setString(getlocal("alien_tech_alreadySend"))
                                itemData[k]["isGive"] = true
                            end
                            local function onClickGive(tag, obj)
                                if G_checkClickEnable() == false then
                                    do return end
                                else
                                    base.setWaitTime = G_getCurDeviceMillTime()
                                end
                                PlayEffect(audioCfg.mouseClick)
                                print("cjl ----->>> 赠送", item.name, item.key, item.id)
                                local paramTb = {item.name, rechargeId, v.rewardData.type, v.rewardData.itemIndex, giveCallback}
                                acFlashSaleVoApi:showFriendListSmallDialog(layerNum + 1, paramTb)
                            end
                            local btnScale = 0.4
                            giveBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickGive, nil, getlocal("rechargeGifts_giveLabel"), 20 / btnScale, 10)
                            giveBtn:setScale(btnScale)
                            giveBtn:setAnchorPoint(ccp(0.5, 1))
                            giveBtn:setPosition(ccp(v.icon:getPositionX() + iconSize / 2, v.icon:getPositionY() - iconSize))
                            local giveMenu = CCMenu:createWithItem(giveBtn)
                            giveMenu:setPosition(ccp(0, 0))
                            giveMenu:setTouchPriority(-(layerNum - 1) * 20 - 2)
                            self.effectLayer:addChild(giveMenu)
                        end
                    end
                end
                local function onClickGetAll(tag, obj)
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    print("cjl ----->>> 领取全部")
                    acFlashSaleVoApi:netRequest("allreceive", {tid = tostring(rechargeId)}, function()
                        local acVo = acFlashSaleVoApi:getAcVo()
                        if acVo and type(acVo.refreshFunc) == "function" then
                            acVo.refreshFunc()
                        end
                        local rewardTipTb = {}
                        for k, v in pairs(itemData) do
                            if v.isGive ~= true then
                                local item = v.rewardData.item
                                G_addPlayerAward(item.type, item.key, item.id, item.num, nil, true)
                                if item.type == "h" then --添加将领魂魄
                                    if item.key and string.sub(item.key, 1, 1) == "s" then
                                        heroVoApi:addSoul(item.key, tonumber(item.num))
                                    end
                                end
                                table.insert(rewardTipTb, item)
                            end
                        end
                        G_showRewardTip(rewardTipTb)
                        self.effectLayer:removeFromParentAndCleanup(true)
                        self.effectLayer = nil
                        self:refreshTodayList()
                    end)
                end
                local getAllBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickGetAll, nil, getlocal("activity_shareHappiness_getAll"), 22 / 0.8)
                getAllBtn:setScale(0.8)
                getAllBtn:setAnchorPoint(ccp(0.5, 0))
                getAllBtn:setPosition(ccp(G_VisibleSizeWidth / 2, boxSpPos.y + 135))
                local getAllMenu = CCMenu:createWithItem(getAllBtn)
                getAllMenu:setPosition(ccp(0, 0))
                getAllMenu:setTouchPriority(-(layerNum - 1) * 20 - 2)
                self.effectLayer:addChild(getAllMenu)
            end
            local row, iconSpaceX, iconSpaceY = 4, 35, 65
            local firstPosX = (G_VisibleSizeWidth - (row * iconSize + (row - 1) * iconSpaceX)) / 2
            local firstPosY = G_VisibleSizeHeight - ((G_getIphoneType() == G_iphone4) and 90 or 180)
            local interval = 0.07
            for k, v in pairs(rewardData) do
                local function showNewPropDialog()
                    if v.item.type == "at" and v.item.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.item.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
                    else
                        G_showNewPropInfo(layerNum + 1, true, true, nil, v.item, nil, nil, nil, nil, true)
                    end
                end
                local icon, scale = G_getItemIcon(v.item, 100, false, layerNum, showNewPropDialog)
                icon:setAnchorPoint(ccp(0, 1))
                icon:setTouchPriority(-(layerNum - 1) * 20 - 2)
                self.effectLayer:addChild(icon)
                scale = iconSize / icon:getContentSize().height
                icon:setScale(0)
                icon:setPosition(boxSpPos)
                local endPos = ccp(firstPosX + ((k - 1) % row) * (iconSize + iconSpaceX), firstPosY - math.floor((k - 1) / row) * (iconSize + iconSpaceY))
                table.insert(itemData, {icon = icon, rewardData = v})
                local spawnArr = CCArray:create()
                spawnArr:addObject(CCMoveTo:create(0.33 + (k - 1) * interval, endPos))
                spawnArr:addObject(CCScaleTo:create(0.33 + (k - 1) * interval, scale))
                if k == rewardDataSize then
                    local spawn = CCSpawn:create(spawnArr)
                    local callFunc = CCCallFunc:create(showBtn)
                    icon:runAction(CCSequence:createWithTwoActions(spawn, callFunc))
                    break
                else
                    icon:runAction(CCSpawn:create(spawnArr))
                end
            end
        end
    end
    local isCanClick, isBoxOpen = false, false
    local function playBoxOpenAnim()
        if isCanClick == false then
            do return end
        end
        if isBoxOpen == false then
            isBoxOpen = true
            print("cjl ----->>> 播放开箱动画")
            local boxSp = tolua.cast(self.effectLayer:getChildByTag(1000), "CCSprite")
            boxSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("acFS_box"..giftIdx.."_open.png"))
            local boxAnimSp = tolua.cast(self.effectLayer:getChildByTag(1001), "CCSprite")
            boxAnimSp:removeFromParentAndCleanup(true)
            boxAnimSp = nil
            local boxOpenAnim1Sp, boxOpenAnim1 = self:createAnim(2, 20)
            boxOpenAnim1Sp:setScale(2)
            boxOpenAnim1Sp:setPosition(ccp(boxSp:getPositionX(), boxSp:getPositionY()))
            self.effectLayer:addChild(boxOpenAnim1Sp)
            boxOpenAnim1Sp:runAction(boxOpenAnim1)
            local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function()
                showReward(ccp(boxSp:getPosition()))
                local boxOpenAnim2Sp, boxOpenAnim2 = self:createAnim(3, 10)
                boxOpenAnim2Sp:setPosition(ccp(boxSp:getPositionX(), boxSp:getPositionY()))
                boxOpenAnim2Sp:runAction(CCRepeatForever:create(boxOpenAnim2))
                self.effectLayer:addChild(boxOpenAnim2Sp)
            end))
            boxSp:runAction(seq)
        end
    end
    local boxSp = LuaCCSprite:createWithSpriteFrameName("acFS_box"..giftIdx.."_closed.png", playBoxOpenAnim)
    boxSp:setTouchPriority(-(layerNum - 1) * 20 - 2)
    boxSp:setPosition(ccp(startPos.x, startPos.y + 15))
    boxSp:setTag(1000)
    self.effectLayer:addChild(boxSp)
    local function playBoxAnim()
        local boxAnimSp, boxAnim = self:createAnim(1, 17)
        boxAnimSp:setScale(2)
        boxAnimSp:setPosition(ccp(boxSp:getPositionX(), boxSp:getPositionY()))
        boxAnimSp:setTag(1001)
        self.effectLayer:addChild(boxAnimSp)
        boxAnimSp:runAction(CCRepeatForever:create(boxAnim))
        isCanClick = true
    end
    local spawnArry = CCArray:create()
    local seqArry = CCArray:create()
    seqArry:addObject(CCScaleTo:create(0.4, 2))
    seqArry:addObject(CCScaleTo:create(0.67 - 0.4, 1.9))
    seqArry:addObject(CCCallFunc:create(playBoxAnim))
    spawnArry:addObject(CCMoveTo:create(0.4, ccp(G_VisibleSizeWidth / 2, boxSp:getContentSize().height / 2 + 120)))
    spawnArry:addObject(CCSequence:create(seqArry))
    boxSp:runAction(CCSpawn:create(spawnArry))
end

function acFlashSaleDialog:createAnim(animId, frameNum)
    local firstFrameSp = CCSprite:createWithSpriteFrameName("acFlashSaleEffect" .. animId .. "_1.png")
    G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
    local frameArray = CCArray:create()
    for i = 1, frameNum do
        local frameName = "acFlashSaleEffect" .. animId .. "_" .. i .. ".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
        frameArray:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.1)
    local animate = CCAnimate:create(animation)
    return firstFrameSp, animate
end

function acFlashSaleDialog:showTodayListUI()
    self.todayListLbTb = {}
    local posY = self.giftTv:getPositionY() - 10
    local titleFontSize = G_isAsia() == false and 22 or 24
    local titleStrTb = {getlocal("acFlashSale_todayLuckText"), getlocal("acFlashSale_todayGiveOutText")}
    for k, titleStr in pairs(titleStrTb) do
        local tempTitleLb = GetTTFLabel(titleStr, titleFontSize, true)
        local titleBg, titleLb, titleLbHeight = G_createNewTitle({titleStr, titleFontSize, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + 130, 0), nil, true, "Helvetica-bold")
        titleBg:setAnchorPoint(ccp(0.5, 0))
        titleBg:setPosition(ccp(G_VisibleSizeWidth / 2, posY - titleLbHeight))
        self.bgLayer:addChild(titleBg)
        local function onClickList()
            if self.todayList then
                local listData, listDataNum = {}, 0
                if k == 1 and self.todayList.lucky then
                    for kk, vv in pairs(self.todayList.lucky) do
                        local giftName = acFlashSaleVoApi:getGiftName(vv[2])
                        local keyTb = Split(vv[3], "_")
                        local item = FormatItem({[G_rewardType(keyTb[1])] = {[keyTb[2]] = vv[4]}})[1]
                        table.insert(listData, {getlocal("acFlashSale_todayLuckListDesc", {vv[1], giftName, item.name, item.num}), vv[5]})
                        listDataNum = listDataNum + 1
                    end
                elseif k == 2 and self.todayList.receive then
                    for kk, vv in pairs(self.todayList.receive) do
                        table.insert(listData, {getlocal("acFlashSale_todayGiveListDesc", {vv[1], vv[2]}), vv[3]})
                        listDataNum = listDataNum + 1
                    end
                end
                if listDataNum > 0 then
                    acFlashSaleVoApi:showTodayListDetailsSmallDialog(self.layerNum + 1, listData)
                end
            end
        end
        posY = titleBg:getPositionY() - 10
        local kuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), onClickList)
        kuangSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        kuangSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, 50))
        kuangSp:setAnchorPoint(ccp(0.5, 0))
        kuangSp:setPosition(ccp(G_VisibleSizeWidth / 2, posY - kuangSp:getContentSize().height))
        self.bgLayer:addChild(kuangSp)
        posY = kuangSp:getPositionY() - 10
        local lb = GetTTFLabel("", 20)
        lb:setAnchorPoint(ccp(0, 0.5))
        lb:setPosition(ccp(10, kuangSp:getContentSize().height / 2))
        kuangSp:addChild(lb)
        local arrowBtn = CCSprite:createWithSpriteFrameName("acFS_arrowDown.png")
        arrowBtn:setAnchorPoint(ccp(1, 0.5))
        arrowBtn:setPosition(ccp(kuangSp:getContentSize().width - 15, kuangSp:getContentSize().height / 2))
        kuangSp:addChild(arrowBtn)
        local tsLb = GetTTFLabel("", 20)
        tsLb:setAnchorPoint(ccp(1, 0.5))
        tsLb:setPosition(ccp(arrowBtn:getPositionX() - arrowBtn:getContentSize().width - 5, kuangSp:getContentSize().height / 2))
        kuangSp:addChild(tsLb)
        self.todayListLbTb[k] = {lb, tsLb}
    end
    self:refreshTodayList()
end

function acFlashSaleDialog:refreshTodayList()
    self.todayList = acFlashSaleVoApi:getTodayList()
    if self.todayListLbTb then
        for k, v in pairs(self.todayListLbTb) do
            local descLb = tolua.cast(v[1], "CCLabelTTF")
            local tsLb = tolua.cast(v[2], "CCLabelTTF")
            local str, ts
            if k == 1 then
                if self.todayList and self.todayList.lucky and self.todayList.lucky[1] then
                    local name = self.todayList.lucky[1][1]
                    local giftIdx = self.todayList.lucky[1][2]
                    local itemKey = self.todayList.lucky[1][3]
                    local itemNum = self.todayList.lucky[1][4]
                    local giftName = acFlashSaleVoApi:getGiftName(giftIdx)
                    local keyTb = Split(itemKey, "_")
                    local item = FormatItem({[G_rewardType(keyTb[1])] = {[keyTb[2]] = itemNum}})[1]
                    str = getlocal("acFlashSale_todayLuckListDesc", {name, giftName, item.name, item.num})
                    ts = self.todayList.lucky[1][5]
                end
            elseif k == 2 then
                if self.todayList and self.todayList.receive and self.todayList.receive[1] then
                    local selfName = self.todayList.receive[1][1]
                    local friendName = self.todayList.receive[1][2]
                    str = getlocal("acFlashSale_todayGiveListDesc", {selfName, friendName})
                    ts = self.todayList.receive[1][3]
                end
            end
            if str then
                descLb:setString(G_getPointStr(str, descLb:getParent():getContentSize().width - 180, descLb:getFontSize()))
            else
                descLb:setString("")
            end
            if ts then
                tsLb:setString(G_getDataTimeStr(ts))
            else
                tsLb:setString("")
            end
        end
    end
end

function acFlashSaleDialog:overDayEvent(dt)
    if self then
        local function overDayRefresh()
            self:showForbidUI()
            local acVo = acFlashSaleVoApi:getAcVo()
            if acVo and type(acVo.refreshFunc) == "function" then
                acVo.refreshFunc(1, function() self:showThemeAndFreeGift() end)
            end
            self:refreshTodayList()
        end
        --由于后端的特殊要求，故需要跨天后延迟请求。
        self.bgLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(dt or acFlashSaleVoApi:getOverDayDelayTime()), CCCallFunc:create(function()
            if acFlashSaleVoApi:isChangeCfg() then
                G_getActiveList(overDayRefresh)
            else
                overDayRefresh()
            end
            --跨天拉领取邮件
            socketHelper:emailList(1, 0, 0, function(fn, data)
                local ret, sData = base:checkServerData(data)
            end, 1)
        end)))
    end
end

function acFlashSaleDialog:tick()
    if self then
        local vo = acFlashSaleVoApi:getAcVo()
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        end
    end
end

function acFlashSaleDialog:dispose()
    local acVo = acFlashSaleVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = nil
    end
    self = nil
    spriteController:removePlist("public/acFlashSaleImage.plist")
    spriteController:removeTexture("public/acFlashSaleImage.png")
    spriteController:removePlist("public/acFlashSaleEffect1.plist")
    spriteController:removeTexture("public/acFlashSaleEffect1.png")
    spriteController:removePlist("public/acFlashSaleEffect2.plist")
    spriteController:removeTexture("public/acFlashSaleEffect2.png")
    spriteController:removePlist("public/acFlashSaleEffect3.plist")
    spriteController:removeTexture("public/acFlashSaleEffect3.png")
    -- spriteController:removePlist("public/accessoryImage.plist")
    -- spriteController:removePlist("public/accessoryImage2.plist")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removePlist("public/greenFlicker.plist")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removePlist("public/redFlicker.plist")
end
