--军团锦标赛赛季本次军团排名
championshipWarAllianceRankDialog = commonDialog:new()

function championshipWarAllianceRankDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function championshipWarAllianceRankDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local rankList = championshipWarVoApi:getAllianceWarRankList()
    local cellNum = SizeOfTable(rankList)
    if cellNum > 0 then
        local function sort(a, b)
            if a and b and a[6] and b[6] and tonumber(a[6]) < tonumber(b[6]) then
                return true
            end
            return false
        end
        table.sort(rankList, sort)
    end
    local grade = championshipWarVoApi:getCurrentSeasonGrade()
    
    --联赛阶层
    local statusBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    statusBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - statusBg:getContentSize().height / 2 - 92)
    self.bgLayer:addChild(statusBg)
    
    local gradeLb = GetTTFLabelWrap(getlocal("championshipWar_grade", {grade}), 24, CCSizeMake(G_VisibleSizeWidth - 180, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold", true)
    gradeLb:setPosition(getCenterPoint(statusBg))
    gradeLb:setColor(G_ColorYellowPro)
    statusBg:addChild(gradeLb)
    
    local tvBgWidth, tvBgHeight = 616, statusBg:getPositionY() - statusBg:getContentSize().height / 2 - 30
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setContentSize(CCSizeMake(tvBgWidth, tvBgHeight))
    tvBg:setPosition(G_VisibleSizeWidth / 2, statusBg:getPositionY() - statusBg:getContentSize().height / 2 - 10)
    self.bgLayer:addChild(tvBg)
    
    local titleFontSize, rankFontSize = 22, 20
    local maxLbHeight = 0
    local titleCfg = {getlocal("rank"), getlocal("serverwar_point"), getlocal("alliance_list_scene_alliance_name"), getlocal("championshipWar_total_fight")}
    local rankFontWidthTb = {100, 100, 150, 250}
    local rankPosTb = {}
    local posX = 0
    for k, v in pairs(titleCfg) do
        local strLb = GetTTFLabelWrap(v, titleFontSize, CCSizeMake(rankFontWidthTb[k], 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        strLb:setColor(G_ColorGreen)
        strLb:setAnchorPoint(ccp(0.5, 1))
        tvBg:addChild(strLb)
        
        rankPosTb[k] = posX + strLb:getContentSize().width / 2
        strLb:setPosition(rankPosTb[k], tvBgHeight - 10)
        
        posX = posX + strLb:getContentSize().width + 5
        
        if strLb:getContentSize().height > maxLbHeight then
            maxLbHeight = strLb:getContentSize().height
        end
    end
    
    local tvWidth, tvHeight, cellHeight = tvBgWidth, tvBgHeight - maxLbHeight - 20, 60
    
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvWidth, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local item = rankList[idx + 1]
            local rank = item[6] or 0
            local name = item[3] or ""
            local point = item[4] or 0
            local fight = FormatNumber(item[5] or 0)
            
            local showTb = {rank, point, name, fight}
            local bgSp
            if rank == 1 then
                bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png", CCRect(20, 20, 10, 10), function()end)
            elseif rank == 2 then
                bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png", CCRect(20, 20, 10, 10), function()end)
            elseif rank == 3 then
                bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png", CCRect(20, 20, 10, 10), function()end)
            else
                bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png", CCRect(40, 40, 10, 10), function()end)
            end
            bgSp:setContentSize(CCSizeMake(tvWidth - 10, cellHeight - 5))
            bgSp:setAnchorPoint(ccp(0.5, 1))
            bgSp:setPosition(tvWidth / 2, cellHeight)
            cell:addChild(bgSp)
            
            for k, v in pairs(showTb) do
                local strLb = GetTTFLabelWrap(v, rankFontSize, CCSizeMake(rankFontWidthTb[k], 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                strLb:setPosition(rankPosTb[k] - 5, bgSp:getContentSize().height / 2)
                bgSp:addChild(strLb)
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvWidth, tvHeight), nil)
    self.tv:setPosition((G_VisibleSizeWidth - tvWidth) / 2, 30)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv, 2)
end

function championshipWarAllianceRankDialog:dispose()
    
end
