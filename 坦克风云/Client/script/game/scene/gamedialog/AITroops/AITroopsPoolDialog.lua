AITroopsPoolDialog = smallDialog:new()

function AITroopsPoolDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsPoolDialog:showPoolDialog(layerNum)
    local sd = AITroopsPoolDialog:new()
    sd:initPoolDialog(layerNum)
end

function AITroopsPoolDialog:initPoolDialog(layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local function close()
        return self:close()
    end
    local dialogBgWidth, dialogBgHeight = 500, 750
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("world_war_sub_title21"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local tvWidth, tvHeight = dialogBgWidth - 40, dialogBgHeight - 220
    
    contentBg:setContentSize(CCSizeMake(tvWidth + 6, tvHeight + 20))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 70)
    self.bgLayer:addChild(contentBg)
    
    local tvPosY = dialogBgHeight - 80 - tvHeight
    
    local aitroopsCfg = AITroopsVoApi:getModelCfg()
    local poolRewardCfg = aitroopsCfg.producePoolReward
    local pc = SizeOfTable(poolRewardCfg)
    
    local iconWidth, rowRewardNum, spaceX, spaceY = 80, 4, 20, 15
    local cellHeightTb = {}
    local poolTb = {}
    for k = 1, pc do
        local cfg = poolRewardCfg["pool"..k]
        local rewardList = FormatItem(cfg, nil, true)
        table.insert(poolTb, rewardList)
        local rowNum = math.ceil(SizeOfTable(rewardList) / rowRewardNum)
        cellHeightTb[k] = 40 + 20 + iconWidth * rowNum + (rowNum - 1) * spaceY
    end
    
    local isMoved = false
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return pc
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(tvWidth, cellHeightTb[idx + 1])
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local cellHeight = cellHeightTb[idx + 1]
            
            local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            lbBg:setAnchorPoint(ccp(0, 1))
            lbBg:setContentSize(CCSizeMake(tvWidth - 10, lbBg:getContentSize().height))
            lbBg:setPosition(10, cellHeight - 8)
            cell:addChild(lbBg)
            
            local lb = GetTTFLabel(getlocal("aitroops_troop" .. (idx + 1)), 22, true)
            lb:setAnchorPoint(ccp(0, 0.5))
            lb:setPosition(ccp(15, lbBg:getContentSize().height / 2))
            lb:setColor(G_ColorYellowPro)
            lbBg:addChild(lb)
            
            local posY = lbBg:getPositionY() - lbBg:getContentSize().height - 10
            
            local rewardList = poolTb[idx + 1]
            for k, v in pairs(rewardList) do
                local function showInfo()
                    if v.type == "at" and v.eType == "a" then
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                    else
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v)
                    end
                    return false
                end
                local icon = G_getItemIcon(v, 100, false, self.layerNum, showInfo)
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setScale(iconWidth / icon:getContentSize().width)
                icon:setPosition(ccp(40 + iconWidth / 2 + (iconWidth + spaceX) * ((k - 1) % rowRewardNum), posY - iconWidth / 2 - (iconWidth + spaceY) * math.floor((k - 1) / rowRewardNum)))
                cell:addChild(icon)
                --AI部队不显示个数
                if v.type == "at" and v.eType == "a" then
                    local levelLv = tolua.cast(icon:getChildByTag(101), "CCLabelTTF")
                    if levelLv then
                        levelLv:setScale(1 / icon:getScale())
                    end
                else
                    local numLb = GetTTFLabel(FormatNumber(v.num), 22)
                    numLb:setScale(1 / icon:getScale())
                    numLb:setAnchorPoint(ccp(1, 0))
                    numLb:setPosition(ccp(icon:getContentSize().width - 5, 5))
                    icon:addChild(numLb, 4)
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    numBg:setAnchorPoint(ccp(1, 0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
                    numBg:setPosition(ccp(icon:getContentSize().width - 5, 5))
                    numBg:setOpacity(150)
                    icon:addChild(numBg, 3)
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
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((dialogBgWidth - tvWidth) / 2, tvPosY))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 4
    local function confirm()
        close()
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2, 60), {getlocal("confirm"), 24}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", confirm, btnScale, priority)
    
    local strSize = 20
    local adaWidth = dialogBgWidth - 60
    if G_getCurChoseLanguage() == "ko" or  not G_isAsia() then
        strSize = 14
        adaWidth = dialogBgWidth - 30
    end

    local tipLb = GetTTFLabelWrap(getlocal("aitroops_produce_tip4"), strSize, CCSizeMake(dialogBgWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(dialogBgWidth / 2, self.tv:getPositionY() - 20)
    self.bgLayer:addChild(tipLb)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end
