--军团锦标赛军团战个人设置部队页面
championshipWarAllianceTroopDialog = commonDialog:new()

function championshipWarAllianceTroopDialog:new()
    local nc = {}
    
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function championshipWarAllianceTroopDialog:doUserHandler()
    self.type = 39
    self:reInitTroop()
end

function championshipWarAllianceTroopDialog:reInitTroop()
    self.allianceWarTrooop = G_clone(tankVoApi:getTanksTbByType(self.type)) --坦克
    self.allianceWarHero = G_clone(heroVoApi:getChampionshipWarHeroTb()) --将领
    tankVoApi:setChampionshipWarTempTanks(G_clone(tankVoApi:getTanksTbByType(self.type)))
    --AI部队
    self.allianceWarAITroops = G_clone(AITroopsFleetVoApi:getChampionshipWarAITroopsTb())
    local emblemID = emblemVoApi:getTmpEquip()
    emblemID = emblemVoApi:getEquipIdStr(emblemID)
    self.allianceWarEmblem = emblemID --军徽
    local planePos = planeVoApi:getTmpEquip()
    self.allianceWarPlane = planePos --飞机
    self.warAirship = airShipVoApi:getTempLineupId() --飞艇
end

function championshipWarAllianceTroopDialog:initTableView()
    local function addRes()
        spriteController:addPlist("public/reportyouhua.plist")
        spriteController:addTexture("public/reportyouhua.png")
    end
    G_addResource8888(addRes)
    
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local layerPosY = G_VisibleSizeHeight - 85 - 60
    local troopLayer = CCLayer:create()
    troopLayer:setPosition(0, 0)
    self.bgLayer:addChild(troopLayer)
    self.troopLayer = troopLayer
    G_addSelectTankLayer(self.type, self.troopLayer, self.layerNum, nil, true, nil, nil, nil, layerPosY)
    
    local settroopTipLb = GetTTFLabelWrap(getlocal("championshipWar_settroop_tip"), 22, CCSize(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    settroopTipLb:setColor(G_ColorRed)
    if G_isIphone5() == true then
        settroopTipLb:setPosition(G_VisibleSizeWidth / 2, 255)
    else
        settroopTipLb:setPosition(G_VisibleSizeWidth / 2, 200)
    end
    self.troopLayer:addChild(settroopTipLb)
    
    local attributeLayer = CCLayer:create()
    attributeLayer:setPosition(0, 0)
    self.bgLayer:addChild(attributeLayer)
    self.attributeLayer = attributeLayer
    self.attributeLayer:setPosition(G_VisibleSizeWidth, 0)
    self.attributeLayer:setVisible(false)
    
    local attrBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function ()end)
    attrBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, layerPosY - 150))
    attrBg:setAnchorPoint(ccp(0.5, 1))
    attrBg:setPosition(G_VisibleSizeWidth / 2, layerPosY + 35)
    self.attributeLayer:addChild(attrBg)
    
    local titleBg = G_createNewTitle({getlocal("battlebuff_overview"), 24}, CCSizeMake(300, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(attrBg:getContentSize().width / 2, attrBg:getContentSize().height - 40)
    attrBg:addChild(titleBg)
    
    local buffDescTb = championshipWarVoApi:getTotalBuffDescStr(true)
    local fontSize, fontWidth = 22, attrBg:getContentSize().width - 40
    local cellHeightTb = {}
    local cellNum = SizeOfTable(buffDescTb)
    for k, v in pairs(buffDescTb) do
        local descLb, lbheight = G_getRichTextLabel(v[1], v[2], fontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        cellHeightTb[k] = lbheight + 10
    end
    if cellNum == 0 then
        local tipLb = GetTTFLabelWrap(getlocal("championshipWar_no_buff"), 22, CCSize(attrBg:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipLb:setColor(G_ColorGray2)
        tipLb:setPosition(getCenterPoint(attrBg))
        attrBg:addChild(tipLb)
    end
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(fontWidth, cellHeightTb[idx + 1])
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local cellHeight = cellHeightTb[idx + 1]
            local desc = buffDescTb[idx + 1]
            local descLb, lbheight = G_getRichTextLabel(desc[1], desc[2], fontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(0, 5 + lbheight)
            cell:addChild(descLb)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(fontWidth, attrBg:getContentSize().height - 70), nil)
    tv:setPosition((attrBg:getContentSize().width - fontWidth) / 2, 5)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    tv:setMaxDisToBottomOrTop(120)
    attrBg:addChild(tv)
    
    self.showIdx, self.moving = 1, false
    --属性总览
    local function switchHandler()
        if self.moving == true then
            do return end
        end
        local function realShow()
            local detailLb = tolua.cast(self.switchBtn:getChildByTag(101), "CCLabelTTF")
            local moveDis = 0
            if self.showIdx == 1 then
                self.showIdx = 2
                detailLb:setString(getlocal("championshipWar_troop_overview"))
                moveDis = -G_VisibleSizeWidth
            else
                self.showIdx = 1
                detailLb:setString(getlocal("battlebuff_overview"))
                moveDis = G_VisibleSizeWidth
            end
            self.moving = true
            self.troopLayer:setVisible(true)
            self.attributeLayer:setVisible(true)
            for i = 1, 2 do
                local moveBy = CCMoveBy:create(0.5, ccp(moveDis, 0))
                local function moveEnd()
                    self.moving = false
                    if self.showIdx == 1 then
                        self:showTroopLayer()
                    else
                        self:showAttributeLayer()
                    end
                end
                if i == 1 then
                    self.troopLayer:runAction(CCSequence:createWithTwoActions(moveBy, CCCallFunc:create(moveEnd)))
                else
                    self.attributeLayer:runAction(moveBy)
                end
            end
        end
        
        G_touchedItem(self.switchBtn, realShow, 0.9)
    end
    local switchBtn = LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png", switchHandler)
    switchBtn:setPosition(G_VisibleSizeWidth / 2, 120)
    switchBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(switchBtn, 5)
    self.switchBtn = switchBtn
    local detailLb = GetTTFLabel(getlocal("battlebuff_overview"), 24, true)
    detailLb:setPosition(getCenterPoint(switchBtn))
    detailLb:setTag(101)
    switchBtn:addChild(detailLb)
    for i = 1, 2 do
        local arrowSp = CCSprite:createWithSpriteFrameName("reportArrow.png")
        if i == 1 then
            arrowSp:setPosition(150, switchBtn:getContentSize().height / 2)
        else
            arrowSp:setPosition(switchBtn:getContentSize().width - 150, switchBtn:getContentSize().height / 2)
            arrowSp:setRotation(180)
        end
        switchBtn:addChild(arrowSp)
    end
    
    local btnScale, priority, btnFontSize, btnPosY = 0.8, -(self.layerNum - 1) * 20 - 4, 25, 60
    --保存部队
    local function saveTroop()
        self:saveHandler()
    end
    G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 + 200, btnPosY), {getlocal("setFleet"), btnFontSize}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", saveTroop, btnScale, priority)
    
    local function close()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local flag = championshipWarVoApi:isCanSetTroop()
        local changeFlag, costTanks = self:isChangeTroop()
        if flag == 1 and changeFlag == true then
            local function onConfirm()
                local function saveBack()
                    self:close()
                end
                self:saveHandler(saveBack)
            end
            local function onCancle()
                self:close()
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("world_war_set_changed_fleet"), nil, self.layerNum + 1, nil, nil, onCancle)
        else
            self:close()
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

function championshipWarAllianceTroopDialog:showAttributeLayer()
    self.attributeLayer:setVisible(true)
    if self.troopLayer then
        self.troopLayer:setVisible(false)
    end
end

function championshipWarAllianceTroopDialog:showTroopLayer()
    if self.attributeLayer then
        self.attributeLayer:setVisible(false)
    end
    self.troopLayer:setVisible(true)
end

function championshipWarAllianceTroopDialog:saveHandler(callback)
    local flag = championshipWarVoApi:isCanSetTroop()
    if flag ~= 1 then
        if flag == -1 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_set_troop_toooften"), 30)
        elseif flag == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notset_troop"), 30)
        end
        do return end
    end
    
    local isEable = true
    local num = 0
    local tankTb = tankVoApi:getTanksTbByType(self.type)
    for k, v in pairs(tankTb) do
        if SizeOfTable(v) == 0 then
            num = num + 1
        end
    end
    if num == 6 then
        isEable = false
    end
    if isEable == false then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("allianceWarNoArmy"), nil, self.layerNum + 1, nil)
        do return end
    end
    
    local function setinfoHandler(troopsReward)
        local tipsStr = getlocal("save_success")
        if troopsReward then
            local rewardTb = FormatItem(troopsReward)
            for k, v in pairs(rewardTb) do
                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
            end
            tipsStr = getlocal("save_success") .. "," .. getlocal("championshipWar_grantGoldTips")
        end
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipsStr, 30)
        local heroList = heroVoApi:getTroopsHeroList()
        heroVoApi:setChampionshipWarHeroTb(heroList)
        --AI部队
        local aitroops = AITroopsFleetVoApi:getAITroopsTb()
        AITroopsFleetVoApi:setChampionshipWarAITroopsTb(aitroops)
        local emblemID = emblemVoApi:getTmpEquip()
        emblemID = emblemVoApi:getEquipIdStr(emblemID)
        emblemVoApi:setBattleEquip(self.type, emblemID)
        local planePos = planeVoApi:getTmpEquip()
        planeVoApi:setBattleEquip(self.type, planePos)
        
        airShipVoApi:setBattleEquip(self.type, airShipVoApi:getTempLineupId()) --飞艇
        
        local tskin = G_clone(tankSkinVoApi:getTempTankSkinList(self.type))
        tankSkinVoApi:setTankSkinListByBattleType(self.type, tskin)
        
        self:reInitTroop()
    end
    local tankTb = tankVoApi:getTanksTbByType(self.type)
    local hero = nil
    if heroVoApi:isHaveTroops() == true then
        local heroList = heroVoApi:getTroopsHeroList()
        hero = heroVoApi:getBindFleetHeroList(heroList, tankTb, self.type)
    end
    
    --AI部队
    local aitroops = AITroopsFleetVoApi:getAITroopsTb()
    aitroops = AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, tankTb, self.type)
    
    local emblemID = emblemVoApi:getTmpEquip()
    local planePos = planeVoApi:getTmpEquip()
    local airshipId = airShipVoApi:getTempLineupId()
    local function saveCallback()
        local realEmblemId = emblemVoApi:getEquipIdForBattle(emblemID)
        if realEmblemId ~= -1 then
            championshipWarVoApi:championshipWarSetTroops(tankTb, hero, realEmblemId, planePos, aitroops, airshipId, setinfoHandler)
        end
    end
    local isChangeTroop, costTanks = self:isChangeTroop()
    if isChangeTroop == false then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_war_no_change_save"), 30)
    else
        if costTanks and SizeOfTable(costTanks) > 0 then
            local exchangeRate = championshipWarVoApi:getWarCfg().tankeTransRate
            smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png", CCSizeMake(550, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, self.layerNum + 1, saveCallback, costTanks, nil, exchangeRate)
        else
            saveCallback()
        end
    end
end

function championshipWarAllianceTroopDialog:isChangeTroop()
    local tankTb = tankVoApi:getTanksTbByType(self.type)
    local costTanks, isSame = tankVoApi:setFleetCostTanks(self.allianceWarTrooop, tankTb)
    
    local hero1 = heroVoApi:getBindFleetHeroList(self.allianceWarHero, self.allianceWarTrooop, self.type, false)
    local heroList = heroVoApi:getTroopsHeroList()
    local hero2 = heroVoApi:getBindFleetHeroList(heroList, tankTb, self.type, false)
    local isSameHero = heroVoApi:isSameHero(hero1, hero2)
    
    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self.allianceWarAITroops, self.allianceWarTrooop, self.type, false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb, tankTb, self.type, false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    
    local isSameEmblem = true
    local tmpEmblemId = emblemVoApi:getTmpEquip()
    local emblemID = emblemVoApi:getBattleEquip(self.type)
    if tmpEmblemId ~= emblemID then
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
    if isSame == true and isSameHero == true and isSameEmblem and isSamePlane and isSameAITroops == true and isSameAirship == true then
        return false, costTanks
    else
        return true, costTanks
    end
end

--恢复原来的保存部队
function championshipWarAllianceTroopDialog:restoreTroop()
    for id = 1, 6 do
        if self.allianceWarTrooop and self.allianceWarTrooop[id] and self.allianceWarTrooop[id][1] then
            local tid = self.allianceWarTrooop[id][1]
            local num = self.allianceWarTrooop[id][2] or 0
            tankVoApi:setTanksByType(self.type, id, tid, num)
        else
            tankVoApi:deleteTanksTbByType(self.type, id)
        end
        
        if self.allianceWarHero then --将领
            local hid = self.allianceWarHero[id]
            if hid then
                heroVoApi:setChampionshipWarHeroByPos(id, hid)
            else
                heroVoApi:clearChampionshipWarHeroTb()
            end
        end
        
        if self.allianceWarAITroops then --AI部队
            local atid = self.allianceWarAITroops[id]
            if atid then
                AITroopsFleetVoApi:setChampionshipWarAITroopsByPos(id, atid)
            else
                AITroopsFleetVoApi:clearChampionshipWarAITroopsTb()
            end
        end
    end
    if self.allianceWarEmblem then --军徽
        emblemVoApi:setTmpEquip(self.allianceWarEmblem, self.type)
        self.allianceWarEmblem = emblemVoApi:getEquipIdStr(self.allianceWarEmblem)
        emblemVoApi:setBattleEquip(self.type, self.allianceWarEmblem)
    end
    if self.allianceWarPlane then --飞机
        planeVoApi:setTmpEquip(self.allianceWarPlane, self.type)
        planeVoApi:setBattleEquip(self.type, self.allianceWarPlane)
    end
    if self.warAirship then --飞艇
        airShipVoApi:setTempLineupId(self.warAirship)
        airShipVoApi:setBattleEquip(self.type, self.warAirship)
    end
    tankVoApi:setChampionshipWarTempTanks(G_clone(tankVoApi:getTanksTbByType(self.type)))
end

function championshipWarAllianceTroopDialog:dispose()
    self:restoreTroop()
    
    self.allianceWarTrooop = nil
    self.allianceWarHero = nil
    self.allianceWarAITroops = nil
    self.allianceWarEmblem = nil
    self.allianceWarPlane = nil
    self.warAirship = nil
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    G_clearEditTroopsLayer(self.type)
    self.type = nil
end
