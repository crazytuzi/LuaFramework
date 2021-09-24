--商店页面
exerShopDialog = {}

function exerShopDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    spriteController:addPlist("public/acRadar_images.plist")
    spriteController:addTexture("public/acRadar_images.png")
    spriteController:addPlist("public/accessoryImage2.plist")
    spriteController:addTexture("public/accessoryImage2.png")
    G_addResource8888(function()
        spriteController:addPlist("public/accessoryImage.plist")
    end)
    return nc
end

function exerShopDialog:initTableView()
    self.bgLayer = CCLayer:create()
    self.curShowTabIndex = 1
    local peroid, status = exerWarVoApi:getWarPeroid()
    if peroid >= 7 and status >= 40 then
        self.curShowTabIndex = 2
    end
    local tabTitle = {
        getlocal("plat_war_reward_detail"), getlocal("serverWarLocal_feat_exchange"), getlocal("believer_exchange_report")
    }
    local tabLinePosY
    self.allTabBtn = {}
    local tabBtn = CCMenu:create()
    for k, v in pairs(tabTitle) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0.5, 1))
        tabBtnItem:setPosition(35 + tabBtnItem:getContentSize().width / 2 + (k - 1) * (tabBtnItem:getContentSize().width + 3), G_VisibleSizeHeight - 93)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(k)
        local tabTitleLb = GetTTFLabelWrap(v, 20, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        tabTitleLb:setPosition(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2)
        tabBtnItem:addChild(tabTitleLb)
        tabBtnItem:registerScriptTapHandler(function(...)
                PlayEffect(audioCfg.mouseClick)
                return self:switchTab(...)
        end)
        self.allTabBtn[k] = tabBtnItem
        if tabLinePosY == nil then
            tabLinePosY = tabBtnItem:getPositionY() - tabBtnItem:getContentSize().height
        end
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabBtn)
    local tabLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 3, 1, 1), function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth, 7))
    tabLine:setAnchorPoint(ccp(0.5, 1))
    tabLine:setPosition(G_VisibleSizeWidth / 2, tabLinePosY)
    self.bgLayer:addChild(tabLine)
    self:switchTab(self.curShowTabIndex)
end

function exerShopDialog:switchTab(idx)
    if self.allTabBtn then
        for k, v in pairs(self.allTabBtn) do
            if v:getTag() == idx then
                v:setEnabled(false)
                self.curShowTabIndex = idx
            else
                v:setEnabled(true)
            end
        end
        self:showTabUI()
    end
end

function exerShopDialog:showTabUI()
    if self.tabLayer then
        self.tabLayer:removeAllChildrenWithCleanup(true)
    else
        self.tabLayer = CCLayer:create()
        self.bgLayer:addChild(self.tabLayer)
    end
    if self.curShowTabIndex == 1 then
        local function getCellSize(idx, cellNum)
            local height = 0
            local titleBg = CCSprite:createWithSpriteFrameName("panelSubTitleBg.png")
            height = height + titleBg:getContentSize().height
            if idx == 0 or idx == 1 then
                height = height + 10
                local rewardLb = GetTTFLabelWrap(getlocal("exerwar_rewardDescText", {exerWarVoApi:getWinScore(idx + 1), exerWarVoApi:getFailScore(idx + 1)}), 24, CCSizeMake(G_VisibleSizeWidth - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                height = height + rewardLb:getContentSize().height
                height = height + 10
            elseif idx == 2 then
                height = height + 10
                local rewardIconSize = 80
                local rewardIconSpace = 20
                local rewardIconCol = 6
                local rankRewardTb = exerWarVoApi:getRankReward()
                for k, v in pairs(rankRewardTb) do
                    local rankStr = v.range[1] .. "~" .. v.range[2]
                    if v.range[1] == v.range[2] then
                        rankStr = tostring(v.range[1])
                    end
                    local rankLabel = GetTTFLabelWrap(getlocal("exerwar_shopRankListDescText", {rankStr, v.point}), 24, CCSizeMake(G_VisibleSizeWidth - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    height = height + rankLabel:getContentSize().height + 10
                    local rewardTb = FormatItem(v.reward)
                    local rewardTbSize = SizeOfTable(rewardTb)
                    local rewardIconRowSize = math.ceil(rewardTbSize / rewardIconCol)
                    height = height + rewardIconRowSize * rewardIconSize + (rewardIconRowSize - 1) * rewardIconSpace
                    height = height + 10
                end
            end
            return CCSizeMake(G_VisibleSizeWidth, height)
        end
        local tv = G_createTableView(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 250), 3, getCellSize,
            function(cell, cellSize, idx, cellNum)
                local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                titleBg:setContentSize(CCSizeMake(cellSize.width - 100, titleBg:getContentSize().height))
                titleBg:setAnchorPoint(ccp(0, 1))
                titleBg:setPosition(15, cellSize.height)
                cell:addChild(titleBg)
                local titleStr = ""
                if idx == 0 then
                    titleStr = getlocal("exerwar_maneuverStageText")
                elseif idx == 1 then
                    titleStr = getlocal("exerwar_serverFirstStageText")
                elseif idx == 2 then
                    titleStr = getlocal("exerwar_serverFinalStageText")
                end
                local titleLb = GetTTFLabel(titleStr, 22, true)
                titleLb:setAnchorPoint(ccp(0, 0.5))
                titleLb:setPosition(15, titleBg:getContentSize().height / 2)
                titleLb:setColor(G_ColorYellowPro)
                titleBg:addChild(titleLb)
                if idx == 0 or idx == 1 then
                    local rewardLb = GetTTFLabelWrap(getlocal("exerwar_rewardDescText", {exerWarVoApi:getWinScore(idx + 1), exerWarVoApi:getFailScore(idx + 1)}), 24, CCSizeMake(cellSize.width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    rewardLb:setAnchorPoint(ccp(0.5, 0.5))
                    rewardLb:setPosition(cellSize.width / 2, (titleBg:getPositionY() - titleBg:getContentSize().height) / 2)
                    cell:addChild(rewardLb)
                elseif idx == 2 then
                    local rewardIconSize = 80
                    local rewardIconSpace = 20
                    local rewardIconCol = 6
                    local firsPosX = (cellSize.width - (rewardIconSize * rewardIconCol + (rewardIconCol - 1) * rewardIconSpace)) / 2
                    local posY = titleBg:getPositionY() - titleBg:getContentSize().height - 10
                    local rankRewardTb = exerWarVoApi:getRankReward()
                    for k, v in pairs(rankRewardTb) do
                        local rankStr = v.range[1] .. "~" .. v.range[2]
                        if v.range[1] == v.range[2] then
                            rankStr = tostring(v.range[1])
                        end
                        local rankLabel = GetTTFLabelWrap(getlocal("exerwar_shopRankListDescText", {rankStr, v.point}), 24, CCSizeMake(cellSize.width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        rankLabel:setAnchorPoint(ccp(0, 1))
                        rankLabel:setPosition(titleBg:getPositionX(), posY)
                        cell:addChild(rankLabel)
                        posY = rankLabel:getPositionY() - rankLabel:getContentSize().height - 10
                        local rewardTb = FormatItem(v.reward, nil, true)
                        local rewardTbSize = SizeOfTable(rewardTb)
                        for m, n in pairs(rewardTb) do
                            local icon, scale = G_getItemIcon(n, 100, false, self.layerNum, function()
                                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, n, nil, nil, nil, nil, true)
                            end)
                            icon:setScale(rewardIconSize / icon:getContentSize().height)
                            scale = icon:getScale()
                            icon:setPosition(firsPosX + rewardIconSize / 2 + ((m - 1) % rewardIconCol) * (rewardIconSize + rewardIconSpace), posY - rewardIconSize / 2)
                            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                            cell:addChild(icon)
                            local numLb = GetTTFLabel("x" .. FormatNumber(n.num), 20)
                            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                            numBg:setAnchorPoint(ccp(0, 1))
                            numBg:setRotation(180)
                            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                            numBg:setPosition(icon:getPositionX() + rewardIconSize / 2 - 5, icon:getPositionY() - rewardIconSize / 2 + 5)
                            cell:addChild(numBg)
                            numLb:setAnchorPoint(ccp(1, 0))
                            numLb:setPosition(numBg:getPosition())
                            cell:addChild(numLb)
                            if m % rewardIconCol == 0 or m == rewardTbSize then
                                posY = icon:getPositionY() - rewardIconSize / 2 - ((m == rewardTbSize) and 10 or rewardIconSpace)
                            end
                        end
                    end
                end
            end)
        tv:setPosition(0, 100)
        tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
        self.tabLayer:addChild(tv)
    else
        local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function()end)
        topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, 155))
        topBg:setAnchorPoint(ccp(0.5, 1))
        topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 155)
        self.tabLayer:addChild(topBg)
        local function onClickInfoBtn(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local tabStr = { getlocal("exerwar_shopDescText1"), getlocal("exerwar_shopDescText2") }
            require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
            tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
        end
        local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickInfoBtn)
        local infoMenu = CCMenu:createWithItem(infoBtn)
        infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        infoMenu:setPosition(ccp(0, 0))
        infoBtn:setAnchorPoint(ccp(1, 0.5))
        infoBtn:setPosition(topBg:getContentSize().width - 10, topBg:getContentSize().height / 2)
        topBg:addChild(infoMenu)
        local myScoreLb = GetTTFLabel(getlocal("serverwar_my_point"), 24)
        myScoreLb:setAnchorPoint(ccp(0, 0.5))
        myScoreLb:setPosition(20, topBg:getContentSize().height - 35)
        topBg:addChild(myScoreLb)
        local scoreSp = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
        scoreSp:setAnchorPoint(ccp(0, 0.5))
        scoreSp:setPosition(myScoreLb:getPositionX() + myScoreLb:getContentSize().width, myScoreLb:getPositionY())
        topBg:addChild(scoreSp)
        local myScore = exerWarVoApi:getMyPoint()
        local scoreLb = GetTTFLabel(myScore, 24)
        scoreLb:setAnchorPoint(ccp(0, 0.5))
        scoreLb:setPosition(scoreSp:getPositionX() + scoreSp:getContentSize().width * scoreSp:getScale(), scoreSp:getPositionY())
        topBg:addChild(scoreLb)
        local descStr
        if exerWarVoApi:getExchangeOpenTime() > 0 then
            self.exchangeTimeStatus = 1
            descStr = getlocal("exerwar_shopTipsDescText", {G_formatActiveDate(exerWarVoApi:getExchangeOpenTime())})
        else
            self.exchangeTimeStatus = 2
            descStr = getlocal("exerwar_shopTipsCountDownText", {G_formatActiveDate(exerWarVoApi:getExchangeSupreTime())})
        end
        local descLb = GetTTFLabelWrap(descStr, 24, CCSizeMake(topBg:getContentSize().width - 80, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0, 0.5))
        descLb:setPosition(myScoreLb:getPositionX(), myScoreLb:getPositionY() - 65)
        descLb:setColor(G_ColorYellowPro)
        topBg:addChild(descLb)
        self.descLb = descLb
        if self.curShowTabIndex == 2 then
            local scoreShopData = exerWarVoApi:getScoreShopData()
            local tvSize = CCSizeMake(G_VisibleSizeWidth - 20, topBg:getPositionY() - topBg:getContentSize().height - 115)
            local tvCellHeight = 155
            if G_isAsia() == false then
                tvCellHeight = 180
                if G_isIOS() == false then
                    tvCellHeight = 230
                end
                if G_getCurChoseLanguage() == "de" then
                    tvCellHeight = tvCellHeight + 30
                end
            end
            local tv
            tv = G_createTableView(tvSize, SizeOfTable(scoreShopData), CCSizeMake(tvSize.width, tvCellHeight), function(cell, cellSize, idx, cellNum)
                local data = scoreShopData[idx + 1]
                local reward = FormatItem(data.item, nil, true)
                if reward then
                    reward = reward[1]
                end
                local exchangeNum = exerWarVoApi:getScoreShopExchangeNum(data.id)
                local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                nameBg:setContentSize(CCSizeMake(cellSize.width - 100, nameBg:getContentSize().height))
                nameBg:setAnchorPoint(ccp(0, 1))
                nameBg:setPosition(10, cellSize.height - 5)
                cell:addChild(nameBg)
                local nameLb = GetTTFLabel(reward.name .. "x" .. FormatNumber(reward.num) .. "（" .. exchangeNum .. "/" .. data.num .. "）", 22, true)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(15, nameBg:getContentSize().height / 2)
                nameLb:setColor(G_ColorYellowPro)
                nameBg:addChild(nameLb)
                local iconSize = 95
                local icon, scale = G_getItemIcon(reward, 100, false, self.layerNum, function()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, reward, nil, nil, nil, nil, true)
                end)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setPosition(10 + iconSize / 2, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2)
                icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                cell:addChild(icon)
                local descLbHeight = nameBg:getPositionY() - nameBg:getContentSize().height - 5 - 25
                local descLb = GetTTFLabelWrap(getlocal(reward.desc), 20, CCSizeMake(cellSize.width - 250, descLbHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0, 1))
                descLb:setPosition(icon:getPositionX() + iconSize / 2 + 10, nameBg:getPositionY() - nameBg:getContentSize().height - 5)
                cell:addChild(descLb)
                local canBuyNum = data.num - exchangeNum
                if canBuyNum * data.cost > myScore then
                    canBuyNum = math.floor(myScore / data.cost)
                end
                local function onClickExchange(tag, obj)
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function onBuyHander(buyNum)
                        exerWarVoApi:shopBuyItem(function()
                            reward.num = reward.num * buyNum
                            G_addPlayerAward(reward.type, reward.key, reward.id, reward.num, nil, true)
                            if reward.type == "h" then --添加将领魂魄
                                if reward.key and string.sub(reward.key, 1, 1) == "s" then
                                    heroVoApi:addSoul(reward.key, tonumber(reward.num))
                                end
                            end
                            G_showRewardTip({reward})
                            myScore = exerWarVoApi:getMyPoint()
                            if scoreLb then
                                scoreLb:setString(myScore)
                            end
                            if tv then
                                scoreShopData = exerWarVoApi:getScoreShopData()
                                local recordPoint = tv:getRecordPoint()
                                tv:reloadData()
                                tv:recoverToRecordPoint(recordPoint)
                            end
                        end, data.id, buyNum)
                    end
                    shopVoApi:showBatchBuyPropSmallDialog(reward.key, self.layerNum + 1, onBuyHander, nil, canBuyNum, nil, nil, nil, nil, data.cost, true)
                end
                local btnScale = 0.6
                local exchangeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickExchange, 11, getlocal("buy"), 24 / btnScale)
                exchangeBtn:setScale(btnScale)
                local menu = CCMenu:createWithItem(exchangeBtn)
                menu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                menu:setPosition(0, 0)
                exchangeBtn:setAnchorPoint(ccp(1, 0.5))
                exchangeBtn:setPosition(cellSize.width - 10, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2 - 20)
                cell:addChild(menu)
                local flag = false
                local period, warStatus = exerWarVoApi:getWarPeroid()
                local ts, value = exerWarVoApi:getFinalTimeStatus()
                if period >= 7 and ts and ts == 0 and value and value == 0 then --所有赛事结束后才可购买
                    if data.type == 1 then
                        flag = true
                    elseif data.type == 2 then
                        flag = exerWarVoApi:isEnterFirstPVP()
                    elseif data.type == 3 then
                        flag = exerWarVoApi:isEnterFinal()
                    end
                end
                if flag == false or canBuyNum <= 0 or exchangeNum >= data.num then
                    exchangeBtn:setEnabled(false)
                    local tipsStr
                    if data.type == 2 and exerWarVoApi:isEnterFirstPVP() == false then
                        tipsStr = getlocal("exerwar_shopNotCanBuyTipsText1")
                    elseif data.type == 3 and exerWarVoApi:isEnterFinal() == false then
                        tipsStr = getlocal("exerwar_shopNotCanBuyTipsText2")
                    end
                    if tipsStr then
                        local tipsLb = GetTTFLabelWrap(tipsStr, 20, CCSizeMake(cellSize.width - 250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
                        tipsLb:setAnchorPoint(ccp(0, 0))
                        tipsLb:setPosition(descLb:getPositionX(), 3)
                        tipsLb:setColor(G_ColorRed)
                        cell:addChild(tipsLb)
                    end
                end
                local scoreSp = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
                scoreSp:setAnchorPoint(ccp(1, 0.5))
                scoreSp:setScale(0.8)
                scoreSp:setPosition(exchangeBtn:getPositionX() - exchangeBtn:getContentSize().width * btnScale / 2, exchangeBtn:getPositionY() + exchangeBtn:getContentSize().height * btnScale / 2 + scoreSp:getContentSize().height * scoreSp:getScale() / 2)
                cell:addChild(scoreSp)
                local scoreLb = GetTTFLabel(data.cost, 22)
                scoreLb:setAnchorPoint(ccp(0, 0.5))
                scoreLb:setPosition(scoreSp:getPosition())
                if myScore < data.cost then
                    scoreLb:setColor(G_ColorRed)
                end
                cell:addChild(scoreLb)
                if idx + 1 < cellNum then
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(cellSize.width - 20, 4))
                    lineSp:setPosition(cellSize.width / 2, 0)
                    cell:addChild(lineSp)
                end
            end)
            tv:setPosition(10, 100)
            tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
            self.tabLayer:addChild(tv)
        elseif self.curShowTabIndex == 3 then
            local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
            tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, topBg:getPositionY() - topBg:getContentSize().height - 115))
            tvBg:setAnchorPoint(ccp(0.5, 0))
            tvBg:setPosition(G_VisibleSizeWidth / 2, 100)
            self.tabLayer:addChild(tvBg)
            local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
            tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, 45))
            tvTitleBg:setAnchorPoint(ccp(0.5, 1))
            tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
            tvBg:addChild(tvTitleBg)
            local titleLb1 = GetTTFLabel(getlocal("alliance_event_time"), 22)
            local titleLb2 = GetTTFLabel(getlocal("buyLogTitle"), 22)
            titleLb1:setColor(G_ColorYellowPro)
            titleLb2:setColor(G_ColorYellowPro)
            titleLb1:setPosition(tvTitleBg:getContentSize().width * 0.15, tvTitleBg:getContentSize().height * 0.5)
            titleLb2:setPosition(tvTitleBg:getContentSize().width * 0.65, tvTitleBg:getContentSize().height * 0.5)
            tvTitleBg:addChild(titleLb1)
            tvTitleBg:addChild(titleLb2)
            local logData = exerWarVoApi:getScoreShopExchangeLog()
            local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - tvTitleBg:getContentSize().height - 6)
            local tv = G_createTableView(tvSize, SizeOfTable(logData or {}), CCSizeMake(tvSize.width, 60), function(cell, cellSize, idx, cellNum)
                local time = logData[idx + 1][1]
                local shopId = logData[idx + 1][2]
                local buyNum = logData[idx + 1][3]
                local shopData = exerWarVoApi:getScoreShopData(shopId)
                local itemData = FormatItem(shopData.item, nil, true)
                if itemData then
                    itemData = itemData[1]
                end
                local timeLb = GetTTFLabel(G_getDataTimeStr(time), 22)
                local descLb = GetTTFLabel(itemData.name .."x" .. (itemData.num * buyNum), 22)
                timeLb:setPosition(cellSize.width * 0.15, cellSize.height * 0.5)
                descLb:setPosition(cellSize.width * 0.65, cellSize.height * 0.5)
                cell:addChild(timeLb)
                cell:addChild(descLb)
                if idx + 1 < cellNum then
                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                    lineSp:setContentSize(CCSizeMake(cellSize.width - 20, 4))
                    lineSp:setPosition(cellSize.width / 2, 0)
                    cell:addChild(lineSp)
                end
            end)
            tv:setPosition(3, 3)
            tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
            tvBg:addChild(tv)
        end
    end
end

function exerShopDialog:tick()
    if self and tolua.cast(self.descLb, "CCLabelTTF") then
        local descLb = tolua.cast(self.descLb, "CCLabelTTF")
        if descLb then
            local timeStatus
            if exerWarVoApi:getExchangeOpenTime() > 0 then
                timeStatus = 1
                descLb:setString(getlocal("exerwar_shopTipsDescText", {G_formatActiveDate(exerWarVoApi:getExchangeOpenTime())}))
            else
                timeStatus = 2
                descLb:setString(getlocal("exerwar_shopTipsCountDownText", {G_formatActiveDate(exerWarVoApi:getExchangeSupreTime())}))
            end
            if self.exchangeTimeStatus ~= timeStatus and self.curShowTabIndex == 2 then
                self:showTabUI()
            end
        end
    end
end

function exerShopDialog:dispose()
    self = nil
    spriteController:removePlist("public/acRadar_images.plist")
    spriteController:removeTexture("public/acRadar_images.png")
    spriteController:removePlist("public/accessoryImage2.plist")
    spriteController:removeTexture("public/accessoryImage2.png")
    spriteController:removePlist("public/accessoryImage.plist")
end
