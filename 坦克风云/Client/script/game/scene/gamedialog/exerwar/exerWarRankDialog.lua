exerWarRankDialog = {}

function exerWarRankDialog:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	G_addResource8888(function()
		spriteController:addPlist("public/rewardCenterImage.plist")
    	spriteController:addTexture("public/rewardCenterImage.png")
    	spriteController:addPlist("public/newTopBgImage1.plist")
    	spriteController:addTexture("public/newTopBgImage1.png")
	end)
	return nc
end

function exerWarRankDialog:initTableView()
	self.bgLayer = CCLayer:create()
	self.curShowTabIndex = 1
	local peroid, status = exerWarVoApi:getWarPeroid()
	if peroid <= 5 then
		self.curShowTabIndex = 1
	elseif peroid == 6 then
		self.curShowTabIndex = 2
    elseif peroid >= 7 then
    	self.curShowTabIndex = 3
    end
	local tabTitleStr = { getlocal("exerwar_rankStr1"), getlocal("exerwar_rankStr2"), getlocal("exerwar_rankStr3"), getlocal("exerwar_rankStr4") }
	self.allTabBtn = {}
	local firstPosX
	local tabMenu = CCMenu:create()
	for k, v in pairs(tabTitleStr) do
		local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0.5, 1))
        if firstPosX == nil then
        	local tabTitleSize = SizeOfTable(tabTitleStr)
        	firstPosX = (G_VisibleSizeWidth - (tabBtnItem:getContentSize().width * tabTitleSize + (tabTitleSize - 1) * 3)) / 2
        end
        tabBtnItem:setPosition(firstPosX + tabBtnItem:getContentSize().width / 2 + (k - 1) * (tabBtnItem:getContentSize().width + 3), G_VisibleSizeHeight - 93)
        tabMenu:addChild(tabBtnItem)
        tabBtnItem:setTag(k)
        local tabTitleLb = GetTTFLabelWrap(v, 20, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        tabTitleLb:setPosition(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2)
        tabBtnItem:addChild(tabTitleLb)
        tabBtnItem:registerScriptTapHandler(function(...)
                PlayEffect(audioCfg.mouseClick)
                return self:switchTab(...)
        end)
        self.allTabBtn[k] = tabBtnItem
        if self.tabLinePosY == nil then
            self.tabLinePosY = tabBtnItem:getPositionY() - tabBtnItem:getContentSize().height
        end
	end
	tabMenu:setPosition(0, 0)
    tabMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabMenu)
    local tabLine = LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png", CCRect(4, 3, 1, 1), function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth, 7))
    tabLine:setAnchorPoint(ccp(0.5, 1))
    tabLine:setPosition(G_VisibleSizeWidth / 2, self.tabLinePosY)
    self.bgLayer:addChild(tabLine)

    self.tvTitleHeight, self.tvTitleFontSize = 40, 22
    if G_isAsia() == false then
        self.tvTitleHeight, self.tvTitleFontSize = 60, 17
        if G_isIOS() == false then
            self.tvTitleHeight = 80
        end
    end

    self:switchTab(self.curShowTabIndex)
end

function exerWarRankDialog:switchTab(idx)
	if self.allTabBtn then
        for k, v in pairs(self.allTabBtn) do
            if v:getTag() == idx then
                v:setEnabled(false)
                self.curShowTabIndex = idx
            else
                v:setEnabled(true)
            end
        end
        self:showTabUI()
    end
end

function exerWarRankDialog:showTabUI()
	if self.tabLayer then
        self.tabLayer:removeAllChildrenWithCleanup(true)
    else
        self.tabLayer = CCLayer:create()
        self.bgLayer:addChild(self.tabLayer)
    end
    if self.rankData == nil then
    	self.rankData = {}
    end
    self.cdTimeLbTb = nil
    if self.curShowTabIndex == 1 then
    	self:showUITabOne()
    elseif self.curShowTabIndex == 2 then
    	self:showUITabTwo()
    elseif self.curShowTabIndex == 3 then
    	self:showUITabThree()
    elseif self.curShowTabIndex == 4 then
    	self:showUITabFour()
    end
end

function exerWarRankDialog:showTipLabel(parentBg, posY)
	if parentBg == nil or posY == nil then
		do return end
	end
	local notTipsLb = GetTTFLabelWrap(getlocal("exerwar_notShowRankTip"), 22, CCSizeMake(parentBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	notTipsLb:setColor(G_ColorGray)
	notTipsLb:setPosition(parentBg:getContentSize().width / 2, posY)
	parentBg:addChild(notTipsLb)
end

function exerWarRankDialog:showUITabOne()
	local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(G_VisibleSizeWidth / 2, self.tabLinePosY - 10)
	self.tabLayer:addChild(titleBg)
	local titleLb = GetTTFLabel(getlocal("exerwar_rankTab1_rTitle"), 26, true)
	titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)

    local biddingBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    biddingBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 220))
    biddingBg:setAnchorPoint(ccp(0.5, 0))
    biddingBg:setPosition(G_VisibleSizeWidth / 2, 100)
    self.tabLayer:addChild(biddingBg)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, titleBg:getPositionY() - titleBg:getContentSize().height - 10 - (biddingBg:getPositionY() + biddingBg:getContentSize().height) - 10))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 10)
    self.tabLayer:addChild(tvBg)
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, self.tvTitleHeight))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
    tvBg:addChild(tvTitleBg)
    local tvTitleStr = {getlocal("exerwar_rankTab1_str1"), getlocal("exerwar_rankTab1_str2"), getlocal("exerwar_rankTab1_str3"), getlocal("exerwar_rankTab1_str4"), getlocal("exerwar_rankTab1_str5")}
    local tvTitleWidthRate = {0.1, 0.3, 0.48, 0.7, 0.9}
    local tvTitleFontWidth = {70, 70, 110, 140, 90}
    for k, v in pairs(tvTitleStr) do
        local titleLb = GetTTFLabelWrap(v, self.tvTitleFontSize, CCSizeMake(tvTitleFontWidth[k], 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        titleLb:setPosition(tvTitleBg:getContentSize().width * tvTitleWidthRate[k], tvTitleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        tvTitleBg:addChild(titleLb)
    end

    local biddingData
    local peroid, status = exerWarVoApi:getWarPeroid()
    if status >= 20 or (peroid == 5 and status < 20) then
    	if self.rankData[self.curShowTabIndex] == nil then
	    	exerWarVoApi:requestRankData(self.curShowTabIndex, function(data)
	    		self.rankData[self.curShowTabIndex] = data
	    		self:showTabUI()
	    	end)
    	end
    	local rankSelfData, tvData, militaryData, auctionData
		if self.rankData[self.curShowTabIndex] then
			biddingData = {}
			if self.rankData[self.curShowTabIndex].militaryfirst then
				militaryData = self.rankData[self.curShowTabIndex].militaryfirst
				biddingData[1] = militaryData
			end
			if self.rankData[self.curShowTabIndex].auctionData then
				auctionData = self.rankData[self.curShowTabIndex].auctionData
				biddingData[2] = auctionData
			end
			if self.rankData[self.curShowTabIndex].rankList then
				tvData = self.rankData[self.curShowTabIndex].rankList
				for k, v in pairs(tvData) do
					if tonumber(playerVoApi:getUid()) == tonumber(v.uid) then
						rankSelfData = v
						rankSelfData.rank = k
						break
					end
				end
			end
		end
		local tvDataSize = SizeOfTable(tvData)
		if tvDataSize > 0 then
	    	local cellHeight = 50
	    	local selfData = exerWarVoApi:getRankSelfData()
			local labelStrTb = {"10+", playerVoApi:getPlayerName(), selfData.score or 0, G_GetPreciseDecimal(tonumber(selfData.surrate or 0) * 100, 1) .. "%", FormatNumber(tonumber(selfData.fc or 0))}
			if rankSelfData then
				labelStrTb = {rankSelfData.rank, rankSelfData.nickname, rankSelfData.score, G_GetPreciseDecimal(tonumber(rankSelfData.surrate) * 100, 1) .. "%", FormatNumber(tonumber(rankSelfData.fc))}
			end
			for k, v in pairs(labelStrTb) do
				local label = GetTTFLabel(v, G_isAsia() and 22 or 16)
				label:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[k], tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - cellHeight / 2)
				tvBg:addChild(label)
			end
			local tempGreenFrameSize = 0
			local winNum = exerWarVoApi:getWinNum(1)
		    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - cellHeight - 3)
		    local tv = G_createTableView(tvSize, tvDataSize, CCSizeMake(tvSize.width, cellHeight), function(cell, cellSize, idx, cellNum)
		    	local data = tvData[idx + 1]
		    	local bgPic, bgRect
		    	if (militaryData == nil and idx < winNum) or (militaryData and tonumber(militaryData.uid) ~= tonumber(data.uid) and tempGreenFrameSize < winNum) then
		    		bgPic = "exer_lightGreenFrame.png"
		    		bgRect = CCRect(3, 10, 1, 1)
		    		tempGreenFrameSize = tempGreenFrameSize + 1
		    	elseif (auctionData and tonumber(auctionData.uid) == tonumber(data.uid)) or (militaryData and tonumber(militaryData.uid) == tonumber(data.uid)) then
		    		bgPic = "exer_lightYellowFrame.png"
		    		bgRect = CCRect(3, 10, 1, 1)
		    	elseif idx % 2 == 0 then
		    		bgPic = "newListItemBg.png"
		    		bgRect = CCRect(4, 4, 1, 1)
		    	end
		    	if bgPic and bgRect then
			    	local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgPic, bgRect, function()end)
		    		cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height))
		    		cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
		    		cell:addChild(cellBg)
		    	end
		    	local labelStrTb = {idx + 1, data.nickname, data.score, G_GetPreciseDecimal(tonumber(data.surrate) * 100, 1) .. "%", FormatNumber(tonumber(data.fc))}
		    	for k, v in pairs(labelStrTb) do
	    			local label = GetTTFLabel(v, G_isAsia() and 22 or 16)
	    			label:setPosition(cellSize.width * tvTitleWidthRate[k], cellSize.height / 2)
	    			cell:addChild(label)
	    		end
		    end)
		    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
		    tv:setPosition(3, 3)
		    tvBg:addChild(tv)
		else
			self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
		end
	else
		self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
	end

    local titleFontSize = 24
    if G_isAsia() == false then
        titleFontSize = 20
    end
    --保送、竞拍部分
    local biddingTitleBg, biddingTitleLb = G_createNewTitle({getlocal("exerwar_rankTab1_rTitle2"), titleFontSize, G_ColorYellowPro}, CCSizeMake(250, 0), nil, nil, "Helvetica-bold")
    biddingTitleBg:setAnchorPoint(ccp(0.5, 1))
    biddingTitleBg:setPosition(biddingBg:getContentSize().width / 2, biddingBg:getContentSize().height - 20)
    biddingBg:addChild(biddingTitleBg)

    self.cdTimeLbTb = {}
    local bcdType, bcdTime = exerWarVoApi:getBiddingCountdown()
    self.bcdType = bcdType
    for i = 1, 2 do
    	local playerHeadBg = LuaCCScale9Sprite:createWithSpriteFrameName("icon_bg_gray.png", CCRect(34, 34, 1, 1), function()end)
    	playerHeadBg:setContentSize(CCSizeMake(90, 90))
    	if i == 1 then
    		playerHeadBg:setPositionX(15 + playerHeadBg:getContentSize().width / 2)
    	else
    		playerHeadBg:setPositionX(biddingBg:getContentSize().width / 2 + playerHeadBg:getContentSize().width / 2)
    	end
    	playerHeadBg:setPositionY(biddingTitleBg:getPositionY() - biddingTitleBg:getContentSize().height - 15 - playerHeadBg:getContentSize().height / 2)
    	biddingBg:addChild(playerHeadBg)
    	local iconNameLb = GetTTFLabelWrap(getlocal((i == 1) and "exerwar_rankTab1_dTitleTip_1" or "exerwar_rankTab1_dTitleTip_2"), G_isAsia() and 22 or 17, CCSizeMake(150, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    	iconNameLb:setAnchorPoint(ccp(0, 1))
    	iconNameLb:setPosition(playerHeadBg:getPositionX() + playerHeadBg:getContentSize().width / 2 + 10, playerHeadBg:getPositionY() + playerHeadBg:getContentSize().height / 2 - 4)
    	iconNameLb:setColor(G_ColorYellowPro)
    	biddingBg:addChild(iconNameLb)

    	if biddingData and biddingData[i] and biddingData[i].pic and biddingData[i].nickname then
    		local iconSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(biddingData[i].pic))
    		iconSp:setScale(90 / iconSp:getContentSize().width)
    		iconSp:setPosition(getCenterPoint(playerHeadBg))
    		playerHeadBg:addChild(iconSp)
    		local nameLb = GetTTFLabel(biddingData[i].nickname, G_isAsia() and 20 or 15)
    		nameLb:setAnchorPoint(ccp(0, 1))
    		nameLb:setPosition(iconNameLb:getPositionX(), iconNameLb:getPositionY() - iconNameLb:getContentSize().height)
    		biddingBg:addChild(nameLb)
    		if i == 2 and biddingData[i].gem then
    			local auctionGemLb = GetTTFLabel(getlocal("exerwar_rankTab1_dTimeShow2_2", {biddingData[i].gem}), G_isAsia() and 20 or 15)
    			auctionGemLb:setAnchorPoint(ccp(0, 1))
    			auctionGemLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height)
    			biddingBg:addChild(auctionGemLb)
    		end
    	else
	    	local iconSp = CCSprite:createWithSpriteFrameName("blackHero.png")
	    	iconSp:setScale(80 / iconSp:getContentSize().width)
	    	iconSp:setPosition(getCenterPoint(playerHeadBg))
	    	playerHeadBg:addChild(iconSp)
	    end

    	if bcdType <= 3 then
    		local cdTimeStr
    		if bcdType == 1 then
    			cdTimeStr = getlocal("exerwar_rankTab1_dTimeShow" .. i, {G_formatActiveDate(bcdTime)})
    		elseif bcdType == 2 and i == 2 then
    			cdTimeStr = getlocal("exerwar_rankTab1_dTimeShow2_1", {G_formatActiveDate(bcdTime)})
    		elseif bcdType == 3 and i == 2 then
    			cdTimeStr = getlocal("exerwar_rankTab1_dTimeShow3", {G_formatActiveDate(bcdTime)})
    		end
    		if i == 1 and biddingData and biddingData[i] and biddingData[i].nickname then
    			cdTimeStr = nil
    		end
    		if cdTimeStr then
    			local cdTimeLb = GetTTFLabel(cdTimeStr, G_isAsia() and 18 or 12)
    			cdTimeLb:setAnchorPoint(ccp(0, 1))
    			cdTimeLb:setPosition(iconNameLb:getPositionX(), iconNameLb:getPositionY() - iconNameLb:getContentSize().height - 5)
    			biddingBg:addChild(cdTimeLb)
    			self.cdTimeLbTb[i] = cdTimeLb
    		end
    	end

    	if i == 2 then
    		if bcdType == 2 and self.cdTimeLbTb and self.cdTimeLbTb[i] then
    			local auctionGemLb = GetTTFLabel(getlocal("exerwar_rankTab1_dTimeShow2_2", {exerWarVoApi:getAuctionGem()}), G_isAsia() and 18 or 12)
    			auctionGemLb:setAnchorPoint(ccp(0, 1))
    			auctionGemLb:setPosition(self.cdTimeLbTb[i]:getPositionX(), self.cdTimeLbTb[i]:getPositionY() - self.cdTimeLbTb[i]:getContentSize().height)
    			biddingBg:addChild(auctionGemLb)
    			self.auctionGemLb = auctionGemLb
    		end
    		local function onClickAution(tag, obj)
    			if G_checkClickEnable() == false then
		            do return end
		        else
		            base.setWaitTime = G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        local cdType = exerWarVoApi:getBiddingCountdown()
		        if cdType ~= 2 then
		        	G_showTipsDialog(getlocal("exerwar_aution_notBiddingTime"))
		        	do return end
		        end
		        if exerWarVoApi:isSettingTroops() == false then --没有参与过服内pvp，不允许竞拍
		        	G_showTipsDialog(getlocal("backstage40015"))
		        	do return end
		        end
		        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
		        local function autionCallback(autionNum)
		        	print("autionCallback~~~~")
		        	if self.auctionGemLb then
		        		self.auctionGemLb:setString(getlocal("exerwar_rankTab1_dTimeShow2_2", {exerWarVoApi:getAuctionGem()}))
		        	end
		        end 
		        local titleStr = getlocal("exerwar_rankTab1_dTitleTip_2")
		        local tipTb = {getlocal("exerwar_aution_tip1"), getlocal("exerwar_aution_tip2"), getlocal("exerwar_aution_tip3")}
			    local needTb = {"exerwarAution", titleStr, autionCallback, tipTb}
			    local sd = acThrivingSmallDialog:new(self.layerNum + 1, needTb)
			    sd:init()
    		end
    		local btnScale = 0.6
    		local autionBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickAution, nil, getlocal("exerwar_biddingStr"), 22 / btnScale)
    		autionBtn:setScale(btnScale)
    		autionBtn:setAnchorPoint(ccp(0.5, 1))
    		local autionMenu = CCMenu:createWithItem(autionBtn)
    		autionMenu:setPosition(playerHeadBg:getPositionX(), playerHeadBg:getPositionY() - playerHeadBg:getContentSize().height / 2 - 10)
    		autionMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    		biddingBg:addChild(autionMenu)
    		autionBtn:setEnabled(bcdType == 2)
    	end
    end
end

function exerWarRankDialog:showUITabTwo()
	local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(G_VisibleSizeWidth / 2, self.tabLinePosY - 10)
	self.tabLayer:addChild(titleBg)
	local titleLb = GetTTFLabel(getlocal("exerwar_rankTab2_title"), G_isAsia() and 26 or 22, true)
	titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, titleBg:getPositionY() - titleBg:getContentSize().height - 10 - 100))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 10)
    self.tabLayer:addChild(tvBg)
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, self.tvTitleHeight))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
    tvBg:addChild(tvTitleBg)
    local tvTitleWidthRate = {0.07, 0.21, 0.38, 0.56, 0.72, 0.9}
    local tvTitleFontWidth = {60, 60, 80, 130, 80, 130}
    for k, v in pairs(tvTitleWidthRate) do
        local tvTitleLb = GetTTFLabelWrap(getlocal("exerwar_rankTab2_t" .. k), self.tvTitleFontSize, CCSizeMake(tvTitleFontWidth[k], 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        tvTitleLb:setPosition(tvTitleBg:getContentSize().width * v, tvTitleBg:getContentSize().height / 2)
        tvTitleLb:setColor(G_ColorYellowPro)
        tvTitleBg:addChild(tvTitleLb)
    end

    local peroid, status = exerWarVoApi:getWarPeroid()
    if peroid >= 6 and status >= 24 then
	    local tv, tvData
	    if self.rankData[self.curShowTabIndex] then
	    	tvData = self.rankData[self.curShowTabIndex]
	    else
		    exerWarVoApi:requestRankData(self.curShowTabIndex, function(data)
		    	self.rankData[self.curShowTabIndex] = data
		    	tvData = self.rankData[self.curShowTabIndex]
		    	if tv then
		    		self:showTabUI()
		    	end
		    end)
		end
		local tvDataSize = SizeOfTable(tvData)
		if tvDataSize > 0 then
			local tvTitleBgBottomPosY = tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height
			local cellHeight = 60

			local isShowSelf = false
			for k, v in pairs(tvData) do
				if v[1] == playerVoApi:getUid() and v[3] == base.curZoneID then
		            local selfCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
		            selfCellBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, cellHeight - 4))
		            selfCellBg:setPosition(tvBg:getContentSize().width / 2, tvTitleBgBottomPosY - cellHeight / 2)
		            tvBg:addChild(selfCellBg)
		            local labelStrTb = {
		                tonumber(k), v[2] or "", GetServerNameByID(tonumber(v[3] or 0), true), FormatNumber(tonumber(v[4] or 0)), FormatNumber(tonumber(v[5] or 0)), FormatNumber(tonumber(v[6] or 0))
		            }
		            for kk, vv in pairs(labelStrTb) do
	                    local label = GetTTFLabel(vv, G_isAsia() and 22 or 20)
	                    label:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], tvTitleBgBottomPosY - cellHeight / 2)
	                    tvBg:addChild(label)
		            end
		            isShowSelf = true
		            break
	        	end
			end

			--[[
			local tempTvData = {}
			local tempTvDataSize = 0
			local biddingTvData = {}
			local biddingTvDataSize = 0
			local isShowSelf = nil
			for k, v in pairs(tvData) do
				if v[7] == 1 then
					table.insert(biddingTvData, v)
					biddingTvDataSize = biddingTvDataSize + 1
					if v[1] == playerVoApi:getUid() and v[3] == base.curZoneID then
						isShowSelf = false
					end
				else
		        	table.insert(tempTvData, v)
		        	tempTvDataSize = tempTvDataSize + 1
		        end
			end
			
			if isShowSelf == nil then
				for k, v in pairs(tempTvData) do
					if v[1] == playerVoApi:getUid() and v[3] == base.curZoneID then
			            local selfCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
			            selfCellBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, cellHeight - 4))
			            selfCellBg:setPosition(tvBg:getContentSize().width / 2, tvTitleBgBottomPosY - cellHeight / 2)
			            tvBg:addChild(selfCellBg)
			            local labelStrTb = {
			                tonumber(k), v[2] or "", GetServerNameByID(tonumber(v[3] or 0), true), FormatNumber(tonumber(v[4] or 0)), FormatNumber(tonumber(v[5] or 0)), FormatNumber(tonumber(v[6] or 0))
			            }
			            for kk, vv in pairs(labelStrTb) do
			            	if kk == 1 and vv < 4 then
			            		local rankSp = CCSprite:createWithSpriteFrameName("top" .. vv .. ".png")
			            		rankSp:setScale(0.7)
			            		rankSp:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], tvTitleBgBottomPosY - cellHeight / 2)
			            		tvBg:addChild(rankSp)
			            	else
			                    local label = GetTTFLabel(vv, G_isAsia() and 22 or 20)
			                    label:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], tvTitleBgBottomPosY - cellHeight / 2)
			                    tvBg:addChild(label)
			                end
			            end
			            isShowSelf = true
			            break
		        	end
				end
			end

			for k, v in pairs(biddingTvData) do
				local posY = tvTitleBgBottomPosY - (isShowSelf and k or (k - 1)) * cellHeight - cellHeight / 2
				local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("exer_lightYellowFrame.png", CCRect(3, 10, 1, 1), function()end)
		        cellBg:setContentSize(CCSizeMake((tvBg:getContentSize().width - 6) - 4, cellHeight - 4))
		        cellBg:setPosition(tvBg:getContentSize().width / 2, posY)
		        tvBg:addChild(cellBg)
		        local labelStrTb = {
	                getlocal("believer_seg_change_1"), v[2] or "", GetServerNameByID(tonumber(v[3] or 0), true), FormatNumber(tonumber(v[4] or 0)), FormatNumber(tonumber(v[5] or 0)), FormatNumber(tonumber(v[6] or 0))
	            }
	            for kk, vv in pairs(labelStrTb) do
	                local label = GetTTFLabel(vv, G_isAsia() and 22 or 20)
	                label:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], posY)
	                tvBg:addChild(label)
	            end
			end
			
		    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBgBottomPosY - 3 - ((biddingTvDataSize + (isShowSelf and 1 or 0)) * cellHeight))
		    tv = G_createTableView(tvSize, tempTvDataSize, CCSizeMake(tvSize.width, cellHeight), function(cell, cellSize, idx, cellNum)
		    	local data = tempTvData[idx + 1]
		    --]]
		    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBgBottomPosY - 3 - (isShowSelf and cellHeight or 0))
		    tv = G_createTableView(tvSize, tvDataSize, CCSizeMake(tvSize.width, cellHeight), function(cell, cellSize, idx, cellNum)
		    	local data = tvData[idx + 1]
		    	local cellBgPic
		        if data[7] == 1 then
		            cellBgPic = "exer_lightYellowFrame.png"
		        else
		        	cellBgPic = "exer_lightGreenFrame.png"
		        end
		        if cellBgPic then
			        local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName(cellBgPic, CCRect(3, 10, 1, 1), function()end)
			        cellBg:setContentSize(CCSizeMake(cellSize.width - 4, cellSize.height - 4))
			        cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
			        cell:addChild(cellBg)
			    end
		        local labelStrTb = {
		            tonumber(idx + 1), data[2] or "", GetServerNameByID(tonumber(data[3] or 0), true), FormatNumber(tonumber(data[4] or 0)), FormatNumber(tonumber(data[5] or 0)), FormatNumber(tonumber(data[6] or 0))
		        }
		        for k, v in pairs(labelStrTb) do
	                local label = GetTTFLabel(v, G_isAsia() and 22 or 20)
	                label:setPosition(cellSize.width * tvTitleWidthRate[k], cellSize.height / 2)
	                cell:addChild(label)
		        end
		    end)
		    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
		    tv:setPosition(3, 3)
		    tvBg:addChild(tv)
		else
			self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
		end
	else
		self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
	end
end

function exerWarRankDialog:showUITabThree()
	local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
	titleBg:setAnchorPoint(ccp(0.5, 1))
	titleBg:setPosition(G_VisibleSizeWidth / 2, self.tabLinePosY - 10)
	self.tabLayer:addChild(titleBg)
	local titleLb = GetTTFLabel(getlocal("exerwar_rankTab3_title"), G_isAsia() and 26 or 22, true)
	titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, titleBg:getPositionY() - titleBg:getContentSize().height - 10 - 100))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, titleBg:getPositionY() - titleBg:getContentSize().height - 10)
    self.tabLayer:addChild(tvBg)
    local tvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png", CCRect(4, 4, 1, 1), function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width - 6, self.tvTitleHeight))
    tvTitleBg:setAnchorPoint(ccp(0.5, 1))
    tvTitleBg:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3)
    tvBg:addChild(tvTitleBg)
    local tvTitleWidthRate = {0.07, 0.21, 0.38, 0.56, 0.72, 0.9}
    local tvTitleFontWidth = {60, 60, 80, 130, 80, 130}
    for k, v in pairs(tvTitleWidthRate) do
        local tvTitleLb = GetTTFLabelWrap(getlocal("exerwar_rankTab3_t" .. k), self.tvTitleFontSize, CCSizeMake(tvTitleFontWidth[k], 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        tvTitleLb:setPosition(tvTitleBg:getContentSize().width * v, tvTitleBg:getContentSize().height / 2)
        tvTitleLb:setColor(G_ColorYellowPro)
        tvTitleBg:addChild(tvTitleLb)
    end

	local peroid, status = exerWarVoApi:getWarPeroid()
    local ts, value = exerWarVoApi:getFinalTimeStatus()
    if peroid >= 7 and ts == 0 and value == 0 then
	    local tv, tvData
	    if self.rankData[self.curShowTabIndex] then
	    	tvData = self.rankData[self.curShowTabIndex]
	    else
		    exerWarVoApi:requestRankData(self.curShowTabIndex, function(data)
		    	self.rankData[self.curShowTabIndex] = data
		    	tvData = self.rankData[self.curShowTabIndex]
		    	if tv then
		    		self:showTabUI()
		    	end
		    end)
		end
		local tvDataSize = SizeOfTable(tvData)
		if tvDataSize > 0 then
			local cellHeight = 60
			local isShowSelf = false
			for k, v in pairs(tvData) do
				if v[1] == playerVoApi:getUid() and v[3] == base.curZoneID then
					if k < 4 then
			            local selfCellBg = CCSprite:createWithSpriteFrameName("top_" .. k .. ".png")
			            selfCellBg:setScaleX((tvBg:getContentSize().width - 6 - 4) / selfCellBg:getContentSize().width)
			            selfCellBg:setScaleY(cellHeight / selfCellBg:getContentSize().height)
			            selfCellBg:setPosition(tvBg:getContentSize().width / 2, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - cellHeight / 2)
			            tvBg:addChild(selfCellBg)
		        	end
		            local labelStrTb = {
		                tonumber(k), v[2] or "", GetServerNameByID(tonumber(v[3] or 0), true), FormatNumber(tonumber(v[4] or 0)), FormatNumber(tonumber(v[5] or 0)), FormatNumber(tonumber(v[6] or 0))
		            }
		            for kk, vv in pairs(labelStrTb) do
		            	if kk == 1 and vv < 4 then
		            		local rankSp = CCSprite:createWithSpriteFrameName("top" .. vv .. ".png")
		            		rankSp:setScale(0.7)
		            		rankSp:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - cellHeight / 2)
		            		tvBg:addChild(rankSp)
		            	else
		                    local label = GetTTFLabel(vv, G_isAsia() and 22 or 20)
		                    label:setPosition(3 + tvTitleBg:getContentSize().width * tvTitleWidthRate[kk], tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - cellHeight / 2)
		                    tvBg:addChild(label)
		                end
		            end
		            isShowSelf = true
		            break
		        end
			end
		    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height - 3 - (isShowSelf and cellHeight or 0))
		    tv = G_createTableView(tvSize, tvDataSize, CCSizeMake(tvSize.width, cellHeight), function(cell, cellSize, idx, cellNum)
		    	local data = tvData[idx + 1]
		    	if idx + 1 < 4 then
		    		local cellBg = CCSprite:createWithSpriteFrameName("top_" .. (idx + 1) .. ".png")
		            cellBg:setScaleX((cellSize.width - 4) / cellBg:getContentSize().width)
		            cellBg:setScaleY(cellSize.height / cellBg:getContentSize().height)
		            cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
		            cell:addChild(cellBg)
		    	elseif idx % 2 ~= 0 then
		    		local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
			        cellBg:setContentSize(CCSizeMake(cellSize.width - 4, cellSize.height - 4))
			        cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
			        cell:addChild(cellBg)
		    	end
		        local labelStrTb = {
		            tonumber(idx + 1), data[2] or "", GetServerNameByID(tonumber(data[3] or 0), true), FormatNumber(tonumber(data[4] or 0)), FormatNumber(tonumber(data[5] or 0)), FormatNumber(tonumber(data[6] or 0))
		        }
		        for k, v in pairs(labelStrTb) do
		        	if k == 1 and v < 4 then
		        		local rankSp = CCSprite:createWithSpriteFrameName("top" .. v .. ".png")
	            		rankSp:setScale(0.7)
	            		rankSp:setPosition(cellSize.width * tvTitleWidthRate[k], cellSize.height / 2)
	            		cell:addChild(rankSp)
		        	else
		                local label = GetTTFLabel(v, G_isAsia() and 22 or 20)
		                label:setPosition(cellSize.width * tvTitleWidthRate[k], cellSize.height / 2)
		                cell:addChild(label)
		            end
		        end
		    end)
		    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
		    tv:setPosition(3, 3)
		    tvBg:addChild(tv)
		else
		    self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
		end
	else
		self:showTipLabel(tvBg, (tvTitleBg:getPositionY() - tvTitleBg:getContentSize().height) / 2)
	end
end

function exerWarRankDialog:showUITabFour()
    local tv, tvData
    local tvDataSize = 0
    exerWarVoApi:requestRankData(4, function(data)
		tvData = data
		tvDataSize = SizeOfTable(tvData)
		if tv and tvDataSize > 0 then
			tv:reloadData()
		end
	end)
	tvDataSize = SizeOfTable(tvData)
	if tvDataSize > 0 then
	    local tvSize = CCSizeMake(G_VisibleSizeWidth - 40, self.tabLinePosY - 10 - 95)
	    tv = G_createTableView(tvSize, tvDataSize, CCSizeMake(tvSize.width, 425), function(cell, cellSize, idx, cellNum)
	    	local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
	    	if idx + 1 == cellNum then
		    	cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height))
		    	cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
		    else
		    	cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height + 2))
		    	cellBg:setAnchorPoint(ccp(0.5, 0))
		    	cellBg:setPosition(cellSize.width / 2, - 2)
		    end
	    	cell:addChild(cellBg)
	    	local titleBg = CCSprite:createWithSpriteFrameName("titlebg.png")
	    	titleBg:setAnchorPoint(ccp(0.5, 1))
	    	titleBg:setPosition(cellSize.width / 2, cellSize.height - 5)
	    	cell:addChild(titleBg)
	    	local titleLb = GetTTFLabel(getlocal("exerwar_rankTab4_rankTitle", {cellNum - idx}), G_isAsia() and 25 or 22, true)
	    	titleLb:setPosition(getCenterPoint(titleBg))
	    	titleLb:setColor(G_ColorYellowPro2)
	    	titleBg:addChild(titleLb)
	    	local lbColorTb = {{ccc3(163, 95, 15), ccc3(254, 246, 206)}, {ccc3(71, 97, 119), ccc3(201, 242, 255)}, {ccc3(112, 55, 55), ccc3(211, 211, 211)}}
	    	for k, v in pairs(lbColorTb) do
                local winnerBg = CCSprite:createWithSpriteFrameName("exer_banner" .. k .. ".png")
                if k == 1 then
                    winnerBg:setPosition(cellSize.width / 2, cellSize.height / 2)
                else
                    if k == 2 then
                        winnerBg:setPositionX(cellSize.width / 2 - winnerBg:getContentSize().width + 5)
                    elseif k == 3 then
                        winnerBg:setPositionX(cellSize.width / 2 + winnerBg:getContentSize().width)
                    end
                    winnerBg:setPositionY(cellSize.height / 2 - 50)
                end
                cell:addChild(winnerBg)
	    		local rankData = tvData[cellNum - idx][k]
	    		if rankData then
		    		local serverName = GetServerNameByID(rankData[2])
		    		local headId = tostring(rankData[3])
		    		local winnerName = rankData[4]
		    		local rankingLb = GetTTFLabel(getlocal("serverwar_rank_" .. k), 20, true)
		    		rankingLb:setAnchorPoint(ccp(0.5, 1))
		    		rankingLb:setPosition(winnerBg:getContentSize().width / 2, winnerBg:getContentSize().height - 20)
		    		rankingLb:setColor(v[1])
		    		winnerBg:addChild(rankingLb)
		    		local headSp = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(headId))
		    		headSp:setScale(1.2)
		    		headSp:setPosition(winnerBg:getContentSize().width / 2, winnerBg:getContentSize().height / 2 + 35)
		    		winnerBg:addChild(headSp)
		    		local serverNameLb = GetTTFLabel(serverName, 18)
		    		serverNameLb:setAnchorPoint(ccp(0.5, 1))
		    		serverNameLb:setPosition(winnerBg:getContentSize().width / 2, winnerBg:getContentSize().height / 2 - 15)
		    		serverNameLb:setColor(v[2])
		    		winnerBg:addChild(serverNameLb)
		    		local winnerNameLb = GetTTFLabel(winnerName, 18)
		    		winnerNameLb:setAnchorPoint(ccp(0.5, 1))
		    		winnerNameLb:setPosition(winnerBg:getContentSize().width / 2, serverNameLb:getPositionY() - serverNameLb:getContentSize().height)
		    		winnerNameLb:setColor(v[2])
		    		winnerBg:addChild(winnerNameLb)
		    	end
	    	end
	    end)
	    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
	    tv:setPosition((G_VisibleSizeWidth - tvSize.width) / 2, 95)
	    self.tabLayer:addChild(tv)
	else
		self:showTipLabel(self.tabLayer, G_VisibleSizeHeight / 2)
	end
end

function exerWarRankDialog:tick()
	if self then
		if self.cdTimeLbTb then
			local bcdType, bcdTime = exerWarVoApi:getBiddingCountdown()
			if bcdType <= 3 then
				for i = 1, 2 do
					local cdTimeLb = tolua.cast(self.cdTimeLbTb[i], "CCLabelTTF")
					if cdTimeLb then
						if bcdType == 1 then
			    			cdTimeLb:setString(getlocal("exerwar_rankTab1_dTimeShow" .. i, {G_formatActiveDate(bcdTime)}))
			    		elseif bcdType == 2 and i == 2 then
			    			cdTimeLb:setString(getlocal("exerwar_rankTab1_dTimeShow2_1", {G_formatActiveDate(bcdTime)}))
			    		elseif bcdType == 3 and i == 2 then
    						cdTimeLb:setString(getlocal("exerwar_rankTab1_dTimeShow3", {G_formatActiveDate(bcdTime)}))
			    		end
					end
				end
			end
			if self.bcdType ~= bcdType and self.rankData then
				self.rankData[self.curShowTabIndex] = nil
				self:showTabUI()
			end
		end
	end
end

function exerWarRankDialog:dispose()
    self.tvTitleHeight,self.tvTitleFontSize = nil, nil
	self = nil
	spriteController:removePlist("public/rewardCenterImage.plist")
    spriteController:removeTexture("public/rewardCenterImage.png")
    spriteController:removePlist("public/newTopBgImage1.plist")
    spriteController:removeTexture("public/newTopBgImage1.png")
end