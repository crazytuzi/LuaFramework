personalRebelSmallDialog = smallDialog:new()

function personalRebelSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function personalRebelSmallDialog:showBagDialog(layerNum, titleStr)
    local sd = personalRebelSmallDialog:new()
    sd:initBagDialog(layerNum, titleStr)
end

function personalRebelSmallDialog:initBagDialog(layerNum, titleStr)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 580)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(self.bgSize.width - 50, self.bgSize.height - 115))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 88)
    self.bgLayer:addChild(tableViewBg)
    
    local itemTb = rebelVoApi:pr_getBagItem()
    local cellNum = SizeOfTable(itemTb)
    local tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvSize.width, 150)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = tvSize.width, 150
            local itemData = itemTb[idx + 1]
            local iconSize = 95
            local icon, scale = G_getItemIcon(itemData, 100, false, self.layerNum, function()
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, itemData, nil, nil, nil, nil, true)
            end)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setPosition(10 + iconSize / 2, cellH / 2)
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            cell:addChild(icon)
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            nameBg:setContentSize(CCSizeMake(cellW - (icon:getPositionX() + iconSize / 2 + 115), nameBg:getContentSize().height))
            nameBg:setAnchorPoint(ccp(0, 1))
            nameBg:setPosition(icon:getPositionX() + iconSize / 2 + 10, icon:getPositionY() + iconSize / 2)
            cell:addChild(nameBg)
            local nameLb = GetTTFLabel(itemData.name, (G_isAsia() == false) and 16 or 22, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(15, nameBg:getContentSize().height / 2)
            nameLb:setColor(G_ColorYellowPro)
            nameBg:addChild(nameLb)
            local descStr = getlocal(itemData.desc)
            local descWidth = cellW - (nameBg:getPositionX() + 15 + 135)
            local descHeight = nameBg:getPositionY() - nameBg:getContentSize().height - 10
            local descLb = GetTTFLabelWrap(descStr, 18, CCSizeMake(descWidth, descHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(nameBg:getPositionX() + 15, nameBg:getPositionY() - nameBg:getContentSize().height)
            cell:addChild(descLb)
            local numLb = GetTTFLabel(getlocal("propInfoNum", { itemData.num }), 18)
            numLb:setAnchorPoint(ccp(0.5, 0))
            cell:addChild(numLb)
            if itemData.key == "p2" then
            	numLb:setPosition(cellW - 71.5, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2)
            else
	            local function onClickUseBtn(tag, obj)
	                if G_checkClickEnable() == false then
	                    do return end
	                else
	                    base.setWaitTime = G_getCurDeviceMillTime()
	                end
	                PlayEffect(audioCfg.mouseClick)
	                --使用道具逻辑
	                rebelVoApi:pr_requestUseProp(function()
	                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("decorateUseSucess"), 30)
	                        self:close(function()
	                                eventDispatcher:dispatchEvent("personalRebelDialog.refresh", (itemData.key == "p3") and {eventType == 1} or nil)
	                            end)
	                end, itemData.key)
	            end
	            local btnScale = 0.6
	            local useBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickUseBtn, 11, getlocal("use"), 24 / btnScale)
	            useBtn:setScale(btnScale)
	            useBtn:setAnchorPoint(ccp(1, 0))
	            local menu = CCMenu:createWithItem(useBtn)
	            menu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	            menu:setPosition(cellW - 10, icon:getPositionY() - iconSize / 2)
	            cell:addChild(menu)
	            if itemData.num <= 0 or (itemData.key == "p1" and rebelVoApi:pr_isCanUseFog() == false) then
	                useBtn:setEnabled(false)
	            end
	            numLb:setPosition(menu:getPositionX() - useBtn:getContentSize().width * btnScale / 2, menu:getPositionY() + useBtn:getContentSize().height * btnScale + 3)
        	end
            if idx + 1 < cellNum then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                lineSp:setContentSize(CCSizeMake(cellW - 20, 4))
                lineSp:setPosition(cellW / 2, 0)
                lineSp:setRotation(180)
                cell:addChild(lineSp)
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setPosition(ccp(3, 3))
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(tv)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

------------------------------------【叛军信息界面】------------------------------------

function personalRebelSmallDialog:showInfoDialog(layerNum, params)
    local sd = personalRebelSmallDialog:new()
    sd:initInfoDialog(layerNum, params)
end

function personalRebelSmallDialog:initInfoDialog(layerNum, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    spriteController:addPlist("public/boss_fuben_images.plist")
    spriteController:addTexture("public/boss_fuben_images.png")
    spriteController:addPlist("serverWar/serverWar2.plist")
    spriteController:addTexture("serverWar/serverWar2.png")
    self.removeResFunc = function()
        spriteController:removePlist("public/boss_fuben_images.plist")
        spriteController:removeTexture("public/boss_fuben_images.png")
        spriteController:removePlist("serverWar/serverWar2.plist")
        spriteController:removeTexture("serverWar/serverWar2.png")
    end
    
    local data = params[1]
    local position = params[2]
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(550, 680)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local closeBtnItem = GetButtonItem("newCloseBtn.png", "newCloseBtn_Down.png", "newCloseBtn.png", closeDialog)
    closeBtnItem:setAnchorPoint(ccp(0, 0))
    closeBtnItem:setPosition(0, 0)
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    closeBtn:setPosition(ccp(self.bgSize.width - closeBtnItem:getContentSize().width, self.bgSize.height - closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn, 9)
    
    local tankId = rebelVoApi:pr_getMonsterIconId(data.npcType, data.monsterId)
    if tankId then
        --叛军信息
        tankId = tonumber(RemoveFirstChar(tankId))
        local posY = self.bgSize.height - 40
        local tankIconBg = LuaCCSprite:createWithSpriteFrameName("alliance_boss_dissectionbg.png", function()end)
        tankIconBg:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        tankIconBg:setAnchorPoint(ccp(0, 1))
        tankIconBg:setScale(1.2)
        tankIconBg:setPosition(20, posY)
        self.bgLayer:addChild(tankIconBg)
        local tankIcon = G_getTankPic(tankId, nil, nil, nil, nil, false)
        tankIcon:setScale(100 / tankIcon:getContentSize().height)
        tankIcon:setPosition(getCenterPoint(tankIconBg))
        tankIconBg:addChild(tankIcon)
        local nameStr = rebelVoApi:pr_getMonsterName(data.npcType, tankId)
        local nameLbWidth = self.bgSize.width - (tankIconBg:getPositionX() + tankIconBg:getContentSize().width * tankIconBg:getScale() + 50)
        local nameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(nameLbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(tankIconBg:getPositionX() + tankIconBg:getContentSize().width * tankIconBg:getScale() + 5, tankIconBg:getPositionY() - 5)
        self.bgLayer:addChild(nameLb)
        local levelLb = GetTTFLabel(getlocal("world_war_level", { data.monsterLv }), 22)
        levelLb:setAnchorPoint(ccp(0, 1))
        levelLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 5)
        self.bgLayer:addChild(levelLb)
        local hpBg = CCSprite:createWithSpriteFrameName("rebelProgressBg.png")
        local hpProgressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("rebelProgress.png"))
        hpProgressBar:setMidpoint(ccp(0, 1))
        hpProgressBar:setBarChangeRate(ccp(1, 0))
        hpProgressBar:setType(kCCProgressTimerTypeBar)
        hpProgressBar:setPosition(hpBg:getContentSize().width / 2, hpBg:getContentSize().height / 2)
        local perValue = data.monsterHp / data.monsterMaxHp * 100
        hpProgressBar:setPercentage(perValue)
        hpBg:addChild(hpProgressBar)
        local hpPerLb = GetTTFLabel(G_keepNumber(perValue, 2) .. "%", 20)
        hpPerLb:setPosition(hpBg:getContentSize().width / 2, hpBg:getContentSize().height / 2)
        hpBg:addChild(hpPerLb)
        hpBg:setPosition(nameLb:getPositionX() + hpBg:getContentSize().width / 2, tankIconBg:getPositionY() - tankIconBg:getContentSize().height * tankIconBg:getScale() + hpBg:getContentSize().height / 2)
        self.bgLayer:addChild(hpBg)
        posY = tankIconBg:getPositionY() - tankIconBg:getContentSize().height * tankIconBg:getScale()
        
        --线
        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setScaleX(self.bgSize.width / lineSp:getContentSize().width)
        lineSp:setScaleY(1.2)
        lineSp:setPosition(self.bgSize.width / 2, posY - 25)
        self.bgLayer:addChild(lineSp)
        posY = lineSp:getPositionY() - 35
        
        --连续讨伐提示
        if data.doubleHit and data.doubleHit > 0 then
            local doubleHitLb = GetTTFLabel(getlocal("worldRebel_attackCombo", {data.doubleHit}), 22)
            doubleHitLb:setColor(G_ColorYellowPro)
            doubleHitLb:setPosition(self.bgSize.width / 2, posY)
            self.bgLayer:addChild(doubleHitLb)
            posY = doubleHitLb:getPositionY() - doubleHitLb:getContentSize().height / 2 - 5
            local buffLb1 = GetTTFLabel(getlocal("worldRebel_comboBuff", {""}), 22)
            buffLb1:setAnchorPoint(ccp(0, 0.5))
            buffLb1:setPosition(30, posY - buffLb1:getContentSize().height / 2)
            self.bgLayer:addChild(buffLb1)
            local buffLb2 = GetTTFLabel((rebelCfg.attackBuff * 100 * data.doubleHit) .. "%", 22)
            buffLb2:setColor(G_ColorGreen)
            buffLb2:setAnchorPoint(ccp(1, 0.5))
            buffLb2:setPosition(self.bgSize.width - 30, buffLb1:getPositionY())
            self.bgLayer:addChild(buffLb2)
            posY = buffLb1:getPositionY() - 35
        else
            local tipsLb = GetTTFLabelWrap(getlocal("worldRebel_comboTitle"), 20, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            tipsLb:setPosition(self.bgSize.width / 2, posY - tipsLb:getContentSize().height / 2)
            self.bgLayer:addChild(tipsLb)
            posY = tipsLb:getPositionY() - tipsLb:getContentSize().height / 2 - 35
        end
        
        --奖励
        local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        rewardBg:setContentSize(CCSizeMake(self.bgSize.width - 30, 150))
        rewardBg:setPosition(self.bgSize.width / 2, posY - rewardBg:getContentSize().height / 2)
        self.bgLayer:addChild(rewardBg)
        local rewardLb = GetTTFLabel(getlocal("award"), 24, true)
        rewardLb:setAnchorPoint(ccp(0.5, 1))
        rewardLb:setPosition(rewardBg:getContentSize().width / 2, rewardBg:getContentSize().height - 5)
        rewardLb:setColor(G_ColorYellowPro)
        rewardBg:addChild(rewardLb)
        local rewardTvSize = CCSizeMake(rewardBg:getContentSize().width - 30, 100)
        local rewardTb = rebelVoApi:pr_getReward(data)
        local cellNum = SizeOfTable(rewardTb or {})
        local function tvCallBack(handler, fn, idx, cel)
            if fn == "numberOfCellsInTableView" then
                return cellNum
            elseif fn == "tableCellSizeForIndex" then
                return CCSizeMake(110, rewardTvSize.height)
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                local cellW, cellH = 110, rewardTvSize.height
                local item = rewardTb[idx + 1]
                local iconSize = 95
                local icon, scale = G_getItemIcon(item, 100, false, self.layerNum, function()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
                end)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setPosition(cellW / 2, cellH / 2)
                icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                cell:addChild(icon)
                return cell
            elseif fn == "ccTouchBegan" then
                return true
            elseif fn == "ccTouchMoved" then
            elseif fn == "ccTouchEnded" then
            end
        end
        local hd = LuaEventHandler:createHandler(tvCallBack)
        local rewardTv = LuaCCTableView:createHorizontalWithEventHandler(hd, rewardTvSize, nil)
        rewardTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
        rewardTv:setPosition((rewardBg:getContentSize().width - rewardTvSize.width) / 2, 10)
        rewardTv:setMaxDisToBottomOrTop(80)
        rewardBg:addChild(rewardTv)
        posY = rewardBg:getPositionY() - rewardBg:getContentSize().height / 2 - 10
        
        --体力
        local energyLb
        local buyEnergyBg = CCSprite:createWithSpriteFrameName("rebelEnergyBtnBg.png")
        posY = posY - 20 - buyEnergyBg:getContentSize().height / 2
        local energyPosY = posY
        local maxEnergy = rebelCfg.energyMax
        local tempSp = CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
        local space = 20
        local totalWidth = (tempSp:getContentSize().width + space) * maxEnergy + buyEnergyBg:getContentSize().width
        tempSp = nil
        local function initEnergyUI()
            local curEnergy = rebelVoApi:getRebelEnergy()
            local startX = (self.bgSize.width - totalWidth) / 2
            for i = 1, maxEnergy do
                if tolua.cast(self.bgLayer:getChildByTag(1000 + i), "CCSprite") then
                    tolua.cast(self.bgLayer:getChildByTag(1000 + i), "CCSprite"):removeFromParentAndCleanup(true)
                end
                if tolua.cast(self.bgLayer:getChildByTag(2000 + i), "CCSprite") then
                    tolua.cast(self.bgLayer:getChildByTag(2000 + i), "CCSprite"):removeFromParentAndCleanup(true)
                end
                local energyIcon = CCSprite:createWithSpriteFrameName("serverWarTIcon" .. ((i > curEnergy) and 1 or 2) .. ".png")
                energyIcon:setAnchorPoint(ccp(0, 0.5))
                energyIcon:setPosition(startX, energyPosY)
                energyIcon:setTag(1000 + i)
                self.bgLayer:addChild(energyIcon, 1)
                if i ~= maxEnergy then
                    local spaceSp
                    if i > curEnergy then
                        spaceSp = LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg3.png", CCRect(0, 2, 8, 4), function()end)
                        spaceSp:setContentSize(CCSizeMake(space + 4, 8))
                    else
                        spaceSp = LuaCCScale9Sprite:createWithSpriteFrameName("serverWarProgressBg2.png", CCRect(0, 0, 4, 4), function()end)
                        spaceSp:setContentSize(CCSizeMake(space + 4, 6))
                    end
                    spaceSp:setAnchorPoint(ccp(0, 0.5))
                    spaceSp:setPosition(startX + energyIcon:getContentSize().width - 2, energyPosY)
                    spaceSp:setTag(2000 + i)
                    self.bgLayer:addChild(spaceSp)
                end
                startX = startX + (energyIcon:getContentSize().width + space)
            end
            buyEnergyBg:setPosition(startX + buyEnergyBg:getContentSize().width / 2, energyPosY)
            if energyLb and curEnergy >= rebelVoApi:pr_getCostEnergy(data.npcId) then
                energyLb:setColor(G_ColorWhite)
            end
        end
        initEnergyUI()
        self.bgLayer:addChild(buyEnergyBg)
        local function onBuyEnergy(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if rebelVoApi:getRebelEnergy() >= maxEnergy then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("worldRebel_energyFull"), 30)
                do return end
            end
            if rebelVoApi:checkCanBuyRebelEnergy() then --购买行动力
                rebelVoApi:pr_showBuyEnergySmallDialog(self.layerNum + 1, {function() initEnergyUI() end})
            else
                if playerVoApi:getVipLevel() >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage24001"), 30)
                else
                    local function onConfirm()
                        self:close()
                        vipVoApi:showRechargeDialog(self.layerNum + 1)
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("worldRebel_energyBuyMax"), nil, self.layerNum + 1)
                end
            end
        end
        local buyEnergyBtn = GetButtonItem("rebelEnergyBtn.png", "rebelEnergyBtn_down.png", "rebelEnergyBtn_down.png", onBuyEnergy)
        local buyEnergyMenu = CCMenu:createWithItem(buyEnergyBtn)
        buyEnergyMenu:setPosition(buyEnergyBg:getContentSize().width / 2, buyEnergyBg:getContentSize().height / 2)
        buyEnergyMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        buyEnergyBg:addChild(buyEnergyMenu)
        posY = posY - buyEnergyBg:getContentSize().height / 2 - 30
        
        --消耗品
        local costIconSize = 32
        posY = posY - costIconSize / 2
        local costCrystal = rebelVoApi:pr_getCostCrystal(data.npcType, data.monsterLv)
        local costEnergy = rebelVoApi:pr_getCostEnergy(data.npcId)
        local costPropNum = rebelVoApi:pr_getCostPropNum(data.npcId)
        local crystalIcon = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
        local costCrystalLb = GetTTFLabel("-" .. FormatNumber(costCrystal), 25)
        costCrystalLb:setAnchorPoint(ccp(0, 0.5))
        if playerVoApi:getGold() < costCrystal then
            costCrystalLb:setColor(G_ColorRed)
        end
        crystalIcon:setScale(costIconSize / crystalIcon:getContentSize().height)
        crystalIcon:setPositionY(posY)
        costCrystalLb:setPositionY(posY)
        self.bgLayer:addChild(crystalIcon)
        self.bgLayer:addChild(costCrystalLb)
        local energyIcon = CCSprite:createWithSpriteFrameName("serverWarTIcon2.png")
        energyLb = GetTTFLabel("-" .. costEnergy, 25)
        energyLb:setAnchorPoint(ccp(0, 0.5))
        if rebelVoApi:getRebelEnergy() < costEnergy then
            energyLb:setColor(G_ColorRed)
        end
        energyIcon:setScale(costIconSize / energyIcon:getContentSize().height)
        energyIcon:setPositionY(posY)
        energyLb:setPositionY(posY)
        self.bgLayer:addChild(energyIcon)
        self.bgLayer:addChild(energyLb)
        local propData = rebelVoApi:pr_getCfg().propList["p2"]
        local propIcon = CCSprite:createWithSpriteFrameName(propData.icon)
        local propLb = GetTTFLabel("-" .. costPropNum, 25)
        propLb:setAnchorPoint(ccp(0, 0.5))
        if rebelVoApi:pr_getPropNum(propData.id) < costPropNum then
            propLb:setColor(G_ColorRed)
        end
        propIcon:setScale(costIconSize / propIcon:getContentSize().height)
        propIcon:setPositionY(posY)
        propLb:setPositionY(posY)
        self.bgLayer:addChild(propIcon)
        self.bgLayer:addChild(propLb)
        posY = posY - costIconSize / 2 - 5
        
        --按钮
        local function onClickHandler(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if tag == 10 then
                --侦察逻辑
                local function onSureLogic()
                    if playerVoApi:getGold() >= costCrystal then
                        rebelVoApi:pr_requestScout(function(report)
                                self:close()
                                playerVoApi:setGold(playerVoApi:getGold() - costCrystal)
                                rebelVoApi:pr_showReportDetailDialog(self.layerNum + 1, report)
                        end, {position.x, position.y})
                    else
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("reputation_scene_money_require"), true, self.layerNum + 1)
                    end
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("rebel_info_scout_tip", {FormatNumber(costCrystal)}), nil, self.layerNum + 1)
            elseif tag == 11 then
                --判断是否有能量
                if rebelVoApi:getRebelEnergy() < costEnergy then
                    if rebelVoApi:checkCanBuyRebelEnergy() then
                        rebelVoApi:pr_showBuyEnergySmallDialog(self.layerNum + 1, {function() initEnergyUI() end})
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dimensionalWar_event_title7"), 30)
                    end
                    do return end
                end
                self:close()
                local function battleCallback(rData, isVictory, closeBattleCallback, battleLayerNum)
                    --战斗完成刷新界面
                    if rData then
                    	rData = FormatItem(rData, nil, true)
                    	for k, v in pairs(rData) do
                    		if v.type ~= "rg" and v.type ~= "o" then
				                G_addPlayerAward(v.type, v.key, v.id, v.num, true, true)
				            end
                    	end
                        local eventType = (isVictory == true) and 5 or 4
                        rebelVoApi:pr_showRewardSmallDialog((battleLayerNum or self.layerNum) + 1, {eventType, rData, function()
                                -- if type(closeBattleCallback) == "function" then
                                --     closeBattleCallback()
                                -- end
                                eventDispatcher:dispatchEvent("personalRebelDialog.refresh")
                        end, closeBattleCallback})

                        rebelVoApi:rebelGet(function()
                            eventDispatcher:dispatchEvent("refresh.flag.numbg")
                        end)
                    end
                end
                local battleParam = {callbackFunc = battleCallback, position = {position.x, position.y}, eventType = "personalRebel", prName = nameStr}
                battleParam.repairStr = getlocal("personalRebel_repairTankText")
                require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
                local td = tankStoryDialog:new(nil, nil, nil, nil, nil, nil, nil, nil, nil, battleParam)
                local tbArr = {getlocal("AEFFighting"), getlocal("dispatchCard"), getlocal("repair")}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("AEFFighting"), true, self.layerNum + 1)
                sceneGame:addChild(dialog, self.layerNum + 1)
            elseif tag == 12 then
                --秒杀逻辑
                if rebelVoApi:pr_getPropNum(propData.id) < costPropNum then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_fyss_propNoEnough"), 30)
                    do return end
                end
                rebelVoApi:pr_requestUseProp(function(rData)
                        self:close()
                        if rData then
                        	rData = FormatItem(rData, nil, true)
                        	for k, v in pairs(rData) do
                        		if v.type ~= "rg" then
					                G_addPlayerAward(v.type, v.key, v.id, v.num, true, true)
					            end
                        	end
                            rebelVoApi:pr_showRewardSmallDialog(self.layerNum + 1, {3, rData, function()
                                    eventDispatcher:dispatchEvent("personalRebelDialog.refresh")
                                end})
                        end
                end, propData.id, {position.x, position.y})
            end
        end
        local btnScale, btnFontSize = 0.7, 24
        local scoutBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("city_info_scout"), btnFontSize / btnScale)
        local attackBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("worldRebel_attack"), btnFontSize / btnScale)
        local killBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("activity_new112018_tab1"), btnFontSize / btnScale)
        local menuArr = CCArray:create()
        menuArr:addObject(scoutBtn)
        menuArr:addObject(attackBtn)
        menuArr:addObject(killBtn)
        local btnMenu = CCMenu:createWithArray(menuArr)
        btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        btnMenu:setPosition(ccp(0, 0))
        self.bgLayer:addChild(btnMenu)
        scoutBtn:setScale(btnScale)
        attackBtn:setScale(btnScale)
        killBtn:setScale(btnScale)
        local btnSpaceW = 30
        attackBtn:setPosition(self.bgSize.width / 2, posY - attackBtn:getContentSize().height * btnScale / 2)
        scoutBtn:setPosition(attackBtn:getPositionX() - attackBtn:getContentSize().width * btnScale - btnSpaceW, posY - scoutBtn:getContentSize().height * btnScale / 2)
        killBtn:setPosition(attackBtn:getPositionX() + attackBtn:getContentSize().width * btnScale + btnSpaceW, posY - killBtn:getContentSize().height * btnScale / 2)
        
        local startX1 = (scoutBtn:getContentSize().width * btnScale - (crystalIcon:getContentSize().width * crystalIcon:getScale() + costCrystalLb:getContentSize().width)) / 2
        local startX2 = (attackBtn:getContentSize().width * btnScale - (energyIcon:getContentSize().width * energyIcon:getScale() + energyLb:getContentSize().width)) / 2
        local startX3 = (killBtn:getContentSize().width * btnScale - (propIcon:getContentSize().width * propIcon:getScale() + propLb:getContentSize().width)) / 2
        startX1 = startX1 + (scoutBtn:getPositionX() - scoutBtn:getContentSize().width * scoutBtn:getScale() / 2)
        startX2 = startX2 + (attackBtn:getPositionX() - attackBtn:getContentSize().width * attackBtn:getScale() / 2)
        startX3 = startX3 + (killBtn:getPositionX() - killBtn:getContentSize().width * killBtn:getScale() / 2)
        crystalIcon:setPositionX(startX1 + crystalIcon:getContentSize().width * crystalIcon:getScale() / 2)
        costCrystalLb:setPositionX(crystalIcon:getPositionX() + crystalIcon:getContentSize().width * crystalIcon:getScale() / 2)
        energyIcon:setPositionX(startX2 + energyIcon:getContentSize().width * energyIcon:getScale() / 2)
        energyLb:setPositionX(energyIcon:getPositionX() + energyIcon:getContentSize().width * energyIcon:getScale() / 2)
        propIcon:setPositionX(startX3 + propIcon:getContentSize().width * propIcon:getScale() / 2)
        propLb:setPositionX(propIcon:getPositionX() + propIcon:getContentSize().width * propIcon:getScale() / 2)
    end
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

------------------------------------【购买行动力界面】------------------------------------

function personalRebelSmallDialog:showBuyEnergyDialog(layerNum, params)
    local sd = personalRebelSmallDialog:new()
    sd:initBuyEnergyDialog(layerNum, params)
end

function personalRebelSmallDialog:initBuyEnergyDialog(layerNum, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local buyCallback = params[1]
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    touchDialogBg:setOpacity(120)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:addChild(touchDialogBg)
    
    local tickFunc, tickId
    local function closeDialog()
        if tickId ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickId)
            tickId = nil
        end
        self:close()
    end
    
    local recoverLeft = rebelVoApi:getEnergyRecoverTs() - base.serverTime
    local recoverEnergy = rebelVoApi:getEnergyBuyMax()
    local recoverCost1 = rebelVoApi:getBuyRebelEneryCost(1)
    local recoverCost2 = rebelVoApi:getBuyRebelEneryCost(2)
    local energyCountDown = GetTTFLabel(getlocal("worldRebel_buyEnergyConfirm1", {GetTimeStr(recoverLeft)}), 25)
    local height = energyCountDown:getContentSize().height
    local descLb1, descLb2, height1, height2
    local buyLimitLb = GetTTFLabelWrap(getlocal("worldRebel_buyEnergyNum", {rebelVoApi:getBuyEnergy(), rebelCfg.vipBuyLimit[playerVoApi:getVipLevel() + 1]}), 25, CCSizeMake(470, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    height = height + buyLimitLb:getContentSize().height
    descLb1, height1 = G_getRichTextLabel(getlocal("worldRebel_buyEnergyConfirm2"), {G_ColorWhite}, 25, 470, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    height = height + height1
    descLb2, height2 = G_getRichTextLabel(getlocal("worldRebel_buyEnergyConfirm3"), {G_ColorWhite, G_ColorYellowPro, G_ColorWhite}, 25, 470, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    height = height + height2 + 230
    
    self.bgSize = CCSizeMake(530, height)
    self.bgLayer = G_getNewDialogBg(self.bgSize, getlocal("dialog_title_prompt"), 28, nil, self.layerNum, true, closeDialog)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(false)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    energyCountDown:setAnchorPoint(ccp(0, 1))
    energyCountDown:setPosition(30, self.bgSize.height - 90)
    self.bgLayer:addChild(energyCountDown)
    buyLimitLb:setAnchorPoint(ccp(0, 1))
    buyLimitLb:setPosition(30, self.bgSize.height - 90 - energyCountDown:getContentSize().height)
    self.bgLayer:addChild(buyLimitLb)
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width - 60, 2))
    lineSp:setPosition(265, self.bgSize.height - 95 - energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height)
    self.bgLayer:addChild(lineSp)
    descLb1:setAnchorPoint(ccp(0, 1))
    descLb1:setPosition(30, self.bgSize.height - 100 - energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height)
    self.bgLayer:addChild(descLb1)
    descLb2:setAnchorPoint(ccp(0, 1))
    descLb2:setPosition(30, self.bgSize.height - 100 - energyCountDown:getContentSize().height - buyLimitLb:getContentSize().height - height1)
    self.bgLayer:addChild(descLb2)
    local costIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    costIcon:setPosition(ccp(80, 110))
    self.bgLayer:addChild(costIcon)
    local costLb = GetTTFLabel("-" .. recoverCost1, 23)
    if(recoverCost1 > playerVoApi:getGems())then
        costLb:setColor(G_ColorRed)
    end
    costLb:setPosition(ccp(120, 110))
    self.bgLayer:addChild(costLb)
    
    local function onClickBuyBtn(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local paramRecoverCost, paramsRecoverEnergy
        if tag == 11 then
            paramRecoverCost = recoverCost1
            paramsRecoverEnergy = 1
        elseif tag == 12 then
            paramRecoverCost = recoverCost2
            paramsRecoverEnergy = recoverEnergy
        end
        if paramRecoverCost and paramsRecoverEnergy then
            if paramRecoverCost > playerVoApi:getGems() then
                GemsNotEnoughDialog(nil, nil, paramRecoverCost - playerVoApi:getGems(), self.layerNum + 1, paramRecoverCost)
                do return end
            else
                rebelVoApi:buyRebelEnergy(paramsRecoverEnergy, function()
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vip_tequanlibao_goumai_success"), 30)
                        if type(buyCallback) == "function" then
                            eventDispatcher:dispatchEvent("refresh.flag.numbg")
                            buyCallback()
                        end
                        closeDialog()
                end)
            end
        end
    end
    local btnScale, btnFontSize = 0.8, 24
    local buyItem1 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickBuyBtn, 11, getlocal("worldRebel_buyEnergyBtn", {1}), btnFontSize / btnScale)
    local buyItem2 = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuyBtn, 12, getlocal("worldRebel_buyEnergyBtn", {recoverEnergy}), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(buyItem1)
    menuArr:addObject(buyItem2)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu)
    buyItem1:setScale(btnScale)
    buyItem2:setScale(btnScale)
    buyItem1:setPosition(ccp(120, 50))
    buyItem2:setPosition(ccp(530 - 120, 50))
    local costIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    costIcon:setPosition(ccp(80, 110))
    self.bgLayer:addChild(costIcon)
    local costLb = GetTTFLabel("-" .. recoverCost1, 23)
    if(recoverCost1 > playerVoApi:getGems())then
        costLb:setColor(G_ColorRed)
    end
    costLb:setPosition(ccp(120, 110))
    self.bgLayer:addChild(costLb)
    local costIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    costIcon:setPosition(ccp(530 - 120 - 40, 110))
    self.bgLayer:addChild(costIcon)
    local costLb = GetTTFLabel("-" .. recoverCost2, 23)
    if(recoverCost2 > playerVoApi:getGems())then
        costLb:setColor(G_ColorRed)
    end
    costLb:setPosition(ccp(530 - 120, 110))
    self.bgLayer:addChild(costLb)
    
    tickFunc = function()
        if energyCountDown and energyCountDown.setString then
            local recoverLeft = rebelVoApi:getEnergyRecoverTs() - base.serverTime
            if recoverLeft == 0 then
                if type(buyCallback) == "function" then
                    buyCallback()
                end
                closeDialog()
                if rebelVoApi:getRebelEnergy() >= rebelCfg.energyMax then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("worldRebel_energyFull"), 30)
                else
                    rebelVoApi:pr_showBuyEnergySmallDialog(self.layerNum, params)
                end
            else
                energyCountDown:setString(getlocal("worldRebel_buyEnergyConfirm1", {GetTimeStr(recoverLeft)}))
            end
        end
    end
    tickId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tickFunc, 1, false)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

------------------------------------【奖励结果展示界面】------------------------------------

function personalRebelSmallDialog:showRewardDialog(layerNum, params)
    local sd = personalRebelSmallDialog:new()
    sd:initRewardDialog(layerNum, params)
end

function personalRebelSmallDialog:initRewardDialog(layerNum, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    local eventType = params[1]--1：探索废墟，2：Boss宝箱，3：秒杀叛军，4：讨伐叛军失败，5：讨伐叛军胜利
    local rewardTb = params[2]
    local closeCallback = params[3]
    local closeBattleCallback = params[4]
    local titleStr, tipsStr
    if eventType == 1 then
        titleStr = getlocal("personalRebel_exploreRuinsText")
        tipsStr = getlocal("personalRebel_exploreRuinsEventText")
    elseif eventType == 2 then
        titleStr = getlocal("personalRebel_bossBoxText")
        tipsStr = getlocal("personalRebel_bossBoxEventText")
    elseif eventType == 3 then
        titleStr = getlocal("personalRebel_killRebelText")
        tipsStr = getlocal("personalRebel_killRebelEventText")
    elseif eventType == 4 or eventType == 5 then
        titleStr = getlocal("personalRebel_attackRebelText")
        if eventType == 4 then
            tipsStr = getlocal("personalRebel_attackRebelEventText2")
        elseif eventType == 5 then
            tipsStr = getlocal("personalRebel_attackRebelEventText1")
        end
    end
    self.bgSize = CCSizeMake(550, 550)
    local cellNum = SizeOfTable(rewardTb or {})
    local cellHeight, tvMaxDisToBottomOrTop = 100, 120
    local tipsLb = GetTTFLabelWrap(tipsStr, 20, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    local bgSizeHeight = 30 + tipsLb:getContentSize().height + 30 + 6 + cellNum * cellHeight
    if bgSizeHeight < self.bgSize.height then
        self.bgSize.height = bgSizeHeight
        tvMaxDisToBottomOrTop = 0
    end
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
    	if type(closeBattleCallback) == "function" then
    		closeBattleCallback()
    	end
    	self:close(closeCallback)
    end)
    touchDialogBg:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgLayer = G_getNewDialogBg2(self.bgSize, self.layerNum, nil, titleStr, 28, nil, "Helvetica-bold")
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(false)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    tipsLb:setAnchorPoint(ccp(0.5, 1))
    tipsLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 30)
    tipsLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipsLb)
    
    local rTvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    rTvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, tipsLb:getPositionY() - tipsLb:getContentSize().height - 30))
    rTvBg:setAnchorPoint(ccp(0.5, 1))
    rTvBg:setPosition(self.bgSize.width / 2, tipsLb:getPositionY() - tipsLb:getContentSize().height - 10)
    self.bgLayer:addChild(rTvBg)
    
    local tvSize = CCSizeMake(rTvBg:getContentSize().width - 6, rTvBg:getContentSize().height - 6)
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvSize.width, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW = tvSize.width
            local itemData = rewardTb[idx + 1]
            local iconSize = 90
            local icon, scale = G_getItemIcon(itemData, 100, false, self.layerNum, function()
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, itemData, nil, nil, nil, nil, true)
            end)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setPosition(10 + iconSize / 2, cellHeight / 2)
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            cell:addChild(icon)
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            nameBg:setContentSize(CCSizeMake(cellW - (icon:getPositionX() + iconSize / 2 + 25), nameBg:getContentSize().height))
            nameBg:setAnchorPoint(ccp(0, 1))
            nameBg:setPosition(icon:getPositionX() + iconSize / 2 + 10, icon:getPositionY() + iconSize / 2)
            cell:addChild(nameBg)
            local nameLb = GetTTFLabel(itemData.name, (G_isAsia() == false) and 16 or 22, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(15, nameBg:getContentSize().height / 2)
            nameLb:setColor(G_ColorYellowPro)
            nameBg:addChild(nameLb)
            local numLb = GetTTFLabel(getlocal("propInfoNum", {itemData.num}), 22)
            numLb:setAnchorPoint(ccp(0, 0.5))
            numLb:setPosition(nameBg:getPositionX() + 15, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2)
            cell:addChild(numLb)
            --[[
            local descStr = getlocal(itemData.desc)
            local descWidth = cellW - (nameBg:getPositionX() + 15 + 15)
            local descHeight = nameBg:getPositionY() - nameBg:getContentSize().height - 10
            local descLb = GetTTFLabelWrap(descStr, 18, CCSizeMake(descWidth, descHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(nameBg:getPositionX() + 15, nameBg:getPositionY() - nameBg:getContentSize().height)
            cell:addChild(descLb)
            --]]
            if idx + 1 < cellNum then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                lineSp:setContentSize(CCSizeMake(cellW - 20, 4))
                lineSp:setPosition(cellW / 2, 0)
                lineSp:setRotation(180)
                cell:addChild(lineSp)
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local rTv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    rTv:setPosition(ccp(3, 3))
    rTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    rTv:setMaxDisToBottomOrTop(tvMaxDisToBottomOrTop)
    rTvBg:addChild(rTv)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    -------- 点击屏幕继续 --------
    local clickLbPosy = - 80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = self.bgSize.width / 2 - maxWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + maxWidth / 2
    else
        arrowPosx1 = self.bgSize.width / 2 - realWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow( - 1, space))
    smallArrowSp4:runAction(G_actionArrow( - 1, space))
end

function personalRebelSmallDialog:dispose()
    if type(self.removeResFunc) == "function" then
        self.removeResFunc()
    end
    self = nil
end