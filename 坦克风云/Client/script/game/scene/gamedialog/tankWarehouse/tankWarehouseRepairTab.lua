local tankWarehouseRepairTab = {}

function tankWarehouseRepairTab:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tankWarehouseRepairTab:init(layerNum, parent)
    self.layerNum = layerNum
    self.parent = parent
    self.bgLayer = CCLayer:create()
    self.bid = 15
    
    local posY = G_VisibleSizeHeight - 90
    local bgHeight = 100
    local totalRepairBg = LuaCCScale9Sprite:createWithSpriteFrameName("brown_kuang2.png", CCRect(16, 16, 1, 1), function () end)
    totalRepairBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, bgHeight))
    totalRepairBg:setPosition(G_VisibleSizeWidth / 2, posY - bgHeight / 2)
    self.bgLayer:addChild(totalRepairBg)
    
    local totalRepairLb = GetTTFLabelWrap(getlocal("repairAll"), 24, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    totalRepairLb:setAnchorPoint(ccp(0, 0.5))
    totalRepairLb:setPosition(30, bgHeight / 2)
    totalRepairBg:addChild(totalRepairLb)
    
    local btnScale, priority, btnPosy = 0.6, -(self.layerNum - 1) * 20 - 3, 35
    --金币修复
    local function gemRepair()
        self:tankRepair(2, nil, nil, self.repairCostTb)
    end
    local gemRepairBtn, gemRepairMenu = G_createBotton(totalRepairBg, ccp(totalRepairBg:getContentSize().width - 200, btnPosy), {getlocal("repairItem"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", gemRepair, btnScale, priority)
    
    --水晶修复
    local function crystalRepair()
        self:tankRepair(1, nil, nil, self.repairCostTb)
    end
    local crystalRepairBtn, crystalRepairMenu = G_createBotton(totalRepairBg, ccp(totalRepairBg:getContentSize().width - 70, btnPosy), {getlocal("repairItem"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", crystalRepair, btnScale, priority)
    
    local gemSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    gemSp:setAnchorPoint(ccp(0, 0.5))
    totalRepairBg:addChild(gemSp)
    local gemCostLb = GetTTFLabel("0", 20)
    gemCostLb:setAnchorPoint(ccp(0, 0.5))
    totalRepairBg:addChild(gemCostLb)
    
    local crystalSp = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
    crystalSp:setAnchorPoint(ccp(0, 0.5))
    totalRepairBg:addChild(crystalSp)
    local crystalCostLb = GetTTFLabel("0", 20)
    crystalCostLb:setAnchorPoint(ccp(0, 0.5))
    totalRepairBg:addChild(crystalCostLb)
    
    self.repairRefreshTb = {{crystalSp, crystalCostLb, crystalRepairBtn, crystalRepairMenu}, {gemSp, gemCostLb, gemRepairBtn, gemRepairMenu}}
    
    self:refreshTotalRepair()
    
    self.tipOffsetY = 0
    if G_getIphoneType() == G_iphoneX then
        self.tipOffsetY = 10
    end
    local redTipLb = GetTTFLabelWrap(getlocal("repairTipStr"), G_isAsia() and 20 or 17, CCSizeMake(G_VisibleSizeWidth - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    redTipLb:setPosition(15, redTipLb:getContentSize().height / 2 + 5 + self.tipOffsetY)
    redTipLb:setAnchorPoint(ccp(0, 0.5))
    redTipLb:setColor(G_ColorRed)
    self.bgLayer:addChild(redTipLb)
    self.redTipLb = redTipLb
    
    self.infoBgHeight = 155
    if G_isAsia() == true then
        self.infoBgHeight = 170
        if G_isIOS() == false then
            self.infoBgHeight = 185
        end
    end
    self.tvWidth, self.tvHeight, self.cellHeight = G_VisibleSizeWidth - 60, posY - bgHeight - self.infoBgHeight - redTipLb:getContentSize().height - 20 - self.tipOffsetY, 120
    if G_isIOS() == false then
        self.cellHeight = 140
    end
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, self.infoBgHeight + redTipLb:getPositionY() + 5 + 10 + self.tipOffsetY)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
    
    local noRepairLb = GetTTFLabelWrap(getlocal("haveNoDamageFleet"), 24, CCSizeMake(G_VisibleSizeWidth - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    noRepairLb:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() + self.tvHeight / 2)
    -- noRepairLb:setColor(G_ColorGray)
    self.bgLayer:addChild(noRepairLb, 3)
    self.noRepairLb = noRepairLb
    if self.listNum > 0 then
        self.noRepairLb:setVisible(false)
    end
    
    self:initBuildUpgradeView()
    
    local function upgradeRefresh(event, data)
        if data.bid == self.bid then
            self:refreshBuildUpgradeView()
        end
    end
    self.refreshListener = upgradeRefresh
    eventDispatcher:addEventListener("building.upgrade.success", upgradeRefresh)
    
    return self.bgLayer
end

function tankWarehouseRepairTab:initBuildUpgradeView()
    local infoBgWidth = G_VisibleSizeWidth - 30
    local viewBg = LuaCCScale9Sprite:createWithSpriteFrameName("brown_kuang1.png", CCRect(4, 4, 1, 1), function () end)
    viewBg:setContentSize(CCSizeMake(infoBgWidth, self.infoBgHeight))
    viewBg:setPosition(G_VisibleSizeWidth / 2, self.infoBgHeight / 2 + self.redTipLb:getContentSize().height + 10 + self.tipOffsetY)
    self.bgLayer:addChild(viewBg)
    self.buildInfoBg = viewBg
    local iconWidth = 100
    local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
    iconBg:setScale(iconWidth / iconBg:getContentSize().width)
    iconBg:setPosition(ccp(15 + iconWidth / 2, self.infoBgHeight - iconWidth / 2 - 15))
    viewBg:addChild(iconBg)
    local dkIconSp = CCSprite:createWithSpriteFrameName("dk_icon.png")
    dkIconSp:setPosition(getCenterPoint(iconBg))
    dkIconSp:setScale(iconBg:getContentSize().width / dkIconSp:getContentSize().width)
    iconBg:addChild(dkIconSp)
    
    local repairNameLb = GetTTFLabel(getlocal("repair_factory"), 22, true)
    repairNameLb:setAnchorPoint(ccp(0, 0.5))
    repairNameLb:setPosition(iconBg:getPositionX() + iconWidth / 2 + 10, self.infoBgHeight - repairNameLb:getContentSize().height / 2 - 15)
    repairNameLb:setColor(G_ColorYellowPro)
    viewBg:addChild(repairNameLb)
    self.repairNameLb = repairNameLb
    
    local iconTimeSp = CCSprite:createWithSpriteFrameName("IconTime.png")
    iconTimeSp:setAnchorPoint(ccp(0, 0.5))
    iconTimeSp:setPosition(10, iconTimeSp:getContentSize().height / 2)
    iconTimeSp:setScale(0.9)
    viewBg:addChild(iconTimeSp)
    self.iconTimeSp = iconTimeSp
    --建筑升级需要时间
    local timeLb = GetTTFLabel("", 18)
    timeLb:setAnchorPoint(ccp(0, 0.5))
    timeLb:setPosition(iconTimeSp:getPositionX() + iconTimeSp:getContentSize().width * iconTimeSp:getScale(), iconTimeSp:getPositionY())
    viewBg:addChild(timeLb)
    self.totalTimeLb = timeLb
    
    local function showAttriInfo()
        local maxLv = buildingVoApi:canUpgradeMaxLevel(17)
        local strTb, textFormatTb = {}, {}
        for k = 1, maxLv do
            local nameStr = getlocal("repair_factory")..getlocal("fightLevel", {k})
            local rate, pnum, troopsNum = buildingVoApi:getRepairFactoryBuff(k)
            local descTb = {getlocal("repair_factory_desc1", {rate * 100}), getlocal("repair_factory_desc2", {pnum}), getlocal("repair_factory_desc3", {troopsNum})}
            local strnum = #descTb
            table.insert(strTb, nameStr)
            table.insert(textFormatTb, {fontSize = 22, bold = true, ws = 5, color = G_ColorYellowPro})
            for k, v in pairs(descTb) do
                local ws = (k == strnum) and 10 or 0
                table.insert(strTb, v)
                table.insert(textFormatTb, {richColor = {nil, G_ColorGreen, nil}, richFlag = true, fontSize = 20, ws = ws})
            end
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, nil, strTb, nil, 25, textFormatTb)
    end
    local infoBtn = G_createBotton(viewBg, ccp(infoBgWidth - 40, self.infoBgHeight - 30), {}, "i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showAttriInfo, 1, -(self.layerNum - 1) * 20 - 3)
    infoBtn:setScale(40 / infoBtn:getContentSize().width)
    
    --升级
    local function upgrade()
        if otherGuideMgr.isGuiding == true and otherGuideMgr.curStep == 84 then --结束修理厂升级教学
            otherGuideMgr:toNextStep()
        end
        self.buildVo = buildingVoApi:getBuildiingVoByBId(self.bid)
        local function serverUpgrade(fn, data)
            if base:checkServerData(data) == true then
                self:refreshBuildUpgradeView()
                local needCommandLv, prop = buildingVoApi:getRepairFactoryUpgradeCondition(self.buildVo.level + 1)
                local useNum = bagVoApi:getItemNumId(prop.id) <= prop.num and bagVoApi:getItemNumId(prop.id) or prop.num
                bagVoApi:useItemNumId(prop.id, useNum)
            end
        end
        local function upgradeHandler()
            local function upgradeFactory(usegem)
                socketHelper:upgradeBuild(self.bid, self.buildVo.type, serverUpgrade, usegem and 1 or nil)
            end
            buildingVoApi:showRepairConfirmDialog(self.buildVo, self.layerNum + 1, upgradeFactory)
        end
        if buildingSlotVoApi:getFreeSlotNum() <= 0 then --升级队列不足
            local function onSpeedCallBack()
                upgradeHandler()
            end
            vipVoApi:showQueueFullDialog(1, self.layerNum + 1, onSpeedCallBack)
        else
            upgradeHandler()
        end
    end
    self.upgradeBtn, self.upgradeMenu = G_createBotton(viewBg, ccp(0, 0), {}, "yh_BtnUp.png", "yh_BtnUp_Down.png", "yh_BtnUp_Down.png", upgrade, 1, -(self.layerNum - 1) * 20 - 3)
    self.upgradeBtn:setScale(40 / self.upgradeBtn:getContentSize().width)
    
    self:refreshBuildUpgradeView()
    
    if otherGuideMgr:checkGuide(84) == false then --引导升级按钮
        otherGuideMgr:setGuideStepField(84, self.upgradeBtn)
        otherGuideMgr:showGuide(84)
    end
end

function tankWarehouseRepairTab:refreshBuildUpgradeView()
    if self.buildInfoBg == nil then
        do return end
    end
    self.buildVo = buildingVoApi:getBuildiingVoByBId(self.bid)
    
    self.repairNameLb:setString(getlocal("repair_factory")..getlocal("fightLevel", {self.buildVo.level}))
    self.upgradeMenu:setPosition(self.repairNameLb:getPositionX() + self.repairNameLb:getContentSize().width + 30, self.repairNameLb:getPositionY())
    if (self.buildVo.status == 2) or (self.buildVo.level >= buildingCfg[self.buildVo.type].maxLevel) then
        self.upgradeBtn:setEnabled(false)
    else
        self.upgradeBtn:setEnabled(true)
    end
    
    local isMax = false
    --升级到下一级需要的时间
    local maxLv = buildingVoApi:canUpgradeMaxLevel(17)
    if self.buildVo.level >= maxLv then
        self.totalTimeLb:setString("--")
        -- self.iconTimeSp:setVisible(false)
        if self.cancelUpgradeBtn then
            self.cancelUpgradeBtn:setVisible(false)
        end
        if self.speedupBtn then
            self.speedupBtn:setVisible(false)
        end
        if self.freeSpeedupBtn then
            self.freeSpeedupBtn:setVisible(false)
        end
        
        if self.seekHelpBtn then
            self.seekHelpBtn:setVisible(false)
        end
        
        isMax = true
    else
        self.totalTimeLb:setString(GetTimeStr(math.ceil(buildingVoApi:getBuildingTime(self.buildVo.type, self.buildVo.level))))
    end
    
    --修理厂属性加成显示
    if self.descTv then
        self.descTv:removeFromParentAndCleanup(true)
        self.descTv = nil
    end
    local rate, pnum, troopsNum = buildingVoApi:getRepairFactoryBuff(self.buildVo.level)
    local descTb = {
        {getlocal("repair_factory_desc1", {rate * 100}), {nil, G_ColorGreen, nil}, nil, true},
        {getlocal("repair_factory_desc2", {pnum}), {nil, G_ColorGreen, nil}, nil, true},
        {getlocal("repair_factory_desc3", {troopsNum}), {nil, G_ColorGreen, nil}, nil, true},
    }
    local descTv = G_LabelTableViewNew(CCSizeMake(G_VisibleSizeWidth - 230, self.infoBgHeight - self.repairNameLb:getContentSize().height - 70), descTb, 20, kCCTextAlignmentLeft)
    descTv:setAnchorPoint(ccp(0, 0))
    descTv:setPosition(self.repairNameLb:getPositionX(), 45)
    descTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    descTv:setMaxDisToBottomOrTop(80)
    self.buildInfoBg:addChild(descTv)
    self.descTv = descTv
    
    if self.buildVo.status == 2 or isMax == true then --正在升级中
        if self.timerLayer == nil then
            local timerLayer = CCNode:create()
            timerLayer:setAnchorPoint(ccp(0.5, 0.5))
            timerLayer:setContentSize(self.buildInfoBg:getContentSize())
            timerLayer:setPosition(getCenterPoint(self.buildInfoBg))
            self.buildInfoBg:addChild(timerLayer)
            self.timerLayer = timerLayer
            
            local barWidth, barHeight = 330, 25
            local upgradeTimer = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png"))
            upgradeTimer:setMidpoint(ccp(0, 1))
            upgradeTimer:setBarChangeRate(ccp(1, 0))
            upgradeTimer:setType(kCCProgressTimerTypeBar)
            upgradeTimer:setScaleX((barWidth + 6) / upgradeTimer:getContentSize().width)
            upgradeTimer:setScaleY((barHeight + 6) / upgradeTimer:getContentSize().height)
            local progressBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("studyPointBarBg.png", CCRect(4, 4, 1, 1), function()end)
            progressBarBg:setContentSize(CCSizeMake(barWidth + 6, barHeight))
            progressBarBg:setAnchorPoint(ccp(0, 0.5))
            progressBarBg:setPosition(self.repairNameLb:getPositionX(), self.totalTimeLb:getPositionY())
            upgradeTimer:setPosition(getCenterPoint(progressBarBg))
            progressBarBg:addChild(upgradeTimer)
            timerLayer:addChild(progressBarBg)
            self.upgradeTimer = upgradeTimer
            self.progressBarBg = progressBarBg
            
            local timeLb = GetTTFLabel("", 20)
            timeLb:setPosition(getCenterPoint(progressBarBg))
            progressBarBg:addChild(timeLb, 3)
            self.timeLb = timeLb
            
            if isMax == false then
                local bgWidth = self.buildInfoBg:getContentSize().width
                local btnScale, priority, btnPosy = 0.8, -(self.layerNum - 1) * 20 - 3, 30
                --取消升级
                local function cancelUpgrade()
                    PlayEffect(audioCfg.mouseClick)
                    local function realCancle()
                        local function serverCancleUpgrade(fn, data)
                            if base:checkServerData(data) == true then
                                self:refreshBuildUpgradeView()
                                G_showTipsDialog(getlocal("cancel_upgrade_success"))
                                local needCommandLv, prop = buildingVoApi:getRepairFactoryUpgradeCondition(self.buildVo.level + 1)
                                G_addPlayerAward(prop.type, prop.key, prop.id, prop.num)
                            end
                        end
                        if buildingVoApi:checkCancleUpgradeBuildBeforeServer(self.bid) == true then
                            socketHelper:cancleUpgradeBuild(self.bid, self.buildVo.type, serverCancleUpgrade)
                        end
                    end
                    local smallD = smallDialog:new()
                    smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), realCancle, getlocal("dialog_title_prompt"), getlocal("repairCancleUpGrade"), nil, self.layerNum + 1)
                end
                self.cancelUpgradeBtn, self.cancelUpgradeMenu = G_createBotton(timerLayer, ccp(bgWidth - 100, btnPosy), {}, "yh_BtnNo.png", "yh_BtnNo_Down.png", "yh_BtnNo_Down.png", cancelUpgrade, btnScale, priority)
                
                --加速升级
                local function speedup()
                    PlayEffect(audioCfg.mouseClick)
                    local function superUpgradeHandler()
                        local function superUpgrade()
                            local function serverSuperUpgrade(fn, data)
                                --local retTb=OBJDEF:decode(data)
                                if base:checkServerData(data) == true then
                                    if self.speedUpSmallDialog ~= nil then
                                        self.speedUpSmallDialog:close()
                                        self.speedUpSmallDialog = nil
                                    end
                                    if buildingVoApi:superUpgradeBuild(self.bid) then --加速成功
                                        self:refreshBuildUpgradeView()
                                    end
                                end
                            end
                            
                            if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.bid) == true then
                                socketHelper:superUpgradeBuild(self.bid, self.buildVo.type, serverSuperUpgrade)
                            end
                        end
                        local bsv = buildingSlotVoApi:getSlotByBid(self.bid)
                        local leftTime = buildingVoApi:getUpgradeLeftTime(self.bid)
                        if leftTime > 0 then
                            local needGemsNum = TimeToGems(leftTime)
                            local needGems = getlocal("speedUp", {needGemsNum})
                            if needGemsNum > playerVoApi:getGems() then --金币不足
                                GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), self.layerNum + 2, needGemsNum)
                            else
                                local smallD = smallDialog:new()
                                local addStr = getlocal("recommendJoinAlliance_lbDes")
                                smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), superUpgrade, getlocal("dialog_title_prompt"), needGems, nil, self.layerNum + 2, nil, nil, nil, nil, nil, nil, nil, nil, addStr)
                            end
                        end
                    end
                    --使用加速道具
                    if base.speedUpPropSwitch == 1 then
                        if self.speedUpSmallDialog ~= nil then
                            self.speedUpSmallDialog:close()
                            self.speedUpSmallDialog = nil
                        end
                        require "luascript/script/componet/speedUpPropSmallDialog"
                        self.speedUpSmallDialog = speedUpPropSmallDialog:new(1, self.bid, superUpgradeHandler)
                        self.speedUpSmallDialog:init(self.layerNum + 1)
                    else
                        superUpgradeHandler()
                    end
                end
                self.speedupBtn, self.speedupMenu = G_createBotton(timerLayer, ccp(bgWidth - 40, btnPosy), {}, "yh_BtnRight.png", "yh_BtnRight_Down.png", "yh_BtnRight_Down.png", speedup, btnScale, priority)
                
                --免费加速
                local function freeSpeedup()
                    PlayEffect(audioCfg.mouseClick)
                    local function serverSuperUpgrade(fn, data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data) == true then
                            if buildingVoApi:superUpgradeBuild(self.bid) then --加速成功
                                self:refreshBuildUpgradeView()
                            end
                        end
                    end
                    if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.bid) == true then
                        socketHelper:freeUpgradeBuild(self.bid, self.buildVo.type, serverSuperUpgrade)
                    end
                end
                self.freeSpeedupBtn, self.freeSpeedupMenu = G_createBotton(timerLayer, ccp(bgWidth - 40, btnPosy), {}, "yh_freeSpeedupBtn.png", "yh_freeSpeedupBtn_Down.png", "yh_freeSpeedupBtn_Down.png", freeSpeedup, btnScale, priority)
                
                --请求军团协助
                local function seekHelp()
                    PlayEffect(audioCfg.mouseClick)
                    local function helpCallback(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            if sData and sData.data and sData.data.newhelp then
                                local selfAlliance = allianceVoApi:getSelfAlliance()
                                if selfAlliance then
                                    local aid = selfAlliance.aid
                                    local prams = {newhelp = sData.data.newhelp, uid = playerVoApi:getUid()}
                                    chatVoApi:sendUpdateMessage(29, prams, aid + 1)
                                end
                                self:refreshBuildUpgradeView()
                            end
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_help_success"), 30)
                    end
                    
                    local leftTime = buildingVoApi:getUpgradeLeftTime(self.bid)
                    local buildingSlotVo = buildingSlotVoApi:getSlotByBid(self.bid)
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil then
                        if base.fs == 1 then
                            local canSpeedTime = playerVoApi:getFreeTime()
                            if leftTime > canSpeedTime then
                                local bid = self.bid
                                local btype = self.buildVo.type
                                socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                            end
                        else
                            local bid = self.bid
                            local btype = self.buildVo.type
                            socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                        end
                    end
                end
                self.seekHelpBtn, self.seekHelpMenu = G_createBotton(timerLayer, ccp(bgWidth - 40, btnPosy), {}, "yh_allianceHelpBtn.png", "yh_allianceHelpBtn_Down.png", "yh_allianceHelpBtn_Down.png", seekHelp, btnScale, priority)
            end
            self:tick()
        end
        if isMax == true and self.timeLb and self.upgradeTimer and self.progressBarBg then
            self.timeLb:setString(getlocal("decorateMax"))
            self.timeLb:setColor(G_ColorGreen)
            self.timeLb:setPositionX(self.progressBarBg:getContentSize().width + self.timeLb:getContentSize().width / 2 + 15)
            self.upgradeTimer:setPercentage(100)
        end
    else
        if self.timerLayer then
            self.timerLayer:removeFromParentAndCleanup(true)
            self.timerLayer = nil
        end
    end
end

--刷新全部修复消耗
function tankWarehouseRepairTab:refreshTotalRepair()
    if self.repairRefreshTb == nil or next(self.repairRefreshTb) == nil then
        do return end
    end
    
    self.repairTank = tankVoApi:getRepairTanks()
    self.listNum = SizeOfTable(self.repairTank)
    local repairCostTb = {0, 0} --修复消耗
    for k, v in pairs(self.repairTank) do
        local tankId, tankNum = self.repairTank[k][1], self.repairTank[k][2]
        local crystal, gem = tankVoApi:getTankRepairCost(tankId, tankNum)
        repairCostTb[1] = tonumber(repairCostTb[1] or 0) + crystal
        repairCostTb[2] = tonumber(repairCostTb[2] or 0) + gem
    end
    self.repairCostTb = repairCostTb
    for k, v in pairs(self.repairRefreshTb) do
        local sp, lb, btn, menu = v[1], v[2], v[3], v[4]
        local cost = repairCostTb[k] or 0
        lb:setString(FormatNumber(cost))
        local tw = sp:getContentSize().width + lb:getContentSize().width
        sp:setPosition(menu:getPositionX() - tw / 2, menu:getPositionY() + sp:getContentSize().height / 2 + 20)
        lb:setPosition(sp:getPositionX() + sp:getContentSize().width, sp:getPositionY())
        local ownNum = 0
        if k == 2 then
            ownNum = playerVoApi:getGems()
        else
            ownNum = playerVoApi:getGold()
        end
        if cost == 0 or ownNum < cost then --不可修复
            btn:setEnabled(false)
        end
        if ownNum < cost then
            lb:setColor(G_ColorRed)
        else
            lb:setColor(G_ColorWhite)
            if k == 1 then
                --勇往直前活动, 水晶修理费用减少50%
                local vo = activityVoApi:getActivityVo("yongwangzhiqian")
                local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
                if vo and activityVoApi:isStart(vo) then
                    lb:setColor(G_ColorYellowPro)
                elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
                    lb:setColor(G_ColorYellowPro)
                end
            end
        end
    end
end

function tankWarehouseRepairTab:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.listNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local tankId, tankNum = self.repairTank[idx + 1][1], self.repairTank[idx + 1][2]
        local crystalCost, gemCost = tankVoApi:getTankRepairCost(tankId, tankNum)
        local costTb = {crystalCost, gemCost}
        
        local iconWidth = 100
        local spriteIcon = tankVoApi:getTankIconSp(tankId)
        spriteIcon:setAnchorPoint(ccp(0, 0.5))
        spriteIcon:setScale(iconWidth / spriteIcon:getContentSize().width)
        spriteIcon:setPosition(15, self.cellHeight / 2)
        cell:addChild(spriteIcon)
        
        local nameLb = GetTTFLabel(getlocal(tankCfg[tankId].name), 22, true)
        nameLb:setAnchorPoint(ccp(0, 0.5))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(spriteIcon:getPositionX() + iconWidth + 10, self.cellHeight - nameLb:getContentSize().height / 2 - 10)
        cell:addChild(nameLb)
        
        --需要修复的坦克总量
        local numLb = GetTTFLabel(tankNum, 20)
        numLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height / 2 - numLb:getContentSize().height / 2 - 10)
        numLb:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(numLb)
        
        --本次修理 修理厂保护的量
        local proNum = tankVoApi:getProdamagedTankNum(tankId)
        local protectLb = GetTTFLabelWrap(getlocal("repair_tankProtect", {proNum}), G_isAsia() and 20 or 18, CCSizeMake(180, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        protectLb:setPosition(nameLb:getPositionX(), numLb:getPositionY() - numLb:getContentSize().height / 2 - protectLb:getContentSize().height / 2 - 5)
        protectLb:setAnchorPoint(ccp(0, 0.5))
        protectLb:setColor(G_ColorRed)
        cell:addChild(protectLb)
        
        local btnScale, priority, btnPosy = 0.6, -(self.layerNum - 1) * 20 - 3, 40
        --金币修复
        local function gemRepair()
            if self.tv:getIsScrolled() == true and self.tv:getScrollEnable() == false then
                do
                    return
                end
            end
            self:tankRepair(2, tankId, tankNum, costTb)
        end
        local gemRepairBtn, gemRepairMenu = G_createBotton(cell, ccp(self.tvWidth - 200, btnPosy), {getlocal("repairItem"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", gemRepair, btnScale, priority)
        
        --水晶修复
        local function crystalRepair()
            if self.tv:getIsScrolled() == true and self.tv:getScrollEnable() == false then
                do
                    return
                end
            end
            self:tankRepair(1, tankId, tankNum, costTb)
        end
        local crystalRepairBtn, crystalRepairMenu = G_createBotton(cell, ccp(self.tvWidth - 70, btnPosy), {getlocal("repairItem"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", crystalRepair, btnScale, priority)
        
        local gemSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        gemSp:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(gemSp)
        local gemCostLb = GetTTFLabel(FormatNumber(gemCost), 20)
        gemCostLb:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(gemCostLb)
        
        local crystalSp = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
        crystalSp:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(crystalSp)
        local crystalCostLb = GetTTFLabel(FormatNumber(crystalCost), 20)
        crystalCostLb:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(crystalCostLb)
        
        local gemWidth = gemSp:getContentSize().width + gemCostLb:getContentSize().width
        gemSp:setPosition(gemRepairMenu:getPositionX() - gemWidth / 2, gemRepairMenu:getPositionY() + gemSp:getContentSize().height / 2 + 20)
        gemCostLb:setPosition(gemSp:getPositionX() + gemSp:getContentSize().width, gemSp:getPositionY())
        
        local crystalWidth = crystalSp:getContentSize().width + crystalCostLb:getContentSize().width
        crystalSp:setPosition(crystalRepairMenu:getPositionX() - crystalWidth / 2, crystalRepairMenu:getPositionY() + crystalSp:getContentSize().height / 2 + 20)
        crystalCostLb:setPosition(crystalSp:getPositionX() + crystalSp:getContentSize().width, crystalSp:getPositionY())
        if playerVoApi:getGems() < gemCost then
            gemRepairBtn:setEnabled(false)
            gemCostLb:setColor(G_ColorRed)
        end
        if playerVoApi:getGold() < crystalCost then
            crystalRepairBtn:setEnabled(false)
            crystalCostLb:setColor(G_ColorRed)
        else
            --勇往直前活动, 水晶修理费用减少50%
            local vo = activityVoApi:getActivityVo("yongwangzhiqian")
            local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
            if vo and activityVoApi:isStart(vo) then
                crystalCostLb:setColor(G_ColorYellowPro)
            elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
                crystalCostLb:setColor(G_ColorYellowPro)
            end
        end
        
        if (idx + 1) ~= self.listNum then
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("dk_yellowLine.png", CCRect(2, 0, 1, 2), function ()end)
            lineSp:setAnchorPoint(ccp(0.5, 0.5))
            lineSp:setPosition(self.tvWidth / 2, 1)
            lineSp:setContentSize(CCSizeMake(self.tvWidth, 2))
            cell:addChild(lineSp)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function tankWarehouseRepairTab:tankRepair(repairType, tankId, tankNum, costTb, callback)
    local function realRepair(repairNum)
        local function serverRepair()
            self:refresh()
            if tankId == nil then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allDamageFleetRepairSuccess"), 28)
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("damageFleetRepairSuccess", {getlocal(tankCfg[tankId].name)}), 28)
            end
            if callback then
                callback()
            end
        end
        tankVoApi:tankRepair(repairType, tankId, repairNum, serverRepair)
    end
    local resOwnNum, singleCost = 0, 0
    if repairType == 2 then
        resOwnNum = playerVoApi:getGems()
        if tankId then
            singleCost = tonumber(tankCfg[tankId].glodCost)
        end
    else
        resOwnNum = playerVoApi:getGold()
        if tankId then
            singleCost = tonumber(tankCfg[tankId].glodCost)
        end
        --勇往直前活动, 水晶修理费用减少50%
        local vo = activityVoApi:getActivityVo("yongwangzhiqian")
        local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
        if vo and activityVoApi:isStart(vo) then
            singleCost = singleCost * vo.activeRes
        elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
            singleCost = singleCost * ywzq2018Vo.activeRes
        end
    end
    local totalCost = costTb[repairType]
    local enough = true
    if tankId == nil or tankNum == nil then --全部修复
        if resOwnNum < totalCost then
            enough = false
        end
    else
        if resOwnNum < singleCost then
            enough = false
        end
    end
    if enough == true then
        local repairNum, realCost
        if tankId and tankNum then
            if(resOwnNum >= totalCost)then
                repairNum = tankNum
                realCost = totalCost
            else
                repairNum = math.floor(resOwnNum / singleCost)
                realCost = repairNum * singleCost
            end
        else
            realCost = totalCost
        end
        
        if repairType == 2 then
            local key = "repairTank_gem_buy"
            if G_isPopBoard(key) then
                local function secondTipFunc(flag)
                    local sValue = base.serverTime .. "_" .. flag
                    G_changePopFlag(key, sValue)
                end
                local function repair()
                    realRepair(repairNum)
                end
                G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("second_tip_des", {realCost}), false, repair, secondTipFunc)
            else
                realRepair(repairNum)
            end
        else
            realRepair(repairNum)
        end
    else
        if repairType == 2 then
            vipVoApi:showRechargeDialog(3)
        else
            smallDialog:showBuyResDialog(3)
        end
    end
end

function tankWarehouseRepairTab:refresh()
    self:refreshTotalRepair()
    if self.tv then
        self.tv:reloadData()
    end
    if self.noRepairLb then
        if self.listNum == 0 then
            self.noRepairLb:setVisible(true)
        else
            self.noRepairLb:setVisible(false)
        end
    end
end

function tankWarehouseRepairTab:tick()
    if self.timerLayer then
        if self.buildVo.status == 2 then
            local totalTime = buildingVoApi:getUpgradingTotalUpgradeTime(self.bid)
            local leftTime = buildingVoApi:getUpgradeLeftTime(self.bid)
            self.upgradeTimer:setPercentage((1 - leftTime / totalTime) * 100)
            self.timeLb:setString(GetTimeStr(leftTime))
            if base.fs == 1 and self.canSpeedTime == nil then
                self.canSpeedTime = playerVoApi:getFreeTime()
            end
            local isFree = false
            if leftTime <= self.canSpeedTime then
                self.freeSpeedupBtn:setEnabled(true)
                self.freeSpeedupMenu:setVisible(true)
                isFree = true
            else
                self.freeSpeedupBtn:setEnabled(false)
                self.freeSpeedupMenu:setVisible(false)
            end
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local buildingSlotVo = buildingSlotVoApi:getSlotByBid(self.bid)
            if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil and isFree == false then
                self.seekHelpBtn:setVisible(true)
                self.seekHelpMenu:setEnabled(true)
                self.speedupBtn:setEnabled(false)
                self.speedupMenu:setVisible(false)
            else
                self.seekHelpBtn:setVisible(false)
                self.seekHelpMenu:setEnabled(false)
                self.speedupBtn:setEnabled(true)
                self.speedupMenu:setVisible(true)
            end
        end
    end
end

function tankWarehouseRepairTab:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("building.upgrade.success", self.refreshListener)
        self.refreshListener = nil
    end
    if self.speedUpSmallDialog then
        self.speedUpSmallDialog:close()
        self.speedUpSmallDialog = nil
    end
    
    self.freeSpeedupBtn, self.freeSpeedupMenu = nil, nil
    self.seekHelpBtn, self.seekHelpMenu = nil, nil
    self.speedupBtn, self.speedupMenu = nil, nil
    self.upgradeBtn, self.upgradeMenu = nil, nil
    self.buildInfoBg = nil
    self.upgradeTimer = nil
    self.repairCostTb = nil
    self.repairRefreshTb = nil
    self.repairTank = nil
    self.listNum = nil
    self.bid = nil
    self.totalTimeLb = nil
    self.timeLb = nil
    self.redTipLb = nil
    self.noRepairLb = nil
    self = nil
end

return tankWarehouseRepairTab
