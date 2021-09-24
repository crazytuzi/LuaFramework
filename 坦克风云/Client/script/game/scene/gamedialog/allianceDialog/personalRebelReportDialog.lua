personalRebelReportDialog = commonDialog:new()

function personalRebelReportDialog:new(layerNum, reportList)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    self.reportList = reportList
    self.cellHeight = 120
    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
    return nc
end

function personalRebelReportDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function personalRebelReportDialog:initTableView()
	local scoutReport = rebelVoApi:pr_getScoutReport()
	if scoutReport then
		if self.reportList == nil then
			self.reportList = {}
		end
		for k, v in pairs(scoutReport) do
			table.insert(self.reportList, v)
		end
	end
    if self.reportList then
        table.sort(self.reportList, function(a, b) return tonumber(a.ts) > tonumber(b.ts) end)
    end
    self.cellNum = SizeOfTable(self.reportList or {})
    local function tvCallBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 40, G_VisibleSizeHeight - 135), nil)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(20, 35))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function personalRebelReportDialog:eventHandler(handler, fn, index, cel)
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
            rebelVoApi:pr_showReportDetailDialog(self.layerNum + 1, report.eid or report, function()
            	if tonumber(report.isRead) ~= 1 then
	            	self.reportList[index + 1].isRead = 1
	            	if self.tv then
		            	local recordPoint = self.tv:getRecordPoint()
		    			self.tv:reloadData()
		   				self.tv:recoverToRecordPoint(recordPoint)
	   				end
   				end
            end)
        end
        local backSprie, iconBgImage, iconImage, typeImage
        if tonumber(report.isRead) == 1 then
        	backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png", CCRect(5, 5, 1, 1), onCellClick)
        	iconBgImage = "emailNewUI_readIconBg.png"
        	iconImage = "emailNewUI_readIcon.png"
        	typeImage = report.eid and "emailNewUI_fight0.png" or "emailNewUI_scout0.png"
        else
        	backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png", CCRect(5, 23, 1, 1), onCellClick)
        	iconBgImage = "newChat_head_shade.png"
        	iconImage = "emailNewUI_unReadIcon.png"
        	typeImage = report.eid and "emailNewUI_fight1.png" or "emailNewUI_scout1.png"
        end
        backSprie:setContentSize(CCSizeMake(cellW, cellH - 10))
        backSprie:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
        backSprie:setPosition(cellW / 2, cellH / 2)
        cell:addChild(backSprie)
        
        local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName(iconBgImage, CCRect(16, 16, 2, 2), function()end)
        iconBg:setContentSize(CCSizeMake(backSprie:getContentSize().height, backSprie:getContentSize().height))
        iconBg:setAnchorPoint(ccp(0, 0.5))
        iconBg:setPosition(0, backSprie:getContentSize().height / 2)
        backSprie:addChild(iconBg)
        
        local icon = CCSprite:createWithSpriteFrameName(iconImage)
        icon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        iconBg:addChild(icon)

        local typeIcon = CCSprite:createWithSpriteFrameName(typeImage)
		typeIcon:setPosition(getCenterPoint(iconBg))
		if tonumber(report.isRead) == 1 then
			typeIcon:setPositionY(typeIcon:getPositionY() - 10)
		end
		iconBg:addChild(typeIcon)
        
        local params = Split(report.title, "-")
        local rid = params[1]
        local monsterId = tonumber(params[2])
        local monsterLv = params[3]
        local isVictory = (tonumber(params[4]) == 1)
        
        local enemyName = ""
        local npc = rebelVoApi:pr_getCfg().npcList[rid]
        if npc then
            local tankId = rebelVoApi:pr_getMonsterIconId(npc.type, monsterId)
            if tankId then
                tankId = tonumber(RemoveFirstChar(tankId))
                enemyName = rebelVoApi:pr_getMonsterName(npc.type, tankId) .. getlocal("fightLevel", {monsterLv})
            end
        end
        
        local titleStr
        if report.eid then
        	titleStr = getlocal("fight_content_fight_title") .. getlocal("email_figth_title1", {enemyName})
        else
        	titleStr = getlocal("scout_content_scout_title") .. getlocal("email_scout_title", {enemyName})
        end
        local titleLbFontSize = 24
        if G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() == "de" then
            titleLbFontSize = 22
        end
        local titleLbWidth = backSprie:getContentSize().width - iconBg:getContentSize().width - 10
        local titleLb = GetTTFLabelWrap(titleStr, titleLbFontSize, CCSizeMake(titleLbWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom, "Helvetica-bold")
        titleLb:setAnchorPoint(ccp(0, 0))
        titleLb:setPosition(iconBg:getPositionX() + iconBg:getContentSize().width + 5, backSprie:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellow)
        backSprie:addChild(titleLb)
        
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake(backSprie:getContentSize().width - iconBg:getContentSize().width - 10, 2))
        lineSp:setAnchorPoint(ccp(0, 1))
        lineSp:setPosition(iconBg:getPositionX() + iconBg:getContentSize().width + 5, titleLb:getPositionY() - 5)
        lineSp:setOpacity(255 * 0.06)
        backSprie:addChild(lineSp)
        
        local timeLb = GetTTFLabel(G_getDataTimeStr(report.ts), 20)
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

function personalRebelReportDialog:dispose()
    self = nil
    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
end