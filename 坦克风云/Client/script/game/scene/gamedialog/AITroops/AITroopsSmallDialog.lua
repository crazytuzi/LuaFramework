AITroopsSmallDialog = smallDialog:new()

function AITroopsSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsSmallDialog:showRewardDialog(rewardList, titleStr, tipContent, confirmStr, confirmCallBack, layerNum)
    local sd = AITroopsSmallDialog:new()
    sd:initRewardDialog(rewardList, titleStr, tipContent, confirmStr, confirmCallBack, layerNum)
end

function AITroopsSmallDialog:initRewardDialog(rewardList, titleStr, tipContent, confirmStr, confirmCallBack, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local function close()
        return self:close()
    end
    
    local dialogBgWidth, dialogBgHeight = 550, 100
    local tipStr, tipColor, tipSize = tipContent[1], tipContent[2], tipContent[3]
    local tipLb, tipHeight = G_getRichTextLabel(tipStr, tipColor, tipSize, dialogBgWidth - 60, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0, 1))
    
    dialogBgHeight = dialogBgHeight + tipHeight + 60
    
    local cellWidth, cellHeight, tvHeight, scrollFlag = dialogBgWidth - 80, 0, 480, true
    local count = SizeOfTable(rewardList)
    local propSize = 100
    local spaceX, spaceY = 20, 20
    if count % 4 > 0 then
        count = math.floor(count / 4) + 1
    else
        count = math.floor(count / 4)
    end
    cellHeight = cellHeight + count * propSize + (count - 1) * spaceY
    if cellHeight < tvHeight then
        tvHeight = cellHeight
        scrollFlag = false
    end
    dialogBgHeight = dialogBgHeight + tvHeight + 40
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum, nil, titleStr, 28)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    contentBg:setContentSize(CCSizeMake(dialogBgWidth - 40, dialogBgHeight - 140))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 30)
    self.bgLayer:addChild(contentBg)
    
    tipLb:setPosition(30, dialogBgHeight - 50)
    self.bgLayer:addChild(tipLb)
    
    local tvPosY = tipLb:getPositionY() - tipHeight - tvHeight - 20
    local rc = SizeOfTable(rewardList)
    
    local isMoved = false
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(cellWidth, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local posX = cellWidth / 2
            local firstPosX, firstPosY = 0, cellHeight
            
            if rc <= 4 then
                firstPosX = (cellWidth - (rc * propSize + (rc - 1) * spaceX)) / 2
            else
                firstPosX = (cellWidth - (4 * propSize + 3 * spaceX)) / 2
            end
            for k, item in pairs(rewardList) do
                local px = firstPosX + (k - 1) % 4 * (spaceX + propSize)
                local py = firstPosY - math.floor((k - 1) / 4) * (propSize + spaceY)
                local icon, scale = G_getItemIcon(item, propSize, false, layerNum + 1, nil, self.tv, nil, nil, nil, nil, true)
                if icon then
                    icon:setAnchorPoint(ccp(0, 1))
                    icon:setPosition(ccp(px, py))
                    cell:addChild(icon, 1)
                    if item.type ~= "at" or (item.type == "at" and item.eType ~= "a") then --AI部队不显示个数
                        local numLb = GetTTFLabel(FormatNumber(item.num), 25)
                        numLb:setAnchorPoint(ccp(1, 0))
                        numLb:setScale(1 / scale)
                        numLb:setPosition(ccp(icon:getContentSize().width - 5, 0))
                        icon:addChild(numLb, 4)
                        if item.type == "at" and item.eType == "f" then --AI部队碎片的数量显示在框外边，避免挡住碎片标识
                            numLb:setString("x" .. FormatNumber(item.num))
                            numLb:setPositionX(icon:getContentSize().width + 5 + numLb:getContentSize().width)
                        else
                            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                            numBg:setAnchorPoint(ccp(1, 0))
                            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
                            numBg:setPosition(ccp(icon:getContentSize().width - 5, 5))
                            numBg:setOpacity(150)
                            icon:addChild(numBg, 3)
                        end
                    end
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(cellWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(40, tvPosY))
    self.bgLayer:addChild(self.tv)
    if scrollFlag == true then
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 4
    local function confirm()
        close()
        if confirmCallBack then
            confirmCallBack()
        end
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2, 60), {confirmStr, 24}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", confirm, btnScale, priority)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function AITroopsSmallDialog:showProduceConfirmDialog(produceType, layerNum)
    local sd = AITroopsSmallDialog:new()
    sd:initProduceConfirmDialog(produceType, layerNum)
end

function AITroopsSmallDialog:initProduceConfirmDialog(produceType, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local dialogBgWidth, dialogBgHeight = 550, 130
    local fontWidth = dialogBgWidth - 60
    local fontSize, smallFontSize = 22, 20
    
    local tankId, cost = AITroopsVoApi:getProduceCostByTroopType(produceType)
    tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))

    --普通坦克数量
    local ownNum1 = tankVoApi:getTankCountByItemId(tankId)
    --精英坦克数量
    local ownNum2 = tankVoApi:getTankCountByItemId(tankId+40000)
    --坦克总数量
    local ownNum = ownNum1+ownNum2
    
    local time = AITroopsVoApi:getProduceCostTime(produceType) --生产时间
    
    local confirmLb, confirmLbHeight = G_getRichTextLabel(getlocal("aitroops_produce_tip1", {cost, getlocal(tankCfg[tankId].name)}), {G_ColorWhite, G_ColorGreen, G_ColorWhite}, fontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    confirmLb:setAnchorPoint(ccp(0, 1))
    
    local timeLb, timeLbHeight = G_getRichTextLabel(getlocal("aitroops_produce_tip2", {GetTimeStr(time)}), {G_ColorWhite, G_ColorYellowPro, G_ColorWhite}, smallFontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    timeLb:setAnchorPoint(ccp(0, 1))
    
    local tipLb = GetTTFLabelWrap(getlocal("aitroops_produce_tip3"), smallFontSize, CCSizeMake(fontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0, 1))
    tipLb:setColor(G_ColorRed)
    
    local contentHeight = confirmLbHeight + timeLbHeight + tipLb:getContentSize().height + 60
    
    dialogBgHeight = dialogBgHeight + contentHeight + 40
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local function close()
        self:close()
    end
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum)
    -- local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("startProduce"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    contentBg:setContentSize(CCSizeMake(dialogBgWidth - 40, contentHeight))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 20)
    self.bgLayer:addChild(contentBg)
    
    confirmLb:setPosition(30, contentHeight - 20)
    contentBg:addChild(confirmLb)
    timeLb:setPosition(confirmLb:getPositionX(), confirmLb:getPositionY() - confirmLbHeight - 10)
    contentBg:addChild(timeLb)
    tipLb:setPosition(timeLb:getPositionX(), timeLb:getPositionY() - timeLbHeight - 10)
    contentBg:addChild(tipLb)
    
    local btnScale, btnPosY, priority, offsetX = 0.8, 80, -(self.layerNum - 1) * 20 - 4, 150

    local function produceHandler(double)
        local costNum = (double == 1) and (2 * cost) or cost
        local ownNum1 = tankVoApi:getTankCountByItemId(tankId)
        local ownNum2 = tankVoApi:getTankCountByItemId(tankId+40000)
        local num = ownNum1+ownNum2
        local defNum = AITroopsVoApi:getDefenseTankCount(tankId)
        if num >= costNum and (num - defNum) < costNum then --总数量满足，但是刨去防守部队中的数量不足，也不能生产
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_produce_needless2"), 28)
            do return end
        end
        if num < costNum then --总数量不满足
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_produce_needless1"), 28)
            do return end
        end
        local function handler()
            self:close()
        end
        if (ownNum1 - defNum) >= costNum then
            AITroopsVoApi:AITroopsProduce(produceType, double, handler)
            do return end
        end

        --如果需要精英坦克则需要二次弹板
        local function secondTipFunc(sbFlag)
            local keyName = "active.aitroops"
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end

        local function confirmHandler(  )
            -- 兑换逻辑
            AITroopsVoApi:AITroopsProduce(produceType, double, handler)
            do return end
        end
        local keyName = "active.aitroops"
        if G_isPopBoard(keyName) then
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),{getlocal("aitroops_produce_tip6", {ownNum1, getlocal(tankCfg[tankId].name),costNum-ownNum1,getlocal(tankCfg[tankId+40000].name)}), {G_ColorWhite, G_ColorGreen, G_ColorWhite,G_ColorGreen,G_ColorWhite}},true,confirmHandler,secondTipFunc)
            do return end
        else
            confirmHandler(  )
        end
    end
    
    --双倍生产AI部队
    local function produceImmediately()
        produceHandler(1)
    end
    local produceImmedItem, produceImmedMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - offsetX, btnPosY), {getlocal("gemCompleted")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", produceImmediately, btnScale, priority)
    
    --生产AI部队
    local function produce()
        produceHandler()
    end
    local produceItem, produceMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + offsetX, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", produce, btnScale, priority)
    local produceLb, produceLbHeight = G_getRichTextLabel(getlocal("aitroops_produce_btnStr", {cost}), {nil, G_ColorYellowPro, nil}, 22, 150, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    produceLb:setAnchorPoint(ccp(0.5,1))
    produceLb:setPosition(produceItem:getContentSize().width / 2, produceItem:getContentSize().height / 2 + produceLbHeight / 2 + 3)
    produceLb:setScale(1 / produceItem:getScale())
    produceItem:addChild(produceLb)
    
    local tankSize = 58
    local tankSp = tankVoApi:getTankIconSp(tankId)
    tankSp:setPosition(self.bgSize.width / 2 + tankSize * 0.5, btnPosY)
    tankSp:setScale(tankSize / tankSp:getContentSize().width)
    self.bgLayer:addChild(tankSp)
    if tankId ~= G_pickedList(tankId) then
        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        tankSp:addChild(pickedIcon)
        pickedIcon:setPosition(tankSp:getContentSize().width - 30, 30)
        pickedIcon:setScale(1.5)
    end
    local costStr = getlocal("propOwned") .. ownNum
    local costLb = GetTTFLabel(costStr, 20)
    costLb:setAnchorPoint(ccp(0.5, 1))
    costLb:setPosition(tankSp:getPositionX(), tankSp:getPositionY() - tankSize * 0.5 - 10)
    self.bgLayer:addChild(costLb)
    if ownNum < cost then --拥有数量不足
        costLb:setColor(G_ColorRed)
    end
    
    local dcnum, maxDcnum = AITroopsVoApi:getDaydcnum() --今日双倍消耗生产的次数
    if dcnum >= maxDcnum then
        produceImmedItem:setEnabled(false)
    end
    local dcnumLb = GetTTFLabel(dcnum.."/"..maxDcnum, 20)
    dcnumLb:setAnchorPoint(ccp(0.5, 0))
    dcnumLb:setPosition(produceImmedMenu:getPositionX(), produceImmedMenu:getPositionY() + 35)
    self.bgLayer:addChild(dcnumLb)
    
    local dpnum, maxDpnum = AITroopsVoApi:getDaydpnum() --今日生产次数
    if dpnum >= maxDpnum then
        produceItem:setEnabled(false)
    end
    local dpnumLb = GetTTFLabel(dpnum.."/"..maxDpnum, 20)
    dpnumLb:setAnchorPoint(ccp(0.5, 0))
    dpnumLb:setPosition(produceMenu:getPositionX(), produceMenu:getPositionY() + 35)
    self.bgLayer:addChild(dpnumLb)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    G_addForbidForSmallDialog(self.dialogLayer, self.bgLayer, -(self.layerNum - 1) * 20 - 3, close)
    
    G_addArrowPrompt(self.bgLayer, nil, -70)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

--exchangeType：标识兑换类型，用于判断是什么兑换，fromItem：花费的道具，targetItem：要兑换的道具
function AITroopsSmallDialog:showExchangeDialog(exchangeType, fromItem, targetItem, exchangeRate, confirmCallBack, layerNum)
    local sd = AITroopsSmallDialog:new()
    sd:initExchangeDialog(exchangeType, fromItem, targetItem, exchangeRate, confirmCallBack, layerNum)
end

function AITroopsSmallDialog:initExchangeDialog(exchangeType, fromItem, targetItem, exchangeRate, confirmCallBack, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local dialogBgWidth, dialogBgHeight = 550, 100
    
    local propSize, sliderHeight = 80, 70
    local tipFontSize, smallFontSize = 22, 20
    local cost, receive = 1, math.floor(exchangeRate) --消耗数量，兑换数量
    
    dialogBgHeight = dialogBgHeight + propSize + sliderHeight + 120
    
    local tipLb
    if exchangeType == 1 then
        tipLb = GetTTFLabelWrap(getlocal("aitroops_exchange_tip", {fromItem.name, targetItem.name}), tipFontSize, CCSizeMake(dialogBgWidth - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    end
    if tipLb then
        dialogBgHeight = dialogBgHeight + tipLb:getContentSize().height + 60
    end
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local function close()
        self:close()
    end
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local contentSize = CCSizeMake(dialogBgWidth - 40, dialogBgHeight - 120)
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    contentBg:setContentSize(contentSize)
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 20)
    self.bgLayer:addChild(contentBg)
    
    local posY = contentSize.height - 20
    if tipLb then
        tipLb:setAnchorPoint(ccp(0, 1))
        tipLb:setPosition(20, posY)
        contentBg:addChild(tipLb)
        posY = posY - tipLb:getContentSize().height - 40
    end
    
    --消耗的物品
    local fromPropIcon = G_getItemIcon(fromItem, 100)
    fromPropIcon:setScale(propSize / fromPropIcon:getContentSize().width)
    fromPropIcon:setAnchorPoint(ccp(0, 0.5))
    fromPropIcon:setPosition(60, posY - propSize * 0.5)
    contentBg:addChild(fromPropIcon)
    --当前拥有数量
    local fromOwnLb = GetTTFLabel(getlocal("propOwned")..fromItem.num, smallFontSize)
    fromOwnLb:setAnchorPoint(ccp(0, 1))
    fromOwnLb:setPosition(fromPropIcon:getPositionX(), fromPropIcon:getPositionY() - propSize * 0.5 - 5)
    contentBg:addChild(fromOwnLb)
    self.fromOwnLb = fromOwnLb
    --消耗的数量
    local costLb = GetTTFLabel("x"..cost, smallFontSize)
    costLb:setAnchorPoint(ccp(0, 0))
    costLb:setPosition(fromPropIcon:getPositionX() + propSize + 5, fromPropIcon:getPositionY() - propSize * 0.5)
    contentBg:addChild(costLb)
    self.costLb = costLb
    
    --要兑换的物品
    local targetPropIcon = G_getItemIcon(targetItem, 100)
    targetPropIcon:setScale(propSize / targetPropIcon:getContentSize().width)
    targetPropIcon:setAnchorPoint(ccp(0, 0.5))
    targetPropIcon:setPosition(dialogBgWidth - propSize - 120, posY - propSize * 0.5)
    contentBg:addChild(targetPropIcon)
    --当前拥有数量
    local targetOwnLb = GetTTFLabel(getlocal("propOwned")..targetItem.num, smallFontSize)
    targetOwnLb:setAnchorPoint(ccp(0, 1))
    targetOwnLb:setPosition(targetPropIcon:getPositionX(), targetPropIcon:getPositionY() - propSize * 0.5 - 5)
    contentBg:addChild(targetOwnLb)
    --得到的数量
    local receiveLb = GetTTFLabel("x"..receive, smallFontSize)
    receiveLb:setAnchorPoint(ccp(0, 0))
    receiveLb:setPosition(targetPropIcon:getPositionX() + propSize + 5, targetPropIcon:getPositionY() - propSize * 0.5)
    contentBg:addChild(receiveLb)
    self.receiveLb = receiveLb
    
    local directSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
    directSp:setAnchorPoint(ccp(0.5, 0.5))
    directSp:setScale(1.5)
    directSp:setPosition((fromPropIcon:getPositionX() + propSize + targetPropIcon:getPositionX()) / 2, targetPropIcon:getPositionY())
    contentBg:addChild(directSp)
    
    posY = posY - propSize - 45
    
    --分割线
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp:setAnchorPoint(ccp(0.5, 0))
    lineSp:setContentSize(CCSizeMake(contentSize.width - 18, lineSp:getContentSize().height))
    lineSp:setRotation(180)
    lineSp:setPosition(contentSize.width / 2, posY)
    contentBg:addChild(lineSp)
    
    posY = posY - 30
    
    local ownTipLb = GetTTFLabel(getlocal("activity_qxtw_need"), tipFontSize)
    ownTipLb:setAnchorPoint(ccp(0, 0.5))
    contentBg:addChild(ownTipLb)
    local ownTipWidth = 200
    local ownTipSp = CCSprite:createWithSpriteFrameName("proBar_n2.png")
    ownTipSp:setScaleX(ownTipWidth / ownTipSp:getContentSize().width)
    ownTipSp:setAnchorPoint(ccp(0, 0.5))
    contentBg:addChild(ownTipSp)
    local curNumLb = GetTTFLabel(cost.."/"..fromItem.num, smallFontSize)
    curNumLb:setAnchorPoint(ccp(0.5, 0.5))
    contentBg:addChild(curNumLb)
    self.curNumLb = curNumLb
    ownTipLb:setPosition((contentSize.width - ownTipLb:getContentSize().width - ownTipWidth) / 2, posY)
    ownTipSp:setPosition(ownTipLb:getPositionX() + ownTipLb:getContentSize().width, posY)
    curNumLb:setPosition(ownTipSp:getPositionX() + ownTipWidth / 2, posY)
    
    posY = posY - 45
    
    local function refresh(num)
        cost = num
        receive = math.floor(num * exchangeRate)
        if self.fromOwnLb and self.costLb and self.receiveLb and self.curNumLb then
            self.fromOwnLb:setString(getlocal("propOwned") .. (fromItem.num - num))
            self.costLb:setString("x"..num)
            self.receiveLb:setString("x"..receive)
            self.curNumLb:setString(num.."/"..fromItem.num)
        end
    end
    
    local function sliderTouch(handler, object)
        local count = math.floor(object:getValue())
        if count > 0 then
            refresh(count)
        end
    end
    local spBg = CCSprite:createWithSpriteFrameName("proBar_n2.png")
    local spPr = CCSprite:createWithSpriteFrameName("proBar_n1.png")
    local spPr1 = CCSprite:createWithSpriteFrameName("grayBarBtn.png")
    local slider = LuaCCControlSlider:create(spBg, spPr, spPr1, sliderTouch)
    slider:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    slider:setIsSallow(true)
    slider:setMinimumValue(1)
    slider:setMaximumValue(fromItem.num)
    slider:setValue(0)
    slider:setPosition(ccp(contentSize.width / 2, posY - 15))
    slider:setTag(99)
    contentBg:addChild(slider, 2)
    self.slider = slider
    
    local function touchHander()
    end
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchHander)
    bgSp:setContentSize(CCSizeMake(490, 45))
    bgSp:setOpacity(0)
    bgSp:setPosition(contentSize.width / 2, slider:getPositionY())
    contentBg:addChild(bgSp, 1)
    
    local function touchAdd()
        self.slider:setValue(self.slider:getValue() + 1)
    end
    
    local function touchMinus()
        if self.slider:getValue() - 1 > 0 then
            self.slider:setValue(self.slider:getValue() - 1)
        end
    end
    
    local addSp = CCSprite:createWithSpriteFrameName("greenPlus.png")
    addSp:setAnchorPoint(ccp(1, 0.5))
    addSp:setPosition(ccp(bgSp:getContentSize().width - 10, bgSp:getContentSize().height / 2))
    bgSp:addChild(addSp, 1)
    
    local rect = CCSizeMake(50, 45)
    local addTouchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchAdd)
    addTouchBg:setTouchPriority(-(layerNum - 1) * 20 - 5)
    addTouchBg:setContentSize(rect)
    addTouchBg:setAnchorPoint(ccp(1, 0.5))
    addTouchBg:setOpacity(0)
    addTouchBg:setPosition(ccp(bgSp:getContentSize().width, bgSp:getContentSize().height / 2))
    bgSp:addChild(addTouchBg, 1)
    
    local minusSp = CCSprite:createWithSpriteFrameName("greenMinus.png")
    minusSp:setAnchorPoint(ccp(0, 0.5))
    minusSp:setPosition(ccp(10, bgSp:getContentSize().height / 2))
    bgSp:addChild(minusSp, 1)
    
    local minusTouchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchMinus)
    minusTouchBg:setTouchPriority(-(layerNum - 1) * 20 - 5)
    minusTouchBg:setContentSize(rect)
    minusTouchBg:setAnchorPoint(ccp(0, 0.5))
    minusTouchBg:setOpacity(0)
    minusTouchBg:setPosition(ccp(0, bgSp:getContentSize().height / 2))
    bgSp:addChild(minusTouchBg, 1)
    
    --兑换道具
    local function exchange()
        local function handler()
            close()
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceShop_buySuccess"), 28)
        end
        AITroopsVoApi:fragmentExchange(fromItem.key, cost, handler)
    end
    local exchangeItem, exchangeMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2, 60), {getlocal("code_gift")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", exchange, 0.8, -(self.layerNum - 1) * 20 - 4)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    G_addForbidForSmallDialog(self.dialogLayer, self.bgLayer, -(self.layerNum - 1) * 20 - 3, close)
    
    G_addArrowPrompt(self.bgLayer, nil, -70)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

--exchangeType：标识兑换类型，用于判断是什么兑换，fromItem：花费的道具，targetItem：要兑换的道具
function AITroopsSmallDialog:showSkillExchangeConfirmDialog(exchangeSkill, confirmCallBack, layerNum)
    local sd = AITroopsSmallDialog:new()
    sd:initSkillExchangeConfirmDialog(exchangeSkill, confirmCallBack, layerNum)
end

function AITroopsSmallDialog:initSkillExchangeConfirmDialog(exchangeSkill, confirmCallBack, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local dialogBgWidth, dialogBgHeight = 550, 150
    
    local propSize = 60
    local nameFontSize, tipFontSize, smallFontSize = 30, 24, 22
    
    local contentBgWidth, contentBgHeight = dialogBgWidth - 40, 40
    local tipLb = GetTTFLabelWrap(getlocal("aitroops_skillexchange_confirm"), tipFontSize, CCSizeMake(dialogBgWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    contentBgHeight = contentBgHeight + tipLb:getContentSize().height
    
    local returnLb
    local expReturnNum = AITroopsVoApi:getExchangeSkillReturnExpPropNum(exchangeSkill.lv)
    if tonumber(expReturnNum) > 0 then
        returnLb = GetTTFLabelWrap(getlocal("aitroops_skillexchange_return_tip"), smallFontSize, CCSizeMake(dialogBgWidth - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        contentBgHeight = contentBgHeight + returnLb:getContentSize().height + propSize + 20
    end
    
    dialogBgHeight = dialogBgHeight + contentBgHeight + 20
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local function close()
        self:close()
    end
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local titleLb = G_createNewTitle({getlocal("hero_honor_change"), 28, G_ColorYellowPro}, CCSizeMake(dialogBgWidth - 60, 0), nil, nil, "Helvetica-bold")
    titleLb:setPosition(dialogBgWidth / 2, dialogBgHeight - 60)
    self.bgLayer:addChild(titleLb)
    
    local contentSize = CCSizeMake(contentBgWidth, contentBgHeight)
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    contentBg:setContentSize(contentSize)
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, titleLb:getPositionY())
    self.bgLayer:addChild(contentBg)
    
    tipLb:setPosition(contentSize.width / 2, contentSize.height - tipLb:getContentSize().height / 2 - 20)
    tipLb:setColor(G_ColorYellowPro)
    contentBg:addChild(tipLb)
    
    if returnLb then
        returnLb:setAnchorPoint(ccp(0, 0.5))
        returnLb:setPosition(20, tipLb:getPositionY() - tipLb:getContentSize().height / 2 - 20)
        contentBg:addChild(returnLb)
        
        local aitroopsCfg = AITroopsVoApi:getModelCfg()
        local returnExpProp = {at = {p1 = expReturnNum}}
        returnExpProp = FormatItem(returnExpProp)[1]
        local expIconSp = G_getItemIcon(returnExpProp, 100, false, self.layerNum)
        expIconSp:setScale(propSize / expIconSp:getContentSize().width)
        expIconSp:setPosition(40 + propSize / 2, returnLb:getPositionY() - returnLb:getContentSize().height / 2 - propSize / 2 - 10)
        contentBg:addChild(expIconSp)
        local numLb = GetTTFLabel("x"..FormatNumber(returnExpProp.num), smallFontSize)
        numLb:setAnchorPoint(ccp(0, 0))
        numLb:setPosition(expIconSp:getPositionX() + propSize / 2 + 5, expIconSp:getPositionY() - propSize / 2)
        contentBg:addChild(numLb)
    end
    
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 4
    local function confirm()
        if confirmCallBack then
            confirmCallBack()
        end
        close()
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - 140, 60), {getlocal("confirm"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", confirm, btnScale, priority)
    
    local function cancel()
        close()
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + 140, 60), {getlocal("cancel"), 25}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn_Down.png", cancel, btnScale, priority)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function AITroopsSmallDialog:dispose()
    
end
