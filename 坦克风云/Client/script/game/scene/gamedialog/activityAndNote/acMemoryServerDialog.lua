acMemoryServerDialog = commonDialog:new()

function acMemoryServerDialog:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	G_addResource8888(function()
        spriteController:addPlist("public/acMemoryServerImage.plist")
        spriteController:addTexture("public/acMemoryServerImage.png")
    end)
	return nc
end

function acMemoryServerDialog:resetTab()
	if G_isMemoryServer() then
		self.panelLineBg:setVisible(false)
	    self.panelTopLine:setVisible(true)
	    self.panelShadeBg:setVisible(true)

	    require "luascript/script/game/scene/gamedialog/activityAndNote/acMemoryServerTabOne"
	    require "luascript/script/game/scene/gamedialog/activityAndNote/acMemoryServerTabTwo"
	    self.tabObj = { acMemoryServerTabOne, acMemoryServerTabTwo }
    	self.tabNum = SizeOfTable(self.tabObj)

	    local index = 0
	    local tabBtnItemSpaceX = 3
	    for k, tabBtnItem in pairs(self.allTabs) do
	        local btnItemFirstPosX = (G_VisibleSizeWidth - (tabBtnItem:getContentSize().width * self.tabNum + tabBtnItemSpaceX * (self.tabNum - 1))) / 2 + (tabBtnItem:getContentSize().width / 2)
	        local btnItemPosY = G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 80
	        tabBtnItem:setPosition(btnItemFirstPosX + index * (tabBtnItem:getContentSize().width + tabBtnItemSpaceX), btnItemPosY)
	        if index == self.selectedTabIndex then
	            tabBtnItem:setEnabled(false)
	        end
	        index = index + 1
	    end
	    self.selectedTabIndex = 0
	else
		self.panelLineBg:setVisible(false)
	    self.panelTopLine:setVisible(false)
	    self.panelShadeBg:setVisible(true)
	end
	local bgColor = CCLayerColor:create(ccc4(9, 14, 19, 255))
	bgColor:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85))
	self.bgLayer:addChild(bgColor)
end

function acMemoryServerDialog:initTableView()
	acMemoryServerVoApi:requestInitData(function()
		if self then
			if G_isMemoryServer() then
				if self.tabNum then
		            for i = 1, self.tabNum do
		                if self["tab" .. i] and type(self["tab" .. i].responseInitData) == "function" then
		                    self["tab" .. i]:responseInitData()
		                end
		            end
		        end
		    else
	        	self:showBindInfoUI()
	        	if self.taskTv then
					self.taskTv:reloadData()
				end
	        end
    	end
	end)

	if G_isMemoryServer() then
		self:tabClick(0)
	else
		self:showOldServerUI()
	end
end

function acMemoryServerDialog:showOldServerUI()
	local topBg
    G_addResource8888(function() topBg = CCSprite:create("public/acMemoryServerBg.jpg") end)
    topBg:setAnchorPoint(ccp(0.5, 1))
    topBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85))
    self.bgLayer:addChild(topBg)

    local rewardTipsLb = GetTTFLabelWrap(getlocal("acMemoryServer_maxRewardNumTips"), 20, CCSizeMake(280, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    rewardTipsLb:setAnchorPoint(ccp(0, 1))
    rewardTipsLb:setPosition(ccp(15, topBg:getContentSize().height - 15))
    topBg:addChild(rewardTipsLb)
    local rewardGoldSp = CCSprite:createWithSpriteFrameName("iconGoldNew3.png")
    rewardGoldSp:setAnchorPoint(ccp(1, 0))
    rewardGoldSp:setPosition(ccp(430, topBg:getContentSize().height - 85))
    topBg:addChild(rewardGoldSp)
    local rewardNumLb = GetBMLabel(tostring(acMemoryServerVoApi:getMaxRewardGoldNum()), G_vrorangenumber, 30)
    rewardNumLb:setAnchorPoint(ccp(1, 0))
    rewardNumLb:setPosition(ccp(rewardGoldSp:getPositionX() - rewardGoldSp:getContentSize().width, rewardGoldSp:getPositionY() + rewardNumLb:getContentSize().height / 2))
    topBg:addChild(rewardNumLb)

    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("acMemoryServer_i_desc1", {acMemoryServerVoApi:getBindLimitLevel()}),
            getlocal("acMemoryServer_i_desc2"),
            getlocal("acMemoryServer_i_desc3"),
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(topBg:getContentSize().width - 20, topBg:getContentSize().height - 20))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    topBg:addChild(infoMenu)

    local function onClickButton(tag, obj)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        G_showSureAndCancle(getlocal("acMemoryServer_sureEnterMemoryServerTips"), function()
        	require "luascript/script/game/scene/gamedialog/settingsDialog/serverListDialog"
        	local td = serverListDialog:new()
	        local tbArr = {getlocal("recentLogin"), getlocal("allServers")}
	        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverListOpt"), false, self.layerNum + 1)
	        sceneGame:addChild(dialog, self.layerNum + 1)
        end)
    end
    local button = GetButtonItem("acMS_yellowBtn.png", "acMS_yellowBtn_down.png", "acMS_yellowBtn.png", onClickButton, 11, getlocal("acMemoryServer_gotoMemoryServer"), 22, 10)
    local buttonLb = tolua.cast(button:getChildByTag(10), "CCLabelTTF")
    if buttonLb then
    	buttonLb:setColor(G_ColorBlack)
    end
    local btnMenu = CCMenu:createWithItem(button)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 1)
    topBg:addChild(btnMenu)
    button:setAnchorPoint(ccp(1, 0))
	button:setPosition(ccp(topBg:getContentSize().width - 10, 35))
	local noteTipsLb = GetTTFLabelWrap(getlocal("acMemoryServer_noteTips"), 22, CCSizeMake(button:getPositionX() - button:getContentSize().width - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	noteTipsLb:setAnchorPoint(ccp(0, 0.5))
	noteTipsLb:setPosition(ccp(15, 85))
	noteTipsLb:setColor(G_ColorYellowPro2)
	topBg:addChild(noteTipsLb)

	local bindTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_listTitleBg.png", CCRect(15, 15, 4, 4), function()end)
	bindTitleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, bindTitleBg:getContentSize().height))
	bindTitleBg:setAnchorPoint(ccp(0.5, 1))
	bindTitleBg:setPosition(ccp(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height))
	self.bgLayer:addChild(bindTitleBg)
	local bindTitleLb = GetTTFLabel(getlocal("acMemoryServer_bindInfo"), 20)
	bindTitleLb:setColor(G_ColorYellowPro)
	bindTitleLb:setAnchorPoint(ccp(0.5, 1))
	bindTitleLb:setPosition(ccp(bindTitleBg:getContentSize().width / 2, bindTitleBg:getContentSize().height - 5))
	bindTitleBg:addChild(bindTitleLb)
	local bindCellBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
	bindCellBg:setContentSize(CCSizeMake(bindTitleBg:getContentSize().width, 55))
	bindCellBg:setAnchorPoint(ccp(0.5, 1))
	bindCellBg:setPosition(ccp(bindTitleBg:getPositionX(), bindTitleBg:getPositionY() - bindTitleBg:getContentSize().height))
	self.bgLayer:addChild(bindCellBg)

	if acMemoryServerVoApi:isBind() then
		self.bindCellBgNode = CCNode:create()
		self.bindCellBgNode:setContentSize(bindCellBg:getContentSize())
		self.bindCellBgNode:setAnchorPoint(ccp(0, 0))
		self.bindCellBgNode:setPosition(ccp(0, 0))
		bindCellBg:addChild(self.bindCellBgNode)
		self:showBindInfoUI()
	else
		local notBindTipsLb = GetTTFLabelWrap(getlocal("acMemoryServer_notBindNewSoldiersTips1"), 22, CCSizeMake(bindCellBg:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		notBindTipsLb:setPosition(ccp(bindCellBg:getContentSize().width / 2, bindCellBg:getContentSize().height / 2))
		bindCellBg:addChild(notBindTipsLb)
		local shadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
		shadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bindCellBg:getPositionY() - bindCellBg:getContentSize().height - 30))
		shadeBg:setAnchorPoint(ccp(0.5, 1))
		shadeBg:setPosition(ccp(G_VisibleSizeWidth / 2, bindCellBg:getPositionY() - bindCellBg:getContentSize().height - 30))
		shadeBg:setTouchPriority( - (self.layerNum - 1) * 20 - 5)
		shadeBg:setOpacity(255 * 0.85)
		self.bgLayer:addChild(shadeBg, 1)
		local shadeTipsLb = GetTTFLabelWrap(getlocal("acMemoryServer_notBindNewSoldiersTips2"), 25, CCSizeMake(shadeBg:getContentSize().width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
		shadeTipsLb:setPosition(ccp(shadeBg:getContentSize().width / 2, shadeBg:getContentSize().height * 0.73))
		shadeTipsLb:setColor(G_ColorYellowPro2)
		shadeBg:addChild(shadeTipsLb)
	end

	local taskTvTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_listTitleBg.png", CCRect(15, 15, 4, 4), function()end)
	taskTvTitleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, taskTvTitleBg:getContentSize().height))
	taskTvTitleBg:setAnchorPoint(ccp(0.5, 1))
	taskTvTitleBg:setPosition(ccp(G_VisibleSizeWidth / 2, bindCellBg:getPositionY() - bindCellBg:getContentSize().height - 30))
	self.bgLayer:addChild(taskTvTitleBg)
	local taskTvTitleLb = GetTTFLabel(getlocal("acMemoryServer_memoryTask"), 20)
	taskTvTitleLb:setColor(G_ColorYellowPro)
	taskTvTitleLb:setAnchorPoint(ccp(0.5, 1))
	taskTvTitleLb:setPosition(ccp(taskTvTitleBg:getContentSize().width / 2, taskTvTitleBg:getContentSize().height - 5))
	taskTvTitleBg:addChild(taskTvTitleLb)

	self.taskList = acMemoryServerVoApi:getTaskList(2)
	local taskTvSize = CCSizeMake(taskTvTitleBg:getContentSize().width, taskTvTitleBg:getPositionY() - taskTvTitleBg:getContentSize().height - 20)
	local taskTv = G_createTableView(taskTvSize, SizeOfTable(self.taskList), CCSizeMake(taskTvSize.width, 165), function(...) self:showTaskTvCell(...) end)
    taskTv:setPosition(ccp((G_VisibleSizeWidth - taskTvSize.width) / 2, 20))
    taskTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    -- taskTv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(taskTv)
    self.taskTv = taskTv
end

function acMemoryServerDialog:showBindInfoUI()
	if self and tolua.cast(self.bindCellBgNode, "CCNode") then
		local bindCellBg = tolua.cast(self.bindCellBgNode, "CCNode")
		bindCellBg:removeAllChildrenWithCleanup(true)
		local bindLb = GetTTFLabel(getlocal("accessory_bindOver"), 22)
		bindLb:setAnchorPoint(ccp(1, 0.5))
		bindLb:setPosition(ccp(bindCellBg:getContentSize().width - 15, bindCellBg:getContentSize().height / 2))
		bindLb:setColor(G_ColorGreen)
		bindCellBg:addChild(bindLb)
		local playerData = acMemoryServerVoApi:getBindPlayerData()
		if playerData then
			local vipLevelSp = CCSprite:createWithSpriteFrameName("Vip" .. playerData.vip .. ".png")
			vipLevelSp:setScale((bindCellBg:getContentSize().height - 8) / vipLevelSp:getContentSize().height)
			vipLevelSp:setPosition(ccp(bindCellBg:getContentSize().width * 0.7, bindCellBg:getContentSize().height / 2))
			bindCellBg:addChild(vipLevelSp)
			local playerLevelLb = GetTTFLabel(getlocal("fightLevel", {playerData.level}), 22)
			playerLevelLb:setPosition(ccp(bindCellBg:getContentSize().width * 0.46, bindCellBg:getContentSize().height / 2))
			bindCellBg:addChild(playerLevelLb)
			local bindPlayerSerName = acMemoryServerVoApi:getBindPlayerServerName()
			local playerNameLb = GetTTFLabel(bindPlayerSerName .. "-" .. playerData.nickname, 22)
			playerNameLb:setAnchorPoint(ccp(0, 0.5))
			playerNameLb:setPosition(ccp(15, bindCellBg:getContentSize().height / 2))
			bindCellBg:addChild(playerNameLb)
		end
	end
end

function acMemoryServerDialog:showTaskTvCell(cell, cellSize, idx, cellNum)
	local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
	cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 4))
	cellBg:setAnchorPoint(ccp(0.5, 1))
	cellBg:setPosition(ccp(cellSize.width / 2, cellSize.height))
	cell:addChild(cellBg)
	local cellTitleTitleBg = CCSprite:createWithSpriteFrameName("acMS_cellTitleBg2.png")
	cellTitleTitleBg:setAnchorPoint(ccp(0, 1))
	cellTitleTitleBg:setPosition(ccp(3, cellBg:getContentSize().height - 4))
	cellBg:addChild(cellTitleTitleBg)
	local oldSoldiersLb = GetTTFLabel(getlocal("acMemoryServer_oldSoldiers"), 18)
	oldSoldiersLb:setAnchorPoint(ccp(0, 0))
	oldSoldiersLb:setPosition(ccp(20, cellTitleTitleBg:getContentSize().height / 2 + 5))
	cellTitleTitleBg:addChild(oldSoldiersLb)
	local newSoldiersLb = GetTTFLabel(getlocal("acMemoryServer_newSoldiers"), 18)
	newSoldiersLb:setAnchorPoint(ccp(0, 1))
	newSoldiersLb:setPosition(ccp(10, cellTitleTitleBg:getContentSize().height / 2 - 5))
	cellTitleTitleBg:addChild(newSoldiersLb)

	local data = self.taskList[idx + 1]
	if data then
		local taskId = data.tsk
		local taskKey = data.key
		local completeNum = acMemoryServerVoApi:getTaskCompleteNum(taskKey, 2)
		local totalNum = SizeOfTable(data.num)
		local taskIndex = (completeNum == totalNum) and completeNum or (completeNum + 1)
		local needNumTb = (data.num[taskIndex] or data.num[totalNum])
		local oldCurNum, oldNeedNum = acMemoryServerVoApi:getTaskCurNum(taskKey, true), needNumTb[2]
        local oldStr = acMemoryServerVoApi:getTaskDesc(taskKey, oldCurNum, oldNeedNum, data.quality)
        local newCurNum, newNeedNum = acMemoryServerVoApi:getTaskCurNum(taskKey, false), needNumTb[1]
        local newStr = acMemoryServerVoApi:getTaskDesc(taskKey, newCurNum, newNeedNum, data.quality)
        local oldDescLb = GetTTFLabelWrap(oldStr, 16, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        if oldCurNum >= oldNeedNum then
        	oldDescLb:setColor(G_ColorGreen)
        end
        oldDescLb:setAnchorPoint(ccp(0, 0))
        oldDescLb:setPosition(ccp(oldSoldiersLb:getPositionX() + oldSoldiersLb:getContentSize().width + 30, oldSoldiersLb:getPositionY()))
        cellTitleTitleBg:addChild(oldDescLb)
        local newDescLb = GetTTFLabelWrap(newStr, 16, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        if newCurNum >= newNeedNum then
        	newDescLb:setColor(G_ColorGreen)
        end
        newDescLb:setAnchorPoint(ccp(0, 1))
        newDescLb:setPosition(ccp(newSoldiersLb:getPositionX() + newSoldiersLb:getContentSize().width + 30, newSoldiersLb:getPositionY()))
        cellTitleTitleBg:addChild(newDescLb)
        local taskNumLb = GetTTFLabelWrap(getlocal("acMemoryServer_taskNum", {completeNum, totalNum}), 18, CCSizeMake(180, 0), kCCTextAlignmentRight, kCCVerticalTextAlignmentTop)
        taskNumLb:setAnchorPoint(ccp(1, 1))
        taskNumLb:setPosition(ccp(cellBg:getContentSize().width - 5, cellBg:getContentSize().height - 8))
        cellBg:addChild(taskNumLb)
        local taskReward = acMemoryServerVoApi:getTaskReward(2, taskKey, taskIndex)
        if taskReward then
        	local iconSize = 70
        	local iconSpaceX = 20
        	local firstIconPosX = 30
        	for k, v in pairs(taskReward) do
        		local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, function()
        			if v.type == "at" and v.eType == "a" then --AI部队
			            local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
			            AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
			        else
			            G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
			        end
        		end)
	            icon:setScale(iconSize / icon:getContentSize().height)
	            scale = icon:getScale()
	            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	            icon:setPosition(firstIconPosX + (k - 1) * (iconSize + iconSpaceX) + iconSize / 2, (cellTitleTitleBg:getPositionY() - cellTitleTitleBg:getContentSize().height) / 2)
	            cellBg:addChild(icon, 1)
	        	local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 18)
	            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
	            numBg:setAnchorPoint(ccp(0, 1))
	            numBg:setRotation(180)
	            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
	            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
	            numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
	            cellBg:addChild(numBg, 1)
	            numLb:setAnchorPoint(ccp(1, 0))
	            numLb:setPosition(numBg:getPosition())
	            cellBg:addChild(numLb, 1)
        	end
        end
        if (oldCurNum >= oldNeedNum and newCurNum >= newNeedNum) or (completeNum == totalNum) then
        	local lbStr
        	if completeNum == totalNum then --已完成
        		lbStr = getlocal("activity_hadReward")
        	else
        		lbStr = getlocal("acMemoryServer_gotoMemoryServerReward")
        	end
        	local accomplishLb = GetTTFLabelWrap(lbStr, 22, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        	accomplishLb:setAnchorPoint(ccp(1, 0.5))
        	accomplishLb:setPosition(ccp(cellBg:getContentSize().width - 20, (cellTitleTitleBg:getPositionY() - cellTitleTitleBg:getContentSize().height) / 2))
        	cellBg:addChild(accomplishLb)
        else
	        local function onClickJump(tag, obj)
	        	if G_checkClickEnable() == false then
		            do return end
		        else
		            base.setWaitTime = G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        acMemoryServerVoApi:taskJumpTo(taskKey)
	        end
	        local jumpBtn = GetButtonItem("yh_taskGoto.png", "yh_taskGoto_down.png", "yh_taskGoto.png", onClickJump)
	        local jumpMenu = CCMenu:createWithItem(jumpBtn)
	        jumpMenu:setPosition(ccp(0, 0))
	        jumpMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	        cellBg:addChild(jumpMenu)
	        jumpBtn:setAnchorPoint(ccp(1, 0.5))
	        jumpBtn:setPosition(ccp(cellBg:getContentSize().width - 20, (cellTitleTitleBg:getPositionY() - cellTitleTitleBg:getContentSize().height) / 2))
	    end
    end
end

function acMemoryServerDialog:tabClick(idx)
	if idx == 1 and acMemoryServerVoApi:isBind() == false then
		for k, v in pairs(self.allTabs) do
			local tabLb = tolua.cast(v:getChildByTag(31), "CCLabelTTF")
			if v:getTag() == idx then
				v:setEnabled(true)
				if tabLb then
					tabLb:setColor(G_TabLBColorGreen)
				end
			else
				v:setEnabled(false)
				if tabLb then
					tabLb:setColor(G_ColorWhite)
				end
			end
		end
		G_showTipsDialog(getlocal("acMemoryServer_pleaseBindTips"))
		do return end
	end
	for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
        else
        	v:setEnabled(true)
        end
    end
    local tabIndex = idx + 1
    if self["tab" .. tabIndex] == nil then
        local tab = self.tabObj[tabIndex]:new(self.layerNum)
        self["tab" .. tabIndex] = tab
        self["layerTab" .. tabIndex] = tab:init()
        self.bgLayer:addChild(self["layerTab" .. tabIndex], 1)
    end
    for i = 1, self.tabNum do
        local tabPos = ccp(999333, 0)
        local tabVisible = false
        if i == tabIndex then
            tabPos = ccp(0, 0)
            tabVisible = true
        end
        if self["layerTab" .. i] ~= nil then
            self["layerTab" .. i]:setPosition(tabPos)
            self["layerTab" .. i]:setVisible(tabVisible)
        end
    end
end

function acMemoryServerDialog:tick()
	if self then
        local vo = acMemoryServerVoApi:getAcVo()
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        else
        	if self.tabNum then
	            for i = 1, self.tabNum do
	                if self["tab" .. i] and type(self["tab" .. i].tick) == "function" then
	                    self["tab" .. i]:tick()
	                end
	            end
	        end
        end
    end
end

function acMemoryServerDialog:dispose()
	if self.tabNum then
		for i = 1, self.tabNum do
	        if self["tab" .. i] and type(self["tab" .. i].dispose) == "function" then
	            self["tab" .. i]:dispose()
	        end
	        self["layerTab" .. i] = nil
	        self["tab" .. i] = nil
	    end
	end
	self = nil
	spriteController:removePlist("public/acMemoryServerImage.plist")
    spriteController:removeTexture("public/acMemoryServerImage.png")
end