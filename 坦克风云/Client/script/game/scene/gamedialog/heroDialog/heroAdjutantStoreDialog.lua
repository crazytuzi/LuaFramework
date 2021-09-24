heroAdjutantStoreDialog = commonDialog:new()

function heroAdjutantStoreDialog:new(layerNum, showType, heroVo, adjPoint)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	self.showType = showType
	self.heroVo = heroVo
	self.adjPoint = adjPoint
	return nc
end

function heroAdjutantStoreDialog:resetTab()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
end

function heroAdjutantStoreDialog:initTableView()
	local tableViewBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tableViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 195))
    tableViewBg:setAnchorPoint(ccp(0.5, 1))
    tableViewBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 95)
    self.bgLayer:addChild(tableViewBg)

    if self.showType == 2 then
    	self.adjStoreTb = heroAdjutantVoApi:getAdjutantCanEquipData(self.heroVo)
    else
    	self.adjStoreTb = heroAdjutantVoApi:getAdjutantStoreTb()
    end
    self.cellNum = math.ceil(SizeOfTable(self.adjStoreTb or {}) / 3)
    self.tvSize = CCSizeMake(tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 6)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tableView = LuaCCTableView:createWithEventHandler(hd, self.tvSize, nil)
    self.tableView:setPosition(ccp(3, 3))
    self.tableView:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tableView:setMaxDisToBottomOrTop(100)
    tableViewBg:addChild(self.tableView)

    if self.cellNum == 0 then
    	local notDataLb = GetTTFLabelWrap(getlocal("heroAdjutant_notStoreData"), 24, CCSizeMake(tableViewBg:getContentSize().width - 20, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    	notDataLb:setPosition(tableViewBg:getContentSize().width / 2, tableViewBg:getContentSize().height / 2)
    	notDataLb:setColor(G_ColorGray)
    	tableViewBg:addChild(notDataLb)
    end

    local function onClickHandler(tag, obj)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then --获取(商店)
        	activityAndNoteDialog:closeAllDialog()
        	allShopVoApi:showAllPropDialog(self.layerNum + 1, "preferential")
        elseif tag == 11 then --背包
            G_closeAllSmallDialog()
        	activityAndNoteDialog:closeAllDialog()
        	shopVoApi:showPropDialog(self.layerNum + 1, true, 2)
        end
    end
    local btnScale = 0.8
    local getBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickHandler, 10, getlocal("accessory_get"), 24 / btnScale)
    local bagBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("bundle"), 24 / btnScale)
    getBtn:setScale(btnScale)
    bagBtn:setScale(btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(getBtn)
    menuArr:addObject(bagBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(0, 0)
    self.bgLayer:addChild(btnMenu)
    getBtn:setPosition(G_VisibleSizeWidth / 2 - getBtn:getContentSize().width * getBtn:getScale() / 2 - 50, 25 + getBtn:getContentSize().height * getBtn:getScale() / 2)
    bagBtn:setPosition(G_VisibleSizeWidth / 2 + bagBtn:getContentSize().width * bagBtn:getScale() / 2 + 50, 25 + bagBtn:getContentSize().height * bagBtn:getScale() / 2)

    --添加上、下的触摸屏蔽层
    local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - tableViewBg:getPositionY()))
    top:setAnchorPoint(ccp(0.5, 0))
    top:setPosition(tableViewBg:getContentSize().width / 2, tableViewBg:getContentSize().height)
    tableViewBg:addChild(top, 5)
    top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    top:setVisible(false)

    local bottom = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    bottom:setContentSize(CCSizeMake(G_VisibleSizeWidth, tableViewBg:getPositionY()))
    bottom:setAnchorPoint(ccp(0.5, 1))
    bottom:setPosition(tableViewBg:getContentSize().width / 2, 0)
    tableViewBg:addChild(bottom, 5)
    bottom:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    bottom:setVisible(false)
end

function heroAdjutantStoreDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvSize.width, 240)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        local cellW, cellH = self.tvSize.width, 240
        local index = idx + 1
        local forNum = index * 3
        local iconFirstPosX
    	local iconScapeW = 20
    	local tempI = 1
        for i = forNum - 2, forNum do
        	local adjData = self.adjStoreTb[i]
        	if adjData then
	        	local adjId, adjNum = adjData[1], adjData[2]
	        	local icon = heroAdjutantVoApi:getAdjutantIcon(adjId, nil, true, function()
	        		if self.tableView and self.tableView:getIsScrolled() == false then
	        			heroAdjutantVoApi:showInfoSmallDialog(self.layerNum + 1, {adjId, nil, self.showType, self.heroVo, self.adjPoint, self})
	        		end
	        	end, true, self.adjPoint)
	        	icon:setScale(0.65)
	        	if iconFirstPosX == nil then
		            iconFirstPosX = (cellW - (icon:getContentSize().width * icon:getScale() * 3 + (3 - 1) * iconScapeW)) / 2
		        end
		        icon:setAnchorPoint(ccp(0, 0.5))
		        icon:setPosition(iconFirstPosX + (tempI - 1) * (icon:getContentSize().width * icon:getScale() + iconScapeW), cellH / 2)
		        icon:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
		        cell:addChild(icon)
		        local lvLb = GetTTFLabel(getlocal("fightLevel", {1}), 30, true)
		        lvLb:setAnchorPoint(ccp(0, 0))
		        lvLb:setPosition(55, 130)
		        icon:addChild(lvLb, 1)
                local lvBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
                lvBg:setScaleX((lvLb:getContentSize().width + 30) / lvBg:getContentSize().width)
                lvBg:setScaleY(lvLb:getContentSize().height / lvBg:getContentSize().height)
                lvBg:setAnchorPoint(ccp(0, 0))
                lvBg:setPosition(lvLb:getPositionX() - 5, lvLb:getPositionY())
                icon:addChild(lvBg)
		        local levelBg = tolua.cast(icon:getChildByTag(501), "CCSprite")
		        if levelBg then
		        	local numLb = GetTTFLabel(getlocal("propInfoNum", {adjNum}), 30, true)
		        	numLb:setAnchorPoint(ccp(1, 0.5))
		        	numLb:setPosition(levelBg:getContentSize().width - 25, levelBg:getContentSize().height / 2)
		        	levelBg:addChild(numLb)
		    	end
		    end
	        tempI = tempI + 1
        end

        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function heroAdjutantStoreDialog:doUserHandler()
end

function heroAdjutantStoreDialog:tick()
end

function heroAdjutantStoreDialog:dispose()
	self = nil
end