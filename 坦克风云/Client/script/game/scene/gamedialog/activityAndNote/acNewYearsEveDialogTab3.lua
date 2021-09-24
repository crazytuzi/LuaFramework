acNewYearsEveDialogTab3 = {}

function acNewYearsEveDialogTab3:new(...)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.parent = nil
    self.troopsType = 30
    self.attackTanks = {{}, {}, {}, {}, {}, {}}
    self.attackHeros = {0, 0, 0, 0, 0, 0}
    self.attackAITroops = {0, 0, 0, 0, 0, 0}
    self.attackEmblem = nil
    self.attackPlane = nil
    self.isShowTank = 1
    self.atkAirship = nil
    return nc
end

function acNewYearsEveDialogTab3:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self:updateData()
    self:initTableView()
    return self.bgLayer
end

function acNewYearsEveDialogTab3:initTableView()
    self.attackTanks = G_clone(tankVoApi:getTanksTbByType(self.troopsType))
    self.attackHeros = G_clone(heroVoApi:getNewYearBossHeroList())
    self.attackAITroops = G_clone(AITroopsFleetVoApi:getNewYearBossAITroopsList())
    self.attackEmblem = emblemVoApi:getBattleEquip(self.troopsType)
    self.attackPlane = planeVoApi:getBattleEquip(self.troopsType)
    self.atkAirship = airShipVoApi:getBattleEquip(self.troopsType)
    
    local function changeHandler(flag)
        self.isShowTank = flag + 1
    end
    G_addSelectTankLayer(self.troopsType, self.bgLayer, self.layerNum, changeHandler)
    
    local function save()
        self:saveHandler()
    end
    local savetem = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", save, nil, getlocal("arena_save"), 25)
    local saveMenu = CCMenu:createWithItem(savetem);
    saveMenu:setPosition(ccp(G_VisibleSize.width - 160, 80))
    saveMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4));
    self.bgLayer:addChild(saveMenu)
end

function acNewYearsEveDialogTab3:saveHandler(callback)
    local tanks = tankVoApi:getTanksTbByType(self.troopsType)
    local isEableAttack = true
    local num = 0;
    for k, v in pairs(tanks) do
        if SizeOfTable(v) == 0 then
            num = num + 1;
        end
    end
    if num == 6 then
        isEableAttack = false
    end
    if isEableAttack == false then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("arena_noTroops"), nil, self.layerNum + 1, nil)
        do return end
    end
    
    if self:judgeFight(callback) then
        do
            return
        end
    end
    local tankTb = tankVoApi:getTanksTbByType(self.troopsType)
    local hTb = {0, 0, 0, 0, 0, 0}
    if heroVoApi:isHaveTroops() then
        hTb = heroVoApi:getMachiningHeroList(tankTb)
    end
    local aitroops = {0, 0, 0, 0, 0, 0}
    if AITroopsFleetVoApi:isHaveAITroops() then
        aitroops = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
    end
    local tanks = tankVoApi:getTanksTbByType(self.troopsType)
    local emblemId = emblemVoApi:getTmpEquip()
    local planePos = planeVoApi:getTmpEquip()
    local airshipId = airShipVoApi:getTempLineupId()
    local troopsData = {tanks = tanks, hero = hTb, emblemId = emblemId, planePos = planePos, aitroops = aitroops, airship = airshipId}
    acNewYearsEveVoApi:setTroopsData(troopsData)
    heroVoApi:setNewYearBossHeroList(hTb)
    AITroopsFleetVoApi:setNewYearBossAITroopsList(aitroops)
    emblemVoApi:setBattleEquip(self.troopsType, emblemId)
    planeVoApi:setBattleEquip(self.troopsType, planePos)
    self.attackTanks = G_clone(tankVoApi:getTanksTbByType(self.troopsType))
    self.attackHeros = G_clone(heroVoApi:getNewYearBossHeroList())
    self.attackAITroops = G_clone(AITroopsFleetVoApi:getNewYearBossAITroopsList())
    self.attackEmblem = emblemVoApi:getBattleEquip(self.troopsType)
    self.attackPlane = planeVoApi:getBattleEquip(self.troopsType)
    self.atkAirship = airShipVoApi:getBattleEquip(self.troopsType)
    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("BossBattle_saveOk"), 30)
    if callback then
        callback()
    end
end

function acNewYearsEveDialogTab3:judgeFight(callback)
    local bestTab2 = {}
    local allfight1 = 0
    local allfight2 = 0
    local bossTanks = acNewYearsEveVoApi:getTroopsData(true)
    for k, v in pairs(bossTanks) do
        if SizeOfTable(v) > 0 then
            local fight = tankVoApi:getBestTanksFighting(v[1], v[2])
            allfight1 = allfight1 + fight
        end
    end
    for k, v in pairs(tankVoApi:getTanksTbByType(self.troopsType)) do
        if SizeOfTable(v) > 0 then
            local fight = tankVoApi:getBestTanksFighting(v[1], v[2])
            allfight2 = allfight2 + fight
        end
    end
    local isLow = false
    
    if allfight1 > allfight2 then
        local hTb = nil
        if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankVoApi:getTanksTbByType(self.troopsType))
        end
        
        local function gosave()
            local tankTb = tankVoApi:getTanksTbByType(self.troopsType)
            local hTb = {0, 0, 0, 0, 0, 0}
            if heroVoApi:isHaveTroops() then
                hTb = heroVoApi:getMachiningHeroList(tankTb)
            end
            local aitroops = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
            local tanks = tankVoApi:getTanksTbByType(self.troopsType)
            local emblemId = emblemVoApi:getTmpEquip()
            local planePos = planeVoApi:getTmpEquip()
            local airshipId = airShipVoApi:getTempLineupId()
            local troopsData = {tanks = tanks, hero = hTb, emblemId = emblemId, planePos = planePos, aitroops = aitroops, airship = airshipId}
            acNewYearsEveVoApi:setTroopsData(troopsData)
            heroVoApi:setNewYearBossHeroList(hTb)
            AITroopsFleetVoApi:setNewYearBossAITroopsList(aitroops)
            emblemVoApi:setBattleEquip(self.troopsType, emblemId)
            planeVoApi:setBattleEquip(self.troopsType, planePos)
            self.attackTanks = G_clone(tankVoApi:getTanksTbByType(self.troopsType))
            self.attackHeros = G_clone(heroVoApi:getNewYearBossHeroList())
            self.attackAITroops = G_clone(AITroopsFleetVoApi:getNewYearBossAITroopsList())
            self.attackEmblem = emblemVoApi:getBattleEquip(self.troopsType)
            self.attackPlane = planeVoApi:getBattleEquip(self.troopsType)
            self.atkAirship = airShipVoApi:getBattleEquip(self.troopsType)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("BossBattle_saveOk"), 30)
            if callback then
                callback()
            end
        end
        local function gocancel()
            self:refreshTroops()
            if callback then
                callback()
            end
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), gosave, getlocal("dialog_title_prompt"), getlocal("arena_powerLow"), nil, self.layerNum + 1, nil, nil, gocancel)
        isLow = true
        
    end
    
    return isLow
    
end

function acNewYearsEveDialogTab3:isChangeFleet()
    local fleetInfo = tankVoApi:getTanksTbByType(self.troopsType)
    local costTanks, isSame = tankVoApi:setFleetCostTanks(self.attackTanks, fleetInfo)
    
    local hero1 = heroVoApi:getBindFleetHeroList(self.attackHeros, self.attackTanks, self.troopsType, false)
    local heroList = heroVoApi:getTroopsHeroList()
    local hero2 = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, self.troopsType, false)
    local isSameHero = heroVoApi:isSameHero(hero1, hero2)
    
    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self.attackAITroops, self.attackTanks, self.troopsType, false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb, fleetInfo, self.troopsType, false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    
    local isSameEmblem = true
    local tmpEmblemID = emblemVoApi:getTmpEquip()
    local emblemID = emblemVoApi:getBattleEquip(self.troopsType)
    if tmpEmblemID ~= emblemID then
        isSameEmblem = false
    end
    local isSamePlane = true
    local tmpPlanePos = planeVoApi:getTmpEquip()
    local planePos = planeVoApi:getBattleEquip(self.troopsType)
    if tmpPlanePos ~= planePos then
        isSamePlane = false
    end
    local isSameAirship = true
    if airShipVoApi:getTempLineupId() ~= airShipVoApi:getBattleEquip(self.troopsType) then
        isSameAirship = false
    end
    
    if isSame == true and isSameHero == true and isSameEmblem == true and isSamePlane == true and isSameAITroops == true and isSameAirship == true then
        return false, costTanks
    else
        return true, costTanks
    end
end

function acNewYearsEveDialogTab3:refreshTroops()
    acNewYearsEveVoApi:setNewYearBossFleet(self.attackTanks, self.attackHeros, self.troopsType, self.attackEmblem, self.attackPlane, self.attackAITroops, self.atkAirship)
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    emblemVoApi:setTmpEquip(nil)
    planeVoApi:setTmpEquip(nil)
    airShipVoApi:setTempLineupId(nil)
    G_updateSelectTankLayer(30, self.bgLayer, self.layerNum, self.isShowTank, self.attackTanks, self.attackHeros, self.attackEmblem, self.attackPlane, self.attackAITroops, self.atkAirship)
end

function acNewYearsEveDialogTab3:clearTouchSp()
    for i = 1, 6, 1 do
        local spA = self.bgLayer:getChildByTag(i):getChildByTag(2)
        if spA ~= nil then
            spA:removeFromParentAndCleanup(true)
        end
    end
    for k, v in pairs(tankVoApi:getTanksTbByType(self.troopsType)) do
        local sp = self.bgLayer:getChildByTag(k)
        if v[1] ~= nil and v[2] ~= nil then
            G_addTouchSp(self.troopsType, sp, v[1], v[2], self.layerNum, self.bgLayer, 1)
        end
    end
    
end

function acNewYearsEveDialogTab3:updateData()
    local tanks, hero, emblemId, planePos, aitroops, airshipId = acNewYearsEveVoApi:getTroopsData()
    -- print("tanks,hero",G_Json.encode(tanks),G_Json.encode(hero))
    acNewYearsEveVoApi:setNewYearBossFleet(tanks, hero, self.troopsType, emblemId, planePos, aitroops, airshipId)
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    emblemVoApi:setTmpEquip(nil)
    planeVoApi:setTmpEquip(nil)
    airShipVoApi:setTempLineupId(nil)
end

function acNewYearsEveDialogTab3:dispose()
    self.isShowTank = 1
    self:updateData()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer = nil
    self.layerNum = nil
    self.attackTanks = {{}, {}, {}, {}, {}, {}}
    self.attackHeros = {0, 0, 0, 0, 0, 0}
    self.attackAITroops = {0, 0, 0, 0, 0, 0}
    self.attackEmblem = nil
    self.attackPlane = nil
    self.atkAirship = nil
end
