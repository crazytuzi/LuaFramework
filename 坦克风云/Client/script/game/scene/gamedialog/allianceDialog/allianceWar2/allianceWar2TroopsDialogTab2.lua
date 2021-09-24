allianceWar2TroopsDialogTab2 = {}

function allianceWar2TroopsDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.type = 32
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
    
    self.allianceWar2Tanks = {{}, {}, {}, {}, {}, {}}
    self.allianceWar2Hero = {0, 0, 0, 0, 0, 0}
    self.allianceWar2AITroops = {0, 0, 0, 0, 0, 0}
    self.allianceWar2tskinList = nil
    
    self.currentShow = 1
    self.currentFundsLb = nil
    
    return nc
end

function allianceWar2TroopsDialogTab2:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTabLayer()
    self:doUserHandler()
    
    return self.bgLayer
end

function allianceWar2TroopsDialogTab2:initTabLayer()
    local function callback(flag)
        self.currentShow = flag + 1
    end
    self.allianceWar2Tanks = G_clone(tankVoApi:getTanksTbByType(self.type))
    -- G_dayin(self.allianceWar2Tanks)
    -- self.maxPowerBtn=G_addSelectTankLayer(self.type,self.bgLayer,self.layerNum,callback)
    G_addSelectTankLayer(self.type, self.bgLayer, self.layerNum, callback)
    tankVoApi:setAllianceWar2TempTanks(G_clone(tankVoApi:getTanksTbByType(self.type)))
    self.allianceWar2Hero = G_clone(heroVoApi:getAllianceWar2HeroList())
    self.allianceWar2AITroops = G_clone(AITroopsFleetVoApi:getAllianceWar2AITroopsList())
    self.allianceWar2tskinList = G_clone(tankSkinVoApi:getTankSkinListByBattleType(self.type))
    self:initSaveBtn()
    self:initFormationBtn()
    self:initDesc()
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        local setFleetStatus = allianceWar2VoApi:getSetFleetStatus()
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

function allianceWar2TroopsDialogTab2:initSaveBtn()
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
    
    -- local lastTime=allianceWar2VoApi:getLastSetFleetTime()
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

function allianceWar2TroopsDialogTab2:saveHandler(callback)
    local setFleetStatus, tipStr = allianceWar2VoApi:getSetFleetStatus()
    if setFleetStatus ~= 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
        do return end
    end
    
    -- local lastTime=allianceWar2VoApi:getLastSetFleetTime()
    -- if lastTime then
    --     local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
    --     if leftTime>0 then
    --         do return end
    --     end
    -- end
    
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
            local function callbackHandler(ret1, sData1)
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
                allianceWar2VoApi:setInitFlag(1)
                self.allianceWar2Tanks = G_clone(tankVoApi:getTanksTbByType(self.type))
                
                local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(self.type))
                tankSkinVoApi:setTankSkinListByBattleType(self.type, tskin)
                self.allianceWar2tskinList = tskin
                
                local heroList = heroVoApi:getTroopsHeroList()
                heroVoApi:setAllianceWar2HeroList(heroList)
                
                local aitroops = AITroopsFleetVoApi:getAITroopsTb()
                AITroopsFleetVoApi:setAllianceWar2AITroopsList(aitroops)
                
                self.allianceWar2Hero = G_clone(heroVoApi:getAllianceWar2HeroList())
                self.allianceWar2AITroops = G_clone(AITroopsFleetVoApi:getAllianceWar2AITroopsList())
                
                allianceWar2VoApi:setLastSetFleetTime(base.serverTime)
                local emblemID = emblemVoApi:getTmpEquip()
                emblemVoApi:setBattleEquip(self.type, emblemID)
                local planePos = planeVoApi:getTmpEquip()
                planeVoApi:setBattleEquip(self.type, planePos)
                --飞艇
                airShipVoApi:setBattleEquip(self.type, airShipVoApi:getTempLineupId())
                
                local savedTroops = {tanks = G_clone(tankVoApi:getTanksTbByType(self.type)), hero = G_clone(heroVoApi:getAllianceWar2HeroList()), aitroops = G_clone(AITroopsFleetVoApi:getAllianceWar2AITroopsList()), tskin = G_clone(self.allianceWar2tskinList)}
                allianceWar2VoApi:setSavedTroops(savedTroops)
                tankVoApi:setAllianceWar2TempTanks(G_clone(tankVoApi:getTanksTbByType(self.type)))
                allianceWar2VoApi:setCurHero(sData1)
                allianceWar2VoApi:setCurAITroops(sData1)
                allianceWar2VoApi:setCurTroopsSkin(sData1)
                -- 设置当前军徽
                -- allianceWar2VoApi:setCurEquip(sData1)
                
                -- print("save~~~~~~~")
                -- G_dayin(G_clone(tankVoApi:getTanksTbByType(type)))
                self:tick()
                if callback then
                    callback()
                end
            end
            local cityID = allianceWar2VoApi:getTargetCity()
            local status = allianceWar2VoApi:getStatus(cityID)
            if status == 30 then
                local function requestCallback(fn1, data1)
                    local ret1, sData1 = base:checkServerData(data1)
                    G_isShowTip = true
                    if ret1 == true then
                        callbackHandler(ret1, sData1)
                    end
                end
                local initFlag = nil
                if allianceWar2VoApi:getInitFlag() == -1 then
                    initFlag = true
                end
                G_isShowTip = false
                socketHelper:alliancewarnewGet(allianceWar2VoApi:getTargetCity(), initFlag, requestCallback)
            else
                callbackHandler()
            end
        end
    end
    local fleetInfo = tankVoApi:getTanksTbByType(self.type)
    local hero = nil
    if heroVoApi:isHaveTroops() == true then
        -- local heroList=heroVoApi:getAllianceWar2HeroList()
        local heroList = heroVoApi:getTroopsHeroList()
        hero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, self.type)
    end
    -- local aName
    -- if allianceVoApi:isHasAlliance() then
    --     local selfAlliance=allianceVoApi:getSelfAlliance()
    --     if selfAlliance and selfAlliance.name then
    --         aName=selfAlliance.name
    --     end
    -- end
    
    local aitroops = AITroopsFleetVoApi:getAITroopsTb()
    aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, self.type)
    
    local emblemID = emblemVoApi:getTmpEquip()
    local planePos = planeVoApi:getTmpEquip()
    local airshipId = airShipVoApi:getTempLineupId()
    local function saveCallback()
        emblemID = emblemVoApi:getEquipIdForBattle(emblemID)
        if emblemID ~= -1 then
            socketHelper:alliancewarnewSetinfo(fleetInfo, hero, setinfoHandler, emblemID, planePos, aitroops, airshipId)
        end
    end
    -- local costTanks,isSame=tankVoApi:setFleetCostTanks(self.allianceWar2Tanks,fleetInfo)
    local isChangeFleet, costTanks = self:isChangeFleet()
    -- print("isChangeFleet",isChangeFleet)
    if isChangeFleet == false then
        -- if isSame==true then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_war_no_change_save"), 30)
    else
        if costTanks and SizeOfTable(costTanks) > 0 then
            smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png", CCSizeMake(550, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, saveCallback, costTanks, 1)
        else
            saveCallback()
        end
    end
end

function allianceWar2TroopsDialogTab2:isChangeFleet()
    local fleetInfo = tankVoApi:getTanksTbByType(self.type)
    local costTanks, isSame = tankVoApi:setFleetCostTanks(self.allianceWar2Tanks, fleetInfo)
    
    local hero1 = heroVoApi:getBindFleetHeroList(self.allianceWar2Hero, self.allianceWar2Tanks, self.type, false)
    -- local heroList=heroVoApi:getWorldWarHeroList(self.selectedTabIndex+1)
    local heroList = heroVoApi:getTroopsHeroList()
    local hero2 = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, self.type, false)
    -- G_dayin(hero1)
    -- G_dayin(hero2)
    local isSameHero = heroVoApi:isSameHero(hero1, hero2)
    -- print("isSame",isSame)
    -- print("isSameHero",isSameHero)
    
    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self.allianceWar2AITroops, self.allianceWar2Tanks, self.type, false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb, fleetInfo, self.type, false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    
    local isSameEmblem = true
    local tmpEmblemID = emblemVoApi:getTmpEquip()
    local emblemID = emblemVoApi:getBattleEquip(self.type)
    if tmpEmblemID ~= emblemID then
        isSameEmblem = false
    end
    local isSamePlane = true
    local tmpPlanePos = planeVoApi:getTmpEquip()
    local planePos = planeVoApi:getBattleEquip(self.type)
    if tmpPlanePos ~= planePos then
        isSamePlane = false
    end
    local isSameAirship = true
    if airShipVoApi:getTempLineupId() ~= airShipVoApi:getBattleEquip(self.type) then
        isSameAirship = false
    end
    if isSame == true and isSameHero == true and isSameEmblem == true and isSamePlane == true and isSameAITroops == true and isSameAirship == true then
        return false, costTanks
    else
        return true, costTanks
    end
end

function allianceWar2TroopsDialogTab2:initFormationBtn()
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
        smallDialog:showFormationDialog("PanelHeaderPopup.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, getlocal("save_formation"), readCallback, self.type, self.currentShow, self.bgLayer)
    end
    self.formationBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", showFormation, nil, getlocal("formation"), 25)
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

function allianceWar2TroopsDialogTab2:initDesc()
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd, fn, idx)
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
    if G_isIphone5() == true then
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870 - 70))
    else
        descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 870))
    end
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0.5, 0))
    descBg:setIsSallow(false)
    descBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    descBg:setPosition(ccp(G_VisibleSizeWidth / 2, 105))
    self.bgLayer:addChild(descBg, 3)
    
    local content = {getlocal("local_war_troops_preset_desc3"), getlocal("local_war_troops_preset_desc4")}
    local color = {G_ColorWhite, G_ColorYellowPro}
    local tabelLb = G_LabelTableView(CCSizeMake(descBg:getContentSize().width - 20, descBg:getContentSize().height - 10), content, 22, kCCTextAlignmentLeft, color)
    tabelLb:setPosition(ccp(10, 5))
    tabelLb:setAnchorPoint(ccp(0, 0))
    tabelLb:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    tabelLb:setMaxDisToBottomOrTop(70)
    descBg:addChild(tabelLb, 5)
end

-- function allianceWar2TroopsDialogTab2:judgeFight()
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

function allianceWar2TroopsDialogTab2:doUserHandler()
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
    
    -- local gems=allianceWar2VoApi:getGems()
    -- self.currentFundsLb=GetAllTTFLabel(getlocal("serverwarteam_funds_current",{gems}),28,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,197),self.bgLayer,1,G_ColorYellowPro,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local fundsDescLb=GetAllTTFLabel(getlocal("serverwarteam_funds_desc1"),25,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,143),self.bgLayer,1,nil,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local currentFundsLb=GetAllTTFLabel(str,28,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,197),self.bgLayer,1,G_ColorYellowPro,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local fundsDescLb=GetAllTTFLabel(str,25,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,143),self.bgLayer,1,nil,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    
    -- self:tick()
end

function allianceWar2TroopsDialogTab2:tick()
    -- if self then
    --     local setFleetStatus=allianceWar2VoApi:getSetFleetStatus()
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
    --     --     local gems=allianceWar2VoApi:getGems()
    --     --     self.currentFundsLb:setString(getlocal("serverwarteam_funds_current",{gems}))
    --     -- end
    
    --     -- if allianceWar2VoApi:getLeftGems()==true then
    --     --     self.tipSp:setVisible(true)
    --     -- else
    --     --     self.tipSp:setVisible(false)
    --     -- end
    
    --     -- local lastTime=allianceWar2VoApi:getLastSetFleetTime() or 0
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

function allianceWar2TroopsDialogTab2:setTanksRestore()
    local tType = self.type
    for i = 1, 6 do
        local id = i
        if self.allianceWar2Tanks and self.allianceWar2Tanks[id] and self.allianceWar2Tanks[id][1] then
            local tid = self.allianceWar2Tanks[id][1]
            local num = self.allianceWar2Tanks[id][2] or 0
            tankVoApi:setTanksByType(tType, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(tType, id)
        end
        tankSkinVoApi:setTankSkinListByBattleType(self.type, G_clone(self.allianceWar2tskinList))
        if self.allianceWar2Hero then
            local hid = self.allianceWar2Hero[id]
            if hid then
                heroVoApi:setAllianceWar2HeroByPos(id, hid)
            else
                heroVoApi:clearAllianceWar2Troops()
            end
        end
        if self.allianceWar2AITroops then
            local atid = self.allianceWar2AITroops[id]
            if atid then
                AITroopsFleetVoApi:setAllianceWar2AITroopsByPos(id, atid)
            else
                AITroopsFleetVoApi:clearAllianceWar2AITroops()
            end
        end
    end
end

function allianceWar2TroopsDialogTab2:refresh()
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    self:setTanksRestore()
    G_updateSelectTankLayer(self.type, self.bgLayer, self.layerNum, self.currentShow)
    self:tick()
end

function allianceWar2TroopsDialogTab2:dispose()
    self:setTanksRestore()
    
    self.allianceWar2Tanks = {{}, {}, {}, {}, {}, {}}
    self.allianceWar2Hero = {0, 0, 0, 0, 0, 0}
    self.allianceWar2AITroops = {0, 0, 0, 0, 0, 0}
    
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
    tankSkinVoApi:clearTempTankSkinList(self.type)
end
