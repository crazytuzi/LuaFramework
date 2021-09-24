exerWarTroopsLayer = {}

function exerWarTroopsLayer:new(layerNum, troopsNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.troopsNum = troopsNum
    self.lineupsData = nil
    self.curShowIndex = 1
    return nc
end

function exerWarTroopsLayer:init()
	if self.bgLayer then
		return self.bgLayer
	end
    self.bgLayer = CCNode:create()
    local bgHeight
    if G_getIphoneType() == G_iphone5 then
        bgHeight = 650
    elseif G_getIphoneType() == G_iphoneX then
        bgHeight = 680
    else --默认是 G_iphone4
        bgHeight = 580
    end
    self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, bgHeight))
    
    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png", CCRect(5, 5, 1, 1), function ()end)
    troopsBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, self.bgLayer:getContentSize().height - 80))
    troopsBg:setAnchorPoint(ccp(0.5, 0))
    troopsBg:setPosition(self.bgLayer:getContentSize().width / 2, 0)
    self.bgLayer:addChild(troopsBg)
    self.troopsBg = troopsBg
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((troopsBg:getContentSize().width) / lineSp:getContentSize().width)
    lineSp:setPosition(troopsBg:getContentSize().width / 2, troopsBg:getContentSize().height)
    troopsBg:addChild(lineSp)
    
    local frameOffestH = 0
    local leftFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg2:setPosition(ccp(0, troopsBg:getContentSize().height / 2 + frameOffestH))
    troopsBg:addChild(leftFrameBg2)
    local rightFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg2:setPosition(ccp(troopsBg:getContentSize().width, troopsBg:getContentSize().height / 2 + frameOffestH))
    troopsBg:addChild(rightFrameBg2)
    local leftFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg1:setPosition(ccp(0, troopsBg:getContentSize().height / 2 + frameOffestH))
    troopsBg:addChild(leftFrameBg1)
    local rightFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg1:setPosition(ccp(troopsBg:getContentSize().width, troopsBg:getContentSize().height / 2 + frameOffestH))
    troopsBg:addChild(rightFrameBg1)
    
    local spaceY
    if G_getIphoneType() == G_iphone5 then
        spaceY = 20
    elseif G_getIphoneType() == G_iphoneX then
        spaceY = 25
    else --默认是 G_iphone4
        spaceY = 5
    end
    self.selectBg = {}
    for i = 0, 1 do
        for j = 0, 2 do
            local index = (j + 1) + (i * 3)
            local selectBg = CCSprite:createWithSpriteFrameName("st_select1.png")
            selectBg:setPosition(troopsBg:getContentSize().width / 2 - 50 + (selectBg:getContentSize().width + 6) * (0.5 - i), troopsBg:getContentSize().height - 10 - (selectBg:getContentSize().height + spaceY) * j - selectBg:getContentSize().height / 2)
            troopsBg:addChild(selectBg)
            local nullIconSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
            nullIconSp:setPosition(selectBg:getContentSize().width / 2, selectBg:getContentSize().height / 2 - 10)
            nullIconSp:setScale(0.8)
            nullIconSp:setTag(1)
            selectBg:addChild(nullIconSp)
            local nullBgSp = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
            nullBgSp:setPosition(nullIconSp:getPositionX(), nullIconSp:getPositionY() - 35)
            nullBgSp:setScale(0.8)
            nullBgSp:setTag(2)
            selectBg:addChild(nullBgSp)
            local iconPosSp = CCSprite:createWithSpriteFrameName("tankPos" .. index .. ".png")
            iconPosSp:setPosition(nullIconSp:getPositionX(), nullIconSp:getPositionY() - 10)
            iconPosSp:setTag(3)
            selectBg:addChild(iconPosSp)
            local nameLb = GetTTFLabel(getlocal("fight_content_null"), 20)
            nameLb:setPosition(selectBg:getPositionX(), selectBg:getPositionY() + selectBg:getContentSize().height / 2 - 20)
            nameLb:setTag(50 + index)
            troopsBg:addChild(nameLb, 2)
            self.selectBg[index] = selectBg
        end
    end
    
    -- 显示舰队时的按钮
    local switchTankPic, switchHeroPic, switchAIPic = "st_showFleet.png", "st_showHero.png", "et_switchAI.png"
    if base.AITroopsSwitch == 1 then
        switchTankPic, switchHeroPic = "et_switchTank.png", "et_switchHero.png"
    end
    local switchSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showFleetSp1 = CCSprite:createWithSpriteFrameName(switchTankPic)
    showFleetSp1:setPosition(getCenterPoint(switchSp1))
    switchSp1:addChild(showFleetSp1)
    local switchSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showFleetSp2 = CCSprite:createWithSpriteFrameName(switchTankPic)
    showFleetSp2:setPosition(getCenterPoint(switchSp2))
    switchSp2:addChild(showFleetSp2)
    switchSp2:setScale(0.97)
    local menuItemSp1 = CCMenuItemSprite:create(switchSp1, switchSp2)
    
    -- 显示将领时的按钮
    local switchSp3 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showHeroSp1 = CCSprite:createWithSpriteFrameName(switchHeroPic)
    showHeroSp1:setPosition(getCenterPoint(switchSp3))
    switchSp3:addChild(showHeroSp1)
    local switchSp4 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showHeroSp2 = CCSprite:createWithSpriteFrameName(switchHeroPic)
    showHeroSp2:setPosition(getCenterPoint(switchSp4))
    switchSp4:addChild(showHeroSp2)
    switchSp4:setScale(0.97)
    local menuItemSp2 = CCMenuItemSprite:create(switchSp3, switchSp4)
    
    -- 显示AI部队的按钮
    local switchSp5 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showAITroopsSp1 = CCSprite:createWithSpriteFrameName(switchAIPic)
    showAITroopsSp1:setPosition(getCenterPoint(switchSp5))
    switchSp5:addChild(showAITroopsSp1)
    local switchSp6 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showAITroopsSp2 = CCSprite:createWithSpriteFrameName(switchAIPic)
    showAITroopsSp2:setPosition(getCenterPoint(switchSp6))
    switchSp6:addChild(showAITroopsSp2)
    switchSp6:setScale(0.97)
    local menuItemSp3 = CCMenuItemSprite:create(switchSp5, switchSp6)
    
    local changeItem = CCMenuItemToggle:create(menuItemSp1)
    if base.AITroopsSwitch == 1 then --AI部队功能已开启
        changeItem:addSubItem(menuItemSp3)
    end
    changeItem:addSubItem(menuItemSp2)
    changeItem:setAnchorPoint(CCPointMake(0, 0))
    changeItem:setPosition(ccp(troopsBg:getContentSize().width - changeItem:getContentSize().width - 15, troopsBg:getContentSize().height - changeItem:getContentSize().height - 10))
    local function changeHandler()
        if changeItem:getSelectedIndex() == 0 then
            self.curShowIndex = 1 --坦克部队
        else
            if base.AITroopsSwitch == 1 then
                if changeItem:getSelectedIndex() == 1 then
                    self.curShowIndex = 3 --AI部队
                else
                    self.curShowIndex = 2 --英雄将领
                end
            else
                self.curShowIndex = 2 --英雄将领
            end
        end
        self:setTroopsUI()
    end
    changeItem:registerScriptTapHandler(changeHandler)
    local changeMenu = CCMenu:create()
    changeMenu:addChild(changeItem)
    changeMenu:setAnchorPoint(ccp(0, 0))
    changeMenu:setPosition(ccp(0, 0))
    changeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    changeItem:setSelectedIndex(0)
    troopsBg:addChild(changeMenu, 1)

    self:setTroopsNumUI()
    
    self.equipMentPosY = troopsBg:getContentSize().height - 10 - 1 * spaceY - 2 * changeItem:getContentSize().height
    self.planeMenuPosY = troopsBg:getContentSize().height - 10 - 2 * spaceY - 3 * changeItem:getContentSize().height
    self:showEmptyEquipBtn()
    self:showEmptyPlaneBtn()

    if G_getIphoneType() ~= G_iphone4 then
        local tipFontSize = 18
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        	tipFontSize = 20
        elseif G_getCurChoseLanguage() =="de" then
        	tipFontSize = 13
        end
        local tipsLb = GetTTFLabelWrap(getlocal("emblem_set_troops_tips"), tipFontSize, CCSizeMake(troopsBg:getContentSize().width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        tipsLb:setAnchorPoint(ccp(0, 0.5))
        tipsLb:setPosition(25, 22)
        tipsLb:setColor(G_ColorRed)
        troopsBg:addChild(tipsLb)
    end
    
    self.touchLayer = CCLayer:create()
    self.touchLayer:setContentSize(self.bgLayer:getContentSize())
    self.touchLayer:registerScriptTouchHandler(function(...) return self:touchLayerEvent(...) end, false, - (self.layerNum - 1) * 20 - 3, true)
    self.touchLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.touchLayer:setTouchEnabled(true)
    self.bgLayer:addChild(self.touchLayer)
    
    return self.bgLayer
end

function exerWarTroopsLayer:setLineupsData(data)
    if data == nil then
        data = {{},{},{}}
    end
    if data then
        self.lineupsData = data
        local emblemId = self.lineupsData[4]
        if emblemId and emblemId ~= "" then
            --检测军徽带兵量
            local eCfg = emblemVoApi:getEquipCfgById(emblemId)
            if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then
                if self.lineupsData[1] then
                    for k, v in pairs(self.lineupsData[1]) do
                        if self.lineupsData[1][k] and self.lineupsData[1][k][2] then
                            self.lineupsData[1][k][2] = self.troopsNum + eCfg.attUp.troopsAdd
                        end
                    end
                    self:setTroopsNumUI(eCfg.attUp.troopsAdd)
                end
            end
            self:showSuperEquipBtn(emblemId)
        else
            self:showEmptyEquipBtn()
        end
        self:setTroopsUI()
        local planeId
        if self.lineupsData[5] and self.lineupsData[5][1] then
            planeId = self.lineupsData[5][1]
        end
        if planeId then
            self:showPlaneBtn(planeId)
        else
            self:showEmptyPlaneBtn()
        end
    end
end

function exerWarTroopsLayer:getLineupsData()
    return self.lineupsData
end

function exerWarTroopsLayer:touchLayerEvent(fn, x, y, touch)
    if fn == "began" then
        if self.touchRect == nil then
            local anchorPoint = self.bgLayer:getAnchorPoint()
            local startPosX = self.bgLayer:getPositionX() - self.bgLayer:getContentSize().width * anchorPoint.x
            local startPosY = self.bgLayer:getPositionY() - self.bgLayer:getContentSize().height * anchorPoint.y
            self.touchRect = CCRect(startPosX, startPosY, self.bgLayer:getContentSize().width, self.bgLayer:getContentSize().height)
        end
        if self.touchRect:containsPoint(ccp(x, y)) == true then
            if self.touchArray == nil then
                self.touchArray = {}
            end
            table.insert(self.touchArray, touch)
            if SizeOfTable(self.touchArray) > 1 then
                self.isMultTouch = true
                return false
            end
            if self.selectBg then
                for k, v in pairs(self.selectBg) do
                    local vPos = v:getParent():convertToWorldSpace(ccp(v:getPosition()))
                    local vAnchorPoint = v:getAnchorPoint()
                    local vRect = CCRect(vPos.x - v:getContentSize().width * vAnchorPoint.x, vPos.y - v:getContentSize().height * vAnchorPoint.y, v:getContentSize().width, v:getContentSize().height)
                    if vRect:containsPoint(ccp(x, y)) == true then
                        self.touchItemIndex = k
                        self.isTouchClick = true
                        if self.itemBg and self.itemBg[k] then
                            self.beganPos = ccp(x, y)
                            self.movePos = ccp(x, y)
                            v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.0), CCCallFunc:create(function()
                                    if self.touchEventType == 1 and self.touchItemIndex and self.itemBg and self.itemBg[self.touchItemIndex] then
                                        local itemBg = self.itemBg[self.touchItemIndex]
                                        self.touchEventType = 2
                                        itemBg:setScale(1.15)
                                        itemBg:getParent():reorderChild(itemBg, 5)
                                        self.isTouchClick = nil
                                    end
                            end)))
                            self.touchEventType = 1
                        end
                        break
                    end
                end
            end
            return true
        end
        return false
    elseif fn == "moved" then
        if self.isMultTouch == true then --多点触摸
            return
        end
        if self.touchItemIndex and self.itemBg and self.itemBg[self.touchItemIndex] then
            local curTouchPos = ccp(x, y)
            local moveDisPos = ccpSub(curTouchPos, self.movePos)
            local moveDisTem = ccpSub(curTouchPos, self.beganPos)
            --部分安卓设备可能存在灵敏度问题
            local offset = (G_isIOS() == false) and 13 or 30
            if math.abs(moveDisTem.y) + math.abs(moveDisTem.x) < offset then
                return
            end
            self.isTouchClick = nil
            local itemBg = self.itemBg[self.touchItemIndex]
            if self.touchEventType == 1 then
                itemBg:stopAllActions()
                self.touchEventType = 2
                itemBg:setScale(1.2)
                itemBg:getParent():reorderChild(itemBg, 5)
            elseif self.touchEventType == 2 then
                itemBg:setPosition(ccpAdd(ccp(itemBg:getPosition()), ccp(moveDisPos.x, moveDisPos.y)))
                self.movePos = curTouchPos
            end
        end
    elseif fn == "ended" then
        if self.touchItemIndex and self.itemBg and self.itemBg[self.touchItemIndex] then
            if self.isTouchClick == true then
                self.lineupsData[self.curShowIndex][self.touchItemIndex] = (self.curShowIndex == 1) and {} or 0
                self:setTroopsUI()
            else
                local itemBg = self.itemBg[self.touchItemIndex]
                if self.selectBg then
                    for k, v in pairs(self.selectBg) do
                        local vRect = CCRect(v:getPositionX() - 100, v:getPositionY() - v:getContentSize().height / 2, 200, v:getContentSize().height)
                        if self.touchItemIndex ~= k and vRect:containsPoint(ccp(itemBg:getPosition())) == true then
                            local temp = self.lineupsData[self.curShowIndex][self.touchItemIndex]
                            self.lineupsData[self.curShowIndex][self.touchItemIndex] = self.lineupsData[self.curShowIndex][k]
                            self.lineupsData[self.curShowIndex][k] = temp
                            self:setTroopsUI()
                            itemBg = nil
                            break
                        end
                    end
                end
                if itemBg then
                    itemBg:stopAllActions()
                    itemBg:setPosition(self.selectBg[self.touchItemIndex]:getPosition())
                    itemBg:getParent():reorderChild(itemBg, 1)
                    itemBg:setScale(1)
                end
            end
        elseif self.touchItemIndex and self.isTouchClick == true and self.selectBg and self.selectBg[self.touchItemIndex] then
            local vBg = self.selectBg[self.touchItemIndex]
            local vPos = vBg:getParent():convertToWorldSpace(ccp(vBg:getPosition()))
            local vAnchorPoint = vBg:getAnchorPoint()
            local vRect = CCRect(vPos.x - vBg:getContentSize().width * vAnchorPoint.x, vPos.y - vBg:getContentSize().height * vAnchorPoint.y, vBg:getContentSize().width, vBg:getContentSize().height)
            if vRect:containsPoint(ccp(x, y)) == true then
                if self.curShowIndex == 1 then
                    self:showSelectDialog(self.curShowIndex, self.touchItemIndex)
                else
                    if self.lineupsData and self.lineupsData[1] and self.lineupsData[1][self.touchItemIndex] and self.lineupsData[1][self.touchItemIndex][1] then
                        if self.curShowIndex == 2 then
                            self:showSelectDialog(self.curShowIndex, self.touchItemIndex)
                        elseif self.curShowIndex == 3 then
                            self:showSelectDialog(self.curShowIndex, self.touchItemIndex)
                        end
                    else
                        if self.curShowIndex == 2 then
                            G_showTipsDialog(getlocal("troops_no_tank"))
                        elseif self.curShowIndex == 3 then
                            G_showTipsDialog(getlocal("aitroops_equip_notank"))
                        end
                    end
                end
            end
        end
        self.touchEventType = nil
        self.touchItemIndex = nil
        self.beganPos = nil
        self.isTouchClick = nil
        self.touchArray = nil
        self.isMultTouch = nil
    else
        if self.touchItemIndex and self.itemBg and self.itemBg[self.touchItemIndex] then
            local itemBg = self.itemBg[self.touchItemIndex]
            itemBg:setPosition(self.selectBg[self.touchItemIndex]:getPosition())
            itemBg:getParent():reorderChild(itemBg, 1)
            itemBg:setScale(1)
        end
        self.touchEventType = nil
        self.touchItemIndex = nil
        self.beganPos = nil
        self.isTouchClick = nil
        self.touchArray = nil
        self.isMultTouch = nil
    end
end

function exerWarTroopsLayer:setTroopsUI()
    if self.itemBg then
        for k, v in pairs(self.itemBg) do
            v:removeFromParentAndCleanup(true)
        end
        self.itemBg = nil
    end
    self.itemBg = {}
    if self.selectBg then
        local tanksTb = self.lineupsData and self.lineupsData[1] or nil
        local heroTb = self.lineupsData and self.lineupsData[2] or nil
        local aiTroopsTb = self.lineupsData and self.lineupsData[3] or nil
        for k, v in pairs(self.selectBg) do
            local headName
            local headNameLb = tolua.cast(self.troopsBg:getChildByTag(50 + k), "CCLabelTTF")
            if headNameLb then
                headNameLb:setString(getlocal("fight_content_null"))
            end
            local heroMaxStar = 5
            for i = 1, heroMaxStar do
                local starSp = tolua.cast(self.troopsBg:getChildByTag(100 * k + i), "CCSprite")
                if starSp then
                    starSp:removeFromParentAndCleanup(true)
                    starSp = nil
                end
            end
            
            local nullIconSp = tolua.cast(v:getChildByTag(1), "CCSprite")
            if nullIconSp then
                nullIconSp:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("selectTankBg" .. ((self.curShowIndex == 2) and 3 or 1) .. ".png"))
            end
            
            local itemBg, itemIcon, iconSpace, itemName, itemNameColor, itemNum
            
            if tanksTb and tanksTb[k] then
                local tankId = tanksTb[k][1]
                if tankId then
                    tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                    local tankNum = tanksTb[k][2]
                    if self.curShowIndex == 1 then
                        itemBg = CCSprite:createWithSpriteFrameName("st_select2.png")
                        itemIcon = tankVoApi:getTankIconSp(tankId)--tankVoApi:getTankIconSpByBattleType(nil, tankId)
                        iconSpace = 0.6
                        itemName = getlocal(tankCfg[tankId].name)
                        itemNum = tankNum
                    else
                        headName = getlocal("item_type_number", {getlocal(tankCfg[tankId].name), tankNum})
                        headName = G_getPointStr(headName, v:getContentSize().width, 20)
                    end
                end
            end
            
            if self.curShowIndex == 1 then
                if heroTb and type(heroTb[k]) == "table" then
                    local hid = heroTb[k][1]
                    if hid and heroListCfg[hid] then
                        local heroLevel = heroTb[k][2] or 1
                        local heroStarLv = heroTb[k][3] or 1
                        headName = getlocal(heroListCfg[hid].heroName)
                        headName = "Lv." .. heroLevel .. " " .. headName
                        local starSize = 13
                        local starNum = heroStarLv
                        if starNum > heroMaxStar then
                            starNum = heroMaxStar
                        end
                        for i = 1, starNum do
                            local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                            starSp:setScale(starSize / starSp:getContentSize().width)
                            local px = v:getPositionX() - v:getContentSize().width / 2 + (v:getContentSize().width / 2 - starSize / 2 * (starNum - 1) + starSize * (i - 1))
                            local py = v:getPositionY() - v:getContentSize().height / 2 + (v:getContentSize().height - 5)
                            starSp:setPosition(px, py)
                            starSp:setTag(100 * k + i)
                            self.troopsBg:addChild(starSp, 2)
                        end
                    end
                end
            elseif self.curShowIndex == 2 then
                if heroTb and type(heroTb[k]) == "table" then
                    local hid = heroTb[k][1]
                    if hid and heroListCfg[hid] then
                        local heroLevel = heroTb[k][2] or 1
                        local heroStarLv = heroTb[k][3] or 1
                        itemBg = CCSprite:createWithSpriteFrameName("st_select2.png")
                        itemIcon = heroVoApi:getHeroIcon(hid, heroStarLv, nil, nil, nil, nil, nil, {showAjt = false})
                        iconSpace = 0.5
                        itemName = heroVoApi:getHeroName(hid)
                        itemNum = "LV." .. heroLevel
                    end
                end
            elseif self.curShowIndex == 3 then
                if aiTroopsTb and type(aiTroopsTb[k]) == "table" then
                    local aid = aiTroopsTb[k][1]
                    if aid and aid ~= 0 then
                        local aiLevel = aiTroopsTb[k][2]
                        local aiGrade = aiTroopsTb[k][3]
                        local aiSkillLv = aiTroopsTb[k][4]
                        itemBg = CCSprite:createWithSpriteFrameName("st_select2.png")
                        itemIcon = AITroopsVoApi:getAITroopsSimpleIcon(aid, aiLevel, aiGrade)
                        iconSpace = 90 / itemIcon:getContentSize().width
                        itemName, itemNameColor = AITroopsVoApi:getAITroopsNameStr(aid)
                        local troopsVo = AITroopsVoApi:createAITroopsVoByMirror({aid, aiLevel, aiGrade, aiSkillLv, aiSkillLv, nil, aiSkillLv})
                        itemNum = troopsVo:getTroopsStrength()
                    end
                end
            end
            if headName and headNameLb then
                headNameLb:setString(headName)
            end
            if itemBg then
                itemBg:setPosition(v:getPositionX(), v:getPositionY())
                self.troopsBg:addChild(itemBg, 1)
                if itemIcon then
                    itemIcon:setScale(iconSpace)
                    if self.curShowIndex == 2 then
                        itemIcon:setPosition(20 + itemIcon:getContentSize().width * iconSpace / 2, 25 + itemIcon:getContentSize().height * iconSpace / 2)
                    else
                        itemIcon:setPosition(10 + itemIcon:getContentSize().width * iconSpace / 2, 10 + itemIcon:getContentSize().height * iconSpace / 2)
                    end
                    itemBg:addChild(itemIcon)
                end
                local lbFontSize = 18
                if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" then
                    lbFontSize = 20
                end
                if itemName then
                    local itemNameLb = GetTTFLabelWrap(itemName, lbFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
                    itemNameLb:setAnchorPoint(ccp(0, 1))
                    if itemIcon then
                        itemNameLb:setPosition(itemIcon:getPositionX() + itemIcon:getContentSize().width * iconSpace / 2 + 3, itemIcon:getPositionY() + itemIcon:getContentSize().height * iconSpace / 2)
                        if self.curShowIndex == 2 then
                            itemNameLb:setPositionX(itemNameLb:getPositionX() + 7)
                        end
                    end
                    if itemNameColor then
                        itemNameLb:setColor(itemNameColor)
                    end
                    itemBg:addChild(itemNameLb)
                end
                if itemNum then
                    local itemNumLb = GetTTFLabel(itemNum, lbFontSize)
                    itemNumLb:setAnchorPoint(ccp(0, 0.5))
                    if itemIcon then
                        itemNumLb:setPosition(itemIcon:getPositionX() + itemIcon:getContentSize().width * iconSpace / 2 + 3, itemIcon:getPositionY() - itemIcon:getContentSize().height * iconSpace / 2 + 10)
                        if self.curShowIndex == 2 then
                            itemNumLb:setPositionX(itemNumLb:getPositionX() + 7)
                        end
                    end
                    itemBg:addChild(itemNumLb)
                end
                local deleteSp = CCSprite:createWithSpriteFrameName("IconFault.png")
                deleteSp:setAnchorPoint(ccp(1, 0))
                deleteSp:setScale(0.7)
                deleteSp:setPosition(itemBg:getContentSize().width - 8, 10)
                itemBg:addChild(deleteSp)
                self.itemBg[k] = itemBg
            end
        end
    end
    if self.curShowIndex == 1 then
        self:setBuffIcon()
    end
end

function exerWarTroopsLayer:setCanUseTroops(canUseTroops)
    self.canUseTroops = canUseTroops
end

--@troopsType : 1-坦克,2-将领,3-AI部队,4-军徽,5-飞机
function exerWarTroopsLayer:getCanUseTroops(troopsType)
    if self.canUseTroops then
        if troopsType == nil then
            return G_clone(self.canUseTroops)
        elseif self.canUseTroops[troopsType] then
            if self.lineupsData and self.lineupsData[troopsType] and (troopsType == 1 or troopsType == 2 or troopsType == 3) then
                local canUseData = {}
                for k, v in pairs(self.canUseTroops[troopsType]) do
                    local flag = true
                    for kk, vv in pairs(self.lineupsData[troopsType]) do
                        local canUseId, usedId
                        if type(v) == "table" then
                            canUseId = v[1]
                            if troopsType == 1 then
                                canUseId = tonumber(canUseId) or tonumber(RemoveFirstChar(canUseId))
                            end
                        end
                        if type(vv) == "table" then
                            usedId = vv[1] or 0
                            if troopsType == 1 then
                                usedId = tonumber(usedId) or tonumber(RemoveFirstChar(usedId))
                            end
                        end
                        if canUseId == usedId then
                            flag = false
                            break
                        end
                    end
                    if flag then
                        table.insert(canUseData, v)
                    end
                end
                return canUseData
            else
                return self.canUseTroops[troopsType]
            end
        end
    end
end

function exerWarTroopsLayer:setTroopsNumUI(extraTroopsNum)
	local label = tolua.cast(self.troopsNumLb, "CCLabelTTF")
	if label then
		label:removeFromParentAndCleanup(true)
		label = nil
	end
	self.troopsNumLb = nil
	extraTroopsNum = extraTroopsNum or 0
    local troopsNumStr = getlocal("player_leader_troop_num", {self.troopsNum})
    if extraTroopsNum > 0 then
        troopsNumStr = troopsNumStr .. "<rayimg>+" .. extraTroopsNum .. "<rayimg>"
    end
    local fontSize = 24
    local lbHieght = 0
    self.troopsNumLb, lbHieght = G_getRichTextLabel(troopsNumStr, {nil, G_ColorGreen, nil}, fontSize, self.troopsBg:getContentSize().width / 2, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.troopsNumLb:setAnchorPoint(ccp(0, 1))
    local offsetY
    if G_getIphoneType() == G_iphone5 then
        offsetY = 25
    elseif G_getIphoneType() == G_iphoneX then
        offsetY = 30
    else --默认是 G_iphone4
        offsetY = 15
    end
    self.troopsNumLb:setPosition(15, self.troopsBg:getContentSize().height + lbHieght + offsetY)
    self.troopsBg:addChild(self.troopsNumLb)
end

function exerWarTroopsLayer:setBuffIcon()
    if self.buffIconTb and SizeOfTable(self.buffIconTb) > 0 then
        for k, v in pairs(self.buffIconTb) do
            local buffIconSp = tolua.cast(v, "CCSprite")
            if buffIconSp then
                buffIconSp:removeFromParentAndCleanup(true)
                buffIconSp = nil
            end
        end
        self.buffIconTb = nil
    end
    if self.lineupsData and self.lineupsData[1] then
        local function onClickBuffIcon()
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            tankVoApi:showTankBuffSmallDialog("TankInforPanel.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), self.lineupsData[1], true, true, self.layerNum + 1, nil, true)
        end
        local offsetY
        if G_getIphoneType() == G_iphone5 then
            offsetY = 15
        elseif G_getIphoneType() == G_iphoneX then
            offsetY = 20
        else --默认是 G_iphone4
            offsetY = 5
        end
        local iconSize = 50
        local tmpTb = {}
        local index = 1
        for k, v in pairs(self.lineupsData[1]) do
            if v and v[1] and v[2] and v[2] > 0 then
                local tankId = tonumber(v[1]) or tonumber(RemoveFirstChar(v[1]))
                local buffType = tankCfg[tankId].buffShow[1]
                if buffType and tmpTb[buffType] == nil then
                    local buffIconSp = LuaCCSprite:createWithSpriteFrameName("tank_gh_icon_" .. buffType .. ".png", onClickBuffIcon)
                    local iconScale = iconSize / buffIconSp:getContentSize().width
                    buffIconSp:setScale(iconScale)
                    buffIconSp:setAnchorPoint(ccp(1, 0.5))
                    local px = self.troopsBg:getContentSize().width - 10 - (iconSize) * (index - 1)
                    buffIconSp:setPosition(px, self.troopsBg:getContentSize().height + buffIconSp:getContentSize().height * iconScale / 2 + offsetY)
                    buffIconSp:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
                    self.troopsBg:addChild(buffIconSp)
                    if self.buffIconTb == nil then
                        self.buffIconTb = {}
                    end
                    self.buffIconTb[index] = buffIconSp
                    index = index + 1
                    tmpTb[buffType] = 1
                end
            end
        end
        tmpTb = nil
    end
end

--显示空的军徽按钮
function exerWarTroopsLayer:showEmptyEquipBtn()
    local equipMenu = tolua.cast(self.troopsBg:getChildByTag(5645), "CCMenu")
    if equipMenu ~= nil then
        equipMenu:removeFromParentAndCleanup(true)
        equipMenu = nil
    end
    -- 普通状态
    local equipSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp1 = CCSprite:createWithSpriteFrameName("st_emptyShadow.png")
    showEquipSp1:setPosition(getCenterPoint(equipSp1))
    showEquipSp1:setScale(0.9)
    equipSp1:addChild(showEquipSp1)
    -- 加号
    local addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(getCenterPoint(showEquipSp1))
    showEquipSp1:addChild(addSp, 1)
    -- 忽隐忽现
    local fade1 = CCFadeTo:create(1, 55)
    local fade2 = CCFadeTo:create(1, 255)
    local seq = CCSequence:createWithTwoActions(fade1, fade2)
    local repeatEver = CCRepeatForever:create(seq)
    if self.notTouch == true then
        addSp:setVisible(false)
    else
        addSp:runAction(repeatEver)
    end
    
    -- 按下状态
    local equipSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp2 = CCSprite:createWithSpriteFrameName("st_emptyShadow.png")
    showEquipSp2:setPosition(getCenterPoint(equipSp2))
    showEquipSp2:setScale(0.9)
    equipSp2:addChild(showEquipSp2)
    equipSp2:setScale(0.97)
    -- 加号
    addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(getCenterPoint(showEquipSp2))
    showEquipSp2:addChild(addSp, 1)
    -- 忽隐忽现
    fade1 = CCFadeTo:create(1, 55)
    fade2 = CCFadeTo:create(1, 255)
    seq = CCSequence:createWithTwoActions(fade1, fade2)
    repeatEver = CCRepeatForever:create(seq)
    if self.notTouch == true then
        addSp:setVisible(false)
    else
        addSp:runAction(repeatEver)
    end
    
    local function equipBtnCallback()
        self:showSelectDialog(4)
    end
    local equipItem = CCMenuItemSprite:create(equipSp1, equipSp2)
    equipItem:registerScriptTapHandler(equipBtnCallback)
    equipItem:setAnchorPoint(ccp(0, 0))
    equipItem:setPosition(ccp(4, 6))
    
    equipMenu = CCMenu:createWithItem(equipItem)
    equipMenu:setTag(5645)
    equipMenu:setAnchorPoint(ccp(0, 0))
    equipMenu:setPosition(ccp(self.troopsBg:getContentSize().width - equipItem:getContentSize().width - 15, self.equipMentPosY - 12))
    equipMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    self.troopsBg:addChild(equipMenu, 1)

    if self.lineupsData then
        self.lineupsData[4] = nil
    end
end

--显示带有军徽的按钮
function exerWarTroopsLayer:showSuperEquipBtn(emblemId)
    local equipMenu = tolua.cast(self.troopsBg:getChildByTag(5645), "CCMenu")
    if equipMenu ~= nil then
        equipMenu:removeFromParentAndCleanup(true)
        equipMenu = nil
    end
    -- 带有军徽的按钮1
    local equipSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp1 = emblemVoApi:getEquipIconNoBg(emblemId, 18, 145, nil, 0)
    showEquipSp1:setScale((equipSp1:getContentSize().width - 10) / showEquipSp1:getContentSize().width)
    showEquipSp1:setPosition(getCenterPoint(equipSp1))
    equipSp1:addChild(showEquipSp1)
    
    local equipSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp2 = emblemVoApi:getEquipIconNoBg(emblemId, 18, 145, nil, 0)
    showEquipSp2:setScale((equipSp2:getContentSize().width - 10) / showEquipSp2:getContentSize().width)
    showEquipSp2:setPosition(getCenterPoint(equipSp2))
    equipSp2:addChild(showEquipSp2)
    equipSp2:setScale(0.97)
    local function equipBtnCallback()
        local function onConfirm(troopsAdd)
            if self == nil or tolua.cast(self.bgLayer, "CCNode") == nil then
                do return end
            end
            self:showEmptyEquipBtn()
            if troopsAdd then 
                if self.lineupsData and self.lineupsData[1] then
                    for k, v in pairs(self.lineupsData[1]) do
                        if self.lineupsData[1][k] and self.lineupsData[1][k][2] then
                            self.lineupsData[1][k][2] = self.lineupsData[1][k][2] - troopsAdd
                        end
                    end
                    self:setTroopsUI()
                end
                self:setTroopsNumUI()
            end
        end
        if emblemId then
            local eCfg = emblemVoApi:getEquipCfgById(emblemId)
            if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then --检测军徽带兵量
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), function() onConfirm(eCfg.attUp.troopsAdd) end, getlocal("dialog_title_prompt"), getlocal("removeEmblemConfirm"), nil, self.layerNum + 1)
            else
                onConfirm()
            end
        else
            onConfirm()
        end
    end
    local equipItem = CCMenuItemSprite:create(equipSp1, equipSp2)
    equipItem:registerScriptTapHandler(equipBtnCallback)
    equipItem:setAnchorPoint(ccp(0, 0))
    equipItem:setPosition(ccp(9, 8))
    equipMenu = CCMenu:createWithItem(equipItem)
    equipMenu:setTag(5645)
    equipMenu:setAnchorPoint(ccp(0, 0))
    equipMenu:setPosition(ccp(self.troopsBg:getContentSize().width - equipItem:getContentSize().width - 20, self.equipMentPosY - 14))
    equipMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    self.troopsBg:addChild(equipMenu, 1)
end

--显示空的飞机按钮
function exerWarTroopsLayer:showEmptyPlaneBtn()
    local planeMenu = tolua.cast(self.troopsBg:getChildByTag(5646), "CCMenu")
    if planeMenu ~= nil then
        planeMenu:removeFromParentAndCleanup(true)
        planeMenu = nil
    end
    -- 普通状态
    local planeSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp1 = CCSprite:createWithSpriteFrameName("plane_icon.png")
    showPlaneSp1:setPosition(getCenterPoint(planeSp1))
    showPlaneSp1:setScale(0.9)
    planeSp1:addChild(showPlaneSp1)
    -- 加号
    local addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(getCenterPoint(showPlaneSp1))
    showPlaneSp1:addChild(addSp, 1)
    -- 忽隐忽现
    local fade1 = CCFadeTo:create(1, 55)
    local fade2 = CCFadeTo:create(1, 255)
    local seq = CCSequence:createWithTwoActions(fade1, fade2)
    local repeatEver = CCRepeatForever:create(seq)
    if self.notTouch == true then
        addSp:setVisible(false)
    else
        addSp:runAction(repeatEver)
    end
    
    -- 按下状态
    local planeSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp2 = CCSprite:createWithSpriteFrameName("plane_icon.png")
    showPlaneSp2:setPosition(getCenterPoint(planeSp2))
    showPlaneSp2:setScale(0.9)
    planeSp2:addChild(showPlaneSp2)
    planeSp2:setScale(0.97)
    -- 加号
    addSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(getCenterPoint(showPlaneSp2))
    showPlaneSp2:addChild(addSp, 1)
    -- 忽隐忽现
    fade1 = CCFadeTo:create(1, 55)
    fade2 = CCFadeTo:create(1, 255)
    seq = CCSequence:createWithTwoActions(fade1, fade2)
    repeatEver = CCRepeatForever:create(seq)
    if self.notTouch == true then
        addSp:setVisible(false)
    else
        addSp:runAction(repeatEver)
    end
    local function planeBtnCallback()
        self:showSelectDialog(5)
    end
    local planeItem = CCMenuItemSprite:create(planeSp1, planeSp2)
    planeItem:registerScriptTapHandler(planeBtnCallback)
    planeItem:setAnchorPoint(ccp(0, 0))
    planeItem:setPosition(ccp(4, 6))
    planeMenu = CCMenu:createWithItem(planeItem)
    planeMenu:setTag(5646)
    planeMenu:setAnchorPoint(ccp(0, 0))
    planeMenu:setPosition(ccp(self.troopsBg:getContentSize().width - planeItem:getContentSize().width - 15, self.planeMenuPosY - 15))
    planeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    self.troopsBg:addChild(planeMenu, 1)

    if self.lineupsData then
        self.lineupsData[5] = nil
    end
end

function exerWarTroopsLayer:showPlaneBtn(planeId)
    local planeMenu = tolua.cast(self.troopsBg:getChildByTag(5646), "CCMenu")
    if planeMenu ~= nil then
        planeMenu:removeFromParentAndCleanup(true)
        planeMenu = nil
    end
    -- 带有飞机的按钮1
    local planeSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp1 = planeVoApi:getPlaneIconNoBg(planeSp1, planeId, 15)
    showPlaneSp1:setPosition(ccp(planeSp1:getContentSize().width / 2, planeSp1:getContentSize().height / 2 + 15))
    planeSp1:addChild(showPlaneSp1)
    
    local planeSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp2 = planeVoApi:getPlaneIconNoBg(planeSp2, planeId, 15)
    showPlaneSp2:setPosition(ccp(planeSp2:getContentSize().width / 2, planeSp2:getContentSize().height / 2 + 15))
    planeSp2:addChild(showPlaneSp2)
    planeSp2:setScale(0.97)
    
    local function planeBtnCallback()
        self:showEmptyPlaneBtn()
    end
    local planeItem = CCMenuItemSprite:create(planeSp1, planeSp2)
    planeItem:registerScriptTapHandler(planeBtnCallback)
    planeItem:setAnchorPoint(ccp(0, 0))
    planeItem:setPosition(ccp(4, 6))
    
    planeMenu = CCMenu:createWithItem(planeItem)
    planeMenu:setTag(5646)
    planeMenu:setAnchorPoint(ccp(0, 0))
    planeMenu:setPosition(ccp(self.troopsBg:getContentSize().width - planeItem:getContentSize().width - 15, self.planeMenuPosY - 15))
    planeMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
    self.troopsBg:addChild(planeMenu, 1)
end

--@troopsType : 1-坦克,2-将领,3-AI部队,4-军徽,5-飞机
function exerWarTroopsLayer:showSelectDialog(troopsType, sTroopsPos)
    local haveSelectAITroopsTb = {}
    if troopsType == 3 then
        if self.lineupsData and self.lineupsData[troopsType] then
            local aiCount = 0
            for k, v in pairs(self.lineupsData[troopsType]) do
                if type(v) == "table" and v[1] and v[1] ~= "" then
                    table.insert(haveSelectAITroopsTb, v[1])
                    aiCount = aiCount + 1
                end
            end
            local aiEquipLimitNum = AITroopsFleetVoApi:AITroopsEquipLimitNum()
            if aiCount >= aiEquipLimitNum then
                G_showTipsDialog(getlocal("aitroops_equip_reachlimit", {aiEquipLimitNum}))
                do return end
            end
        end
    end
    local function onSelected(sData)
        if self == nil or tolua.cast(self.bgLayer, "CCNode") == nil then
            do return end
        end
        if sData then
            if self.lineupsData == nil then
                self.lineupsData = {}
            end
            if self.lineupsData[troopsType] == nil then
                self.lineupsData[troopsType] = {}
            end
            if sTroopsPos then
                self.lineupsData[troopsType][sTroopsPos] = sData
                --检测军徽带兵量
                if troopsType == 1 and self.lineupsData[4] and self.lineupsData[4] ~= "" then
                    local eCfg = emblemVoApi:getEquipCfgById(self.lineupsData[4])
                    if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then
                        for k, v in pairs(self.lineupsData[troopsType]) do
                            if self.lineupsData[troopsType][k] and self.lineupsData[troopsType][k][2] then
                                self.lineupsData[troopsType][k][2] = self.troopsNum + eCfg.attUp.troopsAdd
                            end
                        end
                    end
                end
            else
                if troopsType == 4 then
                    self.lineupsData[troopsType] = sData
                    --检测军徽带兵量
                    local eCfg = emblemVoApi:getEquipCfgById(self.lineupsData[troopsType])
                    if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then
                        if self.lineupsData[1] then
                            for k, v in pairs(self.lineupsData[1]) do
                                if self.lineupsData[1][k] and self.lineupsData[1][k][2] then
                                    self.lineupsData[1][k][2] = self.troopsNum + eCfg.attUp.troopsAdd
                                end
                            end
                        end
                        self:setTroopsNumUI(eCfg.attUp.troopsAdd)
                    end
                    self:showSuperEquipBtn(self.lineupsData[troopsType])
                elseif troopsType == 5 then
                    self.lineupsData[troopsType] = sData
                    self:showPlaneBtn(self.lineupsData[troopsType][1])
                end
            end
            self:setTroopsUI()
        end
    end
    local dialogTitle = ""
    if troopsType == 1 then
        dialogTitle = getlocal("choiceFleet")
    elseif troopsType == 2 then
        dialogTitle = getlocal("selectHero")
    elseif troopsType == 3 then
        dialogTitle = getlocal("select_aitroops_title")
    elseif troopsType == 4 then
        dialogTitle = getlocal("emblem_select")
    elseif troopsType == 5 then
        dialogTitle = getlocal("plane_select")
    end
    require "luascript/script/game/scene/gamedialog/exerwar/exerWarSmallDialog"
    exerWarSmallDialog:showSelectTroops(self.layerNum + 1, dialogTitle, troopsType, self:getCanUseTroops(troopsType), onSelected, haveSelectAITroopsTb)
end