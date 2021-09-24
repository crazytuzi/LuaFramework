editTroopsLayer = {}

function editTroopsLayer:new()
    local nc = {
        clayer = nil, --背景sprite
        layerNum = nil,
        type = 0,
        parentLayer = nil,
        isShowTank = nil,
        touchRect = CCRect(0, 200, G_VisibleSizeWidth, G_VisibleSizeHeight - 400),
        iconTab = {},
        iconBgTab = {},
        posTab = {},
        -- queueNumTab={},
        touchArr = {},
        multTouch = false,
        isMoved = false,
        firstOldPos = nil,
        secondOldPos = nil,
        touchedIcon = nil,
        touchedId = 0,
        movedType = 0, --0 原始 1 准备动  2正在动  3点在空白了
        iconLength = 0,
        --移动到的
        movedIcon = nil,
        movedId = 0,
        touchedScaleX = 1,
        touchedScaleY = 1,
        isShowTank = 1,
        
        emblemTroopsAdd = 0,
        
        tHeight = G_VisibleSizeHeight / 2 + 240,
        notTouch = false,
        nullTankTb = {},
        nullHeroTb = {},
        nullAITroopsTb = {},
        skillIcon = {},
        tankPosY = 0,
        troopsNumLb = nil,
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newImage/soldier/soldierType1.plist"),
        --    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newImage/soldier/soldierType2.plist"),
        --    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newImage/soldier/soldierType4.plist"),
        --    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newImage/soldier/soldierType8.plist"),
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")}
    setmetatable(nc, self)
    self.__index = self
    
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newImage/soldier/soldierTypeSpecial1.plist")
    return nc
end

-- type:35 36 势力战，与原有的逻辑没有半毛钱关系，所有计算重写
-- 35 部队界面  36 出征界面
function editTroopsLayer:initLayer(type, layer, layerNum, callback, isLandTab, notTouch, tPosY, cid)
    if type == 38 then
        spriteController:addPlist("public/believer/believerTexture.plist")
        spriteController:addTexture("public/believer/believerTexture.png")
    end
    local strSize2 = 22
    local strSize3 = 18
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" then
        strSize2 = 25
        strSize3 = 20
    elseif G_getCurChoseLanguage() == "de" then
        strSize3 = 13
    end
    self.layerNum = layerNum
    self.type = type
    self.cid = cid
    self.parentLayer = layer
    
    self.clayer = CCLayer:create()
    layer:addChild(self.clayer, layerNum * 20)
    
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler, false, -(self.layerNum - 1) * 20 - 3, true)
    self.clayer:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.clayer:setTouchEnabled(true)
    
    if self.type == 35 then
        local function disBanRefresh(event, data)
            self:refreshDisban(data)
        end
        self.disbanListener = disBanRefresh
        eventDispatcher:addEventListener("ltzdz.disban", disBanRefresh)
    end
    
    if tankSkinVoApi:checkBattleType(self.type) == true then
        tankSkinVoApi:clearTempTankSkinList(self.type) --清空皮肤缓存数据
        local tskin = G_clone(tankSkinVoApi:getTankSkinListByBattleType(self.type))
        tankSkinVoApi:setTempTankSkinList(self.type, tskin) --同步皮肤缓存数据
    end
    
    -- 清理临时的军徽
    emblemVoApi:setTmpEquip(nil, type)
    -- 清理临时飞机
    planeVoApi:setTmpEquip(nil, type)
    -- 清理临时飞艇
    airShipVoApi:setTempLineupId(nil)

    if tPosY ~= nil then
        self.tHeight = tPosY
    elseif type == 2 or type == 16 then
        self.tHeight = G_VisibleSize.height - 200 - 80
    elseif type == 5 then
        if base.ma == 1 then
            self.tHeight = G_VisibleSize.height - 180 + 50
        else
            self.tHeight = G_VisibleSize.height - 240
        end
    elseif type == 7 or type == 8 or type == 9 then
        self.tHeight = G_VisibleSize.height - 240
    elseif type == 13 or type == 14 or type == 15 then
        self.tHeight = G_VisibleSize.height - 245
        -- elseif type==17 or type==18 then
        --     self.tHeight = G_VisibleSize.height-220
        -- elseif type==31 or type==32 then
        --     self.tHeight = G_VisibleSize.height-200
    elseif type == 24 or type == 25 or type == 26 or type == 27 or type == 28 or type == 29 then
        self.tHeight = G_VisibleSize.height - 240
    elseif type == 33 or type == 34 then
        self.tHeight = G_VisibleSize.height - 130
    elseif type == 35 then
        self.tHeight = G_VisibleSize.height - 180
    elseif type == 36 then
        self.tHeight = G_VisibleSize.height - 240
    else
        self.tHeight = G_VisibleSize.height - 200
    end
    local tHeight = self.tHeight
    -- print("type,tHeight~~~~~~~~",type,tHeight)
    local fontSize = 24
    local layerBgPic, layerBgRect = "NoticeLine.png", CCRect(20, 20, 10, 10)
    if type == 38 or type == 39 then
        layerBgPic, layerBgRect = "rankKuang.png", CCRect(15, 15, 2, 2)
    end
    local layerBg = LuaCCScale9Sprite:createWithSpriteFrameName(layerBgPic, layerBgRect, function ()end)
    layerBg:setAnchorPoint(ccp(0.5, 1))
    self.layerBg = layerBg
    if type == 24 or type == 27 then
        layerBg:setOpacity(0)
        self.tHeight = G_VisibleSizeHeight - 190
        tHeight = self.tHeight
    end
    if type == 2 or type == 16 then
        if G_isIphone5() == true then
            self.tHeight = self.tHeight - 30
            tHeight = self.tHeight
        end
        local function touch(...)
        end
        local marchBg = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png", CCRect(20, 20, 10, 10), touch)
        marchBg:ignoreAnchorPointForPosition(false)
        marchBg:setAnchorPoint(ccp(0.5, 1))
        if G_isIphone5() == true then
            marchBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 80))
            marchBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 120 + 30))
        else
            marchBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 50))
            marchBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 120))
        end
        layer:addChild(marchBg)
        local targetLb = GetTTFLabel(getlocal("targetPostion")..getlocal("city_info_coordinate_style", {isLandTab.x, isLandTab.y}), fontSize);
        targetLb:setAnchorPoint(ccp(0, 0.5));
        targetLb:setPosition(ccp(50, marchBg:getContentSize().height / 2));
        if type == 16 then
            targetLb:setPosition(ccp(10, marchBg:getContentSize().height / 2));
        end
        marchBg:addChild(targetLb, 2);
        
        if type == 2 then
            local help = false
            if isLandTab.allianceName and allianceVoApi:isSameAlliance(isLandTab.allianceName) then
                help = true
            end
            if isLandTab.type and isLandTab.type == 8 and isLandTab.isDef and isLandTab.isDef > 0 then --如果是驻防自己军团城市的话不算是协防
                help = false
            end
            local selfCoord = {playerVoApi:getMapX(), playerVoApi:getMapY()}
            local targetCoord = {isLandTab.x, isLandTab.y}
            local moveTime = GetTimeStr(MarchTimeConsume(selfCoord, targetCoord, help, isLandTab))
            local moveTimeLb = GetTTFLabel(getlocal("costTime2", {moveTime}), fontSize)
            moveTimeLb:setAnchorPoint(ccp(0, 0.5))
            moveTimeLb:setPosition(ccp(350, marchBg:getContentSize().height / 2))
            local lanStr = G_getCurChoseLanguage()
            if lanStr ~= "cn" and lanStr ~= "tw" and lanStr ~= "ja" and lanStr ~= "ko" then
                moveTimeLb:setAnchorPoint(ccp(1, 0.5))
                moveTimeLb:setPosition(ccp(marchBg:getContentSize().width - 5, marchBg:getContentSize().height / 2))
            end
            marchBg:addChild(moveTimeLb, 2)
        end
        
        if G_isIphone5() == true then
            layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, 595 + 35 + 25 * 2 + 20))
            -- layerBg:setPosition(ccp(G_VisibleSizeWidth/2,tHeight+90+35-55-30))
        else
            layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, 595 + 35))
            -- layerBg:setPosition(ccp(G_VisibleSizeWidth/2,tHeight+90+35-55))
        end
        layerBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 90 + 35 - 55))
    elseif type == 38 or type == 39 then
        local layerBgWidth, layerBgHeight = G_VisibleSizeWidth - 30, 595
        if type == 38 then
            layerBgHeight = 558
        else
            layerBgHeight = 595
        end
        if G_isIphone5() == true then
            layerBg:setContentSize(CCSizeMake(layerBgWidth, layerBgHeight + 25 * 2 + 20))
        else
            layerBg:setContentSize(CCSizeMake(layerBgWidth, layerBgHeight))
        end
        layerBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 35))
    elseif type == 4 then
        local layerBgWidth, layerBgHeight = G_VisibleSizeWidth - 30, 595
        if G_isIphone5() == true then
            layerBg:setContentSize(CCSizeMake(layerBgWidth, layerBgHeight))
        else
            layerBg:setContentSize(CCSizeMake(layerBgWidth, layerBgHeight))
        end
    else
        if G_isIphone5() == true then
            layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, 595 + 25 * 2 + 20))
        else
            layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, 595))
        end
        layerBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 35))
        
        if type == 35 or type == 36 then
            local layerBgH = layerBg:getContentSize().height
            local addH = 50
            if type == 36 then
                addH = 110
            end
            layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, layerBgH + addH))
            layerBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight + 35 + addH))
        end
    end
    layer:addChild(layerBg)
    
    -- local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("troops_content_bg.png",CCRect(10, 10, 1, 1),function ()end)
    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png", CCRect(5, 5, 1, 1), function ()end)
    if G_isIphone5() == true then
        if self.type == 24 or self.type == 27 then
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 55, 490 + 25 * 4))
        elseif self.type == 38 or self.type == 39 then
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 34, 490 + 25 * 2))
        else
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 55, 490 + 25 * 2))
        end
        troopsBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight - 30 - 20))
    else
        if self.type == 24 or self.type == 27 then
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 55, 490 + 50))
        elseif self.type == 38 or self.type == 39 then
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 34, 490))
        else
            troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 55, 490))
        end
        troopsBg:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight - 30))
    end
    troopsBg:setTag(4534)
    troopsBg:setAnchorPoint(ccp(0.5, 1))
    layer:addChild(troopsBg)
    if G_isIphone5() == true then
        self.tankPosY = tHeight - 118 - 20
    else
        self.tankPosY = tHeight - 118
    end
    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((troopsBg:getContentSize().width) / lineSp:getContentSize().width)
    lineSp:setPosition(ccp(G_VisibleSizeWidth / 2, troopsBg:getPositionY()))
    layer:addChild(lineSp)
    
    local frameOffestH = 0
    if self.type == 24 or self.type == 27 then
        frameOffestH = 25
    end
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
    
    if notTouch == true then
        self.notTouch = notTouch
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function ()end)
        grayBgSp:setOpacity(0)
        grayBgSp:setAnchorPoint(ccp(0.5, 1))
        grayBgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 10)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, 490))
        grayBgSp:setPosition(ccp(G_VisibleSizeWidth / 2, tHeight))
        layer:addChild(grayBgSp)
        
        -- 禁止触摸
        self.clayer:setTouchEnabled(false)
    end
    
    -- 统御提升带兵量
    local posX = 45
    local posY
    if G_isIphone5() == true then
        posY = tHeight - 10
    else
        posY = tHeight
    end
    -- local fontSize = 22
    -- posY = posY + 5
    
    -- local function tipTouch()
    --     if G_checkClickEnable()==false then
    --         do return end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)
    --     -- 提示文字
    --     local str1 = getlocal("superEquip_troops_add")
    --     local str2 = ""
    --     if base.emblemSwitch==1 then
    --         str1 = str1.."+"..getlocal("superEquip_infoAttup")
    --         str2 = getlocal("superEquip_player_troops_tip")
    --     end
    --     local infoTb = {" ",str2,str1," "}
    --     local tabColor = {nil,G_ColorYellowPro,nil,nil}
    --     -- 个人跨服战提示
    --     if type==7 or type==8 or type==9 then
    --         local str3 = getlocal("server_war_personal_troops_str1")
    --         local str4 = getlocal("server_war_personal_troops_str2",{serverWarPersonalCfg.tankeTransRate})
    --         local str5 = getlocal("server_war_personal_troops_str3")
    --         infoTb = {" ",str2,str1," ",str5," ",str4," ",str3," "}
    --         tabColor = {nil,G_ColorYellowPro,nil,nil,nil,nil,nil,nil,nil,nil}
    --     end
    --     local sd=smallDialog:new()
    --     local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,infoTb,25,tabColor)
    --     sceneGame:addChild(dialogLayer,layerNum+1)
    --     dialogLayer:setPosition(ccp(0,0))
    -- end
    -- local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    -- tipItem:setScale(0.86)
    -- tipItem:setAnchorPoint(ccp(0.5,0.5))
    -- tipItem:setPosition(ccp(tipItem:getContentSize().width/2+15,posY+15))
    -- local tipMenu = CCMenu:createWithItem(tipItem)
    -- tipMenu:setAnchorPoint(ccp(0,0))
    -- tipMenu:setPosition(ccp(0,0))
    -- tipMenu:setTouchPriority(-(layerNum-1)*20-3)
    -- layer:addChild(tipMenu,1)
    -- posX = tipItem:getPositionX() + tipItem:getContentSize().width/2*0.86
    
    -- 军徽加带兵量
    local troopsAdd = 0
    if base.emblemSwitch == 1 then
        local emblemId = emblemVoApi:getBattleEquip(self.type, self.cid)
        -- 获取此类型的军徽id
        if emblemId then
            local emTroopVo
            if self.type == 35 or self.type == 36 then
                emTroopVo = ltzdzFightApi:getEmblemTroopById(emblemId)
            end
            troopsAdd = emblemVoApi:getTroopsAddById(emblemId, emTroopVo)
        end
    end
    
    -- 获取舰队
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local colorTab = {nil, G_ColorGreen, nil}
    local troopsNumStr
    
    if self.type == 35 or self.type == 36 then
        troopsNumStr = getlocal("player_leader_troop_num", {ltzdzFightApi:getFightNum()}) .. "<rayimg>+" .. troopsAdd .. "<rayimg>"
    else
        troopsNumStr = getlocal("player_leader_troop_num", {playerVoApi:getTroopsLvNum()}) .. "<rayimg>+" .. (playerVoApi:getExtraTroopsNum(self.type, false) + troopsAdd) .. "<rayimg>"
    end
    
    -- troopsNumStr=str
    local lbHeight = 0
    self.troopsNumLb, lbHeight = G_getRichTextLabel(troopsNumStr, colorTab, fontSize, G_VisibleSizeWidth / 2 - 60, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.troopsNumLb:setAnchorPoint(ccp(0, 1))
    self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2))
    layer:addChild(self.troopsNumLb, 2)
    
    if self.type == 35 then
        self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2 + 60))
    elseif self.type == 36 then
        self.troopsNumLb:setPosition(ccp(posX, G_VisibleSizeHeight - 180))
    elseif self.type == 4 then
        self.troopsNumLb:setVisible(false)
    end
    
    if airShipVoApi:isCanEnter() == true then
        if self.type == 1 or self.type == 5 or self.type == 12 or self.type == 20 then
            local tempAirShipId = airShipVoApi:getBattleEquip(self.type)
            if airShipVoApi:isGoInto(tempAirShipId) == false then
                airShipVoApi:setTempLineupId(tempAirShipId)
            end
        end
        local function onClikAirShip(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            
            G_touchedItem(self.airshipBtn, function ()
                PlayEffect(audioCfg.mouseClick)
                print("cjl ---------->> 切换扩展的飞艇部队")
                if troopsBg then
                    troopsBg:setVisible(not troopsBg:isVisible())
                    self.clayer:setTouchEnabled(troopsBg:isVisible())
                    self.clayer:setVisible(not self.clayer:isVisible())
                end
                if self.layerBg then
                    self.layerBg:setVisible(not self.layerBg:isVisible())
                end
                for i = 0, 1, 1 do
                    for j = 0, 2, 1 do
                        local tag = ((j + 1) + (i * 3))
                        local bgSp = tolua.cast(layer:getChildByTag(tag), "CCSprite")
                        if bgSp then
                            bgSp:setVisible(not bgSp:isVisible())
                        end
                        local bgSp1 = tolua.cast(self.iconBgTab[tag], "CCSprite")
                        if bgSp1 then
                            bgSp1:setVisible(not bgSp1:isVisible())
                        end
                        local headNameBg = tolua.cast(layer:getChildByTag(65760 + tag), "CCSprite")
                        if headNameBg then
                            headNameBg:setVisible(not headNameBg:isVisible())
                        end
                    end
                end
                if troopsBg then
                    if (not troopsBg:isVisible()) and self.extTroopsLayer == nil then
                        require "luascript/script/componet/extendTroopsLayer"
                        local extTroopsLayer = extendTroopsLayer:new(self)
                        local extTroopsLayerSize = CCSizeMake(troopsBg:getContentSize().width, self.layerBg:getContentSize().height - (self.layerBg:getPositionY() - troopsBg:getPositionY()))
                        extTroopsLayer:initLayer(self.type, layerNum + 1, self.parentLayer, extTroopsLayerSize, troopsBg:getPositionY())
                        self.extTroopsLayer = extTroopsLayer
                    end
                    if self.extTroopsLayer then
                        self.extTroopsLayer:setVisible(not troopsBg:isVisible())
                    end
                end
            end)
        end
        self.airshipBtn = LuaCCSprite:createWithSpriteFrameName("aei_airShipBtn.png", onClikAirShip)
        self.airshipBtn:setAnchorPoint(ccp(0.5, 0.5))
        self.airshipBtn:setPosition(ccp(G_VisibleSizeWidth - 40 - self.airshipBtn:getContentSize().width / 2, self.tHeight - ((G_isIphone5() == true) and 10 or 0)))
        self.airshipBtn:setTouchPriority((-(layerNum - 1) * 20 - 5))
        self.parentLayer:addChild(self.airshipBtn, 1)
        self:refreshAirshipBtn(airShipVoApi:getBattleEquip(self.type))
    end
    
    self:resetSkillIcon()
    
    -- local powerStr=getlocal("world_war_power",{FormatNumber(power)})
    -- -- powerStr=str
    -- self.powerLb=GetTTFLabelWrap(powerStr,fontSize,CCSizeMake(G_VisibleSizeWidth/2-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- self.powerLb:setAnchorPoint(ccp(0,0.5))
    -- self.powerLb:setPosition(ccp(posX,posY))
    -- layer:addChild(self.powerLb,2)
    
    -- 出征界面的载重和行军时间
    if type == 2 or type == 16 then
        self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2))
        posY = posY + 50
        
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(type)))
        local fleetloadStr = getlocal("fleetload", {fleetload})
        -- fleetloadStr=str
        local fleetLb = GetTTFLabelWrap(fleetloadStr, fontSize, CCSizeMake(G_VisibleSizeWidth / 2 - 10, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        fleetLb:setAnchorPoint(ccp(0, 0.5))
        fleetLb:setPosition(ccp(posX, posY))
        layer:addChild(fleetLb, 2)
        fleetLb:setTag(19)
        posY = posY + fontSize + 5
        
        -- local fleetload=FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
        -- local fleetLb=GetTTFLabel(getlocal("fleetload",{fleetload}),fontSize)
        -- fleetLb:setAnchorPoint(ccp(0,0))
        -- fleetLb:setPosition(ccp(posX,posY))
        -- layer:addChild(fleetLb,2)
        -- fleetLb:setTag(19)
        -- posY = posY + fontSize + 5
        
        -- local help=false
        -- if isLandTab.allianceName and allianceVoApi:isSameAlliance(isLandTab.allianceName) then
        --     help=true
        -- end
        -- local selfCoord={playerVoApi:getMapX(),playerVoApi:getMapY()}
        -- local targetCoord={isLandTab.x,isLandTab.y}
        -- local moveTime=GetTimeStr(MarchTimeConsume(selfCoord,targetCoord,help))
        -- local moveTimeLb=GetTTFLabel(getlocal("costTime2",{moveTime}),fontSize)
        -- moveTimeLb:setAnchorPoint(ccp(0,0))
        -- moveTimeLb:setPosition(ccp(posX,posY))
        -- layer:addChild(moveTimeLb,2)
        -- posY = posY + fontSize + 5
    end
    
    -- -- 带兵总量
    -- local soldiersLb = GetTTFLabel(getlocal("player_leader_troop_num",{playerVoApi:getTotalTroops(self.type)}),fontSize)
    -- soldiersLb:setAnchorPoint(ccp(1,0))
    -- soldiersLb:setPosition(ccp(posX+soldiersLb:getContentSize().width,posY))
    -- layer:addChild(soldiersLb,2)
    -- soldiersLb:setTag(11055)
    -- posX = posX + soldiersLb:getContentSize().width
    -- -- 基础带兵量
    -- local soldiersLbNum1 = GetTTFLabel("("..playerVoApi:getTroopsLvNum(),fontSize)
    -- soldiersLbNum1:setAnchorPoint(ccp(0,0))
    -- soldiersLbNum1:setPosition(ccp(posX,posY))
    -- layer:addChild(soldiersLbNum1,2)
    -- posX = posX + soldiersLbNum1:getContentSize().width
    
    -- -- 军衔提升
    -- local soldiersLbNum2 = GetTTFLabel("+"..playerVoApi:getRankTroops(),fontSize)
    -- soldiersLbNum2:setColor(G_ColorYellow)
    -- soldiersLbNum2:setAnchorPoint(ccp(0,0))
    -- soldiersLbNum2:setPosition(ccp(posX,posY))
    -- layer:addChild(soldiersLbNum2,2)
    -- posX = posX + soldiersLbNum2:getContentSize().width
    -- -- 统率提升
    -- local soldiersLbNum3 = GetTTFLabel("+"..playerVoApi:getTroopsNum(),fontSize)
    -- soldiersLbNum3:setColor(G_ColorGreen)
    -- soldiersLbNum3:setAnchorPoint(ccp(0,0))
    -- soldiersLbNum3:setPosition(ccp(posX,posY))
    -- layer:addChild(soldiersLbNum3,2)
    -- posX = posX + soldiersLbNum3:getContentSize().width
    -- -- 繁荣度提升
    -- if base.switchBoom==1 and base.boomTroops==1 then
    --     local soldiersLbNum4 = GetTTFLabel("+"..boomVoApi:getTroopsAdd(),fontSize)
    --     soldiersLbNum4:setColor(G_ColorGreenNew)
    --     soldiersLbNum4:setAnchorPoint(ccp(0,0))
    --     soldiersLbNum4:setPosition(ccp(posX,posY))
    --     layer:addChild(soldiersLbNum4,2)
    --     soldiersLbNum4:setTag(11056)
    --     posX = posX + soldiersLbNum4:getContentSize().width
    -- end
    
    -- -- local soldiersLbNum6 = GetTTFLabel(")",fontSize)
    -- -- soldiersLbNum6:setAnchorPoint(ccp(0,0))
    -- -- soldiersLbNum6:setPosition(ccp(posX,posY))
    -- -- layer:addChild(soldiersLbNum6,2)
    -- -- posX = posX + soldiersLbNum6:getContentSize().width
    
    -- -- 军徽加带兵量
    -- if base.emblemSwitch==1 then
    --     local emblemId = emblemVoApi:getBattleEquip(self.type)
    --     -- 获取此类型的军徽id
    --     local troopsAdd = emblemVoApi:getTroopsAddById(emblemId)
    --     local soldiersLbNum5 = GetTTFLabel("+"..troopsAdd,fontSize)
    --     soldiersLbNum5:setColor(G_ColorEquipPurple)
    --     soldiersLbNum5:setAnchorPoint(ccp(0,0))
    --     soldiersLbNum5:setPosition(ccp(posX+3,posY))
    --     soldiersLbNum5:setTag(11057)
    --     layer:addChild(soldiersLbNum5,2)
    -- end
    
    if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 or type == 38 then
    else
        local tipLb = GetTTFLabelWrap(getlocal("emblem_set_troops_tips"), strSize3, CCSizeMake(troopsBg:getContentSize().width - 50, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        -- local tipLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",20,CCSizeMake(troopsBg:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        tipLb:setAnchorPoint(ccp(0, 0.5))
        tipLb:setPosition(ccp(20, tipLb:getContentSize().height / 2 + 10))
        if type == 24 then
            tipLb:setPosition(ccp(10, tipLb:getContentSize().height / 2 + 15))
            troopsBg:addChild(tipLb, 2)
        else
            layerBg:addChild(tipLb, 2)
        end
        tipLb:setColor(G_ColorRed)
        
        if isLandTab and isLandTab.type == 8 and isLandTab.isDef and isLandTab.isDef > 0 and G_isIphone5() == false then
            tipLb:setVisible(false)
        end
    end
    
    --最大战力
    local function touchBestFight()
        PlayEffect(audioCfg.mouseClick)
        local function showBest(...)
            -- 获取最大战力
            local maxTb, heroTb, maxSuperEquipId, maxPlanePos, AITroops, bestAirshipId
            if self.type == 35 or self.type == 36 then
                maxTb, heroTb, maxSuperEquipId, maxPlanePos, AITroops, bestAirshipId = ltzdzFightApi:getBestTanks(type, self.cid)
            else
                maxTb, heroTb, maxSuperEquipId, maxPlanePos, AITroops, bestAirshipId = tankVoApi:getBestTanks(type)
            end
            
            -- 先选择最大强度的装备
            if base.emblemSwitch == 1 then
                local permitLevel = emblemVoApi:getPermitLevel()
                if self.type == 35 or self.type == 36 then
                    if maxSuperEquipId ~= nil then
                        self:showSuperEquipBtn(troopsBg, maxSuperEquipId, true)
                    else
                        self:showEmptyEquipBtn(troopsBg)
                    end
                else
                    if maxSuperEquipId ~= nil then
                        self:showSuperEquipBtn(troopsBg, maxSuperEquipId, true)
                    else
                        self:showEmptyEquipBtn(troopsBg)
                    end
                end
                
            end
            -- 先选择最大强度的飞机
            if base.plane == 1 then
                local permitLevel = planeVoApi:getOpenLevel()
                if self.type == 35 or self.type == 36 then
                    if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (ltzdzFightApi:numOfPlane() > 0) then
                        if maxPlanePos ~= nil then
                            self:showPlaneBtn(troopsBg, maxPlanePos, true)
                        else
                            self:showEmptyPlaneBtn(troopsBg)
                        end
                    end
                else
                    if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (planeVoApi:getPlaneTotalNum() > 0) then
                        if maxPlanePos ~= nil then
                            self:showPlaneBtn(troopsBg, maxPlanePos, true)
                        else
                            self:showEmptyPlaneBtn(troopsBg)
                        end
                    end
                end
            end
            -- 先选择最大强度的飞艇
            if airShipVoApi:isCanEnter() == true then
                if bestAirshipId ~= self.lastAirshipId then
                    airShipVoApi:setTempLineupId(bestAirshipId, self.type)
                    self:refreshAirshipBtn(bestAirshipId)
                    if self.extTroopsLayer then
                        self.extTroopsLayer:refreshUI()
                    end
                end
            end
            for i = 1, 6, 1 do
                local spA = layer:getChildByTag(i):getChildByTag(2)
                if spA ~= nil then
                    tankVoApi:deleteTanksTbByType(type, i)
                    spA:removeFromParentAndCleanup(true)
                end
                --将领文字变成无
                heroVoApi:deletTroopsByPos(i, type)
                AITroopsFleetVoApi:deleteAITroopsByPos(i, type)
                -- local tankSp=tolua.cast(layer:getChildByTag(i),"LuaCCSprite")
            end
            if self.type == 38 then --上锁的位置不能布置坦克
                local useIdx = 0
                for k, v in pairs(maxTb) do
                    if championshipWarVoApi:isHasTankByPosIdx(k) == true then
                        useIdx = useIdx + 1
                        local tank = maxTb[useIdx]
                        local sp = layer:getChildByTag(k)
                        tankVoApi:setTanksByType(type, k, tank[1], tank[2])
                        if tankSkinVoApi:checkBattleType(self.type) == true then
                            tankSkinVoApi:updateTempTankSkinToLatest(self.type, tank[1]) --同步一下部队缓存皮肤数据
                        end
                        self:addTouchSp(type, sp, tank[1], tank[2], layerNum, layer, 1, k)
                    end
                end
            else
                for k, v in pairs(maxTb) do
                    local sp = layer:getChildByTag(k)
                    tankVoApi:setTanksByType(type, k, v[1], v[2])
                    if tankSkinVoApi:checkBattleType(self.type) == true then
                        tankSkinVoApi:updateTempTankSkinToLatest(self.type, v[1]) --同步一下部队缓存皮肤数据
                    end
                    self:addTouchSp(type, sp, v[1], v[2], layerNum, layer, 1, k)
                end
            end
            if self.type == 35 or self.type == 36 then
                eventDispatcher:dispatchEvent("troops.change", {})
            end
            -- 重置数量
            self:resetQueueNum()
            local hVo
            local nameBg
            local heroLb
            --将领文字变更
            local heroUseIdx = 0
            for k, v in pairs(heroTb) do
                local hid
                if self.type == 38 then
                    if championshipWarVoApi:isHasTankByPosIdx(k) == true then
                        heroUseIdx = heroUseIdx + 1
                        hid = heroTb[heroUseIdx]
                    end
                else
                    hid = v
                end
                if hid and hid ~= 0 then
                    heroVoApi:setTroopsByPos(k, hid, type)
                    if self.type == 35 or self.type == 36 then
                        hVo = ltzdzFightApi:getHeroByHid(hid)
                    else
                        hVo = heroVoApi:getHeroByHid(hid)
                    end
                    nameBg = layer:getChildByTag(65760 + k)
                    -- nameBg=layer:getChildByTag(1980+k)
                    heroLb = tolua.cast(nameBg:getChildByTag(12), "CCLabelTTF")
                    if hVo then
                        local heroName = ""
                        if heroListCfg[hVo.hid] then
                            heroName = getlocal(heroListCfg[hVo.hid].heroName)
                        end
                        local level = hVo.level or 1
                        local productOrder = hVo.productOrder or 1
                        if heroName and heroName ~= "" and heroLb then
                            local heroStr = "Lv."..level.." "..heroName
                            heroStr = G_getPointStr(heroStr, nameBg:getContentSize().width, 20)
                            heroLb:setString(heroStr)
                        end
                        -- 将领星星
                        local star = productOrder
                        local starSize = 13
                        local starSp
                        local px
                        local py
                        for i = 1, star do
                            starSp = tolua.cast(nameBg:getChildByTag(200 + i), "CCSprite")
                            if starSp then
                                px = nameBg:getContentSize().width / 2 - starSize / 2 * (star - 1) + starSize * (i - 1)
                                py = nameBg:getContentSize().height - 5
                                starSp:setPosition(ccp(px, py))
                                starSp:setVisible(true)
                            end
                        end
                    else
                        if heroLb then
                            heroLb:setString(getlocal("fight_content_null"))
                        end
                        for i = 1, 5 do
                            local starSp = tolua.cast(nameBg:getChildByTag(200 + i), "CCSprite")
                            if starSp then
                                starSp:setVisible(false)
                            end
                        end
                    end
                end
            end
            
            --AI部队布置
            local aitUseIdx = 0
            for k, v in pairs(AITroops) do
                local atid
                if self.type == 38 then
                    if championshipWarVoApi:isHasTankByPosIdx(k) == true then
                        aitUseIdx = aitUseIdx + 1
                        atid = AITroops[aitUseIdx]
                    end
                else
                    atid = v
                end
                if atid and atid ~= 0 and atid ~= "" then
                    AITroopsFleetVoApi:setAITroopsByPos(k, atid, type)
                end
            end
            
            if type == 2 or type == 16 then
                local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
                local temLayer = tolua.cast(layer, "CCLayer")
                local fleetLb = temLayer:getChildByTag(19)
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
            
            self:resetSkillIcon()
            
            if newGuidMgr:isNewGuiding() == true then
                newGuidMgr:toNextStep()
            end
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 51 then
                otherGuideMgr:toNextStep()
            end
        end
        local function onGetCheckpoint()
            showBest()
        end
        local function onGetTech()
            local techFlag = checkPointVoApi:getTechFlag()
            if techFlag == -1 then
                local function challengeRewardlistCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        onGetCheckpoint()
                        checkPointVoApi:setTechFlag(1)
                    end
                end
                socketHelper:challengeRewardlist(challengeRewardlistCallback)
            else
                onGetCheckpoint()
            end
        end
        local function onGetAccessory()
            local alienTechOpenLv = base.alienTechOpenLv or 22
            if base.alien == 1 and base.richMineOpen == 1 and alienTechVoApi and alienTechVoApi.getTechData and playerVoApi:getPlayerLevel() >= alienTechOpenLv then
                alienTechVoApi:getTechData(onGetTech)
            else
                onGetTech()
            end
        end
        local function onGetPlane()
            if base.ifAccessoryOpen == 1 and accessoryVoApi.dataNeedRefresh == true then
                accessoryVoApi:refreshData(onGetAccessory)
            else
                onGetAccessory()
            end
        end
        if self.type == 35 or self.type == 36 then
            showBest()
            do return end
        end
        if planeVoApi:needInitData() == true then
            planeVoApi:planeGet(onGetPlane)
        else
            onGetPlane()
        end
    end
    local bestPic1 = "BtnOkSmall.png"
    local bestPic2 = "BtnOkSmall_Down.png"
    local scaleB = 1
    local menuLbSize = 25
    if type == 35 or type == 36 or type == 24 or type == 27 or type == 38 or type == 39 or type == 12 then
        bestPic1 = "newGreenBtn.png"
        bestPic2 = "newGreenBtn_down.png"
        scaleB = 0.8
        if type == 35 then
            scaleB = 0.6
            bestPic1 = "newGrayBtn2.png"
            bestPic2 = "newGrayBtn2_Down.png"
            menuLbSize = 22
        end
        
    end
    local bestItem = GetButtonItem(bestPic1, bestPic2, bestPic1, touchBestFight, nil, getlocal("autoMaxPower"), menuLbSize / scaleB, 101)
    bestItem:setScale(scaleB)
    -- local lb = bestItem:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local bestMenu = CCMenu:createWithItem(bestItem);
    bestMenu:setPosition(ccp(520, 80))
    bestMenu:setTouchPriority((-(layerNum - 1) * 20 - 5));
    layer:addChild(bestMenu)
    
    if type == 16 or type == 38 then
        bestMenu:setTag(101)
        bestItem:setTag(101)
    end
    if type == 1 or type == 2 or type == 3 or type == 5 or type == 10 or type == 12 or type == 13 or type == 14 or type == 15 or type == 16 or type == 19 or type == 20 or type == 21 or type == 22 or type == 23 then
        bestMenu:setPosition(ccp(320, 80))
    elseif type == 33 then
        if notTouch == nil then
            bestMenu:setPosition(ccp(180, 75))
        else
            bestMenu:setPosition(ccp(9999, 9999))
            bestMenu:setVisible(false)
        end
    elseif type == 1 or type == 30 then
        bestMenu:setPosition(ccp(160, 80))
    elseif type == 7 or type == 8 or type == 9 then
        bestMenu:setPosition(ccp(320, 70))
    elseif type == 17 or type == 32 or type == 24 or type == 25 or type == 26 then
        bestMenu:setPosition(ccp(320, 60))
    elseif type == 11 then
        bestItem:setScale(0.8)
        bestMenu:setPosition(ccp(393, 80))
    elseif type == 35 then
        bestMenu:setPosition(ccp(G_VisibleSizeWidth * 0.62, 150))
    elseif type == 36 or type == 38 then
        bestMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
    elseif type == 39 then --军团锦标赛军团战设置部队，不需要最大战力
        if championshipWarVoApi:isTestServer() == true then --测试服最大战力放开
            bestMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
        else
            bestMenu:setPosition(9999, 9999)
            bestMenu:setVisible(false)
        end
    end
    if type == 4 then
        if G_getIphoneType() == G_iphone4 then
            bestMenu:setPositionY(60)
        end
    end
    
    otherGuideMgr:setGuideStepField(51, bestItem, true)
    
    -- 推荐将领
    local function bestHero()
        PlayEffect(audioCfg.mouseClick)
        local maxTb
        if self.type == 35 or self.type == 36 then
            local tankTb = tankVoApi:getTanksTbByType(self.type)
            maxTb = ltzdzFightApi:bestHero(type, tankTb, self.cid)
            
        else
            maxTb = heroVoApi:bestHero(type, tankTb)
        end
        for i = 1, 6, 1 do
            local spA = layer:getChildByTag(i):getChildByTag(2)
            if spA ~= nil then
                heroVoApi:deletTroopsByPos(i, type)
                spA:removeFromParentAndCleanup(true)
            end
            
        end
        for k, v in pairs(maxTb) do
            local sp = layer:getChildByTag(k)
            heroVoApi:setTroopsByPos(k, v, type)
            local hvo
            if self.type == 35 or self.type == 36 then
                hvo = ltzdzFightApi:getHeroByHid(v)
            else
                hvo = heroVoApi:getHeroByHid(v)
            end
            if hvo then
                self:addHeroTouchSp(type, sp, hvo.hid, hvo.productOrder, layerNum, layer, 2)
            else
                local sp = tolua.cast(layer:getChildByTag(k), "CCSprite")
                if sp then
                    sp:setOpacity(0)
                end
            end
        end
    end
    local bestPic1 = "BtnOkSmall.png"
    local bestPic2 = "BtnOkSmall_Down.png"
    local scaleB = 1
    local menuLbSize = 25
    if type == 35 or type == 36 or type == 24 or type == 27 or type == 38 or type == 39 then
        bestPic1 = "newGreenBtn.png"
        bestPic2 = "newGreenBtn_down.png"
        scaleB = 0.8
        if type == 35 then
            scaleB = 0.6
            bestPic1 = "newGrayBtn2.png"
            bestPic2 = "newGrayBtn2_Down.png"
            menuLbSize = 22
        end
        
    end
    local bestHeroItem = GetButtonItem(bestPic1, bestPic2, bestPic1, bestHero, nil, getlocal("bestHero"), menuLbSize / scaleB, 101)
    bestHeroItem:setScale(scaleB)
    -- local lb = bestHeroItem:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local bestHeroMenu = CCMenu:createWithItem(bestHeroItem);
    bestHeroMenu:setPosition(ccp(520, 80))
    bestHeroMenu:setTouchPriority((-(layerNum - 1) * 20 - 5));
    layer:addChild(bestHeroMenu)
    if type == 1 or type == 2 or type == 3 or type == 5 or type == 10 or type == 12 or type == 13 or type == 14 or type == 15 or type == 16 or type == 19 or type == 20 or type == 21 or type == 22 or type == 23 then
        bestHeroMenu:setPosition(ccp(320, 80))
    elseif type == 33 then
        if notTouch == nil then
            bestHeroMenu:setPosition(ccp(180, 75))
        else
            bestHeroMenu:setPosition(ccp(9999, 9999))
            bestHeroMenu:setVisible(false)
        end
    elseif type == 1 or type == 30 then
        bestHeroMenu:setPosition(ccp(160, 80))
    elseif type == 7 or type == 8 or type == 9 then
        bestHeroMenu:setPosition(ccp(320, 70))
    elseif type == 17 or type == 32 or type == 24 or type == 25 or type == 26 then
        bestHeroMenu:setPosition(ccp(320, 60))
    elseif type == 11 then
        bestHeroItem:setScale(0.8)
        bestHeroMenu:setPosition(ccp(393, 80))
    elseif type == 35 then
        bestHeroMenu:setPosition(ccp(G_VisibleSizeWidth * 0.62, 150))
    elseif type == 36 or type == 38 then
        bestHeroMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
    elseif type == 39 then
        if championshipWarVoApi:isTestServer() == true then --测试服最大战力放开
            bestHeroMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
        else
            bestHeroMenu:setPosition(9999, 9999)
            bestHeroMenu:setVisible(false)
        end
    end
    bestHeroMenu:setVisible(false)
    if type == 4 then
        if G_getIphoneType() == G_iphone4 then
            bestHeroMenu:setPositionY(60)
        end
    end
    
    -- 推荐AI部队
    local function bestAITroops()
        PlayEffect(audioCfg.mouseClick)
        local maxTb
        if self.type == 35 or self.type == 36 then
            local tankTb = tankVoApi:getTanksTbByType(self.type)
            maxTb = ltzdzFightApi:bestAITroops(type, tankTb, self.cid)
            
        else
            maxTb = AITroopsFleetVoApi:bestAITroops(type, tankTb)
        end
        for i = 1, 6, 1 do
            local spA = layer:getChildByTag(i):getChildByTag(2)
            if spA ~= nil then
                AITroopsFleetVoApi:deleteAITroopsByPos(i, type)
                spA:removeFromParentAndCleanup(true)
            end
            
        end
        for k, v in pairs(maxTb) do
            local sp = layer:getChildByTag(k)
            AITroopsFleetVoApi:setAITroopsByPos(k, v, type)
            if v and v ~= 0 and v ~= "" then
                self:addAITroopsTouchSp(type, sp, v, layerNum, layer, 3)
            else
                local sp = tolua.cast(layer:getChildByTag(k), "CCSprite")
                if sp then
                    sp:setOpacity(0)
                end
            end
        end
    end
    
    local bestAITroopsItem = GetButtonItem(bestPic1, bestPic2, bestPic1, bestAITroops, nil, getlocal("bestAITroops"), menuLbSize / scaleB, 101)
    bestAITroopsItem:setScale(scaleB)
    local bestAITroopsMenu = CCMenu:createWithItem(bestAITroopsItem);
    bestAITroopsMenu:setPosition(ccp(520, 80))
    bestAITroopsMenu:setTouchPriority((-(layerNum - 1) * 20 - 5));
    layer:addChild(bestAITroopsMenu)
    if type == 1 or type == 2 or type == 3 or type == 5 or type == 10 or type == 12 or type == 13 or type == 14 or type == 15 or type == 16 or type == 19 or type == 20 or type == 21 or type == 22 or type == 23 then
        bestAITroopsMenu:setPosition(ccp(320, 80))
    elseif type == 33 then
        if notTouch == nil then
            bestAITroopsMenu:setPosition(ccp(180, 75))
        else
            bestAITroopsMenu:setPosition(ccp(9999, 9999))
            bestAITroopsMenu:setVisible(false)
        end
    elseif type == 1 or type == 30 then
        bestAITroopsMenu:setPosition(ccp(160, 80))
    elseif type == 7 or type == 8 or type == 9 then
        bestAITroopsMenu:setPosition(ccp(320, 70))
    elseif type == 17 or type == 32 or type == 24 or type == 25 or type == 26 then
        bestAITroopsMenu:setPosition(ccp(320, 60))
    elseif type == 11 then
        bestAITroopsItem:setScale(0.8)
        bestAITroopsMenu:setPosition(ccp(393, 80))
    elseif type == 35 then
        bestAITroopsMenu:setPosition(ccp(G_VisibleSizeWidth * 0.62, 150))
    elseif type == 36 or type == 38 then
        bestAITroopsMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
    elseif type == 39 then
        if championshipWarVoApi:isTestServer() == true then --测试服最大战力放开
            bestAITroopsMenu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
        else
            bestAITroopsMenu:setPosition(9999, 9999)
            bestAITroopsMenu:setVisible(false)
        end
    end
    
    bestAITroopsMenu:setVisible(false)
    
    local changeMenu = CCMenu:create()
    
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
    if self.type == 38 or self.type == 39 then
        changeItem:setPosition(ccp(troopsBg:getContentSize().width - changeItem:getContentSize().width - 16, troopsBg:getContentSize().height - changeItem:getContentSize().height - 10))
    else
        changeItem:setPosition(ccp(troopsBg:getContentSize().width - changeItem:getContentSize().width - 4, troopsBg:getContentSize().height - changeItem:getContentSize().height - 10))
    end
    --切换顺序：部队-AI部队-将领
    local function changeHandler()
        print("点击更换按钮了", changeItem:getSelectedIndex())
        if changeItem:getSelectedIndex() == 0 then
            self:changeHeroOrTank(type, 1, layer, layerNum, 1)
            bestHeroMenu:setVisible(false)
            bestMenu:setVisible(true)
            bestAITroopsMenu:setVisible(false)
        else
            if base.AITroopsSwitch == 1 then
                if changeItem:getSelectedIndex() == 1 then
                    self:changeHeroOrTank(type, 3, layer, layerNum, 1)
                    bestHeroMenu:setVisible(false)
                    bestMenu:setVisible(false)
                    bestAITroopsMenu:setVisible(true)
                else
                    self:changeHeroOrTank(type, 2, layer, layerNum, 1)
                    bestHeroMenu:setVisible(true)
                    bestMenu:setVisible(false)
                    bestAITroopsMenu:setVisible(false)
                end
            else
                self:changeHeroOrTank(type, 2, layer, layerNum, 1)
                bestHeroMenu:setVisible(true)
                bestMenu:setVisible(false)
            end
        end
        if callback then
            local clickIdx = changeItem:getSelectedIndex()
            --将领显示id为2，AI部队的显示id为3，所以在传参的时候需要特殊处理（将两者颠倒一下）
            if clickIdx ~= 0 then
                clickIdx = (clickIdx == 1) and 2 or 1
            end
            callback(clickIdx)
        end
    end
    changeItem:registerScriptTapHandler(changeHandler)
    changeMenu:addChild(changeItem)
    changeMenu:setAnchorPoint(ccp(0, 0))
    changeMenu:setPosition(ccp(0, 0))
    if type == 33 and notTouch ~= nil then
        changeMenu:setTouchPriority(-(layerNum - 1) * 20 - 11)
    elseif type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
        changeMenu:setTouchPriority(-(layerNum - 1) * 20 - 11)
    else
        changeMenu:setTouchPriority(-(layerNum - 1) * 20 - 5)
    end
    changeItem:setSelectedIndex(0)
    troopsBg:addChild(changeMenu, 1)
    
    self:changeHeroOrTank(type, 1, layer, layerNum, 0)
    
    -- 是否显示英雄按钮
    local showHeroFlag = false
    -- 将领开关没开
    if base.heroSwitch == 1 then
        -- -- 远征军判断是否还有未阵亡将领
        -- if type==11 then
        --     if SizeOfTable(heroVoApi:getCanSetBestHeroListExpedition())>0 then
        --         showHeroFlag = true
        --     end
        -- else
        --     if heroVoApi:isHaveHero()==true then
        --         showHeroFlag = true
        --     end
        -- end
        if buildingVoApi:isYouhua() then
            -- 指挥中心的等级
            local zhhzxVo = buildingVoApi:getBuildiingVoByBId(1)
            local zhhzxLevel = zhhzxVo.level
            -- 玩家等级
            local playerLevel = playerVoApi:getPlayerLevel()
            local heroOpenLv = base.heroOpenLv or 20
            -- local heroEquipOpenLv=base.heroEquipOpenLv or 30
            local bid = 9
            if homeCfg.buildingUnDisplay[bid][1] <= zhhzxLevel and homeCfg.buildingUnDisplay[bid][2] <= playerLevel then
                if self.type == 35 or self.type == 36 then
                    if playerLevel >= heroOpenLv or ltzdzFightApi:numOfhero() > 0 then
                        showHeroFlag = true
                    end
                else
                    local herolist = heroVoApi:getHeroList()
                    local soullist = heroVoApi:getSoulList()
                    if playerLevel >= heroOpenLv or SizeOfTable(herolist) > 0 or SizeOfTable(soullist) > 0 then
                        showHeroFlag = true
                    end
                end
                
            end
        else
            showHeroFlag = true
        end
    end
    
    -- 不显示将领按钮
    if showHeroFlag == false then
        changeItem:setVisible(false)
        changeItem:setPosition(ccp(10000, 0))
        
        local heroSp = CCSprite:createWithSpriteFrameName("st_unlock.png")
        heroSp:setAnchorPoint(ccp(1, 1))
        heroSp:setFlipX(true)
        heroSp:setPosition(ccp(troopsBg:getContentSize().width - 8, troopsBg:getContentSize().height - 10))
        troopsBg:addChild(heroSp)
    end
    
    -- 是否显示军徽
    local showSuperEquipFlag = false
    -- 显示军徽按钮
    if base.emblemSwitch == 1 then
        local permitLevel = emblemVoApi:getPermitLevel()
        -- if emblemVoApi:getEquipTotalNum()>0 then
        --打开军徽功能条件下，如果军徽建筑解锁或者玩家已经拥有军徽，则选择军徽按钮显示
        if self.type == 35 or self.type == 36 then
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (ltzdzFightApi:numOfEmblem() > 0) then
                showSuperEquipFlag = true
            end
        else
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (emblemVoApi:getEquipTotalNum() > 0) then
                showSuperEquipFlag = true
            end
        end
        
        -- end
    end
    if showSuperEquipFlag == true then
        -- 获取此类型的军徽id
        local battleEquip = emblemVoApi:getBattleEquip(self.type, self.cid)
        local showEmptyEquipFlag = false
        if self.type == 11 then
            showEmptyEquipFlag = true
        end
        if battleEquip == nil or showEmptyEquipFlag == true then
            self:showEmptyEquipBtn(troopsBg)
        else
            self:showSuperEquipBtn(troopsBg, battleEquip, nil, 0)
        end
    else
        local equipSp = CCSprite:createWithSpriteFrameName("st_unlock.png")
        equipSp:setAnchorPoint(ccp(0, 0))
        -- equipSp:setPosition(ccp(8,8))
        if G_isIphone5() == true then
            equipSp:setPosition(ccp(troopsBg:getContentSize().width - 92 - 8, 170 + 25))
        else
            equipSp:setPosition(ccp(troopsBg:getContentSize().width - 92 - 8, 170))
        end
        if self.type == 24 or self.type == 27 then
            equipSp:setPositionY(equipSp:getPositionY() + 50)
        end
        troopsBg:addChild(equipSp)
    end
    
    -- 是否显示飞机
    local showPlaneFlag = false
    -- 显示飞机按钮
    if base.plane == 1 then
        local permitLevel = planeVoApi:getOpenLevel()
        if type == 35 or self.type == 36 then
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (ltzdzFightApi:numOfPlane() > 0) then
                showPlaneFlag = true
            end
        else
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (planeVoApi:getPlaneTotalNum() > 0) then
                showPlaneFlag = true
            end
        end
        
    end
    if showPlaneFlag == true then
        -- 获取此类型的飞机id
        local battlePlane = planeVoApi:getBattleEquip(self.type, self.cid)
        local showEmptyPlaneFlag = false
        if self.type == 11 then
            showEmptyPlaneFlag = true
        end
        if battlePlane == nil or showEmptyPlaneFlag == true then
            self:showEmptyPlaneBtn(troopsBg)
        else
            self:showPlaneBtn(troopsBg, battlePlane, nil, 0)
        end
    else
        local planeSp = CCSprite:createWithSpriteFrameName("st_unlock.png")
        planeSp:setAnchorPoint(ccp(0, 0))
        -- planeSp:setPosition(ccp(8,8))
        if self.type == 24 or self.type == 27 then
            planeSp:setPosition(ccp(troopsBg:getContentSize().width - 92 - 8, 62))
        else
            planeSp:setPosition(ccp(troopsBg:getContentSize().width - 92 - 8, 12))
        end
        troopsBg:addChild(planeSp)
    end
    
    -- 不显示最大战力与推荐将领按钮
    if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
        bestMenu:setVisible(false)
        bestMenu:setPosition(ccp(10000, 0))
        bestHeroMenu:setVisible(false)
        bestHeroMenu:setPosition(ccp(10000, 0))
        bestAITroopsMenu:setVisible(false)
        bestAITroopsMenu:setPosition(ccp(10000, 0))
    end
    if base.he == 1 and heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
        if((base.heroEquipOpenLv and playerVoApi:getPlayerLevel() < base.heroEquipOpenLv) or(base.heroOpenLv and playerVoApi:getPlayerLevel() < base.heroOpenLv))then
        else
            heroEquipVoApi:equipGet()
        end
    end
    
    if newGuidMgr:isNewGuiding() == true then
        local nextStepId = newGuidCfg[newGuidMgr.curStep].toStepId
        if nextStepId then
            if newGuidMgr.curStep == 12 or newGuidMgr.curStep == 13 then
                newGuidMgr:setGuideStepField(nextStepId, bestItem, true)
            end
        end
    end
end

function editTroopsLayer:touchBlank(tag, isShowTank)
    -- print("点击添加",tag,isShowTank)
    if G_checkClickEnable() == false then
        do
            return
        end
    end
    if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
        do return end
    end
    if isShowTank == 1 then
        --士兵
        if self.type == 4 and allianceWarVoApi:getSelfOid() > 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
            do
                return
            end
        end
        
        local function callBack(id, num)
            if num and num == 0 then
                return
            end
            if(self and self.parentLayer and tolua.cast(self.parentLayer, "CCNode"))then
                tankVoApi:setTanksByType(self.type, tag, id, num)
                if base.tskinSwitch == 1 and tankSkinVoApi:checkBattleType(self.type) == true then
                    local tskinOld = G_clone(tankSkinVoApi:getTempTankSkinList(self.type))
                    local tankTb = tankVoApi:getTanksTbByType(self.type)
                    for k, v in pairs(tankTb) do
                        if v[1] and v[2] then
                            tankSkinVoApi:updateTempTankSkinToLatest(self.type, v[1])
                            local tskin = tankSkinVoApi:getTempTankSkinList(self.type)
                            local tid = tankSkinVoApi:convertTankId(v[1])
                            if tskinOld[tid] ~= tskin[tid] and k ~= tag then
                                local sp = self.parentLayer:getChildByTag(k)
                                self:addTouchSp(self.type, sp, v[1], v[2], self.layerNum, self.parentLayer, isShowTank, k)
                            end
                        end
                    end
                end
                if base.tskinSwitch == 1 then
                    tankSkinVoApi:updateTempTankSkinToLatest(self.type, id)
                end
                local sp = self.parentLayer:getChildByTag(tag)
                self:addTouchSp(self.type, sp, id, num, self.layerNum, self.parentLayer, isShowTank, tag)
            end
            if self.type == 35 or self.type == 36 then
                eventDispatcher:dispatchEvent("troops.change", {})
            end
        end
        if self.type == 35 or self.type == 36 then
            ltzdzFightApi:showSelectTankDialog(self.layerNum + 1, true, true, callBack, getlocal("choiceFleet"), self.type, self.cid)
        else
            require "luascript/script/game/scene/gamedialog/warDialog/selectTankDialog"
            selectTankDialog:showSelectTankDialog(self.type, self.layerNum + 1, callBack)
        end
        
        PlayEffect(audioCfg.mouseClick)
        
        if self.type == 2 or self.type == 16 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(self.type)))
            local temLayer = tolua.cast(self.parentLayer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            if fleetLb then
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
        end
        
        self:resetSkillIcon()
    else
        local tanksTb = tankVoApi:getTanksTbByType(self.type)
        if self.type == 4 then
            if allianceWarVoApi:getSelfOid() > 0 then
                tanksTb = tankVoApi:getTanksTbByType(6)
            end
        end
        local tankidx = tag
        if tanksTb and tanksTb[tankidx] then
            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("troops_no_tank"),30)
            if SizeOfTable(tanksTb[tankidx]) == 0 then
                -- print("当前位置没有设置坦克")
                if isShowTank == 2 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("troops_no_tank"), 30)
                else
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_equip_notank"), 30)
                end
                do return end
            end
        end
        if isShowTank == 2 then
            --将领
            local function callBack(hid, productOrder)
                local sp = self.parentLayer:getChildByTag(tag)
                heroVoApi:setTroopsByPos(tag, hid, self.type)
                self:addHeroTouchSp(self.type, sp, hid, productOrder, self.layerNum, self.parentLayer, 2)
            end
            require "luascript/script/game/scene/gamedialog/heroDialog/selectHeroDialog"
            selectHeroDialog:showselectHeroDialog(self.type, self.layerNum + 1, callBack, self.cid)
        elseif isShowTank == 3 then
            local equipLimitNum = AITroopsFleetVoApi:AITroopsEquipLimitNum()
            local troopsTb = AITroopsFleetVoApi:getAITroopsTb()
            local equipNum = 0
            for k, v in pairs(troopsTb) do
                if v ~= 0 and tostring(v) ~= "" then
                    equipNum = equipNum + 1
                end
            end
            if equipNum >= equipLimitNum then --装配数量已达上限
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_equip_reachlimit", {equipLimitNum}), 30)
                do return end
            end
            --AI部队
            local function callBack(atid)
                local sp = self.parentLayer:getChildByTag(tag)
                AITroopsFleetVoApi:setAITroopsByPos(tag, atid, self.type)
                self:addAITroopsTouchSp(self.type, sp, atid, self.layerNum, self.parentLayer, 3)
            end
            --选择出战AI部队页面
            AITroopsFleetVoApi:showSelectAITroopsDialog(self.type, self.layerNum + 1, callBack, self.cid)
        end
        PlayEffect(audioCfg.mouseClick)
    end
end

function editTroopsLayer:changeHeroOrTank(type, isShowTank, layer, layerNum, isFirst, tankTb, heroTb, emblemId, planePos, aitroops)
    local tHeight = self.tHeight
    if isFirst == 2 then
        -- 刷新军徽
        if base.emblemSwitch == 1 then
            local battleEquip = nil
            if emblemId then
                if tostring(emblemId) ~= "0" then
                    battleEquip = emblemId
                end
            else--if emblemVoApi:getEquipTotalNum()>0 then
                battleEquip = emblemVoApi:getBattleEquip(type, self.cid)
            end
            local troopsBg = tolua.cast(layer:getChildByTag(4534), "CCSprite")
            if battleEquip == nil then
                self:showEmptyEquipBtn(troopsBg)
            else
                self:showSuperEquipBtn(troopsBg, battleEquip, nil, isFirst)
            end
        end
        -- 刷新飞机
        if base.plane == 1 then
            local battlePlane = nil
            if planePos then
                if tostring(planePos) ~= "0" then
                    battlePlane = planePos
                end
            else
                battlePlane = planeVoApi:getBattleEquip(type, self.cid)
            end
            local troopsBg = tolua.cast(layer:getChildByTag(4534), "CCSprite")
            if battlePlane == nil then
                self:showEmptyPlaneBtn(troopsBg)
            else
                self:showPlaneBtn(troopsBg, battlePlane, nil, isFirst)
            end
        end
    end
    local tanksTb = tankVoApi:getTanksTbByType(type)
    if tankTb then
        tanksTb = tankTb
    end
    -- if type==4 then
    --     if allianceWarVoApi:getSelfOid()>0 then
    --        tanksTb=tankVoApi:getTanksTbByType(6)
    --     end
    -- end
    
    self.isShowTank = isShowTank
    -- 排列按钮
    if self.type == 38 then --军团锦标赛个人战布置部队的处理
        local tag = 0
        local tankX, tankY = G_VisibleSize.width / 2 - 50, self.tankPosY
        local xOff, yOff = 6, 5
        if G_isIphone5() == true then
            yOff = 5 + 25
        end
        self.tankIconWidth = 70
        self.myTankPosX, self.myTankPosY = 15 + self.tankIconWidth / 2, 15 + self.tankIconWidth / 2
        local showIdx = 0
        for i = 0, 1, 1 do
            for j = 0, 2, 1 do
                local posIdx = ((j + 1) + (i * 3))
                tag = posIdx
                local unlockFlag = championshipWarVoApi:isHasTankByPosIdx(posIdx)
                local bgSp = tolua.cast(layer:getChildByTag(tag), "CCSprite")
                if bgSp == nil then
                    bgSp = CCSprite:createWithSpriteFrameName("st_select2.png")
                    bgSp:setTag(tag)
                    bgSp:setOpacity(0)
                    bgSp:setPosition(tankX + (bgSp:getContentSize().width + xOff) * (0.5 - (i * 1)), tankY - bgSp:getContentSize().height * j - yOff * j)
                    layer:addChild(bgSp, 2)
                    
                    local bgSp1 = CCSprite:createWithSpriteFrameName("st_select1.png")
                    bgSp1:setPosition(bgSp:getPositionX(), bgSp:getPositionY())
                    layer:addChild(bgSp1, 1)
                    self.iconBgTab[tag] = bgSp1
                    if unlockFlag == false then
                        local lockSp = CCSprite:createWithSpriteFrameName("csi_trooplock.png")
                        lockSp:setPosition(getCenterPoint(bgSp1))
                        bgSp1:addChild(lockSp, 5)
                    end
                    local nullTankSp = CCSprite:createWithSpriteFrameName("troopsVsBg.png")
                    nullTankSp:setAnchorPoint(ccp(0.5, 0.5))
                    nullTankSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2))
                    nullTankSp:setVisible(false)
                    bgSp1:addChild(nullTankSp, 1)
                    self.nullTankTb[tag] = nullTankSp
                    --部队位置
                    local numberSp = CCSprite:createWithSpriteFrameName("tankPos"..posIdx..".png")
                    numberSp:setAnchorPoint(ccp(1, 0))
                    numberSp:setScale(0.6)
                    numberSp:setPosition(ccp(nullTankSp:getContentSize().width - 12, 12))
                    nullTankSp:addChild(numberSp, 1)
                    -- 英雄为空时显示
                    local nullHeroSp = CCSprite:createWithSpriteFrameName("selectTankBg3.png")
                    nullHeroSp:setAnchorPoint(ccp(0.5, 0.5))
                    nullHeroSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 10))
                    nullHeroSp:setVisible(false)
                    bgSp1:addChild(nullHeroSp, 1)
                    nullHeroSp:setScale(0.8)
                    self.nullHeroTb[tag] = nullHeroSp
                    local selectTankBg21 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                    selectTankBg21:setAnchorPoint(ccp(0.5, 0.5))
                    selectTankBg21:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 35))
                    nullHeroSp:addChild(selectTankBg21)
                    local posSp1 = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                    posSp1:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 10))
                    nullHeroSp:addChild(posSp1, 1)
                    
                    -- AI部队为空时显示
                    local nullAITroopsSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                    nullAITroopsSp:setAnchorPoint(ccp(0.5, 0.5))
                    nullAITroopsSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 15))
                    nullAITroopsSp:setVisible(false)
                    bgSp1:addChild(nullAITroopsSp, 1)
                    nullAITroopsSp:setScale(0.8)
                    self.nullAITroopsTb[tag] = nullAITroopsSp
                    local selectTankBg22 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                    selectTankBg22:setAnchorPoint(ccp(0.5, 0.5))
                    selectTankBg22:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 35))
                    nullAITroopsSp:addChild(selectTankBg22)
                    local posSp2 = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                    posSp2:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 10))
                    nullAITroopsSp:addChild(posSp2, 1)
                    
                    self.posTab[tag] = ccp(bgSp:getPositionX(), bgSp:getPositionY())
                    self.iconTab[tag] = bgSp
                    
                    local capInSet = CCRect(20, 20, 10, 10)
                    local function touch(hd, fn, idx)
                    end
                    local headNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, touch)
                    headNameBg:setContentSize(CCSizeMake(bgSp1:getContentSize().width, 40))
                    headNameBg:setAnchorPoint(ccp(0.5, 0.5))
                    headNameBg:setPosition(ccp(bgSp:getPositionX() - 0, bgSp:getPositionY() + bgSp:getContentSize().height / 2 - headNameBg:getContentSize().height / 2))
                    headNameBg:setTag(65760 + tag)
                    layer:addChild(headNameBg, 6)
                    headNameBg:setOpacity(0)
                    
                    -- 头顶显示文字
                    local headNameLb = GetTTFLabel(getlocal("fight_content_null"), 20)
                    headNameLb:setAnchorPoint(ccp(0.5, 0.5))
                    headNameLb:setPosition(ccp(headNameBg:getContentSize().width / 2, headNameBg:getContentSize().height / 2))
                    headNameLb:setTag(12)
                    headNameBg:addChild(headNameLb, 1)
                    
                    -- 头顶显示将领的时候显示品质星级
                    local star = 5
                    local px = 0
                    local py = 0
                    local starSize = 13
                    local starSp
                    for i = 1, star do
                        starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                        starSp:setScale(starSize / starSp:getContentSize().width)
                        px = headNameBg:getContentSize().width / 2 - starSize / 2 * (star - 1) + starSize * (i - 1)
                        py = headNameBg:getContentSize().height - 5
                        starSp:setPosition(ccp(px, py))
                        starSp:setTag(200 + i)
                        headNameBg:addChild(starSp, 1)
                        starSp:setVisible(false)
                    end
                end
                --每次切换需要刷新背景
                bgSp:setOpacity(0)
                --移除掉之前add的touchSp,准备添加新的舰队或将领
                if bgSp:getChildByTag(2) then
                    local sp2 = bgSp:getChildByTag(2)
                    if sp2 then
                        sp2:removeFromParentAndCleanup(true)
                    end
                end
                local htb = heroVoApi:getChampionshipWarPersonalHeroTb()
                local aitb = AITroopsFleetVoApi:getChampionshipWarPersonalAITroopsTb()
                -- heroVoApi:setTroopsByTb(htb)
                --获取将领数据
                local hVo
                if heroVoApi:isHaveTroops() then
                    if heroVoApi:getTroopsHeroList()[tag] ~= nil and heroVoApi:getTroopsHeroList()[tag] ~= 0 then
                        local hid = heroVoApi:getTroopsHeroList()[tag]
                        if hid and hid ~= 0 then
                            local hidArr = Split(hid, "-")
                            if hidArr and hidArr[1] then
                                hid = hidArr[1]
                                
                                if self.type == 35 or self.type == 36 then
                                    hVo = ltzdzFightApi:getHeroByHid(hid)
                                else
                                    hVo = heroVoApi:getHeroByHid(hid)
                                end
                                if hVo then
                                    productOrder = hVo.productOrder
                                    heroVoApi:setTroopsByPos(tag, hid, type)
                                end
                            end
                        end
                    end
                end
                local atid
                if AITroopsFleetVoApi:isHaveAITroops() then
                    local aitb = AITroopsFleetVoApi:getAITroopsTb()
                    atid = aitb[tag]
                    if atid and atid ~= 0 and atid ~= "" then
                        AITroopsFleetVoApi:setAITroopsByPos(tag, atid, type)
                    end
                end
                if self.isShowTank == 1 then --显示坦克
                    if self.nullTankTb and self.nullTankTb[tag] then
                        self.nullTankTb[tag]:setVisible(true)
                    end
                    if self.nullHeroTb and self.nullHeroTb[tag] then
                        self.nullHeroTb[tag]:setVisible(false)
                    end
                    local headNameBg = layer:getChildByTag(65760 + tag)
                    local headNameLb = tolua.cast(headNameBg:getChildByTag(12), "CCLabelTTF")
                    if headNameBg and headNameLb then
                        headNameBg:setVisible(false)
                    end
                    local nullTankSp = self.nullTankTb[tag]
                    local enemyTanks = championshipWarVoApi:getAttackCheckpointEnemyTanks() --敌方坦克情况
                    local enemyTankId = enemyTanks[posIdx][1]
                    if enemyTankId then
                        enemyTankId = tonumber(RemoveFirstChar(enemyTankId))
                    end
                    local enemyTankNum = enemyTanks[posIdx][2]
                    local enemyTankPosX, enemyTankPosY = nullTankSp:getContentSize().width - 15 - self.tankIconWidth / 2, nullTankSp:getContentSize().height - 15 - self.tankIconWidth / 2
                    if unlockFlag == true then --如果敌方该位置有坦克，则我方可以设置坦克
                        local addBtnTag = 101
                        local addBtnSp = tolua.cast(nullTankSp:getChildByTag(addBtnTag), "CCSprite")
                        if addBtnSp == nil then
                            addBtnSp = CCSprite:createWithSpriteFrameName("st_addIcon.png")
                            addBtnSp:setPosition(self.myTankPosX, self.myTankPosY)
                            addBtnSp:setTag(addBtnTag)
                            nullTankSp:addChild(addBtnSp, 1)
                            -- 忽隐忽现
                            local fade1 = CCFadeTo:create(1, 55)
                            local fade2 = CCFadeTo:create(1, 255)
                            local seq = CCSequence:createWithTwoActions(fade1, fade2)
                            local repeatEver = CCRepeatForever:create(seq)
                            addBtnSp:runAction(repeatEver)
                        end
                        if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then --我方坦克情况
                            if tanksTb[posIdx] ~= nil and SizeOfTable(tanksTb[posIdx]) > 0 then
                                local id = tanksTb[posIdx][1]
                                local num = tanksTb[posIdx][2]
                                if id and id ~= 0 then --如果该位置有部队则隐藏加号按钮
                                    addBtnSp:setVisible(false)
                                    addBtnSp:setPosition(-99999, self.myTankPosY)
                                    self:addTouchSp(type, bgSp, id, num, layerNum, layer, isShowTank, posIdx)
                                else
                                    addBtnSp:setVisible(true)
                                    addBtnSp:setPosition(self.myTankPosX, self.myTankPosY)
                                end
                            end
                        end
                    end
                    local enemyTankTag = 104
                    local enemyTankSp = tolua.cast(nullTankSp:getChildByTag(enemyTankTag), "CCSprite")
                    if enemyTankId and enemyTankId ~= 0 then --如果该位置有部队则隐藏加号按钮
                        if enemyTankSp == nil then
                            enemyTankSp = tankVoApi:getTankIconSp(enemyTankId, nil, nil, false)--CCSprite:createWithSpriteFrameName(tankCfg[enemyTankId].icon)
                            local scale = self.tankIconWidth / enemyTankSp:getContentSize().width
                            enemyTankSp:setScale(scale)
                            enemyTankSp:setPosition(enemyTankPosX, enemyTankPosY)
                            enemyTankSp:setTag(enemyTankTag)
                            nullTankSp:addChild(enemyTankSp, 1)
                            enemyTankSp:setOpacity(0)
                            enemyTankSp:setScale(0)
                            local fadeIn = CCFadeIn:create(0.3)
                            local scaleTo = CCScaleTo:create(0.3, scale)
                            local arr = CCArray:create()
                            arr:addObject(fadeIn)
                            arr:addObject(scaleTo)
                            local spawn = CCSpawn:create(arr)
                            local delayT = CCDelayTime:create(0.3 + showIdx * 0.3)
                            local scaleTo2 = CCScaleTo:create(0.1, scale + 0.5)
                            local scaleTo3 = CCScaleTo:create(0.03, scale - 0.2)
                            local scaleTo4 = CCScaleTo:create(0.05, scale)
                            local arr2 = CCArray:create()
                            arr2:addObject(delayT)
                            arr2:addObject(spawn)
                            arr2:addObject(scaleTo2)
                            arr2:addObject(scaleTo3)
                            arr2:addObject(scaleTo4)
                            local seq = CCSequence:create(arr2)
                            enemyTankSp:runAction(seq)
                            
                            showIdx = showIdx + 1
                        end
                    else
                        if enemyTankSp then
                            enemyTankSp:setVisible(false)
                            enemyTankSp:setPosition(-99999, enemyTankPosY)
                        end
                    end
                else --显示将领
                    --底部将领信息
                    local headNameBg = layer:getChildByTag(65760 + tag)
                    local headNameLb = tolua.cast(headNameBg:getChildByTag(12), "CCLabelTTF")
                    if headNameBg and headNameLb then
                        headNameBg:setVisible(true)
                        if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then
                            if tanksTb[tag] ~= nil and SizeOfTable(tanksTb[tag]) > 0 then
                                local id = tanksTb[tag][1]
                                local num = tanksTb[tag][2]
                                local tId = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                                local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tId].name), num})
                                tankStr = G_getPointStr(tankStr, bgSp:getContentSize().width, 20)
                                headNameLb:setString(tankStr)
                            else
                                headNameLb:setString(getlocal("fight_content_null"))
                            end
                        else
                            headNameLb:setString(getlocal("fight_content_null"))
                        end
                    end
                    --隐藏星星
                    local starSp
                    for i = 1, 5 do
                        starSp = tolua.cast(headNameBg:getChildByTag(200 + i), "CCSprite")
                        if starSp then
                            starSp:setVisible(false)
                        end
                    end
                    if isShowTank == 2 then
                        if self.nullTankTb and self.nullTankTb[tag] then
                            self.nullTankTb[tag]:setVisible(false)
                        end
                        if self.nullHeroTb and self.nullHeroTb[tag] then
                            self.nullHeroTb[tag]:setVisible(true)
                        end
                        if self.nullAITroopsTb and self.nullAITroopsTb[tag] then
                            self.nullAITroopsTb[tag]:setVisible(false)
                        end
                        if hVo then
                            bgSp:setOpacity(255)
                            self:addHeroTouchSp(type, bgSp, hVo.hid, hVo.productOrder, layerNum, layer, isShowTank)
                        end
                    else
                        if self.nullTankTb and self.nullTankTb[tag] then
                            self.nullTankTb[tag]:setVisible(false)
                        end
                        if self.nullHeroTb and self.nullHeroTb[tag] then
                            self.nullHeroTb[tag]:setVisible(false)
                        end
                        if self.nullAITroopsTb and self.nullAITroopsTb[tag] then
                            self.nullAITroopsTb[tag]:setVisible(true)
                        end
                        --显示AI部队配置情况
                        if atid and (atid ~= 0 and tostring(atid) ~= "") then
                            bgSp:setOpacity(255)
                            self:addAITroopsTouchSp(type, bgSp, atid, layerNum, layer, isShowTank)
                        end
                    end
                end
            end
        end
        do return end
    end
    for i = 0, 1, 1 do
        for j = 0, 2, 1 do
            local tag = ((j + 1) + (i * 3))
            local bgSp = tolua.cast(layer:getChildByTag(tag), "CCSprite")
            if bgSp == nil then
                -- 有舰队或者将领才显示
                bgSp = CCSprite:createWithSpriteFrameName("st_select2.png")
                bgSp:setTag(tag)
                bgSp:setOpacity(0)
                local tankX = G_VisibleSize.width / 2--441
                local tankY = self.tankPosY
                local yOff = 5--35
                if G_isIphone5() == true then
                    yOff = 5 + 25
                end
                local xOff = 6
                -- -- 第一行需要向左移
                -- if j==0 then
                if self.type == 39 then
                    tankX = G_VisibleSize.width / 2 - 50--397
                else
                    tankX = G_VisibleSize.width / 2 - 45--397
                end
                -- elseif j==2 then -- 第二行需要向右移
                --     tankX = G_VisibleSize.width/2+45--483
                -- end
                -- bgSp:setPosition(tankX-(bgSp:getContentSize().width+5)*i,tHeight-tankY-bgSp:getContentSize().height*j-yOff*j)
                bgSp:setPosition(tankX + (bgSp:getContentSize().width + xOff) * (0.5 - (i * 1)), tankY - bgSp:getContentSize().height * j - yOff * j)
                layer:addChild(bgSp, 2)
                if i == 1 and j == 0 and self.type == 35 then --测试代码
                    otherGuideMgr:setGuideStepField(47, nil, true, {bgSp, 1})
                end
                
                local bgSp1 = CCSprite:createWithSpriteFrameName("st_select1.png")
                bgSp1:setPosition(bgSp:getPositionX(), bgSp:getPositionY())
                layer:addChild(bgSp1, 1)
                self.iconBgTab[tag] = bgSp1
                
                -- 舰队为空时显示
                local nullTankSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullTankSp:setAnchorPoint(ccp(0.5, 0.5))
                nullTankSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 10))
                nullTankSp:setVisible(false)
                bgSp1:addChild(nullTankSp, 1)
                nullTankSp:setScale(0.8)
                self.nullTankTb[tag] = nullTankSp
                local selectTankBg2 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg2:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg2:setPosition(ccp(nullTankSp:getContentSize().width / 2, nullTankSp:getContentSize().height / 2 - 35))
                nullTankSp:addChild(selectTankBg2)
                local posSp = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp:setPosition(ccp(nullTankSp:getContentSize().width / 2, nullTankSp:getContentSize().height / 2 - 10))
                nullTankSp:addChild(posSp, 1)
                
                -- 英雄为空时显示
                local nullHeroSp = CCSprite:createWithSpriteFrameName("selectTankBg3.png")
                nullHeroSp:setAnchorPoint(ccp(0.5, 0.5))
                nullHeroSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 10))
                nullHeroSp:setVisible(false)
                bgSp1:addChild(nullHeroSp, 1)
                nullHeroSp:setScale(0.8)
                self.nullHeroTb[tag] = nullHeroSp
                local selectTankBg21 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg21:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg21:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 35))
                nullHeroSp:addChild(selectTankBg21)
                local posSp1 = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp1:setPosition(ccp(nullHeroSp:getContentSize().width / 2, nullHeroSp:getContentSize().height / 2 - 10))
                nullHeroSp:addChild(posSp1, 1)
                
                -- AI部队为空时显示
                local nullAITroopsSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullAITroopsSp:setAnchorPoint(ccp(0.5, 0.5))
                nullAITroopsSp:setPosition(ccp(bgSp1:getContentSize().width / 2, bgSp1:getContentSize().height / 2 - 10))
                nullAITroopsSp:setVisible(false)
                bgSp1:addChild(nullAITroopsSp, 1)
                nullAITroopsSp:setScale(0.8)
                self.nullAITroopsTb[tag] = nullAITroopsSp
                local selectTankBg22 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg22:setAnchorPoint(ccp(0.5, 0.5))
                selectTankBg22:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 35))
                nullAITroopsSp:addChild(selectTankBg22)
                local posSp2 = CCSprite:createWithSpriteFrameName("tankPos"..tag..".png")
                posSp2:setPosition(ccp(nullAITroopsSp:getContentSize().width / 2, nullAITroopsSp:getContentSize().height / 2 - 10))
                nullAITroopsSp:addChild(posSp2, 1)
                
                -- local queueNum=CCSprite:createWithSpriteFrameName("troops_pos_"..tag..".png")
                -- queueNum:setAnchorPoint(ccp(1,0))
                -- queueNum:setPosition(ccp(bgSp1:getContentSize().width-8,8))   --(ccp(bgSp1:getContentSize().width/2,bgSp1:getContentSize().height/2))
                -- bgSp1:addChild(queueNum,1)
                
                self.posTab[tag] = ccp(bgSp:getPositionX(), bgSp:getPositionY())
                self.iconTab[tag] = bgSp
                
                -- -- 头顶文字背景
                -- local headNameBg=CCSprite:createWithSpriteFrameName("troops_name_bg.png")
                
                -- local capInSet = CCRect(20, 20, 10, 10)
                -- local function cellClick(hd,fn,idx)
                -- end
                -- local headNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
                
                local capInSet = CCRect(20, 20, 10, 10)
                local function touch(hd, fn, idx)
                end
                local headNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png", capInSet, touch)
                headNameBg:setContentSize(CCSizeMake(bgSp1:getContentSize().width, 40))
                headNameBg:setAnchorPoint(ccp(0.5, 0.5))
                headNameBg:setPosition(ccp(bgSp:getPositionX() - 0, bgSp:getPositionY() + bgSp:getContentSize().height / 2 - headNameBg:getContentSize().height / 2))
                headNameBg:setTag(65760 + tag)
                layer:addChild(headNameBg, 6)
                headNameBg:setOpacity(0)
                
                -- 头顶显示文字
                local headNameLb = GetTTFLabel(getlocal("fight_content_null"), 20)
                headNameLb:setAnchorPoint(ccp(0.5, 0.5))
                headNameLb:setPosition(ccp(headNameBg:getContentSize().width / 2, headNameBg:getContentSize().height / 2))
                headNameLb:setTag(12)
                headNameBg:addChild(headNameLb, 1)
                
                -- 头顶显示将领的时候显示品质星级
                local star = 5
                local px = 0
                local py = 0
                local starSize = 13
                local starSp
                for i = 1, star do
                    starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                    starSp:setScale(starSize / starSp:getContentSize().width)
                    px = headNameBg:getContentSize().width / 2 - starSize / 2 * (star - 1) + starSize * (i - 1)
                    py = headNameBg:getContentSize().height - 5
                    -- px = bgSp1:getContentSize().width/2-starSize/2*(star-1)+starSize*(i-1)
                    -- py = bgSp1:getContentSize().height-8
                    starSp:setPosition(ccp(px, py))
                    starSp:setTag(200 + i)
                    headNameBg:addChild(starSp, 1)
                    starSp:setVisible(false)
                end
            end
            
            -- 每次切换需要刷新背景
            bgSp:setOpacity(0)
            -- 移除掉之前add的touchSp,准备添加新的舰队或将领
            if bgSp:getChildByTag(2) then
                local sp2 = bgSp:getChildByTag(2)
                if sp2 then
                    sp2:removeFromParentAndCleanup(true)
                end
            end
            
            local htb = {0, 0, 0, 0, 0, 0}
            local aitb = {0, 0, 0, 0, 0, 0}
            local isSetHeroTroops = false
            if isFirst == 0 then
                if type == 1 then
                    htb = heroVoApi:getDefHeroList()
                    aitb = AITroopsFleetVoApi:getDefAITroopsList()
                    isSetHeroTroops = true
                elseif type == 5 then
                    htb = heroVoApi:getArenaHeroList()
                    aitb = AITroopsFleetVoApi:getArenaAITroopsList()
                    isSetHeroTroops = true
                elseif type == 4 then
                    htb = heroVoApi:getAllianceHeroList()
                    aitb = AITroopsFleetVoApi:getAllianceAITroopsList()
                    isSetHeroTroops = true
                elseif type == 7 or type == 8 or type == 9 then
                    htb = heroVoApi:getServerWarHeroList(type - 6)
                    aitb = AITroopsFleetVoApi:getServerWarAITroopsList(type - 6)
                    isSetHeroTroops = true
                elseif type == 10 then
                    htb = heroVoApi:getServerWarTeamHeroList()
                    aitb = AITroopsFleetVoApi:getServerWarTeamAITroopsList()
                    isSetHeroTroops = true
                elseif type == 12 then
                    htb = heroVoApi:getBossHeroList()
                    aitb = AITroopsFleetVoApi:getBossAITroopsList()
                    isSetHeroTroops = true
                elseif type == 13 or type == 14 or type == 15 then
                    htb = heroVoApi:getWorldWarHeroList(type - 12)
                    aitb = AITroopsFleetVoApi:getWorldWarAITroopsList(type - 12)
                    isSetHeroTroops = true
                elseif type == 17 then
                    htb = heroVoApi:getLocalWarHeroList()
                    aitb = AITroopsFleetVoApi:getLocalWarAITroopsList()
                    isSetHeroTroops = true
                elseif type == 18 then
                    htb = heroVoApi:getLocalWarCurHeroList()
                    aitb = AITroopsFleetVoApi:getLocalWarCurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 19 then
                    htb = heroVoApi:getSWAttackHeroList()
                    isSetHeroTroops = true
                elseif type == 20 then
                    htb = heroVoApi:getSWDefenceHeroList()
                    aitb = AITroopsFleetVoApi:getSWDefenceAITroopsList()
                    isSetHeroTroops = true
                elseif type == 21 or type == 22 or type == 23 then
                    htb = heroVoApi:getPlatWarHeroList(type - 20)
                    aitb = AITroopsFleetVoApi:getPlatWarAITroopsList(type - 20)
                    isSetHeroTroops = true
                elseif type == 24 or type == 25 or type == 26 then
                    htb = heroVoApi:getServerWarLocalHeroList(type - 23)
                    aitb = AITroopsFleetVoApi:getServerWarLocalAITroopsList(type - 23)
                    isSetHeroTroops = true
                elseif type == 27 or type == 28 or type == 29 then
                    htb = heroVoApi:getServerWarLocalCurHeroList(type - 26)
                    aitb = AITroopsFleetVoApi:getServerWarLocalCurAITroopsList(type - 26)
                    isSetHeroTroops = true
                elseif type == 30 then
                    htb = heroVoApi:getNewYearBossHeroList()
                    aitb = AITroopsFleetVoApi:getNewYearBossAITroopsList()
                    isSetHeroTroops = true
                elseif type == 31 then
                    htb = heroVoApi:getAllianceWar2CurHeroList()
                    aitb = AITroopsFleetVoApi:getAllianceWar2CurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 32 then
                    htb = heroVoApi:getAllianceWar2HeroList()
                    aitb = AITroopsFleetVoApi:getAllianceWar2AITroopsList()
                    isSetHeroTroops = true
                elseif type == 33 then
                    htb = heroVoApi:getDimensionalWarHeroList()
                    aitb = AITroopsFleetVoApi:getDimensionalWarAITroopsList()
                    isSetHeroTroops = true
                elseif type == 34 then
                    htb = heroVoApi:getServerWarTeamCurHeroList()
                    aitb = AITroopsFleetVoApi:getServerWarTeamCurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 35 or type == 36 then -- 领土争夺战
                    htb = ltzdzFightApi:getHeroTbByType(type)
                    aitb = ltzdzFightApi:getAITroopsTbByType(type)
                    isSetHeroTroops = true
                elseif type == 39 then --军团锦标赛军团战参战部队
                    htb = heroVoApi:getChampionshipWarHeroTb()
                    aitb = AITroopsFleetVoApi:getChampionshipWarAITroopsTb()
                    isSetHeroTroops = true
                end
                if isSetHeroTroops == true then
                    heroVoApi:setTroopsByTb(htb)
                    AITroopsFleetVoApi:setAITroopsTb(aitb)
                end
            elseif isFirst == 2 then
                if heroTb then
                    htb = heroTb
                    isSetHeroTroops = true
                elseif type == 7 or type == 8 or type == 9 then
                    htb = heroVoApi:getServerWarHeroList(type - 6)
                    aitb = AITroopsFleetVoApi:getServerWarAITroopsList(type - 6)
                    isSetHeroTroops = true
                elseif type == 13 or type == 14 or type == 15 then
                    htb = heroVoApi:getWorldWarHeroList(type - 12)
                    aitb = AITroopsFleetVoApi:getWorldWarAITroopsList(type - 12)
                    isSetHeroTroops = true
                elseif type == 17 then
                    htb = heroVoApi:getLocalWarHeroList()
                    aitb = AITroopsFleetVoApi:getLocalWarAITroopsList()
                    isSetHeroTroops = true
                elseif type == 18 then
                    htb = heroVoApi:getLocalWarCurHeroList()
                    aitb = AITroopsFleetVoApi:getLocalWarCurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 21 or type == 22 or type == 23 then
                    htb = heroVoApi:getPlatWarHeroList(type - 20)
                    aitb = AITroopsFleetVoApi:getPlatWarAITroopsList(type - 20)
                    isSetHeroTroops = true
                elseif type == 24 or type == 25 or type == 26 then
                    htb = heroVoApi:getServerWarLocalHeroList(type - 23)
                    aitb = AITroopsFleetVoApi:getServerWarLocalAITroopsList(type - 23)
                    isSetHeroTroops = true
                elseif type == 27 or type == 28 or type == 29 then
                    htb = heroVoApi:getServerWarLocalCurHeroList(type - 26)
                    aitb = AITroopsFleetVoApi:getServerWarLocalCurAITroopsList(type - 26)
                    isSetHeroTroops = true
                elseif type == 31 then
                    htb = heroVoApi:getAllianceWar2CurHeroList()
                    aitb = AITroopsFleetVoApi:getAllianceWar2CurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 32 then
                    htb = heroVoApi:getAllianceWar2HeroList()
                    aitb = AITroopsFleetVoApi:getAllianceWar2AITroopsList()
                    isSetHeroTroops = true
                elseif type == 34 then
                    htb = heroVoApi:getServerWarTeamCurHeroList()
                    aitb = AITroopsFleetVoApi:getServerWarTeamCurAITroopsList()
                    isSetHeroTroops = true
                elseif type == 35 or type == 36 then -- 领土争夺战
                    htb = ltzdzFightApi:getHeroTbByType(type)
                    aitb = ltzdzFightApi:getAITroopsTbByType(type)
                    isSetHeroTroops = true
                elseif type == 39 then --军团锦标赛军团战参战部队
                    htb = heroVoApi:getChampionshipWarHeroTb()
                    aitb = AITroopsFleetVoApi:getChampionshipWarAITroopsTb()
                    isSetHeroTroops = true
                end
                if isSetHeroTroops == true then
                    heroVoApi:setTroopsByTb(htb)
                    if base.AITroopsSwitch == 1 and aitroops == nil then
                        AITroopsFleetVoApi:setAITroopsTb(aitb)
                    end
                end
                if aitroops then --如果是传进来的AI部队的话就用传进来的
                    if base.AITroopsSwitch == 1 then
                        AITroopsFleetVoApi:setAITroopsTb(aitroops)
                    end
                end
            end
            
            -- 获取将领数据
            local hVo
            -- local hid--,productOrder,level=nil,1,1
            if heroVoApi:isHaveTroops() then
                -- G_dayin(heroVoApi:isHaveTroops())
                if heroVoApi:getTroopsHeroList()[tag] ~= nil and heroVoApi:getTroopsHeroList()[tag] ~= 0 then
                    local hid = heroVoApi:getTroopsHeroList()[tag]
                    if hid and hid ~= 0 then
                        local hidArr = Split(hid, "-")
                        -- if hidArr and hidArr[1] and hidArr[2] and hidArr[3] then
                        --     hid,productOrder,level=hidArr[1],tonumber(hidArr[2]) or 1,tonumber(hidArr[3]) or 1
                        -- else
                        if hidArr and hidArr[1] then
                            hid = hidArr[1]
                            
                            if self.type == 35 or self.type == 36 then
                                hVo = ltzdzFightApi:getHeroByHid(hid)
                            else
                                hVo = heroVoApi:getHeroByHid(hid)
                            end
                            if hVo then
                                productOrder = hVo.productOrder
                                heroVoApi:setTroopsByPos(tag, hid, type)
                            end
                        end
                    end
                end
            end
            local atid
            if AITroopsFleetVoApi:isHaveAITroops() then
                local aitb = AITroopsFleetVoApi:getAITroopsTb()
                atid = aitb[tag]
                if atid and atid ~= 0 and atid ~= "" then
                    AITroopsFleetVoApi:setAITroopsByPos(tag, atid, type)
                end
            end
            
            --显示舰队
            if isShowTank == 1 then
                -- 显示舰队空时的底图
                self.nullTankTb[tag]:setVisible(true)
                self.nullHeroTb[tag]:setVisible(false)
                self.nullAITroopsTb[tag]:setVisible(false)
                --底部将领信息
                local headNameBg = layer:getChildByTag(65760 + tag)
                local headNameLb = tolua.cast(headNameBg:getChildByTag(12), "CCLabelTTF")
                -- local bgSp1 = layer:getChildByTag(1980+tag)
                -- local headNameLb = tolua.cast(bgSp1:getChildByTag(12),"CCLabelTTF")
                if hVo then
                    local heroName = ""
                    if heroListCfg[hVo.hid] then
                        heroName = getlocal(heroListCfg[hVo.hid].heroName)
                    end
                    
                    local level = hVo.level or 1
                    local productOrder = hVo.productOrder or 1
                    if heroName and heroName ~= "" then
                        local heroStr = "Lv."..level.." "..heroName
                        heroStr = G_getPointStr(heroStr, bgSp:getContentSize().width, 18)
                        headNameLb:setString(heroStr)
                    end
                    local star = productOrder
                    for i = 1, star do
                        local starSize = 13
                        local starSpace = starSize
                        local starSp = tolua.cast(headNameBg:getChildByTag(200 + i), "CCSprite")
                        -- local starSp=tolua.cast(bgSp1:getChildByTag(200+i),"CCSprite")
                        if starSp then
                            local px = headNameBg:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                            local py = headNameBg:getContentSize().height - 5
                            -- local px=bgSp1:getContentSize().width/2-starSpace/2*(star-1)+starSpace*(i-1)
                            -- local py=bgSp1:getContentSize().height-8
                            starSp:setPosition(ccp(px, py))
                            starSp:setVisible(true)
                        end
                    end
                else
                    headNameLb:setString(getlocal("fight_content_null"))
                    local starSp
                    for i = 1, 5 do
                        starSp = tolua.cast(headNameBg:getChildByTag(200 + i), "CCSprite")
                        if starSp then
                            starSp:setVisible(false)
                        end
                    end
                end
                
                -- 舰队图像
                if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then
                    if tanksTb[tag] ~= nil and SizeOfTable(tanksTb[tag]) > 0 then
                        local id = tanksTb[tag][1]
                        local num = tanksTb[tag][2]
                        if id ~= 0 then
                            self:addTouchSp(type, bgSp, id, num, layerNum, layer, isShowTank, tag)
                            bgSp:setOpacity(255)
                        end
                    end
                end
            else
                --底部将领信息
                local headNameBg = layer:getChildByTag(65760 + tag)
                local headNameLb = tolua.cast(headNameBg:getChildByTag(12), "CCLabelTTF")
                -- local bgSp1 = layer:getChildByTag(1980+tag)
                -- local headNameLb = tolua.cast(bgSp1:getChildByTag(12),"CCLabelTTF")
                if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then
                    -- print("tanksTb[tag]",tanksTb[tag][1],tanksTb[tag][2])
                    if tanksTb[tag] ~= nil and SizeOfTable(tanksTb[tag]) > 0 then
                        local id = tanksTb[tag][1]
                        local num = tanksTb[tag][2]
                        local tId = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                        local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tId].name), num})
                        tankStr = G_getPointStr(tankStr, bgSp:getContentSize().width, 20)
                        headNameLb:setString(tankStr)
                    else
                        headNameLb:setString(getlocal("fight_content_null"))
                    end
                else
                    headNameLb:setString(getlocal("fight_content_null"))
                end
                --隐藏星星
                local starSp
                for i = 1, 5 do
                    starSp = tolua.cast(headNameBg:getChildByTag(200 + i), "CCSprite")
                    -- starSp=tolua.cast(bgSp1:getChildByTag(200+i),"CCSprite")
                    if starSp then
                        starSp:setVisible(false)
                    end
                end
                if isShowTank == 2 then --显示将领
                    -- 显示将领空时的底图
                    self.nullTankTb[tag]:setVisible(false)
                    self.nullHeroTb[tag]:setVisible(true)
                    self.nullAITroopsTb[tag]:setVisible(false)
                    
                    if hVo then
                        bgSp:setOpacity(255)
                        self:addHeroTouchSp(type, bgSp, hVo.hid, hVo.productOrder, layerNum, layer, isShowTank)
                    end
                else --AI部队显示
                    --显示AI部队空时的底图
                    self.nullTankTb[tag]:setVisible(false)
                    self.nullHeroTb[tag]:setVisible(false)
                    self.nullAITroopsTb[tag]:setVisible(true)
                    --显示AI部队配置情况
                    if atid and (atid ~= 0 and tostring(atid) ~= "") then
                        bgSp:setOpacity(255)
                        self:addAITroopsTouchSp(type, bgSp, atid, layerNum, layer, isShowTank)
                    end
                end
            end
        end
    end
end

function editTroopsLayer:touchSoldier(tag, isShowTank)
    if isShowTank ~= 1 then
        do return end
    end
    PlayEffect(audioCfg.mouseClick)
    if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
        do return end
    end
    if self.type == 4 and allianceWarVoApi:getSelfOid() > 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
        do return end
    end
    
    local parent = self.iconTab[tag]
    parent:setOpacity(0)
    
    tankVoApi:deleteTanksTbByType(self.type, tag)
    local spA = parent:getChildByTag(2)
    spA:removeFromParentAndCleanup(true)
    if self.type == 38 then
        local nullTankSp = self.nullTankTb[tag]
        if nullTankSp then
            local addBtnSp = tolua.cast(nullTankSp:getChildByTag(101), "CCSprite")
            if addBtnSp then
                addBtnSp:setVisible(true)
                addBtnSp:setPosition(self.myTankPosX, self.myTankPosY)
            end
        end
    end
    
    if self.type == 2 or type == 16 then
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
        local temLayer = tolua.cast(self.parentLayer, "CCLayer")
        local fleetLb = temLayer:getChildByTag(19)
        fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
        fleetLb:setString(getlocal("fleetload", {fleetload}))
    end
    
    if self.type == 35 or self.type == 36 then
        eventDispatcher:dispatchEvent("troops.change", {})
    end
    
    self:resetSkillIcon()
end

function editTroopsLayer:addTouchSp(type, parent, id, num, layerNum, layer, isShowTank, posIdx)
    
    local addLayer = CCLayer:create()
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    -- 显示背景
    parent:setOpacity(255)
    
    --士兵图像
    local touchSp = tankVoApi:getTankIconSpByBattleType(type, id)
    local spScale = 0.6
    if type == 38 then
        parent:setOpacity(0)
        spScale = self.tankIconWidth / touchSp:getContentSize().width
        touchSp:setPosition(self.myTankPosX, self.myTankPosY)
        local nullTankSp = self.nullTankTb[posIdx]
        if nullTankSp then
            local addBtnSp = tolua.cast(nullTankSp:getChildByTag(101), "CCSprite")
            if addBtnSp then --隐藏加号
                addBtnSp:setVisible(false)
                addBtnSp:setPosition(-99999, 0)
            end
        end
    else
        touchSp:setPosition(ccp(10 + touchSp:getContentSize().width * spScale / 2, parent:getContentSize().height / 2 - 15))
    end
    touchSp:setScale(spScale)
    touchSp:setTag(9000 + self.isShowTank)
    addLayer:addChild(touchSp, 3)
    
    if id ~= G_pickedList(id) then
        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        touchSp:addChild(pickedIcon)
        pickedIcon:setPosition(touchSp:getContentSize().width - 30, 30)
        pickedIcon:setScale(1.5)
    end
    
    if isShowTank and isShowTank ~= 1 then
    end
    -- local cnOrDeXheightPos = nil
    -- local cnOrDeTheightPos = nil
    -- local cnOrDeXWidPos = nil
    -- local cnOrDeTNumheiPos = nil
    -- if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then
    --     cnOrDeXheightPos=25
    --     cnOrDeXWidPos=25
    --     cnOrDeTheightPos=55
    --     cnOrDeTNumheiPos=40
    -- else
    --     cnOrDeXheightPos=40
    --     cnOrDeXWidPos=40
    --     cnOrDeTheightPos=50
    --     cnOrDeTNumheiPos=30
    -- end
    -- 没设置部队时预设部队显示空图片，则需要在这里添加部队的类型
    if type == 38 then --军团锦标赛不显示部队名称和数量，所以不处理
    else
        if type ~= 18 and type ~= 27 and type ~= 28 and type ~= 29 and type ~= 31 and type ~= 34 and self.notTouch ~= true then
            local spDelect = CCSprite:createWithSpriteFrameName("IconFault.png")
            spDelect:setAnchorPoint(ccp(1, 0))
            spDelect:setScale(0.7)
            spDelect:setPosition(ccp(parent:getContentSize().width - 8, 10))
            addLayer:addChild(spDelect, 5)
        end
        
        local soldiersFontSize = 18
        if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" then
            soldiersFontSize = 20
            
        end
        
        local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name), soldiersFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        soldiersLbName:setAnchorPoint(ccp(0, 1))
        soldiersLbName:setPosition(ccp(touchSp:getPositionX() + touchSp:getContentSize().width * spScale / 2 + 3, touchSp:getPositionY() + touchSp:getContentSize().height * spScale / 2))
        addLayer:addChild(soldiersLbName, 2)
        
        local soldiersLbNum = GetTTFLabel(num, soldiersFontSize)
        soldiersLbNum:setAnchorPoint(ccp(0, 0.5))
        soldiersLbNum:setPosition(ccp(touchSp:getPositionX() + touchSp:getContentSize().width * spScale / 2 + 3, touchSp:getPositionY() - touchSp:getContentSize().height * spScale / 2 + 10))
        addLayer:addChild(soldiersLbNum, 2)
        
        if type == 2 or type == 16 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
    end
    self:resetSkillIcon()
end

function editTroopsLayer:touchHeroDelete(tag)
    if self.isShowTank ~= 2 then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    local type = self.type
    local parent = self.iconTab[tag]
    parent:setOpacity(0)
    if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
        do return end
    end
    if type == 4 and allianceWarVoApi:getSelfOid() > 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
        
        do
            return
        end
    end
    heroVoApi:deletTroopsByPos(parent:getTag(), type)
    local spA = parent:getChildByTag(2)
    spA:removeFromParentAndCleanup(true)
    
    if type == 2 or type == 16 then
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
        local temLayer = tolua.cast(layer, "CCLayer")
        if temLayer then
            local fleetLb = temLayer:getChildByTag(19)
            if fleetLb then
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
        end
    end
    
end
function editTroopsLayer:addHeroTouchSp(type, parent, hid, productOrder, layerNum, layer, isShowTank, isGary)
    local addLayer = CCLayer:create();
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    -- 显示背景
    parent:setOpacity(255)
    
    local adjutants --将领副官
    if type == 35 or type == 36 then
        local heroVo, ajt = ltzdzFightApi:getHeroByHid(hid)
        adjutants = ajt
    end
    local spScale = 0.5
    local spAdd = heroVoApi:getHeroIcon(hid, productOrder, isGary, nil, nil, nil, nil, {adjutants = adjutants})
    spAdd:setScale(spScale)
    spAdd:setTag(9000 + self.isShowTank)
    spAdd:setPosition(ccp(20 + spAdd:getContentSize().width * spScale / 2, parent:getContentSize().height / 2 - 10))
    addLayer:addChild(spAdd)
    
    if isShowTank and isShowTank ~= 2 then
        -- touchSp:setTouchPriority(-(layerNum-1)*20-3)
        -- spAdd:setTouchPriority(-(layerNum-1)*20-3)
    end
    
    if type ~= 18 and type ~= 27 and type ~= 28 and type ~= 29 and type ~= 31 and type ~= 34 and self.notTouch ~= true then
        local spDelect = CCSprite:createWithSpriteFrameName("IconFault.png")
        spDelect:setAnchorPoint(ccp(1, 0))
        spDelect:setScale(0.7)
        spDelect:setPosition(ccp(parent:getContentSize().width - 8, 8))
        addLayer:addChild(spDelect, 5)
    end
    
    local heroFontSize = 18
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" then
        heroFontSize = 20
        
    end
    local heroNameLb = GetTTFLabelWrap(heroVoApi:getHeroName(hid), heroFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    heroNameLb:setAnchorPoint(ccp(0, 0.5))
    heroNameLb:setPosition(ccp(spAdd:getPositionX() + spAdd:getContentSize().width * spScale / 2 + 8, spAdd:getPositionY() + spAdd:getContentSize().height * spScale / 2 - 13))
    addLayer:addChild(heroNameLb, 2)
    
    local heroLv
    if self.type == 35 or self.type == 36 then
        heroLv = ltzdzFightApi:getHeroByHid(hid).level or 1
    else
        heroLv = heroVoApi:getHeroByHid(hid).level or 1
    end
    local heroLvLb = GetTTFLabel("LV."..heroLv, heroFontSize)
    heroLvLb:setAnchorPoint(ccp(0, 0.5))
    heroLvLb:setPosition(ccp(spAdd:getPositionX() + spAdd:getContentSize().width * spScale / 2 + 10, spAdd:getPositionY() - spAdd:getContentSize().height * spScale / 2 + 10))
    addLayer:addChild(heroLvLb, 2)
    
end

--显示AI部队的布置详情
function editTroopsLayer:addAITroopsTouchSp(type, parent, atid, layerNum, layer, isShowTank)
    local troopsVo = AITroopsVoApi:getTroopsById(atid)
    if troopsVo == nil then
        do return end
    end
    local addLayer = CCLayer:create()
    parent:addChild(addLayer)
    addLayer:setTag(2)
    -- 显示背景
    parent:setOpacity(255)
    --AI部队icon显示
    local iconSize = 90
    local spAdd = AITroopsVoApi:getAITroopsSimpleIcon(troopsVo.id, troopsVo.lv, troopsVo.grade)
    spAdd:setScale(iconSize / spAdd:getContentSize().width)
    spAdd:setTag(9000 + self.isShowTank)
    spAdd:setPosition(ccp(10 + iconSize / 2, parent:getContentSize().height / 2 - 15))
    addLayer:addChild(spAdd)
    
    if type ~= 18 and type ~= 27 and type ~= 28 and type ~= 29 and type ~= 31 and type ~= 34 and self.notTouch ~= true then
        local spDelect = CCSprite:createWithSpriteFrameName("IconFault.png")
        spDelect:setAnchorPoint(ccp(1, 0))
        spDelect:setScale(0.7)
        spDelect:setPosition(ccp(parent:getContentSize().width - 8, 8))
        addLayer:addChild(spDelect, 5)
    end
    
    local nameFontSize = 18
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" then
        nameFontSize = 20
    end
    --AI部队名称显示
    local nameStr, color = AITroopsVoApi:getAITroopsNameStr(troopsVo.id)
    local troopsNameLb = GetTTFLabelWrap(nameStr, nameFontSize, CCSizeMake(130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    troopsNameLb:setAnchorPoint(ccp(0, 0.5))
    troopsNameLb:setColor(color)
    troopsNameLb:setPosition(ccp(spAdd:getPositionX() + iconSize / 2 + 8, spAdd:getPositionY() + iconSize / 2 - 13))
    addLayer:addChild(troopsNameLb, 2)
    
    --AI部队强度显示
    local strength = troopsVo:getTroopsStrength()
    local strengthLb = GetTTFLabel(strength, nameFontSize)
    strengthLb:setAnchorPoint(ccp(0, 0.5))
    strengthLb:setPosition(ccp(spAdd:getPositionX() + iconSize / 2 + 10, spAdd:getPositionY() - iconSize / 2 + 10))
    addLayer:addChild(strengthLb, 2)
end

--点击AI部队卸载的处理
function editTroopsLayer:touchAITroopsDelete(tag)
    if self.isShowTank ~= 3 then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    local type = self.type
    local parent = self.iconTab[tag]
    parent:setOpacity(0)
    if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
        do return end
    end
    if type == 4 and allianceWarVoApi:getSelfOid() > 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
        do
            return
        end
    end
    
    AITroopsFleetVoApi:deleteAITroopsByPos(parent:getTag(), type)
    
    local spA = parent:getChildByTag(2)
    spA:removeFromParentAndCleanup(true)
    
    if type == 2 or type == 16 then
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
        local temLayer = tolua.cast(layer, "CCLayer")
        if temLayer then
            local fleetLb = temLayer:getChildByTag(19)
            if fleetLb then
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
        end
    end
end

function editTroopsLayer:isHasIconWithPos(x, y, isMoveEnd)
    local tIcon = nil
    local idx = 0
    
    if isMoveEnd == true then
        for i = 1, 6 do
            
            local tempIcon = self.iconTab[i]
            
            local tPos = self.posTab[i]
            local tRect = CCRect(tPos.x - 100, tPos.y - tempIcon:getContentSize().height / 2, 200, tempIcon:getContentSize().height)
            
            if tRect:containsPoint(ccp(x, y)) == true then
                
                local isTouchedSoldier = false
                if tempIcon:getChildByTag(2) then
                    isTouchedSoldier = true
                end
                
                if self.type == 38 and championshipWarVoApi:isHasTankByPosIdx(i) == false then
                    return nil, nil
                end
                return tempIcon, i, isTouchedSoldier
                
            end
        end
    else
        for i = 1, 6 do
            
            local tempIcon = self.iconTab[i]
            
            local tPos = self.posTab[i]
            local tRect = CCRect(tPos.x - tempIcon:getContentSize().width / 2, tPos.y - tempIcon:getContentSize().height / 2, tempIcon:getContentSize().width, tempIcon:getContentSize().height)
            
            -- print("touch pos",tPos.x,tPos.y,tPos.x-tempIcon:getContentSize().width/2,tPos.y-tempIcon:getContentSize().height/2,tempIcon:getContentSize().width,tempIcon:getContentSize().height)
            
            if tRect:containsPoint(ccp(x, y)) == true then
                
                local isTouchedSoldier = false
                if tempIcon:getChildByTag(2) then
                    isTouchedSoldier = true
                end
                if self.type == 38 and championshipWarVoApi:isHasTankByPosIdx(i) == false then
                    return nil, nil
                end
                return tempIcon, i, isTouchedSoldier
            end
        end
    end
    
    return tIcon, idx
end

function editTroopsLayer:beginSwitch()
    if self.isMoved == false and self.movedType == 1 then
        if self.touchedIcon ~= nil then
            print("beginSwitch")
            self.movedType = 2
            self.touchedIcon:setScale(1.15)
            self.parentLayer:reorderChild(self.touchedIcon, 8)
        end
    end
end

function editTroopsLayer:touchEvent(fn, x, y, touch)
    print("touchEvent", fn, x, y, touch)
    if fn == "began" then
        if self.touchEnable == false or SizeOfTable(self.touchArr) >= 1 or self.touchRect:containsPoint(ccp(x, y)) == false then
            return 0
        end
        
        if self.parentLayer:isVisible() == false then
            return 0
        end
        
        local tIcon, tId, isTouchedSoldier = self:isHasIconWithPos(x, y)
        print("touch event", self.type, tId, isTouchedSoldier)
        if tIcon == nil or tId == 0 then
            return 0
        end
        
        self.touchedIcon = tIcon
        self.touchedId = tId
        
        if isTouchedSoldier == true then
            local function startMove()
                self:beginSwitch()
            end
            local callFuncS = CCCallFunc:create(startMove)
            local delayAction = CCDelayTime:create(1.0)
            local seq = CCSequence:createWithTwoActions(delayAction, callFuncS)
            self.touchedIcon:runAction(seq)
            self.movedType = 1
            
        else
            self.movedType = 3
            
        end
        
        self.isMoved = false
        self.touchArr[touch] = touch
        local touchIndex = 0
        for k, v in pairs(self.touchArr) do
            local temTouch = tolua.cast(v, "CCTouch")
            if self and temTouch then
                if touchIndex == 0 then
                    self.firstOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                    self.secondOldPos = CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
            end
            touchIndex = touchIndex + 1
        end
        if touchIndex == 1 then
            self.secondOldPos = nil
            self.lastTouchDownPoint = self.firstOldPos
        end
        if SizeOfTable(self.touchArr) > 1 then
            self.multTouch = true
        else
            self.multTouch = false
        end
        return 1
    elseif fn == "moved" then
        if self.touchEnable == false then
            do
                return
            end
        end
        
        if self.movedType == 3 then
            do
                return
            end
        end
        
        self.isMoved = true
        if self.multTouch == true then --双点触摸
            
        else --单点触摸
            
            local curPos = CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local moveDisPos = ccpSub(curPos, self.firstOldPos)
            -- 部分安卓设备可能存在灵敏度问题
            local moveDisTmp = ccpSub(curPos, self.lastTouchDownPoint)
            if G_isIOS() == false then
                if (math.abs(moveDisTmp.y) + math.abs(moveDisTmp.x)) < 13 then
                    self.isMoved = false
                    do return end
                end
            else
                if (math.abs(moveDisTmp.y) + math.abs(moveDisTmp.x)) < 30 then
                    self.isMoved = false
                    do return end
                end
            end
            if self.movedType == 1 then
                self.touchedIcon:stopAllActions()
                self.movedType = 2
                self.touchedIcon:setScale(1.2)
                self.parentLayer:reorderChild(self.touchedIcon, 8)
            end
            
            if self.movedType == 2 then
                self.autoMoveAddPos = ccp((curPos.x - self.firstOldPos.x) * 3, (curPos.y - self.firstOldPos.y) * 3)
                local tmpPos = ccpAdd(ccp(self.touchedIcon:getPosition()), ccp(moveDisPos.x, moveDisPos.y))
                self.touchedIcon:setPosition(tmpPos)
                self.firstOldPos = curPos
                self.isMoving = true
                
                -- 移动到的
                local tIcon, tId, isTouchedSoldier = self:isHasIconWithPos(self.touchedIcon:getPositionX(), self.touchedIcon:getPositionY(), true)
                if tId ~= self.movedId and self.movedIcon then
                    
                    local tempSp = nil
                    if self.movedIcon and self.movedIcon:getChildByTag(2) then
                        tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12), "CCSprite")
                    end
                    if tempSp then
                        tempSp:setOpacity(255)
                    end
                    self.movedIcon = nil
                    self.movedId = 0
                    
                end
                
                if tIcon ~= nil and tId ~= 0 and isTouchedSoldier and tId ~= self.movedId and tId ~= self.touchedId then
                    self.movedIcon = tIcon
                    local tempSp = nil
                    if tIcon:getChildByTag(2) then
                        tempSp = tolua.cast(tIcon:getChildByTag(2):getChildByTag(12), "CCSprite")
                    end
                    if tempSp then
                        tempSp:setOpacity(100)
                    end
                    self.movedId = tId
                end
            end
        end
    elseif fn == "ended" then
        if self.touchEnable == false then
            do
                return
            end
        end
        if self.touchArr[touch] ~= nil then
            self.touchArr[touch] = nil
            local touchIndex = 0
            for k, v in pairs(self.touchArr) do
                if touchIndex == 0 then
                    self.firstOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                    self.secondOldPos = CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex = touchIndex + 1
            end
            if touchIndex == 1 then
                self.secondOldPos = nil
            end
            if SizeOfTable(self.touchArr) > 1 then
                self.multTouch = true
            else
                self.multTouch = false
            end
        end
        if self.isMoving == true then
            self.isMoving = false
            
            local tmpToPos = ccp(self.touchedIcon:getPosition())
            
            local positionY = G_VisibleSizeHeight / 2 - 10 - 32 + 5
            
            local positionX = 120 + (self.touchedId - 1) * 200
            
            local XL = 0
            
            --优化拖动
            if (x - positionX > 30 and x - positionX < 100) then
                XL = 100
            end
            if (x - positionX > -100 and x - positionX < -30) then
                XL = -100
            end
            
            -- local tIcon,tId = self:isHasIconWithPos(x+XL,y,true)
            local tIcon, tId = self:isHasIconWithPos(self.touchedIcon:getPositionX(), self.touchedIcon:getPositionY(), true)
            
            local iconPos = nil
            
            if tIcon ~= nil and tId ~= 0 and tId ~= self.touchedId then
                
                tIcon:setPosition(self.posTab[self.touchedId])
                self:shakeIt(tIcon)
                self.iconTab[self.touchedId] = tIcon
                self.iconTab[tId] = self.touchedIcon
                
                tIcon:setTag(self.touchedId)
                self.touchedIcon:setTag(tId)
                
                iconPos = self.posTab[tId]
                
                if self.isShowTank == 1 then
                    tankVoApi:exchangeTanksByType(self.type, self.touchedId, tId)
                elseif self.isShowTank == 2 then
                    heroVoApi:exchangeHerosByType(self.type, self.touchedId, tId)
                else
                    AITroopsFleetVoApi:exchangeAITroopsByType(self.type, self.touchedId, tId)
                end
                
                self:checkButtomName(self.touchedId)
                self:checkButtomName(tId)
            end
            
            if iconPos then
                self.touchedIcon:setPosition(iconPos)
                self:shakeIt(self.touchedIcon)
            else
                self.touchedIcon:setPosition(self.posTab[self.touchedId])
            end
            
            local function endMove()
                -- self.touchedIcon:setScale(self.touchedScaleX)
                -- self.touchedIcon:setScale(self.touchedScaleY)
                -- self.touchedIcon:setOpacity(0)
                self.touchedIcon:setScale(1)
                self.parentLayer:reorderChild(self.touchedIcon, 5)
                
                self.touchedIcon = nil
                self.touchedId = 0
                self.movedType = 0
                
                if self.movedIcon and self.movedIcon:getChildByTag(2) and self.movedIcon:getChildByTag(2):getChildByTag(12) then
                    local tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12), "CCSprite")
                    if tempSp then
                        tempSp:setOpacity(255)
                    end
                    
                    self.movedIcon = nil
                    self.movedId = 0
                end
                
            end
            endMove()
            
            self:resetQueueNum()
        else
            if self.touchedIcon ~= nil and self.touchedId ~= 0 and (self.movedType == 1 or self.movedType == 3)then
                self:touchConfig(self.touchedId)
            elseif self.touchedIcon ~= nil and self.touchedId ~= 0 and self.movedType == 2 then
                -- self.touchedIcon:setOpacity(0)
                self.touchedIcon:setScale(1)
                self.parentLayer:reorderChild(self.touchedIcon, 5)
            end
            self.touchedIcon:stopAllActions()
            self.movedType = 0
        end
    else
        
        if self.touchedIcon then
            self.touchedIcon:setPosition(self.posTab[self.touchedId])
            -- self.touchedIcon:setOpacity(0)
            self.touchedIcon:setScale(1)
            self.parentLayer:reorderChild(self.touchedIcon, 5)
        end
        
        self.touchedIcon = nil
        self.touchedId = 0
        self.movedType = 0
        
        if self.movedIcon then
            local tempSp = tolua.cast(self.movedIcon:getChildByTag(2):getChildByTag(12), "CCSprite")
            if tempSp then
                tempSp:setOpacity(255)
            end
            self.movedIcon = nil
            self.movedId = 0
        end
        self.touchArr = nil
        self.touchArr = {}
    end
end

function editTroopsLayer:touchConfig(tId)
    print("tId,self.isShowTank--->>", tId, self.isShowTank)
    if self.iconTab[tId]:getChildByTag(2) then
        if self.isShowTank == 1 then
            self:touchSoldier(tId, 1)
        elseif self.isShowTank == 2 then
            self:touchHeroDelete(tId)
        else
            self:touchAITroopsDelete(tId)
        end
    else
        self:touchBlank(tId, self.isShowTank)
    end
end

function editTroopsLayer:shakeIt(icon)
    
    local scaleToBig = CCScaleTo:create(0.1, 1.05)
    local scaleToNormal = CCScaleTo:create(0.1, 1)
    
    local acArr = CCArray:create()
    acArr:addObject(scaleToBig)
    acArr:addObject(scaleToNormal)
    -- acArr:addObject(scaleToBig)
    -- acArr:addObject(scaleToNormal)
    
    local seq = CCSequence:create(acArr)
    icon:stopAllActions()
    icon:runAction(seq)
    
end

function editTroopsLayer:resetQueueNum()
    for k, v in pairs(self.iconTab) do
        local addBtnSp
        if self.type == 38 then
            local tag = v:getTag()
            local nullTankSp = self.nullTankTb[tag]
            if nullTankSp then
                addBtnSp = tolua.cast(nullTankSp:getChildByTag(101), "CCSprite")
            end
        end
        if v:getChildByTag(2) ~= nil and v:getChildByTag(2):getChildByTag(9000 + self.isShowTank) then
            if self.type == 38 and self.isShowTank == 1 then
                v:setOpacity(0)
            else
                v:setOpacity(255)
            end
            if addBtnSp then
                addBtnSp:setVisible(false)
                addBtnSp:setPosition(-99999, 0)
            end
        else
            v:setOpacity(0)
            if addBtnSp and self.myTankPosX and self.myTankPosY then
                addBtnSp:setVisible(true)
                addBtnSp:setPosition(self.myTankPosX, self.myTankPosY)
            end
        end
    end
end

function editTroopsLayer:checkButtomName(tag)
    local hVo
    if heroVoApi:isHaveTroops() then
        if heroVoApi:getTroopsHeroList()[tag] ~= nil and heroVoApi:getTroopsHeroList()[tag] ~= 0 then
            local hid = heroVoApi:getTroopsHeroList()[tag]
            -- hVo=heroVoApi:getHeroByHid(hid)
            if self.type == 35 or self.type == 36 then
                hVo = ltzdzFightApi:getHeroByHid(hid)
            else
                hvo = heroVoApi:getHeroByHid(hid)
            end
        end
    end
    --显示士兵
    local bgSp = self.parentLayer:getChildByTag(tag)
    local headNameBg = self.parentLayer:getChildByTag(65760 + tag)
    local headNameLb = tolua.cast(headNameBg:getChildByTag(12), "CCLabelTTF")
    -- local sp1 = layer:getChildByTag(1980+tag)
    -- local headNameLb = tolua.cast(sp1:getChildByTag(12),"CCLabelTTF")
    if self.isShowTank == 1 then
        --底部将领信息
        if hVo then
            local heroName = ""
            if heroListCfg[hVo.hid] then
                heroName = getlocal(heroListCfg[hVo.hid].heroName)
            end
            
            local level = hVo.level or 1
            local productOrder = hVo.productOrder or 1
            if heroName and heroName ~= "" then
                local heroStr = "Lv."..level.." "..heroName
                heroStr = G_getPointStr(heroStr, bgSp:getContentSize().width, 18)
                headNameLb:setString(heroStr)
            end
        end
    else --显示将领
        --底部将领信息
        local tanksTb = tankVoApi:getTanksTbByType(self.type)
        if self.type == 4 then
            if allianceWarVoApi:getSelfOid() > 0 then
                tanksTb = tankVoApi:getTanksTbByType(6)
            end
        end
        if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then
            if tanksTb[tag] ~= nil and SizeOfTable(tanksTb[tag]) > 0 then
                local id = tanksTb[tag][1]
                local num = tanksTb[tag][2]
                local tId = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tId].name), num})
                tankStr = G_getPointStr(tankStr, bgSp:getContentSize().width, 20)
                headNameLb:setString(tankStr)
            end
        end
    end
end

function editTroopsLayer:updateSelect(type, layer, layerNum, isShowTank, tankTb, heroTb, emblemId, planePos, aitroops, airshipId)
    if tankSkinVoApi:checkBattleType(type) == true then
        tankSkinVoApi:clearTempTankSkinList(type) --清空皮肤缓存数据
        local tskin = G_clone(tankSkinVoApi:getTankSkinListByBattleType(type))
        tankSkinVoApi:setTempTankSkinList(type, tskin, tankTb) --同步皮肤缓存数据
    end
    self:changeHeroOrTank(type, isShowTank, layer, layerNum, 2, tankTb, heroTb, emblemId, planePos, aitroops)
    self:resetQueueNum()
    self:resetSkillIcon()
    -- if airShipVoApi:isCanEnter() == false or airshipId == "" then
    --     airshipId = nil
    -- end
    if airshipId == nil then
        airshipId = airShipVoApi:getBattleEquip(type)
    end
    self:refreshAirshipBtn(airshipId)
    if self.extTroopsLayer then
        self.extTroopsLayer:refreshUI()
    end
end

-- 军徽更换后，带兵量变化，重新按最大带兵量部署舰队
function editTroopsLayer:troopsChangedRefresh(type, layer, layerNum)
    -- 获取舰队
    local tankTb = tankVoApi:getTanksTbByType(type)
    -- 检查当前最大带兵量
    local maxTroopsNum
    if type == 35 or type == 36 then
        maxTroopsNum = ltzdzFightApi:getFightNum(type)
    else
        maxTroopsNum = playerVoApi:getTotalTroops(type)
    end
    for k, v in pairs(tankTb) do
        if v[1] and v[2] then
            if v[2] > maxTroopsNum then
                v[2] = maxTroopsNum
            end
        end
    end
    -- 重新设置舰队
    for k, v in pairs(tankTb) do
        if v[1] and v[2] then
            tankVoApi:setTanksByType(type, k, v[1], v[2])
        end
    end
    if self.type == 35 or self.type == 36 then
        eventDispatcher:dispatchEvent("troops.change", {})
    end
    self:changeHeroOrTank(type, self.isShowTank, layer, layerNum, 1)
end

-- 检测军徽是否增加带兵量，如果带，刷新
function editTroopsLayer:checkEquipTroopsNum(emblemId, refresh, isFirst)
    -- local totalTroopsNum = playerVoApi:getTotalTroops(self.type)
    local troopsAdd = 0
    local equipColor = 1
    if emblemId ~= nil then
        -- totalTroopsNum = playerVoApi:getTotalTroops(self.type)
        local emTroopVo
        if self.type == 35 or self.type == 36 then
            emTroopVo = ltzdzFightApi:getEmblemTroopById(emblemId)
        end
        troopsAdd, equipColor = emblemVoApi:getTroopsAddById(emblemId, emTroopVo)
    end
    
    -- -- print("TroopsNum",totalTroopsNum,troopsAdd,emblemId)
    -- -- 更新总带兵量
    -- local totalTroopsLb = tolua.cast(self.parentLayer:getChildByTag(11055),"CCLabelTTF")
    -- if totalTroopsLb then
    --     totalTroopsLb:setString(getlocal("player_leader_troop_num",{totalTroopsNum}))
    -- end
    
    -- -- 更新军徽加带兵
    -- local equipTroopsLb = tolua.cast(self.parentLayer:getChildByTag(11057),"CCLabelTTF")
    -- if equipTroopsLb then
    --     equipTroopsLb:setString("+"..troopsAdd)
    --     if troopsAdd<=0 then
    --         equipTroopsLb:setVisible(false)
    --     else
    --         equipTroopsLb:setVisible(true)
    --     end
    --     local colorTb = {G_ColorWhite,G_ColorEquipGreen,G_ColorEquipBlue,G_ColorEquipPurple,G_ColorEquipOrange}
    --     equipTroopsLb:setColor(colorTb[equipColor])
    -- end
    
    local fontSize = 22
    local posX, posY = 45, 0
    if G_isIphone5() == true then
        posY = self.tHeight - 10
    else
        posY = self.tHeight
    end
    if self.troopsNumLb then
        self.troopsNumLb:removeFromParentAndCleanup(true)
    end
    local colorTab = {nil, G_ColorGreen, nil}
    local troopsNumStr
    if self.type == 35 or self.type == 36 then
        troopsNumStr = getlocal("player_leader_troop_num", {ltzdzFightApi:getFightNum()}) .. "<rayimg>+" .. troopsAdd .. "<rayimg>"
    else
        troopsNumStr = getlocal("player_leader_troop_num", {playerVoApi:getTroopsLvNum()}) .. "<rayimg>+" .. (playerVoApi:getExtraTroopsNum(self.type, false) + troopsAdd) .. "<rayimg>"
    end
    
    local lbHeight = 0
    self.troopsNumLb, lbHeight = G_getRichTextLabel(troopsNumStr, colorTab, fontSize, G_VisibleSizeWidth / 2 - 60, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.troopsNumLb:setAnchorPoint(ccp(0, 1))
    self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2))
    self.parentLayer:addChild(self.troopsNumLb, 2)
    
    if self.type == 35 then
        self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2 + 60))
    elseif self.type == 36 then
        self.troopsNumLb:setPosition(ccp(posX, G_VisibleSizeHeight - 180))
    end
    
    -- 是否刷新部队
    if refresh == nil then
        self:troopsChangedRefresh(self.type, self.parentLayer, self.layerNum)
    end
    if isFirst and isFirst ~= 0 and isFirst ~= 2 then
        -- 带兵量变化，增加，则提示玩家
        if troopsAdd > self.emblemTroopsAdd then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_troops_add_prompt"), 30)
        end
    end
    self.emblemTroopsAdd = troopsAdd
end

-- 显示空军徽的按钮
function editTroopsLayer:showEmptyEquipBtn(parent)
    
    local equipMenu = tolua.cast(parent:getChildByTag(5645), "CCMenu")
    if equipMenu ~= nil then
        equipMenu:removeFromParentAndCleanup(true)
        equipMenu = nil
    end
    -- 清空军徽
    -- emblemVoApi:setBattleEquip(self.type,nil)
    emblemVoApi:setTmpEquip(nil, self.type)
    -- 刷新带兵量
    self:checkEquipTroopsNum()
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
    
    local function showEquipBtn()
        if base.emblemSwitch == 0 then
            do return end
        end
        if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
            do return end
        end
        local function showEquipDialog(emblemId)
            self:showSuperEquipBtn(parent, emblemId)
        end
        
        local canNotUseEmblemTb = {}
        local tb = emblemVoApi:getEquipCanNotUse(self.type)
        if self.type == 11 then
            canNotUseEmblemTb = G_clone(tb)
        else
            local troopList = nil
            if emblemTroopVoApi:checkIfEmblemTroopIsOpen() == true then
                troopList = G_clone(emblemTroopVoApi:getEmblemTroopList()) --当前玩家军徽部队列表
            end
            if tb and type(tb) == "table" and SizeOfTable(tb) > 0 then --将镜像中已经占用的军徽部队和军徽加入到占用列表中
                for k, v in pairs(tb) do
                    local equipIdTb = emblemVoApi:getEquipUsedByEquipId(v)
                    for k, equipId in pairs(equipIdTb) do
                        if equipId and equipId ~= "0" then
                            if canNotUseEmblemTb[equipId] then
                                canNotUseEmblemTb[equipId] = canNotUseEmblemTb[equipId] + 1
                            else
                                canNotUseEmblemTb[equipId] = 1
                            end
                        end
                    end
                    local isTroop, equipArr = emblemTroopVoApi:checkIfIsEmblemTroopById(v)
                    if troopList and isTroop == true and equipArr and SizeOfTable(equipArr) > 1 then
                        local troopId = equipArr[12]
                        troopList[troopId] = nil --在镜像中的军徽部队要剔除
                    end
                end
            end
            if self.type ~= 35 and self.type ~= 36 and troopList then --领土争夺战不能处理玩家身上的数据（因所有数据都是跨服带过去的数据）
                for k, v in pairs(troopList) do --处理除镜像以外的军徽
                    for kidx, posEquipId in pairs(v.posTb) do
                        if posEquipId and posEquipId ~= "0" then
                            canNotUseEmblemTb[posEquipId] = (canNotUseEmblemTb[posEquipId] or 0) + 1 --将除镜像以外的军徽部队装配的军徽也加入到占用列表中
                        end
                    end
                end
            end
            -- if tb and type(tb)=="table" and SizeOfTable(tb)>0 then
            --     for k,v in pairs(tb) do
            --         if v and v~=0 then
            --             if canNotUseEmblemTb[v] then
            --                 canNotUseEmblemTb[v]=canNotUseEmblemTb[v]+1
            --             else
            --                 canNotUseEmblemTb[v]=1
            --             end
            --         end
            --     end
            -- end
        end
        emblemVoApi:showSelectEmblemDialog(nil, 2, self.layerNum + 1, showEquipDialog, canNotUseEmblemTb, self.type, self.cid)
    end
    local equipItem = CCMenuItemSprite:create(equipSp1, equipSp2)
    equipItem:registerScriptTapHandler(showEquipBtn)
    equipItem:setAnchorPoint(ccp(0, 0))
    equipItem:setPosition(ccp(4, 6))
    
    equipMenu = CCMenu:createWithItem(equipItem)
    equipMenu:setTag(5645)
    equipMenu:setAnchorPoint(ccp(0, 0))
    -- equipMenu:setPosition(ccp(0,0))`
    local addH = 0
    if self.type == 24 or self.type == 27 then
        addH = 50
    end
    if G_isIphone5() == true then
        if self.type == 38 or self.type == 39 then
            equipMenu:setPosition(ccp(parent:getContentSize().width - 114, 160 + 25 + addH))
        else
            equipMenu:setPosition(ccp(parent:getContentSize().width - 102, 160 + 25 + addH))
        end
    else
        if self.type == 38 or self.type == 39 then
            equipMenu:setPosition(ccp(parent:getContentSize().width - 114, 160 + addH))
        else
            equipMenu:setPosition(ccp(parent:getContentSize().width - 102, 160 + addH))
        end
    end
    equipMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    parent:addChild(equipMenu, 1)
end

-- 显示带有军徽的按钮
function editTroopsLayer:showSuperEquipBtn(parent, emblemId, noCheck, isFirst)
    -- print("self.type,emblemId------>>>",self.type,emblemId)
    -- 移除原有的按钮
    local equipMenu = tolua.cast(parent:getChildByTag(5645), "CCMenu")
    if equipMenu ~= nil then
        equipMenu:removeFromParentAndCleanup(true)
        equipMenu = nil
    end
    -- 判断是否还有可用装备
    local equipCfg = emblemVoApi:getEquipCfgById(emblemId)
    if equipCfg == nil then
        do return end
    end
    -- 显示军徽
    -- emblemVoApi:setBattleEquip(self.type,emblemId)
    emblemVoApi:setTmpEquip(emblemId, self.type)
    -- 更改军徽之后，是否需要刷新带兵部队，只有最大战力的时候才会传true，不刷新
    self:checkEquipTroopsNum(emblemId, noCheck, isFirst)
    -- -- 如果有等级，那么取此装备的基础数据
    -- local iconAndNameId = emblemId
    -- if equipCfg and equipCfg.lv>0 then
    --     local start = string.find(iconAndNameId,"_")
    --     if start>1 then
    --         iconAndNameId = string.sub(iconAndNameId,1,start-1)
    --     end
    -- end
    local emTroopVo
    if self.type == 35 or self.type == 36 then --领土争夺战取一下军徽部队数据
        emTroopVo = ltzdzFightApi:getEmblemTroopById(emblemId)
    end
    -- 带有军徽的按钮1
    local equipSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp1 = emblemVoApi:getEquipIconNoBg(emblemId, 18, 145, nil, 0, emTroopVo)
    -- showEquipSp1:setScale(0.7)
    showEquipSp1:setScale((equipSp1:getContentSize().width - 10) / showEquipSp1:getContentSize().width)
    -- showEquipSp1:setPosition(ccp(equipSp1:getContentSize().width/2-15,equipSp1:getContentSize().height/2-9))
    showEquipSp1:setPosition(getCenterPoint(equipSp1))
    equipSp1:addChild(showEquipSp1)
    
    local equipSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showEquipSp2 = emblemVoApi:getEquipIconNoBg(emblemId, 18, 145, nil, 0, emTroopVo)
    -- showEquipSp2:setScale(0.7)
    showEquipSp2:setScale((equipSp2:getContentSize().width - 10) / showEquipSp2:getContentSize().width)
    -- showEquipSp2:setPosition(ccp(equipSp2:getContentSize().width/2-15,equipSp2:getContentSize().height/2-9))
    showEquipSp2:setPosition(getCenterPoint(equipSp2))
    equipSp2:addChild(showEquipSp2)
    equipSp2:setScale(0.97)
    -- 已选择军徽的时候，点击会移除掉军徽，显示空按钮
    local function showEmptyBtn()
        if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
            do return end
        end
        local function onConfirm()
            self:showEmptyEquipBtn(parent)
        end
        if(emblemId)then
            local eCfg = emblemVoApi:getEquipCfgById(emblemId)
            if(eCfg and eCfg.attUp and eCfg.attUp.troopsAdd)then
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onConfirm, getlocal("dialog_title_prompt"), getlocal("removeEmblemConfirm"), nil, self.layerNum + 1)
            else
                onConfirm()
            end
        else
            onConfirm()
        end
    end
    local equipItem = CCMenuItemSprite:create(equipSp1, equipSp2)
    equipItem:registerScriptTapHandler(showEmptyBtn)
    equipItem:setAnchorPoint(ccp(0, 0))
    equipItem:setPosition(ccp(9, 8))
    
    equipMenu = CCMenu:createWithItem(equipItem)
    equipMenu:setTag(5645)
    equipMenu:setAnchorPoint(ccp(0, 0))
    -- equipMenu:setPosition(ccp(0-5,0))
    local addH = 0
    if self.type == 24 or self.type == 27 then
        addH = 50
    end
    if G_isIphone5() == true then
        if self.type == 38 or self.type == 39 then
            equipMenu:setPosition(ccp(parent:getContentSize().width - 114 - 5, 160 + 25 + addH))
        else
            equipMenu:setPosition(ccp(parent:getContentSize().width - 102 - 5, 160 + 25 + addH))
        end
    else
        if self.type == 38 or self.type == 39 then
            equipMenu:setPosition(ccp(parent:getContentSize().width - 114 - 5, 160 + addH))
        else
            equipMenu:setPosition(ccp(parent:getContentSize().width - 102 - 5, 160 + addH))
        end
    end
    equipMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    parent:addChild(equipMenu, 1)
end

-- 显示空飞机的按钮
function editTroopsLayer:showEmptyPlaneBtn(parent)
    
    local planeMenu = tolua.cast(parent:getChildByTag(5646), "CCMenu")
    if planeMenu ~= nil then
        planeMenu:removeFromParentAndCleanup(true)
        planeMenu = nil
    end
    -- 清空飞机
    -- planeVoApi:setBattleEquip(self.type,nil)
    planeVoApi:setTmpEquip(nil, self.type)
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
    
    local function showPlaneBtn()
        if base.plane == 0 then
            do return end
        end
        if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
            do return end
        end
        local function showPlaneDialog(planePos)
            print("planePos", planePos)
            self:showPlaneBtn(parent, planePos)
        end
        
        -- local canNotUsePlaneTb={}
        local tb = planeVoApi:getEquipCanNotUse(self.type) or {}
        local canNotUsePlaneTb = G_clone(tb)
        -- if self.type==11 then
        --     canNotUsePlaneTb=G_clone(tb)
        -- else
        --     if tb and type(tb)=="table" and SizeOfTable(tb)>0 then
        --         for k,v in pairs(tb) do
        --             if v and v~=0 then
        --                 if canNotUsePlaneTb[v] then
        --                     canNotUsePlaneTb[v]=canNotUsePlaneTb[v]+1
        --                 else
        --                     canNotUsePlaneTb[v]=1
        --                 end
        --             end
        --         end
        --     end
        -- end
        planeVoApi:showSelectPlaneDialog(nil, 2, self.layerNum + 1, showPlaneDialog, nil, canNotUsePlaneTb, self.type, self.cid)
        if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 39 then
            otherGuideMgr:toNextStep()
        end
    end
    local planeItem = CCMenuItemSprite:create(planeSp1, planeSp2)
    planeItem:registerScriptTapHandler(showPlaneBtn)
    planeItem:setAnchorPoint(ccp(0, 0))
    planeItem:setPosition(ccp(4, 6))
    
    planeMenu = CCMenu:createWithItem(planeItem)
    planeMenu:setTag(5646)
    planeMenu:setAnchorPoint(ccp(0, 0))
    -- planeMenu:setPosition(ccp(0,0))
    planeMenu:setPosition(ccp(parent:getContentSize().width - 102, 0))
    if self.type == 24 or self.type == 27 then
        planeMenu:setPosition(ccp(parent:getContentSize().width - 102, 50))
    elseif self.type == 38 or self.type == 39 then
        planeMenu:setPosition(ccp(parent:getContentSize().width - 114, 0))
    end
    planeMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    parent:addChild(planeMenu, 1)
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 38 then
        otherGuideMgr:setGuideStepField(39, planeItem, true)
    end
end

-- 显示带有飞机的按钮
function editTroopsLayer:showPlaneBtn(parent, planePos)
    -- 移除原有的按钮
    local planeMenu = tolua.cast(parent:getChildByTag(5646), "CCMenu")
    if planeMenu ~= nil then
        planeMenu:removeFromParentAndCleanup(true)
        planeMenu = nil
    end
    -- 判断是否解锁飞机
    local planeVo
    if self.type == 35 or self.type == 36 then
        planeVo = ltzdzFightApi:getPlaneVoByPos(planePos)
    else
        planeVo = planeVoApi:getPlaneVoByPos(planePos)
    end
    if planeVo == nil then
        do return end
    end
    -- 显示飞机
    -- planeVoApi:setBattleEquip(self.type,planePos)
    planeVoApi:setTmpEquip(planePos, self.type)
    -- 带有飞机的按钮1
    local planeSp1 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp1 = planeVoApi:getPlaneIconNoBg(planeSp1, planeVo.pid, 15)
    -- showPlaneSp1:setScale(0.3)
    showPlaneSp1:setPosition(ccp(planeSp1:getContentSize().width / 2, planeSp1:getContentSize().height / 2 + 15))
    planeSp1:addChild(showPlaneSp1)
    
    local planeSp2 = CCSprite:createWithSpriteFrameName("st_features.png")
    local showPlaneSp2 = planeVoApi:getPlaneIconNoBg(planeSp2, planeVo.pid, 15)
    -- showPlaneSp2:setScale(0.3)
    showPlaneSp2:setPosition(ccp(planeSp2:getContentSize().width / 2, planeSp2:getContentSize().height / 2 + 15))
    planeSp2:addChild(showPlaneSp2)
    planeSp2:setScale(0.97)
    -- 已选择飞机的时候，点击会移除掉飞机，显示空按钮
    local function showPlaneBtn()
        if self.type == 18 or (self.type >= 27 and self.type <= 29) or self.type == 31 or self.type == 34 then
            do return end
        end
        self:showEmptyPlaneBtn(parent)
    end
    local planeItem = CCMenuItemSprite:create(planeSp1, planeSp2)
    planeItem:registerScriptTapHandler(showPlaneBtn)
    planeItem:setAnchorPoint(ccp(0, 0))
    planeItem:setPosition(ccp(4, 6))
    
    planeMenu = CCMenu:createWithItem(planeItem)
    planeMenu:setTag(5646)
    planeMenu:setAnchorPoint(ccp(0, 0))
    -- planeMenu:setPosition(ccp(0-5,0))
    planeMenu:setPosition(ccp(parent:getContentSize().width - 102, 0))
    if self.type == 24 or self.type == 27 then
        planeMenu:setPosition(ccp(parent:getContentSize().width - 102, 50))
    elseif self.type == 38 or self.type == 39 then
        planeMenu:setPosition(ccp(parent:getContentSize().width - 114, 0))
    end
    planeMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    parent:addChild(planeMenu, 1)
end

function editTroopsLayer:resetSkillIcon()
    if self.type == 35 or self.type == 36 or self.type == 4 then
        do return end
    end
    if self.skillIcon and SizeOfTable(self.skillIcon) > 0 then
        for k, v in pairs(self.skillIcon) do
            if v then
                local sp = tolua.cast(v, "CCSprite")
                sp:removeFromParentAndCleanup(true)
                sp = nil
            end
        end
        self.skillIcon = {}
    end
    if self.parentLayer and self.type then
        local tankTb = tankVoApi:getTanksTbByType(self.type)
        local iSize = 50
        local tmpTb = {}
        local function touchHandler(object, fn, tag)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local content = tankVoApi:getTanksTbByType(self.type)
            tankVoApi:showTankBuffSmallDialog("TankInforPanel.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), content, true, true, self.layerNum + 1, nil, true)
        end
        local rightSpace = (airShipVoApi:isCanEnter() == true) and 165 or 40
        local index = 1
        if airShipVoApi:isCanEnter() == true then
            local bufIconCount = 0
            for k, v in pairs(tankTb) do
                if v and v[1] and v[2] and v[2] > 0 then
                    local tankId = v[1]
                    local id = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    local buffType = tankCfg[id].buffShow[1]
                    if buffType and tmpTb[buffType] == nil then
                        bufIconCount = bufIconCount + 1
                    end
                end
            end
            if bufIconCount > 0 then
                local ghPic = "tank_buffGather_icon.png"
                local ghSp = LuaCCSprite:createWithSpriteFrameName(ghPic, touchHandler)
                local iconScale = iSize / ghSp:getContentSize().width
                ghSp:setScale(iconScale)
                ghSp:setAnchorPoint(ccp(1, 0.5))
                if self.airshipBtn and tolua.cast(self.airshipBtn, "CCSprite") then
                    ghSp:setPosition(ccp(self.airshipBtn:getPositionX() - self.airshipBtn:getContentSize().width / 2 - 10, self.airshipBtn:getPositionY() + 9))
                end
                ghSp:setTouchPriority(-(self.layerNum - 1) * 20 - 11)
                self.parentLayer:addChild(ghSp, 1)
                self.skillIcon[index] = ghSp
                index = index + 1
            end
        else
            for k, v in pairs(tankTb) do
                if v and v[1] and v[2] and v[2] > 0 then
                    local tankId = v[1]
                    local id = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    local buffType = tankCfg[id].buffShow[1]
                    if buffType and tmpTb[buffType] == nil then
                        local ghPic = "tank_gh_icon_" ..buffType.. ".png"
                        local ghSp = LuaCCSprite:createWithSpriteFrameName(ghPic, touchHandler)
                        local iconScale = iSize / ghSp:getContentSize().width
                        ghSp:setScale(iconScale)
                        ghSp:setAnchorPoint(ccp(1, 0.5))
                        local px = G_VisibleSizeWidth - rightSpace - (iSize) * (index - 1)
                        if G_isIphone5() == true then
                            ghSp:setPosition(ccp(px, self.tHeight - 10))
                        else
                            ghSp:setPosition(ccp(px, self.tHeight))
                        end
                        ghSp:setTouchPriority(-(self.layerNum - 1) * 20 - 11)
                        self.parentLayer:addChild(ghSp, 1)
                        self.skillIcon[index] = ghSp
                        index = index + 1
                        tmpTb[buffType] = 1
                    end
                end
            end
        end
        
        if self.type == 12 then
            -- local tankTb = tankVoApi:getTanksTbByType(self.type)
            local typeTb = {["1"] = 0, ["2"] = 0, ["4"] = 0, ["8"] = 0}
            for k, v in pairs(tankTb) do
                if v and v[1] and v[2] and v[2] > 0 then
                    local tankId = v[1]
                    local id = (tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    local tankType = tankCfg[id].type
                    if typeTb[tankType] then
                        typeTb[tankType] = 1
                    end
                end
            end
            local index = 0
            for k, v in pairs(typeTb) do
                index = v == 1 and index + 1 or index
            end
            if self.hydraBufSp then
                self.hydraBufSp:removeFromParentAndCleanup(true)
                self.hydraBufSp = nil
            end
            
            local function hydraBufHandler(object, fn, tag)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                tankVoApi:showTankBuffSmallDialog("TankInforPanel.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), nil, true, true, self.layerNum + 1, nil, true, {12, index, typeTb})
            end
            
            local bufIcon = index < 2 and "hydraBuf_1.png" or "hydraBuf_"..index..".png"
            local hydraBufSp = LuaCCSprite:createWithSpriteFrameName(bufIcon, hydraBufHandler)
            local iconScale = 70 / hydraBufSp:getContentSize().width
            hydraBufSp:setScale(iconScale)
            hydraBufSp:setAnchorPoint(ccp(0, 1))
            hydraBufSp:setPosition(ccp(2, -8))
            hydraBufSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            if index < 1 then
                local hydraBufSp2 = GraySprite:createWithSpriteFrameName(bufIcon)
                hydraBufSp2:setPosition(getCenterPoint(hydraBufSp))
                hydraBufSp:addChild(hydraBufSp2)
            end
            self.layerBg:addChild(hydraBufSp, 1)
            self.hydraBufSp = hydraBufSp
        end
    end
end

function editTroopsLayer:refreshDisban()
    for i = 1, 6, 1 do
        local spA = self.parentLayer:getChildByTag(i):getChildByTag(2)
        if spA ~= nil then
            spA:removeFromParentAndCleanup(true)
        end
        tankVoApi:deleteTanksTbByType(self.type, i)
        --将领文字变成无
        heroVoApi:deletTroopsByPos(i, self.type)
        --解散后删除AI部队信息
        AITroopsFleetVoApi:deleteAITroopsByPos(i, self.type)
    end
    
    local troopsBg = tolua.cast(self.parentLayer:getChildByTag(4534), "CCSprite")
    if troopsBg then
        if base.emblemSwitch == 1 then
            local permitLevel = emblemVoApi:getPermitLevel()
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (ltzdzFightApi:numOfEmblem() > 0) then
                self:showEmptyEquipBtn(troopsBg)
            end
        end
        -- 先选择最大强度的飞机
        if base.plane == 1 then
            local permitLevel = planeVoApi:getOpenLevel()
            if (permitLevel and playerVoApi:getPlayerLevel() >= permitLevel) or (ltzdzFightApi:numOfPlane() > 0) then
                self:showEmptyPlaneBtn(troopsBg)
            end
            
        end
    end
    self:resetQueueNum()
    eventDispatcher:dispatchEvent("troops.change", {})
    
end

function editTroopsLayer:refreshAirshipBtn(airshipId, isRefreshTroops)
    if self then
        airShipVoApi:setTempLineupId(airshipId, self.type)
        local airshipBtn = tolua.cast(self.airshipBtn, "CCSprite")
        if airshipBtn then
            local airshipBtnPic = "aei_airShipBtn.png"
            if airshipId then
                airshipId = tonumber(airshipId) and "a"..airshipId or airshipId
                airshipBtnPic = "aei_airShipBtn_" .. airshipId .. ".png"
                self.lastAirshipId = airshipId
            else
                self.lastAirshipId = nil
            end
            airshipBtn:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(airshipBtnPic))
        end
        self:refreshTroopsNum(isRefreshTroops)
    end
end

--刷新带兵量
function editTroopsLayer:refreshTroopsNum(isRefreshTroops)
    local fontSize = 22
    local posX, posY = 45, 0
    if G_isIphone5() == true then
        posY = self.tHeight - 10
    else
        posY = self.tHeight
    end
    -- 军徽加带兵量
    local troopsAdd = 0
    if base.emblemSwitch == 1 then
        local emblemId = emblemVoApi:getTmpEquip(self.type, self.cid)
        -- 获取此类型的军徽id
        if emblemId then
            local emTroopVo
            if self.type == 35 or self.type == 36 then
                emTroopVo = ltzdzFightApi:getEmblemTroopById(emblemId)
            end
            troopsAdd = emblemVoApi:getTroopsAddById(emblemId, emTroopVo)
        end
    end
    if self.troopsNumLb then
        self.troopsNumLb:removeFromParentAndCleanup(true)
    end
    local colorTab = {nil, G_ColorGreen, nil}
    local troopsNumStr
    if self.type == 35 or self.type == 36 then
        troopsNumStr = getlocal("player_leader_troop_num", {ltzdzFightApi:getFightNum()}) .. "<rayimg>+" .. troopsAdd .. "<rayimg>"
    else
        troopsNumStr = getlocal("player_leader_troop_num", {playerVoApi:getTroopsLvNum()}) .. "<rayimg>+" .. (playerVoApi:getExtraTroopsNum(self.type, false) + troopsAdd) .. "<rayimg>"
    end
    
    local lbHeight = 0
    self.troopsNumLb, lbHeight = G_getRichTextLabel(troopsNumStr, colorTab, fontSize, G_VisibleSizeWidth / 2 - 60, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.troopsNumLb:setAnchorPoint(ccp(0, 1))
    self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2))
    self.parentLayer:addChild(self.troopsNumLb, 2)
    
    if self.type == 35 then
        self.troopsNumLb:setPosition(ccp(posX, posY + lbHeight / 2 + 60))
    elseif self.type == 36 then
        self.troopsNumLb:setPosition(ccp(posX, G_VisibleSizeHeight - 180))
    end
    if isRefreshTroops then
        self:troopsChangedRefresh(self.type, self.parentLayer, self.layerNum)
    end
end

function editTroopsLayer:tick()
    
end

function editTroopsLayer:dispose()
    if self.type == 35 and self.disbanListener then
        eventDispatcher:removeEventListener("ltzdz.disban", self.disbanListener)
    end
    if self.type == 38 then
        spriteController:removePlist("public/believer/believerTexture.plist")
        spriteController:removeTexture("public/believer/believerTexture.png")
    end
    self.tankPosY = nil
    self.troopsNumLb = nil
    self.skillIcon = {}
    self.iconTab = {}
    self.posTab = {}
    self.nullAITroopsTb = nil
    if self.extTroopsLayer then
        self.extTroopsLayer:dispose()
    end
    self.extTroopsLayer = nil
    G_editLayer[self.type] = nil
    tankSkinVoApi:clearTempTankSkinList(self.type)
end
