--军徽进阶面板
emblemAdvanceDialog = commonDialog:new()

function emblemAdvanceDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    nc.selectedQuality = 1
    return nc
end

function emblemAdvanceDialog:resetTab()
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
            self.descLb:setString(getlocal("emblem_advance_prompt", {getlocal("emblem_tab_title_" .. (self.selectedQuality + 1))}))
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
        local tabBtn = LuaCCSprite:createWithSpriteFrameName("emblemQ"..i..".png", onSelectQuality)
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
    end
end

function emblemAdvanceDialog:doUserHandler()
    local strSize2 = 20
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" then
        strSize2 = 24
    end
    local background = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png", CCRect(30, 30, 40, 40), function (...)end)
    background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, G_VisibleSizeHeight - 310))
    background:setAnchorPoint(ccp(0.5, 0))
    background:setPosition(G_VisibleSizeWidth / 2, 150)
    self.bgLayer:addChild(background)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 100
    end
    local advanceBg = CCSprite:create("public/emblem/emblemAdvanceBg.jpg")
    advanceBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 495 - adaH)
    self.bgLayer:addChild(advanceBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    if G_getIphoneType() == G_iphoneX then
        self.posTb = {
            ccp(125, G_VisibleSizeHeight - 385 - adaH), -- 1
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 288 - adaH), -- 2
            ccp(515, G_VisibleSizeHeight - 385 - adaH), -- 3
            ccp(515, G_VisibleSizeHeight - 625 - adaH), -- 4
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 720 - adaH), -- 5
            ccp(125, G_VisibleSizeHeight - 625 - adaH), -- 6
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 505 - adaH), -- 7
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
    else
        self.posTb = {-- 装备框位置
            ccp(125, G_VisibleSizeHeight - 385), -- 1
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 288), -- 2
            ccp(515, G_VisibleSizeHeight - 385), -- 3
            ccp(515, G_VisibleSizeHeight - 605), -- 4
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 700), -- 5
            ccp(125, G_VisibleSizeHeight - 605), -- 6
            ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 495), -- 7
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
        if(tag)then
            local index = tag - 100
            if(self.selectedTb[index]) or (index == 7 and self.advanceEid) then
                self:clearSelected(index)
            else
                local function callback(id)
                    self:addEmblem(index, id)
                end
                if index == 7 then
                    local emblemList = emblemCfg.equipAdvance.pool[self.selectedQuality + 1]
                    if emblemList then --可进阶的军徽列表
                        require "luascript/script/game/scene/gamedialog/emblem/emblemSmallDialog"
                        emblemSmallDialog:showAdvanceSelectDialog(emblemList, self.layerNum + 1, callback)
                    end
                else
                    local usedList = {}
                    for k, id in pairs(self.selectedTb) do
                        if(id)then
                            if(usedList[id])then
                                usedList[id] = usedList[id] + 1
                            else
                                usedList[id] = 1
                            end
                        end
                    end
                    local troopList = {}
                    if emblemTroopVoApi:checkIfEmblemTroopIsOpen() == true then
                        troopList = G_clone(emblemTroopVoApi:getEmblemTroopList()) --当前玩家军徽部队列表
                    end
                    for k, v in pairs(troopList) do --处理除镜像以外的军徽
                        for kidx, posEquipId in pairs(v.posTb) do
                            if posEquipId and posEquipId ~= "0" then
                                usedList[posEquipId] = (usedList[posEquipId] or 0) + 1 --军徽部队装配的军徽也加入到占用列表中
                            end
                        end
                    end
                    emblemVoApi:showSelectEmblemDialog(self.selectedQuality, 1, self.layerNum + 1, callback, usedList)
                end
            end
        end
    end
    for i = 1, 7 do
        local selectBg, addIcon
        if(i ~= 7)then
            selectBg = LuaCCSprite:createWithSpriteFrameName("emblemGreenBg2.png", onClickSelect)
        else
            selectBg = LuaCCSprite:createWithSpriteFrameName("emblemGreenBg1.png", onClickSelect)
        end
        selectBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        selectBg:setTag(100 + i)
        selectBg:setPosition(self.posTb[i])
        self.bgLayer:addChild(selectBg)
        if(i ~= 7)then
            addIcon = CCSprite:createWithSpriteFrameName("emblemPlus.png")
        else
            addIcon = CCSprite:createWithSpriteFrameName("emblemUnknown.png")
            local fade1 = CCFadeTo:create(0.8, 55)
            local fade2 = CCFadeTo:create(0.8, 255)
            local repeatEver = CCRepeatForever:create(CCSequence:createWithTwoActions(fade1, fade2))
            addIcon:runAction(repeatEver)
        end
        addIcon:setTag(99)
        addIcon:setPosition(selectBg:getContentSize().width / 2, selectBg:getContentSize().height / 2)
        selectBg:addChild(addIcon)
        local nameLb = GetTTFLabelWrap(getlocal("emblem_select"), 20, CCSizeMake(180, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        nameLb:setTag(100)
        nameLb:setPosition(selectBg:getContentSize().width / 2, 30)
        selectBg:addChild(nameLb)
        self.selectBgTb[i] = selectBg
    end
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {"\n", getlocal("emblem_advance_info_6"), "\n", getlocal("emblem_advance_info_5"), "\n", getlocal("emblem_advance_info_4"), "\n", getlocal("emblem_advance_info_3"), "\n", getlocal("emblem_advance_info_2"), "\n", getlocal("emblem_advance_info_1"), "\n"}
        local tabColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}
        local td = smallDialog:new()
        local dialog = td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, true, true, self.layerNum + 1, tabStr, 25, tabColor)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo, 11, nil, nil)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth - 85, G_VisibleSizeHeight - 215))
    infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoBtn)
    
    local tempBtnScale = 0.7
    local function onAutoSelect()
        self:autoSelect()
    end
    local autoItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onAutoSelect, 3, getlocal("emblem_btn_auto_input"), strSize2 / tempBtnScale)
    autoItem:setScale(tempBtnScale)
    local autoBtn = CCMenu:createWithItem(autoItem)
    autoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    autoBtn:setPosition(120, 200)
    self.bgLayer:addChild(autoBtn)
    local function onAutoCompose()
        self:autoCompose()
    end
    local autoComposeItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onAutoCompose, 3, getlocal("emblem_btn_one_key"), strSize2 / tempBtnScale)
    autoComposeItem:setScale(tempBtnScale)
    local autoComposeBtn = CCMenu:createWithItem(autoComposeItem)
    autoComposeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    autoComposeBtn:setPosition(G_VisibleSizeWidth - 120, 200)
    self.bgLayer:addChild(autoComposeBtn)
    self.autoComposeItem = autoComposeItem
    
    self.descLb = GetTTFLabelWrap(getlocal("emblem_advance_prompt", {getlocal("emblem_tab_title_" .. (self.selectedQuality + 1))}), 20, CCSizeMake(G_VisibleSizeWidth - 250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    self.descLb:setAnchorPoint(ccp(0, 0.5))
    self.descLb:setPosition(30, 65)
    self.bgLayer:addChild(self.descLb)
    
    local needProp = emblemCfg.equipAdvance.prop[self.selectedQuality]
    needProp = FormatItem(needProp)[1]
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    self.propIcon = CCSprite:createWithSpriteFrameName(propCfg["p"..propID].icon)
    self.propIcon:setScale(60 / self.propIcon:getContentSize().width)
    self.propIcon:setPosition(G_VisibleSizeWidth - 160, 130)
    self.bgLayer:addChild(self.propIcon)
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    self.propLb = GetTTFLabel("1", 23)
    if(bagVoApi:getItemNumId(propID) < 1)then
        self.propLb:setColor(G_ColorRed)
    else
        self.propLb:setColor(G_ColorWhite)
    end
    self.propLb:setAnchorPoint(ccp(0, 0.5))
    self.propLb:setPosition(G_VisibleSizeWidth - 120, 130)
    self.bgLayer:addChild(self.propLb)
    local function onCompose()
        self:compose()
    end
    local composeItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onCompose, 3, getlocal("super_weapon_lvUp"), strSize2 / tempBtnScale)
    composeItem:setScale(tempBtnScale)
    local composeBtn = CCMenu:createWithItem(composeItem)
    composeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    composeBtn:setPosition(G_VisibleSizeWidth - 130, 65)
    self.bgLayer:addChild(composeBtn)
end

function emblemAdvanceDialog:clearSelected(index, isClearAdvanceEid)
    if(index == nil)then
        for k, v in pairs(self.selectBgTb) do
            if v and tolua.cast(v, "CCSprite") then
                if (k == 7 and isClearAdvanceEid ~= false) or k ~= 7 then
                    local addIcon = tolua.cast(v:getChildByTag(99), "CCSprite")
                    addIcon:setVisible(true)
                    local nameLb = tolua.cast(v:getChildByTag(100), "CCLabelTTF")
                    nameLb:setString(getlocal("emblem_select"))
                    local emblemIcon = v:getChildByTag(101)
                    if(emblemIcon)then
                        emblemIcon = tolua.cast(emblemIcon, "CCSprite")
                        emblemIcon:removeFromParentAndCleanup(true)
                    end
                end
            end
        end
        self.selectedTb = {}
        if isClearAdvanceEid ~= false then
            self.advanceEid = nil
            self:refreshAdvanceWayShow()
        end
    else
        local selectBg = self.selectBgTb[index]
        if selectBg and tolua.cast(selectBg, "CCSprite") then
            local addIcon = tolua.cast(selectBg:getChildByTag(99), "CCSprite")
            addIcon:setVisible(true)
            local nameLb = tolua.cast(selectBg:getChildByTag(100), "CCLabelTTF")
            nameLb:setString(getlocal("emblem_select"))
            local emblemIcon = selectBg:getChildByTag(101)
            if(emblemIcon)then
                emblemIcon = tolua.cast(emblemIcon, "CCSprite")
                emblemIcon:removeFromParentAndCleanup(true)
            end
        end
        if index == 7 then
            self.advanceEid = nil
            self:refreshAdvanceWayShow()
        else
            self.selectedTb[index] = nil
        end
    end
end

function emblemAdvanceDialog:addEmblem(index, id)
    if index == 7 then
        self.advanceEid = id --选中的进阶获得的军徽id
        self:refreshAdvanceWayShow()
    else
        self.selectedTb[index] = id
    end
    local emblemIcon = emblemVoApi:getEquipIconNoBg(id, nil, 130)
    emblemIcon:setTag(101)
    local bgSp = self.selectBgTb[index]
    emblemIcon:setPosition(bgSp:getContentSize().width / 2, bgSp:getContentSize().height / 2 + 15)
    bgSp:addChild(emblemIcon)
    local addIcon = tolua.cast(bgSp:getChildByTag(99), "CCSprite")
    addIcon:setVisible(false)
    local nameLb = tolua.cast(bgSp:getChildByTag(100), "CCLabelTTF")
    nameLb:setString(emblemVoApi:getEquipName(id))
end

function emblemAdvanceDialog:refreshProp()
    self.propIcon:removeFromParentAndCleanup(true)
    local needProp = emblemCfg.equipAdvance.prop[self.selectedQuality]
    needProp = FormatItem(needProp)[1]
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    self.propIcon = CCSprite:createWithSpriteFrameName(propCfg["p"..propID].icon)
    self.propIcon:setScale(60 / self.propIcon:getContentSize().width)
    self.propIcon:setPosition(G_VisibleSizeWidth - 160, 130)
    self.bgLayer:addChild(self.propIcon)
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    if(bagVoApi:getItemNumId(propID) < 1)then
        self.propLb:setColor(G_ColorRed)
    else
        self.propLb:setColor(G_ColorWhite)
    end
    if self.specialCostLayer then
        self.specialCostLayer:removeFromParentAndCleanup(true)
        self.specialCostLayer = nil
    end
    if self.advanceEid then --有选中的进阶军徽，则要刷新选中进阶需要消耗的道具
        local iconWidth = 80
        self.specialCostLayer = CCNode:create()
        self.specialCostLayer:setContentSize(CCSizeMake(500, iconWidth))
        local costCfg = emblemCfg.equipAdvance.specialCost[self.selectedQuality + 1]
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
                self.specialCostLayer:addChild(numLb)
                local ownLb = GetTTFLabel(FormatNumber(ownNum), 20)
                ownLb:setAnchorPoint(ccp(0, 1))
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

--选中获得进阶指定军徽的话，不支持自动进阶
function emblemAdvanceDialog:refreshAdvanceWayShow()
    if self.advanceEid == nil then
        self.autoComposeItem:setEnabled(true)
        self.descLb:setVisible(true)
    else
        self.autoComposeItem:setEnabled(false)
        self.descLb:setVisible(false)
    end
    self:refreshProp()
end

function emblemAdvanceDialog:checkAllSelected()
    for i = 1, 6 do
        if(self.selectedTb[i] == nil)then
            return false
        end
    end
    return true
end

function emblemAdvanceDialog:autoSelect()
    self:clearSelected(nil, false)
    local idList = {}
    local tmpList = {}
    local num = 0
    for k, v in pairs(emblemVoApi:getEquipList()) do
        if(v.cfg.color == self.selectedQuality and (v.cfg.lv == nil or v.cfg.lv == 0))then
            local usableNum = v:getUsableNum()
            -- print("v.id,usableNum===>",v.id,usableNum)
            if(usableNum > 1)then
                for i = 1, usableNum - 1 do
                    table.insert(idList, v.id)
                    num = num + 1
                    if(num >= 6)then
                        break
                    end
                end
                table.insert(tmpList, v.id)
            elseif(usableNum == 1)then
                table.insert(tmpList, v.id)
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
        self:addEmblem(k, v)
    end
    if(num < 6)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_advance_not_enough"), 30)
    end
end

function emblemAdvanceDialog:compose()
    if(self:checkAllSelected() == false)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_advance_null_prompt"), 30)
        do return end
    end
    local function callback(award)
        self.oldSelectedTb = {}
        for index, id in pairs(self.selectedTb) do
            self.oldSelectedTb[index] = id
        end
        self:clearSelected()
        self:refreshProp()
        self:showAward(award)
    end
    local needProp = emblemCfg.equipAdvance.prop[self.selectedQuality]
    needProp = FormatItem(needProp)[1]
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    local ownNum = bagVoApi:getItemNumId(propID)
    local emblemList = {}
    for k, id in pairs(self.selectedTb) do
        if(emblemList[id])then
            emblemList[id] = emblemList[id] + 1
        else
            emblemList[id] = 1
        end
    end
    local specialCostGems, advancePosIdx, specialCostTb = 0, nil, nil
    if self.advanceEid then --如果要进阶为指定军徽的话需要消耗特殊道具
        local costCfg = emblemCfg.equipAdvance.specialCost[self.selectedQuality + 1]
        if costCfg then
            specialCostTb = FormatItem(costCfg, nil, true)
            for k, v in pairs(specialCostTb) do
                local num = bagVoApi:getItemNumId(v.id)
                if num < v.num then
                    specialCostGems = specialCostGems + propCfg[v.key].gemCost * (v.num - num)
                    v.num = num
                end
            end
        end
        local emblemList = emblemCfg.equipAdvance.pool[self.selectedQuality + 1] or {}
        for k, v in pairs(emblemList) do
            if v == self.advanceEid then
                advancePosIdx = k
                do break end
            end
        end
    end
    
    if(ownNum < 1 or specialCostGems > 0)then
        local goldCost = propCfg[needProp.key].gemCost + specialCostGems
        local function onConfirm()
            if(playerVoApi:getGems() < goldCost)then
                GemsNotEnoughDialog(nil, nil, goldCost - playerVoApi:getGems(), self.layerNum + 1, goldCost)
                do return end
            end
            emblemVoApi:compose(emblemList, goldCost, callback, advancePosIdx, specialCostTb)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("emblem_upgrade_no_prop", {goldCost}), nil, self.layerNum + 1)
    else
        emblemVoApi:compose(emblemList, 0, callback, advancePosIdx, specialCostTb)
    end
end

function emblemAdvanceDialog:autoCompose()
    local idList = {}
    local tmpList = {}
    local num = 0
    for k, v in pairs(emblemVoApi:getEquipList()) do
        if(v.cfg.color == self.selectedQuality and (v.cfg.lv == nil or v.cfg.lv == 0))then
            local usableNum = v:getUsableNum()
            if(usableNum > 1)then
                for i = 1, usableNum - 1 do
                    table.insert(idList, v.id)
                    num = num + 1
                end
                table.insert(tmpList, v.id)
            elseif(usableNum == 1)then
                table.insert(tmpList, v.id)
            end
        end
    end
    local tmpNum = #tmpList
    if(num + tmpNum < 6)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_advance_not_enough"), 30)
        do return end
    end
    local mod
    local composeNum = math.floor((num + tmpNum) / 6)
    local needProp = emblemCfg.equipAdvance.prop[self.selectedQuality]
    needProp = FormatItem(needProp)[1]
    local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
    local ownNum = bagVoApi:getItemNumId(propID)
    local pcomNum = math.floor(ownNum / needProp.num) --道具数量计算出的可进阶次数
    if pcomNum == 0 then --道具数量不足进阶的情况则走原先花费金币进阶的逻辑
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
    local emblemList = {}
    for k, id in pairs(idList) do
        if(emblemList[id])then
            emblemList[id] = emblemList[id] + 1
        else
            emblemList[id] = 1
        end
    end
    local function onConfirmAuto()
        local function callback(award)
            G_showRewardTip(award, true)
            self:clearSelected()
            self:refreshProp()
        end
        local composeCost = composeNum * needProp.num
        if(ownNum < composeCost)then
            local goldCost = propCfg[needProp.key].gemCost * (composeCost - ownNum)
            local function onConfirm()
                if(playerVoApi:getGems() < goldCost)then
                    GemsNotEnoughDialog(nil, nil, goldCost - playerVoApi:getGems(), self.layerNum + 1, goldCost)
                    do return end
                end
                emblemVoApi:compose(emblemList, goldCost, callback)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("emblem_upgrade_no_prop", {goldCost}), nil, self.layerNum + 1)
        else
            emblemVoApi:compose(emblemList, 0, callback)
        end
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirmAuto, getlocal("dialog_title_prompt"), getlocal("emblem_one_key_promp", {composeNum, getlocal("emblem_tab_title_" .. (self.selectedQuality + 1)), composeNum * needProp.num, needProp.name}), nil, self.layerNum + 1)
end

function emblemAdvanceDialog:showAward(award)
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
    local awardEmblem = award[1]
    local emblemID = awardEmblem.key
    if(emblemID == nil)then
        self.awardLayer:removeFromParentAndCleanup(true)
        self.awardLayer = nil
        do return end
    end
    local eVo = emblemVoApi:getEquipVoByID(emblemID)
    if(eVo == nil)then
        self.awardLayer:removeFromParentAndCleanup(true)
        self.awardLayer = nil
        do return end
    end
    for k, v in pairs(self.oldSelectedTb) do
        local emblemIcon = emblemVoApi:getEquipIconNoBg(v, nil, 130)
        emblemIcon:setPosition(self.posTb[k].x, self.posTb[k].y + 15)
        self.awardLayer:addChild(emblemIcon)
        local delay = CCDelayTime:create(0.5)
        local moveTo = CCMoveTo:create(1, self.posTb[7])
        local function removeFunc()
            emblemIcon:removeFromParentAndCleanup(true)
        end
        local removeFunc = CCCallFunc:create(removeFunc)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(moveTo)
        acArr:addObject(removeFunc)
        local seq = CCSequence:create(acArr)
        emblemIcon:runAction(seq)
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
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGet"..eVo.cfg.color..".plist")
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
        if eVo.num == 1 then
            promptStr = getlocal("emblem_getNewEquipDesc")
        else
            promptStr = getlocal("emblem_advance_success")
        end
        local lb = GetTTFLabel(promptStr, 24, true)
        lb:setPosition(getCenterPoint(titleBg))
        titleBg:addChild(lb)
        local function callback31()
            local function onClose(...)
                self.awardLayer:removeAllChildrenWithCleanup(true)
                self.awardLayer:removeFromParentAndCleanup(true)
                self.awardLayer = nil
            end
            local okItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClose, nil, getlocal("confirm"), 24 / 0.7)
            okItem:setScale(0.7)
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
            emblemVoApi:showInfoDialog(eVo, layerNum + 1)
        end
        local mIcon = emblemVoApi:getEquipIconNoBg(emblemID, 24, nil, showItemInfo)
        if mIcon then
            mIcon:setTouchPriority(-(layerNum - 1) * 20 - 5)
            mIcon:setScale(0)
            mIcon:setPosition(self.posTb[7])
            self.awardLayer:addChild(mIcon, 15)
            -- 名称
            local nameLb = tolua.cast(mIcon:getChildByTag(1), "CCLabelTTF")
            if nameLb then
                nameLb:setPosition(ccp(nameLb:getPositionX(), nameLb:getPositionY() - 35))
            end
            -- 星星
            local starSp
            for k = 1, 5 do
                starSp = tolua.cast(mIcon:getChildByTag(10 + k), "CCLabelTTF")
                if starSp then
                    starSp:setPosition(ccp(starSp:getPositionX(), starSp:getPositionY() - 25))
                end
            end
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
    local seq = CCSequence:create(acArr)
    bgSp:runAction(seq)
end

function emblemAdvanceDialog:dispose()
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemAdvanceBg.jpg")
end
