acZntpDialog = commonDialog:new()

function acZntpDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    return nc
end

function acZntpDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function acZntpDialog:initTableView()
    local topBg = CCSprite:create("public/acZntp_bg.jpg")
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 87)
    self.bgLayer:addChild(topBg)
    
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBg:getContentSize().height))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY())
    self.bgLayer:addChild(timeBg)
    local timeLb = GetTTFLabel(acZntpVoApi:getTimeStr(), 21)
    timeLb:setPosition(timeBg:getContentSize().width / 2 - 20, timeBg:getContentSize().height - 25)
    timeLb:setColor(G_ColorYellowPro)
    timeBg:addChild(timeLb)
    self.timeLb = timeLb
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("activity_zntp_tipsDesc1"), 
            getlocal("activity_zntp_tipsDesc2"), 
        }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(timeBg:getContentSize().width - 8 - infoBtn:getContentSize().width / 2, timeBg:getContentSize().height / 2))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    timeBg:addChild(infoMenu)
        
    local strSize = 23
    if G_isAsia() == false then
        strSize = 18
    end
    local descLabel = GetTTFLabelWrap(getlocal("activity_zntp_descText"), strSize, CCSizeMake(G_VisibleSizeWidth - 150, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    local descLbBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    descLbBg:setScaleX((descLabel:getContentSize().width + 100) / descLbBg:getContentSize().width)
    descLbBg:setScaleY(descLabel:getContentSize().height / descLbBg:getContentSize().height)
    descLbBg:setPosition(G_VisibleSizeWidth / 2, timeBg:getPositionY() - timeBg:getContentSize().height - 10 - (descLbBg:getContentSize().height * descLbBg:getScaleY() / 2))
    self.bgLayer:addChild(descLbBg)
    descLabel:setPosition(descLbBg:getPosition())
    self.bgLayer:addChild(descLabel)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 25, topBg:getPositionY() - topBg:getContentSize().height - 30))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height - 1)
    self.bgLayer:addChild(tableViewBg)
    
    self.taskList = acZntpVoApi:getTaskList()
    self.cellNum = SizeOfTable(self.taskList or {})
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setPosition(ccp(3, 3))
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.tv)
end

function acZntpDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 150)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvSize.width, 150
        
        local data = self.taskList[idx + 1]
        if data == nil then
            do return cell end
        end
        
        local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
        titleBg:setContentSize(CCSizeMake(cellW - 55, titleBg:getContentSize().height))
        titleBg:setAnchorPoint(ccp(0, 1))
        titleBg:setPosition(3, cellH - 10)
        cell:addChild(titleBg)
        
        local curNum = data.num
        local key = data.key
        key = (key == "gb") and "gba" or key
        if key == "ai" then
            if data.quality == 0 then
                curNum = getlocal("fleetInfoTitle2") .. curNum
            else
                curNum = getlocal("aitroops_troop" .. data.quality) .. curNum
            end
        end

        local strSize = 22
        if G_isAsia() == false then
            strSize = 16
        end
        local titleLb = GetTTFLabel(getlocal("activity_chunjiepansheng_" .. key .. "_title", {curNum, data.needNum}), strSize)
        titleLb:setAnchorPoint(ccp(0, 0.5))
        titleLb:setPosition(15, titleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        titleBg:addChild(titleLb)
        
        local rewardTb = FormatItem(data.reward, nil, true)
        if rewardTb then
            local iconSize = 85
            local itemPosY = (cellH - (titleBg:getContentSize().height + 10)) / 2
            for k, v in pairs(rewardTb) do
                local function showNewPropDialog()
                    if v.type == "at" and v.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                    else
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                    end
                end
                icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
                icon:setPosition(50 + icon:getContentSize().width * scale / 2 + (k - 1) * (30 + icon:getContentSize().width * scale), itemPosY)
                -- local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
                -- numLb:setAnchorPoint(ccp(1, 0))
                -- numLb:setPosition(ccp(icon:getContentSize().width - 10, 5))
                -- icon:addChild(numLb, 1)
                -- numLb:setScale(1 / scale)
                G_noVisibleInIcon(v,icon,101)
                cell:addChild(icon)
                local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                numBg:setAnchorPoint(ccp(0, 1))
                numBg:setRotation(180)
                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
                cell:addChild(numBg)
                numLb:setAnchorPoint(ccp(1, 0))
                numLb:setPosition(numBg:getPosition())
                cell:addChild(numLb)
            end
        end
        
        if data.state == 1 then
            local function awardHandler(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                acZntpVoApi:requestTaskReward(data.id, function()
                    local rewardTipTb = {}
                    local tipStr = ""
                    for k, v in pairs(rewardTb) do
                        local num = tonumber(v.num)
                        if v.type == "at" and v.eType == "a" then --AI部队
                            if AITroopsVoApi:isExist(v.key) == true then
                                local aiFragmentNum = AITroopsVoApi:getModelCfg().fragmentExchangeNum * num
                                local aiName = AITroopsVoApi:getAITroopsNameStr(v.key)
                                tipStr = tipStr .. getlocal("alreadyHasAITroopsTipDesc", { aiName, aiName, aiFragmentNum})
                            else
                                local temp = v
                                if num > 1 then
                                    local aiFragmentNum = AITroopsVoApi:getModelCfg().fragmentExchangeNum * (num - 1)
                                    local aiName = AITroopsVoApi:getAITroopsNameStr(v.key)
                                    tipStr = tipStr .. getlocal("alreadyHasAITroopsTipDesc", { aiName, aiName, aiFragmentNum})
                                    num = 1
                                    temp = G_clone(v)
                                    temp.num = num
                                end
                                table.insert(rewardTipTb, temp)
                            end
                        else
                            table.insert(rewardTipTb, v)
                        end
                        G_addPlayerAward(v.type, v.key, v.id, num, nil, true)
                    end
                    
                    if tipStr == "" then
                        tipStr = getlocal("receivereward_received_success")
                    end
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
                    G_showRewardTip(rewardTipTb, true)
                    self.taskList = acZntpVoApi:getTaskList()
                    self.cellNum = SizeOfTable(self.taskList or {})
                    if self.tv then
                        self.tv:reloadData()
                    end
                end)
            end
            local btnScale = 0.6
            local awardBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", awardHandler, 11, getlocal("daily_scene_get"), 24 / btnScale)
            awardBtn:setScale(btnScale)
            awardBtn:setAnchorPoint(ccp(1, 0.5))
            local menu = CCMenu:createWithItem(awardBtn)
            menu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
            menu:setPosition(ccp(cellW - 40, (cellH - (titleBg:getContentSize().height + 10)) / 2))
            cell:addChild(menu)
        else
            local stateLb = GetTTFLabel(getlocal("noReached"), 24)
            if data.state == 3 then
                stateLb:setString(getlocal("activity_hadReward"))
                stateLb:setColor(G_ColorGray)
            end
            stateLb:setAnchorPoint(ccp(1, 0.5))
            stateLb:setPosition(cellW - 65, (cellH - (titleBg:getContentSize().height + 10)) / 2)
            cell:addChild(stateLb)
        end
        
        if (idx + 1) < self.cellNum then
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

function acZntpDialog:tick()
    if self then
        local vo = acZntpVoApi:getAcVo()
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        elseif self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
            self.timeLb:setString(acZntpVoApi:getTimeStr())
        end
    end
end

function acZntpDialog:dispose()
    self = nil
end