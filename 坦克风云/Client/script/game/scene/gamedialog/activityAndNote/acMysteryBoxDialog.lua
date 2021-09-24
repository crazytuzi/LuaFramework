acMysteryBoxDialog = commonDialog:new()

function acMysteryBoxDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/rewardCenterImage.plist")
        spriteController:addTexture("public/rewardCenterImage.png")
        spriteController:addPlist("public/accessoryImage.plist")
        spriteController:addPlist("public/accessoryImage2.plist")
    end)
    return nc
end

function acMysteryBoxDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function acMysteryBoxDialog:initTableView()
    local topBg
    G_addResource8888(function() topBg = CCSprite:create("public/acMysteryBox_bg.jpg") end)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85))
    self.bgLayer:addChild(topBg)

    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("acMysteryBox_i_desc1", {acMysteryBoxVoApi:getActiveTitle()}),
            getlocal("acMysteryBox_i_desc2"),
            getlocal("acMysteryBox_i_desc3"),
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(topBg:getContentSize().width - 15, topBg:getContentSize().height - 15))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    topBg:addChild(infoMenu)

    local descTvSize = CCSizeMake(330, 60)
    local descLb = GetTTFLabelWrap(acMysteryBoxVoApi:getActiveDesc(), 22, CCSizeMake(descTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    local descTv = G_createTableView(descTvSize, 1, CCSizeMake(descTvSize.width, descLb:getContentSize().height), function(cell, cellSize, idx, cellNum)
        descLb:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
        descLb:setColor(G_ColorYellowPro)
        cell:addChild(descLb)
    end)
    descTv:setPosition(ccp(250, topBg:getContentSize().height - 70))
    descTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    descTv:setMaxDisToBottomOrTop(0)
    topBg:addChild(descTv)

    acMysteryBoxVoApi:checkOverDayData()
    self.shopList = acMysteryBoxVoApi:getShopList()

    local pageList = {}
    local pageListSize = 0
    local pageShowCount = 4 --每一页显示4个道具
    if self.shopList and self.shopList[1] then
        local rewardTb = self.shopList[1].reward
        if rewardTb and rewardTb[1] then
            pageListSize = 1
            pageList[pageListSize] = {}
            local rewardItem = FormatItem(rewardTb[1])[1]
            if propCfg[rewardItem.key].useGetPool and propCfg[rewardItem.key].useGetPool[3] then
                for k, v in ipairs(propCfg[rewardItem.key].useGetPool[3]) do
                    if k - 1 > 0 and (k - 1) % pageShowCount == 0 then 
                        pageListSize = pageListSize + 1
                        pageList[pageListSize] = {}
                    end
                    local itemId = Split(v[1], "_")
                    local eType = G_rewardType(itemId[1])
                    table.insert(pageList[pageListSize], FormatItem({[eType] = {[itemId[2]] = v[2]}})[1])
                end
            else
                table.insert(pageList[pageListSize], rewardItem)
            end
        end
    end

    local showPageIndex, pageTurning = 1, false
    local curPageItem
    local function createPageItem(pageLayerSize, pageIndex, refreshPageItem)
        local pageItem
        if refreshPageItem then
            refreshPageItem:removeAllChildrenWithCleanup(true)
            pageItem = refreshPageItem
        else
            pageItem = CCNode:create()
            pageItem:setContentSize(pageLayerSize)
            pageItem:setAnchorPoint(ccp(0, 0))
            pageItem:setPosition(ccp(0, 0))
        end
        for k, v in ipairs(pageList[pageIndex]) do
            local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
                if v.type == "at" and v.eType == "a" then --AI部队
                    local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                else
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                end
            end)
            icon:setScale(85 / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
            local x, y = 0, 0
            if k % 2 == 0 then
                x = pageItem:getContentSize().width / 2 + 15 + icon:getContentSize().width * scale / 2
                if k == 2 then
                    y = pageItem:getContentSize().height / 2 + 15 + icon:getContentSize().height * scale / 2
                else
                    y = pageItem:getContentSize().height / 2 - 15 - icon:getContentSize().height * scale / 2
                end
            else
                x = pageItem:getContentSize().width / 2 - 15 - icon:getContentSize().width * scale / 2
                if k == 1 then
                    y = pageItem:getContentSize().height / 2 + 15 + icon:getContentSize().height * scale / 2
                else
                    y = pageItem:getContentSize().height / 2 - 15 - icon:getContentSize().height * scale / 2
                end
            end
            icon:setPosition(ccp(x, y))
            pageItem:addChild(icon)
        end
        return pageItem
    end
    local function onPageEvent(pageLayer, direction)
        if direction == 0 then
            curPageItem = createPageItem(pageLayer:getContentSize(), showPageIndex)
            pageLayer:addChild(curPageItem)
        else
            if pageTurning == true then
                do return end
            end
            pageTurning = true
            showPageIndex = showPageIndex + direction
            if showPageIndex <= 0 then
                showPageIndex = pageListSize
            end
            if showPageIndex > pageListSize then
                showPageIndex = 1
            end
            local cPos = ccp(curPageItem:getPosition())
            local nextPageItem = createPageItem(pageLayer:getContentSize(), showPageIndex)
            nextPageItem:setPosition(cPos.x + direction * pageLayer:getContentSize().width, cPos.y)
            pageLayer:addChild(nextPageItem)
            curPageItem:runAction(CCMoveTo:create(0.3, ccp(cPos.x - direction * pageLayer:getContentSize().width, cPos.y)))
            local arry = CCArray:create()
            arry:addObject(CCMoveTo:create(0.3, cPos))
            arry:addObject(CCMoveTo:create(0.06, ccp(cPos.x - direction * 50, cPos.y)))
            arry:addObject(CCMoveTo:create(0.06, cPos))
            arry:addObject(CCCallFunc:create(function()
                curPageItem:removeFromParentAndCleanup(true)
                curPageItem = nil
                curPageItem = nextPageItem
                pageTurning = false
            end))
            nextPageItem:runAction(CCSequence:create(arry))
        end
    end
    local pageLayer = self:createPageLayer(CCSizeMake(330, 230), - (self.layerNum - 1) * 20 - 3, onPageEvent)
    pageLayer:setPosition(ccp(255, topBg:getPositionY() - topBg:getContentSize().height + 25))
    self.bgLayer:addChild(pageLayer)

    local rewardTvSize = CCSizeMake(G_VisibleSizeWidth - 30, topBg:getPositionY() - topBg:getContentSize().height - 35)
    local rewardTv = G_createTableView(rewardTvSize, SizeOfTable(self.shopList), CCSizeMake(rewardTvSize.width, 165), function(...) self:onCellOfRewardTv(...) end)
    rewardTv:setPosition(ccp((G_VisibleSizeWidth - rewardTvSize.width) / 2, 25))
    rewardTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(rewardTv)
    self.rewardTv = rewardTv

    local acVo = acMysteryBoxVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = function()
            if self.rewardTv then
                local recordPoint = self.rewardTv:getRecordPoint()
                self.rewardTv:reloadData()
                self.rewardTv:recoverToRecordPoint(recordPoint)
            end
        end
    end
end

function acMysteryBoxDialog:createPageLayer(pageLayerSize, touchPriority, onPageCallback)
    local pageLayer = CCLayer:create()--CCLayerColor:create(ccc4(255, 0, 0, 255))
    pageLayer:setContentSize(pageLayerSize)

    local clipper = CCClippingNode:create()
    clipper:setContentSize(pageLayerSize)
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(ccp(pageLayerSize.width / 2, pageLayerSize.height))
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    pageLayer:addChild(clipper)

    local touchArray = {}
    local beganPos
    local function touchHandler(fn, x, y, touch)
        if fn == "began" then
            if x >= pageLayer:getPositionX() and x <= pageLayer:getPositionX() + pageLayer:getContentSize().width and y >= pageLayer:getPositionY() and y <= pageLayer:getPositionY() + pageLayer:getContentSize().height then
                table.insert(touchArray, touch)
                if SizeOfTable(touchArray) > 1 then
                    touchArray = {}
                    return false
                else
                    beganPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                    return true
                end
            end
            return false
        elseif fn == "moved" then
        elseif fn == "ended" then
            if beganPos then
                local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                local moveDisTmp = ccpSub(curPos, beganPos)
                if moveDisTmp.x > 50 then
                    if type(onPageCallback) == "function" then
                        -- onPageCallback(pageLayer, -1)
                        onPageCallback(clipper, -1)
                    end
                elseif moveDisTmp.x < - 50 then
                    if type(onPageCallback) == "function" then
                        -- onPageCallback(pageLayer, 1)
                        onPageCallback(clipper, 1)
                    end
                end
            end
            beganPos = nil
            touchArray = {}
        else
            touchArray = {}
        end
    end
    pageLayer:setTouchEnabled(true)
    pageLayer:setBSwallowsTouches(true)
    pageLayer:registerScriptTouchHandler(touchHandler, false, touchPriority, true)

    local offset = 20
    local leftArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    leftArrowSp:setPosition(- leftArrowSp:getContentSize().width / 2 + offset, pageLayer:getContentSize().height / 2)
    pageLayer:addChild(leftArrowSp)
    local rightArrowSp = CCSprite:createWithSpriteFrameName("rewardCenterArrow.png")
    rightArrowSp:setFlipX(true)
    rightArrowSp:setPosition(pageLayer:getContentSize().width + rightArrowSp:getContentSize().width / 2 - offset, pageLayer:getContentSize().height / 2)
    pageLayer:addChild(rightArrowSp)
    local function runArrowAction(arrowSp, flag)
        local posX, posY = arrowSp:getPosition()
        local posX2 = posX + flag * offset
        local arry1 = CCArray:create()
        arry1:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
        arry1:addObject(CCFadeIn:create(0.5))
        local spawn1 = CCSpawn:create(arry1)
        local arry2 = CCArray:create()
        arry2:addObject(CCMoveTo:create(0.5, ccp(posX2, posY)))
        arry2:addObject(CCFadeOut:create(0.5))
        local spawn2 = CCSpawn:create(arry2)
        arrowSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(spawn2, spawn1)))
    end
    runArrowAction(leftArrowSp, - 1)
    runArrowAction(rightArrowSp, 1)

    local leftTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then --[[onPageCallback(pageLayer, -1)]] onPageCallback(clipper, -1) end end)
    local rightTouchArrow = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if type(onPageCallback) == "function" then --[[onPageCallback(pageLayer, 1)]] onPageCallback(clipper, 1) end end)
    leftTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    rightTouchArrow:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    leftTouchArrow:setContentSize(CCSizeMake(leftArrowSp:getContentSize().width + 40, leftArrowSp:getContentSize().height + 50))
    rightTouchArrow:setContentSize(CCSizeMake(rightArrowSp:getContentSize().width + 40, rightArrowSp:getContentSize().height + 50))
    leftTouchArrow:setPosition(leftArrowSp:getPositionX(), leftArrowSp:getPositionY())
    rightTouchArrow:setPosition(rightArrowSp:getPositionX(), rightArrowSp:getPositionY())
    leftTouchArrow:setOpacity(0)
    rightTouchArrow:setOpacity(0)
    pageLayer:addChild(leftTouchArrow)
    pageLayer:addChild(rightTouchArrow)
    if type(onPageCallback) == "function" then
        -- onPageCallback(pageLayer, 0)
        onPageCallback(clipper, 0)
    end

    return pageLayer
end

function acMysteryBoxDialog:onCellOfRewardTv(cell, cellSize, idx, cellNum)
    if idx == 0 then
        self.cellTimeLb = {}
    end
    local data = self.shopList[idx + 1]
    if data == nil then
        do return end
    end
    local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 8))
    cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
    cell:addChild(cellBg)
    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
    nameBg:setContentSize(CCSizeMake(cellBg:getContentSize().width - 150, nameBg:getContentSize().height))
    nameBg:setAnchorPoint(ccp(0, 1))
    nameBg:setPosition(0, cellBg:getContentSize().height - 3)
    cellBg:addChild(nameBg)
    local nameLb = GetTTFLabel(data.name, 22, true)
    nameLb:setAnchorPoint(ccp(0, 0.5))
    nameLb:setPosition(15, nameBg:getContentSize().height / 2)
    nameLb:setColor(G_ColorYellowPro)
    nameBg:addChild(nameLb)
    local rData = acMysteryBoxVoApi:getRechargeData(data.index)
    local rState, rNum = 0, 0
    if rData then
        rState = (rData[1] or 0) --充值状态  默认 0 未充值； 1 已充值； 2 已领取
        rNum = (rData[2] or 0) --领取次数
    end
    if data.rtype == 1 and rNum >= data.limit then
        local dTs = G_getWeeTs(base.serverTime) + 86400 - base.serverTime
        if dTs < 0 then
            dTs = 0
        end
        local againLb = GetTTFLabel(getlocal("acMysteryBox_againBuy", {GetTimeStr(dTs)}), 20)
        againLb:setAnchorPoint(ccp(1, 0.5))
        againLb:setPosition(ccp(cellBg:getContentSize().width - 3, nameBg:getPositionY() - nameBg:getContentSize().height / 2))
        cellBg:addChild(againLb)
        self.cellTimeLb[data.index] = againLb
    end
    local oldPriceLb
    if data.price and data.price > 0 then
        oldPriceLb = GetTTFLabel(getlocal("vip_tequanlibao_realCost", {data.price .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]}), 20)
        local oldPriceLineLb = GetTTFLabel("-", 20)
        oldPriceLineLb:setScaleX(oldPriceLb:getContentSize().width / oldPriceLineLb:getContentSize().width)
        oldPriceLineLb:setPosition(ccp(oldPriceLb:getContentSize().width / 2, oldPriceLb:getContentSize().height / 2))
        oldPriceLb:addChild(oldPriceLineLb)
        oldPriceLb:setColor(G_ColorRed)
        oldPriceLineLb:setColor(G_ColorRed)
    end
    local rewardItemTb = {}
    local function onClickButton(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if rState == 1 then
            acMysteryBoxVoApi:requestReward(function()
                for k, v in pairs(rewardItemTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                    if v.type == "h" then --添加将领魂魄
                        if v.key and string.sub(v.key, 1, 1) == "s" then
                            heroVoApi:addSoul(v.key, tonumber(v.num))
                        end
                    end
                end
                G_showRewardTip(rewardItemTb)
                -- if self.rewardTv then
                --     local recordPoint = self.rewardTv:getRecordPoint()
                --     self.rewardTv:reloadData()
                --     self.rewardTv:recoverToRecordPoint(recordPoint)
                -- end
            end, data.index)
        else
            G_rechargeHandler(data.recharge, data.cost, data.name, self.layerNum)
        end
    end
    local btnStr = G_getPlatStoreCfg()["moneyType"][GetMoneyName()] .. data.cost --getlocal("activity_calls_reward", {data.cost})
    if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
        btnStr = data.cost .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
    end
    local btnEnabled = true
    local btnImage1, btnImage2 = "creatRoleBtn.png", "creatRoleBtn_Down.png"
    if rState == 1 then --可领取
        btnStr = getlocal("daily_scene_get")
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
        if oldPriceLb then
            oldPriceLb:removeFromParentAndCleanup(true)
            oldPriceLb = nil
        end
    elseif rState == 2 and rNum >= data.limit then --已领取
        btnStr = getlocal("activity_hadReward")
        btnEnabled = false
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
        if oldPriceLb then
            oldPriceLb:removeFromParentAndCleanup(true)
            oldPriceLb = nil
        end
    end
    local btnScale = 0.6
    local button = GetButtonItem(btnImage1, btnImage2, btnImage1, onClickButton, 11, btnStr, 24 / btnScale)
    local btnMenu = CCMenu:createWithItem(button)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    cellBg:addChild(btnMenu)
    button:setScale(btnScale)
    button:setAnchorPoint(ccp(1, 0))
    button:setPosition(ccp(cellBg:getContentSize().width - 20, 35))
    button:setEnabled(btnEnabled)
    if oldPriceLb then
        oldPriceLb:setPosition(ccp(button:getPositionX() - button:getContentSize().width * btnScale / 2, button:getPositionY() + button:getContentSize().height * btnScale + 5 + oldPriceLb:getContentSize().height / 2))
        cellBg:addChild(oldPriceLb)
    end
    local rewardTb = data.reward
    local itemTvSize = CCSizeMake(button:getPositionX() - button:getContentSize().width * btnScale - 40, 100)
    local itemTv = G_createTableView(itemTvSize, SizeOfTable(rewardTb), CCSizeMake(100, 100), function(cell, cellSize, idx, cellNum)
        local v = FormatItem(rewardTb[idx + 1])[1]
        if v == nil then
            do return end
        end
        rewardItemTb[idx] = v
        local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
            if v.type == "at" and v.eType == "a" then --AI部队
                local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
            else
                G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
            end
        end)
        icon:setScale(90 / icon:getContentSize().height)
        scale = icon:getScale()
        icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        icon:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
        cell:addChild(icon)
    end, true)
    itemTv:setPosition(ccp(20, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2 - itemTvSize.height / 2))
    itemTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    itemTv:setMaxDisToBottomOrTop(0)
    cellBg:addChild(itemTv)
end

function acMysteryBoxDialog:overDayEvent()
    if self then
        if self.rewardTv and acMysteryBoxVoApi:checkOverDayData() == true then
            local recordPoint = self.rewardTv:getRecordPoint()
            self.rewardTv:reloadData()
            self.rewardTv:recoverToRecordPoint(recordPoint)
        end
    end
end

function acMysteryBoxDialog:tick()
    if self then
        local acVo = acMysteryBoxVoApi:getAcVo()
        if activityVoApi:isStart(acVo) == false then --活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        elseif self.cellTimeLb then
            for k, v in pairs(self.cellTimeLb) do
                local againLb = tolua.cast(v, "CCLabelTTF")
                if againLb then
                    local dTs = G_getWeeTs(base.serverTime) + 86400 - base.serverTime
                    if dTs < 0 then
                        dTs = 0
                    end
                    againLb:setString(getlocal("acMysteryBox_againBuy", {GetTimeStr(dTs)}))
                end
            end
        end
    end
end

function acMysteryBoxDialog:dispose()
    local acVo = acMysteryBoxVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = nil
    end
    self = nil
    spriteController:removePlist("public/rewardCenterImage.plist")
    spriteController:removeTexture("public/rewardCenterImage.png")
    -- spriteController:removePlist("public/accessoryImage.plist")
    -- spriteController:removePlist("public/accessoryImage2.plist")
end