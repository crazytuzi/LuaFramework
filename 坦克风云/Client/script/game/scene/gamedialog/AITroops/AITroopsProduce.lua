AITroopsProduce = {}

function AITroopsProduce:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsProduce:init(layerNum, parent)
    local function addRes()
        spriteController:addPlist("public/aiTroopsImage/aitroops_images3.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_images3.png")
        spriteController:addPlist("public/aiTroopsImage/aitroops_effect3.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_effect3.png")
    end
    G_addResource8888(addRes)
    self.layerNum, self.parent = layerNum, parent
    self.bgLayer = CCLayer:create()
    
    self:initMainLayer()
    
    self.selectTroopType = AITroopsVoApi:getCurProduceTroopType()
    self.listOpenFlag = false
    local bgWidth, bgHeight, firstPosX, firstPosY, itemPriority = 200, 40, self.mainBg:getContentSize().width / 2, 322, -(self.layerNum - 1) * 20 - 6
    local curTroopItemArrowSp
    
    local function hideList()
        if self.listLayer then
            self.listLayer:removeFromParentAndCleanup(true)
            self.listLayer = nil
        end
        self.listOpenFlag = false
        if curTroopItemArrowSp then
            curTroopItemArrowSp:setVisible(true)
        end
    end
    local function selectItem(object, fn, tag)
        local touchType = tag / 10
        if self.selectTroopType == touchType then
            hideList()
            do return end
        end
        local unlockFlag, needStrength, curStrength = AITroopsVoApi:isTroopsUnlock(touchType)
        if unlockFlag == false then --未解锁给出提示
            local troopsStr = getlocal("aitroops_troop" .. (tonumber(touchType) - 1))
            local tipsStr = getlocal("aitroops_troopunlock_tip", {troopsStr, getlocal("scheduleChapter", {curStrength, needStrength})})
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipsStr, 28)
        elseif self.curTroopItemLb and tolua.cast(self.curTroopItemLb, "CCLabelTTF") then
            self.selectTroopType = touchType
            self.curTroopItemLb:setString(getlocal("aitroops_troop" .. self.selectTroopType))
            self:refreshProduceCostTankView() --选中后刷新坦克消耗
            AITroopsVoApi:saveCurProduceTroopType(self.selectTroopType) --本地保存一下选中的部队类型
        end
        hideList()
    end
    local function showList()
        hideList()
        if curTroopItemArrowSp then
            curTroopItemArrowSp:setVisible(false)
        end
        
        local listLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), hideList)
        listLayer:setTouchPriority(-(layerNum - 1) * 20 - 5)
        listLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        listLayer:setOpacity(0)
        listLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(listLayer, 3)
        self.listLayer = listLayer
        local list = {1, 2, 3}
        table.remove(list, tonumber(self.selectTroopType))
        local itemCount = SizeOfTable(list)
        for k, v in pairs(list) do
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("ait_select_bg.png", CCRect(4, 4, 1, 1), selectItem)
            itemBg:setContentSize(CCSizeMake(bgWidth, bgHeight))
            local curTroopItemBgPos = self.curTroopItemBg:getParent():convertToWorldSpace(ccp(self.curTroopItemBg:getPosition()))
            itemBg:setPosition(G_VisibleSizeWidth / 2, curTroopItemBgPos.y + (itemCount + 1 - k) * bgHeight)
            itemBg:setTag(v * 10)
            itemBg:setIsSallow(true)
            itemBg:setTouchPriority(itemPriority)
            listLayer:addChild(itemBg)
            local itemLb = GetTTFLabelWrap(getlocal("aitroops_troop" .. tostring(v)), 22, CCSize(bgWidth - 4, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
            -- itemLb:setColor(G_ColorGreen)
            itemLb:setPosition(getCenterPoint(itemBg))
            itemBg:addChild(itemLb)
            local unlockFlag = AITroopsVoApi:isTroopsUnlock(v)
            if unlockFlag == false then
                itemLb:setColor(G_ColorRed)
                local lockSize = 35
                local lockSp = CCSprite:createWithSpriteFrameName("aitroops_lock.png")
                lockSp:setScale(lockSize / lockSp:getContentSize().height)
                lockSp:setPosition(bgWidth - lockSp:getContentSize().width * lockSp:getScale() * 0.5 - 5, itemBg:getContentSize().height / 2)
                itemBg:addChild(lockSp)
            end
        end
        self.listOpenFlag = true
    end
    local function touchCurItem(object, fn, tag)
        local touchType = tag / 10
        if self.selectTroopType == touchType and self.listOpenFlag == true then --如果选中的就是当前的则直接隐藏列表
            hideList()
            do return end
        end
        showList() --显示列表
    end
    local curTroopItemBg = LuaCCScale9Sprite:createWithSpriteFrameName("ait_select_bg.png", CCRect(4, 4, 1, 1), touchCurItem)
    curTroopItemBg:setContentSize(CCSizeMake(bgWidth, bgHeight))
    curTroopItemBg:setPosition(firstPosX, firstPosY)
    curTroopItemBg:setTag(self.selectTroopType * 10)
    curTroopItemBg:setIsSallow(true)
    curTroopItemBg:setTouchPriority(itemPriority)
    self.mainBg:addChild(curTroopItemBg, 2)
    curTroopItemArrowSp = CCSprite:createWithSpriteFrameName("ait_arrow_up.png")
    curTroopItemArrowSp:setPosition(curTroopItemBg:getContentSize().width / 2, curTroopItemBg:getContentSize().height)
    curTroopItemBg:addChild(curTroopItemArrowSp)
    local arrowSeq = CCSequence:createWithTwoActions(CCMoveBy:create(0.3, ccp(0, 3)), CCMoveBy:create(0.3, ccp(0, -3)))
    curTroopItemArrowSp:runAction(CCRepeatForever:create(arrowSeq))
    local curTroopItemLb = GetTTFLabelWrap(getlocal("aitroops_troop" .. self.selectTroopType), 22, CCSize(bgWidth - 4, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    -- curTroopItemLb:setColor(G_ColorGreen)
    curTroopItemLb:setPosition(getCenterPoint(curTroopItemBg))
    curTroopItemBg:addChild(curTroopItemLb)
    self.curTroopItemBg = curTroopItemBg
    self.curTroopItemLb = curTroopItemLb
    
    local slotTimerWidth, slotTimerHeight = 506, 32
    local slotTimerSp = CCSprite:createWithSpriteFrameName("TeamTravelBarBg.png")
    slotTimerSp:setPosition(firstPosX, firstPosY)
    slotTimerSp:setColor(ccc3(0, 0, 0))
    slotTimerSp:setOpacity(255 * 0.7)
    local scaleX, scaleY = slotTimerWidth / slotTimerSp:getContentSize().width, slotTimerHeight / slotTimerSp:getContentSize().height
    slotTimerSp:setScaleX(scaleX)
    slotTimerSp:setScaleY(scaleY)
    self.mainBg:addChild(slotTimerSp, 5)
    
    local slotTimer = AddProgramTimer(slotTimerSp, getCenterPoint(slotTimerSp), 9, 12, "", nil, "TeamTravelBar.png", 11)
    local lbPer = tolua.cast(slotTimer:getChildByTag(12), "CCLabelTTF")
    lbPer:setScaleX(1 / scaleX)
    lbPer:setScaleY(1 / scaleY)
    self.slotTimerSp = slotTimerSp
    self.slotTimer = slotTimer
    self.timerLb = lbPer
    
    self:refreshProduceView()
    
    self:initButton() --功能按钮
    
    self:refreshProduceCostTankView() --坦克消耗刷新
    
    self:tick()
    
    local function produceRefresh(event, data)
        if data == nil then
            do return end
        end
        if data.rtype then
            if data.rtype == 1 then --生产刷新
                self:refresh()
            elseif data.rtype == 2 then --生产中被攻击玩家中断，则需要重新拉取一下数据
                local function handler()
                    self:refresh()
                end
                --避免重复调用get接口
                if data.ispush == 1 then
                    AITroopsVoApi:AITroopsGet(1, handler)
                else
                    handler()
                end
            end
        end
        if data.pr or data.br or data.cr then
            local rewardList = nil
            local titleStr, tipContent
            if data.pr then --生产产出
                rewardList = FormatItem(data.pr, nil, true)
                titleStr = getlocal("aitroops_troop_out")
                if rewardList and rewardList[1] then
                    tipContent = {getlocal("aitroops_troop_produceFinished", {rewardList[1].name}), {nil, G_ColorGreen, nil}, 22}
                end
            elseif data.br then --生产被打断后返还部队
                rewardList = FormatItem(data.br, nil, true)
                titleStr = getlocal("aitroops_troop_back")
                tipContent = {getlocal("aitroops_troop_break_tip"), {}, 22}
            elseif data.cr then --取消生产后返还部队
                rewardList = FormatItem(data.cr, nil, true)
                titleStr = getlocal("aitroops_troop_back")
                tipContent = {getlocal("aitroops_produce_cancel_tip3"), {}, 22}
            end
            if rewardList then
                AITroopsVoApi:showRewardDialog(rewardList, titleStr, tipContent, getlocal("confirm"), nil, self.layerNum + 4)
            end
        end
    end
    self.produceRefreshListener = produceRefresh
    eventDispatcher:addEventListener("aitroops.produce.refresh", produceRefresh)
    
    local function overTodayRefresh(event, data)
        self:refreshProduceCostTankView() --跨天刷新生产AI部队消耗
    end
    self.overTodayListener = overTodayRefresh
    eventDispatcher:addEventListener("aitroops.over.today", overTodayRefresh)
    
    return self.bgLayer
end

function AITroopsProduce:initButton()
    local btnScale, btnPosY, priority, zorder = 1, 260, -(self.layerNum - 1) * 20 - 4, 180, 2
    local leftBtnPosX, rightBtnPosX = 140, G_VisibleSizeWidth - 140
    --重置坦克消耗类型
    local function reset()
        local gems = playerVoApi:getGems()
        local cost = AITroopsVoApi:getResetCost()
        if gems < cost then --金币不足
            GemsNotEnoughDialog(nil, nil, cost - gems, self.layerNum + 1, cost)
            do return end
        end
        local function realReset()
            local function callback()
                playerVoApi:setGems(gems - cost)
                self:resetEffect()
            end
            AITroopsVoApi:resetProduceCost(self.selectTroopType, callback)
        end
        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("aitroops_reset_tip", {cost}), false, realReset)
    end
    self.resetItem, self.resetMenu = G_createBotton(self.mainBg, ccp(leftBtnPosX, btnPosY), {getlocal("dailyTaskReset"), nil, nil, {ccc3(0, 93, 158), 2}}, "ait_greenbtn.png", "ait_greenbtn_down.png", "ait_greenbtn_down.png", reset, btnScale, priority, zorder)
    
    --生产AI部队
    local function produce()
        local flag = AITroopsVoApi:isProduceLimit()
        if flag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_produce_tip5"), 28)
            do return end
        end
        -- local tankId, num = AITroopsVoApi:getProduceCostByTroopType(self.selectTroopType)
        -- if tankId and num then
        --     tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
        --     local ownNum = tankVoApi:getTankCountByItemId(tankId)
        --     if ownNum < num then
        --         smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_produce_needless1"), 28)
        --         do return end
        --     end
        -- end
        AITroopsVoApi:showProduceConfirmDialog(self.selectTroopType, self.layerNum + 1)
    end
    self.produceItem, self.produceMenu = G_createBotton(self.mainBg, ccp(rightBtnPosX, btnPosY), {getlocal("startProduce"), nil, nil, {ccc3(0, 93, 158), 2}}, "ait_greenbtn.png", "ait_greenbtn_down.png", "ait_greenbtn_down.png", produce, btnScale, priority, zorder)
    
    --加速生产AI部队
    local function speedup()
        local gems = playerVoApi:getGems()
        local cost = AITroopsVoApi:getSpeedupCost(self.produce)
        if gems < cost then --金币不足
            GemsNotEnoughDialog(nil, nil, cost - gems, self.layerNum + 1, cost)
            do return end
        end
        local function realSpeedup()
            AITroopsVoApi:AITroopsProduceSpeedup(self.slotId)
        end
        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("aitroops_produce_speedup_tip", {cost}), false, realSpeedup)
    end
    self.speedupItem, self.speedupMenu = G_createBotton(self.mainBg, ccp(rightBtnPosX, btnPosY), {getlocal("accelerateBuild"), nil, nil, {ccc3(0, 93, 158), 2}}, "ait_greenbtn.png", "ait_greenbtn_down.png", "ait_greenbtn_down.png", speedup, btnScale, priority, zorder)
    
    --取消生产AI部队
    local function cancel()
        local function realCancel()
            AITroopsVoApi:AITroopsProduceCancel(self.slotId)
        end
        local addStrTb = {{getlocal("aitroops_produce_cancel_tip2"), G_ColorRed, 22, kCCTextAlignmentCenter, 20}}
        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("aitroops_produce_cancel_tip1"), false, realCancel, nil, nil, nil, addStrTb)
    end
    self.cancelItem, self.cancelMenu = G_createBotton(self.mainBg, ccp(leftBtnPosX, btnPosY), {getlocal("cancel"), nil, nil, {ccc3(0, 93, 158), 2}}, "ait_greenbtn.png", "ait_greenbtn_down.png", "ait_greenbtn_down.png", cancel, btnScale, priority, zorder)
    
    --显示生产池
    local function showPool()
        AITroopsVoApi:showProducePoolDialog(self.layerNum + 1)
    end
    local poolItem, poolMenu = G_createBotton(self.screenSp, ccp(485, 952), {getlocal("aitroops_produce_pool"), nil, nil, {ccc3(0, 93, 158), 2}}, "ait_pool_btn.png", "ait_pool_btn.png", "ait_pool_btn.png", showPool, 1, priority, 1)
    
    --显示规则说明
    local function showRule()
        local aiTroopsCfg = AITroopsVoApi:getModelCfg()
        local tabStr, textFormatTb = {}, {}
        table.insert(tabStr, getlocal("aitroops_produce_rule_title"))
        table.insert(textFormatTb, {richColor = {G_ColorYellowPro}, richFlag = true})
        local arg = {
            [1] = {aiTroopsCfg.dailyProduceLimitNum},
            [2] = {aiTroopsCfg.returnTankRate * 100},
        }
        local formatTb = {
            [1] = {richColor = {nil, G_ColorYellowPro, nil}, richFlag = true},
            [2] = {richColor = {nil, G_ColorYellowPro, nil}, richFlag = true},
        }
        for k = 1, 3 do
            local str = getlocal("aitroops_produce_rule" .. k, arg[k] or {})
            table.insert(tabStr, str)
            table.insert(textFormatTb, formatTb[k] or {})
        end
        table.insert(tabStr, getlocal("aitroops_fight_rule_title"))
        table.insert(textFormatTb, {richColor = {G_ColorYellowPro}, richFlag = true})
        
        arg = {
            [1] = {aiTroopsCfg.aiTroopsEquipLimit},
        }
        formatTb = {
            [1] = {richColor = {nil, G_ColorYellowPro, nil}, richFlag = true},
        }
        for k = 1, 2 do
            local str = getlocal("aitroops_fight_rule" .. k, arg[k] or {})
            table.insert(tabStr, str)
            table.insert(textFormatTb, formatTb[k] or {})
        end
        
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    local ruleItem, ruleMenu = G_createBotton(self.mainBg, ccp(534.5, 399), {}, "ait_infopic.png", "ait_infopic.png", "ait_infopic.png", showRule, 1, priority, zorder)
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.25, 1.1))
    arr:addObject(CCScaleTo:create(0.25, 1))
    arr:addObject(CCScaleTo:create(0.25, 1.1))
    arr:addObject(CCScaleTo:create(0.25, 1))
    arr:addObject(CCDelayTime:create(math.random(5, 8)))
    ruleItem:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    
    self:refreshButton()
end

function AITroopsProduce:refreshButton()
    local flag = AITroopsVoApi:isHasProduceQueue()
    if flag == true then
        self.speedupItem:setEnabled(true)
        self.speedupMenu:setVisible(true)
        self.cancelItem:setEnabled(true)
        self.cancelMenu:setVisible(true)
        self.resetItem:setEnabled(false)
        self.resetMenu:setVisible(false)
        self.produceItem:setEnabled(false)
        self.produceMenu:setVisible(false)
    else
        self.speedupItem:setEnabled(false)
        self.speedupMenu:setVisible(false)
        self.cancelItem:setEnabled(false)
        self.cancelMenu:setVisible(false)
        self.resetItem:setEnabled(true)
        self.resetMenu:setVisible(true)
        self.produceItem:setEnabled(true)
        self.produceMenu:setVisible(true)
    end
end

--刷新消耗坦克类型
function AITroopsProduce:refreshProduceCostTankView()
    if self.produceCostSp then
        self.produceCostSp:removeFromParentAndCleanup(true)
        self.produceCostSp = nil
    end
    local tankId, num = AITroopsVoApi:getProduceCostByTroopType(self.selectTroopType)
    if tankId and num then
        local tankSize = 50
        tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
        local tankSp = tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
        tankSp:setScale(tankSize / tankSp:getContentSize().width)
        tankSp:setAnchorPoint(ccp(0, 0.5))
        tankSp:setPosition(270, 263)
        self.mainBg:addChild(tankSp, 3)
        self.produceCostSp = tankSp
        if tankId ~= G_pickedList(tankId) then
            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
            tankSp:addChild(pickedIcon)
            pickedIcon:setPosition(tankSp:getContentSize().width - 30, 30)
            pickedIcon:setScale(1.5)
        end
        -- local costStr = getlocal("activity_xuyuanlu_costGolds", {num})
        local costStr = "x" .. num
        if self.produceCostLb == nil then
            local costLb = GetTTFLabel(costStr, 20, true)
            costLb:setAnchorPoint(ccp(0, 0.5))
            costLb:setPosition(tankSp:getPositionX() + tankSize + 10, tankSp:getPositionY())
            self.mainBg:addChild(costLb)
            self.produceCostLb = costLb
        else
            self.produceCostLb:setString(costStr)
        end
        local ownNum1 = tankVoApi:getTankCountByItemId(tankId)
        local ownNum2 = tankVoApi:getTankCountByItemId(tankId+40000)
        local ownNum = ownNum1+ownNum2
        if ownNum < num then --拥有数量不足
            self.produceCostLb:setColor(G_ColorRed)
        else
            self.produceCostLb:setColor(G_ColorYellow)
        end
        --保持居中显示
        local posX = (self.mainBg:getContentSize().width - (tankSize + self.produceCostLb:getContentSize().width + 10)) / 2
        self.produceCostSp:setPositionX(posX)
        self.produceCostLb:setPositionX(posX + tankSize + 10)
    else
        if self.produceCostLb then
            self.produceCostLb:setString("")
        end
    end
end

--重置效果
function AITroopsProduce:resetEffect()
    for i = 1, 2 do
        local particleSystem = CCParticleSystemQuad:create("public/textShine" .. i .. ".plist")
        particleSystem:setScale(1)
        particleSystem:setPosition(ccp(self.produceCostSp:getPositionX() + self.produceCostSp:getContentSize().width * self.produceCostSp:getScale() / 2, self.produceCostSp:getPositionY()))
        particleSystem:setAutoRemoveOnFinish(true)
        self.produceCostSp:getParent():addChild(particleSystem, 10)
    end
end

function AITroopsProduce:refreshProduceView()
    self.slotId, self.produce = AITroopsVoApi:getProduceQueue()
    if self.slotId and self.produce and base.serverTime < self.produce.et then --有生产队列
        if self.curTroopItemBg then
            self.curTroopItemBg:setVisible(false)
            self.curTroopItemBg:setPositionX(9999)
        end
        if self.slotTimerSp and self.slotTimer and self.timerLb then
            self.slotTimerSp:setVisible(true)
        end
    else
        if self.curTroopItemBg then
            self.curTroopItemBg:setVisible(true)
            self.curTroopItemBg:setPositionX(G_VisibleSizeWidth / 2)
        end
        if self.slotTimerSp then
            self.slotTimerSp:setVisible(false)
        end
    end
end

function AITroopsProduce:refresh()
    self:refreshProduceView()
    self:refreshProduceCostTankView()
    self:refreshButton()
    self:tick()
end

function AITroopsProduce:initMainLayer()
    local screenWidth, screenHeight = G_VisibleSizeWidth, G_VisibleSizeHeight - 158
    local screenCliper = CCClippingNode:create()
    screenCliper:setContentSize(CCSizeMake(screenWidth, screenHeight))
    screenCliper:setAnchorPoint(ccp(0.5, 1))
    screenCliper:setPosition(G_VisibleSizeWidth / 2, screenHeight)
    local stencil = CCDrawNode:getAPolygon(CCSizeMake(screenWidth, screenHeight), 1, 1)
    screenCliper:setStencil(stencil)
    self.bgLayer:addChild(screenCliper, 2)
    
    local mainBgPosY = screenHeight
    local iphoneType = G_getIphoneType()
    if iphoneType == G_iphone4 then
        mainBgPosY = screenHeight + 70
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local mainBg = CCSprite:create("public/aiTroopsImage/ait_main_kuang.png")
    mainBg:setPosition(G_VisibleSizeWidth / 2, mainBgPosY)
    mainBg:setAnchorPoint(ccp(0.5, 1))
    screenCliper:addChild(mainBg, 5)
    self.mainBg = mainBg
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local mainBgSize = mainBg:getContentSize()
    
    local screenSp = LuaCCScale9Sprite:createWithSpriteFrameName("ait_screenpic.png", CCRect(4, 4, 1, 1), function () end)
    screenSp:setAnchorPoint(ccp(0.5, 1))
    screenSp:setPosition(G_VisibleSizeWidth / 2, mainBgPosY)
    screenSp:setContentSize(CCSizeMake(mainBgSize.width, mainBgSize.height))
    screenCliper:addChild(screenSp, 2)
    self.screenSp = screenSp
    
    local screenUp = CCSprite:createWithSpriteFrameName("ait_screenpic1.png")
    screenUp:setPosition(256.5, 838.5)
    screenSp:addChild(screenUp)
    local screenDown = CCSprite:createWithSpriteFrameName("ait_screenpic2.png")
    screenDown:setPosition(323, 499.5)
    screenSp:addChild(screenDown)
    self.screenUp = screenUp
    
    self:playUpScreenEffect()
    self:playDownScreenEffect()
end

--上方屏幕特效
function AITroopsProduce:playUpScreenEffect()
    --两块扇形动作
    local sectorSp1 = CCSprite:createWithSpriteFrameName("ait_sector.png")
    local sectorSp2 = CCSprite:createWithSpriteFrameName("ait_sector.png")
    sectorSp1:setPosition(150, 786)
    sectorSp2:setPosition(150, 786)
    self.screenSp:addChild(sectorSp1)
    self.screenSp:addChild(sectorSp2)
    sectorSp2:setRotation(40)
    local function sectorSpAction(isSp1)
        local sectorSp
        if isSp1 then
            sectorSp = sectorSp1
            isSp1 = nil
        else
            sectorSp = sectorSp2
            isSp1 = true
        end
        local seq = CCSequence:createWithTwoActions(CCRotateBy:create(1.5, 360 - 2 * 40), CCCallFunc:create(function() sectorSpAction(isSp1) end))
        sectorSp:runAction(seq)
    end
    sectorSpAction()
    
    --缩放的圆点动作
    local circleSp = CCSprite:createWithSpriteFrameName("ait_scalecircel.png")
    circleSp:setPosition(369, 878)
    self.screenSp:addChild(circleSp)
    circleSp:setScale(0)
    local function circleSpAction()
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(1, 1))
        arr:addObject(CCCallFunc:create(function() circleSp:setScale(0) end))
        local seq = CCSequence:create(arr)
        local ccrepeat = CCRepeat:create(seq, 6)
        local repeatForever = CCRepeatForever:create(ccrepeat)
        circleSp:runAction(repeatForever)
    end
    circleSpAction()
    
    --坦克动作
    local tankBg1 = CCSprite:createWithSpriteFrameName("ait_light_screentank1.png")
    local tankBg2 = CCSprite:createWithSpriteFrameName("ait_light_screentank2.png")
    tankBg1:setOpacity(30)
    tankBg2:setOpacity(30)
    tankBg1:setPosition(201.5, 892.5)
    tankBg2:setPosition(443.5, 797)
    self.screenSp:addChild(tankBg1)
    self.screenSp:addChild(tankBg2)
    local tankSp1 = CCSprite:createWithSpriteFrameName("ait_screen_tank1.png")
    local tankSp2 = CCSprite:createWithSpriteFrameName("ait_screen_tank2.png")
    G_setBlendFunc(tankSp1, GL_ONE, GL_ONE)
    G_setBlendFunc(tankSp2, GL_ONE, GL_ONE)
    tankSp1:setPosition(tankBg1:getPositionX()+4,tankBg1:getPositionY()-1)
    tankSp2:setPosition(tankBg2:getPositionX()+3,tankBg2:getPositionY()-4)
    self.screenSp:addChild(tankSp1)
    self.screenSp:addChild(tankSp2)
    tankSp1:setOpacity(255 * 0.9)
    tankSp2:setOpacity(0)
    local function tankSpAction()
        for i = 1, 2 do
            local arr = CCArray:create()
            if i == 1 then
                arr:addObject(CCFadeTo:create(1.5, 0))
                arr:addObject(CCFadeTo:create(1.5, 255 * 0.9))
            else
                arr:addObject(CCFadeTo:create(1.5, 255 * 0.9))
                arr:addObject(CCFadeTo:create(1.5, 0))
            end
            local seq = CCSequence:create(arr)
            local ccrepeat = CCRepeat:create(seq, 2)
            local repeatForever = CCRepeatForever:create(ccrepeat)
            if i == 1 then
                tankSp1:runAction(repeatForever)
            else
                tankSp2:runAction(repeatForever)
            end
        end
    end
    tankSpAction()
    
    --底板网格动作
    local shadeSp = CCSprite:createWithSpriteFrameName("ait_screen_shade.png")
    G_setBlendFunc(shadeSp, GL_ONE, GL_ONE)
    shadeSp:setPosition(314, 838.5)
    self.screenSp:addChild(shadeSp)
    shadeSp:setOpacity(0)
    local function shadeSpAction()
        local arr = CCArray:create()
        arr:addObject(CCFadeTo:create(3, 255))
        arr:addObject(CCFadeTo:create(3, 0))
        local seq = CCSequence:create(arr)
        local repeatForever = CCRepeatForever:create(seq)
        shadeSp:runAction(repeatForever)
    end
    shadeSpAction()
    
    --两边扫描动作
    self:playScanAction()
end

--两边扫描动作
function AITroopsProduce:playScanAction(isStopAction)
    if self.scanSpLeft == nil then
        self.scanSpLeft = CCSprite:createWithSpriteFrameName("ait_screen_scanline.png")
        G_setBlendFunc(self.scanSpLeft, GL_ONE, GL_ONE)
        self.screenSp:addChild(self.scanSpLeft, 2)
    end
    if self.scanSpRight == nil then
        self.scanSpRight = CCSprite:createWithSpriteFrameName("ait_screen_scanline.png")
        G_setBlendFunc(self.scanSpRight, GL_ONE, GL_ONE)
        self.scanSpRight:setFlipX(true)
        self.screenSp:addChild(self.scanSpRight, 2)
    end
    if isStopAction == true then
        self.scanSpLeft:stopAllActions()
        self.scanSpRight:stopAllActions()
    end
    self.scanSpLeft:setAnchorPoint(ccp(1, 0.5))
    self.scanSpRight:setAnchorPoint(ccp(0, 0.5))
    self.scanSpLeft:setPosition(70, 838.5)
    self.scanSpRight:setPosition(self.mainBg:getContentSize().width - 70, 838.5)
    self.scanSpLeft:setOpacity(0)
    self.scanSpRight:setOpacity(0)
    
    if not isStopAction then
        local moveDistance = self.mainBg:getContentSize().width - 70 * 2
        for i = 1, 2 do
            local arr = CCArray:create()
            arr:addObject(CCFadeTo:create(1.5, 255))
            arr:addObject(CCFadeTo:create(1.5, 0))
            arr:addObject(CCCallFunc:create(function()
                self.scanSpLeft:setPositionX(70)
                self.scanSpRight:setPositionX(self.mainBg:getContentSize().width - 70)
            end))
            local arr1 = CCArray:create()
            arr1:addObject(CCSequence:create(arr))
            if i == 1 then
                arr1:addObject(CCMoveBy:create(3, ccp(moveDistance, 0)))
            else
                arr1:addObject(CCMoveBy:create(3, ccp(-moveDistance, 0)))
            end
            local spawn = CCSpawn:create(arr1)
            local ccrepeat = CCRepeat:create(spawn, 2)
            local repeatForever = CCRepeatForever:create(ccrepeat)
            if i == 1 then
                self.scanSpLeft:runAction(repeatForever)
            else
                self.scanSpRight:runAction(repeatForever)
            end
        end
    end
end

--下方屏幕特效
function AITroopsProduce:playDownScreenEffect()
    --左边三个圆盘特效
    local circleCenterPos = ccp(174, 502)
    
    local circleSp1 = CCSprite:createWithSpriteFrameName("ait_circelpan1.png")
    circleSp1:setPosition(circleCenterPos)
    self.screenSp:addChild(circleSp1)
    
    local circleSp2 = CCSprite:createWithSpriteFrameName("ait_circelpan2.png")
    circleSp2:setPosition(circleCenterPos)
    self.screenSp:addChild(circleSp2)
    
    local circleSp3 = CCSprite:createWithSpriteFrameName("ait_circelpan3.png")
    circleSp3:setPosition(circleCenterPos)
    self.screenSp:addChild(circleSp3)
    
    local function circleSp1Action()
        local rotateBy = CCRotateBy:create(2, 360)
        local ccrepeat = CCRepeat:create(rotateBy, 3)
        local repeatForever = CCRepeatForever:create(ccrepeat)
        circleSp1:runAction(repeatForever)
    end
    
    local function circleSp2Action()
        local rotateBy = CCRotateBy:create(6, -360)
        local repeatForever = CCRepeatForever:create(rotateBy)
        circleSp2:runAction(repeatForever)
    end
    
    local function circleSp3Action()
        local arr = CCArray:create()
        local rotateBy = CCRotateBy:create(2, 360 + 45)
        arr:addObject(CCEaseIn:create(rotateBy, 2))
        arr:addObject(CCRotateBy:create(1, -45))
        local seq = CCSequence:create(arr)
        local ccrepeat = CCRepeat:create(seq, 2)
        local repeatForever = CCRepeatForever:create(ccrepeat)
        circleSp3:runAction(repeatForever)
    end
    
    circleSp1Action()
    circleSp2Action()
    circleSp3Action()
    
    --音量显示特效
    local volumeSpeed = 1 --从0缩放到1的时间
    local tarsrand = {0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}
    for k = 1, 20 do
        local oris, tars, pts, vacflag = 0, 0, 0, true --起始缩放比例，目标缩放比例,缩放时间，动作是否结束
        local aitVolumeSp = CCSprite:createWithSpriteFrameName("ait_volumepic.png")
        aitVolumeSp:setScaleY(oris)
        aitVolumeSp:setAnchorPoint(ccp(0, 0))
        aitVolumeSp:setPosition(300.5 + (k - 1) * (aitVolumeSp:getContentSize().width + 2), 563)
        self.screenSp:addChild(aitVolumeSp)
        
        local acArr = CCArray:create()
        local function playAction()
            if vacflag == true then
                vacflag = false
                tars = tarsrand[math.random(1, #tarsrand)] or 0.2
                volumeSpeed = math.random() + 1--速度随机1秒到2秒之间
                pts = math.abs(tars - oris) * volumeSpeed
                oris = tars
                local function playEnd()
                    vacflag = true
                end
                local scaleTo = CCScaleTo:create(pts, 1, tars)
                local func = CCCallFunc:create(playEnd)
                aitVolumeSp:runAction(CCSequence:createWithTwoActions(scaleTo, func))
            end
        end
        acArr:addObject(CCCallFunc:create(playAction))
        aitVolumeSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
    end
    --扫光进度条的特效
    local oriop, tarop = 0.2 * 255, 255 --起始透明度，目标透明度
    local opts1, opts2, opIntervalTs = 0.8, 1.2, 0.16
    for k = 1, 22 do
        local saproSp = CCSprite:createWithSpriteFrameName("ait_green_linear.png")
        saproSp:setPosition(304.5 + (k - 1) * (saproSp:getContentSize().width + 2), 399.5)
        saproSp:setOpacity(oriop)
        self.screenSp:addChild(saproSp)
        
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        saproSp:setBlendFunc(blendFunc)
        
        local acArr = CCArray:create()
        acArr:addObject(CCDelayTime:create((k - 1) * opIntervalTs))
        acArr:addObject(CCFadeTo:create(opts1, tarop))
        acArr:addObject(CCFadeTo:create(opts2, oriop))
        acArr:addObject(CCDelayTime:create((22 - k) * opIntervalTs))
        saproSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
    end
    --两行绿点的效果
    opts1, opts2, opIntervalTs = 0.65, 0.65, 0.5
    local greenPos = {ccp(304.5, 548.5), ccp(469.5, 506.5)}
    for k = 1, 2 do
        for num = 1, 3 do
            local greenPointSp = CCSprite:createWithSpriteFrameName("ait_green_point2.png")
            greenPointSp:setPosition(greenPos[k].x + (num - 1) * (greenPointSp:getContentSize().width + 3), greenPos[k].y)
            self.screenSp:addChild(greenPointSp)
            
            local lightSp = CCSprite:createWithSpriteFrameName("ait_green_point.png")
            lightSp:setPosition(getCenterPoint(greenPointSp))
            greenPointSp:addChild(lightSp)
            
            local blendFunc = ccBlendFunc:new()
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            lightSp:setBlendFunc(blendFunc)
            
            local acArr = CCArray:create()
            acArr:addObject(CCDelayTime:create((num - 1) * opIntervalTs))
            acArr:addObject(CCFadeTo:create(opts1, 255))
            acArr:addObject(CCFadeTo:create(opts2, 0))
            acArr:addObject(CCDelayTime:create((3 - num) * opIntervalTs))
            lightSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
        end
    end
    
    --小地图指示图标随机移动效果
    local mapPiontAcFlag, moveSpeed = true, 30 --指示表是否移动结束,移动速度（1秒多少像素）
    local randPos = {ccp(320.5, 480.5), ccp(340.5, 450.5), ccp(340, 490), ccp(380, 450), ccp(360, 450), ccp(380, 470)}
    local lastPos = randPos[1]
    local mapPointSp = CCSprite:createWithSpriteFrameName("ait_circel_point.png")
    mapPointSp:setPosition(randPos[1])
    self.screenSp:addChild(mapPointSp)
    local mapPointAcArr = CCArray:create()
    local function playMapPointAction()
        if mapPiontAcFlag == true then
            mapPiontAcFlag = false
            local pos = randPos[math.random(1, #randPos)] or randPos[1]
            local function playEnd()
                mapPiontAcFlag = true
            end
            local mt = math.sqrt(math.pow(math.abs(pos.x - lastPos.x), 2) + math.pow(math.abs(pos.y - lastPos.y), 2)) / moveSpeed
            local moveTo = CCMoveTo:create(mt, pos)
            local func = CCCallFunc:create(playEnd)
            mapPointSp:runAction(CCSequence:createWithTwoActions(moveTo, func))
            lastPos = pos
        end
    end
    mapPointAcArr:addObject(CCCallFunc:create(playMapPointAction))
    mapPointSp:runAction(CCRepeatForever:create(CCSequence:create(mapPointAcArr)))
    
    --小圆盘旋转动画
    local smallCircelSp = CCSprite:createWithSpriteFrameName("ait_circelpan5.png")
    smallCircelSp:setPosition(455.5, 524.5)
    self.screenSp:addChild(smallCircelSp)
    smallCircelSp:runAction(CCRepeatForever:create(CCRotateBy:create(5, 360)))
end

function AITroopsProduce:setTouchEnabled(_enabled, _callbackFunc, _touchPriority)
    local sp = self.bgLayer:getChildByTag(-99999)
    if _enabled then
        if sp then
            sp:removeFromParentAndCleanup(true)
            sp = nil
        end
    else
        if sp == nil then
        sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() if _callbackFunc then _callbackFunc() end end)
        if _touchPriority then
            sp:setTouchPriority(_touchPriority)
        else
            sp:setTouchPriority(-self.layerNum * 20 - 10)
        end
        sp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        sp:setOpacity(0)
        sp:setTag(-99999)
        self.bgLayer:addChild(sp, 99999)
    end
    sp:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
    return sp
end
end

--普通生产完成特效
function AITroopsProduce:produceFinishEffect(_clickCallFunc)
    local clickState = nil --防止连击
    
    --四周的灯光
    local upLightSp = CCSprite:createWithSpriteFrameName("ait_light_up.png")
    local downLightSp = CCSprite:createWithSpriteFrameName("ait_light_down.png")
    local leftLightSp = CCSprite:createWithSpriteFrameName("ait_light_left.png")
    local rightLightSp = CCSprite:createWithSpriteFrameName("ait_light_right.png")
    G_setBlendFunc(upLightSp, GL_ONE, GL_ONE)
    G_setBlendFunc(downLightSp, GL_ONE, GL_ONE)
    G_setBlendFunc(leftLightSp, GL_ONE, GL_ONE)
    G_setBlendFunc(rightLightSp, GL_ONE, GL_ONE)
    upLightSp:setPosition(320, 1034)
    downLightSp:setPosition(320, 222)
    leftLightSp:setPosition(43, 670)
    rightLightSp:setPosition(598, 670)
    self.mainBg:addChild(upLightSp)
    self.mainBg:addChild(downLightSp)
    self.mainBg:addChild(leftLightSp)
    self.mainBg:addChild(rightLightSp)
    upLightSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))))
    downLightSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))))
    leftLightSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))))
    rightLightSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))))
    
    --FINISH背景
    local finishBg = CCSprite:createWithSpriteFrameName("ait_finish_bg.png")
    finishBg:setPosition(323, 499.5)
    G_setBlendFunc(finishBg, GL_ONE, GL_ONE)
    self.screenSp:addChild(finishBg, 5)
    
    --向上扫描
    local function upScanAction(_refreshCallFunc)
        local firstFrameSp = CCSprite:createWithSpriteFrameName("ait_produce_finish_effect1.png")
        firstFrameSp:setPosition(314, 838.5)
        G_setBlendFunc(firstFrameSp, GL_ONE, GL_ONE)
        self.screenSp:addChild(firstFrameSp, 3)
        local frameArray = CCArray:create()
        for i = 1, 13 do
            local frameName = "ait_produce_finish_effect" .. i .. ".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
            if frame then
                frameArray:addObject(frame)
            end
        end
        local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.03)
        local animate = CCAnimate:create(animation)
        firstFrameSp:runAction(CCSequence:createWithTwoActions(animate, CCCallFunc:create(function()
            firstFrameSp:removeFromParentAndCleanup(true)
            firstFrameSp = nil
        end)))
        
        local upScaneSp = CCSprite:createWithSpriteFrameName("ait_screen_scanline.png")
        G_setBlendFunc(upScaneSp, GL_ONE, GL_ONE)
        upScaneSp:setAnchorPoint(ccp(1, 0.5))
        upScaneSp:setRotation(-90)
        upScaneSp:setScaleY(3)
        upScaneSp:setPosition(self.mainBg:getContentSize().width / 2, 691)
        self.screenSp:addChild(upScaneSp, 2)
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.5, 1, 1.5))
        arr:addObject(CCMoveBy:create(0.5, ccp(0, self.screenUp:getContentSize().height + upScaneSp:getContentSize().width)))
        upScaneSp:runAction(CCSequence:createWithTwoActions(CCSpawn:create(arr), CCCallFunc:create(function()
            upScaneSp:removeFromParentAndCleanup(true)
            upScaneSp = nil
            self:setTouchEnabled(true)
            self:playScanAction()
            clickState = nil
            if _refreshCallFunc then
                _refreshCallFunc()
            end
        end)))
    end
    --点击完成时背景消失和高亮闪光动画
    local function clickFinish(_refreshCallFunc)
        local seq = CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 1, 0), CCCallFunc:create(function()
            finishBg:removeFromParentAndCleanup(true)
            finishBg = nil
            upLightSp:removeFromParentAndCleanup(true)
            upLightSp = nil
            downLightSp:removeFromParentAndCleanup(true)
            downLightSp = nil
            leftLightSp:removeFromParentAndCleanup(true)
            leftLightSp = nil
            rightLightSp:removeFromParentAndCleanup(true)
            rightLightSp = nil
        end))
        finishBg:runAction(seq)
        
        local lightBg = CCSprite:createWithSpriteFrameName("ait_light_bg.png")
        lightBg:setScale(2)
        lightBg:setPosition(314, 838.5)
        G_setBlendFunc(lightBg, GL_ONE, GL_ONE)
        self.screenSp:addChild(lightBg, 3)
        lightBg:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.25, 0), CCCallFunc:create(function()
            upScanAction(_refreshCallFunc)
            lightBg:removeFromParentAndCleanup(true)
            lightBg = nil
        end)))
        self:playScanAction(true)
    end
    --点击屏幕任意区域完成生产
    local touchSp = self:setTouchEnabled(false, function()
        if not clickState then
            clickState = true
            _clickCallFunc(clickFinish)
        end
    end)
    --此处让屏蔽层下移是为了上边的点击事件出现网络故障时无法回调而导致的界面卡死，让其能够点击右上角的关闭按钮
    touchSp:setPositionY(touchSp:getPositionY() - 75)
    
    local particleSystem = CCParticleSystemQuad:create("public/aiTroopsImage/TK_lizi.plist")
    particleSystem:setScale(1)
    particleSystem:setPosition(finishBg:getContentSize().width / 2, finishBg:getContentSize().height / 2)
    particleSystem:setAutoRemoveOnFinish(true)
    finishBg:addChild(particleSystem)
    
    --FINISH
    local finishSp = CCSprite:createWithSpriteFrameName("ait_finish_down.png")
    local finishSp2 = CCSprite:createWithSpriteFrameName("ait_finish_up.png")
    finishSp2:setPosition(finishSp:getContentSize().width / 2, finishSp:getContentSize().height / 2)
    finishSp:addChild(finishSp2)
    finishSp:setPosition(finishBg:getContentSize().width / 2, finishBg:getContentSize().height / 2 + 20)
    finishBg:addChild(finishSp)
    local finishLb = GetTTFLabel(getlocal("aitroops_click_finish"), 25, true)
    finishLb:setAnchorPoint(ccp(0.5, 1))
    finishLb:setPosition(finishBg:getContentSize().width / 2, finishSp:getPositionY() - finishSp:getContentSize().height / 2 - 20)
    finishBg:addChild(finishLb)
    
    finishSp2:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 1.13), CCScaleTo:create(0.5, 1))))
end

function AITroopsProduce:tick()
    if self.slotId and self.produce then --有生产队列则刷新队列
        if self.produce.s == 1 then --生产被玩家打断
            self.produce = nil
            AITroopsVoApi:AITroopsGet(1, function()
                AITroopsVoApi:removeProduceQueue(self.slotId)
                self.slotId = nil
            end)
        else
            local tt = self.produce.et - self.produce.st --总时间
            local lt = self.produce.et - base.serverTime --剩余时间
            if lt > 0 then
                self.slotTimer:setPercentage(math.floor((tt - lt) / tt * 100))
                self.timerLb:setString(GetTimeStr(lt))
            else
                self.slotTimer:setPercentage(100)
                self.timerLb:setString(GetTimeStr(0))
                
                AITroopsVoApi:removeProduceQueue(self.slotId)
                self.slotId, self.produce = nil, nil
                --生产完成重新拉取系统数据
                -- local function handler()
                -- self:refresh()
                -- eventDispatcher:dispatchEvent("aitroops.list.refresh", {rtype = 1})
                -- end
                -- AITroopsVoApi:AITroopsGet(1, handler)
                
                self:produceFinishEffect(function(callback)
                    AITroopsVoApi:AITroopsGet(1, function(refreshCallFunc)
                        --此处的refreshCallFunc是为了让所有FINISH动作执行完毕后在刷新弹框
                        if callback then
                            callback(refreshCallFunc)
                        end
                    end)
                end)
            end
        end
    end
end

function AITroopsProduce:dispose()
    if self.produceRefreshListener then
        eventDispatcher:removeEventListener("aitroops.produce.refresh", self.produceRefreshListener)
        self.produceRefreshListener = nil
    end
    if self.overTodayListener then
        eventDispatcher:removeEventListener("aitroops.over.today", self.overTodayListener)
        self.overTodayListener = nil
    end
    self = nil
    spriteController:removePlist("public/aiTroopsImage/aitroops_images3.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_images3.png")
    spriteController:removePlist("public/aiTroopsImage/aitroops_effect3.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_effect3.png")
end
