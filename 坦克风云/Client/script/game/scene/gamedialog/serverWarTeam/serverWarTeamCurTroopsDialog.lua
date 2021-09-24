serverWarTeamCurTroopsDialog = commonDialog:new()

function serverWarTeamCurTroopsDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    -- self.serverWarTeamCurTanks={{},{},{},{},{},{}}
    --    self.serverWarTeamCurHero={0,0,0,0,0,0}
    self.troopsType = 34
    self.currentShow = 1
    
    return nc
end

function serverWarTeamCurTroopsDialog:initTableView()
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 30, self.bgLayer:getContentSize().height - 105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height / 2 - 30))
    
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight), nil)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setAnchorPoint(ccp(0,0))
    -- self.tv:setPosition(ccp(20,40))
    -- self.tv:setMaxDisToBottomOrTop(120)
    -- self.bgLayer:addChild(self.tv)
    
    local function callback(flag)
        self.currentShow = flag + 1
    end
    -- self.serverWarTeamCurTanks=G_clone(tankVoApi:getTanksTbByType(self.troopsType))
    G_addSelectTankLayer(self.troopsType, self.bgLayer, self.layerNum, callback, true, 120, nil, true)
    -- self.serverWarTeamCurHero=G_clone(heroVoApi:getServerWarTeamCurHeroList())
    
    local function getTroopsCallback(fn, data)
        local ret, sData = base:checkServerData2(data)
        if ret == true then
            if sData.data and sData.data.acrossserver then
                -- local isEmpty=true
                local troops = {{}, {}, {}, {}, {}, {}}
                if sData.data.acrossserver.troops then
                    troops = sData.data.acrossserver.troops
                end
                -- if troops and SizeOfTable(troops)>0 then
                -- for k,v in pairs(troops) do
                -- if v and v[1] and v[2] and v[2]>0 then
                -- isEmpty=false
                -- end
                -- end
                -- end
                -- if isEmpty==true then
                -- troops=G_clone(tankVoApi:getTanksTbByType(10))
                -- end
                tankVoApi:clearTanksTbByType(self.troopsType)
                for k, v in pairs(troops) do
                    if v and SizeOfTable(v) > 0 and v[2] and v[2] > 0 then
                        local tid = (tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                        tankVoApi:setTanksByType(self.troopsType, k, tid, v[2])
                    else
                        tankVoApi:deleteTanksTbByType(self.troopsType, k)
                    end
                end
                
                local hero = sData.data.acrossserver.hero
                hero = heroVoApi:getBindFleetHeroList(hero, troops, self.troopsType)
                heroVoApi:setServerWarTeamCurHeroList(hero)
                
                --AI部队
                local aitroops = sData.data.acrossserver.aitroops
                aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, troops, self.troopsType)
                AITroopsFleetVoApi:setServerWarTeamCurAITroopsList(aitroops)
                
                --战斗中不能设置，取跨服军团战设置的军徽
                local emblemId = emblemVoApi:getBattleEquip(10)
                emblemVoApi:setBattleEquip(self.troopsType, emblemId)
                
                local planePos = planeVoApi:getBattleEquip(10)
                planeVoApi:setBattleEquip(self.troopsType, planePos)
                
                local airshipId = airShipVoApi:getBattleEquip(10)
                airShipVoApi:setBattleEquip(self.troopsType, airshipId)
                
                local tankTb, heroTb = G_clone(tankVoApi:getTanksTbByType(self.troopsType)), G_clone(heroVoApi:getServerWarTeamCurHeroList())
                aitroops = G_clone(AITroopsFleetVoApi:getServerWarTeamCurAITroopsList())
                G_updateSelectTankLayer(self.troopsType, self.bgLayer, self.layerNum, self.currentShow, tankTb, heroTb, nil, nil, aitroops, airshipId)
            end
        end
    end
    local warId, aid, roundID, battleID = serverWarTeamVoApi:getServerWarId(), playerVoApi:getPlayerAid(), serverWarTeamFightVoApi.battleData.roundID, serverWarTeamFightVoApi.battleData.battleID
    if warId and aid and roundID and battleID then
        socketHelper2:acrossserverGetactiontroops(warId, aid, roundID, battleID, getTroopsCallback)
    end
    
    local function nilFunc()
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png", CCRect(50, 50, 1, 1), nilFunc)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 50, 220))
    descBg:setAnchorPoint(ccp(0.5, 0))
    self.bgLayer:addChild(descBg, 1)
    if G_isIphone5() == true then
        descBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 85))
    else
        descBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 40))
    end
    
    self.leftTimeLb = GetTTFLabel(getlocal("costTime1", {0}), 25)
    self.leftTimeLb:setAnchorPoint(ccp(0.5, 0.5))
    self.leftTimeLb:setPosition(ccp(descBg:getContentSize().width / 2, descBg:getContentSize().height / 4 * 3 - 5))
    descBg:addChild(self.leftTimeLb, 1)
    self.leftTimeLb:setColor(G_ColorYellowPro)
    self.leftTimeLb:setVisible(false)
    
    self.descLb = GetTTFLabelWrap("", 25, CCSizeMake(descBg:getContentSize().width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.descLb:setAnchorPoint(ccp(0.5, 0.5))
    self.descLb:setPosition(ccp(descBg:getContentSize().width / 2, descBg:getContentSize().height / 2 - 10))
    descBg:addChild(self.descLb, 1)
    
    self:tick()
end

function serverWarTeamCurTroopsDialog:tick()
    local descStr = ""
    local leftTime = 0
    local isVisible = false
    local player = serverWarTeamFightVoApi:getPlayer()
    if player then
        if player.canMoveTime and player.canMoveTime > base.serverTime then
            --复活中
            isVisible = true
            leftTime = player.canMoveTime - base.serverTime
            descStr = getlocal("serverwarteam_troops_desc1")
        elseif player.arriveTime and player.arriveTime > base.serverTime then
            --行进中
            isVisible = true
            leftTime = player.arriveTime - base.serverTime
            descStr = getlocal("serverwarteam_troops_desc2")
        else
            local cityList = serverWarTeamFightVoApi:getCityList()
            local cityID = serverWarTeamFightVoApi:getPlayer().cityID
            if cityID and cityList and cityList[cityID] then
                local cityVo = cityList[cityID]
                if cityVo then
                    local cityName = getlocal(cityVo.cfg.name)
                    descStr = getlocal("serverwarteam_troops_desc3", {cityName})
                end
            end
        end
    end
    -- isVisible=true
    -- descStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    if self.leftTimeLb then
        self.leftTimeLb:setVisible(isVisible)
        self.leftTimeLb:setString(getlocal("costTime1", {leftTime}))
    end
    if self.descLb then
        self.descLb:setString(descStr)
    end
end

function serverWarTeamCurTroopsDialog:dispose()
    heroVoApi:clearTroops()
    self.currentShow = 1
end
