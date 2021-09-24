platWarTroopsDialogTab3 = {}

function platWarTroopsDialogTab3:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.tv = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.parent = nil
    
    self.maskSp = nil
    self.saveTimeLb = nil
    self.leftTimeLb = nil
    self.cannotSaveLb = nil
    
    self.selectedTabIndex = 1
    self.bgLayer2 = nil
    self.maxPowerBtn2 = nil
    self.platWarTanks2 = {{}, {}, {}, {}, {}, {}}
    self.platWarHero2 = {0, 0, 0, 0, 0, 0}
    self.platWarAITroops2 = {0, 0, 0, 0, 0, 0}
    self.platWarEmblem2 = nil
    self.platWarPlane2 = nil
    
    self.currentShow = 1
    
    return nc
end

function platWarTroopsDialogTab3:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    self:initTabLayer()
    self:doUserHandler()
    
    return self.bgLayer
end

--设置对话框里的tableView
function platWarTroopsDialogTab3:initTableView()
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 50, G_VisibleSizeHeight), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setPosition(ccp(50,115))
    -- self.bgLayer:addChild(self.tv,1)
    -- self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

function platWarTroopsDialogTab3:initTabLayer()
    self:initTabLayer1()
    self:initSaveBtn()
    self:initFormationBtn()
end

function platWarTroopsDialogTab3:initTabLayer1()
    self.bgLayer2 = CCLayer:create()
    self.bgLayer:addChild(self.bgLayer2, 2)
    
    local function callback(flag)
        self.currentShow = flag + 1
    end
    local btype = self.selectedTabIndex + 21
    self.platWarTanks2 = G_clone(tankVoApi:getTanksTbByType(btype))
    self.maxPowerBtn2 = G_addSelectTankLayer(btype, self.bgLayer2, self.layerNum, callback)
    self.platWarHero2 = G_clone(heroVoApi:getPlatWarHeroList(self.selectedTabIndex + 1))
    self.platWarAITroops2 = G_clone(AITroopsFleetVoApi:getPlatWarAITroopsList(self.selectedTabIndex + 1))
    self.platWarEmblem2 = emblemVoApi:getBattleEquip(btype)
    self.platWarPlane2 = planeVoApi:getBattleEquip(btype)
    self.warAirship = airShipVoApi:getBattleEquip(btype)
    tankVoApi:setPlatWarTempTanks(G_clone(tankVoApi:getTanksTbByType(btype)))
end

function platWarTroopsDialogTab3:initSaveBtn()
    local function save()
        self:saveHandler()
    end
    self.saveBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", save, nil, getlocal("arena_save"), 25)
    local saveMenu = CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520, 80))
    saveMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(saveMenu, 3)
    
    local saveTimeStr = getlocal("serverwar_left_save_time")
    -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    self.saveTimeLb = GetTTFLabelWrap(saveTimeStr, 25, CCSizeMake(180, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
    self.saveTimeLb:setAnchorPoint(ccp(0.5, 0))
    self.saveTimeLb:setPosition(ccp(520, 150))
    self.bgLayer:addChild(self.saveTimeLb, 3)
    self.saveTimeLb:setVisible(false)
    
    self.leftTimeLb = GetTTFLabel("0", 25)
    self.leftTimeLb:setAnchorPoint(ccp(0.5, 0))
    self.leftTimeLb:setPosition(ccp(520, 120))
    self.bgLayer:addChild(self.leftTimeLb, 3)
    self.leftTimeLb:setColor(G_ColorYellowPro)
    self.leftTimeLb:setVisible(false)
    
    local lastTime = platWarVoApi:getLastSetFleetTime(self.selectedTabIndex + 1)
    if lastTime then
        local leftTime = platWarCfg.settingTroopsLimit - (base.serverTime - lastTime)
        if leftTime > 0 then
            self.saveBtn:setEnabled(false)
            
            self.saveTimeLb:setVisible(true)
            self.leftTimeLb:setVisible(true)
            self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
        end
    end
    
end

function platWarTroopsDialogTab3:saveHandler(callFunc)
    if platWarVoApi:isCanSetTroops() == false then
        do return end
    end
    local isCanSetFleet = platWarVoApi:getIsCanSetFleet(self.selectedTabIndex + 1, self.layerNum)
    if isCanSetFleet == true then
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
                local btype = self.selectedTabIndex + 21
                self.platWarTanks2 = G_clone(tankVoApi:getTanksTbByType(btype))
                
                local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
                tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
                
                local heroList = heroVoApi:getTroopsHeroList()
                heroVoApi:setPlatWarHeroList(self.selectedTabIndex + 1, heroList)
                
                local aitroops = AITroopsFleetVoApi:getAITroopsTb()
                AITroopsFleetVoApi:setPlatWarAITroopsList(self.selectedTabIndex + 1, aitroops)
                
                self.platWarHero2 = G_clone(heroVoApi:getPlatWarHeroList(self.selectedTabIndex + 1))
                self.platWarAITroops2 = G_clone(AITroopsFleetVoApi:getPlatWarAITroopsList(self.selectedTabIndex + 1))
                
                platWarVoApi:setLastSetFleetTime(self.selectedTabIndex + 1, base.serverTime)
                tankVoApi:setPlatWarTempTanks(G_clone(tankVoApi:getTanksTbByType(btype)))
                local emblemId = emblemVoApi:getTmpEquip(btype)
                emblemVoApi:setBattleEquip(btype, emblemId)
                self.platWarEmblem2 = emblemVoApi:getBattleEquip(btype)
                local planePos = planeVoApi:getTmpEquip(btype)
                planeVoApi:setBattleEquip(btype, planePos)
                self.platWarPlane2 = planeVoApi:getBattleEquip(btype)
                self.warAirship = airShipVoApi:getTempLineupId(btype)
                airShipVoApi:setBattleEquip(btype, self.warAirship)
                self:tick()
                if callFunc then
                    callFunc()
                end
                -- elseif sData.ret==-5015 then
                --     local function sureCallBackHandler()
                --         if G_checkClickEnable()==false then
                --             do
                --                 return
                --             end
                --         else
                --             base.setWaitTime=G_getCurDeviceMillTime()
                --         end
                --         PlayEffect(audioCfg.mouseClick)
                
                --         local function clearSetFleetHandler(fn,data)
                --             local ret,sData=base:checkServerData(data)
                --             if ret==true then
                --              self.platWarTanks2={{},{},{},{},{},{}}
                --           self.platWarHero2={0,0,0,0,0,0}
                --                 self:setTanksRestore()
                --                 if self.bgLayer2 then
                --                  G_updateSelectTankLayer(self.selectedTabIndex+21,self.bgLayer2,self.layerNum)
                --                 end
                --             end
                --         end
                --         socketHelper:crossSetInfo(nil,nil,nil,nil,1,clearSetFleetHandler)
                --     end
                --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureCallBackHandler,getlocal("dialog_title_prompt"),getlocal("backstage5015"),nil,self.layerNum+1)
            end
        end
        local bType = self.selectedTabIndex + 21
        local fleetInfo = tankVoApi:getTanksTbByType(bType)
        local aName
        if allianceVoApi:isHasAlliance() then
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.name then
                aName = selfAlliance.name
            end
        end
        local wwhero = nil
        print("heroVoApi:isHaveTroops()", heroVoApi:isHaveTroops())
        if heroVoApi:isHaveTroops() == true then
            -- local heroList=heroVoApi:getPlatWarHeroList(self.selectedTabIndex+1)
            local heroList = heroVoApi:getTroopsHeroList()
            wwhero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, bType)
        end
        local aitroops = AITroopsFleetVoApi:getAITroopsTb()
        aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, bType)
        
        local function saveCallback()
            local emblemId = emblemVoApi:getTmpEquip(bType)
            local planePos = planeVoApi:getTmpEquip(bType)
            local airshipId = airShipVoApi:getTempLineupId(bType)
            socketHelper:platwarSetinfo(self.selectedTabIndex + 1, fleetInfo, wwhero, callback, emblemId, planePos, aitroops, airshipId)
        end
        local costTanks, isSame = tankVoApi:setFleetCostTanks(self.platWarTanks2, fleetInfo)
        local isChangeFleet = self:isChangeFleet()
        if isChangeFleet == false then
            -- if isSame==true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_war_no_change_save"), 30)
        else
            if costTanks and SizeOfTable(costTanks) > 0 then
                smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png", CCSizeMake(550, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, saveCallback, costTanks)
            else
                saveCallback()
            end
        end
    end
end

function platWarTroopsDialogTab3:isChangeFleet()
    local bType = self.selectedTabIndex + 21
    local fleetInfo = tankVoApi:getTanksTbByType(bType)
    local costTanks, isSame = tankVoApi:setFleetCostTanks(self.platWarTanks2, fleetInfo)
    
    local hero1 = heroVoApi:getBindFleetHeroList(self.platWarHero2, self.platWarTanks2, bType, false)
    -- local heroList=heroVoApi:getPlatWarHeroList(self.selectedTabIndex+1)
    local heroList = heroVoApi:getTroopsHeroList()
    local hero2 = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, bType, false)
    local isSameHero = heroVoApi:isSameHero(hero1, hero2)
    
    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self.platWarAITroops2, self.platWarTanks2, bType, false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb, fleetInfo, bType, false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    
    local isSameEmblem = true
    local tmpEmblemId = emblemVoApi:getTmpEquip(bType)
    local emblemID = emblemVoApi:getBattleEquip(bType)
    if tmpEmblemId ~= emblemID then
        isSameEmblem = false
    end
    local isSamePlane = true
    local tmpPlanePos = planeVoApi:getTmpEquip(bType)
    local planePos = planeVoApi:getBattleEquip(bType)
    if tmpPlanePos ~= planePos then
        isSamePlane = false
    end
    local isSameAirship = true
    if airShipVoApi:getTempLineupId(bType) ~= airShipVoApi:getBattleEquip(bType) then
        isSameAirship = false
    end
    if isSame == true and isSameHero == true and isSameEmblem and isSamePlane and isSameAITroops == true and isSameAirship == true then
        return false, costTanks
    else
        return true, costTanks
    end
end

function platWarTroopsDialogTab3:initFormationBtn()
    local tType = self.selectedTabIndex + 21
    local function readCallback()
    end
    local formationMenu = G_getFormationBtn(self.bgLayer2, self.layerNum, self.currentShow, tType, readCallback)
end

function platWarTroopsDialogTab3:doUserHandler()
    local function tmpFunc()
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), tmpFunc)
    self.maskSp:setOpacity(255)
    local size = CCSizeMake(G_VisibleSize.width - 50, G_VisibleSizeHeight - 235)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0.5, 0))
    self.maskSp:setPosition(ccp(G_VisibleSize.width / 2, 30))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum - 1) * 20 - 9)
    self.bgLayer:addChild(self.maskSp, 4)
    
    self.cannotSaveLb = GetTTFLabelWrap(getlocal("world_war_cannot_set_fleet2"), 30, CCSizeMake(self.maskSp:getContentSize().width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.cannotSaveLb:setAnchorPoint(ccp(0.5, 0.5))
    self.cannotSaveLb:setPosition(getCenterPoint(self.maskSp))
    self.maskSp:addChild(self.cannotSaveLb, 2)
    self.cannotSaveLb:setColor(G_ColorYellowPro)
    
    self:tick()
    
    self.maskSp:setPosition(ccp(10000, 0))
end

function platWarTroopsDialogTab3:tick()
    if self then
        local lastTime = platWarVoApi:getLastSetFleetTime(self.selectedTabIndex + 1) or 0
        local leftTime = platWarCfg.settingTroopsLimit - (base.serverTime - lastTime)
        if leftTime > 0 then
            if self.saveBtn and self.saveBtn:isEnabled() == true then
                self.saveBtn:setEnabled(false)
            end
            if self.saveTimeLb then
                self.saveTimeLb:setVisible(true)
            end
            if self.leftTimeLb then
                self.leftTimeLb:setVisible(true)
                self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
            end
        else
            if self.saveBtn and self.saveBtn:isEnabled() == false then
                self.saveBtn:setEnabled(true)
            end
            if self.saveTimeLb then
                self.saveTimeLb:setVisible(false)
            end
            if self.leftTimeLb then
                self.leftTimeLb:setVisible(false)
            end
        end
    end
end

function platWarTroopsDialogTab3:setTanksRestore()
    local tType = self.selectedTabIndex + 21
    for i = 1, 6 do
        local id = i
        if self.platWarTanks2 and self.platWarTanks2[id] and self.platWarTanks2[id][1] then
            local tid = self.platWarTanks2[id][1]
            local num = self.platWarTanks2[id][2] or 0
            tankVoApi:setTanksByType(tType, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(tType, id)
        end
        tankVoApi:setPlatWarTempTanks(self.platWarTanks2)
        
        if self.platWarHero2 then
            local hid = self.platWarHero2[id]
            if hid then
                heroVoApi:setPlatWarHeroByIndex(self.selectedTabIndex + 1, id, hid)
            else
                heroVoApi:deletePlatWarTroopsByIndex(self.selectedTabIndex + 1, id)
            end
        end
        
        if self.platWarAITroops2 then
            local atid = self.platWarAITroops2[id]
            if atid then
                AITroopsFleetVoApi:setPlatWarAITroopsByIndex(self.selectedTabIndex + 1, id, atid)
            else
                AITroopsFleetVoApi:setPlatWarAITroopsByIndex(self.selectedTabIndex + 1, id, 0)
            end
        end
    end
    emblemVoApi:setTmpEquip(self.platWarEmblem2, tType)
    planeVoApi:setTmpEquip(self.platWarPlane2, tType)
    airShipVoApi:setTempLineupId(self.warAirship, tType)
end

function platWarTroopsDialogTab3:updateData()
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
end
function platWarTroopsDialogTab3:refresh()
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
    G_updateSelectTankLayer(self.selectedTabIndex + 21, self.bgLayer2, self.layerNum, self.currentShow)
    self:tick()
end

function platWarTroopsDialogTab3:dispose()
    self:setTanksRestore()
    
    local tType = self.selectedTabIndex + 21
    G_clearEditTroopsLayer(tType)
    self.selectedTabIndex = 1
    self.bgLayer2 = nil
    self.maxPowerBtn2 = nil
    self.platWarTanks2 = {{}, {}, {}, {}, {}, {}}
    self.platWarHero2 = {0, 0, 0, 0, 0, 0}
    self.platWarAITroops2 = {0, 0, 0, 0, 0, 0}
    self.platWarEmblem2 = nil
    self.platWarPlane2 = nil
    self.warAirship = nil
    
    self.tv = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.maskSp = nil
    self.saveTimeLb = nil
    self.leftTimeLb = nil
    self.cannotSaveLb = nil
    self.currentShow = 1
end

