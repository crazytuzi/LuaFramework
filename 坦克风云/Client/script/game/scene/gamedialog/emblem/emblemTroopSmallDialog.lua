emblemTroopSmallDialog = smallDialog:new()

function emblemTroopSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    nc.layerNum = nil
    nc.bgSize = nil
    return nc
end

function emblemTroopSmallDialog:showEmblemTroopPosDialog(layerNum, titleStr, subTitleStr, data)
    local sd = emblemTroopSmallDialog:new()
    sd:initEmblemTroopPosDialog(layerNum, titleStr, subTitleStr, data)
    return sd
end

function emblemTroopSmallDialog:initEmblemTroopPosDialog(layerNum, titleStr, subTitleStr, data)
    self.isUseAmi = true
    self.layerNum = layerNum
    self.bgSize = CCSizeMake(560, 420)
    self.dialogLayer = CCLayer:create()
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local function close()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, layerNum, true, close, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority( - (layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer)
    
    local subTitle, subTitleHeight
    if type(subTitleStr) == "table" then
        subTitle, subTitleHeight = G_getRichTextLabel(subTitleStr[1], subTitleStr[2], 24, self.bgSize.width - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    else
        subTitle = GetTTFLabelWrap(subTitleStr, 24, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        subTitleHeight = subTitle:getContentSize().height
    end
    subTitle:setAnchorPoint(ccp(0.5, 1))
    subTitle:setPosition(self.bgSize.width / 2, self.bgSize.height - 80)
    self.bgLayer:addChild(subTitle)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 60, 120))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, subTitle:getPositionY() - subTitleHeight - 15)
    self.bgLayer:addChild(contentBg)
    
    local cTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    cTitleBg:setContentSize(CCSizeMake(contentBg:getContentSize().width, 50))
    cTitleBg:setAnchorPoint(ccp(0.5, 1))
    cTitleBg:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height)
    contentBg:addChild(cTitleBg)
    
    local titleLbPosX = {
        cTitleBg:getContentSize().width * 0.18, 
        cTitleBg:getContentSize().width * 0.42, 
        cTitleBg:getContentSize().width * 0.62, 
        cTitleBg:getContentSize().width * 0.82
    }
    local titleLbPosY = cTitleBg:getContentSize().height / 2
    for k, v in pairs(titleLbPosX) do
        local titleLb
        if k == 1 then
            titleLb = GetTTFLabel(getlocal("emblem_troop_equipNum"), 24)
        else
            titleLb = GetTTFLabel(getlocal("emblem_troop_piece", {k - 1}), 24)
        end
        titleLb:setPosition(v, titleLbPosY)
        cTitleBg:addChild(titleLb)
    end
    titleLbPosY = (contentBg:getContentSize().height - cTitleBg:getContentSize().height) / 2
    local fValue = 0
    if data then
        for k, v in pairs(titleLbPosX) do
            local titleLb
            if k == 1 then
                titleLb = GetTTFLabel(getlocal("firstValue"), 24)
                fValue = data[k] or 0
            else
                titleLb = GetTTFLabel(tostring(data[k] or 0), 24)
                -- fValue=fValue+(data[k] or 0)
            end
            titleLb:setPosition(v, titleLbPosY)
            contentBg:addChild(titleLb)
        end
    end
    local fValueColor = nil
    if fValue == 0 then
        fValueColor = G_ColorRed
        fValue = getlocal("ltzdz_help_image_content_1_2_1")
    end
    local firstValueLb, fvHeight = G_getRichTextLabel(getlocal("emblem_troop_getFirstValue", {fValue}), {nil, fValueColor}, 24, self.bgSize.width - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    firstValueLb:setAnchorPoint(ccp(0.5, 1))
    firstValueLb:setPosition(self.bgSize.width / 2, contentBg:getPositionY() - contentBg:getContentSize().height - 15)
    self.bgLayer:addChild(firstValueLb)
    
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function()end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width - 10, lineSp:getContentSize().height))
    lineSp:setPosition(self.bgSize.width / 2, firstValueLb:getPositionY() - fvHeight - 10)
    self.bgLayer:addChild(lineSp)
    
    local btnScale = 0.8
    local btn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", close, 11, getlocal("confirm"), 24 / btnScale)
    btn:setScale(btnScale)
    btn:setAnchorPoint(ccp(0.5, 1))
    local menu = CCMenu:createWithItem(btn)
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    menu:setPosition(ccp(self.bgSize.width / 2, lineSp:getPositionY() - lineSp:getContentSize().height / 2 - 20))
    self.bgLayer:addChild(menu)
    
    self:show()
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function emblemTroopSmallDialog:showStrengthReward(layerNum, titleStr, contentData, parentCallback)
    local sd = emblemTroopSmallDialog:new()
    sd:initStrengthReward(layerNum, titleStr, contentData, parentCallback)
    return sd
end

function emblemTroopSmallDialog:initStrengthReward(layerNum, titleStr, contentData, parentCallback)
    self.isUseAmi = true
    self.layerNum = layerNum
    self.bgSize = CCSizeMake(560, 700)
    self.dialogLayer = CCLayer:create()
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local function close()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, layerNum, true, close, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority( - (layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer)
    
    local tv
    local activeBtn
    local rewardItemTb
    local function onActiveBtn()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        emblemTroopVoApi:emblemTroopActiveStrengthReward(function()
                --激活成功
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("buffSuccess"), 30)
                if rewardItemTb then
                    for k, v in pairs(rewardItemTb) do
                        for m, n in pairs(v) do
                            G_addPlayerAward(n.type, n.key, n.id, tonumber(n.num), nil, true)
                        end
                    end
                    rewardItemTb = nil
                end
                if activeBtn then
                    activeBtn:setEnabled(emblemTroopVoApi:isCanActiveStrengthReward())
                end
                if tv then
                    tv:reloadData()
                end
                if type(parentCallback) == "function" then
                    parentCallback()
                end
        end)
    end
    local btnScale = 0.8
    activeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onActiveBtn, 11, getlocal("activation"), 24 / btnScale)
    activeBtn:setScale(btnScale)
    activeBtn:setAnchorPoint(ccp(0.5, 0.5))
    local menu = CCMenu:createWithItem(activeBtn)
    menu:setPosition(ccp(self.bgSize.width / 2, 25 + activeBtn:getContentSize().height * activeBtn:getScale() / 2))
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menu)
    activeBtn:setEnabled(emblemTroopVoApi:isCanActiveStrengthReward())
    
    local fontSize = 22
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 105 - menu:getPositionY() - activeBtn:getContentSize().height * activeBtn:getScale() / 2))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 85)
    self.bgLayer:addChild(tvBg)
    
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width, 45))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height)
    tvBg:addChild(tvTitleBg)
    
    local label1 = GetTTFLabel(getlocal("emblem_troop_totalStrength"), fontSize)
    local label2 = GetTTFLabel(getlocal("emblem_troop_unlockReward"), fontSize)
    label1:setPosition(tvTitleBg:getContentSize().width * 0.2, tvTitleBg:getContentSize().height * 0.5)
    label2:setPosition(tvTitleBg:getContentSize().width * 0.7, tvTitleBg:getContentSize().height * 0.5)
    tvTitleBg:addChild(label1)
    tvTitleBg:addChild(label2)
    
    local tvSize = CCSizeMake(tvBg:getContentSize().width, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - 5)
    local cellW, cellHeightTb = tvSize.width, {}
    local cellNum = 0
    local descLbCellMaxH = 0
    local maxStrength = emblemTroopVoApi:getTroopListMaxStrength()
    if type(contentData) == "table" then
        cellNum = SizeOfTable(contentData)
        for k, v in pairs(contentData) do
            if type(v[2]) == "string" then
                local lbW = (cellW - label2:getPositionX() - 10) * 2
                local descLb = GetTTFLabelWrap(v[2], fontSize, CCSizeMake(lbW, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                if descLbCellMaxH < descLb:getContentSize().height then
                    descLbCellMaxH = descLb:getContentSize().height + 20
                end
            elseif type(v[2]) == "table" then
                local height = 10
                local itemCount = SizeOfTable(v[2])
                local iconSize = 80
                local rowNum = 3
                local space = 10
                local colNum = math.ceil(itemCount / rowNum)
                height = height + (iconSize * colNum + (colNum - 1) * space)
                height = height + 10
                cellHeightTb[k] = height
                
                local stateIndex = emblemTroopVoApi:getTroopStrengthRewardState()
                stateIndex = stateIndex or 0
                if stateIndex < k and maxStrength >= v[1] then
                    if rewardItemTb == nil then
                        rewardItemTb = {}
                    end
                    table.insert(rewardItemTb, v[2])
                end
            end
        end
    end
    local function tvCallBack(handler, fn, index, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return  CCSizeMake(cellW, cellHeightTb[index + 1] or descLbCellMaxH)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellH = cellHeightTb[index + 1] or descLbCellMaxH
            if (index + 1)%2 == 0 then
                local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
                cellBg:setContentSize(CCSizeMake(cellW, cellH))
                cellBg:setPosition(cellW / 2, cellH / 2)
                cell:addChild(cellBg)
            end
            local data = contentData[index + 1]
            local stength = data[1]
            local desc = data[2]
            local isUnlock
            local stateIndex = emblemTroopVoApi:getTroopStrengthRewardState()
            stateIndex = stateIndex or 0
            if stateIndex >= (index + 1) then
                isUnlock = true
            end
            local strengthLb = GetTTFLabel(tostring(stength), fontSize)
            strengthLb:setPosition(label1:getPositionX(), cellH / 2)
            if isUnlock == true then
                strengthLb:setColor(G_ColorGreen)
            end
            cell:addChild(strengthLb)
            if type(desc) == "string" then
                local lbW = (cellW - label2:getPositionX() - 10) * 2
                local descLb = GetTTFLabelWrap(desc, fontSize, CCSizeMake(lbW, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                descLb:setPosition(label2:getPositionX(), cellH / 2)
                if isUnlock == true then
                    descLb:setColor(G_ColorGreen)
                end
                cell:addChild(descLb)
            elseif type(desc) == "table" then
                local itemCount = SizeOfTable(desc)
                local iconSize = 80
                local rowNum = 3
                local space = 10
                local colNum = math.ceil(itemCount / rowNum)
                for k, v in pairs(desc) do
                    local function showNewPropDialog()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v)
                    end
                    local icon = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
                    icon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                    local scale = iconSize / icon:getContentSize().width
                    icon:setScale(scale)
                    local posX
                    if math.ceil(k / rowNum) == colNum and itemCount%rowNum ~= 0 then
                        if itemCount%rowNum == 1 then
                            posX = label2:getPositionX() - iconSize / 2
                        else
                            posX = label2:getPositionX() - iconSize - space / 2
                        end
                    else
                        posX = label2:getPositionX() - iconSize - space - iconSize / 2
                    end
                    local posY = (cellH - 10) - math.floor(((k - 1) / rowNum)) * (iconSize + space) - iconSize / 2
                    icon:setPosition(posX + ((k - 1)%rowNum) * (iconSize + space) + iconSize / 2, posY)
                    cell:addChild(icon)
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
    tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(100)
    tv:setPosition(0, 3)
    tvBg:addChild(tv)
    
    self:show()
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function emblemTroopSmallDialog:showEmblemTroopUnlockDialog(layerNum, unlockIndex)
    local sd = emblemTroopSmallDialog:new()
    sd:initEmblemTroopUnlockDialog(layerNum, unlockIndex)
    return sd
end

function emblemTroopSmallDialog:initEmblemTroopUnlockDialog(layerNum, unlockIndex)
    self.isUseAmi = true
    self.layerNum = layerNum
    self.bgSize = CCSizeMake(500, 330)
    self.dialogLayer = CCLayer:create()
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer)
    
    local unlockIcon = CCSprite:createWithSpriteFrameName("emTroop_unlock" .. unlockIndex .. ".png")
    unlockIcon:setPosition(50 + unlockIcon:getContentSize().width / 2, self.bgSize.height - 30 - unlockIcon:getContentSize().height / 2)
    self.bgLayer:addChild(unlockIcon)
    
    local nameRectW = self.bgSize.width - (unlockIcon:getPositionX() + unlockIcon:getContentSize().width / 2 + 20 + 30)
    local nameLb = GetTTFLabelWrap(getlocal("emblem_troop_unlock" .. unlockIndex), 24, CCSizeMake(nameRectW, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(unlockIcon:getPositionX() + unlockIcon:getContentSize().width / 2 + 20, unlockIcon:getPositionY() + unlockIcon:getContentSize().height / 2 - 15)
    self.bgLayer:addChild(nameLb)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function ()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 60, self.bgSize.height - (30 + unlockIcon:getContentSize().height + 15 + 25)))
    contentBg:setAnchorPoint(ccp(0.5, 0))
    contentBg:setPosition(self.bgSize.width / 2, 25)
    self.bgLayer:addChild(contentBg)
    
    local cfg = emblemTroopVoApi:getTroopEquipPosUnlockCfgByIndex(unlockIndex)
    local descStr = ""
    if cfg then
        if cfg.unlock then
            local placeGetCfg = emblemTroopVoApi:getEmblemTroopPlaceGetCfg()
            local gerPercent = placeGetCfg[cfg.unlock] or 0
            descStr = getlocal("emblem_troop_unlockDesc" .. unlockIndex, {cfg.strNeed, gerPercent * 100})
        elseif cfg.troopsAdd then
            descStr = getlocal("emblem_troop_unlockDesc" .. unlockIndex, {cfg.strNeed, cfg.troopsAdd})
        elseif cfg.first then
            descStr = getlocal("emblem_troop_unlockDesc" .. unlockIndex, {cfg.strNeed, cfg.first})
        end
    end
    local descLb = GetTTFLabelWrap(descStr, 20, CCSizeMake(contentBg:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    descLb:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height / 2)
    contentBg:addChild(descLb)
    
    -- 下面的点击屏幕继续
    local clickLbPosy = - 80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = self.bgLayer:getContentSize().width / 2 - maxWidth / 2
        arrowPosx2 = self.bgLayer:getContentSize().width / 2 + maxWidth / 2
    else
        arrowPosx1 = self.bgLayer:getContentSize().width / 2 - realWidth / 2
        arrowPosx2 = self.bgLayer:getContentSize().width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow( - 1, space))
    smallArrowSp4:runAction(G_actionArrow( - 1, space))
    
    self:show()
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function emblemTroopSmallDialog:dispose()
    self.layerNum = nil
    self.bgSize = nil
    self = nil
end