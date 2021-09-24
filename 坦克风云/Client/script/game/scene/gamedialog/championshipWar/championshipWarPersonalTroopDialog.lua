--军团锦标赛个人战设置部队页面
championshipWarPersonalTroopDialog = commonDialog:new()

function championshipWarPersonalTroopDialog:new(diffId)
    local nc = {
        diffId = diffId,
    }
    
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function championshipWarPersonalTroopDialog:doUserHandler()
    self.type = 38
    championshipWarVoApi:setAttackCheckpointDiffId(self.diffId)
    --进入设置部队前将之前的部队数据清空，每次都重新设置部队
    tankVoApi:clearTanksTbByType(self.type)
    heroVoApi:clearChampionshipWarPersonalHeroTb()
    AITroopsFleetVoApi:clearChampionshipWarPersonalAITroopsTb()
    emblemVoApi:setBattleEquip(self.type, nil)
    planeVoApi:setBattleEquip(self.type, nil)
end

function championshipWarPersonalTroopDialog:initTableView()
    local function addRes()
        spriteController:addPlist("public/reportyouhua.plist")
        spriteController:addTexture("public/reportyouhua.png")
    end
    G_addResource8888(addRes)
    
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local playerInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function()end)
    playerInfoBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 140))
    playerInfoBg:setAnchorPoint(ccp(0.5, 1))
    playerInfoBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 90)
    self.bgLayer:addChild(playerInfoBg)
    
    local iconWidth = 100
    local cfg = championshipWarVoApi:getWarCfg()
    local iconTb = championshipWarVoApi:getCurrentCheckpointIconId()
    local iconId = iconTb[self.diffId] or headCfg.default
    local iconFrameId = cfg.npcIconFrame[self.diffId]
    local iconPic = playerVoApi:getPersonPhotoName(iconId)
    local playerIconSp = playerVoApi:GetPlayerBgIcon(iconPic, nil, nil, nil, nil, iconFrameId)
    if playerIconSp then
        playerIconSp:setPosition(10, playerInfoBg:getContentSize().height / 2)
        playerIconSp:setAnchorPoint(ccp(0, 0.5))
        playerIconSp:setScale(iconWidth / playerIconSp:getContentSize().width)
        playerInfoBg:addChild(playerIconSp)
    end
    
    --第几关
    local checkpointLb = GetTTFLabel(getlocal("championshipWar_checkpoint_numth", {championshipWarVoApi:getCurrentCheckpointId()}), 22, true)
    checkpointLb:setAnchorPoint(ccp(0, 0.5))
    checkpointLb:setPosition(playerIconSp:getPositionX() + iconWidth + 10, playerInfoBg:getContentSize().height / 2 + 35)
    checkpointLb:setColor(G_ColorYellowPro)
    playerInfoBg:addChild(checkpointLb)
    
    --战力
    local fight = championshipWarVoApi:getCheckpointFight(self.diffId)
    local fightLb = GetTTFLabel(getlocal("ltzdz_fight") .. FormatNumber(fight), 20)
    fightLb:setAnchorPoint(ccp(0, 0.5))
    fightLb:setPosition(checkpointLb:getPositionX(), playerInfoBg:getContentSize().height / 2)
    playerInfoBg:addChild(fightLb)
    
    --带兵量
    local troopIconSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
    troopIconSp:setAnchorPoint(ccp(0, 0.5))
    troopIconSp:setScale(0.8)
    troopIconSp:setPosition(checkpointLb:getPositionX(), playerInfoBg:getContentSize().height / 2 - 35)
    playerInfoBg:addChild(troopIconSp, 2)
    local troopNum = championshipWarVoApi:getAttackCheckpointEnemyTroopNum(self.diffId)
    local troopNumLb = GetTTFLabel(FormatNumber(troopNum), 20)
    troopNumLb:setAnchorPoint(ccp(0, 0.5))
    troopNumLb:setPosition(troopIconSp:getPositionX() + troopIconSp:getContentSize().width * troopIconSp:getScale() + 10, playerInfoBg:getContentSize().height / 2 - 35)
    playerInfoBg:addChild(troopNumLb)
    
    --显示对方携带的飞机
    local troops, plane = championshipWarVoApi:getAttackCheckpointEnemyTroopInfo(self.diffId)
    if plane and plane.pid then
        local planeBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function () end)
        planeBg:setContentSize(CCSizeMake(90, 90))
        planeBg:setPosition(playerInfoBg:getContentSize().width - planeBg:getContentSize().width / 2 - 20, playerInfoBg:getContentSize().height / 2)
        playerInfoBg:addChild(planeBg)
        
        local takeLb = GetTTFLabel(getlocal("championshipWar_planeTake") .. ":", 20)
        takeLb:setPosition(planeBg:getContentSize().width / 2, planeBg:getContentSize().height - takeLb:getContentSize().height / 2 - 5)
        planeBg:addChild(takeLb)
        
        local planeWidth = 50
        local pic = planeVoApi:getPlaneSmallPic("p"..plane.pid)
        local planeSp = CCSprite:createWithSpriteFrameName(pic)
        planeSp:setScale(planeWidth / planeSp:getContentSize().width)
        planeSp:setPosition(planeBg:getContentSize().width / 2, planeSp:getContentSize().height * planeSp:getScale() / 2 + 15)
        planeBg:addChild(planeSp)
    end
    
    local layerPosY = G_VisibleSizeHeight - 80 - 200
    local troopLayer = CCLayer:create()
    troopLayer:setPosition(0, 0)
    self.bgLayer:addChild(troopLayer)
    self.troopLayer = troopLayer
    G_addSelectTankLayer(self.type, self.troopLayer, self.layerNum, nil, nil, nil, nil, nil, layerPosY)
    
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
    
    local buffDescTb = championshipWarVoApi:getTotalBuffDescStr()
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
        tipLb:setPosition(getCenterPoint(tipLb))
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
            local bestMenu = tolua.cast(self.troopLayer:getChildByTag(101), "CCMenu")
            if bestMenu then
                bestMenu:setVisible(false)
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
    
    local btnScale, priority, btnFontSize, btnPosY, zorder = 0.8, -(self.layerNum - 1) * 20 - 4, 25, 60, 3
    --挑战
    local function attack()
        local state = championshipWarVoApi:getWarState()
        if state ~= 10 then --不在个人战期间
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notin_personalwar"), 30)
            do return end
        end
        local checkpointId = championshipWarVoApi:getCurrentCheckpointId()
        local function attackHandler()
            self:close()
        end
        local function battleResultHandler(isVictory) --如果战斗胜利则在战斗结算页面关闭后弹出每五关的奖励页面
            if isVictory ~= true then
                do return end
            end
            local function refresh() --刷新一些页面
                eventDispatcher:dispatchEvent("championshipWarPersonalDialog.refreshUI", {refreshType = 1})
            end
            local warCfg = championshipWarVoApi:getWarCfg()
            if checkpointId > 0 and checkpointId % warCfg.extraStageReward == 0 then --达到5关标准
                championshipWarVoApi:showFiveStageRewardDialog(true, self.layerNum + 1, refresh)
            else
                refresh()
            end
        end
        local fleetinfo = tankVoApi:getTanksTbByType(self.type)
        local num = 0
        for k, v in pairs(fleetinfo) do
            local tankId, tankNum = v[1], v[2]
            if tankId and tankNum and tonumber(tankNum) > 0 then
                num = num + 1
            end
        end
        if num == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceWarNoArmy"), 30)
            do return end
        end
        local hero
        if heroVoApi:isHaveTroops() then
            hero = heroVoApi:getMachiningHeroList(fleetinfo)
        end
        local aitroops = AITroopsFleetVoApi:getMatchAITroopsList(fleetinfo)
        local emblemID = emblemVoApi:getTmpEquip(self.type)
        local planePos = planeVoApi:getTmpEquip(self.type)
        local airshipId = airShipVoApi:getTempLineupId(self.type)
        local realEmblemId = emblemVoApi:getEquipIdForBattle(emblemID)
        if realEmblemId ~= -1 then
            championshipWarVoApi:personalWarBattle(checkpointId, fleetinfo, hero, realEmblemId, planePos, aitroops, airshipId, self.diffId, attackHandler, battleResultHandler)
        end
    end
    G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 + 200, btnPosY), {getlocal("alliance_challenge_fight"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", attack, btnScale, priority, zorder)
    --阵型
    local function formationHandler(tank, hero)
        
    end
    -- G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 - 200, btnPosY), {getlocal("formation"), btnFontSize}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", attack, btnScale, priority, zorder)
    self.formationBtn = G_getFormationBtn(self.troopLayer, self.layerNum, 1, self.type, formationHandler, ccp(G_VisibleSizeWidth / 2 - 200, btnPosY), priority, btnScale)
end

function championshipWarPersonalTroopDialog:showAttributeLayer()
    self.attributeLayer:setVisible(true)
    if self.troopLayer then
        self.troopLayer:setVisible(false)
        local bestMenu = tolua.cast(self.troopLayer:getChildByTag(101), "CCMenu")
        if bestMenu then
            bestMenu:setVisible(false)
        end
    end
end

function championshipWarPersonalTroopDialog:showTroopLayer()
    if self.attributeLayer then
        self.attributeLayer:setVisible(false)
    end
    self.troopLayer:setVisible(true)
    local bestMenu = tolua.cast(self.troopLayer:getChildByTag(101), "CCMenu")
    if bestMenu then
        bestMenu:setVisible(true)
    end
end

function championshipWarPersonalTroopDialog:dispose()
    self.diffId = nil
    G_clearEditTroopsLayer(self.type)
    self.type = nil
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    self.formationBtn = nil
end
