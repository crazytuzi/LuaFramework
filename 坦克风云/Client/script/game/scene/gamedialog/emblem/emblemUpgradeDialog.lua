--军徽进阶面板
emblemUpgradeDialog = commonDialog:new()

function emblemUpgradeDialog:new(data)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.equipBgWidth = 295
    self.equipBgHeight = 530
    nc.data = data
    nc.equipID = data.id
    nc.equipCfg = data.cfg
    return nc
end

function emblemUpgradeDialog:resetTab()
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 93))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth / 2, 20))
end

-- 添加一条装备信息
function emblemUpgradeDialog:doUserHandler()
    local function nilFunc()
    end
    local centerX = G_VisibleSizeWidth / 2
    local centerY = G_VisibleSizeHeight - 100 - self.equipBgHeight / 2

    -- 文字大小
    self.fontSize = 20
    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" then
        self.fontSize = 18
    end
    
    local txtWidth = 255
    self.lvToEquipCfg = emblemVoApi:getEquipCfgById(self.equipCfg.lvTo)
    
    self.skillHeight = 0
    self.skillTb = {}
    self.attUpHeight = 0
    self.attUpNoTb = {}
    
    local h
    for i = 1, 2 do
        -- 技能名称
        local cfg
        if i == 1 then
            cfg = self.equipCfg
        else
            cfg = self.lvToEquipCfg
        end
        self.skillTb[i] = nil
        if cfg.skill then
            self.skillTb[i] = {}
            local str = emblemVoApi:getEquipSkillNameById(cfg.skill[1], cfg.skill[2])
            str = str..":"
            local strLb = GetTTFLabelWrap(str, self.fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            self.skillTb[i][1] = strLb
            -- 技能描述
            str = emblemVoApi:getEquipSkillDesById(cfg.skill[1], cfg.skill[2])
            local strDesLb = GetTTFLabelWrap(str, self.fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            self.skillTb[i][2] = strDesLb
            
            h = strLb:getContentSize().height + strDesLb:getContentSize().height + 10 -- 10是技能标题和描述之间高度

        else
            local skillnoLb = GetTTFLabel(getlocal("emblem_noSkill"), self.fontSize)
            self.skillTb[i] = skillnoLb
            h = skillnoLb:getContentSize().height
        end
        
        if h > self.skillHeight then
            self.skillHeight = h
        end

        self.attUpNoTb[i] = nil
        if SizeOfTable(cfg.attUp) > 0 then
            h = SizeOfTable(cfg.attUp) * 30
        else
            local tipLb1 = GetTTFLabelWrap(getlocal("emblem_noAttTip1"), self.fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            local tipLb2 = GetTTFLabelWrap(getlocal("emblem_noAttTip2"), self.fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            self.attUpNoTb[i] = {}
            self.attUpNoTb[i][1] = tipLb1
            self.attUpNoTb[i][2] = tipLb2
            h = tipLb1:getContentSize().height + tipLb2:getContentSize().height + 10
        end
        if h > self.attUpHeight then
            self.attUpHeight = h
        end
    end
    
    self.skillHeight = self.skillHeight + 10 + 50 --  10 是文字最下面间隔高度，50是“装备技能”文字总高度
    self.attUpHeight = self.attUpHeight + 10 + 50

    local showEquip, showEquipCfg
    
    local function callBack1(handler, fn, idx, cel)
        return self:eventHandlerContent(handler, fn, idx, cel, 1)
    end
    
    local function callBack2(handler, fn, idx, cel)
        return self:eventHandlerContent(handler, fn, idx, cel, 2)
    end
    
    for k = 1, 2 do
        if k == 1 then
            showEquip = self.equipID
            showEquipCfg = self.equipCfg
        else
            showEquip = self.equipCfg.lvTo
            showEquipCfg = self.lvToEquipCfg
        end
        local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("emblemUpBg.png", CCRect(40, 60, 46, 6), nilFunc)
        iconBg:setContentSize(CCSizeMake(self.equipBgWidth, self.equipBgHeight))
        iconBg:setAnchorPoint(ccp(0.5, 0.5))
        
        -- 装备的icon
        local icon = emblemVoApi:getEquipIconNoBg(showEquip, nil, 0)--CCSprite:createWithSpriteFrameName(iconName)
        icon:setAnchorPoint(ccp(0.5, 1))
        icon:setPosition(ccp(iconBg:getContentSize().width / 2, iconBg:getContentSize().height - 10))
        iconBg:addChild(icon)
        
        local nameLb = GetTTFLabel(emblemVoApi:getEquipName(showEquip), 25)
        nameLb:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height - 170)
        iconBg:addChild(nameLb)
        
        local line1 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
        line1:setContentSize(CCSizeMake(iconBg:getContentSize().width - 20, 3))
        line1:setPosition(ccp(iconBg:getContentSize().width / 2, iconBg:getContentSize().height - 200))
        iconBg:addChild(line1)
        
        local hd
        if k == 1 then
            hd = LuaEventHandler:createHandler(callBack1)
        else
            hd = LuaEventHandler:createHandler(callBack2)
        end
        local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.equipBgWidth, self.equipBgHeight - 220), nil)
        iconBg:addChild(tv)
        tv:setPosition(ccp(0, 10))
        tv:setAnchorPoint(ccp(0, 0))
        tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        tv:setMaxDisToBottomOrTop(120)
        
        if k == 1 then
            iconBg:setPosition(ccp(iconBg:getContentSize().width / 2 + 15, centerY))
            self.bgLayer:addChild(iconBg)
        else
            iconBg:setPosition(ccp(self.bgLayer:getContentSize().width - iconBg:getContentSize().width / 2 - 15, centerY))
            self.bgLayer:addChild(iconBg)
        end

    end
    
    self.mvTb = {}
    local startX = centerX - 30
    for i = 1, 3 do
        self.mvTb[i] = {}
        local sp1 = CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
        sp1:setPosition(startX + (i - 1) * 30, centerY)
        self.bgLayer:addChild(sp1)
        self.mvTb[i][1] = sp1
        local sp2 = CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
        sp2:setOpacity(0)
        sp2:setPosition(startX + (i - 1) * 30, centerY)
        self.bgLayer:addChild(sp2)
        self.mvTb[i][2] = sp2
    end
    self.actionSp = 0
    local function onActionEnd()
        self.actionSp = self.actionSp + 1
        if(self.actionSp > 3)then
            self.actionSp = 1
        end
        local fadeOut = CCFadeOut:create(0.5)
        local delay = CCDelayTime:create(0.5)
        local callFunc = CCCallFunc:create(onActionEnd)
        local fadeIn = CCFadeIn:create(0.5)
        local acArr2 = CCArray:create()
        acArr2:addObject(fadeIn)
        acArr2:addObject(delay)
        acArr2:addObject(fadeOut)
        local seq2 = CCSequence:create(acArr2)
        self.mvTb[self.actionSp][2]:runAction(seq2)
        local acArr = CCArray:create()
        acArr:addObject(fadeOut)
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        acArr:addObject(fadeIn)
        local seq = CCSequence:create(acArr)
        self.mvTb[self.actionSp][1]:runAction(seq)
    end
    onActionEnd()
    
    -- 升级所需材料背景框
    local costY = centerY - self.equipBgHeight / 2 - 10
    local costBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function (...)end)
    costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 200))
    costBg:setAnchorPoint(ccp(0.5, 1))
    costBg:setPosition(G_VisibleSizeWidth / 2, costY)
    self.bgLayer:addChild(costBg)
    -- 标题
    costY = costY - 40
    local titleTb = {getlocal("emblem_upgrade_need"), 25, G_ColorWhite}
    local titleLbSize = CCSizeMake(550, 0)
    local titleBg, titleL, subHeight = G_createNewTitle(titleTb, titleLbSize, nil, true)
    titleBg:setPosition(self.bgLayer:getContentSize().width / 2, costY)
    self.bgLayer:addChild(titleBg)
    
    costY = costY - 5
    
    local upCost = {p = self.equipCfg.upCost}
    local costReward = FormatItem(upCost)
    local index = 1
    local px
    local iconSpace = 130
    local isSuccessUpdate = true--是否材料足够升级
    local useGems = 0
    local startX = (G_VisibleSizeWidth - iconSpace * (#costReward)) / 2 + iconSpace / 2
    for k, v in pairs(costReward) do
        local icon = G_getItemIcon(v, 100, true, self.layerNum)
        px = startX + (k - 1) * iconSpace
        icon:setPosition(ccp(px, costY - 65))
        self.bgLayer:addChild(icon)
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        local str = bagVoApi:getItemNumId(v.id) .. "/"..v.num
        local strLb = GetTTFLabel(str, 22)
        strLb:setPosition(ccp(icon:getContentSize().width / 2, -15))
        icon:addChild(strLb)
        local havePropNum = bagVoApi:getItemNumId(v.id)
        if havePropNum < v.num then
            strLb:setColor(G_ColorRed)
            isSuccessUpdate = false
            useGems = useGems + (v.num - havePropNum) * propCfg[v.key].gemCost
        end
        index = index + 1
    end
    costY = costY - 150 - 20
    
    -- 升级
    local function onClickUpgrade()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function onConfirm()
            if self.equipCfg.lvTo == nil then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_maxLv"), 30)
                do return end
            end
            --test data
            -- self:showGetEquip(self.equipID,self.equipCfg.lvTo,self.layerNum + 1)
            -- do return end
            --test end

            local function upgradeCallBack()
                self:showGetEquip(self.equipID, self.equipCfg.lvTo, self.layerNum + 1)
            end

            if isSuccessUpdate == false then
                local function upgradeByGemsFunc()
                    local upCostReward = FormatItem({p = self.equipCfg.upCost})
                    local useGems = 0--所需要花费的钻石
                    for k, v in pairs(upCostReward) do
                        local havePropNum = bagVoApi:getItemNumId(v.id)
                        if havePropNum < v.num then
                            useGems = useGems + (v.num - havePropNum) * propCfg[v.key].gemCost
                        end

                    end
                    if playerVoApi:getGems() >= useGems then
                        emblemVoApi:upgrade(self.data, true, upgradeCallBack)
                    else
                        GemsNotEnoughDialog(nil, nil, useGems - playerVoApi:getGems(), self.layerNum + 1, useGems)
                    end
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), upgradeByGemsFunc, getlocal("dialog_title_prompt"), getlocal("emblem_upgrade_no_prop", {useGems}), nil, self.layerNum + 1)
            else
                emblemVoApi:upgrade(self.data, false, upgradeCallBack)
            end
        end
        if(self.equipCfg.color < 5)then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("emblem_upgradeConfirm"), nil, self.layerNum + 1)
        else
            onConfirm()
        end
    end
    local upgradeItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickUpgrade, 2, getlocal("upgradeBuild"), 24 / 0.7)
    upgradeItem:setScale(0.7)
    local upgradeBtn = CCMenu:createWithItem(upgradeItem)
    upgradeBtn:setPosition(ccp(self.bgLayer:getContentSize().width / 2, costY / 2 + 10))
    upgradeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(upgradeBtn)
end

function emblemUpgradeDialog:eventHandlerContent(handler, fn, idx, cel, index)
    if fn == "numberOfCellsInTableView" then
        return 2
    elseif fn == "tableCellSizeForIndex" then
        if idx == 0 then
            return CCSizeMake(self.equipBgWidth, self.attUpHeight)
        else
            return CCSizeMake(self.equipBgWidth, self.skillHeight)
        end
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local showEquip, showEquipCfg
        if index == 1 then
            showEquip = self.equipID
            showEquipCfg = self.equipCfg
        else
            showEquip = self.equipCfg.lvTo
            showEquipCfg = emblemVoApi:getEquipCfgById(showEquip)
        end

        local posY
        if idx == 0 then
            posY = self.attUpHeight
            local attupTitleLb = GetTTFLabel(getlocal("emblem_infoAttup"), self.fontSize + 2)
            attupTitleLb:setAnchorPoint(ccp(0.5, 0.5))
            attupTitleLb:setPosition(ccp(self.equipBgWidth / 2, self.attUpHeight - 25))
            cell:addChild(attupTitleLb)
            attupTitleLb:setColor(G_ColorYellowPro)
            
            posY = posY - 50
            -- 该等级的属性
            local effectTb = emblemVoApi:getEquipAttUpForShow(showEquipCfg.attUp)
            if effectTb and SizeOfTable(effectTb) > 0 then
                posY = posY - 15
                for kk, vv in pairs(effectTb) do
                    local attNameLb = GetTTFLabel(getlocal("emblem_attUp_"..vv[1]), self.fontSize)--getlocal(k)
                    attNameLb:setAnchorPoint(ccp(0, 0.5))
                    attNameLb:setPosition(ccp(100, posY))
                    cell:addChild(attNameLb)
                    
                    local attLbAdd
                    if vv[1] == "troopsAdd" then
                        attLbAdd = GetTTFLabel("+" .. (vv[2]), self.fontSize)
                    else
                        attLbAdd = GetTTFLabel("+" .. (vv[2] * 100) .. "%", self.fontSize)
                    end
                    attLbAdd:setAnchorPoint(ccp(0, 0.5))
                    attLbAdd:setPosition(ccp(105 + attNameLb:getContentSize().width, posY))
                    if index == 2 then
                        attLbAdd:setColor(G_ColorGreen)
                    end
                    
                    cell:addChild(attLbAdd)
                    posY = posY - 30
                end
            else
                local tipLb1 = self.attUpNoTb[index][1]
                tipLb1:setAnchorPoint(ccp(0, 1))
                tipLb1:setPosition(ccp(20, posY))
                tipLb1:setColor(G_ColorGreen)
                cell:addChild(tipLb1)

                posY = posY - tipLb1:getContentSize().height - 10
                local tipLb2 = self.attUpNoTb[index][2]
                tipLb2:setAnchorPoint(ccp(0, 1))
                tipLb2:setPosition(ccp(20, posY))
                cell:addChild(tipLb2)
            end
        else

            posY = self.skillHeight
            local line2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            line2:setContentSize(CCSizeMake(self.equipBgWidth - 20, 3))
            line2:setPosition(ccp(self.equipBgWidth / 2, posY))
            cell:addChild(line2)

            
            local skillTitleLb = GetTTFLabel(getlocal("emblem_infoSkill"), self.fontSize + 2)
            skillTitleLb:setAnchorPoint(ccp(0.5, 0.5))
            skillTitleLb:setPosition(ccp(self.equipBgWidth / 2, posY - 25))
            cell:addChild(skillTitleLb)
            skillTitleLb:setColor(G_ColorYellowPro)

            posY = posY - 50
            -- 技能名称
            local strLb = self.skillTb[index][1]
            strLb:setAnchorPoint(ccp(0, 1))
            strLb:setPosition(ccp(30, posY))
            cell:addChild(strLb)
            strLb:setColor(G_ColorGreen)

            posY = posY - strLb:getContentSize().height - 10
            -- 技能描述
            strLb = self.skillTb[index][2]
            strLb:setAnchorPoint(ccp(0, 1))
            strLb:setPosition(ccp(30, posY))
            cell:addChild(strLb)
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

function emblemUpgradeDialog:showGetEquip(equipId, lvToequipId, layerNum)
    self:close()
    
    local layer = CCLayer:create()
    layer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    sceneGame:addChild(layer, layerNum)
    
    local equipIconPos = ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 250)
    
    local iconID = lvToequipId
    local start = string.find(iconID, "_")
    if start and start > 1 then
        iconID = string.sub(lvToequipId, 1, start - 1)
    end
    
    -- 文字大小
    local fontSize = 20
    if G_getCurChoseLanguage() ~= "cn" and G_getCurChoseLanguage() ~= "tw" then
        fontSize = 18
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setAnchorPoint(ccp(0, 0))
    touchDialogBg:setContentSize(CCSizeMake(640, G_VisibleSizeHeight))
    touchDialogBg:setOpacity(200)
    touchDialogBg:setPosition(ccp(0, 0))
    layer:addChild(touchDialogBg)

    local lightSp1 = CCSprite:createWithSpriteFrameName("emblemLight.png")
    lightSp1:setScale(5)
    lightSp1:setOpacity(153)
    lightSp1:setPosition(equipIconPos)
    layer:addChild(lightSp1, 1)
    local rotate = CCRotateBy:create(10, 360)
    local repeatAc = CCRepeatForever:create(rotate)
    lightSp1:runAction(repeatAc)
    local lightSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
    lightSp2:setScale(2.5)
    lightSp2:setPosition(equipIconPos)
    layer:addChild(lightSp2, 2)
    local rotate = CCRotateBy:create(10, -360)
    local repeatAc = CCRepeatForever:create(rotate)
    lightSp2:runAction(repeatAc)
    
    local titleBg = CCSprite:createWithSpriteFrameName("awTitleBg.png")
    titleBg:setPosition(layer:getContentSize().width / 2, layer:getContentSize().height - 80)
    layer:addChild(titleBg, 1)
    
    local lb = GetTTFLabel(getlocal("emblem_upgrade_success"), 28)
    lb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 + 7)
    lb:setColor(G_ColorYellowPro)
    titleBg:addChild(lb, 8)
    
    local function callback31()
        local function nilFunc(...)
            -- body
        end
        local txtWidth = 200
        local equipCfg = emblemVoApi:getEquipCfgById(equipId)
        local lvToEquipCfg = emblemVoApi:getEquipCfgById(lvToequipId)
        local skillHeight = 0
        local maxSkillHeight = 220
        if G_getIphoneType() == G_iphone4 then
            maxSkillHeight = 100
        end
        local skillTb = {}
        local attUpHeight = 0
        local attUpNoTb = {}
        local h
        for i = 1, 2 do
            -- 技能名称
            local cfg
            if i == 1 then
                cfg = equipCfg
            else
                cfg = lvToEquipCfg
            end
            skillTb[i] = nil
            if cfg.skill then
                skillTb[i] = {}
                local str = emblemVoApi:getEquipSkillNameById(cfg.skill[1], cfg.skill[2])
                str = str..":"
                local strLb = GetTTFLabelWrap(str, fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                skillTb[i][1] = strLb
                -- 技能描述
                str = emblemVoApi:getEquipSkillDesById(cfg.skill[1], cfg.skill[2])
                local strDesLb = GetTTFLabelWrap(str, fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                local descHeight = strDesLb:getContentSize().height
                if descHeight > maxSkillHeight then
                    h = strLb:getContentSize().height + maxSkillHeight + 10 --10是技能标题和描述之间高度
                else
                    h = strLb:getContentSize().height + descHeight + 10 --10是技能标题和描述之间高度
                end
                skillTb[i][2] = {str, descHeight}
            else
                local skillnoLb = GetTTFLabel(getlocal("emblem_noSkill"), fontSize)
                skillTb[i] = skillnoLb
                h = skillnoLb:getContentSize().height
            end
            
            if h > skillHeight then
                skillHeight = h
            end

            attUpNoTb[i] = nil
            if SizeOfTable(cfg.attUp) > 0 then
                h = SizeOfTable(cfg.attUp) * 30
            else
                local tipLb1 = GetTTFLabelWrap(getlocal("emblem_noAttTip1"), fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                local tipLb2 = GetTTFLabelWrap(getlocal("emblem_noAttTip2"), fontSize, CCSizeMake(txtWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                attUpNoTb[i] = {}
                attUpNoTb[i][1] = tipLb1
                attUpNoTb[i][2] = tipLb2
                h = tipLb1:getContentSize().height + tipLb2:getContentSize().height + 10
            end
            if h > attUpHeight then
                attUpHeight = h
            end
        end
        
        skillHeight = skillHeight + 10 + 50 --  10 是文字最下面间隔高度，50是“装备技能”文字总高度
        attUpHeight = attUpHeight + 10 + 50
        local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png", CCRect(60, 24, 90, 40), nilFunc)
        titleBg:setContentSize(CCSizeMake(400, 74))
        
        local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png", CCRect(213, 20, 1, 7), nilFunc)
        contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, attUpHeight + titleBg:getContentSize().height + skillHeight))--下部分（按钮）120 上部分（图标）400 layer:getContentSize().height - 120 - 400
        contentBg:setAnchorPoint(ccp(0.5, 1))
        contentBg:setPosition(layer:getContentSize().width / 2, layer:getContentSize().height - 430)
        layer:addChild(contentBg, 10)
        
        titleBg:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height)
        contentBg:addChild(titleBg, 9)
        
        -- 装备名称
        local nameStr = getlocal("emblem_name_"..iconID)
        if lvToEquipCfg and lvToEquipCfg.lv and lvToEquipCfg.lv > 0 then
            nameStr = nameStr.."+"..lvToEquipCfg.lv
        end
        -- 装备名称
        local equipNameLb = GetTTFLabelWrap(nameStr, 26, CCSizeMake(300, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
        equipNameLb:setAnchorPoint(ccp(0.5, 0))
        equipNameLb:setPosition(ccp(titleBg:getContentSize().width / 2, 20))
        titleBg:addChild(equipNameLb)

        -- 装备品阶星级
        local colorNum = equipCfg.color
        if colorNum and colorNum > 0 then
            -- 变色
            if colorNum == 2 then
                equipNameLb:setColor(G_ColorEquipGreen)
            elseif colorNum == 3 then
                equipNameLb:setColor(G_ColorEquipBlue)
            elseif colorNum == 4 then
                equipNameLb:setColor(G_ColorEquipPurple)
            elseif colorNum == 5 then
                equipNameLb:setColor(G_ColorEquipOrange)
            end
            local px = titleBg:getContentSize().width
            for i = 1, colorNum do
                local starSize = 20 -- 星星大小
                local starSpace = 20
                local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                starSp:setScale(starSize / starSp:getContentSize().width)
                px = titleBg:getContentSize().width / 2 - starSpace / 2 * (colorNum - 1) + starSpace * (i - 1)
                starSp:setPosition(ccp(px, titleBg:getContentSize().height - 15))
                titleBg:addChild(starSp)
            end
        end
        
        local mvTb = {}
        local startX = contentBg:getContentSize().width / 2 - 30
        for i = 1, 3 do
            mvTb[i] = {}
            local sp1 = CCSprite:createWithSpriteFrameName("accessoryArrow1.png")
            sp1:setPosition(startX + (i - 1) * 30, skillHeight + 35)
            contentBg:addChild(sp1, 1)
            mvTb[i][1] = sp1
            local sp2 = CCSprite:createWithSpriteFrameName("accessoryArrow2.png")
            sp2:setOpacity(0)
            sp2:setPosition(startX + (i - 1) * 30, skillHeight + 35)
            contentBg:addChild(sp2, 1)
            mvTb[i][2] = sp2
        end
        local actionSp = 0
        local function onActionEnd()
            actionSp = actionSp + 1
            if(actionSp > 3)then
                actionSp = 1
            end
            local fadeOut = CCFadeOut:create(0.5)
            local delay = CCDelayTime:create(0.5)
            local callFunc = CCCallFunc:create(onActionEnd)
            local fadeIn = CCFadeIn:create(0.5)
            local acArr2 = CCArray:create()
            acArr2:addObject(fadeIn)
            acArr2:addObject(delay)
            acArr2:addObject(fadeOut)
            local seq2 = CCSequence:create(acArr2)
            mvTb[actionSp][2]:runAction(seq2)
            local acArr = CCArray:create()
            acArr:addObject(fadeOut)
            acArr:addObject(delay)
            acArr:addObject(callFunc)
            acArr:addObject(fadeIn)
            local seq = CCSequence:create(acArr)
            mvTb[actionSp][1]:runAction(seq)
        end
        onActionEnd()
        

        local startX = 0
        local attStartX = 0
        local posY
        for k = 1, 2 do
            startX = 50
            attStartX = startX + 50
            if k == 2 then
                startX = contentBg:getContentSize().width / 2 + 40
                attStartX = startX + 50
                equipCfg = lvToEquipCfg
            end
            posY = skillHeight + attUpHeight

            local attupTitleLb = GetTTFLabel(getlocal("emblem_infoAttup"), fontSize + 2)
            attupTitleLb:setAnchorPoint(ccp(0, 0.5))
            attupTitleLb:setPosition(ccp(attStartX, posY + 10))--标题预留50
            contentBg:addChild(attupTitleLb)
            attupTitleLb:setColor(G_ColorYellowPro)
            
            posY = posY - 15--标题预留50
            -- 该等级的属性
            local effectTb = emblemVoApi:getEquipAttUpForShow(equipCfg.attUp)
            if effectTb and SizeOfTable(effectTb) > 0 then
                posY = posY - 15
                for kk, vv in pairs(effectTb) do
                    local attNameLb = GetTTFLabel(getlocal("emblem_attUp_"..vv[1]), fontSize)--getlocal(k)
                    attNameLb:setAnchorPoint(ccp(0, 0.5))
                    attNameLb:setPosition(ccp(attStartX, posY))
                    contentBg:addChild(attNameLb)
                    
                    local attLbAdd
                    if vv[1] == "troopsAdd" then
                        attLbAdd = GetTTFLabel("+" .. (vv[2]), fontSize)
                    else
                        attLbAdd = GetTTFLabel("+" .. (vv[2] * 100) .. "%", fontSize)
                    end
                    attLbAdd:setAnchorPoint(ccp(0, 0.5))
                    attLbAdd:setPosition(ccp(attStartX + attNameLb:getContentSize().width, posY))
                    if k == 2 then
                        attLbAdd:setColor(G_ColorGreen)
                    end
                    
                    contentBg:addChild(attLbAdd)
                    posY = posY - 30
                end
            else
                local tipLb1 = attUpNoTb[k][1]
                tipLb1:setAnchorPoint(ccp(0, 1))
                tipLb1:setPosition(ccp(startX, posY))
                tipLb1:setColor(G_ColorGreen)
                contentBg:addChild(tipLb1)

                posY = posY - tipLb1:getContentSize().height - 10
                local tipLb2 = attUpNoTb[k][2]
                tipLb2:setAnchorPoint(ccp(0, 1))
                tipLb2:setPosition(ccp(startX, posY))
                contentBg:addChild(tipLb2)
            end
            
            posY = skillHeight + 35
            local line2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            line2:setContentSize(CCSizeMake((contentBg:getContentSize().width - 80) / 2, 3))
            if k == 1 then
                line2:setPosition(ccp(contentBg:getContentSize().width * 0.23, posY))
            else
                line2:setPosition(ccp(contentBg:getContentSize().width * 0.73, posY))
            end
            contentBg:addChild(line2)

            local skillTitleLb = GetTTFLabel(getlocal("emblem_infoSkill"), fontSize + 2)
            skillTitleLb:setAnchorPoint(ccp(0, 0.5))
            skillTitleLb:setPosition(ccp(attStartX, posY - 20))
            contentBg:addChild(skillTitleLb)
            skillTitleLb:setColor(G_ColorYellowPro)
            
            posY = posY - 45
            
            -- 技能名称
            if equipCfg.skill then
                local strLb = skillTb[k][1]
                strLb:setAnchorPoint(ccp(0, 1))
                strLb:setPosition(ccp(startX, posY))
                contentBg:addChild(strLb)
                strLb:setColor(G_ColorGreen)

                posY = posY - strLb:getContentSize().height - 10
                -- 技能描述
                local str, lbheight = skillTb[k][2][1], skillTb[k][2][2]
                local tvHeight = lbheight
                if tvHeight > maxSkillHeight then
                    tvHeight = maxSkillHeight
                end
                tvHeight = tvHeight + 30
                local descTv = G_LabelTableViewNew(CCSizeMake(txtWidth, tvHeight), str, fontSize, kCCTextAlignmentLeft)
                descTv:setTableViewTouchPriority(-(layerNum) * 20 - 3)
                descTv:setMaxDisToBottomOrTop(60)
                descTv:setPosition(startX, posY - tvHeight)
                contentBg:addChild(descTv)
            else
                local skillnoLb = skillTb[k]
                skillnoLb:setAnchorPoint(ccp(0, 1))
                skillnoLb:setPosition(ccp(startX, posY))
                contentBg:addChild(skillnoLb)
            end
        end
        
        local function onClose(...)
            for k, v in pairs(mvTb) do
                if(v and v.stopAllActions)then
                    v:stopAllActions()
                end
            end
            layer:removeAllChildrenWithCleanup(true)
            layer:removeFromParentAndCleanup(true)
        end
        
        local okItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClose, nil, getlocal("fight_close"), 24 / 0.7)
        okItem:setScale(0.7)
        local okBtn = CCMenu:createWithItem(okItem)
        okBtn:setTouchPriority(-(layerNum) * 20 - 2)
        okBtn:setAnchorPoint(ccp(1, 0.5))
        okBtn:setPosition(ccp(G_VisibleSizeWidth / 2, 60))
        layer:addChild(okBtn, 11)
    end

    -- 装备的icon
    local mIcon = CCSprite:create("public/emblem/icon/emblemIcon_"..iconID..".png")
    if mIcon then
        mIcon:setScale(0)
        mIcon:setPosition(equipIconPos)
        layer:addChild(mIcon, 12)
        local ccScaleTo = CCScaleTo:create(0.6, 1.4)
        local callFunc3 = CCCallFuncN:create(callback31)
        local iconAcArr = CCArray:create()
        iconAcArr:addObject(ccScaleTo)
        iconAcArr:addObject(callFunc3)
        local seq = CCSequence:create(iconAcArr)
        mIcon:runAction(seq)
    end
end

function emblemUpgradeDialog:dispose()
    if(self.mvTb)then
        for k, v in pairs(self.mvTb) do
            if(v and v.stopAllActions)then
                v:stopAllActions()
            end
        end
    end
end
