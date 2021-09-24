reviveHeroSmallDialog = smallDialog:new()

function reviveHeroSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function reviveHeroSmallDialog:showReviveHeroView(layerNum)
    local sd = reviveHeroSmallDialog:new()
    sd:initReviveHeroView(layerNum)
end

function reviveHeroSmallDialog:initReviveHeroView(layerNum)
    self.layerNum = layerNum
    self.dialogBgWidth, self.dialogBgHeight = 550, 180
    local tvWidth, tvHeight = self.dialogBgWidth - 40, 450
    self.dialogBgHeight = self.dialogBgHeight + tvHeight
    local tipFontSize = 20
    local reviveNumLb = GetTTFLabelWrap(getlocal("daily_revive_leftnum", {expeditionVoApi:getLeftReviveNum()}), tipFontSize + 2, CCSizeMake(self.dialogBgWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    reviveNumLb:setAnchorPoint(ccp(0.5, 1))
    reviveNumLb:setColor(G_ColorYellowPro)
    self.dialogBgHeight = self.dialogBgHeight + reviveNumLb:getContentSize().height + 20
    
    local reviveTipLb = GetTTFLabelWrap(getlocal("daily_revive_tip"), tipFontSize, CCSizeMake(self.dialogBgWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    reviveTipLb:setAnchorPoint(ccp(0.5, 1))
    self.dialogBgHeight = self.dialogBgHeight + reviveTipLb:getContentSize().height + 10
    
    self.bgSize = CCSizeMake(self.dialogBgWidth, self.dialogBgHeight)
    
    local touchDialogBg
    
    local function cancel()
        -- self:close()
        touchDialogBg:setOpacity(0)
        local function close()
            self:close()
        end
        local arr = CCArray:create()
        local scaleTo = CCScaleTo:create(0.2, 0)
        local moveTo = CCMoveTo:create(0.2, ccp(80, G_VisibleSizeHeight - 80))
        arr:addObject(scaleTo)
        arr:addObject(moveTo)
        local swpan = CCSpawn:create(arr)
        local func = CCCallFunc:create(close)
        self.bgLayer:runAction(CCSequence:createWithTwoActions(swpan, func))
    end
    local function nilFunc()
    end
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("revive_hero_title"), 28, nilFunc, self.layerNum, true, cancel)
    self.bgLayer = dialogBg
    dialogBg:setContentSize(self.bgSize)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer:setAnchorPoint(ccp(0, 1))
    self.bgLayer:setPosition((G_VisibleSizeWidth - self.bgSize.width) / 2, G_VisibleSizeHeight / 2 + self.bgSize.height / 2)
    self.dialogLayer:addChild(self.bgLayer, 2)
    self:show()
    
    self.bgLayer:addChild(reviveNumLb, 2)
    self.bgLayer:addChild(reviveTipLb, 2)
    reviveTipLb:setPosition(self.dialogBgWidth / 2, self.dialogBgHeight - 75)
    reviveNumLb:setPosition(self.dialogBgWidth / 2, reviveTipLb:getPositionY() - reviveTipLb:getContentSize().height - 15)
    
    local hnameFontSize, hnameWidth, heroIconWidth, maxHeroNameHeight = 20, 100, 90, 0
    local deadHeroList = {}
    local dhero = expeditionVoApi:getDeadHero()
    for k, v in pairs(dhero) do --获取将领vo插入列表
        local heroVo = G_clone(heroVoApi:getHeroByHid(v))
        table.insert(deadHeroList, heroVo)
        local nameLb = GetTTFLabelWrap(heroVoApi:getHeroName(v), hnameFontSize, CCSizeMake(hnameWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        if nameLb:getContentSize().height > maxHeroNameHeight then
            maxHeroNameHeight = nameLb:getContentSize().height
        end
    end
    table.sort(deadHeroList, function(a, b) return a.sortId > b.sortId end) --对将领进行排序
    
    local hspace, nameSpace, iconSpace = 70, 20, 10
    local cellHeight = math.ceil(SizeOfTable(dhero) / 3) * (heroIconWidth + nameSpace + maxHeroNameHeight + iconSpace + 10)
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(tvWidth, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local posX, posY = 0, cellHeight
            for k, v in pairs(deadHeroList) do
                if k % 3 == 1 then
                    posX = tvWidth / 2 - heroIconWidth - hspace
                elseif k % 3 == 0 then
                    posX = tvWidth / 2 + heroIconWidth + hspace
                else
                    posX = tvWidth / 2
                end
                local heroIconSp = heroVoApi:getHeroIcon(v.hid, v.productOrder, true)
                heroIconSp:setScale(heroIconWidth / heroIconSp:getContentSize().width)
                heroIconSp:setPosition(posX, posY - heroIconWidth / 2 - 10)
                cell:addChild(heroIconSp)
                
                local color = heroVoApi:getHeroColor(v.productOrder)
                local heroNameLb = GetTTFLabelWrap(heroVoApi:getHeroName(v.hid), hnameFontSize, CCSizeMake(hnameWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                heroNameLb:setAnchorPoint(ccp(0.5, 1))
                heroNameLb:setPosition(posX, heroIconSp:getPositionY() - heroIconWidth / 2 - nameSpace)
                heroNameLb:setColor(color)
                cell:addChild(heroNameLb)
                
                if k % 3 == 0 then
                    posY = posY - heroIconWidth - nameSpace - maxHeroNameHeight - iconSpace
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((self.bgSize.width - tvWidth) / 2, reviveNumLb:getPositionY() - reviveNumLb:getContentSize().height - tvHeight - 5)
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(80)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), nilFunc)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(tvWidth, tvHeight + reviveNumLb:getContentSize().height + 10))
    tvBg:setPosition(self.dialogBgWidth / 2, self.tv:getPositionY() - 2)
    self.bgLayer:addChild(tvBg)
    
    local btnScale, priority = 0.7, -(self.layerNum - 1) * 20 - 4
    local function revive() --复活将领
        local cost = expeditionVoApi:getReviveCost()
        local function realRevive()
            local gems = playerVoApi:getGems()
            if gems < cost then
                GemsNotEnoughDialog(nil, nil, cost - gems, self.layerNum + 2, cost)
                do return end
            end
            local function reviveHandler()
                self:close()
                G_ShowFloatingBoard(getlocal("daily_revive_success"))
            end
            expeditionVoApi:reviveHero(reviveHandler)
        end
        if cost > 0 then
            G_dailyConfirm("expedition.revive", getlocal("daily_revive_gemTip", {cost}), realRevive, self.layerNum + 1)
        else
            realRevive()
        end
    end
    local reviveBtnPic, reviveBtnDownPic = "creatRoleBtn.png", "creatRoleBtn_Down.png"
    local reviveCost = expeditionVoApi:getReviveCost()
    if reviveCost <= 0 then
        reviveBtnPic, reviveBtnDownPic = "newGreenBtn.png", "newGreenBtn_down.png"
    end
    local movga_fontSize = 22
    if G_isAsia() then
        movga_fontSize = 25
    end
    local reviveItem, reviveMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + 140, 50), {getlocal("revive"), movga_fontSize}, reviveBtnPic, reviveBtnDownPic, reviveBtnPic, revive, btnScale, priority)
    
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - 140, 50), {getlocal("cancel"), 25}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn_Down.png", cancel, btnScale, priority)
    
    local costSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0, 0.5))
    if reviveCost > 0 then --复活消耗
        self.bgLayer:addChild(costSp)
        local costLb = GetTTFLabel(tostring(reviveCost), 22, true)
        costLb:setAnchorPoint(ccp(0, 0.5))
        self.bgLayer:addChild(costLb)
        local lbWidth = costLb:getContentSize().width + costSp:getContentSize().width
        costSp:setPosition(reviveMenu:getPositionX() - lbWidth / 2, reviveMenu:getPositionY() + 25 + costSp:getContentSize().height / 2)
        costLb:setPosition(costSp:getPositionX() + costSp:getContentSize().width, costSp:getPositionY())
    else
        local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 20, true)
        freeLb:setPosition(reviveMenu:getPositionX(), reviveMenu:getPositionY() + 25 + costSp:getContentSize().height / 2)
        self.bgLayer:addChild(freeLb)
    end
    
    local function touchHandler()
    end
    touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchHandler)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.dialogLayer:setPosition(0, 0)
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end
