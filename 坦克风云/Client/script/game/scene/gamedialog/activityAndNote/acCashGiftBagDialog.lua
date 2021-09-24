acCashGiftBagDialog = commonDialog:new()

function acCashGiftBagDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/accessoryImage.plist")
        spriteController:addPlist("public/accessoryImage2.plist")
        spriteController:addPlist("public/acMjcsIconImage.plist")
		spriteController:addTexture("public/acMjcsIconImage.png")
    end)
    return nc
end

function acCashGiftBagDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function acCashGiftBagDialog:initTableView()
	local rData = acCashGiftBagVoApi:getUIRandomData()
    for k, v in pairs(rData) do
        self["imageIndex_" .. k] = v
    end

    local bgColorLayer = CCLayerColor:create(acCashGiftBagVoApi:getColorOfBg(self.imageIndex_color))
    bgColorLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 84))
    self.bgLayer:addChild(bgColorLayer)

    local topBg
    G_addResource8888(function()
        topBg = CCSprite:create("public/acxjlb_infoBg_" .. self.imageIndex_infoBg .. ".jpg")
    end)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 84)
    self.bgLayer:addChild(topBg, 1)
    local personSp = CCSprite:createWithSpriteFrameName("acxjlb_person_" .. self.imageIndex_person .. ".png")
    personSp:setPosition(topBg:getContentSize().width - personSp:getContentSize().width / 2, topBg:getContentSize().height / 2)
    topBg:addChild(personSp)
    
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    timeBg:setContentSize(CCSizeMake(topBg:getContentSize().width, 50))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(topBg:getContentSize().width / 2, topBg:getContentSize().height)
    topBg:addChild(timeBg)
    local timeLb = GetTTFLabel(acCashGiftBagVoApi:getTimeStr(), 20, true)
    timeLb:setPosition(timeBg:getContentSize().width / 2, timeBg:getContentSize().height / 2)
    timeLb:setColor(G_ColorYellowPro)
    timeBg:addChild(timeLb)
    self.timeLb = timeLb

    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("acCashGiftBag_i_desc1"),
            getlocal("acCashGiftBag_i_desc2"),
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(timeBg:getContentSize().width - 10 - infoBtn:getContentSize().width * infoBtn:getScale() / 2, timeBg:getContentSize().height / 2))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    timeBg:addChild(infoMenu)

    local descStr = acCashGiftBagVoApi:getActiveDesc()
    if descStr and descStr ~= "" then
        local tempSp = CCSprite:createWithSpriteFrameName("acxjlb_descBg_" .. self.imageIndex_descBg .. ".png")
        local descLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("acxjlb_descBg_" .. self.imageIndex_descBg .. ".png", CCRect(tempSp:getContentSize().width / 2 - 1, tempSp:getContentSize().height / 2 - 1, 2, 2), function()end)
        descLbBg:setContentSize(CCSizeMake(topBg:getContentSize().width - personSp:getContentSize().width + 50, tempSp:getContentSize().height))
        descLbBg:setPosition(personSp:getPositionX() - personSp:getContentSize().width / 2 + 80 - descLbBg:getContentSize().width / 2, descLbBg:getContentSize().height / 2 + 75)
        topBg:addChild(descLbBg)
        local descLbTvSize = CCSizeMake(descLbBg:getContentSize().width - 60, descLbBg:getContentSize().height - 20)
        local descLabel = GetTTFLabelWrap(descStr, 22, CCSizeMake(descLbTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        local descLbTvCellHeight = descLbTvSize.height
        if descLabel:getContentSize().height > descLbTvSize.height then
            descLbTvCellHeight = descLabel:getContentSize().height
        end
        local descLbTv = G_createTableView(descLbTvSize, 1, CCSizeMake(descLbTvSize.width, descLbTvCellHeight), function(cell, cellSize, idx, cellNum)
        	descLabel:setPosition(descLbTvSize.width / 2, descLbTvCellHeight / 2)
            cell:addChild(descLabel)
        end)
        descLbTv:setPosition(ccp((descLbBg:getContentSize().width - descLbTvSize.width) / 2, (descLbBg:getContentSize().height - descLbTvSize.height) / 2))
        descLbTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
        descLbTv:setMaxDisToBottomOrTop(0)
        descLbBg:addChild(descLbTv)
    end

    local topBgLine = CCSprite:createWithSpriteFrameName("metalPartitionBar.png")
    topBgLine:setPosition(topBg:getContentSize().width / 2, 0)
    topBg:addChild(topBgLine)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, topBg:getPositionY() - topBg:getContentSize().height - 25))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height - 10)
    self.bgLayer:addChild(tableViewBg)
    tableViewBg:setOpacity(0)
    
    self.shopList = acCashGiftBagVoApi:getShopList()
    local rewardTvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    self.rewardTv = G_createTableView(rewardTvSize, function() return SizeOfTable(self.shopList or {}) end, CCSizeMake(rewardTvSize.width, 170), function(...) self:initRewardTvCell(...) end)
    self.rewardTv:setPosition(ccp(3, 3))
    self.rewardTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.rewardTv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.rewardTv)

    local acVo = acCashGiftBagVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = function()
            if self.rewardTv then
                local recordPoint = self.rewardTv:getRecordPoint()
                self.rewardTv:reloadData()
                self.rewardTv:recoverToRecordPoint(recordPoint)
            end
        end
    end
end

function acCashGiftBagDialog:initRewardTvCell(cell, cellSize, idx, cellNum)
	-- if idx == 0 then
 --        self.cellTimeLb = {}
 --    end
	local data = self.shopList[idx + 1]
    if data == nil then
        do return cell end
    end

	local cellBg = CCSprite:createWithSpriteFrameName("acxjlb_cellBg_" .. self.imageIndex_cellBg .. ".png")
    cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
    cellBg:setColor(acCashGiftBagVoApi:getColorOfCellBg(self.imageIndex_color))
    cell:addChild(cellBg)

    local rData = acCashGiftBagVoApi:getRechargeData(data.index)
    local rState, rNum = 0, 0
    if rData then
        rState = (rData[1] or 0) --充值状态  默认 0 未充值； 1 已充值； 2 已领取
        rNum = (rData[2] or 0) --领取次数
    end
    local nameLb = GetTTFLabel(data.name .. "(" .. rNum .. "/" .. data.limit .. ")", 22, true)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(20, cellBg:getContentSize().height - 8)
    nameLb:setColor(ccc3(253, 230, 134))
    cellBg:addChild(nameLb)

    local oldPriceLb
    if data.price and data.price > 0 then
        oldPriceLb = GetTTFLabel(getlocal("vip_tequanlibao_realCost", {data.price .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]}), 20)
        local oldPriceLineLb = GetTTFLabel("-", 20)
        oldPriceLineLb:setScaleX(oldPriceLb:getContentSize().width / oldPriceLineLb:getContentSize().width)
        oldPriceLineLb:setPosition(ccp(oldPriceLb:getContentSize().width / 2, oldPriceLb:getContentSize().height / 2))
        oldPriceLb:addChild(oldPriceLineLb)
        oldPriceLb:setColor(G_ColorRed)
        oldPriceLineLb:setColor(G_ColorRed)
    end

    local giftSp = CCSprite:createWithSpriteFrameName("acxjlb_giftBag_" .. self.imageIndex_gift .. ".png")
    giftSp:setAnchorPoint(ccp(0, 0.5))
    giftSp:setPosition(20, cellBg:getContentSize().height / 2 - 20)
    cellBg:addChild(giftSp)

    local rewardTb
    if data.reward then
        rewardTb = {}
        local iconSize = 70
        local iconSpaceX = 15
        for k, v in pairs(data.reward) do
            v = FormatItem(v, nil, true)[1]
            if v then
	            local function showNewPropDialog()
	                if v.type == "at" and v.eType == "a" then --AI部队
	                    local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
	                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
	                else
	                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
	                end
	            end
	            icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
	            icon:setScale(iconSize / icon:getContentSize().height)
	            scale = icon:getScale()
	            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
	            icon:setPosition(giftSp:getPositionX() + giftSp:getContentSize().width * giftSp:getScale() + 15 + icon:getContentSize().width * scale / 2 + (k - 1) * (iconSpaceX + icon:getContentSize().width * scale), iconSize / 2 + 30)
	            cellBg:addChild(icon)
	            local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
	            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
	            numBg:setAnchorPoint(ccp(0, 1))
	            numBg:setRotation(180)
	            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
	            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
	            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
	            cellBg:addChild(numBg)
	            numLb:setAnchorPoint(ccp(1, 0))
	            numLb:setPosition(numBg:getPosition())
	            cellBg:addChild(numLb)
	            table.insert(rewardTb, v)
	        end
        end
    end

    local function onClickButton(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if rState == 1 then
        	acCashGiftBagVoApi:requestReward(function()
                for k, v in pairs(rewardTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                    if v.type == "h" then --添加将领魂魄
                        if v.key and string.sub(v.key, 1, 1) == "s" then
                            heroVoApi:addSoul(v.key, tonumber(v.num))
                        end
                    end
                end
                G_showRewardTip(rewardTb)
                -- if self.rewardTv then
                --     local recordPoint = self.rewardTv:getRecordPoint()
                --     self.rewardTv:reloadData()
                --     self.rewardTv:recoverToRecordPoint(recordPoint)
                -- end
            end, data.index)
        else
        	G_rechargeHandler(data.recharge, data.cost, data.name, self.layerNum)
        end
    end
    local btnStr = G_getPlatStoreCfg()["moneyType"][GetMoneyName()] .. data.cost
    if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
        btnStr = data.cost .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
    end
    local btnEnabled = true
    local btnImage1, btnImage2 = "creatRoleBtn.png", "creatRoleBtn_Down.png"
    if rState == 1 then --可领取
        btnStr = getlocal("daily_scene_get")
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
        if oldPriceLb then
            oldPriceLb:removeFromParentAndCleanup(true)
            oldPriceLb = nil
        end
    elseif rState == 2 and rNum >= data.limit then --已领取
        btnStr = getlocal("activity_hadReward")
        btnEnabled = false
        btnImage1, btnImage2 = "newGreenBtn.png", "newGreenBtn_down.png"
        if oldPriceLb then
            oldPriceLb:removeFromParentAndCleanup(true)
            oldPriceLb = nil
        end
    end
    local btnScale = 0.6
    local button = GetButtonItem(btnImage1, btnImage2, btnImage1, onClickButton, 11, btnStr, 24 / btnScale)
    local btnMenu = CCMenu:createWithItem(button)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    cellBg:addChild(btnMenu)
    button:setScale(btnScale)
    button:setAnchorPoint(ccp(1, 0))
    button:setPosition(ccp(cellBg:getContentSize().width - 20, 45))
    button:setEnabled(btnEnabled)
    if oldPriceLb then
        oldPriceLb:setPosition(ccp(button:getPositionX() - button:getContentSize().width * btnScale / 2, button:getPositionY() + button:getContentSize().height * btnScale + 15 + oldPriceLb:getContentSize().height / 2))
        cellBg:addChild(oldPriceLb)
    end
end

function acCashGiftBagDialog:tick()
    if self then
        local vo = acCashGiftBagVoApi:getAcVo()
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        elseif self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
            self.timeLb:setString(acCashGiftBagVoApi:getTimeStr())
        end
    end
end

function acCashGiftBagDialog:dispose()
	local acVo = acCashGiftBagVoApi:getAcVo()
    if acVo then
        acVo.refreshFunc = nil
    end
    self = nil
    -- spriteController:removePlist("public/accessoryImage.plist")
    -- spriteController:removePlist("public/accessoryImage2.plist")
    spriteController:removePlist("public/acMjcsIconImage.plist")
    spriteController:removeTexture("public/acMjcsIconImage.png")
end