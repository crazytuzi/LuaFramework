--统率升级页面
playerCommanderUpSmallDialog = smallDialog:new()

function playerCommanderUpSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function playerCommanderUpSmallDialog:showCommanderUpDialog(result, layerNum)
    local sd = playerCommanderUpSmallDialog:new()
    sd:initCommanderUpSmallDialog(result, layerNum)
    return sd
end

function playerCommanderUpSmallDialog:initCommanderUpSmallDialog(result, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    self.bgSize = CCSizeMake(550, 740)
    self.result = result
    self.tvNum = SizeOfTable(result)
    self.cellShowTb = {}
    self.cellHeightTb = {}
    self.actionFlag = true
    self.viewTotalHeight, self.viewShowHeight = 0, 0
    self.showSpeed = 0.3
    self.showTime = self.showSpeed
    self.showIdx = 0
    
    local function close()
        if self.actionFlag == true then
            do return end
        end
        self:close()
    end
    
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("fight_fail_tip_13"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    self.tvWidth, self.tvHeight = self.bgSize.width - 40, self.bgSize.height - 190
    
    local viewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function ()end)
    viewBg:setAnchorPoint(ccp(0.5, 0))
    viewBg:setContentSize(CCSizeMake(self.tvWidth, self.tvHeight + 10))
    self.bgLayer:addChild(viewBg)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((self.bgSize.width - self.tvWidth) / 2, 110)
    self.bgLayer:addChild(self.tv, 3)
    self.tv:setMaxDisToBottomOrTop(120)
    viewBg:setPosition(self.bgSize.width / 2, self.tv:getPositionY() - 5)
    
    local function confirmHandler()
        if self.actionFlag == true then
            self:endShowUpgradeView()
        else
            close()
        end
    end
    self.confirmBtn = G_createBotton(self.bgLayer, ccp(self.bgSize.width * 0.5, 55), {getlocal("gemCompleted")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", confirmHandler, 0.7, -(self.layerNum - 1) * 20 - 4)
    
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
    
    base:addNeedRefresh(self)
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function playerCommanderUpSmallDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.tvNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellHeight = self:getCellHeight(idx + 1)
        local viewNode = CCNode:create()
        viewNode:setContentSize(CCSizeMake(self.tvWidth, cellHeight))
        viewNode:setAnchorPoint(ccp(0.5, 0.5))
        viewNode:setPosition(self.tvWidth / 2, cellHeight / 2)
        cell:addChild(viewNode)
        
        local leftPosX = 10
        local commanderUpResult = self.result[idx + 1]
        local status, commanderLv = commanderUpResult[1], commanderUpResult[2] --升级状态，统率等级
        local lbTb, upgradeNumLbWidth = self:createCommanderUpView(idx + 1)
        if tonumber(status) == 2 then
            local reachTopLb = lbTb.reachTopLb
            if reachTopLb then
                reachTopLb:setAnchorPoint(ccp(0, 0.5))
                reachTopLb:setPosition(leftPosX, cellHeight / 2)
                reachTopLb:setColor(G_ColorYellowPro)
                viewNode:addChild(reachTopLb)
            end
        else
            local upgradeNumLb, resultLb, troopsNumLb, rateLb = lbTb.upgradeNumLb, lbTb.resultLb, lbTb.troopsNumLb, lbTb.successRateLb
            --升级次数
            upgradeNumLb:setAnchorPoint(ccp(0, 0.5))
            upgradeNumLb:setPosition(leftPosX, cellHeight - upgradeNumLb:getContentSize().height / 2 - 10)
            viewNode:addChild(upgradeNumLb)
            
            resultLb:setAnchorPoint(ccp(0, 0.5))
            resultLb:setPosition(leftPosX + upgradeNumLbWidth + 10, cellHeight - resultLb:getContentSize().height / 2 - 10)
            viewNode:addChild(resultLb)
            local maxHeight = upgradeNumLb:getContentSize().height
            if maxHeight < resultLb:getContentSize().height then
                maxHeight = resultLb:getContentSize().height
            end
            if tonumber(status) == 0 then --升级失败
                resultLb:setColor(G_ColorRed)
            elseif tonumber(status) == 1 then --升级成功
                resultLb:setColor(G_ColorGreen)
            end
            local posY = 0
            if troopsNumLb then
                posY = cellHeight - maxHeight - troopsNumLb:getContentSize().height / 2 - 20
                troopsNumLb:setAnchorPoint(ccp(0, 0.5))
                troopsNumLb:setPosition(leftPosX, posY)
                troopsNumLb:setColor(G_ColorGreen)
                viewNode:addChild(troopsNumLb)
                posY = posY - troopsNumLb:getContentSize().height / 2
            end
            if rateLb then
                posY = cellHeight - maxHeight - rateLb:getContentSize().height / 2 - 20
                rateLb:setAnchorPoint(ccp(0, 0.5))
                rateLb:setPosition(leftPosX, posY)
                rateLb:setColor(G_ColorRed)
                viewNode:addChild(rateLb)
                posY = posY - rateLb:getContentSize().height / 2
            end
            --多重好礼庆元旦活动额外奖励统率书显示
            if lbTb.commanderBookLb then
                local commanderBookLb = lbTb.commanderBookLb
                commanderBookLb:setAnchorPoint(ccp(0, 0.5))
                commanderBookLb:setPosition(leftPosX, posY - commanderBookLb:getContentSize().height / 2 - 10)
                commanderBookLb:setColor(G_ColorYellowPro)
                viewNode:addChild(commanderBookLb)
            end
        end
        
        if (idx + 1) ~= self.tvNum then
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
            lineSp:setContentSize(CCSizeMake(self.tvWidth - 20, 2))
            lineSp:setPosition(self.tvWidth / 2, 0)
            viewNode:addChild(lineSp, 2)
        end
        
        viewNode:setVisible(false)
        self.cellShowTb[idx + 1] = viewNode
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function playerCommanderUpSmallDialog:createCommanderUpView(idx)
    local fontSize, smallFontSize = 24, 22
    local lbTb = {}
    local upgradeNumLbWidth = 0
    local commanderUpResult = self.result[idx]
    local status, commanderLv = commanderUpResult[1], commanderUpResult[2] --升级状态，统率等级
    if tonumber(status) == 2 then --统率等级提升已达上限
        local limitLb = GetTTFLabelWrap(getlocal("upgrade_command_reachTop"), fontSize, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        lbTb.reachTopLb = limitLb
    else
        local upgradeNumLb = GetTTFLabelWrap(getlocal("upgrade_command_upgradeNum", {idx}), fontSize, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        lbTb.upgradeNumLb = upgradeNumLb
        local tmpLb = GetTTFLabel(getlocal("upgrade_command_upgradeNum", {idx}), fontSize)
        local realW = tmpLb:getContentSize().width
        if realW > upgradeNumLb:getContentSize().width then
            realW = upgradeNumLb:getContentSize().width
        else
            if G_getCurChoseLanguage() == "ar" then
                realW = upgradeNumLb:getContentSize().width
            end
        end
        upgradeNumLbWidth = realW
        if tonumber(status) == 1 then --升级成功
            local upgradeSuccessLb = GetTTFLabelWrap(getlocal("upgrade_command_upSuccess", {commanderLv}), fontSize, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbTb.resultLb = upgradeSuccessLb
            --带兵量
            local troopsNum = playerVoApi:getTroopsNumByCommanderLv(commanderLv)
            local troopsNumLb = GetTTFLabelWrap(getlocal("player_leader_troop_num", {" +"..troopsNum}), smallFontSize, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbTb.troopsNumLb = troopsNumLb
            --多重好礼庆元旦活动额外获得统率书
            local newyearVoApi = activityVoApi:getVoApiByType("newyeargift")
            if newyearVoApi then
                local openAc, bookNum = newyearVoApi:getTroopsConfig()
                if openAc == true then
                    --统率书
                    local commanderBookStr = getlocal("activity_newyeargift_troopstip", {getlocal("activity_newyeargift_title"), bookNum})
                    local commanderBookLb = GetTTFLabelWrap(commanderBookStr, smallFontSize, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    lbTb.commanderBookLb = commanderBookLb
                end
            end
        elseif tonumber(status) == 0 then --升级失败
            local upgradeFailLb = GetTTFLabelWrap(getlocal("fight_content_result_defeat"), fontSize, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbTb.resultLb = upgradeFailLb
            --升级成功概率
            local rate = playerVoApi:getTroopsTotalSuccess()
            local rateStr = getlocal("tip_succeedRate", {rate})
            local successRateLb = GetTTFLabelWrap(rateStr, smallFontSize, CCSizeMake(self.tvWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            lbTb.successRateLb = successRateLb
        end
    end
    return lbTb, upgradeNumLbWidth
end

function playerCommanderUpSmallDialog:getCellHeight(idx)
    if self.cellHeightTb[idx] == nil then
        local height = 20
        local lbTb = self:createCommanderUpView(idx)
        local commanderUpResult = self.result[idx]
        local status, commanderLv = commanderUpResult[1], commanderUpResult[2] --升级状态，统率等级
        if tonumber(status) == 2 then --统率等级提升已达上限
            if lbTb.reachTopLb then
                height = height + lbTb.reachTopLb:getContentSize().height
            end
        else
            local maxHeight = 0
            if lbTb.upgradeNumLb then
                maxHeight = lbTb.upgradeNumLb:getContentSize().height
            end
            if lbTb.resultLb then
                if lbTb.resultLb:getContentSize().height > maxHeight then
                    maxHeight = lbTb.resultLb:getContentSize().height
                end
            end
            if tonumber(status) == 1 then --升级成功
                --带兵量
                if lbTb.troopsNumLb then
                    height = height + lbTb.troopsNumLb:getContentSize().height
                end
                if lbTb.commanderBookLb then
                    height = height + lbTb.commanderBookLb:getContentSize().height + 10
                end
            elseif tonumber(status) == 0 then --升级失败
                --升级成功概率
                if lbTb.successRateLb then
                    height = height + lbTb.successRateLb:getContentSize().height
                end
            end
            height = height + maxHeight + 10
        end
        self.cellHeightTb[idx] = height
        self.viewTotalHeight = self.viewTotalHeight + height
    end
    return self.cellHeightTb[idx]
end

function playerCommanderUpSmallDialog:showCommanderUpgradeView(viewIdx)
    if self.cellShowTb and self.cellShowTb[viewIdx] then
        local viewNode = tolua.cast(self.cellShowTb[viewIdx], "CCNode")
        if viewNode then
            viewNode:setVisible(true)
        end
    end
end

function playerCommanderUpSmallDialog:checkScrollEnd()
    local tvPoint = self.tv:getRecordPoint()
    if self.viewTotalHeight <= self.tvHeight then
        if self.showIdx >= self.tvNum then
            self:endShowUpgradeView()
            return true
        end
    else
        if tvPoint.y > 0 then
            tvPoint.y = 0
            self:endShowUpgradeView()
            return true
        end
    end
    return false
end

function playerCommanderUpSmallDialog:fastTick(dt)
    if self.actionFlag == true then
        if self.tv == nil or tolua.cast(self.tv, "LuaCCTableView") == nil then
            do return end
        end
        if self:checkScrollEnd() == true then
            do return end
        end
        local scrollSpeed = 120 --1秒钟100像素
        local tvPoint = self.tv:getRecordPoint()
        if self.viewShowHeight >= self.tvHeight then
            tvPoint.y = tvPoint.y + scrollSpeed * dt
            if self:checkScrollEnd() == true then
                do return end
            end
            if tvPoint.y >= self.viewShowHeight - self.viewTotalHeight + self:getCellHeight(self.showIdx) / 2 and self.showIdx < self.tvNum then
                self.showIdx = self.showIdx + 1
                self:showCommanderUpgradeView(self.showIdx)
                self.viewShowHeight = self.viewShowHeight + self:getCellHeight(self.showIdx)
            end
        else
            self.showTime = self.showTime + dt
            if self.showTime >= self.showSpeed and self.showIdx < self.tvNum then
                self.showTime = self.showTime - self.showSpeed
                self.showIdx = self.showIdx + 1
                self:showCommanderUpgradeView(self.showIdx)
                self.viewShowHeight = self.viewShowHeight + self:getCellHeight(self.showIdx)
            end
        end
        self.tv:recoverToRecordPoint(tvPoint)
    end
end

function playerCommanderUpSmallDialog:endShowUpgradeView()
    self.actionFlag = false
    if self.tv then
        if self.viewTotalHeight > self.tvHeight then
            local recordPoint = self.tv:getRecordPoint()
            recordPoint.y = 0
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end
    for k = self.showIdx, self.tvNum do
        self:showCommanderUpgradeView(k)
    end
    if self.confirmBtn then
        local confirmBtnLb = tolua.cast(self.confirmBtn:getChildByTag(101), "CCLabelTTF")
        if confirmBtnLb then
            confirmBtnLb:setString(getlocal("confirm"))
        end
    end
end
