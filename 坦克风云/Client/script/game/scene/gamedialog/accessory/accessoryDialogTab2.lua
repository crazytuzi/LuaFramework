accessoryDialogTab2 = {}

function accessoryDialogTab2:new(...)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.bgLayer = nil
    self.layerNum = nil
    self.parent = nil
    
    self.descLb = nil
    self.resetBtn = nil
    self.raidBtn = nil
    
    self.pageDialog = nil
    
    self.headBg = nil
    self.leftNumLb = nil
    self.tipBtn = nil
    
    return nc
end

function accessoryDialogTab2:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    self:doUserHandler()
    
    return self.bgLayer
end

function accessoryDialogTab2:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 60, self.bgLayer:getContentSize().height - 330), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 165))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function accessoryDialogTab2:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        local ecCfg = accessoryVoApi:getECCfg()
        return SizeOfTable(ecCfg)
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 60, 120)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth = self.bgLayer:getContentSize().width - 60
        local cellHeight = 120
        
        local cfg = accessoryVoApi:getEChallengeCfg()
        local ecDetailCfg = accessoryVoApi:getECCfg()
        local ecCfg = ecDetailCfg["s" .. (idx + 1)]
        local maxStar = cfg.starNum
        
        local ecVo = accessoryVoApi:getECVo()
        local star = 0
        if ecVo and ecVo.info and ecVo.info[idx + 1] then
            star = tonumber(ecVo.info[idx + 1]) or 0
        end
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd, fn, idx)
        end
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, cellClick)
        
        backSprie:setContentSize(CCSizeMake(cellWidth - 10, cellHeight - 2))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0, 0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        backSprie:setPosition(ccp(5, 0))
        cell:addChild(backSprie, 1)
        
        local pic = ecCfg.icon
        local tankIcon = CCSprite:createWithSpriteFrameName(pic)
        local scale = (100 / tankIcon:getContentSize().width)
        tankIcon:setScale(scale)
        tankIcon:setAnchorPoint(ccp(0.5, 0.5))
        tankIcon:setPosition(ccp(20 + tankIcon:getContentSize().width / 2 * scale, cellHeight / 2))
        cell:addChild(tankIcon, 1)
        
        local lockSp = CCSprite:createWithSpriteFrameName("LockIcon.png")
        lockSp:setAnchorPoint(CCPointMake(0.5, 0.5))
        lockSp:setPosition(getCenterPoint(tankIcon))
        -- lockSp:setScale(0.7)
        tankIcon:addChild(lockSp, 3)
        -- lockSp:setTag(30)
        if accessoryVoApi:isUnlock(idx + 1) == true then
            lockSp:setVisible(false)
        end
        
        local cName = GetTTFLabelWrap(getlocal(ecCfg.name), 24, CCSizeMake(cellWidth - 300, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
        cName:setColor(G_ColorGreen)
        cName:setAnchorPoint(ccp(0, 1))
        cName:setPosition(150, cellHeight - 20)
        cell:addChild(cName, 1)
        
        local starNum = star --星数
        local starSize = 36
        local spaceWidth = starSize + 2
        for i = 1, maxStar do
            local cStar
            local starScale = 1
            if i <= starNum then
                -- cStar=CCSprite:createWithSpriteFrameName("gameoverstar_gray.png")
                cStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
                starScale = starSize / cStar:getContentSize().width
            else
                cStar = CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
                -- cStar=CCSprite:createWithSpriteFrameName("starIconEmpty.png")
                starScale = starSize / cStar:getContentSize().width
            end
            cStar:setAnchorPoint(ccp(0.5, 0.5))
            cStar:setScale(starScale)
            
            cStar:setPosition(ccp(150 + starSize / 2 + spaceWidth * (i - 1), 15 + starSize / 2))
            cell:addChild(cStar, 1)
        end
        
        local iconSize = 70
        
        local function attackHandler(tag, object)
            PlayEffect(audioCfg.mouseClick)
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                if(accessoryVoApi:getGuideStep() > 0)then
                    accessoryVoApi:setGuideStep(-1)
                    accessoryGuideMgr:endNewGuid()
                end
                local canAttack = accessoryVoApi:canAttack(idx + 1)
                if canAttack ~= 0 then
                    if canAttack == 2 then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("accessory_bag_full"), nil, self.layerNum + 1)
                    elseif canAttack == 1 then
                        local function buyEnergy()
                            G_buyEnergy(self.layerNum + 1)
                        end
                        -- smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyEnergy, getlocal("dialog_title_prompt"), getlocal("energyis0"), nil, self.layerNum + 1)
                        smallDialog:showEnergySupplementDialog(self.layerNum+1)
                    end
                    do return end
                end
                
                --tag 关卡id
                require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
                local td = tankStoryDialog:new(nil, nil, nil, tag)
                local tbArr = {getlocal("fleetCard"), getlocal("dispatchCard"), getlocal("repair")}
                local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("goFighting"), true, 7)
                sceneGame:addChild(dialog, 7)
            end
        end
        local menuItemAttack = GetButtonItem("yh_IconAttackBtn.png", "yh_IconAttackBtn_Down.png", "yh_IconAttackBtn.png", attackHandler, idx + 1, nil, 0)
        -- self:iconFlicker(menuItemAttack)
        local scale1 = 1
        menuItemAttack:setScale(scale1)
        local menuAttack = CCMenu:createWithItem(menuItemAttack)
        menuAttack:setAnchorPoint(ccp(0.5, 0.5))
        menuAttack:setPosition(ccp(cellWidth - menuItemAttack:getContentSize().width / 2 * scale1 - 20, cellHeight / 2))
        menuAttack:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(menuAttack, 1)
        local canAttack = accessoryVoApi:canAttack(idx + 1)
        --是否能攻打关卡 0：可以，1：能量不足，2：仓库不足，3：关卡已经被击杀，4：关卡未解锁，5.没有数据id
        if canAttack > 2 then
            menuItemAttack:setEnabled(false)
            if(canAttack == 3)then
                if(accessoryVoApi:getGuideStep() > 0)then
                    local function onShowPowerChange()
                        accessoryVoApi:setGuideStep(-1)
                        accessoryGuideMgr:endNewGuid()
                    end
                    local callFunc = CCCallFunc:create(onShowPowerChange)
                    local delay = CCDelayTime:create(2)
                    local acArr = CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq = CCSequence:create(acArr)
                    sceneGame:runAction(seq)
                end
            end
            --    elseif canAttack==2 then
            --        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("accessory_bag_full"),nil,self.layerNum+1)
            -- elseif canAttack==1 then
            -- local function buyEnergy()
            --            G_buyEnergy(self.layerNum+1)
            --        end
            --        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,self.layerNum+1)
        end
        
        local function touch(tag, object)
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if newGuidMgr:isNewGuiding() == true then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                local index = tag - 100
                local cfg = accessoryVoApi:getEChallengeCfg()
                local ecDetailCfg = accessoryVoApi:getECCfg()
                local ecCfg = ecDetailCfg["s"..index]
                
                local ecVo = accessoryVoApi:getECVo()
                local star = 0
                if ecVo and ecVo.info and ecVo.info[idx + 1] then
                    star = tonumber(ecVo.info[idx + 1]) or 0
                end
                
                local tipStrTab = {" "}
                local colorTab = {G_ColorWhite}
                
                local tipStrData = accessoryVoApi:eChallengeTipStr(index)
                if tipStrData and SizeOfTable(tipStrData) > 0 then
                    for k = 1, SizeOfTable(tipStrData) do
                        if k == 3 then
                            local tipStr = ""
                            for i, j in pairs(tipStrData[k]) do
                                if j and accessoryCfg.propCfg[j] and (not (j == "p12" and base.redAccessoryPromote ~= 1)) then
                                    local pCfg = accessoryCfg.propCfg[j]
                                    if tipStr == "" then
                                        tipStr = tipStr..getlocal(pCfg.name)
                                    else
                                        tipStr = tipStr..","..getlocal(pCfg.name)
                                    end
                                end
                            end
                            if tipStr ~= "" then
                                -- table.insert(tipStrTab,getlocal("elite_challenge_smelt_prop",{tipStr}))
                                table.insert(tipStrTab, tipStr)
                                table.insert(colorTab, G_ColorWhite)
                            end
                        else
                            for i = SizeOfTable(tipStrData[k]), 1, -1 do
                                local j = tipStrData[k][i]
                                if j and SizeOfTable(j) > 0 then
                                    local quality = tonumber(i) or 0
                                    local tankTypeTab = j or {}
                                    local tankStr = ""
                                    for m, n in pairs(tankTypeTab) do
                                        if tonumber(n) == 1 then
                                            tankStr = tankStr..getlocal("tanke") .. ","
                                        elseif tonumber(n) == 2 then
                                            tankStr = tankStr..getlocal("jianjiche") .. ","
                                        elseif tonumber(n) == 3 then
                                            tankStr = tankStr..getlocal("zixinghuopao") .. ","
                                        elseif tonumber(n) == 4 then
                                            tankStr = tankStr..getlocal("huojianche") .. ","
                                        end
                                    end
                                    if tankStr and tankStr ~= "" then
                                        tankStr = string.sub(tankStr, 1, -2)
                                        local color = accessoryVoApi:getColorByQuality(quality)
                                        local tipStr = ""
                                        if k == 2 then
                                            tipStr = getlocal("elite_challenge_accessory_"..quality, {tankStr})
                                        elseif k == 1 then
                                            tipStr = getlocal("elite_challenge_fragment_"..quality, {tankStr})
                                        end
                                        if tipStr and tipStr ~= "" then
                                            table.insert(tipStrTab, tipStr)
                                            table.insert(colorTab, color)
                                        end
                                    end
                                end
                                
                            end
                        end
                        
                    end
                    
                end
                
                table.insert(tipStrTab, getlocal("elite_challenge_dorp"))
                table.insert(colorTab, G_ColorWhite)
                
                table.insert(tipStrTab, " ")
                table.insert(colorTab, G_ColorWhite)
                
                local isKill = accessoryVoApi:isKill(index)
                if isKill == true then
                    table.insert(tipStrTab, getlocal("elite_challenge_raid_3"))
                    table.insert(colorTab, G_ColorWhite)
                else
                    if star == 3 then
                        table.insert(tipStrTab, getlocal("elite_challenge_raid_2"))
                        table.insert(colorTab, G_ColorWhite)
                    else
                        table.insert(tipStrTab, getlocal("elite_challenge_raid_1"))
                        table.insert(colorTab, G_ColorRed)
                    end
                end
                table.insert(tipStrTab, " ")
                table.insert(colorTab, G_ColorWhite)
                
                -- if accessoryVoApi:isUnlock(index)==false then
                if ecCfg.unlockLv and playerVoApi:getPlayerLevel() < ecCfg.unlockLv then
                    table.insert(tipStrTab, getlocal("elite_challenge_unlock_level", {ecCfg.unlockLv}))
                    table.insert(colorTab, G_ColorRed)
                end
                
                table.insert(tipStrTab, " ")
                table.insert(colorTab, G_ColorWhite)
                
                local sd = smallDialog:new()
                local dialogLayer = sd:init("TankInforPanel.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tipStrTab, 25, colorTab)
                sceneGame:addChild(dialogLayer, self.layerNum + 1)
                dialogLayer:setPosition(ccp(0, 0))
            end
        end
        local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch, idx + 101, nil, 0)
        local scale2 = 1
        menuItemDesc:setScale(scale2)
        local menuDesc = CCMenu:createWithItem(menuItemDesc)
        menuDesc:setAnchorPoint(ccp(0.5, 0.5))
        menuDesc:setPosition(ccp(cellWidth - menuItemAttack:getContentSize().width * scale1 - menuItemDesc:getContentSize().width / 2 * scale2 - 30, cellHeight / 2))
        menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(menuDesc, 1)
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    elseif fn == "ccScrollEnable" then
        if newGuidMgr:isNewGuiding() == true then
            return 0
        else
            return 1
        end
    end
end

function accessoryDialogTab2:tick()
    
end

function accessoryDialogTab2:doUserHandler()
    local cfg = accessoryVoApi:getEChallengeCfg()
    local leftResetNum = accessoryVoApi:getLeftResetNum()
    
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function touch(hd, fn, idx)
        
    end
    if self.headBg == nil then
        self.headBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, touch)
        self.headBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 50, 70))
        self.headBg:ignoreAnchorPointForPosition(false)
        self.headBg:setAnchorPoint(ccp(0, 1))
        self.headBg:setIsSallow(false)
        self.headBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
        self.headBg:setPosition(ccp(25, self.bgLayer:getContentSize().height - 85))
        self.bgLayer:addChild(self.headBg)
    end
    
    local leftNum = accessoryVoApi:getLeftECNum()
    if self.leftNumLb == nil then
        self.leftNumLb = GetTTFLabelWrap(getlocal("elite_challenge_attack_left", {leftNum}), 25, CCSizeMake(self.bgLayer:getContentSize().width - 140, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        self.leftNumLb:setAnchorPoint(ccp(0, 0.5))
        self.leftNumLb:setPosition(10, self.headBg:getContentSize().height / 2)
        self.headBg:addChild(self.leftNumLb, 1)
    else
        self.leftNumLb:setString(getlocal("elite_challenge_attack_left", {leftNum}))
    end
    
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
        local dialogLayer = sd:init("TankInforPanel.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, {" ", getlocal("elite_challenge_desc_6"), " ", getlocal("elite_challenge_desc_5"), " ", getlocal("elite_challenge_desc_4"), " ", getlocal("elite_challenge_desc_3"), " ", getlocal("elite_challenge_desc_2"), " ", getlocal("elite_challenge_desc_1"), " "}, 25, {nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil, G_ColorYellow, nil})
        sceneGame:addChild(dialogLayer, self.layerNum + 1)
        dialogLayer:setPosition(ccp(0, 0))
    end
    if self.tipBtn == nil then
        local tipItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", tipTouch, 11, nil, nil)
        local spScale = 0.8
        tipItem:setScale(spScale)
        self.tipBtn = CCMenu:createWithItem(tipItem)
        self.tipBtn:setPosition(ccp(self.headBg:getContentSize().width - tipItem:getContentSize().width / 2 * spScale - 10, self.headBg:getContentSize().height / 2))
        self.tipBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.headBg:addChild(self.tipBtn, 1)
    end
    
    if self.descLb == nil then
        self.descLb = GetTTFLabelWrap(getlocal("elite_challenge_reset_num", {leftResetNum}), 22, CCSizeMake(self.bgLayer:getContentSize().width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        self.descLb:setAnchorPoint(ccp(0.5, 0.5))
        self.descLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 120 + self.descLb:getContentSize().height / 2))
        self.bgLayer:addChild(self.descLb)
        -- self.descLb:setColor(G_ColorYellowPro)
    else
        self.descLb:setString(getlocal("elite_challenge_reset_num", {leftResetNum}))
    end
    
    local function resetHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local resetGemsTab = cfg.resetGems
        local usedResetNum = accessoryVoApi:getUsedResetNum()
        if usedResetNum >= accessoryVoApi:getResetMaxNum() then
            do return end
        end
        local resetGems = resetGemsTab[usedResetNum + 1]
        if(activityVoApi:checkActivityEffective("accessoryFight"))then
            resetGems = resetGems * activityCfg.accessoryFight.serverreward.reducePrice
        end
        -- local resetGems=0--测试
        local needGem = resetGems - playerVoApi:getGems()
        if needGem > 0 then
            GemsNotEnoughDialog(nil, nil, needGem, self.layerNum + 1, resetGems)
        else
            local remainNum = accessoryVoApi:getLeftResetNum()
            local function resetConfirm()
                local function ecResetCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData and sData.ts then
                            playerVoApi:setValue("gems", playerVoApi:getGems() - resetGems)
                            
                            accessoryVoApi:resetData(sData.ts)
                            self:refresh()
                            
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_reset_success"), 30)
                        end
                    end
                end
                socketHelper:echallengeReset(ecResetCallback)
            end
            if remainNum > 0 then
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), resetConfirm, getlocal("dialog_title_prompt"), getlocal("elite_challenge_reset_remind", {resetGems}), nil, self.layerNum + 1)
            end
        end
        
    end
    if self.resetBtn == nil then
        self.resetBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", resetHandler, 1, getlocal("elite_challenge_reset_btn"), 24, 101)
        local btnLb = self.resetBtn:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb, "CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local menuReset = CCMenu:createWithItem(self.resetBtn)
        menuReset:setAnchorPoint(ccp(0, 0))
        menuReset:setPosition(ccp(self.bgLayer:getContentSize().width / 3 - 10, 30 + self.resetBtn:getContentSize().height / 2))
        menuReset:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(menuReset, 1)
    end
    if leftResetNum > 0 then
        self.resetBtn:setEnabled(true)
    else
        self.resetBtn:setEnabled(false)
    end
    
    local function raidHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local resetNum = accessoryVoApi:getUsedResetNum() --今日重置次数
        if resetNum == 0 then --今日重置次数为0时扫荡需要消耗能量
            local flag, needVipLevel = accessoryVoApi:canRaid()
            if flag == 1 then --没有可扫荡的关卡
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("elite_challenge_vip_raid", {needVipLevel}), nil, self.layerNum + 1)
                do return end
            elseif flag == 2 then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage6008"), nil, self.layerNum + 1)
                do return end
            end
            local energy = playerVoApi:getEnergy()
            if energy == 0 then --没有能量
                local function buyEnergy()
                    G_buyEnergy(self.layerNum + 1)
                end
                -- smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buyEnergy, getlocal("dialog_title_prompt"), getlocal("energyis0"), nil, self.layerNum + 1)
                smallDialog:showEnergySupplementDialog(self.layerNum+1)
                do return end
            end
            local function raid(eid, callBack)
                self:supplyRaid(eid, callBack)
            end
            accessoryVoApi:showRaidSelectDialog(self.layerNum + 1, raid)
        else --不消耗能量时直接扫荡所有关卡（原先的逻辑）
            self:supplyRaid()
        end
    end
    if self.raidBtn == nil then
        self.raidBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", raidHandler, 2, getlocal("elite_challenge_raid_btn"), 24, 101)
        local btnLb = self.raidBtn:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb, "CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local menuReset = CCMenu:createWithItem(self.raidBtn)
        menuReset:setAnchorPoint(ccp(0, 0))
        menuReset:setPosition(ccp(self.bgLayer:getContentSize().width / 3 * 2 + 10, 30 + self.raidBtn:getContentSize().height / 2))
        menuReset:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(menuReset, 1)
    end
    if accessoryVoApi:canRaid() == 5 then
        self.raidBtn:setEnabled(false)
    else
        self.raidBtn:setEnabled(true)
    end
end

--补给线扫荡处理
function accessoryDialogTab2:supplyRaid(eid, raidSuccessCallback)
    local function raidCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.echallengeraid and sData.data.echallengeraid.report then
                local raidReward = sData.data.echallengeraid.report
                if raidReward and SizeOfTable(raidReward) == 1 then
                    for k, v in pairs(raidReward) do
                        if tonumber(v) and tonumber(v) < 0 then
                            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("accessory_bag_full"), nil, self.layerNum + 1)
                            do return end
                        end
                    end
                end
                if sData.data.echallengeraid.rAcrd then --活动掉落处理。周年狂欢2019活动掉落数字卡片
                    for k,v in pairs(sData.data.echallengeraid.rAcrd) do
                        if raidReward[k] then
                            if raidReward[k].ac == nil then
                                raidReward[k].ac = {}
                            end
                            for ack,acv in pairs(v.ac) do
                                raidReward[k].ac[ack] = acv
                            end  
                        else
                            raidReward[k] = v.ac
                        end
                    end
                end

                local isFull = false
                local eIsEnough = true
                local rewardTab = {}
                rewardTab, eIsEnough, isFull = accessoryVoApi:raidUpdate(raidReward)
                
                --添加配件和碎片、原材料
                if sData.data and sData.data.echallengeraid and sData.data.echallengeraid.reward then
                    local accessory = sData.data.echallengeraid.reward
                    accessoryVoApi:addNewData(accessory)
                end
                
                self:refresh()
                
                local cfg = accessoryVoApi:getEChallengeCfg()
                local ecCfg = accessoryVoApi:getECCfg()
                
                local title = getlocal("elite_challenge_raid_btn")
                local content = {}
                local lbColor = {}
                local showStrTb = {}
                if rewardTab and SizeOfTable(rewardTab) > 0 then
                    for k, v in pairs(rewardTab) do
                        local awardTab = v.awardTab
                        local id = v.id
                        local eCfg = ecCfg["s"..id]
                        local name = getlocal(eCfg.name)
                        for kk, vv in pairs(awardTab) do
                            if vv.type == "e" then
                                vv.index = 1000 + kk
                            elseif vv.type == "u" then
                                vv.index = 0 + kk
                            else
                                vv.index = 100 + kk
                            end
                        end
                        local function sortFunc(a, b)
                            return a.index < b.index
                        end
                        table.sort(awardTab, sortFunc)
                        table.insert(content, {award = awardTab})
                        
                        local showStr = getlocal("accessory_rout_des", {name})
                        table.insert(showStrTb, showStr)
                    end
                end
                
                local endRaidStrTb
                if isFull == true then
                    endRaidStr = getlocal("accessory_bag_full")
                    endRaidStrTb = {endRaidStr, G_ColorRed}
                elseif eIsEnough == false then
                    endRaidStr = getlocal("elite_challenge_raid_energy")
                    endRaidStrTb = {endRaidStr, G_ColorRed}
                else
                    endRaidStr = getlocal("elite_challenge_raid_complete")
                    endRaidStrTb = {endRaidStr, G_ColorGreen}
                end
                
                local isOneByOne = true
                local function raidHandler()
                end
                accessoryVoApi:showRaidsRewardSmallDialog("TankInforPanel.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), getlocal("raids_raids_result"), content, nil, nil, self.layerNum + 1, nil, isOneByOne, nil, showStrTb, endRaidStrTb)
                
                if raidSuccessCallback then
                    raidSuccessCallback()
                end
            end
        end
    end
    --是否能扫荡关卡 0：可以，1：vip等级不够，2：没有剩余的3星关卡，3：仓库不足，4：能量不足
    local canRaid, needVipLevel = accessoryVoApi:canRaid()
    if canRaid == 0 then
        socketHelper:echallengeRaid(raidCallback, eid)
    elseif canRaid == 1 then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("elite_challenge_vip_raid", {needVipLevel}), nil, self.layerNum + 1)
    elseif canRaid == 2 then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("backstage6008"), nil, self.layerNum + 1)
    elseif canRaid == 3 then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("accessory_bag_full"), nil, self.layerNum + 1)
    elseif canRaid == 4 then
        local function buyEnergy()
            G_buyEnergy(self.layerNum + 1)
        end
        smallDialog:showEnergySupplementDialog(self.layerNum + 1)
    end
end

function accessoryDialogTab2:refresh()
    if self then
        if self.tv then
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
        self:doUserHandler()
    end
end

function accessoryDialogTab2:dispose()
    self.headBg = nil
    self.leftNumLb = nil
    self.tipBtn = nil
    self.descLb = nil
    self.resetBtn = nil
    self.raidBtn = nil
    self.layerNum = nil
    self.bgLayer = nil
end
