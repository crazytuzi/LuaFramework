--每五关的奖励页面
personalWarFiveStageRewardDialog = smallDialog:new()

function personalWarFiveStageRewardDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--autoFlag：每打无关自动弹出此页面，此时需要检测各个奖励是否已经领取的状态，其他情况无需检测
function personalWarFiveStageRewardDialog:showFiveStageRewardDialog(autoFlag, layerNum, closeFunc)
    local sd = personalWarFiveStageRewardDialog:new()
    sd:initFiveStageRewardDialog(autoFlag, layerNum, closeFunc)
end

function personalWarFiveStageRewardDialog:initFiveStageRewardDialog(autoFlag, layerNum, closeFunc)
    self.isTouch = false
    self.isUseAmi = true
    self.layerNum = layerNum
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    
    local function close()
        self:close()
        if closeFunc then
            closeFunc()
        end
    end
    self.bgSize = CCSizeMake(580, 700)
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("award"), 28, nil, layerNum, true, close)
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    self:show()
    
    local showPosY = self.bgSize.height - 60
    local warCfg = championshipWarVoApi:getWarCfg()
    
    local tipLb = GetTTFLabelWrap(getlocal("championshipWar_fivestage_reward", {warCfg.extraStageReward}), 22, CCSize(self.bgSize.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipLb:setPosition(self.bgSize.width / 2, showPosY - tipLb:getContentSize().height)
    self.bgLayer:addChild(tipLb)
    
    local cellNum = SizeOfTable(warCfg.fiveStageReward)
    local tvWidth, tvHeight = self.bgSize.width - 60, showPosY - 130 - tipLb:getContentSize().height - 10
    local iconWidth = 100
    local cellHeight = iconWidth + 32 + 30
    local fontWidth, titleFontSize, descFontSize = tvWidth - iconWidth - 60, 22, 20
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local fiveStageReward = warCfg.fiveStageReward
            local titleStr = ""
            if fiveStageReward[idx + 1] then
                local stageRewardCfg = fiveStageReward[idx + 1]
                if stageRewardCfg.starsNum then
                    titleStr = getlocal("championshipWar_fivestage_reward_title2", {warCfg.extraStageReward, stageRewardCfg.starsNum})
                else
                    titleStr = getlocal("championshipWar_fivestage_reward_title1", {warCfg.extraStageReward})
                end
                
                local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 0, 1, 32), function () end)
                titleBg:setContentSize(CCSizeMake(tvWidth, 32))
                titleBg:setAnchorPoint(ccp(0, 1))
                titleBg:setPosition(5, cellHeight)
                cell:addChild(titleBg)
                local titleLb = GetTTFLabelWrap(titleStr, titleFontSize, CCSizeMake(titleBg:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                titleLb:setAnchorPoint(ccp(0, 0.5))
                titleLb:setPosition(15, titleBg:getContentSize().height / 2)
                titleBg:addChild(titleLb)
                
                local rewardSp
                local nameStr, descStr
                if stageRewardCfg.buff then
                    rewardSp = CCSprite:createWithSpriteFrameName("tech_fight_exp_up.png")
                    descStr = getlocal("championshipWar_personal_propertyDesc3", {stageRewardCfg.buff * 100})
                else
                    local reward = FormatItem(stageRewardCfg.reward)[1]
                    rewardSp = G_getItemIcon(reward, 100, false, layerNum)
                    
                    local numLb = GetTTFLabel(FormatNumber(reward.num), descFontSize)
                    numLb:setAnchorPoint(ccp(1, 0))
                    numLb:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
                    rewardSp:addChild(numLb, 4)
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    numBg:setAnchorPoint(ccp(1, 0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 3))
                    numBg:setPosition(ccp(rewardSp:getContentSize().width - 5, 5))
                    numBg:setOpacity(150)
                    rewardSp:addChild(numBg, 3)
                    
                    nameStr = reward.name
                    descStr = G_getItemDesc(reward)
                end
                rewardSp:setScale(iconWidth / rewardSp:getContentSize().width)
                rewardSp:setAnchorPoint(ccp(0, 0.5))
                rewardSp:setPosition(20, 20 + iconWidth / 2)
                cell:addChild(rewardSp)
                
                if stageRewardCfg.buff then
                    local descLb, lbheight = G_getRichTextLabel(descStr, {G_ColorWhite, G_ColorGreen}, descFontSize, fontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(rewardSp:getPositionX() + iconWidth + 10, rewardSp:getPositionY() + iconWidth / 2 - 10)
                    cell:addChild(descLb)
                else
                    if nameStr and descStr then
                        local nameLb = GetTTFLabelWrap(nameStr, titleFontSize, CCSizeMake(fontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                        nameLb:setAnchorPoint(ccp(0, 1))
                        nameLb:setColor(G_ColorYellowPro)
                        nameLb:setPosition(rewardSp:getPositionX() + iconWidth + 10, rewardSp:getPositionY() + iconWidth / 2 - 10)
                        cell:addChild(nameLb)
                        
                        local descLb = GetTTFLabelWrap(descStr, descFontSize, CCSizeMake(fontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                        descLb:setAnchorPoint(ccp(0, 1))
                        descLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 20)
                        cell:addChild(descLb)
                    end
                end
                
                if autoFlag == true then
                    local checkpointId = championshipWarVoApi:getCurrentCheckpointId() - 1
                    if checkpointId > 0 and checkpointId % warCfg.extraStageReward == 0 then --判断奖励领取状态
                        local flag = true
                        local starNum = championshipWarVoApi:getLatestFiveStarNum()
                        if stageRewardCfg.buff then
                            flag = true
                        elseif stageRewardCfg.starsNum and starNum < stageRewardCfg.starsNum then
                            flag = false
                        end
                        if flag == true then
                            local tipBg = CCSprite:createWithSpriteFrameName("ydczStateBg.png")
                            tipBg:setPosition(tvWidth - tipBg:getContentSize().width / 2 - 10, cellHeight - 80)
                            tipBg:setRotation(22)
                            cell:addChild(tipBg, 2)
                            local tipLb = GetTTFLabelWrap(getlocal("taskCompleted"), descFontSize, CCSizeMake(tipBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                            tipLb:setColor(G_LowfiColorRed2)
                            tipLb:setPosition(getCenterPoint(tipBg))
                            tipBg:addChild(tipLb)
                        end
                    end
                end
                
                if idx ~= (cellNum - 1) then
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(tvWidth - 20, 2))
                    lineSp:setPosition(tvWidth / 2, 10)
                    cell:addChild(lineSp)
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    tv:setPosition((self.bgSize.width - tvWidth) / 2, 110)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(tv, 2)
    self.tv = tv
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth + 10, tvHeight + 20))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(self.bgSize.width / 2, self.tv:getPositionY() - 10)
    self.bgLayer:addChild(tvBg)
    
    --确定
    local btnScale, priority = 0.8, -(layerNum - 1) * 20 - 4
    G_createBotton(dialogBg, ccp(self.bgSize.width / 2, 60), {getlocal("ok")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", close, btnScale, priority)
    
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
