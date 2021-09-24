--军团排名奖励面板
championshipWarRankRewardDialog = smallDialog:new()

function championshipWarRankRewardDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function championshipWarRankRewardDialog:showRankRewardDialog(layerNum)
    local sd = championshipWarRankRewardDialog:new()
    sd:initRankRewardDialog(layerNum)
end

function championshipWarRankRewardDialog:initRankRewardDialog(layerNum)
    self.isTouch = true
    self.isUseAmi = true
    self.layerNum = layerNum
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    local size = CCSizeMake(G_VisibleSizeWidth - 90, G_VisibleSizeHeight - 350)
    self.bgSize = size
    local dialogBg = G_getNewDialogBg2(size, layerNum, nil, getlocal("championshipWar_reward_list"), 28)
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    self:show()
    
    local warCfg = championshipWarVoApi:getWarCfg()
    local grade = championshipWarVoApi:getCurrentSeasonGrade() or 1
    local rankingReward = warCfg.rankingReward[grade]
    
    local tipFontSize, titleFontSize, iconHeight = 22, 22, 80
    
    local tipLb = GetTTFLabelWrap(getlocal("championshipWar_rankRewardTip"), tipFontSize, CCSizeMake(size.width - 80, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(size.width / 2, size.height - 32 - tipLb:getContentSize().height / 2)
    self.bgLayer:addChild(tipLb)
    
    local tvWidth, tvHeight, cellHeight = size.width - 40, tipLb:getPositionY() - tipLb:getContentSize().height / 2 - 40, iconHeight + 32 + 20
    local cellNum = SizeOfTable(rankingReward)
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local reward = rankingReward[idx + 1]
            local minRank, maxRank = reward.rank[1] or 1, reward.rank[2] or 1
            local coin = reward.coin or 0
            
            local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            titleBg:setContentSize(CCSizeMake(tvWidth - 20, 32))
            titleBg:setAnchorPoint(ccp(0, 1))
            titleBg:setPosition(10, cellHeight)
            cell:addChild(titleBg)
            
            local rankStr = ""
            if tonumber(minRank) == tonumber(maxRank) then
                rankStr = getlocal("serverwar_rank_reward", {"<rayimg>"..tostring(minRank) .. "<rayimg>"})
            else
                rankStr = getlocal("serverwar_rank_reward", {"<rayimg>"..minRank.."~"..maxRank.."<rayimg>"})
            end
            local colorTb = {nil, G_ColorYellowPro, nil}
            local titleLb, lbheight = G_getRichTextLabel(rankStr, colorTb, titleFontSize, tvWidth - 80, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            titleLb:setAnchorPoint(ccp(0, 1))
            titleLb:setPosition(10, (titleBg:getContentSize().height + lbheight) / 2)
            titleBg:addChild(titleLb)
            
            local rewardSp = CCSprite:createWithSpriteFrameName("csi_coin.png")
            rewardSp:setScale(iconHeight / rewardSp:getContentSize().height)
            rewardSp:setAnchorPoint(ccp(0, 0.5))
            rewardSp:setPosition(20, 10 + iconHeight / 2)
            cell:addChild(rewardSp)

            local numLb = GetTTFLabel("x"..coin, titleFontSize)
            numLb:setAnchorPoint(ccp(0, 0))
            numLb:setPosition(ccp(rewardSp:getContentSize().width + 5, 0))
            rewardSp:addChild(numLb, 4)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setPosition((size.width - tvWidth) / 2, 30)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv, 2)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(tvWidth, tvHeight + 10))
    tvBg:setPosition(size.width / 2, self.tv:getPositionY()-5)
    tvBg:setIsSallow(false)
    tvBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(tvBg)
    
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
    G_addForbidForSmallDialog(self.dialogLayer,self.bgLayer,-(self.layerNum-1)*20-3,closeFunc)
    
    G_addArrowPrompt(self.bgLayer, nil, -70)
    
    self.dialogLayer:setPosition(ccp(0, 0))
end
