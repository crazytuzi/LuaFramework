serverWarTeamDialogTab2 = {}

function serverWarTeamDialogTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.tv = nil
    self.bgLayer = nil
    self.layerNum = nil
    -- self.selectedTabIndex=0
    self.serverWarDialog = nil
    
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    self.cannotSaveLb = nil
    
    self.maxPowerBtn = nil
    self.fundsBtn = nil
    
    self.serverWarTeamTanks = {{}, {}, {}, {}, {}, {}}
    self.serverWarTeamHero = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamAITroops = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamEquip = nil
    self.serverWarTeamPlane = nil
    
    self.currentShow = 1
    self.currentFundsLb = nil
    
    return nc
end

function serverWarTeamDialogTab2:init(layerNum, serverWarDialog)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.serverWarDialog = serverWarDialog
    
    self:initTableView()
    self:initTabLayer()
    self:doUserHandler()
    
    -- self.bgLayer1=CCLayer:create()
    -- self.bgLayer:addChild(self.bgLayer1,2)
    
    return self.bgLayer
end

--[[
function serverWarTeamDialogTab2:getDataByType(type)
if type==nil then
type=1
end
local flag=emailVoApi:getFlag(type)
local function showEmailList(fn,data)
if base:checkServerData(data)==true then
      self:refresh()
end
end
if self.noEmailLabel then
self.noEmailLabel:setVisible(false)
end
if flag==nil or flag==-1 then
socketHelper:emailList(type,0,0,showEmailList,1)
else
self:refresh()
end
end
]]

--设置对话框里的tableView
function serverWarTeamDialogTab2:initTableView()
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 50, G_VisibleSizeHeight), nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    -- self.tv:setPosition(ccp(50,115))
    -- self.bgLayer:addChild(self.tv,1)
    -- self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

function serverWarTeamDialogTab2:initTabLayer()
    local function callback(flag)
        self.currentShow = flag + 1
    end
    self.serverWarTeamTanks = G_clone(tankVoApi:getTanksTbByType(10))
    self.maxPowerBtn = G_addSelectTankLayer(10, self.bgLayer, self.layerNum, callback, nil, 0)
    self.serverWarTeamHero = G_clone(heroVoApi:getServerWarTeamHeroList())
    self.serverWarTeamAITroops = G_clone(AITroopsFleetVoApi:getServerWarTeamAITroopsList())
    self.serverWarTeamEquip = emblemVoApi:getBattleEquip(10)
    self.serverWarTeamPlane = planeVoApi:getBattleEquip(10)
    self.serverWarTeamAirship = airShipVoApi:getBattleEquip(10)
    self:initSaveBtn()
    self:initfundsBtn()
end

function serverWarTeamDialogTab2:initSaveBtn()
    local function save()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        -- local lastTime=serverWarTeamVoApi:getLastSetFleetTime()
        -- if lastTime then
        --     local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
        --     if leftTime>0 then
        --         do return end
        --     end
        -- end
        
        local isEable = true
        local num = 0;
        local type = 10
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
        
        local fleetInfo = tankVoApi:getTanksTbByType(10)
        local hero = nil
        if heroVoApi:isHaveTroops() == true then
            -- local heroList=heroVoApi:getServerWarTeamHeroList()
            local heroList = heroVoApi:getTroopsHeroList()
            hero = heroVoApi:getBindFleetHeroList(heroList, fleetInfo, 10)
        end
        local aitroops = AITroopsFleetVoApi:getAITroopsTb()
        local AITroopsTb = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, 10)
        local function setBattleInfoHandler(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("save_success"), 30)
                local btype = 10
                self.serverWarTeamTanks = G_clone(tankVoApi:getTanksTbByType(btype))
                
                local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(btype))
                tankSkinVoApi:setTankSkinListByBattleType(btype, tskin)
                
                local heroList = {0, 0, 0, 0, 0, 0}
                if hero then
                    heroList = hero
                end
                heroVoApi:setServerWarTeamHeroList(heroList)
                AITroopsFleetVoApi:setServerWarTeamAITroopsList(AITroopsTb)
                self.serverWarTeamHero = G_clone(heroVoApi:getServerWarTeamHeroList())
                self.serverWarTeamAITroops = G_clone(AITroopsFleetVoApi:getServerWarTeamAITroopsList())
                -- 超级装备
                local equipId = emblemVoApi:getTmpEquip()
                equipId = emblemVoApi:getEquipIdStr(equipId)
                emblemVoApi:setBattleEquip(btype, equipId)
                self.serverWarTeamEquip = equipId
                -- 飞机
                local planePos = planeVoApi:getTmpEquip()
                planeVoApi:setBattleEquip(btype, equipId)
                self.serverWarTeamPlane = planePos
                --飞艇
                self.serverWarTeamAirship = airShipVoApi:getTempLineupId()
                airShipVoApi:setBattleEquip(btype, self.serverWarTeamAirship)
                
                serverWarTeamVoApi:setLastSetFleetTime(base.serverTime)
                self:tick()
            elseif sData.ret == -21013 then
                local function sureCallBackHandler()
                    if G_checkClickEnable() == false then
                        do
                            return
                        end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    
                    local function clearSetFleetHandler(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            self.serverWarTeamTanks = {{}, {}, {}, {}, {}, {}}
                            self.serverWarTeamHero = {0, 0, 0, 0, 0, 0}
                            self.serverWarTeamAITroops = {0, 0, 0, 0, 0, 0}
                            self.serverWarTeamEquip = nil
                            self.serverWarTeamPlane = nil
                            self.serverWarTeamAirship = nil
                            self:setTanksRestore()
                            if self.bgLayer then
                                G_updateSelectTankLayer(10, self.bgLayer, self.layerNum, self.currentShow)
                            end
                        end
                    end
                    socketHelper:acrossSetinfo(nil, nil, nil, nil, 1, clearSetFleetHandler)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), sureCallBackHandler, getlocal("dialog_title_prompt"), getlocal("backstage5015"), nil, self.layerNum + 1)
            end
        end
        local aName
        if allianceVoApi:isHasAlliance() then
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.name then
                aName = selfAlliance.name
            end
        end
        local emblemID = emblemVoApi:getTmpEquip()
        local planePos = planeVoApi:getTmpEquip()
        local airshipId = airShipVoApi:getTempLineupId()
        emblemID = emblemVoApi:getEquipIdForBattle(emblemID)
        if emblemID ~= -1 then
            socketHelper:acrossSetinfo(nil, fleetInfo, hero, aName, nil, setBattleInfoHandler, emblemID, planePos, AITroopsTb, airshipId)
        end
    end
    self.saveBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", save, nil, getlocal("arena_save"), 25)
    local saveMenu = CCMenu:createWithItem(self.saveBtn)
    saveMenu:setPosition(ccp(520, 80))
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
    
    -- local lastTime=serverWarTeamVoApi:getLastSetFleetTime()
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

function serverWarTeamDialogTab2:initfundsBtn()
    local function showFundsDialog()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        smallDialog:showBattleFundsDialog("PanelHeaderPopup.png", CCSizeMake(550, 650), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, getlocal("serverwarteam_funds_title"), nil)
    end
    self.fundsBtn = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", showFundsDialog, nil, getlocal("serverwarteam_funds"), 25)
    local fundsMenu = CCMenu:createWithItem(self.fundsBtn)
    fundsMenu:setPosition(ccp(120, 80))
    fundsMenu:setTouchPriority((-(self.layerNum - 1) * 20 - 4))
    self.bgLayer:addChild(fundsMenu, 3)
    
    self.tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
    self.tipSp:setPosition(ccp(self.fundsBtn:getContentSize().width - 10, self.fundsBtn:getContentSize().height - 10))
    self.tipSp:setTag(11)
    self.tipSp:setVisible(false)
    self.fundsBtn:addChild(self.tipSp)
end

-- function serverWarTeamDialogTab2:judgeFight()
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

function serverWarTeamDialogTab2:doUserHandler()
    local function tipTouch()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local sd = smallDialog:new()
        local dialogLayer = sd:init("TankInforPanel.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, {" ", getlocal("serverwarteam_tanks_tip5"), " ", getlocal("serverwarteam_tanks_tip4"), " ", getlocal("serverwarteam_tanks_tip3"), " ", getlocal("serverwarteam_tanks_tip2", {math.floor(serverWarTeamCfg.setTroopsLimit / 60)}), " ", getlocal("serverwarteam_tanks_tip1"), " "}, 25, {nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil})
        sceneGame:addChild(dialogLayer, self.layerNum + 1)
        dialogLayer:setPosition(ccp(0, 0))
    end
    local tipItem = GetButtonItem("BtnInfor.png", "BtnInfor_Down.png", "BtnInfor_Down.png", tipTouch, 11, nil, nil)
    local spScale = 0.8
    tipItem:setScale(spScale)
    local tipMenu = CCMenu:createWithItem(tipItem)
    -- tipMenu:setPosition(ccp(self.bgLayer:getContentSize().width-tipItem:getContentSize().width/2*spScale-30-100,G_VisibleSize.height-210))
    tipMenu:setPosition(ccp(60, 160))
    if G_isIphone5() == true then
        tipMenu:setPosition(ccp(60, 160 + 50))
    end
    tipMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 6)
    self.bgLayer:addChild(tipMenu, 5)
    
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
    
    local currentFundsPy, fundsDescPy = 185, 143
    if G_isIphone5() == true then
        currentFundsPy, fundsDescPy = 185 + 60, 143 + 40
    end
    local gems = serverWarTeamVoApi:getGems()
    self.currentFundsLb = GetAllTTFLabel(getlocal("serverwarteam_funds_current", {gems}), 28, ccp(0.5, 0.5), ccp(G_VisibleSizeWidth / 2 + 30, currentFundsPy), self.bgLayer, 1, G_ColorYellowPro, CCSize(G_VisibleSizeWidth - 60 - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    local fundsDescLb = GetAllTTFLabel(getlocal("serverwarteam_funds_desc1"), 25, ccp(0.5, 0.5), ccp(G_VisibleSizeWidth / 2 + 30, fundsDescPy), self.bgLayer, 1, nil, CCSize(G_VisibleSizeWidth - 60 - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local currentFundsLb=GetAllTTFLabel(str,28,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,197),self.bgLayer,1,G_ColorYellowPro,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local fundsDescLb=GetAllTTFLabel(str,25,ccp(0.5,0.5),ccp(G_VisibleSizeWidth/2,143),self.bgLayer,1,nil,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    
    self:tick()
end

function serverWarTeamDialogTab2:tick()
    if self then
        local setFleetStatus = serverWarTeamVoApi:getSetFleetStatus()
        if setFleetStatus and setFleetStatus >= 0 then
            if setFleetStatus == 0 then
                if self.maxPowerBtn then
                    self.maxPowerBtn:setEnabled(true)
                end
                if self.saveBtn then
                    self.saveBtn:setEnabled(true)
                end
                -- if self.maskSp then
                --     self.maskSp:setPosition(ccp(10000,0))
                -- end
            else
                if self.maxPowerBtn then
                    self.maxPowerBtn:setEnabled(false)
                end
                if self.saveBtn then
                    self.saveBtn:setEnabled(false)
                end
                -- if self.maskSp then
                --     self.maskSp:setPosition(ccp(G_VisibleSize.width/2,30))
                -- end
                
                -- if self.cannotSaveLb then
                --     if setFleetStatus==1 then
                --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet1"))
                --     elseif setFleetStatus==2 then
                --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet2"))
                --     elseif setFleetStatus==3 then
                --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet3"))
                --     elseif setFleetStatus==4 then
                --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet4"))
                --     elseif setFleetStatus==5 then
                --         self.cannotSaveLb:setString(getlocal("serverwar_cannot_set_fleet5"))
                --     end
                -- end
            end
        end
        
        if self.currentFundsLb then
            local gems = serverWarTeamVoApi:getGems()
            self.currentFundsLb:setString(getlocal("serverwarteam_funds_current", {gems}))
        end
        
        if serverWarTeamVoApi:getLeftGems() == true then
            self.tipSp:setVisible(true)
        else
            self.tipSp:setVisible(false)
        end
        
        -- local lastTime=serverWarTeamVoApi:getLastSetFleetTime() or 0
        --    local leftTime=serverWarTeamCfg.settingTroopsLimit-(base.serverTime-lastTime)
        --    if leftTime>0 then
        --        if self.saveBtn and self.saveBtn:isEnabled()==true then
        --            self.saveBtn:setEnabled(false)
        --        end
        
        --        if self.saveTimeLb then
        --            self.saveTimeLb:setVisible(true)
        --        end
        --        if self.leftTimeLb then
        --            self.leftTimeLb:setVisible(true)
        --            self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
        --        end
        --    else
        --        if self.saveTimeLb then
        --            self.saveTimeLb:setVisible(false)
        --        end
        --        if self.leftTimeLb then
        --            self.leftTimeLb:setVisible(false)
        --        end
        --    end
    end
end

function serverWarTeamDialogTab2:setTanksRestore()
    local tType = 10
    for i = 1, 6 do
        local id = i
        if self.serverWarTeamTanks and self.serverWarTeamTanks[id] and self.serverWarTeamTanks[id][1] then
            local tid = self.serverWarTeamTanks[id][1]
            local num = self.serverWarTeamTanks[id][2] or 0
            tankVoApi:setTanksByType(tType, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(tType, id)
        end
        
        if self.serverWarTeamHero then
            local hid = self.serverWarTeamHero[id]
            if hid then
                heroVoApi:setServerWarTeamHeroByPos(id, hid)
            else
                heroVoApi:clearServerWarTeamTroops()
            end
        end
        --AI部队保存
        if self.serverWarTeamAITroops then
            local atid = self.serverWarTeamAITroops[id]
            if atid then
                AITroopsFleetVoApi:setServerWarTeamAITroopsByPos(id, atid)
            else
                AITroopsFleetVoApi:setServerWarTeamAITroopsByPos(id, 0)
            end
        end
    end
    emblemVoApi:setBattleEquip(tType, self.serverWarTeamEquip)
    planeVoApi:setBattleEquip(tType, self.serverWarTeamPlane)
    airShipVoApi:setBattleEquip(tType, self.serverWarTeamAirship)
end

function serverWarTeamDialogTab2:refresh()
    
end

function serverWarTeamDialogTab2:dispose()
    self:setTanksRestore()
    
    G_clearEditTroopsLayer(10)
    
    self.serverWarTeamTanks = {{}, {}, {}, {}, {}, {}}
    self.serverWarTeamHero = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamAITroops = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamEquip = nil
    self.serverWarTeamPlane = nil
    self.serverWarTeamAirship = nil
    self.tv = nil
    self.bgLayer = nil
    self.layerNum = nil
    self.selectedTabIndex = 0
    -- self.serverWarTanks=nil
    -- self.maskSp=nil
    -- self.saveTimeLb=nil
    -- self.leftTimeLb=nil
    self.cannotSaveLb = nil
    self.maxPowerBtn = nil
    self.fundsBtn = nil
    self.currentShow = 1
    self.currentFundsLb = nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
end
