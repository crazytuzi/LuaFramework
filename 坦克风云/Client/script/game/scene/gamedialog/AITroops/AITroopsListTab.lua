AITroopsListTab = {}

function AITroopsListTab:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsListTab:init(layerNum, parent)
    self.layerNum, self.parent = layerNum, parent
    
    self.troopsIconList = {}
    self.bgLayer = CCLayer:create()
    
    self:updateList() --同步部队列表
    
    self.tvWidth, self.tvHeight = G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 200
    self.cellHeight = 300
    local function callBack(...)
        return self:eventHandler(...)
    end
    
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, G_VisibleSizeHeight - self.tvHeight - 170)
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv)

    --添加上、下的触摸屏蔽层 start
    local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
    top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - (self.tv:getPositionY() + self.tvHeight)))
    top:setAnchorPoint(ccp(0.5, 0))
    top:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() + self.tvHeight)
    self.bgLayer:addChild(top)
    top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    top:setVisible(false)

    local bottom = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
    bottom:setContentSize(CCSizeMake(G_VisibleSizeWidth, self.tv:getPositionY()))
    bottom:setAnchorPoint(ccp(0.5, 1))
    bottom:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY())
    self.bgLayer:addChild(bottom)
    bottom:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    bottom:setVisible(false)
    --添加上、下的触摸屏蔽层 end
    
    local noTroopsLb = GetTTFLabelWrap(getlocal("aitroops_no_troops"), 24, CCSize(G_VisibleSizeWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    noTroopsLb:setColor(G_ColorGray2)
    noTroopsLb:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() + self.tvHeight / 2)
    self.bgLayer:addChild(noTroopsLb)
    self.noTroopsLb = noTroopsLb
    
    if self.cellNum > 0 then
        self.noTroopsLb:setVisible(false)
    end
    
    local function listRefrsh(event, data)
        if data == nil then
            do return end
        end
        local flag = AITroopsVoApi:getListRefreshFlag()
        if flag == true then
            do return end
        end
        self:updateList()
        if data.rtype == 1 then
            if self.tv then
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        elseif data.rtype == 2 then --刷新ai部队的状态
            if self.troopsIconList and self.troopsList then
                for k, v in pairs(self.troopsIconList) do
                    local troopsVo = self.troopsList[k]
                    self:refreshAITroopsState(v, troopsVo)
                end
            end
        end
        local atid = data.atid
        if atid then --刷新指定部队的显示
            if self.troopsIconList and self.troopsIconList[atid] then
                local troopsIcon = self.troopsIconList[atid]
                local troopsVo = self.troopsList[atid]
                local levelLb = tolua.cast(troopsIcon:getChildByTag(102), "CCLabelTTF")
                local strengthLb = tolua.cast(troopsIcon:getChildByTag(103), "CCLabelTTF")
                if levelLb and strengthLb then
                    levelLb:setString(getlocal("fightLevel", {troopsVo.lv}))
                    local strength = troopsVo:getTroopsStrength()
                    strengthLb:setString(getlocal("emblem_infoStrong", {strength}))
                end
                self:refreshAITroopsState(troopsIcon, troopsVo)
                if data.isAdvanced == 1 then
                    local aiTroopsCfg = AITroopsVoApi:getModelCfg()
                    local acfg = aiTroopsCfg.aitroopType[atid]
                    AITroopsVoApi:setAITroopsIconEffect(troopsIcon:getChildByTag(101), AITroopsVoApi:getAITroopsPic(atid), 2, acfg.quality, troopsVo.grade)
                end
            end
        end
    end
    self.listRefrshListener = listRefrsh
    eventDispatcher:addEventListener("aitroops.list.refresh", listRefrsh)
    
    return self.bgLayer
end

function AITroopsListTab:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local startIndex = idx * 3
        local bgWidth = self.tvWidth / 3
        for k = 1, 3 do
            local atid = self.troopsIds[startIndex + k]
            local troopsVo = self.troopsList[atid]
            if(troopsVo)then
                local troopsIcon
                local function showInfo()
                    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        local function realShow()
                            AITroopsVoApi:showTroopsDetailDialog(troopsVo, self.layerNum + 1)
                        end
                        if troopsIcon then
                            G_touchedItem(troopsIcon, realShow)
                        end
                    end
                end
                troopsIcon = AITroopsVoApi:getAITroopsIcon(atid, nil, showInfo)
                troopsIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                troopsIcon:setPosition(ccp(bgWidth / 2 + (k - 1) * bgWidth, self.cellHeight - troopsIcon:getContentSize().height / 2 - 8))
                cell:addChild(troopsIcon)
                local battleFlag = AITroopsFleetVoApi:getIsBattled(atid)
                if battleFlag == true then
                    local lbBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    lbBg:setContentSize(CCSizeMake(troopsIcon:getContentSize().width - 6, 55))
                    lbBg:setOpacity(255 * 0.5)
                    lbBg:setPosition(getCenterPoint(troopsIcon))
                    troopsIcon:addChild(lbBg, 5)
                    local lb = GetTTFLabel(getlocal("emblem_battle"), 20)
                    lb:setColor(G_ColorYellowPro)
                    lb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(lb)
                end
                self.troopsIconList[atid] = troopsIcon
                
                self:refreshAITroopsState(troopsIcon, troopsVo)
            end
        end
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function AITroopsListTab:refreshAITroopsState(troopsIcon, troopsVo)
    if troopsIcon and troopsVo then
        local tipTag = 999
        local tipSp = tolua.cast(troopsIcon:getChildByTag(tipTag), "CCSprite")
        if AITroopsVoApi:isAITroopsCanUpgrade(troopsVo) == 1 or AITroopsVoApi:isAITroopsCanAdvance(troopsVo) == 1 then
            if tipSp then
                tipSp:setVisible(true)
            else
                tipSp = CCSprite:createWithSpriteFrameName("ait_upgrade.png")
                tipSp:setPosition(troopsIcon:getContentSize().width - 10, troopsIcon:getContentSize().height - 10)
                tipSp:setTag(tipTag)
                troopsIcon:addChild(tipSp, 2)
            end
        else
            if tipSp then
                tipSp:removeFromParentAndCleanup(true)
                tipSp = nil
            end
        end
    end
end

function AITroopsListTab:updateList()
    self.troopsList = AITroopsVoApi:getTroopsList()
    self.troopsIds = AITroopsVoApi:getTroopsIds()
    self.cellNum = math.ceil(SizeOfTable(self.troopsIds) / 3)
    if self.noTroopsLb then
        if self.cellNum > 0 then
            self.noTroopsLb:setVisible(false)
        else
            self.noTroopsLb:setVisible(true)
        end
    end
end

function AITroopsListTab:updateUI()
    if AITroopsVoApi:getListRefreshFlag() == true then
        self:updateList()
        if self.tv then
            if self.tv then
                -- local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                -- self.tv:recoverToRecordPoint(recordPoint)
            end
        end
        AITroopsVoApi:setListRefreshFlag(false)
    end
end

function AITroopsListTab:tick()
    
end

function AITroopsListTab:dispose()
    if self.listRefrshListener then
        eventDispatcher:removeEventListener("aitroops.list.refresh", self.listRefrshListener)
        self.listRefrshListener = nil
    end
    self.cellNum = nil
    self.troopsIconList = nil
    self.noTroopsLb = nil
end
