heroAdjutantChangeDialog = commonDialog:new()

function heroAdjutantChangeDialog:new(layerNum, heroVo, adjPoint)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.heroVo = heroVo
    self.adjPoint = adjPoint
    self.isCanChange = false
    return nc
end

function heroAdjutantChangeDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function heroAdjutantChangeDialog:initTableView()
    local adjData = heroAdjutantVoApi:getAdjutant(self.heroVo.hid)[self.adjPoint]
    self.adjId, self.adjCurLv = adjData[3], adjData[4]
    
    local frontLb = GetTTFLabel(getlocal("heroAdjutant_changeFront"), 24, true)
    local backLb = GetTTFLabel(getlocal("heroAdjutant_changeBack"), 24, true)
    frontLb:setAnchorPoint(ccp(0.5, 1))
    backLb:setAnchorPoint(ccp(0.5, 1))
    frontLb:setPosition(G_VisibleSizeWidth / 2 - 165, G_VisibleSizeHeight - 90)
    backLb:setPosition(G_VisibleSizeWidth / 2 + 165, G_VisibleSizeHeight - 90)
    frontLb:setColor(G_ColorYellowPro)
    backLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(frontLb)
    self.bgLayer:addChild(backLb)
    
    local iconFront = heroAdjutantVoApi:getAdjutantIcon(self.adjId, nil, true, nil, nil, self.adjPoint)
    iconFront:setScale(0.8)
    iconFront:setAnchorPoint(ccp(0.5, 1))
    iconFront:setPosition(frontLb:getPositionX(), frontLb:getPositionY() - frontLb:getContentSize().height)
    self.bgLayer:addChild(iconFront)
    heroAdjutantVoApi:setAdjLevel(iconFront, self.adjId, self.adjCurLv)
    
    local arrowSp = CCSprite:createWithSpriteFrameName("hellChallengeArrow2.png")
    arrowSp:setPosition(G_VisibleSizeWidth / 2, iconFront:getPositionY() - iconFront:getContentSize().height * iconFront:getScale() / 2)
    self.bgLayer:addChild(arrowSp)
    
    local iconBack = heroAdjutantVoApi:getAdjutantIcon(nil, nil, true, nil, nil, self.adjPoint)
    iconBack:setScale(0.8)
    iconBack:setAnchorPoint(ccp(0.5, 1))
    iconBack:setPosition(backLb:getPositionX(), backLb:getPositionY() - backLb:getContentSize().height)
    self.bgLayer:addChild(iconBack)
    self.iconBack = iconBack
    
    self.changeData = heroAdjutantVoApi:getAdjutantCanChangeData(self.heroVo, self.adjCurLv)
    
    self.curSelectedAdjId, self.lastSelectedAdjId = nil, nil
    if self.changeData and self.changeData[1] then
        self.curSelectedAdjId = self.changeData[1][1]
    end


    self.descTvWidth, self.descTvHeight = G_VisibleSizeWidth - 60, 0
    self.descCellHeight = self:getAdjutantDescTvHeight()
    self.maxDescTvHeight = 200
    if self.descCellHeight > self.maxDescTvHeight then
        self.descTvHeight = self.maxDescTvHeight
    else
        self.descTvHeight = self.descCellHeight
    end
    
    local function tvCallBack(...)
        return self:adjutantDescTvHandler(...)
    end
    local deschd = LuaEventHandler:createHandler(tvCallBack)
    self.descTv = LuaCCTableView:createWithEventHandler(deschd, CCSizeMake(self.descTvWidth, self.descTvHeight), nil)
    self.descTv:setPosition(ccp(30, iconFront:getPositionY() - iconFront:getContentSize().height * iconFront:getScale() - 10 - self.descTvHeight))
    self.descTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(self.descTv)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, self.descTv:getPositionY() - 30))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, self.descTv:getPositionY() - 10)
    self.bgLayer:addChild(tableViewBg)
    local titleBg, titleLb, titleLbHeight = G_createNewTitle({getlocal("heroAdjutant_alternative"), 24, G_ColorYellowPro}, CCSizeMake(tableViewBg:getContentSize().width - 200, 0), nil, true, "Helvetica-bold")
    titleBg:setPosition(tableViewBg:getContentSize().width / 2, tableViewBg:getContentSize().height - titleLbHeight - 10)
    tableViewBg:addChild(titleBg)
    
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp:setContentSize(CCSizeMake(tableViewBg:getContentSize().width - 10, 4))
    lineSp:setPosition(tableViewBg:getContentSize().width / 2, 110)
    tableViewBg:addChild(lineSp)
    
    local costLb = GetTTFLabel(getlocal("activity_xuyuanlu_costGolds", {""}), 24, true)
    costLb:setAnchorPoint(ccp(0, 0.5))
    costLb:setPosition(30, lineSp:getPositionY() / 2)
    tableViewBg:addChild(costLb)
    
    self.bottomItemBg = CCNode:create()
    self.bottomItemBg:setAnchorPoint(ccp(0, 0.5))
    self.bottomItemBg:setPosition(costLb:getPositionX() + costLb:getContentSize().width, lineSp:getPositionY() / 2)
    tableViewBg:addChild(self.bottomItemBg)
    
    local itemCost, gemsCost = heroAdjutantVoApi:getAdjutantExchangeItem(self.adjId, self.adjCurLv, true)
    local quality,adjReqLv,rate = heroAdjutantVoApi:returnAdjutantRate()

    local function onChangeHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local gems = playerVoApi:getGems()
        if gems < gemsCost then
            GemsNotEnoughDialog(nil, nil, gemsCost - gems, self.layerNum + 1, gemsCost)
            do return end
        end
        if self.isCanChange == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroAdjutant_costItemTips"), 30)
            do return end
        end
        if self.curSelectedAdjId then
            local function onSureLogic()
                heroAdjutantVoApi:requestEquip(function()
                    self:close()
                    eventDispatcher:dispatchEvent("heroAdjutant.inif.refresh", {eventType = 3, adjIndex = self.adjPoint})
                    if self.selectedItemTb then
                        for k, v in pairs(self.selectedItemTb) do
                            G_addPlayerAward(v.type, v.key, v.id, -1 * tonumber(v.num), false, true)
                        end
                    end
                    playerVoApi:setGems(playerVoApi:getGems() - gemsCost)
                end, self.heroVo.hid, self.adjPoint, self.curSelectedAdjId)
            end
            local curSelectedAdjcfg = heroAdjutantVoApi:getAdjutantCfgData(self.curSelectedAdjId)
            local curSelectedAdjquality = curSelectedAdjcfg.quality
            -- print("curSelectedAdjquality---------------",curSelectedAdjquality)
            if curSelectedAdjquality== quality and self.adjCurLv>=adjReqLv then
                local cost = heroAdjutantVoApi:getAdjutantTotalNum(self.adjId, self.adjCurLv)
                cost = math.ceil(cost*rate)
                local adjCurName = heroAdjutantVoApi:getAdjutantName(self.adjId)
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("heroAdjutant_changeSureTips1",{gemsCost,cost,getlocal(adjCurName)}), nil, self.layerNum + 1)
            else
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("heroAdjutant_changeSureTips",{gemsCost}), nil, self.layerNum + 1)
            end
        else
            print("cjl --------->>> ERROR: 请选择需要替换的副官！")
        end
    end
    local btnScale = 0.8
    local changeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onChangeHandler, 11, getlocal("hero_honor_change"), 24 / btnScale)
    changeBtn:setScale(btnScale)
    local btnMenu = CCMenu:create()
    btnMenu:addChild(changeBtn)
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    changeBtn:setPosition(tableViewBg:getContentSize().width - changeBtn:getContentSize().width * changeBtn:getScale() / 2 - 25, lineSp:getPositionY() / 2 - 10)
    tableViewBg:addChild(btnMenu)
    
    local gemsCostNumLb = GetTTFLabel(tostring(gemsCost), 22)
    gemsCostNumLb:setAnchorPoint(ccp(0, 0.5))
    tableViewBg:addChild(gemsCostNumLb)
    local gemsSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    gemsSp:setAnchorPoint(ccp(0, 0.5))
    tableViewBg:addChild(gemsSp)
    local gemsWidth = gemsCostNumLb:getContentSize().width + gemsSp:getContentSize().width + 5
    gemsCostNumLb:setPosition(changeBtn:getPositionX() - gemsWidth / 2, changeBtn:getPositionY() + 45)
    gemsSp:setPosition(gemsCostNumLb:getPositionX() + gemsCostNumLb:getContentSize().width + 5, gemsCostNumLb:getPositionY())
    
    self.cellNum = math.ceil(SizeOfTable(self.changeData or {}) / 3)
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, titleBg:getPositionY() - lineSp:getPositionY() - 10)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setPosition(ccp(3, lineSp:getPositionY() + 5))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.tv)
    
    if self.cellNum == 0 then
        local notDataLb = GetTTFLabelWrap(getlocal("heroAdjutant_notStoreData"), 24, CCSizeMake(tableViewBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        notDataLb:setPosition(tableViewBg:getContentSize().width / 2, tableViewBg:getContentSize().height / 2)
        notDataLb:setColor(G_ColorGray)
        tableViewBg:addChild(notDataLb)
    end
end

function heroAdjutantChangeDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 240)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvSize.width, 240
        local index = idx + 1
        local forNum = index * 3
        local iconFirstPosX
        local iconScapeW = 20
        local tempI = 1
        for i = forNum - 2, forNum do
            local adjData = self.changeData[i]
            if adjData then
                local adjId, adjNum, adjIcon = adjData[1], adjData[2]
                local function addSelectedSp(iconSp)
                    local selectedSp = LuaCCScale9Sprite:createWithSpriteFrameName("adj_selected.png", CCRect(59, 59, 2, 2), function()end)
                    selectedSp:setContentSize(CCSizeMake(iconSp:getContentSize().width + 30, iconSp:getContentSize().height + 30))
                    selectedSp:setPosition(iconSp:getContentSize().width / 2, iconSp:getContentSize().height / 2)
                    selectedSp:setTag(301)
                    iconSp:addChild(selectedSp)
                    self.curSelectedAdjId = adjId
                    self.curSelectedAdjIcon = iconSp
                    if self.lastSelectedAdjId ~= self.curSelectedAdjId then
                        self:setAdjIconBack(adjId)
                        self.lastSelectedAdjId = self.curSelectedAdjId
                    end
                end
                adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, function()
                    if self.tv and self.tv:getIsScrolled() == false then
                        if self.curSelectedAdjId ~= adjId then
                            if tolua.cast(self.curSelectedAdjIcon, "CCSprite") then
                                local prevSelectedSp = tolua.cast(self.curSelectedAdjIcon:getChildByTag(301), "CCSprite")
                                if prevSelectedSp then
                                    prevSelectedSp:removeFromParentAndCleanup(true)
                                    prevSelectedSp = nil
                                end
                            end
                            addSelectedSp(adjIcon)
                        end
                    end
                end)
                adjIcon:setScale(0.65)
                if iconFirstPosX == nil then
                    iconFirstPosX = (cellW - (adjIcon:getContentSize().width * adjIcon:getScale() * 3 + (3 - 1) * iconScapeW)) / 2
                end
                adjIcon:setAnchorPoint(ccp(0, 0.5))
                adjIcon:setPosition(iconFirstPosX + (tempI - 1) * (adjIcon:getContentSize().width * adjIcon:getScale() + iconScapeW), cellH / 2)
                adjIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
                cell:addChild(adjIcon)
                local lvLb = GetTTFLabel(getlocal("fightLevel", {1}), 30, true)
                lvLb:setAnchorPoint(ccp(0, 0))
                lvLb:setPosition(55, 130)
                adjIcon:addChild(lvLb, 1)
                local lvBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                lvBg:setScaleX((lvLb:getContentSize().width + 30) / lvBg:getContentSize().width)
                lvBg:setScaleY(lvLb:getContentSize().height / lvBg:getContentSize().height)
                lvBg:setAnchorPoint(ccp(0, 0))
                lvBg:setPosition(lvLb:getPositionX() - 5, lvLb:getPositionY())
                adjIcon:addChild(lvBg)
                local levelBg = tolua.cast(adjIcon:getChildByTag(501), "CCSprite")
                if levelBg then
                    local numLb = GetTTFLabel(getlocal("propInfoNum", {adjNum}), 30, true)
                    numLb:setAnchorPoint(ccp(1, 0.5))
                    numLb:setPosition(levelBg:getContentSize().width - 25, levelBg:getContentSize().height / 2)
                    levelBg:addChild(numLb)
                end
                if i == 1 then
                    addSelectedSp(adjIcon)
                end
            end
            tempI = tempI + 1
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function heroAdjutantChangeDialog:getAdjutantDescTvHeight()
    if self.lastSelectedAdjId == self.curSelectedAdjId then
        do return self.descCellHeight end
    end
    self.descCellHeight = 10
    local descFontSize, descFontWidth = 22, G_VisibleSizeWidth - 60
    --替换前
    local frontDescStr = getlocal("heroAdjutant_changeFront") .. "：" .. heroAdjutantVoApi:getAdjutantDesc(self.adjId, self.adjCurLv)
    local descFrontLb, frontLbHeight = G_getRichTextLabel(frontDescStr, {}, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.descCellHeight = self.descCellHeight + frontLbHeight
    if self.curSelectedAdjId then
        --替换后
        local backDescStr = getlocal("heroAdjutant_changeBack") .. "：" .. heroAdjutantVoApi:getAdjutantDesc(self.curSelectedAdjId, self.adjCurLv)
        local descBackLb, backLbHeight = G_getRichTextLabel(backDescStr, {}, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        self.descCellHeight = self.descCellHeight + backLbHeight + 5
    end
    return self.descCellHeight
end

function heroAdjutantChangeDialog:adjutantDescTvHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.descTvWidth, self.descCellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.descTvWidth, self.descCellHeight
        local descFontSize, descFontWidth = 22, self.descTvWidth
        --替换前
        local frontDescStr = getlocal("heroAdjutant_changeFront") .. "：" .. heroAdjutantVoApi:getAdjutantDesc(self.adjId, self.adjCurLv)
        local frontDescColorTb = heroAdjutantVoApi:getAdjutantDescColor(self.adjId, 1)
        local descFrontLb, frontLbHeight = G_getRichTextLabel(frontDescStr, frontDescColorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        descFrontLb:setAnchorPoint(ccp(0, 1))
        descFrontLb:setPosition(0, cellH - 5)
        cell:addChild(descFrontLb)
        
        --替换后
        if self.curSelectedAdjId then
            local backDescStr = getlocal("heroAdjutant_changeBack") .. "：" .. heroAdjutantVoApi:getAdjutantDesc(self.curSelectedAdjId, self.adjCurLv)
            local backDescColorTb = heroAdjutantVoApi:getAdjutantDescColor(self.curSelectedAdjId, 2)
            
            local descBackLb, backLbHeight = G_getRichTextLabel(backDescStr, backDescColorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descBackLb:setAnchorPoint(ccp(0, 1))
            descBackLb:setPosition(0, descFrontLb:getPositionY() - frontLbHeight - 5)
            cell:addChild(descBackLb)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function heroAdjutantChangeDialog:setAdjIconBack(adjId)
    if tolua.cast(self.iconBack, "CCSprite") then
        local scale = self.iconBack:getScale()
        local x, y = self.iconBack:getPosition()
        self.iconBack:removeFromParentAndCleanup(true)
        self.iconBack = nil
        self.iconBack = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, nil, nil, self.adjPoint)
        self.iconBack:setScale(scale)
        self.iconBack:setAnchorPoint(ccp(0.5, 1))
        self.iconBack:setPosition(x, y)
        self.bgLayer:addChild(self.iconBack)
        heroAdjutantVoApi:setAdjLevel(self.iconBack, adjId, self.adjCurLv)
        if self.descTv then --刷新属性显示区域
            self.descCellHeight = self:getAdjutantDescTvHeight()
            self.descTv:reloadData()
            if self.descCellHeight > self.descTvHeight then
                self.descTv:setMaxDisToBottomOrTop(100)
            else
                self.descTv:setMaxDisToBottomOrTop(0)
            end
        end
        self:setCostItem(adjId)
    end
end

function heroAdjutantChangeDialog:setCostItem(adjId)
    if tolua.cast(self.bottomItemBg, "CCNode") then
        self.bottomItemBg:removeAllChildrenWithCleanup(true)
        self.selectedItemTb = nil
        local itemTb = heroAdjutantVoApi:getAdjutantExchangeItem(adjId, self.adjCurLv, true)
        if itemTb then
            self.isCanChange = true
            for k, v in pairs(itemTb) do
                local iconSize = 80
                local icon, scale = G_getItemIcon(v, 100, true, self.layerNum)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setAnchorPoint(ccp(0, 0.5))
                icon:setPosition((k - 1) * (icon:getContentSize().width * scale + 10), 0)
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                self.bottomItemBg:addChild(icon)
                local curNum = 0
                if v.type == "aj" then
                    curNum = heroAdjutantVoApi:getAdjutantNum(adjId)
                else
                    curNum = bagVoApi:getItemNumId(v.id)
                end
                curNum = tonumber(curNum)
                local numLb = GetTTFLabel(FormatNumber(curNum) .. "/" .. FormatNumber(v.num), 20)
                if curNum < v.num then
                    numLb:setColor(G_ColorRed)
                    self.isCanChange = false
                end
                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                numBg:setAnchorPoint(ccp(0, 1))
                numBg:setRotation(180)
                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize / 2 + 5)
                self.bottomItemBg:addChild(numBg)
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setPosition(numBg:getPosition())
                self.bottomItemBg:addChild(numLb)
            end
        end
        self.selectedItemTb = itemTb
    end
end

function heroAdjutantChangeDialog:doUserHandler()
end

function heroAdjutantChangeDialog:tick()
end

function heroAdjutantChangeDialog:dispose()
    self.descTvWidth, self.descTvHeight = nil, nil
    self.maxDescTvHeight = nil
    self.descCellHeight = nil
    self.curSelectedAdjId, self.lastSelectedAdjId = nil, nil
    self.descTv = nil
    self = nil
end
