allianceCoinShopTab = {}

function allianceCoinShopTab:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function allianceCoinShopTab:init(layerNum, parent)
    self.layerNum = layerNum
    self.parent = parent
    
    self.bgLayer = CCLayer:create()
    
    local headerSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png", CCRect(50, 20, 1, 1), function () end)
    headerSprie:setContentSize(CCSizeMake(616, 90))
    headerSprie:ignoreAnchorPointForPosition(false)
    headerSprie:setAnchorPoint(ccp(0.5, 1))
    headerSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    headerSprie:setPosition(self.bgLayer:getContentSize().width / 2, G_VisibleSizeHeight - 165)
    self.bgLayer:addChild(headerSprie)
    
    local pointSp = CCSprite:createWithSpriteFrameName("csi_coin.png")
    pointSp:setAnchorPoint(ccp(0, 0.5))
    local scale = 70 / pointSp:getContentSize().width
    pointSp:setScale(scale)
    pointSp:setPosition(20, headerSprie:getContentSize().height / 2)
    headerSprie:addChild(pointSp)
    
    local nameLb = GetTTFLabel(getlocal("believer_kcoin"), 20)
    headerSprie:addChild(nameLb)
    nameLb:setAnchorPoint(ccp(0, 0))
    nameLb:setPosition(110, headerSprie:getContentSize().height / 2 + 5)
    
    local coin = championshipWarVoApi:getMyCoin()
    local valueLb = GetTTFLabel(coin, 20)
    headerSprie:addChild(valueLb)
    valueLb:setAnchorPoint(ccp(0, 1))
    valueLb:setColor(G_ColorGreen)
    valueLb:setPosition(110, headerSprie:getContentSize().height / 2 - 5)
    self.valueLb = valueLb
    
    local function infoHandler(tag, object)
        local tabStr = {}
        for i = 1, 3 do
            local str = getlocal("championshipWar_shop_tip"..i)
            table.insert(tabStr, str)
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local priority = -(self.layerNum - 1) * 20 - 4
    local btnPos = ccp(headerSprie:getContentSize().width - 60, headerSprie:getContentSize().height / 2)
    G_createBotton(headerSprie, btnPos, nil, "i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", infoHandler, 0.8, priority)
    
    self.nameFontSize, self.descFontSize = 20, 18
    local tvWidth, tvHeight = 616, G_VisibleSizeHeight - 300
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png", CCRect(10, 10, 12, 12), function () end)
    tvBg:setContentSize(CCSizeMake(616, tvHeight + 10))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(G_VisibleSizeWidth / 2, 30)
    self.bgLayer:addChild(tvBg)
    
    self.cellWidth, self.cellHeight = tvWidth, 120
    local warCfg = championshipWarVoApi:getWarCfg()
    local warGradeLv = championshipWarVoApi:getGrade()
    local championWarShop = warCfg["championWarShop"..warGradeLv]
    self.cellNum = SizeOfTable(championWarShop)
    self.shopList = {}
    for k = 1, self.cellNum do
        local id = "c"..k
        local shopItem = championWarShop[id]
        local reward = FormatItem(shopItem.r)[1]
        table.insert(self.shopList, {id = id, bn = shopItem.bn, p = shopItem.p, r = reward})
    end
    self.buyData = championshipWarVoApi:getBuyData().b2 or {}
    
    self:updateData()
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.tv:setPosition((G_VisibleSizeWidth - tvWidth) / 2, 40)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    return self.bgLayer
end

function allianceCoinShopTab:updateData()
    self.buyData = championshipWarVoApi:getBuyData().b2 or {}
    local function sort(v1, v2)
        local w1 = tonumber(RemoveFirstChar(v1.id)) * 100 + ((tonumber(self.buyData[v1.id] or 0) >= v1.bn) and 2 or 1) * 10
        local w2 = tonumber(RemoveFirstChar(v2.id)) * 100 + ((tonumber(self.buyData[v2.id] or 0) >= v2.bn) and 2 or 1) * 10
        if w1 < w2 then
            return true
        end
        return false
    end
    table.sort(self.shopList, sort)
end

function allianceCoinShopTab:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.cellWidth, self.cellHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local shopItem = self.shopList[idx + 1]
        local id = shopItem.id
        local buyNum = self.buyData[id] or 0 --当前购买次数
        local limit = shopItem.bn --购买上限
        local reward = shopItem.r
        local cost = shopItem.p --消耗的联赛币
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, reward, true)
            return false
        end
        local iconSp, scale = G_getItemIcon(reward, 100, true, self.layerNum + 1, showNewPropInfo)
        iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        iconSp:setAnchorPoint(ccp(0, 0.5))
        iconSp:setPosition(15, self.cellHeight / 2)
        cell:addChild(iconSp)
        local iconWidth = iconSp:getContentSize().width * iconSp:getScaleX()
        local iconHeight = iconSp:getContentSize().height * iconSp:getScaleY()
        
        local numLb = GetTTFLabel("x"..reward.num, 20)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setPosition(ccp(iconSp:getContentSize().width - 5, 5))
        numLb:setScale(1 / scale)
        iconSp:addChild(numLb, 3)
        
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 3))
        numBg:setPosition(ccp(iconSp:getContentSize().width - 5, 5))
        numBg:setOpacity(150)
        iconSp:addChild(numBg, 2)
        
        local nameLb = GetTTFLabelWrap(reward.name, self.nameFontSize, CCSizeMake(self.cellWidth - 280, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        nameLb:setPosition(15 + iconWidth + 10, self.cellHeight - nameLb:getContentSize().height / 2 - 20)
        nameLb:setAnchorPoint(ccp(0, 0.5))
        nameLb:setColor(G_ColorYellowPro)
        cell:addChild(nameLb)
        local tempNameLb = GetTTFLabel(reward.name, self.nameFontSize)
        local realW = tempNameLb:getContentSize().width
        if realW > nameLb:getContentSize().width then
            realW = nameLb:getContentSize().width
        end
        
        if limit > 0 then
            local limitLb = GetTTFLabel("("..buyNum.."/"..limit..")", self.nameFontSize)
            limitLb:setAnchorPoint(ccp(0, 0.5))
            limitLb:setPosition(nameLb:getPositionX() + realW + 5, nameLb:getPositionY())
            if G_getCurChoseLanguage() =="ar" then
                limitLb:setPositionX(limitLb:getPositionX() - realW)
            end
            cell:addChild(limitLb)
        end
        
        local descLb = GetTTFLabelWrap(G_getItemDesc(reward), self.descFontSize, CCSizeMake(self.cellWidth - 280, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        descLb:setPosition(15 + iconWidth + 10, nameLb:getPositionY() - nameLb:getContentSize().height / 2 - 10)
        descLb:setAnchorPoint(ccp(0, 1))
        cell:addChild(descLb)
        
        local function buyHandler()
            if self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if championshipWarVoApi:isRestBattle(true) == true then
                    do return end
                end
                local function realBuy()
                    local function buyCallBack()
                        self:refresh()
                        G_showRewardTip({reward}, true)
                        G_addPlayerAward(reward.type, reward.key, reward.id, reward.num, nil, true)
                    end
                    local grade = championshipWarVoApi:getGrade()
                    championshipWarVoApi:championshipWarShopBuy(2, id, grade, buyCallBack)
                end
                local key = "championshipWar_pointshop_buy"
                local function secondTipFunc(flag)
                    local sValue = base.serverTime .. "_" .. flag
                    G_changePopFlag(key, sValue)
                end
                if G_isPopBoard(key) then
                    G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("dialog_title_prompt"), getlocal("ladder_shopBuy", {cost..getlocal("believer_kcoin"), reward.name}), true, realBuy, secondTipFunc)
                else
                    realBuy()
                end
            end
        end
        local priority = -(self.layerNum - 1) * 20 - 3
        local buyItem = G_createBotton(cell, ccp(self.cellWidth - 80, self.cellHeight / 2 - 20), {getlocal("code_gift")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", buyHandler, 0.7, priority)
        local coin = championshipWarVoApi:getMyCoin()
        if (coin < cost) or (limit > 0 and buyNum >= limit) then --功勋值不够或者购买已达上限或者没有达到段位需求不可购买
            buyItem:setEnabled(false)
        end
        
        local costSp = CCSprite:createWithSpriteFrameName("csi_coin.png")
        costSp:setAnchorPoint(ccp(0, 0.5))
        local scale = 32 / costSp:getContentSize().width
        costSp:setScale(scale)
        cell:addChild(costSp)
        local costLb = GetTTFLabel(cost, self.nameFontSize)
        costLb:setAnchorPoint(ccp(0, 0.5))
        if coin < cost then
            costLb:setColor(G_ColorRed)
        end
        cell:addChild(costLb)
        local costWidth = costSp:getContentSize().width * scale + costLb:getContentSize().width + 10
        costSp:setPosition(self.cellWidth - 80 - costWidth / 2, self.cellHeight / 2 + 25)
        costLb:setPosition(costSp:getPositionX() + costSp:getContentSize().width * scale + 10, costSp:getPositionY())
        
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function ()end)
        lineSp:setContentSize(CCSizeMake((self.cellWidth - 4), 2))
        lineSp:setRotation(180)
        lineSp:setPosition(self.cellWidth / 2, 0)
        cell:addChild(lineSp)
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function allianceCoinShopTab:refresh()
    self:updateData()
    local coin = championshipWarVoApi:getMyCoin()
    if self.valueLb then
        self.valueLb:setString(coin)
    end
    if self.tv then
        self.tv:reloadData()
    end
end

function allianceCoinShopTab:tick()
    
end

function allianceCoinShopTab:dispose()
    
end
