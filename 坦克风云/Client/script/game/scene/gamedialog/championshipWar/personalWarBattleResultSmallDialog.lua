personalWarBattleResultSmallDialog = smallDialog:new()

function personalWarBattleResultSmallDialog:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

--result：结算的数据，isWipe：是否是扫荡
function personalWarBattleResultSmallDialog:showBattleResultDialog(isVictory, result, isWipe, layerNum, callback, parent)
    local sd = personalWarBattleResultSmallDialog:new()
    sd:initBattleResultDialog(isVictory, result, isWipe, layerNum, callback, parent)
end

function personalWarBattleResultSmallDialog:initBattleResultDialog(isVictory, result, isWipe, layerNum, callback, parent)
    self.parent = parent
    self.isVictory = isVictory
    self.isWipe = isWipe
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/battleResultAddPic.plist")
    spriteController:addTexture("public/battleResultAddPic.png")
    if self.isVictory then
        spriteController:addPlist("public/winR_newImage170612.plist")
        spriteController:addTexture("public/winR_newImage170612.png")
    else
        spriteController:addPlist("public/loseR_newImage170612.plist")
        spriteController:addTexture("public/loseR_newImage170612.png")
    end
    local bgPic = "loserBgSp.jpg"
    if isVictory == true then
        bgPic = "WinnerBgSp.jpg"--dwEndBg1
    end
    local bgSp = CCSprite:create("public/"..bgPic)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.isTouch = false
    self.isUseAmi = false
    self.layerNum = layerNum
    
    local warCfg = championshipWarVoApi:getWarCfg()
    local starNum = result.star or 0 --结算得星
    local dieTroops = result.dieTroops --损失部队
    local troops = result.troops --出战时的部队
    local diffId = result.diffId or 1--关卡难易
    local diePlaceNum, placeNum = 0, 0
    local dieTroopNum, totalTroopNum = 0, 0
    self.sizeRate = 1
    if isWipe == true then
        local enemyTankTb = championshipWarVoApi:getAttackCheckpointEnemyTanks(diffId)
        for k, v in pairs(enemyTankTb) do
            local tankId, num = v[1], v[2]
            if tankId and tankId ~= 0 then
                placeNum = placeNum + 1
            end
        end
        diePlaceNum = 0
        self.sizeRate = 0.8
    else
        for k, v in pairs(troops) do
            local tankId, num = v[1], v[2]
            local dieTank = dieTroops[k] or {}
            local dieId, dieNum = dieTank[1], dieTank[2] or 0
            if tankId and tankId ~= 0 then
                placeNum = placeNum + 1
                totalTroopNum = totalTroopNum + tonumber(num)
                dieTroopNum = dieTroopNum + (tonumber(dieNum) or 0)
                if dieNum >= num then
                    diePlaceNum = diePlaceNum + 1
                end
            end
        end
    end
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    
    local dialogBg
    self.bgSize = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    if isWipe == true then
        self.bgSize = CCSizeMake(580, 820)
        dialogBg = G_getNewDialogBg2(self.bgSize, layerNum, nil, getlocal("believer_battle_result"), 28)
        bgSp:setVisible(false)
    else
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function () end)
        dialogBg:setContentSize(self.bgSize)
        dialogBg:setOpacity(0)
    end
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local clipper = CCClippingNode:create()
    clipper:setContentSize(self.bgSize)
    clipper:setAnchorPoint(ccp(0.5, 0.5))
    clipper:setPosition(getCenterPoint(self.bgLayer))
    local stencil
    if isWipe == true then
        stencil = CCDrawNode:getAPolygon(CCSizeMake(self.bgSize.width - 10, self.bgSize.height), 1, 1)
    else
        stencil = CCDrawNode:getAPolygon(self.bgSize, 1, 1)
    end
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper, 2)
    
    self:show()
    
    bgSp:setScaleX(self.bgSize.width / bgSp:getContentSize().width)
    bgSp:setScaleY(self.bgSize.height / bgSp:getContentSize().height)
    bgSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(bgSp)
    
    if isVictory == true then
        self:runWinAniTank(starNum)
    else
        self:runLoseAniTank()
    end
    
    local actionTb = {} --每个KEY 内容{ 1：使用动画效果 2：动画效果的对象 3：父类 4：动画前坐标 5：动画后坐标 6：延时时间 7：动画时间 }
    
    local firstBgPic, secondBgPic, thirdBgPic = "lightGreenBg.png", "lightGreenBg.png", "lightGreenBg.png"
    local starFlag1, starFlag2, starFlag3 = 1, 1, 1
    local colorTb1, colorTb2, colorTb3 = {}, {G_ColorWhite, G_ColorGreen, G_ColorWhite}, {G_ColorWhite, G_ColorGreen, G_ColorWhite}
    if isVictory ~= true then --战斗失败
        firstBgPic, starFlag1 = "lightRedBg.png", 0
    end
    if diePlaceNum > 0 then --有战斗位损失
        secondBgPic, starFlag2, colorTb2 = "lightRedBg.png", 0, {G_ColorWhite, G_ColorRed, G_ColorWhite}
    end
    local remainPercent = 0
    if isWipe == true then
        remainPercent = 1
    else
        remainPercent = tonumber(string.format("%0.2f", (totalTroopNum - dieTroopNum) / totalTroopNum))
    end
    if remainPercent < warCfg.surplusTroopsNumPercent then --部队剩余低于配置数据
        thirdBgPic, starFlag3, colorTb3 = "lightRedBg.png", 0, {G_ColorWhite, G_ColorRed, G_ColorWhite}
    end
    local starConditionTb = {
        {pic = firstBgPic, lbStr = getlocal("fight_win"), starFlag = starFlag1, colorTb = colorTb1},
        {pic = secondBgPic, lbStr = getlocal("fight_place_full") .. "<rayimg>"..getlocal("super_weapon_challenge_troops_schedule", {placeNum - diePlaceNum, placeNum}) .. "<rayimg>", starFlag = starFlag2, colorTb = colorTb2},
        {pic = thirdBgPic, lbStr = getlocal("fight_troop_remain", {warCfg.surplusTroopsNumPercent * 100}) .. "<rayimg>"..getlocal("brackets", {(remainPercent * 100) .. "%%"}) .. "<rayimg>", starFlag = starFlag3, colorTb = colorTb3},
    }
    local contentWidth = self.bgSize.width - 150
    local posY = self.bgSize.height - 520
    if isWipe == true then
        posY = self.bgSize.height - 360
    end
    local dt = 0.5
    
    local posX = self.bgSize.width / 2
    local titleBg = G_createNewTitle({getlocal("championshipWar_battle_resultTitle"), 25}, CCSizeMake(300, 0), true)
    titleBg:setPosition(posX + self.bgSize.width, posY)
    clipper:addChild(titleBg)
    actionTb["titleBg"] = {{1, 103}, titleBg, nil, nil, ccp(posX, posY), dt, 0.5, nil}
    
    local starSpTb = {}
    posY = posY - 60
    for k, v in pairs(starConditionTb) do
        posX = self.bgSize.width / 2 - 15
        local conditionLb, lbheight = G_getRichTextLabel(v.lbStr, v.colorTb, 24, contentWidth - 80, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        local conditionBg = LuaCCScale9Sprite:createWithSpriteFrameName(v.pic, CCRect(32, 15, 2, 2), function() end)
        conditionBg:setContentSize(CCSizeMake(contentWidth, 32))
        conditionBg:setPosition(posX + self.bgSize.width, posY)
        clipper:addChild(conditionBg)
        
        conditionLb:setAnchorPoint(ccp(0, 1))
        conditionLb:setPosition(40, conditionBg:getContentSize().height / 2 + lbheight / 2)
        conditionBg:addChild(conditionLb)
        
        local starPic = "stars_n1.png"
        if v.starFlag == 0 then
            starPic = "stars_n2.png"
        end
        local starSp = CCSprite:createWithSpriteFrameName(starPic)
        starSp:setAnchorPoint(ccp(0.5, 0.5))
        starSp:setScale(0.8)
        starSp:setPosition(conditionBg:getContentSize().width - 20 + starSp:getContentSize().width * starSp:getScale() / 2, conditionBg:getContentSize().height / 2 + 10)
        conditionBg:addChild(starSp)
        
        if v.starFlag ~= 0 then --记录一下得星的sprite，后面需要做动画
            starSpTb[k] = starSp
            starSp:setVisible(false)
        end
        
        dt = dt + 0.3
        actionTb["condition"..k] = {{1, 103}, conditionBg, nil, nil, ccp(posX, posY), dt, 0.5, nil}
        
        posY = posY - 80
    end
    dt = dt + 0.5
    for k, starSp in pairs(starSpTb) do
        starSp:setVisible(true)
        starSp:setScale(5 * self.sizeRate)
        starSp:setOpacity(0)
        -- starSp:setPosition(ccp(tankPic:getPositionX() + addPosXTb[i] * self.sizeRate, tankPic:getPositionY() - 140 + addPosYTb[i] * self.sizeRate))
        -- self.bgLayer:addChild(starSp, 4)
        
        local function readyShake()
            PlayEffect(audioCfg.battle_star)
            -- self:shakingNow()
        end
        local shakeCall = CCCallFunc:create(readyShake)
        local delayAc = CCDelayTime:create(dt + (k-1) * 0.3)
        local fadeIn = CCFadeIn:create(0.2)
        local scaleIn = CCScaleTo:create(0.1, 0.8 * self.sizeRate)
        local arr2 = CCArray:create()
        local arr3 = CCArray:create()
        arr2:addObject(fadeIn)
        arr2:addObject(scaleIn)
        
        local spawn = CCSpawn:create(arr2)
        arr3:addObject(delayAc)
        arr3:addObject(spawn)
        arr3:addObject(shakeCall)
        local seq = CCSequence:create(arr3)
        starSp:runAction(seq)        
    end
    dt = dt + SizeOfTable(starSpTb)*0.3
    
    local starSp = CCSprite:createWithSpriteFrameName("stars_n1.png")
    starSp:setScale(0.6)
    posX = self.bgSize.width / 2 - starSp:getContentSize().width * starSp:getScale() / 2
    local starRate = warCfg.getStarRatio[diffId]
    local starLb = GetTTFLabel(getlocal("get_star_num", {starNum.."x"..starRate}), 32)
    starLb:setPosition(posX + self.bgSize.width, posY)
    clipper:addChild(starLb)
    starSp:setAnchorPoint(ccp(0.5, 0.5))
    starSp:setPosition(starLb:getContentSize().width + starSp:getContentSize().width * starSp:getScale() / 2 + 5, starLb:getContentSize().height / 2)
    starLb:addChild(starSp)
    actionTb["starLb"] = {{1, 103}, starLb, nil, nil, ccp(posX, posY), dt, 0.5, nil}
    dt = dt + 0.5
    local starAcArr = CCArray:create()
    local delayAc = CCDelayTime:create(dt)
    local scaleTo1 = CCScaleTo:create(0.3, 1.2)
    local scaleTo2 = CCScaleTo:create(0.2, 1)
    starAcArr:addObject(delayAc)
    starAcArr:addObject(scaleTo1)
    starAcArr:addObject(scaleTo2)
    local starLbSeq = CCSequence:create(starAcArr)
    starLb:runAction(starLbSeq)
    
    dt = dt + 0.5
    --确定
    local btnScale, priority = 0.8, -(layerNum - 1) * 20 - 200
    local btnPosX, btnPosY = self.bgSize.width / 2 + 120, 60
    if isWipe == true then
        btnPosX = self.bgSize.width / 2
    end
    local function cancleHandler()
        if callback ~= nil then
            callback()
        end
        self:closeResultDialog()
    end
    local closeItem, closeMenu = G_createBotton(clipper, ccp(btnPosX + self.bgSize.width, btnPosY), {getlocal("ok")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", cancleHandler, btnScale, priority)
    actionTb["closeBtn"] = {{1, 103}, closeMenu, nil, nil, ccp(btnPosX, btnPosY), dt, 0.5, nil}
    dt = dt + 0.3
    
    if isWipe ~= true then
        --战斗回放
        local function replay()
            if self.parent then
                self.parent:close()
                battleScene:initData(self.parent.firstData)
            end
            self:closeResultDialog()
        end
        btnPosX = self.bgSize.width / 2 - 120
        local replayItem, replayMenu = G_createBotton(clipper, ccp(btnPosX + self.bgSize.width, btnPosY), {getlocal("playBackStr")}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", replay, btnScale, priority)
        actionTb["replayBtn"] = {{1, 103}, replayMenu, nil, nil, ccp(btnPosX, btnPosY), dt, 0.5, nil}
    end
    
    G_RunActionCombo(actionTb)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

function personalWarBattleResultSmallDialog:runWinAniTank(starsNum, isVictory)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local sizeRate = self.sizeRate
    local sunSp = {}
    local tankPic = CCSprite:createWithSpriteFrameName("win_r_tank.png")
    tankPic:setPosition(ccp(self.bgSize.width * 0.5, self.bgSize.height * 0.83))
    tankPic:setOpacity(0)
    tankPic:setScale(3 * sizeRate)
    self.bgLayer:addChild(tankPic, 4)
    
    local delayAc = CCDelayTime:create(0.3)
    local delayAc5 = CCDelayTime:create(0.4)
    local fadeIn1 = CCFadeIn:create(0)
    local ScaleAction4 = CCScaleTo:create(0.1, 0.8 * sizeRate)
    local ScaleAction5 = CCScaleTo:create(0.08, 1.1 * sizeRate)
    local ScaleAction6 = CCScaleTo:create(0.08, 1 * sizeRate)
    
    local function roteCall()
        if sunSp[1] then
            sunSp[1]:setVisible(true)
        end
        if sunSp[2] then
            sunSp[2]:setVisible(true)
        end
        if starsNum then
            self:showStarAni(starsNum, tankPic)
        end
    end
    local ccCall = CCCallFunc:create(roteCall)
    local acArr2 = CCArray:create()
    acArr2:addObject(delayAc)
    acArr2:addObject(fadeIn1)
    acArr2:addObject(ScaleAction4)
    acArr2:addObject(ScaleAction5)
    acArr2:addObject(ScaleAction6)
    acArr2:addObject(delayAc5)
    
    acArr2:addObject(ccCall)
    local seq1 = CCSequence:create(acArr2)
    tankPic:runAction(seq1)
    
    for i = 1, 2 do
        local realLight = CCSprite:createWithSpriteFrameName("win_r_sun"..i..".png")
        realLight:setPosition(ccp(tankPic:getPositionX(), tankPic:getPositionY()))
        realLight:setScale(sizeRate)
        self.bgLayer:addChild(realLight, 2)
        realLight:setVisible(false)
        sunSp[i] = realLight
        
        local roteSize = i == 1 and 360 or - 360
        local rotate1 = CCRotateBy:create(10, roteSize)
        local repeatForever = CCRepeatForever:create(rotate1)
        realLight:runAction(repeatForever)
    end
    
    local tankBg = CCSprite:createWithSpriteFrameName("win_r_1.png")
    tankBg:setPosition(ccp(tankPic:getPositionX(), tankPic:getPositionY() - 50))
    tankBg:setOpacity(0)
    tankBg:setScale(2 * sizeRate)
    self.bgLayer:addChild(tankBg, 3)
    
    local delayAc2 = CCDelayTime:create(0.8)
    local fadeIn2 = CCFadeIn:create(0)
    local pzArr = CCArray:create()
    for kk = 1, 22 do
        local nameStr = "win_r_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.06)
    local animate = CCAnimate:create(animation)
    
    local acArr3 = CCArray:create()
    acArr3:addObject(delayAc2)
    acArr3:addObject(fadeIn2)
    acArr3:addObject(animate)
    local seq2 = CCSequence:create(acArr3)
    tankBg:runAction(seq2)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function personalWarBattleResultSmallDialog:runLoseAniTank(starsNum)
    local sizeRate = self.sizeRate
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local addposY = starsNum and 50 or 0
    local tankBg = CCSprite:createWithSpriteFrameName("loseR_3.png")
    local lastPosY = self.bgSize.height * 0.86 + addposY
    tankBg:setPosition(ccp(self.bgSize.width * 0.5, lastPosY))
    tankBg:setVisible(false)
    tankBg:setScale(sizeRate)
    self.bgLayer:addChild(tankBg, 5)
    
    local loseAniPic2 = CCSprite:createWithSpriteFrameName("loseR_1.png")--翅膀
    loseAniPic2:setPosition(ccp(self.bgSize.width * 0.5, lastPosY + 300))
    loseAniPic2:setScale(5 * sizeRate)
    loseAniPic2:setOpacity(0)
    self.bgLayer:addChild(loseAniPic2, 4)
    
    local loseAniPic1 = CCSprite:createWithSpriteFrameName("loseR_2.png")--坦克
    loseAniPic1:setPosition(ccp(self.bgSize.width * 0.5, lastPosY + 300))
    loseAniPic1:setScale(sizeRate)
    self.bgLayer:addChild(loseAniPic1, 4)
    
    local delayAc1 = CCDelayTime:create(0.3)
    local fadeIn1 = CCFadeIn:create(0.25)
    local movTo1 = CCMoveTo:create(0.25, ccp(self.bgSize.width * 0.5, lastPosY))
    local scal1 = CCScaleTo:create(0.25, 1 * sizeRate)
    local arr1 = CCArray:create()
    arr1:addObject(fadeIn1)
    arr1:addObject(movTo1)
    arr1:addObject(scal1)
    local spawn1 = CCSpawn:create(arr1)
    local seq1 = CCSequence:createWithTwoActions(delayAc1, spawn1)
    loseAniPic2:runAction(seq1)
    
    local delayAc2 = CCDelayTime:create(0.5)
    local movTo2 = CCMoveTo:create(0.25, ccp(self.bgSize.width * 0.5, lastPosY))
    local rotate1 = CCRotateTo:create(0.1, 10)
    local rotate2 = CCRotateTo:create(0.1, -10)
    local rotate3 = CCRotateTo:create(0.05, 5)
    local rotate4 = CCRotateTo:create(0.05, -5)
    local rotate5 = CCRotateTo:create(0.05, 0)
    local function roteCall()
        tankBg:setVisible(true)
        loseAniPic1:setVisible(false)
        loseAniPic2:setVisible(false)
        if starsNum then
            self:showStarAni(starsNum, tankBg)
        end
    end
    local ccCall = CCCallFunc:create(roteCall)
    local arr2 = CCArray:create()
    arr2:addObject(delayAc2)
    arr2:addObject(movTo2)
    arr2:addObject(rotate1)
    arr2:addObject(rotate2)
    arr2:addObject(rotate3)
    arr2:addObject(rotate4)
    arr2:addObject(rotate5)
    arr2:addObject(ccCall)
    local seq2 = CCSequence:create(arr2)
    loseAniPic1:runAction(seq2)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function personalWarBattleResultSmallDialog:showStarAni(starsNum, tankPic)
    local sizeRate = self.sizeRate
    local addPosXTb = {-110, 0, 110}
    local addPosYTb = {30, 0, 30}
    if starsNum and starsNum > 0 then
        for i = 1, 3 do
            local starsSp = CCSprite:createWithSpriteFrameName("stars_n2.png")
            starsSp:setOpacity(0)
            starsSp:setScale(sizeRate)
            starsSp:setPosition(ccp(tankPic:getPositionX() + addPosXTb[i] * sizeRate, tankPic:getPositionY() - 140 + addPosYTb[i] * sizeRate))
            self.bgLayer:addChild(starsSp, 4)
            
            local delayAc = CCDelayTime:create(0.2)
            local fadeIn = CCFadeIn:create(0.2)
            local arr2 = CCArray:create()
            arr2:addObject(delayAc)
            arr2:addObject(fadeIn)
            
            local seq = CCSequence:create(arr2)
            starsSp:runAction(seq)
        end
        
        for i = 1, starsNum do
            
            local starsSp = CCSprite:createWithSpriteFrameName("stars_n1.png")
            starsSp:setScale(5 * sizeRate)
            starsSp:setOpacity(0)
            starsSp:setPosition(ccp(tankPic:getPositionX() + addPosXTb[i] * sizeRate, tankPic:getPositionY() - 140 + addPosYTb[i] * sizeRate))
            self.bgLayer:addChild(starsSp, 4)
            
            local function readyShake()
                PlayEffect(audioCfg.battle_star)
                -- self:shakingNow()
            end
            local shakeCall = CCCallFunc:create(readyShake)
            local delayAc = CCDelayTime:create(0.4 + i * 0.3)
            local fadeIn = CCFadeIn:create(0.2)
            local scaleIn = CCScaleTo:create(0.1, 1 * sizeRate)
            local arr2 = CCArray:create()
            local arr3 = CCArray:create()
            arr2:addObject(fadeIn)
            arr2:addObject(scaleIn)
            
            local spawn = CCSpawn:create(arr2)
            arr3:addObject(delayAc)
            arr3:addObject(spawn)
            arr3:addObject(shakeCall)
            local seq = CCSequence:create(arr3)
            starsSp:runAction(seq)
        end
    end
end

function personalWarBattleResultSmallDialog:closeResultDialog()
    spriteController:removePlist("public/battleResultAddPic.plist")
    spriteController:removeTexture("public/battleResultAddPic.png")
    if self.isVictory then
        spriteController:removePlist("public/winR_newImage170612.plist")
        spriteController:removeTexture("public/winR_newImage170612.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/WinnerBgSp.jpg")
    else
        spriteController:removePlist("public/loseR_newImage170612.plist")
        spriteController:removeTexture("public/loseR_newImage170612.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/loserBgSp.jpg")
    end
    self:close()
    self.parent = nil
end
