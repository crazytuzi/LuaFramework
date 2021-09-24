acHuoxianmingjiangHeroInfoDialog = {}

function acHuoxianmingjiangHeroInfoDialog:new(hid, heroProductOrder, isSpicalUse)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.heroHid = hid
    self.heroProductOrder = heroProductOrder
    self.isSpicalUse = isSpicalUse--可特殊使用的参数
    return nc
end

function acHuoxianmingjiangHeroInfoDialog:init(bgSrc, layerNum, inRect, size, titleStr)
    -- base:setWait()
    self.layerNum = layerNum
    self.dialogLayer = CCLayer:create()
    
    local function tmpFunc()
        if self then
            self:close()
        end
    end
    local forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), tmpFunc)
    forbidBg:setContentSize(CCSizeMake(640, G_VisibleSizeHeight))
    forbidBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    
    forbidBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    forbidBg:setOpacity(200)
    self.dialogLayer:addChild(forbidBg)
    
    --采用新式小板子
    local function closeCallBack(...)
        self:close()
    end
    local dialogBg = G_getNewDialogBg(size, titleStr, 30, nil, layerNum, true, closeCallBack, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.bgSize = size
    
    -- 添加icon
    local showStar = true
    if self.isSpicalUse == "mjzx" then
        showStar = false
    end
    local heroIcon = heroVoApi:getHeroIcon(self.heroHid, self.heroProductOrder, showStar, nil, nil, nil, nil, {adjutants = {}})
    heroIcon:setPosition(ccp(115, size.height - 150))
    heroIcon:setScale(0.8)
    self.bgLayer:addChild(heroIcon)
    
    -- 添加nameLabel
    local heroName = GetTTFLabel(heroVoApi:getHeroName(self.heroHid), 30)
    heroName:setAnchorPoint(ccp(0, 0))
    heroName:setColor(heroVoApi:getHeroColor(self.heroProductOrder))
    heroName:setPosition(ccp(250, size.height - 150))
    self.bgLayer:addChild(heroName)
    
    -- 添加等级
    local heroLevel = GetTTFLabel(getlocal("scheduleChapter", {"Lv.1", tostring(heroCfg.heroLevel[self.heroProductOrder])}), 25)
    heroLevel:setAnchorPoint(ccp(0, 0))
    heroLevel:setPosition(ccp(250, size.height - 200))
    self.bgLayer:addChild(heroLevel)
    
    local function itemTouch()
        if G_checkClickEnable() == false then
            return
        end
        
        PlayEffect(audioCfg.mouseClick)
        
        local td = smallDialog:new()
        
        -- 获取hero描述lable的高度，动态的传给smallDialog
        local lable = GetTTFLabelWrap(heroVoApi:getHeroDes(self.heroHid), 25, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        
        local dialog = td:initHeroInfo("PanelPopup.png", CCSizeMake(500, 200 + lable:getContentSize().height + 25 + 60), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, {hid = self.heroHid, productOrder = self.heroProductOrder, level = 1}, 28, tabColor)
        sceneGame:addChild(dialog, self.layerNum + 1)
        
    end
    
    -- 添加英雄信息按钮
    local heroInfoItem = GetButtonItem("hero_infoBtn.png", "hero_infoBtn.png", "hero_infoBtn.png", itemTouch, nil, nil, nil)
    local menu = CCMenu:createWithItem(heroInfoItem)
    menu:setPosition(ccp(500, size.height - 160))
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(menu)
    
    local lineSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp1:setContentSize(CCSizeMake(size.width - 20, 2))
    lineSp1:setAnchorPoint(ccp(0, 0))
    lineSp1:setPosition(ccp(10, size.height - 240))
    self.bgLayer:addChild(lineSp1, 1)
    
    local lineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp2:setContentSize(CCSizeMake(size.width - 20, 2))
    lineSp2:setAnchorPoint(ccp(0, 0))
    lineSp2:setPosition(ccp(10, size.height - 395))
    self.bgLayer:addChild(lineSp2, 1)
    
    -- 添加技能
    local atb = self:getAddBuffTb(self.heroHid, self.heroProductOrder)
    local tb = {atk = {icon = "attributeARP.png", lb = {getlocal("dmg"), }},
        hlp = {icon = "attributeArmor.png", lb = {getlocal("hlp"), }},
        hit = {icon = "skill_01.png", lb = {getlocal("sample_skill_name_101"), }},
        eva = {icon = "skill_02.png", lb = {getlocal("sample_skill_name_102"), }},
        cri = {icon = "skill_03.png", lb = {getlocal("sample_skill_name_103"), }},
        res = {icon = "skill_04.png", lb = {getlocal("sample_skill_name_104"), }},
    }
    self.adTb = {}
    for k, v in pairs(heroListCfg[self.heroHid].heroAtt) do
        table.insert(self.adTb, k)
    end
    self.lbTb1 = {}
    for i = 1, SizeOfTable(heroListCfg[self.heroHid].heroAtt) do
        local attackSp = CCSprite:createWithSpriteFrameName(tb[self.adTb[i]].icon)
        local iconScale = 50 / attackSp:getContentSize().width
        attackSp:setAnchorPoint(ccp(0, 0.5))
        local width = i % 2
        local chanWidth = 230
        if width == 0 then
            width = 2
            chanWidth = chanWidth + 30
        end
        attackSp:setPosition(ccp(-170 + chanWidth * width, 30 + size.height - 230 - math.ceil(i / 2) * 75))
        self.bgLayer:addChild(attackSp, 2)
        attackSp:setScale(iconScale)
        
        local strLb1 = GetTTFLabel(tb[self.adTb[i]].lb[1], 40)
        strLb1:setAnchorPoint(ccp(0, 0.5))
        strLb1:setPosition(ccp(attackSp:getContentSize().width + 10, attackSp:getContentSize().height / 2))
        attackSp:addChild(strLb1)
        
        local strLb2 = GetTTFLabel("+"..atb[self.adTb[i]] .. "%", 40)
        strLb2:setAnchorPoint(ccp(0, 0.5))
        strLb2:setPosition(ccp(attackSp:getContentSize().width + 10 + strLb1:getContentSize().width + 5, attackSp:getContentSize().height / 2))
        attackSp:addChild(strLb2)
        self.lbTb1[i] = strLb2
    end
    self:initTableView()
    self.dialogLayer:addChild(self.bgLayer)
    return self.dialogLayer
end

function acHuoxianmingjiangHeroInfoDialog:initTableView()
    self.tvCellHeightTb = {}
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local height = 0;
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgLayer:getContentSize().width - 10, self.bgLayer:getContentSize().height - 430), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(30, 30))
    self.bgLayer:addChild(self.tv)
    
    self.tv:setMaxDisToBottomOrTop(120)
    
end

function acHuoxianmingjiangHeroInfoDialog:getSkillLb(idx)
    local nameFontSize, descFontSize = G_getLS(22, 20), G_getLS(20, 18)
    local textWidth = 350
    
    local sid = heroListCfg[self.heroHid].skills[idx + 1][1]
    local lvStr, sv, skillLv = self:getHeroSkillLvAndValue(self.heroHid, sid, self.heroProductOrder)
    local skdesc = heroVoApi:getSkillDesc(sid, sv)
    local nameLb = GetTTFLabelWrap(getlocal(heroSkillCfg[heroListCfg[self.heroHid].skills[idx + 1][1]].name) .. " "..lvStr, nameFontSize, CCSizeMake(textWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    local descLb = GetTTFLabelWrap(skdesc, descFontSize, CCSizeMake(textWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    
    nameLb:setAnchorPoint(ccp(0, 1))
    descLb:setAnchorPoint(ccp(0, 1))
    nameLb:setColor(G_ColorGreen)
    
    return {nameLb, descLb}
end

function acHuoxianmingjiangHeroInfoDialog:getCellSize(idx)
    if self.tvCellHeightTb[idx + 1] == nil then
        local height = 10
        local tb = self:getSkillLb(idx)
        for k, v in pairs(tb) do
            if v and tolua.cast(v, "CCLabelTTF") then
                height = height + v:getContentSize().height + 10
            end
        end
        if height < 120 then
            height = 120
        end
        self.tvCellHeightTb[idx + 1] = height
    end
    return CCSizeMake(400, self.tvCellHeightTb[idx + 1])
end

function acHuoxianmingjiangHeroInfoDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return SizeOfTable(heroListCfg[self.heroHid].skills)
    elseif fn == "tableCellSizeForIndex" then
        return self:getCellSize(idx)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd, fn, idx)
        end
        local hei = self:getCellSize(idx).height
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, hei))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0, 0));
        backSprie:setTag(1000 + idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(backSprie, 1)
        
        local sid = heroListCfg[self.heroHid].skills[idx + 1][1]
        local icon = CCSprite:create(heroVoApi:getSkillIconBySid(sid))
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPosition(ccp(10, backSprie:getContentSize().height / 2))
        backSprie:addChild(icon)
        
        local lbTB = self:getSkillLb(idx)
        local posY = hei - 10
        for k, v in pairs(lbTB) do
            local strLb = tolua.cast(v, "CCLabelTTF")
            if strLb then
                strLb:setPosition(140, posY)
                posY = posY - strLb:getContentSize().height - 10
                backSprie:addChild(strLb)
            end
        end
        
        if idx + 1 > self.heroProductOrder then
            
            local function touchLuaSpr(...)
            end
            local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr);
            touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
            local rect = CCSizeMake(backSprie:getContentSize().width, backSprie:getContentSize().height)
            touchDialogBg:setContentSize(rect)
            touchDialogBg:setOpacity(200)
            touchDialogBg:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(touchDialogBg, 4)
            
            local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(20, 20, 10, 10), function ()end)
            titleBg:setContentSize(CCSizeMake(120, 100))
            titleBg:setPosition(ccp(60, backSprie:getContentSize().height / 2))
            backSprie:addChild(titleBg)
            
            local numLabel = GetTTFLabel(tostring(idx + 1), 30)
            titleBg:addChild(numLabel)
            numLabel:setPosition(titleBg:getContentSize().width / 2 - 15, titleBg:getContentSize().height / 2 + 20)
            numLabel:setColor(G_ColorRed)
            
            local spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
            titleBg:addChild(spriteStar)
            spriteStar:setPosition(titleBg:getContentSize().width / 2 + 15, titleBg:getContentSize().height / 2 + 20)
            spriteStar:setScale(0.8)
            
            local unLockLb = 30
            if G_getCurChoseLanguage() == "ru" then
                unLockLb = unLockLb - 15
            end
            local lockLabel = GetTTFLabel(getlocal("activity_fbReward_unlock"), unLockLb)
            titleBg:addChild(lockLabel)
            lockLabel:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2 - 20)
            lockLabel:setColor(G_ColorRed)
            
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

function acHuoxianmingjiangHeroInfoDialog:getHeroSkillLvAndValue(hid, sid, productOrder)
    
    local skillsCfg = {}
    for k, v in pairs(heroListCfg[hid].skills) do
        if v[1] == sid then
            skillsCfg = v
            break
        end
    end
    local level = 0
    local lvStr = G_LV()..level.."/"..skillsCfg[2][productOrder]
    if level == 0 then
        level = 1
        lvStr = G_LV()..level
    end
    
    local value = 1 * heroSkillCfg[sid].attValuePerLv * 100
    local sv = value
    if heroSkillCfg[sid].attType == "antifirst" or heroSkillCfg[sid].attType == "first" then
        sv = value / 100
    end
    
    return lvStr, sv, level
end

function acHuoxianmingjiangHeroInfoDialog:getAddBuffTb(hid, productOrder)
    local tb = {}
    for k, v in pairs(heroListCfg[hid].heroAtt) do
        tb[k] = v[1] * productOrder + v[2] * 1
    end
    
    return tb
end

function acHuoxianmingjiangHeroInfoDialog:close()
    self.dialogLayer:removeFromParentAndCleanup(true)
    self.closeBtn = nil
    self.layerNum = nil
    self.dialogLayer = nil
    self.titleLabel = nil
    self.bgSize = nil
    self.bgLayer = nil
    self.heroHid = nil
    self.adTb = nil
    self.lbTb1 = nil
end
