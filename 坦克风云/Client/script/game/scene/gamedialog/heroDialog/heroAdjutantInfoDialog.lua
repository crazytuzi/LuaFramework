heroAdjutantInfoDialog = commonDialog:new()

function heroAdjutantInfoDialog:new(layerNum, heroVo, parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.heroVo = heroVo
    self.parent = parent
    G_addResource8888(function()
        spriteController:addPlist("public/limitChallenge.plist")
        spriteController:addTexture("public/limitChallenge.png")
        spriteController:addPlist("public/heroAdjutantEffect.plist")
        spriteController:addTexture("public/heroAdjutantEffect.png")
    end)
    return nc
end

function heroAdjutantInfoDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function heroAdjutantInfoDialog:createAnim(animIndex, callback)
    local animTb = {"adjEffect_upgrade", "adjEffect_change"}
    local firstFrameSp = CCSprite:createWithSpriteFrameName(animTb[animIndex] .. "1.png")
    G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
    local frameArray = CCArray:create()
    for i = 1, 12 do
        local frameName = animTb[animIndex] .. i .. ".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
        frameArray:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.08)
    local animate = CCAnimate:create(animation)
    local callFunc = CCCallFunc:create(function()
        firstFrameSp:removeFromParentAndCleanup(true)
        if callback then callback() end
    end)
    return firstFrameSp, CCSequence:createWithTwoActions(animate, callFunc)
end

function heroAdjutantInfoDialog:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local infoBg = CCSprite:create("public/heroAdjutant_infoBg.jpg")
    infoBg:setAnchorPoint(ccp(0.5, 1))
    infoBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 83)
    self.bgLayer:addChild(infoBg)
    self.infoBg = infoBg
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local adjCfg = heroAdjutantVoApi:getAdjutantCfg()
        local tabStr = {
            getlocal("heroAdjutant_operationDesc1"),
            getlocal("heroAdjutant_operationDesc2"),
            getlocal("heroAdjutant_operationDesc3"),
            getlocal("heroAdjutant_operationDesc4"),
            getlocal("heroAdjutant_operationDesc5", {adjCfg.chainEffectList[1].totalLv, adjCfg.chainEffectList[2].totalLv, adjCfg.chainEffectList[3].totalLv, adjCfg.chainEffectList[4].totalLv}),
            getlocal("heroAdjutant_operationDesc6"),
        }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(infoBg:getContentSize().width / 2 + 110, infoBg:getContentSize().height - 50))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    infoBg:addChild(infoMenu)
    
    self.adjData = heroAdjutantVoApi:getAdjutant(self.heroVo.hid)
    for i = 1, 4 do
        self:setAdjutantIcon(i)
    end
    
    local propBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()
        heroAdjutantVoApi:showExtraPropertySmallDialog(self.layerNum + 1, {self.heroVo.hid})
    end)
    propBg:setContentSize(CCSizeMake(250, 85))
    propBg:setAnchorPoint(ccp(0.5, 0))
    propBg:setPosition(infoBg:getContentSize().width / 2, 12)
    propBg:setOpacity(90)
    propBg:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    infoBg:addChild(propBg)
    local propLb = GetTTFLabel(getlocal("heroAdjutant_extraEffect"), 20, true)
    propLb:setAnchorPoint(ccp(0.5, 1))
    propLb:setPosition(propBg:getContentSize().width / 2, propBg:getContentSize().height - 5)
    propLb:setColor(G_ColorYellowPro)
    propBg:addChild(propLb)
    self:setExtraPropertyIcon(propBg)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, infoBg:getPositionY() - infoBg:getContentSize().height - 100))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, infoBg:getPositionY() - infoBg:getContentSize().height)
    self.bgLayer:addChild(tableViewBg)
    
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    self.cellHeight = self:getCellHieght()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setPosition(ccp(3, 3))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tableViewBg:addChild(self.tv)
    if self.cellHeight > self.tvSize.height then
        self.tv:setMaxDisToBottomOrTop(100)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    
    self.refreshListener = function(event, data)
        if data == nil then
            return
        end
        local function refresUI()
            self.adjData = heroAdjutantVoApi:getAdjutant(self.heroVo.hid)
            self:setAdjutantIcon(data.adjIndex)
            self.cellHeight = self:getCellHieght()
            self.tv:reloadData()
            if self.cellHeight > self.tvSize.height then
                self.tv:setMaxDisToBottomOrTop(100)
            else
                self.tv:setMaxDisToBottomOrTop(0)
            end
            self.isRunningAction = false
            if data.eventType == 1 then
            	if data.adjIndex and data.adjIndex < 4 then
            		self:setAdjutantIcon(data.adjIndex + 1)
            	end
            	if self.parent and type(self.parent.refresh) == "function" then
            		self.parent:refresh(data.adjIndex)
            	end
            elseif data.eventType == 2 or data.eventType == 4 then
                self:setExtraPropertyIcon(propBg)
                if data.eventType == 2 then
                	if self.parent and type(self.parent.refresh) == "function" then
                		self.parent:refresh(data.adjIndex)
                	end
                elseif data.eventType == 4 then
                    heroAdjutantVoApi:sendUpgradeMessage(self.heroVo.hid, data.adjIndex)
                end
            end
            eventDispatcher:dispatchEvent("heroAdjutant.list.refresh", {hid = self.heroVo.hid})
        end
        -- eventType 1:激活, 2:装配, 3:替换, 4:升级
        if data.eventType == 3 or data.eventType == 4 then
            local animIndex
            if data.eventType == 3 then
                animIndex = 2
            elseif data.eventType == 4 then
                animIndex = 1
            end
            if animIndex then
                self.isRunningAction = true
                local adjIcon = tolua.cast(self.infoBg:getChildByTag(1000 + data.adjIndex), "CCSprite")
                local animSp, animSeq = self:createAnim(animIndex, refresUI)
                animSp:setPosition(adjIcon:getPositionX(), adjIcon:getPositionY() + 30)
                self.infoBg:addChild(animSp, 10)
                animSp:runAction(animSeq)
            end
        else
            refresUI()
        end
    end
    eventDispatcher:addEventListener("heroAdjutant.inif.refresh", self.refreshListener)
    
    local function storeHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        heroAdjutantVoApi:showAdjutantStoreDialog(self.layerNum + 1)
    end
    local btnScale = 0.8
    local storeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", storeHandler, 11, getlocal("accessory_title_3"), 24 / btnScale)
    storeBtn:setScale(btnScale)
    storeBtn:setAnchorPoint(ccp(0.5, 0.5))
    local menu = CCMenu:createWithItem(storeBtn)
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    menu:setPosition(G_VisibleSizeWidth / 2, storeBtn:getContentSize().height * storeBtn:getScale() / 2 + 20)
    self.bgLayer:addChild(menu)
end

function heroAdjutantInfoDialog:setAdjutantIcon(index)
    local iconTag = 1000 + index
    local eventType --1:激活, 2:装配副官, 3:替换副官
    local adjId, adjActivateState, adjActivateExp, adjCurLv
    if self.adjData and self.adjData[index] then
        if self.adjData[index][1] == 1 then
            adjActivateState = true
            eventType = 2
        end
        adjActivateExp = self.adjData[index][2]
        if self.adjData[index][3] then
            adjId = self.adjData[index][3]
            adjCurLv = self.adjData[index][4]
            eventType = 3
        end
    end
    local icon = heroAdjutantVoApi:getAdjutantIcon(adjId, adjActivateState, true, function()
        -- print("cjl ----->>> eventType", eventType)
        if eventType == 1 then
            if index == 1 or (index > 1 and heroAdjutantVoApi:isActivate(self.heroVo.hid, index - 1)) then
                heroAdjutantVoApi:showActivateSmallDialog(self.layerNum + 1, {self.heroVo, index, adjActivateExp})
            else
                local curUnlockIndex = index - 1
                for j = 1, 4 do
                    if heroAdjutantVoApi:isActivate(self.heroVo.hid, j) == false then
                        curUnlockIndex = j
                        break
                    end
                end
                local tipStr = getlocal("heroAdjutant_pointUnlockTips", {curUnlockIndex})
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
            end
        elseif eventType == 2 then
            heroAdjutantVoApi:showAdjutantStoreDialog(self.layerNum + 1, eventType, self.heroVo, index)
        elseif eventType == 3 then
            if not self.isRunningAction then
                heroAdjutantVoApi:showInfoSmallDialog(self.layerNum + 1, {adjId, adjCurLv, eventType, self.heroVo, index})
            end
        end
    end, true, index)
    icon:setScale(0.55)
    icon:setPositionX(self.infoBg:getContentSize().width / 2 + ((index % 2 ~= 0) and - 1 or 1) * 220)
    icon:setPositionY(self.infoBg:getContentSize().height / 2 + ((index > 2) and - 1 or 1) * (icon:getContentSize().height * icon:getScale() / 2 + 12))
    icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    local oldIcon = tolua.cast(self.infoBg:getChildByTag(iconTag), "CCSprite")
    if oldIcon then
        oldIcon:removeFromParentAndCleanup(true)
        oldIcon = nil
    end
    icon:setTag(iconTag)
    self.infoBg:addChild(icon)
    if adjId and adjCurLv then
        heroAdjutantVoApi:setAdjLevel(icon, adjId, adjCurLv)
    else
        local stateSp = tolua.cast(icon:getChildByTag(502), "CCSprite")
        local tipsStr, tipsLabelColor
        if adjActivateState == true then --可装配
            tipsStr = getlocal("heroAdjutant_equipTips")
            tipsLabelColor = G_ColorGreen
            if stateSp then
                local arr = CCArray:create()
                arr:addObject(CCScaleTo:create(0.25, 1.2))
                arr:addObject(CCScaleTo:create(0.25, 1))
                arr:addObject(CCScaleTo:create(0.25, 1.2))
                arr:addObject(CCScaleTo:create(0.25, 1))
                arr:addObject(CCScaleTo:create(0.25, 1.2))
                arr:addObject(CCScaleTo:create(0.25, 1))
                arr:addObject(CCDelayTime:create(math.random(2, 3)))
                stateSp:runAction(CCRepeatForever:create(CCSequence:create(arr)))
            end
        else
            local needStarLv = heroAdjutantVoApi:getAdjutantCfg().needHeroStar[index]
            if self.heroVo.productOrder >= needStarLv then --可激活
                eventType = 1
                tipsStr = getlocal("heroAdjutant_activateTips")
                if stateSp and (index == 1 or (index > 1 and heroAdjutantVoApi:isActivate(self.heroVo.hid, index - 1))) then
                    local arr = CCArray:create()
                    arr:addObject(CCRotateTo:create(0.15, -15))
                    arr:addObject(CCRotateTo:create(0.30, 15))
                    arr:addObject(CCRotateTo:create(0.25, -10))
                    arr:addObject(CCRotateTo:create(0.25, 10))
                    arr:addObject(CCRotateTo:create(0.15, -5))
                    arr:addObject(CCRotateTo:create(0.15, 5))
                    arr:addObject(CCRotateTo:create(0.05, 0))
                    arr:addObject(CCDelayTime:create(math.random(3, 5)))
                    stateSp:runAction(CCRepeatForever:create(CCSequence:create(arr)))
                end
                tipsLabelColor = G_ColorGreen
            else --将领星级达到x星可解锁
                tipsStr = getlocal("heroAdjutant_unlockTips", {needStarLv})
                tipsLabelColor = G_ColorRed
            end
        end
        local tipsLabel = GetTTFLabelWrap(tipsStr, 35, CCSizeMake(icon:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        tipsLabel:setPosition(icon:getContentSize().width / 2, 55)
        tipsLabel:setColor(tipsLabelColor)
        icon:addChild(tipsLabel)
    end
end

function heroAdjutantInfoDialog:setExtraPropertyIcon(propBg)
    local propIconFirstPosX
    local propIconScapeW = 18
    local adjTotalLv = heroAdjutantVoApi:getAdjutantTotalLevel(self.heroVo.hid)
    for i = 1, 4 do
        local propIconTag = 100 + i
        local oldPropIcon = tolua.cast(propBg:getChildByTag(propIconTag), "CCSprite")
        if oldPropIcon then
            oldPropIcon:removeFromParentAndCleanup(true)
            oldPropIcon = nil
        end
        local propIconName = "adj_propertyIcon_lock.png"
        if adjTotalLv >= heroAdjutantVoApi:getAdjutantCfg().chainEffectList[i].totalLv then
            propIconName = "adj_property_icon"..i..".png"
        end
        local propIcon = CCSprite:createWithSpriteFrameName(propIconName)
        propIcon:setScale(0.35)
        if propIconFirstPosX == nil then
            propIconFirstPosX = (propBg:getContentSize().width - (propIcon:getContentSize().width * propIcon:getScale() * 4 + (4 - 1) * propIconScapeW)) / 2
        end
        propIcon:setAnchorPoint(ccp(0, 0))
        propIcon:setPosition(propIconFirstPosX + (i - 1) * (propIcon:getContentSize().width * propIcon:getScale() + propIconScapeW), 10)
        propIcon:setTag(propIconTag)
        propBg:addChild(propIcon)
    end
end

function heroAdjutantInfoDialog:getCellHieght()
    if self.adjData == nil or #self.adjData == 0 then
        do return self.tvSize.height end
    end
    local height = 0
    
    local cellW = self.tvSize.width
    local maxLv = heroAdjutantVoApi:getAdjutantTotalLevel(self.heroVo.hid)
    local adjutantTotalLvLb = GetTTFLabelWrap(getlocal("adjutant_totallv", {heroVoApi:getHeroName(self.heroVo.hid), maxLv}), 24, CCSizeMake(cellW, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    height = height + adjutantTotalLvLb:getContentSize().height + 30
    
    local iconWidth = 80
    local leftPosX = 40
    local fontWidth = cellW - iconWidth - 2 * leftPosX - 10
    if self.adjData then
        for k, v in pairs(self.adjData) do
            local adjId, adjCurLv = v[3], v[4]
            if adjId and adjCurLv then
                local descStr = heroAdjutantVoApi:getAdjutantDesc(adjId, adjCurLv)
                local colorTb = heroAdjutantVoApi:getAdjutantDescColor(adjId, 1)
                local descLb, lbHeight = G_getRichTextLabel(descStr, colorTb, 22, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                if lbHeight > iconWidth then
                    height = height + lbHeight
                else
                    height = height + iconWidth
                end
                height = height + 10
            end
        end
    end
    
    -- height = height + 15
    -- local titleLb = GetTTFLabelWrap(getlocal("heroAdjutant_adjEffectTitle"), 24, CCSizeMake(self.tvSize.width - 200, 0), kCCTextAlignmentCenter, kCCTextAlignmentCenter, "Helvetica-bold")
    -- height = height + titleLb:getContentSize().height + 15
    -- height = height + 15
    -- local titleLb = GetTTFLabelWrap(getlocal("heroAdjutant_extraEffect"), 24, CCSizeMake(self.tvSize.width - 200, 0), kCCTextAlignmentCenter, kCCTextAlignmentCenter, "Helvetica-bold")
    -- height = height + titleLb:getContentSize().height + 15
    -- local isShowTipsLb = true
    -- if self.adjData then
    --     for k, v in pairs(self.adjData) do
    --         local adjId, adjCurLv = v[3], v[4]
    --         if adjId and adjCurLv then
    --             local descStr = heroAdjutantVoApi:getAdjutantDesc(adjId, adjCurLv)
    --             local colorTb = heroAdjutantVoApi:getAdjutantDescColor(adjId, 1)
    --             local descLb, lbHeight = G_getRichTextLabel(descStr, colorTb, 22, self.tvSize.width - 30, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    --             height = height + lbHeight
    --             isShowTipsLb = nil
    --         end
    --     end
    --     local propTb = heroAdjutantVoApi:getExtraProperty(self.heroVo.hid)
    --     if propTb and SizeOfTable(propTb) > 0 then
    --         for k, v in pairs(propTb) do
    --             local propCfg = heroAdjutantVoApi:getPropertyCfg(v.key, v.value)
    --             if propCfg then
    --                 local propLb = GetTTFLabelWrap(propCfg.name, 22, CCSizeMake(self.tvSize.width - 30, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
    --                 height = height + propLb:getContentSize().height
    --             end
    --         end
    --     end
    -- end
    -- if isShowTipsLb then
    --     local tipsLb = GetTTFLabel(getlocal("ladderRank_noRank"), 24, true)
    --     height = height + (tipsLb:getContentSize().height + 20) * 2
    -- end
    return height
end

function heroAdjutantInfoDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvSize.width, self.cellHeight
        local leftPosX = 40
        local iconWidth = 80
        local fontWidth = cellW - iconWidth - 2 * leftPosX - 10
        --副官总等级
        local maxLv = heroAdjutantVoApi:getAdjutantTotalLevel(self.heroVo.hid)
        local adjutantTotalLvLb = GetTTFLabelWrap(getlocal("adjutant_totallv", {heroVoApi:getHeroName(self.heroVo.hid), maxLv}), 24, CCSizeMake(cellW, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        adjutantTotalLvLb:setPosition(cellW / 2, cellH - adjutantTotalLvLb:getContentSize().height / 2 - 10)
        adjutantTotalLvLb:setColor(G_ColorYellowPro)
        cell:addChild(adjutantTotalLvLb)
        
        local noAdjutantFlag = true
        local posY = adjutantTotalLvLb:getPositionY() - adjutantTotalLvLb:getContentSize().height / 2 - 20
        --副官技能
        if self.adjData then
            for k, v in pairs(self.adjData) do
                local adjId, adjCurLv = v[3], v[4]
                if adjId and adjCurLv then
                    local iconSp = heroAdjutantVoApi:getAdjutantIcon(adjId)
                    iconSp:setAnchorPoint(ccp(0, 0.5))
                    iconSp:setScale(iconWidth / iconSp:getContentSize().width)
                    iconSp:setPosition(leftPosX, posY - iconWidth / 2)
                    cell:addChild(iconSp)
                    local descStr = heroAdjutantVoApi:getAdjutantDesc(adjId, adjCurLv)
                    local colorTb = heroAdjutantVoApi:getAdjutantDescColor(adjId, 1)
                    local descLb, lbHeight = G_getRichTextLabel(descStr, colorTb, 22, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(leftPosX + iconWidth + 10, posY)
                    cell:addChild(descLb)
                    if lbHeight > iconWidth then
                        posY = posY - lbHeight
                    else
                        posY = posY - iconWidth
                    end
                    posY = posY - 10
                    noAdjutantFlag = false
                end
            end
        end
        if noAdjutantFlag == true then
            local tipsLb = GetTTFLabel(getlocal("no_equip_adjutant"), 24, true)
            tipsLb:setPosition(cellW / 2, self.tvSize.height / 2 - 30)
            tipsLb:setColor(G_ColorGray)
            cell:addChild(tipsLb)
        end
        -- local titleBg1, titleLb1, titleLbHeight1 = G_createNewTitle({getlocal("heroAdjutant_adjEffectTitle"), 24, G_ColorYellowPro}, CCSizeMake(self.tvSize.width - 200, 0), nil, true, "Helvetica-bold")
        -- titleBg1:setPosition(cellW / 2, cellH - titleLbHeight1 - 15)
        -- cell:addChild(titleBg1)
        -- local posY = titleBg1:getPositionY() - 15
        -- local isShowTipsLb = true
        -- if self.adjData then
        --     for k, v in pairs(self.adjData) do
        --         local adjId, adjCurLv = v[3], v[4]
        --         if adjId and adjCurLv then
        --             local descStr = heroAdjutantVoApi:getAdjutantDesc(adjId, adjCurLv)
        --             local colorTb = heroAdjutantVoApi:getAdjutantDescColor(adjId, 1)
        --             local descLb, lbHeight = G_getRichTextLabel(descStr, colorTb, 22, self.tvSize.width - 30, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        --             descLb:setAnchorPoint(ccp(0, 1))
        --             descLb:setPosition(15, posY)
        --             cell:addChild(descLb)
        --             posY = descLb:getPositionY() - lbHeight
        --             isShowTipsLb = nil
        --         end
        --     end
        -- end
        -- if isShowTipsLb then
        --     local tipsLb = GetTTFLabel(getlocal("ladderRank_noRank"), 24, true)
        --     tipsLb:setPosition(cellW / 2, posY - tipsLb:getContentSize().height / 2)
        --     tipsLb:setColor(G_ColorGray)
        --     cell:addChild(tipsLb)
        --     posY = posY - tipsLb:getContentSize().height / 2 - 15
        -- end
        
        -- posY = posY - 15
        -- local titleBg2, titleLb2, titleLbHeight2 = G_createNewTitle({getlocal("heroAdjutant_extraEffect"), 24, G_ColorYellowPro}, CCSizeMake(self.tvSize.width - 200, 0), nil, true, "Helvetica-bold")
        -- titleBg2:setPosition(cellW / 2, posY - titleLbHeight2)
        -- cell:addChild(titleBg2)
        -- local posY = titleBg2:getPositionY() - 15
        -- local propTb = heroAdjutantVoApi:getExtraProperty(self.heroVo.hid)
        -- if propTb and SizeOfTable(propTb) > 0 then
        --     for k, v in pairs(propTb) do
        --         local propCfg = heroAdjutantVoApi:getPropertyCfg(v.key, v.value)
        --         if propCfg then
        --             local propLb = GetTTFLabelWrap(propCfg.name, 22, CCSizeMake(self.tvSize.width - 30, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
        --             propLb:setPosition(cellW / 2, posY - propLb:getContentSize().height / 2)
        --             cell:addChild(propLb)
        --             posY = propLb:getPositionY() - propLb:getContentSize().height / 2
        --         end
        --     end
        -- end
        -- if isShowTipsLb then
        --     local tipsLb = GetTTFLabel(getlocal("ladderRank_noRank"), 24, true)
        --     tipsLb:setPosition(cellW / 2, posY - tipsLb:getContentSize().height / 2)
        --     tipsLb:setColor(G_ColorGray)
        --     cell:addChild(tipsLb)
        --     posY = posY - tipsLb:getContentSize().height / 2
        -- end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function heroAdjutantInfoDialog:doUserHandler()
end

function heroAdjutantInfoDialog:tick()
end

function heroAdjutantInfoDialog:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("heroAdjutant.inif.refresh", self.refreshListener)
        self.refreshListener = nil
    end
    self = nil
    spriteController:removePlist("public/limitChallenge.plist")
    spriteController:removeTexture("public/limitChallenge.png")
    spriteController:removePlist("public/heroAdjutantEffect.plist")
    spriteController:removeTexture("public/heroAdjutantEffect.png")
end
