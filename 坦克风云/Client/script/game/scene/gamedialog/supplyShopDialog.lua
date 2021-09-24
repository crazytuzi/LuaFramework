supplyShopDialog = smallDialog:new()

function supplyShopDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.selectedTabIndex = 1
    G_addResource8888(function()
            spriteController:addPlist("public/datebaseShow.plist")
            spriteController:addPlist("public/accessoryImage.plist")
            spriteController:addPlist("public/accessoryImage2.plist")
    end)
    return nc
end

function supplyShopDialog:showSupplyShopDialog(layerNum, titleStr)
    local sd = supplyShopDialog:new()
    sd:initSupplyShopDialog(layerNum, titleStr)
    return sd
end

function supplyShopDialog:initSupplyShopDialog(layerNum, titleStr)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 680)
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 55))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("steward_titleBg.png", CCRect(215, 30, 1, 1), function()end)
    titleBg:setContentSize(CCSizeMake(self.bgSize.width + 40, titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0.5, 0))
    titleBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 20)
    self.bgLayer:addChild(titleBg)
    local tipsTimeBg = LuaCCScale9Sprite:createWithSpriteFrameName("ssi_tipsTimeBg.png", CCRect(55, 45, 5, 10), function()end)
    tipsTimeBg:setContentSize(CCSizeMake(400, tipsTimeBg:getContentSize().height))
    tipsTimeBg:setPosition(150 + tipsTimeBg:getContentSize().width / 2, 76 + tipsTimeBg:getContentSize().height / 2)
    titleBg:addChild(tipsTimeBg)

    self.tipsTimeLb = GetTTFLabelWrap(getlocal("supplyShop_nextRefreshTipsTimer"), 22, CCSizeMake(tipsTimeBg:getContentSize().width / 2 + 30, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    local tipsClipper = CCClippingNode:create()
    tipsClipper:setContentSize(CCSizeMake(tipsTimeBg:getContentSize().width, self.tipsTimeLb:getContentSize().height + 10))
    tipsClipper:setAnchorPoint(ccp(0.5, 0.5))
    tipsClipper:setPosition(tipsTimeBg:getContentSize().width / 2, tipsTimeBg:getContentSize().height / 2 + 13)
    tipsClipper:setStencil(CCDrawNode:getAPolygon(tipsClipper:getContentSize(), 1, 1))
    tipsTimeBg:addChild(tipsClipper)

    self.tipsTimeLb:setAnchorPoint(ccp(1, 0.5))
    self.tipsTimeLb:setPosition(15 + self.tipsTimeLb:getContentSize().width, tipsClipper:getContentSize().height / 2)
    -- self.tipsTimeLb:setPosition(15 + self.tipsTimeLb:getContentSize().width, tipsTimeBg:getContentSize().height / 2 + 13)
    -- tipsTimeBg:addChild(self.tipsTimeLb)
    tipsClipper:addChild(self.tipsTimeLb)
    self.timeLb = GetTTFLabel("", 22, true)
    self.timeLb:setAnchorPoint(ccp(0, 0.5))
    self.timeLb:setPosition(self.tipsTimeLb:getPosition())
    self.timeLb:setColor(G_ColorYellowPro)
    -- tipsTimeBg:addChild(self.timeLb)
    tipsClipper:addChild(self.timeLb)

    self.customNumLb = GetTTFLabelWrap("", 22, CCSizeMake(tipsClipper:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    self.customNumLb:setAnchorPoint(ccp(0.5, 0.5))
    self.customNumLb:setPosition(tipsClipper:getContentSize().width / 2, -self.tipsTimeLb:getContentSize().height / 2 - 5)
    self.customNumLb:setColor(G_ColorYellowPro)
    tipsClipper:addChild(self.customNumLb)

    if G_getCurChoseLanguage() == "ar" then
        self.tipsTimeLb:setPositionX(self.tipsTimeLb:getPositionX() + 50)
        self.timeLb:setPositionX(self.timeLb:getPositionX() - 200)
    end
    
    local function closeBtnHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:closeDialog()
    end
    local closeBtn = GetButtonItem("steward_closeBtn.png", "steward_closeBtn_down.png", "steward_closeBtn.png", closeBtnHandler)
    closeBtn:setAnchorPoint(ccp(1, 0))
    local menu = CCMenu:createWithItem(closeBtn)
    menu:setTouchPriority( - (layerNum - 1) * 20 - 4)
    menu:setPosition(titleBg:getContentSize().width - 20, 66)
    titleBg:addChild(menu)
    local titleLb = GetTTFLabel(titleStr, 32, true)
    titleLb:setPosition((titleBg:getContentSize().width + 200) / 2, 34)
    titleBg:addChild(titleLb)
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr
        if self.selectedTabIndex == 1 then
            tabStr = {
                getlocal("supplyShop_tab1Info1"), 
                getlocal("supplyShop_tab1Info2"), 
                getlocal("supplyShop_tab1Info3"), 
            }
        else
            tabStr = {
                getlocal("supplyShop_tab2Info1"), 
                getlocal("supplyShop_tab2Info2"), 
                getlocal("supplyShop_tab2Info3"), 
                getlocal("supplyShop_tab2Info4"), 
                getlocal("supplyShop_tab2Info5"), 
            }
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setScale(0.6)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(self.bgSize.width - 20 - infoBtn:getContentSize().width * infoBtn:getScale() / 2, self.bgSize.height - 60))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoMenu)
    
    local function tabClick(idx)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:tabClick(idx)
    end
    self.allTabData = {}
    local tabTitleTb = { getlocal("dailyUseIt"), getlocal("supplyShop_customSupply"), "" }
    local isCustom = false
    local tab3Data = supplyShopVoApi:getTabData(3)
    if tab3Data and tab3Data.customType > 0 then
        tabTitleTb[3] = getlocal("supplyShop_customItem" .. tab3Data.customType .. "Name")
        isCustom = true
    end
    local tabBtn = CCMenu:create()
    for i, tabTitle in pairs(tabTitleTb) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 1))
        tabBtnItem:setPosition(20 + (i - 1) * (tabBtnItem:getContentSize().width + 4), self.bgSize.height - 35)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)
        
        local strSize = 24
        if G_isAsia() == false then
            if G_isIOS() == true then
                strSize = 20
            else
                strSize = 17
            end 
        end
        local lb = GetTTFLabelWrap(tabTitle, strSize, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
        lb:setTag(11)
        tabBtnItem:addChild(lb, 1)
        
        local tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
        tipIcon:setPosition(tabBtnItem:getContentSize().width - 10, tabBtnItem:getContentSize().height - 5)
        tipIcon:setScale(0.8)
        tipIcon:setTag(10)
        tipIcon:setVisible(false)
        tabBtnItem:addChild(tipIcon)
        if i == 3 and isCustom == false then
            tabBtnItem:setEnabled(false)
            tabBtnItem:setVisible(false)
        end
        
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabData[i] = tabBtnItem
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabBtn, 1)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 110))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 85)
    self.bgLayer:addChild(tvBg)
    self.tvBg = tvBg

    --添加上、下的触摸屏蔽层
    local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    top:setAnchorPoint(ccp(0.5, 0))
    top:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height)
    tvBg:addChild(top, 5)
    top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    top:setVisible(false)

    local bottom = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    bottom:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    bottom:setAnchorPoint(ccp(0.5, 1))
    bottom:setPosition(tvBg:getContentSize().width / 2, 0)
    tvBg:addChild(bottom, 5)
    bottom:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    bottom:setVisible(false)
    
    self:tabClick(self.selectedTabIndex)
    base:addNeedRefresh(self)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function supplyShopDialog:initTableView()
    if self.tv then
        self.tv:removeFromParentAndCleanup(true)
        self.tv = nil
    end
    if self.bottomNode then
        self.bottomNode:removeFromParentAndCleanup(true)
        self.bottomNode = nil
    end
    self.cellNum = 0
    self.tabData = supplyShopVoApi:getTabData(self.selectedTabIndex)
    if self.tabData then
        if self.tabData.itemData then
            self.cellNum = SizeOfTable(self.tabData.itemData)
        end
    end
    
    if self.tipsTimeLb and self.timeLb then
        local tipsClipper = self.tipsTimeLb:getParent()
        if self.tabData.cdTimer == nil then
            tipsClipper:getParent():setVisible(false)
        else
            if self.selectedTabIndex == 1 then
                self.tipsTimeLb:setString(getlocal("supplyShop_nextRefreshTipsTimer"))
            elseif self.selectedTabIndex == 2 then
                self.tipsTimeLb:setString(getlocal("supplyShop_nextTipsTimer"))
            end
            self.timeLb:setString(G_formatActiveDate(self.tabData.cdTimer - base.serverTime))
            tipsClipper:getParent():setVisible(true)
            if self.selectedTabIndex == 1 and self.tabData.cdTimer >= base.serverTime then
                self.isRefreshRes = true
            end
        end

        self.tipsTimeLb:stopAllActions()
        self.timeLb:stopAllActions()
        self.customNumLb:stopAllActions()
        self.tipsTimeLb:setPositionY(tipsClipper:getContentSize().height / 2)
        self.timeLb:setPositionY(self.tipsTimeLb:getPositionY())
        self.customNumLb:setPositionY(-self.tipsTimeLb:getContentSize().height / 2 - 5)
        self.customNumLb:setVisible(false)
        local moveByPosY = tipsClipper:getContentSize().height / 2 + self.tipsTimeLb:getContentSize().height / 2 + 5
        if self.selectedTabIndex == 2 then
            local arry = CCArray:create()
            arry:addObject(CCMoveBy:create(1, ccp(0, moveByPosY)))
            arry:addObject(CCCallFunc:create(function()
                    if self.tipsTimeLb:getPositionY() > tipsClipper:getContentSize().height then
                        self.tipsTimeLb:setPositionY(-self.tipsTimeLb:getContentSize().height / 2 - 5)
                    end
                end))
            arry:addObject(CCDelayTime:create(3.0))
            self.tipsTimeLb:runAction(CCRepeatForever:create(CCSequence:create(arry)))

            local arry = CCArray:create()
            arry:addObject(CCMoveBy:create(1, ccp(0, moveByPosY)))
            arry:addObject(CCCallFunc:create(function()
                    if self.timeLb:getPositionY() > tipsClipper:getContentSize().height then
                        self.timeLb:setPositionY(-self.tipsTimeLb:getContentSize().height / 2 - 5)
                    end
                end))
            arry:addObject(CCDelayTime:create(3.0))
            self.timeLb:runAction(CCRepeatForever:create(CCSequence:create(arry)))

            self.customNumLb:setString(getlocal("supplyShop_todayCustomNum", {self.tabData.customNum .. "/" .. supplyShopVoApi:getMaxCustomNum()}))
            self.customNumLb:setVisible(true)
            local arry = CCArray:create()
            arry:addObject(CCMoveBy:create(1, ccp(0, moveByPosY)))
            arry:addObject(CCCallFunc:create(function()
                        if self.customNumLb:getPositionY() > tipsClipper:getContentSize().height then
                            self.customNumLb:setPositionY(-self.tipsTimeLb:getContentSize().height / 2 - 5)
                        end
                    end))
            arry:addObject(CCDelayTime:create(3.0))
            self.customNumLb:runAction(CCRepeatForever:create(CCSequence:create(arry)))
        end
    end
    
    local tvPosY = 3
    local tvSize = CCSizeMake(self.tvBg:getContentSize().width - 6, self.tvBg:getContentSize().height - 6)
    if self.selectedTabIndex == 3 and self.tabData then
        self.bottomNode = CCNode:create()
        self.bottomNode:setContentSize(CCSizeMake(tvSize.width, 130))
        self.bottomNode:setAnchorPoint(ccp(0, 0))
        self.bottomNode:setPosition(3, 0)
        self.tvBg:addChild(self.bottomNode)
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function()end)
        lineSp:setContentSize(CCSizeMake(self.tvBg:getContentSize().width, lineSp:getContentSize().height))
        lineSp:setAnchorPoint(ccp(0.5, 1))
        lineSp:setPosition(self.bottomNode:getContentSize().width / 2, self.bottomNode:getContentSize().height)
        self.bottomNode:addChild(lineSp)
        local dobulePrice, maxDoubleNum = supplyShopVoApi:getDoublePrice(self.tabData.customType, self.tabData.doubleNum)
        local function onClickBuyBtn(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if self.tabData.doubleNum - 1 >= maxDoubleNum then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("supplyShop_maxDoubleNumTips"), 30)
                do return end
            end
            local gems = playerVoApi:getGems()
            if gems < dobulePrice then
                GemsNotEnoughDialog(nil, nil, dobulePrice - gems, self.layerNum + 1, dobulePrice)
                do return end
            end
            local function onSureLogic()
                supplyShopVoApi:requestDouble(function()
                    playerVoApi:setGems(playerVoApi:getGems() - dobulePrice)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("supplyShop_doubleBuySuccessTips",{self.tabData.doubleNum + 1}), 30)
                    local recordPoint = self.tv:getRecordPoint()
                    self:initTableView()
                    self.tv:recoverToRecordPoint(recordPoint)
                end, self.tabData.customType)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("supplyShop_doubleShopTips",{dobulePrice}), nil, self.layerNum + 1)
        end
        local btnScale = 0.6
        local buyBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuyBtn, 11, getlocal("attribute_upgrade"), 24 / btnScale)
        buyBtn:setScale(btnScale)
        buyBtn:setAnchorPoint(ccp(1, 0))
        local menu = CCMenu:createWithItem(buyBtn)
        menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        menu:setPosition(self.bottomNode:getContentSize().width - 20, 25)
        self.bottomNode:addChild(menu)
        if self.tabData.doubleNum - 1 >= maxDoubleNum then
            buyBtn:setEnabled(false)
        else
            local isEnabled = false
            for k, v in pairs(self.tabData.itemData) do
                if not (v.buyNum and v.buyNum > 0) then
                    isEnabled = true
                    break
                end
            end
            buyBtn:setEnabled(isEnabled)
            if isEnabled then
                local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
                goldIcon:setAnchorPoint(ccp(1, 0))
                goldIcon:setPosition(menu:getPositionX() - buyBtn:getContentSize().width * btnScale / 2, menu:getPositionY() + buyBtn:getContentSize().height * btnScale)
                self.bottomNode:addChild(goldIcon)
                local goldNumLb = GetTTFLabel(tostring(dobulePrice), 18)
                goldNumLb:setAnchorPoint(ccp(0, 0.5))
                goldNumLb:setPosition(goldIcon:getPositionX(), goldIcon:getPositionY() + goldIcon:getContentSize().height * goldIcon:getScale() / 2)
                self.bottomNode:addChild(goldNumLb)
            end
        end
        local curDoubleLb = GetTTFLabel(getlocal("supplyShop_curMultiple", {self.tabData.doubleNum}), 20)
        curDoubleLb:setAnchorPoint(ccp(0, 0))
        curDoubleLb:setPosition(10, 25)
        curDoubleLb:setColor(G_ColorYellowPro)
        self.bottomNode:addChild(curDoubleLb)
        local tipsLb = GetTTFLabel(getlocal("supplyShop_doubleTipsText", {(self.tabData.doubleNum - 1) .. "/" .. maxDoubleNum}), 20)
        tipsLb:setAnchorPoint(ccp(0, 0.5))
        tipsLb:setPosition(10, curDoubleLb:getPositionY() + curDoubleLb:getContentSize().height + (lineSp:getPositionY() - lineSp:getContentSize().height - curDoubleLb:getPositionY() - curDoubleLb:getContentSize().height) / 2)
        tipsLb:setColor(G_ColorYellowPro)
        self.bottomNode:addChild(tipsLb)
        
        tvPosY = self.bottomNode:getContentSize().height
        tvSize.height = tvSize.height - self.bottomNode:getContentSize().height
    end
    local hd = LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    self.tv:setPosition(3, tvPosY)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tvBg:addChild(self.tv)
end

function supplyShopDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.bgSize.width - 46, 120)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = self.bgSize.width - 46, 120
        local index = idx + 1
        
        local data = self.tabData.itemData[index]
        if data then
            if self.selectedTabIndex == 1 or self.selectedTabIndex == 3 then
                local rewardItem = FormatItem(data.rewardItem)
                if rewardItem and rewardItem[1] then
                    if self.selectedTabIndex == 3 then
                        if data.buyNum and data.buyNum > 0 then
                            rewardItem[1].num = rewardItem[1].num * data.buyNum
                        else
                            rewardItem[1].num = rewardItem[1].num * self.tabData.doubleNum
                        end
                    end
                    local iconSize = 95
                    local icon, scale = G_getItemIcon(rewardItem[1], 100, false, self.layerNum, function()
                            G_showNewPropInfo(self.layerNum + 1, true, true, nil, rewardItem[1], nil, nil, nil, nil, true)
                    end)
                    icon:setScale(iconSize / icon:getContentSize().height)
                    scale = icon:getScale()
                    icon:setPosition(10 + iconSize / 2, cellH / 2)
                    icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                    cell:addChild(icon)
                    local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                    nameBg:setContentSize(CCSizeMake(cellW - (icon:getPositionX() + iconSize / 2 + 115), nameBg:getContentSize().height))
                    nameBg:setAnchorPoint(ccp(0, 1))
                    nameBg:setPosition(icon:getPositionX() + iconSize / 2 + 10, icon:getPositionY() + iconSize / 2)
                    cell:addChild(nameBg)
                    local nameLb = GetTTFLabel(rewardItem[1].name .. "x" .. FormatNumber(rewardItem[1].num), (G_isAsia() == false) and 16 or 22, true)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    nameLb:setPosition(15, nameBg:getContentSize().height / 2)
                    nameLb:setColor(G_ColorYellowPro)
                    nameBg:addChild(nameLb)
                    local descStr = getlocal(rewardItem[1].desc)
                    local descWidth = cellW - (nameBg:getPositionX() + 15 + 135)
                    local descHeight = nameBg:getPositionY() - nameBg:getContentSize().height - 10
                    local descLb = GetTTFLabelWrap(descStr, 18, CCSizeMake(descWidth, descHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(nameBg:getPositionX() + 15, nameBg:getPositionY() - nameBg:getContentSize().height)
                    cell:addChild(descLb)
                    if data.buyNum and data.buyNum > 0 then
                    	local stateLb = GetTTFLabel(getlocal("supplyShop_sellOut"), 20)
                    	stateLb:setPosition(cellW - 75, cellH / 2 - 10)
                    	stateLb:setColor(G_ColorRed)
                    	cell:addChild(stateLb)
                    else
	                    local costItem = FormatItem(data.costItem)
	                    local costNum = 0
                        local isCostGems = false
	                    if costItem and costItem[1] then
	                        costNum = costItem[1].num
                            if costItem[1].type == "u" and (costItem[1].key == "gem" or costItem[1].key == "gems") then
                                isCostGems = true
                            end
	                    end
                        if self.selectedTabIndex == 3 then
                            costNum = costNum * self.tabData.doubleNum
                        end
                        local function getPlayerResNum(resKey)
                            local selfResNum = 0
                            if resKey == "r1" then
                                selfResNum = playerVoApi:getR1()
                            elseif resKey == "r2" then
                                selfResNum = playerVoApi:getR2()
                            elseif resKey == "r3" then
                                selfResNum = playerVoApi:getR3()
                            elseif resKey == "r4" then
                                selfResNum = playerVoApi:getR4()
                            elseif resKey == "gold" then
                                selfResNum = playerVoApi:getGold()
                            end
                            return selfResNum
                        end
	                    local function onClickBuyBtn(tag, obj)
	                        if G_checkClickEnable() == false then
	                            do return end
	                        else
	                            base.setWaitTime = G_getCurDeviceMillTime()
	                        end
	                        PlayEffect(audioCfg.mouseClick)
                            if isCostGems then
                                local gems = playerVoApi:getGems()
                                if gems < costNum then
                                    GemsNotEnoughDialog(nil, nil, costNum - gems, self.layerNum + 1, costNum)
                                    do return end
                                end
                            else
                                if costItem[1].type == "u" then
                                    if getPlayerResNum(costItem[1].key) < costNum then
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("resourcelimit"), 30)
                                        do return end
                                    end
                                end
                            end


                            local function confirmHandler( ... )
                                supplyShopVoApi:requestBuy(function()
                                        if isCostGems then
                                            playerVoApi:setGems(playerVoApi:getGems() - costNum)
                                        else
                                            if costItem[1].type == "u" then
                                                local costR1, costR2, costR3, costR4, gold = 0, 0, 0, 0, 0
                                                if costItem[1].key == "r1" then
                                                    costR1 = costNum
                                                elseif costItem[1].key == "r2" then
                                                    costR2 = costNum
                                                elseif costItem[1].key == "r3" then
                                                    costR3 = costNum
                                                elseif costItem[1].key == "r4" then
                                                    costR4 = costNum
                                                elseif costItem[1].key == "gold" then
                                                    gold = costNum
                                                end
                                                playerVoApi:useResource(costR1, costR2, costR3, costR4, gold, 0)
                                            end
                                        end
                                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vip_tequanlibao_goumai_success"), 30)
                                        if rewardItem[1].type == "h" then --添加将领魂魄
                                            if rewardItem[1].key and string.sub(rewardItem[1].key,1,1) == "s" then
                                                heroVoApi:addSoul(rewardItem[1].key, tonumber(rewardItem[1].num))
                                            end
                                        else
                                            G_addPlayerAward(rewardItem[1].type, rewardItem[1].key, rewardItem[1].id, rewardItem[1].num, true, true)
                                        end
                                        local recordPoint = self.tv:getRecordPoint()
                                        self:initTableView()
                                        self.tv:recoverToRecordPoint(recordPoint)
                                end, (self.selectedTabIndex == 1) and 1 or 2, (self.selectedTabIndex == 1) and (data.id .. "_" .. index) or tostring(data.id))
                            end
                            if isCostGems then
                                local keyName = "supply_Shop"
                                local function secondTipFunc(sbFlag)
                                    local sValue=base.serverTime .. "_" .. sbFlag
                                    G_changePopFlag(keyName,sValue)
                                end
                                if G_isPopBoard(keyName) then
                                   G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{costNum}),true,confirmHandler,secondTipFunc)
                                else
                                    confirmHandler()
                                end
                            else
                                confirmHandler()
                            end
	                    end
	                    local btnScale = 0.6
	                    local buyBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuyBtn, 11, getlocal("buy"), 24 / btnScale)
	                    buyBtn:setScale(btnScale)
	                    buyBtn:setAnchorPoint(ccp(1, 0))
	                    local menu = CCMenu:createWithItem(buyBtn)
	                    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	                    menu:setPosition(cellW - 10, icon:getPositionY() - iconSize / 2)
	                    cell:addChild(menu)
	                    if costItem and costItem[1] then
                            local pic = G_getResourceIcon(costItem[1].key)
	                        local costIcon = CCSprite:createWithSpriteFrameName(pic)
	                        costIcon:setScale(30 / costIcon:getContentSize().height)
	                        costIcon:setAnchorPoint(ccp(1, 0))
	                        costIcon:setPosition(menu:getPositionX() - buyBtn:getContentSize().width * btnScale / 2, menu:getPositionY() + buyBtn:getContentSize().height * btnScale)
	                        cell:addChild(costIcon)
	                        local costNumLb = GetTTFLabel(FormatNumber(costNum), 18)
	                        costNumLb:setAnchorPoint(ccp(0, 0.5))
	                        costNumLb:setPosition(costIcon:getPositionX(), costIcon:getPositionY() + costIcon:getContentSize().height * costIcon:getScale() / 2)
	                        cell:addChild(costNumLb)
                            if self.selectedTabIndex == 1 then
                                if costItem[1].type == "u" then
                                    if getPlayerResNum(costItem[1].key) < costNum then
                                        costNumLb:setColor(G_ColorRed)
                                    end
                                end
                            end
                            if self.selectedTabIndex == 3 and data.dis then
                                local discountIcon = CCSprite:createWithSpriteFrameName(pic)
                                discountIcon:setScale(30 / discountIcon:getContentSize().height)
                                discountIcon:setAnchorPoint(ccp(1, 0))
                                discountIcon:setPosition(costIcon:getPositionX(), costIcon:getPositionY() + costIcon:getContentSize().height * costIcon:getScale())
                                cell:addChild(discountIcon)
                                local discountLb = GetTTFLabel(FormatNumber(math.ceil((costNum / data.dis))), 18)
                                discountLb:setAnchorPoint(ccp(0, 0.5))
                                discountLb:setPosition(discountIcon:getPositionX(), discountIcon:getPositionY() + discountIcon:getContentSize().height * discountIcon:getScale() / 2)
                                discountLb:setColor(G_ColorRed)
                                cell:addChild(discountLb)
                                local redLine = GetTTFLabel("-", 18, true)
                                redLine:setScaleX(discountLb:getContentSize().width / redLine:getContentSize().width)
                                redLine:setPosition(discountLb:getPositionX() + discountLb:getContentSize().width / 2, discountLb:getPositionY())
                                redLine:setColor(G_ColorRed)
                                cell:addChild(redLine)
                            end
	                    end
	                end
                end
            elseif self.selectedTabIndex == 2 then
                local iconBg = LuaCCSprite:createWithSpriteFrameName("ssi_customBg.png", function()
                        supplyShopDialog:showSupplyShopPreviewDialog(self.layerNum + 1, getlocal("supplyShop_previewTitle"), data.unlockItem)
                end)
                local icon = CCSprite:createWithSpriteFrameName("ssi_customIcon" .. index .. ".png")
                icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
                iconBg:addChild(icon)
                local lensSp = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
                lensSp:setAnchorPoint(ccp(1, 0))
                lensSp:setPosition(iconBg:getContentSize().width - 5, 5)
                iconBg:addChild(lensSp)
                iconBg:setPosition(10 + iconBg:getContentSize().width / 2, cellH / 2)
                iconBg:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                cell:addChild(iconBg)
                local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                nameBg:setContentSize(CCSizeMake(cellW - (iconBg:getPositionX() + iconBg:getContentSize().width / 2 + 115), nameBg:getContentSize().height))
                nameBg:setAnchorPoint(ccp(0, 1))
                nameBg:setPosition(iconBg:getPositionX() + iconBg:getContentSize().width / 2 + 10, iconBg:getPositionY() + iconBg:getContentSize().height / 2)
                cell:addChild(nameBg)
                local nameLb = GetTTFLabel(getlocal("supplyShop_customItem" .. index .. "Name"), (G_isAsia() == false) and 16 or 22, true)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(15, nameBg:getContentSize().height / 2)
                nameLb:setColor(G_ColorYellowPro)
                nameBg:addChild(nameLb)
                local maxCustomNum = supplyShopVoApi:getMaxCustomNum()
                local customPrice = supplyShopVoApi:getCustomPrice(self.tabData.customNum)
                local function onClickBuyBtn(tag, obj)
                    if G_checkClickEnable() == false then
                        do return end
                    else
                        base.setWaitTime = G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if self.tabData.customNum >= maxCustomNum then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("supplyShop_maxCustomNumTips"), 30)
                        do return end
                    end
                    if customPrice > 0 then
                        local gems = playerVoApi:getGems()
                        if gems < customPrice then
                            GemsNotEnoughDialog(nil, nil, customPrice - gems, self.layerNum + 1, customPrice)
                            do return end
                        end
                    end
                    local function onSureLogic()
                        supplyShopVoApi:requestCustomBuy(function()
                                if customPrice > 0 then
                                    playerVoApi:setGems(playerVoApi:getGems() - customPrice)
                                end
                                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vip_tequanlibao_goumai_success"), 30)
                                --关闭第二个页签的红点
                                if self.allTabData[2] then
                                    local tipIcon = tolua.cast(self.allTabData[2]:getChildByTag(10), "CCSprite")
                                    tipIcon:setVisible(false)
                                end
                                --开启第三个页签
                                if self.allTabData[3] then
                                    local tabTitleLb = tolua.cast(self.allTabData[3]:getChildByTag(11), "CCLabelTTF")
                                    if tabTitleLb then
                                        local tab3Data = supplyShopVoApi:getTabData(3)
                                        if tab3Data and tab3Data.customType > 0 then
                                            tabTitleLb:setString(getlocal("supplyShop_customItem" .. tab3Data.customType .. "Name"))
                                        end
                                    end
                                    self.allTabData[3]:setEnabled(true)
                                    self.allTabData[3]:setVisible(true)
                                end
                                self:tabClick(3)
                        end, index)
                    end
                    if customPrice > 0 then
                        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("supplyShop_customBuySureTips",{customPrice}), nil, self.layerNum + 1)
                    else
                        onSureLogic()
                    end
                end
                local btnScale = 0.6
                local btnNormal, btnDown = "newGreenBtn.png", "newGreenBtn_down.png"
                if customPrice > 0 then
                    btnNormal, btnDown = "creatRoleBtn.png", "creatRoleBtn_Down.png"
                end
                local buyBtn = GetButtonItem(btnNormal, btnDown, btnNormal, onClickBuyBtn, 11, getlocal("supplyShop_customBuy"), 24 / btnScale)
                buyBtn:setScale(btnScale)
                buyBtn:setAnchorPoint(ccp(1, 0))
                local menu = CCMenu:createWithItem(buyBtn)
                menu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                menu:setPosition(cellW - 10, iconBg:getPositionY() - iconBg:getContentSize().height / 2)
                cell:addChild(menu)
                if playerVoApi:getPlayerLevel() < data.unlockLv then
                    buyBtn:setEnabled(false)
                    local lockLbWidth = cellW - (nameBg:getPositionX() + 15 + 135)
                    local lockLb = GetTTFLabelWrap(getlocal("expeditionunlockLv", {data.unlockLv}), 20, CCSizeMake(lockLbWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                    lockLb:setAnchorPoint(ccp(0, 0.5))
                    lockLb:setPosition(nameBg:getPositionX() + 15, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2 + 5)
                    lockLb:setColor(G_ColorRed)
                    cell:addChild(lockLb)
                else
                    local descLbFontSize = 18
                    if G_getCurChoseLanguage() == "en" then
                        if G_isIOS() == true then
                            descLbFontSize = 15
                        else
                            descLbFontSize = 12
                        end
                    elseif G_getCurChoseLanguage() == "ja" then
                        descLbFontSize = 16
                    end
                    local descWidth = cellW - (nameBg:getPositionX() + 15 + 135)
                    local descLb = GetTTFLabelWrap(getlocal("supplyShop_customItem" .. index .. "Desc"), descLbFontSize, CCSizeMake(descWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(nameBg:getPositionX() + 15, nameBg:getPositionY() - nameBg:getContentSize().height)
                    cell:addChild(descLb)
                    if self.tabData.customNum >= maxCustomNum then
                        buyBtn:setEnabled(false)
                    elseif customPrice > 0 then
                        local costIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
                        costIcon:setAnchorPoint(ccp(1, 0))
                        costIcon:setPosition(menu:getPositionX() - buyBtn:getContentSize().width * btnScale / 2, menu:getPositionY() + buyBtn:getContentSize().height * btnScale)
                        cell:addChild(costIcon)
                        local costNumLb = GetTTFLabel(FormatNumber(customPrice), 18)
                        costNumLb:setAnchorPoint(ccp(0, 0.5))
                        costNumLb:setPosition(costIcon:getPositionX(), costIcon:getPositionY() + costIcon:getContentSize().height * costIcon:getScale() / 2)
                        cell:addChild(costNumLb)
                    end
                end
            end
        end
        
        if index < self.cellNum then
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
            lineSp:setContentSize(CCSizeMake(cellW - 20, 4))
            lineSp:setPosition(cellW / 2, 0)
            cell:addChild(lineSp)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function supplyShopDialog:tabClick(idx)
    for k, v in pairs(self.allTabData) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            self:initTableView()
        else
            v:setEnabled(true)
        end
    end
end

function supplyShopDialog:tick()
    if self and tolua.cast(self.bgLayer, "CCNode") then
        if self.tipsTimeLb and self.timeLb then
            if self.tabData and self.tabData.cdTimer then
                self.timeLb:setString(G_formatActiveDate(self.tabData.cdTimer - base.serverTime))
                if self.selectedTabIndex == 1 and self.tabData.cdTimer < base.serverTime and self.isRefreshRes then
                    self.isRefreshRes = nil
                    supplyShopVoApi:requestData(function()
                        self:initTableView()
                    end)
                end
            end
        end

        --判断第二个页签的红点显示
        local tab2Data = supplyShopVoApi:getTabData(2)
        if tab2Data and tab2Data.cdTimer and tab2Data.cdTimer < base.serverTime then
	        if self.allTabData[2] then
	        	local tipIcon = tolua.cast(self.allTabData[2]:getChildByTag(10), "CCSprite")
                tipIcon:setVisible(true)
                if self.selectedTabIndex == 2 and tab2Data.customNum ~= 0 then
                    supplyShopVoApi:resetCustomNum()
                    self:initTableView()
                end
	        end
    	end
    end
end

function supplyShopDialog:closeDialog()
    base:removeFromNeedRefresh(self)
    self:close()
end

function supplyShopDialog:dispose()
    self = nil
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removePlist("public/accessoryImage.plist")
    spriteController:removePlist("public/accessoryImage2.plist")
end

------------------------------------------------------补给预览------------------------------------------------------

function supplyShopDialog:showSupplyShopPreviewDialog(layerNum, titleStr, params)
    local sd = supplyShopDialog:new()
    sd:initSupplyShopPreviewDialog(layerNum, titleStr, params)
    return sd
end

function supplyShopDialog:initSupplyShopPreviewDialog(layerNum, titleStr, params)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 580)
    self.bgLayer = G_getNewDialogBg2(self.bgSize, layerNum, nil, titleStr, 28, nil, "Helvetica-bold")
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 55))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local tipsLb = GetTTFLabelWrap(getlocal("supplyShop_previewTips"), 20, CCSizeMake(self.bgSize.width - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    tipsLb:setAnchorPoint(ccp(0.5, 1))
    tipsLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 30)
    tipsLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipsLb)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, tipsLb:getPositionY() - tipsLb:getContentSize().height - 30))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, tipsLb:getPositionY() - tipsLb:getContentSize().height - 10)
    self.bgLayer:addChild(tvBg)

    local cellNum = SizeOfTable(params or {})
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvBg:getContentSize().height - 6)
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvSize.width, 100)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH = tvSize.width, 100
            local reward, unlockLv
            for k, v in pairs(params[idx + 1]) do
            	if k == "unlock" then
            		unlockLv = v
            	else
            		reward = FormatItem({[k] = v})
            	end
            end
            unlockLv = unlockLv or 0
            if reward and reward[1] then
            	local iconSize = 90
                local icon, scale = G_getItemIcon(reward[1], 100, false, self.layerNum, function()
                        G_showNewPropInfo(self.layerNum + 1, true, true, nil, reward[1], nil, nil, nil, nil, true)
                end)
                icon:setScale(iconSize / icon:getContentSize().height)
                scale = icon:getScale()
                icon:setPosition(5 + iconSize / 2, cellH / 2)
                icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                cell:addChild(icon)
                local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
                nameBg:setContentSize(CCSizeMake(cellW - (icon:getPositionX() + iconSize / 2 + 115), nameBg:getContentSize().height))
                nameBg:setAnchorPoint(ccp(0, 1))
                nameBg:setPosition(icon:getPositionX() + iconSize / 2 + 10, icon:getPositionY() + iconSize / 2)
                cell:addChild(nameBg)
                local nameLb = GetTTFLabel(reward[1].name, (G_isAsia() == false) and 16 or 22, true)
                nameLb:setAnchorPoint(ccp(0, 0.5))
                nameLb:setPosition(15, nameBg:getContentSize().height / 2)
                nameLb:setColor(G_ColorYellowPro)
                nameBg:addChild(nameLb)
                local descWidth = cellW - (nameBg:getPositionX() + 15 + 15)
                if playerVoApi:getPlayerLevel() < unlockLv then
                	local unlockLb = GetTTFLabelWrap(getlocal("expeditionunlockLv", {tostring(unlockLv)}), 22, CCSizeMake(descWidth, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
                	unlockLb:setAnchorPoint(ccp(0, 0.5))
                	unlockLb:setPosition(nameBg:getPositionX() + 15, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2)
                	unlockLb:setColor(G_ColorRed)
                	cell:addChild(unlockLb)
                else
                    local descLbFontSize = 18
                    if G_getCurChoseLanguage() == "en" then
                        if G_isIOS() == true then
                            descLbFontSize = 14
                        else
                            descLbFontSize = 12
                        end
                    elseif G_getCurChoseLanguage() == "ar" then
                        if G_isIOS() == true then
                        else
                            descLbFontSize = 16
                        end
                    elseif G_getCurChoseLanguage() == "ja" then
                        descLbFontSize = 16
                    end
	                local descLb = GetTTFLabelWrap(getlocal(reward[1].desc), descLbFontSize, CCSizeMake(descWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	                descLb:setAnchorPoint(ccp(0, 1))
	                descLb:setPosition(nameBg:getPositionX() + 15, nameBg:getPositionY() - nameBg:getContentSize().height)
	                cell:addChild(descLb)
	            end
            end
            if idx + 1 < cellNum then
	            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
	            lineSp:setContentSize(CCSizeMake(cellW - 20, 4))
	            lineSp:setPosition(cellW / 2, 0)
	            cell:addChild(lineSp)
	        end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setPosition(ccp(3, 3))
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(120)
    tvBg:addChild(tv)

    --添加上、下的触摸屏蔽层
    local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    top:setAnchorPoint(ccp(0.5, 0))
    top:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height)
    tvBg:addChild(top, 5)
    top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    top:setVisible(false)

    local bottom = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    bottom:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    bottom:setAnchorPoint(ccp(0.5, 1))
    bottom:setPosition(tvBg:getContentSize().width / 2, 0)
    tvBg:addChild(bottom, 5)
    bottom:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    bottom:setVisible(false)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    -------- 点击屏幕继续 --------
    local clickLbPosy = - 80
    local tmpLb = GetTTFLabel(getlocal("click_screen_continue"), 25)
    local clickLb = GetTTFLabelWrap(getlocal("click_screen_continue"), 25, CCSizeMake(400, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width / 2, clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1, arrowPosx2
    local realWidth, maxWidth = tmpLb:getContentSize().width, clickLb:getContentSize().width
    if realWidth > maxWidth then
        arrowPosx1 = self.bgSize.width / 2 - maxWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + maxWidth / 2
    else
        arrowPosx1 = self.bgSize.width / 2 - realWidth / 2
        arrowPosx2 = self.bgSize.width / 2 + realWidth / 2
    end
    local smallArrowSp1 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1 - 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1 - 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2 + 15, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4 = CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2 + 25, clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)
    
    local space = 20
    smallArrowSp1:runAction(G_actionArrow(1, space))
    smallArrowSp2:runAction(G_actionArrow(1, space))
    smallArrowSp3:runAction(G_actionArrow( - 1, space))
    smallArrowSp4:runAction(G_actionArrow( - 1, space))
end