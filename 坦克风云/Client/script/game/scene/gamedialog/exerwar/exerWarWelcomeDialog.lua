exerWarWelcomeDialog = commonDialog:new()

function exerWarWelcomeDialog:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
    self.__index = self
	self.layerNum = layerNum
	G_addResource8888(function()
        spriteController:addPlist("public/acCustomImage.plist")
        spriteController:addTexture("public/acCustomImage.png")
    end)
	return nc
end

function exerWarWelcomeDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)

    local tipsBg
	G_addResource8888(function()
		tipsBg = CCSprite:create("public/exerWar_welcomeTipsBg.jpg")
	end)
	tipsBg:setAnchorPoint(ccp(0.5,1))
	tipsBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85)
	self.bgLayer:addChild(tipsBg)

	local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("acci_timeBg.png", CCRect(86, 25, 2, 2), function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, timeBg:getContentSize().height))
    timeBg:setAnchorPoint(ccp(0.5, 1))
    timeBg:setPosition(G_VisibleSizeWidth / 2, tipsBg:getPositionY())
    self.bgLayer:addChild(timeBg)
    local warSt, warEt = exerWarVoApi:getWarTime()
    if warSt and warEt then
    	local timeLb = GetTTFLabel(getlocal("believer_seasonTime", {G_getDateStr(warSt, true, true), G_getDateStr(warEt, true, true)}), 20)
    	timeLb:setAnchorPoint(ccp(0.5, 1))
    	timeLb:setPosition(timeBg:getContentSize().width / 2, timeBg:getContentSize().height - 3)
    	timeBg:addChild(timeLb)
    end

    local titleStr = ""
    local period, warStatus = exerWarVoApi:getWarPeroid()
    if period <= 5 then
        titleStr = getlocal("exerwar_pvpRound", {period})
    elseif period == 6 then
        titleStr = getlocal("exerwar_serverPvp")
    else
        titleStr = getlocal("exerwar_finals_serverPvp")
    end
    self:initContentData()

	local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, tipsBg:getPositionY() - tipsBg:getContentSize().height))
    contentBg:setAnchorPoint(ccp(0.5, 0))
    contentBg:setPosition(G_VisibleSizeWidth / 2, 20)
    self.bgLayer:addChild(contentBg)
    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(contentBg:getContentSize().width / 2, contentBg:getContentSize().height - 25)
	contentBg:addChild(titleBg)
	local titleLb = GetTTFLabel(titleStr, 26, true)
	titleLb:setPosition(getCenterPoint(titleBg))
	titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)

    local function onClickEnter(tag, obj)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        exerWarVoApi:showExerWarDialog(self.layerNum + 1, function() self:close() end)
    end
    local enterBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickEnter, 11, getlocal("allianceWar_enter"), 26)
    enterBtn:setAnchorPoint(ccp(0.5, 0))
    local menu = CCMenu:createWithItem(enterBtn)
    menu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    menu:setPosition(ccp(contentBg:getContentSize().width / 2, 25))
    contentBg:addChild(menu)

    local tvSize = CCSizeMake(contentBg:getContentSize().width - 70, titleBg:getPositionY() - titleBg:getContentSize().height - 15 - menu:getPositionY() - enterBtn:getContentSize().height - 15)
    local contentTv = G_createTableView(tvSize, SizeOfTable(self.contentData[period]), function(idx, cellNum)
    	local height = 0
    	height = height + 15
    	local fontSize = 24
    	local kCCTextAlignment = kCCTextAlignmentLeft
    	local isTheme
    	local contentStr = self.contentData[period][idx + 1]
    	if type(contentStr) == "table" then
    		isTheme = contentStr[5]
    		if contentStr[4] then
    			fontSize = contentStr[4]
    		end
    		if contentStr[3] == true then
    			kCCTextAlignment = kCCTextAlignmentCenter
    		end
    		if type(contentStr[1]) == "function" then
    			contentStr = contentStr[1](period)
    		else
    			contentStr = contentStr[1]
    		end
    	end
    	if isTheme == true then
    		local contentLbBg, contentLb, contentLbHeight = G_createNewTitle({contentStr, fontSize, nil}, CCSizeMake(tvSize.width - 100, 0), nil, true, "Helvetica-bold")
    		height = height + contentLbHeight + 20
    	else
	    	local contentLb = GetTTFLabelWrap(contentStr, fontSize, CCSizeMake(tvSize.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
	    	height = height + contentLb:getContentSize().height
	    end
    	height = height + 15
    	return CCSizeMake(tvSize.width, height)
    end, function(cell, cellSize, idx, cellNum)
    	local fontSize = 24
    	local kCCTextAlignment = kCCTextAlignmentLeft
    	local strColor = nil
    	local isTheme
    	local contentStr = self.contentData[period][idx + 1]
    	if type(contentStr) == "table" then
    		isTheme = contentStr[5]
    		if contentStr[4] then
    			fontSize = contentStr[4]
    		end
    		if contentStr[3] == true then
    			kCCTextAlignment = kCCTextAlignmentCenter
    		end
    		strColor = contentStr[2]
    		if type(contentStr[1]) == "function" then
    			contentStr = contentStr[1](period)
    		else
    			contentStr = contentStr[1]
    		end
    	end
    	if isTheme == true then
    		local contentLbBg, contentLb, contentLbHeight = G_createNewTitle({contentStr, fontSize, strColor}, CCSizeMake(tvSize.width - 100, 0), nil, true, "Helvetica-bold")
    		contentLbBg:setPosition(cellSize.width / 2, (cellSize.height - contentLbHeight) / 2 - 10)
    		cell:addChild(contentLbBg)
    	else
	    	local contentLb = GetTTFLabelWrap(contentStr, fontSize, CCSizeMake(cellSize.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
	    	contentLb:setAnchorPoint(ccp(0, 0.5))
	    	contentLb:setPosition(0, cellSize.height / 2)
	    	if strColor then
	    		contentLb:setColor(strColor)
	    	end
	    	cell:addChild(contentLb)
	    end
    end)
    contentTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    contentTv:setPosition((contentBg:getContentSize().width - tvSize.width) / 2, menu:getPositionY() + enterBtn:getContentSize().height + 15)
    contentTv:setMaxDisToBottomOrTop(0)
    contentBg:addChild(contentTv)
end

function exerWarWelcomeDialog:initContentData()
	if self.contentData == nil then
		self.contentData = {
			{
				--第一天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText3"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText4"), G_ColorYellowPro, true, 25, true },
				{ function(peroid) return exerWarVoApi:getManeuverThemeTitle(peroid) end, G_ColorRed, true },
			},
			{
				--第二天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText3"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText4"), G_ColorYellowPro, true, 25, true },
				{ function(peroid) return exerWarVoApi:getManeuverThemeTitle(peroid) end, G_ColorRed, true },
			},
			{
				--第三天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText3"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText4"), G_ColorYellowPro, true, 25, true },
				{ function(peroid) return exerWarVoApi:getManeuverThemeTitle(peroid) end, G_ColorRed, true },
			},
			{
				--第四天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText3"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText4"), G_ColorYellowPro, true, 25, true },
				{ function(peroid) return exerWarVoApi:getManeuverThemeTitle(peroid) end, G_ColorRed, true },
			},
			{
				--第五天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText3"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText5"), G_ColorGreen, true },
				{ getlocal("exerwar_welcomeDescText4"), G_ColorYellowPro, true, 25, true },
				{ function(peroid) return exerWarVoApi:getManeuverThemeTitle(peroid) end, G_ColorRed, true },
			},
			{
				--第六天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText6"), G_ColorRed, true },
				{ getlocal("exerwar_welcomeDescText7", {exerWarVoApi:getAccessoryPercent()}), G_ColorRed, true },
			},
			{
				--第七天
				getlocal("exerwar_welcomeDescText1"),
				getlocal("exerwar_welcomeDescText2"),
				{ getlocal("exerwar_welcomeDescText8"), G_ColorGreen, true },
			},
		}
	end
end

function exerWarWelcomeDialog:tick()
end

function exerWarWelcomeDialog:dispose()
	self = nil
	spriteController:removePlist("public/acCustomImage.plist")
    spriteController:removeTexture("public/acCustomImage.png")
end