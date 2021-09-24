--[[
活动万象更新

@author JNK
]]

acWxgxDialog = commonDialog:new()

function acWxgxDialog:new()
	local nc = {
        showLayerTop  = nil,
        showLayerBg   = nil,
        timeLb        = nil,
        rechargeLb    = nil,
        buyItemButton = nil,
        buyLb         = nil,
        buyCostIcon   = nil,
        stateLb       = nil,
        lockSp        = nil,
        buyState      = 0, -- 0未解锁不可购买，1已购买，2解锁可购买，3充值不足
        showTopY = G_VisibleSizeHeight - 82,
        showTopHeight = 400,
        version = acWxgxVoApi:getVersion()
	}
	setmetatable(nc,self)
	self.__index = self

    self.shopListCellSize = CCSizeMake(616, 122)
    self.shopList = acWxgxVoApi:getShoplist()
    self.shopKeyList = acWxgxVoApi:getShoplistSortKey()

	return nc
end

function acWxgxDialog:dispose()
    if self.circelAc then
        self.circelAc:stop()
    end
    if self.magnifierSp then
        self.magnifierSp:stopAllActions()
        self.magnifierSp = nil
    end
    if self.buildingAc then
        self.buildingAc:stopAllActions()
        self.buildingAc = nil
    end
    
    self.version       = nil
    self.showLayerTop  = nil
    self.showLayerBg   = nil
    self.timeLb        = nil
    self.rechargeLb    = nil
    self.buyItemButton = nil
    self.buyLb         = nil
    self.buyCostIcon   = nil
    self.stateLb       = nil
    self.lockSp        = nil
    self.buyState      = 0
    self.shopList      = nil
    self.shopKeyList   = nil

    spriteController:removePlist("public/acydcz_images.plist")
    spriteController:removeTexture("public/acydcz_images.png")
    spriteController:removePlist("public/rewardCenterImage.plist")
    spriteController:removeTexture("public/rewardCenterImage.png")
end
function acWxgxDialog:resetTab()
    spriteController:addPlist("public/acydcz_images.plist")
    spriteController:addTexture("public/acydcz_images.png")
    spriteController:addPlist("public/rewardCenterImage.plist")
    spriteController:addTexture("public/rewardCenterImage.png")
    self.panelLineBg:setVisible(false)

    local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight
    -- 上边显示Layer
    self.showLayerTop = CCLayer:create()
    self.showLayerTop:ignoreAnchorPointForPosition(false)
    self.showLayerTop:setAnchorPoint(ccp(0.5, 1))
    self.showLayerTop:setContentSize(CCSize(showTopWidth, showTopHeight))
    self.showLayerTop:setPosition(ccp(showTopWidth / 2, showTopY))
    self.bgLayer:addChild(self.showLayerTop)

    -- 背景
    self.showLayerBg = CCLayer:create()
    self.showLayerBg:setPosition(ccp(showTopWidth / 2, showTopHeight / 2))
    self.showLayerTop:addChild(self.showLayerBg)
    -- 网络下载的图
    local function onLoadIcon(fn,icon)
        if self and self.showLayerBg and tolua.cast(self.showLayerBg, "CCLayer") then
            icon:setAnchorPoint(ccp(0.5, 0.5))
            icon:setPosition(ccp(0, 0))
            self.showLayerBg:addChild(icon)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acWxgxBg.png"), onLoadIcon)

    -- 梯形底
    local bgShade = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function () end)
    bgShade:setContentSize(CCSizeMake(showTopWidth, 80))
    bgShade:setAnchorPoint(ccp(0.5, 1))
    bgShade:setPosition(showTopWidth / 2, showTopHeight)
    self.showLayerTop:addChild(bgShade)

    local function touch(tag, object)
        PlayEffect(audioCfg.mouseClick)
        -- 说明按钮详细
        local tabStr = {}
        local tabColor = {}
        local tabAlignment = {}
        tabStr = {"\n", getlocal("activity_wxgx_desc3"), "\n", getlocal("activity_wxgx_desc2"), "\n", getlocal("activity_wxgx_desc1"), "\n"}
        tabColor = {nil, nil, nil, nil, nil, nil}
        tabAlignment = {nil, nil, nil, nil, nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
            nil, true, true, self.layerNum + 1, tabStr, 25, tabColor, nil, nil, nil, tabAlignment)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end

    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(showTopWidth - 40, showTopHeight - 40))
    self.showLayerTop:addChild(menuDesc)

    local timeLb = GetTTFLabel("", 25)
    timeLb:setAnchorPoint(ccp(0.5, 0))
    timeLb:setPosition(ccp(showTopWidth / 2, showTopHeight - 40))
    -- timeLb:setColor(G_ColorGreen)
    if self.version == 5 then
        local buildingPic = acWxgxVoApi:getCurPicName()
        self:showBuildingFunction(buildingPic,self.showLayerTop,ccp(20,15),ccp(0,0),0.7)
    end

    self.showLayerTop:addChild(timeLb)
    self.timeLb = timeLb

    self:updateShowTop(true)
    self:tick()
end

function acWxgxDialog:doUserHandler()
end

function acWxgxDialog:initTableView()
    local tvH = self.showTopY - self.showTopHeight - 35
    local function eventHandler( ... )
        return self:eventHandler( ... )
    end
    local hdSize = CCSizeMake(G_VisibleSizeWidth - 50, tvH)
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tv = LuaCCTableView:createWithEventHandler(hd, hdSize, nil)
    self.tv:setPosition(ccp(25, 20))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(120)

    local tableViewBox = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tableViewBox:setContentSize(CCSizeMake(616, hdSize.height + 4))
    tableViewBox:setAnchorPoint(ccp(0.5, 0))
    tableViewBox:setPosition(ccp(G_VisibleSizeWidth / 2, self.tv:getPositionY() - 2))
    self.bgLayer:addChild(tableViewBox)
end

function acWxgxDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return SizeOfTable(self.shopList)
    elseif fn == "tableCellSizeForIndex" then
        return  self.shopListCellSize
    elseif fn == "tableCellAtIndex" then
        local index = self.shopKeyList[idx + 1]
        return self:showShopListCellUI(idx + 1, index)
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end

function acWxgxDialog:showShopListCellUI(index, idx)
    local showListCfg  = self.shopList[idx]
    local rewardData = showListCfg.reward
    local btnState = 0 -- 0可购买，1金币不足，2次数达到上限
    local sid = idx
    local ownGems = playerVoApi:getGems()
    local price = acWxgxVoApi:getPriceDis(idx)
    local limitNum = acWxgxVoApi:getRd(idx) 
    local limitMax = showListCfg.bn

    local cell = CCTableViewCell:new()
    cell:autorelease()
    local cellWidth = self.shopListCellSize.width
    local cellHeight = self.shopListCellSize.height

    if index ~= SizeOfTable(self.shopList) then
        local cellLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 1, 1, 1), function () end)
        cellLine:setContentSize(CCSizeMake(cellWidth - 10, cellLine:getContentSize().height))
        cellLine:setPosition(ccp(cellWidth / 2 - 5, 3))
        cell:addChild(cellLine)
    end

    local itemData = nil
    local itemName = ""
    local itemNum = 0
    local strSize = 22
    local adaH = 0
    if G_isAsia() == false then
        strSize = 20
    end
    local reward = FormatItem(rewardData,false,true) or {}
    if reward and next(reward) then
        local v = reward[1]
        itemData = v
        local icon, scale = G_getItemIcon(v, 100, true, self.layerNum + 1, nil, self.tv)
        icon:setPosition(ccp(50, cellHeight / 2))
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(icon, 1)

        local numLabel = GetTTFLabel("x" .. FormatNumber(v.num), strSize)
        numLabel:setAnchorPoint(ccp(1, 0))
        numLabel:setPosition(icon:getContentSize().width - 5, 5)
        numLabel:setScale(1 / scale)
        icon:addChild(numLabel, 1)

        local nameLb = GetTTFLabelWrap(getlocal("activity_wxgx_name", {v.name, limitNum, limitMax}),strSize,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        if nameLb:getContentSize().height > 30 then
            adaH = 12
        end
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(ccp(icon:getPositionX() + 55, cellHeight - 24+adaH))
        nameLb:setScale(1 / scale)
        nameLb:setColor(G_ColorGreen)
        icon:addChild(nameLb)
        local descLb = GetTTFLabelWrap(getlocal(v.desc), (strSize-4) / scale, CCSizeMake(cellWidth - 280, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setPosition(icon:getPositionX() + 55, 78)
        descLb:setAnchorPoint(ccp(0, 1))
        cell:addChild(descLb, 2)

        itemName = v.name
        itemNum = v.num
    end

    local function onBuyCallBack(tag, object)
        if self.tv:getIsScrolled() == true then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        if limitNum >= limitMax then
            -- 达到上限
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350),
                CCRect(168, 86, 10, 10), getlocal("activity_wxgx_limitTips"), 30)
            return
        end

        -- 检测金币
        if ownGems < price then
            GemsNotEnoughDialog(nil, nil, price - playerVoApi:getGems(), self.layerNum + 1, price)
            return
        end

        local function sureCallBack()
            if acWxgxVoApi:isEnd() == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                    getlocal("acOver"), 28)
                return
            end

            local function callBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local rewardlist = {}
                    if reward and next(reward) then
                        local addItem = reward[1]
                        G_addPlayerAward(addItem.type, addItem.key, addItem.id, addItem.num, nil, true)
                        table.insert(rewardlist, addItem)
                    end
                    acWxgxVoApi:updateData(sData.data.wxgx)
                    playerVoApi:setGems(playerVoApi:getGems() - price)
                    self:refresh()

                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    local function showEndHandler()
                        if itemData then
                            local awardItem = {
                                type=itemData.type,
                                key=itemData.key,
                                pic=itemData.pic,
                                name=itemData.name,
                                num=itemData.num,
                                desc=itemData.desc,
                                id=itemData.id,
                                bgname=itemData.bgname
                            }
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                                "", 28, nil, nil, {awardItem})
                        end
                    end
                    rewardShowSmallDialog:showNewReward(self.layerNum + 1, true, true, rewardlist,
                        showEndHandler, getlocal("but_get"), nil, nil, nil, "")
                end
            end

            socketHelper:acWxgxBuyshop(callBack, sid)
        end

        local title = getlocal("dialog_title_prompt")
        local content = getlocal("activity_wxgx_buy_tip", {price, itemNum, itemName})
        local tipDialog = smallDialog:new()
        tipDialog:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350),
            CCRect(168, 86, 10, 10), sureCallBack, title, content, nil, self.layerNum + 1)
    end

    local btnScale = 0.7
    local btnPosx = cellWidth - 100
    local str = getlocal("buy")
    local buyItemButton = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png",
        onBuyCallBack, 102, str, 24 / btnScale, 100)
    buyItemButton:setScale(btnScale)
    local okBtn = CCMenu:createWithItem(buyItemButton)
    okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    okBtn:setAnchorPoint(ccp(1, 0.5))
    okBtn:setPosition(ccp(btnPosx, 36))
    cell:addChild(okBtn)

    -- 原始价格
    local lbPosx = btnPosx - 15
    local goldIconPosx = btnPosx + 30
    local realLbPosy = cellHeight - 20
    local realLb = GetTTFLabel(acWxgxVoApi:getPrice(idx), 20)
    realLb:setAnchorPoint(ccp(0.5, 0.5))
    realLb:setPosition(ccp(lbPosx, realLbPosy))
    cell:addChild(realLb)
    local realCost = CCSprite:createWithSpriteFrameName("IconGold.png")
    realCost:setAnchorPoint(ccp(0.5, 0.5))
    realCost:setPosition(ccp(goldIconPosx, realLbPosy))
    cell:addChild(realCost)
    local redLine = CCSprite:createWithSpriteFrameName("redline.jpg")
    redLine:setAnchorPoint(ccp(0.5, 0.5))
    redLine:setScaleX(100 / redLine:getContentSize().width)
    redLine:setPosition(ccp(btnPosx, realLbPosy))
    cell:addChild(redLine, 1)
    -- 打折价格
    local disPosy = cellHeight / 2 + 16
    local dazheLb = GetTTFLabel(price, 20)
    dazheLb:setAnchorPoint(ccp(0.5, 0.5))
    dazheLb:setPosition(ccp(lbPosx, disPosy))

    if ownGems >= price or limitNum >= limitMax then
        dazheLb:setColor(G_ColorYellowPro)
        btnState = 0
    else
        dazheLb:setColor(G_ColorRed)
        btnState = 1
    end
    cell:addChild(dazheLb)
    local dazheCost = CCSprite:createWithSpriteFrameName("IconGold.png")
    dazheCost:setAnchorPoint(ccp(0.5, 0.5))
    dazheCost:setPosition(ccp(goldIconPosx, disPosy))
    cell:addChild(dazheCost)

    return cell
end

function acWxgxDialog:tick()
    if acWxgxVoApi:isEnd() == true then
        self:close()
        do return end
    end

    local acVo = acWxgxVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acWxgxVoApi:getTimeStr())
    end
end

function acWxgxDialog:refresh()
    if self.tv then
        self.shopKeyList = acWxgxVoApi:getShoplistSortKey()
        self.tv:reloadData()
    end
end

function acWxgxDialog:updateShowTop(isInit)
    local unlockId = acWxgxVoApi:getAcVo().exteriorId

    if self.rechargeLb then
        self.rechargeLb:removeFromParentAndCleanup(true)
    end

    local recharge1 = acWxgxVoApi:getV()
    local recharge2 = acWxgxVoApi:getAcVo().recharge
    if buildDecorateVoApi:judgeHas(unlockId) and buildDecorateVoApi:isExperience(unlockId) == false then
        recharge1 = recharge2
    else
        if recharge1 >= recharge2 then
            recharge1 = recharge2
        end
    end
    local rechargeStr = getlocal("activity_wxgx_info1",{recharge1, recharge2})
    local colorTab = {G_ColorWhite, G_ColorYellowPro2, G_ColorWhite}
    local rechargeLb, lbHeight = G_getRichTextLabel(rechargeStr, colorTab, 22, G_VisibleSizeWidth - 100, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    rechargeLb:setAnchorPoint(ccp(0.5, 1))
    rechargeLb:setPosition(ccp(G_VisibleSizeWidth / 2, self.showTopHeight - 82))
    self.showLayerTop:addChild(rechargeLb, 1)
    self.rechargeLb = rechargeLb

    if isInit == true then
        -- 装备配置
        local decorateCfg = exteriorCfg.exteriorLit[unlockId]
        local decorateLv = #decorateCfg.value[1]

        -- 属性背景
        local attrBg = CCSprite:createWithSpriteFrameName("amHeaderBg.png")
        attrBg:setAnchorPoint(ccp(1, 0.5))
        attrBg:setPosition(ccp(G_VisibleSizeWidth, rechargeLb:getPositionY() - 135))
        attrBg:setOpacity(100)
        attrBg:setScaleX(7)
        attrBg:setScaleY(4)
        attrBg:setFlipX(true)
        self.showLayerTop:addChild(attrBg)

        local attrLb = GetTTFLabel(getlocal("activity_wxgx_info2"), 24, true)
        attrLb:setAnchorPoint(ccp(0, 1))
        attrLb:setPosition(ccp(rechargeLb:getPositionX() - 50, rechargeLb:getPositionY() - 80))
        self.showLayerTop:addChild(attrLb)

        local strSize = 22
        local supX = 0
        if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
            strSize = 15
            supX = 40
        end
        for i,v in ipairs(decorateCfg.attType) do
            local value = decorateCfg.value[i][decorateLv]
            local attstr = value < 1 and tostring(value * 100) .. "%" or value
            attstr = getlocal("decorateAttr" .. v) .. " + " .. attstr
            local nameLb = GetTTFLabel(attstr, strSize)
            nameLb:setAnchorPoint(ccp(0, 1))
            nameLb:setPosition(ccp(attrLb:getPositionX() + 40 - supX, attrLb:getPositionY() - 40 - (i - 1) * 40))
            nameLb:setColor(G_ColorGreen)
            self.showLayerTop:addChild(nameLb)
        end

        local function onBuyCallBack(tag, object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.buyState == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                    getlocal("activity_wxgx_tips2"), 30)
                return
            end

            -- 检测金币
            if playerVoApi:getGems() < acWxgxVoApi:getAcVo().exteriorCost then
                GemsNotEnoughDialog(nil, nil, acWxgxVoApi:getAcVo().exteriorCost - playerVoApi:getGems(), self.layerNum + 1, acWxgxVoApi:getAcVo().exteriorCost)
                return
            end

            local function sureCallBack()
                if acWxgxVoApi:isEnd() == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("acOver"), 28)
                    return
                end

                local function callBack(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        playerVoApi:setGems(playerVoApi:getGems() - acWxgxVoApi:getAcVo().exteriorCost)
                        buildDecorateVoApi:unlockSkin(unlockId)
                        self:updateShowTop()

                        local paramTab = {}
                        paramTab.functionStr = "wxgx"
                        paramTab.addStr = "goTo_see_see"
                        paramTab.colorStr = "w"
                        local playerName = playerVoApi:getPlayerName()
                        local message = {key = "activity_wxgx_notice_tip", param = {playerName}}
                        chatVoApi:sendSystemMessage(message, paramTab)
                    end
                end

                socketHelper:acWxgxBuyexter(callBack)
            end

            local title = getlocal("dialog_title_prompt")
            local content = getlocal("activity_wxgx_tips4", {acWxgxVoApi:getAcVo().exteriorCost})
            local tipDialog = smallDialog:new()
            tipDialog:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350),
                CCRect(168, 86, 10, 10), sureCallBack, title, content, nil, self.layerNum + 1)
        end

        local btnScale = 0.7
        local buyItemButton = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onBuyCallBack, 102, getlocal("buy"), 24 / btnScale, 100)
        buyItemButton:setScale(btnScale)
        local okBtn = CCMenu:createWithItem(buyItemButton)
        okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        okBtn:setAnchorPoint(ccp(0.5, 0.5))
        okBtn:setPosition(ccp(G_VisibleSizeWidth / 2 + 130, 50))
        self.showLayerTop:addChild(okBtn)

        -- 价格
        local buyPriceWidth = 0
        local lbPosx = okBtn:getPositionX() + 2
        local disPosy = okBtn:getPositionY() + 42
        local buyLb = GetTTFLabel(acWxgxVoApi:getAcVo().exteriorCost, 20)
        buyLb:setAnchorPoint(ccp(0, 0.5))
        self.showLayerTop:addChild(buyLb)
        local buyCostIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        buyCostIcon:setAnchorPoint(ccp(1, 0.5))
        self.showLayerTop:addChild(buyCostIcon)
        -- 修正位置
        buyPriceWidth = buyLb:getContentSize().width + 15 + buyCostIcon:getContentSize().width
        buyLb:setPosition(ccp(lbPosx - buyPriceWidth / 2, disPosy))
        buyCostIcon:setPosition(ccp(lbPosx + buyPriceWidth / 2, disPosy))

        self.buyItemButton = buyItemButton
        self.buyLb = buyLb
        self.buyCostIcon = buyCostIcon

        local strSize = 24
        local stateLb = GetTTFLabelWrap("", strSize, CCSizeMake(300, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        stateLb:setAnchorPoint(ccp(0.5, 0.5))
        stateLb:setPosition(ccp(okBtn:getPositionX(), okBtn:getPositionY()))
        self.showLayerTop:addChild(stateLb)
        self.stateLb = stateLb

        if self.version ~= 5 then
            local buildIconSp = CCSprite:createWithSpriteFrameName(decorateCfg.decorateSp)
            buildIconSp:setPosition(ccp(140, 130))
            buildIconSp:setScale(1.2)
            self.showLayerTop:addChild(buildIconSp)

            local lockSp = CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
            lockSp:setPosition(ccp(buildIconSp:getPositionX(), buildIconSp:getPositionY()))
            self.showLayerTop:addChild(lockSp)
            self.lockSp = lockSp
        end
    end

    if buildDecorateVoApi:judgeHas(unlockId) and buildDecorateVoApi:isExperience(unlockId) == false then
        -- 已拥有
        self.buyItemButton:setVisible(false)
        self.buyLb:setVisible(false)
        self.buyCostIcon:setVisible(false)
        self.stateLb:setVisible(true)

        self.stateLb:setColor(G_ColorYellow)
        self.stateLb:setString(getlocal("activity_wxgx_tips3"))

        self.buyState = 1
    else
        -- 未解锁
        local playerLv = playerVoApi:getPlayerLevel()
        if playerLv < acWxgxVoApi:getAcVo().unlockNeedPlayerlv then
            -- 指挥官等级不足
            self.buyItemButton:setVisible(false)
            self.buyLb:setVisible(false)
            self.buyCostIcon:setVisible(false)

            self.stateLb:setVisible(true)

            self.stateLb:setColor(G_ColorRed)
            self.stateLb:setString(getlocal("activity_wxgx_tips1", {acWxgxVoApi:getAcVo().unlockNeedPlayerlv}))

            self.buyState = 0
        else
            self.buyItemButton:setVisible(true)
            self.buyLb:setVisible(true)
            self.buyCostIcon:setVisible(true)
            self.stateLb:setVisible(false)

            if recharge1 >= recharge2 then
                self.buyState = 2
            else
                self.buyState = 3
            end
        end
    end
    if self.version ~= 5 then
        self.lockSp:setVisible((self.buyState == 0))
    end
end

function acWxgxDialog:showBuildingFunction(buildingPic,parent,pos,aPos,scaleSize)
    local buildingSp = G_buildingAction3(buildingPic,parent,pos,aPos,scaleSize)
    self.buildingAc = buildingSp
    local buildingSpWidth = buildingSp:getContentSize().width
    --放大镜
    local magnifierNode=CCNode:create()
    magnifierNode:setPosition(buildingSpWidth - 120,50)
    magnifierNode:setTag(1016)
    parent:addChild(magnifierNode)
    local nodeWidth,nodeHeight = magnifierNode:getContentSize().width ,magnifierNode:getContentSize().height

    local circelCenter=getCenterPoint(magnifierNode)
    local radius,rt,rtimes=10,2,2
    local magnifierSp=LuaCCSprite:createWithSpriteFrameName("ydcz_magnifier.png",function() end)
    self.magnifierSp = magnifierSp
    magnifierSp:setScale(0.6)
    magnifierSp:setTouchPriority(-(self.layerNum-1)*20-4)
    magnifierSp:setPosition(circelCenter)
    magnifierNode:addChild(magnifierSp)

    local acArr=CCArray:create()
    local moveTo=CCMoveTo:create(0.5,ccp(nodeWidth * 0.5,radius))
    local function rotateBy()
        if magnifierSp and circelCenter then
            G_requireLua("componet/CircleBy")
            self.circelAc=CircleBy:create(magnifierSp,rt,circelCenter,radius,rtimes)
        end
    end
    local function removeRotateBy()
        if self.circelAc and self.circelAc.stop then
            self.circelAc:stop()
        end
    end
    local moveTo2=CCMoveTo:create(0.5,ccp(nodeWidth * 0.5,nodeHeight * 0.5))
    local delay=CCDelayTime:create(1)
    acArr:addObject(moveTo)
    acArr:addObject(CCCallFunc:create(rotateBy))
    acArr:addObject(CCDelayTime:create(rt))
    acArr:addObject(CCCallFunc:create(removeRotateBy))
    acArr:addObject(moveTo2)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    magnifierSp:runAction(CCRepeatForever:create(seq))

    local function touchHandle( )
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local titleStr = getlocal("buildingReadyToShow")
        local needTb = {"hryx",titleStr,3,true,"wxgx"}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
    end 
    local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandle)
    touchSp:setContentSize(CCSizeMake(buildingSpWidth * 0.8,buildingSp:getContentSize().height))
    touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    touchSp:setAnchorPoint(ccp(0,0))
    touchSp:setPosition(0,0)
    touchSp:setOpacity(0)
    parent:addChild(touchSp)
end