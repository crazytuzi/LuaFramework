acCustomDialog = commonDialog:new()

function acCustomDialog:new(layerNum, version)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.version = version
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    G_addResource8888(function()
        spriteController:addPlist("public/acThfb.plist")
        spriteController:addTexture("public/acThfb.png")
    end)
    return nc
end

function acCustomDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function acCustomDialog:initTableView()
    local rData = acCustomVoApi:getUIRandomData(self.version)
    for k, v in pairs(rData) do
        self["imageIndex_" .. k] = v
    end

    local bgColorLayer = CCLayerColor:create(acCustomVoApi:getColorOfBg(self.imageIndex_color))
    bgColorLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 84))
    self.bgLayer:addChild(bgColorLayer)

    local topBg
    G_addResource8888(function()
        topBg = CCSprite:create("public/acci_infoBg_" .. self.imageIndex_infoBg .. ".jpg")
    end)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 84)
    self.bgLayer:addChild(topBg, 1)
    local personSp = CCSprite:createWithSpriteFrameName("acci_person_" .. self.imageIndex_person .. ".png")
    personSp:setPosition(personSp:getContentSize().width / 2, topBg:getContentSize().height / 2)
    topBg:addChild(personSp)
    
    local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("acci_timeBg.png", CCRect(86, 25, 2, 2), function()end)
    timeBg:setContentSize(CCSizeMake(topBg:getContentSize().width, timeBg:getContentSize().height))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(topBg:getContentSize().width / 2, topBg:getContentSize().height)
    topBg:addChild(timeBg)
    local timeLb = GetTTFLabel(acCustomVoApi:getTimeStr(self.version), 20, true)
    timeLb:setPosition(timeBg:getContentSize().width / 2, timeBg:getContentSize().height - timeLb:getContentSize().height / 2)
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
            getlocal("acCustom_i_desc1"),
            getlocal("acCustom_i_desc2"),
        }
        if acCustomVoApi:getActiveType(self.version) == 2 then
            tabStr = {
                getlocal("acCustom_i2_desc1"),
                getlocal("acCustom_i2_desc2"),
            }
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(timeBg:getContentSize().width - 10 - infoBtn:getContentSize().width * infoBtn:getScale() / 2, timeBg:getContentSize().height / 2))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    timeBg:addChild(infoMenu)

    local descStr = acCustomVoApi:getActiveDesc(self.version)
    if descStr and descStr ~= "" then
        local tempSp = CCSprite:createWithSpriteFrameName("acci_descBg_" .. self.imageIndex_descBg .. ".png")
        local descLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("acci_descBg_" .. self.imageIndex_descBg .. ".png", CCRect(tempSp:getContentSize().width / 2 - 1, tempSp:getContentSize().height / 2 - 1, 2, 2), function()end)
        descLbBg:setContentSize(CCSizeMake(topBg:getContentSize().width - personSp:getContentSize().width + 50, tempSp:getContentSize().height))
        descLbBg:setPosition(personSp:getPositionX() + personSp:getContentSize().width / 2 - 60 + descLbBg:getContentSize().width / 2, descLbBg:getContentSize().height / 2 + 75)
        topBg:addChild(descLbBg)
        local descLbTvSize = CCSizeMake(descLbBg:getContentSize().width - 60, descLbBg:getContentSize().height - 20)
        local descLabel = GetTTFLabelWrap(descStr, 22, CCSizeMake(descLbTvSize.width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        local descLbTvCellHeight = descLbTvSize.height
        if descLabel:getContentSize().height > descLbTvSize.height then
            descLbTvCellHeight = descLabel:getContentSize().height
        end
        local function descLbTvHandler(handler, fn, idx, cel)
            if fn == "numberOfCellsInTableView" then
                return 1
            elseif fn == "tableCellSizeForIndex" then
                return CCSizeMake(descLbTvSize.width, descLbTvCellHeight)
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                descLabel:setPosition(descLbTvSize.width / 2, descLbTvCellHeight / 2)
                cell:addChild(descLabel)
                return cell
            elseif fn == "ccTouchBegan" then
                return true
            elseif fn == "ccTouchMoved" then
            elseif fn == "ccTouchEnded" then
            end
        end
        local descLbTv = LuaCCTableView:createWithEventHandler(LuaEventHandler:createHandler(function(...) return descLbTvHandler(...) end), descLbTvSize, nil)
        descLbTv:setPosition(ccp((descLbBg:getContentSize().width - descLbTvSize.width) / 2, (descLbBg:getContentSize().height - descLbTvSize.height) / 2))
        descLbTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
        descLbTv:setMaxDisToBottomOrTop(0)
        descLbBg:addChild(descLbTv)
    end

    local topBgLine = LuaCCScale9Sprite:createWithSpriteFrameName("acci_infoBgLine.png", CCRect(168, 3, 2, 2), function()end)
    topBgLine:setContentSize(CCSizeMake(topBg:getContentSize().width, topBgLine:getContentSize().height))
    topBgLine:setPosition(topBg:getContentSize().width / 2, 0)
    topBg:addChild(topBgLine)
    
    local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, topBg:getPositionY() - topBg:getContentSize().height - 25))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height - 10)
    self.bgLayer:addChild(tableViewBg)
    tableViewBg:setOpacity(0)
    
    self:initListData()
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tv:setPosition(ccp(3, 3))
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.tv)
end

function acCustomDialog:initListData()
    self.shopList = acCustomVoApi:getShopList(self.version)
    if self.shopList then
        local acType = acCustomVoApi:getActiveType(self.version)
        local tempTb1, tempTb2 = {}, {}
        for k, v in pairs(self.shopList) do
            if acCustomVoApi:getBuyNum(v.index, self.version) >= ((acType == 2) and 1 or v.limit) then
                table.insert(tempTb2, v)
            else
                table.insert(tempTb1, v)
            end
        end
        if acType == 2 then
            table.sort(tempTb1, function(a, b) return a.limit < b.limit end)
        end
        self.shopList = {}
        for k, v in pairs(tempTb1) do
            table.insert(self.shopList, v)
        end
        for k, v in pairs(tempTb2) do
            table.insert(self.shopList, v)
        end
        tempTb1 = nil
        tempTb2 = nil
    end
    self.cellNum = SizeOfTable(self.shopList or {})
    if self.tv then
        self.tv:reloadData()
    end
end

function acCustomDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 150)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellW, cellH = self.tvSize.width, 150
        
        local data = self.shopList[idx + 1]
        if data == nil then
            do return cell end
        end
        local cellBg = CCSprite:createWithSpriteFrameName("acci_cellBg_" .. self.imageIndex_cellBg .. ".png")
        cellBg:setPosition(cellW / 2, cellH / 2)
        cellBg:setColor(acCustomVoApi:getColorOfCellBg(self.imageIndex_color))
        cell:addChild(cellBg)
        
        local buyNum = acCustomVoApi:getBuyNum(data.index, self.version)
        local nameLbStr
        if acCustomVoApi:getActiveType(self.version) == 2 then
            nameLbStr = getlocal("activity_ramadan_recharge2", {data.limit}) .. "(" .. acCustomVoApi:getRechargeGoldNum(self.version) .. "/" .. data.limit .. ")"
        else
            nameLbStr = data.name .. "(" .. buyNum .. "/" .. data.limit .. ")"
        end
        local nameLb = GetTTFLabel(nameLbStr, 22, true)
        nameLb:setAnchorPoint(ccp(0.5, 1))
        nameLb:setPosition(cellBg:getContentSize().width / 2, cellBg:getContentSize().height - 3)
        nameLb:setColor(ccc3(253, 230, 134))
        cellBg:addChild(nameLb)

        local giftSp = CCSprite:createWithSpriteFrameName("packs" .. self.imageIndex_gift .. ".png")
        giftSp:setAnchorPoint(ccp(0, 0.5))
        giftSp:setPosition(25, cellBg:getContentSize().height / 2)
        cellBg:addChild(giftSp)
        
        local rewardTb
        if data.reward then
            rewardTb = {}
            local iconSize = 70
            local iconSpaceX = 15
            for k, v in pairs(data.reward) do
                v = FormatItem(v, nil, true)[1]
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
                icon:setPosition(giftSp:getPositionX() + giftSp:getContentSize().width * giftSp:getScale() + 25 + icon:getContentSize().width * scale / 2 + (k - 1) * (iconSpaceX + icon:getContentSize().width * scale), iconSize / 2 + 20)
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
        
        local buyPrice = data.cost
        local function buyHandler(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if acCustomVoApi:getActiveType(self.version) == 2 then
                if acCustomVoApi:getRechargeGoldNum(self.version) < data.limit then
                    activityAndNoteDialog:closeAllDialog()
                    -- closeDialog()
                    vipVoApi:showRechargeDialog(self.layerNum + 1)
                else
                    local count = 1
                    acCustomVoApi:requestBuy(function()
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("receivereward_received_success"), 30)
                        if rewardTb then
                            local rewardTipTb = {}
                            for k, v in pairs(rewardTb) do
                                v.num = count * v.num
                                table.insert(rewardTipTb, v)
                                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                if v.type == "h" then --添加加将领魂魄
                                    if v.key and string.sub(v.key, 1, 1) == "s" then
                                        heroVoApi:addSoul(v.key, tonumber(v.num))
                                    end
                                end
                            end
                            G_showRewardTip(rewardTipTb, true)
                        end
                        self:initListData()
                    end, data.index, self.version, count)
                end
            else
                local gems = playerVoApi:getGems()
                if gems < buyPrice then
                    GemsNotEnoughDialog(nil, nil, buyPrice - gems, self.layerNum + 1, buyPrice)
                    do return end
                end
                local function sureTips(count)
                    count = count or 1
                    local costPrice = count * buyPrice
                    local function onSureLogic()
                        acCustomVoApi:requestBuy(function()
                            playerVoApi:setGems(playerVoApi:getGems() - costPrice)
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vip_tequanlibao_goumai_success"), 30)
                            if rewardTb then
                                local rewardTipTb = {}
                                for k, v in pairs(rewardTb) do
                                    v.num = count * v.num
                                    table.insert(rewardTipTb, v)
                                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                                    if v.type == "h" then --添加加将领魂魄
                                        if v.key and string.sub(v.key, 1, 1) == "s" then
                                            heroVoApi:addSoul(v.key, tonumber(v.num))
                                        end
                                    end
                                end
                                G_showRewardTip(rewardTipTb, true)
                            end
                            self:initListData()
                        end, data.index, self.version, count)
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("buyAndUsePropStr", {costPrice, data.name}), nil, self.layerNum + 1)
                end
                require "luascript/script/game/scene/gamedialog/useOrBuyPropSmallDialog"
                useOrBuyPropSmallDialog:showBatchBuyProp(self.layerNum + 1, sureTips, data.name, buyPrice, data.limit - buyNum)
            end
        end
        local btnScale = 0.55
        local btnPic1, btnPic2, btnStr
        if acCustomVoApi:getActiveType(self.version) == 2 then
            if acCustomVoApi:getBuyNum(data.index, self.version) > 0 then
                btnPic1, btnPic2, btnStr = "newGreenBtn.png", "newGreenBtn_down.png", getlocal("activity_hadReward")
            else
                if acCustomVoApi:getRechargeGoldNum(self.version) < data.limit then
                    btnPic1, btnPic2, btnStr = "creatRoleBtn.png", "creatRoleBtn_Down.png", getlocal("recharge")
                else
                    btnPic1, btnPic2, btnStr = "newGreenBtn.png", "newGreenBtn_down.png", getlocal("daily_scene_get")
                end
            end
        else
            btnPic1, btnPic2, btnStr = "creatRoleBtn.png", "creatRoleBtn_Down.png", getlocal("buy")
        end
        local buyBtn = GetButtonItem(btnPic1, btnPic2, btnPic1, buyHandler, 11, btnStr, 24 / btnScale)
        buyBtn:setScale(btnScale)
        buyBtn:setAnchorPoint(ccp(1, 0.5))
        local menu = CCMenu:createWithItem(buyBtn)
        menu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
        menu:setPosition(ccp(cellBg:getContentSize().width - 5, cellBg:getContentSize().height / 2 - 25))
        cellBg:addChild(menu)
        if acCustomVoApi:getActiveType(self.version) == 2 then
            if acCustomVoApi:getBuyNum(data.index, self.version) > 0 then
                buyBtn:setEnabled(false)
            else
                if acCustomVoApi:getRechargeGoldNum(self.version) >= data.limit then
                    local tipsIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
                    tipsIcon:setAnchorPoint(ccp(0.8, 0.8))
                    tipsIcon:setPosition(buyBtn:getContentSize().width, buyBtn:getContentSize().height)
                    buyBtn:addChild(tipsIcon, 5)
                end
            end
        else
            if buyNum >= data.limit then
                buyBtn:setEnabled(false)
            end
            local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setAnchorPoint(ccp(1, 0))
            goldIcon:setPosition(menu:getPositionX() - buyBtn:getContentSize().width * btnScale / 2, menu:getPositionY() + buyBtn:getContentSize().height * btnScale / 2)
            cellBg:addChild(goldIcon)
            local goldNumLb = GetTTFLabel(tostring(buyPrice), 18, true)
            goldNumLb:setAnchorPoint(ccp(0, 0.5))
            goldNumLb:setPosition(goldIcon:getPositionX(), goldIcon:getPositionY() + goldIcon:getContentSize().height * goldIcon:getScale() / 2)
            cellBg:addChild(goldNumLb)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function acCustomDialog:tick()
    if self then
        local vo = acCustomVoApi:getAcVo(self.version)
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        elseif self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
            self.timeLb:setString(acCustomVoApi:getTimeStr(self.version))
        end
    end
end

function acCustomDialog:dispose()
    self = nil
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
end