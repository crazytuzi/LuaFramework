acFlashSaleSmallDialog = smallDialog:new()

function acFlashSaleSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acFlashSaleSmallDialog:showRecord(layerNum, titleStr, logData)
	local sd = acFlashSaleSmallDialog:new()
    sd:initRecordUI(layerNum, titleStr, logData)
end

function acFlashSaleSmallDialog:initRecordUI(layerNum, titleStr, logData)
	self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local function closeDialog()
        -- base:removeFromNeedRefresh(self)
        self:close()
    end
    self.bgSize = CCSizeMake(560, 840)
    local function onClickClose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, false, nil, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    -- base:addNeedRefresh(self)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local logDataSize = SizeOfTable(logData)
    local iconSize = 75
    local row = 6
    local iconSpaceX, iconSpaceY = 10, 10
    local cellHeightTb = {}
    if logData then
        for k, v in pairs(logData) do
            local v1Num, v2Num = 0, 0
            for kk, vv in pairs(v[2]) do
                local vvNum = 0
                for kkk, vvv in pairs(vv) do
                    if SizeOfTable(vvv) > 0 then
                        vvNum = vvNum + 1
                    end
                end
                v1Num = v1Num + vvNum
            end
            for kk, vv in pairs(v[3]) do
                v2Num = v2Num + SizeOfTable(vv)
            end
            local height = 50
            local v1Col = math.ceil(v1Num / row)
            local v2Col = math.ceil(v2Num / row)
            height = height + v1Col * iconSize + (v1Col - 1) * iconSpaceY
            if v2Num > 0 then
                height = height + 50
                height = height + v2Col * iconSize + (v2Col - 1) * iconSpaceY
            end
            height = height + 20
            cellHeightTb[k] = height
        end
    end
    if logDataSize <= 0 then
        local tipsLb = GetTTFLabelWrap(getlocal("activity_tccx_no_record"), 24, CCSizeMake(self.bgSize.width - 50, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipsLb:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height / 2))
        tipsLb:setColor(G_ColorGray)
        self.bgLayer:addChild(tipsLb)
    end
    local logTv
    local logTvSize = CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 230)
    logTv = G_createTableView(logTvSize, logDataSize, function(idx, cellNum) return CCSizeMake(logTvSize.width, cellHeightTb[idx + 1]) end, function(cell, cellSize, idx, cellNum)
    	local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
    	cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 10))
    	cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
    	cell:addChild(cellBg)
    	local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function()end)
    	lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width - 30, lineSp:getContentSize().height))
    	lineSp:setPosition(ccp(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 40))
    	cellBg:addChild(lineSp)
        local data = logData[idx + 1]
        if data == nil then
            do return end
        end
        local rechargeId = data[1]
        local rewardData = data[2]
        local giveData = data[3]
        local ts = data[4]
        local buyNameLb = GetTTFLabel(getlocal("acFlashSale_buyLogTitleText", {acFlashSaleVoApi:getGiftNameByRechargeId(rechargeId)}), 22)
        buyNameLb:setAnchorPoint(ccp(0, 0.5))
        buyNameLb:setPosition(ccp(20, cellBg:getContentSize().height - 20))
        cellBg:addChild(buyNameLb)
        local tsLb = GetTTFLabel(G_getDataTimeStr(ts), 22)
        tsLb:setAnchorPoint(ccp(1, 0.5))
        tsLb:setPosition(ccp(cellBg:getContentSize().width - 20, cellBg:getContentSize().height - 20))
        cellBg:addChild(tsLb)
        local function rewardUI(item, pos)
            local function showNewPropDialog()
                if logTv and logTv:getIsScrolled() == false then
                    if item.type == "at" and item.eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(item.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
                    else
                        G_showNewPropInfo(layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
                    end
                end
            end
            local icon, scale = G_getItemIcon(item, 100, false, self.layerNum, showNewPropDialog)
            icon:setTouchPriority(-(layerNum - 1) * 20 - 2)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setAnchorPoint(ccp(0, 1))
            icon:setPosition(pos)
            cellBg:addChild(icon)
            local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 18)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize + 5)
            icon:getParent():addChild(numBg, 1)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            icon:getParent():addChild(numLb, 1)
        end
        local firstPosX = 10
        local firstPosY = lineSp:getPositionY() - 10
        local itemIndex = 0
        if rewardData then
            for k, v in pairs(rewardData) do
                for kk, vv in pairs(v) do
                    local item = FormatItem(vv)[1]
                    if item then
                        itemIndex = itemIndex + 1
                        local pos = ccp(firstPosX + ((itemIndex - 1) % row) * (iconSize + iconSpaceX), firstPosY - math.floor((itemIndex - 1) / row) * (iconSize + iconSpaceY))
                        rewardUI(item, pos)
                    end
                end
            end
        end
        if giveData and SizeOfTable(giveData) > 0 then
            local col = math.ceil(itemIndex / row)
            firstPosY = firstPosY - (col * iconSize + (col - 1) * iconSpaceY) - 10
            local giveNameLb = GetTTFLabel(getlocal("acFlashSale_buyLogGiveTitleText"), 22)
            giveNameLb:setAnchorPoint(ccp(0, 1))
            giveNameLb:setPosition(ccp(20, firstPosY))
            cellBg:addChild(giveNameLb)
            firstPosY = giveNameLb:getPositionY() - giveNameLb:getContentSize().height - 10
            itemIndex = 0
            for k, v in pairs(giveData) do
                local item = FormatItem(v)[1]
                if item then
                    itemIndex = itemIndex + 1
                    local pos = ccp(firstPosX + ((itemIndex - 1) % row) * (iconSize + iconSpaceX), firstPosY - math.floor((itemIndex - 1) / row) * (iconSize + iconSpaceY))
                    rewardUI(item, pos)
                end
            end
        end
    end)
    logTv:setPosition(ccp((self.bgSize.width - logTvSize.width) / 2, self.bgSize.height - 89 - logTvSize.height))
    logTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(logTv)
    if logDataSize > 0 then
        --添加上下屏蔽层
        local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
        upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        upShiedldBg:setAnchorPoint(ccp(0.5, 0))
        upShiedldBg:setPosition(self.bgSize.width / 2, logTv:getPositionY() + logTvSize.height)
        upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
        upShiedldBg:setOpacity(0)
        self.bgLayer:addChild(upShiedldBg)
        local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
        downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        downShiedldBg:setAnchorPoint(ccp(0.5, 1))
        downShiedldBg:setPosition(self.bgSize.width / 2, logTv:getPositionY())
        downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
        downShiedldBg:setOpacity(0)
        self.bgLayer:addChild(downShiedldBg)
        local tipsLb = GetTTFLabelWrap(getlocal("recentShowText"), 22, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipsLb:setAnchorPoint(ccp(0.5, 1))
        tipsLb:setPosition(ccp(self.bgSize.width / 2, logTv:getPositionY() - 10))
        tipsLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(tipsLb)
    end
    local btnScale = 0.8
    local button = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickClose, nil, getlocal("confirm"), 24 / btnScale)
    button:setScale(btnScale)
    button:setAnchorPoint(ccp(0.5, 0))
    button:setPosition(ccp(self.bgSize.width / 2, 25))
    local btnMenu = CCMenu:createWithItem(button)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(btnMenu)
end

function acFlashSaleSmallDialog:showPreviewReward(layerNum, titleStr, rewardTb, bdNum)
    local sd = acFlashSaleSmallDialog:new()
    sd:initPreviewRewardUI(layerNum, titleStr, rewardTb, bdNum)
end

function acFlashSaleSmallDialog:initPreviewRewardUI(layerNum, titleStr, rewardTb, bdNum)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local function closeDialog()
        self:close()
    end
    self.bgSize = CCSizeMake(560, 750)
    local function onClickClose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, onClickClose, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local tvBgPosY = self.bgSize.height - 80
    if bdNum then
        local tipsLb = GetTTFLabelWrap(getlocal("acFlashSale_previewAllTipsText", {bdNum}), 22, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipsLb:setAnchorPoint(ccp(0.5, 1))
        tipsLb:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 80))
        tipsLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(tipsLb)
        tvBgPosY = tipsLb:getPositionY() - tipsLb:getContentSize().height - 15
    end
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, tvBgPosY - 25))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(ccp(self.bgSize.width / 2, tvBgPosY))
    self.bgLayer:addChild(tvBg)
    local rewardTv
    local iconSize = 80
    local row, iconSpaceX = 5, 20
    local cellNum = 0
    local luckRewardTb, generalRewardTb = {}, {}
    local luckRewardTbNum, generalRewardTbNum = 0, 0
    local luckRewardCol, generalRewardCol = 0, 0
    for k, v in pairs(rewardTb) do
        if type(v.extend) == "string" then
            table.insert(luckRewardTb, v)
            luckRewardTbNum = luckRewardTbNum + 1
        else
            table.insert(generalRewardTb, v)
            generalRewardTbNum = generalRewardTbNum + 1
        end
    end
    if luckRewardTbNum > 0 then
        luckRewardCol = math.ceil(luckRewardTbNum / row)
        cellNum = luckRewardCol + 1
    end
    generalRewardCol = math.ceil(generalRewardTbNum / row)
    cellNum = cellNum + generalRewardCol + 1
    local rewardTvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - 6)
    rewardTv = G_createTableView(rewardTvSize, cellNum, CCSizeMake(rewardTvSize.width, iconSize + iconSpaceX), function(cell, cellSize, idx, cellNum)
        local function initRewardTitle(rewardTitleStr)
            local rewardTitleLb = GetTTFLabel(rewardTitleStr, 25, true)
            local rewardTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
            rewardTitleBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
            cell:addChild(rewardTitleBg)
            rewardTitleLb:setPosition(ccp(rewardTitleBg:getContentSize().width / 2, rewardTitleBg:getContentSize().height / 2))
            rewardTitleBg:addChild(rewardTitleLb)
        end
        local cellIndex = idx
        local data = rewardTb
        if luckRewardTbNum == 0 then
            if idx == 0 then
                cellIndex = nil
                initRewardTitle(getlocal("custom_maze_reward"))
            else
                cellIndex = idx - 1
                data = generalRewardTb
            end
        elseif luckRewardTbNum > 0 then
            if idx == 0 or idx - luckRewardCol == 1 then
                cellIndex = nil
                initRewardTitle(getlocal((idx == 0) and "luckyRewardText" or "custom_maze_reward"))
            elseif idx > 0 and idx <= luckRewardCol then
                cellIndex = idx - 1
                data = luckRewardTb
            else
                cellIndex = idx - luckRewardCol - 2
                data = generalRewardTb
            end
        end
        if cellIndex then
            local firstPosX = (cellSize.width - (row * iconSize + (row - 1) * iconSpaceX)) / 2
            local startIndex = cellIndex * row + 1
            local endIndex = startIndex + row - 1
            local index = 0
            for i = startIndex, endIndex do
                local item = data[i]
                if item then
                    index = index + 1
                    local function showNewPropDialog()
                        if rewardTv:getIsScrolled() == false then
                            if item.type == "at" and item.eType == "a" then --AI部队
                                local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(item.key, true)
                                AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                            else
                                G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
                            end
                        end
                    end
                    local icon, scale = G_getItemIcon(item, 100, false, self.layerNum, showNewPropDialog)
                    icon:setScale(iconSize / icon:getContentSize().height)
                    scale = icon:getScale()
                    icon:setAnchorPoint(ccp(0, 0.5))
                    icon:setPosition(ccp(firstPosX + (index - 1) * (iconSize + iconSpaceX), cellSize.height / 2))
                    icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                    cell:addChild(icon)
                    if type(item.extend) == "string" then
                        local flickerScale = (item.type == "o" or item.type == "troops" or (item.type == "p" and propCfg[item.key].useGetHero)) and 1.65 or 1.15
                        G_addRectFlicker2(icon, flickerScale, flickerScale, 1, item.extend, nil, 10)
                    end
                    local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 18)
                    local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                    numBg:setAnchorPoint(ccp(0, 1))
                    numBg:setRotation(180)
                    numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                    numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                    numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize / 2 + 5)
                    cell:addChild(numBg, 1)
                    numLb:setAnchorPoint(ccp(1, 0))
                    numLb:setPosition(numBg:getPosition())
                    cell:addChild(numLb, 1)
                end
            end
        end
    end)
    rewardTv:setPosition(ccp((tvBg:getContentSize().width - rewardTvSize.width) / 2, (tvBg:getContentSize().height - rewardTvSize.height) / 2))
    rewardTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tvBg:addChild(rewardTv)

    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(self.bgSize.width / 2, tvBg:getPositionY())
    upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    self.bgLayer:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(self.bgSize.width / 2, tvBg:getPositionY() - tvBg:getContentSize().height)
    downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    self.bgLayer:addChild(downShiedldBg)
end

function acFlashSaleSmallDialog:showFriendList(layerNum, titleStr, friendTb, paramsTb)
    local sd = acFlashSaleSmallDialog:new()
    sd:initFriendList(layerNum, titleStr, friendTb, paramsTb)
end

function acFlashSaleSmallDialog:initFriendList(layerNum, titleStr, friendTb, paramsTb)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    local function closeDialog()
        self:close()
    end
    self.bgSize = CCSizeMake(560, 750)
    local function onClickClose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, onClickClose, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local friendTbSize = SizeOfTable(friendTb)
    if friendTbSize <= 0 then
        local tipsLb = GetTTFLabelWrap(getlocal("noFriends"), 22, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipsLb:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height / 2))
        tipsLb:setColor(G_ColorGray)
        self.bgLayer:addChild(tipsLb)
    else
        local tipsLb = GetTTFLabelWrap(getlocal("acFlashSale_friendGiveTipsText", {acFlashSaleVoApi:getGiveNum()}), 22, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - tipsLb:getContentSize().height - 115))
        tvBg:setAnchorPoint(ccp(0.5, 1))
        tvBg:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 80))
        self.bgLayer:addChild(tvBg)
        tipsLb:setAnchorPoint(ccp(0.5, 1))
        tipsLb:setPosition(ccp(self.bgSize.width / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10))
        self.bgLayer:addChild(tipsLb)

        local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
        tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, 40))
        tvTitleBg:setAnchorPoint(ccp(0.5, 1))
        tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
        tvBg:addChild(tvTitleBg)
        local tvTitleStr = {getlocal("help2_t1_t3"), getlocal("RankScene_name"), getlocal("RankScene_level"), getlocal("alliance_list_scene_operator")}
        local tvTitleWidthRate = {0.1, 0.35, 0.6, 0.9}
        for k, v in pairs(tvTitleStr) do
            local titleLb = GetTTFLabel(v, 20, true)
            titleLb:setPosition(tvTitleBg:getContentSize().width * tvTitleWidthRate[k], tvTitleBg:getContentSize().height / 2)
            titleLb:setColor(G_ColorYellowPro)
            tvTitleBg:addChild(titleLb)
        end
        local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - 3)
        local tv
        tv = G_createTableView(tvSize, friendTbSize, CCSizeMake(tvSize.width, 65), function(cell, cellSize, idx, cellNum)
            local data = friendTb[idx + 1]
            if data == nil then
                do return end
            end
            if idx % 2 == 0 then
                local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
                cellBg:setContentSize(cellSize)
                cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
                cell:addChild(cellBg)
            end
            local uid = data[1]
            local rank = tonumber(data[2])
            local name = data[3]
            local lv = data[4]
            local giveNum = data[5]
            local content = {rank, name, getlocal("fightLevel", {lv})}
            for k, v in pairs(content) do
                local node
                if k == 1 then
                    node = CCSprite:createWithSpriteFrameName(playerVoApi:getRankIconName(rank))
                    node:setScale((cellSize.height - 10) / node:getContentSize().height)
                else
                    node = GetTTFLabel(v, 20)
                end
                node:setPosition(ccp(cellSize.width * tvTitleWidthRate[k], cellSize.height / 2))
                cell:addChild(node)
            end
            if giveNum >= acFlashSaleVoApi:getGiveNum() then
                local lb = GetTTFLabel(getlocal("itsEnough"), 20)
                lb:setPosition(ccp(cellSize.width * tvTitleWidthRate[4], cellSize.height / 2))
                cell:addChild(lb)
            else
                local function onClickSelect(tag, obj)
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if tv and tv:getIsScrolled() == false then
                        if paramsTb then
                            local itemName = paramsTb[1]
                            local rechargeId = paramsTb[2]
                            local stype = paramsTb[3]
                            local sid = paramsTb[4]
                            local callback = paramsTb[5]
                            G_showSureAndCancle(getlocal("acFlashSale_sureGiveTipsText", {itemName, name}), function()
                                local netParams = {fid = tostring(uid), tid = tostring(rechargeId), stype = tostring(stype), sid = tostring(sid)}
                                acFlashSaleVoApi:netRequest("give", netParams, function(sData)
                                    if type(callback) == "function" then
                                        callback()
                                    end
                                    closeDialog()
                                    print("cjl ----->>> 赠送成功！")
                                end)
                            end)
                        end
                    end
                end
                local btnScale = 0.5
                local selectBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickSelect, nil, getlocal("dailyAnswer_tab1_btn"), 22 / btnScale)
                selectBtn:setScale(btnScale)
                selectBtn:setAnchorPoint(ccp(1, 0.5))
                selectBtn:setPosition(ccp(cellSize.width - 10, cellSize.height / 2))
                local btnMenu = CCMenu:createWithItem(selectBtn)
                btnMenu:setPosition(ccp(0, 0))
                btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cell:addChild(btnMenu)
            end
        end)
        tv:setPosition(ccp((tvBg:getContentSize().width - tvSize.width) / 2, 3))
        tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        tvBg:addChild(tv)
    end
end

function acFlashSaleSmallDialog:showTodayListDetails(layerNum, listData)
    local sd = acFlashSaleSmallDialog:new()
    sd:initTodayListDetails(layerNum, listData)
end

function acFlashSaleSmallDialog:initTodayListDetails(layerNum, listData)
    self.layerNum = layerNum
    self.isUseAmi = false
    
    self.dialogLayer = CCLayer:create()

    local function closeDialog()
        self:close()
    end
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() closeDialog() end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(G_VisibleSizeWidth, 500)
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setTouchPriority(-(layerNum - 1) * 20 - 2)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    local closeTipLb = GetTTFLabelWrap(getlocal("closeDialogTipsText"), 20, CCSizeMake(self.bgSize.width - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    local closeTipBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    closeTipBg:setContentSize(CCSizeMake(self.bgSize.width, closeTipLb:getContentSize().height + 20))
    closeTipBg:setAnchorPoint(ccp(0.5, 1))
    closeTipBg:setPosition(ccp(self.bgSize.width / 2, 0))
    self.bgLayer:addChild(closeTipBg)
    closeTipLb:setPosition(ccp(closeTipBg:getContentSize().width / 2, closeTipBg:getContentSize().height / 2))
    closeTipBg:addChild(closeTipLb)
    if listData then
        local listTvSize = CCSizeMake(self.bgLayer:getContentSize().width - 20, self.bgLayer:getContentSize().height - 20)
        local listDataSize = 0
        local cellHeightTb = {}
        local listLbTb = {}
        for k, v in pairs(listData) do
            listDataSize = listDataSize + 1
            local lb = GetTTFLabelWrap(v[1], 20, CCSizeMake(listTvSize.width - 130, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            cellHeightTb[k] = 8 + lb:getContentSize().height + 8
            listLbTb[k] = lb
        end
        local listTv = G_createTableView(listTvSize, listDataSize, function(idx, cellNum) return CCSizeMake(listTvSize.width, cellHeightTb[idx + 1]) end, function(cell, cellSize, idx, cellNum)
            local lb = listLbTb[idx + 1]
            lb:setAnchorPoint(ccp(0, 0.5))
            lb:setPosition(ccp(0, cellSize.height / 2))
            cell:addChild(lb)
            local tsLb = GetTTFLabel(G_getDataTimeStr(listData[idx + 1][2]), 20)
            tsLb:setAnchorPoint(ccp(1, 0.5))
            tsLb:setPosition(ccp(cellSize.width, cellSize.height / 2))
            cell:addChild(tsLb)
        end)
        listTv:setPosition(ccp((self.bgLayer:getContentSize().width - listTvSize.width) / 2, (self.bgLayer:getContentSize().height - listTvSize.height) / 2))
        listTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.bgLayer:addChild(listTv)
    end
end

function acFlashSaleSmallDialog:dispose()
	self = nil
end