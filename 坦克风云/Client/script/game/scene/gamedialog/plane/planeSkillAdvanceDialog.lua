--技能进阶面板
planeSkillAdvanceDialog = commonDialog:new()

function planeSkillAdvanceDialog:new()
    local nc = {}
    setmetatable(nc, self)
    nc.advanceFlag = false
    self.__index = self
    nc.selectedQuality = 1
    return nc
end

function planeSkillAdvanceDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, G_VisibleSizeHeight - 100))
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setPosition(G_VisibleSizeWidth / 2, 17)
    local posY = G_VisibleSizeHeight - 123
    local function onSelectQuality(object, fn, tag)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        if(tag)then
            if tag > 1000 then
                tag = tag - 1000
            end
            if(self.selectedQuality == tag)then
                do return end
            end
            self.selectedQuality = tag
            for k, v in pairs(self.qualityTabTb) do
                if(k ~= tag)then
                    v:setColor(G_ColorGray)
                    v:setScale(1)
                else
                    v:setColor(G_ColorWhite)
                    v:setScale(1.1)
                end
            end
            self.descLb:setString(getlocal("skill_advance_prompt", {getlocal("plane_skill_level_s" .. (self.selectedQuality + 1))}))
            if(tag == 1)then
                self.descLb:setColor(G_ColorGreen)
            elseif(tag == 2)then
                self.descLb:setColor(G_ColorBlue)
            elseif(tag == 3)then
                self.descLb:setColor(G_ColorPurple)
            else
                self.descLb:setColor(G_ColorOrange)
            end
            self:clearSelected()
            self:refreshProp()
        end
    end
    self.qualityTabTb = {}
    for i = 1, 4 do
        local tabBtn = LuaCCSprite:createWithSpriteFrameName("planeSkillTab"..i..".png", onSelectQuality)
        tabBtn:setTag(i)
        tabBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        tabBtn:setPosition(G_VisibleSizeWidth / 5 * i, posY)
        self.bgLayer:addChild(tabBtn, 1)
        if(i == self.selectedQuality)then
            tabBtn:setScale(1.1)
        else
            tabBtn:setColor(G_ColorGray)
        end
        self.qualityTabTb[i] = tabBtn
        
        local rect = CCSizeMake(90, 90)
        local addTouchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), onSelectQuality)
        addTouchBg:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        addTouchBg:setContentSize(rect)
        addTouchBg:setOpacity(0)
        addTouchBg:setTag(1000 + i)
        addTouchBg:setPosition(tabBtn:getPosition())
        self.bgLayer:addChild(addTouchBg)
    end
end

function planeSkillAdvanceDialog:doUserHandler()
    local strSize2 = 20
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" then
        strSize2 = 21
    end
    --外面框框
    local background = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png", CCRect(30, 30, 40, 40), function (...)end)
    background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, G_VisibleSizeHeight - 310))
    background:setAnchorPoint(ccp(0.5, 0))
    background:setPosition(G_VisibleSizeWidth / 2, 150)
    self.bgLayer:addChild(background)
    --优化像素
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    
    local adaptHeight = 495
    local adaptSize = 120
    local advanceBg = CCSprite:create("public/emblem/emblemAdvanceBg.jpg")
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("newblackgrayBg.png", CCRect(3, 3, 4, 4), function (...)end)
    
    --机型适配
    if G_getIphoneType() == G_iphoneX then
        adaptSize = 290
        adaptHeight = 630
        bottomBg:setContentSize(CCSizeMake(advanceBg:getContentSize().width, advanceBg:getContentSize().height + adaptSize))
        bottomBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - adaptHeight)
        self.bgLayer:addChild(bottomBg)
    elseif G_getIphoneType == G_iphone5 then
        adaptHeight = 595
        bottomBg:setContentSize(CCSizeMake(advanceBg:getContentSize().width, advanceBg:getContentSize().height + adaptSize))
        bottomBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - adaptHeight)
        self.bgLayer:addChild(bottomBg)
    end
    advanceBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - adaptHeight)
    self.bgLayer:addChild(advanceBg)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.posTb = {-- 装备框位置
        ccp(125, G_VisibleSizeHeight - 385), -- 1
        ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 288), -- 2
        ccp(515, G_VisibleSizeHeight - 385), -- 3
        ccp(515, G_VisibleSizeHeight - 605), -- 4
        ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 700), -- 5
        ccp(125, G_VisibleSizeHeight - 605), -- 6
        ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 495), -- 7
    }
    if G_getIphoneType() == G_iphoneX then
        self.posTb = {
            ccp(125, G_VisibleSizeHeight - 520), -- 1
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 370), -- 2
            ccp(515, G_VisibleSizeHeight - 520), -- 3
            ccp(515, G_VisibleSizeHeight - 750), -- 4
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 850), -- 5
            ccp(125, G_VisibleSizeHeight - 750), -- 6
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 620), -- 7
        }
    elseif(G_isIphone5())then
        self.posTb = {
            ccp(125, G_VisibleSizeHeight - 385), -- 1
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 288), -- 2
            ccp(515, G_VisibleSizeHeight - 385), -- 3
            ccp(515, G_VisibleSizeHeight - 625), -- 4
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 720), -- 5
            ccp(125, G_VisibleSizeHeight - 625), -- 6
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 505), -- 7
        }
    end
    self.selectedTb = {}
    self.selectBgTb = {}
    local function onClickSelect(object, fn, tag)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if(tag)then
            local index = tag - 100
            if(self.selectedTb[index]) or (index == 7 and self.advanceSid) then
                self:clearSelected(index)
            else
                local function callback(id)
                    self:addSkill(index, id)
                end
                if index == 7 then --弹出选择指定获得技能的页面
                    local skillList = planeGetCfg.upgrade.pool[self.selectedQuality + 1]
                    if skillList then
                        require "luascript/script/game/scene/gamedialog/plane/planeSmallDialog"
                        planeSmallDialog:showSkillAdvanceSelectDialog(skillList, self.layerNum + 1, callback)
                    end
                else
                    local usedList = {}
                    for k, sid in pairs(self.selectedTb) do
                        if(sid)then
                            if(usedList[sid])then
                                usedList[sid] = usedList[sid] + 1
                            else
                                usedList[sid] = 1
                            end
                        end
                    end
                    planeVoApi:showSkillSelectSmallDialog(self.selectedQuality, usedList, callback, self.layerNum + 1)
                end
            end
        end
    end
    for i = 1, 7 do
        local selectBg
        if(i ~= 7)then
            selectBg = LuaCCSprite:createWithSpriteFrameName("planeSkillGreenBg.png", onClickSelect)
            selectBg:setScale(0.8)
        else
            selectBg = LuaCCSprite:createWithSpriteFrameName("planeSkillGreenBg2.png", onClickSelect)
        end
        selectBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        selectBg:setTag(100 + i)
        selectBg:setPosition(self.posTb[i])
        self.bgLayer:addChild(selectBg)
        local addSp
        if(i ~= 7)then
            addSp = CCSprite:createWithSpriteFrameName("skillPlus.png")
            addSp:setPosition(selectBg:getContentSize().width / 2, selectBg:getContentSize().height / 2 + 30)
        else
            addSp = CCSprite:createWithSpriteFrameName("skillPlus.png")
            addSp:setPosition(selectBg:getContentSize().width / 2, selectBg:getContentSize().height / 2)
        end
        addSp:setTag(99)
        selectBg:addChild(addSp)
        local fade1 = CCFadeTo:create(0.8, 150)
        local fade2 = CCFadeTo:create(0.8, 255)
        local seq = CCSequence:createWithTwoActions(fade1, fade2)
        local repeatEver = CCRepeatForever:create(seq)
        addSp:runAction(repeatEver)
        local nameLb = GetTTFLabelWrap(getlocal("skill_select"), strSize2, CCSizeMake(158, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        nameLb:setTag(100)
        nameLb:setPosition(selectBg:getContentSize().width / 2, 50)
        selectBg:addChild(nameLb)
        if i == 7 then
            nameLb:setPositionY(-10)
        end
        self.selectBgTb[i] = selectBg
    end
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {}
        for i = 1, 6 do
            table.insert(tabStr, getlocal("planeSkill_advance_info_"..i))
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo, 11, nil, nil)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth - 85, G_VisibleSizeHeight - 215))
    infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoBtn)
    
    local scale = 0.8
    local function onAutoSelect()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:autoSelect()
    end
    local autoItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", onAutoSelect, 3, getlocal("emblem_btn_auto_input"), strSize2 / scale)
    autoItem:setScale(scale)
    local autoBtn = CCMenu:createWithItem(autoItem)
    autoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    autoBtn:setPosition(120, 200)
    self.bgLayer:addChild(autoBtn)
    local function onAutoCompose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:autoCompose()
    end
    local autoComposeItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", onAutoCompose, 3, getlocal("skill_btn_one_key"), strSize2 / scale)
    autoComposeItem:setScale(scale)
    local autoComposeBtn = CCMenu:createWithItem(autoComposeItem)
    autoComposeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    autoComposeBtn:setPosition(G_VisibleSizeWidth - 120, 200)
    self.bgLayer:addChild(autoComposeBtn)
    self.autoComposeItem = autoComposeItem
    
    self.descLb = GetTTFLabelWrap(getlocal("skill_advance_prompt", {getlocal("plane_skill_level_s" .. (self.selectedQuality + 1))}), strSize2, CCSizeMake(G_VisibleSizeWidth - 250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    self.descLb:setAnchorPoint(ccp(0, 0.5))
    self.descLb:setPosition(30, 65)
    self.bgLayer:addChild(self.descLb)
    
    self:refreshProp() --刷新融合消耗
    local function onCompose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:compose()
    end
    local composeItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", onCompose, 3, getlocal("merge_btn"), strSize2 / scale)
    composeItem:setScale(scale)
    local composeBtn = CCMenu:createWithItem(composeItem)
    composeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    composeBtn:setPosition(G_VisibleSizeWidth - 130, 65)
    self.bgLayer:addChild(composeBtn)
end

function planeSkillAdvanceDialog:clearSelected(index, isClearAdvanceSid)
    if(index == nil)then
        for k, v in pairs(self.selectBgTb) do
            if(k ~= 7 or (k == 7 and isClearAdvanceSid ~= false))then
                local addSp = tolua.cast(v:getChildByTag(99), "CCSprite")
                addSp:setVisible(true)
                local nameLb = tolua.cast(v:getChildByTag(100), "CCLabelTTF")
                nameLb:setString(getlocal("skill_select"))
                local skillIcon = v:getChildByTag(101)
                if(skillIcon)then
                    skillIcon = tolua.cast(skillIcon, "CCSprite")
                    skillIcon:removeFromParentAndCleanup(true)
                    skillIcon = nil
                end
            end
        end
        self.selectedTb = {}
        if isClearAdvanceSid ~= false then
            self.advanceSid = nil
            self:refreshAdvanceWayShow()
        end
    else
        local selectBg = self.selectBgTb[index]
        local addSp = tolua.cast(selectBg:getChildByTag(99), "CCSprite")
        addSp:setVisible(true)
        local nameLb = tolua.cast(selectBg:getChildByTag(100), "CCLabelTTF")
        nameLb:setString(getlocal("skill_select"))
        local skillIcon = selectBg:getChildByTag(101)
        if(skillIcon)then
            skillIcon = tolua.cast(skillIcon, "CCSprite")
            skillIcon:removeFromParentAndCleanup(true)
            skillIcon = nil
        end
        if index == 7 then
            self.advanceSid = nil
            self:refreshAdvanceWayShow()
        else
            self.selectedTb[index] = nil
        end
    end
end

function planeSkillAdvanceDialog:addSkill(index, sid)
    local bgSp = self.selectBgTb[index]
    local posY = 0
    if index == 7 then
        self.advanceSid = sid --选中的进阶获得的军徽id
        self:refreshAdvanceWayShow()
        posY = bgSp:getContentSize().height / 2
    else
        self.selectedTb[index] = sid
        posY = bgSp:getContentSize().height / 2 + 30
    end
    local function touchHandler()
    end
    local skillIcon = planeVoApi:getSkillIcon(sid, 135, touchHandler)
    skillIcon:setTag(101)
    skillIcon:setPosition(bgSp:getContentSize().width / 2, posY)
    bgSp:addChild(skillIcon)
    local addSp = tolua.cast(bgSp:getChildByTag(99), "CCSprite")
    addSp:setVisible(false)
    local nameStr, descStr = planeVoApi:getSkillInfoById(sid)
    local nameLb = tolua.cast(bgSp:getChildByTag(100), "CCLabelTTF")
    nameLb:setString(nameStr)
end

function planeSkillAdvanceDialog:refreshProp()
    if self.propIcon then
        self.propIcon:removeFromParentAndCleanup(true)
        self.propIcon = nil
    end
    local needProp, own, gemsCost = planeVoApi:getSkillAdvanceCost(self.selectedQuality)
    self.propIcon = CCSprite:createWithSpriteFrameName(needProp.pic)
    self.propIcon:setScale(60 / self.propIcon:getContentSize().width)
    self.propIcon:setPosition(G_VisibleSizeWidth - 160, 123)
    self.bgLayer:addChild(self.propIcon)
    if self.propLb == nil then
        self.propLb = GetTTFLabel(needProp.num, 23)
        self.propLb:setAnchorPoint(ccp(0, 0.5))
        self.propLb:setPosition(G_VisibleSizeWidth - 120, 123)
        self.bgLayer:addChild(self.propLb)
    end
    if(needProp.num > own)then
        self.propLb:setColor(G_ColorRed)
    else
        self.propLb:setColor(G_ColorWhite)
    end
    if self.specialCostLayer then
        self.specialCostLayer:removeFromParentAndCleanup(true)
        self.specialCostLayer = nil
    end
    if self.advanceSid then --有指定的获得技能，则要刷新选中升级需要消耗的道具
        local iconWidth = 80
        self.specialCostLayer = CCNode:create()
        self.specialCostLayer:setContentSize(CCSizeMake(500, iconWidth))
        local costCfg = planeGetCfg.upgrade.specialCost[self.selectedQuality + 1]
        if costCfg then
            local costTb = FormatItem(costCfg, nil, true)
            for k, v in pairs(costTb) do
                local ownNum = bagVoApi:getItemNumId(v.id)
                local function showPropInfo()
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, v)
                end
                local propSp = G_getItemIcon(v, 100, false, self.layerNum, showPropInfo)
                propSp:setScale(iconWidth / propSp:getContentSize().width)
                propSp:setPosition(30 + (2 * k - 1) * iconWidth / 2 + (k - 1) * 30, iconWidth / 2)
                propSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
                self.specialCostLayer:addChild(propSp)
                local numLb = GetTTFLabel("/"..tostring(v.num), 20)
                numLb:setAnchorPoint(ccp(0, 1))
                numLb:setPosition(propSp:getPositionX() + iconWidth / 2 + 5, propSp:getPositionY())
                self.specialCostLayer:addChild(numLb)
                local ownLb = GetTTFLabel(FormatNumber(ownNum), 20)
                ownLb:setAnchorPoint(ccp(0, 1))
                ownLb:setPosition(numLb:getPositionX() + numLb:getContentSize().width, numLb:getPositionY())
                self.specialCostLayer:addChild(ownLb)
                if ownNum < v.num then
                    numLb:setColor(G_ColorRed)
                end
                local lbWidth = numLb:getContentSize().width + ownLb:getContentSize().width
                ownLb:setPosition(propSp:getPositionX() - lbWidth / 2, propSp:getPositionY() - iconWidth / 2)
                numLb:setPosition(ownLb:getPositionX() + ownLb:getContentSize().width, ownLb:getPositionY())
            end
        end
        self.specialCostLayer:setAnchorPoint(ccp(0, 0))
        self.specialCostLayer:setPosition(20, 55)
        self.bgLayer:addChild(self.specialCostLayer)
    end
end

--选中获得进阶指定技能的话，不支持自动进阶
function planeSkillAdvanceDialog:refreshAdvanceWayShow()
    if self.advanceSid == nil then
        self.autoComposeItem:setEnabled(true)
        self.descLb:setVisible(true)
    else
        self.autoComposeItem:setEnabled(false)
        self.descLb:setVisible(false)
    end
    self:refreshProp()
end

function planeSkillAdvanceDialog:checkAllSelected()
    for i = 1, 6 do
        if(self.selectedTb[i] == nil)then
            return false
        end
    end
    return true
end

function planeSkillAdvanceDialog:autoSelect()
    self:clearSelected(nil, false)
    local idList = {}
    local tmpList = {}
    local num = 0
    local slist = planeVoApi:getSkillList()
    for k, v in pairs(slist) do
        if(v.gcfg.color == self.selectedQuality and (v.gcfg.lv == nil or v.gcfg.lv == 0))then
            if(v.num > 1)then
                for i = 1, v.num - 1 do
                    table.insert(idList, v.sid)
                    num = num + 1
                    if(num >= 6)then
                        break
                    end
                end
                table.insert(tmpList, v.sid)
            elseif(v.num == 1)then
                table.insert(tmpList, v.sid)
            end
            if(num >= 6)then
                break
            end
        end
    end
    if(num < 6)then
        for k, v in pairs(tmpList) do
            table.insert(idList, v)
            num = num + 1
            if(num >= 6)then
                break
            end
        end
    end
    for k, v in pairs(idList) do
        self:addSkill(k, v)
    end
    if(num < 6)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("skill_advance_not_enough"), 30)
    end
end

function planeSkillAdvanceDialog:compose()
    if(self:checkAllSelected() == false)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("skill_advance_null_prompt"), 30)
        do return end
    end
    local function callback(award)
        self.advanceFlag = true
        self.oldSelectedTb = {}
        for index, id in pairs(self.selectedTb) do
            self.oldSelectedTb[index] = id
        end
        self:clearSelected()
        self:refreshProp()
        self:showAward(award)
    end
    local needProp, own, gemsCost = planeVoApi:getSkillAdvanceCost(self.selectedQuality)
    local skillList = {}
    for k, id in pairs(self.selectedTb) do
        if(skillList[id])then
            skillList[id] = skillList[id] + 1
        else
            skillList[id] = 1
        end
    end
    local advancePosIdx, specialCostTb
    if self.advanceSid then --如果要进阶为指定技能的话需要消耗特殊道具
        local costCfg = planeGetCfg.upgrade.specialCost[self.selectedQuality + 1]
        if costCfg then
            specialCostTb = FormatItem(costCfg, nil, true)
            for k, v in pairs(specialCostTb) do
                local num = bagVoApi:getItemNumId(v.id)
                if num < v.num then
                    gemsCost = gemsCost + propCfg[v.key].gemCost * (v.num - num)
                    v.num = num
                end
            end
        end
        local pool = planeGetCfg.upgrade.pool[self.selectedQuality + 1] or {}
        for k, v in pairs(pool) do
            if v == self.advanceSid then
                advancePosIdx = k
                do break end
            end
        end
    end
    if(gemsCost > 0)then
        local function onConfirm()
            if(playerVoApi:getGems() < gemsCost)then
                GemsNotEnoughDialog(nil, nil, gemsCost - playerVoApi:getGems(), self.layerNum + 1, gemsCost)
                do return end
            end
            planeVoApi:compose(skillList, gemsCost, callback, advancePosIdx, specialCostTb)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("skill_merge_no_prop", {gemsCost}), nil, self.layerNum + 1)
    else
        planeVoApi:compose(skillList, gemsCost, callback, advancePosIdx, specialCostTb)
    end
end

function planeSkillAdvanceDialog:autoCompose()
    local idList = {}
    local tmpList = {}
    local num = 0
    local slist = planeVoApi:getSkillList()
    for k, v in pairs(slist) do
        if(v.gcfg.color == self.selectedQuality and (v.gcfg.lv == nil or v.gcfg.lv == 0))then
            if(v.num > 1)then
                for i = 1, v.num - 1 do
                    table.insert(idList, v.sid)
                    num = num + 1
                end
                table.insert(tmpList, v.sid)
            elseif(v.num == 1)then
                table.insert(tmpList, v.sid)
            end
        end
    end
    local tmpNum = #tmpList
    if(num + tmpNum < 6)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("skill_advance_not_enough"), 30)
        do return end
    end
    local mod
    local composeNum = math.floor((num + tmpNum) / 6)
    local costProp, havePropNum = planeVoApi:getSkillAdvanceCost(self.selectedQuality)
    local pcomNum = math.floor(havePropNum / costProp.num) --道具数量计算出的可融合次数
    if pcomNum == 0 then --道具数量不足融合的情况则走原先花费金币融合的逻辑
        mod = (num + tmpNum) % 6
    else
        composeNum = math.min(composeNum, pcomNum)
        mod = num + tmpNum - composeNum * 6
    end
    if(mod ~= 0)then
        for i = 1, mod do
            if(#tmpList == 0)then
                table.remove(idList, #idList)
            else
                table.remove(tmpList, #tmpList)
            end
        end
    end
    if(#tmpList > 0)then
        for k, v in pairs(tmpList) do
            table.insert(idList, v)
        end
    end
    local skillList = {}
    for k, sid in pairs(idList) do
        if(skillList[sid])then
            skillList[sid] = skillList[sid] + 1
        else
            skillList[sid] = 1
        end
    end
    local function onConfirmAuto()
        local function callback(award)
            self.advanceFlag = true
            G_showRewardTip(award, true)
            self:clearSelected()
            self:refreshProp()
        end
        local composeCost = composeNum * costProp.num
        if(havePropNum < composeCost)then
            local perCost = propCfg[costProp.key].gemCost or 0
            local gemsCost = perCost * (composeCost - havePropNum)
            local function onConfirm()
                if(playerVoApi:getGems() < gemsCost)then
                    GemsNotEnoughDialog(nil, nil, gemsCost - playerVoApi:getGems(), self.layerNum + 1, gemsCost)
                    do return end
                end
                planeVoApi:compose(skillList, gemsCost, callback)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("skill_merge_no_prop", {gemsCost}), nil, self.layerNum + 1)
        else
            planeVoApi:compose(skillList, 0, callback)
        end
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirmAuto, getlocal("dialog_title_prompt"), getlocal("skill_one_key_promp", {composeNum, getlocal("plane_skill_level_s" .. (self.selectedQuality + 1)), composeNum * costProp.num, costProp.name}), nil, self.layerNum + 1)
end

function planeSkillAdvanceDialog:showAward(award)
    if(self.awardLayer)then
        do return end
    end
    local layerNum = self.layerNum + 1
    self.awardLayer = CCLayer:create()
    self.bgLayer:addChild(self.awardLayer, 9)
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function ()end)
    bgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    bgSp:setOpacity(0)
    bgSp:setAnchorPoint(ccp(0, 0))
    bgSp:setPosition(ccp(0, 0))
    bgSp:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.awardLayer:addChild(bgSp)
    local rewardSkill = award[1]
    local skillId = rewardSkill.key
    if(skillId == nil)then
        self.awardLayer:removeFromParentAndCleanup(true)
        self.awardLayer = nil
        do return end
    end
    local skillVo = planeVoApi:getSkillVoById(skillId)
    if(skillVo == nil)then
        self.awardLayer:removeFromParentAndCleanup(true)
        self.awardLayer = nil
        do return end
    end
    for k, v in pairs(self.oldSelectedTb) do
        local function nilFunc()
        end
        local skillIcon = planeVoApi:getSkillIcon(v, 100, nilFunc)
        skillIcon:setPosition(self.posTb[k].x, self.posTb[k].y + 15)
        self.awardLayer:addChild(skillIcon)
        local delay = CCDelayTime:create(0.5)
        local moveTo = CCMoveTo:create(1, self.posTb[7])
        local function removeFunc()
            skillIcon:removeFromParentAndCleanup(true)
        end
        local removeFunc = CCCallFunc:create(removeFunc)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(moveTo)
        acArr:addObject(removeFunc)
        local seq = CCSequence:create(acArr)
        skillIcon:runAction(seq)
    end
    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance1.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(self.posTb[7])
        self.awardLayer:addChild(particleS, 10)
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance2.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(self.posTb[7])
        self.awardLayer:addChild(particleS, 11)
    end
    
    local function callback4()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance3.plist")
        particleS:setScale(2.5)
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(self.posTb[7])
        self.awardLayer:addChild(particleS, 13)
    end
    
    local function callback2()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGet"..skillVo.gcfg.color..".plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(self.posTb[7])
        self.awardLayer:addChild(particleS, 12)
    end
    local callFunc1 = CCCallFunc:create(callback1)
    local callFunc2 = CCCallFunc:create(callback2)
    local delay2 = CCDelayTime:create(1.5)
    local acArr = CCArray:create()
    local function callback3()
        local titleBg = CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
        titleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 120)
        self.awardLayer:addChild(titleBg)
        
        local promptStr
        if skillVo.num == 1 then
            promptStr = getlocal("skill_getNewSkillDesc")
        else
            promptStr = getlocal("skill_advance_success")
        end
        local lb = GetTTFLabel(promptStr, 32)
        lb:setPosition(getCenterPoint(titleBg))
        titleBg:addChild(lb)
        local function callback31()
            local function onClose(...)
                self.awardLayer:removeAllChildrenWithCleanup(true)
                self.awardLayer:removeFromParentAndCleanup(true)
                self.awardLayer = nil
            end
            local okItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", onClose, nil, getlocal("confirm"), 25)
            local okBtn = CCMenu:createWithItem(okItem)
            okBtn:setTouchPriority(-(layerNum - 1) * 20 - 5)
            okBtn:setAnchorPoint(ccp(0.5, 0.5))
            okBtn:setPosition(ccp(G_VisibleSizeWidth / 2, 150))
            self.awardLayer:addChild(okBtn, 11)
        end
        
        local function showItemInfo(tag)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            planeVoApi:showInfoDialog(skillVo, layerNum + 1)
        end
        local mIcon = planeVoApi:getSkillIcon(skillId, 100, showItemInfo, nil, 3)
        if mIcon then
            mIcon:setTouchPriority(-(layerNum - 1) * 20 - 5)
            mIcon:setScale(0)
            mIcon:setPosition(self.posTb[7])
            self.awardLayer:addChild(mIcon, 15)
            -- 动画
            local callback4 = CCCallFunc:create(callback4)
            local ccScaleTo = CCScaleTo:create(0.3, 1.3)
            local callFunc3 = CCCallFuncN:create(callback31)
            local delayTime = CCDelayTime:create(0.5)
            local iconAcArr = CCArray:create()
            iconAcArr:addObject(callback4)
            iconAcArr:addObject(delayTime)
            iconAcArr:addObject(ccScaleTo)
            iconAcArr:addObject(callFunc3)
            local seq = CCSequence:create(iconAcArr)
            mIcon:runAction(seq)
        end
    end
    local callFunc3 = CCCallFunc:create(callback3)
    local opacityAc = CCFadeTo:create(0.7, 150)
    acArr:addObject(callFunc1)
    acArr:addObject(delay2)
    acArr:addObject(opacityAc)
    acArr:addObject(callFunc2)
    acArr:addObject(callFunc3)
    local delay3 = CCDelayTime:create(1)
    acArr:addObject(delay3)
    local seq = CCSequence:create(acArr)
    bgSp:runAction(seq)
end

function planeSkillAdvanceDialog:dispose()
    if self.advanceFlag == true then
        eventDispatcher:dispatchEvent("plane.skillbag.refresh")
        self.advanceFlag = false
    end
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemAdvanceBg.jpg")
end
