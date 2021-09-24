serverWarLocalTroopsSubTab12 = {}

function serverWarLocalTroopsSubTab12:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.selectedTabIndex = 1
    self.type = 27
    self.bgLayer = nil
    self.layerNum = nil
    self.parent = nil
    self.currentShow = {1, 1, 1}
    -- self.currentFundsLb=nil
    self.timeLb = nil
    
    return nc
end

function serverWarLocalTroopsSubTab12:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self:initTabLayer()
    return self.bgLayer
end

function serverWarLocalTroopsSubTab12:initTabLayer()
    local type = self.type + self.selectedTabIndex
    local function callback(flag)
        self.currentShow[self.selectedTabIndex + 1] = flag + 1
    end
    self:updateData()
    G_addSelectTankLayer(type, self.bgLayer, self.layerNum, callback, true, nil, nil, true)
    
    self:initDesc()
    self:initRepair()
    self:tick()
end

function serverWarLocalTroopsSubTab12:initDesc()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png", capInSet, cellClick)
    if G_isIphone5() == true then
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870 - 140))
        descBg:setPosition(ccp(G_VisibleSizeWidth / 2, 125))
    else
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870 - 40))
        descBg:setPosition(ccp(G_VisibleSizeWidth / 2, 125 - 15))
    end
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0.5, 0))
    descBg:setIsSallow(false)
    descBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(descBg, 3)
    
    local content = {getlocal("local_war_troops_preset_desc1"), getlocal("local_war_troops_preset_desc2")}
    local color = {G_ColorWhite, G_ColorYellowPro}
    local tabelLb = G_LabelTableView(CCSizeMake(descBg:getContentSize().width - 10, descBg:getContentSize().height - 10), content, 22, kCCTextAlignmentLeft, color)
    tabelLb:setPosition(ccp(5, 5))
    tabelLb:setAnchorPoint(ccp(0, 0))
    tabelLb:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    tabelLb:setMaxDisToBottomOrTop(70)
    descBg:addChild(tabelLb, 5)
end

function serverWarLocalTroopsSubTab12:initRepair()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    self.repairBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
    self.repairBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 90))
    self.repairBg:ignoreAnchorPointForPosition(false)
    self.repairBg:setAnchorPoint(ccp(0.5, 0))
    self.repairBg:setIsSallow(false)
    self.repairBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.repairBg:setPosition(ccp(G_VisibleSizeWidth / 2, 20))
    self.bgLayer:addChild(self.repairBg, 3)
    self.repairBg:setPosition(ccp(10000, 20))
    
    local icon = CCSprite:createWithSpriteFrameName("buildingIcon.png")
    icon:setPosition(ccp(icon:getContentSize().width / 2 + 20, self.repairBg:getContentSize().height / 2))
    self.repairBg:addChild(icon, 2)
    local repairLb = GetTTFLabelWrap(getlocal("local_war_troops_repair"), 22, CCSizeMake(260, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    -- local repairLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",22,CCSizeMake(260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    repairLb:setAnchorPoint(ccp(0, 0.5))
    repairLb:setPosition(ccp(icon:getContentSize().width + 30, self.repairBg:getContentSize().height / 2 + 15))
    self.repairBg:addChild(repairLb, 2)
    local timeStr = GetTimeStr(0)
    self.timeLb = GetTTFLabel(timeStr, 22)
    self.timeLb:setAnchorPoint(ccp(0, 0.5))
    self.timeLb:setPosition(ccp(icon:getContentSize().width + 30, self.repairBg:getContentSize().height / 2 - 15))
    self.repairBg:addChild(self.timeLb, 2)
    self.timeLb:setColor(G_ColorYellowPro)
    
    local function repairHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local setFleetStatus, tipStr = serverWarLocalVoApi:getSetFleetStatus()
        if setFleetStatus ~= 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
            do return end
        end
        
        -- local selfPlayer=serverWarLocalFightVoApi:getPlayer()
        --     if selfPlayer then
        local selfTroops = serverWarLocalFightVoApi:getSelfTroops()
        if selfTroops and selfTroops[self.selectedTabIndex + 1] and selfTroops[self.selectedTabIndex + 1].canMoveTime then
            local reviveTime = selfTroops[self.selectedTabIndex + 1].canMoveTime
            local function reviveCallback()
                self:tick()
            end
            local troopID = self.selectedTabIndex + 1
            serverWarLocalFightVoApi:showRepairDialog(troopID, reviveTime, self.layerNum + 1, reviveCallback)
        end
    end
    local scale = 0.8
    local repairBtn = GetButtonItem("BtnRecharge.png", "BtnRecharge_Down.png", "BtnRecharge_Down.png", repairHandler, nil, getlocal("local_war_troops_quick_repair"), 25)
    repairBtn:setScale(scale)
    local repairMenu = CCMenu:createWithItem(repairBtn)
    repairMenu:setPosition(ccp(self.repairBg:getContentSize().width - repairBtn:getContentSize().width / 2 * scale - 20, self.repairBg:getContentSize().height / 2))
    repairMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.repairBg:addChild(repairMenu, 3)
end

function serverWarLocalTroopsSubTab12:tick()
    if self then
        if self.repairBg then
            -- local selfPlayer=serverWarLocalFightVoApi:getPlayer()
            -- if selfPlayer then
            --     local reviveTime=selfPlayer.canMoveTime
            local selfTroops = serverWarLocalFightVoApi:getSelfTroops()
            if selfTroops and selfTroops[self.selectedTabIndex + 1] and selfTroops[self.selectedTabIndex + 1].canMoveTime then
                local reviveTime = selfTroops[self.selectedTabIndex + 1].canMoveTime
                if reviveTime and base.serverTime < reviveTime then
                    self.repairBg:setPosition(ccp(G_VisibleSizeWidth / 2, 20))
                    if self.timeLb then
                        local timeStr = GetTimeStr(reviveTime - base.serverTime)
                        self.timeLb:setString(timeStr)
                    end
                else
                    self.repairBg:setPosition(ccp(10000, 20))
                end
            else
                self.repairBg:setPosition(ccp(10000, 20))
            end
        end
    end
end

function serverWarLocalTroopsSubTab12:updateData()
    local checkStatus = serverWarLocalVoApi:checkStatus()
    local isUseCurTroops = false
    local btype = self.type + self.selectedTabIndex
    local tanksTb = tankVoApi:getTanksTbByType(btype)
    if checkStatus == 21 and tanksTb and SizeOfTable(tanksTb) > 0 then
        for k, v in pairs(tanksTb) do
            if v and v[1] and v[2] and tonumber(v[2]) > 0 then
                isUseCurTroops = true
            end
        end
    end
    if isUseCurTroops == true then
    else
        tankVoApi:clearTanksTbByType(btype)
        local tmpTanks = {{}, {}, {}, {}, {}, {}}
        tmpTanks = G_clone(tankVoApi:getTanksTbByType(btype - 3))
        for k, v in pairs(tmpTanks) do
            if v and v[1] and v[2] then
                tankVoApi:setTanksByType(btype, k, v[1], v[2])
            else
                tankVoApi:deleteTanksTbByType(btype, k)
            end
        end
        local tskin = G_clone(tankSkinVoApi:getTankSkinListByBattleType(btype - 3))
        tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
    end
    
    heroVoApi:clearTroops()
    local isUseCurHero = false
    local heroTb = heroVoApi:getServerWarLocalCurHeroList(self.selectedTabIndex + 1)
    if checkStatus == 21 and heroTb and SizeOfTable(heroTb) > 0 then
        -- for k,v in pairs(heroTb) do
        --     if v and tostring(v)~="0" then
        isUseCurHero = true
        --     end
        -- end
    end
    if isUseCurHero == true then
    else
        heroVoApi:deleteServerWarLocalCurTroopsByIndex(self.selectedTabIndex + 1)
        local tmpHero = G_clone(heroVoApi:getServerWarLocalHeroList(self.selectedTabIndex + 1))
        heroVoApi:setServerWarLocalCurHeroList(self.selectedTabIndex + 1, tmpHero)
    end
    
    --AI部队
    AITroopsFleetVoApi:clearAITroops()
    local isUseCurAITroops = false
    local aitroops = AITroopsFleetVoApi:getServerWarLocalCurAITroopsList(self.selectedTabIndex + 1)
    if checkStatus == 21 and aitroops and SizeOfTable(aitroops) > 0 then
        isUseCurAITroops = true
    end
    if isUseCurAITroops == true then
    else
        AITroopsFleetVoApi:deleteServerWarLocalCurAITroopsByIndex(self.selectedTabIndex + 1)
        local aitroops = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(self.selectedTabIndex + 1))
        AITroopsFleetVoApi:setServerWarLocalCurAITroopsList(self.selectedTabIndex + 1, aitroops)
    end
    
    local isUseCurEmblem = false
    local emblemId = emblemVoApi:getBattleEquip(btype)
    if checkStatus == 21 then
        isUseCurEmblem = true
    end
    if isUseCurEmblem == true then
    else
        local emblemId = emblemVoApi:getBattleEquip(btype - 3)
        emblemVoApi:setBattleEquip(btype, emblemId)
        local planePos = planeVoApi:getBattleEquip(btype - 3)
        planeVoApi:setBattleEquip(btype, planePos)
        local airshipId = airShipVoApi:getBattleEquip(btype - 3)
        airShipVoApi:setBattleEquip(btype, airshipId)
    end
end

function serverWarLocalTroopsSubTab12:refresh()
    if self and self.bgLayer then
        heroVoApi:clearTroops()
        AITroopsFleetVoApi:clearAITroops()
        self:updateData()
        local type = self.type + self.selectedTabIndex
        G_updateSelectTankLayer(type, self.bgLayer, self.layerNum, self.currentShow[self.selectedTabIndex + 1])
    end
end

function serverWarLocalTroopsSubTab12:dispose()
    self.selectedTabIndex = 1
    self.type = 27
    self.bgLayer = nil
    self.currentShow = {1, 1, 1}
    -- self.currentFundsLb=nil
    self.timeLb = nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    G_clearEditTroopsLayer(self.type)
end
