buildingUpgradeCommon = {
    
}

function buildingUpgradeCommon:new()
    local nc = {
        guildItem = nil,
    }
    setmetatable(nc, self)
    self.__index = self
    
    self.normalHeight = 155
    self.expandHeight = G_VisibleSize.height - 140
    self.requires = {}
    self.allCellsBtn = {}
    self.buildBtn = nil
    self.progressTag = 100
    self.upgradeBtnTag = 101
    self.removeBuildBtnTag = 102
    self.cancleUpgradeTag = 103
    self.superUpgradeTag = 104
    self.upgradeTextTag = 105
    self.bgSpriteTag = 106
    self.buildBtnTag = 107
    self.exBg = nil
    self.fourBtns = {}
    self.tmIco = nil
    self.tmLb = nil
    self.acDis = nil
    self.acDisBg = nil
    self.bDescLb = nil
    self.arriveMaxLevel = false
    self.upgradeBtnItem = nil
    
    self.isShowPoint = nil
    self.flickSp = nil
    self.arowSp = nil
    self.lastState = nil
    self.canSpeedTime = 0
    self.speedUpSmallDialog = nil--选择加速升级道具进行加速升级的小面板
    return nc
end

--container:父容器 bgLayer:背景层 bid:建筑ID  dialog:对话框
function buildingUpgradeCommon:init(container, bgLayer, bid, dialog, layerNum, isShowPoint)
    
    local cell = container
    self.bgLayer = bgLayer
    self.dialog = dialog
    self.bid = bid
    if G_phasedGuideOnOff() then
        local tb = {[2] = 101, [3] = 103, [4] = 104, [6] = 105, [13] = 106}
        for k, v in pairs(tb) do
            if k == self.bid and phasedGuideMgr:getInsideKey(self.bid) == 0 then
                phasedGuideMgr:insidePanel(v)
                phasedGuideMgr:setInsideKeyDone(self.bid)
            end
            
        end
    end
    
    if base.fs == 1 then
        self.canSpeedTime = playerVoApi:getFreeTime()
    end
    self.isShowPoint = isShowPoint
    if layerNum then
        self.layerNum = layerNum
    else
        self.layerNum = 3
    end
    local idx = 1
    local function cellClick(hd, fn, idx)
        
    end
    local expanded = true
    local hei = 30
    
    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, self.expandHeight))
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local headerSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, self.normalHeight))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0, 0));
    headerSprie:setTag(1000 + idx)
    headerSprie:setIsSallow(false)
    headerSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    headerSprie:setPosition(ccp(0, cell:getContentSize().height - headerSprie:getContentSize().height));
    cell:addChild(headerSprie)
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    local curBuildType = bvo.type
    if self.bid < 16 and curBuildType == -1 then
        curBuildType = homeCfg.buildingUnlock[self.bid].type
    end
    local maxLv = buildingVoApi:canUpgradeMaxLevel(curBuildType)
    if self.bid == 6 then
        maxLv = 1
    elseif self.bid == 52 then
        maxLv = buildingVoApi:canUpgradeMaxLevel(18)
    end

    if bvo.level >= maxLv then --已经达到最大等级
        self.arriveMaxLevel = true
    end
    
    local btype = curBuildType
    local bcfg = buildingCfg[btype]
    local itemImgContainer = CCSprite:createWithSpriteFrameName(buildingCfg[btype].icon)
    
    itemImgContainer:setAnchorPoint(ccp(0, 0));
    itemImgContainer:setPosition(ccp(10, self.normalHeight - itemImgContainer:getContentSize().height - hei))
    --[[
               
               local itemImgSp=CCSprite:createWithSpriteFrameName(bcfg.style)
               local scaleX=itemImgContainer:getContentSize().width/itemImgSp:getContentSize().width
               local scaleY=itemImgContainer:getContentSize().height/itemImgSp:getContentSize().height
               --itemImgSp:setScaleX(scaleX)
               --itemImgSp:setScaleY(scaleY)
               itemImgSp:setScale(scaleX)               
               itemImgSp:setPosition(ccp(itemImgContainer:getContentSize().width/2,itemImgContainer:getContentSize().height/2))
               itemImgContainer:addChild(itemImgSp)
               ]]
    
    headerSprie:addChild(itemImgContainer)
    headerSprie:setOpacity(0)
    --建造时间
    if self.arriveMaxLevel == false then
        self.tmIco = CCSprite:createWithSpriteFrameName("IconTime.png")
        self.tmIco:setAnchorPoint(ccp(0, 0))
        self.tmIco:setPosition(ccp(10, self.normalHeight - itemImgContainer:getContentSize().height - self.tmIco:getContentSize().height - hei))
        headerSprie:addChild(self.tmIco)
        
        self.tmLb = GetTTFLabel(GetTimeStr(buildingVoApi:getBuildingTime(btype, bvo.level)), 20)
        self.tmLb:setAnchorPoint(ccp(0, 0.5))
        self.tmLb:setPosition(ccp(10 + self.tmIco:getContentSize().width, self.normalHeight - itemImgContainer:getContentSize().height - self.tmIco:getContentSize().height + self.tmIco:getContentSize().height / 2 - hei))
        headerSprie:addChild(self.tmLb)
        
        self.acDisBg = headerSprie
        self:showAcDis()
        
        local function listener(event, data)
            self:onActivityChangeListener(event, data)
        end
        self.listener = listener
        if(eventDispatcher:hasEventHandler("activity.levelingOpenOrClose", listener) == false) and self.bid == 1 then
            eventDispatcher:addEventListener("activity.levelingOpenOrClose", listener)
        end
        
    end
    --建筑名称
    local bNameCon = LuaCCScale9Sprite:createWithSpriteFrameName("HeaderBg.png", CCRect(17, 17, 2, 2), cellClick)
    bNameCon:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 200, 48))
    bNameCon:setAnchorPoint(ccp(0, 0))
    bNameCon:setPosition(130, self.normalHeight - bNameCon:getContentSize().height - hei)
    headerSprie:addChild(bNameCon)
    
    local bNameLb = GetTTFLabel(getlocal(bcfg.buildName), 20)
    bNameLb:setAnchorPoint(ccp(0, 0.5))
    bNameLb:setPosition(ccp(10, bNameCon:getContentSize().height / 2))
    bNameCon:addChild(bNameLb)
    --描述文字
    local descStr
    local tmpLv = (bvo.level < 1 and 1 or bvo.level)
    if curBuildType <= 5 or curBuildType == 7 then
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(Split(bcfg.produceSpeed, ",")[tmpLv]), FormatNumber(Split(bcfg.capacity, ",")[tmpLv])})
    elseif curBuildType == 10 then
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(Split(bcfg.capacity, ",")[tmpLv])})
    elseif curBuildType == 18 then --战争飞艇
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(airShipVoApi:getResourceRecoverSpeedByHour())})
    else
        descStr = getlocal(bcfg.buildDescription)
    end
    self.bDescLb = GetTTFLabelWrap(descStr, 20, CCSize(bNameCon:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.bDescLb:setAnchorPoint(ccp(0, 1))
    self.bDescLb:setPosition(140, self.normalHeight - bNameCon:getContentSize().height - hei - 5)
    headerSprie:addChild(self.bDescLb)
    
    --展开后的内容
    if expanded then
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function touchHander()
            
        end
        local exBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, touchHander)
        self.exBg = exBg
        exBg:setAnchorPoint(ccp(0, 0))
        exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width - 80, 380))
        exBg:setPosition(ccp(10, G_VisibleSize.height - 730))
        exBg:setTag(2)
        cell:addChild(exBg)
        
        --建造条件
        if self.arriveMaxLevel == false then
            self.requires[idx + 1] = upgradeRequire:new()
            self.result = self.requires[idx + 1]:create(exBg, "build", self.bid, curBuildType)
            
            self:resetBtn(exBg)
        else
            local arriveMaxLevelLb = GetTTFLabelWrap(getlocal("maxBuildLevel"), 24, CCSize(bNameCon:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            arriveMaxLevelLb:setAnchorPoint(ccp(0.5, 0.5))
            arriveMaxLevelLb:setPosition(exBg:getContentSize().width / 2, self.exBg:getContentSize().height / 2)
            exBg:addChild(arriveMaxLevelLb)
            if self.bid == 1 then
                if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                    local function decorateCallback(...)
                        if buildDecorateVoApi.getLevelLimit and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                            buildDecorateVoApi:showDialog(self.layerNum)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateNotLevel", {buildDecorateVoApi:getLevelLimit()}), 30)
                        end
                    end
                    local decorateButton = G_createBotton(exBg, ccp(exBg:getContentSize().width / 2, -100), {getlocal("decorateTitle"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", decorateCallback, 1, -(self.layerNum - 1) * 20 - 3, 10)
                    decorateButton:setScale(0.85)
                    local lb = decorateButton:getChildByTag(101)
                    if lb then
                        lb = tolua.cast(lb, "CCLabelTTF")
                        lb:setFontName("Helvetica-bold")
                    end
                end
            end
        end
        if self.bid > 15 and self.bid < 46 then
            self:movBtn(exBg)
            self:chaiBtn(exBg)
        end
    end
    self:tick()
end

function buildingUpgradeCommon:showAcDis()
    if self.bid ~= 1 then -- 只有指挥中心才走
        do
            return
        end
    end
    
    local function removeAcDis()
        if self.acDis ~= nil then
            for k, v in pairs(self.acDis) do
                if v ~= nil then
                    v:removeFromParentAndCleanup(true)
                end
            end
            self.acDis = nil
        end
    end
    
    if self.arriveMaxLevel == true then
        removeAcDis()
    else
        local canDis = false
        local desVate = 1
        local levelVo = activityVoApi:getActivityVo("leveling")
        if levelVo ~= nil and activityVoApi:isStart(levelVo) == true then
            canDis = true
            desVate = acLevelingVoApi:getDesVate()
        end
        local level2Vo = activityVoApi:getActivityVo("leveling2")
        if level2Vo ~= nil and activityVoApi:isStart(level2Vo) == true then
            if acLeveling2VoApi:checkIfDesVate() == true then
                canDis = true
                desVate = acLeveling2VoApi:getDesVate()
            end
        end
        if canDis == true then
            local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
            local curBuildType = bvo.type
            if self.acDis == nil then
                self.acDis = {}
                local line = CCSprite:createWithSpriteFrameName("redline.jpg")
                line:setScaleX((self.tmLb:getContentSize().width + self.tmIco:getContentSize().width + 10) / 4)
                line:setPosition(ccp(10 + (self.tmIco:getContentSize().width + self.tmLb:getContentSize().width) / 2, self.tmLb:getPositionY()))
                self.acDisBg:addChild(line)
                
                table.insert(self.acDis, line)
                
                local tmIcoDis = CCSprite:createWithSpriteFrameName("IconTime.png")
                tmIcoDis:setAnchorPoint(ccp(0, 0))
                tmIcoDis:setPosition(ccp(10, self.tmIco:getPositionY() - 35))
                self.acDisBg:addChild(tmIcoDis)
                
                table.insert(self.acDis, tmIcoDis)
                
                local tmLbDis = GetTTFLabel(GetTimeStr(math.ceil(buildingVoApi:getBuildingTime(curBuildType, bvo.level) * desVate)), 20)
                tmLbDis:setAnchorPoint(ccp(0, 0.5))
                tmLbDis:setPosition(ccp(10 + self.tmIco:getContentSize().width, self.tmLb:getPositionY() - 35))
                self.acDisBg:addChild(tmLbDis)
                
                table.insert(self.acDis, tmLbDis)
            else
                self.acDis[1]:setScaleX((self.tmLb:getContentSize().width + self.tmIco:getContentSize().width + 10) / 4)
                self.acDis[3]:setString(GetTimeStr(math.ceil(buildingVoApi:getBuildingTime(curBuildType, bvo.level) * desVate)))
            end
            
        else
            removeAcDis()
        end
    end
end

function buildingUpgradeCommon:onActivityChangeListener(event, data)
    if self.requires ~= nil then
        for k, v in pairs(self.requires) do
            v:updateAcDis()
        end
    end
    self:showAcDis()
end

function buildingUpgradeCommon:tick()
    self:refreshRemoveBuildView() --刷新移除建筑cd时间或者金币消耗显示
    
    if self.arriveMaxLevel == true then
        do
            return
        end
    end
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    local curBuildType = bvo.type
    if self.bid < 16 and curBuildType == -1 then
        curBuildType = homeCfg.buildingUnlock[self.bid].type
    end
    
    local bcfg = buildingCfg[curBuildType]
    local maxLv = buildingVoApi:canUpgradeMaxLevel(curBuildType)
    if self.bid == 6 then
        maxLv = 1
    elseif self.bid == 52 then
        maxLv = buildingVoApi:canUpgradeMaxLevel(18)
    end
    
    local descStr
    local tmpLv = (bvo.level < 1 and 1 or bvo.level)
    if curBuildType <= 5 or curBuildType == 7 then
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(Split(bcfg.produceSpeed, ",")[tmpLv]), FormatNumber(Split(bcfg.capacity, ",")[tmpLv])})
    elseif curBuildType == 10 then
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(Split(bcfg.capacity, ",")[tmpLv])})
    elseif curBuildType == 18 then --战争飞艇
        descStr = getlocal(bcfg.buildDescription, {FormatNumber(airShipVoApi:getResourceRecoverSpeedByHour())})
    else
        descStr = getlocal(bcfg.buildDescription)
    end
    self.bDescLb:setString(descStr)
    
    if bvo.level >= maxLv then --已经达到最大等级
        self.arriveMaxLevel = true
        if self.tmLb ~= nil then
            self.tmLb:setVisible(false)
        end
        self:showAcDis()
        
        if self.requires ~= nil then
            for k, v in pairs(self.requires) do
                v:dispose()
            end
            self.requires = nil
        end
        self.exBg:removeAllChildrenWithCleanup(true)
        self.rbViewNode = nil
        if self.bid > 15 and self.bid < 46 then
            self:movBtn(self.exBg)
            self:chaiBtn(self.exBg)
        end
        local capInSet = CCRect(20, 20, 10, 10)
        local function touchHander()
            
        end
        local exBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, touchHander)
        exBg:setAnchorPoint(ccp(0, 0))
        exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width - 80, 380))
        exBg:setPosition(ccp(10, G_VisibleSize.height - 730))
        self.exBg:getParent():addChild(exBg)
        self.exBg = exBg
        local arriveMaxLevelLb = GetTTFLabelWrap(getlocal("maxBuildLevel"), 24, CCSize(420, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        arriveMaxLevelLb:setAnchorPoint(ccp(0.5, 0.5))
        arriveMaxLevelLb:setPosition(exBg:getContentSize().width / 2, exBg:getContentSize().height / 2)
        exBg:addChild(arriveMaxLevelLb)
        if self.dialog.titleLabel ~= nil then
            self.dialog.titleLabel:setString(getlocal(buildingCfg[curBuildType].buildName) .. "("..G_LV()..bvo.level..")")
        end
        if self.bid == 1 then
            if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                local function decorateCallback(...)
                    if buildDecorateVoApi.getLevelLimit and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                        buildDecorateVoApi:showDialog(self.layerNum)
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateNotLevel", {buildDecorateVoApi:getLevelLimit()}), 30)
                    end
                end
                local decorateButton = G_createBotton(exBg, ccp(exBg:getContentSize().width / 2, -100), {getlocal("decorateTitle"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", decorateCallback, 1, -(self.layerNum - 1) * 20 - 3, 10)
                decorateButton:setScale(0.85)
                local lb = decorateButton:getChildByTag(101)
                if lb then
                    lb = tolua.cast(lb, "CCLabelTTF")
                    lb:setFontName("Helvetica-bold")
                end
            end
        end
        do
            return
        end
    end
    
    self.tmLb = tolua.cast(self.tmLb, "CCLabelTTF")
    if self.tmLb then
        if self.arriveMaxLevel == true then
            self.tmLb:setVisible(false)
        else
            self.tmLb:setVisible(true)
            self.tmLb:setString(GetTimeStr(buildingVoApi:getBuildingTime(curBuildType, bvo.level)))
        end
    end
    self:showAcDis()
    
    if self.dialog.titleLabel ~= nil then
        local leftParth = "("
        if G_getCurChoseLanguage() == "tu" then --土耳其要求
            leftParth = " ("
        end
        self.dialog.titleLabel:setString(getlocal(buildingCfg[curBuildType].buildName)..leftParth..G_LV()..bvo.level..")")
    end
    
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    if bvo.status == 2 then
        local progress = tolua.cast(self.exBg:getChildByTag(self.progressTag), "CCProgressTimer")
        --local totalTime=buildingVoApi:getUpgradeTotalTimeByBid(self.bid)
        --local leftTime= (totalTime-(base.serverTime-buildingSlotVoApi:getSlotByBid(self.bid).st))
        local leftTime = buildingVoApi:getUpgradeLeftTime(self.bid)
        local totalTime = buildingVoApi:getUpgradingTotalUpgradeTime(self.bid)
        if progress ~= nil then
            progress:setPercentage((1 - leftTime / totalTime) * 100)
            tolua.cast(progress:getChildByTag(self.upgradeTextTag), "CCLabelTTF"):setString(GetTimeStr(leftTime))
        end
        -- if self.fourBtns[8] and self.movItem then
        --     self.movItem:setEnabled(false)
        -- end
        if self.fourBtns[1] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[1], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[2] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[2], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        
        if self.fourBtns[3] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[3], "CCMenu")
            temMenu:setVisible(true)
            temMenu:setEnabled(true)
        end
        local isFree = false
        if base.fs == 1 then
            if leftTime <= self.canSpeedTime then
                if self.fourBtns[4] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
                    temMenu:setVisible(false)
                    temMenu:setEnabled(false)
                end
                if self.fourBtns[6] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[6], "CCMenu")
                    temMenu:setVisible(true)
                    temMenu:setEnabled(true)
                    self:setPointSpShow()
                    isFree = true
                end
                if self.fourBtns[10] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[10], "CCMenu")
                    temMenu:setPosition(ccp(self.btnPosxMid, -100))
                end
            else
                if self.fourBtns[4] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
                    temMenu:setVisible(true)
                    temMenu:setEnabled(true)
                    
                    self:setPointSpShow()
                end
                if self.fourBtns[10] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[10], "CCMenu")
                    temMenu:setPosition(ccp(self.btnPosxMid, -100))
                end
                if self.fourBtns[6] ~= nil then
                    local temMenu = tolua.cast(self.fourBtns[6], "CCMenu")
                    temMenu:setVisible(false)
                    temMenu:setEnabled(false)
                end
            end
        else
            if self.fourBtns[4] ~= nil then
                local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
                temMenu:setVisible(true)
                temMenu:setEnabled(true)
                
                self:setPointSpShow()
            end
        end
        if base.allianceHelpSwitch == 1 then
            if self.fourBtns[7] ~= nil and self.fourBtns[4] ~= nil then
                local buildingSlotVo = buildingSlotVoApi:getSlotByBid(bvo.id)
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and buildingSlotVo and buildingSlotVo.hid == nil and isFree == false then
                    local seekHelpBtn = tolua.cast(self.fourBtns[7], "CCMenu")
                    seekHelpBtn:setVisible(true)
                    seekHelpBtn:setEnabled(true)
                    local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
                    temMenu:setVisible(false)
                    temMenu:setEnabled(false)
                else
                    local seekHelpBtn = tolua.cast(self.fourBtns[7], "CCMenu")
                    seekHelpBtn:setVisible(false)
                    seekHelpBtn:setEnabled(false)
                end
            end
        end
        
        if self.fourBtns[5] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[5], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.movItem then
            self.movItem:setEnabled(false)
        end
    elseif bvo.status == 1 then
        
        local temSp = tolua.cast(self.exBg, "CCNode")
        if temSp:getChildByTag(self.progressTag) ~= nil then
            tolua.cast(temSp:getChildByTag(self.progressTag), "CCProgressTimer"):removeFromParentAndCleanup(true)
            tolua.cast(temSp:getChildByTag(self.bgSpriteTag), "CCSprite"):removeFromParentAndCleanup(true)
        end
        if self.fourBtns[8] and self.movItem then
            self.movItem:setEnabled(true)
        end
        if self.fourBtns[1] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[1], "CCMenu")
            temMenu:setVisible(true)
            temMenu:setEnabled(true)
        end
        if self.fourBtns[10] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[10], "CCMenu")
            temMenu:setPosition(ccp(self.btnPosxLeft, -100))
        end
        if self.fourBtns[2] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[2], "CCMenu")
            temMenu:setVisible(true)
            temMenu:setEnabled(true)
            
            self:setPointSpShow()
        end
        
        if self.fourBtns[3] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[3], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[4] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[5] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[5], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[6] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[6], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[7] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[7], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
    elseif bvo.status == 0 then
        if self.exBg:getChildByTag(self.progressTag) ~= nil then
            tolua.cast(self.exBg:getChildByTag(self.progressTag), "CCProgressTimer"):removeFromParentAndCleanup(true)
            tolua.cast(self.exBg:getChildByTag(self.bgSpriteTag), "CCSprite"):removeFromParentAndCleanup(true)
        end
        if self.fourBtns[1] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[1], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[2] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[2], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        
        if self.fourBtns[3] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[3], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[4] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[4], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[5] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[5], "CCMenu")
            temMenu:setVisible(true)
            temMenu:setEnabled(true)
            
            self:setPointSpShow()
        end
        if self.fourBtns[6] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[6], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[7] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[7], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
        if self.fourBtns[8] then
            local temMenu = tolua.cast(self.fourBtns[8], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
    end
    if bvo.id < 16 then
        if self.fourBtns[1] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[1], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
    end
    if curBuildType == 4 then
        if self.fourBtns[1] ~= nil then
            local temMenu = tolua.cast(self.fourBtns[1], "CCMenu")
            temMenu:setVisible(false)
            temMenu:setEnabled(false)
        end
    end
    for k, v in pairs(self.requires) do
        local result = v:tick()
        if self.allCellsBtn[k] ~= nil then
            self.allCellsBtn[k]:setEnabled(result)
            self.buildBtn:setEnabled(result)
        end
        if result == false then
            if self.fourBtns[2] ~= nil then
                if self.upgradeBtnItem ~= nil then
                    self.upgradeBtnItem:setEnabled(false)
                end
                local temMenu = tolua.cast(self.fourBtns[2], "CCMenu")
                temMenu:setEnabled(false)
                
                self:setPointSpHide()
            end
        else
            if self.fourBtns[2] ~= nil then
                if self.upgradeBtnItem ~= nil then
                    self.upgradeBtnItem:setEnabled(true)
                end
                local temMenu = tolua.cast(self.fourBtns[2], "CCMenu")
                temMenu:setEnabled(true)
            end
        end
    end
    if self.lastState == nil then
        self.lastState = bvo.status
    end
    if self.lastState ~= bvo.status then
        -- if self.lastState==2 and bvo.status==1 then
        self:setPointSpHide()
        -- end
    end
end

function buildingUpgradeCommon:setPointSpShow()
    -- if self and self.isShowPoint==true then
    --     if self.halo then
    --         self.halo:setVisible(true)
    --     end
    --     if self.pointerSp then
    --         self.pointerSp:setVisible(true)
    --     end
    -- end
end
function buildingUpgradeCommon:setPointSpHide()
    -- if self then
    --     if self.halo then
    --         self.halo:setVisible(false)
    --     end
    --     if self.pointerSp then
    --         self.pointerSp:setVisible(false)
    --     end
    --     self.isShowPoint=false
    -- end
end
function buildingUpgradeCommon:movBtn(exBg)
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    local btnScale = 0.85
    local function movCall()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        mainLandScene:showTip(getlocal("movConfirmStr1"), nil, self.bid)
        local allBuildsVo = buildingVoApi:getHomeBuilding()
        for k, v in pairs(allBuildsVo) do
            if buildings.allBuildings[v.id] and buildings.allBuildings[v.id].movTipSpChose then
                buildings.allBuildings[v.id].movTipSpChose:setVisible(true)
                buildings.allBuildings[v.id].movTipSpChose:setPosition(buildings.allBuildings[v.id].movTipUsePos)
                if v.id == self.bid then
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("selfLots.png")
                    if frame then
                        tolua.cast(buildings.allBuildings[v.id].movTipSp, "CCSprite"):setDisplayFrame(frame)
                        buildings.allBuildings[v.id].movTipSpChange = true
                    end
                end
                buildings.allBuildings[v.id]:runChooseAction()
            end
        end
        self.dialog:close()
    end
    local movItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", movCall, nil, getlocal("movStr"), 25, 100)
    movItem:setScale(btnScale)
    local movMenu = CCMenu:createWithItem(movItem);
    movMenu:setPosition(ccp(exBg:getContentSize().width * 0.5, -100))
    movMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
    -- movMenu:setTag(self.removeBuildBtnTag)
    exBg:addChild(movMenu)
    self.fourBtns[8] = movMenu
    self.movItem = movItem
    if bvo.status == 2 then
        movItem:setEnabled(false)
    end
    local maxLv = buildingVoApi:canUpgradeMaxLevel(bvo.type)
    if bvo.level >= maxLv then
        movMenu:setPosition(exBg:getContentSize().width * 0.5 + 120, -100)
    end
end

--拆除建筑
function buildingUpgradeCommon:chaiBtn(exBg)
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    if bvo.type == 18 then --战争飞艇建筑不能拆除
        do return end
    end
    local btnScale, leftPosx, rightPosx = 0.85, 90, exBg:getContentSize().width - 90
    --拆除按钮
    local function chaiHandler()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        if buildingVoApi:isRemoveBuildCdOpen() == true then
            local rmInCdFlag, removeBuildCd = buildingVoApi:isBuildRemoveInCd()
            if rmInCdFlag == true and tonumber(removeBuildCd) > 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage3004"), 30)
                do return end
            end
        end
        self:setPointSpHide()
        local function chai()
            local function serverRemove(fn, data)
                --local retTb=OBJDEF:decode(data)
                if base:checkServerData(data) == true then
                    if buildingVoApi:isRemoveBuildCdOpen() == true then --有cd版移除需要消耗金币
                        playerVoApi:setGems(playerVoApi:getGems() - playerCfg.removeBuildCost)
                    end
                    buildingVoApi:removeBuild(self.bid)
                    self.dialog:close()
                end
            end
            socketHelper:removeBuild(self.bid, bvo.type, serverRemove)
        end
        --local smallD=smallDialog:new()
        --smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),chai,getlocal("dialog_title_prompt"),getlocal("BuildBoard_remove_prompt"),nil,self.layerNum+1)
        local removeBuildStr = ""
        if buildingVoApi:isRemoveBuildCdOpen() == true then
            local ownGems = playerVoApi:getGems()
            if ownGems < playerCfg.removeBuildCost then
                GemsNotEnoughDialog(nil, nil, playerCfg.removeBuildCost - ownGems, self.layerNum + 1, playerCfg.removeBuildCost)
                do return end
            end
            removeBuildStr = getlocal("build_remove_tip", {playerCfg.removeBuildCost})
        else
            removeBuildStr = getlocal("BuildBoard_remove_prompt")
        end
        allianceSmallDialog:initOKDialog(chai, removeBuildStr, self.layerNum + 1)
    end
    local chaiItem = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", chaiHandler, nil, getlocal("removeBuild"), 25, 100)
    chaiItem:setScale(btnScale)
    local chaiMenu = CCMenu:createWithItem(chaiItem);
    chaiMenu:setPosition(ccp(leftPosx, -100))
    chaiMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
    chaiMenu:setTag(self.removeBuildBtnTag)
    exBg:addChild(chaiMenu)
    local lb = chaiItem:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    self.fourBtns[1] = chaiMenu
    local maxLv = buildingVoApi:canUpgradeMaxLevel(bvo.type)
    if bvo.level >= maxLv then
        chaiMenu:setPosition(exBg:getContentSize().width * 0.5 - 120, -100)
    end
end

function buildingUpgradeCommon:resetBtn(exBg)
    
    local btnScale, leftPosx, rightPosx = 0.85, 90, exBg:getContentSize().width - 90
    local bvo = buildingVoApi:getBuildiingVoByBId(self.bid)
    --拆除建筑
    self:chaiBtn(exBg)
    --升级按钮
    local function touch1(tag, object)
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:setPointSpHide()
        local function serverUpgrade(fn, data)
            --local retTb=OBJDEF:decode(data)
            if base:checkServerData(data) == true then
                if buildingVoApi:upgrade(self.bid, bvo.type) then
                    local leftTime = GetTimeStr(buildingVoApi:getUpgradeLeftTime(self.bid))
                    AddProgramTimer(exBg, ccp(exBg:getContentSize().width / 2, -30), self.progressTag, self.upgradeTextTag, leftTime, "PanelBuildUpBarBg.png", "PanelBuildUpBar.png", self.bgSpriteTag)
                    self:tick()
                    
                end
            end
        end
        local checkResult = buildingVoApi:checkUpgradeBeforeSendServer(self.bid, bvo.type)
        if(checkResult == 0)then
            socketHelper:upgradeBuild(self.bid, bvo.type, serverUpgrade)
        elseif(checkResult == 1)then
            local function onSpeed()
                socketHelper:upgradeBuild(self.bid, bvo.type, serverUpgrade)
            end
            vipVoApi:showQueueFullDialog(1, self.layerNum + 1, onSpeed)
        end
    end
    local menuItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", touch1, nil, getlocal("upgradeBuild"), 25, 100)
    menuItem:setScale(btnScale)
    self.allCellsBtn[1] = menuItem
    if self.result == false then
        menuItem:setEnabled(false)
    end
    local lb = menuItem:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local upgradeMenu = CCMenu:createWithItem(menuItem);
    upgradeMenu:setPosition(ccp(rightPosx, -100))
    upgradeMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    upgradeMenu:setTag(self.upgradeBtnTag)
    exBg:addChild(upgradeMenu)
    self.upgradeBtnItem = menuItem
    self.fourBtns[2] = upgradeMenu
    
    if self.bid == 1 then
        if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
            local function decorateCallback(...)
                if buildDecorateVoApi.getLevelLimit and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
                    buildDecorateVoApi:showDialog(self.layerNum)
                else
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateNotLevel", {buildDecorateVoApi:getLevelLimit()}), 30)
                end
            end
            local decorateButton, decorateMenu = G_createBotton(exBg, ccp(leftPosx, -100), {getlocal("decorateTitle"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", decorateCallback, 1, -(self.layerNum - 1) * 20 - 3, 10)
            decorateButton:setScale(btnScale)
            self.btnPosxMid = exBg:getContentSize().width / 2
            self.btnPosxLeft = leftPosx
            self.fourBtns[10] = decorateMenu
            local lb = decorateButton:getChildByTag(101)
            if lb then
                lb = tolua.cast(lb, "CCLabelTTF")
                lb:setFontName("Helvetica-bold")
            end
        end
    end
    --升级进度条
    if bvo.status == 2 then
        local leftTime = GetTimeStr(tonumber(Split(buildingCfg[bvo.type].timeConsumeArray, ",")[bvo.level + 1]))
        AddProgramTimer(exBg, ccp(exBg:getContentSize().width / 2, -30), self.progressTag, self.upgradeTextTag, leftTime, "PanelBuildUpBarBg.png", "PanelBuildUpBar.png", self.bgSpriteTag)
    end
    
    --取消升级按钮
    local function cancleHandler()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:setPointSpHide()
        local function cancleUpgrade()
            
            local function serverCancleUpgrade(fn, data)
                
                --local retTb=OBJDEF:decode(data)
                if base:checkServerData(data) == true then
                    if buildingVoApi:cancleUpgradeBuild(self.bid) == false then --取消失败
                        
                    else--取消成功
                        base:tick()
                        --self:tick()
                        -- self:refreshRemoveBuildView()
                    end
                end
            end
            if buildingVoApi:checkCancleUpgradeBuildBeforeServer(self.bid) == true then
                socketHelper:cancleUpgradeBuild(self.bid, bvo.type, serverCancleUpgrade)
            end
        end
        local smallD = smallDialog:new()
        local contenStr
        if base.autoUpgrade == 1 and buildingVoApi:getAutoUpgradeBuilding() == 1 and buildingVoApi:getAutoUpgradeExpire() - base.serverTime > 0 then
            contenStr = getlocal("BuildBoard_cancel_prompt")..getlocal("building_auto_upgrade_cancle")
        else
            contenStr = getlocal("BuildBoard_cancel_prompt")
        end
        smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), cancleUpgrade, getlocal("dialog_title_prompt"), contenStr, nil, self.layerNum + 1)
        
    end
    local cancleItem = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", cancleHandler, nil, getlocal("cancelBuild"), 25, 100)
    cancleItem:setScale(btnScale)
    local cancleMenu = CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(leftPosx, -100))
    cancleMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    cancleMenu:setTag(self.cancleUpgradeTag)
    exBg:addChild(cancleMenu)
    local lb = cancleItem:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    self.fourBtns[3] = cancleMenu
    --加速升级按钮
    local function superHandler()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:setPointSpHide()
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
                            base:tick()
                            --self:tick()
                            -- self:setPointSpHide()
                            -- self:refreshRemoveBuildView()
                        end
                    end
                end
                
                if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.bid) == true then
                    socketHelper:superUpgradeBuild(self.bid, bvo.type, serverSuperUpgrade)
                end
            end
            
            local bsv = buildingSlotVoApi:getSlotByBid(bvo.id)
            if bsv == nil then
                return
            end
            
            --local leftTime=base.serverTime-bsv.st-tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1])
            local leftTime = buildingVoApi:getUpgradeLeftTime(bvo.id)
            if leftTime > 0 then
                local needGemsNum = TimeToGems(leftTime)
                local needGems = getlocal("speedUp", {needGemsNum})
                if needGemsNum > playerVoApi:getGems() then --金币不足
                    GemsNotEnoughDialog(nil, nil, needGemsNum - playerVoApi:getGems(), self.layerNum + 2, needGemsNum)
                else
                    local smallD = smallDialog:new()
                    local contenStr
                    if base.autoUpgrade == 1 and buildingVoApi:getAutoUpgradeBuilding() == 1 and buildingVoApi:getAutoUpgradeExpire() - base.serverTime > 0 then
                        contenStr = needGems..getlocal("building_auto_upgrade_quick")
                    else
                        contenStr = needGems
                    end
                    local zhhzxVo = buildingVoApi:getBuildiingVoByBId(1)
                    local level = 5
                    for k, v in pairs(homeCfg.pIndexArrayByLevel) do
                        for kk, vv in pairs(v) do
                            if vv == 7 then
                                level = k
                                break
                            end
                        end
                    end
                    local addStr = nil
                    if zhhzxVo and zhhzxVo.level and zhhzxVo.level >= level then
                        addStr = getlocal("recommendJoinAlliance_lbDes")
                    end
                    
                    smallD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), superUpgrade, getlocal("dialog_title_prompt"), contenStr, nil, self.layerNum + 2, nil, nil, nil, nil, nil, nil, nil, nil, addStr)
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
    local superItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", superHandler, nil, getlocal("accelerateBuild"), 25, 100)
    superItem:setScale(btnScale)
    local superMenu = CCMenu:createWithItem(superItem);
    superMenu:setPosition(ccp(rightPosx, -100))
    superMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    superMenu:setTag(self.superUpgradeTag)
    exBg:addChild(superMenu)
    local lb = superItem:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    self.fourBtns[4] = superMenu
    
    --建造按钮
    local function buildHandler(tag, object)
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:setPointSpHide()
        local function serverUpgrade(fn, data)
            --local retTb=OBJDEF:decode(data)
            if base:checkServerData(data) == true then
                if buildingVoApi:upgrade(self.bid, bvo.type) then
                    -- self:setPointSpHide()
                    local leftTime = GetTimeStr(buildingVoApi:getUpgradeLeftTime(self.bid))
                    AddProgramTimer(exBg, ccp(exBg:getContentSize().width / 2, -20), self.progressTag, self.upgradeTextTag, leftTime, "PanelBuildUpBarBg.png", "PanelBuildUpBar.png", self.bgSpriteTag)
                    self:tick()
                    if newGuidMgr:isNewGuiding() then --新手引导跳入下一步
                        newGuidMgr:toNextStep()
                        self.dialog:close()
                    end
                    
                end
                
            end
        end
        local checkResult = buildingVoApi:checkUpgradeBeforeSendServer(self.bid, bvo.type)
        if(checkResult == 0)then
            socketHelper:upgradeBuild(self.bid, bvo.type, serverUpgrade)
        elseif(checkResult == 1)then
            local function onSpeed()
                socketHelper:upgradeBuild(self.bid, bvo.type, serverUpgrade)
            end
            vipVoApi:showQueueFullDialog(1, self.layerNum + 1, onSpeed)
        end
        
    end
    local buildItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", buildHandler, nil, getlocal("startBuild"), 25, 100)
    buildItem:setScale(btnScale)
    self.buildBtn = buildItem
    if self.result == false then
        buildItem:setEnabled(false)
    end
    local lb = buildItem:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local buildMenu = CCMenu:createWithItem(buildItem);
    buildMenu:setPosition(ccp(rightPosx, -100))
    buildMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    buildMenu:setTag(self.buildBtnTag)
    exBg:addChild(buildMenu)
    self.fourBtns[5] = buildMenu
    if newGuidMgr:isNewGuiding() == true and newGuidMgr.curStep == 1 then
        self.guildItem = buildItem
    end
    
    --免费加速按钮
    -- base.fs=0
    if base.fs == 1 then
        local function freeAccHandler(tag, object)
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            self:setPointSpHide()
            
            local function superUpgrade()
                local function serverSuperUpgrade(fn, data)
                    --local retTb=OBJDEF:decode(data)
                    if base:checkServerData(data) == true then
                        if buildingVoApi:superUpgradeBuild(self.bid) then --加速成功
                            base:tick()
                            --self:tick()
                            -- self:setPointSpHide()
                            -- self:refreshRemoveBuildView()
                        end
                    end
                end
                
                if buildingVoApi:checkSuperUpgradeBuildBeforeServer(self.bid) == true then
                    socketHelper:freeUpgradeBuild(self.bid, bvo.type, serverSuperUpgrade)
                end
            end
            local bsv = buildingSlotVoApi:getSlotByBid(bvo.id)
            if bsv == nil then
                return
            end
            --local leftTime=base.serverTime-bsv.st-tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1])
            local leftTime = buildingVoApi:getUpgradeLeftTime(bvo.id)
            if leftTime and leftTime <= self.canSpeedTime then
                -- 这里写免费加速的请求
                superUpgrade()
            end
        end
        local freeAccItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", freeAccHandler, nil, getlocal("freeAccelerate"), 25, 100)
        freeAccItem:setScale(btnScale)
        local freeAccMenu = CCMenu:createWithItem(freeAccItem);
        freeAccMenu:setPosition(ccp(rightPosx, -100))
        freeAccMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
        freeAccMenu:setTag(self.buildBtnTag)
        exBg:addChild(freeAccMenu)
        local lb = freeAccItem:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        self.fourBtns[6] = freeAccMenu
    end
    
    if base.allianceHelpSwitch == 1 then
        local function seekHelpHandler()
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
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
                        base:tick()
                    end
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_help_success"), 30)
                end
            end
            local leftTime = buildingVoApi:getUpgradeLeftTime(bvo.id)
            local buildingSlotVo = buildingSlotVoApi:getSlotByBid(bvo.id)
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and leftTime and leftTime > 0 and buildingSlotVo and buildingSlotVo.hid == nil then
                if base.fs == 1 then
                    local canSpeedTime = playerVoApi:getFreeTime()
                    if leftTime > canSpeedTime then
                        local bid = bvo.id
                        local btype = bvo.type
                        socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                    end
                else
                    local bid = bvo.id
                    local btype = bvo.type
                    socketHelper:buildingAlliancehelp(bid, btype, helpCallback)
                end
            end
        end
        local seekHelpItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", seekHelpHandler, nil, getlocal("alliance_help"), 25, 100)
        seekHelpItem:setScale(btnScale)
        local seekHelpMenu = CCMenu:createWithItem(seekHelpItem)
        seekHelpMenu:setPosition(ccp(rightPosx, -100))
        seekHelpMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        seekHelpMenu:setTag(self.buildBtnTag)
        exBg:addChild(seekHelpMenu)
        local lb = seekHelpItem:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        self.fourBtns[7] = seekHelpMenu
    end
    
    if self.isShowPoint == true then
        -- local function nilFunc()
        -- end
        -- self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
        -- self.halo:setContentSize(CCSizeMake(buildItem:getContentSize().width+10,buildItem:getContentSize().height+10))
        -- self.halo:setAnchorPoint(ccp(0.5,0.5))
        -- self.halo:setTouchPriority(-(self.layerNum-1)*20-1)
        -- self.halo:setPosition(ccp(exBg:getContentSize().width-100-1,-100+1))
        -- exBg:addChild(self.halo,5)
        -- self.halo:setVisible(false)
        
        -- self.pointerSp=CCSprite:createWithSpriteFrameName("ArowShape.png")
        -- self.pointerSp:setPosition(ccp(exBg:getContentSize().width-100,-100+100))
        -- exBg:addChild(self.pointerSp,5)
        -- local up=CCMoveBy:create(0.35,CCPointMake(0,50/2))
        -- local down=CCMoveBy:create(0.35,CCPointMake(0,-50/2))
        -- local seq=CCSequence:createWithTwoActions(up,down)
        -- self.pointerSp:runAction(CCRepeatForever:create(seq))
        -- self.pointerSp:setVisible(false)
    end
    
    self:tick()
    -- self:refreshRemoveBuildView()
    
end

function buildingUpgradeCommon:refreshRemoveBuildView()
    -- if self.arriveMaxLevel==true then
    --   do return end
    -- end
    if buildingVoApi:isRemoveBuildCdOpen() == false then
        do return end
    end
    if buildingVoApi:checkBuildCanRemove(self.bid) == false then
        if self.rbViewNode and tolua.cast(self.rbViewNode, "CCNode") then
            self.rbViewNode:removeFromParentAndCleanup(true)
            self.rbViewNode = nil
            self.rmbCdTimeLb, self.rmbCostLb, self.rmbGemSp = nil, nil, nil
        end
        do return end
    end
    if self.fourBtns == nil or self.fourBtns[1] == nil then
        do return end
    end
    if self.rbViewNode == nil or tolua.cast(self.rbViewNode, "CCNode") == nil then
        local rbViewNode = CCNode:create()
        rbViewNode:setAnchorPoint(ccp(0.5, 0.5))
        self.exBg:addChild(rbViewNode, 2)
        self.rbViewNode = rbViewNode
        local chaiMenu = self.fourBtns[1]
        self.rbViewNode:setPosition(chaiMenu:getPositionX(), chaiMenu:getPositionY() + 50)
        self.rmbCdTimeLb = nil
        self.rmbCostLb = nil
        self.rmbGemSp = nil
    end
    local rmInCdFlag, removeBuildCd = buildingVoApi:isBuildRemoveInCd()
    if rmInCdFlag == false then --可以拆除时显示拆除需要消耗的金币数
        if self.rmbCdTimeLb and tolua.cast(self.rmbCdTimeLb, "CCLabelTTF") then
            self.rmbCdTimeLb:removeFromParentAndCleanup(true)
            self.rmbCdTimeLb = nil
        end
        if self.rmbCostLb == nil or self.rmbGemSp == nil then
            --消耗的金币数
            local costLb = GetTTFLabel(playerCfg.removeBuildCost, 22)
            costLb:setAnchorPoint(ccp(0, 0.5))
            costLb:setColor(G_ColorYellowPro3)
            self.rbViewNode:addChild(costLb)
            local gemSp = CCSprite:createWithSpriteFrameName("IconGold.png")
            gemSp:setAnchorPoint(ccp(0, 0.5))
            self.rbViewNode:addChild(gemSp)
            self.rbViewNode:setContentSize(CCSizeMake(costLb:getContentSize().width + gemSp:getContentSize().width + 10, 30))
            costLb:setPosition(0, self.rbViewNode:getContentSize().height / 2)
            gemSp:setPosition(costLb:getPositionX() + costLb:getContentSize().width + 10, self.rbViewNode:getContentSize().height / 2)
            self.rmbCostLb, self.rmbGemSp = costLb, gemSp
        end
    else --在拆除cd时间内，显示剩余cd时间
        if self.rmbCostLb and self.rmbGemSp then
            self.rmbCostLb:removeFromParentAndCleanup(true)
            self.rmbGemSp:removeFromParentAndCleanup(true)
            self.rmbCostLb, self.rmbGemSp = nil, nil
        end
        if removeBuildCd > 0 then
            local cdStr = "CD："..G_formatActiveDate(removeBuildCd)
            if self.rmbCdTimeLb == nil then
                local rmbCdTimeLb = GetTTFLabel(cdStr, 22)
                self.rbViewNode:setContentSize(CCSizeMake(rmbCdTimeLb:getContentSize().width, 30))
                rmbCdTimeLb:setPosition(getCenterPoint(self.rbViewNode))
                rmbCdTimeLb:setColor(G_ColorRed)
                self.rbViewNode:addChild(rmbCdTimeLb)
                self.rmbCdTimeLb = rmbCdTimeLb
            elseif tolua.cast(self.rmbCdTimeLb, "CCLabelTTF") then
                self.rmbCdTimeLb:setString(cdStr)
            end
        else
            self:refreshRemoveBuildView()
        end
    end
end

function buildingUpgradeCommon:dispose()
    if self.speedUpSmallDialog then
        self.speedUpSmallDialog:close()
        self.speedUpSmallDialog = nil
    end
    if(eventDispatcher:hasEventHandler("activity.levelingOpenOrClose", self.listener) == true)then
        eventDispatcher:removeEventListener("activity.levelingOpenOrClose", self.listener)
    end
    self.listener = nil
    
    for k, v in pairs(self.requires) do
        v = nil
    end
    self.layerNum = nil
    self.requires = nil
    self.allCellsBtn = nil
    self.buildBtn = nil
    self.exBg = nil
    self.fourBtns = nil
    self.tmIco = nil
    self.tmLb = nil
    self.acDis = nil
    self.acDisBg = nil
    self.bDescLb = nil
    self.upgradeBtnItem = nil
    self.isShowPoint = nil
    self.halo = nil
    self.pointerSp = nil
    self.lastState = nil
    self.guildItem = nil
    self.movItem = nil
    self.rmbCdTimeLb = nil
    self.rmbCostLb, self.rmbGemSp = nil, nil
    self.rbViewNode = nil
end

