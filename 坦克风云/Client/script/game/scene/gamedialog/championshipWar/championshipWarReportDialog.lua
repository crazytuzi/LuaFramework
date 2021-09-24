championshipWarReportDialog = commonDialog:new()

function championshipWarReportDialog:new(reportList,layerNum)
    local nc = {
        reportList = reportList,
        layerNum = layerNum,
        cellHeight = 120,
        cellNum = 0,
    }
    setmetatable(nc, self)
    self.__index = self
    
    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
    
    return nc
end

function championshipWarReportDialog:initData()
    local selfUid = playerVoApi:getUid()
    table.sort(self.reportList, function(a, b) if a.id < b.id then return true end end)    
    self.cellNum = SizeOfTable(self.reportList)
end

function championshipWarReportDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self:initData()
    
    local function tvCallBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 40, G_VisibleSizeHeight - 135), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 35))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function championshipWarReportDialog:eventHandler(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 40, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = G_VisibleSizeWidth - 40, self.cellHeight
        
        local report = self.reportList[index + 1]
        
        local function onCellClick()
            local function readCallBack(content)
                championshipWarVoApi:showReportDetailDialog(content, self.layerNum + 1)
            end
            championshipWarVoApi:readReport(report, readCallBack)
        end
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png", CCRect(5, 5, 1, 1), onCellClick)
        backSprie:setContentSize(CCSizeMake(cellW, cellH - 10))
        backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        backSprie:setPosition(cellW / 2, cellH / 2)
        cell:addChild(backSprie)
        
        local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("emailNewUI_readIconBg.png", CCRect(16, 16, 2, 2), function()end)
        iconBg:setContentSize(CCSizeMake(backSprie:getContentSize().height, backSprie:getContentSize().height))
        iconBg:setAnchorPoint(ccp(0, 0.5))
        iconBg:setPosition(0, backSprie:getContentSize().height / 2)
        backSprie:addChild(iconBg)
        
        local icon = CCSprite:createWithSpriteFrameName("emailNewUI_readIcon.png")
        icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        iconBg:addChild(icon)
        
        local selfUid = playerVoApi:getUid()
        local isVictory, enemyName = false, ""
        if tonumber(report.defuid) == tonumber(selfUid) then
            if report.win == 0 then
                isVictory = true
            end
            enemyName = report.attname
        elseif tonumber(selfUid) == tonumber(report.attuid) then
            if report.win == 1 then
                isVictory = true
            end
            enemyName = report.defname
        end
        local titleStr
        if isVictory then
            titleStr = getlocal("championshipWar_reportListTitle1", {enemyName})
        else
            titleStr = getlocal("championshipWar_reportListTitle2", {enemyName})
        end
        local titleLbWidth = backSprie:getContentSize().width - iconBg:getContentSize().width - 10
        local titleLb = GetTTFLabelWrap(titleStr, 24, CCSizeMake(titleLbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom, "Helvetica-bold")
        titleLb:setAnchorPoint(ccp(0, 0))
        titleLb:setPosition(iconBg:getPositionX() + iconBg:getContentSize().width + 5, backSprie:getContentSize().height / 2)
        if isVictory then
            titleLb:setColor(G_ColorGreen)
        else
            titleLb:setColor(G_ColorRed)
        end
        backSprie:addChild(titleLb)
        
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake(backSprie:getContentSize().width - iconBg:getContentSize().width - 10, 2))
        lineSp:setAnchorPoint(ccp(0, 1))
        lineSp:setPosition(iconBg:getPositionX() + iconBg:getContentSize().width + 5, titleLb:getPositionY() - 5)
        lineSp:setOpacity(255 * 0.06)
        backSprie:addChild(lineSp)
        
        local timeLb = GetTTFLabel(getlocal("serverwar_battle_num", {index + 1}), 20)
        timeLb:setAnchorPoint(ccp(1, 0))
        timeLb:setPosition(backSprie:getContentSize().width - 25, 15)
        backSprie:addChild(timeLb)
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function championshipWarReportDialog:dispose()
    self.reportList = nil
    self = nil
    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
end
