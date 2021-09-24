extendTroopsLayer = {}

function extendTroopsLayer:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.parent = parent
    self.curShowTabItemIndex = 1
    return nc
end

function extendTroopsLayer:initLayer(troopsType, layerNum, parentLayer, size, topPosY)
    self.troopsType = troopsType
    self.layerNum = layerNum
    self.parentLayer = parentLayer
    self.bgLayer = CCNode:create()
    self.bgLayer:setContentSize(size)
    self.bgLayer:setAnchorPoint(ccp(0.5, 1))
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, topPosY))
    self.parentLayer:addChild(self.bgLayer, 8)
    
    self.tabitemSize = CCSizeMake(115, 0)
    --[[
self.menuItemTb = {}
local menu = CCMenu:create()
local tabItemSpaceX = 3
for i = 1, 5 do
local tabItem = CCMenuItemImage:create("aei_tabBg.png", "aei_tabBg_focus.png", "aei_tabBg_focus.png")
tabItem:setAnchorPoint(ccp(0, 1))
tabItem:setScale((size.width - tabItemSpaceX * (5 - 1)) / 5 / tabItem:getContentSize().width)
if self.tabitemSize == nil then
self.tabitemSize = CCSizeMake(tabItem:getContentSize().width * tabItem:getScale(), tabItem:getContentSize().height * tabItem:getScale())
end
tabItem:setPosition(ccp((i - 1) * (self.tabitemSize.width + tabItemSpaceX), size.height))
menu:addChild(tabItem)
tabItem:setTag(i)
        tabItem:registerScriptTapHandler(function(...)
            PlayEffect(audioCfg.mouseClick)
            return self:switchTab(...)
        end)
        self.menuItemTb[i] = tabItem
end
menu:setPosition(0, 0)
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    self.bgLayer:addChild(menu)
    --]]
    
    local infoBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    infoBgSp:setContentSize(CCSizeMake(size.width, size.height - self.tabitemSize.height))
    infoBgSp:setAnchorPoint(ccp(0.5, 1))
    infoBgSp:setPosition(ccp(size.width / 2, size.height - self.tabitemSize.height))
    self.bgLayer:addChild(infoBgSp)
    self.infoBgSp = infoBgSp
    
    self:switchTab(self.curShowTabItemIndex)
end

function extendTroopsLayer:switchTab(index)
    if self.itemNodeTb == nil then
        self.itemNodeTb = {}
    end
    self.curShowTabItemIndex = index
    local node = CCNode:create()
    node:setContentSize(self.infoBgSp:getContentSize())
    node:setPosition(ccp(0, 0))
    self.infoBgSp:addChild(node)
    self.itemNodeTb[index] = node
    if index == 1 then
        self:showAirShipTroops(node)
    end
    
    --[[
    if index ~= 1 then
        G_showTipsDialog(getlocal("backstage180"))
        do return end
    end
if self.menuItemTb then
        if self.itemNodeTb == nil then
            self.itemNodeTb = {}
        end
for k, v in pairs(self.menuItemTb) do
            local node = tolua.cast(self.itemNodeTb[v:getTag()], "CCNode")
        if v:getTag() == index then
            v:setEnabled(false)
                self.curShowTabItemIndex = index
                if node then
                    node:setPosition(ccp(0, 0))
                    node:setVisible(true)
                else
                    node = CCNode:create()
                    node:setContentSize(self.infoBgSp:getContentSize())
                    node:setPosition(ccp(0, 0))
                    self.infoBgSp:addChild(node)
                    self.itemNodeTb[index] = node
                    if index == 1 then
                        self:showAirShipTroops(node)
                    end
                end
        else
            v:setEnabled(true)
                if node then
                    -- node:removeAllChildrenWithCleanup(true)
                    node:setVisible(false)
                    node:setPosition(ccp(G_VisibleSizeWidth * 10, G_VisibleSizeHeight * 10))
                end
        end
    end
end
    --]]
end

function extendTroopsLayer:showAirShipTroops(bgSp)
    --[[
    local curTabItem = self.menuItemTb[self.curShowTabItemIndex]
    local tabItemBg = CCSprite:createWithSpriteFrameName("aei_airShipTroopsBg.png")
    tabItemBg:setPosition(ccp(curTabItem:getContentSize().width / 2, curTabItem:getContentSize().height / 2))
    curTabItem:addChild(tabItemBg)
    local addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(ccp(tabItemBg:getContentSize().width / 2, tabItemBg:getContentSize().height / 2))
    addSp:setTag(1)
    tabItemBg:addChild(addSp)
    --]]
    local lineupList, listState, extra = airShipVoApi:getLineupList(self.troopsType)
    
    local function onLoadWebImage(fn, webImage)
        if self and tolua.cast(bgSp, "CCSprite") then
            webImage:setAnchorPoint(ccp(1, 0))
            webImage:setScaleX((bgSp:getContentSize().width - 6) / webImage:getContentSize().width)
            webImage:setScaleY((bgSp:getContentSize().height - 6) / webImage:getContentSize().height)
            webImage:setPosition(ccp(bgSp:getContentSize().width - 3, 3))
            bgSp:addChild(webImage)
        end
    end
    G_addResource8888(function()
        LuaCCWebImage:createWithURL(G_downloadUrl("airShip/aei_airShipBg.jpg"), onLoadWebImage)
    end)
    
    local airShipListBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    airShipListBg:setContentSize(CCSizeMake(self.tabitemSize.width, bgSp:getContentSize().height))
    airShipListBg:setAnchorPoint(ccp(0, 1))
    airShipListBg:setPosition(ccp(0, bgSp:getContentSize().height))
    bgSp:addChild(airShipListBg, 1)
    
    local prevIdx, prevFocusSp
    local airShipPropBg = LuaCCScale9Sprite:createWithSpriteFrameName("aei_propBg.png", CCRect(5, 52, 150, 25), function()end)
    airShipPropBg:setContentSize(CCSizeMake(airShipPropBg:getContentSize().width, bgSp:getContentSize().height))
    airShipPropBg:setAnchorPoint(ccp(1, 1))
    airShipPropBg:setPosition(ccp(bgSp:getContentSize().width, bgSp:getContentSize().height))
    bgSp:addChild(airShipPropBg, 1)
    local airShipPropTitleLb = GetTTFLabel(getlocal("airShip_attributeText"), 20, true)
    airShipPropTitleLb:setAnchorPoint(ccp(0.5, 1))
    airShipPropTitleLb:setPosition(ccp(airShipPropBg:getContentSize().width / 2, airShipPropBg:getContentSize().height - 8))
    airShipPropTitleLb:setColor(ccc3(99, 206, 212))
    airShipPropBg:addChild(airShipPropTitleLb)
    local propNode = CCNode:create()
    propNode:setContentSize(CCSizeMake(airShipPropBg:getContentSize().width, airShipPropBg:getContentSize().height - 40))
    airShipPropBg:addChild(propNode)
    
    local centerWidth = airShipPropBg:getPositionX() - airShipPropBg:getContentSize().width - airShipListBg:getContentSize().width
    -- local battleAirShipLb = GetTTFLabelWrap(getlocal("airShip_alreadyBattleNameText", {getlocal("alliance_info_content")}), 18, CCSizeMake(centerWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    -- battleAirShipLb:setAnchorPoint(ccp(0.5, 1))
    -- battleAirShipLb:setPosition(ccp(airShipListBg:getContentSize().width + centerWidth / 2, bgSp:getContentSize().height - 10))
    -- battleAirShipLb:setColor(G_ColorYellowPro)
    -- bgSp:addChild(battleAirShipLb, 1)
    local airShipNameBg = CCSprite:createWithSpriteFrameName("aei_nameBg.png")
    airShipNameBg:setAnchorPoint(ccp(0.5, 1))
    airShipNameBg:setPosition(ccp(airShipListBg:getContentSize().width + centerWidth / 2, bgSp:getContentSize().height - 55))
    bgSp:addChild(airShipNameBg, 1)
    local airShipNameLb = GetTTFLabel("", 24, true)
    airShipNameLb:setAnchorPoint(ccp(0.5, 1))
    airShipNameLb:setPosition(ccp(airShipNameBg:getContentSize().width / 2, airShipNameBg:getContentSize().height - 35))
    airShipNameBg:addChild(airShipNameLb)
    local isBattleState = false
    local curSelectCell, battleCell
    local airShipSp
    local goIntoBtnLb
    local function createAriShipTagSp(parent, data) --创建飞艇标签
        local cellBg = tolua.cast(parent:getChildByTag(1), "CCSprite")
        local tagBg = CCSprite:createWithSpriteFrameName((data == nil or data.tagState == nil) and "aei_tagBg1.png" or "aei_tagBg2.png")
        tagBg:setAnchorPoint(ccp(1, 0))
        tagBg:setPosition(ccp(cellBg:getContentSize().width - 15, 5))
        tagBg:setTag(3)
        parent:addChild(tagBg, 2)
        local tagLbStr = ""
        if data == nil or data.tagState == nil then
            tagLbStr = getlocal("airShip_alreadyBattleText")
        elseif data.tagState == 1 then
            tagLbStr = getlocal("emblem_battle")
        elseif data.tagState == -1 then
            tagLbStr = getlocal("not_activated")
        elseif data.tagState == 2 then
            if data.additional and data.additional.troopIdx then
                tagLbStr = getlocal("world_war_sub_title" .. (21 + data.additional.troopIdx))
            end
        end
        local tagLb = GetTTFLabel(tagLbStr, 16)
        tagLb:setPosition(ccp(tagBg:getContentSize().width / 2, tagBg:getContentSize().height / 2))
        tagBg:addChild(tagLb)
        if data == nil or data.tagState == nil then
            local seq = CCSequence:createWithTwoActions(CCFadeTo:create(0.5, 0), CCFadeTo:create(0.5, 255))
            tagBg:runAction(CCRepeatForever:create(seq))
        end
    end
    local function createShadePanel(isCreate, data)
        local shadeBg = tolua.cast(bgSp:getChildByTag(-100), "CCSprite")
        if shadeBg then
            shadeBg:removeFromParentAndCleanup(true)
            shadeBg = nil
        end
        if isCreate then
            shadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
            shadeBg:setContentSize(CCSizeMake(bgSp:getContentSize().width - airShipListBg:getContentSize().width, bgSp:getContentSize().height))
            shadeBg:setAnchorPoint(ccp(1, 0.5))
            shadeBg:setPosition(ccp(bgSp:getContentSize().width, bgSp:getContentSize().height / 2))
            shadeBg:setTag(-100)
            bgSp:addChild(shadeBg, 10)
            -- local tipsLbStr = getlocal("airShip_noBattleAirShipTips")
            local tipsLbStr = ""
            if listState == -1 then
                tipsLbStr = getlocal("airShip_noBattleTroopsTipsText1")
            elseif listState == -2 then
                tipsLbStr = getlocal("airShip_noBattleTroopsTipsText2", {extra.nextGoIn, extra.strength})     
            end
            if data then
                if data.tagState == 1 then
                    tipsLbStr = getlocal("airShip_noBattleTroopsTipsText3")
                elseif data.tagState == -1 then
                    tipsLbStr = getlocal("airShip_noBattleTroopsTipsText4")
                end
            end
            local tipsLb = GetTTFLabelWrap(tipsLbStr, 24, CCSizeMake(shadeBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            tipsLb:setAnchorPoint(ccp(0.5, 0))
            tipsLb:setPosition(ccp(shadeBg:getContentSize().width / 2, shadeBg:getContentSize().height / 2 + 25))
            shadeBg:addChild(tipsLb)
            local function onClickGet(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                activityAndNoteDialog:closeAllDialog()
                airShipVoApi:showMainDialog(self.layerNum + 1)
            end
            if listState == -2 or data.tagState == -1 then
                local btnScale = 0.8
                local getBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickGet, nil, getlocal("activity_heartOfIron_goto"), 24 / btnScale)
                getBtn:setAnchorPoint(ccp(0.5, 1))
                getBtn:setScale(btnScale)
                getBtn:setPosition(ccp(shadeBg:getContentSize().width / 2, shadeBg:getContentSize().height / 2 - 25))
                local getMenu = CCMenu:createWithItem(getBtn)
                getMenu:setPosition(ccp(0, 0))
                getMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                shadeBg:addChild(getMenu)
            end
        end
    end
    local function onClickGoInto(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local asId, btnStr
        --[[
        local asId, btnStr, tabItemBgPic
        local tabItemBgIcon = tolua.cast(tabItemBg:getChildByTag(1), "CCSprite")
        if tabItemBgIcon then
            tabItemBgIcon:removeFromParentAndCleanup(true)
        end
        tabItemBgIcon = nil
        --]]
        if battleCell then --移除已出战标签
            local tagBg = tolua.cast(battleCell:getChildByTag(3), "CCSprite")
            if tagBg then
                tagBg:removeFromParentAndCleanup(true)
                tagBg = nil
            end
        end
        if isBattleState then --下阵
            asId = nil
            btnStr = getlocal("alliance_war_battle_btn")
            --[[
            tabItemBgPic = "aei_airShipTroopsBg.png"
            tabItemBgIcon = CCSprite:createWithSpriteFrameName("st_addIcon.png")
            --]]
            -- battleAirShipLb:setString(getlocal("airShip_alreadyBattleNameText", {getlocal("alliance_info_content")}))
        else --上阵
            asId = lineupList[prevIdx + 1].id
            btnStr = getlocal("airShip_alreadyGoInto")
            --[[
            tabItemBgPic = "aei_airShipTroopsTabBg.png"
            tabItemBgIcon = G_showAirShip(RemoveFirstChar(asId), nil, true)
            tabItemBgIcon:setScale(tabItemBg:getContentSize().width / tabItemBgIcon:getContentSize().width)
            --]]
            -- battleAirShipLb:setString(getlocal("airShip_alreadyBattleNameText", {lineupList[prevIdx + 1].name}))
            --添加已出战标签
            if curSelectCell then
                createAriShipTagSp(curSelectCell)
                battleCell = curSelectCell
            end
        end
        isBattleState = (not isBattleState)
        airShipVoApi:setTempLineupId(asId)
        goIntoBtnLb:setString(btnStr)
        if self.parent and type(self.parent.refreshAirshipBtn) == "function" then
            self.parent:refreshAirshipBtn(asId, true)
        end
        --[[
        tabItemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tabItemBgPic))
        tabItemBgIcon:setPosition(ccp(tabItemBg:getContentSize().width / 2, tabItemBg:getContentSize().height / 2))
        tabItemBgIcon:setTag(1)
        tabItemBg:addChild(tabItemBgIcon)
        --]]
    end
    local btnScale = 0.8
    local goIntoBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickGoInto, nil, getlocal("alliance_war_battle_btn"), 24 / btnScale, 10)
    goIntoBtn:setAnchorPoint(ccp(0.5, 0))
    goIntoBtn:setScale(btnScale)
    goIntoBtn:setPosition(ccp(airShipNameBg:getPositionX(), 20))
    local goIntoMenu = CCMenu:createWithItem(goIntoBtn)
    goIntoMenu:setPosition(ccp(0, 0))
    goIntoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    bgSp:addChild(goIntoMenu, 1)
    goIntoBtnLb = tolua.cast(goIntoBtn:getChildByTag(10), "CCLabelTTF")
    local airShipStrengthLb = GetTTFLabel(getlocal("alliance_boss_degree", {0}), 22)
    airShipStrengthLb:setAnchorPoint(ccp(0.5, 0))
    airShipStrengthLb:setPosition(ccp(goIntoBtn:getPositionX(), goIntoBtn:getPositionY() + goIntoBtn:getContentSize().height * btnScale + 15))
    airShipStrengthLb:setColor(G_ColorGreen)
    bgSp:addChild(airShipStrengthLb, 1)
    goIntoBtn:setEnabled(false)
    
    local airShipListTvSize = CCSizeMake(airShipListBg:getContentSize().width + 15, airShipListBg:getContentSize().height)
    local airShipListTv
    airShipListTv = G_createTableView(airShipListTvSize, SizeOfTable(lineupList), CCSizeMake(airShipListTvSize.width, 102), function(cell, cellSize, idx, cellNum)
        local data = lineupList[idx + 1]
        local function onAirShipFocus()
            if airShipListTv and airShipListTv:getIsScrolled() ~= false then
                do return end
            end
            if prevIdx == idx then
                do return end
            end
            local focusSp = tolua.cast(prevFocusSp, "CCSprite")
            if focusSp then
                focusSp:removeFromParentAndCleanup(true)
                focusSp = nil
            end
            focusSp = CCSprite:createWithSpriteFrameName("aei_iconBgFocus.png")
            focusSp:setAnchorPoint(ccp(0, 0.5))
            focusSp:setPosition(ccp(0, cellSize.height / 2))
            cell:addChild(focusSp)
            prevFocusSp = focusSp
            prevIdx = idx
            if airShipNameLb then
                airShipNameLb:setString(data.name)
            end
            if airShipSp then
                airShipSp:removeFromParentAndCleanup(true)
                airShipSp = nil
            end
            airShipSp = G_showAirShip(RemoveFirstChar(data.id))
            airShipSp:setPosition(ccp(airShipNameBg:getPositionX(), bgSp:getContentSize().height / 2))
            airShipSp:setScale(0.5)
            bgSp:addChild(airShipSp, 1)
            if airShipStrengthLb then
                airShipStrengthLb:setString(getlocal("alliance_boss_degree", {airShipVoApi:getStrength(data.id)}))
            end
            if airShipVoApi:getTempLineupId() == data.id or data.tagState == 2 then
                isBattleState = true
                goIntoBtnLb:setString(getlocal("airShip_alreadyGoInto"))
            else
                isBattleState = false
                goIntoBtnLb:setString(getlocal("alliance_war_battle_btn"))
            end
            self:showAirShipAttribute(propNode, data.id)
            curSelectCell = cell
            local isCreateShade = false
            if listState then
                isCreateShade = true
                goIntoBtn:setEnabled(false)
            else
                if data.tagState == 1 or data.tagState == -1 or data.tagState == 2 then
                    isCreateShade = true
                    goIntoBtn:setEnabled(false)
                else
                    goIntoBtn:setEnabled(true)
                end
            end
            createShadePanel(isCreateShade, data)
        end
        local cellBg = LuaCCSprite:createWithSpriteFrameName("aei_iconBg.png", onAirShipFocus)
        cellBg:setAnchorPoint(ccp(0, 0.5))
        -- cellBg:setScale(cellSize.width / cellBg:getContentSize().width)
        cellBg:setPosition(ccp(0, cellSize.height / 2))
        cellBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cellBg:setTag(1)
        cell:addChild(cellBg)
        local airShipIcon = G_showAirShip(RemoveFirstChar(data.id), nil, true)
        airShipIcon:setPosition(ccp(cellBg:getContentSize().width / 2, cellSize.height / 2))
        airShipIcon:setScale(cellBg:getContentSize().width / airShipIcon:getContentSize().width)
        cell:addChild(airShipIcon, 1)
        if idx == 0 then
            onAirShipFocus()
        end
        if airShipVoApi:getTempLineupId() == data.id then
            --[[
            tabItemBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("aei_airShipTroopsTabBg.png"))
            local tabItemBgIcon = tolua.cast(tabItemBg:getChildByTag(1), "CCSprite")
            if tabItemBgIcon then
                tabItemBgIcon:removeFromParentAndCleanup(true)
            end
            tabItemBgIcon = nil
            tabItemBgIcon = G_showAirShip(RemoveFirstChar(data.id), nil, true)
            tabItemBgIcon:setScale(tabItemBg:getContentSize().width / tabItemBgIcon:getContentSize().width)
            tabItemBgIcon:setPosition(ccp(tabItemBg:getContentSize().width / 2, tabItemBg:getContentSize().height / 2))
            tabItemBgIcon:setTag(1)
            tabItemBg:addChild(tabItemBgIcon)
            --]]
            -- battleAirShipLb:setString(getlocal("airShip_alreadyBattleNameText", {data.name}))
            --已出战标签
            createAriShipTagSp(cell)
            battleCell = cell
        elseif data.tagState then
            createAriShipTagSp(cell, data)
        end
    end)
    airShipListTv:setPosition(ccp(0, 0))
    airShipListTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    airShipListTv:setMaxDisToBottomOrTop(100)
    airShipListBg:addChild(airShipListTv)
end

function extendTroopsLayer:showAirShipAttribute(attributeNode, airShipId)
    if attributeNode then
        attributeNode:removeAllChildrenWithCleanup(true)
        local attributeTb = airShipVoApi:getAttribute(airShipId)
        if attributeTb then
            local asCfg = airShipVoApi:getAirShipCfg().airship[tonumber(RemoveFirstChar(airShipId))]
            local perfix = ""
            if asCfg and asCfg.target > 0 then
                perfix = airShipVoApi:getTankTypeName(asCfg.target)
            end
            local cellItemTb = {}
            local firstPosY = attributeNode:getContentSize().height - 10
            local attTitle = {getlocal("airShip_resonanceStr"), getlocal("airShip_tacticsActving")}
            for k, v in pairs(attributeTb) do
                local attributeTitleLb
                if k > 1 then
                    local spaceLineSp = CCSprite:createWithSpriteFrameName("aei_line.png")
                    spaceLineSp:setScaleX((attributeNode:getContentSize().width - 30) / spaceLineSp:getContentSize().width)
                    spaceLineSp:setScaleY(3 / spaceLineSp:getContentSize().height)
                    spaceLineSp:setPosition(ccp(attributeNode:getContentSize().width / 2, firstPosY))
                    -- attributeNode:addChild(spaceLineSp)
                    table.insert(cellItemTb, spaceLineSp)
                    firstPosY = firstPosY - 5
                    attributeTitleLb = GetTTFLabelWrap(attTitle[k - 1], 20, CCSizeMake(attributeNode:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                    attributeTitleLb:setAnchorPoint(ccp(0.5, 1))
                    attributeTitleLb:setPosition(ccp(attributeNode:getContentSize().width / 2, firstPosY))
                    attributeTitleLb:setColor(ccc3(99, 206, 212))
                    -- attributeNode:addChild(attributeTitleLb)
                    table.insert(cellItemTb, attributeTitleLb)
                    firstPosY = firstPosY - attributeTitleLb:getContentSize().height - 5
                end
                local count = 0
                for kk, vv in pairs(v) do
                    local attrKey, attrValue = kk, vv
                    if k == 3 then
                        attrKey = vv[2]
                        attrValue = vv[3]
                        count = count + 1
                    end
                    local bufId = buffKeyMatchCodeCfg[attrKey]
                    local lbStr = getlocal(buffEffectCfg[bufId].name) .. "：<rayimg>" .. ((attrKey == "antifirst") and "" or "+") ..airShipVoApi:getPropertyValueStr(attrKey, attrValue)
                    if k == 1 then
                        lbStr = perfix .. lbStr
                    elseif k == 3 then
                        lbStr = airShipVoApi:getTankTypeName(vv[1]) .. lbStr
                    end
                    local lbColorTb = {nil, (attrKey == "antifirst") and G_ColorRed or G_ColorGreen}
                    local attributeLb, attributeLbHeight = G_getRichTextLabel(lbStr, lbColorTb, 18, attributeNode:getContentSize().width, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    attributeLb:setAnchorPoint(ccp(0.5, 1))
                    attributeLb:setPosition(ccp(attributeNode:getContentSize().width / 2, firstPosY))
                    -- attributeNode:addChild(attributeLb)
                    table.insert(cellItemTb, attributeLb)
                    firstPosY = firstPosY - attributeLbHeight - 5
                end
                if k == 3 and attributeTitleLb then
                    attributeTitleLb:setString(getlocal("airShip_tacticsActving", {count, 5}))
                end
            end
            local tvCellHeight = attributeNode:getContentSize().height
            if firstPosY < 0 then
                tvCellHeight = attributeNode:getContentSize().height - firstPosY + 5
            end
            local attributeTv = G_createTableView(attributeNode:getContentSize(), 1, CCSizeMake(attributeNode:getContentSize().width, tvCellHeight), function(cell, cellSize, idx, cellNum)
                if cellItemTb then
                    for k, v in ipairs(cellItemTb) do
                        if firstPosY < 0 then
                            v:setPositionY(v:getPositionY() + (-firstPosY + 5))
                        end
                        cell:addChild(v)
                    end
                end
            end)
            attributeTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
            attributeTv:setPosition(ccp(0, 0))
            attributeTv:setMaxDisToBottomOrTop((firstPosY < 0) and 100 or 0)
            attributeNode:addChild(attributeTv)
        end
    end
end

function extendTroopsLayer:setVisible(visible)
    if self.bgLayer then
        self.bgLayer:setVisible(visible)
        self.bgLayer:setPositionX(visible and (G_VisibleSizeWidth / 2) or (G_VisibleSizeWidth * 10))
    end
end

function extendTroopsLayer:refreshUI()
    if self and self.itemNodeTb and self.itemNodeTb[self.curShowTabItemIndex] then
        self.itemNodeTb[self.curShowTabItemIndex]:removeAllChildrenWithCleanup(true)
        if self.curShowTabItemIndex == 1 then
            self:showAirShipTroops(self.itemNodeTb[self.curShowTabItemIndex])
        end
    end
end

function extendTroopsLayer:dispose()
    self = nil
end
