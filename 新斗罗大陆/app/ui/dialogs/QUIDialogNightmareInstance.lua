local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNightmareInstance = class("QUIDialogNightmareInstance", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QScrollContain = import("...ui.QScrollContain")
local QUIWidgetNightmareInstance = import("..widgets.QUIWidgetNightmareInstance")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNightmareArrangement = import("...arrangement.QNightmareArrangement")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
-- local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QChatData = import("...models.chatdata.QChatData")

function QUIDialogNightmareInstance:ctor(options)
	local ccbFile = "ccb/Dialog_nightmare_floor.ccbi"
	local callBacks = {
						{ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogNightmareInstance._onTriggerLeft)},
						{ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogNightmareInstance._onTriggerRight)},
						{ccbCallbackName = "onTriggerBadge", callback = handler(self, QUIDialogNightmareInstance._onTriggerBadge)},
						{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogNightmareInstance._onTriggerRank)},
					}
	QUIDialogNightmareInstance.super.ctor(self,ccbFile,callBacks,options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setScalingVisible(false)

	self._badgeConfigs = {}
	local configs= QStaticDatabase:sharedDatabase():getBadge()
	for _,value in pairs(configs) do
		table.insert(self._badgeConfigs, value)
	end
	table.sort(self._badgeConfigs, function (a,b)
		return a.number < b.number
	end)

	self._nightmareId = options.nightmareId
	self._maps = {}
	self._emptyFrames = {}
	self._ccbOwner.sheet_layout:setContentSize(CCSize(display.width, display.height))
	self._ccbOwner.sheet:setPositionY(-display.height/2)
    self._mapContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, touchLayerOffsetY = 0, isMask = false,
    	directionDown = false, direction = QScrollContain.directionY, renderFun = handler(self, self._onFrameHandler)})
	self._mapContain:setIsCheckAtMove(true)

	self._nightmares = remote.nightmare:getAllUnlockNightmare(true) or {}
	local count = #self._nightmares
	self._progress, self._totalCount = remote.nightmare:getProgressByNightmareId(self._nightmareId)
	if count < 2 or self._progress == self._totalCount then
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_left:setVisible(false)
	end

    self:initMapById(self._nightmareId)
	-- self._parentOptions = options.parentOptions
	--左下角聊天室按钮
	-- self.widgetChat = QUIWidgetChat.new()
	-- self.widgetChat:setPosition(-display.width/2 + 52, -display.height/2 + 48)
	-- self.widgetChat:retain()

	self._ccbOwner.node_info:setPositionX(24-display.width/2)
	self._ccbOwner.node_info:setPositionY(display.height/2-200)
	self._ccbOwner.btn_rank:setPositionX(display.width/2 - 48)
	self._ccbOwner.btn_rank:setPositionY(display.height/2 - 44)
	self._ccbOwner.node_battlefoce:setPositionX(206 - display.width/2)
	self._ccbOwner.node_battlefoce:setPositionY(display.height/2 - 35)
end

function QUIDialogNightmareInstance:viewDidAppear()
    QUIDialogNightmareInstance.super.viewDidAppear(self)
    self:addBackEvent()
    self._nightmareProxy = cc.EventProxy.new(remote.nightmare)
    self._nightmareProxy:addEventListener(remote.nightmare.EVENT_BEST_PASS_UPDATE, handler(self, self.bestPassUpdate))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

 --    self:getView():addChild(self.widgetChat)
 --    self.widgetChat:setChatAreaVisible(false)
	-- self.widgetChat:checkPrivateChannelRedTips()
	-- self.widgetChat:release()
	-- self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
    -- self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self:showForce()
	self._oldChatOrder = app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButtonZOrder(9997)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(true)	
end

function QUIDialogNightmareInstance:viewWillDisappear()
    QUIDialogNightmareInstance.super.viewWillDisappear(self)
	self:removeBackEvent()
	if 	self._nightmareProxy ~= nil then
	 	self._nightmareProxy:removeAllEventListeners()
	 	self._nightmareProxy = nil
	end
    if self._mapContain ~= nil then
    	self._mapContain:disappear()
    	self._mapContain = nil
    end
 --    if self._chatDataProxy ~= nil then
	-- 	self._chatDataProxy:removeAllEventListeners()
	-- 	self._chatDataProxy = nil
	-- end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
	remote.nightmare:removePropToTeam()
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButtonZOrder(self._oldChatOrder)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setChatButton(false)	
end

--显示战斗力
function QUIDialogNightmareInstance:showForce()
	remote.nightmare:addPropToTeam()
	local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.INSTANCE_TEAM, true) or 0
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	local num,unit = q.convertLargerNumber(force)
	if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	end
	self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
end

function QUIDialogNightmareInstance:_exitFromBattle()
	self:enableTouchSwallowTop()
	local progress = remote.nightmare:getProgressByNightmareId(self._nightmareId)
	local effectWidget = nil
	local nextEffectWidget = nil
	self:_onFrameHandler(true)
	local isWin = false
	if self._progress < progress then
		isWin = true
		for _,frame in ipairs(self._virtualFrames) do
			if frame.layer1 ~= nil then
				if frame.layer1.layer == (self._progress+1) then
					if frame.widget ~= nil then
						effectWidget = frame.widget:getChildWidgetByIndex(1)
					end
				elseif frame.layer1.layer == (progress+1) then
					if frame.widget ~= nil then
						nextEffectWidget = frame.widget:getChildWidgetByIndex(1)
					end
				end
			end
			if frame.layer2 ~= nil then
				if frame.layer2.layer == (self._progress+1) then
					if frame.widget ~= nil then
						effectWidget = frame.widget:getChildWidgetByIndex(2)
					end
				elseif frame.layer2.layer == (progress+1) then
					if frame.widget ~= nil then
						nextEffectWidget = frame.widget:getChildWidgetByIndex(2)
					end
				end
			end
		end
	end
	if effectWidget ~= nil then
		local nextFun = function ()
 			self._mapContain:moveTo(0, -self._mapContain.content:getPositionY() - progress * self._cellH/2 + (display.height/2 - self._cellH/4), true)
 			if nextEffectWidget ~= nil then
	 			scheduler.performWithDelayGlobal(function ()
 					nextEffectWidget:playAppearEffect(function ()
						self._progress = progress
						self:_onFrameHandler(true)
						remote.nightmare:nightmareGetBestPassForceRequest(self._nightmareId)
    					self:initMapById(self._nightmareId)
    					self:disableTouchSwallowTop()
    					if isWin then
    						self:checkBadgeUpgrade()
							self:refreshInfo()
    					end
 					end)
 				end, 0.2)
	 		else
			    scheduler.performWithDelayGlobal(function ()
					self._progress = progress
					self:_onFrameHandler(true)
					remote.nightmare:nightmareGetBestPassForceRequest(self._nightmareId)
    				self:initMapById(self._nightmareId)
    				self:disableTouchSwallowTop()
					if isWin then
						self:checkBadgeUpgrade()
						self:refreshInfo()
					end
			    end, 0.3)
			end
		end
		effectWidget:playMonsterDead(function ()
			local chestResult = remote.nightmare:getChestResult()
			if chestResult ~= nil then
				local awards = {}
				for _, value in ipairs(chestResult) do
					table.insert(awards, {id = value.id or 0, typeName = value.type, count = value.count or 0})
				end
		        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		            options = {awards = awards, callBack = function ()
					    local nightmareConfig = remote.nightmare:getConfigByNightmareId(self._nightmareId)
					    if progress == #nightmareConfig.configs then
					    	self:popSelf()
					    	return
					    end
						effectWidget:playEndEffect(nextFun)
		            end}}, {isPopCurrentDialog = false} )
		        dialog:setTitle("恭喜您获得宝箱奖励")
			else
				effectWidget:playEndEffect(nextFun)
			end
		end)
	else
    	self:initMapById(self._nightmareId)
    	self:disableTouchSwallowTop()
		if isWin then
			self:checkBadgeUpgrade()
			self:refreshInfo()
		end
	end
end

--刷新一下当前地图的信息显示
function QUIDialogNightmareInstance:refreshInfo()
	local count = (remote.user.nightmareDungeonPassCount or 0)
	local totalCount = 0
	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(count)
	local nextConfig = nil
	if config ~= nil then
		for index,value in ipairs(self._badgeConfigs) do
			if nextConfig ~= nil then
				nextConfig = value
				break
			end
			if value.number == config.number then
				nextConfig = value
			end
		end
	else
		nextConfig = self._badgeConfigs[1]
	end
	totalCount = nextConfig.number
	self._ccbOwner.tf_progress:setString(count.."/"..totalCount)
	self._ccbOwner.node_bar:setScaleX(count/totalCount)
	self._ccbOwner.sp_badge:setTexture(CCTextureCache:sharedTextureCache():addImage(nextConfig.alphaicon))

	self._ccbOwner.tf_badge_name:setString("下级（"..nextConfig.badge_name.."）：")
	self._ccbOwner.tf_prop1:setString("＋"..nextConfig.attack_value)
	self._ccbOwner.tf_prop2:setString("＋"..nextConfig.hp_value)
	self._ccbOwner.tf_prop3:setString("＋"..nextConfig.armor_physical)
	self._ccbOwner.tf_prop4:setString("＋"..nextConfig.armor_magic)

	local instanceConfig = remote.nightmare:getConfigByNightmareId(self._nightmareId)

	self._ccbOwner.tf_number:setString(instanceConfig.index)
	self._ccbOwner.tf_name:setString(instanceConfig.configs[1].instance_name)
	if self._oldCount == nil then
		self._oldCount = count
	elseif count > self._oldCount then
		if self._effect ~= nil then 
			self._effect:disappear()
			self._effect:removeFromParent()
			self._effect = nil
		end
		self._ccbOwner.node_bar:setScaleX((count-1)/totalCount)
		self._ccbOwner.node_bar:runAction(CCScaleTo:create(1, count/totalCount, self._ccbOwner.node_bar:getScaleY()))

		self._effect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_effect:addChild(self._effect)
		self._effect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
			ccbOwner.content:setString("+1")
		end, function()
        	self._effect:disappear()
        end)

        local node = self._ccbOwner.tf_progress
		node:setScale(0.8)
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 0.8, 0.8))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
	self._oldCount = count
end

--初始化地图通过nightmareId
function QUIDialogNightmareInstance:initMapById(nightmareId)
	remote.nightmare:nightmareGetBestPassForceRequest(nightmareId)
	self._nightmareId = nightmareId
	self:getOptions().nightmareId = nightmareId
	self._progress, self._totalCount = remote.nightmare:getProgressByNightmareId(nightmareId)
	-- self._progress = 10
	self._cellH = 660
	self._offsetY = self._cellH/2
	local offsetIndex = 1
	if self._totalCount%2 ~= 0 then                                               
		self._offsetY = 0
		offsetIndex = 0
	end
	local configs = remote.nightmare:getConfigByNightmareId(nightmareId).configs
	if self._virtualFrames ~= nil then
		for _,frame in ipairs(self._virtualFrames) do
			self:_show(frame, false)
		end
	end
	self._virtualFrames = {}
	local realIndex = 0
	local realTotal = math.ceil(self._totalCount/2)
	for i=realIndex,realTotal do
		local tbl = {}
		tbl.index = i
		tbl.layer1 = configs[offsetIndex]
		tbl.layer2 = configs[offsetIndex+1]
		tbl.mirror = 1
		if tbl.layer1 ~= nil then
			tbl.layer1.layer = offsetIndex
			if tbl.layer1.file ~= nil then
				tbl.file = tbl.layer1.file
			end
			if tbl.layer1.mirror ~= nil then
				tbl.mirror = tbl.layer1.mirror
			end
		end
		if tbl.layer2 ~= nil then
			tbl.layer2.layer = offsetIndex + 1
			if tbl.layer2.file ~= nil then
				tbl.file = tbl.layer2.file
			end
			if tbl.layer2.mirror ~= nil then
				tbl.mirror = tbl.layer2.mirror
			end
		end
		tbl.posX = display.width/2
		tbl.posY = self._offsetY + i * self._cellH
		if tbl.file ~= nil then
			table.insert(self._virtualFrames, tbl)
		end
		offsetIndex = offsetIndex + 2
	end
	local size = self._mapContain:getContentSize()
	local moveCount = math.min(self._totalCount, self._progress+8)
	size.height = self._cellH/2 * moveCount
    self._mapContain:setContentSize(size.width, size.height)

    --添加渐变蒙板
    if self._colorLayer == nil then
		self._colorLayer = CCLayerGradient:create(ccc4(0, 0, 0, 0), ccc4(0, 0, 0, 255), ccp(0, 1))
		self._colorLayer:setContentSize(CCSize(1136, 660))
	    self._mapContain:addChild(self._colorLayer)
	end
	local offsetAlpha = self._totalCount - self._progress
	offsetAlpha = math.min(offsetAlpha, 7)
	local endAlpha = 255/2*offsetAlpha/7
	self._colorLayer:setEndOpacity(endAlpha)
	self._colorLayer:setContentSize(CCSize(1136, offsetAlpha * 330))
	self._colorLayer:setPositionY((self._progress + 1) * 330)

	self._bestPass = remote.nightmare:getBestPass(self._nightmareId)
    --复位
    self:moveToIndex(self._progress, false)

    self:refreshInfo()
end

function QUIDialogNightmareInstance:moveToIndex(layer, isMove)
	if isMove then
 		self._mapContain:moveTo(0, -self._mapContain.content:getPositionY() - layer * self._cellH/2 + (display.height/2 - self._cellH/4), isMove)
 	else
 		self._mapContain:moveTo(0, - layer * self._cellH/2 + (display.height/2 - self._cellH/4), isMove)
 	end
end

-- function QUIDialogNightmareInstance:setParentOption()
-- 	if self._parentOptions ~= nil then
-- 		local configs = remote.nightmare:getConfigByNightmareId(self._nightmareId).configs
-- 		self._parentOptions.selectIndex = configs[1].unlock_dungeon_id
-- 	end
-- end

function QUIDialogNightmareInstance:_onFrameHandler(isForce)
	local contentY = self._mapContain.content:getPositionY()
	local minValue = - self._cellH/2
	local maxValue = self._mapContain.size.height + self._cellH/2
	local offsetY = 0
	for _, value in ipairs(self._virtualFrames) do
		offsetY = value.posY + contentY
		if offsetY >= maxValue or offsetY <= minValue then  
			self:_show(value, false, isForce)
		end
	end
	for _, value in ipairs(self._virtualFrames) do
		offsetY = value.posY + contentY
		if offsetY >= maxValue or offsetY <= minValue then  
		else
			self:_show(value, true, isForce)
		end
	end
end

function QUIDialogNightmareInstance:_show(frame, isShow, isForce)
	if frame.isShow == isShow and isForce ~= true then 
		return 
	end
	frame.isShow = isShow
	if isShow == false then
		if frame.widget ~= nil then
			self:setEmptyFrame(frame)
			frame.widget:setVisible(false)
			frame.widget = nil
		end
	else
		if frame.widget == nil then
			frame.widget = self:getEmptyFrame(frame)
		end
		frame.widget:setVisible(true)
		frame.widget:setPosition(ccp(frame.posX , frame.posY))
		frame.widget:setZOrder(-frame.index)
		frame.widget:setInfo(frame, self._progress, self._totalCount)
	end
end

function QUIDialogNightmareInstance:refreshShow()
	for _, frame in ipairs(self._virtualFrames) do
		if frame.widget ~= nil then
			frame.widget:setInfo(frame, self._progress, self._totalCount)
		end
	end
end

--保存空闲的widget
function QUIDialogNightmareInstance:setEmptyFrame(frame)
	if self._emptyFrames[frame.file] == nil then
		self._emptyFrames[frame.file] = {}
	end
	if frame.widget ~= nil then
		table.insert(self._emptyFrames[frame.file], frame.widget)
	end
end

--获取的widget
function QUIDialogNightmareInstance:getEmptyFrame(frame)
	if self._emptyFrames[frame.file] == nil then
		self._emptyFrames[frame.file] = {}
	end
	if #self._emptyFrames[frame.file] > 0 then
		return table.remove(self._emptyFrames[frame.file], 1)
	end
	local widget = QUIWidgetNightmareInstance.new({ccbFile = frame.file})
	widget:addEventListener(QUIWidgetNightmareInstance.EVENT_CLICK_CHEST, handler(self, self._onTriggerChest))
	widget:addEventListener(QUIWidgetNightmareInstance.EVENT_CLICK_FIGHT, handler(self, self._onTriggerFight))
	widget:addEventListener(QUIWidgetNightmareInstance.EVENT_CLICK_RECORD, handler(self, self._onTriggerRecord))
	self._mapContain:addChild(widget)
	return widget
end

--播放自己出现的动画
function QUIDialogNightmareInstance:avatarAnimationForSelf()
	for _, frame in ipairs(self._virtualFrames) do
		if frame.widget ~= nil then
			frame.widget:avatarAnimationForSelf()
		end
	end
end

--点击宝箱查看内容
function QUIDialogNightmareInstance:_onTriggerChest(e)
	if self._mapContain:getMoveState() == false then
    	app.sound:playSound("common_small")
		local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(e.dungeonId)
		app:luckyDrawAlert(dungeonConfig.boss_box, "获得条件：击败怪物")
	end
end

--点击怪物战斗
function QUIDialogNightmareInstance:_onTriggerFight(e)
	if self._mapContain:getMoveState() == false then
		local herosInfos, count, force = remote.herosUtil:getMaxForceHeros()
		local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(e.dungeonId)
		local recommendPower = tonumber(config.thunder_force or 0)
		local isRecommend = (not not config.thunder_force) and force >= recommendPower
		local maxPower = tonumber(config.commonly_upper_limit or 0)
		local isEasy = (force > maxPower) and (config.thunder_force ~= nil)
		local options = self:getOptions()
		local dungeonArrangement = QNightmareArrangement.new({dungeonId = e.dungeonId, isEasy = isEasy, isRecommend = isRecommend, force = force})
	    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
	     	options = {arrangement = dungeonArrangement}})
	end
end

--点击查看最佳通关
function QUIDialogNightmareInstance:_onTriggerRecord(e)
	if self._mapContain:getMoveState() == false then
    	app.sound:playSound("common_small")
		local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(e.dungeonId)
		remote.nightmare:nightmarePassHistoryRequest(config.int_id, function (data)
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogNightmareRecord",
		     	options = {info = data.nightmareDungeonPassHistoryResponse}})
		end)
	end
end

function QUIDialogNightmareInstance:_onTriggerLeft()
	if self._nightmares ~= nil and #self._nightmares > 1 then
		for index,id in ipairs(self._nightmares) do
			if id == self._nightmareId then
				index = index - 1
				if index == 0 then
					index = #self._nightmares
				end
				self:showChangeChapterEffect(function ()
    				self:initMapById(self._nightmares[index])
					self:avatarAnimationForSelf()
				end)
    			return
			end
		end
	end
end

function QUIDialogNightmareInstance:_onTriggerRight()
	if self._nightmares ~= nil and #self._nightmares > 1 then
		for index,id in ipairs(self._nightmares) do
			if id == self._nightmareId then
				index = index + 1
				if index == #self._nightmares+1 then
					index = 1
				end
				self:showChangeChapterEffect(function ()
    				self:initMapById(self._nightmares[index])
					self:avatarAnimationForSelf()
				end)
    			return
			end
		end
	end
end

--检查是否有新的徽章
function QUIDialogNightmareInstance:checkBadgeUpgrade()
	local oldConfig = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount - 1)
	local newConfig = QStaticDatabase:sharedDatabase():getBadgeByCount(remote.user.nightmareDungeonPassCount)
	local oldBadge = 0
	if oldConfig ~= nil then
		oldBadge = oldConfig.number
	end
	local newBadge = 0
	if newConfig ~= nil then
		newBadge = newConfig.number
	end
	if oldBadge < newBadge then
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNightmareBadge", 
			options = {oldConfig = oldConfig, newConfig = newConfig}}, {isPopCurrentDialog = false})
		dialog:addEventListener(dialog.EVENT_CLOSE, function ()
			self:showForce()
		end)
	end
end

function QUIDialogNightmareInstance:showChangeChapterEffect(callback)
	self:enableTouchSwallowTop()
	if self._chapterEffect == nil then
		self._chapterEffect = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._chapterEffect)
	end
	local animationName = "move2"
	self._chapterEffect:playAnimation("ccb/effects/nightmare_emeng_yidong_ud.ccbi", function (ccbOwner)
		local size = ccbOwner.sp_mask:getContentSize()
		ccbOwner.sp_mask:setScaleX(display.width/size.width)
		ccbOwner.sp_mask:setScaleY(display.height/size.height)
	end, function ()
		self:disableTouchSwallowTop()
	end, true, animationName)
	scheduler.performWithDelayGlobal(callback, 6/30)
end

function QUIDialogNightmareInstance:bestPassUpdate()
	self:refreshShow()
end

-- function QUIDialogNightmareInstance:_onMessageReceived(event)
	-- if self.widgetChat ~= nil then
	-- 	self.widgetChat:checkPrivateChannelRedTips()
	-- end
-- end

function QUIDialogNightmareInstance:_onTriggerBadge()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNightmareBadgeList"})
end

function QUIDialogNightmareInstance:_onTriggerRank()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "nightmareRank"}}, {isPopCurrentDialog = false})
end

function QUIDialogNightmareInstance:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogNightmareInstance:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end

function QUIDialogNightmareInstance:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogNightmareInstance:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogNightmareInstance