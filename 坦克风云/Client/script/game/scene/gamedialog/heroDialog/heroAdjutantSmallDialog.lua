heroAdjutantSmallDialog = smallDialog:new()

function heroAdjutantSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function heroAdjutantSmallDialog:showActivateDialog(layerNum, titleStr, params)
    local sd = heroAdjutantSmallDialog:new()
    sd:initActivateDialog(layerNum, titleStr, params)
end

function heroAdjutantSmallDialog:initActivateDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local heroVo = params[1]
    local adjPoint = params[2]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 580)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local icon = heroAdjutantVoApi:getAdjutantIcon(nil, nil, nil, nil, nil, adjPoint)
    icon:setScale(0.55)
    icon:setPosition(self.bgSize.width / 2, self.bgSize.height - 140)
    self.bgLayer:addChild(icon)
    
    local progressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("VipIconYellowBar.png"))
    progressBar:setMidpoint(ccp(0, 1))
    progressBar:setBarChangeRate(ccp(1, 0))
    progressBar:setType(kCCProgressTimerTypeBar)
    -- local barWidth, barHeight = self.bgSize.width - 100, progressBar:getContentSize().height
    -- progressBar:setScaleX(barWidth / progressBar:getContentSize().width)
    -- progressBar:setScaleY(barHeight / progressBar:getContentSize().height)
    -- local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellowBarBg.png", CCRect(4, 4, 1, 1), function()end)
    -- progressBarBg:setContentSize(CCSizeMake(barWidth + 6, barHeight + 5))
    local progressBarBg = CCSprite:createWithSpriteFrameName("VipIconYellowBarBg.png")
    progressBarBg:setAnchorPoint(ccp(0.5, 1))
    progressBarBg:setPosition(self.bgSize.width / 2, icon:getPositionY() - icon:getContentSize().height * icon:getScale() / 2 - 10)
    progressBar:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2)
    progressBarBg:addChild(progressBar)
    self.bgLayer:addChild(progressBarBg)
    local maxExp = heroAdjutantVoApi:getAdjutantCfg().unlockNeedExp[adjPoint]
    local heroAdjData = heroAdjutantVoApi:getAdjutant(heroVo.hid)
    local adjActivateExp = 0
    if heroAdjData and heroAdjData[adjPoint] then
        adjActivateExp = heroAdjData[adjPoint][2]
    end
    progressBar:setPercentage(adjActivateExp / maxExp * 100)
    local progressLb = GetTTFLabel(adjActivateExp .. "/" .. maxExp, 20, true)
    progressLb:setPosition(progressBarBg:getContentSize().width / 2, progressBarBg:getContentSize().height / 2 + 2)
    progressBarBg:addChild(progressLb)
    
    local tipsLabel = GetTTFLabelWrap(getlocal("heroAdjutant_costPorpsTips"), 24, CCSizeMake(self.bgSize.width - 70, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipsLabel:setPosition(self.bgSize.width / 2, progressBarBg:getPositionY() - progressBarBg:getContentSize().height - 10 - tipsLabel:getContentSize().height / 2)
    self.bgLayer:addChild(tipsLabel)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(self.bgSize.width - 70, tipsLabel:getPositionY() - tipsLabel:getContentSize().height / 2 - 125))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(self.bgSize.width / 2, tipsLabel:getPositionY() - tipsLabel:getContentSize().height / 2 - 10)
    self.bgLayer:addChild(tableViewBg)
    
    local adjutantStoreTb = heroAdjutantVoApi:getActiveCostAdjutants()
    local cellNum = SizeOfTable(adjutantStoreTb or {})
    local tv, curSelectedIcon, curSelectedAdjId
    local tvSize = CCSizeMake(tableViewBg:getContentSize().width - 16, tableViewBg:getContentSize().height - 6)
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(140, tvSize.height)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = 140, tvSize.height
            local adjData = adjutantStoreTb[idx + 1]
            if adjData then
                local adjId, adjNum, adjIcon = adjData[1], adjData[2]
                local function addSelectedSp(iconSp)
                    local selectedSp = LuaCCScale9Sprite:createWithSpriteFrameName("adj_selected.png", CCRect(59, 59, 2, 2), function()end)
                    selectedSp:setContentSize(CCSizeMake(iconSp:getContentSize().width + 30, iconSp:getContentSize().height + 30))
                    selectedSp:setPosition(iconSp:getContentSize().width / 2, iconSp:getContentSize().height / 2)
                    selectedSp:setTag(301)
                    iconSp:addChild(selectedSp)
                    curSelectedAdjId = adjId
                    curSelectedIcon = iconSp
                end
                adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, function()
                    if tv and tv:getIsScrolled() == false then
                        if curSelectedAdjId ~= adjId then
                            local prevSelectedSp = tolua.cast(curSelectedIcon:getChildByTag(301), "CCSprite")
                            if prevSelectedSp then
                                prevSelectedSp:removeFromParentAndCleanup(true)
                                prevSelectedSp = nil
                            end
                            addSelectedSp(adjIcon)
                        end
                    end
                end)
                adjIcon:setScale(0.45)
                adjIcon:setPosition(cellW / 2, cellH / 2)
                adjIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cell:addChild(adjIcon)
                local numLb = GetTTFLabel("x" .. adjNum, 30, true)
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setPosition(adjIcon:getContentSize().width - 50, 125)
                numLb:setTag(401)
                adjIcon:addChild(numLb, 1)
                local numLbBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                numLbBg:setRotation(180)
                numLbBg:setScaleX((numLb:getContentSize().width + 30) / numLbBg:getContentSize().width)
                numLbBg:setScaleY(numLb:getContentSize().height / numLbBg:getContentSize().height)
                numLbBg:setAnchorPoint(ccp(0, 1))
                numLbBg:setPosition(numLb:getPosition())
                adjIcon:addChild(numLbBg)
                local levelBg = tolua.cast(adjIcon:getChildByTag(501), "CCSprite")
                if levelBg then
                    levelBg:removeFromParentAndCleanup(true)
                    levelBg = nil
                end
                local addExpLb = GetTTFLabel("+" .. heroAdjutantVoApi:getAdjutantCfg().adjutantList[adjId].decomposeExp, 30, true)
                addExpLb:setAnchorPoint(ccp(0.5, 0))
                addExpLb:setPosition(adjIcon:getContentSize().width / 2, 10)
                adjIcon:addChild(addExpLb)
                if idx == 0 then
                    addSelectedSp(adjIcon)
                end
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    tv = LuaCCTableView:createHorizontalWithEventHandler(hd, tvSize, nil)
    tv:setPosition(ccp(8, 3))
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(tv)
    
    local btn1Str, btn2Str = getlocal("heroAdjutant_batchOperation"), getlocal("activation")
    local btn1ImageNormal, btn1ImageDown = "newGreenBtn.png", "newGreenBtn_down.png"
    if cellNum == 0 then
        local notDataLb = GetTTFLabelWrap(getlocal("heroAdjutant_notStoreData"), 24, CCSizeMake(tableViewBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        notDataLb:setPosition(tableViewBg:getContentSize().width / 2, tableViewBg:getContentSize().height / 2)
        notDataLb:setColor(G_ColorGray)
        tableViewBg:addChild(notDataLb)
        btn1Str, btn2Str = getlocal("accessory_get"), getlocal("bundle")
        btn1ImageNormal, btn1ImageDown = "creatRoleBtn.png", "creatRoleBtn_Down.png"
    end
    
    local batchBtn, activateBtn
    local function refreshUI(useNum)
        heroAdjData = heroAdjutantVoApi:getAdjutant(heroVo.hid)
        if heroAdjData and heroAdjData[adjPoint] then
            adjActivateExp = heroAdjData[adjPoint][2]
        end
        local isClose
        local per = adjActivateExp / maxExp * 100
        if per >= 100 then
            per = 100
            isClose = true
        end
        local progressFromTo = CCProgressFromTo:create(0.5, progressBar:getPercentage(), per)
        local progressCallFunc = CCCallFunc:create(function()
            progressLb:setString(adjActivateExp .. "/" .. maxExp)
        end)
        progressBar:runAction(CCSequence:createWithTwoActions(progressFromTo, progressCallFunc))
        -- progressBar:setPercentage(per)
        -- progressLb:setString(adjActivateExp .. "/" .. maxExp)
        local numLb = tolua.cast(curSelectedIcon:getChildByTag(401), "CCLabelTTF")
        local adjNum = tonumber(RemoveFirstChar(numLb:getString())) - (useNum or 1)
        if adjNum > 0 then
            numLb:setString("x" .. adjNum)
        else
            adjutantStoreTb = heroAdjutantVoApi:getActiveCostAdjutants()
            cellNum = SizeOfTable(adjutantStoreTb or {})
            tv:reloadData()
        end
        if isClose == true then
            self:close()
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("buffSuccess"), 30)
            eventDispatcher:dispatchEvent("heroAdjutant.inif.refresh", {eventType = 1, adjIndex = adjPoint})
        else
            if cellNum == 0 then
                if batchBtn then
                    batchBtn:setEnabled(false)
                end
                if activateBtn then
                    activateBtn:setEnabled(false)
                end
            end
        end
    end
    
    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
            if cellNum == 0 then --获取(商店)
                self:close()
                activityAndNoteDialog:closeAllDialog()
                allShopVoApi:showAllPropDialog(self.layerNum + 1, "preferential")
            else --批量操作
                if curSelectedAdjId then
                    local numLb = tolua.cast(curSelectedIcon:getChildByTag(401), "CCLabelTTF")
                    local adjNum = tonumber(RemoveFirstChar(numLb:getString()))
                    heroAdjutantVoApi:showBatchActivateSmallDialog(self.layerNum + 1, {heroVo, adjPoint, curSelectedAdjId, adjNum, refreshUI})
                else
                    print("cjl -------->>> ERROR: 请选择消耗的道具！")
                end
            end
        elseif tag == 11 then
            if cellNum == 0 then --背包
                G_closeAllSmallDialog()
                activityAndNoteDialog:closeAllDialog()
                shopVoApi:showPropDialog(self.layerNum + 1, true, 2)
            else --激活
                if curSelectedAdjId then
                    local pAdjTb = {}
                    pAdjTb[curSelectedAdjId] = 1
                    heroAdjutantVoApi:requestActivate(function()
                        refreshUI()
                    end, heroVo.hid, adjPoint, pAdjTb)
                else
                    print("cjl -------->>> ERROR: 请选择消耗的道具！")
                end
            end
        end
    end
    local btnScale = 0.8
    batchBtn = GetButtonItem(btn1ImageNormal, btn1ImageDown, btn1ImageNormal, onClickHandler, 10, btn1Str, 24 / btnScale)
    activateBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, btn2Str, 24 / btnScale)
    batchBtn:setScale(btnScale)
    activateBtn:setScale(btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(batchBtn)
    menuArr:addObject(activateBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    self.bgLayer:addChild(btnMenu)
    batchBtn:setPosition(self.bgSize.width / 2 - batchBtn:getContentSize().width * batchBtn:getScale() / 2 - 50, 35 + batchBtn:getContentSize().height * batchBtn:getScale() / 2)
    activateBtn:setPosition(self.bgSize.width / 2 + activateBtn:getContentSize().width * activateBtn:getScale() / 2 + 50, 35 + activateBtn:getContentSize().height * activateBtn:getScale() / 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroAdjutantSmallDialog:showBatchActivateDialog(layerNum, titleStr, params)
    local sd = heroAdjutantSmallDialog:new()
    sd:initBatchActivateDialog(layerNum, titleStr, params)
end

function heroAdjutantSmallDialog:initBatchActivateDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local heroVo = params[1]
    local adjPoint = params[2]
    local selectedAdjId = params[3]
    local adjNum = params[4]
    local callback = params[5]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(550, 500)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    -- local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    local dialogBg, lineSp1, lineSp2 = G_getNewDialogBg2(self.bgSize, self.layerNum, function()end)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local tipsLabel = GetTTFLabelWrap(getlocal("heroAdjutant_costPorpsTips"), 24, CCSizeMake(self.bgSize.width - 70, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    tipsLabel:setPosition(self.bgSize.width / 2, self.bgSize.height - 50)
    self.bgLayer:addChild(tipsLabel)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 70, 220))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, tipsLabel:getPositionY() - tipsLabel:getContentSize().height / 2 - 10)
    self.bgLayer:addChild(contentBg)
    local adjIcon = heroAdjutantVoApi:getAdjutantIcon(selectedAdjId, nil, true)
    adjIcon:setScale(0.6)
    adjIcon:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height / 2)
    contentBg:addChild(adjIcon)
    local numLb = GetTTFLabel("x" .. adjNum, 30, true)
    numLb:setAnchorPoint(ccp(1, 0))
    numLb:setPosition(adjIcon:getContentSize().width - 50, 125)
    numLb:setTag(401)
    adjIcon:addChild(numLb, 1)
    local numLbBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
    numLbBg:setRotation(180)
    numLbBg:setScaleX((numLb:getContentSize().width + 30) / numLbBg:getContentSize().width)
    numLbBg:setScaleY(numLb:getContentSize().height / numLbBg:getContentSize().height)
    numLbBg:setAnchorPoint(ccp(0, 1))
    numLbBg:setPosition(numLb:getPosition())
    adjIcon:addChild(numLbBg)
    local levelBg = tolua.cast(adjIcon:getChildByTag(501), "CCSprite")
    if levelBg then
        levelBg:removeFromParentAndCleanup(true)
        levelBg = nil
    end
    local decomposeExp = heroAdjutantVoApi:getAdjutantCfg().adjutantList[selectedAdjId].decomposeExp
    local addExpLb = GetTTFLabel("+" .. decomposeExp, 30, true)
    addExpLb:setAnchorPoint(ccp(0.5, 0))
    addExpLb:setPosition(adjIcon:getContentSize().width / 2, 10)
    adjIcon:addChild(addExpLb)
    
    local adjData = heroAdjutantVoApi:getAdjutant(heroVo.hid)
    local adjActivateExp = 0
    if adjData and adjData[adjPoint] then
        adjActivateExp = adjData[adjPoint][2]
    end
    local maxExp = heroAdjutantVoApi:getAdjutantCfg().unlockNeedExp[adjPoint]
    local needNum = math.ceil((maxExp - adjActivateExp) / decomposeExp)
    if needNum > adjNum then
        needNum = adjNum
    end
    -- if needNum > 100 then
    --     needNum = 100
    -- end
    local useNumLb = GetTTFLabel(getlocal("propInfoNum", {""}), 22)
    useNumLb:setAnchorPoint(ccp(1, 0.5))
    useNumLb:setPosition(self.bgSize.width / 2, contentBg:getPositionY() - contentBg:getContentSize().height - 10 - useNumLb:getContentSize().height / 2)
    self.bgLayer:addChild(useNumLb)
    local useNumValueLb = GetTTFLabel("1/" .. needNum, 22)
    useNumValueLb:setAnchorPoint(ccp(0, 0.5))
    useNumValueLb:setPosition(self.bgSize.width / 2, useNumLb:getPositionY())
    useNumValueLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(useNumValueLb)
    
    local curSelectedNum = 1
    local function onSliderHandler(handler, obj)
        local count = math.ceil(obj:getValue())
        if count > 0 then
            useNumValueLb:setString(count .. "/" .. needNum)
            addExpLb:setString("+" .. (tonumber(decomposeExp) * tonumber(count)))
            curSelectedNum = count
        end
    end
    local slider = LuaCCControlSlider:create(CCSprite:createWithSpriteFrameName("proBar_n2.png"), CCSprite:createWithSpriteFrameName("proBar_n1.png"), CCSprite:createWithSpriteFrameName("grayBarBtn.png"), onSliderHandler)
    slider:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    slider:setIsSallow(true)
    slider:setMinimumValue(1)
    slider:setMaximumValue(needNum)
    slider:setValue(1)
    slider:setPosition(self.bgSize.width / 2, useNumLb:getPositionY() - useNumLb:getContentSize().height / 2 - 30)
    self.bgLayer:addChild(slider)
    local minusSp = LuaCCSprite:createWithSpriteFrameName("greenMinus.png", function()
        slider:setValue(slider:getValue() - 1)
    end)
    minusSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    minusSp:setAnchorPoint(ccp(1, 0.5))
    minusSp:setPosition(slider:getPositionX() - slider:getContentSize().width / 2 - 20, slider:getPositionY())
    self.bgLayer:addChild(minusSp)
    local plusSp = LuaCCSprite:createWithSpriteFrameName("greenPlus.png", function()
        slider:setValue(slider:getValue() + 1)
    end)
    plusSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    plusSp:setAnchorPoint(ccp(0, 0.5))
    plusSp:setPosition(slider:getPositionX() + slider:getContentSize().width / 2 + 20, slider:getPositionY())
    self.bgLayer:addChild(plusSp)
    
    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then --取消
            self:close()
        elseif tag == 11 then --使用(激活-批量使用)
            if selectedAdjId then
                local pAdjTb = {}
                pAdjTb[selectedAdjId] = curSelectedNum
                heroAdjutantVoApi:requestActivate(function()
                    self:close()
                    if type(callback) == "function" then
                        callback(curSelectedNum)
                    end
                end, heroVo.hid, adjPoint, pAdjTb)
            else
                print("cjl -------->>> ERROR: 请选择消耗的道具！")
            end
        end
    end
    local btnScale = 0.8
    local cancelBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onClickHandler, 10, getlocal("cancel"), 24 / btnScale)
    local useBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickHandler, 11, getlocal("use"), 24 / btnScale)
    cancelBtn:setScale(btnScale)
    useBtn:setScale(btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(cancelBtn)
    menuArr:addObject(useBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    self.bgLayer:addChild(btnMenu)
    cancelBtn:setPosition(self.bgSize.width / 2 - cancelBtn:getContentSize().width * cancelBtn:getScale() / 2 - 50, 35 + cancelBtn:getContentSize().height * cancelBtn:getScale() / 2)
    useBtn:setPosition(self.bgSize.width / 2 + useBtn:getContentSize().width * useBtn:getScale() / 2 + 50, 35 + useBtn:getContentSize().height * useBtn:getScale() / 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroAdjutantSmallDialog:showInfoDialog(layerNum, titleStr, params)
    local sd = heroAdjutantSmallDialog:new()
    sd:initInfoDialog(layerNum, titleStr, params)
end

function heroAdjutantSmallDialog:initInfoDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local adjId = params[1]
    local adjCurLv = params[2] or 1
    local showType = params[3] --nil:查看副官, 2:装备副官, 3:替换和升级副官
    local heroVo = params[4]
    local adjPoint = params[5]
    local storeDialog = params[6]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 500)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 70, self.bgSize.height - 200))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 100)
    self.bgLayer:addChild(contentBg)
    
    local adjIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, nil, nil, nil, adjPoint)
    adjIcon:setScale(0.8)
    adjIcon:setAnchorPoint(ccp(0, 1))
    adjIcon:setPosition(20, contentBg:getContentSize().height - 10)
    contentBg:addChild(adjIcon)
    
    local adjCfgData = heroAdjutantVoApi:getAdjutantCfgData(adjId)
    if adjCfgData then
        local nameLb = GetTTFLabelWrap(getlocal(adjCfgData.name), 24, CCSizeMake(contentBg:getContentSize().width - (adjIcon:getPositionX() + adjIcon:getContentSize().width * adjIcon:getScale()) - 13, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(adjIcon:getPositionX() + adjIcon:getContentSize().width * adjIcon:getScale() + 10, adjIcon:getPositionY() - 15)
        nameLb:setColor(G_ColorYellowPro)
        contentBg:addChild(nameLb)
        
        local levelLb = GetTTFLabel(getlocal("fightLevel", {adjCurLv}) .. "/" .. getlocal("fightLevel", {adjCfgData.lvMax}), 24)
        levelLb:setAnchorPoint(ccp(0, 0.5))
        levelLb:setPosition(nameLb:getPositionX(), adjIcon:getPositionY() - adjIcon:getContentSize().height * adjIcon:getScale() / 2)
        contentBg:addChild(levelLb)
        
        local descStr = heroAdjutantVoApi:getAdjutantDesc(adjId, adjCurLv)
        local colorTb = heroAdjutantVoApi:getAdjutantDescColor(adjId, 1)
        local descLb, lbHeight = G_getRichTextLabel(descStr, colorTb, 24, contentBg:getContentSize().width - 40, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0, 1))
        descLb:setPosition(20, adjIcon:getPositionY() - adjIcon:getContentSize().height * adjIcon:getScale() - 10)
        contentBg:addChild(descLb)
        
        local contentBgBottomPosY = contentBg:getPositionY() - contentBg:getContentSize().height
        if showType == 2 then --装配副官
            local function onEquipHandler(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                heroAdjutantVoApi:requestEquip(function()
                    if storeDialog and storeDialog.close then
                        storeDialog:close()
                    end
                    self:close()
                    eventDispatcher:dispatchEvent("heroAdjutant.inif.refresh", {eventType = 2, adjIndex = adjPoint})
                end, heroVo.hid, adjPoint, adjId)
            end
            local btnScale = 0.8
            local equipBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onEquipHandler, 11, getlocal("accessory_ware"), 24 / btnScale)
            equipBtn:setScale(btnScale)
            local btnMenu = CCMenu:create()
            btnMenu:addChild(equipBtn)
            btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            btnMenu:setPosition(0, 0)
            equipBtn:setPosition(self.bgSize.width / 2, contentBgBottomPosY - 15 - equipBtn:getContentSize().height * equipBtn:getScale() / 2)
            self.bgLayer:addChild(btnMenu)
        elseif showType == 3 then --替换、升级
            local function onClickHandler(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if tag == 10 then --替换副官
                    local changeData = heroAdjutantVoApi:getAdjutantCanChangeData(heroVo, adjCurLv)
                    if changeData and SizeOfTable(changeData) > 0 then
                        heroAdjutantVoApi:showAdjutantChangeDialog(self.layerNum + 1, heroVo, adjPoint)
                        self:close()
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroAdjutant_notChangeData"), 30)
                    end
                elseif tag == 11 then --升级副官
                    self:close()
                    heroAdjutantVoApi:showUpgradeSmallDialog(self.layerNum + 1, {heroVo, adjPoint})
                end
            end
            local btnScale = 0.8
            local changeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("armorMatrix_change"), 24 / btnScale)
            local upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("upgradeBuild"), 24 / btnScale)
            changeBtn:setScale(btnScale)
            upgradeBtn:setScale(btnScale)
            local menuArr = CCArray:create()
            menuArr:addObject(changeBtn)
            menuArr:addObject(upgradeBtn)
            local btnMenu = CCMenu:createWithArray(menuArr)
            btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            btnMenu:setPosition(0, 0)
            self.bgLayer:addChild(btnMenu)
            changeBtn:setPosition(self.bgSize.width / 2 - changeBtn:getContentSize().width * changeBtn:getScale() / 2 - 50, contentBgBottomPosY - 15 - changeBtn:getContentSize().height * changeBtn:getScale() / 2)
            upgradeBtn:setPosition(self.bgSize.width / 2 + upgradeBtn:getContentSize().width * upgradeBtn:getScale() / 2 + 50, contentBgBottomPosY - 15 - upgradeBtn:getContentSize().height * upgradeBtn:getScale() / 2)
            if adjCurLv == adjCfgData.lvMax then
                upgradeBtn:setEnabled(false)
            end
        else
            local tipsLb, tipsLbHeight = G_getRichTextLabel(getlocal("heroAdjutant_reachConditionTips", {adjCfgData.heroStarLv}), {nil, G_ColorGreen, nil}, 24, contentBg:getContentSize().width, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            tipsLb:setAnchorPoint(ccp(0.5, 1))
            tipsLb:setPosition(self.bgSize.width / 2, contentBgBottomPosY - 15)
            self.bgLayer:addChild(tipsLb)
        end
    end
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroAdjutantSmallDialog:showUpgradeDialog(layerNum, titleStr, params)
    local sd = heroAdjutantSmallDialog:new()
    sd:initUpgradeDialog(layerNum, titleStr, params)
end

function heroAdjutantSmallDialog:initUpgradeDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local heroVo = params[1]
    local adjPoint = params[2]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 580)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 70, self.bgSize.height - 320))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 90)
    self.bgLayer:addChild(contentBg)
    
    local adjData = heroAdjutantVoApi:getAdjutant(heroVo.hid)
    local adjId, adjCurLv = adjData[adjPoint][3], adjData[adjPoint][4]
    local adjNextLv = adjCurLv + 1
    
    local adjCurLvIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, nil, nil, adjPoint)
    adjCurLvIcon:setScale(0.68)
    heroAdjutantVoApi:setAdjLevel(adjCurLvIcon, adjId, adjCurLv)
    adjCurLvIcon:setPosition(contentBg:getContentSize().width / 2 - 50 - adjCurLvIcon:getContentSize().width * adjCurLvIcon:getScale() / 2, contentBg:getContentSize().height / 2)
    contentBg:addChild(adjCurLvIcon)
    local arrowSp = CCSprite:createWithSpriteFrameName("hellChallengeArrow2.png")
    arrowSp:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height / 2)
    contentBg:addChild(arrowSp)
    local adjNextLvIcon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, nil, nil, adjPoint)
    adjNextLvIcon:setScale(0.68)
    heroAdjutantVoApi:setAdjLevel(adjNextLvIcon, adjId, adjNextLv)
    adjNextLvIcon:setPosition(contentBg:getContentSize().width / 2 + 50 + adjNextLvIcon:getContentSize().width * adjNextLvIcon:getScale() / 2, contentBg:getContentSize().height / 2)
    contentBg:addChild(adjNextLvIcon)
    
    local contentPosY = contentBg:getPositionY() - contentBg:getContentSize().height
    
    local propLb = GetTTFLabel(getlocal("heroAdjutant_propertyText"), 24, true)
    propLb:setAnchorPoint(ccp(1, 0.5))
    propLb:setPosition(150, contentPosY - 10 - propLb:getContentSize().height / 2)
    self.bgLayer:addChild(propLb)
    contentPosY = propLb:getPositionY() - propLb:getContentSize().height / 2
    local adjCurLvPropLb = GetTTFLabel(heroAdjutantVoApi:getAdjutantProperty(adjId, adjCurLv), 24, true)
    adjCurLvPropLb:setAnchorPoint(ccp(0, 0.5))
    adjCurLvPropLb:setPosition(propLb:getPositionX(), propLb:getPositionY())
    self.bgLayer:addChild(adjCurLvPropLb)
    local pArrow = CCSprite:createWithSpriteFrameName("arrowUp.png")
    pArrow:setPosition(adjCurLvPropLb:getPositionX() + adjCurLvPropLb:getContentSize().width + 15 + pArrow:getContentSize().width / 2, propLb:getPositionY())
    self.bgLayer:addChild(pArrow)
    local adjNextLvPropLb = GetTTFLabel(heroAdjutantVoApi:getAdjutantProperty(adjId, adjNextLv), 24, true)
    adjNextLvPropLb:setAnchorPoint(ccp(0, 0.5))
    adjNextLvPropLb:setPosition(pArrow:getPositionX() + pArrow:getContentSize().width / 2 + 15, propLb:getPositionY())
    self.bgLayer:addChild(adjNextLvPropLb)
    
    local iconSize = 80
    local costLb = GetTTFLabel(getlocal("activity_xuyuanlu_costGolds", {""}), 24, true)
    costLb:setAnchorPoint(ccp(1, 0.5))
    costLb:setPosition(propLb:getPositionX(), contentPosY - 10 - iconSize / 2)
    self.bgLayer:addChild(costLb)
    contentPosY = costLb:getPositionY() - iconSize / 2
    
    local isCanUpgrade = true
    local itemTb = heroAdjutantVoApi:getAdjutantUpgradeItem(adjId, adjCurLv)
    if itemTb then
        for k, v in pairs(itemTb) do
            local icon, scale = G_getItemIcon(v, 100, true, self.layerNum)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setAnchorPoint(ccp(0, 0.5))
            icon:setPosition(costLb:getPositionX() + (k - 1) * (icon:getContentSize().width * scale + 20), costLb:getPositionY())
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            self.bgLayer:addChild(icon)
            local curNum = 0
            if v.type == "aj" then
                curNum = heroAdjutantVoApi:getAdjutantNum(adjId)
            else
                curNum = bagVoApi:getItemNumId(v.id)
            end
            curNum = tonumber(curNum)
            local numLb = GetTTFLabel(FormatNumber(curNum) .. "/" .. FormatNumber(v.num), 18)
            if curNum < v.num then
                numLb:setColor(G_ColorRed)
                isCanUpgrade = false
            end
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize / 2 + 5)
            self.bgLayer:addChild(numBg)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            self.bgLayer:addChild(numLb)
        end
    end
    
    local function onUpgradeHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if isCanUpgrade == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroAdjutant_costItemTips"), 30)
            do return end
        end
        heroAdjutantVoApi:requestUpgrade(function()
            self:close()
            eventDispatcher:dispatchEvent("heroAdjutant.inif.refresh", {eventType = 4, adjIndex = adjPoint})
            if itemTb then
                for k, v in pairs(itemTb) do
                    G_addPlayerAward(v.type, v.key, v.id, -1 * tonumber(v.num), false, true)
                end
            end
        end, heroVo.hid, adjPoint)
    end
    local btnScale = 0.8
    local upgradeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onUpgradeHandler, 11, getlocal("upgradeBuild"), 24 / btnScale)
    upgradeBtn:setScale(btnScale)
    local btnMenu = CCMenu:create()
    btnMenu:addChild(upgradeBtn)
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    upgradeBtn:setPosition(self.bgSize.width / 2, contentPosY - 15 - upgradeBtn:getContentSize().height * upgradeBtn:getScale() / 2)
    self.bgLayer:addChild(btnMenu)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroAdjutantSmallDialog:showExtraPropertyDialog(layerNum, titleStr, params)
    local sd = heroAdjutantSmallDialog:new()
    sd:initExtraPropertyDialog(layerNum, titleStr, params)
end

function heroAdjutantSmallDialog:initExtraPropertyDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local hid = params[1]
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 595)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 105))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 80)
    self.bgLayer:addChild(tableViewBg)
    
    local adjTotalLv = heroAdjutantVoApi:getAdjutantTotalLevel(hid)
    local effectList = heroAdjutantVoApi:getAdjutantCfg().chainEffectList
    local cellNum = SizeOfTable(effectList or {})
    local tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvSize.width, 120)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = tvSize.width, 120
            local propData = effectList[idx + 1]
            local needLevel = propData.totalLv
            local propIconName = "adj_propertyIcon_lock.png"
            local unlockTipsStr, unlockLbColor, propLbColor = getlocal("heroAdjutant_propertyLockTips", {needLevel}), G_ColorGray, G_ColorGray
            if adjTotalLv >= needLevel then
                propIconName = "adj_property_icon"..(idx+1)..".png"
                unlockTipsStr = getlocal("heroAdjutant_propertyUnlockTips", {needLevel})
                unlockLbColor = G_ColorWhite
                propLbColor = G_ColorYellowPro
            end
            local propIcon = CCSprite:createWithSpriteFrameName(propIconName)
            propIcon:setScale(0.9)
            propIcon:setPosition(20 + propIcon:getContentSize().width * propIcon:getScale() / 2, cellH / 2 + 2)
            cell:addChild(propIcon)
            local lbWidth = cellW - propIcon:getPositionX() - propIcon:getContentSize().width * propIcon:getScale() / 2 - 30
            local unlockLb = GetTTFLabelWrap(unlockTipsStr, 20, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            unlockLb:setAnchorPoint(ccp(0, 0))
            unlockLb:setPosition(propIcon:getPositionX() + propIcon:getContentSize().width * propIcon:getScale() / 2 + 20, 15)
            unlockLb:setColor(unlockLbColor)
            cell:addChild(unlockLb)
            local propStr = ""--getlocal("heroAdjutant_propertyText")
            if propData.type == 1 then
                local pdIndex, pdSize = 1, SizeOfTable(propData.value)
                for k, v in pairs(propData.value) do
                    local propCfg = heroAdjutantVoApi:getPropertyCfg(k, v)
                    if propCfg then
                        propStr = propStr .. propCfg.name .. (pdIndex < pdSize and "  " or "")
                    end
                    pdIndex = pdIndex + 1
                end
            elseif propData.type == 2 then
                local propCfg = heroAdjutantVoApi:getPropertyCfg("exploit", propData.value)
                if propCfg then
                    propStr = propStr .. propCfg.name
                end
            elseif propData.type == 3 then
                local propCfg = heroAdjutantVoApi:getPropertyCfg("skill", propData.value)
                if propCfg then
                    propStr = propStr .. propCfg.name
                end
            end
            local propLb = GetTTFLabelWrap(propStr, 22, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            propLb:setAnchorPoint(ccp(0, 0))
            propLb:setPosition(propIcon:getPositionX() + propIcon:getContentSize().width * propIcon:getScale() / 2 + 20, unlockLb:getPositionY() + unlockLb:getContentSize().height + 5)
            propLb:setColor(propLbColor)
            cell:addChild(propLb)
            local lbStartPosY = (cellH - (unlockLb:getContentSize().height + 5 + propLb:getContentSize().height)) / 2
            unlockLb:setPositionY(lbStartPosY)
            propLb:setPositionY(lbStartPosY + unlockLb:getContentSize().height + 5)
            if idx + 1 < cellNum then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                lineSp:setContentSize(CCSizeMake((cellW - 10), 4))
                lineSp:ignoreAnchorPointForPosition(false)
                lineSp:setAnchorPoint(ccp(0.5, 0))
                lineSp:setPosition(cellW / 2, 0)
                cell:addChild(lineSp)
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setPosition(ccp(3, 3))
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(0)
    tableViewBg:addChild(tv)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroAdjutantSmallDialog:dispose()
    self = nil
end
