militaryOrdersSmallDialog = smallDialog:new()

function militaryOrdersSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function militaryOrdersSmallDialog:showPrivilege(layerNum, titleStr, btnCallback)
    local sd = militaryOrdersSmallDialog:new()
    sd:initPrivilege(layerNum, titleStr, btnCallback)
end

function militaryOrdersSmallDialog:initPrivilege(layerNum, titleStr, btnCallback)
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
        base:removeFromNeedRefresh(self)
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
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, onClickClose, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    base:addNeedRefresh(self)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    local timeStr = getlocal("militaryOrders_privilegeCountdownText", {G_formatActiveDate(militaryOrdersVoApi:getEndTime() - base.serverTime)})
    local timeLb = GetTTFLabelWrap(timeStr, 22, CCSizeMake(self.bgSize.width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    timeLb:setAnchorPoint(ccp(0.5, 1))
    timeLb:setPosition(self.bgSize.width / 2, self.bgSize.height - 75)
    timeLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(timeLb)
    self.timeLb = timeLb
    
    local isMaxLevel = (militaryOrdersVoApi:getMilitaryOrdersLv() == militaryOrdersVoApi:getMaxLevel())
    local tvBgOffsetH = 130
    if isMaxLevel == true and militaryOrdersVoApi:isActivate() == true then
        tvBgOffsetH = 30
    end
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 30, timeLb:getPositionY() - timeLb:getContentSize().height - 10 - tvBgOffsetH))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, timeLb:getPositionY() - timeLb:getContentSize().height - 10)
    self.bgLayer:addChild(tvBg)
    local normalPrivilegeData, honourPrivilegeData = militaryOrdersVoApi:getPrivilegeData()
    local normalCount = SizeOfTable(normalPrivilegeData)
    local honourCount = SizeOfTable(honourPrivilegeData)
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 8, tvBg:getContentSize().height - 8)
    local tv = G_createTableView(tvSize, normalCount + honourCount + 2, function(idx, cellNum)
        local height = G_isAsia() == false and 140 or 110
        if idx == 0 or idx == normalCount + 1 then
            height = 50
        end
        return CCSizeMake(tvSize.width, height)
    end, function(cell, cellSize, idx, cellNum)
        if idx == 0 or idx == normalCount + 1 then
            local titleStr = getlocal(idx == 0 and "militaryOrders_normalPrivilegeText" or "militaryOrders_honourPrivilegeText")
            local tempTitleLb = GetTTFLabel(titleStr, G_isAsia() == false and 22 or 24, true)
            local titleBg, titleLb, titleLbHeight = G_createNewTitle({titleStr, G_isAsia() == false and 22 or 24, G_ColorYellowPro}, CCSizeMake(tempTitleLb:getContentSize().width + (G_isAsia() == false and 130 or 100), 0), nil, true, "Helvetica-bold")
            titleBg:setAnchorPoint(ccp(0.5, 0))
            titleBg:setPosition(cellSize.width / 2, cellSize.height - titleLbHeight - 10)
            cell:addChild(titleBg)
        else
            local data
            if idx <= normalCount then
                data = normalPrivilegeData[idx]
            else
                data = honourPrivilegeData[idx - normalCount - 1]
            end
            if data then
                local privilegeIcon = CCSprite:createWithSpriteFrameName("moi_privilegeIcon" .. data.unlockType .. ".png")
                privilegeIcon:setAnchorPoint(ccp(0, 0.5))
                privilegeIcon:setScale(0.8)
                privilegeIcon:setPosition(15, cellSize.height / 2)
                cell:addChild(privilegeIcon)
                local descLbWidth = cellSize.width - (privilegeIcon:getPositionX() + privilegeIcon:getContentSize().width * privilegeIcon:getScale() + 10) - 60
                local privilegeDescLb = GetTTFLabelWrap(getlocal("dailyTask_sub_title_4") .. "：" .. data.desc, G_isAsia() == false and 18 or 22, CCSizeMake(descLbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
                local unlockLbStr = (data.openLv == 0) and getlocal("militaryOrders_privilegeUnlockTips1") or getlocal("militaryOrders_privilegeUnlockTips", {data.openLv})
                local unlockLb = GetTTFLabelWrap(unlockLbStr, 20, CCSizeMake(descLbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                local lbPosY = (cellSize.height - (privilegeDescLb:getContentSize().height + unlockLb:getContentSize().height)) / 2
                unlockLb:setAnchorPoint(ccp(0, 0))
                unlockLb:setPosition(privilegeIcon:getPositionX() + privilegeIcon:getContentSize().width * privilegeIcon:getScale() + 10, lbPosY)
                privilegeDescLb:setAnchorPoint(ccp(0, 0))
                privilegeDescLb:setPosition(unlockLb:getPositionX(), unlockLb:getPositionY() + unlockLb:getContentSize().height)
                privilegeDescLb:setColor(G_ColorYellowPro)
                cell:addChild(unlockLb)
                cell:addChild(privilegeDescLb)
                if data.unlockStatus == true then
                    local checkSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
                    checkSp:setAnchorPoint(ccp(1, 0.5))
                    checkSp:setPosition(cellSize.width - 15, cellSize.height / 2)
                    cell:addChild(checkSp)
                end
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                lineSp:setContentSize(CCSizeMake(cellSize.width - 20, lineSp:getContentSize().height))
                lineSp:setPosition(cellSize.width / 2, 0)
                lineSp:setRotation(180)
                cell:addChild(lineSp)
            end
        end
    end)
    tv:setPosition((tvBg:getContentSize().width - tvSize.width) / 2, 4)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tvBg:addChild(tv)
    
    if isMaxLevel == false and militaryOrdersVoApi:isActivate() == true then
        local unlockData = militaryOrdersVoApi:getUnlockData()
        if unlockData and unlockData[2] then
            local unlockToLv = unlockData[2][1]
            local costGold = unlockData[2][2]
            local function onClickUnlock(tag, obj)
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local gems = playerVoApi:getGems()
                if gems < costGold then
                    GemsNotEnoughDialog(nil, nil, costGold - gems, self.layerNum + 1, costGold)
                    do return end
                end
                local function onSureLogic()
                    print("cjl ------>>> 一键解锁")
                    militaryOrdersVoApi:requestUnlock(function()
                        playerVoApi:setGems(playerVoApi:getGems() - costGold)
                        if type(btnCallback) == "function" then
                            btnCallback(2, unlockToLv)
                        end
                    end, 2)
                    closeDialog()
                end
                local tipsStr = getlocal("militaryOrders_unlockSureCostTips", {costGold, unlockToLv})
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), tipsStr, nil, self.layerNum + 1)
            end
            local btnScale = 0.8
            local unlockBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickUnlock, nil, getlocal("militaryOrders_unlockOfAll"), G_isAsia() == false and 20 or 24 / btnScale)
            local btnMenu = CCMenu:createWithItem(unlockBtn)
            btnMenu:setPosition(0, 0)
            btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            self.bgLayer:addChild(btnMenu)
            unlockBtn:setAnchorPoint(ccp(0.5, 0))
            unlockBtn:setScale(btnScale)
            unlockBtn:setPosition(self.bgSize.width / 2, 30)
            local unlockTipLb = GetTTFLabel(getlocal("militaryOrders_unlockTo", {unlockToLv}), 22)
            local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
            local goldLb = GetTTFLabel(tostring(costGold), 22)
            local firstPosX = (self.bgSize.width - (unlockTipLb:getContentSize().width + goldSp:getContentSize().width + goldLb:getContentSize().width)) / 2
            unlockTipLb:setAnchorPoint(ccp(0, 0.5))
            goldSp:setAnchorPoint(ccp(0, 0.5))
            goldLb:setAnchorPoint(ccp(0, 0.5))
            goldSp:setPositionY(unlockBtn:getPositionY() + unlockBtn:getContentSize().height * btnScale + goldSp:getContentSize().height / 2 + 3)
            unlockTipLb:setPosition(firstPosX, goldSp:getPositionY())
            goldSp:setPositionX(unlockTipLb:getPositionX() + unlockTipLb:getContentSize().width)
            goldLb:setPosition(goldSp:getPositionX() + goldSp:getContentSize().width, goldSp:getPositionY())
            self.bgLayer:addChild(unlockTipLb)
            self.bgLayer:addChild(goldSp)
            self.bgLayer:addChild(goldLb)
        end
    elseif militaryOrdersVoApi:isActivate() == false then
        local activateCardItem = {pic = "moi_activateCard.png", name = getlocal("militaryOrders_activateCardName"), desc = "militaryOrders_activateCardDesc", num = 1}
        local iconSize = 90
        local activateCardIcon, iconScale = G_getItemIcon(activateCardItem, 100, false, self.layerNum, function()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, activateCardItem, nil, nil, nil, nil, true)
        end)
        activateCardIcon:setScale(iconSize / activateCardIcon:getContentSize().height)
        iconScale = activateCardIcon:getScale()
        activateCardIcon:setPosition(35 + iconSize / 2, 25 + iconSize / 2)
        activateCardIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(activateCardIcon)
        local function onClickBuy(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if militaryOrdersVoApi:isRechargeBuy() == true then

            	militaryOrdersVoApi:saveRechargeBuyTime()

                local rechargeId, rechargeCost = militaryOrdersVoApi:getRechargeBuyCost()
                G_rechargeHandler(rechargeId, rechargeCost, nil, self.layerNum)

                do return end
            end
            if militaryOrdersVoApi:isCanBuyActivateCard() then
                local costGold = militaryOrdersVoApi:getBuyActivateCardCost()
                local gems = playerVoApi:getGems()
                if gems < costGold then
                    GemsNotEnoughDialog(nil, nil, costGold - gems, self.layerNum + 1, costGold)
                    do return end
                end
                local function onSureLogic()
                    print("cjl -------->>> 购买激活卡")
                    militaryOrdersVoApi:requestActivate(function()
                        playerVoApi:setGems(gems - costGold)
                        G_showTipsDialog(getlocal("buffSuccess"))
                        if type(btnCallback) == "function" then
                            btnCallback(1)
                        end
                    end)
                    closeDialog()
                end
                local tipsStr = getlocal("buyAndUsePropStr", {costGold, activateCardItem.name})
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), tipsStr, nil, self.layerNum + 1)
            else
                local function onSureLogic()
                    -- G_closeAllSmallDialog()
                    activityAndNoteDialog:closeAllDialog()
                    closeDialog()
                    vipVoApi:showRechargeDialog(self.layerNum + 1)
                end
                local tipsStr = getlocal("militaryOrders_activateCardBuyConditionTips", {militaryOrdersVoApi:getRechargeNeedGold()})
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), tipsStr, nil, self.layerNum + 1)
            end
        end
        local btnScale = 0.6
        local buyBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuy, nil, getlocal("buy"), 24 / btnScale, 10)
        local btnMenu = CCMenu:createWithItem(buyBtn)
        btnMenu:setPosition(0, 0)
        btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(btnMenu)
        buyBtn:setAnchorPoint(ccp(1, 0))
        buyBtn:setScale(btnScale)
        buyBtn:setPosition(self.bgSize.width - 20, 30)
        self.buyActiveCardBtn = buyBtn
        
        self:refreshActiveCardBtn()
        
        local lbWidth = self.bgSize.width - (activateCardIcon:getPositionX() + iconSize / 2) - buyBtn:getContentSize().width * btnScale - 20 - 20
        if militaryOrdersVoApi:isRechargeBuy() == true then
            local buyTip = GetTTFLabelWrap(getlocal("vip_monthlyCard_not_recharge_active"), G_isAsia() == false and 20 or 22, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
            buyTip:setAnchorPoint(ccp(0, 0.5))
            buyTip:setPosition(activateCardIcon:getPositionX() + iconSize / 2 + 10, activateCardIcon:getPositionY())
            self.bgLayer:addChild(buyTip)
            buyBtn:setPositionY(activateCardIcon:getPositionY() - buyBtn:getContentSize().height * btnScale / 2)
        else
            local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
            local goldLb = GetTTFLabel(tostring(militaryOrdersVoApi:getBuyActivateCardCost()), 22)
            goldSp:setAnchorPoint(ccp(1, 0))
            goldSp:setPosition(buyBtn:getPositionX() - buyBtn:getContentSize().width * btnScale / 2 - 10, buyBtn:getPositionY() + buyBtn:getContentSize().height * btnScale + 3)
            self.bgLayer:addChild(goldSp)
            goldLb:setAnchorPoint(ccp(0, 0.5))
            goldLb:setPosition(goldSp:getPositionX(), goldSp:getPositionY() + goldSp:getContentSize().height * goldSp:getScale() / 2)
            self.bgLayer:addChild(goldLb)
            local buyTipsTitleLb = GetTTFLabelWrap(getlocal("armor_buy_conditions"), G_isAsia() == false and 20 or 22, CCSizeMake(lbWidth, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
            local lbStr = getlocal("militaryOrders_activateCardBuyTips", {militaryOrdersVoApi:getRechargeGold(), militaryOrdersVoApi:getRechargeNeedGold()})
            local buyTipsLb, buyTipsLbHeight = G_getRichTextLabel(lbStr, {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}, G_isAsia() == false and 20 or 22, lbWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            buyTipsLb:setAnchorPoint(ccp(0, 1))
            buyTipsTitleLb:setAnchorPoint(ccp(0, 0))
            local lbFirsPosY = (iconSize - (buyTipsTitleLb:getContentSize().height + buyTipsLbHeight)) / 2 + (activateCardIcon:getPositionY() - iconSize / 2)
            buyTipsTitleLb:setPosition(activateCardIcon:getPositionX() + iconSize / 2 + 10, lbFirsPosY + buyTipsLbHeight)
            buyTipsLb:setPosition(buyTipsTitleLb:getPositionX(), buyTipsTitleLb:getPositionY())
            self.bgLayer:addChild(buyTipsTitleLb)
            self.bgLayer:addChild(buyTipsLb)
        end
    end

	if(self.activateCardBuyListener==nil)then
		local function listener(event,data) --支付购买激活卡成功后关闭该页面
			if(data and data.itemId)then
                local rechargeId, rechargeCost = militaryOrdersVoApi:getRechargeBuyCost()
				if tonumber(rechargeId) == tonumber(data.itemId) and self and self:isClosed() == false then
					self:close()
				end
			end
		end
		self.activateCardBuyListener=listener
		eventDispatcher:addEventListener("user.pay",self.activateCardBuyListener)
	end
    if(self.overMonthListener==nil)then
        local function listener(event,data) --支付购买激活卡成功后关闭该页面
            if self then
                self:close()
            end
        end
        self.overMonthListener=listener
        eventDispatcher:addEventListener("military.overmonth",self.overMonthListener)
    end
end

--激活卡购买按钮刷新
function militaryOrdersSmallDialog:refreshActiveCardBtn()
    if self.buyActiveCardBtn == nil or tolua.cast(self.buyActiveCardBtn, "CCMenuItemSprite") == nil then
        do return end
    end
    local btnLb = tolua.cast(self.buyActiveCardBtn:getChildByTag(10), "CCLabelTTF")
    if btnLb == nil then
        do return end
    end
    if militaryOrdersVoApi:isRechargeBuy() == true then
        local buyTime = militaryOrdersVoApi:getRechargeBuyTime()
        if buyTime and buyTime > 0 and base.serverTime < buyTime then
            btnStr = GetTimeStr(buyTime - base.serverTime)
            self.buyActiveCardBtn:setEnabled(false)
        else
            local rechargeId, rechargeCost = militaryOrdersVoApi:getRechargeBuyCost()
            btnStr = rechargeCost .. G_getPlatStoreCfg()["moneyType"][GetMoneyName()]
            self.buyActiveCardBtn:setEnabled(true)
        end
    else
        btnStr = getlocal("buy")
        self.buyActiveCardBtn:setEnabled(true)
    end
    btnLb:setString(btnStr)
end

function militaryOrdersSmallDialog:tick()
    if self then
        self:refreshActiveCardBtn()
        if tolua.cast(self.timeLb, "CCLabelTTF") then
            local timer = militaryOrdersVoApi:getEndTime() - base.serverTime
            self.timeLb:setString(getlocal("militaryOrders_privilegeCountdownText", {G_formatActiveDate(timer)}))
            if timer <= 0 then
                self:close()
            end
        end
    end
end

function militaryOrdersSmallDialog:showShop(layerNum, titleStr)
    local sd = militaryOrdersSmallDialog:new()
    sd:initShop(layerNum, titleStr)
end

function militaryOrdersSmallDialog:initShop(layerNum, titleStr)
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
    
    self.bgSize = CCSizeMake(560, 780)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 110))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 78)
    self.bgLayer:addChild(contentBg)
    
    local function onClickInfoBtn(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {getlocal("militaryOrders_shopTipsDesc1"), getlocal("militaryOrders_shopTipsDesc2")}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickInfoBtn)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    infoMenu:setPosition(ccp(0, 0))
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.8)
    infoBtn:setPosition(contentBg:getContentSize().width - 10, contentBg:getContentSize().height - 10)
    contentBg:addChild(infoMenu)
    
    local scoreSp = CCSprite:createWithSpriteFrameName("moi_money.png")
    scoreSp:setAnchorPoint(ccp(1, 0.5))
    scoreSp:setScale((infoBtn:getContentSize().height * infoBtn:getScale()) / scoreSp:getContentSize().height)
    scoreSp:setPosition(contentBg:getContentSize().width / 2 - infoBtn:getContentSize().width * infoBtn:getScale(), infoBtn:getPositionY() - infoBtn:getContentSize().height * infoBtn:getScale() / 2)
    contentBg:addChild(scoreSp)
    local myScore = militaryOrdersVoApi:getMilitaryOrdersMoney()
    local scoreLb = GetTTFLabel(myScore, 24, true)
    scoreLb:setAnchorPoint(ccp(0, 0.5))
    scoreLb:setPosition(scoreSp:getPositionX() + 5, scoreSp:getPositionY())
    scoreLb:setColor(G_ColorYellowPro)
    contentBg:addChild(scoreLb)
    
    local shopData = militaryOrdersVoApi:getShopData()
    local tvSize = CCSizeMake(contentBg:getContentSize().width - 10, infoBtn:getPositionY() - infoBtn:getContentSize().height * infoBtn:getScale() - 13)
    local tv
    tv = G_createTableView(tvSize, SizeOfTable(shopData), CCSizeMake(tvSize.width, G_isAsia() == false and 170 or 155), function(cell, cellSize, idx, cellNum)
        local data = shopData[idx + 1]
        if data == nil then
            do return end
        end
        local reward = FormatItem(data.reward)
        if reward then
            reward = reward[1]
        end
        if reward == nil then
            do return end
        end
        local exchangeNum = militaryOrdersVoApi:getShopBuyNum(data.id)
        local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
        nameBg:setContentSize(CCSizeMake(cellSize.width - 100, nameBg:getContentSize().height))
        nameBg:setAnchorPoint(ccp(0, 1))
        nameBg:setPosition(10, cellSize.height - 5)
        cell:addChild(nameBg)
        local nameLb = GetTTFLabel(reward.name .. "x" .. FormatNumber(reward.num) .. "（" .. exchangeNum .. "/" .. data.num .. "）", G_isAsia() == false and 17 or 22, true)
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
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(icon)
        local descLbHeight = nameBg:getPositionY() - nameBg:getContentSize().height - 5 - (G_isAsia() == false and 35 or 25)
        local descLb = GetTTFLabelWrap(getlocal(reward.desc), G_isAsia() == false and 16 or 20, CCSizeMake(cellSize.width - 250, descLbHeight), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
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
                print("cjl ------->>>> 购买 ", buyNum, data.id)
                militaryOrdersVoApi:requestBuy(function()
                    reward.num = reward.num * buyNum
                    G_addPlayerAward(reward.type, reward.key, reward.id, reward.num, nil, true)
                    if reward.type == "h" then --添加将领魂魄
                        if reward.key and string.sub(reward.key, 1, 1) == "s" then
                            heroVoApi:addSoul(reward.key, tonumber(reward.num))
                        end
                    end
                    G_showRewardTip({reward})
                    myScore = militaryOrdersVoApi:getMilitaryOrdersMoney()
                    if scoreLb then
                        scoreLb:setString(tostring(myScore))
                    end
                    if tv then
                        shopData = militaryOrdersVoApi:getShopData()
                        local recordPoint = tv:getRecordPoint()
                        tv:reloadData()
                        tv:recoverToRecordPoint(recordPoint)
                    end
                end, data.id, buyNum)
            end
            shopVoApi:showBatchBuyPropSmallDialog(reward.key, self.layerNum + 1, onBuyHander, nil, canBuyNum, nil, nil, nil, nil, data.cost, {"moi_money.png", 0.3})
        end
        local btnScale = 0.6
        local exchangeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickExchange, 11, getlocal("buy"), 24 / btnScale)
        exchangeBtn:setScale(btnScale)
        local menu = CCMenu:createWithItem(exchangeBtn)
        menu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        menu:setPosition(0, 0)
        exchangeBtn:setAnchorPoint(ccp(1, 0.5))
        exchangeBtn:setPosition(cellSize.width - 10, (nameBg:getPositionY() - nameBg:getContentSize().height) / 2 - 20)
        cell:addChild(menu)
        local moLevel = militaryOrdersVoApi:getMilitaryOrdersLv()
        if moLevel < data.openLv or canBuyNum <= 0 or exchangeNum >= data.num then
            exchangeBtn:setEnabled(false)
            if moLevel < data.openLv then
                local tipsStr = getlocal("militaryOrders_levelSatisfyDesc", {data.openLv})
                local tipsLb = GetTTFLabelWrap(tipsStr, G_isAsia() == false and 16 or 20, CCSizeMake(cellSize.width - 250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
                tipsLb:setAnchorPoint(ccp(0, 0))
                tipsLb:setPosition(descLb:getPositionX(), 3)
                tipsLb:setColor(G_ColorRed)
                cell:addChild(tipsLb)
            end
        end
        local scoreSp = CCSprite:createWithSpriteFrameName("moi_money.png")
        scoreSp:setAnchorPoint(ccp(1, 0.5))
        scoreSp:setScale(0.3)
        scoreSp:setPosition(exchangeBtn:getPositionX() - exchangeBtn:getContentSize().width * btnScale / 2, exchangeBtn:getPositionY() + exchangeBtn:getContentSize().height * btnScale / 2 + 5 + scoreSp:getContentSize().height * scoreSp:getScale() / 2)
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
            lineSp:setContentSize(CCSizeMake(cellSize.width - 20, lineSp:getContentSize().height))
            lineSp:setPosition(cellSize.width / 2, 0)
            lineSp:setRotation(180)
            cell:addChild(lineSp)
        end
    end)
    tv:setPosition((contentBg:getContentSize().width - tvSize.width) / 2, 4)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    contentBg:addChild(tv)
    
    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(contentBg:getContentSize().width / 2, tv:getPositionY() + tvSize.height)
    upShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    contentBg:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(contentBg:getContentSize().width / 2, tv:getPositionY())
    downShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    contentBg:addChild(downShiedldBg)
end

function militaryOrdersSmallDialog:showUnlock(layerNum, paramsTb, btnCallback)
    local sd = militaryOrdersSmallDialog:new()
    sd:initUnlock(layerNum, paramsTb, btnCallback)
end

function militaryOrdersSmallDialog:initUnlock(layerNum, paramsTb, btnCallback)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(500, 300)
    self.bgLayer = G_getNewDialogBg2(self.bgSize, layerNum, nil, getlocal("activity_fbReward_unlock"), 28, nil, "Helvetica-bold")
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    local spaceLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
    spaceLineSp:setContentSize(CCSizeMake(self.bgSize.height - 80, spaceLineSp:getContentSize().height))
    spaceLineSp:setPosition(self.bgSize.width / 2, self.bgSize.height / 2)
    spaceLineSp:setRotation(90)
    self.bgLayer:addChild(spaceLineSp)
    
    local leftUnlockLb = GetTTFLabelWrap(getlocal("militaryOrders_unlockTo", {paramsTb[1][1]}), 24, CCSizeMake(self.bgSize.width / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    leftUnlockLb:setPosition(self.bgSize.width / 2 / 2, self.bgSize.height - 40 - leftUnlockLb:getContentSize().height / 2 - 30)
    self.bgLayer:addChild(leftUnlockLb)
    
    local rightUnlockLb = GetTTFLabelWrap(getlocal("militaryOrders_unlockTo", {paramsTb[2][1]}), 24, CCSizeMake(self.bgSize.width / 2 - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    rightUnlockLb:setPosition(self.bgSize.width / 2 + self.bgSize.width / 2 / 2, self.bgSize.height - 40 - rightUnlockLb:getContentSize().height / 2 - 30)
    self.bgLayer:addChild(rightUnlockLb)
    
    local function onClickBuyHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local costGold, unlockToLv, unlockType
        if tag == 10 then
            costGold = paramsTb[1][2]
            unlockToLv = paramsTb[1][1]
            unlockType = 1
        elseif tag == 11 then
            costGold = paramsTb[2][2]
            unlockToLv = paramsTb[2][1]
            unlockType = 2
        end
        if type(costGold) == "number" then
            local gems = playerVoApi:getGems()
            if gems < costGold then
                GemsNotEnoughDialog(nil, nil, costGold - gems, self.layerNum + 1, costGold)
                do return end
            end
            local function onSureLogic()
                if type(btnCallback) == "function" then
                    btnCallback(unlockToLv, unlockType, costGold)
                end
                self:close()
            end
            local tipsStr = getlocal("militaryOrders_unlockSureCostTips", {costGold, unlockToLv})
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), tipsStr, nil, self.layerNum + 1)
        end
    end
    local btnScale, btnFontSize = 0.7, 24
    local leftBuyBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuyHandler, 10, getlocal("buy"), btnFontSize / btnScale)
    local rightBuyBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickBuyHandler, 11, getlocal("buy"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(leftBuyBtn)
    menuArr:addObject(rightBuyBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu)
    leftBuyBtn:setScale(btnScale)
    rightBuyBtn:setScale(btnScale)
    leftBuyBtn:setPosition(leftUnlockLb:getPositionX(), 45 + leftBuyBtn:getContentSize().height * btnScale / 2)
    rightBuyBtn:setPosition(rightUnlockLb:getPositionX(), 45 + rightBuyBtn:getContentSize().height * btnScale / 2)
    local goldTb = {{leftBuyBtn, paramsTb[1][2]}, {rightBuyBtn, paramsTb[2][2]}}
    for k, v in pairs(goldTb) do
        local goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        local goldLb = GetTTFLabel(tostring(v[2]), 22)
        goldSp:setAnchorPoint(ccp(1, 0))
        goldSp:setPosition(v[1]:getPositionX() - 10, v[1]:getPositionY() + v[1]:getContentSize().height * btnScale / 2 + 3)
        self.bgLayer:addChild(goldSp)
        goldLb:setAnchorPoint(ccp(0, 0.5))
        goldLb:setPosition(goldSp:getPositionX(), goldSp:getPositionY() + goldSp:getContentSize().height * goldSp:getScale() / 2)
        self.bgLayer:addChild(goldLb)
    end
    
    -------- 点击屏幕继续 --------
    local clickLbPosy = -80
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
    smallArrowSp3:runAction(G_actionArrow(-1, space))
    smallArrowSp4:runAction(G_actionArrow(-1, space))
end

function militaryOrdersSmallDialog:showRewardList(layerNum, titleStr, paramsTb, closeBtnCallback)
    local sd = militaryOrdersSmallDialog:new()
    sd:initRewardList(layerNum, titleStr, paramsTb, closeBtnCallback)
end

function militaryOrdersSmallDialog:initRewardList(layerNum, titleStr, paramsTb, closeBtnCallback)
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
    
    local isHasNewPrivilege
    self.bgSize = CCSizeMake(560, 780)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if type(closeBtnCallback) == "function" then
            closeBtnCallback(isHasNewPrivilege)
        end
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    
    local rowNum = 6
    local iconSize = 70
    local iconSpaceX, iconSpaceY = 10, 10
    local tempTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    local titleBgHeight = tempTitleBg:getContentSize().height
    local rewardTvSize = CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 100)
    local rewardTv = G_createTableView(rewardTvSize, SizeOfTable(paramsTb), function(idx, cellNum)
        local height = 0
        local data = paramsTb[idx + 1]
        if data then
            height = height + 5
            height = height + titleBgHeight
            if data.reward then
                height = height + 15
                local rewardNum = SizeOfTable(data.reward[1]) + SizeOfTable(data.reward[2])
                local colNum = math.floor(rewardNum / rowNum)
                if rewardNum % rowNum ~= 0 then
                    colNum = colNum + 1
                end
                height = height + iconSize * colNum + (colNum - 1) * iconSpaceY
                height = height + 15
            end
            height = height + 5
        end
        return CCSizeMake(rewardTvSize.width, height)
    end, function(cell, cellSize, idx, cellNum)
        local data = paramsTb[idx + 1]
        if data == nil then
            do return end
        end
        local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 10))
        cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
        cell:addChild(cellBg)
        local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        titleBg:setAnchorPoint(ccp(0.5, 1))
        titleBg:setPosition(cellBg:getContentSize().width / 2, cellBg:getContentSize().height)
        cellBg:addChild(titleBg)
        local titleLb = GetTTFLabel(getlocal("militaryOrders_levelReward", {data.level}), 22, true)
        titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
        titleBg:addChild(titleLb)
        if data.reward then
            local firstPosX = (cellBg:getContentSize().width - (iconSize * rowNum + iconSpaceX * (rowNum - 1))) / 2
            local firstPosY = titleBg:getPositionY() - titleBg:getContentSize().height - 15
            local rIndex = 0
            for i = 1, 2 do
                if data.reward[i] then
                    for k, v in pairs(data.reward[i]) do
                        if tonumber(v.id) and v.id >= 5040 and v.id <= 5045 then --特权钥匙不进背包
                            isHasNewPrivilege = true
                        else
                            G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                            if v.type == "h" then --添加将领魂魄
                                if v.key and string.sub(v.key, 1, 1) == "s" then
                                    heroVoApi:addSoul(v.key, tonumber(v.num))
                                end
                            end
                        end
                        rIndex = rIndex + 1
                        local function showNewPropDialog()
                            if v.type == "at" and v.eType == "a" then --AI部队
                                local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
                                AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                            else
                                G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
                            end
                        end
                        local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
                        icon:setAnchorPoint(ccp(0, 1))
                        icon:setScale(iconSize / icon:getContentSize().height)
                        scale = icon:getScale()
                        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                        icon:setPosition(firstPosX + ((rIndex - 1) % rowNum) * (iconSize + iconSpaceX), firstPosY - math.floor(((rIndex - 1) / rowNum)) * (iconSize + iconSpaceY))
                        cellBg:addChild(icon)
                        if type(v.extend) == "string" then
                            G_addRectFlicker2(icon, 1.15, 1.15, 1, v.extend, nil, 10)
                        end
                        local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
                        local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                        numBg:setAnchorPoint(ccp(0, 1))
                        numBg:setRotation(180)
                        numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
                        numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
                        numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize + 5)
                        cellBg:addChild(numBg)
                        numLb:setAnchorPoint(ccp(1, 0))
                        numLb:setPosition(numBg:getPosition())
                        cellBg:addChild(numLb)
                    end
                end
            end
        end
    end)
    rewardTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    rewardTv:setPosition((self.bgSize.width - rewardTvSize.width) / 2, 30)
    self.bgLayer:addChild(rewardTv)
    
    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(self.bgSize.width / 2, rewardTv:getPositionY() + rewardTvSize.height)
    upShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    self.bgLayer:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(self.bgSize.width / 2, rewardTv:getPositionY())
    downShiedldBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    self.bgLayer:addChild(downShiedldBg)
end

function militaryOrdersSmallDialog:dispose()
	if self.activateCardBuyListener then
		eventDispatcher:removeEventListener("user.pay",self.activateCardBuyListener)
		self.activateCardBuyListener = nil
	end
    if self.overMonthListener then
        eventDispatcher:removeEventListener("military.overmonth",self.overMonthListener)
        self.overMonthListener = nil
    end
    self.buyActiveCardBtn = nil
    self = nil
end
