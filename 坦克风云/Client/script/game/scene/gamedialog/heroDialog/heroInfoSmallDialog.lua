heroInfoSmallDialog = smallDialog:new()

function heroInfoSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function heroInfoSmallDialog:showHeroInfo(heroVo, onlyBaseAttr, isMax, layerNum)
    spriteController:addPlist("public/nbSkill.plist")
    spriteController:addTexture("public/nbSkill.png")
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    
    self.heroVo = heroVo
    self.layerNum = layerNum
    self.onlyBaseAttr = onlyBaseAttr
    self.isMax = isMax
    self.cellHeightTb = {}
    self.sbSkillHeight = {}
    local sd = heroInfoSmallDialog:new()
    sd:initHeroInfoView()
end

function heroInfoSmallDialog:initHeroInfoView()
    if self.isMax == true then
        self.heroVo.level = heroVoApi:getHeroMaxLevel()
    end
    
    self.dialogWidth, self.dialogHeight = 550, 85
    self.heroIconWidth, self.attrIconWidth, self.hsIconWidth = 100, 50, 80
    self.dialogHeight = self.dialogHeight + self.heroIconWidth + 90
    
    self.sbSkillNum = SizeOfTable(heroListCfg[self.heroVo.hid].skills)
    -- if heroVoApi:heroHonorIsOpen() == true and self.heroVo and self.heroVo.hid then
    self.nbSkillNum = #heroVoApi:getUsedRealiseSkill(self.heroVo.hid, self.heroVo)
    -- end
    self.adTb = {}
    for k, v in pairs(heroListCfg[self.heroVo.hid].heroAtt) do
        table.insert(self.adTb, k)
    end
    local equipOpenLv = base.heroEquipOpenLv or 30
    if self.onlyBaseAttr ~= true and base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv then
        local newAllAttList = {}
        self.equipAttList, newAllAttList = heroEquipVoApi:getAttListByHid(self.heroVo.hid, nil, self.heroVo.productOrder)
        for k, v in pairs(newAllAttList) do
            local ifHas = false
            for kk, vv in pairs(self.adTb) do
                if vv == v.key then
                    ifHas = true
                    break
                end
            end
            if ifHas == false then
                table.insert(self.adTb, v.key)
            end
        end
    end
    local attrNum = #self.adTb
    local attrHeight = math.ceil(attrNum / 2) * self.attrIconWidth + (math.ceil(attrNum / 2) - 1) * 10
    self.dialogHeight = self.dialogHeight + attrHeight
    
    self.stvWidth, self.stvHeight = self.dialogWidth, 420
    self.dialogHeight = self.dialogHeight + self.stvHeight
    
    local overviewTipLb
    if self.isMax == true then
        overviewTipLb = GetTTFLabelWrap(getlocal("hero_info_reviewTip"), 24, CCSize(self.dialogWidth - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        overviewTipLb:setAnchorPoint(ccp(0.5, 1))
        overviewTipLb:setColor(G_ColorYellowPro)
        self.dialogHeight = self.dialogHeight + overviewTipLb:getContentSize().height + 20
    end
    
    local function close()
        self:close()
    end
    local dialog = G_getNewDialogBg(CCSizeMake(self.dialogWidth, self.dialogHeight), getlocal("report_hero_message"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialog
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self:show()
    
    local posY = self.dialogHeight - 65
    if overviewTipLb then
        overviewTipLb:setPosition(self.dialogWidth / 2, posY - 10)
        self.bgLayer:addChild(overviewTipLb)
        posY = posY - overviewTipLb:getContentSize().height - 10
    end
    
    local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid, self.heroVo.productOrder, nil, nil, nil, nil, nil, {showAjt = false})
    heroIcon:setPosition(ccp(50 + self.heroIconWidth / 2, posY - self.heroIconWidth / 2 - 20))
    heroIcon:setScale(self.heroIconWidth / heroIcon:getContentSize().width)
    self.bgLayer:addChild(heroIcon)
    
    local function itemTouch(...)
        if G_checkClickEnable() == false then
            return
        end
        
        -- 显示英雄信息
        local td = smallDialog:new()
        
        -- 获取hero描述lable的高度，动态的传给smallDialog
        local lable = GetTTFLabelWrap(heroVoApi:getHeroDes(self.heroVo.hid), 25, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        
        local dialog = td:initHeroInfo("PanelPopup.png", CCSizeMake(500, 200 + lable:getContentSize().height + 25 + 60), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, self.heroVo, 28, tabColor)
        sceneGame:addChild(dialog, self.layerNum + 1)
        PlayEffect(audioCfg.mouseClick)
    end
    -- 添加英雄信息按钮
    local heroInfoItem = GetButtonItem("hero_infoBtn.png", "hero_infoBtn.png", "hero_infoBtn.png", itemTouch, 11, nil, nil)
    local menu = CCMenu:createWithItem(heroInfoItem)
    menu:setPosition(ccp(self.dialogWidth - 50, self.dialogHeight - 150))
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menu)
    
    local lbx = 250
    local exp, per = heroVoApi:getHeroLeftExp(self.heroVo)
    local mLv = G_LV()..self.heroVo.level.."/"..G_LV()..heroVoApi:getHeroMaxLevel()
    
    if heroVoApi:isHeroMaxLv(self.heroVo.hid, self.heroVo.productOrder, self.heroVo) then
        mLv = G_LV()..self.heroVo.level.." ("..getlocal("alliance_lvmax") .. ")"
    end
    
    local color = heroVoApi:getHeroColor(self.heroVo.productOrder)
    local nameLb = GetTTFLabel(getlocal(heroListCfg[self.heroVo.hid].heroName), 24, true)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(230, heroIcon:getPositionY() + self.heroIconWidth / 2 - 20)
    nameLb:setColor(color)
    self.bgLayer:addChild(nameLb)
    
    local lvLb = GetTTFLabel(mLv, 22)
    lvLb:setAnchorPoint(ccp(0, 1))
    lvLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
    self.bgLayer:addChild(lvLb)
    
    posY = heroIcon:getPositionY() - self.heroIconWidth / 2 - 40
    
    local atb = heroVoApi:getAddBuffTb(self.heroVo)
    local tb = {atk = {icon = "attributeARP.png", lb = {getlocal("dmg"), }},
        hlp = {icon = "attributeArmor.png", lb = {getlocal("hlp"), }},
        hit = {icon = "skill_01.png", lb = {getlocal("sample_skill_name_101"), }},
        eva = {icon = "skill_02.png", lb = {getlocal("sample_skill_name_102"), }},
        cri = {icon = "skill_03.png", lb = {getlocal("sample_skill_name_103"), }},
        res = {icon = "skill_04.png", lb = {getlocal("sample_skill_name_104"), }},
        first = {icon = "positiveHead.png", lb = {getlocal("firstValue"), }},
    }
    
    local posTb = {30, 275}
    local iconWidth = 50
    local attrFontSize = 18
    for i = 1, #self.adTb do
        local attackSp = CCSprite:createWithSpriteFrameName(tb[self.adTb[i]].icon)
        if self.adTb[i] == "first" then
            attackSp = GetBgIcon(tb[self.adTb[i]].icon, nil, nil, 55)
        end
        local posx = posTb[1]
        if i % 2 == 0 then
            posx = posTb[2]
        end
        attackSp:setAnchorPoint(ccp(0, 0.5))
        attackSp:setScale(self.attrIconWidth / attackSp:getContentSize().width)
        attackSp:setPosition(posx, posY - (2 * math.ceil(i / 2) - 1) * self.attrIconWidth / 2 - (math.ceil(i / 2) - 1) * 10)
        self.bgLayer:addChild(attackSp)
        local strLb1 = GetTTFLabel(tb[self.adTb[i]].lb[1], attrFontSize)
        if self.adTb[i] == "first" then
            strLb1 = GetTTFLabel(tb[self.adTb[i]].lb[1], 20 / iconScale)
        end
        strLb1:setAnchorPoint(ccp(0, 0.5))
        strLb1:setPosition(attackSp:getPositionX() + self.attrIconWidth + 5, attackSp:getPositionY())
        self.bgLayer:addChild(strLb1)
        local txtWidth = strLb1:getContentSize().width
        
        if atb[self.adTb[i]] then
            local strLb2 = GetTTFLabel("+"..atb[self.adTb[i]] .. "%", attrFontSize)
            strLb2:setAnchorPoint(ccp(0, 0.5))
            strLb2:setPosition(strLb1:getPositionX() + txtWidth, strLb1:getPositionY())
            self.bgLayer:addChild(strLb2)
            txtWidth = txtWidth + strLb2:getContentSize().width
        end
        
        local value3 = 0
        local equipOpenLv = base.heroEquipOpenLv or 30
        if self.onlyBaseAttr ~= true and base.he == 1 and playerVoApi:getPlayerLevel() >= equipOpenLv and self.equipAttList and SizeOfTable(self.equipAttList) then
            if self.equipAttList[self.adTb[i]] then
                value3 = self.equipAttList[self.adTb[i]].value
            end
        end
        if self.onlyBaseAttr ~= true and heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(self.heroVo) then
            if self.adjAttTb[self.adTb[i]] then
                value3 = value3 + self.adjAttTb[self.adTb[i]]
            end
        end
        if value3 > 0 then
            local strLb3
            if self.adTb[i] == "first" then
                strLb3 = GetTTFLabel("+"..value3, attrFontSize)
            else
                strLb3 = GetTTFLabel("+"..value3.."%", attrFontSize)
            end
            strLb3:setAnchorPoint(ccp(0, 0.5))
            strLb3:setAnchorPoint(strLb1:getPositionX() + txtWidth, strLb1:getPositionY())
            txtWidth = txtWidth + strLb3:getContentSize().width
            strLb3:setColor(G_ColorGreen)
            self.bgLayer:addChild(strLb3)
        end
    end
    posY = posY - attrHeight - 20
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    lineSp:setAnchorPoint(ccp(0.5, 0.5))
    lineSp:setContentSize(CCSizeMake(self.dialogWidth - 30, lineSp:getContentSize().height))
    lineSp:setPosition(self.dialogWidth / 2, posY)
    
    self.stvWidth = self.dialogWidth - 20
    
    self.titleHeight, self.cellSpaceY = 0.5 * 138, 20
    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" then
        self.cellSpaceY = 130
    end
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.stvWidth, self.stvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((self.dialogWidth - self.stvWidth) / 2, posY - self.stvHeight)
    self.bgLayer:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    
    local function touchHandler()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchHandler)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.dialogLayer:setPosition(0, 0)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function heroInfoSmallDialog:getCellHeight(idx)
    if self.cellHeightTb[idx] == nil then
        if idx == 1 then
            local cellWidth = self.dialogWidth - 20
            local titleFontSize, nameFontSize, descFontSize = 24, 22, 20
            local txtWidth = cellWidth - self.hsIconWidth - 40
            local height = 0
            for i = 1, self.sbSkillNum do
                local sid = heroListCfg[self.heroVo.hid].skills[i][1]
                local awakenSid = sid
                if self.heroVo.skill[sid] == nil and equipCfg[self.heroVo.hid]["e1"].awaken.skill then
                    local awakenSkill = equipCfg[self.heroVo.hid]["e1"].awaken.skill
                    if awakenSkill[sid] then
                        awakenSid = awakenSkill[sid]
                    end
                end
                local lvStr, value, isMax, skillLv, sv = heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder, nil, nil, 25, true)
                local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[awakenSid].name)..lvStr, nameFontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
                local skdesc = heroVoApi:getSkillDesc(sid, sv)
                local descLb = GetTTFLabelWrap(skdesc, descFontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                
                local perh = nameLb:getContentSize().height + 20 + descLb:getContentSize().height
                if perh < (self.hsIconWidth + 20) then
                    perh = self.hsIconWidth + 20
                end
                height = height + perh
                self.sbSkillHeight[i] = perh
            end
            self.cellHeightTb[idx] = height + self.titleHeight
        else
            if(self.nbSkillNum == 0)then
                self.cellHeightTb[idx] = self.titleHeight + self.hsIconWidth + self.cellSpaceY
            else
                self.cellHeightTb[idx] = self.titleHeight + math.ceil(self.nbSkillNum / 2) * (self.hsIconWidth + self.cellSpaceY)
            end
        end
    end
    return self.cellHeightTb[idx]
end

function heroInfoSmallDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 2
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.dialogWidth - 20, self:getCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellWidth = self.dialogWidth - 20
        local cellHeight = self:getCellHeight(idx + 1)
        local titleFontSize, nameFontSize, descFontSize = 24, 22, 20
        --上面一格是普通技能
        if(idx == 0)then
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setAnchorPoint(ccp(0.5, 0.5))
            lineSp:setScaleX((cellWidth - 20) / lineSp:getContentSize().width)
            lineSp:setPosition(cellWidth / 2, cellHeight - 2)
            cell:addChild(lineSp)
            local titleSp = CCSprite:createWithSpriteFrameName("nbSkillTitle1.png")
            titleSp:setAnchorPoint(ccp(0.5, 1))
            titleSp:setPosition(cellWidth / 2, cellHeight)
            cell:addChild(titleSp, 1)
            local titleBg = CCSprite:createWithSpriteFrameName("heroInfoHeaderBg.png")
            titleBg:setScale(self.titleHeight / titleBg:getContentSize().height)
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(cellWidth / 2, cellHeight - 1)
            cell:addChild(titleBg)
            local titleLb = GetTTFLabel(getlocal("hero_honor_commonSkill"), titleFontSize, true)
            titleLb:setColor(G_ColorYellowPro)
            titleLb:setAnchorPoint(ccp(0.5, 1))
            titleLb:setPosition(cellWidth / 2, cellHeight - titleSp:getContentSize().height)
            cell:addChild(titleLb, 1)
            local posY = cellHeight - self.titleHeight - 2
            local txtWidth = cellWidth - self.hsIconWidth - 40
            local maxLv
            if self.isMax == true then
                maxLv = heroVoApi:getSkillMaxLevel()
            end
            for i = 1, self.sbSkillNum do
                local sid = heroListCfg[self.heroVo.hid].skills[i][1]
                local awakenSid = sid
                if self.heroVo.skill[sid] == nil and equipCfg[self.heroVo.hid]["e1"].awaken.skill then
                    local awakenSkill = equipCfg[self.heroVo.hid]["e1"].awaken.skill
                    if awakenSkill[sid] then
                        awakenSid = awakenSkill[sid]
                    end
                end
                local lvStr, value, isMax, skillLv, sv = heroVoApi:getHeroSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder, nil, nil, maxLv, true, true)
                local function showSkillDesc(...)
                    if self.tv:getIsScrolled() == true then
                        do return end
                    end
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    heroVoApi:showHeroSkillDescDialog(self.heroVo.hid, awakenSid, self.heroVo.productOrder, skillLv, false, self.layerNum + 1)
                end
                local icon = LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid), showSkillDesc)
                icon:setScale(self.hsIconWidth / icon:getContentSize().width)
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setAnchorPoint(ccp(0, 0.5))
                icon:setPosition(10, posY - self.sbSkillHeight[i] / 2)
                cell:addChild(icon)
                local color = G_ColorWhite
                if skillLv then
                    color = heroVoApi:getSkillColorByLv(skillLv)
                end
                local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[awakenSid].name)..lvStr, nameFontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
                nameLb:setColor(color)
                nameLb:setAnchorPoint(ccp(0, 1))
                nameLb:setPosition(icon:getPositionX() + self.hsIconWidth + 10, posY - 5)
                cell:addChild(nameLb)
                
                local skdesc = heroVoApi:getSkillDesc(sid, sv)
                local descLb = GetTTFLabelWrap(skdesc, descFontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0, 1))
                descLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
                cell:addChild(descLb)
                
                posY = posY - self.sbSkillHeight[i]
                
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                lineSp:setContentSize(CCSizeMake(cellWidth - 20, lineSp:getContentSize().height))
                lineSp:setPosition(cellWidth / 2, posY)
                cell:addChild(lineSp)
            end
            --下面一格是授勋技能
        else
            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setAnchorPoint(ccp(0.5, 0.5))
            lineSp:setScaleX((cellWidth - 20) / lineSp:getContentSize().width)
            lineSp:setPosition(cellWidth / 2, cellHeight - 2)
            cell:addChild(lineSp)
            local titleSp = CCSprite:createWithSpriteFrameName("nbSkillTitle2.png")
            titleSp:setAnchorPoint(ccp(0.5, 1))
            titleSp:setPosition((cellWidth) / 2, cellHeight)
            cell:addChild(titleSp, 1)
            local titleBg = CCSprite:createWithSpriteFrameName("heroInfoHeaderBg.png")
            titleBg:setScale(0.5)
            titleBg:setAnchorPoint(ccp(0.5, 1))
            titleBg:setPosition(cellWidth / 2, cellHeight - 1)
            cell:addChild(titleBg)
            local titleLb = GetTTFLabel(getlocal("hero_honor_used_honor_skill"), titleFontSize, true)
            titleLb:setColor(G_ColorYellowPro)
            titleLb:setAnchorPoint(ccp(0.5, 1))
            titleLb:setPosition(cellWidth / 2, cellHeight - titleSp:getContentSize().height)
            cell:addChild(titleLb, 1)
            local posY = cellHeight - self.titleHeight - 2
            local totalNum = 2
            for i = 1, totalNum do
                if(i > self.nbSkillNum)then
                    local posX
                    if(i % 2 == 1)then
                        posX = 10
                    else
                        posX = cellWidth / 2 + 5
                    end
                    local iconBg = GraySprite:createWithSpriteFrameName("accessoryMetalBg.png")
                    iconBg:setScale(90 / iconBg:getContentSize().width)
                    iconBg:setAnchorPoint(ccp(0, 1))
                    iconBg:setPosition(posX - 5, posY - 10)
                    cell:addChild(iconBg)
                    local lockIcon = CCSprite:createWithSpriteFrameName("aitroops_lock.png")
                    lockIcon:setScale(0.8)
                    lockIcon:setPosition(posX + 40, posY - 55)
                    cell:addChild(lockIcon)
                    local unlockStr = ""
                    if i == 1 then
                        unlockStr = getlocal("hero_honor_unlock")
                    else
                        unlockStr = getlocal("hero_honor_unlock2")
                    end
                    local lockLb = GetTTFLabelWrap(unlockStr, nameFontSize, CCSizeMake(cellWidth / 2 - 10 - self.hsIconWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                    lockLb:setAnchorPoint(ccp(0, 0.5))
                    lockLb:setPosition(posX + 95, posY - 55)
                    cell:addChild(lockLb)
                else
                    local sid = self.heroVo.honorSkill[i][1]
                    local skillLv = self.heroVo.honorSkill[i][2]
                    local lvStr, value, isMax, skillLv = heroVoApi:getHeroHonorSkillLvAndValue(self.heroVo.hid, sid, self.heroVo.productOrder, skillLv)
                    local function showSkillDesc(...)
                        if self.tv:getIsScrolled() == true then
                            do return end
                        end
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        heroVoApi:showHeroSkillDescDialog(self.heroVo.hid, sid, self.heroVo.productOrder, skillLv, true, self.layerNum + 1)
                    end
                    local icon = LuaCCSprite:createWithFileName(heroVoApi:getSkillIconBySid(sid), showSkillDesc)
                    icon:setScale(self.hsIconWidth / icon:getContentSize().width)
                    icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    local posX
                    if(i % 2 == 1)then
                        posX = 5
                        if(i > 1)then
                            posY = posY - self.hsIconWidth - 20
                        end
                    else
                        posX = cellWidth / 2 + 5
                    end
                    icon:setAnchorPoint(ccp(0, 1))
                    icon:setPosition(posX, posY - 10)
                    cell:addChild(icon, 1)
                    local iconBg = CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
                    iconBg:setScale(90 / iconBg:getContentSize().width)
                    iconBg:setAnchorPoint(ccp(0, 1))
                    iconBg:setPosition(posX - 5, posY - 5)
                    cell:addChild(iconBg)
                    local icon2 = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                    icon2:setAnchorPoint(ccp(1, 0))
                    icon2:setPosition(icon:getContentSize().width - 5, 5)
                    icon:addChild(icon2)
                    local color = G_ColorWhite
                    if skillLv then
                        color = heroVoApi:getSkillColorByLv(skillLv)
                    end
                    local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[sid].name), nameFontSize, CCSizeMake(cellWidth / 2 - 80 - 64, 65), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                    nameLb:setColor(color)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    nameLb:setPosition(posX + 80 + 10, posY - 50 + 25)
                    cell:addChild(nameLb)
                    local lvLb = GetTTFLabel(lvStr, descFontSize)
                    lvLb:setAnchorPoint(ccp(0, 0.5))
                    lvLb:setPosition(posX + 80 + 10, posY - 50 - 25)
                    cell:addChild(lvLb)
                end
            end
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

