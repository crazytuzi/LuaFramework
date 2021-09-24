localWarTroopsDialogTab1 = {}

function localWarTroopsDialogTab1:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.type = 18
    self.bgLayer = nil
    self.layerNum = nil
    self.parent = nil
    self.currentShow = 1
    self.currentFundsLb = nil
    self.timeLb = nil
    
    return nc
end

function localWarTroopsDialogTab1:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self:initTabLayer()
    return self.bgLayer
end

function localWarTroopsDialogTab1:initTabLayer()
    local function callback(flag)
        self.currentShow = flag + 1
    end
    
    self:updateData()
    G_addSelectTankLayer(self.type, self.bgLayer, self.layerNum, callback, true, nil, nil, true)
    
    self:initDesc()
    self:initRepair()
    self:tick()
end

function localWarTroopsDialogTab1:initDesc()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
    if G_isIphone5() == true then
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870 - 10 - 70))
    else
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870 - 10))
    end
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0.5, 0))
    descBg:setIsSallow(false)
    descBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    descBg:setPosition(ccp(G_VisibleSizeWidth / 2, 105 + 10))
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

function localWarTroopsDialogTab1:initRepair()
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
        
        local setFleetStatus, tipStr = localWarVoApi:getSetFleetStatus()
        if setFleetStatus ~= 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("tipStr"), 30)
            do return end
        end
        
        -- local function onConfirm()
        --     local selfPlayer=localWarFightVoApi:getPlayer()
        --     if selfPlayer then
        --         local reviveTime=selfPlayer.canMoveTime
        --         local costGems=(reviveTime - base.serverTime) + localWarCfg.reviveCost
        --         if(playerVoApi:getGems()<costGems)then
        --             local needGem=costGems - playerVoApi:getGems()
        --             GemsNotEnoughDialog(nil,nil,needGem,self.layerNum+1,costGems)
        --             do return end
        --         end
        --         local function reviveCallback()
        --             self:tick()
        --         end
        --         localWarFightVoApi:revive(reviveCallback)
        --     end
        -- end
        -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_reviveAndMove"),nil,self.layerNum+1)
        
        local selfPlayer = localWarFightVoApi:getPlayer()
        if selfPlayer then
            local reviveTime = selfPlayer.canMoveTime
            local function reviveCallback()
                self:tick()
            end
            localWarVoApi:showRepairDialog(reviveTime, self.layerNum + 1, reviveCallback)
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

function localWarTroopsDialogTab1:tick()
    if self then
        if self.repairBg then
            local selfPlayer = localWarFightVoApi:getPlayer()
            if selfPlayer then
                local reviveTime = selfPlayer.canMoveTime
                if base.serverTime < reviveTime then
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

function localWarTroopsDialogTab1:updateData()
    local isUseCurTroops = false
    local tanksTb = tankVoApi:getTanksTbByType(self.type)
    if localWarVoApi:checkStatus() == 21 and tanksTb and SizeOfTable(tanksTb) > 0 then
        for k, v in pairs(tanksTb) do
            if v and v[1] and v[2] and tonumber(v[2]) > 0 then
                isUseCurTroops = true
            end
        end
    end
    if isUseCurTroops == true then
    else
        tankVoApi:clearTanksTbByType(self.type)
        local tmpTanks = {{}, {}, {}, {}, {}, {}}
        tmpTanks = G_clone(tankVoApi:getTanksTbByType(17))
        for k, v in pairs(tmpTanks) do
            if v and v[1] and v[2] then
                tankVoApi:setTanksByType(self.type, k, v[1], v[2])
            else
                tankVoApi:deleteTanksTbByType(self.type, k)
            end
        end
        local hero = G_clone(heroVoApi:getLocalWarHeroList())
        heroVoApi:setLocalWarCurHeroList(hero)
        
        local aitroops = G_clone(AITroopsFleetVoApi:getLocalWarAITroopsList())
        AITroopsFleetVoApi:setLocalWarCurAITroopsList(aitroops)
        
        local emblemID = emblemVoApi:getBattleEquip(17)
        emblemVoApi:setBattleEquip(self.type, emblemID)
        local planePos = planeVoApi:getBattleEquip(17)
        planeVoApi:setBattleEquip(self.type, planePos)
        
        airShipVoApi:setBattleEquip(self.type, airShipVoApi:getBattleEquip(17))
        
        local tskin = G_clone(tankSkinVoApi:getTankSkinListByBattleType(17))
        tankSkinVoApi:setTankSkinListByBattleType(self.type, tskin)
    end
end

function localWarTroopsDialogTab1:refresh()
    if self and self.bgLayer then
        heroVoApi:clearTroops()
        self:updateData()
        G_updateSelectTankLayer(18, self.bgLayer, self.layerNum, self.currentShow)
    end
end

function localWarTroopsDialogTab1:dispose()
    self.bgLayer = nil
    self.currentShow = 1
    self.currentFundsLb = nil
    self.timeLb = nil
    heroVoApi:clearTroops()
    G_clearEditTroopsLayer(self.type)
end
