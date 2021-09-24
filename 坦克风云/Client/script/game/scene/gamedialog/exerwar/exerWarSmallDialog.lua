exerWarSmallDialog = smallDialog:new()

function exerWarSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function exerWarSmallDialog:showAllTroops(layerNum, titleStr, troopsData)
    local sd = exerWarSmallDialog:new()
    sd:initAllTroops(layerNum, titleStr, troopsData)
end

function exerWarSmallDialog:initAllTroops(layerNum, titleStr, troopsData)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    G_addResource8888(function()
            spriteController:addPlist("public/aiTroopsImage/aitroops_images2.plist")
            spriteController:addTexture("public/aiTroopsImage/aitroops_images2.png")
    end)
    self.bgSize = CCSizeMake(560, 780)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
        spriteController:removePlist("public/aiTroopsImage/aitroops_images2.plist")
        spriteController:removeTexture("public/aiTroopsImage/aitroops_images2.png")
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local selectedTabIndex = 1
    local tabTitle = {
        getlocal("fleetInfoTitle2"), getlocal("heroTitle"), getlocal("aitroops_title"), getlocal("emblem_title"), getlocal("plane_titleText")
    }
    local funcTabClick
    local tabLinePosY
    local allTabBtn = {}
    local tabBtn = CCMenu:create()
    for k, v in pairs(tabTitle) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0.5, 0.5))
        tabBtnItem:setScaleX(0.73)
        tabBtnItem:setPosition(7 + tabBtnItem:getContentSize().width * tabBtnItem:getScaleX() / 2 + (k - 1) * (tabBtnItem:getContentSize().width * tabBtnItem:getScaleX() + 3), self.bgSize.height - 89)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(k)
        local lb = GetTTFLabelWrap(v, 18, CCSizeMake(tabBtnItem:getContentSize().width * tabBtnItem:getScaleX(), 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        lb:setPosition(tabBtnItem:getPosition())
        self.bgLayer:addChild(lb, 1)
        tabBtnItem:registerScriptTapHandler(function(...)
                PlayEffect(audioCfg.mouseClick)
                return funcTabClick(...)
        end)
        allTabBtn[k] = tabBtnItem
        if tabLinePosY == nil then
            tabLinePosY = tabBtnItem:getPositionY() - tabBtnItem:getContentSize().height * tabBtnItem:getScaleY() / 2
        end
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 6)
    self.bgLayer:addChild(tabBtn)
    local tabLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 3, 1, 1), function()end)
    tabLine:setContentSize(CCSizeMake(self.bgSize.width - 14, tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5, 1))
    tabLine:setPosition(self.bgSize.width / 2, tabLinePosY)
    self.bgLayer:addChild(tabLine)
    
    local function getCellNum(tabIndex)
        if troopsData and troopsData[tabIndex] then
            local size
            if tabIndex == 5 then
                size = SizeOfTable(troopsData[tabIndex][1] or {})
            else
                size = SizeOfTable(troopsData[tabIndex])
            end
            if tabIndex == 1 or tabIndex == 2 or tabIndex == 4 then
                return math.ceil(size / 3)
            elseif tabIndex == 3 or tabIndex == 5 then
                return math.ceil(size / 2)
            end
        end
        return 0
    end
    local function getCellHeight(tabIndex)
        local cellHeight = 0
        if tabIndex == 1 then
            cellHeight = 230
        elseif tabIndex == 2 then
            cellHeight = 210
        elseif tabIndex == 3 then
            cellHeight = 300
        elseif tabIndex == 4 then
            cellHeight = 210
        elseif tabIndex == 5 then
            cellHeight = 270
        end
        return cellHeight
    end
    local tv 
    local cellNum = 0
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(self.bgSize.width - 30, getCellHeight(selectedTabIndex))
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = self.bgSize.width - 30, getCellHeight(selectedTabIndex)
            if selectedTabIndex == 1 then
                local endIndex = (idx + 1) * 3
                local startIndex = endIndex - 2
                local index = 1
                for i = startIndex, endIndex do
                    local tankTb = troopsData[selectedTabIndex][i]
                    if tankTb then
                        local tankId = tonumber(tankTb[1]) or tonumber(RemoveFirstChar(tankTb[1]))
                        local troopsNum = exerWarVoApi:getBaseTroopsNum()--tankTb[2]
                        local tankIcon = tankVoApi:getTankIconSp(tankId)
                        local startPosX = (cellW - (tankIcon:getContentSize().width * 3 + (3 - 1) * 20)) / 2 + tankIcon:getContentSize().width / 2
                        tankIcon:setPosition(startPosX + (index - 1) * (tankIcon:getContentSize().width + 20), cellH - tankIcon:getContentSize().height / 2)
                        cell:addChild(tankIcon)
                        if tankId ~= G_pickedList(tankId) then
                            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                            pickedIcon:setPosition(tankIcon:getContentSize().width * 0.7, tankIcon:getContentSize().height * 0.5 - 20)
                            tankIcon:addChild(pickedIcon)
                        end
                        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png", CCRect(15, 15, 1, 1), function()end)
                        numBg:setContentSize(CCSizeMake(130, 36))
                        numBg:setPosition(tankIcon:getContentSize().width / 2, - 16)
                        tankIcon:addChild(numBg)
                        local numLb = GetTTFLabel(tostring(troopsNum), 26)
                        numLb:setPosition(numBg:getContentSize().width / 2, numBg:getContentSize().height / 2)
                        numBg:addChild(numLb)
                        local nameLb = GetTTFLabelWrap(getlocal(tankCfg[tankId].name), 24, CCSizeMake(24 * 7, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                        nameLb:setAnchorPoint(ccp(0.5, 1))
                        nameLb:setPosition(tankIcon:getContentSize().width / 2, numBg:getPositionY() - numBg:getContentSize().height / 2)
                        tankIcon:addChild(nameLb, 1)
                        local function showInfoHandler()
                            if tv:getIsScrolled() == true then
                                do return end
                            end
                            if G_checkClickEnable() == false then
                                do return end
                            else
                                base.setWaitTime = G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)
                            if exerWarVoApi and exerWarVoApi:getWarPeroid() <= 5 then
                                tankInfoDialog:create(nil, tonumber(G_pickedList(tankId)), self.layerNum + 1, true, nil, nil, true)
                            else
                                tankInfoDialog:create(nil, tonumber(G_pickedList(tankId)), self.layerNum + 1, true, nil, nil, true, nil, nil, exerWarVoApi:getAccessoryPercent())
                            end
                        end
                        local tipItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfoHandler)
                        tipItem:setScale(0.7)
                        local tipMenu = CCMenu:createWithItem(tipItem)
                        tipMenu:setPosition(tankIcon:getContentSize().width - tipItem:getContentSize().width * tipItem:getScale() / 2 - 10, tankIcon:getContentSize().height - tipItem:getContentSize().height * tipItem:getScale() / 2 - 10)
                        tipMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                        tankIcon:addChild(tipMenu)
                    end
                    index = index + 1
                end
            elseif selectedTabIndex == 2 then
                local endIndex = (idx + 1) * 3
                local startIndex = endIndex - 2
                local index = 1
                for i = startIndex, endIndex do
                    local heroTb = troopsData[selectedTabIndex][i]
                    if heroTb then
                        local hid = heroTb[1]
                        local heroLevel = heroTb[2] or 1
                        local heroStarLv = heroTb[3] or 1
                        local heroSkillLv = heroTb[4] or 1
                        local heroIcon = heroVoApi:getHeroIcon(hid, heroStarLv, nil, nil, nil, nil, nil, {showAjt = false})
                        heroIcon:setScale(0.7)
                        local startPosX = (cellW - (heroIcon:getContentSize().width * heroIcon:getScale() * 3 + (3 - 1) * 65)) / 2 + heroIcon:getContentSize().width * heroIcon:getScale() / 2
                        heroIcon:setPosition(startPosX + (index - 1) * (heroIcon:getContentSize().width * heroIcon:getScale() + 65), cellH - heroIcon:getContentSize().height * heroIcon:getScale() / 2)
                        cell:addChild(heroIcon)
                        local nameLb = GetTTFLabelWrap(heroVoApi:getHeroName(hid), 24, CCSizeMake(24 * 7, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                        nameLb:setAnchorPoint(ccp(0.5, 1))
                        nameLb:setPosition(heroIcon:getContentSize().width / 2, - 30)
                        heroIcon:addChild(nameLb, 1)
                        local groundPic = exerWarVoApi:getHeroGroundPic(hid)
                        if groundPic then
                            local groundBg = CCSprite:createWithSpriteFrameName("exer_groundBg.png")
                            local groundSp = CCSprite:createWithSpriteFrameName(groundPic)
                            groundSp:setPosition(groundBg:getContentSize().width / 2, groundBg:getContentSize().height / 2)
                            groundSp:setScale((groundBg:getContentSize().width - 10) / groundSp:getContentSize().width)
                            groundBg:addChild(groundSp)
                            groundBg:setAnchorPoint(ccp(1, 1))
                            groundBg:setPosition(heroIcon:getContentSize().width, heroIcon:getContentSize().height)
                            groundBg:setScale(1.3)
                            heroIcon:addChild(groundBg)
                        elseif exerWarVoApi:isHeroFirst(hid) == true then
                            local groundBg = CCSprite:createWithSpriteFrameName("exer_groundBg.png")
                            local firstValueSp = CCSprite:createWithSpriteFrameName("positiveHead.png")
                            firstValueSp:setPosition(groundBg:getContentSize().width / 2, groundBg:getContentSize().height / 2)
                            firstValueSp:setScale((groundBg:getContentSize().width - 10) / firstValueSp:getContentSize().width)
                            groundBg:addChild(firstValueSp)
                            groundBg:setAnchorPoint(ccp(1, 1))
                            groundBg:setPosition(heroIcon:getContentSize().width, heroIcon:getContentSize().height)
                            groundBg:setScale(1.3)
                            heroIcon:addChild(groundBg)
                        end
                        local function checkCallback()
                            if tv:getIsScrolled() == true then
                                do return end
                            end
                            if G_checkClickEnable() == false then
                                do return end
                            else
                                base.setWaitTime = G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)
                            require "luascript/script/game/scene/gamedialog/heroDialog/heroShareSmallDialog"
                            heroShareSmallDialog:showHeroInfoSmallDialog({name = getlocal("heroInfo")}, heroVoApi:exerWarHeroVo(heroTb), self.layerNum + 1, "TankInforPanel.png", CCRect(130, 50, 1, 1))
                        end
                        local itemScale = 0.9
                        local checkItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", checkCallback, nil, getlocal("alliance_list_check_info"), 24 / itemScale)
                        checkItem:setScale(itemScale)
                        checkItem:setAnchorPoint(ccp(0.5, 1))
                        local checkMenu = CCMenu:createWithItem(checkItem)
                        checkMenu:setPosition(heroIcon:getContentSize().width / 2, nameLb:getPositionY() - nameLb:getContentSize().height - 5)
                        checkMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                        heroIcon:addChild(checkMenu)
                    end
                    index = index + 1
                end
            elseif selectedTabIndex == 3 then
                local endIndex = (idx + 1) * 2
                local startIndex = endIndex - 1
                local index = 1
                for i = startIndex, endIndex do
                    local aiTroopsTb = troopsData[selectedTabIndex][i]
                    if aiTroopsTb and type(aiTroopsTb) == "table" then
                        local aid = aiTroopsTb[1]
                        local aiLevel = aiTroopsTb[2]
                        local aiGrade = aiTroopsTb[3]
                        local aiSkillLv = aiTroopsTb[4]
                        local troopsVo = AITroopsVoApi:createAITroopsVoByMirror({aid, aiLevel, aiGrade, aiSkillLv, aiSkillLv, nil, aiSkillLv})
                        local aiTroopsIcon = AITroopsVoApi:getAITroopsIcon(troopsVo)
                        aiTroopsIcon:setPosition((cellW / 2) / 2 + (index - 1) * (cellW / 2), cellH - aiTroopsIcon:getContentSize().height / 2)
                        cell:addChild(aiTroopsIcon)
                        local function showInfo()
                            if tv:getIsScrolled() == true then
                                do return end
                            end
                            AITroopsVoApi:showTroopsInfoDialog(troopsVo, false, self.layerNum + 1)
                        end
                        local pos = ccp(aiTroopsIcon:getContentSize().width - 57 * 0.5, aiTroopsIcon:getContentSize().height - 57 * 0.5 - 60)
                        G_addMenuInfo(aiTroopsIcon, self.layerNum, pos, nil, nil, 0.7, nil, showInfo, true, 3)
                    end
                    index = index + 1
                end
            elseif selectedTabIndex == 4 then
                local endIndex = (idx + 1) * 3
                local startIndex = endIndex - 2
                local index = 1
                for i = startIndex, endIndex do
                    local eid = troopsData[selectedTabIndex][i]
                    if eid and eid ~= "" then
                        local eCfg = emblemListCfg.equipListCfg[eid]
                        local emblemIcon = emblemVoApi:getEquipIcon(eid, nil, nil, nil, eCfg.qiangdu)
                        emblemIcon:setScale(((cellW - 15 * 3) / 3) / emblemIcon:getContentSize().width)
                        local startPosX = (cellW - (emblemIcon:getContentSize().width * emblemIcon:getScale() * 3 + (3 - 1) * 15)) / 2 + emblemIcon:getContentSize().width * emblemIcon:getScale() / 2
                        emblemIcon:setPosition(startPosX + (index - 1) * (emblemIcon:getContentSize().width * emblemIcon:getScale() + 15), cellH - emblemIcon:getContentSize().height * emblemIcon:getScale() / 2)
                        cell:addChild(emblemIcon)
                        local function showInfo()
                            if tv:getIsScrolled() == true then
                                do return end
                            end
                            local eVo = emblemVo:new(eCfg)
                            eVo:initWithData(eid, 0)
                            emblemVoApi:showInfoDialog(eVo, self.layerNum + 1)
                        end
                        local pos = ccp(emblemIcon:getContentSize().width - 57 * 0.5, emblemIcon:getContentSize().height - 57 * 0.5)
                        G_addMenuInfo(emblemIcon, self.layerNum, pos, nil, nil, 1, nil, showInfo, true, 3)
                    end
                    index = index + 1
                end
            elseif selectedTabIndex == 5 then
                local endIndex = (idx + 1) * 2
                local startIndex = endIndex - 1
                local index = 1
                for i = startIndex, endIndex do
                    local planeId = troopsData[selectedTabIndex][1][i]
                    if planeId then
                        local planeIcon = planeVoApi:getPlaneIcon(planeId, planeCfg.plane[planeId].strength)
                        planeIcon:setPosition((cellW / 2) / 2 + (index - 1) * (cellW / 2), cellH - planeIcon:getContentSize().height / 2)
                        cell:addChild(planeIcon)
                    end
                    index = index + 1
                end
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local sTv
    local function createTv()
        if tv then
            tv:removeFromParentAndCleanup(true)
            tv = nil
        end
        if sTv then
            sTv:removeFromParentAndCleanup(true)
            sTv = nil
        end
        local tvHeight, tvPosY = tabLinePosY - tabLine:getContentSize().height - 25, 25
        if selectedTabIndex == 5 then
            tvHeight, tvPosY = tabLinePosY - tabLine:getContentSize().height - 175, 175
        end
        local hd = LuaEventHandler:createHandler(function(...) return tvCallBack(...) end)
        tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgSize.width - 30, tvHeight), nil)
        tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
        tv:setPosition(ccp(15, tvPosY))
        self.bgLayer:addChild(tv)
        tv:setMaxDisToBottomOrTop(120)
        if selectedTabIndex == 5 then
            local sSize = 0
            if troopsData and troopsData[selectedTabIndex] then
                sSize = SizeOfTable(troopsData[selectedTabIndex][2] or {})
            end
            local function sTvCallBack(handler, fn, idx, cel)
                if fn == "numberOfCellsInTableView" then
                    return sSize
                elseif fn == "tableCellSizeForIndex" then
                    return CCSizeMake(150, 145)
                elseif fn == "tableCellAtIndex" then
                    local cell = CCTableViewCell:new()
                    cell:autorelease()
                    local cellWidth, cellHeight = 150, 145
                    local planeSkillId = troopsData[selectedTabIndex][2][idx + 1]
                    local function showInfo()
                        if sTv and sTv:getIsScrolled() == true then
                            do return end
                        end
                        local scfg, gcfg = planeVoApi:getSkillCfgById(planeSkillId)
                        local skillVo = planeSkillVo:new(scfg, gcfg)
                        skillVo:initWithData(planeSkillId, 0, 2)
                        planeVoApi:showInfoDialog(skillVo, self.layerNum + 1)
                    end
                    local psIconSize = 100
                    local planeSkillIcon = planeVoApi:getSkillIcon(planeSkillId, psIconSize, showInfo)
                    planeSkillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                    planeSkillIcon:setPosition(cellWidth / 2, cellHeight - psIconSize / 2 - 5)
                    cell:addChild(planeSkillIcon)
                    local psName = planeVoApi:getSkillInfoById(planeSkillId, true)
                    local nameLb = GetTTFLabelWrap(psName, 20, CCSizeMake(cellWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    local scfg, gcfg = planeVoApi:getSkillCfgById(planeSkillId)
                    local color = planeVoApi:getColorByQuality(gcfg.color)
                    nameLb:setColor(color)
                    nameLb:setAnchorPoint(ccp(0.5, 1))
                    nameLb:setPosition(planeSkillIcon:getContentSize().width / 2, - 5)
                    planeSkillIcon:addChild(nameLb)
                    return cell
                elseif fn == "ccTouchBegan" then
                    return true
                elseif fn == "ccTouchMoved" then
                elseif fn == "ccTouchEnded" then
                end
            end
            local sHd = LuaEventHandler:createHandler(function(...) return sTvCallBack(...) end)
            sTv = LuaCCTableView:createHorizontalWithEventHandler(sHd, CCSizeMake(self.bgSize.width - 30, 145), nil)
            sTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
            sTv:setPosition(ccp(15, 25))
            self.bgLayer:addChild(sTv)
            sTv:setMaxDisToBottomOrTop(120)
        end
    end
    
    funcTabClick = function(tag)
        for k, v in pairs(allTabBtn) do
            if v:getTag() == tag then
                v:setEnabled(false)
                selectedTabIndex = tag
            else
                v:setEnabled(true)
            end
        end
        cellNum = getCellNum(selectedTabIndex)
        -- tv:reloadData()
        createTv()
    end
    funcTabClick(selectedTabIndex)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(self.bgSize.width / 2, tabLinePosY)
    upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    upShiedldBg:setOpacity(0)
    self.bgLayer:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(self.bgSize.width / 2, 10)
    downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    downShiedldBg:setOpacity(0)
    self.bgLayer:addChild(downShiedldBg)
end

--@sType : 1-坦克,2-将领,3-AI部队,4-军徽,5-飞机
function exerWarSmallDialog:showSelectTroops(layerNum, titleStr, sType, sData, selectedCallback, haveSelectAITroopsTb)
    local sd = exerWarSmallDialog:new()
    sd:initSelectTroops(layerNum, titleStr, sType, sData, selectedCallback, haveSelectAITroopsTb)
end

function exerWarSmallDialog:initSelectTroops(layerNum, titleStr, sType, sData, selectedCallback, haveSelectAITroopsTb)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    if sType == 2 then
        spriteController:addPlist("public/world_ground.plist")
    elseif sType == 3 then
        G_addResource8888(function()
                spriteController:addPlist("public/aiTroopsImage/aitroops_images2.plist")
                spriteController:addTexture("public/aiTroopsImage/aitroops_images2.png")
                spriteController:addPlist("public/emblem/emblemImage.plist")
                spriteController:addTexture("public/emblem/emblemImage.png")
        end)
    end
    self.bgSize = CCSizeMake(560, 780)
    local function closeDialog()
        self:close()
        if sType == 2 then
            spriteController:removePlist("public/world_ground.plist")
        elseif sType == 3 then
            spriteController:removePlist("public/aiTroopsImage/aitroops_images2.plist")
            spriteController:removeTexture("public/aiTroopsImage/aitroops_images2.png")
            spriteController:removePlist("public/emblem/emblemImage.plist")
            spriteController:removeTexture("public/emblem/emblemImage.png")
        end
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local sDataSize = SizeOfTable(sData or {})
    if sType == 2 and sData then
        sData = exerWarVoApi:sortHeroPool(sData)
    elseif sType == 5 and sData then
        sDataSize = SizeOfTable(sData[1] or {})
    end
    if sDataSize == 0 then
        local notTipsLb = GetTTFLabelWrap(getlocal("serverWarLocal_noData"), 24, CCSizeMake(self.bgSize.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        notTipsLb:setPosition(self.bgSize.width / 2, (self.bgSize.height - 80) / 2)
        notTipsLb:setColor(G_ColorGray)
        self.bgLayer:addChild(notTipsLb)
    else
        local function getCellNum(tabIndex)
            if tabIndex == 1 or tabIndex == 2 or tabIndex == 4 then
                return math.ceil(sDataSize / 3)
            elseif tabIndex == 3 or tabIndex == 5 then
                return math.ceil(sDataSize / 2)
            end
            return 0
        end
        local function getCellHeight(tabIndex, idx)
            local cellHeight = 0
            if tabIndex == 1 then
                cellHeight = 230
            elseif tabIndex == 2 then
                cellHeight = 210
            elseif tabIndex == 3 then
                cellHeight = 300
            elseif tabIndex == 4 then
                cellHeight = 210
            elseif tabIndex == 5 then
                cellHeight = 270
            end
            return cellHeight
        end
        local tv
        local prevSelectedIcon, curSelectedIndex
        local function tvCallBack(handler, fn, idx, cel)
            if fn == "numberOfCellsInTableView" then
                return getCellNum(sType)
            elseif fn == "tableCellSizeForIndex" then
                return CCSizeMake(self.bgSize.width - 30, getCellHeight(sType, idx))
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                local cellWidth, cellHeight = self.bgSize.width - 30, getCellHeight(sType, idx)
                if sType == 1 then
                    local function onClickTank(tankIcon, i)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        if prevSelectedIcon == tankIcon then
                            do return end
                        end
                        local troopsNum = exerWarVoApi:getBaseTroopsNum()--sData[i][2]
                        if tolua.cast(prevSelectedIcon, "CCSprite") then
                            local iconSp = tolua.cast(prevSelectedIcon, "CCSprite")
                            local numLb = tolua.cast(iconSp:getChildByTag(100), "CCLabelTTF")
                            local selectedBg = tolua.cast(iconSp:getChildByTag(101), "CCSprite")
                            local selectedNumBg = tolua.cast(iconSp:getChildByTag(102), "CCSprite")
                            if numLb then
                                numLb:setString(tostring(troopsNum))
                            end
                            if selectedBg then
                                selectedBg:removeFromParentAndCleanup(true)
                                selectedBg = nil
                            end
                            if selectedNumBg then
                                selectedNumBg:removeFromParentAndCleanup(true)
                                selectedNumBg = nil
                            end
                        end
                        local selectedNumBg = LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png", CCRect(15, 15, 1, 1), function()end)
                        selectedNumBg:setContentSize(CCSizeMake(100, 36))
                        selectedNumBg:setPosition(tankIcon:getContentSize().width / 2, selectedNumBg:getContentSize().height / 2 + 5)
                        tankIcon:addChild(selectedNumBg)
                        local selectedNumLb = GetTTFLabel(tostring(troopsNum), 26)
                        selectedNumLb:setPosition(selectedNumBg:getContentSize().width / 2, selectedNumBg:getContentSize().height / 2)
                        selectedNumBg:addChild(selectedNumLb)
                        local selectedBg = CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
                        selectedBg:setPosition(tankIcon:getContentSize().width / 2, tankIcon:getContentSize().height / 2)
                        tankIcon:addChild(selectedBg, 1)
                        selectedBg:setTag(101)
                        selectedNumBg:setTag(102)
                        local numLb = tolua.cast(tankIcon:getChildByTag(100), "CCLabelTTF")
                        if numLb then
                            numLb:setString(tostring(0))
                        end
                        prevSelectedIcon = tankIcon
                        curSelectedIndex = i
                    end
                    local endIndex = (idx + 1) * 3
                    local startIndex = endIndex - 2
                    local index = 1
                    for i = startIndex, endIndex do
                        local tankTb = sData[i]
                        if tankTb then
                            local tankId = tonumber(tankTb[1]) or tonumber(RemoveFirstChar(tankTb[1]))
                            local troopsNum = exerWarVoApi:getBaseTroopsNum()--tankTb[2]
                            local tankIcon
                            tankIcon = tankVoApi:getTankIconSp(tankId, nil, function() onClickTank(tankIcon, i) end)
                            tankIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                            local startPosX = (cellWidth - (tankIcon:getContentSize().width * 3 + (3 - 1) * 20)) / 2 + tankIcon:getContentSize().width / 2
                            tankIcon:setPosition(startPosX + (index - 1) * (tankIcon:getContentSize().width + 20), cellHeight - tankIcon:getContentSize().height / 2 - 10)
                            cell:addChild(tankIcon)
                            if tankId ~= G_pickedList(tankId) then
                                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                                pickedIcon:setPosition(tankIcon:getContentSize().width * 0.7, tankIcon:getContentSize().height * 0.5 - 20)
                                tankIcon:addChild(pickedIcon)
                            end
                            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png", CCRect(15, 15, 1, 1), function()end)
                            numBg:setContentSize(CCSizeMake(130, 36))
                            numBg:setPosition(tankIcon:getContentSize().width / 2, - 16)
                            tankIcon:addChild(numBg)
                            local numLb = GetTTFLabel(tostring(troopsNum), 26)
                            numLb:setPosition(numBg:getPosition())
                            numLb:setTag(100)
                            tankIcon:addChild(numLb)
                            local nameLb = GetTTFLabelWrap(getlocal(tankCfg[tankId].name), 24, CCSizeMake(24 * 7, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                            nameLb:setAnchorPoint(ccp(0.5, 1))
                            nameLb:setPosition(tankIcon:getContentSize().width / 2, numBg:getPositionY() - numBg:getContentSize().height / 2)
                            tankIcon:addChild(nameLb, 1)
                            local function showInfoHandler()
                                if tv:getIsScrolled() == true then
                                    do return end
                                end
                                if G_checkClickEnable() == false then
                                    do return end
                                else
                                    base.setWaitTime = G_getCurDeviceMillTime()
                                end
                                PlayEffect(audioCfg.mouseClick)
                                if exerWarVoApi and exerWarVoApi:getWarPeroid() <= 5 then
                                    tankInfoDialog:create(nil, tonumber(G_pickedList(tankId)), self.layerNum + 1, true, nil, nil, true)
                                else
                                    tankInfoDialog:create(nil, tonumber(G_pickedList(tankId)), self.layerNum + 1, true, nil, nil, true, nil, nil, exerWarVoApi:getAccessoryPercent())
                                end
                            end
                            local tipItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfoHandler)
                            tipItem:setScale(0.7)
                            local tipMenu = CCMenu:createWithItem(tipItem)
                            tipMenu:setPosition(tankIcon:getContentSize().width - tipItem:getContentSize().width * tipItem:getScale() / 2 - 10, tankIcon:getContentSize().height - tipItem:getContentSize().height * tipItem:getScale() / 2 - 10)
                            tipMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                            tankIcon:addChild(tipMenu)
                            if i == 1 then
                                onClickTank(tankIcon, i)
                            end
                        end
                        index = index + 1
                    end
                elseif sType == 2 then
                    local function onClickHero(i)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        closeDialog()
                        if type(selectedCallback) == "function" then
                            selectedCallback(sData[i])
                        end
                    end
                    local endIndex = (idx + 1) * 3
                    local startIndex = endIndex - 2
                    local index = 1
                    for i = startIndex, endIndex do
                        local heroTb = sData[i]
                        if heroTb then
                            local hid = heroTb[1]
                            local heroLevel = heroTb[2] or 1
                            local heroStarLv = heroTb[3] or 1
                            local heroIcon = heroVoApi:getHeroIcon(hid, heroStarLv, nil, function() onClickHero(i) end, nil, nil, nil, {showAjt = false})
                            heroIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                            heroIcon:setScale(0.7)
                            local startPosX = (cellWidth - (heroIcon:getContentSize().width * heroIcon:getScale() * 3 + (3 - 1) * 65)) / 2 + heroIcon:getContentSize().width * heroIcon:getScale() / 2
                            heroIcon:setPosition(startPosX + (index - 1) * (heroIcon:getContentSize().width * heroIcon:getScale() + 65), cellHeight - heroIcon:getContentSize().height * heroIcon:getScale() / 2)
                            cell:addChild(heroIcon)
                            local nameLb = GetTTFLabelWrap(heroVoApi:getHeroName(hid), 24, CCSizeMake(24 * 7, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                            nameLb:setAnchorPoint(ccp(0.5, 1))
                            nameLb:setPosition(heroIcon:getContentSize().width / 2, - 30)
                            heroIcon:addChild(nameLb, 1)
                            local groundPic = exerWarVoApi:getHeroGroundPic(hid)
                            if groundPic then
                                local groundBg = CCSprite:createWithSpriteFrameName("exer_groundBg.png")
                                local groundSp = CCSprite:createWithSpriteFrameName(groundPic)
                                groundSp:setPosition(groundBg:getContentSize().width / 2, groundBg:getContentSize().height / 2)
                                groundSp:setScale((groundBg:getContentSize().width - 10) / groundSp:getContentSize().width)
                                groundBg:addChild(groundSp)
                                groundBg:setAnchorPoint(ccp(1, 1))
                                groundBg:setPosition(heroIcon:getContentSize().width, heroIcon:getContentSize().height)
                                groundBg:setScale(1.3)
                                heroIcon:addChild(groundBg)
                            elseif exerWarVoApi:isHeroFirst(hid) == true then
                                local groundBg = CCSprite:createWithSpriteFrameName("exer_groundBg.png")
                                local firstValueSp = CCSprite:createWithSpriteFrameName("positiveHead.png")
                                firstValueSp:setPosition(groundBg:getContentSize().width / 2, groundBg:getContentSize().height / 2)
                                firstValueSp:setScale((groundBg:getContentSize().width - 10) / firstValueSp:getContentSize().width)
                                groundBg:addChild(firstValueSp)
                                groundBg:setAnchorPoint(ccp(1, 1))
                                groundBg:setPosition(heroIcon:getContentSize().width, heroIcon:getContentSize().height)
                                groundBg:setScale(1.3)
                                heroIcon:addChild(groundBg)
                            end
                            local function checkCallback()
                                if tv and tv:getIsScrolled() == true then
                                    do return end
                                end
                                if G_checkClickEnable() == false then
                                    do return end
                                else
                                    base.setWaitTime = G_getCurDeviceMillTime()
                                end
                                PlayEffect(audioCfg.mouseClick)
                                require "luascript/script/game/scene/gamedialog/heroDialog/heroShareSmallDialog"
                            heroShareSmallDialog:showHeroInfoSmallDialog({name = getlocal("heroInfo")}, heroVoApi:exerWarHeroVo(heroTb), self.layerNum + 1, "TankInforPanel.png", CCRect(130, 50, 1, 1))
                            end
                            local itemScale = 0.9
                            local checkItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", checkCallback, nil, getlocal("alliance_list_check_info"), 24 / itemScale)
                            checkItem:setScale(itemScale)
                            checkItem:setAnchorPoint(ccp(0.5, 1))
                            local checkMenu = CCMenu:createWithItem(checkItem)
                            checkMenu:setPosition(heroIcon:getContentSize().width / 2, nameLb:getPositionY() - nameLb:getContentSize().height - 5)
                            checkMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                            heroIcon:addChild(checkMenu)
                        end
                        index = index + 1
                    end
                elseif sType == 3 then
                    local function onClickAITroops(aiTroopsIcon, i, isCanSelect)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        if prevSelectedIcon == aiTroopsIcon then
                            do return end
                        end
                        if isCanSelect == false then
                            do return end
                        end
                        if tolua.cast(prevSelectedIcon, "CCSprite") then
                            local iconSp = tolua.cast(prevSelectedIcon, "CCSprite")
                            local selectedBg = tolua.cast(iconSp:getChildByTag(335501), "CCSprite")
                            local selectedStatusSp = tolua.cast(iconSp:getChildByTag(335502), "CCSprite")
                            if selectedBg then
                                selectedBg:removeFromParentAndCleanup(true)
                                selectedBg = nil
                            end
                            if selectedStatusSp then
                                selectedStatusSp:removeFromParentAndCleanup(true)
                                selectedStatusSp = nil
                            end
                        end
                        local selectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                        selectedBg:setContentSize(aiTroopsIcon:getContentSize())
                        selectedBg:setPosition(aiTroopsIcon:getContentSize().width / 2, aiTroopsIcon:getContentSize().height / 2)
                        selectedBg:setOpacity(120)
                        aiTroopsIcon:addChild(selectedBg, 10)
                        local selectedStatusSp = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                        selectedStatusSp:setPosition(aiTroopsIcon:getContentSize().width / 2, aiTroopsIcon:getContentSize().height / 2)
                        aiTroopsIcon:addChild(selectedStatusSp, 10)
                        selectedBg:setTag(335501)
                        selectedStatusSp:setTag(335502)
                        prevSelectedIcon = aiTroopsIcon
                        curSelectedIndex = i
                    end
                    local endIndex = (idx + 1) * 2
                    local startIndex = endIndex - 1
                    local index = 1
                    for i = startIndex, endIndex do
                        local aiTroopsTb = sData[i]
                        if aiTroopsTb and type(aiTroopsTb) == "table" then
                            local aid = aiTroopsTb[1]
                            local aiLevel = aiTroopsTb[2]
                            local aiGrade = aiTroopsTb[3]
                            local aiSkillLv = aiTroopsTb[4]
                            local troopsVo = AITroopsVoApi:createAITroopsVoByMirror({aid, aiLevel, aiGrade, aiSkillLv, aiSkillLv, nil, aiSkillLv})
                            local aiTroopsIcon
                            local limitTb = AITroopsVoApi:getLimitTroopsCfg(aid)
                            local conflictTb = AITroopsVoApi:troopsConflict(limitTb, haveSelectAITroopsTb)
                            local sizeOfConflictTable = SizeOfTable(conflictTb)
                            aiTroopsIcon = AITroopsVoApi:getAITroopsIcon(troopsVo, nil, function() onClickAITroops(aiTroopsIcon, i, sizeOfConflictTable == 0) end)
                            aiTroopsIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                            aiTroopsIcon:setPosition((cellWidth / 2) / 2 + (index - 1) * (cellWidth / 2), cellHeight - aiTroopsIcon:getContentSize().height / 2)
                            cell:addChild(aiTroopsIcon)
                            if sizeOfConflictTable ~= 0 then
                                local cannotUseTroopsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                                cannotUseTroopsIcon:setContentSize(aiTroopsIcon:getContentSize())
                                cannotUseTroopsIcon:setOpacity(120)
                                cannotUseTroopsIcon:setPosition(getCenterPoint(aiTroopsIcon))
                                aiTroopsIcon:addChild(cannotUseTroopsIcon, 500)
                                local lbBg = CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
                                lbBg:setPosition(getCenterPoint(aiTroopsIcon))
                                aiTroopsIcon:addChild(lbBg, 500)
                                local fontSize
                                if G_isAsia() then
                                    fontSize = 20
                                else
                                    fontSize = 16
                                    lbBg:setScaleY(2)
                                end
                                local str = AITroopsVoApi:getLimitDes(nil, conflictTb)
                                local limitDes = GetTTFLabelWrap(str, fontSize, CCSizeMake(aiTroopsIcon:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                                limitDes:setPosition(getCenterPoint(aiTroopsIcon))
                                aiTroopsIcon:addChild(limitDes, 999)
                            end
                            local function showInfo()
                                if tv and tv:getIsScrolled() == true then
                                    do return end
                                end
                                AITroopsVoApi:showTroopsInfoDialog(troopsVo, false, self.layerNum + 1)
                            end
                            local pos = ccp(aiTroopsIcon:getContentSize().width - 57 * 0.5, aiTroopsIcon:getContentSize().height - 57 * 0.5 - 60)
                            G_addMenuInfo(aiTroopsIcon, self.layerNum, pos, nil, nil, 0.7, nil, showInfo, true, 3)
                        end
                        index = index + 1
                    end
                elseif sType == 4 then
                    local function onClickEmblem(emblemIcon, i)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        if prevSelectedIcon == emblemIcon then
                            do return end
                        end
                        if tolua.cast(prevSelectedIcon, "CCSprite") then
                            local iconSp = tolua.cast(prevSelectedIcon, "CCSprite")
                            local selectedBg = tolua.cast(iconSp:getChildByTag(335501), "CCSprite")
                            local selectedStatusSp = tolua.cast(iconSp:getChildByTag(335502), "CCSprite")
                            if selectedBg then
                                selectedBg:removeFromParentAndCleanup(true)
                                selectedBg = nil
                            end
                            if selectedStatusSp then
                                selectedStatusSp:removeFromParentAndCleanup(true)
                                selectedStatusSp = nil
                            end
                        end
                        local selectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                        selectedBg:setContentSize(emblemIcon:getContentSize())
                        selectedBg:setPosition(emblemIcon:getContentSize().width / 2, emblemIcon:getContentSize().height / 2)
                        selectedBg:setOpacity(120)
                        emblemIcon:addChild(selectedBg, 10)
                        local selectedStatusSp = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                        selectedStatusSp:setPosition(emblemIcon:getContentSize().width / 2, emblemIcon:getContentSize().height / 2)
                        emblemIcon:addChild(selectedStatusSp, 10)
                        selectedBg:setTag(335501)
                        selectedStatusSp:setTag(335502)
                        prevSelectedIcon = emblemIcon
                        curSelectedIndex = i
                    end
                    local endIndex = (idx + 1) * 3
                    local startIndex = endIndex - 2
                    local index = 1
                    for i = startIndex, endIndex do
                        local eid = sData[i]
                        if eid and eid ~= "" then
                            local emblemIcon
                            local eCfg = emblemListCfg.equipListCfg[eid]
                            emblemIcon = emblemVoApi:getEquipIcon(eid, function() onClickEmblem(emblemIcon, i) end, nil, nil, eCfg.qiangdu)
                            emblemIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                            emblemIcon:setScale(((cellWidth - 15 * 3) / 3) / emblemIcon:getContentSize().width)
                            local startPosX = (cellWidth - (emblemIcon:getContentSize().width * emblemIcon:getScale() * 3 + (3 - 1) * 15)) / 2 + emblemIcon:getContentSize().width * emblemIcon:getScale() / 2
                            emblemIcon:setPosition(startPosX + (index - 1) * (emblemIcon:getContentSize().width * emblemIcon:getScale() + 15), cellHeight - emblemIcon:getContentSize().height * emblemIcon:getScale() / 2)
                            cell:addChild(emblemIcon)
                            local function showInfo()
                                if tv and tv:getIsScrolled() == true then
                                    do return end
                                end
                                local eVo = emblemVo:new(eCfg)
                                eVo:initWithData(eid, 0)
                                emblemVoApi:showInfoDialog(eVo, self.layerNum + 1)
                            end
                            local pos = ccp(emblemIcon:getContentSize().width - 57 * 0.5, emblemIcon:getContentSize().height - 57 * 0.5)
                            G_addMenuInfo(emblemIcon, self.layerNum, pos, nil, nil, 1, nil, showInfo, true, 3)
                        end
                        index = index + 1
                    end
                elseif sType == 5 then
                    local function onClickPlane(planeIcon, i)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        if prevSelectedIcon == planeIcon then
                            do return end
                        end
                        if tolua.cast(prevSelectedIcon, "CCSprite") then
                            local iconSp = tolua.cast(prevSelectedIcon, "CCSprite")
                            local selectedBg = tolua.cast(iconSp:getChildByTag(335501), "CCSprite")
                            local selectedStatusSp = tolua.cast(iconSp:getChildByTag(335502), "CCSprite")
                            if selectedBg then
                                selectedBg:removeFromParentAndCleanup(true)
                                selectedBg = nil
                            end
                            if selectedStatusSp then
                                selectedStatusSp:removeFromParentAndCleanup(true)
                                selectedStatusSp = nil
                            end
                        end
                        local selectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                        selectedBg:setContentSize(planeIcon:getContentSize())
                        selectedBg:setPosition(planeIcon:getContentSize().width / 2, planeIcon:getContentSize().height / 2)
                        selectedBg:setOpacity(120)
                        planeIcon:addChild(selectedBg, 10)
                        local selectedStatusSp = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                        selectedStatusSp:setPosition(planeIcon:getContentSize().width / 2, planeIcon:getContentSize().height / 2)
                        planeIcon:addChild(selectedStatusSp, 10)
                        selectedBg:setTag(335501)
                        selectedStatusSp:setTag(335502)
                        prevSelectedIcon = planeIcon
                        curSelectedIndex = i
                    end
                    local endIndex = (idx + 1) * 2
                    local startIndex = endIndex - 1
                    local index = 1
                    for i = startIndex, endIndex do
                        local planeId = sData[1][i]
                        if planeId then
                            local planeIcon
                            planeIcon = planeVoApi:getPlaneIcon(planeId, planeCfg.plane[planeId].strength, function() onClickPlane(planeIcon, i) end)
                            planeIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
                            planeIcon:setPosition((cellWidth / 2) / 2 + (index - 1) * (cellWidth / 2), cellHeight - planeIcon:getContentSize().height / 2)
                            cell:addChild(planeIcon)
                        end
                        index = index + 1
                    end
                end
                return cell
            elseif fn == "ccTouchBegan" then
                return true
            elseif fn == "ccTouchMoved" then
            elseif fn == "ccTouchEnded" then
            end
        end
        local tvHeight, tvPosY = self.bgSize.height - 155, 85
        if sType == 2 then
            tvHeight = self.bgSize.height - 100
            tvPosY = 25
        elseif sType == 5 then
            tvHeight = self.bgSize.height - 305
            tvPosY = 235
        end
        local hd = LuaEventHandler:createHandler(function(...) return tvCallBack(...) end)
        tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.bgSize.width - 30, tvHeight), nil)
        tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
        tv:setPosition(ccp(15, tvPosY))
        self.bgLayer:addChild(tv)
        tv:setMaxDisToBottomOrTop(120)
        
        local sPrevSelectedIcon, sCurSelectedIndex
        if sType == 5 then
            local sSize = SizeOfTable(sData[2] or {})
            local sTv
            local function sTvCallBack(handler, fn, idx, cel)
                if fn == "numberOfCellsInTableView" then
                    return sSize
                elseif fn == "tableCellSizeForIndex" then
                    return CCSizeMake(150, 145)
                elseif fn == "tableCellAtIndex" then
                    local cell = CCTableViewCell:new()
                    cell:autorelease()
                    local function onClickPlaneSkill(planeSkillIcon, i)
                        if sTv and sTv:getIsScrolled() == true then
                            do return end
                        end
                        if sPrevSelectedIcon == planeSkillIcon then
                            do return end
                        end
                        if tolua.cast(sPrevSelectedIcon, "CCSprite") then
                            local iconSp = tolua.cast(sPrevSelectedIcon, "CCSprite")
                            local selectedBg = tolua.cast(iconSp:getChildByTag(335501), "CCSprite")
                            local selectedStatusSp = tolua.cast(iconSp:getChildByTag(335502), "CCSprite")
                            if selectedBg then
                                selectedBg:removeFromParentAndCleanup(true)
                                selectedBg = nil
                            end
                            if selectedStatusSp then
                                selectedStatusSp:removeFromParentAndCleanup(true)
                                selectedStatusSp = nil
                            end
                        end
                        local selectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function()end)
                        selectedBg:setContentSize(CCSizeMake(planeSkillIcon:getContentSize().width + 20, planeSkillIcon:getContentSize().height))
                        selectedBg:setPosition(planeSkillIcon:getContentSize().width / 2, planeSkillIcon:getContentSize().height / 2)
                        selectedBg:setOpacity(120)
                        planeSkillIcon:addChild(selectedBg, 10)
                        local selectedStatusSp = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                        selectedStatusSp:setPosition(planeSkillIcon:getContentSize().width / 2, planeSkillIcon:getContentSize().height / 2)
                        planeSkillIcon:addChild(selectedStatusSp, 10)
                        selectedBg:setTag(335501)
                        selectedStatusSp:setTag(335502)
                        sPrevSelectedIcon = planeSkillIcon
                        sCurSelectedIndex = i
                    end
                    local cellWidth, cellHeight = 150, 145
                    local planeSkillId = sData[2][idx + 1]
                    local psIconSize = 100
                    local planeSkillIcon
                    planeSkillIcon = planeVoApi:getSkillIcon(planeSkillId, psIconSize, function() onClickPlaneSkill(planeSkillIcon, idx + 1) end)
                    planeSkillIcon:setTouchPriority( - (self.layerNum - 1) * 20 - 6)
                    planeSkillIcon:setPosition(cellWidth / 2, cellHeight - psIconSize / 2 - 5)
                    cell:addChild(planeSkillIcon)
                    local psName = planeVoApi:getSkillInfoById(planeSkillId, true)
                    local nameLb = GetTTFLabelWrap(psName, 20, CCSizeMake(cellWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    local scfg, gcfg = planeVoApi:getSkillCfgById(planeSkillId)
                    local color = planeVoApi:getColorByQuality(gcfg.color)
                    nameLb:setColor(color)
                    nameLb:setAnchorPoint(ccp(0.5, 1))
                    nameLb:setPosition(planeSkillIcon:getContentSize().width / 2, - 5)
                    planeSkillIcon:addChild(nameLb)
                    local function showInfo()
                        if sTv and sTv:getIsScrolled() == true then
                            do return end
                        end
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local scfg, gcfg = planeVoApi:getSkillCfgById(planeSkillId)
                        local skillVo = planeSkillVo:new(scfg, gcfg)
                        skillVo:initWithData(planeSkillId, 0, 2)
                        planeVoApi:showInfoDialog(skillVo, self.layerNum + 1)
                    end
                    local tipItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
                    tipItem:setScale(0.7)
                    local tipMenu = CCMenu:createWithItem(tipItem)
                    tipMenu:setPosition(planeSkillIcon:getContentSize().width - tipItem:getContentSize().width * tipItem:getScale() / 2 + 10, planeSkillIcon:getContentSize().height - tipItem:getContentSize().height * tipItem:getScale() / 2)
                    tipMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 7)
                    planeSkillIcon:addChild(tipMenu)
                    return cell
                elseif fn == "ccTouchBegan" then
                    return true
                elseif fn == "ccTouchMoved" then
                elseif fn == "ccTouchEnded" then
                end
            end
            local sHd = LuaEventHandler:createHandler(function(...) return sTvCallBack(...) end)
            sTv = LuaCCTableView:createHorizontalWithEventHandler(sHd, CCSizeMake(self.bgSize.width - 30, 145), nil)
            sTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 8)
            sTv:setPosition(ccp(15, 85))
            self.bgLayer:addChild(sTv, 1)
            sTv:setMaxDisToBottomOrTop(120)
        end
        
        if sType ~= 2 then
            local function onClickHandler(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                if tag == 10 then
                    if sType == 5 then
                        if (not curSelectedIndex) then
                            G_showTipsDialog(getlocal("plane_set_troops_prompt"))
                            do return end
                        end
                        if (not sCurSelectedIndex) then
                            G_showTipsDialog(getlocal("skill_merge_prompt"))
                            do return end
                        end
                        closeDialog()
                        if type(selectedCallback) == "function" then
                            selectedCallback({sData[1][curSelectedIndex], sData[2][sCurSelectedIndex]})
                        end
                    else
                        if curSelectedIndex then
                            closeDialog()
                            if type(selectedCallback) == "function" then
                                selectedCallback(sData[curSelectedIndex])
                            end
                        else
                            if sType == 3 then
                                G_showTipsDialog(getlocal("aitroops_select_null2"))
                            elseif sType == 4 then
                                G_showTipsDialog(getlocal("emblem_set_troops_prompt"))
                            end
                        end
                    end
                elseif tag == 11 then
                    closeDialog()
                end
            end
            local btnScale, btnFontSize = 0.7, 24
            local sureBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("confirm"), btnFontSize / btnScale)
            local cancelBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onClickHandler, 11, getlocal("cancel"), btnFontSize / btnScale)
            local menuArr = CCArray:create()
            menuArr:addObject(sureBtn)
            menuArr:addObject(cancelBtn)
            local btnMenu = CCMenu:createWithArray(menuArr)
            btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 9)
            btnMenu:setPosition(ccp(0, 0))
            self.bgLayer:addChild(btnMenu)
            sureBtn:setScale(btnScale)
            cancelBtn:setScale(btnScale)
            sureBtn:setPosition(self.bgSize.width / 2 + sureBtn:getContentSize().width * btnScale / 2 + 50, sureBtn:getContentSize().height * btnScale / 2 + 25)
            cancelBtn:setPosition(self.bgSize.width / 2 - cancelBtn:getContentSize().width * btnScale / 2 - 50, cancelBtn:getContentSize().height * btnScale / 2 + 25)
        end

        --添加上下屏蔽层
        local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
        upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        upShiedldBg:setAnchorPoint(ccp(0.5, 0))
        upShiedldBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 68)
        upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
        upShiedldBg:setOpacity(0)
        self.bgLayer:addChild(upShiedldBg)
        local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
        downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        downShiedldBg:setAnchorPoint(ccp(0.5, 1))
        downShiedldBg:setPosition(self.bgSize.width / 2, 10)
        if sType == 5 then
            downShiedldBg:setPositionY(tvPosY)
        end
        downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
        downShiedldBg:setOpacity(0)
        self.bgLayer:addChild(downShiedldBg)
    end
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function exerWarSmallDialog:showReportList(layerNum, titleStr, reportData, reportTitleStr, isShowPraise)
    local sd = exerWarSmallDialog:new()
    sd:initReportList(layerNum, titleStr, reportData, reportTitleStr, isShowPraise)
end

function exerWarSmallDialog:initReportList(layerNum, titleStr, reportData, reportTitleStr, isShowPraise)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()

    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    self.bgSize = CCSizeMake(560, 650)
    G_addResource8888(function()
            spriteController:addPlist("public/youhuaUI3.plist")
            spriteController:addTexture("public/youhuaUI3.png")
            spriteController:addPlist("public/youhuaUI4.plist")
            spriteController:addTexture("public/youhuaUI4.png")
    end)
    spriteController:addPlist("serverWar/serverWar.plist")
    local function closeDialog()
        self:close()
        spriteController:removePlist("public/youhuaUI3.plist")
        spriteController:removeTexture("public/youhuaUI3.png")
        spriteController:removePlist("public/youhuaUI4.plist")
        spriteController:removeTexture("public/youhuaUI4.png")
        spriteController:removePlist("serverWar/serverWar.plist")
        spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - (isShowPraise and 165 or 115)))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 80)
    self.bgLayer:addChild(tvBg)



    local listTitleHeight = 50
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - 6)
    local tv = G_createTableView(tvSize, SizeOfTable(reportData), function(idx, cellNum)
        local cellHeight = 130
        if idx == 0 then
            cellHeight = cellHeight + listTitleHeight
        end
        return CCSizeMake(tvSize.width, cellHeight)
    end, function(cell, cellSize, idx, cellNum)
        local report = reportData[idx + 1]
        local aName = report.attInfo[1] or ""
        local dName = report.defInfo[1] or ""
        local isVictory = (report.report.r == 1)
        local attBg, defBg
        local attStatusLb, defStatusLb
        local attStatusSp, defStatusSp
        local fontSize = 22
        if isVictory == true then
            attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
            attBg:setRotation(180)
            defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
            attStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
            defStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
            attStatusLb:setColor(G_ColorGreen)
            defStatusLb:setColor(G_ColorRed)
            attStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
            defStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
        else
            attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
            attBg:setFlipX(true)
            defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
            defBg:setFlipY(true)
            attStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
            defStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
            attStatusLb:setColor(G_ColorRed)
            defStatusLb:setColor(G_ColorGreen)
            attStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
            defStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
        end
        if idx == 0 then
            cellSize.height = cellSize.height - listTitleHeight
            local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
            vsSp:setAnchorPoint(ccp(0.5, 0.5))
            vsSp:setScale(30 / vsSp:getContentSize().height)
            vsSp:setPosition(cellSize.width / 2, cellSize.height + listTitleHeight / 2)
            cell:addChild(vsSp)
            local myNameLb = GetTTFLabel(aName, 22)
            myNameLb:setAnchorPoint(ccp(0.5, 0.5))
            myNameLb:setPosition(cellSize.width / 2 - (cellSize.width / 2 - 20) / 2 - 15, vsSp:getPositionY())
            cell:addChild(myNameLb)
            local dfNameLb = GetTTFLabel(dName, 22)
            dfNameLb:setAnchorPoint(ccp(0.5, 0.5))
            dfNameLb:setPosition(cellSize.width / 2 + (cellSize.width / 2 - 20) / 2 + 15, vsSp:getPositionY())
            cell:addChild(dfNameLb)
        end
        local bgWidth, bgHeight = cellSize.width / 2 - 20, cellSize.height - 10
        local bgPosY = bgHeight / 2
        attBg:setScaleX(bgWidth / attBg:getContentSize().width)
        attBg:setScaleY(bgHeight / attBg:getContentSize().height)
        defBg:setScaleX(bgWidth / defBg:getContentSize().width)
        defBg:setScaleY(bgHeight / defBg:getContentSize().height)
        attBg:setPosition(cellSize.width / 2 - bgWidth / 2 - 15, bgPosY)
        defBg:setPosition(cellSize.width / 2 + bgWidth / 2 + 15, bgPosY)
        cell:addChild(attBg)
        cell:addChild(defBg)
        attStatusLb:setAnchorPoint(ccp(0.5, 1))
        attStatusLb:setPosition(attBg:getPositionX() - 10, attBg:getPositionY() + bgHeight / 2 - 5)
        cell:addChild(attStatusLb)
        defStatusLb:setAnchorPoint(ccp(0.5, 1))
        defStatusLb:setPosition(defBg:getPositionX() + 10, defBg:getPositionY() + bgHeight / 2 - 5)
        cell:addChild(defStatusLb)
        attStatusSp:setAnchorPoint(ccp(0.5, 0))
        attStatusSp:setPosition(attBg:getPositionX() - 10, attBg:getPositionY() - bgHeight / 2 + 5)
        cell:addChild(attStatusSp)
        defStatusSp:setAnchorPoint(ccp(0.5, 0))
        defStatusSp:setPosition(defBg:getPositionX() + 10, defBg:getPositionY() - bgHeight / 2 + 5)
        cell:addChild(defStatusSp)

        local function onClickCamera(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            exerWarVoApi:showReportDetail(self.layerNum + 1, nil, nil, report, reportTitleStr)
        end
        local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
        local cameraMenu = CCMenu:createWithItem(cameraBtn)
        cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
        cameraMenu:setPosition(0, 0)
        cameraBtn:setPosition(cellSize.width / 2, bgPosY)
        cell:addChild(cameraMenu)
    end)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    tv:setPosition(ccp(3, 3))
    tvBg:addChild(tv)

    --[[
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - 6)
    local tv = G_createTableView(tvSize, SizeOfTable(reportData or {}), CCSizeMake(tvSize.width, 175), function(cell, cellSize, idx, cellNum)
        local report = reportData[idx + 1]
        local aName = report.attInfo[1] or ""
        local dName = report.defInfo[1] or ""
        local isVictory = (report.report.r == 1)
        local attBg, defBg
        local attStatusLb, defStatusLb
        local attStatusSp, defStatusSp
        local fontSize = 22
        if isVictory == true then
            attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
            attBg:setRotation(180)
            defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
            attStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
            defStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
            attStatusLb:setColor(G_ColorGreen)
            defStatusLb:setColor(G_ColorRed)
            attStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
            defStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
        else
            attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
            attBg:setFlipX(true)
            defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
            defBg:setFlipY(true)
            attStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
            defStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
            attStatusLb:setColor(G_ColorRed)
            defStatusLb:setColor(G_ColorGreen)
            attStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
            defStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
        end
        local bgWidth, bgHeight = cellSize.width / 2 - 10, cellSize.height - 50
        local bgPosY = bgHeight / 2
        attBg:setScaleX(bgWidth / attBg:getContentSize().width)
        attBg:setScaleY(bgHeight / attBg:getContentSize().height)
        defBg:setScaleX(bgWidth / defBg:getContentSize().width)
        defBg:setScaleY(bgHeight / defBg:getContentSize().height)
        attBg:setPosition(cellSize.width / 2 - bgWidth / 2 - 20, bgPosY)
        defBg:setPosition(cellSize.width / 2 + bgWidth / 2 + 20, bgPosY)
        cell:addChild(attBg)
        cell:addChild(defBg)
        attStatusLb:setAnchorPoint(ccp(0.5, 1))
        attStatusLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2 - 5)
        cell:addChild(attStatusLb)
        defStatusLb:setAnchorPoint(ccp(0.5, 1))
        defStatusLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2 - 5)
        cell:addChild(defStatusLb)
        attStatusSp:setAnchorPoint(ccp(0.5, 0))
        attStatusSp:setPosition(attBg:getPositionX(), attBg:getPositionY() - bgHeight / 2)
        cell:addChild(attStatusSp)
        defStatusSp:setAnchorPoint(ccp(0.5, 0))
        defStatusSp:setPosition(defBg:getPositionX(), defBg:getPositionY() - bgHeight / 2)
        cell:addChild(defStatusSp)

        local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
        vsSp:setAnchorPoint(ccp(0.5, 0))
        vsSp:setScale(0.3)
        vsSp:setPosition(cellSize.width / 2, attBg:getPositionY() + bgHeight / 2)
        cell:addChild(vsSp)

        local attNameLb = GetTTFLabel(aName, fontSize)
        attNameLb:setAnchorPoint(ccp(0.5, 0))
        attNameLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2)
        cell:addChild(attNameLb)
        local defNameLb = GetTTFLabel(dName, fontSize)
        defNameLb:setAnchorPoint(ccp(0.5, 0))
        defNameLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2)
        cell:addChild(defNameLb)

        local function onClickCamera(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            exerWarVoApi:showReportDetail(self.layerNum + 1, nil, nil, report, reportTitleStr)
        end
        local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
        local cameraMenu = CCMenu:createWithItem(cameraBtn)
        cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
        cameraMenu:setPosition(0, 0)
        cameraBtn:setPosition(cellSize.width / 2, bgPosY)
        cell:addChild(cameraMenu)
    end)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    tv:setPosition(ccp(3, 3))
    tvBg:addChild(tv)
    --]]

    if isShowPraise == true then
        local praiseBtn
        local function onClickPraise(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            exerWarVoApi:requestPraise(function()
                G_showTipsDialog(getlocal("exerwar_praiseSuccessTipsText", {exerWarVoApi:getPraiseScore()}))
                if praiseBtn then
                    praiseBtn:setEnabled(exerWarVoApi:isCanPraise())
                end
            end)
        end
        praiseBtn = GetButtonItem("newPraiseBtn.png", "newPraiseBtn_Down.png", "newPraiseBtn.png", onClickPraise)
        local praiseMenu = CCMenu:createWithItem(praiseBtn)
        praiseMenu:setPosition(0, 0)
        self.bgLayer:addChild(praiseMenu)
        praiseBtn:setAnchorPoint(ccp(1, 0.5))
        praiseBtn:setPosition(tvBg:getPositionX() + tvBg:getContentSize().width / 2, 20 + praiseBtn:getContentSize().height / 2)
        praiseBtn:setEnabled(exerWarVoApi:isCanPraise())
        local praiseLb = GetTTFLabelWrap(getlocal("exerwar_praiseDescText"), 20, CCSizeMake(tvBg:getContentSize().width - praiseBtn:getContentSize().width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        praiseLb:setAnchorPoint(ccp(0, 0.5))
        praiseLb:setPosition(tvBg:getPositionX() - tvBg:getContentSize().width / 2, praiseBtn:getPositionY())
        self.bgLayer:addChild(praiseLb)
    end

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function exerWarSmallDialog:showScoreDetail(layerNum, titleStr)
    local sd = exerWarSmallDialog:new()
    sd:initScoreDetail(layerNum, titleStr)
end

function exerWarSmallDialog:initScoreDetail(layerNum, titleStr)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    self.bgSize = CCSizeMake(560, 700)
    local function closeDialog()
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local descLb = GetTTFLabelWrap(getlocal("exerwar_scoreDetailTipsDescText", {exerWarVoApi:getWinNum(1)}), 22, CCSizeMake(self.bgSize.width - 80, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0.5, 1))
    descLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 80)
    descLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(descLb)

    local pointInfo = exerWarVoApi:getPointInfo()
    local periodNum = 5
    local rowHeight = 55
    local bgSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function()end)
    bgSp1:setContentSize(CCSizeMake(self.bgSize.width - 60, rowHeight * periodNum))
    bgSp1:setAnchorPoint(ccp(0.5, 1))
    bgSp1:setPosition(self.bgSize.width / 2, descLb:getPositionY() - descLb:getContentSize().height - 10)
    self.bgLayer:addChild(bgSp1)
    local rankScore, maxIndexTb = exerWarVoApi:getRankScore()
    for i = 1, periodNum do
        local score = 0
        if pointInfo and pointInfo["d" .. i] then
            score = pointInfo["d" .. i]
        end
        local periodLb = GetTTFLabel(getlocal("serverwar_roundIndex", {i}), 22)
        local scoreLb = GetTTFLabel(tostring(score), 22)
        periodLb:setPosition(bgSp1:getContentSize().width * 0.2, bgSp1:getContentSize().height - (i - 1) * rowHeight - rowHeight / 2)
        scoreLb:setPosition(bgSp1:getContentSize().width * 0.83, periodLb:getPositionY())
        bgSp1:addChild(periodLb)
        bgSp1:addChild(scoreLb)
        if maxIndexTb then
            for k, v in pairs(maxIndexTb) do
                if v == "d" .. i then
                    scoreLb:setColor(G_ColorRed)
                    break
                end
            end
        end
        if i < periodNum then
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            lineSp:setContentSize(CCSizeMake(bgSp1:getContentSize().width - 20, 4))
            lineSp:setPosition(bgSp1:getContentSize().width / 2, periodLb:getPositionY() - rowHeight / 2)
            bgSp1:addChild(lineSp)
        end
    end
    local titleLb2 = GetTTFLabel(getlocal("exerwar_serverFirstText"), 22)
    titleLb2:setColor(G_ColorYellowPro)
    titleLb2:setAnchorPoint(ccp(0.5, 1))
    titleLb2:setPosition(self.bgSize.width / 2, bgSp1:getPositionY() - bgSp1:getContentSize().height - 10)
    self.bgLayer:addChild(titleLb2)
    local bgSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function()end)
    bgSp2:setContentSize(CCSizeMake(self.bgSize.width - 60, rowHeight))
    bgSp2:setAnchorPoint(ccp(0.5, 1))
    bgSp2:setPosition(self.bgSize.width / 2, titleLb2:getPositionY() - titleLb2:getContentSize().height - 10)
    self.bgLayer:addChild(bgSp2)
    local periodLb2 = GetTTFLabel(getlocal("exerwar_rankStr2"), 22)
    local score = 0
    if pointInfo and pointInfo["d6"] then
        score = pointInfo["d6"]
    end
    local scoreLb2 = GetTTFLabel(tostring(score), 22)
    periodLb2:setPosition(bgSp2:getContentSize().width * 0.2, bgSp2:getContentSize().height / 2)
    scoreLb2:setPosition(bgSp2:getContentSize().width * 0.83, periodLb2:getPositionY())
    bgSp2:addChild(periodLb2)
    bgSp2:addChild(scoreLb2)

    local titleLb3 = GetTTFLabel(getlocal("exerwar_serverFinalText"), 22)
    titleLb3:setColor(G_ColorYellowPro)
    titleLb3:setAnchorPoint(ccp(0.5, 1))
    titleLb3:setPosition(self.bgSize.width / 2, bgSp2:getPositionY() - bgSp2:getContentSize().height - 10)
    self.bgLayer:addChild(titleLb3)
    local bgSp3 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function()end)
    bgSp3:setContentSize(CCSizeMake(self.bgSize.width - 60, rowHeight))
    bgSp3:setAnchorPoint(ccp(0.5, 1))
    bgSp3:setPosition(self.bgSize.width / 2, titleLb3:getPositionY() - titleLb3:getContentSize().height - 10)
    self.bgLayer:addChild(bgSp3)
    local periodLb3 = GetTTFLabel(getlocal("exerwar_finals_serverPvp"), 22)
    local score = 0
    if pointInfo and pointInfo["d7"] then
        score = pointInfo["d7"]
    end
    local scoreLb3 = GetTTFLabel(tostring(score), 22)
    periodLb3:setPosition(bgSp3:getContentSize().width * 0.2, bgSp3:getContentSize().height / 2)
    scoreLb3:setPosition(bgSp3:getContentSize().width * 0.83, periodLb3:getPositionY())
    bgSp3:addChild(periodLb3)
    bgSp3:addChild(scoreLb3)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function exerWarSmallDialog:showSelectRandomLineup(layerNum, btnCallback)
    local sd = exerWarSmallDialog:new()
    sd:initSelectRandomLineup(layerNum, btnCallback)
end

function exerWarSmallDialog:initSelectRandomLineup(layerNum, btnCallback)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    self.bgSize = CCSizeMake(400, 300)
    self.bgLayer = G_getNewDialogBg2(self.bgSize, layerNum, nil, getlocal("exerwar_randomTroopsText"), 28, nil, "Helvetica-bold")
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if type(btnCallback) == "function" then
            if tag == 10 then
                btnCallback(1)
            elseif tag == 11 then
                btnCallback(3)
            end
        end
        self:close()
    end
    local btnScale, btnFontSize = 1.0, 24
    local oneBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickHandler, 10, getlocal("exerwar_randomTroopsOneText"), btnFontSize / btnScale)
    local allBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickHandler, 11, getlocal("exerwar_randomTroopsAllText"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(oneBtn)
    menuArr:addObject(allBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    btnMenu:setPosition(ccp(0.5, 0.5))
    self.bgLayer:addChild(btnMenu)
    oneBtn:setScale(btnScale)
    allBtn:setScale(btnScale)
    oneBtn:setPosition(self.bgSize.width / 2, self.bgSize.height / 2 + oneBtn:getContentSize().height * btnScale / 2 + 15)
    allBtn:setPosition(self.bgSize.width / 2, self.bgSize.height / 2 - allBtn:getContentSize().height * btnScale / 2 - 15)

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

function exerWarSmallDialog:dispose()
    self = nil
end