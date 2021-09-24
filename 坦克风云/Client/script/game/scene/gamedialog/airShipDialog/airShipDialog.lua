airShipDialog = commonDialog:new()

function airShipDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    
    self.dialogWidth = G_VisibleSizeWidth
    self.dialogHeight = G_VisibleSizeHeight
    self.realHeight = self.dialogHeight - 80
    self.curAirShipId = airShipVoApi:getCurShowAirShip()
    G_addResource8888(function()
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        spriteController:addPlist("public/airShipImage1.plist")
        spriteController:addTexture("public/airShipImage1.png")
        spriteController:addPlist("public/airShipImage4.plist")
        spriteController:addTexture("public/airShipImage4.png")
        spriteController:addPlist("public/airShipImage5.plist")
        spriteController:addTexture("public/airShipImage5.png")
        
        spriteController:addPlist("public/taskYouhua.plist")
        spriteController:addTexture("public/taskYouhua.png")
        -- G_addingOrRemovingAirShipImage(true, nil, true)
    end)
    
    self.lotteryBtnTb = {}
    self.airshipTipTb = {}
    
    return nc
end

function airShipDialog:dispose()
    if self.powerChangeListener then
        eventDispatcher:removeEventListener("user.power.change", self.powerChangeListener)
        self.powerChangeListener = nil
    end
    if self.strengthRefreshListener then
        eventDispatcher:removeEventListener("airship.strength.refresh", self.strengthRefreshListener)
        self.strengthRefreshListener = nil
    end
    if self.propsRefreshListener then
        eventDispatcher:removeEventListener("airship.props.refresh", self.propsRefreshListener)
        self.propsRefreshListener = nil
    end
    
    self.bgLayer:stopAllActions()
    self.airshipTipTb = nil
    self.curAirShipId = nil
    self.lotteryBtnTb = nil
    self.curbuildingLvStr = nil
    self.bigAwardBg, self.bigAwardSp = nil, nil
    self.buildBtn, self.upArrowSp = nil, nil
    self.lotteryBtn = nil
    self.strengthBg, self.strengthLb = nil, nil
    self.getPartsTipActionSp = nil
    spriteController:removePlist("public/airShipImage1.plist")
    spriteController:removeTexture("public/airShipImage1.png")
    spriteController:removePlist("public/airShipImage4.plist")
    spriteController:removeTexture("public/airShipImage4.png")
    spriteController:removePlist("public/airShipImage5.plist")
    spriteController:removeTexture("public/airShipImage5.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end

function airShipDialog:refresh(rKey, params)
    if rKey == "lottery" then
        if params == nil then
            for rType = 1, 2 do
                self:refreshLotteryUseNum(rType)
            end
        else
            self:refreshLotteryUseNum(params.rType or 1)
        end
    elseif rKey == "parts" then
        self:refreshPartsDataWithSp()
    else
        --领取材料 相关刷新
        self:refreshPartsDataWithSp()
        --抽奖 相关刷新
        self:refreshLotteryUseNum(1)
        --概率Up 相关刷新
        self:refreshTodayUpType()
    end
end

function airShipDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    
    local fillingBg = LuaCCScale9Sprite:createWithSpriteFrameName("arpl_blackFillingBg.png", CCRect(3, 3, 1, 1), function() end)
    fillingBg:setContentSize(CCSizeMake(self.dialogWidth, self.realHeight))
    fillingBg:setAnchorPoint(ccp(0.5, 1))
    fillingBg:setPosition(self.dialogWidth * 0.5, self.realHeight)
    self.bgLayer:addChild(fillingBg)
    
    --建筑升级入口
    self:initUpBg()
    
    self:showMiddle()
    
    self:showLotteryBtn()
    
    --添加战力值变化的监听
    self.powerChangeListener = function(eventKey, eventData)
        G_showNumberChange(eventData[1], eventData[2])
    end
    eventDispatcher:addEventListener("user.power.change", self.powerChangeListener)
    if self.curAirShipId ~= 1 then --如果选中的不是运输艇认为玩家已玩过该功能，直接结束引导
        otherGuideMgr:endGuideStep(90)
    else
        if airShipVoApi:isGuidePlayed() == true then --玩家是否进行过教学步骤
            otherGuideMgr:endGuideStep(90)
        else
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep == 90 then
                otherGuideMgr:toNextStep()
            end
            if otherGuideMgr.isGuiding == true then --设置收取原料的引导位置
                otherGuideMgr:setGuideStepField(92, self.lotteryBtn, true, nil, {panlePos = ccp(10, 60)})
            end
        end
    end
    
    local function strengthRefresh(event, data)
        if self == nil or self.bgLayer == nil or tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
            do return end
        end
        self:refreshStrengthLb(data)
    end
    
    self.strengthRefreshListener = strengthRefresh
    eventDispatcher:addEventListener("airship.strength.refresh", self.strengthRefreshListener)
    
    local function propsRefresh(event, data)
        if self == nil or self.bgLayer == nil or tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
            do return end
        end
        self:refreshAirShipTip() --刷新飞艇的提示箭头状态
    end
    
    self.propsRefreshListener = propsRefresh
    eventDispatcher:addEventListener("airship.props.refresh", self.propsRefreshListener)
    
    self:refreshStrengthLb()
end

function airShipDialog:showMiddle()
    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
    local middleBgHeight = 300
    middleBg:setContentSize(CCSizeMake(self.dialogWidth, middleBgHeight))
    middleBg:setPosition(self.dialogWidth * 0.5, self.middleBgTopPosy)
    middleBg:setAnchorPoint(ccp(0.5, 1))
    middleBg:setOpacity(0)
    self.bgLayer:addChild(middleBg, 1)
    self.middleBgHeight = middleBgHeight
    self.middleBg = middleBg
    local partsBgHeight = 105
    local partsBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function() end)
    partsBg:setContentSize(CCSizeMake(self.dialogWidth - 20, partsBgHeight))
    partsBg:setAnchorPoint(ccp(0.5, 1))
    partsBg:setPosition(self.dialogWidth * 0.5, middleBgHeight - 15)
    middleBg:addChild(partsBg)
    self.partsBg = partsBg
    
    local function showPartsDataSmallPanel()
        local formatTotalPartsNum, hourOutPut, totalPartsNum = airShipVoApi:getTotalPartsNum()
        local needTb = {"airShipPartsTotal", formatTotalPartsNum, getlocal("airShip_warehoursHadPartsNum", {totalPartsNum}), getlocal("airShip_hourOutPutNum", {hourOutPut}), getlocal("airShip_buildGradeToOutPut")}
        G_showCustomizeSmallDialog(self.layerNum + 1, needTb)
    end
    local partsSpUseHeight = 80
    local partsSp = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", showPartsDataSmallPanel)
    partsSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    partsSp:setAnchorPoint(ccp(0, 0.5))
    partsSp:setPosition(10, partsBgHeight * 0.5)
    partsSp:setScale(partsSpUseHeight / partsSp:getContentSize().height)
    partsBg:addChild(partsSp)
    local materialSp = CCSprite:createWithSpriteFrameName("airship_cl.png")
    materialSp:setScale((partsSp:getContentSize().width - 6) / materialSp:getContentSize().width)
    materialSp:setPosition(getCenterPoint(partsSp))
    partsSp:addChild(materialSp)
    
    local totalPartsNumLb = GetTTFLabel(airShipVoApi:getTotalPartsNum(), 18)
    totalPartsNumLb:setAnchorPoint(ccp(1, 0))
    totalPartsNumLb:setPosition(partsSp:getContentSize().width - 3, 3)
    if totalPartsNumLb:getContentSize().width > partsSpUseHeight then
        totalPartsNumLb:setScale(partsSpUseHeight / totalPartsNumLb)
    end
    partsSp:addChild(totalPartsNumLb, 2)
    self.totalPartsNumLb = totalPartsNumLb
    
    local partsTipLb = GetTTFLabelWrap(getlocal("airShip_partsGetWithTip"), G_isAsia() and 22 or 18, CCSizeMake(436, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)--"Helvetica-bold"
    partsTipLb:setAnchorPoint(ccp(0.5, 1))
    partsTipLb:setPosition(partsBg:getContentSize().width * 0.5, partsBgHeight - 20)
    partsBg:addChild(partsTipLb)
    
    local per, curUnGetParts, manxUnGetParts = airShipVoApi:getCurUnGetPartsAnyData("progress")
    local percentStr = curUnGetParts.."/"..manxUnGetParts
    AddProgramTimer(partsBg, ccp(partsBg:getContentSize().width * 0.5 + 10, partsBgHeight * 0.38), 11, 12, percentStr, "platWarProgressBg.png", "taskBlueBar.png", 13, 1, 1)
    local progressSp = partsBg:getChildByTag(11)
    progressSp = tolua.cast(progressSp, "CCProgressTimer")
    progressSp:setPercentage(per)
    self.progressSp = progressSp
    local progressBgSp = partsBg:getChildByTag(13)
    progressBgSp = tolua.cast(progressBgSp, "CCSprite")
    local scalex = 420 / progressSp:getContentSize().width
    progressBgSp:setScaleX(scalex)
    progressSp:setScaleX(scalex)
    percentStrLb = tolua.cast(progressSp:getChildByTag(12), "CCLabelTTF")
    self.percentStrLb = percentStrLb
    
    self.getPartsBtnPos = ccp(partsBg:getContentSize().width - 40, partsBgHeight * 0.5)
    local function getPartsHandle(tag, object)
        local per, curUnGetParts, manxUnGetParts = airShipVoApi:getCurUnGetPartsAnyData("progress")
        if curUnGetParts < 1 then--per < 1 then
            G_showTipsDialog(getlocal("airShip_nooutput"))
            do return end
        end
        local function refreshHandle()
            self.airshipTipTb[3] = false
            self:refresh("parts")
            self:refresh("lottery", {rType = 1})
            G_showTipsDialog(getlocal("airShip_getPartsSucess"))
            
            self:refreshGetPartsTip(2) --刷新提示
            
            if otherGuideMgr.isGuiding == true and otherGuideMgr.curStep == 92 then
                otherGuideMgr:toNextStep()
            end
        end
        airShipVoApi:socketGetParts(refreshHandle)
    end
    local btnScale, priority = 1, -(self.layerNum - 1) * 20 - 3
    local lotteryBtn = G_createBotton(partsBg, self.getPartsBtnPos, nil, "arpl_yellowGetBtn1.png", "arpl_yellowGetBtn2.png", "arpl_yellowGetBtn2.png", getPartsHandle, btnScale, priority, nil)
    self.lotteryBtn = lotteryBtn
    
    local per, curUnGetParts, manxUnGetParts = airShipVoApi:getCurUnGetPartsAnyData("progress")
    self:refreshGetPartsTip(curUnGetParts >= manxUnGetParts and 1 or 2)
        
    sNum = airShipVoApi:getMyPhoneType( ) == 1 and 0.43 or 0.35

    local nbAwardTipBg = LuaCCScale9Sprite:createWithSpriteFrameName("arpl_panelBg.png", CCRect(32, 25, 2, 2), function() end)
    nbAwardTipBg:setContentSize(CCSizeMake(450, 50))
    nbAwardTipBg:setPosition(self.dialogWidth * 0.5, middleBgHeight * sNum)
    middleBg:addChild(nbAwardTipBg)
    self.nbAwardTipBg = nbAwardTipBg
    
    local function getBigAwardHandle()
        local function refreshAnyDataAboutBigAward(reward)
            self:refresh("parts")
            require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
            rewardShowSmallDialog:showNewReward(self.layerNum + 1, true, true, reward, nil, getlocal("award"))
        end
        airShipVoApi:socketGetSpecial(refreshAnyDataAboutBigAward)
    end
    local useWidth = 70
    local bigAwardSp = LuaCCSprite:createWithSpriteFrameName("airship_sreward.png", getBigAwardHandle)
    bigAwardSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    bigAwardSp:setPosition(self.dialogWidth - 50, middleBgHeight * sNum)
    middleBg:addChild(bigAwardSp, 2)
    -- bigAwardSp:setScale(70 / bigAwardSp:getContentSize().width)
    self.bigAwardSp = bigAwardSp
    
    self:showLastRwardIndex()
    
    if airShipVoApi:getMyPhoneType( ) > 1 then
        local addline = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
        addline:setContentSize(CCSizeMake(self.dialogWidth, addline:getContentSize().height))
        addline:setPosition(self.dialogWidth * 0.5, 35)
        middleBg:addChild(addline)
    end
    
    --系统规则说明
    local function touchTip()
        local airShipCfg = airShipVoApi:getAirShipCfg()
        local textTb, textFormatTb = {}, {}
        --当前飞艇总强度显示
        table.insert(textTb, getlocal("airShip_totalStrength", {airShipVoApi:getTotalStrength()}))
        table.insert(textFormatTb, {richFlag = true, richColor = {nil, G_ColorYellowPro, nil}})
        for k = 1, 14 do
            local color, args
            if k == 1 or k == 3 or k == 6 or k == 11 or k == 14 then
                color = {nil, G_ColorGreen, nil, G_ColorGreen, nil}
                if k == 14 then
                    args = {airShipCfg.gNum}
                end
            elseif k == 2 or k == 8 then
                color = {nil, G_ColorGreen, nil}
            elseif k == 4 then
                color = {nil, G_ColorGreen, nil, G_ColorGreen, nil, G_ColorGreen, nil, G_ColorGreen, nil, G_ColorGreen, nil}
            elseif k == 7 then
            elseif k == 9 or k == 10 then
                color = {nil, G_ColorGreen, nil, G_ColorGreen, nil, G_ColorGreen, nil, G_ColorGreen, nil}
            end
            table.insert(textTb, getlocal("airShip_rule"..k, args))
            table.insert(textFormatTb, {richFlag = (color ~= nil and true or false), richColor = color})
            if k == 7 then
                local maxbf = SizeOfTable(airShipCfg.asNum)
                for gn = 1, maxbf do
                    local str = "  "..getlocal("emblem_troop_totalStrength") .. "<rayimg>"..airShipCfg.asNum[gn] .. "<rayimg>->"..getlocal("airShip_maxbf_str") .. "<rayimg>"..gn.."<rayimg>"
                    table.insert(textTb, str)
                    table.insert(textFormatTb, {richFlag = true, richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}})
                end
            end
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, textTb, nil, nil, textFormatTb)
    end
    G_addMenuInfo(middleBg, self.layerNum, ccp(50, nbAwardTipBg:getPositionY()), {}, nil, nil, 28, touchTip, true)
end
function airShipDialog:showLastRwardIndex()
    if self.middleBg and self.nbAwardTipBg then
        if self.lastRewardTipLb then
            self.lastRewardTipLb:removeFromParentAndCleanup(true)
            self.lastRewardTipLb = nil
        end
        if self.nbAwardTipLb then
            self.nbAwardTipLb:removeFromParentAndCleanup(true)
            self.nbAwardTipLb = nil
        end
        
        local lastRewardTipLb, lbHeight = G_getRichTextLabel(getlocal("airShip_lotteryNumTip", {airShipVoApi:getLastRewardNum()}), {G_ColorGray, G_ColorYellowPro2, G_ColorGray}, G_isAsia() and 18 or 16, 400, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        lastRewardTipLb:setAnchorPoint(ccp(0.5, 1))
        lastRewardTipLb:setPosition(self.nbAwardTipBg:getContentSize().width * 0.5, -10)
        self.lastRewardTipLb = lastRewardTipLb
        self.nbAwardTipBg:addChild(lastRewardTipLb)
        
        local specialNum = airShipVoApi:getAnyDataWithCfg("specialNum")
        if self.specialNumLb then
            self.specialNumLb:setString(specialNum)
        else
            local specialNumLb = GetTTFLabel(specialNum, 19)
            specialNumLb:setAnchorPoint(ccp(0.5, 1))
            specialNumLb:setPosition(self.dialogWidth - 50, self.middleBgHeight * 0.22)
            specialNumLb:setColor(G_ColorGreen)
            self.specialNumLb = specialNumLb
            self.middleBg:addChild(specialNumLb)
        end
        if self.specialNumLb and specialNum == 0 then
            self.specialNumLb:setColor(G_ColorWhite)
        end
        
        local nbAwardTipLb, lbHeight = G_getRichTextLabel(getlocal("airShip_nbAwardTipStr", {airShipVoApi:getLastNumWithGetPurpleEquip()}), {G_ColorWhite, G_ColorYellow, G_ColorWhite, G_ColorPurple, G_ColorWhite}, G_isAsia() and 18 or 15, 420, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        nbAwardTipLb:setAnchorPoint(ccp(0.5, 1))
        nbAwardTipLb:setPosition(self.nbAwardTipBg:getContentSize().width * 0.5, self.nbAwardTipBg:getContentSize().height * 0.5 + 10)
        self.nbAwardTipBg:addChild(nbAwardTipLb)
        self.nbAwardTipLb = nbAwardTipLb
        
        if self.bigAwardSp then
            if specialNum > 0 then
                if self.bigAwardBg == nil then
                    local bigAwardBg = CCNode:create()
                    bigAwardBg:setContentSize(CCSizeMake(self.bigAwardSp:getContentSize().width, self.bigAwardSp:getContentSize().height))
                    bigAwardBg:setPosition(self.bigAwardSp:getPosition())
                    bigAwardBg:setAnchorPoint(ccp(0.5, 0.5))
                    self.middleBg:addChild(bigAwardBg)
                    self.bigAwardBg = bigAwardBg
                    for k = 1, 2 do
                        local lightSp = CCSprite:createWithSpriteFrameName("equipShine.png")
                        lightSp:setAnchorPoint(ccp(0.5, 0.5))
                        lightSp:setScale(0.8)
                        lightSp:setPosition(getCenterPoint(self.bigAwardBg))
                        self.bigAwardBg:addChild(lightSp)
                        local ry = k == 1 and 360 or - 360
                        lightSp:runAction(CCRepeatForever:create(CCRotateBy:create(4, ry)))
                    end
                end
            else
                if self.bigAwardBg then
                    self.bigAwardBg:removeFromParentAndCleanup(true)
                    self.bigAwardBg = nil
                end
            end
        end
    end
end
--原料数据相关ui的刷新
function airShipDialog:refreshPartsDataWithSp()
    if self.totalPartsNumLb then
        local num = airShipVoApi:getTotalPartsNum()
        self.totalPartsNumLb:setString(num)
        if self.totalPartsNumLb:getContentSize().width > 80 then
            self.totalPartsNumLb:setScale(80 / self.totalPartsNumLb)
        end
    end
    self:showLastRwardIndex()
    
    if self.progressSp and self.percentStrLb then
        local per, curUnGetParts, manxUnGetParts = airShipVoApi:getCurUnGetPartsAnyData("progress")
        self.progressSp:setPercentage(per)
        self.percentStrLb:setString(curUnGetParts.."/"..manxUnGetParts)
    end
end

--抽零件的按钮
function airShipDialog:showLotteryBtn()
    local posxTb = {0.23, 0.77}
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 3
    
    local function lotteryHandle(tag, object) --加价
        
        local function refreshHandle(reward)
            local function showAnimateHandl()
                self:refresh("lottery", {rType = tag})
                self:refresh("parts")
                G_showTipsDialog(getlocal("airShip_device1_1")..getlocal("success_str"))
                G_showRewardTip(reward)
            end
            self:showLotteryAnimate(showAnimateHandl)
        end
        airShipVoApi:lotteryClickBtn(refreshHandle, tag, self.layerNum + 1)
    end
    
    local btnPosy = airShipVoApi:getMyPhoneType( ) == 1 and 45 or 120

    for rType = 1, 2 do
        local lotteryBtn = G_createBotton(self.bgLayer, ccp(self.dialogWidth * posxTb[rType], btnPosy), {getlocal("airShip_lotteryBtn", {airShipVoApi:getLotteryNum(rType)}), G_isAsia() and 24 or 20}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", lotteryHandle, btnScale, priority, nil, rType)
        self.lotteryBtnTb[rType] = lotteryBtn
        self:refreshLotteryUseNum(rType)
    end
end

function airShipDialog:refreshLotteryUseNum(rType)
    if rType == 1 and self.lotteryBtnTb[rType] then
        if self.singleLotteryShowBg then
            self.singleLotteryShowBg:removeFromParentAndCleanup(true)
            self.singleLotteryShowBg = nil
        end
        
        lotteryShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
        lotteryShowBg:setContentSize(CCSizeMake(100, 40))
        lotteryShowBg:setAnchorPoint(ccp(0.5, 0))
        lotteryShowBg:setOpacity(0)
        lotteryShowBg:setPosition(self.lotteryBtnTb[rType]:getContentSize().width * 0.5, self.lotteryBtnTb[rType]:getContentSize().height + 5)
        self.lotteryBtnTb[rType]:addChild(lotteryShowBg)
        self.singleLotteryShowBg = lotteryShowBg
        
        local canLottery, canUseParts, canUseGems, useNum, hasNum = airShipVoApi:getCurDayIsCanLottery(rType)
        
        local iconStr = canUseParts and "Icon_BG.png" or "IconGold.png"
        
        local numLb = GetTTFLabel(useNum, 25)
        numLb:setAnchorPoint(ccp(1, 0.5))
        numLb:setPosition(getCenterPoint(lotteryShowBg))
        
        if not canUseParts and not canUseGems then
            numLb:setColor(G_ColorRed)
        end
        
        if canUseParts == true then
            iconSp = CCSprite:createWithSpriteFrameName("Icon_BG.png")
            local sp = CCSprite:createWithSpriteFrameName("airship_cl.png")
            sp:setPosition(getCenterPoint(iconSp))
            sp:setScale((iconSp:getContentSize().width - 6) / sp:getContentSize().width)
            iconSp:addChild(sp)
            iconSp:setScale(40 / iconSp:getContentSize().height)
        else
            iconSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        end
        iconSp:setAnchorPoint(ccp(0, 0.5))
        iconSp:setPosition(getCenterPoint(lotteryShowBg))
        iconSp:setPositionX(iconSp:getPositionX() + 5)
        
        lotteryShowBg:addChild(numLb)
        lotteryShowBg:addChild(iconSp)
    elseif rType == 2 then
        if self.multiLotteryShowBg then
            do return end
        end
        lotteryShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
        lotteryShowBg:setContentSize(CCSizeMake(100, 40))
        lotteryShowBg:setAnchorPoint(ccp(0.5, 0))
        lotteryShowBg:setOpacity(0)
        lotteryShowBg:setPosition(self.lotteryBtnTb[rType]:getContentSize().width * 0.5, self.lotteryBtnTb[rType]:getContentSize().height + 5)
        self.lotteryBtnTb[rType]:addChild(lotteryShowBg)
        self.multiLotteryShowBg = lotteryShowBg
        
        local canLottery, canUseParts, canUseGems, useNum, hasNum = airShipVoApi:getCurDayIsCanLottery(rType)
        
        local numLb = GetTTFLabel(useNum, 25)
        numLb:setAnchorPoint(ccp(1, 0.5))
        numLb:setPosition(getCenterPoint(lotteryShowBg))
        
        if not canUseGems then
            numLb:setColor(G_ColorRed)
        end
        
        local iconSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        iconSp:setAnchorPoint(ccp(0, 0.5))
        iconSp:setPosition(getCenterPoint(lotteryShowBg))
        iconSp:setPositionX(iconSp:getPositionX() + 5)
        iconSp:setScale(numLb:getContentSize().height / iconSp:getContentSize().height)
        
        lotteryShowBg:addChild(numLb)
        lotteryShowBg:addChild(iconSp)
    end
end

function airShipDialog:initUpBg()
    self.upBgHeight = 552--webImage 的 高度
    self.upBgWidth = self.dialogWidth
    self.middleBgTopPosy = 504--self.realHeight - webImage:getContentSize().height
    if G_getIphoneType() == G_iphoneX then
        self.upBgHeight = 670
    end
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local function onLoadIcon(fn, icon)
        if self and self.bgLayer and tolua.cast(self.bgLayer, "LuaCCScale9Sprite") then
            icon:setAnchorPoint(ccp(0.5, 1))
            icon:setPosition(ccp(self.dialogWidth * 0.5, self.realHeight))
            icon:setScale(self.upBgHeight / icon:getContentSize().height)
            self.bgLayer:addChild(icon)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("airShip/arpl_cloudBg.jpg"), onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    if airShipVoApi:getMyPhoneType( ) == 1 then
        self.middleBgTopPosy = self.realHeight - webImage:getContentSize().height + 10
    end

    local upBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
    upBgSp:setContentSize(CCSizeMake(self.upBgWidth, self.upBgHeight))
    upBgSp:setOpacity(0)
    upBgSp:setAnchorPoint(ccp(0.5, 1))
    upBgSp:setPosition(ccp(self.dialogWidth * 0.5, self.realHeight))
    self.bgLayer:addChild(upBgSp, 2)
    self.upBgSp = upBgSp
    
    --添加裁剪区域
    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(self.upBgSp:getContentSize().width, self.upBgSp:getContentSize().height))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(self.upBgSp:getPosition())
    local stencil = CCDrawNode:getAPolygon(CCSizeMake(self.upBgSp:getContentSize().width, self.upBgSp:getContentSize().height), 1, 1)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper, 1)
    self.clipperAreaSp = clipper
    
    self:initAnyDisplayAndEntry()
end

function airShipDialog:initAnyDisplayAndEntry()
    self:initAnyEntry()--仓库 排名 奖励库 入口
    self:refreshTodayUpType()
    self:initBuildingUpGradeEntry()
    self:initOrRefreshAirShipEntry(true)
end
--飞艇入口
function airShipDialog:initOrRefreshAirShipEntry(firstIn)
    if self.airShipEntrySp then
        self.airShipEntrySp:stopAllActions()
        self.airShipEntrySp:removeFromParentAndCleanup(true)
        self.airShipEntrySp = nil
    end
    local targetPos, targetScale = ccp(self.upBgWidth * 0.5 - 10, self.upBgHeight * 0.5 - 10), 0.9
    local function intoAirShipHandle()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.firstIn == true then
            do return end
        end
        airShipVoApi:gotoOtherpanel(self.layerNum + 1, 4, self)
        if otherGuideMgr.isGuiding == true and otherGuideMgr.curStep == 94 then
            otherGuideMgr:toNextStep()
        end
    end
    local airShipEntrySp = G_showAirShip(self.curAirShipId, nil, nil, true, intoAirShipHandle) --LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",intoAirShipHandle)--------------------------
    airShipEntrySp:setScale(targetScale)
    airShipEntrySp:setPosition(targetPos)
    airShipEntrySp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.airShipEntrySp = airShipEntrySp
    self.clipperAreaSp:addChild(airShipEntrySp, 1)
    
    local function playFloat()
        local movBy1 = CCMoveBy:create(1.5, ccp(0, 5))
        local movBy2 = movBy1:reverse()
        local movArr = CCArray:create()
        movArr:addObject(movBy1)
        movArr:addObject(movBy2)
        local movSeq = CCSequence:create(movArr)
        local movRepeat = CCRepeatForever:create(movSeq)
        airShipEntrySp:runAction(movRepeat)
        
        self:refreshAirShipTip() --飞艇进场后显示箭头特效提示效果
        
        if otherGuideMgr.isGuiding == true then
            otherGuideMgr:setGuideStepField(94, self.airShipEntrySp, false, nil, {panlePos = ccp(10, G_VisibleSizeHeight - self.upBgHeight - 300)})
        end
        
        self.firstIn = false
    end
    if firstIn == true then --第一次打开需要有进场动画
        self.firstIn = firstIn
        local moveDis, mt, opy = 200, 0.5, 255 * 0.5
        airShipEntrySp:setScale(0.5)
        G_playSpriteTint(airShipEntrySp, mt, ccc3(opy, opy, opy), false, true)
        airShipEntrySp:setPosition(targetPos.x + math.cos(math.rad(45)) * moveDis, targetPos.y - math.sin(math.rad(45)) * moveDis)
        airShipEntrySp:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(function ()
            local arr = CCArray:create()
            arr:addObject(CCEaseBackOut:create(CCScaleTo:create(mt, targetScale)))
            arr:addObject(CCEaseBackOut:create(CCMoveTo:create(mt, targetPos)))
            local spawn = CCSpawn:create(arr)
            airShipEntrySp:runAction(CCSequence:createWithTwoActions(spawn, CCCallFunc:create(function ()
                playFloat()
            end)))
            G_playSpriteTint(airShipEntrySp, mt, ccc3(255, 255, 255), true, true)
        end)))
    else
        playFloat()
    end
end
--建筑升级入口
function airShipDialog:initBuildingUpGradeEntry()
    local buildingLvBg = CCSprite:createWithSpriteFrameName("greenGradientBarBg.png")
    buildingLvBg:setAnchorPoint(ccp(0, 1))
    buildingLvBg:setPosition(5, self.upBgHeight - 5)
    self.upBgSp:addChild(buildingLvBg)
    -- 190 buildingLvBg.width ; 30 buildingLvBg.height
    self.curbuildingLvStr = airShipVoApi:getBuildingLevel()
    local buildingLvLb = GetTTFLabelWrap(getlocal("airShip_CurBuildingLv", {self.curbuildingLvStr}), 23, CCSizeMake(190 - 15, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)--,"Helvetica-bold")
    buildingLvLb:setAnchorPoint(ccp(0, 0.5))
    buildingLvLb:setPosition(14, 15)
    buildingLvBg:addChild(buildingLvLb)
    self.buildingLvLb = buildingLvLb
    
    local scale = 0.9
    local function greatCallback()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        G_touchedItem(self.buildBtn, function ()
            airShipVoApi:greatUpGradeDialog(self.layerNum + 1)
        end, 0.8)
    end
    local buildBtn = LuaCCSprite:createWithSpriteFrameName("airShip_smallPic.png", greatCallback)
    buildBtn:setPosition(ccp(10 + buildBtn:getContentSize().width * scale * 0.5, self.upBgHeight + buildBtn:getContentSize().height * scale * 0.5 - 120))
    buildBtn:setScale(scale)
    buildBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.upBgSp:addChild(buildBtn)
    self.buildBtn = buildBtn
end
function airShipDialog:initAnyEntry()
    local posX, maxWidth = G_VisibleSizeWidth, 0
    local picTb = {"airship_warhouse.png", "airship_rank.png"}
    for k = 1, 2 do
        local entryBtn
        local function entryHandl(object, fn, tag)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            G_touchedItem(entryBtn, function ()
                -- 1 :仓库  2:排名  3:抽奖奖励库
                airShipVoApi:gotoOtherpanel(self.layerNum + 1, tag)
            end)
        end
        entryBtn = LuaCCSprite:createWithSpriteFrameName(picTb[k], entryHandl)
        entryBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        entryBtn:setTag(k)
        self.upBgSp:addChild(entryBtn)
        local btnLb = GetTTFLabel(getlocal("airShip_entryStr"..k), G_getLS(20, 18), true)
        btnLb:setAnchorPoint(ccp(0.5, 0))
        self.upBgSp:addChild(btnLb)
        maxWidth = (entryBtn:getContentSize().width > btnLb:getContentSize().width) and entryBtn:getContentSize().width or btnLb:getContentSize().width
        entryBtn:setPosition(posX - maxWidth / 2 - 10, btnLb:getContentSize().height + 10 + entryBtn:getContentSize().height / 2)
        btnLb:setPosition(entryBtn:getPositionX(), 5)
        posX = posX - maxWidth - 10
    end
    local propCheckSp
    local function entryHandl(object, fn, tag)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        G_touchedItem(propCheckSp, function ()
            -- 1 :仓库  2:排名  3:抽奖奖励库
            airShipVoApi:gotoOtherpanel(self.layerNum + 1, tag)
        end)
    end
    propCheckSp = LuaCCSprite:createWithSpriteFrameName("airship_check.png", entryHandl)
    propCheckSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    propCheckSp:setTag(3)
    propCheckSp:setPosition(G_VisibleSizeWidth - 155, 175)
    self.upBgSp:addChild(propCheckSp, 5)
    propCheckSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 0.8), CCScaleTo:create(0.5, 1))))
end
---概率Up 夸天刷新 直接调这里就可以
function airShipDialog:refreshTodayUpType()
    if not self.upBgSp then
        do return end
    end
    
    if self.upTypeTb then
        for k, v in pairs(self.upTypeTb) do
            self.upTypeTb[k]:removeFromParentAndCleanup(true)
            self.upTypeTb[k] = nil
        end
    end
    self.upTypeTb = {}
    
    local upTypeDataTb = airShipVoApi:getLotteryUpType()
    local upShipName1, upShipName2 = upTypeDataTb[1] and getlocal("airShip_name_"..upTypeDataTb[1]) or "", upTypeDataTb[2] and getlocal("airShip_name_"..upTypeDataTb[2]) or ""
    
    local anyUpShipStr = ""
    if upShipName1 ~= "" and upShipName2 ~= "" then
        anyUpShipStr = upShipName1..","..upShipName2
    else
        anyUpShipStr = upShipName1 ~= "" and upShipName1 or upShipName2
    end
    
    local iconWidth = 110
    for k, v in pairs(upTypeDataTb) do
        local upTypeIconSp = LuaCCSprite:createWithSpriteFrameName("airShipUpTip_"..v..".png", function ()
            G_showTipsDialog(getlocal("airShip_todayUpAdd", {anyUpShipStr}))
        end)
        upTypeIconSp:setScale(iconWidth / upTypeIconSp:getContentSize().width)
        upTypeIconSp:setPosition(0.5 * iconWidth + (k - 1) * (iconWidth - 20), upTypeIconSp:getContentSize().height * upTypeIconSp:getScale() * 0.5)
        upTypeIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        self.upBgSp:addChild(upTypeIconSp)
        self.upTypeTb[k] = upTypeIconSp
        local upSp = CCSprite:createWithSpriteFrameName("airship_dailyup.png")
        upSp:setPosition(upSp:getContentSize().width / 2, upTypeIconSp:getContentSize().height - upSp:getContentSize().height / 2)
        upTypeIconSp:addChild(upSp)
        upSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 10)), CCMoveBy:create(0.5, ccp(0, -10)))))
    end
end

--刷新总强度
function airShipDialog:refreshStrengthLb()
    -- if self.strengthBg and self.strengthLb then
    --     self.strengthBg:removeFromParentAndCleanup(true)
    --     self.strengthBg = nil
    --     self.strengthLb:removeFromParentAndCleanup(true)
    --     self.strengthLb = nil
    -- end
    -- local strengthStr = getlocal("airShip_totalStrength", {airShipVoApi:getTotalStrength()})
    -- local strLb = GetTTFLabel(strengthStr, 22)
    -- local strengthBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
    -- strengthBg:setScaleX((strLb:getContentSize().width + 40) / strengthBg:getContentSize().width)
    -- strengthBg:setScaleY((strLb:getContentSize().height + 10) / strengthBg:getContentSize().height)
    -- strengthBg:setPosition(self.upBgSp:getContentSize().width / 2, self.upBgSp:getContentSize().height - 100)
    -- self.upBgSp:addChild(strengthBg, 10)
    -- local strengthLb, height = G_getRichTextLabel(strengthStr, {G_ColorYellowPro, G_ColorGreen, G_ColorYellowPro}, 22, G_VisibleSizeWidth - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    -- strengthLb:setAnchorPoint(ccp(0.5, 1))
    -- strengthLb:setPosition(strengthBg:getPositionX(), strengthBg:getPositionY() + height / 2)
    -- self.upBgSp:addChild(strengthLb, 10)
    -- self.strengthBg, self.strengthLb = strengthBg, strengthLb
end

function airShipDialog:tick()
    if not self or not airShipVoApi:isOpen() then
        do return end
    end
    -- if base.serverTime % 60 == 0 then
    if self.progressSp and self.percentStrLb then
        local per, curUnGetParts, manxUnGetParts = airShipVoApi:getCurUnGetPartsAnyData("progress")
        -- print("~~~per===>", per)
        self.progressSp:setPercentage(per)
        self.percentStrLb:setString(curUnGetParts.."/"..manxUnGetParts)
        self:refreshGetPartsTip(curUnGetParts >= manxUnGetParts and 1 or 2)
    end
    -- end
    if self.buildingLvLb and self.curbuildingLvStr ~= airShipVoApi:getBuildingLevel() then
        self.curbuildingLvStr = airShipVoApi:getBuildingLevel()
        self.buildingLvLb:setString(getlocal("airShip_CurBuildingLv", {self.curbuildingLvStr}))
    end
    if self.buildBtn and tolua.cast(self.buildBtn, "CCSprite") then
        local curLv = airShipVoApi:getBuildingLevel()
        local maxLv = buildingVoApi:canUpgradeMaxLevel(18)
        --检测建筑是否可以升级
        if curLv < maxLv and buildingVoApi:checkUpgradeRequire(52, 18) == true then
            if self.upArrowSp == nil or tolua.cast(self.upArrowSp, "CCSprite") == nil then
                --升级箭头
                local upArrowSp = CCSprite:createWithSpriteFrameName("airship_buildup.png")
                upArrowSp:setAnchorPoint(ccp(0, 0.5))
                upArrowSp:setPosition(self.buildBtn:getPositionX() - self.buildBtn:getContentSize().width / 2, self.buildBtn:getPositionY() - self.buildBtn:getContentSize().height / 2 + upArrowSp:getContentSize().height / 2)
                self.upBgSp:addChild(upArrowSp, 2)
                self.upArrowSp = upArrowSp
                self.upArrowSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 10)), CCMoveBy:create(0.5, ccp(0, -10)))))
            end
        else
            if self.upArrowSp and tolua.cast(self.upArrowSp, "CCSprite") then
                self.upArrowSp:removeFromParentAndCleanup(true)
                self.upArrowSp = nil
            end
        end
    end
    if self.curAirShipId ~= airShipVoApi:getCurShowAirShip() then
        self.curAirShipId = airShipVoApi:getCurShowAirShip()
        self:initOrRefreshAirShipEntry()
    end
end

--跨天事件处理
function airShipDialog:overDayEvent()
    if self == nil or self.bgLayer == nil and tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
        do return end
    end
    airShipVoApi:requestInit(function ()
        self:refresh("lottery")
        self:refreshTodayUpType()
        self:showLastRwardIndex()
    end)
end

function airShipDialog:closeCallBack()
    -- print("here????????")
    airShipDialog:refreshAirShipTip()
end

function airShipDialog:refreshAirShipTip()
    if self.upBgSp == nil then
        do return end
    end
    local flag = airShipVoApi:getTip(2) --是否有装置可以激活或改造
    if flag > 0 then
        if self.airShipTipSp and tolua.cast(self.airShipTipSp, "CCSprite") then
            do return end
        end
        local airShipTipSp = CCSprite:createWithSpriteFrameName("arpl_halo.png")
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        airShipTipSp:setBlendFunc(blendFunc)
        airShipTipSp:setAnchorPoint(ccp(0.5, 1))
        airShipTipSp:setPosition(self.upBgWidth * 0.5, self.upBgHeight * 0.5 - 50)
        self.airShipTipSp = airShipTipSp
        self.upBgSp:addChild(airShipTipSp, 1)
        
        --arpl_spinBg.png
        local arpl_spinBg = CCSprite:createWithSpriteFrameName("arpl_spinBg.png")
        -- local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
        -- blendFunc.src=GL_ONE
        -- blendFunc.dst=GL_ONE
        -- arpl_spinBg:setBlendFunc(blendFunc)
        arpl_spinBg:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(arpl_spinBg)
        local spinRotateTo = CCRotateBy:create(10, 360)
        local repeatSpinRotateTo = CCRepeatForever:create(spinRotateTo)
        arpl_spinBg:runAction(repeatSpinRotateTo)
        
        local arpl_yellowArrow = CCSprite:createWithSpriteFrameName("arpl_yellowArrow.png")
        -- local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
        -- blendFunc.src=GL_ONE
        -- blendFunc.dst=GL_ONE
        -- arpl_yellowArrow:setBlendFunc(blendFunc)
        arpl_yellowArrow:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(arpl_yellowArrow)
        
        local airShipTipSp2 = CCSprite:createWithSpriteFrameName("arpl_up1.png")
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        airShipTipSp2:setBlendFunc(blendFunc)
        airShipTipSp2:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(airShipTipSp2)
        
        local pzArr = CCArray:create()
        for kk = 1, 14 do
            local nameStr = "arpl_up"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(animation)
        local repeatTipSp2 = CCRepeatForever:create(animate)
        airShipTipSp2:runAction(repeatTipSp2)
        
        local arpl_radiationHaloSp = CCSprite:createWithSpriteFrameName("arpl_radiationHalo.png")
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        arpl_radiationHaloSp:setBlendFunc(blendFunc)
        arpl_radiationHaloSp:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(arpl_radiationHaloSp)
        local RotateTo = CCRotateBy:create(10, -360)
        local repeatRotateTo = CCRepeatForever:create(RotateTo)
        arpl_radiationHaloSp:runAction(repeatRotateTo)
        
        local arpl_diffuseAuraSp1 = CCSprite:createWithSpriteFrameName("arpl_diffuseAura.png")
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        arpl_diffuseAuraSp1:setBlendFunc(blendFunc)
        arpl_diffuseAuraSp1:setOpacity(0)
        arpl_diffuseAuraSp1:setScale(0.64)
        arpl_diffuseAuraSp1:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(arpl_diffuseAuraSp1)
        
        local FadeArr = CCArray:create()
        local FadeIn = CCFadeIn:create(0.625)
        local FadeOut = CCFadeOut:create(0.625)
        local fadeDel1 = CCDelayTime:create(0.41)
        FadeArr:addObject(FadeIn)
        FadeArr:addObject(FadeOut)
        FadeArr:addObject(fadeDel1)
        
        local scaleArr = CCArray:create()
        local scaleOut = CCScaleTo:create(1.25, 1)
        local scalein = CCScaleTo:create(0, 0.64)
        local scaleDel1 = CCDelayTime:create(0.41)
        scaleArr:addObject(scaleOut)
        scaleArr:addObject(scalein)
        scaleArr:addObject(scaleDel1)
        
        local fadeSeq = CCSequence:create(FadeArr)
        local scalSeq = CCSequence:create(scaleArr)
        local sp1Arr = CCArray:create()
        sp1Arr:addObject(fadeSeq)
        sp1Arr:addObject(scalSeq)
        local sp1Spawn = CCSpawn:create(sp1Arr)
        local sp1Repeat = CCRepeatForever:create(sp1Spawn)
        arpl_diffuseAuraSp1:runAction(sp1Repeat)
        -----------
        local arpl_diffuseAuraSp2 = CCSprite:createWithSpriteFrameName("arpl_diffuseAura.png")
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        arpl_diffuseAuraSp2:setBlendFunc(blendFunc)
        arpl_diffuseAuraSp2:setOpacity(0)
        arpl_diffuseAuraSp2:setScale(0.64)
        arpl_diffuseAuraSp2:setPosition(getCenterPoint(airShipTipSp))
        airShipTipSp:addChild(arpl_diffuseAuraSp2)
        
        local function sp2Actionhandl()
            if arpl_diffuseAuraSp2 then
                local FadeArr2 = CCArray:create()
                local FadeIn2 = CCFadeIn:create(0.625)
                local FadeOut2 = CCFadeOut:create(0.625)
                local fadeDel22 = CCDelayTime:create(0.41)
                FadeArr2:addObject(FadeIn2)
                FadeArr2:addObject(FadeOut2)
                FadeArr2:addObject(fadeDel22)
                
                local scaleArr2 = CCArray:create()
                local scaleOut2 = CCScaleTo:create(1.25, 1)
                local scalein2 = CCScaleTo:create(0, 0.64)
                local scaleDel22 = CCDelayTime:create(0.41)
                scaleArr2:addObject(scaleOut2)
                scaleArr2:addObject(scalein2)
                scaleArr2:addObject(scaleDel22)
                
                local fadeSeq2 = CCSequence:create(FadeArr2)
                local scalSeq2 = CCSequence:create(scaleArr2)
                local sp2Arr = CCArray:create()
                sp2Arr:addObject(fadeSeq2)
                sp2Arr:addObject(scalSeq2)
                local sp2Spawn = CCSpawn:create(sp2Arr)
                local sp2Repeat = CCRepeatForever:create(sp2Spawn)
                
                arpl_diffuseAuraSp2:runAction(sp2Repeat)
            end
        end
        local sp2Func = CCCallFunc:create(sp2Actionhandl)
        local sp2Del = CCDelayTime:create(0.83)
        local sp2AcArr = CCArray:create()
        sp2AcArr:addObject(sp2Del)
        sp2AcArr:addObject(sp2Func)
        local sp2AcSeq = CCSequence:create(sp2AcArr)
        arpl_diffuseAuraSp2:runAction(sp2AcSeq)
        
        local movBy1 = CCMoveBy:create(1.5, ccp(0, 5))
        local movBy2 = movBy1:reverse()
        local movArr = CCArray:create()
        movArr:addObject(movBy1)
        movArr:addObject(movBy2)
        local movSeq = CCSequence:create(movArr)
        local movRepeat = CCRepeatForever:create(movSeq)
        airShipTipSp:runAction(movRepeat)
    else
        if self.airShipTipSp and tolua.cast(self.airShipTipSp, "CCSprite") then
            self.airShipTipSp:stopAllActions()
            self.airShipTipSp:removeFromParentAndCleanup(true)
            self.airShipTipSp = nil
        end
    end
end

--刷新原料生产库是否已满的效果
--rType：1显示，2：移除
function airShipDialog:refreshGetPartsTip(rType)
    if rType == 2 then
        if self.getPartsTipActionSp then
            self.getPartsTipActionSp:removeFromParentAndCleanup(true)
            self.getPartsTipActionSp = nil
        end
        do return end
    end
    if self.partsBg and self.getPartsBtnPos and rType == 1 then
        if self.getPartsTipActionSp then
            do return end
        end
        local getPartsTipActionSp = CCSprite:createWithSpriteFrameName("arpl_btnAc1.png")
        local pzArr = CCArray:create()
        for kk = 1, 15 do
            local nameStr = "arpl_btnAc"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate = CCAnimate:create(animation)
        local repeatForever1 = CCRepeatForever:create(animate)
        getPartsTipActionSp:runAction(repeatForever1)
        self.getPartsTipActionSp = getPartsTipActionSp
        getPartsTipActionSp:setPosition(self.getPartsBtnPos)
        self.partsBg:addChild(getPartsTipActionSp, 10)
    end
end

function airShipDialog:showLotteryAnimate(callback)
    if not self.clipperAreaSp or not self.airShipEntrySp then
        do return end
    end
    local shineBg = CCSprite:createWithSpriteFrameName("arpl_goldenBurst_1.png")--10
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    shineBg:setBlendFunc(blendFunc)
    
    shineBg:setScale((self.curAirShipId == 1 or self.curAirShipId == 7) and 2.5 or 2)
    shineBg:setOpacity(0)
    shineBg:setPosition(self.upBgWidth * 0.5, self.upBgHeight * 0.5 + 30)--self.airShipEntrySp:getPosition()) )
    self.clipperAreaSp:addChild(shineBg)
    local sArr = CCArray:create()
    for kk = 1, 10 do
        local nameStr = "arpl_goldenBurst_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        sArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(sArr)
    animation:setDelayPerUnit(0.04)
    local animate = CCAnimate:create(animation)
    local repeatAnimate = CCRepeat:create(animate, 2)
    
    local FadeIn = CCFadeIn:create(0.17)
    local det = CCDelayTime:create(0.6)
    local fadeOut = CCFadeOut:create(0.17)
    local function removeHandl()
        shineBg:removeFromParentAndCleanup(true)
        shineBg = nil
        if callback then
            callback()
        end
    end
    local removeCall = CCCallFunc:create(removeHandl)
    
    local s2Arr = CCArray:create()
    s2Arr:addObject(FadeIn)
    s2Arr:addObject(det)
    s2Arr:addObject(fadeOut)
    s2Arr:addObject(removeCall)
    local s2Seq = CCSequence:create(s2Arr)
    
    local s3Arr = CCArray:create()
    s3Arr:addObject(repeatAnimate)
    s3Arr:addObject(s2Seq)
    
    local spawn = CCSpawn:create(s3Arr)
    shineBg:runAction(spawn)
    
    -- 飞艇自己叠加自己，透明度动画：
    -- 0%-70% 0.27秒  70%-0% 0.23秒    0%-100% 0.16秒  100%维持0.16秒   100%-0% 0.33秒
    print("self.curAirShipId-=-====>>>>", self.curAirShipId)
    local airShipSp = CCSprite:createWithSpriteFrameName("arpl_ship"..self.curAirShipId.."_1.png")
    airShipSp:setPosition(getCenterPoint(self.airShipEntrySp))
    airShipSp:setOpacity(0)
    self.airShipEntrySp:addChild(airShipSp, 10)
    
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    airShipSp:setBlendFunc(blendFunc)
    
    local fade1 = CCFadeTo:create(0.27, 255 * 0.7)
    local fade2 = CCFadeTo:create(0.23, 0)
    local fade3 = CCFadeIn:create(0.16)
    local detAS = CCDelayTime:create(0.16)
    local fade4 = CCFadeOut:create(0.33)
    local function removeSelfHandl()
        airShipSp:removeFromParentAndCleanup(true)
        airShipSp = nil
    end
    local removeSelfCall = CCCallFunc:create(removeSelfHandl)
    local asArr = CCArray:create()
    asArr:addObject(fade1)
    asArr:addObject(fade2)
    asArr:addObject(fade3)
    asArr:addObject(detAS)
    asArr:addObject(fade4)
    asArr:addObject(removeSelfCall)
    local asSeq = CCSequence:create(asArr)
    airShipSp:runAction(asSeq)
    
    --arpl_yellowBurst1
    local yellowBurstSp = CCSprite:createWithSpriteFrameName("arpl_yellowBurst1.png")
    yellowBurstSp:setPosition(getCenterPoint(self.airShipEntrySp))
    yellowBurstSp:setVisible(false)
    yellowBurstSp:setScale(2.5)
    self.airShipEntrySp:addChild(yellowBurstSp, 10)
    
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    yellowBurstSp:setBlendFunc(blendFunc)
    
    local dets = CCDelayTime:create(0.73)
    local function showSelfHandl()
        yellowBurstSp:setVisible(true)
    end
    local showSelfCall = CCCallFunc:create(showSelfHandl)
    local scaleTo1 = CCScaleTo:create(0.133, 1)
    local scaleTo2 = CCScaleTo:create(0.233, 0)
    local function removesSelfHandl()
        yellowBurstSp:removeFromParentAndCleanup(true)
        yellowBurstSp = nil
    end
    local removesSelfCall = CCCallFunc:create(removesSelfHandl)
    local sArr = CCArray:create()
    sArr:addObject(dets)
    sArr:addObject(showSelfCall)
    sArr:addObject(scaleTo1)
    sArr:addObject(scaleTo2)
    sArr:addObject(removesSelfCall)
    local sSeq = CCSequence:create(sArr)
    yellowBurstSp:runAction(sSeq)
    
    --arpl_orgHalo.png
    local arpl_orgHalo = CCSprite:createWithSpriteFrameName("arpl_orgHalo.png")
    arpl_orgHalo:setPosition(getCenterPoint(self.airShipEntrySp))
    arpl_orgHalo:setVisible(false)
    arpl_orgHalo:setScale(4)
    self.airShipEntrySp:addChild(arpl_orgHalo, 10)
    
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    arpl_orgHalo:setBlendFunc(blendFunc)
    
    local deto = CCDelayTime:create(0.73)
    local function showSelfoHandl()
        arpl_orgHalo:setVisible(true)
    end
    local showSelfoCall = CCCallFunc:create(showSelfoHandl)
    local scaleToo1 = CCScaleTo:create(0.1, 3.1)
    local scaleToo2 = CCScaleTo:create(0.2, 3.4)
    local function removesSelfoHandl()
        arpl_orgHalo:removeFromParentAndCleanup(true)
        arpl_orgHalo = nil
    end
    local removesSelfoCall = CCCallFunc:create(removesSelfoHandl)
    local oArr = CCArray:create()
    oArr:addObject(deto)
    oArr:addObject(showSelfoCall)
    oArr:addObject(scaleToo1)
    oArr:addObject(scaleToo2)
    oArr:addObject(removesSelfoCall)
    local oSeq = CCSequence:create(oArr)
    
    local deto2 = CCDelayTime:create(0.83)
    local fadeOut2 = CCFadeOut:create(0.2)
    local oArr2 = CCArray:create()
    oArr2:addObject(deto2)
    oArr2:addObject(fadeOut2)
    local oSeq2 = CCSequence:create(oArr2)
    
    local oArr3 = CCArray:create()
    oArr3:addObject(oSeq)
    oArr3:addObject(oSeq2)
    local oSpawn = CCSpawn:create(oArr3)
    arpl_orgHalo:runAction(oSpawn)
    
    --arpl_orgDiffusionCircle
    for i = 1, 2 do
        local orgSp = CCSprite:createWithSpriteFrameName("arpl_orgDiffusionCircle.png")
        orgSp:setScale(2)
        orgSp:setVisible(false)
        orgSp:setPosition(getCenterPoint(self.airShipEntrySp))
        self.airShipEntrySp:addChild(orgSp, 10)
        
        local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        orgSp:setBlendFunc(blendFunc)
        
        local detor = CCDelayTime:create(0.73)
        local function showSelforHandl()
            orgSp:setVisible(true)
        end
        local showSelforCall = CCCallFunc:create(showSelforHandl)
        local scaleToor = CCScaleTo:create(0.1, 3.6)
        local function removesSelforHandl()
            orgSp:removeFromParentAndCleanup(true)
            orgSp = nil
        end
        local removesSelforCall = CCCallFunc:create(removesSelforHandl)
        local orArr = CCArray:create()
        orArr:addObject(detor)
        orArr:addObject(showSelforCall)
        orArr:addObject(scaleToor)
        orArr:addObject(removesSelforCall)
        local orSeq = CCSequence:create(orArr)
        
        local detor2 = CCDelayTime:create(0.73)
        local fadeOutor = CCFadeOut:create(0.1)
        local orArr2 = CCArray:create()
        orArr2:addObject(detor2)
        orArr2:addObject(fadeOutor)
        local orSeq2 = CCSequence:create(orArr2)
        
        local orArr3 = CCArray:create()
        orArr3:addObject(orSeq)
        orArr3:addObject(orSeq2)
        local orSpawn = CCSpawn:create(orArr3)
        orgSp:runAction(orSpawn)
    end
    
    local orgSp = CCSprite:createWithSpriteFrameName("arpl_orgDiffusionCircle.png")
    orgSp:setScale(2)
    orgSp:setVisible(false)
    orgSp:setPosition(getCenterPoint(self.airShipEntrySp))
    self.airShipEntrySp:addChild(orgSp, 10)
    
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    orgSp:setBlendFunc(blendFunc)
    
    local detor = CCDelayTime:create(0.73)
    local function showSelforHandl()
        orgSp:setVisible(true)
    end
    local showSelforCall = CCCallFunc:create(showSelforHandl)
    local scaleToor = CCScaleTo:create(0.23, 3.2)
    local orArr = CCArray:create()
    orArr:addObject(detor)
    orArr:addObject(showSelforCall)
    orArr:addObject(scaleToor)
    local orSeq = CCSequence:create(orArr)
    
    local detor2 = CCDelayTime:create(0.73)
    local fadeOutor = CCFadeOut:create(0.27)
    local function removesSelforHandl()
        orgSp:removeFromParentAndCleanup(true)
        orgSp = nil
    end
    local removesSelforCall = CCCallFunc:create(removesSelforHandl)
    local orArr2 = CCArray:create()
    orArr2:addObject(detor2)
    orArr2:addObject(fadeOutor)
    orArr2:addObject(removesSelforCall)
    local orSeq2 = CCSequence:create(orArr2)
    
    local orArr3 = CCArray:create()
    orArr3:addObject(orSeq)
    orArr3:addObject(orSeq2)
    local orSpawn = CCSpawn:create(orArr3)
    orgSp:runAction(orSpawn)
end
