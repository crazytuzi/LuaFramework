championshipWarRankOneDialog = {}

function championshipWarRankOneDialog:new(listData, layerNum)
    local nc = {
        listData = listData,
        layerNum = layerNum,
        cellHeight = 70
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function championshipWarRankOneDialog:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function championshipWarRankOneDialog:initUI()
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    local fontSize = 24
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 320))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 252)
    self.bgLayer:addChild(tvBg)
    local lb1 = GetTTFLabel(getlocal("championshipWar_signUpRank"), fontSize)
    local lb2 = GetTTFLabel(getlocal("RankScene_name"), fontSize)
    local lb3 = GetTTFLabel(getlocal("city_info_power"), fontSize)
    lb1:setPosition(tvBg:getContentSize().width * 0.1, tvBg:getContentSize().height - 30)
    lb2:setPosition(tvBg:getContentSize().width * 0.4, tvBg:getContentSize().height - 30)
    lb3:setPosition(tvBg:getContentSize().width * 0.8, tvBg:getContentSize().height - 30)
    lb1:setColor(G_ColorGreen)
    lb2:setColor(G_ColorGreen)
    lb3:setColor(G_ColorGreen)
    tvBg:addChild(lb1)
    tvBg:addChild(lb2)
    tvBg:addChild(lb3)
    
    local warCfg = championshipWarVoApi:getWarCfg()
    self.allianceJoinNum = warCfg.allianceJoinNum
    self.totalFight = 0
    self.cellNum = self.listData and SizeOfTable(self.listData) or 0
    if self.listData then
        local playedMembers = {} --出战的成员
        local applyMembers = {} --剔除出战的已经报名的成员
        for k, v in pairs(self.listData) do
            if k <= self.allianceJoinNum then
                table.insert(playedMembers, v)
            else
                table.insert(applyMembers, v)
            end
        end
        local function sort(a, b)
            if a and b and a[3] and b[3] and tonumber(a[3]) < tonumber(b[3]) then
                return true
            end
            return false
        end
        table.sort(playedMembers, sort) --出战名单按照战力从低到高排序，为出战的按照从高到底排序
        self.listData = {}
        for k, v in pairs(playedMembers) do
            table.insert(self.listData, v)
        end
        for k, v in pairs(applyMembers) do
            table.insert(self.listData, v)
        end
    end
    
    local function tvCallBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvBg:getContentSize().width, tvBg:getContentSize().height - 60 - 3), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setPosition(0, 3)
    tvBg:addChild(self.tv)
    
    local str = getlocal("championshipWar_membersList_desc", {FormatNumber(self.totalFight), self.cellNum})
    local color = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}
    local lbW = G_VisibleSizeWidth - 60
    local descLb, lbHeight = G_getRichTextLabel(str, color, fontSize, lbW, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0, 0.5))
    descLb:setPosition(30, tvBg:getPositionY() + lbHeight / 2 + ((G_VisibleSizeHeight - 155) - tvBg:getPositionY()) / 2)
    self.bgLayer:addChild(descLb)
    
    local tipsLb = GetTTFLabelWrap(getlocal("championshipWar_membersList_tips"), fontSize, CCSizeMake(G_VisibleSizeWidth - 50, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipsLb:setAnchorPoint(ccp(0.5, 1))
    tipsLb:setPosition(G_VisibleSizeWidth / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10)
    self.bgLayer:addChild(tipsLb)
    
    if self.cellNum == 0 then
        local noDataLb = GetTTFLabelWrap(getlocal("serverWarLocal_noData"), fontSize, CCSizeMake(tvBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noDataLb:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height / 2)
        noDataLb:setColor(G_ColorYellowPro)
        tvBg:addChild(noDataLb)
    end
end

function championshipWarRankOneDialog:eventHandler(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 30, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = G_VisibleSizeWidth - 30, self.cellHeight
        
        local data = self.listData[index + 1]
        local name = data[2] or ""
        local fight = data[3] or 0
        local rankStr = ""
        if (index + 1) <= self.allianceJoinNum then
            rankStr = tostring(index + 1)
        else
            rankStr = "~"..tostring(index + 1 - self.allianceJoinNum)
        end
        local rankLb = GetTTFLabel(rankStr, 24)
        local nameLb = GetTTFLabel(name, 24)
        local fightLb = GetTTFLabel(tostring(FormatNumber(fight)), 24)
        local troopsInfo = {}
        if data[4] then --部队信息
            local tank, hero, emblem, plane, aitroops, skin = data[4][1], data[4][2], data[4][3], data[4][4], data[4][5], data[4][6]
            troopsInfo = {tank = tank, hero = hero, emblem = emblem, plane = plane, aitroops = aitroops, skin = skin}
        end
        local function checkTroop()
            if self and self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                --查看军团成员部队情况
                championshipWarVoApi:showMemberTroopDialog(name, troopsInfo, self.layerNum + 1)
            end
        end
        
        local bgSp
        if index == 0 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png", CCRect(20, 20, 10, 10), checkTroop)
        elseif index == 1 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png", CCRect(20, 20, 10, 10), checkTroop)
        elseif index == 2 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png", CCRect(20, 20, 10, 10), checkTroop)
        else
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png", CCRect(40, 40, 10, 10), checkTroop)
        end
        bgSp:setContentSize(CCSizeMake(cellW - 10, cellH - 5))
        bgSp:setAnchorPoint(ccp(0.5, 1))
        bgSp:setPosition(cellW / 2, cellH)
        bgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(bgSp)
        
        rankLb:setPosition(bgSp:getContentSize().width * 0.1, bgSp:getContentSize().height / 2)
        nameLb:setPosition(bgSp:getContentSize().width * 0.4, bgSp:getContentSize().height / 2)
        fightLb:setPosition(bgSp:getContentSize().width * 0.8, bgSp:getContentSize().height / 2)
        bgSp:addChild(rankLb)
        bgSp:addChild(nameLb)
        bgSp:addChild(fightLb)
        
        if (index + 1) <= self.allianceJoinNum then --出战名单战力相加
            self.totalFight = self.totalFight + fight
        else
            rankLb:setColor(G_ColorGray)
            nameLb:setColor(G_ColorGray)
            fightLb:setColor(G_ColorGray)
        end
        
        local eyeSp = CCSprite:createWithSpriteFrameName("datebaseShow2.png")
        eyeSp:setPosition(bgSp:getContentSize().width - eyeSp:getContentSize().width / 2 - 10, bgSp:getContentSize().height / 2)
        bgSp:addChild(eyeSp)
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function championshipWarRankOneDialog:dispose()
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    self = nil
end
