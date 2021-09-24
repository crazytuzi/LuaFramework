acMemoryServerTabTwo = {}

function acMemoryServerTabTwo:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	return nc
end

function acMemoryServerTabTwo:init()
	self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function acMemoryServerTabTwo:initUI()
	local topInfoBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
	topInfoBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 180))
	topInfoBgSp:setAnchorPoint(ccp(0.5, 1))
	topInfoBgSp:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 165))
	self.bgLayer:addChild(topInfoBgSp)
	local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("acMemoryServer_i_tab1Desc1", {acMemoryServerVoApi:getBindLimitLevel()}),
            getlocal("acMemoryServer_i_tab1Desc2"),
            getlocal("acMemoryServer_i_tab1Desc3"),
            getlocal("acMemoryServer_i_tab1Desc4"),
            getlocal("acMemoryServer_i_tab1Desc5"),
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(topInfoBgSp:getContentSize().width - 10, topInfoBgSp:getContentSize().height - 10))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    topInfoBgSp:addChild(infoMenu)
    local topContentBg = CCNode:create()
    topContentBg:setContentSize(topInfoBgSp:getContentSize())
    topContentBg:setAnchorPoint(topInfoBgSp:getAnchorPoint())
    topContentBg:setPosition(ccp(topInfoBgSp:getPosition()))
    self.bgLayer:addChild(topContentBg)
    self.topContentBg = topContentBg

    self:showBindInfoUI()

    self.taskList = acMemoryServerVoApi:getTaskList(2)
	local taskTvSize = CCSizeMake(topContentBg:getContentSize().width, topContentBg:getPositionY() - topContentBg:getContentSize().height - 35)
	local taskTv = G_createTableView(taskTvSize, SizeOfTable(self.taskList), CCSizeMake(taskTvSize.width, 169), function(...) self:showTaskTvCell(...) end)
    taskTv:setPosition(ccp((G_VisibleSizeWidth - taskTvSize.width) / 2, 20))
    taskTv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    -- taskTv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(taskTv)
    self.taskTv = taskTv
end

function acMemoryServerTabTwo:responseInitData()
	self:showBindInfoUI()
	if self.taskTv then
		self.taskTv:reloadData()
	end
end

function acMemoryServerTabTwo:showBindInfoUI()
	if self and tolua.cast(self.topContentBg, "CCNode") then
		local topContentBg = tolua.cast(self.topContentBg, "CCNode")
		topContentBg:removeAllChildrenWithCleanup(true)
		local bindLb = GetTTFLabel(getlocal("accessory_bindOver"), 22)
		bindLb:setAnchorPoint(ccp(1, 0))
		bindLb:setPosition(ccp(topContentBg:getContentSize().width - 15, 15))
		bindLb:setColor(G_ColorGreen)
		topContentBg:addChild(bindLb)
		local playerData = acMemoryServerVoApi:getBindPlayerData()
		if playerData then
			local playerIcon = playerVoApi:GetPlayerBgIcon(playerVoApi:getPersonPhotoName(playerData.pic), nil, nil, nil, topContentBg:getContentSize().height - 60, playerData.hfid or headFrameCfg.default)
			playerIcon:setAnchorPoint(ccp(0, 0.5))
			playerIcon:setPosition(ccp(20, topContentBg:getContentSize().height / 2))
			topContentBg:addChild(playerIcon)
			local bindPlayerSerName = acMemoryServerVoApi:getBindPlayerServerName()
			local playerNameLbWidth = topContentBg:getContentSize().width - (playerIcon:getPositionX() + playerIcon:getContentSize().width * playerIcon:getScale() + 20) - 80
			local playerNameLb = GetTTFLabelWrap(bindPlayerSerName .. "-" .. playerData.nickname, 24, CCSizeMake(playerNameLbWidth, 0), kCCTextAlignmentLeft, kCCTextAlignmentCenter)
			local playerLevelLb = GetTTFLabel(getlocal("fightLevel", {playerData.level}), 24)
			local vipLevelSp = CCSprite:createWithSpriteFrameName("Vip" .. playerData.vip .. ".png")
			local bottomStartPosY = (topContentBg:getContentSize().height - (playerNameLb:getContentSize().height + 5 + playerLevelLb:getContentSize().height + 3 + vipLevelSp:getContentSize().height)) / 2
			vipLevelSp:setAnchorPoint(ccp(0, 0))
			vipLevelSp:setPosition(ccp(playerIcon:getPositionX() + playerIcon:getContentSize().width * playerIcon:getScale() + 15, bottomStartPosY))
			topContentBg:addChild(vipLevelSp)
			playerLevelLb:setAnchorPoint(ccp(0, 0))
			playerLevelLb:setPosition(ccp(vipLevelSp:getPositionX() + 5, vipLevelSp:getPositionY() + vipLevelSp:getContentSize().height + 3))
			topContentBg:addChild(playerLevelLb)
			playerNameLb:setAnchorPoint(ccp(0, 0))
			playerNameLb:setPosition(ccp(playerLevelLb:getPositionX(), playerLevelLb:getPositionY() + playerLevelLb:getContentSize().height + 5))
			topContentBg:addChild(playerNameLb)
		end
	end
end

function acMemoryServerTabTwo:showTaskTvCell(cell, cellSize, idx, cellNum)
	local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("acMS_cellBg.png", CCRect(4, 4, 2, 2), function()end)
	cellBg:setContentSize(CCSizeMake(cellSize.width, cellSize.height - 8))
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
		local oldCurNum, oldNeedNum = acMemoryServerVoApi:getTaskCurNum(taskKey, false), needNumTb[2]
        local oldStr = acMemoryServerVoApi:getTaskDesc(taskKey, oldCurNum, oldNeedNum, data.quality)
        local newCurNum, newNeedNum = acMemoryServerVoApi:getTaskCurNum(taskKey, true), needNumTb[1]
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
        if completeNum == totalNum then --已完成
        	local accomplishLb = GetTTFLabelWrap(getlocal("activity_hadReward"), 22, CCSizeMake(120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        	accomplishLb:setAnchorPoint(ccp(1, 0.5))
        	accomplishLb:setPosition(ccp(cellBg:getContentSize().width - 20, (cellTitleTitleBg:getPositionY() - cellTitleTitleBg:getContentSize().height) / 2))
        	cellBg:addChild(accomplishLb)
        else
        	local function onClickCellBtn(tag, obj)
        		if G_checkClickEnable() == false then
		            do return end
		        else
		            base.setWaitTime = G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
		        if oldCurNum >= oldNeedNum and newCurNum >= newNeedNum then --领奖
		        	acMemoryServerVoApi:requestTaskReward(function()
		        		if taskReward then
				        	for k, v in pairs(taskReward) do
			                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
			                    if v.type == "h" then --添加将领魂魄
			                        if v.key and string.sub(v.key, 1, 1) == "s" then
			                            heroVoApi:addSoul(v.key, tonumber(v.num))
			                        end
			                    end
			                end
			                G_showRewardTip(taskReward)
			            end
		        		if self.taskTv then
		        			local recordPoint = self.taskTv:getRecordPoint()
							self.taskTv:reloadData()
							self.taskTv:recoverToRecordPoint(recordPoint)
						end
		        	end, 2, taskId, taskIndex)
		        else
		        	acMemoryServerVoApi:taskJumpTo(taskKey)
		        end
        	end
        	local cellBtnPicNormal, cellBtnPicDown = "yh_taskGoto.png", "yh_taskGoto_down.png"
        	if oldCurNum >= oldNeedNum and newCurNum >= newNeedNum then
        		cellBtnPicNormal, cellBtnPicDown = "yh_taskReward.png", "yh_taskReward_down.png"
        	end
        	local cellBtn = GetButtonItem(cellBtnPicNormal, cellBtnPicDown, cellBtnPicNormal, onClickCellBtn)
        	local btnMenu = CCMenu:createWithItem(cellBtn)
        	btnMenu:setPosition(ccp(0, 0))
	        btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
	        cellBg:addChild(btnMenu)
	        cellBtn:setAnchorPoint(ccp(1, 0.5))
	        cellBtn:setPosition(ccp(cellBg:getContentSize().width - 20, (cellTitleTitleBg:getPositionY() - cellTitleTitleBg:getContentSize().height) / 2))
		end
    end
end

function acMemoryServerTabTwo:dispose()
	self = nil
end