serverWarLocalTroopsSubTab21 = {}

function serverWarLocalTroopsSubTab21:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.type = 24
    self.bgLayer = nil
    self.layerNum = nil
    self.selectedTabIndex = 0
    self.parent = nil
    
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    -- self.cannotSaveLb=nil
    
    -- self.maxPowerBtn=nil
    -- self.fundsBtn=nil
    self.formationBtn = nil
    self.saveBtn = nil
    
    self.serverWarLocalTanks1 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalTanks2 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalTanks3 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalHero1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalHero2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalHero3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalEmblem1 = nil
    self.serverWarLocalEmblem2 = nil
    self.serverWarLocalEmblem3 = nil
    self.serverWarLocalPlane1 = nil
    self.serverWarLocalPlane2 = nil
    self.serverWarLocalPlane3 = nil
    
    self.currentShow = {1, 1, 1}
    self.currentFundsLb = nil
    
    return nc
end

function serverWarLocalTroopsSubTab21:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    self:initTabLayer()
    self:doUserHandler()
    return self.bgLayer
end

function serverWarLocalTroopsSubTab21:initTabLayer()
    local btype = self.type + self.selectedTabIndex
    local function callback(flag)
        self.currentShow[self.selectedTabIndex + 1] = flag + 1
    end
    local troopsIndex = self.selectedTabIndex + 1
    self["serverWarLocalTanks"..troopsIndex] = G_clone(tankVoApi:getTanksTbByType(btype))
    G_addSelectTankLayer(btype, self.bgLayer, self.layerNum, callback)
    self["serverWarLocalHero"..troopsIndex] = G_clone(heroVoApi:getServerWarLocalHeroList(troopsIndex))
    self["serverWarLocalAITroops"..troopsIndex] = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(troopsIndex))
    tankVoApi:setServerWarLocalTempTanks(G_clone(tankVoApi:getTanksTbByType(btype)))
    self["serverWarLocalEmblem"..troopsIndex] = G_clone(emblemVoApi:getTmpEquip(btype))
    self["serverWarLocalPlane"..troopsIndex] = G_clone(planeVoApi:getTmpEquip(btype))
    self["serverWarLocalAirship"..troopsIndex] = airShipVoApi:getTempLineupId(btype)

    self:initSaveBtn()
    self:initFormationBtn()
    self:initDesc()
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        local setFleetStatus = serverWarLocalVoApi:getSetFleetStatus()
        local isChangeFleet, costTanks = self:isChangeFleet()
        if setFleetStatus == 0 and isChangeFleet == true then
            local function onConfirm()
                local function saveBack()
                    if self.parent and self.parent.close then
                        self.parent:close()
                    end
                end
                self:saveHandler(saveBack)
            end
            local function onCancle()
                if self.parent and self.parent.close then
                    self.parent:close()
                end
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("world_war_set_changed_fleet"), nil, self.layerNum + 1, nil, nil, onCancle)
        else
            if self.parent and self.parent.close then
                self.parent:close()
            end
        end
    end
    local closeBtnItem = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, nil, nil, nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
    local closeMenu = CCMenu:createWithItem(closeBtnItem)
    closeMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    closeMenu:setPosition(ccp(self.bgLayer:getContentSize().width - closeBtnItem:getContentSize().width, self.bgLayer:getContentSize().height - closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeMenu)
end

function serverWarLocalTroopsSubTab21:initSaveBtn()
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
    local btnScale = 0.8
    self.saveBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", save, nil, getlocal("arena_save"), 25 / btnScale)
    self.saveBtn:setScale(btnScale)
    local saveMenu = CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520, 60))
    saveMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(saveMenu, 3)
    
    -- local saveTimeStr=getlocal("serverwar_left_save_time")
    -- -- saveTimeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- self.saveTimeLb=GetTTFLabelWrap(saveTimeStr,25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    -- self.saveTimeLb:setAnchorPoint(ccp(0.5,0))
    -- self.saveTimeLb:setPosition(ccp(520,150))
    -- self.bgLayer:addChild(self.saveTimeLb,3)
    -- self.saveTimeLb:setVisible(false)
    
    -- self.leftTimeLb=GetTTFLabel("0",25)
    -- self.leftTimeLb:setAnchorPoint(ccp(0.5,0))
    -- self.leftTimeLb:setPosition(ccp(520,120))
    -- self.bgLayer:addChild(self.leftTimeLb,3)
    -- self.leftTimeLb:setColor(G_ColorYellowPro)
    -- self.leftTimeLb:setVisible(false)
    
    -- local lastTime=serverWarLocalVoApi:getLastSetFleetTime()
    -- if lastTime then
    --     local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
    --     if leftTime>0 then
    --         self.saveBtn:setEnabled(false)
    
    --         self.saveTimeLb:setVisible(true)
    --         self.leftTimeLb:setVisible(true)
    --         self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
    --     end
    -- end
    
end

function serverWarLocalTroopsSubTab21:saveHandler(callback)
    local setFleetStatus, tipStr = serverWarLocalVoApi:getSetFleetStatus()
    if setFleetStatus ~= 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
        do return end
    end
    
    -- local lastTime=serverWarLocalVoApi:getLastSetFleetTime()
    -- if lastTime then
    --     local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
    --     if leftTime>0 then
    --         do return end
    --     end
    -- end
    
    local isEable = true
    local num = 0;
    local btype = self.type + self.selectedTabIndex
    for k, v in pairs(tankVoApi:getTanksTbByType(btype)) do
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
            local btype = self.type + self.selectedTabIndex
            local troopsIndex = self.selectedTabIndex + 1
            self["serverWarLocalTanks"..troopsIndex] = G_clone(tankVoApi:getTanksTbByType(btype))
            
            --保存设置的坦克皮肤数据
            local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
            tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
            
            local heroList = heroVoApi:getTroopsHeroList()
            heroVoApi:setServerWarLocalHeroList(troopsIndex, heroList)
            
            local aitroops = AITroopsFleetVoApi:getAITroopsTb()
            AITroopsFleetVoApi:setServerWarLocalAITroopsList(troopsIndex, aitroops)
            
            self["serverWarLocalHero"..troopsIndex] = G_clone(heroVoApi:getServerWarLocalHeroList(troopsIndex))
            self["serverWarLocalAITroops"..troopsIndex] = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(troopsIndex))
            
            serverWarLocalVoApi:setLastSetFleetTimeByIdx(troopsIndex, base.serverTime)
            tankVoApi:setServerWarLocalTempTanks(G_clone(tankVoApi:getTanksTbByType(btype)))
            
            local emblemId = emblemVoApi:getTmpEquip(btype)
            emblemVoApi:setBattleEquip(btype, emblemId)
            self["serverWarLocalEmblem"..troopsIndex] = emblemId
            
            local planePos = planeVoApi:getTmpEquip(btype)
            planeVoApi:setBattleEquip(btype, planePos)
            self["serverWarLocalPlane"..troopsIndex] = planePos
            
            local airshipId = airShipVoApi:getTempLineupId(btype)
            airShipVoApi:setBattleEquip(btype, airshipId)
            self["serverWarLocalAirship"..troopsIndex] = airshipId
            
            self:tick()
            
            if(serverWarLocalFightVoApi and serverWarLocalFightVoApi.refreshData)then
                serverWarLocalFightVoApi:refreshData()
            end
            if(serverWarLocalMapScene and serverWarLocalMapScene.checkTroopAlert)then
                serverWarLocalMapScene:checkTroopAlert()
            end
            --部队现状变化
            if serverWarLocalFightVoApi:checkTroopInBase(troopsIndex) == false then
            else
                local tType = btype + 3
                tankVoApi:clearTanksTbByType(tType)
                local tmpTanks = {{}, {}, {}, {}, {}, {}}
                tmpTanks = G_clone(tankVoApi:getTanksTbByType(btype))
                for k, v in pairs(tmpTanks) do
                    if v and v[1] and v[2] then
                        tankVoApi:setTanksByType(tType, k, v[1], v[2])
                    else
                        tankVoApi:deleteTanksTbByType(tType, k)
                    end
                end
                
                local tskin = G_clone(tankSkinVoApi:getTankSkinListByBattleType(btype))
                tankSkinVoApi:setTankSkinListByBattleType(tType, tskin)
                
                heroVoApi:deleteServerWarLocalCurTroopsByIndex(troopsIndex)
                local tmpHero = G_clone(heroVoApi:getServerWarLocalHeroList(troopsIndex))
                heroVoApi:setServerWarLocalCurHeroList(troopsIndex, tmpHero)
                
                --重新设置现有的AI部队
                AITroopsFleetVoApi:deleteServerWarLocalCurAITroopsByIndex(troopsIndex)
                local aitroops = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(troopsIndex))
                AITroopsFleetVoApi:setServerWarLocalCurAITroopsList(troopsIndex, aitroops)
            end
            if callback then
                callback()
            end
        end
    end
    local fleetInfo = tankVoApi:getTanksTbByType(btype)
    local hero = {0, 0, 0, 0, 0, 0}
    if heroVoApi:isHaveTroops() == true then
        -- local heroList=heroVoApi:getServerWarLocalHeroList(self.selectedTabIndex+1)
        local heroList = heroVoApi:getTroopsHeroList()
        hero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, btype)
    end
    --获取设置好的AI部队
    local aitroops = AITroopsFleetVoApi:getAITroopsTb()
    aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, btype)
    
    -- local aName
    -- if allianceVoApi:isHasAlliance() then
    --     local selfAlliance=allianceVoApi:getSelfAlliance()
    --     if selfAlliance and selfAlliance.name then
    --         aName=selfAlliance.name
    --     end
    -- end
    
    local function saveCallback()
        local line = self.selectedTabIndex + 1
        local emblemId = emblemVoApi:getTmpEquip(btype)
        local planePos = planeVoApi:getTmpEquip(btype)
        local airshipId = airShipVoApi:getTempLineupId(btype)
        serverWarLocalVoApi:setFleetAndFunds(nil, line, fleetInfo, hero, setinfoHandler, nil, emblemId, planePos, aitroops, airshipId)
    end
    -- local costTanks,isSame=tankVoApi:setFleetCostTanks(self["serverWarLocalTanks"..(self.selectedTabIndex+1)],fleetInfo)
    local isChangeFleet, costTanks = self:isChangeFleet()
    if isChangeFleet == false then
        -- if isSame==true then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_war_no_change_save"), 30)
    else
        if costTanks and SizeOfTable(costTanks) > 0 then
            smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png", CCSizeMake(550, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, saveCallback, costTanks, 3)
        else
            saveCallback()
        end
    end
end

function serverWarLocalTroopsSubTab21:isChangeFleet()
    local btype = self.type + self.selectedTabIndex
    local troopsIndex = self.selectedTabIndex + 1
    local fleetInfo = tankVoApi:getTanksTbByType(btype)
    local costTanks, isSame = tankVoApi:setFleetCostTanks(self["serverWarLocalTanks"..troopsIndex], fleetInfo)
    
    local hero1 = heroVoApi:getBindFleetHeroList(self["serverWarLocalHero"..troopsIndex], self["serverWarLocalTanks"..troopsIndex], btype, false)
    local heroList = heroVoApi:getTroopsHeroList()
    local hero2 = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, btype, false)
    -- print("hero1",G_Json.encode(hero1))
    -- print("hero2",G_Json.encode(hero2))
    local isSameHero = heroVoApi:isSameHero(hero1, hero2)
    -- print("isSame",isSame)
    -- print("isSameHero",isSameHero)
    
    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self["serverWarLocalAITroops"..troopsIndex], self["serverWarLocalTanks"..troopsIndex], btype, false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb, fleetInfo, btype, false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    
    local isSameEmblem = true
    local tmpEmblemID = emblemVoApi:getTmpEquip(btype)
    local emblemID = emblemVoApi:getBattleEquip(btype)
    if tmpEmblemID ~= emblemID then
        isSameEmblem = false
    end
    local isSamePlane = true
    local tmpPlanePos = planeVoApi:getTmpEquip(btype)
    local planePos = planeVoApi:getBattleEquip(btype)
    if tmpPlanePos ~= planePos then
        isSamePlane = false
    end
    local isSameAirship = true
    if airShipVoApi:getTempLineupId(btype) ~= airShipVoApi:getBattleEquip(btype) then
        isSameAirship = false
    end
    if isSame == true and isSameHero == true and isSameEmblem == true and isSamePlane == true and isSameAITroops == true and isSameAirship == true then
        return false, costTanks
    else
        return true, costTanks
    end
end

function serverWarLocalTroopsSubTab21:initFormationBtn()
    local type = self.type + self.selectedTabIndex
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
        smallDialog:showFormationDialog("PanelHeaderPopup.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, getlocal("save_formation"), readCallback, type, self.currentShow[self.selectedTabIndex + 1], self.bgLayer)
    end
    local btnScale = 0.8
    self.formationBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", showFormation, nil, getlocal("formation"), 25 / btnScale)
    self.formationBtn:setScale(btnScale)
    local fundsMenu = CCMenu:createWithItem(self.formationBtn)
    fundsMenu:setPosition(ccp(120, 60))
    fundsMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(fundsMenu, 3)
    
    -- self.tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
    -- self.tipSp:setPosition(ccp(self.formationBtn:getContentSize().width-10,self.formationBtn:getContentSize().height-10))
    -- self.tipSp:setTag(11)
    -- self.tipSp:setVisible(false)
    -- self.formationBtn:addChild(self.tipSp)
end

function serverWarLocalTroopsSubTab21:initDesc()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("NoticeLine.png", capInSet, cellClick)
    if G_isIphone5() == true then
        -- descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-90,G_VisibleSizeHeight-870-20-90))
        -- descBg:setPosition(ccp(G_VisibleSizeWidth/2,125-20))
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
    
    local content = {getlocal("local_war_troops_preset_desc3"), getlocal("local_war_troops_preset_desc4"), getlocal("serverWarLocal_troops_preset_desc")}
    local color = {G_ColorWhite, G_ColorYellowPro, G_ColorRed}
    local tabelLb = G_LabelTableView(CCSizeMake(descBg:getContentSize().width - 10, descBg:getContentSize().height - 10), content, 22, kCCTextAlignmentLeft, color)
    tabelLb:setPosition(ccp(5, 5))
    tabelLb:setAnchorPoint(ccp(0, 0))
    tabelLb:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    tabelLb:setMaxDisToBottomOrTop(70)
    descBg:addChild(tabelLb, 5)
    descBg:setOpacity(0)
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function () end)
    if G_isIphone5() == true then
        mLine:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSizeHeight - 870))
    else
        mLine:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSizeHeight - 780))
    end
    mLine:setContentSize(CCSizeMake(G_VisibleSize.width, mLine:getContentSize().height))
    self.bgLayer:addChild(mLine, 3)
end

-- function serverWarLocalTroopsSubTab21:judgeFight()
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

function serverWarLocalTroopsSubTab21:doUserHandler()
    -- local function tipTouch()
    --     if G_checkClickEnable()==false then
    --         do
    --             return
    --         end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)
    --     local sd=smallDialog:new()
    --     local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("serverwarteam_tanks_tip5")," ",getlocal("serverwarteam_tanks_tip4")," ",getlocal("serverwarteam_tanks_tip3")," ",getlocal("serverwarteam_tanks_tip2",{math.floor(serverWarTeamCfg.setTroopsLimit/60)})," ",getlocal("serverwarteam_tanks_tip1")," "},25,{nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil})
    --     sceneGame:addChild(dialogLayer,self.layerNum+1)
    --     dialogLayer:setPosition(ccp(0,0))
    -- end
    -- local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    -- local spScale=1
    -- tipItem:setScale(spScale)
    -- local tipMenu = CCMenu:createWithItem(tipItem)
    -- tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-tipItem:getContentSize().width/2*spScale-30-100,G_VisibleSize.height-250))
    -- tipMenu:setTouchPriority(-(self.layerNum-1)*20-6)
    -- self.bgLayer:addChild(tipMenu,5)
    
    -- local function tmpFunc()
    -- end
    -- self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    -- self.maskSp:setOpacity(255)
    -- local size=CCSizeMake(G_VisibleSize.width-50,G_VisibleSizeHeight-235+40)
    -- self.maskSp:setContentSize(size)
    -- self.maskSp:setAnchorPoint(ccp(0.5,0))
    -- self.maskSp:setPosition(ccp(G_VisibleSize.width/2,30))
    -- self.maskSp:setIsSallow(true)
    -- self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
    -- self.bgLayer:addChild(self.maskSp,4)
    
    -- self.cannotSaveLb=GetTTFLabelWrap(getlocal("serverwar_cannot_set_fleet2"),30,CCSizeMake(self.maskSp:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- self.cannotSaveLb:setAnchorPoint(ccp(0.5,0.5))
    -- self.cannotSaveLb:setPosition(getCenterPoint(self.maskSp))
    -- self.maskSp:addChild(self.cannotSaveLb,2)
    -- self.cannotSaveLb:setColor(G_ColorYellowPro)
    
    -- local gems=serverWarLocalVoApi:getGems()
    -- self.currentFundsLb=GetAllTTFLabel(getlocal("serverwarteam_funds_current",{gems}),28,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,197),self.bgLayer,1,G_ColorYellowPro,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local fundsDescLb=GetAllTTFLabel(getlocal("serverwarteam_funds_desc1"),25,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,143),self.bgLayer,1,nil,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local currentFundsLb=GetAllTTFLabel(str,28,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,197),self.bgLayer,1,G_ColorYellowPro,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local fundsDescLb=GetAllTTFLabel(str,25,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,143),self.bgLayer,1,nil,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    
    -- self:tick()
end

function serverWarLocalTroopsSubTab21:tick()
    -- if self then
    --     local setFleetStatus=serverWarLocalVoApi:getSetFleetStatus()
    --     if setFleetStatus and setFleetStatus>=0 then
    --         if setFleetStatus==0 then
    --             -- if self.maxPowerBtn then
    --             --     self.maxPowerBtn:setEnabled(true)
    --             -- end
    --             if self.saveBtn then
    --                 self.saveBtn:setEnabled(true)
    --             end
    --             -- if self.maskSp then
    --             --     self.maskSp:setPosition(ccp(10000,0))
    --             -- end
    --         else
    --             -- if self.maxPowerBtn then
    --             --     self.maxPowerBtn:setEnabled(false)
    --             -- end
    --             if self.saveBtn then
    --                 self.saveBtn:setEnabled(false)
    --             end
    --             -- if self.maskSp then
    --             --     self.maskSp:setPosition(ccp(G_VisibleSize.width/2,30))
    --             -- end
    
    --             -- if self.cannotSaveLb then
    --             --     if setFleetStatus==1 then
    --             --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet1"))
    --             --     elseif setFleetStatus==2 then
    --             --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet2"))
    --             --     elseif setFleetStatus==3 then
    --             --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet3"))
    --             --     elseif setFleetStatus==4 then
    --             --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet4"))
    --             --     elseif setFleetStatus==5 then
    --             --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet5"))
    --             --     end
    --             -- end
    --         end
    --     end
    
    --     -- if self.currentFundsLb then
    --     --     local gems=serverWarLocalVoApi:getGems()
    --     --     self.currentFundsLb:setString(getlocal("serverwarteam_funds_current",{gems}))
    --     -- end
    
    --     -- if serverWarLocalVoApi:getLeftGems()==true then
    --     --     self.tipSp:setVisible(true)
    --     -- else
    --     --     self.tipSp:setVisible(false)
    --     -- end
    
    --     -- local lastTime=serverWarLocalVoApi:getLastSetFleetTime() or 0
    --  --    local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
    --  --    if leftTime>0 then
    --  --        if self.saveBtn and self.saveBtn:isEnabled()==true then
    --  --            self.saveBtn:setEnabled(false)
    --  --        end
    
    --  --        if self.saveTimeLb then
    --  --            self.saveTimeLb:setVisible(true)
    --  --        end
    --  --        if self.leftTimeLb then
    --  --            self.leftTimeLb:setVisible(true)
    --  --            self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
    --  --        end
    --  --    else
    --  --        if self.saveTimeLb then
    --  --            self.saveTimeLb:setVisible(false)
    --  --        end
    --  --        if self.leftTimeLb then
    --  --            self.leftTimeLb:setVisible(false)
    --  --        end
    --  --    end
    -- end
end

function serverWarLocalTroopsSubTab21:setTanksRestore()
    local tType = self.type + self.selectedTabIndex
    local troopsIndex = self.selectedTabIndex + 1
    for i = 1, 6 do
        local id = i
        if self["serverWarLocalTanks"..troopsIndex] and self["serverWarLocalTanks"..troopsIndex][id] and self["serverWarLocalTanks"..troopsIndex][id][1] then
            local tid = self["serverWarLocalTanks"..troopsIndex][id][1]
            local num = self["serverWarLocalTanks"..troopsIndex][id][2] or 0
            tankVoApi:setTanksByType(tType, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(tType, id)
        end
        -- tankVoApi:setServerWarLocalTempTanks(self["serverWarLocalTanks"..troopsIndex])
        
        if self["serverWarLocalHero"..troopsIndex] then
            local hid = self["serverWarLocalHero"..troopsIndex][id]
            if hid then
                heroVoApi:setServerWarLocalHeroByIndex(troopsIndex, id, hid)
            else
                heroVoApi:deleteServerWarLocalTroopsByIndex(troopsIndex)
            end
        end
        
        --重新保存AI部队
        if self["serverWarLocalAITroops"..troopsIndex] then
            local atid = self["serverWarLocalAITroops"..troopsIndex][id]
            if atid then
                AITroopsFleetVoApi:setServerWarLocalAITroopsByIndex(troopsIndex, id, atid)
            else
                AITroopsFleetVoApi:deleteServerWarLocalAITroopsByIndex(troopsIndex)
            end
        end
    end
    if self["serverWarLocalTanks"..troopsIndex] then
        tankVoApi:setServerWarLocalTempTanks(G_clone(self["serverWarLocalTanks"..troopsIndex]))
    end
    emblemVoApi:setTmpEquip(self["serverWarLocalEmblem"..troopsIndex], tType)
    planeVoApi:setTmpEquip(self["serverWarLocalPlane"..troopsIndex], tType)
    airShipVoApi:setTempLineupId(self["serverWarLocalAirship"..troopsIndex], tType)
end

function serverWarLocalTroopsSubTab21:updateData()
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
end
function serverWarLocalTroopsSubTab21:refresh()
    self:updateData()
    local tType = self.type + self.selectedTabIndex
    G_updateSelectTankLayer(tType, self.bgLayer, self.layerNum, self.currentShow[self.selectedTabIndex + 1])
    self:tick()
end

function serverWarLocalTroopsSubTab21:dispose()
    self:setTanksRestore()
    
    self.serverWarLocalTanks1 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalTanks2 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalTanks3 = {{}, {}, {}, {}, {}, {}}
    self.serverWarLocalHero1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalHero2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalHero3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalAITroops3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalEmblem1 = nil
    self.serverWarLocalEmblem2 = nil
    self.serverWarLocalEmblem3 = nil
    self.serverWarLocalPlane1 = nil
    self.serverWarLocalPlane2 = nil
    self.serverWarLocalPlane3 = nil
    self.serverWarLocalAirship1 = nil
    self.serverWarLocalAirship2 = nil
    self.serverWarLocalAirship3 = nil
    
    self.bgLayer = nil
    self.layerNum = nil
    
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    -- self.cannotSaveLb=nil
    -- self.maxPowerBtn=nil
    self.formationBtn = nil
    self.saveBtn = nil
    self.fundsBtn = nil
    self.currentShow = {1, 1, 1}
    self.currentFundsLb = nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    G_clearEditTroopsLayer(self.type + self.selectedTabIndex)
    self.selectedTabIndex = 0
end
