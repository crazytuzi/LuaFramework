--查看部队公用页面
checkTroopsLayer = {}

function checkTroopsLayer:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function checkTroopsLayer:createTroopsLayer(type, troopsInfo, layerNum)
    local offx, offy = 5, 5
    local itemWidth, itemHeight = 232, 153
    local itemScale = 1
    local skiconWidth = 50
    local skillHeight = skiconWidth + 20
    local layerWidth, layerHeight = 232 * itemScale * 2 + 94 * itemScale + 2 * offx + 20 + 5, itemHeight * itemScale * 3 + 2 * offy + 20 + skillHeight
    local troopsLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function ()end)
    troopsLayer:setContentSize(CCSizeMake(layerWidth, layerHeight))
    
    local layerKuang = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function ()end)
    layerKuang:setContentSize(CCSizeMake(layerWidth, layerHeight))
    layerKuang:setAnchorPoint(ccp(0.5, 1))
    layerKuang:setPosition(layerWidth / 2, layerHeight)
    troopsLayer:addChild(layerKuang)
    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png", CCRect(5, 5, 1, 1), function ()end)
    troopsBg:setContentSize(CCSizeMake(layerWidth - 5, layerHeight - skillHeight))
    troopsBg:setAnchorPoint(ccp(0.5, 1))
    troopsBg:setPosition(layerWidth / 2, layerHeight - skillHeight)
    troopsLayer:addChild(troopsBg)
    local troopsBgSize = troopsBg:getContentSize()
    
    local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setScaleX((troopsBgSize.width) / lineSp1:getContentSize().width)
    lineSp1:setPosition(ccp(layerWidth / 2, troopsBg:getContentSize().height))
    troopsBg:addChild(lineSp1)
    
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((troopsBgSize.width) / lineSp:getContentSize().width)
    lineSp:setPosition(ccp(layerWidth / 2, 0))
    troopsBg:addChild(lineSp)
    
    local leftFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg2:setPosition(ccp(0, troopsBgSize.height / 2))
    troopsBg:addChild(leftFrameBg2)
    local rightFrameBg2 = CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg2:setPosition(ccp(troopsBgSize.width, troopsBgSize.height / 2))
    troopsBg:addChild(rightFrameBg2)
    local leftFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0, 0.5))
    leftFrameBg1:setPosition(ccp(0, troopsBgSize.height / 2))
    troopsBg:addChild(leftFrameBg1)
    local rightFrameBg1 = CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1, 0.5))
    rightFrameBg1:setPosition(ccp(troopsBgSize.width, troopsBgSize.height / 2))
    troopsBg:addChild(rightFrameBg1)
    
    local tankInfo = troopsInfo.tank or {{}, {}, {}, {}, {}, {}}
    local heroInfo = troopsInfo.hero or {0, 0, 0, 0, 0, 0}
    local aiTroopsInfo = troopsInfo.aitroops or {0, 0, 0, 0, 0, 0}
    local tskinTb = troopsInfo.skin or {}
    
    local heroBgSpTb = {}
    local tankBgSpTb = {}
    local aiTroopsBgSpTb = {}
    local posX, posY = 0, 0
    for i = 0, 1, 1 do
        for j = 0, 2, 1 do
            local tag = ((j + 1) + (i * 3))
            posX = 10 + (1 - math.floor((tag - 1) / 3)) * (itemWidth * itemScale + offx)
            posY = troopsBgSize.height - 10 - (tag - i * 3) * itemHeight * itemScale - (tag - i * 3 - 1) * offy
            
            local tank = tankInfo[tag]
            local hero = heroInfo[tag]
            local aitroops = aiTroopsInfo[tag]
            -- 坦克
            local bgSp1
            if tank and tank[1] then
                bgSp1 = CCSprite:createWithSpriteFrameName("st_select2.png")
                
                local tankId = tank[1]
                tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum = tank[2]
                local tid = tankSkinVoApi:convertTankId(tankId)
                local tankSp = tankVoApi:getTankIconSp(tankId,tskinTb[tid],nil,false) --CCSprite:createWithSpriteFrameName(tankCfg[tankId].icon)
                local spScale = 0.6
                tankSp:setPosition(ccp(10 + tankSp:getContentSize().width * spScale / 2, bgSp1:getContentSize().height / 2 - 15))
                tankSp:setScale(spScale)
                bgSp1:addChild(tankSp, 3)
                
                if tankId ~= G_pickedList(tankId) then
                    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    tankSp:addChild(pickedIcon)
                    pickedIcon:setPosition(tankSp:getContentSize().width - 30, 30)
                    pickedIcon:setScale(1.5)
                end
                
                local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[tankId].name), 20, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                soldiersLbName:setAnchorPoint(ccp(0, 0.5))
                soldiersLbName:setPosition(ccp(tankSp:getPositionX() + tankSp:getContentSize().width * spScale / 2 + 3, tankSp:getPositionY() + tankSp:getContentSize().height * spScale / 2 - 13))
                bgSp1:addChild(soldiersLbName, 2)
                
                local soldiersLbNum = GetTTFLabel(tankNum, 20)
                soldiersLbNum:setAnchorPoint(ccp(0, 0.5))
                soldiersLbNum:setPosition(ccp(tankSp:getPositionX() + tankSp:getContentSize().width * spScale / 2 + 3, tankSp:getPositionY() - tankSp:getContentSize().height * spScale / 2 + 10))
                bgSp1:addChild(soldiersLbNum, 2)
            else
                bgSp1 = CCSprite:createWithSpriteFrameName("st_select1.png")
                
                -- 部队为空时显示
                local nullTankSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullTankSp:setAnchorPoint(ccp(0.5, 0.5))
                nullTankSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 10))
                bgSp1:addChild(nullTankSp, 1)
                nullTankSp:setScale(0.8)
                local selectTankBg2 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg2:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg2:setPosition(ccp(nullTankSp:getContentSize().width / 2, nullTankSp:getContentSize().height / 2 - 35))
                nullTankSp:addChild(selectTankBg2)
                local posSp = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp:setPosition(ccp(nullTankSp:getContentSize().width / 2, nullTankSp:getContentSize().height / 2 - 10))
                nullTankSp:addChild(posSp, 1)
            end
            
            -- 头顶显示文字
            local headNameLb1 = GetTTFLabel("", 20)
            headNameLb1:setAnchorPoint(ccp(0.5, 0))
            headNameLb1:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height - 32))
            headNameLb1:setTag(12)
            bgSp1:addChild(headNameLb1, 1)
            
            bgSp1:setAnchorPoint(ccp(0, 0))
            
            bgSp1:setPosition(posX, posY)
            troopsBg:addChild(bgSp1)
            
            table.insert(tankBgSpTb, bgSp1)
            
            -- 英雄
            local bgSp2
            if hero and tostring(hero) ~= "0" and tostring(hero) ~= "" then
                bgSp2 = CCSprite:createWithSpriteFrameName("st_select2.png")
                -- 坦克相关bgSp1
                local arr = Split(hero, "-")
                local hid = arr[1]
                local level = arr[2] or 1
                local productOrder = arr[3] or 1
                local adjutants = heroAdjutantVoApi:decodeAdjutant(hero)
                local heroName = getlocal(heroListCfg[hid].heroName)
                local heroStr = "Lv."..level.." "..heroName
                headNameLb1:setString(heroStr)
                local star = tonumber(productOrder)
                local starSize = 13
                for i = 1, star do
                    local starSpace = starSize
                    local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                    starSp:setScale(starSize / starSp:getContentSize().width)
                    bgSp1:addChild(starSp)
                    if starSp then
                        local px = bgSp1:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                        local py = bgSp1:getContentSize().height - 5
                        starSp:setPosition(ccp(px, py))
                    end
                end
                
                -- bgSp2
                local spScale = 0.5
                local heroSp = heroVoApi:getHeroIcon(hid, productOrder, nil,nil,nil,nil,nil,{adjutants=adjutants})
                heroSp:setScale(spScale)
                heroSp:setPosition(ccp(20 + heroSp:getContentSize().width * spScale / 2, bgSp2:getContentSize().height / 2 - 10))
                bgSp2:addChild(heroSp)
                
                local heroNameLb = GetTTFLabelWrap(heroVoApi:getHeroName(hid), 20, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                heroNameLb:setAnchorPoint(ccp(0, 0.5))
                heroNameLb:setPosition(ccp(heroSp:getPositionX() + heroSp:getContentSize().width * spScale / 2 + 8, heroSp:getPositionY() + heroSp:getContentSize().height * spScale / 2 - 13))
                bgSp2:addChild(heroNameLb, 2)
                
                local heroLvLb = GetTTFLabel("LV."..level, 20)
                heroLvLb:setAnchorPoint(ccp(0, 0.5))
                heroLvLb:setPosition(ccp(heroSp:getPositionX() + heroSp:getContentSize().width * spScale / 2 + 10, heroSp:getPositionY() - heroSp:getContentSize().height * spScale / 2 + 10))
                bgSp2:addChild(heroLvLb, 2)
            else
                bgSp2 = CCSprite:createWithSpriteFrameName("st_select1.png")
                -- 英雄为空时显示
                local nullHeroSp = CCSprite:createWithSpriteFrameName("selectTankBg3.png")
                nullHeroSp:setAnchorPoint(ccp(0.5, 0.5))
                nullHeroSp:setPosition(ccp(bgSp2:getContentSize().width / 2, bgSp2:getContentSize().height / 2 - 10))
                bgSp2:addChild(nullHeroSp, 1)
                nullHeroSp:setScale(0.8)
                local selectTankBg21 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg21:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg21:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 35))
                nullHeroSp:addChild(selectTankBg21)
                local posSp1 = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp1:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 10))
                nullHeroSp:addChild(posSp1, 1)
                
                -- 坦克相关bgSp1
                headNameLb1:setString(getlocal("fight_content_null"))
                
            end
            -- 头顶显示文字
            local headNameLb2 = GetTTFLabel("", 20)
            headNameLb2:setAnchorPoint(ccp(0.5, 0))
            headNameLb2:setPosition(ccp(bgSp2:getContentSize().width / 2, bgSp2:getContentSize().height - 32))
            headNameLb2:setTag(12)
            bgSp2:addChild(headNameLb2, 1)
            
            if tank and tank[1] then
                local tankId = tank[1]
                tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum = tank[2]
                local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tankId].name), tankNum})
                headNameLb2:setString(tankStr)
            else
                headNameLb2:setString(getlocal("fight_content_null"))
            end
            
            bgSp2:setAnchorPoint(ccp(0, 0))
            
            bgSp2:setPosition(posX, posY)
            troopsBg:addChild(bgSp2)
            
            table.insert(heroBgSpTb, bgSp2)
            
            --AI部队
            local bgSp3
            if aitroops and aitroops ~= 0 and aitroops ~= "" then
                bgSp3 = CCSprite:createWithSpriteFrameName("st_select2.png")
                local atid, lv, grade, strength
                local mirror, arr = AITroopsVoApi:checkIsAITroopsMirror(aitroops)
                if mirror == true then
                    local aitVo = AITroopsVoApi:createAITroopsVoByMirror(arr)
                    if aitVo then
                        atid, lv, grade, strength = aitVo.id, aitVo.lv, aitVo.grade, aitVo:getTroopsStrength()
                    end
                end
                if atid and lv and grade and strength then
                    local spWidth = 90
                    local aitroopsIconSp = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade)
                    aitroopsIconSp:setScale(spWidth / aitroopsIconSp:getContentSize().width)
                    aitroopsIconSp:setPosition(ccp(10 + spWidth / 2, bgSp3:getContentSize().height / 2 - 15))
                    bgSp3:addChild(aitroopsIconSp)
                    
                    local nameStr, color = AITroopsVoApi:getAITroopsNameStr(atid)
                    local troopsNameLb = GetTTFLabelWrap(nameStr, 20, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    troopsNameLb:setAnchorPoint(ccp(0, 0.5))
                    troopsNameLb:setPosition(ccp(aitroopsIconSp:getPositionX() + spWidth / 2 + 8, aitroopsIconSp:getPositionY() + spWidth / 2 - 13))
                    bgSp3:addChild(troopsNameLb, 2)
                    
                    local strengthLb = GetTTFLabel(strength, 20)
                    strengthLb:setAnchorPoint(ccp(0, 0.5))
                    strengthLb:setPosition(ccp(aitroopsIconSp:getPositionX() + spWidth / 2 + 10, aitroopsIconSp:getPositionY() - spWidth / 2 + 10))
                    bgSp3:addChild(strengthLb, 2)
                end
            else
                bgSp3 = CCSprite:createWithSpriteFrameName("st_select1.png")
                --AI部队为空时显示
                local nullAITroopsSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullAITroopsSp:setAnchorPoint(ccp(0.5, 0.5))
                nullAITroopsSp:setPosition(ccp(bgSp3:getContentSize().width / 2, bgSp3:getContentSize().height / 2 - 10))
                bgSp3:addChild(nullAITroopsSp, 1)
                nullAITroopsSp:setScale(0.8)
                local selectTankBg22 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg22:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg22:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 35))
                nullAITroopsSp:addChild(selectTankBg22)
                local posSp = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 10))
                nullAITroopsSp:addChild(posSp, 1)
            end
            -- 头顶显示文字
            local headNameLb3 = GetTTFLabel("", 20)
            headNameLb3:setAnchorPoint(ccp(0.5, 0))
            headNameLb3:setPosition(ccp(bgSp3:getContentSize().width / 2, bgSp3:getContentSize().height - 32))
            headNameLb3:setTag(12)
            bgSp3:addChild(headNameLb3, 1)
            
            if tank and tank[1] then
                local tankId = tank[1]
                tankId = tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                local tankNum = tank[2]
                local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tankId].name), tankNum})
                headNameLb3:setString(tankStr)
            else
                headNameLb3:setString(getlocal("fight_content_null"))
            end
            
            bgSp3:setAnchorPoint(ccp(0, 0))
            
            bgSp3:setPosition(posX, posY)
            troopsBg:addChild(bgSp3)
            table.insert(aiTroopsBgSpTb, bgSp3)
        end
    end
    self:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, 1)
    
    local peW = troopsBgSize.width - 10
    local startH = 11
    -- 飞机
    local planeSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    troopsBg:addChild(planeSp1)
    planeSp1:setAnchorPoint(ccp(1, 0))
    planeSp1:setPosition(peW, startH - 2)
    
    local plane = troopsInfo.plane
    if plane and plane ~= 0 then
        local showPlaneSp1 = planeVoApi:getPlaneIconNoBg(planeSp1, plane, 15)
        -- showPlaneSp1:setScale(0.3)
        showPlaneSp1:setPosition(ccp(planeSp1:getContentSize().width / 2, planeSp1:getContentSize().height / 2 + 15))
        planeSp1:addChild(showPlaneSp1)
    else
        local showPlaneSp1 = CCSprite:createWithSpriteFrameName("plane_icon.png")
        showPlaneSp1:setPosition(getCenterPoint(planeSp1))
        showPlaneSp1:setScale(0.9)
        planeSp1:addChild(showPlaneSp1)
    end
    
    -- 军徽
    local equipSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    troopsBg:addChild(equipSp1)
    equipSp1:setAnchorPoint(ccp(1, 0))
    equipSp1:setPosition(peW, startH + planeSp1:getContentSize().height + 2)
    
    local emblem = troopsInfo.emblem
    if emblem and emblem ~= 0 then
        local showEquipSp1 = emblemVoApi:getEquipIconNoBg(emblem, 18, 145, nil, 0)
        showEquipSp1:setScale(equipSp1:getContentSize().width / showEquipSp1:getContentSize().width)
        showEquipSp1:setPosition(getCenterPoint(equipSp1))
        equipSp1:addChild(showEquipSp1)
    else
        local showEquipSp1 = CCSprite:createWithSpriteFrameName("st_emptyShadow.png")
        showEquipSp1:setPosition(getCenterPoint(equipSp1))
        showEquipSp1:setScale(0.9)
        equipSp1:addChild(showEquipSp1)
    end
    local switchTankPic, switchHeroPic, switchAIPic = "st_showFleet.png", "st_showHero.png", "et_switchAI.png"
    if base.AITroopsSwitch == 1 then
        switchTankPic, switchHeroPic = "et_switchTank.png", "et_switchHero.png"
    end
    -- 显示坦克时的按钮
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
    changeItem:setAnchorPoint(CCPointMake(1, 0))
    changeItem:setPosition(ccp(peW, startH + planeSp1:getContentSize().height + 5 + equipSp1:getContentSize().height))
    local function changeHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        if changeItem:getSelectedIndex() == 0 then
            self:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, 1)
        else
            if base.AITroopsSwitch == 1 then
                if changeItem:getSelectedIndex() == 1 then
                    self:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, 3)
                else
                    self:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, 2)
                end
            else
                self:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, 2)
            end
        end
    end
    changeItem:registerScriptTapHandler(changeHandler)
    local changeMenu = CCMenu:create()
    changeMenu:addChild(changeItem)
    changeMenu:setAnchorPoint(ccp(0, 0))
    changeMenu:setPosition(ccp(0, 0))
    changeMenu:setTouchPriority(-(layerNum - 1) * 20 - 4)
    changeItem:setSelectedIndex(0)
    troopsBg:addChild(changeMenu, 1)
    
    local function touchHandler(object, fn, tag)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        tankVoApi:showTankBuffSmallDialog("TankInforPanel.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), tankInfo, true, true, layerNum + 1, nil, true)
    end
    local index = 1
    local tmpTb = {}
    for k, v in pairs(tankInfo) do
        if v and v[1] and v[2] and v[2] > 0 then
            local tankId = v[1]
            local id = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
            local buffType = tankCfg[id].buffShow[1]
            if buffType and tmpTb[buffType] == nil then
                local ghPic = "tank_gh_icon_" ..buffType.. ".png"
                local ghSp = LuaCCSprite:createWithSpriteFrameName(ghPic, touchHandler)
                local iconScale = skiconWidth / ghSp:getContentSize().width
                ghSp:setScale(iconScale)
                ghSp:setAnchorPoint(ccp(1, 1))
                local px = layerWidth - 10 - (skiconWidth) * (index - 1)
                ghSp:setPosition(ccp(px, layerHeight - 10))
                ghSp:setTouchPriority(-(layerNum - 1) * 20 - 4)
                troopsLayer:addChild(ghSp, 2)
                index = index + 1
                tmpTb[buffType] = 1
            end
        end
    end
    
    return troopsLayer
end

-- flag:1 tank显示  2：英雄显示
function checkTroopsLayer:changeHeroOrTank(heroBgSpTb, tankBgSpTb, aiTroopsBgSpTb, flag)
    for k, v in pairs(tankBgSpTb) do
        if v then
            v:setVisible(flag == 1 and true or false)
        end
    end
    for k, v in pairs(heroBgSpTb) do
        if v then
            v:setVisible(flag == 2 and true or false)
        end
    end
    for k, v in pairs(aiTroopsBgSpTb) do
        if v then
            v:setVisible(flag == 3 and true or false)
        end
    end
end
