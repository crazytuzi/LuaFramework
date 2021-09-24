acNlgcTab1 = commonDialog:new()

function acNlgcTab1:new(callFun)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    nc.callFun = callFun
    return nc
end

function acNlgcTab1:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    return self.bgLayer
end

function acNlgcTab1:initTableView()
    local vo = acNlgcVoApi:getAcVo()
    local cfg = vo.acCfg
    local sy = G_VisibleSizeHeight - 160
    
    local backSprite = CCSprite:create("public/rechaegeAd2_audit.jpg")
    backSprite:setAnchorPoint(ccp(0.5, 1))
    backSprite:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 160)
    self.bgLayer:addChild(backSprite)
    local bkgW = backSprite:getContentSize().width
    local bkgH = backSprite:getContentSize().height
    
    local desLabel = G_LabelTableView(CCSizeMake(400, 80), getlocal("ac_nlgc_desc", {cfg.diamondRatio}), 22, kCCTextAlignmentLeft)
    desLabel:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    desLabel:setMaxDisToBottomOrTop(70)
    desLabel:setAnchorPoint(ccp(0, 0))
    desLabel:setPosition(ccp(180, 86))
    backSprite:addChild(desLabel, 5)
    
    local eneryLb = GetTTFLabel(getlocal("ac_nlgc_lab6", {vo.enery}), G_getLS(20, 18))
    eneryLb:setAnchorPoint(ccp(0, 0.5))
    eneryLb:setPosition(ccp(158, 30))
    backSprite:addChild(eneryLb)
    self.eneryLb = eneryLb
    
    local enerySp = CCSprite:createWithSpriteFrameName("ac_nlgc_item_icon.png")
    enerySp:setAnchorPoint(ccp(0, 0.5))
    enerySp:setScale(0.5)
    enerySp:setPosition(eneryLb:getPositionX() + eneryLb:getContentSize().width, eneryLb:getPositionY())
    backSprite:addChild(enerySp)
    self.enerySp = enerySp
    
    local descxxLb = GetTTFLabelWrap(getlocal("ac_nlgc_lab8", {cfg.diamondRatio}), G_getLS(20, 16), CCSizeMake(G_VisibleSizeWidth/2, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    descxxLb:setAnchorPoint(ccp(0, 0.5))
    descxxLb:setPosition(backSprite:getContentSize().width - 10 - descxxLb:getContentSize().width, eneryLb:getPositionY())
    backSprite:addChild(descxxLb)
    
    local function touch(tag, object)
        local tabStr = {getlocal("ac_nlgc_info1"), getlocal("ac_nlgc_info2")}
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
    
    self.len = #cfg.taskList
    self.tvH = 150
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth, sy - backSprite:getContentSize().height - 140), nil)
    tv:setAnchorPoint(ccp(0, 0))
    tv:setPosition(ccp(0, 135))
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(tv)
    self.tv = tv
    
    local topforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), function()end)
    topforbidSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    topforbidSp:setAnchorPoint(ccp(0, 0))
    topforbidSp:setContentSize(CCSize(G_VisibleSizeWidth, 120))
    topforbidSp:setPosition(0, 0)
    topforbidSp:setOpacity(0)
    self.bgLayer:addChild(topforbidSp, 2)
    
    local function gotoHandler()
        if self.callFun then
            self:callFun()
        end
    end
    local gotoItem = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", gotoHandler, 2, getlocal("ac_nlgc_lab5"), 25)
    local gotoMenu = CCMenu:createWithItem(gotoItem)
    gotoMenu:setAnchorPoint(ccp(0.5, 0))
    gotoMenu:setPosition(G_VisibleSizeWidth * 0.5, 60)
    gotoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    self.bgLayer:addChild(gotoMenu)
    
    self:updateUI()
end

function acNlgcTab1:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.len
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth, self.tvH)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local vo = acNlgcVoApi:getAcVo()
        local cfg = vo.acCfg
        local info = cfg.taskList[idx + 1]
        local drawEdNum = vo.rd[idx + 1]
        local maxDrawNum = info.limit
        local lastDrawNum = maxDrawNum - drawEdNum
        local curNum = math.min(vo.gems, info.diamond)
        local maxNum = info.diamond
        local canDrawNum = math.min(math.floor(vo.gems / info.diamond) - drawEdNum, maxDrawNum - drawEdNum)
        
        local cellH = self.tvH - 5
        local cellBkg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
        cellBkg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, cellH))
        cellBkg:setAnchorPoint(ccp(0, 0))
        cellBkg:setPosition(20, 5)
        cell:addChild(cellBkg)
        
        local titleSp = LuaCCScale9Sprite:createWithSpriteFrameName("questionTitleBg.png", CCRect(105, 16, 1, 1), function () end)
        titleSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, titleSp:getContentSize().height))
        titleSp:setAnchorPoint(ccp(0, 1))
        titleSp:setPosition(5, cellH - 5)
        cellBkg:addChild(titleSp)
        
        local titleStr = ""
        if cfg.types == 1 then
            if info.cycle == 1 then
                titleStr = "ac_nlgc_lab1"
            else
                titleStr = "ac_nlgc_lab2"
            end
        else
            if info.cycle == 1 then
                titleStr = "ac_nlgc_lab3"
            else
                titleStr = "ac_nlgc_lab4"
            end
        end
        local titleLb = GetTTFLabelWrap(getlocal(titleStr, {curNum, maxNum}), G_getLS(22, 18), CCSizeMake(580, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0, 0.5))
        titleLb:setPosition(ccp(12, titleSp:getContentSize().height / 2))
        titleSp:addChild(titleLb)
        
        local function checkTvScroll()
            if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                return true
            else
                return false
            end
        end
        
        local iconW = 80
        local item = vo.item
        local rd = FormatItem(item)[1]
        rd.num = info.reward
        local icon, iconScale = G_getItemIcon(rd, iconW, true, self.layerNum, checkTvScroll, nil, nil, nil, nil, true)
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        icon:setAnchorPoint(ccp(0, 0))
        icon:setPosition(10, 10)
        cellBkg:addChild(icon)
        
        local numLb = GetTTFLabel(rd.num, 20)
        numLb:setAnchorPoint(ccp(1, 0.5))
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
        numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
        numBg:setOpacity(150)
        icon:addChild(numBg, 2)
        numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
        numBg:addChild(numLb)
        
        local function gotoFun(tag, object)
            if checkTvScroll() == true then
                -- G_goToDialog(shopTb.type,self.layerNum+1,true)
            end
        end
        
        local function drawFun(tag, object)
            local function realSwitchSubTab(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true and sData.data.nlgc and self and self.bgLayer then
                    acNlgcVoApi:updateData(sData.data.nlgc)
                    local reward = FormatItem(sData.data.nlgc.r, true, true)
                    G_showRewardTip(reward, true)
                    self:updateUI()
                end
            end
            if checkTvScroll() == true then
                socketHelper:nlgc_reward(tag, canDrawNum, realSwitchSubTab)
            end
        end
        local buyItem
        if canDrawNum > 0 then
            local btnStr = ""
            if info.cycle == 1 then
                btnStr = getlocal("ac_nlgc_get", {canDrawNum})
            else
                btnStr = getlocal("daily_scene_get")
            end
            buyItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", drawFun, idx + 1, btnStr, G_getLS(25, 22))
            buyItem:setEnabled(true)
        else
            local btnStr = ""
            if drawEdNum >= maxDrawNum then
                btnStr = getlocal("activity_hadReward")
            else
                btnStr = getlocal("daily_scene_get")
            end
            buyItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", drawFun, idx + 1, btnStr, G_getLS(25, 22))
            buyItem:setEnabled(false)
        end
        buyItem:setScale(0.8)
        buyItem:setAnchorPoint(ccp(1, 0))
        local buyBtn = CCMenu:createWithItem(buyItem)
        buyBtn:setPosition(G_VisibleSizeWidth - 50, 15)
        buyBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cellBkg:addChild(buyBtn)
        
        if idx == 0 then
            local limitLb = GetTTFLabel(getlocal("ac_nlgc_avaibleget", {lastDrawNum, maxDrawNum}), G_getLS(20, 18))
            limitLb:setPosition(600, 100)
            limitLb:setAnchorPoint(ccp(1, 0.5))
            cell:addChild(limitLb)
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

function acNlgcTab1:updateUI()
    local acVo = acNlgcVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
            
            self.eneryLb:setString(getlocal("ac_nlgc_lab6", {acVo.enery}))
            self.enerySp:setPosition(self.eneryLb:getPositionX() + self.eneryLb:getContentSize().width, self.eneryLb:getPositionY())
        end
    end
end

function acNlgcTab1:dispose()
end
