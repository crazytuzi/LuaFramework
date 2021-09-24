--军团锦标赛赛季结算面板
championshipWarSettleDialog = smallDialog:new()

function championshipWarSettleDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function championshipWarSettleDialog:showSettlementDialog(layerNum)
    local sd = championshipWarSettleDialog:new()
    sd:initSettlementDialog(layerNum)
end

function championshipWarSettleDialog:initSettlementDialog(layerNum)
    self.isTouch = true
    self.isUseAmi = true
    self.layerNum = layerNum
    
    local warCfg = championshipWarVoApi:getWarCfg()
    local grade = championshipWarVoApi:getGrade() or 1 --当前阶位
    local lastGrade = championshipWarVoApi:getLastGrade() --历史阶位
    local rank = championshipWarVoApi:getRank() --本场战斗排行
    local minGrade, maxGrade = 1, warCfg.warGradeLevel
    
    local rewardSize = 80
    local dialogWidth, dialogHeight = G_VisibleSizeWidth - 90, 90 + rewardSize + 80 + 40 + 40
    local showNum, spaceY = 3, 40
    local showTb = {}
    if grade == minGrade or grade == maxGrade then
        showNum = 2
        if grade == minGrade then
            showTb = {grade + 1, grade}
        else
            showTb = {grade, grade - 1}
        end
    else
        showTb = {grade + 1, grade, grade - 1}
    end
    dialogHeight = dialogHeight + showNum * 74 + (showNum - 1) * spaceY
    
    local fontSize, smallFontSize = 22, 20
    local colorTb = {nil, G_ColorYellowPro, nil}
    local rankLb, rankLbheight = G_getRichTextLabel(getlocal("championshipWar_allianceRank", {rank}), colorTb, fontSize, dialogWidth - 80, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    
    local gradeStr, upgradeFlag = "", 0
    if tonumber(grade) > tonumber(lastGrade) then --升阶
        gradeStr = getlocal("championshipWar_upgrade_allianceGrade", {grade})
        colorTb = {nil, G_ColorYellowPro, nil}
        upgradeFlag = 1
    elseif tonumber(grade) == tonumber(lastGrade) then --无变化
        gradeStr = getlocal("championshipWar_nochange_allianceGrade")
        colorTb = {}
        upgradeFlag = 0
        
    else --降阶
        gradeStr = getlocal("championshipWar_decrease_allianceGrade", {grade})
        colorTb = {nil, G_ColorYellowPro, nil}
        upgradeFlag = -1
    end
    local gradeLb, gradeLbheight = G_getRichTextLabel(gradeStr, colorTb, fontSize, dialogWidth - 80, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    
    dialogHeight = dialogHeight + rankLbheight + gradeLbheight + 10
    
    local function close()
        self:close()
    end
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    local size = CCSizeMake(dialogWidth, dialogHeight)
    
    self.bgSize = size
    local dialogBg = G_getNewDialogBg(size, getlocal("championshipWar_warSettle"), 28, nil, layerNum, true, close)
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    self:show()
    
    rankLb:setAnchorPoint(ccp(0.5, 1))
    rankLb:setPosition(dialogWidth / 2, size.height - 80)
    self.bgLayer:addChild(rankLb)
    
    gradeLb:setAnchorPoint(ccp(0.5, 1))
    gradeLb:setPosition(dialogWidth / 2, rankLb:getPositionY() - rankLbheight - 10)
    self.bgLayer:addChild(gradeLb)
    
    local posY = gradeLb:getPositionY() - gradeLbheight - 40
    local showPic, changePic, angle, arrowPos, color
    for k, v in pairs(showTb) do
        if v == grade then
            showPic = "csi_titleBg2.png"
            color = G_ColorYellowPro
        else
            showPic = "csi_titleBg1.png"
            color = G_ColorGray2
        end
        local gradeBg = CCSprite:createWithSpriteFrameName(showPic)
        gradeBg:setPosition(dialogWidth / 2, posY - gradeBg:getContentSize().height / 2)
        self.bgLayer:addChild(gradeBg)
        local gradeLb = GetTTFLabelWrap("- " .. getlocal("championshipWar_grade", {v}) .. " -", smallFontSize, CCSizeMake(gradeBg:getContentSize().width - 80, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, nil, true)
        gradeLb:setColor(color)
        gradeLb:setPosition(gradeBg:getContentSize().width / 2, gradeBg:getContentSize().height / 2)
        gradeBg:addChild(gradeLb)
        
        if v == grade then
            local iconSp = CCSprite:createWithSpriteFrameName("csi_hexagonBg.png")
            iconSp:setScale(0.8)
            iconSp:setPosition(20, gradeBg:getContentSize().height / 2)
            gradeBg:addChild(iconSp)
            if upgradeFlag == 1 then
                changePic = "csi_arrowUp_yellow.png"
                arrowPos = ccp(dialogWidth / 2 + 160, gradeBg:getPositionY() - gradeBg:getContentSize().height / 2 - spaceY / 2)
            elseif upgradeFlag == -1 then
                changePic, angle = "csi_arrowUp_red.png", 180
                arrowPos = ccp(dialogWidth / 2 - 140, gradeBg:getPositionY() + gradeBg:getContentSize().height / 2 + spaceY / 2)
            else
                changePic = nil
            end
            if changePic then
                local arrowSp = CCSprite:createWithSpriteFrameName(changePic)
                arrowSp:setPosition(arrowPos)
                arrowSp:setRotation(angle or 0)
                self.bgLayer:addChild(arrowSp, 3)
            end
        end
        if k == showNum then
            posY = posY - gradeBg:getContentSize().height
            
        else
            posY = posY - gradeBg:getContentSize().height - spaceY
        end
    end
    
    posY = posY - 40
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
    mLine:setAnchorPoint(ccp(0.5, 0))
    mLine:setPosition(dialogWidth / 2, posY)
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 10, mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)
    
    local titleBg = G_createNewTitle({getlocal("EarnRewardStr"), fontSize}, CCSizeMake(300, 0))
    titleBg:setPosition(dialogWidth / 2, posY - 40)
    self.bgLayer:addChild(titleBg)
    
    local rewardSp = CCSprite:createWithSpriteFrameName("csi_coin.png")
    rewardSp:setScale(rewardSize / rewardSp:getContentSize().height)
    rewardSp:setAnchorPoint(ccp(0, 0.5))
    rewardSp:setPosition(40, posY - rewardSize / 2 - 60)
    self.bgLayer:addChild(rewardSp)
    
    local coin = championshipWarVoApi:getRankReward()
    local numLb = GetTTFLabel("x"..coin, 22)
    numLb:setAnchorPoint(ccp(0, 0))
    numLb:setPosition(ccp(rewardSp:getContentSize().width + 5, 0))
    rewardSp:addChild(numLb, 4)
    
    local function rewardHandler()
        if championshipWarVoApi:isRestBattle(true) == true then
            do return end
        end
        local function callback()
            self:close()
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("receivereward_received_success"), 30)
        end
        championshipWarVoApi:rankRewardRequest(callback) --领取结算奖励
    end
    local rewardBtn = G_createBotton(self.bgLayer, ccp(dialogWidth - 120, rewardSp:getPositionY()), {getlocal("activity_lxcz_reward"), 24}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", rewardHandler, 0.7, -(self.layerNum - 1) * 20 - 4)
    local flag, state = championshipWarVoApi:isCanReceiveAllianceWarReward()
    if flag ~= true then
        rewardBtn:setEnabled(false)
    end
    
    local function touchLuaSpr()
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    
    local function closeFunc()
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer, self.bgLayer, -(self.layerNum - 1) * 20 - 3, closeFunc)
    
    G_addArrowPrompt(self.bgLayer, nil, -70)
    
    self.dialogLayer:setPosition(ccp(0, 0))
end
