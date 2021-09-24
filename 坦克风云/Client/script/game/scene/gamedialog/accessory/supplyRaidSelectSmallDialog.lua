--补给线选择扫荡关卡面板
supplyRaidSelectSmallDialog = smallDialog:new()

function supplyRaidSelectSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function supplyRaidSelectSmallDialog:showSelectWipeDialog(layerNum, confirmCallback)
    local sd = supplyRaidSelectSmallDialog:new()
    sd:initSelectWipeDialog(layerNum, confirmCallback)
end

function supplyRaidSelectSmallDialog:initSelectWipeDialog(layerNum, confirmCallback)
    self.layerNum = layerNum
    self.dialogBgWidth, self.dialogBgHeight = 550, 180
    local tvWidth, tvHeight = self.dialogBgWidth - 40, 420
    self.dialogBgHeight = self.dialogBgHeight + tvHeight
    local tipFontSize = 22
    local wipeLb = GetTTFLabelWrap(getlocal("supply_wipe_tip"), tipFontSize, CCSizeMake(self.dialogBgWidth - 40, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    wipeLb:setAnchorPoint(ccp(0, 1))
    -- wipeLb:setColor(G_ColorYellowPro)
    self.dialogBgHeight = self.dialogBgHeight + wipeLb:getContentSize().height + 20
    
    self.bgSize = CCSizeMake(self.dialogBgWidth, self.dialogBgHeight)
    local function nilFunc()
    end
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum, nil, getlocal("elite_challenge_raid_btn"), 28)
    self.bgLayer = dialogBg
    dialogBg:setContentSize(self.bgSize)
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer:setAnchorPoint(ccp(0, 1))
    self.bgLayer:setPosition((G_VisibleSizeWidth - self.bgSize.width) / 2, G_VisibleSizeHeight / 2 + self.bgSize.height / 2)
    self.dialogLayer:addChild(self.bgLayer, 2)
    self:show()
    
    self.bgLayer:addChild(wipeLb)
    wipeLb:setPosition(40, self.dialogBgHeight - 30)
    
    local allSelectSp, unAllSelectSp, cancelSelectSp, unCancelSelectSp
    local function refreshSelect()
        if self.snum >= self.rnum then --全选
            allSelectSp:setVisible(true)
            unAllSelectSp:setVisible(false)
            cancelSelectSp:setVisible(false)
            unCancelSelectSp:setVisible(true)
        elseif self.snum > 0 then --没有选中的
            allSelectSp:setVisible(false)
            unAllSelectSp:setVisible(true)
            cancelSelectSp:setVisible(false)
            unCancelSelectSp:setVisible(true)
        else
            allSelectSp:setVisible(false)
            unAllSelectSp:setVisible(true)
            cancelSelectSp:setVisible(true)
            unCancelSelectSp:setVisible(false)
        end
    end
    
    local lastRaidTb = accessoryVoApi:getLastSelectRaidList() or {}
    local lastRaidNum = SizeOfTable(lastRaidTb)
    local selectRaidTb = {}
    local ckWidth = 50
    local nameFontSize, nameWidth, descFontSize = 22, self.dialogBgWidth - 120, 20
    local raidTb = G_clone(accessoryVoApi:getLeft3Star()) --可扫荡的关卡
    table.sort(raidTb, function(a, b) return a > b end) --关卡倒序
    
    local function getRaidShowContent(ecid)
        local cfg = accessoryVoApi:getEChallengeCfg()
        local ecDetailCfg = accessoryVoApi:getECCfg()
        local ecCfg = ecDetailCfg["s"..ecid]
        
        local raidNameLb = GetTTFLabel(getlocal(ecCfg.name), nameFontSize, true)
        local dropStr, colorTb = accessoryVoApi:getEChallengeDropStr(ecid)
        local dropLb, lbheight = G_getRichTextLabel(getlocal("elite_challenge_dorp")..dropStr, colorTb, descFontSize, nameWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        
        return raidNameLb, dropLb, lbheight, colorTb
    end
    self.snum, self.rnum = 0, 0 --选中数量，总数量
    local minCellHeight = 80
    local cellHeightTb = {}
    for k, v in pairs(raidTb) do
        local raidNameLb, dropLb, lbheight, colorTb = getRaidShowContent(v)
        cellHeightTb[k] = raidNameLb:getContentSize().height + lbheight + 15
        if cellHeightTb[k] < minCellHeight then
            cellHeightTb[k] = minCellHeight
        end
        local ecidKey = "s"..v
        if selectRaidTb[ecidKey] == nil then
            if lastRaidNum == 0 then --默认是全选的
                selectRaidTb[ecidKey] = 1
            elseif lastRaidTb[ecidKey] == 1 then --如果最近扫荡有记录，则取记录
                selectRaidTb[ecidKey] = 1
            else
                selectRaidTb[ecidKey] = 0
            end
            if selectRaidTb[ecidKey] == 1 then
                self.snum = self.snum + 1
            end
        end
        self.rnum = self.rnum + 1
    end
    
    local rnum = SizeOfTable(raidTb)
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return self.rnum
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(tvWidth, cellHeightTb[idx + 1])
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local cellHeight = cellHeightTb[idx + 1]
            
            local ecid = raidTb[idx + 1]
            local ecidKey = "s"..ecid
            local raidSelectedSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
            raidSelectedSp:setAnchorPoint(ccp(0, 0.5))
            raidSelectedSp:setPosition(0, cellHeight / 2)
            raidSelectedSp:setScale(ckWidth / raidSelectedSp:getContentSize().width)
            cell:addChild(raidSelectedSp, 1)
            
            local function touch()
                if selectRaidTb[ecidKey] == 0 then
                    selectRaidTb[ecidKey] = 1
                    self.snum = self.snum + 1
                else
                    selectRaidTb[ecidKey] = 0
                    self.snum = self.snum - 1
                end
                if selectRaidTb[ecidKey] == 1 then --选中扫荡
                    raidSelectedSp:setVisible(true)
                else
                    raidSelectedSp:setVisible(false)
                end
                refreshSelect()
            end
            
            local unSelectedSp = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png", touch)
            unSelectedSp:setAnchorPoint(ccp(0, 0.5))
            unSelectedSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            unSelectedSp:setPosition(0, cellHeight / 2)
            unSelectedSp:setScale(ckWidth / unSelectedSp:getContentSize().width)
            cell:addChild(unSelectedSp)
            
            if selectRaidTb[ecidKey] == 1 then --选中扫荡
                raidSelectedSp:setVisible(true)
            else
                raidSelectedSp:setVisible(false)
            end
            
            local raidNameLb, dropLb, lbheight, colorTb = getRaidShowContent(ecid)
            raidNameLb:setColor(G_ColorGreen)
            raidNameLb:setAnchorPoint(ccp(0, 1))
            raidNameLb:setPosition(raidSelectedSp:getPositionX() + ckWidth + 10, cellHeight - 5)
            cell:addChild(raidNameLb)
            
            --扫荡关卡随机掉落显示
            dropLb:setAnchorPoint(ccp(0, 1))
            dropLb:setPosition(raidNameLb:getPositionX(), raidNameLb:getPositionY() - raidNameLb:getContentSize().height - 5)
            cell:addChild(dropLb)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((self.bgSize.width - tvWidth) / 2, wipeLb:getPositionY() - wipeLb:getContentSize().height - tvHeight - 20)
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(80)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(tvWidth + 10, tvHeight + 10))
    tvBg:setPosition(self.dialogBgWidth / 2, self.tv:getPositionY() - 5)
    self.bgLayer:addChild(tvBg)
    
    local leftPos, rightPos = ccp(20, 110), ccp(self.bgSize.width - 250, 110)
    local function refreshTv()
        if self.tv then --刷新列表
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end
    local function selectHandler()
        if self.snum >= self.rnum then
            do return end
        end
        for k, v in pairs(raidTb) do
            selectRaidTb["s"..v] = 1
        end
        self.snum = self.rnum
        refreshSelect()
        refreshTv()
    end
    
    allSelectSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    allSelectSp:setAnchorPoint(ccp(0, 0.5))
    allSelectSp:setPosition(leftPos)
    allSelectSp:setScale(ckWidth / allSelectSp:getContentSize().width)
    self.bgLayer:addChild(allSelectSp)
    
    unAllSelectSp = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png", selectHandler)
    unAllSelectSp:setAnchorPoint(ccp(0, 0.5))
    unAllSelectSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    unAllSelectSp:setPosition(leftPos)
    unAllSelectSp:setScale(ckWidth / unAllSelectSp:getContentSize().width)
    self.bgLayer:addChild(unAllSelectSp)
    
    local allSelectLb = GetTTFLabelWrap(getlocal("selectAll"), G_isAsia() and 20 or 17, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    allSelectLb:setAnchorPoint(ccp(0, 0.5))
    allSelectLb:setPosition(allSelectSp:getPositionX() + ckWidth + 5, leftPos.y)
    self.bgLayer:addChild(allSelectLb)
    
    --取消全选
    local function cancelSelectHandler()
        if self.snum == 0 then
            do return end
        end
        for k, v in pairs(raidTb) do
            selectRaidTb["s"..v] = 0
        end
        self.snum = 0
        refreshSelect()
        refreshTv()
    end
    
    cancelSelectSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    cancelSelectSp:setAnchorPoint(ccp(0, 0.5))
    cancelSelectSp:setPosition(rightPos)
    cancelSelectSp:setScale(ckWidth / cancelSelectSp:getContentSize().width)
    self.bgLayer:addChild(cancelSelectSp)
    
    unCancelSelectSp = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png", cancelSelectHandler)
    unCancelSelectSp:setAnchorPoint(ccp(0, 0.5))
    unCancelSelectSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    unCancelSelectSp:setPosition(rightPos)
    unCancelSelectSp:setScale(ckWidth / unCancelSelectSp:getContentSize().width)
    self.bgLayer:addChild(unCancelSelectSp)
    
    local cancelSelectLb = GetTTFLabelWrap(getlocal("cancel_selected"), G_isAsia() and 20 or 17, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    cancelSelectLb:setAnchorPoint(ccp(0, 0.5))
    cancelSelectLb:setPosition(cancelSelectSp:getPositionX() + ckWidth + 5, rightPos.y)
    self.bgLayer:addChild(cancelSelectLb)
    
    refreshSelect()
    
    local btnScale, priority = 0.7, -(self.layerNum - 1) * 20 - 4
    local function raid() --确定扫荡
        local function raidSuccessCallback() --扫荡成功回调
            accessoryVoApi:saveSelectRaidList(selectRaidTb) --保存扫荡的关卡
            self:close()
        end
        if confirmCallback then
            local eid = {} --当前选中扫荡的关卡id
            for k, v in pairs(selectRaidTb) do
                if v == 1 then
                    table.insert(eid, k)
                end
            end
            local enum = #eid
            if enum == 0 then
                G_ShowFloatingBoard(getlocal("supply_wipe_tip3"))
                do return end
            end
            local energy = playerVoApi:getEnergy()
            if energy < enum then
                local function buyEnergy()
                    G_buyEnergy(self.layerNum + 1)
                end
                -- smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyEnergy, getlocal("dialog_title_prompt"), getlocal("energyis0"), nil, self.layerNum + 1)
                smallDialog:showEnergySupplementDialog(self.layerNum+1)
                do return end
            end
            local function realRaid()
                confirmCallback(eid, raidSuccessCallback)
            end
            G_dailyConfirm("supply.eneryRaid", getlocal("supply_wipe_tip2", {enum, enum}), realRaid, self.layerNum + 1)
        end
    end
    local raidItem, raidMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + 140, 50), {getlocal("confirm"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", raid, btnScale, priority)
    
    local function cancel()
        self:close()
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - 140, 50), {getlocal("cancel"), 25}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn_Down.png", cancel, btnScale, priority)
    
    local function touchHandler()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchHandler)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    G_addForbidForSmallDialog2(self.bgLayer, tvBg, -(self.layerNum - 1) * 20 - 3, nil, 3)
    
    self.dialogLayer:setPosition(0, 0)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

