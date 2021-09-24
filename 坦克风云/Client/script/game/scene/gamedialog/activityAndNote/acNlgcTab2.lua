acNlgcTab2 = commonDialog:new()

function acNlgcTab2:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acNlgcTab2:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    return self.bgLayer
end
function acNlgcTab2:updateUI()
    local acVo = acNlgcVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            
        elseif self ~= nil and self.tv2 ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
            
            local recordPoint2 = self.tv2:getRecordPoint()
            self.tv2:reloadData()
            self.tv2:recoverToRecordPoint(recordPoint2)
            
            self.eneryLb:setString(getlocal("ac_nlgc_lab6", {acVo.enery}))
        end
    end
end

function acNlgcTab2:initTableView()
    local vo = acNlgcVoApi:getAcVo()
    local acVo = acNlgcVoApi:getAcVo()
    local cfg = vo.acCfg
    local sy = G_VisibleSizeHeight - 160
    
    local backSprite = CCSprite:create("public/rechaegeAd2_audit.jpg")
    backSprite:setAnchorPoint(ccp(0.5, 1))
    backSprite:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 160)
    self.bgLayer:addChild(backSprite)
    local bkgW = backSprite:getContentSize().width
    local bkgH = backSprite:getContentSize().height
    
    local desLabel = G_LabelTableView(CCSizeMake(400, 80), getlocal("ac_nlgc_tab2_desc", {cfg.discountLimit * 100}), 22, kCCTextAlignmentLeft)
    desLabel:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    desLabel:setMaxDisToBottomOrTop(70)
    desLabel:setAnchorPoint(ccp(0, 0))
    desLabel:setPosition(ccp(180, 86))
    backSprite:addChild(desLabel, 5)
    
    local eneryLb = GetTTFLabel(getlocal("ac_nlgc_lab6", {vo.enery}), G_getLS(22, 18))
    eneryLb:setAnchorPoint(ccp(0, 0.5))
    eneryLb:setPosition(ccp(158, 30))
    backSprite:addChild(eneryLb)
    self.eneryLb = eneryLb
    
    local descxxLb = GetTTFLabel(getlocal("ac_nlgc_lab8", {cfg.diamondRatio}), G_getLS(22, 16))
    descxxLb:setAnchorPoint(ccp(1, 0.5))
    descxxLb:setPosition(backSprite:getContentSize().width - 10, eneryLb:getPositionY())
    backSprite:addChild(descxxLb)
    
    local enerySp = CCSprite:createWithSpriteFrameName("ac_nlgc_item_icon.png")
    enerySp:setAnchorPoint(ccp(0, 0.5))
    enerySp:setScale(0.5)
    enerySp:setPosition(eneryLb:getPositionX() + eneryLb:getContentSize().width, eneryLb:getPositionY())
    backSprite:addChild(enerySp)
    
    local function touch(tag, object)
        local tabStr = {getlocal("ac_nlgc_tab2_info1", {cfg.discountLimit * 100}), getlocal("ac_nlgc_tab2_info2"), getlocal("ac_nlgc_tab2_info3"), getlocal("ac_nlgc_tab2_info4")}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr)
    end
    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch, nil, nil, 0)
    menuItemDesc:setScale(0.8)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(bkgW - 50, bkgH - 40))
    backSprite:addChild(menuDesc, 1)
    
    self.tvLen2 = SizeOfTable(cfg.shop)
    self.tvW2 = 180
    self.tvH2 = 250
    local tvWidth, tvHeight = G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 425 - 35
    local function callBack2(...)
        return self:eventHandler2(...)
    end
    local hd2 = LuaEventHandler:createHandler(callBack2)
    self.tv2 = LuaCCTableView:createWithEventHandler(hd2, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv2:setAnchorPoint(ccp(0, 0))
    self.tv2:setPosition(10, 35)
    self.bgLayer:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(120)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenSellBg.png", CCRect(64, 110, 2, 2), function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth, tvHeight))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(G_VisibleSizeWidth / 2, self.tv2:getPositionY())
    tvBg:setOpacity(0)
    self.bgLayer:addChild(tvBg)

    G_addForbidForSmallDialog2(self.bgLayer, tvBg, -(self.layerNum - 1) * 20 - 3, nil, 0)
    
    self:updateUI()
end

function acNlgcTab2:eventHandler2(handler, fn, idx, cel)
    local acVo = acNlgcVoApi:getAcVo()
    if fn == "numberOfCellsInTableView" then
        return math.ceil(self.tvLen2 / 3)
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvW2, self.tvH2)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local tw = G_VisibleSizeWidth - 20
        local posTb = {tw * 0.2, tw * 0.5, tw * 0.8}
        for i = 1, 3 do
            local ixs = idx * 3 + i - 1
            if ixs < self.tvLen2 then
            else
                return cell
            end
            
            -- local cellSp = LuaCCSprite:createWithSpriteFrameName("acjtzksd_bkg.png", function()end)
            local cellSp = LuaCCScale9Sprite:createWithSpriteFrameName("greenSellBg.png", CCRect(64, 110, 2, 2), function ()end)
            cellSp:setContentSize(CCSizeMake(self.tvW2, self.tvH2))
            cellSp:setAnchorPoint(ccp(0.5, 0))
            -- cellSp:setOpacity(0)
            cellSp:setPosition(posTb[i], 0)
            cell:addChild(cellSp)
            self:initCell(cellSp, ixs)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function acNlgcTab2:initCell(cell, idx)
    local vo = acNlgcVoApi:getAcVo()
    local cfg = vo.acCfg.shop[idx + 1]
    local itemInfo = FormatItem(cfg.r, true, true)[1]
    local buiesNum = vo.times[idx + 1]
    local canBuyNum = cfg.limit - buiesNum
    local zheNum = (1 - cfg.discount) * 100
    local curPrice = math.ceil(cfg.price * cfg.discount)
    
    local function touch(tag, object)
        if self.tv2:getScrollEnable() == true and self.tv2:getIsScrolled() == false then
            
            local function buyCallBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true and sData.data.nlgc and self and self.bgLayer then
                    acNlgcVoApi:updateData(sData.data.nlgc)
                    local rewardList = FormatItem(sData.data.nlgc.r, true, true)
                    G_takeReward(rewardList, sData.data)
                    G_showRewardTip(rewardList, true)
                    
                    local costNum = curPrice - self.dkNum
                    playerVoApi:setGems(playerVoApi:getGems() - costNum)
                    
                    self:updateUI()
                end
            end
            
            local function sureFun(eneryNum, dkNum)
                self.dkNum = dkNum
                local costNum = curPrice - self.dkNum
                local function realBuy()
                    socketHelper:nlgc_shop(cfg.index, eneryNum, buyCallBack)
                end
                if costNum > 0 then --扣除的金币数大于0
                    G_dailyConfirm("active.nlgc.buy", getlocal("second_tip_des", {costNum}), realBuy, self.layerNum + 1)
                else
                    realBuy()
                end
            end
            require "luascript/script/game/scene/gamedialog/activityAndNote/acNlgcBuyDialog"
            local td = acNlgcBuyDialog:new()
            local minNum = 0
            local diamondRatio = vo.acCfg.diamondRatio
            local maxDK = math.ceil(curPrice * vo.acCfg.discountLimit)
            local maxNum = math.min(math.ceil(maxDK / diamondRatio), vo.enery)
            td:init(self.layerNum + 1, sureFun, minNum, maxNum, curPrice, diamondRatio, maxDK)
        end
    end
    
    local icon, iconScale = G_getItemIcon(itemInfo, 80, true, self.layerNum)
    icon:setAnchorPoint(ccp(0.5, 1))
    icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    icon:setPosition(self.tvW2 * 0.5, self.tvH2 - 15)
    cell:addChild(icon, 1)
    
    local picNumsStr = GetTTFLabel("x"..itemInfo.num, 25)
    picNumsStr:setAnchorPoint(ccp(1, 0))
    picNumsStr:setPosition(ccp(icon:getPositionX() + 40, icon:getPositionY() - 80))
    cell:addChild(picNumsStr, 2)
    
    local sy = 160
    local lastNumLb = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule", {canBuyNum, cfg.limit}), 25)
    lastNumLb:setAnchorPoint(ccp(0.5, 0.5))
    lastNumLb:setPosition(self.tvW2 * 0.5, sy - 25)
    cell:addChild(lastNumLb)
    
    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setScale(1.2)
    goldIcon:setAnchorPoint(ccp(0, 0.5))
    goldIcon:setPosition(icon:getPositionX() - 60, sy - 75)
    cell:addChild(goldIcon, 1)
    
    local costStr2 = GetTTFLabel(curPrice, 22)
    costStr2:setAnchorPoint(ccp(0, 0.5))
    costStr2:setPosition(goldIcon:getPositionX() + 35, goldIcon:getPositionY() - 10)
    cell:addChild(costStr2, 1)
    costStr2:setColor(G_ColorGreen)
    
    local btnItem1 = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", touch, idx + 1, getlocal("buy"), 25)
    btnItem1:setScale(0.7)
    btnItem1:setAnchorPoint(ccp(0.5, 0))
    -- btnItem1:setScale(0.8)
    local btn1 = CCMenu:createWithItem(btnItem1);
    btn1:setTouchPriority(-(self.layerNum - 1) * 20 - 2);
    btn1:setPosition(ccp(self.tvW2 * 0.5, 8))
    cell:addChild(btn1)
    
    if canBuyNum < 1 then
        btnItem1:setEnabled(false)
    end
    
    if zheNum > 0 then
        local costStr = GetTTFLabel(cfg.price, 25)
        costStr:setAnchorPoint(ccp(0, 0.5))
        costStr:setPosition(goldIcon:getPositionX() + 35, goldIcon:getPositionY() + 15)
        cell:addChild(costStr, 1)
        costStr:setColor(G_ColorRed)
        
        local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
        rline:setScaleX(costStr:getContentSize().width / rline:getContentSize().width)
        rline:setPosition(ccp(costStr:getPositionX(), costStr:getPositionY()))
        rline:setAnchorPoint(ccp(0, 0.5))
        cell:addChild(rline)
        
        local sellIcon = CCSprite:createWithSpriteFrameName("monthlysignFreeVip.png")
        sellIcon:setPosition(0, self.tvH2 - 2)
        sellIcon:ignoreAnchorPointForPosition(false)
        sellIcon:setAnchorPoint(ccp(0, 1))
        cell:addChild(sellIcon, 10)
        
        local saleNumStr = GetTTFLabel("-"..zheNum.."%", 25)
        saleNumStr:setAnchorPoint(ccp(0.5, 0.5))
        saleNumStr:setPosition(sellIcon:getContentSize().width - 50, sellIcon:getContentSize().height - 25)
        saleNumStr:setRotation(-45)
        sellIcon:addChild(saleNumStr)
    else
        costStr2:setPosition(goldIcon:getPositionX() + 35, goldIcon:getPositionY())
    end
end

function acNlgcTab2:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer = nil
    end
end
