superWeaponRobDialogTab2 = {}

function superWeaponRobDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.type = 20
    self.bgLayer = nil
    self.layerNum = nil
    -- self.selectedTabIndex=0
    self.parent = nil
    
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    -- self.cannotSaveLb=nil
    
    -- self.maxPowerBtn=nil
    -- self.fundsBtn=nil
    self.formationBtn = nil
    
    self.swDefenceTanks = {{}, {}, {}, {}, {}, {}}
    self.swDefenceHero = {0, 0, 0, 0, 0, 0}
    self.swDefenceAITroops = {0, 0, 0, 0, 0, 0}
    
    self.currentShow = 1
    self.currentFundsLb = nil
    
    return nc
end

function superWeaponRobDialogTab2:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTabLayer()
    self:doUserHandler()
    
    return self.bgLayer
end

function superWeaponRobDialogTab2:initTabLayer()
    local function callback(flag)
        self.currentShow = flag + 1
    end
    self.swDefenceTanks = G_clone(tankVoApi:getTanksTbByType(self.type))
    -- self.maxPowerBtn=G_addSelectTankLayer(self.type,self.bgLayer,self.layerNum,callback)
    G_addSelectTankLayer(self.type, self.bgLayer, self.layerNum, callback)
    self.swDefenceHero = G_clone(heroVoApi:getSWDefenceHeroList())
    self.swDefenceAITroops = G_clone(AITroopsFleetVoApi:getSWDefenceAITroopsList())
    self:initSaveBtn()
    self:initFormationBtn()
    
    -- local function close()
    --     PlayEffect(audioCfg.mouseClick)
    --     local setFleetStatus=localWarVoApi:getSetFleetStatus()
    --     local isChangeFleet,costTanks=self:isChangeFleet()
    --     if setFleetStatus==0 and isChangeFleet==true then
    --         local function onConfirm()
    --             local function saveBack()
    --                 if self.parent and self.parent.close then
    --                     self.parent:close()
    --                 end
    --             end
    --             self:saveHandler(saveBack)
    --         end
    --         local function onCancle()
    --             if self.parent and self.parent.close then
    --                 self.parent:close()
    --             end
    --         end
    --         smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_set_changed_fleet"),nil,self.layerNum+1,nil,nil,onCancle)
    --     else
    --         if self.parent and self.parent.close then
    --             self.parent:close()
    --         end
    --     end
    -- end
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(0,0)
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    -- local closeMenu = CCMenu:createWithItem(closeBtnItem)
    -- closeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- closeMenu:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(closeMenu)
end

function superWeaponRobDialogTab2:initSaveBtn()
    local function save()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        self:saveHandler()
    end
    self.saveBtn = GetButtonItem("BtnCancleSmall.png", "BtnCancleSmall_Down.png", "BtnCancleSmall_Down.png", save, nil, getlocal("arena_save"), 25)
    local saveMenu = CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520, 80))
    saveMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(saveMenu, 3)
    
end

function superWeaponRobDialogTab2:saveHandler(callback)
    local isEable = true
    local num = 0;
    local type = self.type
    for k, v in pairs(tankVoApi:getTanksTbByType(type)) do
        if SizeOfTable(v) == 0 then
            num = num + 1;
        end
    end
    if num == 6 then
        isEable = false
    end
    if isEable == false then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("allianceWarNoArmy"), nil, self.layerNum + 1, nil)
        do return end
    end
    
    -- if self:judgeFight() then
    --     do
    --         return
    --     end
    -- end
    
    local function setinfoHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
            local type = self.type
            self.swDefenceTanks = G_clone(tankVoApi:getTanksTbByType(type))
            
            local heroList = heroVoApi:getTroopsHeroList()
            heroVoApi:setSWDefenceHeroList(heroList)
            
            local aitroops = AITroopsFleetVoApi:getAITroopsTb()
            AITroopsFleetVoApi:setSWDefenceAITroopsList(aitroops)
            
            self.swDefenceHero = G_clone(heroVoApi:getSWDefenceHeroList())
            self.swDefenceAITroops = G_clone(AITroopsFleetVoApi:getSWDefenceAITroopsList())
            
            -- localWarVoApi:setLastSetFleetTime(base.serverTime)
            local emblemId = emblemVoApi:getTmpEquip()
            emblemVoApi:setBattleEquip(20, emblemId)
            
            local planePos = planeVoApi:getTmpEquip()
            planeVoApi:setBattleEquip(20, planePos)
            
            airShipVoApi:setBattleEquip(20, airShipVoApi:getTempLineupId())
            
            self:tick()
            if callback then
                callback()
            end
        end
    end
    local fleetInfo = tankVoApi:getTanksTbByType(self.type)
    local hero = nil
    if heroVoApi:isHaveTroops() == true then
        -- local heroList=heroVoApi:getSWDefenceHeroList()
        local heroList = heroVoApi:getTroopsHeroList()
        hero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, self.type)
    end
    local aitroops = AITroopsFleetVoApi:getAITroopsTb()
    aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, self.type)
    
    local emblemId = emblemVoApi:getTmpEquip()
    local planePos = planeVoApi:getTmpEquip()
    local airshipId = airShipVoApi:getTempLineupId()
    socketHelper:weaponSettroops(fleetInfo, hero, setinfoHandler, emblemId, planePos, aitroops, airshipId)
    
    -- local function saveCallback()
    --     -- socketHelper:areawarSetinfo(fleetInfo,hero,setinfoHandler)
    -- end
    -- local isChangeFleet,costTanks=self:isChangeFleet()
    -- if isChangeFleet==false then
    --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_no_change_save"),30)
    -- else
    --     -- if costTanks and SizeOfTable(costTanks)>0 then
    --     --     smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,saveCallback,costTanks)
    --     -- else
    --         saveCallback()
    --     -- end
    -- end
end

-- function superWeaponRobDialogTab2:isChangeFleet()
--     local fleetInfo=tankVoApi:getTanksTbByType(self.type)
--     local costTanks,isSame=tankVoApi:setFleetCostTanks(self.swDefenceTanks,fleetInfo)

--     local hero1=heroVoApi:getBindFleetHeroList(self.swDefenceHero,self.swDefenceTanks,self.type,false)
--     local heroList=heroVoApi:getTroopsHeroList()
--     local hero2=heroVoApi:getBindFleetHeroList(heroList,fleetInfo,self.type,false)
--     local isSameHero=heroVoApi:isSameHero(hero1,hero2)
--     if isSame==true and isSameHero==true then
--         return false,costTanks
--     else
--         return true,costTanks
--     end
-- end

function superWeaponRobDialogTab2:initFormationBtn()
    local function showFormation()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function readCallback(tank, hero)
        end
        smallDialog:showFormationDialog("PanelHeaderPopup.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, getlocal("save_formation"), readCallback, 20, self.currentShow, self.bgLayer)
    end
    self.formationBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", showFormation, nil, getlocal("formation"), 25)
    local fundsMenu = CCMenu:createWithItem(self.formationBtn)
    fundsMenu:setPosition(ccp(120, 80))
    fundsMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(fundsMenu, 3)
    
    -- self.tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
    -- self.tipSp:setPosition(ccp(self.formationBtn:getContentSize().width-10,self.formationBtn:getContentSize().height-10))
    -- self.tipSp:setTag(11)
    -- self.tipSp:setVisible(false)
    -- self.formationBtn:addChild(self.tipSp)
end

-- function superWeaponRobDialogTab2:judgeFight()
--     local bestTab2={}
--     local allfight1=0
--     local allfight2=0
--     for k,v in pairs(self.arenaTanks) do
--         if SizeOfTable(v)>0 then
--             local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
--             allfight1=allfight1+fight
--         end
--     end
--     for k,v in pairs(tankVoApi:getDeArenaTanks()) do
--         if SizeOfTable(v)>0 then
--             local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
--             allfight2=allfight2+fight
--         end
--     end
--     local isLow = false

--     if allfight1>allfight2 then

--         local function gosave()
--             local function callback(fn,data)
--             if base:checkServerData(data)==true then
--                 smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_saveOk"),30)

--             end
--         end

--         socketHelper:militarySettroops(tankVoApi:getDeArenaTanks(),callback)
--         end
--         smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gosave,getlocal("dialog_title_prompt"),getlocal("arena_powerLow"),nil,self.layerNum+1)
--         isLow = true

--     end

--     return isLow

-- end

function superWeaponRobDialogTab2:doUserHandler()
end

function superWeaponRobDialogTab2:tick()
    
end

function superWeaponRobDialogTab2:setTanksRestore()
    local tType = self.type
    for i = 1, 6 do
        local id = i
        if self.swDefenceTanks and self.swDefenceTanks[id] and self.swDefenceTanks[id][1] then
            local tid = self.swDefenceTanks[id][1]
            local num = self.swDefenceTanks[id][2] or 0
            tankVoApi:setTanksByType(tType, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(tType, id)
        end
        
        if self.swDefenceHero then
            local hid = self.swDefenceHero[id]
            if hid then
                heroVoApi:setSWDefenceHeroByPos(id, hid)
            else
                heroVoApi:clearSWDefenceTroops()
            end
        end
        --AI部队
        if self.swDefenceAITroops then
            local atid = self.swDefenceAITroops[id]
            if atid then
                AITroopsFleetVoApi:setSWDefenceAITroopsByPos(id, atid)
            else
                AITroopsFleetVoApi:setSWDefenceAITroopsByPos(id, 0)
            end
        end
    end
end

function superWeaponRobDialogTab2:refresh()
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
    G_updateSelectTankLayer(20, self.bgLayer, self.layerNum, self.currentShow)
    self:tick()
end

function superWeaponRobDialogTab2:dispose()
    self:setTanksRestore()
    
    self.swDefenceTanks = {{}, {}, {}, {}, {}, {}}
    self.swDefenceHero = {0, 0, 0, 0, 0, 0}
    self.swDefenceAITroops = {0, 0, 0, 0, 0, 0}
    
    self.bgLayer = nil
    self.layerNum = nil
    -- self.selectedTabIndex=0
    
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    -- self.cannotSaveLb=nil
    -- self.maxPowerBtn=nil
    self.formationBtn = nil
    self.fundsBtn = nil
    self.currentShow = 1
    self.currentFundsLb = nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
end
