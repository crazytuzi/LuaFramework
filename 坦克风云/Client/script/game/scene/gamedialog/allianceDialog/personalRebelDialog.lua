personalRebelDialog = commonDialog:new()

function personalRebelDialog:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	G_addResource8888(function()
	    spriteController:addPlist("public/personalRebelImages.plist")
	    spriteController:addTexture("public/personalRebelImages.png")
    end)
	return nc
end

function personalRebelDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
    if self.panelBottomLine then
    	self.panelBottomLine:setVisible(false)
    end
end

function personalRebelDialog:initTableView()
	local mapPosY = G_VisibleSizeHeight - 87
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	local mapBg = CCSprite:create("scene/world_map_miNew.jpg")
	if mapBg:getContentSize().height < mapPosY then
		local tempMap = CCSprite:create("scene/world_map_miNew.jpg")
		tempMap:setAnchorPoint(ccp(0.5, 1))
		tempMap:setPosition(mapBg:getContentSize().width / 2, 0)
		mapBg:addChild(tempMap)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	mapBg:setAnchorPoint(ccp(0.5, 1))
	mapBg:setPosition(G_VisibleSizeWidth / 2, mapPosY)
	self.bgLayer:addChild(mapBg)

	--初始化棋盘
	local prCfg = rebelVoApi:pr_getCfg()
	self.row, self.col = prCfg.mapSize[1], prCfg.mapSize[2] --8行4列
	self.gridSpaceW, self.gridSpaceH = 10, 10 --每个网格左右/上下的间距
	self.gridWidth = (G_VisibleSizeWidth - (self.col - 1) * self.gridSpaceW) / self.col --每个网格的宽
	local gridSp = CCSprite:createWithSpriteFrameName("pri_unknown1.png")
	gridSp:setScale(self.gridWidth / gridSp:getContentSize().width)
	self.gridHeight = gridSp:getContentSize().height * gridSp:getScale() --每个网格的高
	gridSp = nil
	self.cellHeight = self.row * self.gridHeight + (self.row - 1) * self.gridSpaceH
	self.gridTvSize = CCSizeMake(G_VisibleSizeWidth, self.cellHeight)
	local gridTvPosY = 110
	if mapPosY - gridTvPosY >= self.cellHeight then
		gridTvPosY = gridTvPosY + (mapPosY - gridTvPosY - self.cellHeight) / 2
	else
		self.gridTvSize.height = mapPosY - gridTvPosY
	end
	local hd = LuaEventHandler:createHandler(function(...) return self:initGrid(...) end)
	self.gridTv = LuaCCTableView:createWithEventHandler(hd, self.gridTvSize, nil)
	self.gridTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
	self.gridTv:setPosition(0, gridTvPosY)
	self.gridTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(self.gridTv, 1)

	self:initBottomButton()

	self.refreshListener = function(event, data)
		if data then
			if data.eventType == 1 then --重置棋盘
				self.fogGridData = nil
			end
		end
        if self and tolua.cast(self.gridTv, "CCNode") then
        	local recordPoint = self.gridTv:getRecordPoint()
        	self.gridTv:reloadData()
		   	self.gridTv:recoverToRecordPoint(recordPoint)
        end
	end
	eventDispatcher:addEventListener("personalRebelDialog.refresh", self.refreshListener)
	local recordPoint = self.gridTv:getRecordPoint()
	recordPoint.y = 0
	self.gridTv:recoverToRecordPoint(recordPoint)
end

function personalRebelDialog:initGrid(handler, fn, idx, cel)
	if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.gridTvSize.width, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        local gridData = rebelVoApi:pr_getGridData()
        for r = 1, self.row do
			for c = 1, self.col do
				local gridNode = CCNode:create()
				gridNode:setContentSize(CCSizeMake(self.gridWidth, self.gridHeight))
				gridNode:setPosition(ccp((c - 1) * (self.gridWidth + self.gridSpaceW), (r - 1) * (self.gridHeight + self.gridSpaceH)))
				cell:addChild(gridNode)

				local data
				if gridData and gridData[r] and gridData[r][c] then
					data = gridData[r][c]
				end
				local nameBgImage, nameStr

				--自己的头像
				local playerPos = rebelVoApi:pr_getPlayerPos()
				if playerPos.x == r and playerPos.y == c then
					local playerIcon = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName())
					playerIcon:setScale((self.gridHeight - 30) / playerIcon:getContentSize().height)
					playerIcon:setPosition(self.gridWidth / 2, self.gridHeight / 2 + 10)
					gridNode:addChild(playerIcon)
					nameBgImage = "pri_nameBg1.png"
					nameStr = playerVoApi:getPlayerName()
				elseif data then
					if data.fogState == 1 then
						if data.npcType == 1 or data.npcType == 5 then
							local ruinsImage
							if data.npcType == 1 then --普通废墟
								ruinsImage = "pri_ruins.png"
								nameBgImage = "rebelNameBg.png"
								nameStr = getlocal("personalRebel_ruinsText")
							elseif data.npcType == 5 then --高级废墟(宝箱)
								ruinsImage = "advanceMaterialBox.png"
							end
							if ruinsImage then
								local ruinsIcon = CCSprite:createWithSpriteFrameName(ruinsImage)
								ruinsIcon:setScale((self.gridHeight - 10) / ruinsIcon:getContentSize().height)
								ruinsIcon:setPosition(self.gridWidth / 2, self.gridHeight / 2)
								gridNode:addChild(ruinsIcon, 1)
								local clickSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
									local eventType --1：探索废墟，2：Boss宝箱，3：秒杀叛军
									if data.npcType == 1 then
										eventType = 1
									elseif data.npcType == 5 then
										eventType = 2
									end
									--占领废墟(宝箱)的逻辑
									rebelVoApi:pr_requestAttackRuins(function(rData)
										if rData then
											rData = FormatItem(rData, nil, true)
				                        	for k, v in pairs(rData) do
				                        		if v.type ~= "rg" then
									                G_addPlayerAward(v.type, v.key, v.id, v.num, true, true)
									            end
				                        	end
											rebelVoApi:pr_showRewardSmallDialog(self.layerNum + 1, {eventType, rData, function()
												eventDispatcher:dispatchEvent("personalRebelDialog.refresh")
											end})
										end
									end, {r, c})
								end)
								clickSp:setContentSize(CCSizeMake(self.gridWidth, self.gridHeight))
								clickSp:setPosition(self.gridWidth / 2, self.gridHeight / 2)
								clickSp:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
								clickSp:setOpacity(0)
								gridNode:addChild(clickSp, 1)
							end
						else
							local tankId = rebelVoApi:pr_getMonsterIconId(data.npcType, data.monsterId)
							if tankId then
								-- print("cjl --------->>>> ", r, c, tankId)
								tankId = tonumber(RemoveFirstChar(tankId))
								local tankIcon = G_getTankPic(tankId, nil, nil, nil, nil, false)
								if tankIcon then
									if data.npcType == 4 then
										local gridBg = CCSprite:createWithSpriteFrameName("pri_unknown2.png")
										gridBg:setScale(self.gridWidth / gridBg:getContentSize().width)
										gridBg:setPosition(self.gridWidth / 2, self.gridHeight / 2)
										gridBg:setOpacity(255 * 0.5)
										gridNode:addChild(gridBg)
									end
									tankIcon:setScale(self.gridHeight / tankIcon:getContentSize().height + self:getTankScale(tankId))
									tankIcon:setPosition(self.gridWidth / 2, self.gridHeight / 2)
									gridNode:addChild(tankIcon, 1)
									nameBgImage = (data.npcType == 4) and "pri_nameBg2.png" or "rebelNameBg.png"
									nameStr = rebelVoApi:pr_getMonsterName(data.npcType, tankId)
									local hpWidth = self.gridWidth * 0.7
									local lvBg = CCSprite:createWithSpriteFrameName("rebelIconLevel.png")
									local hpBg = CCSprite:createWithSpriteFrameName("rebelProgressBg.png")
									hpBg:setScaleX(hpWidth / hpBg:getContentSize().width)
									lvBg:setPosition((self.gridWidth - (lvBg:getContentSize().width + hpWidth)) / 2 + lvBg:getContentSize().width / 2, self.gridHeight - lvBg:getContentSize().height / 2)
									hpBg:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 + hpWidth / 2, lvBg:getPositionY())
									gridNode:addChild(hpBg, 1)
									gridNode:addChild(lvBg, 1)
									local lvLb = GetTTFLabel(tostring(data.monsterLv), 22)
									lvLb:setPosition(lvBg:getContentSize().width / 2, lvBg:getContentSize().height / 2)
									lvBg:addChild(lvLb)
									local hpProgressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("rebelProgress.png"))
									hpProgressBar:setMidpoint(ccp(0, 1))
								    hpProgressBar:setBarChangeRate(ccp(1, 0))
								    hpProgressBar:setType(kCCProgressTimerTypeBar)
									hpProgressBar:setPosition(hpBg:getContentSize().width / 2, hpBg:getContentSize().height / 2)
									hpProgressBar:setPercentage(data.monsterHp / data.monsterMaxHp * 100)
									hpBg:addChild(hpProgressBar)
									local clickSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
										rebelVoApi:pr_showInfoSmallDialog(self.layerNum + 1, { data, ccp(r, c) })
									end)
									clickSp:setContentSize(CCSizeMake(self.gridWidth, self.gridHeight))
									clickSp:setPosition(self.gridWidth / 2, self.gridHeight / 2)
									clickSp:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
									clickSp:setOpacity(0)
									gridNode:addChild(clickSp, 1)
								end
							end
						end
						if self.fogGridData and self.fogGridData[r] and self.fogGridData[r][c] == true then
							local gridBg
							if data.npcType ~= 4 then
								gridBg = CCSprite:createWithSpriteFrameName("pri_unknown1.png")
								gridBg:setScale(self.gridWidth / gridBg:getContentSize().width)
								gridBg:setPosition(self.gridWidth / 2, self.gridHeight / 2)
								gridBg:setOpacity(255 * 0.5)
								gridNode:addChild(gridBg)
							end
							local clipNode = CCClippingNode:create()
						    clipNode:setContentSize(CCSizeMake(self.gridWidth, self.gridHeight))
						    clipNode:setAnchorPoint(ccp(0.5, 0))
						    clipNode:setStencil(CCDrawNode:getAPolygon(clipNode:getContentSize(), 1, 1))
						    clipNode:setPosition(self.gridWidth / 2, 0)
						    gridNode:addChild(clipNode, 2)
						    local fogBgImage = "pri_unknown" .. ((r == self.row) and 2 or 1) .. ".png"
							local fogMarkImage = "pri_bgMark" .. ((r == self.row) and 2 or 1) .. ".png"
							if data.npcType == 4 and r == 7 then
								fogBgImage = "pri_unknown2.png"
								fogMarkImage = "pri_bgMark2.png"
							end
							local fogBg = CCSprite:createWithSpriteFrameName(fogBgImage)
							fogBg:setScale(self.gridWidth / fogBg:getContentSize().width)
							fogBg:setPosition(self.gridWidth / 2, self.gridHeight / 2)
							clipNode:addChild(fogBg)
							local fogMark = CCSprite:createWithSpriteFrameName(fogMarkImage)
							fogMark:setPosition(fogBg:getContentSize().width / 2, fogBg:getContentSize().height / 2)
							fogBg:addChild(fogMark)
							if data.npcType == 4 and r == 7 then
								fogBg:setOpacity(255 * 0.5)
								-- fogMark:setOpacity(255 * 0.5)
								fogMark:setVisible(false)
							end
							local scanSp = CCSprite:createWithSpriteFrameName("pri_scanEffect.png")
						    scanSp:setAnchorPoint(ccp(0.5, 0))
						    scanSp:setScale((self.gridWidth - 10) / scanSp:getContentSize().width)
						    scanSp:setPosition(self.gridWidth / 2, clipNode:getContentSize().height)
						    gridNode:addChild(scanSp, 2)
						    scanSp:setVisible(false)
						    local h = self.gridHeight
						    local arr = CCArray:create()
						    arr:addObject(CCCallFunc:create(function()
						        h = h - 2
						        if h <= 0 then
						        	h = 0
						        end
						        clipNode:setContentSize(CCSizeMake(self.gridWidth, h))
						        clipNode:setStencil(CCDrawNode:getAPolygon(clipNode:getContentSize(), 1, 1))
						        scanSp:setPositionY(clipNode:getContentSize().height)
						        scanSp:setVisible(true)
						        if h == 0 then
						        	if data.npcType == 4 and r == 7 and self.cellHeight > self.gridTvSize.height then
										self.schedulerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(...) self:update(...) end, 0, false)
									end
						            gridNode:stopAllActions()
						            if gridBg then
						            	gridBg:removeFromParentAndCleanup(true)
						            end
						            clipNode:removeFromParentAndCleanup(true)
						            scanSp:removeFromParentAndCleanup(true)
						        end
						    end))
						    gridNode:runAction(CCRepeatForever:create(CCSequence:create(arr)))
						    self.fogGridData[r][c] = nil
						end
					elseif data.fogState == 0 then
						if self.fogGridData == nil then
							self.fogGridData = {}
						end
						if self.fogGridData[r] == nil then
							self.fogGridData[r] = {}
						end
						self.fogGridData[r][c] = true
						local fogBgImage = "pri_unknown" .. ((r == self.row) and 2 or 1) .. ".png"
						local fogMarkImage = "pri_bgMark" .. ((r == self.row) and 2 or 1) .. ".png"
						if data.npcType == 4 and r == 7 then
							fogBgImage = "pri_unknown2.png"
							fogMarkImage = "pri_bgMark2.png"
						end
						--迷雾
						local fogBg = CCSprite:createWithSpriteFrameName(fogBgImage)
						fogBg:setScale(self.gridWidth / fogBg:getContentSize().width)
						fogBg:setPosition(self.gridWidth / 2, self.gridHeight / 2)
						local fogMark = CCSprite:createWithSpriteFrameName(fogMarkImage)
						fogMark:setPosition(fogBg:getContentSize().width / 2, fogBg:getContentSize().height / 2)
						fogBg:addChild(fogMark)
						if data.npcType == 4 and r == 7 then
							fogBg:setOpacity(255 * 0.5)
							-- fogMark:setOpacity(255 * 0.5)
							fogMark:setVisible(false)
							gridNode:addChild(fogBg, 2)
							local tankId = rebelVoApi:pr_getMonsterIconId(data.npcType, data.monsterId)
							print("tankId=====>",tankId)
							if tankId then
								tankId = tonumber(RemoveFirstChar(tankId))
								local tankIcon = G_getTankPic(tankId, nil, nil, nil, nil, false)
								if tankIcon then
									local gridBg = CCSprite:createWithSpriteFrameName("pri_unknown2.png")
									gridBg:setScale(self.gridWidth / gridBg:getContentSize().width)
									gridBg:setPosition(self.gridWidth / 2, self.gridHeight / 2)
									gridBg:setOpacity(255 * 0.5)
									gridNode:addChild(gridBg)
									tankIcon:setScale(self.gridHeight / tankIcon:getContentSize().height + self:getTankScale(tankId))
									tankIcon:setPosition(self.gridWidth / 2, self.gridHeight / 2)
									gridNode:addChild(tankIcon, 1)
									nameBgImage = "pri_nameBg2.png"
									nameStr = rebelVoApi:pr_getMonsterName(data.npcType, tankId)
									local hpWidth = self.gridWidth * 0.7
									local lvBg = CCSprite:createWithSpriteFrameName("rebelIconLevel.png")
									local hpBg = CCSprite:createWithSpriteFrameName("rebelProgressBg.png")
									hpBg:setScaleX(hpWidth / hpBg:getContentSize().width)
									lvBg:setPosition((self.gridWidth - (lvBg:getContentSize().width + hpWidth)) / 2 + lvBg:getContentSize().width / 2, self.gridHeight - lvBg:getContentSize().height / 2)
									hpBg:setPosition(lvBg:getPositionX() + lvBg:getContentSize().width / 2 + hpWidth / 2, lvBg:getPositionY())
									gridNode:addChild(hpBg, 1)
									gridNode:addChild(lvBg, 1)
									local lvLb = GetTTFLabel(tostring(data.monsterLv), 22)
									lvLb:setPosition(lvBg:getContentSize().width / 2, lvBg:getContentSize().height / 2)
									lvBg:addChild(lvLb)
									local hpProgressBar = CCProgressTimer:create(CCSprite:createWithSpriteFrameName("rebelProgress.png"))
									hpProgressBar:setMidpoint(ccp(0, 1))
								    hpProgressBar:setBarChangeRate(ccp(1, 0))
								    hpProgressBar:setType(kCCProgressTimerTypeBar)
									hpProgressBar:setPosition(hpBg:getContentSize().width / 2, hpBg:getContentSize().height / 2)
									hpProgressBar:setPercentage(data.monsterHp / data.monsterMaxHp * 100)
									hpBg:addChild(hpProgressBar)
								end
							end
						else
							gridNode:addChild(fogBg)
						end
					end
				end

				--名称
				if nameBgImage and nameStr then
					local nameFontSize = 18
					local nameLb = GetTTFLabel(nameStr, nameFontSize)
					local nameBgWidth = nameLb:getContentSize().width + 20
					if nameBgWidth > self.gridWidth - 5 then
						nameLb:setScale((self.gridWidth - 5 - 20) / nameLb:getContentSize().width)
						nameBgWidth = self.gridWidth - 5
					end
					local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName(nameBgImage, CCRect(10, 4, 2, 2), function()end)
		            nameBg:setContentSize(CCSizeMake(nameBgWidth, nameLb:getContentSize().height + 4))
		            nameLb:setPosition(nameBg:getContentSize().width / 2, nameBg:getContentSize().height / 2)
		            nameBg:addChild(nameLb)
		            nameBg:setAnchorPoint(ccp(0.5, 0))
		            nameBg:setPosition(self.gridWidth / 2, 3)
		            gridNode:addChild(nameBg, 1)
				end
			end
		end

        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function personalRebelDialog:initBottomButton()
	local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
	bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 110))
	bottomBg:setAnchorPoint(ccp(0.5, 0))
	bottomBg:setPosition(G_VisibleSizeWidth / 2, 0)
	self.bgLayer:addChild(bottomBg, 1)
	local function onClickHandler(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	rebelVoApi:pr_showBagSmallDialog(self.layerNum + 1)
        elseif tag == 11 then
        	--重置棋盘逻辑
        	local function onSureLogic()
	        	rebelVoApi:pr_requestGet(function()
	        		smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("expeditionRestartSuccess"), 30)
	        		if self.restartBtn then
	        			eventDispatcher:dispatchEvent("refresh.flag.numbg")
	        			self.restartBtn:setEnabled(false)
	        			self.getFlagIcon:setVisible(false)
	        		end
	        		eventDispatcher:dispatchEvent("personalRebelDialog.refresh", {eventType = 1})
	        	end, 1)
        	end
        	smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("personalRebel_restartTipsText"), nil, self.layerNum + 1)
        elseif tag == 12 then
        	rebelVoApi:pr_showReportDialog(self.layerNum + 1)
        elseif tag == 13 then
        	local tabStr = {
                    getlocal("personalRebel_directionTitle1"),
                    getlocal("personalRebel_directionText1_1"),
                    getlocal("personalRebel_directionText1_2"),
                    getlocal("personalRebel_directionText1_3"),
                    getlocal("personalRebel_directionText1_4"),
                    getlocal("personalRebel_directionText1_5"),
                    getlocal("personalRebel_directionText1_6"),
                    getlocal("personalRebel_directionText1_7", {math.floor(rebelCfg.recoverTime / 60)}),
                    getlocal("personalRebel_directionText1_8"),
                    "\n",
                    getlocal("personalRebel_directionTitle2"),
                    getlocal("personalRebel_directionText2_1"),
                    getlocal("personalRebel_directionText2_2"),
                    getlocal("personalRebel_directionText2_3"),
                    "\n",
                    getlocal("personalRebel_directionTitle3"),
                    getlocal("personalRebel_directionText3"),
                }
                local tabStrColor = {G_ColorGreen, nil, nil, nil, nil, nil, nil, nil, nil, G_ColorGreen, nil, nil, nil, nil, G_ColorGreen, nil}
                require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, tabStrColor, 25)
        end
	end
	local btnScale, btnFontSize = 0.7, 24
	local bagBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("personalRebel_itemBagText"), btnFontSize / btnScale)
	local restartBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("signAgainBtn"), btnFontSize / btnScale)
	local reportBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("fight_content_fight_title"), btnFontSize / btnScale)
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickHandler, 13)
    local menuArr = CCArray:create()
    menuArr:addObject(bagBtn)
    menuArr:addObject(restartBtn)
    menuArr:addObject(reportBtn)
    menuArr:addObject(infoBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    bottomBg:addChild(btnMenu)
    bagBtn:setScale(btnScale)
    restartBtn:setScale(btnScale)
    reportBtn:setScale(btnScale)
    infoBtn:setScale(0.9)
    local btnSpaceW, btnPosY = 30, bottomBg:getContentSize().height / 2 - 10
    local btnWidth = bagBtn:getContentSize().width * btnScale + restartBtn:getContentSize().width * btnScale + reportBtn:getContentSize().width * btnScale + infoBtn:getContentSize().width * infoBtn:getScale() + btnSpaceW * 3
    local btnStartPosX = (bottomBg:getContentSize().width - btnWidth) / 2
    bagBtn:setPosition(btnStartPosX + bagBtn:getContentSize().width * btnScale / 2, btnPosY)
    restartBtn:setPosition(bagBtn:getPositionX() + bagBtn:getContentSize().width * btnScale / 2 + btnSpaceW + restartBtn:getContentSize().width * btnScale / 2, btnPosY)
    reportBtn:setPosition(restartBtn:getPositionX() + restartBtn:getContentSize().width * btnScale / 2 + btnSpaceW + reportBtn:getContentSize().width * btnScale / 2, btnPosY)
    infoBtn:setPosition(reportBtn:getPositionX() + reportBtn:getContentSize().width * btnScale / 2 + btnSpaceW + infoBtn:getContentSize().width * infoBtn:getScale() / 2, btnPosY)
    self.cdTimeLb = GetTTFLabel(G_formatActiveDate(rebelVoApi:pr_getRestartCDTimer() - base.serverTime), 24)
    self.cdTimeLb:setAnchorPoint(ccp(0.5, 0))
    self.cdTimeLb:setPosition(restartBtn:getPositionX(), restartBtn:getPositionY() + restartBtn:getContentSize().height * btnScale / 2 + 5)
    bottomBg:addChild(self.cdTimeLb)
    restartBtn:setEnabled(false)
    self.restartBtn = restartBtn
    local capInSet1=CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    self.getFlagIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
    self.getFlagIcon:setPosition(self.restartBtn:getContentSize().width-5, self.restartBtn:getContentSize().height-5)

    self.restartBtn:addChild(self.getFlagIcon)
    self.getFlagIcon:setVisible(false)
    self.getFlagIcon:setScale(0.7)
end

function personalRebelDialog:getTankScale(tankId)
	if tonumber(tankId) == 10024 then
		return 0.2
	elseif tonumber(tankId) == 10073 then
		return - 0.15
	elseif tonumber(tankId) == 10082 then
		return - 0.1
	elseif tonumber(tankId) == 20153 then
		return 0.15
	elseif tonumber(tankId) == 10022 then
		return 0.25
	elseif tonumber(tankId) == 10025 then
		return 0.23
	end
	return 0
end

function personalRebelDialog:update(dt)
	if self and tolua.cast(self.bgLayer, "CCNode") and tolua.cast(self.gridTv, "LuaCCTableView") and self.cellHeight > self.gridTvSize.height then
		local recordPoint = self.gridTv:getRecordPoint()
		recordPoint.y = recordPoint.y - 6
		if recordPoint.y < self.gridTvSize.height - self.cellHeight then
			recordPoint.y = self.gridTvSize.height - self.cellHeight
			if self.schedulerID ~= nil then
		        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
		        self.schedulerID = nil
		    end
		end
		self.gridTv:recoverToRecordPoint(recordPoint)
	end
end

function personalRebelDialog:tick()
	if self and tolua.cast(self.bgLayer, "CCNode") then
		if self.cdTimeLb then
			local cdTimer = rebelVoApi:pr_getRestartCDTimer()
			self.cdTimeLb:setString(G_formatActiveDate(cdTimer - base.serverTime))
			if cdTimer < base.serverTime and self.restartBtn then
				self.restartBtn:setEnabled(true)
				self.getFlagIcon:setVisible(true)
			end
		end
	end
end

function personalRebelDialog:dispose()
	if self.schedulerID ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
    end
	if self.refreshListener then
        eventDispatcher:removeEventListener("personalRebelDialog.refresh", self.refreshListener)
        self.refreshListener = nil
    end
	self = nil
	spriteController:removePlist("public/personalRebelImages.plist")
    spriteController:removeTexture("public/personalRebelImages.png")
end