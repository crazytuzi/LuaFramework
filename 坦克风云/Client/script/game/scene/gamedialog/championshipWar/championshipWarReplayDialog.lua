championshipWarReplayDialog = commonDialog:new()

function championshipWarReplayDialog:new(rid, round, report, layerNum)
    local nc = {
        rid = rid, 
        round = round, 
        report = report, 
        layerNum = layerNum, 
        playerIconSize = 100,  --玩家头像大小
        animSpeed = 1,  --动画的倍数
        animMaxSpeed = 2,  --动画的最大倍数
        animFrame = { {15, 0.042}, {5, 0.03}, {20, 0.042} }, 
        isTouchScroll = false, -- TableView是否允许触摸滚动
        cellHeight = 95, 
    }
    setmetatable(nc, self)
    self.__index = self
    
    local function addPlist()
        spriteController:addPlist("public/believer/believerMain.plist")
        spriteController:addTexture("public/believer/believerMain.png")
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/championshipWar/championshipAnim1.plist")
    spriteController:addTexture("public/championshipWar/championshipAnim1.png")
    spriteController:addPlist("public/championshipWar/championshipAnim2.plist")
    spriteController:addTexture("public/championshipWar/championshipAnim2.png")
    spriteController:addPlist("public/championshipWar/championshipAnim3.plist")
    spriteController:addTexture("public/championshipWar/championshipAnim3.png")
    
    return nc
end

function championshipWarReplayDialog:initData()
    local bInfo = championshipWarVoApi:getAllianceWarBattleInfo()
    local alliance = allianceVoApi:getSelfAlliance()
    local selfZoneAid = base.curZoneID .. "-" .. (alliance and alliance.aid or "nil")

    self.allianceInfo = {}
    local tempIndex = 1
    self.membersData = {}
    for k, v in pairs(self.report.members) do
        local tempTb = {
            sortData = {}, 
            infoData = {}, 
        }
        local index = 1
        for m, n in pairs(v) do
            tempTb.sortData[tostring(n[1])] = index
            tempTb.infoData[index] = n
            index = index + 1
        end
        local aInfoTemp = { k, (bInfo and bInfo.ainfo) and bInfo.ainfo[k][1] or "" }
        -- table.insert(self.membersData, tempTb)
        -- 以下判断逻辑主要遵循自己的军团靠右显示，即存放在self.membersData中的第2条数据，否则按照后端发来的顺序显示
        if tempIndex == 1 and k == selfZoneAid then
            self.membersData[2] = tempTb
            self.allianceInfo[2] = aInfoTemp
        else
            if self.membersData[tempIndex] == nil then
                self.membersData[tempIndex] = tempTb
            end
            if self.allianceInfo[tempIndex] == nil then
            	self.allianceInfo[tempIndex] = aInfoTemp
        	end
            tempIndex = tempIndex + 1
        end
    end
    
    self.battleData = {}
    for k, v in pairs(self.report.report) do
        local tempTb = {}
        for m, n in pairs(v) do
            local index = nil
            for i = 1, 2 do
                if self.membersData[i].sortData[m] then
                    index = i
                    tempTb[i] = { m, n }
                    break
                end
            end
        end
        table.insert(self.battleData, tempTb)
    end
end

function championshipWarReplayDialog:initTableView()
    self:initData()
    
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 100)
    self.bgLayer:addChild(titleBg)
    
    local titleLb = GetTTFLabel(championshipWarVoApi:getRoundTitle(self.round), 24, true)
    titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
    titleLb:setColor(G_ColorYellowPro)
    titleBg:addChild(titleLb)
    
    self.topBgTopBoundary = titleBg:getPositionY() - titleBg:getContentSize().height - 15
    
    self:initTopUI(true)
    self:initCenterUI()
    self:initBottomUI()
end

function championshipWarReplayDialog:initTopUI(isInit)
    if self.topBg == nil then
        self.topBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
        self.topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 200))
        self.topBg:setAnchorPoint(ccp(0.5, 1))
        self.topBg:setPosition(G_VisibleSizeWidth / 2, self.topBgTopBoundary)
        self.bgLayer:addChild(self.topBg)
        local leftBg = CCSprite:createWithSpriteFrameName("csi_redBg.png")
        local rightBg = CCSprite:createWithSpriteFrameName("csi_greenBg.png")
        leftBg:setScaleX((self.topBg:getContentSize().width / 2 - 7) / leftBg:getContentSize().width)
        leftBg:setScaleY((self.topBg:getContentSize().height - 10) / leftBg:getContentSize().height)
        rightBg:setScaleX((self.topBg:getContentSize().width / 2 - 7) / rightBg:getContentSize().width)
        rightBg:setScaleY((self.topBg:getContentSize().height - 10) / rightBg:getContentSize().height)
        leftBg:setAnchorPoint(ccp(0.5, 0.5))
        rightBg:setAnchorPoint(ccp(0.5, 0.5))
        leftBg:setPosition(self.topBg:getContentSize().width / 2 - leftBg:getContentSize().width * leftBg:getScaleX() / 2, self.topBg:getContentSize().height / 2)
        rightBg:setPosition(self.topBg:getContentSize().width / 2 + rightBg:getContentSize().width * rightBg:getScaleX() / 2, self.topBg:getContentSize().height / 2)
        self.topBg:addChild(leftBg)
        self.topBg:addChild(rightBg)
        self.topBgNode = CCNode:create()
        self.topBgNode:setContentSize(self.topBg:getContentSize())
        self.topBgNode:setAnchorPoint(ccp(0, 0))
        self.topBgNode:setPosition(0, 0)
        self.topBg:addChild(self.topBgNode)
    else
        self.topBgNode:removeAllChildrenWithCleanup(true)
    end
    
    if isInit == true then
        self.battleIndex = 1
    end
    
    self.playerIconTb = {}
    for i = 1, 2 do
        local battleData = self.battleData[self.battleIndex][i]
        local uid = battleData[1]
        local blood = 100
        if self.battleData[self.battleIndex - 1] then
    		local pervBattleData = self.battleData[self.battleIndex - 1][i]
    		if pervBattleData[2] > 0 then
    			blood = pervBattleData[2]
    		end
    	end
        local membersIndex = self.membersData[i].sortData[tostring(uid)]
        local data = self.membersData[i].infoData[membersIndex]
        local name = data[2] or ""
        local headId = data[3] or headCfg.default
        local troopsNum = data[5] or 0
        local addTroopsNum = data[6] or 0
        if self.tvTb then
            local tv = tolua.cast(self.tvTb[i], "LuaCCTableView")
            if tv then
                local tvSize = tv:getViewSize()
                local itemSize = SizeOfTable(self.membersData[i].infoData)
                local tvPoint = tv:getRecordPoint()
                tvPoint.y = tvSize.height - self.cellHeight * (itemSize - (membersIndex - 1))
                tv:recoverToRecordPoint(tvPoint)
                if not isInit then
                    if self.tvCellTb and self.tvCellTb[i] and self.tvCellTb[i][membersIndex] then
                        local tvCell = self.tvCellTb[i][membersIndex]
                        tvCell:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 1.2), CCScaleTo:create(0.2, 1)))
                    end
                end
            end
        end
        --[[
        if self.focusBgTb then
            for k, v in pairs(self.focusBgTb[i]) do
                if v and tolua.cast(v, "CCSprite") then
                    local focusBg = tolua.cast(v, "CCSprite")
                    focusBg:setVisible(false)
                end
            end
            local focusBg = self.focusBgTb[i][membersIndex]
            focusBg = tolua.cast(focusBg, "CCSprite")
            focusBg:setVisible(true)
        end
        if self.tvTb then
            -- TavleView的定位逻辑
            local tv = tolua.cast(self.tvTb[i], "LuaCCTableView")
            if tv then
            	local tvSize = tv:getViewSize()
            	local itemSize = SizeOfTable(self.membersData[i].infoData)
		        local tvPoint = tv:getRecordPoint()
		        if isInit == true and tvSize.height < self.cellHeight * itemSize then
		        	tvPoint.y = tvSize.height - self.cellHeight * itemSize
		        	tv:recoverToRecordPoint(tvPoint)
		        else
			        if tvPoint.y < 0 then
			            tvPoint.y = tvSize.height - self.cellHeight * (itemSize - (membersIndex - 1))
			            if tvPoint.y > 0 then
			                tvPoint.y = 0
			            end
			            tv:recoverToRecordPoint(tvPoint)
			        end
		    	end
		    end
        end
        --]]
        local posX = self.topBg:getContentSize().width / 4 * ((i == 1) and 1 or 3)
        local nameLb = GetTTFLabel(name, 24)
        nameLb:setPosition(posX, self.topBg:getContentSize().height - 25)
        self.topBgNode:addChild(nameLb)
        local fightSp = CCSprite:createWithSpriteFrameName("picked_icon2.png")
        fightSp:setScale(0.5)
        fightSp:setAnchorPoint(ccp(1, 0.5))
        local troopsStr = troopsNum .. "(<rayimg>+" .. addTroopsNum .. "<rayimg>)"
        local troopsLbColor = { nil, G_ColorGreen, nil }
        local troopsLb, troopsLbHeight = G_getRichTextLabel(troopsStr, troopsLbColor, 24, self.topBg:getContentSize().width - fightSp:getContentSize().width * fightSp:getScale(), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        troopsLb:setAnchorPoint(ccp(0, 0.5))
        fightSp:setPosition(posX - 30, 30)
        troopsLb:setPosition(fightSp:getPositionX() + 5, fightSp:getPositionY() + troopsLbHeight / 2)
        self.topBgNode:addChild(fightSp)
        self.topBgNode:addChild(troopsLb)
        local playerIcon = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(tostring(headId)))
        playerIcon:setPosition(posX, self.topBg:getContentSize().height / 2)
        playerIcon:setScale(self.playerIconSize / playerIcon:getContentSize().width)
        self.topBgNode:addChild(playerIcon)
        local bloodBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("csi_progressBar_red.png"))
        bloodBar:setMidpoint(ccp(0, 1))
        bloodBar:setBarChangeRate(ccp(1, 0))
        bloodBar:setType(kCCProgressTimerTypeBar)
        local bloodBarBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function()end)
        bloodBarBg:setContentSize(CCSizeMake(playerIcon:getContentSize().width - 8, bloodBar:getContentSize().height))
        bloodBarBg:setOpacity(255 * 0.65)
        bloodBarBg:setAnchorPoint(ccp(0.5, 0))
        bloodBarBg:setPosition(playerIcon:getContentSize().width / 2, 3)
        playerIcon:addChild(bloodBarBg)
        bloodBar:setScaleX(bloodBarBg:getContentSize().width / bloodBar:getContentSize().width)
        bloodBar:setScaleY(bloodBarBg:getContentSize().height / bloodBar:getContentSize().height)
        bloodBar:setPosition(bloodBarBg:getContentSize().width / 2, bloodBarBg:getContentSize().height / 2)
        bloodBarBg:addChild(bloodBar)
        bloodBar:setPercentage(blood)
        local bloodPerLb = GetTTFLabel(string.format("%0.2f", bloodBar:getPercentage()) .. "%", 15)
        bloodPerLb:setPosition(bloodBarBg:getContentSize().width / 2, bloodBarBg:getContentSize().height / 2)
        bloodBarBg:addChild(bloodPerLb)
        bloodBarBg:setTag(10)
        bloodBar:setTag(10)
        bloodPerLb:setTag(11)
        table.insert(self.playerIconTb, playerIcon)
    end
    
end

function championshipWarReplayDialog:initCenterUI()
    local centerBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    centerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, self.topBg:getPositionY() - self.topBg:getContentSize().height - 210))
    centerBg:setAnchorPoint(ccp(0.5, 1))
    centerBg:setPosition(G_VisibleSizeWidth / 2, self.topBg:getPositionY() - self.topBg:getContentSize().height - 15)
    self.bgLayer:addChild(centerBg)

    for i = 1, 2 do
    	local allianceName = (self.allianceInfo and self.allianceInfo[i]) and self.allianceInfo[i][2] or ""
    	local allianceNameLb = GetTTFLabelWrap(allianceName, 24, CCSizeMake(centerBg:getContentSize().width / 2 - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    	allianceNameLb:setColor(G_ColorRed)
    	local posX = centerBg:getContentSize().width / 4
    	if i == 2 then
    		posX = centerBg:getContentSize().width / 4 * 3
    		allianceNameLb:setColor(G_ColorGreen)
    	end
    	allianceNameLb:setPosition(posX, centerBg:getContentSize().height - 35)
    	centerBg:addChild(allianceNameLb)
    end
    
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png", CCRect(26, 0, 2, 6), function()end)
    lineSp:setContentSize(CCSizeMake(centerBg:getContentSize().width - 40, lineSp:getContentSize().height))
    lineSp:setPosition(centerBg:getContentSize().width / 2, centerBg:getContentSize().height - 70)
    centerBg:addChild(lineSp)

    for i = 1, 2 do
        local tvBg = CCSprite:createWithSpriteFrameName((i == 1) and "csi_redBg.png" or "csi_greenBg.png")
        tvBg:setScaleX((centerBg:getContentSize().width / 2 - 3) / tvBg:getContentSize().width)
        tvBg:setScaleY((lineSp:getPositionY() - 6) / tvBg:getContentSize().height)
        tvBg:setAnchorPoint(ccp(0.5, 0.5))
        tvBg:setPosition(centerBg:getContentSize().width / 2 + ((i == 1) and -1 or 1) * tvBg:getContentSize().width * tvBg:getScaleX() / 2, lineSp:getPositionY() / 2)
        centerBg:addChild(tvBg)
    end
    
    self.tvTb = {}
    self.tvCellTb = {}
    -- self.focusBgTb = {}
    local tvSize = CCSizeMake(centerBg:getContentSize().width / 2 - 3, lineSp:getPositionY() - 6)
    for i = 1, 2 do
        self.tvCellTb[i] = {}
        -- self.focusBgTb[i] = {}
        local cellNum = SizeOfTable(self.membersData[i].infoData)
        local function tvCallBack(handler, fn, index, cel)
            if fn == "numberOfCellsInTableView" then
                return cellNum
            elseif fn == "tableCellSizeForIndex" then
                return CCSizeMake(tvSize.width, self.cellHeight)
            elseif fn == "tableCellAtIndex" then
                local cell = CCTableViewCell:new()
                cell:autorelease()
                local cellW, cellH = tvSize.width, self.cellHeight
                
                --[[
                local focusBg
                local function onTouchHandler()
                    if self.tvTb[i] and self.tvTb[i]:getIsScrolled() == false then
                        for k, v in pairs(self.focusBgTb[i]) do
                            if v and tolua.cast(v, "CCSprite") then
                                local prevBg = tolua.cast(v, "CCSprite")
                                prevBg:setVisible(false)
                            end
                        end
                        focusBg:setVisible(true)
                    end
                end
                focusBg = LuaCCSprite:createWithSpriteFrameName((i == 2) and "ltzdzCampBg1.png" or "ltzdzCampBg2.png", onTouchHandler)
                if i == 2 then
                    focusBg:setFlipY(true)
                else
                    focusBg:setFlipX(true)
                end
                focusBg:setScaleX(cellW / focusBg:getContentSize().width)
                focusBg:setScaleY(cellH / focusBg:getContentSize().height)
                focusBg:setPosition(cellW / 2, cellH / 2)
                if self.isTouchScroll == true then
                	focusBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            	end
                cell:addChild(focusBg)
                if index > 0 then
                    focusBg:setVisible(false)
                end
                self.focusBgTb[i][index + 1] = focusBg
                --]]

                local cellNode = CCNode:create()
                cellNode:setContentSize(CCSizeMake(cellW, cellH))
                cellNode:setAnchorPoint(ccp(0.5, 0.5))
                cellNode:setPosition(cellW / 2, cellH / 2)
                cell:addChild(cellNode)
                
                local numBg = CCSprite:createWithSpriteFrameName("csi_triangleBg.png")
                numBg:setPosition(15 + numBg:getContentSize().width / 2, cellH / 2)
                numBg:setOpacity(255 * 0.2)
                if i == 2 then
                    numBg:setColor(ccc3(14, 212, 14))
                else
                    numBg:setColor(ccc3(255, 0, 0))
                end
                cellNode:addChild(numBg)
                local numLb = GetTTFLabel(tostring(index + 1), 24)
                numLb:setPosition(numBg:getContentSize().width / 2, numBg:getContentSize().height / 2 + 6)
                numBg:addChild(numLb)
                
                local data = self.membersData[i].infoData[index + 1]
                local name = data[2] or ""
                local fight = data[4] or 0
                
                local nameLb = GetTTFLabel(name, 24)
                local fightLb = GetTTFLabel(tostring(FormatNumber(fight)), 24)
                nameLb:setAnchorPoint(ccp(0.5, 0))
                fightLb:setAnchorPoint(ccp(0.5, 1))
                local lbPosX = numBg:getPositionX() + numBg:getContentSize().width / 2 + (cellW - (numBg:getPositionX() + numBg:getContentSize().width / 2)) / 2
                nameLb:setPosition(lbPosX, cellH / 2)
                fightLb:setPosition(lbPosX, cellH / 2)
                cellNode:addChild(nameLb)
                cellNode:addChild(fightLb)

                self.tvCellTb[i][index + 1] = cellNode
                
                return cell
            elseif fn == "ccTouchBegan" then
                return true
            elseif fn == "ccTouchMoved" then
            elseif fn == "ccTouchEnded" then
            end
        end
        local hd = LuaEventHandler:createHandler(tvCallBack)
        local tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
        if self.isTouchScroll == true then
	        tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
	        tv:setMaxDisToBottomOrTop(80)
    	end
        tv:setPosition(3, 3)
        centerBg:addChild(tv, 1)
        if i == 2 then
            tv:setPosition(centerBg:getContentSize().width / 2, 3)
        end
        self.tvTb[i] = tv

        local focusBg = CCSprite:createWithSpriteFrameName((i == 2) and "ltzdzCampBg1.png" or "ltzdzCampBg2.png")
        if i == 2 then
            focusBg:setFlipY(true)
        else
            focusBg:setFlipX(true)
        end
        focusBg:setScaleX(tvSize.width / focusBg:getContentSize().width)
        focusBg:setScaleY(self.cellHeight / focusBg:getContentSize().height)
        focusBg:setPosition(centerBg:getContentSize().width / 2 + ((i == 1) and -1 or 1) * focusBg:getContentSize().width * focusBg:getScaleX() / 2, tv:getPositionY() + tvSize.height - self.cellHeight / 2)
        centerBg:addChild(focusBg)
    end
    
    if self.isTouchScroll == true then
		--添加上、下、左、右的触摸屏蔽层
		local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
		top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - (centerBg:getPositionY() - 73)))
		top:setAnchorPoint(ccp(0.5, 0))
		top:setPosition(G_VisibleSizeWidth / 2, centerBg:getPositionY() - 73)
		self.bgLayer:addChild(top)
		top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
		top:setVisible(false)

		local bottom = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
		bottom:setContentSize(CCSizeMake(G_VisibleSizeWidth, centerBg:getPositionY() - centerBg:getContentSize().height + 3))
		bottom:setAnchorPoint(ccp(0.5, 1))
		bottom:setPosition(G_VisibleSizeWidth / 2, centerBg:getPositionY() - centerBg:getContentSize().height + 3)
		self.bgLayer:addChild(bottom)
		bottom:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
		bottom:setVisible(false)

		local left = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
		left:setContentSize(CCSizeMake(left:getContentSize().width, top:getPositionY() - bottom:getPositionY()))
		left:setAnchorPoint(ccp(1, 0.5))
		left:setPosition(centerBg:getPositionX() - centerBg:getContentSize().width / 2 + 3, bottom:getPositionY() + left:getContentSize().height / 2)
		self.bgLayer:addChild(left)
		left:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
		left:setVisible(false)

		local right = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
		right:setContentSize(CCSizeMake(right:getContentSize().width, top:getPositionY() - bottom:getPositionY()))
		right:setAnchorPoint(ccp(0, 0.5))
		right:setPosition(centerBg:getPositionX() + centerBg:getContentSize().width / 2 - 3, bottom:getPositionY() + right:getContentSize().height / 2)
		self.bgLayer:addChild(right)
		right:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
		right:setVisible(false)
	end
end

function championshipWarReplayDialog:initBottomUI()
	local mySignUpOrder, signUpOrder, winningStreak = self:getSelfSignUpOrder()

    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	if signUpOrder == 0 then
        		smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_notJoinBattle"), 30)
        		do return end
        	else
        		self.battleIndex = signUpOrder
        		self:initTopUI()
                self:playAnim(true)
        	end
        elseif tag == 11 then
        	if self.selfBtn:isEnabled() == false then
        		local btnState = tolua.cast(self.replayBtn:getChildByTag(55), "CCSprite")
        		self.animSpeed = self.animSpeed + 1
        		if self.animSpeed > self.animMaxSpeed then
        			self.animSpeed = 0
        			btnState:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("csi_pause.png"))
        		else
        			btnState:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("csi_play_speed" .. self.animSpeed .. ".png"))
        		end
		        if self.animSpeedTb then
		            for k, v in pairs(self.animSpeedTb) do
		                if v and tolua.cast(v, "CCSpeed") then
		                    local speed = tolua.cast(v, "CCSpeed")
		                    speed:setSpeed(self.animSpeed)
		                end
		            end
		        end
        	else
	            self:playAnim(true)
        	end
        elseif tag == 12 then
        	championshipWarVoApi:showReportDialog(self.rid, self.round, self.layerNum + 1, function() self:resetReplay() end)
        end
    end
    local selfBtn = GetButtonItem("csi_selfBtn.png", "csi_selfBtn_down.png", "csi_selfBtn.png", onClickHandler, 10)
    local replayBtn = GetButtonItem("steward_green_midBtn.png", "steward_green_midBtn_down.png", "steward_green_midBtn.png", onClickHandler, 11)
    local reportBtn = GetButtonItem("csi_reportBtn.png", "csi_reportBtn_down.png", "csi_reportBtn.png", onClickHandler, 12)
    local menuArr = CCArray:create()
    menuArr:addObject(selfBtn)
    menuArr:addObject(replayBtn)
    menuArr:addObject(reportBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu)
    replayBtn:setPosition(G_VisibleSizeWidth / 2, 30 + replayBtn:getContentSize().height / 2)
    selfBtn:setPosition(G_VisibleSizeWidth / 2 - replayBtn:getContentSize().width / 2 - 60 - selfBtn:getContentSize().width / 2, replayBtn:getPositionY())
    reportBtn:setPosition(G_VisibleSizeWidth / 2 + replayBtn:getContentSize().width / 2 + 60 + reportBtn:getContentSize().width / 2, replayBtn:getPositionY())
    
    local btnState = CCSprite:createWithSpriteFrameName("csi_play_speed1.png")
    btnState:setPosition(replayBtn:getContentSize().width / 2, replayBtn:getContentSize().height / 2)
    btnState:setTag(55)
    replayBtn:addChild(btnState)
    if mySignUpOrder == 0 then
    	reportBtn:setEnabled(false)
    end

    local line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
    line:setContentSize(CCSizeMake(G_VisibleSizeWidth, line:getContentSize().height))
    line:setAnchorPoint(ccp(0.5, 0))
    line:setPosition(ccp(G_VisibleSizeWidth / 2, replayBtn:getPositionY() + replayBtn:getContentSize().height / 2 + 15))
    self.bgLayer:addChild(line)
    
    self.selfBtn = selfBtn
    self.replayBtn = replayBtn
    
    local function onTouchInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = { getlocal("championshipWar_battleReport_rule1"), getlocal("championshipWar_battleReport_rule2"), getlocal("championshipWar_battleReport_rule3") }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onTouchInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(G_VisibleSizeWidth - 35 - infoBtn:getContentSize().width / 2, line:getPositionY() + 10 + infoBtn:getContentSize().height / 2))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoMenu)

    local lbW = G_VisibleSizeWidth - infoBtn:getContentSize().width - 100
    local mySignUpOrderLb = GetTTFLabelWrap(getlocal("championshipWar_mySignUpOrder", {mySignUpOrder}), 24, CCSizeMake(lbW, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
    local myWinningStreakLb = GetTTFLabelWrap(getlocal("championshipWar_myWinningStreak", {winningStreak}), 24, CCSizeMake(lbW, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    mySignUpOrderLb:setAnchorPoint(ccp(0, 0))
    myWinningStreakLb:setAnchorPoint(ccp(0, 1))
    mySignUpOrderLb:setPosition(50, infoMenu:getPositionY())
    myWinningStreakLb:setPosition(50, infoMenu:getPositionY())
    self.bgLayer:addChild(mySignUpOrderLb)
    self.bgLayer:addChild(myWinningStreakLb)
end

function championshipWarReplayDialog:resetReplay()
    if self then
        self.animSpeedTb = nil
        self.selfBtn:setEnabled(true)
        self.animSpeed = 1
        local btnState = tolua.cast(self.replayBtn:getChildByTag(55), "CCSprite")
        btnState:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("csi_play_speed" .. self.animSpeed .. ".png"))
        self:initTopUI(true)
    end
end

--获取自己的出场顺序
function championshipWarReplayDialog:getSelfSignUpOrder()
    local mySignUpOrder = 0 --出场顺序
	local signUpOrder = 0 --出战顺序
	local winningStreak = 0 --连胜
    if self.battleData then
    	local selfUid = playerVoApi:getUid()
        for k, bData in pairs(self.battleData) do
	        for i = 1, 2 do
	            local uid = bData[i][1]
	            local blood = bData[i][2]
	            if tostring(selfUid) == tostring(uid) then
	                if signUpOrder == 0 then
	                	signUpOrder = k
                        mySignUpOrder = self.membersData[i].sortData[tostring(uid)]
	                end
	                if blood > 0 then
	                	winningStreak = winningStreak + 1
	                end
	            end
	        end
    	end
    end
    return mySignUpOrder, signUpOrder, winningStreak
end

function championshipWarReplayDialog:createAnim(animId, callback)
    local firstFrameSp = CCSprite:createWithSpriteFrameName("csa_anim" .. animId .. "_1.png")
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE_MINUS_SRC_COLOR
    firstFrameSp:setBlendFunc(blendFunc)
    local frameArray = CCArray:create()
    for i = 1, self.animFrame[animId][1] do
        local frameName = "csa_anim" .. animId .. "_" .. i .. ".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
        frameArray:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, self.animFrame[animId][2])
    local animate = CCAnimate:create(animation)
    local animArray = CCArray:create()
    animArray:addObject(animate)
    animArray:addObject(CCCallFunc:create(function() if callback then callback() end end))
    local speed = CCSpeed:create(CCSequence:create(animArray), self.animSpeed)
    return firstFrameSp, speed
end

function championshipWarReplayDialog:playAnim(isFirst)
    self.animSpeedTb = nil
    self.selfBtn:setEnabled(false)
    self.animSpeedTb = {}
    
    local function iconAction2(iconSp, rightFlag, winFlag, index)
        local x, y = iconSp:getPosition()
        
        local seqArr = CCArray:create()
        
        local arr1 = CCArray:create()
        arr1:addObject(CCMoveBy:create(0.043, rightFlag and ccp(34, 2) or ccp( - 34, 2)))
        arr1:addObject(CCRotateBy:create(0.043, rightFlag and 5 or - 5))
        local spawn1 = CCSpawn:create(arr1)
        seqArr:addObject(spawn1)
        
        local arr2 = CCArray:create()
        arr2:addObject(CCMoveBy:create(0.1, rightFlag and ccp( - 147, 11) or ccp(147, 11)))
        arr2:addObject(CCRotateBy:create(0.1, rightFlag and - 3 or 3))
        local spawn2 = CCSpawn:create(arr2)
        seqArr:addObject(spawn2)
        
        --播放碰撞动画
        seqArr:addObject(CCCallFunc:create(function()
                local animSp, speed
                animSp, speed = self:createAnim(2, function()
                        animSp:stopAllActions()
                        animSp:removeFromParentAndCleanup(true)
                        --播放血条掉血动画
                        local bloodPer = self.battleData[self.battleIndex][index][2]
                        local bloodBarBg = iconSp:getChildByTag(10)
                        if bloodBarBg and tolua.cast(bloodBarBg, "CCSprite") then
                            bloodBarBg = tolua.cast(bloodBarBg, "CCSprite")
                            local bloodBar = bloodBarBg:getChildByTag(10)
                            if bloodBar and tolua.cast(bloodBar, "CCProgressTimer") then
                                bloodBar = tolua.cast(bloodBar, "CCProgressTimer")
                                -- bloodBar:setPercentage(bloodPer)
                                local progressFromTo = CCProgressFromTo:create(0.21, bloodBar:getPercentage(), bloodPer)
                                local progressCallFunc = CCCallFunc:create(function()
                                	local bloodPerLb = bloodBarBg:getChildByTag(11)
		                            if bloodPerLb and tolua.cast(bloodPerLb, "CCLabelTTF") then
		                                bloodPerLb = tolua.cast(bloodPerLb, "CCLabelTTF")
		                                bloodPerLb:setString(string.format("%0.2f", bloodPer) .. "%")
		                            end
                                end)
                                local progressSeq = CCSequence:createWithTwoActions(progressFromTo, progressCallFunc)
                                local progressSpeed = CCSpeed:create(progressSeq, self.animSpeed)
        						table.insert(self.animSpeedTb, progressSpeed)
                                bloodBar:runAction(progressSpeed)
                            end
                        end
                    end)
                table.insert(self.animSpeedTb, speed)
                animSp:setPosition(self.topBg:getContentSize().width / 2, self.topBg:getContentSize().height / 2 + 50)
                self.topBgNode:addChild(animSp, 10)
                animSp:runAction(speed)
        end))
        
        local arr3 = CCArray:create()
        arr3:addObject(CCMoveBy:create(0.2, rightFlag and ccp(129, - 12) or ccp( - 129, - 12)))
        local rotate = 0
        if rightFlag == true then
            if winFlag == true then
                rotate = 5
            else
                rotate = - 11
            end
        else
            if winFlag == true then
                rotate = - 5
            else
                rotate = 11
            end
        end
        arr3:addObject(CCRotateBy:create(0.2, rotate))
        local spawn3 = CCSpawn:create(arr3)
        seqArr:addObject(spawn3)
        
        if winFlag == true then
            local delay = CCDelayTime:create(0.13)
            seqArr:addObject(delay)
            
            local arr4 = CCArray:create()
            arr4:addObject(CCMoveTo:create(0.5, ccp(x, y)))
            arr4:addObject(CCRotateTo:create(0.5, 0))
            local spawn4 = CCSpawn:create(arr4)
            seqArr:addObject(spawn4)
        else
            seqArr:addObject(CCRotateBy:create(0.13, rightFlag and 9 or - 9))
            seqArr:addObject(CCRotateBy:create(0.13, rightFlag and - 7 or 7))
            seqArr:addObject(CCRotateBy:create(0.13, rightFlag and 5 or - 5))
            seqArr:addObject(CCCallFunc:create(function()
                    local animSp, speed
                    animSp, speed = self:createAnim(3, function()
                    		if self then
	                            animSp:stopAllActions()
	                            animSp:removeFromParentAndCleanup(true)
	                            self.animSpeedTb = nil
	                            if self.battleIndex == SizeOfTable(self.battleData) then
	                                -- 整场战斗的动画播放完成
	                                self:resetReplay()
	                            else
	                                -- 一个回合战斗的动画播放完成
	                                self.battleIndex = self.battleIndex + 1
	                                self:initTopUI()
	                                self:playAnim()
	                            end
	                        end
                        end)
                    table.insert(self.animSpeedTb, speed)
                    animSp:setPosition(iconSp:getPosition())
                    animSp:setRotation(iconSp:getRotation())
                    self.topBgNode:addChild(animSp, 10)
                    animSp:runAction(speed)
            end))
            seqArr:addObject(CCDelayTime:create(self.animFrame[3][2] * 8))
            seqArr:addObject(CCCallFunc:create(function()
                    iconSp:setVisible(false)
            end))
        end
        
        local speed = CCSpeed:create(CCSequence:create(seqArr), self.animSpeed)
        table.insert(self.animSpeedTb, speed)
        iconSp:runAction(speed)
    end
    
    --入场缩放动作
    local function iconAction1(iconSp, callback)
        if iconSp == nil then
            return
        end

        iconSp:setVisible(false)
        -- iconSp:setOpacity(0)
        iconSp:setScale((self.topBg:getContentSize().height + 40) / iconSp:getContentSize().width)
        -- local fadeTo = CCFadeTo:create(0.3, 255)
        local scaleTo = CCScaleTo:create(0.3, 100 / iconSp:getContentSize().width)
        -- local arr = CCArray:create()
        -- arr:addObject(fadeTo)
        -- arr:addObject(scaleTo)
        local seqArr = CCArray:create()
        seqArr:addObject(CCDelayTime:create(0.1))
        seqArr:addObject(CCCallFunc:create(function()
                iconSp:setVisible(true)
        end))
        -- seqArr:addObject(CCSpawn:create(arr))
        seqArr:addObject(scaleTo)
        seqArr:addObject(CCCallFunc:create(function()
                iconSp:stopAllActions()
                local animSp, speed
                animSp, speed = self:createAnim(1, function()
                        animSp:stopAllActions()
                        animSp:removeFromParentAndCleanup(true)
                        if callback then
                            callback()
                        end
                    end)
                table.insert(self.animSpeedTb, speed)
                animSp:setPosition(iconSp:getContentSize().width / 2, iconSp:getContentSize().height / 2)
                animSp:runAction(speed)
                iconSp:addChild(animSp)
        end))
        local speed = CCSpeed:create(CCSequence:create(seqArr), self.animSpeed)
        table.insert(self.animSpeedTb, speed)
        iconSp:runAction(speed)
    end
    
    local function runIconAction2(winIndex)
        for i = 1, 2 do
            iconAction2(self.playerIconTb[i], (i == 2) and true or nil, (winIndex == i) and true or nil, i)
        end
    end
    
    local winIndex
    for i = 1, 2 do
        --判断胜负
        if self.battleData[self.battleIndex][i][2] > 0 then
            winIndex = i
        end
    end
    if isFirst == true then
        for i = 1, 2 do
            iconAction1(self.playerIconTb[i], (i == 2) and function() runIconAction2(winIndex) end or nil)
        end
    else
        local iconIndex
        for i = 1, 2 do
            if self.battleData[self.battleIndex - 1][i][2] == 0 then
                iconIndex = i
            end
        end
        iconAction1(self.playerIconTb[iconIndex], function() runIconAction2(winIndex) end)
    end
end

function championshipWarReplayDialog:dispose()
	-- self.focusBgTb = nil
    self.tvCellTb = nil
	self.tvTb = nil
    self = nil
    spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("public/championshipWar/championshipAnim1.plist")
    spriteController:removeTexture("public/championshipWar/championshipAnim1.png")
    spriteController:removePlist("public/championshipWar/championshipAnim2.plist")
    spriteController:removeTexture("public/championshipWar/championshipAnim2.png")
    spriteController:removePlist("public/championshipWar/championshipAnim3.plist")
    spriteController:removeTexture("public/championshipWar/championshipAnim3.png")
end