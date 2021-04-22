-- @Author: xurui
-- @Date:   2019-05-13 15:34:25
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-24 19:36:06
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivitySoulLetter = class("QUIDialogActivitySoulLetter", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QActivitySoulLetter = import("...utils.QActivitySoulLetter")
local QListView = import("...views.QListView")
local QUIWidgetActivitySoulLetterAwardClient = import("..widgets.QUIWidgetActivitySoulLetterAwardClient")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetActivitySoulLetterTaskClient = import("..widgets.QUIWidgetActivitySoulLetterTaskClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogActivitySoulLetter:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerTask", callback = handler(self, self._onTriggerTask)},
		{ccbCallbackName = "onTriggerBuyExp", callback = handler(self, self._onTriggerBuyExp)},
		{ccbCallbackName = "onTriggerBuyExp1", callback = handler(self, self._onTriggerBuyExp1)},
		{ccbCallbackName = "onTriggerBuyElite", callback = handler(self, self._onTriggerBuyElite)},
		{ccbCallbackName = "onTriggerFinalAward", callback = handler(self, self._onTriggerFinalAward)},
		{ccbCallbackName = "onTriggerReciveAll", callback = handler(self, self._onTriggerReciveAll)},
		{ccbCallbackName = "onTriggerReciveAllTask", callback = handler(self, self._onTriggerReciveAllTask)},
		{ccbCallbackName = "onTriggerActiveElite", callback = handler(self, self._onTriggerActiveElite)},
		{ccbCallbackName = "onTriggerActiveBestElite", callback = handler(self, self._onTriggerActiveBestElite)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    self.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)
    page.topBar:showWithHeroOverView()
    
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._tab = options.tab
    end

 	self._activityProxy = remote.activityRounds:getSoulLetter()

 	if self._tab == nil then
 		local awardTip = self._activityProxy:checkAwardTips() 
 		local taskTip = self._activityProxy:checkTaskTips()
 		if not awardTip and taskTip then
 			self._tab = self._activityProxy.TAB_TASK
 		else
 			self._tab = self._activityProxy.TAB_AWARD
 		end
 	end

 	self._awardDataList = {}          	--等级奖励
 	self._curNodeAward = {}      		--当前节点奖励
	self._normalItem = nil     			--普通节点奖励item
	self._eliteItem = {}       			--精英节点奖励item 
	self._taskRefreshHour = QStaticDatabase:sharedDatabase():getConfigurationValue("BATTLE_PASS_RESET_TIME")
	self._taskRefreshDay = QStaticDatabase:sharedDatabase():getConfigurationValue("BATTLE_PASS_RESET_DAY")
 	
    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
end

function QUIDialogActivitySoulLetter:viewDidAppear()
	QUIDialogActivitySoulLetter.super.viewDidAppear(self)
    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsProxy:addEventListener(remote.activityRounds.SOUL_LETTER_UPDATE, handler(self, self.onEvent))
    self._activityRoundsProxy:addEventListener(remote.activityRounds.SOUL_LETTER_END, handler(self, self.onEvent))

	if self._activityProxy.isOpen == false then
		app.tip:floatTip("魂师大人，当前活动已结束")
		self:popSelf()
		return
	end

	self:setActivityInfo()

	self:setTabStatus()

	self:setFinalAward()

	self:checkRedTips()

	self:addBackEvent(true)
end

function QUIDialogActivitySoulLetter:viewWillDisappear()
  	QUIDialogActivitySoulLetter.super.viewWillDisappear(self)

  	if self._activityRoundsProxy then
  		self._activityRoundsProxy:removeAllEventListeners()
  	end

  	if self._timeScheduler then
  		scheduler.unscheduleGlobal(self._timeScheduler)
  		self._timeScheduler = nil
  	end
  	if self._taskRefreshScheduler then
  		scheduler.unscheduleGlobal(self._taskRefreshScheduler)
  		self._taskRefreshScheduler = nil
  	end

	self:removeBackEvent()
end

function QUIDialogActivitySoulLetter:onEvent()
	if self._activityProxy.isOpen == false then
		app.tip:floatTip("魂师大人，当前活动已结束")
		self:popSelf()
		return
	end
	
	self:setActivityInfo()

	self:setTabStatus()

	self:checkRedTips()
end

function QUIDialogActivitySoulLetter:setActivityInfo()
	local activityInfo = self._activityProxy:getActivityInfo()

	if q.isEmpty(self._awardDataList) then
		local configDict = self._activityProxy:getAwardsConfig()
		for _, value in pairs(configDict) do
			table.insert(self._awardDataList, value)
		end

		table.sort(self._awardDataList, function(a, b)
			return a.level < b.level
		end)
	end

	self._ccbOwner.tf_level:setString(activityInfo.level or 1)

	--set exp
	local currentExp = activityInfo.exp or 0
	local expConfig = self._activityProxy:getAwardsConfigByLevel((activityInfo.level or 1)+1)
	local maxExp = expConfig.exp or 1200
	self._ccbOwner.tf_num:setString(string.format("%s/%s", currentExp, maxExp))

	local scale = currentExp/maxExp 
	if scale > 1 then
		scale = 1
	end
	local progressBar = self._percentBarClippingNode:getStencil()
	progressBar:setAnchorPoint(ccp(0, 0.5))
	progressBar:setScaleX(scale)

	if self._activityProxy:checkIsMaxLevel() then
		progressBar:setScaleX(0)
		self._ccbOwner.tf_num:setString("经验已达上限")
	end

	self:setActivityTime()
end

function QUIDialogActivitySoulLetter:setActivityTime()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local endTime = self._activityProxy.endAt or 0

	local timeFunc
	timeFunc = function ( ... )
		local lastTime = endTime - q.serverTime()
		if lastTime > 0 then
			local timeStr = q.timeToDayHourMinute(lastTime)
			self._ccbOwner.tf_activity_time:setString(timeStr)
		else
			self._ccbOwner.tf_activity_time:setString("")
			self._ccbOwner.tf_time_title:setString("活动已结束")
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogActivitySoulLetter:setTabStatus()
	local isAwardTab = self._activityProxy.TAB_AWARD == self._tab
	local isTaskTab = self._activityProxy.TAB_TASK == self._tab
	self:getOptions().tab = self._tab

	self._ccbOwner.btn_award:setEnabled(not isAwardTab)
	self._ccbOwner.btn_award:setHighlighted(isAwardTab)
	self._ccbOwner.btn_task:setEnabled(not isTaskTab)
	self._ccbOwner.btn_task:setHighlighted(isTaskTab)
	self._ccbOwner.node_award:setVisible(isAwardTab)
	self._ccbOwner.node_task:setVisible(isTaskTab)

	if isAwardTab then
		if self._taskListView then
			self._taskListView:setVisible(false)
		end
		self:setAwardList()
	elseif isTaskTab then
		if self._awardListView then
			self._awardListView:setVisible(false)
		end
    	self._activityProxy:requestSoulLetterTaskInfo(false, function ( ... )
    		if self:safeCheck() then
    			self:updateTaskInfo()
			end
		end)
	end
end

function QUIDialogActivitySoulLetter:updateTaskInfo(showTaskEffect)
	self._taskDataList = self._activityProxy:getTaskList()

	self:setTaskList()

	self:setWeekNum(showTaskEffect)

	local taskTip = self._activityProxy:checkAwardTips(self._activityProxy.TAB_TASK) 
	self._ccbOwner.node_btn_recive_for_task:setVisible(taskTip)
end

function QUIDialogActivitySoulLetter:setAwardList()
	local headIndex = nil
	local activityInfo = self._activityProxy:getActivityInfo()
	local eliteUnlock = self._activityProxy:checkEliteUnlock()

	for _, value in ipairs(self._awardDataList) do
		local levelUnlock = (activityInfo.level or 1) >= value.level
		if levelUnlock then
			local normalRecived = self._activityProxy:checkNormalAwardStatus(value.level)
			if value.normal_reward and not normalRecived then
				headIndex = value.level
			end
			if eliteUnlock then
				if headIndex == nil and levelUnlock then
					local eliteRecived = self._activityProxy:checkEliteAwardStatus(value.level)
					if value.rare_reward1 and not eliteRecived then
						headIndex = value.level
					end
				end
			end
		end

		if headIndex then
			break
		end
	end
	if headIndex == nil then
		headIndex = activityInfo.level or 1
	end

    if not self._awardListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._awardDataList[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetActivitySoulLetterAwardClient.new()
            		item:addEventListener(QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_NORAML, handler(self, self.clickAwardClient))
            		item:addEventListener(QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_ELITE, handler(self, self.clickAwardClient))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData, self._activityProxy)
	            info.item = item
	            info.size = item:getContentSize()

				item:registerItemBoxPrompt(index, list)
				list:registerBtnHandler(index, "btn_normal", "_onTriggerClickNormal")
				list:registerBtnHandler(index, "btn_elite", "_onTriggerClickElite")

				self:setNodeAward(list)
				
	            return isCacheNode
	        end,
	        isVertical = false,
	        ignoreCanDrag = true,
	        enableShadow = false,
	        curOriginOffset = -1,
	        spaceX = -1,
	        curOffset = -1,
	        totalNumber = #self._awardDataList,
	        headIndex = headIndex,
	    }  
	    self._awardListView = QListView.new(self._ccbOwner.sheet_layout1, cfg)
		-- self:setNodeAward(self._awardListView, headIndex + 10)
	else
		self._awardListView:reload({totalNumber = #self._awardDataList, headIndex = headIndex})
		self._awardListView:refreshData()
	end
	self._awardListView:setVisible(true)
end

function QUIDialogActivitySoulLetter:setNodeAward(list, offsetIndex)
	local startIndex = list:getCurStartIndex()
	local endIndex = list:getCurEndIndex()

	local nodeAward = {}
	if startIndex == endIndex then
		endIndex = startIndex + 2
	end
	local offset = endIndex + 8
	if offsetIndex then
		offset = offsetIndex
	end
	for i = offset, startIndex, -1 do 
		if self._awardDataList[i] and tonumber(self._awardDataList[i].is_node or 0) >= 2 then
			nodeAward = self._awardDataList[i]
			break
		end
	end

	if q.isEmpty(nodeAward) == false and self._curNodeAward.level ~= nodeAward.level then
		self._curNodeAward = nodeAward
		self._ccbOwner.tf_award_level:setString((self._curNodeAward.level or 0).."级")

		--normal award
		if self._normalItem == nil then
			self._normalItem = QUIWidgetItemsBox.new()
			self._ccbOwner.node_normal_item:addChild(self._normalItem)
			self._normalItem:setPromptIsOpen(true)
		end
		if self._curNodeAward.normal_reward then
			local normalAwards = {}
			remote.items:analysisServerItem(self._curNodeAward.normal_reward, normalAwards)
			self._normalItem:setGoodsInfo(normalAwards[1].id, normalAwards[1].typeName, normalAwards[1].count)
			self._normalItem:setVisible(true)
		else
			if self._normalItem then
				self._normalItem:setVisible(false)
			end
		end

		--elite award
		for i = 1, 2 do
			if self._curNodeAward["rare_reward"..i] then
				self._ccbOwner["node_elite_item"..i]:setVisible(true)
				if self._eliteItem[i] == nil then
					self._eliteItem[i] = QUIWidgetItemsBox.new()
					self._ccbOwner["node_elite_item"..i]:addChild(self._eliteItem[i])
					self._eliteItem[i]:setPromptIsOpen(true)
				end
				local eliteAwards = {}
				remote.items:analysisServerItem(self._curNodeAward["rare_reward"..i], eliteAwards)
				self._eliteItem[i]:setGoodsInfo(eliteAwards[1].id, eliteAwards[1].typeName, eliteAwards[1].count)
			else
				self._ccbOwner["node_elite_item"..i]:setVisible(false)
			end
		end
	end
end

function QUIDialogActivitySoulLetter:clickAwardClient(event)
	if event == nil then return end

	local info = event.info
	local level = info.level
	if event.name == QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_NORAML then
		self:reciveAward({level}, function()
			self:showNodeAwardTip(level)
		end)
	elseif event.name == QUIWidgetActivitySoulLetterAwardClient.EVENT_CLICK_ELITE then
		self:reciveAward({level})
	end
end

function QUIDialogActivitySoulLetter:reciveAward(levels, callback)
	if q.isEmpty(levels) == false then
		local awards = {}
		local eliteUnlock = self._activityProxy:checkEliteUnlock()
		for _, level in ipairs(levels) do
			local config = self._activityProxy:getAwardsConfigByLevel(level)
			local normalRecived = self._activityProxy:checkNormalAwardStatus(level)
			if config.normal_reward and normalRecived == false then
				remote.items:analysisServerItem(config.normal_reward, awards)
			end
			if eliteUnlock then
				local eliteRecived = self._activityProxy:checkEliteAwardStatus(level)
				if eliteRecived == false then
					if config.rare_reward1 then
						remote.items:analysisServerItem(config.rare_reward1, awards)
					end
					if config.rare_reward2 then
						remote.items:analysisServerItem(config.rare_reward2, awards)
					end
				end
			end
		end

		self._activityProxy:requestSoulLetterAwards(levels, function()
			if self:safeCheck() then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards, callback = function()
						if callback then
							callback()
						end
                    end}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜您获得魂师手札奖励")
			end
		end)
	end
end

function QUIDialogActivitySoulLetter:reciveTaskAward(taskList)
	if q.isEmpty(taskList) then return end

	local oldActivityInfo = self._activityProxy:getActivityInfo()
	local oldLevel = oldActivityInfo.level or 1
	local totalExp = 0
	local tbl = {}
	local multiple = db:getConfigurationValue("shouzha_multiple") or 2
	for _, info in ipairs(taskList) do
		local _, _, isMultiple = self._activityProxy:getTaskMultipleInfo(info)
		if isMultiple then
			totalExp = totalExp + (info.exp or 0) * multiple
		else
			totalExp = totalExp + (info.exp or 0)
		end
		table.insert(tbl, tonumber(info.type))
	end

	self._activityProxy:requestSoulLetterTaskRecived(tbl, false, function()
		if self:safeCheck() then
			if self._taskListView and self._tab == self._activityProxy.TAB_TASK then
				local index = 1 
				while true do
					local item = self._taskListView:getItemByIndex(index)
					if item then
						if item.getInfo then
							local _info = item:getInfo()
							for _, id in ipairs(tbl) do
								if id == _info.type then
									item:showRefreshEffet()
									break
								end
							end
						end

						index = index + 1
					else
						break
					end
				end
			end
			self:setActivityInfo()

			self:updateTaskInfo(true)

			self:checkRedTips()
			
			local newActivityInfo = self._activityProxy:getActivityInfo()
			local addLevel = newActivityInfo.level - oldLevel
			local exp = totalExp
			self:showLevelUpTip(addLevel, exp)
		end
	end)
end

function QUIDialogActivitySoulLetter:showNodeAwardTip(level)
	local eliteUnlock = self._activityProxy:checkEliteUnlock()
	if eliteUnlock == false and level and level % 5 == 0 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterNodeAwardTip", 
			options = {level = level}})
	end
end

function QUIDialogActivitySoulLetter:setTaskList()
	table.sort(self._taskDataList, function(a, b)
		local aProgress, aCurStep = self._activityProxy:getTaskRecodeByType(a.type)
		local aCanRecive = (aProgress.process or 0) >= a.num
		local aIsAllComplete = (aCurStep == nil)
		local bProgress, bCurStep = self._activityProxy:getTaskRecodeByType(b.type)
		local bCanRecive = (bProgress.process or 0) >= b.num
		local bIsAllComplete = (bCurStep == nil)

		if aIsAllComplete ~= bIsAllComplete then
			return aIsAllComplete == false
		else
			if aCanRecive ~= bCanRecive then
				return aCanRecive == true
			else
				return a.type < b.type
			end
		end
	end)

    if not self._taskListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._taskDataList[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetActivitySoulLetterTaskClient.new()
            		item:addEventListener(QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_RECIVE, handler(self, self.clickTaskClient))
            		item:addEventListener(QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_GO, handler(self, self.clickTaskClient))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData, self._activityProxy)
	            info.item = item
	            info.size = item:getContentSize()

				list:registerBtnHandler(index, "btn_recive", "_onTriggerRecive", nil, true)
				list:registerBtnHandler(index, "btn_go", "_onTriggerGo", nil, true)

	            return isCacheNode
	        end,
	        isVertical = false,
	        ignoreCanDrag = true,
	        enableShadow = false,
	        curOriginOffset = 25,
	        spaceX = 15,
	        contentOffsetY = -10,
	        curOffset = 15,
	        totalNumber = #self._taskDataList,
	        endIndex = 10,
	    }  
	    self._taskListView = QListView.new(self._ccbOwner.sheet_layout2, cfg)
	else
		self._taskListView:refreshData()
	end
	self._taskListView:setVisible(true)
end

function QUIDialogActivitySoulLetter:setWeekNum(showTaskEffect)
	local weekNum = self._activityProxy:getCurrentWeekNum()
	self._ccbOwner.tf_week_num:setString(string.format("第%s周任务", weekNum))
	local activityStartTime = self._activityProxy.startAt or 0
    local taskRefreshDay = QStaticDatabase:sharedDatabase():getConfigurationValue("BATTLE_PASS_RESET_DAY")
    
    local startTime = activityStartTime + ((weekNum - 1) * taskRefreshDay * DAY)
    local endTime = startTime + taskRefreshDay * DAY

    local startTimeTbl = q.date("*t", startTime)
    local endTimeTbl = q.date("*t", endTime)
	self._ccbOwner.tf_week_start_time1:setString(string.format("%d/%02d/%02d", startTimeTbl.year, startTimeTbl.month, startTimeTbl.day))
	self._ccbOwner.tf_week_start_time2:setString(string.format("%01d:%02d", startTimeTbl.hour, startTimeTbl.min))
	self._ccbOwner.tf_week_end_time1:setString(string.format("- %d/%02d/%02d", endTimeTbl.year, endTimeTbl.month, endTimeTbl.day))
	self._ccbOwner.tf_week_end_time2:setString(string.format(" %01d:%02d", endTimeTbl.hour, endTimeTbl.min))

	--set week exp
	local maxExpConfig = self._activityProxy:getWeekMaxExp(weekNum)
	local maxExp = (maxExpConfig.exp or 0)
	local weekExp = self._activityProxy:getWeekExp()
	if weekExp > maxExp then
		weekExp = maxExp
	end
	self._ccbOwner.tf_week_exp:setString(string.format("%s/%s", weekExp, maxExp))

	local expIsFull = self._activityProxy:checkWeekExpIsFull()
	self._ccbOwner.ly_mask:setTouchEnabled(expIsFull)
	self._ccbOwner.ly_mask:setTouchSwallowEnabled(expIsFull)
	if showTaskEffect and expIsFull then
		self:showTaskIsDoneEffect()
	else
		self._ccbOwner.node_task_mask:setVisible(expIsFull)
	end
	if expIsFull then
		self._ccbOwner.tf_week_max_exp:setString(string.format("%s/%s", weekExp, maxExp))
	end
	self:setNextWeekTimeScheduler(endTime)
end

function QUIDialogActivitySoulLetter:showTaskIsDoneEffect()
	self._ccbOwner.node_task_mask:setVisible(true)
	self._ccbOwner.ly_mask:setOpacity(0)
	self._ccbOwner.node_mask:setScale(0)
	self._ccbOwner.sp_mask_complete:setVisible(false)
	self._ccbOwner.sp_mask_complete:setScale(2)

	local layerArray = CCArray:create()
	layerArray:addObject(CCFadeTo:create(0.1, 60))
	layerArray:addObject(CCCallFunc:create(function()
		local maskArray = CCArray:create()
		maskArray:addObject(CCScaleTo:create(0.2, 1.15))
		maskArray:addObject(CCScaleTo:create(0.1, 1))
		maskArray:addObject(CCCallFunc:create(function()
			local completeArray = CCArray:create()
			completeArray:addObject(CCDelayTime:create(0.5))
			completeArray:addObject(CCCallFunc:create(function()
				self._ccbOwner.sp_mask_complete:setVisible(true)
			end))
			completeArray:addObject(CCScaleTo:create(0.15, 0.7))
			completeArray:addObject(CCScaleTo:create(0.1, 1))
			self._ccbOwner.sp_mask_complete:runAction(CCSequence:create(completeArray))
		end))
		self._ccbOwner.node_mask:runAction(CCSequence:create(maskArray))
	end))
	self._ccbOwner.ly_mask:runAction(CCSequence:create(layerArray))
end

function QUIDialogActivitySoulLetter:setNextWeekTimeScheduler(nextTime)
	if self._taskRefreshScheduler then
		scheduler.unscheduleGlobal(self._taskRefreshScheduler)
		self._taskRefreshScheduler = nil
	end

	local endTime = nextTime
	local timeFunc
	timeFunc = function ()
		local lastTime = endTime - q.serverTime() + 2
		if lastTime > 0 then
			local timeStr = q.timeToHourMinuteSecond(lastTime)
			self._ccbOwner.tf_next_week_time:setString(timeStr)
		else
			self._ccbOwner.tf_next_week_time:setString("")
		    self._activityProxy:getServerTaskRecord(function()
		        
		    end)
		end
	end

	self._taskRefreshScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogActivitySoulLetter:clickTaskClient(event)
	if event == nil then return end

	local info = event.info
	if event.name == QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_RECIVE then
		local oldActivityInfo = self._activityProxy:getActivityInfo()
		local oldLevel = oldActivityInfo.level or 1
		self._activityProxy:requestSoulLetterTaskRecived({tonumber(info.type)}, false, function()
			if self:safeCheck() then
				local exp = info.exp or 0
				local isMultiple = false
				if event.target then
					event.target:showRefreshEffet(function()
					end)
					if event.target:getIsMultiple() then
						local multiple = db:getConfigurationValue("shouzha_multiple") or 2
						exp = exp * multiple
						isMultiple = true
					end
				end
				
				self:setActivityInfo()
				self:updateTaskInfo(true)
				self:checkRedTips()

				local newActivityInfo = self._activityProxy:getActivityInfo()
				local addLevel = newActivityInfo.level - oldLevel
				self:showLevelUpTip(addLevel, exp, isMultiple)
			end
		end)
	elseif event.name == QUIWidgetActivitySoulLetterTaskClient.EVENT_CLICK_GO then
		QQuickWay:clickGotoByIndex(info.short_approch)
	end
end

function QUIDialogActivitySoulLetter:setFinalAward()
	local finalAward = self._activityProxy:getFinalAward()

	if q.isEmpty(finalAward) == false then
		local award = {}
		self._finalAward = finalAward
		remote.items:analysisServerItem(finalAward.rare_reward1, award)
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(award[1].id)
		local skins = string.split(itemConfig.content, "^")
	    local skinConfig = remote.heroSkin:getSkinConfigDictBySkinId(tonumber(skins[2]))
	    if q.isEmpty(skinConfig) == false then
	    	local characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(skinConfig.character_id)
	        self._ccbOwner.node_avatar:removeAllChildren()
	        self._skinAvatar = QUIWidgetHeroInformation.new()
	        self._ccbOwner.node_avatar:addChild(self._skinAvatar)
		    self._skinAvatar:setAvatarByHeroInfo({skinId = skinConfig.skins_id}, skinConfig.character_id, 1)
		    self._skinAvatar:setNameVisible(false)

		    self._ccbOwner.tf_finalAward_title:setString((skinConfig.skins_name or "").."·"..(characterConfig.name or ""))
		end
	end
end

function QUIDialogActivitySoulLetter:checkRedTips()
	local activityInfo = self._activityProxy:getActivityInfo()

	--一键领奖
	self._ccbOwner.tf_noAward_tip:setVisible(false)
	self._ccbOwner.node_btn_recive:setVisible(false)
	self._ccbOwner.node_btn_recive_for_task:setVisible(false)
	self._ccbOwner.node_btn_activeBestElite:setVisible(false)
	local eliteUnlock = self._activityProxy:checkEliteUnlock()
	local awardTip = self._activityProxy:checkAwardTips() 
	if eliteUnlock then
		--充值88
		if activityInfo.buyState == 1 and self._activityProxy:checkOpen78Recharge() then
	   	 	if awardTip == false then
				self._ccbOwner.node_btn_activeBestElite:setVisible(true)
				self._ccbOwner.node_btn_recive:setVisible(false)
			else	
				self._ccbOwner.node_btn_recive:setVisible(true)
			end
		else
	   	 	if awardTip == false then
				self._ccbOwner.tf_noAward_tip:setVisible(activityInfo.level < #self._awardDataList)
				self._ccbOwner.node_btn_recive:setVisible(false)
			else	
				self._ccbOwner.node_btn_recive:setVisible(true)
			end
		end

		local taskTip = self._activityProxy:checkAwardTips(self._activityProxy.TAB_TASK) 
		self._ccbOwner.node_btn_recive_for_task:setVisible(taskTip)
	end

	self._ccbOwner.node_lock:setVisible(not eliteUnlock)
	self._ccbOwner.node_btn_activeElite:setVisible(not eliteUnlock)

	--奖励领取红点
	self._ccbOwner.sp_award_tips:setVisible(awardTip)

	--任务奖励红点
	self._ccbOwner.sp_task_tips:setVisible(self._activityProxy:checkTaskTips())

    --激活精英红点
	self._ccbOwner.sp_activeElite_tips:setVisible(self._activityProxy:checkEliteActiveTips())
end

function QUIDialogActivitySoulLetter:_onTriggerAward()
	if self._tab == self._activityProxy.TAB_AWARD then return end
	app.sound:playSound("common_small")

	self._tab = self._activityProxy.TAB_AWARD
	self:setTabStatus()
end

function QUIDialogActivitySoulLetter:_onTriggerTask()
	if self._tab == self._activityProxy.TAB_TASK then return end
	app.sound:playSound("common_small")

	self._tab = self._activityProxy.TAB_TASK
	self:setTabStatus()
end
 
function QUIDialogActivitySoulLetter:_onTriggerBuyExp(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_exp) == false then return end
	
	self:_buyExp()
end

function QUIDialogActivitySoulLetter:_onTriggerBuyExp1(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_exp1) == false then return end

	self:_buyExp()
end

function QUIDialogActivitySoulLetter:_buyExp()
	if self._isSHowLevelAnimation then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterBuyExp", 
		options = { callBack = function(addLevel, exp)
		if self:safeCheck() then
			if addLevel and exp then
				self:showLevelUpTip(addLevel, exp)
			end
		end
	end}})
end

function QUIDialogActivitySoulLetter:showLevelUpTip(level, exp, isMultiple)
	self._isSHowLevelAnimation = true
	if not self._effect then
		self._effect =  QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._effect)
	end
	self._effect:stopAnimation()

	self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
		self._isSHowLevelAnimation = false
		ccbOwner.node_openDouble:setVisible(isMultiple == true)
   		ccbOwner.title_skill:setString("手札经验+"..tostring(exp))
   		if level and level > 0 then
   			ccbOwner.node_1:setVisible(true)
   			ccbOwner.tf_desc1:setString("手札等级+"..level)
   		else
   			ccbOwner.node_1:setVisible(false)
   		end
    end)
end

function QUIDialogActivitySoulLetter:_onTriggerBuyElite(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_elite) == false then return end
	app.sound:playSound("common_small")

	self:_onTriggerTask()
end

function QUIDialogActivitySoulLetter:_onTriggerFinalAward(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_final_award) == false then return end
	app.sound:playSound("common_small")

	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterAwardPreview", 
	-- 		options = {awards = self._awardDataList}})
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterAwardPreviewNew", 
			options = {awards = self._awardDataList}})	
end

function QUIDialogActivitySoulLetter:_onTriggerReciveAll(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_receive) == false then return end
	app.sound:playSound("common_small")
	
	local awards = self._activityProxy:getCanReciveAward(self._tab)

	if q.isEmpty(awards) then
		app.tip:floatTip("魂师大人，当前没有奖励可以领取")
	else
		self:reciveAward(awards)
	end
end

function QUIDialogActivitySoulLetter:_onTriggerReciveAllTask(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_receive_for_task) == false then return end
	app.sound:playSound("common_small")
	
	local awards = self._activityProxy:getCanReciveAward(self._tab)

	if q.isEmpty(awards) then
		app.tip:floatTip("魂师大人，当前没有奖励可以领取")
	else
		self:reciveTaskAward(awards)
	end
end

function QUIDialogActivitySoulLetter:_onTriggerActiveElite(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_activeElite) == false then return end
	app.sound:playSound("common_small")

	app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SOUL_LETER_ACTIVE_ELITE)
	self._ccbOwner.sp_activeElite_tips:setVisible(false)

	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterActiveElite",options = { expCallBack = function()
	-- 	self:_buyExp()
	-- end}})
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySoulLetterActiveEliteNew",options = { expCallBack = function()
		self:_buyExp()
	end}})	
end

function QUIDialogActivitySoulLetter:_onTriggerActiveBestElite(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_activeBestElite) == false then return end
	app.sound:playSound("common_small")

	--app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterActiveElite"})
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterActiveElite",options = { expCallBack = function()
	-- 	self:_buyExp()
	-- end}})
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySoulLetterActiveEliteNew",options = { expCallBack = function()
		self:_buyExp()
	end}})		
end

function QUIDialogActivitySoulLetter:_onTriggerHelp()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulLetterHelp",
		options = {helpType = "help_battle_pass"}})
end

function QUIDialogActivitySoulLetter:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivitySoulLetter:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivitySoulLetter
