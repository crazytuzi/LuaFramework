militaryOrdersDialog = commonDialog:new()

function militaryOrdersDialog:new(layerNum)
	local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    G_addResource8888(function()
        spriteController:addPlist("public/acCustomImage.plist")
        spriteController:addTexture("public/acCustomImage.png")
        spriteController:addPlist("public/accessoryImage.plist")
        spriteController:addPlist("public/accessoryImage2.plist")
    end)
    spriteController:addPlist("public/blueFilcker.plist")
	spriteController:addPlist("public/greenFlicker.plist")
	spriteController:addPlist("public/purpleFlicker.plist")
	spriteController:addPlist("public/yellowFlicker.plist")
	spriteController:addPlist("public/redFlicker.plist")
    return nc
end

function militaryOrdersDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)

    local timeStr = getlocal("acCD") .. "：" .. G_formatActiveDate(militaryOrdersVoApi:getEndTime() - base.serverTime)
	local tmpLb = GetTTFLabel(timeStr, 20)
    local timeBg, timeLb, timeLbLbHeight = G_createNewTitle({timeStr, 20, G_ColorYellowPro}, CCSizeMake(tmpLb:getContentSize().width + 150, 0), nil, true, "Helvetica-bold")
    timeBg:setAnchorPoint(ccp(0.5, 0))
    timeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85 - 30)
    self.bgLayer:addChild(timeBg)
	self.timeLb = timeLb

	local function onClickInfoBtn(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = { getlocal("militaryOrders_tipsDesc1"), getlocal("militaryOrders_tipsDesc2"), getlocal("militaryOrders_tipsDesc3"), getlocal("militaryOrders_tipsDesc4"), getlocal("militaryOrders_tipsDesc5") }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("military_info.png", "military_info.png", "military_info.png", onClickInfoBtn)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    infoMenu:setPosition(ccp(0, 0))
    infoBtn:setAnchorPoint(ccp(1, 0.5))
    infoBtn:setScale(1.5)
    infoBtn:setPosition(G_VisibleSizeWidth-30, G_VisibleSizeHeight - 85 - 23)
    self.bgLayer:addChild(infoMenu)

    self.tvCellNum, self.normalReward, self.honourReward = militaryOrdersVoApi:getRewardData()
    local moLevel = militaryOrdersVoApi:getMilitaryOrdersLv()

    local taskContentBg
    if moLevel < self.tvCellNum then
    	taskContentBg = CCSprite:createWithSpriteFrameName("military_taskbg.png")
	    taskContentBg:setAnchorPoint(ccp(0.5, 1))
	    taskContentBg:setPosition(G_VisibleSizeWidth / 2, timeBg:getPositionY() - 5)
	    self.bgLayer:addChild(taskContentBg)
	    local taskLb = GetTTFLabel(getlocal("activity_ganenjiehuikui_eveTask"), G_getLS(22, 18), true)
	    taskLb:setPosition(taskContentBg:getContentSize().width / 2, taskContentBg:getContentSize().height - 16)
	    taskLb:setColor(G_ColorYellowPro)
	    taskContentBg:addChild(taskLb)

	   	self.dayTask = militaryOrdersVoApi:getDayTask()
	    local taskTvSize = CCSizeMake(taskContentBg:getContentSize().width - 50, taskContentBg:getContentSize().height - 50)
	    self.taskTv = G_createTableView(taskTvSize, SizeOfTable(self.dayTask), function(idx, cellNum)
	    		local height = 0
	    		local data = self.dayTask[idx + 1]
	    		if data then
			        local taskKey = data.key
			        taskKey = (taskKey == "gb") and "gba" or taskKey
			        taskKey = (taskKey == "eb") and "eb2" or taskKey
			        local taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {data.num, data.needNum})
			        if taskKey == "ai" then
			        	local param1
			            if data.quality == nil or data.quality == 0 then
			            	param1 = getlocal("fleetInfoTitle2") .. " " .. data.num
			            else
			                param1 = getlocal("aitroops_troop" .. data.quality) .. " " .. data.num
			            end
			            taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {param1, data.needNum .. " "})
			        elseif taskKey == "hy" then
			        	taskDescStr = getlocal("activity_smcz_hy_title", {data.num, data.needNum})
			        end
			        local taskDescLb = GetTTFLabelWrap(taskDescStr, 20, CCSizeMake(taskTvSize.width - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			        height = height + taskDescLb:getContentSize().height
			        height = height + 15
			    end
	    		return CCSizeMake(taskTvSize.width, height)
	    	end, 
	    	function(cell, cellSize, idx, cellNum)
	    		local data = self.dayTask[idx + 1]
	    		if data then
			        local taskKey = data.key
			        taskKey = (taskKey == "gb") and "gba" or taskKey
			        taskKey = (taskKey == "eb") and "eb2" or taskKey
			        local taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {data.num, data.needNum})
			        if taskKey == "ai" then
			        	local param1
			            if data.quality == nil or data.quality == 0 then
			            	param1 = getlocal("fleetInfoTitle2") .. " " .. data.num
			            else
			                param1 = getlocal("aitroops_troop" .. data.quality) .. " " .. data.num
			            end
			            taskDescStr = getlocal("activity_chunjiepansheng_" .. taskKey .. "_title", {param1, data.needNum .. " "})
			        elseif taskKey == "hy" then
			        	taskDescStr = getlocal("activity_smcz_hy_title", {data.num, data.needNum})
			        end
			        local taskDescLb = GetTTFLabelWrap(taskDescStr, 18, CCSizeMake(taskTvSize.width - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			        taskDescLb:setAnchorPoint(ccp(0, 0.5))
			        taskDescLb:setPosition(0, cellSize.height / 2)
			        if data.num >= data.needNum then
			        	taskDescLb:setColor(G_ColorGreen)
			        end
			        cell:addChild(taskDescLb)
			        if idx + 1 < cellNum then
			        	-- local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png", CCRect(4, 0, 1, 2), function()end)
				        -- lineSp:setContentSize(CCSizeMake(cellSize.width, lineSp:getContentSize().height))
				        -- lineSp:setPosition(cellSize.width / 2, 0)
				        -- lineSp:setOpacity(255 * 0.06)
				        -- cell:addChild(lineSp)
			        end
			        if data.num >= data.needNum then
			        	local completeLb = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"), 22)
			        	completeLb:setAnchorPoint(ccp(1, 0.5))
			        	completeLb:setPosition(cellSize.width, cellSize.height / 2)
			        	completeLb:setColor(G_ColorGreen)
			        	cell:addChild(completeLb)
			        else
				        local function onClickJump(tag, obj)
				        	if G_checkClickEnable() == false then
					            do return end
					        else
					            base.setWaitTime = G_getCurDeviceMillTime()
					        end
					        PlayEffect(audioCfg.mouseClick)
					        local typeName = data.key
							typeName = typeName =="gba" and "gb" or typeName--heroM
							typeName = typeName =="bc" and "cn" or typeName
							typeName = (typeName =="ua" or typeName == "ta") and "armor" or typeName
							typeName = (typeName =="uh" or typeName == "th") and "heroM" or typeName
							typeName = typeName =="pr" and "tp" or typeName
							typeName = (typeName == "ac" or typeName == "ai" or typeName == "ai1" or typeName == "ai2") and "aiTroop" or typeName
							typeName = (typeName == "st" or typeName == "sj") and "emblemTroop" or typeName
							local useIdx = nil
							if data.key == "st" then
								useIdx = 2
							elseif data.key == "sj" then
								useIdx = 1
							end
							self:close()
							G_goToDialog2(typeName, 4, true, useIdx)
				        end
				        local jumpBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickJump)
				        jumpBtn:setScale(0.4)
				        local jumpMenu = CCMenu:createWithItem(jumpBtn)
				        jumpMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
				        jumpMenu:setPosition(cellSize.width - 50, cellSize.height / 2)
				        cell:addChild(jumpMenu) 
				        local btnLabel = GetTTFLabel(getlocal("activity_heartOfIron_goto"), 18, true)
				        btnLabel:setPosition(ccp(jumpMenu:getPosition()))
				        cell:addChild(btnLabel)
				    end
			    end
	    	end)
	    self.taskTv:setPosition((taskContentBg:getContentSize().width - taskTvSize.width) / 2, 15)
	    self.taskTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 4)
	    self.taskTv:setMaxDisToBottomOrTop(0)
	    taskContentBg:addChild(self.taskTv)
	end

    local function onClickHandler(tag, obj)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	moLevel = militaryOrdersVoApi:getMilitaryOrdersLv()
        	militaryOrdersVoApi:showPrivilegeSmallDialog(self.layerNum + 1, function(eventType, unlockToLv)
        		--eventType 1-激活,2-解锁
        		if eventType == 1 then
        			if tolua.cast(self.lockSp, "CCSprite") then
        				self.lockSp:setVisible(militaryOrdersVoApi:isActivate() == false)
        			end
        			if tolua.cast(self.activateBtnLabel, "CCLabelTTF") then
						self.activateBtnLabel:setString(militaryOrdersVoApi:isActivate() and getlocal("militaryOrders_privilegeTitle") or getlocal("militaryOrders_activate"))
					end
					self:refreshRewardTv()
				elseif eventType == 2 then
					self:unlockRefreshRewardTvCell(moLevel, unlockToLv)
        		end
        		-- self:refreshRewardTv(eventType == 2)
        	end)
        	militaryOrdersVoApi:setNewPrivilegeStatus(false)
        	if tolua.cast(self.tipsIcon, "CCSprite") then
        		self.tipsIcon:setVisible(militaryOrdersVoApi:isHasNewPrivilege())
        	end
        elseif tag == 11 then
        	militaryOrdersVoApi:showShopSmallDialog(self.layerNum + 1)
        elseif tag == 12 then
        	print("cjl -------->>> 一键领取")
        	militaryOrdersVoApi:requestReward(function()
        		militaryOrdersVoApi:showRewardListSmallDialog(self.layerNum + 1, self.canGetAllReward, function(isHasNewPrivilege)
	        		if isHasNewPrivilege == true then
	                	G_showTipsDialog(getlocal("militaryOrders_unlockNewPrivilegeTips"))
	                	militaryOrdersVoApi:setNewPrivilegeStatus(isHasNewPrivilege)
	                	if tolua.cast(self.tipsIcon, "CCSprite") then
	                		self.tipsIcon:setVisible(militaryOrdersVoApi:isHasNewPrivilege())
	                	end
	                end
	        	end)
	        	self:refreshRewardTv()
        	end)
        end
    end
    local btnScale, btnFontSize = 0.7, 24
   if G_isAsia() == false then
    	btnFontSize = 16
    end
	local activateBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("militaryOrders_activate"), btnFontSize / btnScale, 55)
	local exchangeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("militaryOrders_shopExchange"), btnFontSize / btnScale)
	local allGetBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("friend_newSys_gift_b2"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(activateBtn)
    menuArr:addObject(exchangeBtn)
    menuArr:addObject(allGetBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    self.bgLayer:addChild(btnMenu)
    activateBtn:setScale(btnScale)
    exchangeBtn:setScale(btnScale)
    allGetBtn:setScale(btnScale)
    activateBtn:setPosition(G_VisibleSizeWidth / 2 - activateBtn:getContentSize().width * btnScale / 2 - 120, 20 + activateBtn:getContentSize().height * btnScale / 2)
    exchangeBtn:setPosition(G_VisibleSizeWidth / 2 + exchangeBtn:getContentSize().width * btnScale / 2 + 120, 20 + exchangeBtn:getContentSize().height * btnScale / 2)
    allGetBtn:setPosition(G_VisibleSizeWidth / 2, 20 + allGetBtn:getContentSize().height * btnScale / 2)
    self.allGetBtn = allGetBtn
    self.activateBtnLabel = tolua.cast(activateBtn:getChildByTag(55), "CCLabelTTF")
    self.activateBtnLabel:setString(militaryOrdersVoApi:isActivate() and getlocal("militaryOrders_privilegeTitle") or getlocal("militaryOrders_activate"))
    local tipsIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
    tipsIcon:setAnchorPoint(ccp(0.8, 0.8))
    tipsIcon:setPosition(activateBtn:getPositionX() + activateBtn:getContentSize().width * btnScale / 2, activateBtn:getPositionY() + activateBtn:getContentSize().height * btnScale / 2)
    tipsIcon:setScale(0.6)
    self.bgLayer:addChild(tipsIcon)
    self.tipsIcon = tipsIcon
    self.tipsIcon:setVisible(militaryOrdersVoApi:isHasNewPrivilege())

    local titleHeight = 68
    local rewardBgHeight = timeBg:getPositionY() - titleHeight - (activateBtn:getPositionY() + activateBtn:getContentSize().height * btnScale / 2) - 30
    local rewardBgPosY = timeBg:getPositionY() - titleHeight - 10
    if taskContentBg then
    	rewardBgHeight = taskContentBg:getPositionY() - taskContentBg:getContentSize().height - (activateBtn:getPositionY() + activateBtn:getContentSize().height * btnScale / 2) - titleHeight - 10
    	rewardBgPosY = taskContentBg:getPositionY() - taskContentBg:getContentSize().height - titleHeight + 10
    end
    self:initRewardUI(rewardBgHeight, rewardBgPosY)

    local enabledFlag = (SizeOfTable(self.canGetAllReward) > 1)
    self.allGetBtn:setEnabled(enabledFlag)
    self.allGetBtn:setVisible(enabledFlag)

    if(self.activateCardPushListener==nil)then
		local function listener(event,data) --购买激活卡支付推送
			if data and data.military then
				militaryOrdersVoApi:syncMilitary(data.military)
			end
		end
		self.activateCardPushListener=listener
		eventDispatcher:addEventListener("user.pay.push",self.activateCardPushListener)
	end
end

function militaryOrdersDialog:initRewardUI(rewardBgHeight, rewardBgPosY)
	local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 14, rewardBgHeight))
    rewardBg:setAnchorPoint(ccp(0.5, 1))
    rewardBg:setPosition(G_VisibleSizeWidth / 2, rewardBgPosY)
    self.bgLayer:addChild(rewardBg)
    local titleBg = CCSprite:createWithSpriteFrameName("military_titlebg.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(G_VisibleSizeWidth / 2, rewardBgPosY + 68)
    self.bgLayer:addChild(titleBg)
    
    local moLevel = militaryOrdersVoApi:getMilitaryOrdersLv()
    local lvTipStr = ""
    if moLevel >= militaryOrdersVoApi:getMaxLevel() then
    	lvTipStr = getlocal("decorateMax")
    else
    	lvTipStr = getlocal("current_level_2")
    end
    local curLvLb = GetTTFLabel(lvTipStr, 16, true)
    curLvLb:setAnchorPoint(ccp(0.5, 1))
    curLvLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height - 10)
    curLvLb:setColor(G_ColorYellowPro)
    titleBg:addChild(curLvLb)
    local cruLvNumLb = GetTTFLabel(moLevel, 20, true)
    cruLvNumLb:setAnchorPoint(ccp(0.5, 1))
    cruLvNumLb:setPosition(curLvLb:getPositionX(), curLvLb:getPositionY() - curLvLb:getContentSize().height)
    titleBg:addChild(cruLvNumLb)
    self.cruLvNumLb = cruLvNumLb

    local honourRewardLb = GetTTFLabel(getlocal("militaryOrders_honourReward"), G_isAsia() == false and 18 or 22, true)
    honourRewardLb:setAnchorPoint(ccp(0.5, 0.5))
    honourRewardLb:setPosition((titleBg:getContentSize().width / 2 - 100 / 2 - 3) / 2 + 3, titleBg:getContentSize().height - 35)
    honourRewardLb:setColor(G_ColorYellowPro)
    titleBg:addChild(honourRewardLb)
    local lockSp = CCSprite:createWithSpriteFrameName("military_lock.png")
    lockSp:setScale(honourRewardLb:getContentSize().height / lockSp:getContentSize().height)
    lockSp:setAnchorPoint(ccp(1, 0.5))
    lockSp:setPosition(honourRewardLb:getPositionX() - honourRewardLb:getContentSize().width / 2, honourRewardLb:getPositionY())
    titleBg:addChild(lockSp)
	self.lockSp = lockSp
	self.lockSp:setVisible(militaryOrdersVoApi:isActivate() == false)
    local normalRewardLb = GetTTFLabel(getlocal("award"), G_isAsia() == false and 18 or 22, true)
    normalRewardLb:setPosition(rewardBg:getContentSize().width / 2 + 100 / 2 + honourRewardLb:getPositionX() - 3, titleBg:getContentSize().height - 35)
    titleBg:addChild(normalRewardLb)

    local tvCellHeight = 117
    local bottomCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("moi_lightBg.png", CCRect(4, 4, 2, 2), function()end)
    bottomCellBg:setContentSize(CCSizeMake(rewardBg:getContentSize().width - 6, tvCellHeight))
    bottomCellBg:setAnchorPoint(ccp(0.5, 0))
    bottomCellBg:setPosition(rewardBg:getContentSize().width / 2, 3)
    local rewardTvSize = CCSizeMake(rewardBg:getContentSize().width - 4, rewardBg:getContentSize().height - 5 - bottomCellBg:getContentSize().height - 3)
    self.rewardTv = G_createTableView(rewardTvSize, self.tvCellNum, CCSizeMake(rewardTvSize.width, tvCellHeight), function(...) self:rewardTvView(...) end)
    self.rewardTv:setPosition((rewardBg:getContentSize().width - rewardTvSize.width) / 2, 3 + bottomCellBg:getContentSize().height)
    self.rewardTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    -- self.rewardTv:setMaxDisToBottomOrTop(0)
    rewardBg:addChild(self.rewardTv)
    rewardBg:addChild(bottomCellBg)

    local bottomCellSp = CCSprite:createWithSpriteFrameName("military_cellbg2.png")
    bottomCellSp:setPosition(bottomCellBg:getContentSize().width / 2, bottomCellBg:getContentSize().height / 2)
    bottomCellBg:addChild(bottomCellSp)

    self.bottomCell = CCNode:create()
    self.bottomCell:setContentSize(bottomCellBg:getContentSize())
    self.bottomCell:setAnchorPoint(ccp(0, 0))
    self.bottomCell:setPosition(0, 0)
    bottomCellBg:addChild(self.bottomCell)
    self:rewardTvView(self.bottomCell, self.bottomCell:getContentSize())

    local tvPoint = self.rewardTv:getRecordPoint()
    if tvPoint.y < 0 and moLevel > 1 then
    	tvPoint.y = rewardTvSize.height - tvCellHeight * (self.tvCellNum - (moLevel - 1))
        if tvPoint.y > 0 then
            tvPoint.y = 0
        end
        self.rewardTv:recoverToRecordPoint(tvPoint)
    end

    --添加上下屏蔽层
    local upShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    upShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    upShiedldBg:setAnchorPoint(ccp(0.5, 0))
    upShiedldBg:setPosition(G_VisibleSizeWidth / 2, self.rewardTv:getPositionY() + rewardTvSize.height)
    upShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    upShiedldBg:setOpacity(0)
    rewardBg:addChild(upShiedldBg)
    local downShiedldBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    downShiedldBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    downShiedldBg:setAnchorPoint(ccp(0.5, 1))
    downShiedldBg:setPosition(G_VisibleSizeWidth / 2, self.rewardTv:getPositionY())
    downShiedldBg:setTouchPriority( - (self.layerNum - 1) * 20 - 3)
    downShiedldBg:setOpacity(0)
    rewardBg:addChild(downShiedldBg)
end

function militaryOrdersDialog:refreshRewardTv(isRefBottomCell, overMonthFlag)
	if self.rewardTv then
		self.canGetAllReward = nil
		local recordPoint = self.rewardTv:getRecordPoint()
		self.rewardTv:reloadData()
		if overMonthFlag ~= true then
			self.rewardTv:recoverToRecordPoint(recordPoint)
		end
		if self.allGetBtn then
			local enabledFlag = (SizeOfTable(self.canGetAllReward) > 1)
		    self.allGetBtn:setEnabled(enabledFlag)
		    self.allGetBtn:setVisible(enabledFlag)
		end
	end
	if isRefBottomCell == true then
		if self.bottomCell then
			self.bottomCell:removeAllChildrenWithCleanup(true)
			self:rewardTvView(self.bottomCell, self.bottomCell:getContentSize())
		end
	end
end

function militaryOrdersDialog:unlockRefreshRewardTvCell(prevLv, unlockToLv)
	if self.rewardTvCellTb then
		for i = prevLv + 1, unlockToLv + 1 do
			local tvCellData = self.rewardTvCellTb[i]
			if tvCellData then
				local cell, cellSize, idx, cellNum = tvCellData[1], tvCellData[2], tvCellData[3], tvCellData[4]
				cell:removeAllChildrenWithCleanup(true)
				self:rewardTvView(cell, cellSize, idx, cellNum)
			end
		end
		if self.allGetBtn then
			local enabledFlag = (SizeOfTable(self.canGetAllReward) > 1)
		    self.allGetBtn:setEnabled(enabledFlag)
		    self.allGetBtn:setVisible(enabledFlag)
		end
	end
	if self.bottomCell then
		self.bottomCell:removeAllChildrenWithCleanup(true)
		self:rewardTvView(self.bottomCell, self.bottomCell:getContentSize())
	end
end

function militaryOrdersDialog:rewardTvView(cell, cellSize, idx, cellNum)
	local unlockData
	if idx == nil then
		unlockData = militaryOrdersVoApi:getUnlockData()
		if unlockData and unlockData[2] and unlockData[2][1] then
			idx = unlockData[2][1] - 1
		else
			do return end
		end
	end
	local index = idx + 1
	local function showNewPropDialog(item)
        if item.type == "at" and item.eType == "a" then --AI部队
            local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(item.key, true)
            AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
        else
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
        end
    end
    local iconSize = 70
    local iconSpaceX = 15
    local middleRectWidth = 100
    local rewardRectWidth = (cellSize.width - middleRectWidth) / 2

    local cellBg = CCSprite:createWithSpriteFrameName("military_cellbg2.png")
    cellBg:setPosition(cellSize.width / 2, cellSize.height / 2)
    cell:addChild(cellBg)

    local function showRewardUI(rewardTb, direction)
    	local rewardTbSize = SizeOfTable(rewardTb)
    	local curRewardRectWidth = (rewardTbSize * iconSize + (rewardTbSize - 1) * iconSpaceX)
    	local firstIconPosX
    	if direction == 1 then
    		firstIconPosX = (cellSize.width + middleRectWidth) / 2 + (rewardRectWidth - curRewardRectWidth) / 2
    		if firstIconPosX < 0 then
    			firstIconPosX = (cellSize.width + middleRectWidth) / 2 + 10
    		end
    	elseif direction == 2 then
    		firstIconPosX = (rewardRectWidth - curRewardRectWidth) / 2
    		if firstIconPosX < 0 then
    			firstIconPosX = 20
    		end
    	end
    	for k, v in pairs(rewardTb) do
			local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function() showNewPropDialog(v) end)
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - (unlockData and 4 or 2))
            icon:setPosition(firstIconPosX + (k - 1) * (iconSize + iconSpaceX) + iconSize / 2, cellSize.height / 2)
            cell:addChild(icon, 1)
            if type(v.extend) == "string" then
            	G_addRectFlicker2(icon, 1.15, 1.15, 1, v.extend, nil, 10)
        	end
        	local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
            cell:addChild(numBg, 1)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            cell:addChild(numLb, 1)
		end
    end
    local cellReward
    local moLevel = militaryOrdersVoApi:getMilitaryOrdersLv()
	if self.honourReward and self.honourReward[index] and self.honourReward[index].reward then
		local rewardTb = FormatItem(self.honourReward[index].reward, nil, true)
		if rewardTb then
			showRewardUI(rewardTb, 2)
			if unlockData == nil and index <= moLevel and militaryOrdersVoApi:isActivate() == true and militaryOrdersVoApi:isGetRewardOfLv(2, index) == false then
				if cellReward == nil then
					cellReward = {}
				end
				cellReward[2] = rewardTb
			end
		end
	end
	if self.normalReward and self.normalReward[index] and self.normalReward[index].reward then
		local rewardTb = FormatItem(self.normalReward[index].reward, nil, true)
		if rewardTb then
			showRewardUI(rewardTb, 1)
			if unlockData == nil and index <= moLevel and militaryOrdersVoApi:isGetRewardOfLv(1, index) == false then
				if cellReward == nil then
					cellReward = {}
				end
				cellReward[1] = rewardTb
			end
		end
	end
	if cellReward then
		if self.canGetAllReward == nil then
			self.canGetAllReward = {}
		end
		table.insert(self.canGetAllReward, {level = index, reward = cellReward})
	end
	local lvBg = CCSprite:createWithSpriteFrameName("military_lvicon.png")
	lvBg:setPosition(cellSize.width / 2, cellSize.height / 2 + 20)
	cell:addChild(lvBg, 2)
	if index > moLevel then
		local lockSp = CCSprite:createWithSpriteFrameName("military_lvlock.png")
		lockSp:setPosition(getCenterPoint(lvBg))
		lvBg:addChild(lockSp, 3)
	end
	-- local lvLabel = GetBMLabel(tostring(index), "public/military_num.fnt", 22)
	local lvLabel = GetTTFLabel(tostring(index), 22, true)
	lvLabel:setPosition(lvBg:getContentSize().width / 2, lvBg:getContentSize().height / 2)
	lvBg:addChild(lvLabel)
	if unlockData or idx <= moLevel then
		local isShowButton
		if unlockData == nil and idx ~= moLevel then
			if militaryOrdersVoApi:isActivate() == true and militaryOrdersVoApi:isGetRewardOfLv(2, index) == false then
				isShowButton = true
			elseif militaryOrdersVoApi:isGetRewardOfLv(1, index) == false then
				isShowButton = true
			end
		else
			if unlockData and moLevel == self.tvCellNum then
				isShowButton = false
			else
				isShowButton = true
			end
		end
		if isShowButton == true then
	    	local function onClickButtonHandler(tag, obj)
	    		if G_checkClickEnable() == false then
		            do return end
		        else
		            base.setWaitTime = G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        if unlockData or idx == moLevel then
		        	if militaryOrdersVoApi:isActivate() == true then
		        		local paramsTb = (unlockData or militaryOrdersVoApi:getUnlockData())
		        		militaryOrdersVoApi:showUnlockSmallDialog(self.layerNum + 1, paramsTb, function(unlockToLv, unlockType, costGold)
		        			print("cjl -------->>> 解锁至:" .. unlockToLv .. "级")
		        			militaryOrdersVoApi:requestUnlock(function()
		        				playerVoApi:setGems(playerVoApi:getGems() - costGold)
		        				if tolua.cast(self.cruLvNumLb, "CCLabelTTF") then
		        					self.cruLvNumLb:setString(militaryOrdersVoApi:getMilitaryOrdersLv())
		        				end
		        				-- self:refreshRewardTv(true)
		        				self:unlockRefreshRewardTvCell(moLevel, unlockToLv)
		        			end, unlockType)
		        		end)
		        	else
		        		G_showTipsDialog(getlocal("militaryOrders_activateTips"))
		        	end
		        else
		        	print("cjl -------->>> 领取")
		        	militaryOrdersVoApi:requestReward(function()
		        		if cellReward then
		        			local isHasNewPrivilege
		        			local reward = {}
		        			for i = 1, 2 do
		        				if cellReward[i] then
		        					for k, v in pairs(cellReward[i]) do
		        						if tonumber(v.id) and v.id >= 5040 and v.id <= 5045 then --特权钥匙不进背包
		        							isHasNewPrivilege = true
		        						else
			        						G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
						                    if v.type == "h" then --添加将领魂魄
						                        if v.key and string.sub(v.key, 1, 1) == "s" then
						                            heroVoApi:addSoul(v.key, tonumber(v.num))
						                        end
						                    end
						                    table.insert(reward, v)
						                end
		        					end
		        				end
		        			end
		                    G_showRewardTip(reward)
		                    if isHasNewPrivilege == true then
		                    	G_showTipsDialog(getlocal("militaryOrders_unlockNewPrivilegeTips"))
		                    	militaryOrdersVoApi:setNewPrivilegeStatus(isHasNewPrivilege)
			                	if tolua.cast(self.tipsIcon, "CCSprite") then
			                		self.tipsIcon:setVisible(militaryOrdersVoApi:isHasNewPrivilege())
			                	end
		                    end
	                	end
		        		-- self:refreshRewardTv()
		        		if self.canGetAllReward then
			        		for k, v in pairs(self.canGetAllReward) do
								if v.level == idx + 1 then
									table.remove(self.canGetAllReward, k)
									break
								end
							end
							if self.allGetBtn then
								local enabledFlag = (SizeOfTable(self.canGetAllReward) > 1)
							    self.allGetBtn:setEnabled(enabledFlag)
							    self.allGetBtn:setVisible(enabledFlag)
							end
						end
		        		cell:removeAllChildrenWithCleanup(true)
		        		self:rewardTvView(cell, cellSize, idx, cellNum)
		        	end, index)
		        end
	    	end
	    	local btnStr = getlocal("daily_scene_get")
	    	local btnPic1, btnPic2 = "newGreenBtn.png", "newGreenBtn_down.png"
	    	if unlockData or idx == moLevel then
	    		if unlockData then
	    			btnStr = getlocal("militaryOrders_unlockOfAll")
	    		else
	    			btnStr = getlocal("activity_fbReward_unlock")
	    		end
	    		btnPic1, btnPic2 = "creatRoleBtn.png", "creatRoleBtn_Down.png"
	    	else
	    		local lightEffectSp = CCSprite:createWithSpriteFrameName("moi_lightEffect.png")
	    		lightEffectSp:setAnchorPoint(ccp(1, 0.5))
	    		lightEffectSp:setScaleX(cellSize.width * 0.5 / lightEffectSp:getContentSize().width)
	    		lightEffectSp:setScaleY((cellSize.height - 5) / lightEffectSp:getContentSize().height)
	    		lightEffectSp:setPosition(0, cellSize.height / 2)
	    		lightEffectSp:setOpacity(100)
	    		cell:addChild(lightEffectSp)
	    		local seq = CCSequence:createWithTwoActions(CCMoveBy:create(2, ccp(cellSize.width + lightEffectSp:getContentSize().width * lightEffectSp:getScaleX(), 0)), CCCallFunc:create(function() lightEffectSp:setPositionX(0) end))
	    		lightEffectSp:runAction(CCRepeatForever:create(seq))
	    	end
	    	local btnScale = 0.45
	    	local button = GetButtonItem(btnPic1, btnPic2, btnPic1, onClickButtonHandler, nil, btnStr, (G_isAsia() == false and 16 or 20) / btnScale)
	    	local btnMenu = CCMenu:createWithItem(button)
	    	btnMenu:setPosition(0, 0)
	    	btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - (unlockData and 4 or 2))
	    	cell:addChild(btnMenu, 2)
	    	button:setScale(btnScale)
	    	button:setAnchorPoint(ccp(0.5, 1))
	    	button:setPosition(cellSize.width / 2, cellSize.height / 2 - 15)
	    end
    end
    local rewardedFlag1 = militaryOrdersVoApi:isGetRewardOfLv(1, index)
    local rewardedFlag2 = militaryOrdersVoApi:isGetRewardOfLv(2, index)
    if unlockData == nil and (militaryOrdersVoApi:isActivate() == false or index > moLevel or rewardedFlag1 == true or rewardedFlag2 == true) then
    	local shadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("military_blackbg.png", CCRect(16, 16, 2, 2), function() end)
    	shadeBg:setAnchorPoint(ccp(0, 0))
    	local shadePos = ccp(0, 0)
    	local shadeBgWidth = cellSize.width
    	if militaryOrdersVoApi:isActivate() == false and index <= moLevel and rewardedFlag1 == false then
    		shadeBgWidth = cellSize.width / 2
    	elseif militaryOrdersVoApi:isActivate() == true and rewardedFlag1 == true and rewardedFlag2 == false then
    		shadeBgWidth = cellSize.width / 2
    		shadePos = ccp(cellSize.width / 2, 0)
    	end
    	shadeBg:setContentSize(CCSizeMake(shadeBgWidth, cellSize.height))
    	shadeBg:setPosition(0, 0)
	    cell:addChild(shadeBg, 1)
    end
    if rewardedFlag1 == true or rewardedFlag2 == true then
    	local rewardedBtn = CCSprite:createWithSpriteFrameName("military_getbg.png")
    	cell:addChild(rewardedBtn, 10)
    	if rewardedFlag1 == true and rewardedFlag2 == false then
    		rewardedBtn:setPosition(cellSize.width - cellSize.width / 4, cellSize.height / 2)
    	else
    		rewardedBtn:setPosition(cellSize.width * 0.5, cellSize.height / 2)
    	end
    	local rewardedLb = GetTTFLabel(getlocal("activity_hadReward"), 16)
    	rewardedLb:setColor(G_ColorGreen)
    	rewardedLb:setPosition(rewardedBtn:getContentSize().width / 2,rewardedBtn:getContentSize().height/2 - 2)
    	rewardedBtn:addChild(rewardedLb)
    end
	if unlockData == nil then
		if self.rewardTvCellTb == nil then
			self.rewardTvCellTb = {}
		end
		self.rewardTvCellTb[index] = {cell, cellSize, idx, cellNum}
	end
end

function militaryOrdersDialog:overDayEvent()
	local resetTimer = militaryOrdersVoApi:getResetTimer()
	militaryOrdersVoApi:requestData(function()
		self.dayTask = militaryOrdersVoApi:getDayTask()
		if self.taskTv then
			self.taskTv:reloadData()
		end
		if resetTimer ~= militaryOrdersVoApi:getResetTimer() then --跨月
			militaryOrdersVoApi:setMainUIIconStatus()
			if tolua.cast(self.cruLvNumLb, "CCLabelTTF") then
				self.cruLvNumLb:setString(militaryOrdersVoApi:getMilitaryOrdersLv())
			end
			if tolua.cast(self.lockSp, "CCSprite") then
				self.lockSp:setVisible(militaryOrdersVoApi:isActivate() == false)
			end
			self.tvCellNum, self.normalReward, self.honourReward = militaryOrdersVoApi:getRewardData()
			self:refreshRewardTv(true, true)
			if tolua.cast(self.activateBtnLabel, "CCLabelTTF") then
				self.activateBtnLabel:setString(militaryOrdersVoApi:isActivate() and getlocal("militaryOrders_privilegeTitle") or getlocal("militaryOrders_activate"))
			end
			militaryOrdersVoApi:setNewPrivilegeStatus(false)
        	if tolua.cast(self.tipsIcon, "CCSprite") then
        		self.tipsIcon:setVisible(militaryOrdersVoApi:isHasNewPrivilege())
        	end
        	eventDispatcher:dispatchEvent("military.overmonth",{})
		end
	end)
end

function militaryOrdersDialog:tick()
	if self then
		if tolua.cast(self.timeLb, "CCLabelTTF") then
			self.timeLb:setString(getlocal("acCD") .. "：" .. G_formatActiveDate(militaryOrdersVoApi:getEndTime() - base.serverTime))
		end
	end
end

function militaryOrdersDialog:dispose()
	if self.activateCardPushListener then
		eventDispatcher:removeEventListener("user.pay.push",self.activateCardPushListener)
		self.activateCardPushListener = nil
	end
	self = nil
	spriteController:removePlist("public/acCustomImage.plist")
    spriteController:removeTexture("public/acCustomImage.png")
    -- spriteController:removePlist("public/accessoryImage.plist")
    -- spriteController:removePlist("public/accessoryImage2.plist")
    spriteController:removePlist("public/blueFilcker.plist")
	spriteController:removePlist("public/greenFlicker.plist")
	spriteController:removePlist("public/purpleFlicker.plist")
	spriteController:removePlist("public/yellowFlicker.plist")
	spriteController:removePlist("public/redFlicker.plist")
end