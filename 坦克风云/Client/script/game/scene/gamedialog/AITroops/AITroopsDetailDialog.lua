--AI部队详情页面
AITroopsDetailDialog = commonDialog:new()

function AITroopsDetailDialog:new(troopsVo)
    local nc = {
        troopsVo = troopsVo,
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function AITroopsDetailDialog:initTableView()
    local function addRes()
        spriteController:addPlist("public/aiTroopsImage/aitroops_effect1.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_effect1.png")
    end
    G_addResource8888(addRes)
    self:setTopLineShow()
    
    self.troopsVo = AITroopsVoApi:getTroopsById(self.troopsVo.id)
    self.troopsMaxLv = AITroopsVoApi:getTroopsMaxLvById(self.troopsVo.id)
    
    self.aiTroopCfg = AITroopsVoApi:getModelCfg()
    local itemBgSize = CCSizeMake(616, 140)
    local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function () end)
    itemBg:setAnchorPoint(ccp(0.5, 1))
    itemBg:setContentSize(itemBgSize)
    itemBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 90)
    self.bgLayer:addChild(itemBg)
    self.itemBg = itemBg
    
    --部队图标
    local iconSize = 100
    local troopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(self.troopsVo.id, nil, self.troopsVo.grade)
    troopsIcon:setScale(iconSize / troopsIcon:getContentSize().width)
    troopsIcon:setPosition(10 + iconSize * 0.5, itemBgSize.height * 0.5)
    itemBg:addChild(troopsIcon)
    self.troopsIcon = troopsIcon
    
    --兑换碎片的按钮
    local function exchange()
        local fragmentId = AITroopsVoApi:getFragmentIdByTroopsId(self.troopsVo.id)
        local fragmentNum = AITroopsVoApi:getTroopsFragment(self.troopsVo.id)
        if tonumber(fragmentNum) <= 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_no_fragment"), 28)
            do return end
        end
        local propId, num = AITroopsVoApi:getFragmentDeCompose(fragmentId)
        if propId == nil then
            do return end
        end
        local propNum = AITroopsVoApi:getPropNumById(propId)
        local fromItem = {at = {[fragmentId] = fragmentNum}}
        local targetItem = {at = {[propId] = propNum}}
        fromItem = FormatItem(fromItem)[1]
        targetItem = FormatItem(targetItem)[1]
        AITroopsVoApi:showFragmentExchangeDialog(1, fromItem, targetItem, num, nil, self.layerNum + 1)
    end
    local itemSize = 40
    local exchangeItem, exchangeMenu = G_createBotton(itemBg, ccp(0, 0), {}, "yh_hero_switch1.png", "yh_hero_switch2.png", "yh_hero_switch2.png", exchange, 1, -(self.layerNum - 1) * 20 - 4, 3)
    exchangeItem:setScale(itemSize / exchangeItem:getContentSize().width)
    exchangeItem:setPosition(troopsIcon:getPositionX() + iconSize / 2 - itemSize / 2, troopsIcon:getPositionY() + iconSize / 2 - itemSize / 2)
    
    -- --碎片数
    -- local fragmentLb = GetTTFLabel("", 20)
    -- fragmentLb:setAnchorPoint(ccp(0.5, 0))
    -- fragmentLb:setPosition(troopsIcon:getPositionX(), troopsIcon:getPositionY() - iconSize * 0.5 + 4)
    -- itemBg:addChild(fragmentLb, 3)
    -- self.fragmentLb = fragmentLb
    
    --部队名称
    local nameFontSize, smallFontSize = 22, 20
    local nameStr, color = AITroopsVoApi:getAITroopsNameStr(self.troopsVo.id)
    local nameLb = GetTTFLabel(nameStr, nameFontSize, true)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setColor(color)
    nameLb:setPosition(troopsIcon:getPositionX() + iconSize * 0.5 + 10, troopsIcon:getPositionY() + iconSize * 0.5)
    itemBg:addChild(nameLb)
    self.nameLb = nameLb
    --部队等级
    local levelLb = GetTTFLabel(getlocal("fightLevel", {self.troopsVo.lv}), nameFontSize, true)
    levelLb:setAnchorPoint(ccp(0, 1))
    levelLb:setPosition(nameLb:getPositionX() + nameLb:getContentSize().width + 15, nameLb:getPositionY())
    itemBg:addChild(levelLb)
    self.levelLb = levelLb
    --部队强度
    local strength = self.troopsVo:getTroopsStrength()
    local strengthLb = GetTTFLabel(getlocal("emblem_infoStrong", {strength}), smallFontSize)
    strengthLb:setAnchorPoint(ccp(0, 1))
    strengthLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
    itemBg:addChild(strengthLb)
    self.strengthLb = strengthLb
    --部队当前等级经验进度
    self.progressWidth, self.progressHeight = 250, 30
    local pos = ccp(nameLb:getPositionX() + self.progressWidth / 2, strengthLb:getPositionY() - strengthLb:getContentSize().height - self.progressHeight * 0.5 - 10)
    local expProgressSp = AddProgramTimer(itemBg, pos, 9, 12, "", "TeamTravelBarBg.png", "TeamTravelBar.png", 11, nil, nil, nil, nil, nameFontSize)
    local expProgressBg = tolua.cast(itemBg:getChildByTag(11), "CCSprite")
    local scaleX = self.progressWidth / expProgressSp:getContentSize().width
    local scaleY = self.progressHeight / expProgressSp:getContentSize().height
    expProgressSp:setAnchorPoint(ccp(0.5, 0.5))
    expProgressBg:setAnchorPoint(ccp(0.5, 0.5))
    expProgressSp:setScaleX(scaleX)
    expProgressSp:setScaleY(scaleY)
    expProgressBg:setScaleX(scaleX)
    expProgressBg:setScaleY(scaleY)
    self.expProgressSp = expProgressSp
    
    local expProgressLb = GetTTFLabelWrap("", nameFontSize, CCSize(self.progressWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    expProgressLb:setPosition(expProgressSp:getPositionX(), expProgressSp:getPositionY())
    itemBg:addChild(expProgressLb, 4)
    self.expProgressLb = expProgressLb
    
    self:initButton()
    self:refreshTroops()
    
    local function touchTip()
        local aiTroopsCfg = AITroopsVoApi:getModelCfg()
        local tabStr, textFormatTb = {}, {}
        local arg = {
            [1] = {aiTroopsCfg.expDoubleRate[2], aiTroopsCfg.expDoubleRate[3]},
        }
        local formatTb = {
            [1] = {richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}, richFlag = true},
        }
        for k = 1, 3 do
            local str = getlocal("aitroops_troops_rule"..k, arg[k] or {})
            table.insert(tabStr, str)
            table.insert(textFormatTb, formatTb[k] or {})
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    G_addMenuInfo(itemBg, self.layerNum, ccp(itemBg:getContentSize().width - 60, itemBg:getContentSize().height / 2), {}, nil, nil, 28, touchTip, true)
    
    self.skillNum = #self.troopsVo:getTroopsSkillList()
    
    self.tvWidth, self.tvHeight = 616, G_VisibleSizeHeight - 90 - itemBgSize.height - 150
    self.skillIconSize, self.skillNameFontSize, self.skillDescFontSize, self.expWidth, self.expHeight, self.descFontWidth = 80, 22, 20, 250, 30, self.tvWidth - 200
    self.cellHeightTb = {}
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth, self.tvHeight + 4))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 90 - itemBgSize.height - 10)
    self.bgLayer:addChild(tvBg)
    
    if AITroopsVoApi:getLimitTroops(self.troopsVo.id) then
        local str = AITroopsVoApi:getLimitDes(self.troopsVo.id,nil)
        local limitDes = GetTTFLabelWrap(str,20,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        limitDes:setAnchorPoint(ccp(0,1))
        limitDes:setPosition(10, self.tvHeight-10)
        tvBg:addChild(limitDes)
        self.tvHeight=self.tvHeight-limitDes:getContentSize().height-50

        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake((self.tvWidth - 9), 4))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5, 0))
        lineSp:setPosition(self.tvWidth / 2,self.tvHeight+10)
        tvBg:addChild(lineSp)
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((G_VisibleSizeWidth - self.tvWidth) / 2, tvBg:getPositionY() - tvBg:getContentSize().height + 2)
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv)
    
    local function refresh(event, data)
        if data == nil then
            do return end
        end
        if data.rtype == 1 then
            self:refreshTroops()
        elseif data.rtype == 2 then
            self:refreshSkills()
        else
            self:refreshTroops()
            self:refreshSkills()
        end
    end
    self.refreshListener = refresh
    eventDispatcher:addEventListener("aitroops.detail.refresh", refresh)

    local function overTodayRefresh(event, data)
        --跨天刷新AI部队升级消耗和按钮状态
        self:refreshTroops()
        self:refreshSkills()
        self:refreshButton()
    end
    self.overTodayListener = overTodayRefresh
    eventDispatcher:addEventListener("aitroops.over.today", overTodayRefresh)
end

function AITroopsDetailDialog:initButton()
    local btnScale, btnPosY, priority, offsetX = 0.8, 80, -(self.layerNum - 1) * 20 - 4, 180
    --部队进阶
    local function advanced()
        local battleFlag = AITroopsFleetVoApi:getIsBattled(self.troopsVo.id)
        if battleFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_used_tip"), 28)
            do return end
        end
        local flag, rvalue = AITroopsVoApi:isAITroopsCanAdvance(self.troopsVo)
        if flag ~= 1 then
            if flag == 2 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_troop_advance_tip1"), 28)
            elseif flag == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_troop_advance_tip3", {rvalue}), 28)
            elseif flag == 4 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_troop_advance_tip2"), 28)
            end
            do return end
        end
        local function realAdvanced()
            local function handler()
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("equip_upgrade_success"), 28)
                self:refreshTroops(true)
                self:refreshSkills()
                self:refreshButton()
            end
            AITroopsVoApi:AITroopsAdvanced(self.troopsVo.id, handler)
        end
        G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("aitroops_troop_advance_confirm", {rvalue}), false, realAdvanced)
    end
    self.advancedItem, self.advancedMenu = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 - offsetX * 0.6, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", advanced, btnScale, priority)

    local iconSize = 60
    local troopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(self.troopsVo.id, nil, self.troopsVo.grade,true,nil,nil,nil,true)
    troopsIcon:setScale(iconSize / troopsIcon:getContentSize().width)
    troopsIcon:setPosition(iconSize * 0.5 + 50, btnPosY)
    self.bgLayer:addChild(troopsIcon)

    --碎片数
    local fragmentLb = GetTTFLabel("", 20)
    fragmentLb:setAnchorPoint(ccp(0, 1))
    fragmentLb:setPosition(troopsIcon:getPositionX() - iconSize / 2, troopsIcon:getPositionY() - iconSize * 0.5 - 10)
    self.bgLayer:addChild(fragmentLb, 3)
    self.fragmentLb = fragmentLb

    --部队升级（其实是给部队加经验）
    local costPropId = self.aiTroopCfg.expCostId
    local cost = AITroopsVoApi:getTroopsUpgradeCost()
    local num = AITroopsVoApi:getPropNumById(costPropId)
    local upgradeProp = {at = {[costPropId] = num}}
    local item = FormatItem(upgradeProp)[1]
    local function upgrade()
        local battleFlag = AITroopsFleetVoApi:getIsBattled(self.troopsVo.id)
        if battleFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_used_tip"), 28)
            do return end
        end
        local flag, cost = AITroopsVoApi:isAITroopsCanUpgrade(self.troopsVo)
        if flag ~= 1 then
            if flag == 2 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_troop_reachMaxLv"), 28)
            elseif flag == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_troop_upgrade_tip1"), 28)
            end
            do return end
        end
        local popKey = "aitroops_upgrade_tip"
        local function realUpgrade()
            local function realRefresh()
                self:refreshTroops()
                self:refreshButton()
                local refrehSkillFlag = false
                for k = 1, self.skillNum do
                    local skill = self.troopsVo:getSkillByPos(k)
                    local flag = AITroopsVoApi:checkSkillUpgrade(skill, self.troopsVo)
                    if flag == 1 then
                        refrehSkillFlag = true
                        do break end
                    end
                end
                if refrehSkillFlag == true then
                    self:refreshSkills()
                end
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_upgrade_success"), 28)
            end
            self:removeUpgradeEffect(realRefresh)
            local function handler(arg)
                local expRate = 1
                if arg and arg.expRate then
                    expRate = arg.expRate
                end
                self:playUpgradeEffect(expRate, realRefresh)
            end
            AITroopsVoApi:AITroopsUpgrade(self.troopsVo.id, handler)
        end
        --保存页面弹出时间
        local function secondTipFunc(sbFlag)
            local sValue = base.serverTime .. "_" .. sbFlag
            G_changePopFlag(popKey, sValue)
        end
        if G_isPopBoard(popKey) then
            G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("aitroops_troop_upgrade_tip2", {cost, item.name}), true, realUpgrade, secondTipFunc)
        else
            realUpgrade()
        end
    end
    self.upgradeItem, self.upgradeMenu = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2 + offsetX, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", upgrade, btnScale, priority)
    self:refreshButton()
    
    local iconSize = 60
    local costSp = G_getItemIcon(item, 100)
    costSp:setScale(iconSize / costSp:getContentSize().width)
    costSp:setPosition(G_VisibleSizeWidth / 2 + iconSize * 0.5 + 20, btnPosY)
    self.bgLayer:addChild(costSp)
    local numLb = GetTTFLabel(getlocal("propOwned")..FormatNumber(num), 20)
    numLb:setAnchorPoint(ccp(0, 1))
    numLb:setPosition(costSp:getPositionX() - iconSize / 2, costSp:getPositionY() - iconSize * 0.5 - 10)
    self.bgLayer:addChild(numLb)
    self.numLb = numLb
end

--刷新部队属性
function AITroopsDetailDialog:refreshTroops(isRefreshIconEffect)
    self.troopsVo = AITroopsVoApi:getTroopsById(self.troopsVo.id)
    local nextExp = AITroopsVoApi:getTroopsUpgradeExpById(self.troopsVo.id)
    self.lastLv, self.lastExp, self.lastNextExp = self.troopsVo.lv, self.troopsVo.exp, nextExp
    if self.fragmentLb then
        local maxGrade = SizeOfTable(self.aiTroopCfg.needTroopsLv)
        if AITroopsVoApi:isHasSkill3(self.troopsVo.id) == false then
            maxGrade = maxGrade - 1
        end
        local grade = self.troopsVo.grade + 1
        grade = grade >= maxGrade and maxGrade or grade
        local fragment = AITroopsVoApi:getTroopsFragment(self.troopsVo.id)
        local cost = AITroopsVoApi:getTroopsAdvancedCost(self.troopsVo.id, grade - 1)
        
        self.fragmentLb:setString(fragment.."/"..cost.num)
        -- local useMaxGrade = AITroopsVoApi:isHasSkill3(self.troopsVo.id) == false and maxGrade + 1 or maxGrade
        -- print("useMaxGrade----grade----->>>>",useMaxGrade,grade)
        local useGrade = self.troopsVo.grade or 1
        if useGrade >= maxGrade then
            local fragmentOwn = AITroopsVoApi:getTroopsFragment(self.troopsVo.id) or 0
            self.fragmentLb:setString(getlocal("propOwned") .. FormatNumber(fragmentOwn))
        end
    end
    if self.nameLb and self.levelLb then
        local nameStr = AITroopsVoApi:getAITroopsNameStr(self.troopsVo.id)
        self.nameLb:setString(nameStr)
        self.levelLb:setString(getlocal("fightLevel", {self.troopsVo.lv}))
        self.levelLb:setPositionX(self.nameLb:getPositionX() + self.nameLb:getContentSize().width + 15)
    end
    if self.strengthLb then
        local strength = self.troopsVo:getTroopsStrength()
        self.strengthLb:setString(getlocal("emblem_infoStrong", {strength}))
    end
    if self.expProgressSp and self.expProgressLb then
        if self.troopsVo.lv >= self.troopsMaxLv then
            self.expProgressSp:setPercentage(100)
            self.expProgressLb:setString(getlocal("alliance_lvmax"))
        else
            local per = math.floor(self.troopsVo.exp / nextExp * 100)
            self.expProgressSp:setPercentage(per)
            self.expProgressLb:setString(self.troopsVo.exp.."/"..nextExp)
        end
    end
    if self.numLb then --刷新道具数量
        local costPropId = self.aiTroopCfg.expCostId
        local num = AITroopsVoApi:getPropNumById(costPropId)
        local cost = AITroopsVoApi:getTroopsUpgradeCost()
        self.numLb:setString(getlocal("propOwned")..FormatNumber(num))
        if cost > num then
            self.numLb:setColor(G_ColorRed)
        else
            self.numLb:setColor(G_ColorWhite)
        end
    end
    if isRefreshIconEffect == true and self.troopsIcon then
        local acfg = self.aiTroopCfg.aitroopType[self.troopsVo.id]
        AITroopsVoApi:setAITroopsIconEffect(self.troopsIcon:getChildByTag(100), AITroopsVoApi:getAITroopsPic(self.troopsVo.id), 1, acfg.quality, self.troopsVo.grade)
    end
end

function AITroopsDetailDialog:refreshButton()
    if self.upgradeItem == nil or self.advancedItem == nil then
        do return end
    end
    local fontWidth, fontSize = 150, 22
    local cost = AITroopsVoApi:getTroopsUpgradeCost()
    if self.upgradeLb then
        self.upgradeLb:removeFromParentAndCleanup(true)
        self.upgradeLb = nil
    end
    if self.advancedLb then
        self.advancedLb:removeFromParentAndCleanup(true)
        self.advancedLb = nil
    end
    local upgradeLb, upgradeLbHeight = G_getRichTextLabel(getlocal("aitroops_skillupgrade_btnStr", {cost}), {nil, G_ColorYellowPro, nil}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    upgradeLb:setAnchorPoint(ccp(0.5,1))
    upgradeLb:setPosition(self.upgradeItem:getContentSize().width / 2, self.upgradeItem:getContentSize().height / 2 + upgradeLbHeight / 2 + 3)
    upgradeLb:setScale(1 / self.upgradeItem:getScale())
    self.upgradeItem:addChild(upgradeLb)
    self.upgradeLb = upgradeLb
    
    local btnStr = ""
    local maxGrade = SizeOfTable(self.aiTroopCfg.needTroopsLv)
    if AITroopsVoApi:isHasSkill3(self.troopsVo.id) == false then --没有第三个技能则只能进阶到2阶
        maxGrade = maxGrade - 1
    end
    local grade = self.troopsVo.grade or 1
    if grade >= maxGrade then
        btnStr = getlocal("aitroops_grade_max")
        self.advancedItem:setEnabled(false)
        if self.fragmentLb then
            local fragmentOwn = AITroopsVoApi:getTroopsFragment(self.troopsVo.id) or 0
            self.fragmentLb:setString(getlocal("propOwned") .. FormatNumber(fragmentOwn))
        end
    else
        btnStr = getlocal("aitroops_grade_advance", {grade + 1})
        self.advancedItem:setEnabled(true)
    end
    local advancedLb, advancedLbHeight = G_getRichTextLabel(btnStr, {nil, G_ColorYellowPro, nil}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    advancedLb:setAnchorPoint(ccp(0.5,1))
    advancedLb:setPosition(self.advancedItem:getContentSize().width / 2, self.advancedItem:getContentSize().height / 2 + advancedLbHeight / 2 + 3)
    advancedLb:setScale(1 / self.advancedItem:getScale())
    self.advancedItem:addChild(advancedLb)
    self.advancedLb = advancedLb
end

function AITroopsDetailDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.skillNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getCellHeight(idx + 1)
        local skillPos = idx + 1
        local skill = self.troopsVo:getSkillByPos(skillPos)
        if skill then
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            nameBg:setAnchorPoint(ccp(0, 1))
            nameBg:setContentSize(CCSizeMake(cellWidth - 10, nameBg:getContentSize().height))
            nameBg:setPosition(10, cellHeight - 8)
            cell:addChild(nameBg)
            
            local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(skill.sid, skill.lv)
            --技能名称
            local nameLb = GetTTFLabel(nameStr, self.skillNameFontSize, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setPosition(15, nameBg:getContentSize().height / 2)
            nameLb:setColor(G_ColorYellowPro)
            nameBg:addChild(nameLb)
            --当前等级
            local levelLb = GetTTFLabel(getlocal("fightLevel", {skill.lv}), self.skillNameFontSize, true)
            levelLb:setAnchorPoint(ccp(0, 0.5))
            levelLb:setPosition(nameLb:getPositionX() + nameLb:getContentSize().width + 15, nameLb:getPositionY())
            nameBg:addChild(levelLb)
            --技能icon
            local skillIconSp = AITroopsVoApi:getSkillIcon(skill.sid)
            skillIconSp:setScale(self.skillIconSize / skillIconSp:getContentSize().width)
            skillIconSp:setPosition(15 + self.skillIconSize * 0.5, (cellHeight - 40) * 0.5)
            cell:addChild(skillIconSp)
            
            local descPosX = 110
            local unlockFlag = true
            if self.troopsVo.grade < skillPos then--该技能未解锁
                unlockFlag = false
            end
            
            if skillPos == 3 and unlockFlag == false then
                desc = getlocal("aitroops_skill3_tip", {skillPos})
                colorTb = {nil, G_ColorYellowPro, nil}
            else
                nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(skill.sid, skill.lv)
            end
            
            local descFontWidth = self.descFontWidth
            if skillPos == 3 and unlockFlag == true then
                descFontWidth = self.descFontWidth - 90
            end
            --技能描述
            local descLb, descHeight = G_getRichTextLabel(desc, colorTb, self.skillDescFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(descPosX, cellHeight - 50)
            cell:addChild(descLb)
            
            if unlockFlag == false then --该技能未解锁
                local unlockLb, lbHeight = G_getRichTextLabel(getlocal("aitroops_skill_unlocklimit", {skillPos}), {nil, G_ColorRed, nil}, self.skillDescFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                unlockLb:setAnchorPoint(ccp(0, 1))
                unlockLb:setPosition(descPosX, 10 + lbHeight)
                cell:addChild(unlockLb)
            else
                --当前经验进度
                local expProgressSp = AddProgramTimer(cell, ccp(descLb:getPositionX(), 10 + self.expHeight * 0.5), 9, 12, "", "TeamTravelBarBg.png", "TeamTravelBar.png", 11, nil, nil, nil, nil, self.skillDescFontSize)
                local expProgressBg = tolua.cast(cell:getChildByTag(11), "CCSprite")
                local lbPer = tolua.cast(expProgressSp:getChildByTag(12), "CCLabelTTF")
                local scaleX = self.expWidth / expProgressSp:getContentSize().width
                local scaleY = self.expHeight / expProgressSp:getContentSize().height
                expProgressSp:setAnchorPoint(ccp(0, 0.5))
                expProgressBg:setAnchorPoint(ccp(0, 0.5))
                expProgressSp:setScaleX(scaleX)
                expProgressSp:setScaleY(scaleY)
                expProgressBg:setScaleX(scaleX)
                expProgressBg:setScaleY(scaleY)
                lbPer:setScaleX(1 / scaleX)
                lbPer:setScaleY(1 / scaleY)
                
                local maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(skill.sid, skill.lv)
                if skill.lv >= maxLv then
                    expProgressSp:setPercentage(100)
                    lbPer:setString(getlocal("alliance_lvmax"))
                else
                    local per = math.floor(skill.exp / nextExp * 100)
                    expProgressSp:setPercentage(per)
                    lbPer:setString(skill.exp.."/"..nextExp)
                end
                
                local priority = -(self.layerNum - 1) * 20 - 2
                --技能升级
                local function upgrade()
                    --显示技能升级页面
                    AITroopsVoApi:showSkillUpgradeDialog(self.troopsVo.id, skillPos, self.layerNum + 1)
                end
                local upgradeItem, upgradeMenu = G_createBotton(cell, ccp(cellWidth - 50, skillIconSp:getPositionY()), {}, "yh_BtnUp.png", "yh_BtnUp_Down.png", "yh_BtnUp_Down.png", upgrade, 1, priority)
                upgradeItem:setEnabled(unlockFlag)
                local flag = AITroopsVoApi:checkSkillUpgrade(skill, self.troopsVo)
                if flag == 1 then --可以升级，显示红点提示
                    local redTipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
                    redTipSp:setPosition(upgradeItem:getContentSize().width - 3, upgradeItem:getContentSize().height - 3)
                    redTipSp:setScale(0.5)
                    upgradeItem:addChild(redTipSp)
                end
                
                if idx == 2 then --第三个技能可以替换技能
                    --技能替换
                    local function exchange()
                        --显示技能替换页面
                        AITroopsVoApi:showSkillExchangeDialog(self.troopsVo.id, skillPos, self.layerNum + 1)
                    end
                    local exchangeItem, exchangeMenu = G_createBotton(cell, ccp(cellWidth - 50, skillIconSp:getPositionY()), {}, "yh_hero_switch1.png", "yh_hero_switch2.png", "yh_hero_switch2.png", exchange, 1, priority)
                    upgradeMenu:setPosition(cellWidth - 120, skillIconSp:getPositionY())
                    exchangeItem:setEnabled(unlockFlag)
                end
            end
            
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            lineSp:setAnchorPoint(ccp(0.5, 0))
            lineSp:setContentSize(CCSizeMake(cellWidth - 18, lineSp:getContentSize().height))
            lineSp:setRotation(180)
            lineSp:setPosition(cellWidth / 2, lineSp:getContentSize().height / 2)
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

function AITroopsDetailDialog:getCellHeight(idx)
    if self.cellHeightTb[idx] == nil then
        local height = 40
        local showHeight = 0
        local unlockFlag = true
        if self.troopsVo.grade < idx then --该技能未解锁
            unlockFlag = false
        end
        local nameStr, desc, colorTb
        if idx == 3 and unlockFlag == false then
            desc = getlocal("aitroops_skill3_tip", {idx})
            colorTb = {nil, G_ColorYellowPro, nil}
        else
            local skill = self.troopsVo:getSkillByPos(idx)
            nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(skill.sid, skill.lv)
        end
        
        local descFontWidth = self.descFontWidth
        if idx == 3 and unlockFlag == true then
            descFontWidth = self.descFontWidth - 90
        end
        local descLb, descHeight = G_getRichTextLabel(desc, colorTb, self.skillDescFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        showHeight = showHeight + descHeight
        if self.troopsVo.grade < idx then --该技能未解锁
            local unlockLb, lbHeight = G_getRichTextLabel(getlocal("aitroops_skill_unlocklimit", {idx}), {nil, G_ColorRed, nil}, self.skillDescFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            showHeight = showHeight + lbHeight + 10
        else
            showHeight = showHeight + self.expHeight + 10
        end
        if showHeight < self.skillIconSize then
            showHeight = self.skillIconSize
        end
        height = height + showHeight + 20
        self.cellHeightTb[idx] = height
    end
    return self.cellHeightTb[idx]
end

--刷新技能相关
function AITroopsDetailDialog:refreshSkills()
    self.troopsVo = AITroopsVoApi:getTroopsById(self.troopsVo.id)
    self.skillNum = #self.troopsVo:getTroopsSkillList()
    self.cellHeightTb = {}
    if self.tv then
        self.tv:reloadData()
    end
end

--移除部队经验升级的动画
function AITroopsDetailDialog:removeUpgradeEffect(callback)
    if self.actionLayer then
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer = nil
    end
    if self.progressScheduler then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.progressScheduler)
        self.progressScheduler = nil
    end
    if self.actionFlag == true then
        if callback then
            callback()
        end
    end
    self.actionFlag = false
end

--部队经验提升的动画
function AITroopsDetailDialog:playUpgradeEffect(expRate, callback)
    self.actionFlag = true
    
    if self.actionLayer == nil then
        local actionLayer = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function () end)
        actionLayer:setAnchorPoint(ccp(0.5, 1))
        actionLayer:setContentSize(self.itemBg:getContentSize())
        actionLayer:setOpacity(0)
        actionLayer:setPosition(self.itemBg:getPosition())
        self.bgLayer:addChild(actionLayer, 3)
        self.actionLayer = actionLayer
    end
    local troopsId = self.troopsVo.id
    self.troopsVo = AITroopsVoApi:getTroopsById(troopsId)
    local totalAddExp = AITroopsVoApi:getTroopsAddExpByRate(expRate)
    local exp, needExp = self.lastExp, self.lastNextExp
    local realAddExp = 0
    for k = self.lastLv, self.troopsVo.lv do
        local tNextExp = AITroopsVoApi:getTroopsUpgradeExpById(troopsId, k)
        if k == self.lastLv then
            local leftExp = tNextExp - self.lastExp
            if leftExp >= totalAddExp then
                realAddExp = realAddExp + totalAddExp
            else
                realAddExp = realAddExp + leftExp
            end
        else
            realAddExp = realAddExp + tNextExp
        end
    end
    if realAddExp > totalAddExp then
        realAddExp = totalAddExp
    end
    
    local ft = 0.03
    local totalTime, timeSpeed, fastTickFlag = 0, 0.5, true
    local expRateShowHeight = 50
    if tonumber(expRate) > 1 then
        expRateShowHeight = 80
    end
    local function progressAction()
        if tonumber(expRate) > 1 then --经验翻倍的话，展示以下特效
            local progressAcSp = CCSprite:createWithSpriteFrameName("aitskill_upgrade_pro1.png")
            local proFrameArr = CCArray:create()
            for k = 1, 6 do
                local nameStr = "aitskill_upgrade_pro"..k..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                proFrameArr:addObject(frame)
            end
            local proAni = CCAnimation:createWithSpriteFrames(proFrameArr)
            proAni:setDelayPerUnit(ft)
            local proAnimate = CCAnimate:create(proAni)
            progressAcSp:setAnchorPoint(ccp(0.5, 0.5))
            progressAcSp:setScale(0.8)
            progressAcSp:setPosition(self.expProgressSp:getPositionX(), self.expProgressSp:getPositionY())
            self.actionLayer:addChild(progressAcSp, 3)
            
            local blendFunc = ccBlendFunc:new()
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            progressAcSp:setBlendFunc(blendFunc)
            
            local acArr = CCArray:create()
            acArr:addObject(proAnimate)
            local function aniEnd()
                progressAcSp:removeFromParentAndCleanup(true)
                progressAcSp = nil
            end
            acArr:addObject(CCCallFunc:create(aniEnd))
            local seq = CCSequence:create(acArr)
            progressAcSp:runAction(seq)
            
            if self.expProgressLb then
                local acArr = CCArray:create()
                local scaleTo1 = CCScaleTo:create(3 * ft, 3)
                local scaleTo2 = CCScaleTo:create(3 * ft, 1)
                acArr:addObject(scaleTo1)
                acArr:addObject(scaleTo2)
                local seq = CCSequence:create(acArr)
                self.expProgressLb:runAction(seq)
            end
        else
            local progressAcSp = CCSprite:createWithSpriteFrameName("aitskill_upgrade_pro.png")
            progressAcSp:setPosition(self.expProgressSp:getPosition())
            progressAcSp:setScaleX((self.progressWidth + 40) / progressAcSp:getContentSize().width)
            progressAcSp:setScaleY((self.progressHeight + 50) / progressAcSp:getContentSize().height)
            progressAcSp:setOpacity(0)
            self.actionLayer:addChild(progressAcSp)
            local acArr = CCArray:create()
            local fadeTo1 = CCFadeTo:create(timeSpeed, 255)
            local fadeTo2 = CCFadeTo:create(0.2, 0)
            acArr:addObject(fadeTo1)
            acArr:addObject(fadeTo2)
            local function progressAcEnd()
                if progressAcSp then
                    progressAcSp:removeFromParentAndCleanup(true)
                    progressAcSp = nil
                end
            end
            acArr:addObject(CCCallFunc:create(progressAcEnd))
            local seq = CCSequence:create(acArr)
            progressAcSp:runAction(seq)
        end
    end
    local curAddExp, lastAddExp, showLv = 0, 0, self.lastLv
    local function progressFastTick(dt)
        if fastTickFlag == true then
            totalTime = totalTime + dt
            if totalTime > timeSpeed then
                totalTime = timeSpeed
            end
            lastAddExp = curAddExp
            curAddExp = math.floor(realAddExp * totalTime / timeSpeed)
            local expValue = curAddExp - lastAddExp
            exp = exp + expValue
            if exp >= needExp then
                showLv = showLv + 1
                if showLv > self.troopsVo.lv then
                    showLv = self.troopsVo.lv
                    exp = needExp
                else
                    exp = exp - needExp --当前显示等级溢出的经验积累到下一等级显示
                    needExp = AITroopsVoApi:getTroopsUpgradeExpById(troopsId, showLv)
                end
                if self.nameLb and self.levelLb then
                    self.levelLb:setString(getlocal("fightLevel", {showLv}))
                    self.levelLb:setPositionX(self.nameLb:getPositionX() + self.nameLb:getContentSize().width + 15)
                end
            end
            if self.expProgressLb and self.expProgressSp then
                if showLv >= self.troopsMaxLv then --满级处理
                    self.expProgressLb:setString(getlocal("alliance_lvmax"))
                    self.expProgressSp:setPercentage(100)
                    
                else
                    self.expProgressLb:setString(exp.."/"..needExp)
                    local per = math.floor(exp / needExp * 100)
                    self.expProgressSp:setPercentage(per)
                end
            end
            if curAddExp >= realAddExp then --进度条变化结束
                fastTickFlag = false
                if tonumber(expRate) > 1 then
                    progressAction()
                end
                if self.progressScheduler then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.progressScheduler)
                    self.progressScheduler = nil
                end
            end
        end
    end
    self.progressScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(progressFastTick, 0, false)
    if tonumber(expRate) == 1 then --如果经验没有翻倍的话，则进度条特效一开始就播放
        progressAction()
    end
    
    --增加的经验显示特效
    local addExpLb = GetTTFLabel("Exp+"..totalAddExp, 22, true)
    addExpLb:setPosition(self.expProgressLb:getPosition())
    addExpLb:setOpacity(20)
    addExpLb:setScale(0.5)
    addExpLb:setColor(G_ColorBlue)
    self.actionLayer:addChild(addExpLb, 5)
    local targetPosY = addExpLb:getPositionY() + 40
    local addExpAcArr = CCArray:create()
    local expLbFadeTo = CCFadeTo:create(timeSpeed, 255)
    local expLbScaleTo = CCScaleTo:create(timeSpeed, 1.2)
    local expMoveTo1 = CCMoveTo:create(timeSpeed, ccp(addExpLb:getPositionX(), targetPosY - 20))
    local expLbSpawnArr = CCArray:create()
    expLbSpawnArr:addObject(expLbFadeTo)
    expLbSpawnArr:addObject(expLbScaleTo)
    expLbSpawnArr:addObject(expMoveTo1)
    local expLbSpawnAc = CCSpawn:create(expLbSpawnArr)
    addExpAcArr:addObject(expLbSpawnAc) --先渐现放大
    local expMoveTo2 = CCMoveTo:create(3 * ft, ccp(addExpLb:getPositionX(), targetPosY))
    addExpAcArr:addObject(expMoveTo2)
    addExpAcArr:addObject(CCDelayTime:create(0.5))
    local function addExpLbActionEnd() --这个动作视为整个动画结束
        self:removeUpgradeEffect(callback)
    end
    addExpAcArr:addObject(CCCallFunc:create(addExpLbActionEnd))
    local expLbSeq = CCSequence:create(addExpAcArr)
    addExpLb:runAction(expLbSeq)
    
    --增加经验的背景显示
    local addExpShowBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    addExpShowBg:setScaleX(200 / addExpShowBg:getContentSize().width)
    addExpShowBg:setScaleY(expRateShowHeight / addExpShowBg:getContentSize().height)
    addExpShowBg:setAnchorPoint(ccp(0.5, 0))
    addExpShowBg:setOpacity(0)
    addExpShowBg:setPosition(self.expProgressSp:getPositionX(), self.expProgressLb:getPositionY() + 15)
    self.actionLayer:addChild(addExpShowBg, 3)
    addExpShowBg:runAction(CCFadeTo:create(timeSpeed / 2, 200))
    
    if tonumber(expRate) > 1 then --如果翻倍的话显示翻倍比例特效
        local expRateLb = GetTTFLabel("x"..expRate, 40, true)
        expRateLb:setPosition(addExpShowBg:getPositionX(), addExpShowBg:getPositionY() + expRateShowHeight - expRateLb:getContentSize().height / 2 - 5)
        expRateLb:setScale(0)
        expRateLb:setColor(G_ColorYellowPro)
        self.actionLayer:addChild(expRateLb, 5)
        expRateLb:runAction(CCScaleTo:create(timeSpeed / 2, 1))
    end
end

function AITroopsDetailDialog:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("aitroops.detail.refresh", self.refreshListener)
        self.refreshListener = nil
    end
    if self.overTodayListener then
        eventDispatcher:removeEventListener("aitroops.over.today", self.overTodayListener)
        self.overTodayListener = nil
    end
    self.cellHeightTb = nil
    self.skillNum = nil
    self.tvWidth, self.tvHeight = nil, nil
    self.skillIconSize = nil
    self.skillNameFontSize = nil
    self.skillDescFontSize = nil
    self.expWidth = nil
    self.expHeight = nil
    self.descFontWidth = nil
    self.nameLb = nil
    self.strengthLb = nil
    self.expProgressSp = nil
    self.fragmentLb = nil
    self.numLb = nil
    self.upgradeItem, self.upgradeMenu, self.upgradeLb = nil, nil, nil
    self.advancedItem, self.advancedMenu, self.advancedLb = nil, nil, nil
    self.lastLv, self.lastExp, self.lastNextExp = nil, nil, nil
    self.expProgressLb = nil
    self:removeUpgradeEffect()
    spriteController:removePlist("public/aiTroopsImage/aitroops_effect1.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_effect1.png")
end
