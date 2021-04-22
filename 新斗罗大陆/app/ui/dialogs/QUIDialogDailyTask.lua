--
-- Author: wkwang
-- Date: 2014-11-15 11:21:55
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDailyTask = class("QUIDialogDailyTask", QUIDialog)

local QUIWidgetDailyTaskCell = import("..widgets.QUIWidgetDailyTaskCell")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetDailyTaskAchievement = import("..widgets.QUIWidgetDailyTaskAchievement")

QUIDialogDailyTask.MAX_SHOW_NUM = 3


QUIDialogDailyTask.TASK_TYPE_DAILY = 1
QUIDialogDailyTask.TASK_TYPE_WEEKLY = 2
QUIDialogDailyTask.WEEKLY_TASK_OFFSIDE = 8

function QUIDialogDailyTask:ctor(options)
	local ccbFile = "ccb/Dialog_DailyMission.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOneGet", callback = handler(self, self._onTriggerOneGet)},
		{ccbCallbackName = "onTriggerDaily", callback = handler(self, self._onTriggerDaily)},
		{ccbCallbackName = "onTriggerWeekly", callback = handler(self, self._onTriggerWeekly)},
	}
	QUIDialogDailyTask.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setScalingVisible(true)
	page:setManyUIVisible()

	self._achievementWidget = QUIWidgetDailyTaskAchievement.new()
	self._ccbOwner.node_achievement:addChild(self._achievementWidget)
	self._cellTbls = {}
	self._items = {}
	self._taskConfigs = {}
	self._itemBoxAniamtion = false
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height
	self._ccbOwner.frame_tf_title:setString("每日任务")
	self._ccbOwner.node_right_center:setVisible(false)
	self._ccbOwner.node_daily:setVisible(false)
	self._ccbOwner.node_weekly:setVisible(false)
    ui.tabButton(self._ccbOwner.tab_daily, "每日")
    ui.tabButton(self._ccbOwner.tab_weekly, "每周")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.tab_daily)
    table.insert(tabs, self._ccbOwner.tab_weekly)
    self._tabManager = ui.tabManager(tabs)


	self:initListView()
end


function QUIDialogDailyTask:_switchTag(detailType , first)
	remote.task:setCurTaskType(detailType)
    if detailType == QUIDialogDailyTask.TASK_TYPE_DAILY then
		self._ccbOwner.frame_tf_title:setString("每日任务")
        self._tabManager:selected(self._ccbOwner.tab_daily)
		if app.unlock:getUnlockDailyTask() then
			self._ccbOwner.btn_one:setVisible(true) --屏蔽一键领取
			self._ccbOwner.node_one_effect:setVisible(true)
		else
			self._ccbOwner.btn_one:setVisible(false)
		end 
    elseif detailType == QUIDialogDailyTask.TASK_TYPE_WEEKLY then
		self._ccbOwner.frame_tf_title:setString("每周任务")
        self._tabManager:selected(self._ccbOwner.tab_weekly)
		if remote.task:checkWeeklyTaskOneKeyUnlock(false) then
			self._ccbOwner.btn_one:setVisible(true) --屏蔽一键领取
			self._ccbOwner.node_one_effect:setVisible(true)
		else
			self._ccbOwner.btn_one:setVisible(false)
		end
    end

	if app:getUserData():getValueForKey("UNLOCK_TASKS_REWARDS"..remote.user.userId) then
		self._ccbOwner.node_one_effect:setVisible(false)
	end

	self:refreshData()
	self:initListView(first)
end

function QUIDialogDailyTask:viewDidAppear()
	QUIDialogDailyTask.super.viewDidAppear(self)

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.TASK_UPDATE_EVENT, handler(self, self._taskInfoUpdate))

    self._taskProxy = cc.EventProxy.new(remote.task)
    self._taskProxy:addEventListener(remote.task.EVENT_DONE, handler(self, self._taskInfoUpdate))
    self._taskProxy:addEventListener(remote.task.EVENT_TIME_DONE, handler(self, self._taskInfoUpdate))

    self:setInfo()

	self:addBackEvent()
end

function QUIDialogDailyTask:viewWillDisappear()
	QUIDialogDailyTask.super.viewWillDisappear(self)
    self._remoteProxy:removeAllEventListeners()
    self._taskProxy:removeAllEventListeners()

	self:removeBackEvent()

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
end

function QUIDialogDailyTask:setInfo()
	if remote.task:checkWeeklyTaskUnlock(false) then
		self._ccbOwner.node_daily:setVisible(true)
		self._ccbOwner.node_weekly:setVisible(true)
		if not remote.task:dailyTaskRedTips() and remote.task:weeklyTaskRedTips() then
			self._task_type = QUIDialogDailyTask.TASK_TYPE_WEEKLY
		else
			self._task_type = QUIDialogDailyTask.TASK_TYPE_DAILY
		end
		local last_task_type = remote.task:getCurTaskType()
		if last_task_type ~= remote.task.TASK_TYPE_NONE then
			self._task_type = last_task_type
			remote.task:weeklyTaskGetInfo(function()
				if self:safeCheck() then
					self:_switchTag(self._task_type , true) 
				end
			end)
			self._achievementWidget:updateWeeklyInfo()
		else
			remote.task:weeklyTaskGetInfo()
			self:_switchTag(self._task_type , true)  
		end

	else
		self._task_type = QUIDialogDailyTask.TASK_TYPE_DAILY
		if app.unlock:getUnlockDailyTask() then
				self._ccbOwner.node_one_effect:setVisible(true)
			self._ccbOwner.btn_one:setVisible(true) --屏蔽一键领取
		else
			self._ccbOwner.btn_one:setVisible(false)
		end 
		if app:getUserData():getValueForKey("UNLOCK_TASKS_REWARDS"..remote.user.userId) then
			self._ccbOwner.node_one_effect:setVisible(false)
		end
		self:refreshData()
		self:initListView(true)
	end
end

function QUIDialogDailyTask:initListView(actionflag)
	if self._itemBoxAniamtion == true then return end
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetDailyTaskCell.new()
					item:addEventListener(QUIWidgetDailyTaskCell.EVENT_QUICK_LINK, handler(self,self.quickLinkHandler))
					item:addEventListener(QUIWidgetDailyTaskCell.EVENT_CLICK, handler(self, self.cellClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_r_done", "_onTriggerClick", nil, "true")
                list:registerBtnHandler(index, "btn_r_go", "_onTriggerGo", nil, "true")
	            return isCacheNode
	        end,
	        curOriginOffset = 7,
	        contentOffsetX = 10,
	        curOffset = 10,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._items})
	end

	if actionflag then
		self:taskBoxRunOutAction()
	end
end

function QUIDialogDailyTask:taskBoxRunOutAction()
	if self._itemBoxAniamtion == true then return end
	self._listViewLayout:setCanNotTouchMove(true)
	self._itemBoxAniamtion = true
	local index = 1
	for index = 1,QUIDialogDailyTask.MAX_SHOW_NUM do
		local itemBox1
		if self._listViewLayout then
			itemBox1 = self._listViewLayout:getItemByIndex(index)
		end
		if itemBox1 ~= nil then
			local posx,posy = itemBox1:getPosition()
			itemBox1:setPosition(ccp(posx,posy-self._itemHeight))	
		end
	end

	self.func1 = function()
		self._checkItemScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:taskBoxRunInAction()
			end
		end, 0.01)
	end
	self.func1()
end 

function QUIDialogDailyTask:taskBoxRunInAction()
	self._itemBoxAniamtion = true
	self.time = 0.12
	local index = 1
	self.func2 = function()
		if index <= QUIDialogDailyTask.MAX_SHOW_NUM then
			local itemBox1 = self._listViewLayout:getItemByIndex(index)
			if itemBox1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(itemBox1, self.time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(self.time, ccp(0,self._itemHeight))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				itemBox1:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, 0.04)
		else
			self._itemBoxAniamtion = false
			self._listViewLayout:setCanNotTouchMove(false)
		end
	end
	self.func2()
end 

function QUIDialogDailyTask:refreshData()
    if self._task_type == QUIDialogDailyTask.TASK_TYPE_DAILY then
		self._taskConfigs = remote.task:getDailyTask()
    elseif self._task_type == QUIDialogDailyTask.TASK_TYPE_WEEKLY then
		self._taskConfigs = remote.task:getWeeklyTask()
    end

	self._items = {}
	for _,value in pairs(self._taskConfigs) do
		-- 不显示月卡, 月卡被放在精彩活动里@qinyuanji
		if (value.config.label ~= nil and value.config.module ~= "月卡") then
			--xurui: 巨龙之战任务解锁提交比较特殊，先在这里屏蔽，后面再优化
			if value.config.id_1 ~= 11000001 or (value.config.index == "103400" and remote.unionDragonWar:checkDragonWarUnlock()) then
				if app.unlock:checkLevelUnlock(value.display_level) and app.unlock:checkDungeonUnlock(value.unlock) and value.isShow == true then
					table.insert(self._items, value)
				end
			end
		end
	end
	local totalCount = #self._items
	table.sort(self._items, function (a,b)
			if a.state ~= b.state then
	        	return a.state > b.state
	        end
			if a.config.sort ~= b.config.sort then
				return (a.config.sort or totalCount) < (b.config.sort or totalCount)
			end
	        if (a.stepNum or 0) == (b.stepNum or 0) then
	        	return a.config.label < b.config.label
	        else
	        	return (a.stepNum or 0) > (b.stepNum or 0)
	        end
        end)

	local isShow = not next(self._items)

	self._ccbOwner.node_complete:setVisible(isShow)
	self._ccbOwner.sp_finash:setVisible(false)
	

	self._ccbOwner.node_tips_daily:setVisible(remote.task:dailyTaskRedTips())
	self._ccbOwner.node_tips_weekly:setVisible(remote.task:weeklyTaskRedTips())

    if self._task_type == QUIDialogDailyTask.TASK_TYPE_DAILY then
		self._achievementWidget:updateInfo()
    elseif self._task_type == QUIDialogDailyTask.TASK_TYPE_WEEKLY then
		self._achievementWidget:updateWeeklyInfo()
    end

end

function QUIDialogDailyTask:quickLinkHandler(event)
	if self._isMoving == true then return end
    app.sound:playSound("common_small")
	remote.task:quickLink(event.index)
end

function QUIDialogDailyTask:_taskInfoUpdate()
	self:refreshData()
	self:initListView()
end

function QUIDialogDailyTask:_onTriggerOneGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")
    if not app:getUserData():getValueForKey("UNLOCK_TASKS_REWARDS"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_TASKS_REWARDS"..remote.user.userId, "true")
        self._ccbOwner.node_one_effect:setVisible(false)
    end 	
	if self._task_type == QUIDialogDailyTask.TASK_TYPE_DAILY then
		self:_onTriggerOneGetDaily()
	else
		self:_onTriggerOneGetWeekly()
	end
    
end

function QUIDialogDailyTask:_onTriggerOneGetDaily()

	local ids = {}
	local completedIds = {}
	local expiredIds = {}
	local uncompletedIds = {}
	-- local awards = {}
	local taskPoint = {}
	for _,taskInfo in pairs(self._taskConfigs) do
		if taskInfo.config.label ~= nil and taskInfo.config.module ~= "月卡" then
	    	if taskInfo.state == remote.task.TASK_DONE then
	    		print("11111111111")
				table.insert(ids, taskInfo.config.index)
	    		if taskInfo.config.meiri_points > 0 then
	    			-- table.insert(awards, {id = nil, typeName = ITEM_TYPE.TASK_POINT, count = taskInfo.config.meiri_points})
					table.insert(taskPoint, {id = nil, typeName = ITEM_TYPE.TASK_POINT, count = taskInfo.config.meiri_points})
				end
	    	end
		end
	end

	local teamLevel = remote.user.dailyTeamLevel or 1
	local awardsData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 1)
	local dailyTaskRewardInfo = remote.user.dailyTaskRewardInfo or {}
	local dailyTaskRewardIntegral = remote.user.dailyTaskRewardIntegral
	local isBoxAward = false
	for i = 1, 4, 1 do
		local isGet = false
		for _, index in ipairs(dailyTaskRewardInfo) do
			if index == i then
				isGet = true
				break
			end
		end
		local data = awardsData[i]
		if isGet == false and dailyTaskRewardIntegral >= data.condition then
			isBoxAward = true
			break
		end
	end
    if next(ids) == nil and isBoxAward == false then
            app.tip:floatTip("没有可领取的每日任务")
        return
    end

	app:getClient():dailyTaskComplete(ids,true, function (data)
		if self._achievementWidget then
			self._achievementWidget:updateInfo()
		end
		local awards = data.awards or {}
		if #taskPoint > 0 then
			for _, value in ipairs(taskPoint or {}) do
		    	table.insert(awards, {id = value.id, typeName = (value.typeName or value.type), count = value.count})
		    	remote.activity:updateLocalDataByType(503,1)
		        --xurui: 更新每日祭祀活跃任务
		        remote.union.unionActive:updateActiveTaskProgress(20003, value.count)
		    end
		end
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
    			remote.redpacket:openFreeTimeAlert(function()
					remote.user:checkTeamUp()
				end, true)
    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得每日任务奖励")
    	if self:safeCheck() then
			self:_taskInfoUpdate()
		end
	end)
end


function QUIDialogDailyTask:_onTriggerOneGetWeekly()

	local ids = {}
	local completedIds = {}
	local expiredIds = {}
	local uncompletedIds = {}
	-- local awards = {}
	local taskPoint = {}
	for _,taskInfo in pairs(self._taskConfigs) do
		if taskInfo.config.label ~= nil and taskInfo.config.module ~= "月卡" then
	    	if taskInfo.state == remote.task.TASK_DONE then
	    		print("222222")
				table.insert(ids, taskInfo.config.index)
				if taskInfo.config.meiri_points > 0 then
	    			-- table.insert(awards, {id = nil, typeName = ITEM_TYPE.TASK_POINT, count = taskInfo.config.meiri_points})
					table.insert(taskPoint, {id = nil, typeName = ITEM_TYPE.TASKWK_POINT, count = taskInfo.config.meiri_points})
				end
	    	end
		end
	end

	local teamLevel = remote.user.level or 1
	local awardsData = QStaticDatabase:sharedDatabase():getDaliyTaskScoreAwardsByLevel(teamLevel, 3)
	local weeklyTaskRewardInfo = remote.task.weeklyTaskRewardInfo or {}
	local weeklyTaskRewardIntegral = remote.task.weeklyTaskRewardIntegral
	-- QPrintTable(weeklyTaskRewardInfo)
	local isBoxAward = false
	for i = 1 + QUIDialogDailyTask.WEEKLY_TASK_OFFSIDE, 4 + QUIDialogDailyTask.WEEKLY_TASK_OFFSIDE, 1 do
		local isGet = false
		for _, index in pairs(weeklyTaskRewardInfo) do
			if tonumber(index) == i then
				isGet = true
				break
			end
		end
		local data = awardsData[i]
		if data and isGet == false and weeklyTaskRewardIntegral >= data.condition then
			isBoxAward = true
			break
		end
	end
    if next(ids) == nil and isBoxAward == false then
            app.tip:floatTip("没有可领取的每周任务")
        return
    end



	app:getClient():weeklyTaskComplete(ids,true, function (data)
		if self._achievementWidget then
			self._achievementWidget:updateWeeklyInfo()
		end
		local awards = data.awards or {}
		if #taskPoint > 0 then
			for _, value in ipairs(taskPoint or {}) do
		    	table.insert(awards, {id = value.id, typeName = (value.typeName or value.type), count = value.count})
		    	remote.activity:updateLocalDataByType(503,1)
		    end
		end		
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards, callBack = function ()
    			remote.redpacket:openFreeTimeAlert(function()
					remote.user:checkTeamUp()
				end, true)
    		end}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得每周任务奖励")
    	if self:safeCheck() then
			self:_taskInfoUpdate()
		end
	end)
end


function QUIDialogDailyTask:_onTriggerDaily()
    if self._task_type ~= QUIDialogDailyTask.TASK_TYPE_DAILY then
        app.sound:playSound("common_switch")
        -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        -- page:setManyUIVisible()
        -- page.topBar:showWithHeroOverView()
        -- remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
        -- remote.herosUtil:requestSkillUp()
        self._task_type = QUIDialogDailyTask.TASK_TYPE_DAILY
        self:_switchTag(self._task_type)    
    end 
end

function QUIDialogDailyTask:_onTriggerWeekly()
    if self._task_type ~= QUIDialogDailyTask.TASK_TYPE_WEEKLY then
        -- app.sound:playSound("common_switch")
        -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        -- page:setManyUIVisible()
        -- page.topBar:showWithHeroOverView()
        -- remote.herosUtil:dispatchEvent({name = QHerosUtils.EVENT_HERO_EXP_CHECK})
        -- remote.herosUtil:requestSkillUp()
        self._task_type = QUIDialogDailyTask.TASK_TYPE_WEEKLY
        self:_switchTag(self._task_type)    
    end 
end




function QUIDialogDailyTask:cellClickHandler(event)
	if self._isMoving == true then return end
	app.sound:playSound("common_small")
	local task_idx = event.index
	if self._task_type == QUIDialogDailyTask.TASK_TYPE_DAILY then
		self:_onClickDailyTask(task_idx)
	else
		self:_onClickWeeklyTask(task_idx)
	end
end


function QUIDialogDailyTask:_onClickWeeklyTask(task_idx)
    local taskInfo = remote.task:getDailyTaskById(task_idx)
	local awards = {}
	if taskInfo.config.task_level_drop ~= nil then
		awards = QStaticDatabase.sharedDatabase():getLevelDropById(taskInfo.config.task_level_drop, remote.user.level)
	else
		if (taskInfo.config.levellimit_1 or 0) <= remote.user.level then 
			if taskInfo.config.id_1 ~= nil or taskInfo.config.type_1 ~= nil then
				table.insert(awards, {id = taskInfo.config.id_1, typeName = taskInfo.config.type_1, count = taskInfo.config.num_1})
			end
		end
		if (taskInfo.config.levellimit_2 or 0) <= remote.user.level then
			if taskInfo.config.id_2 ~= nil or taskInfo.config.type_2 ~= nil  then
				table.insert(awards, {id = taskInfo.config.id_2, typeName = taskInfo.config.type_2, count = taskInfo.config.num_2})
			end
		end
	end
	if taskInfo.config.meiri_points > 0 then
			table.insert(awards, {id = nil, typeName = ITEM_TYPE.TASKWK_POINT, count = taskInfo.config.meiri_points})
	end
	app:getClient():weeklyTaskComplete({task_idx}, false, function (data)
			remote.activity:updateLocalDataByType(503,1)
			if self._achievementWidget then
				self._achievementWidget:updateWeeklyInfo()
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards, callBack = function ()
					remote.user:checkTeamUp()
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得每周任务奖励")
			if self:safeCheck() then
				self:_taskInfoUpdate()
			end
	end)
end



function QUIDialogDailyTask:_onClickDailyTask(task_idx)
    local taskInfo = remote.task:getDailyTaskById(task_idx)
	local awards = {}
	if taskInfo.config.task_level_drop ~= nil then
		awards = QStaticDatabase.sharedDatabase():getLevelDropById(taskInfo.config.task_level_drop, remote.user.level)
	else
		if (taskInfo.config.levellimit_1 or 0) <= remote.user.level then 
			if taskInfo.config.id_1 ~= nil or taskInfo.config.type_1 ~= nil then
				table.insert(awards, {id = taskInfo.config.id_1, typeName = taskInfo.config.type_1, count = taskInfo.config.num_1})
			end
		end
		if (taskInfo.config.levellimit_2 or 0) <= remote.user.level then
			if taskInfo.config.id_2 ~= nil or taskInfo.config.type_2 ~= nil  then
				table.insert(awards, {id = taskInfo.config.id_2, typeName = taskInfo.config.type_2, count = taskInfo.config.num_2})
			end
		end
	end

	if taskInfo.config.meiri_points > 0 then
		table.insert(awards, {id = nil, typeName = ITEM_TYPE.TASK_POINT, count = taskInfo.config.meiri_points})
	end
	if taskInfo.state == remote.task.TASK_DONE_TOKEN then
		app:getClient():dailyTaskCompleteByToken({task_idx}, function ()
			remote.activity:updateLocalDataByType(503,1)
	        --xurui: 更新每日建设活跃任务
	        remote.union.unionActive:updateActiveTaskProgress(20003, taskInfo.config.meiri_points)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards, callBack = function ()
					remote.user:checkTeamUp()
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得每日任务奖励")
			if self:safeCheck() then
				self:_taskInfoUpdate()
			end
		end)
	else
		app:getClient():dailyTaskComplete({task_idx}, false, function ()
			remote.activity:updateLocalDataByType(503,1)
	        --xurui: 更新每日建设活跃任务
	        remote.union.unionActive:updateActiveTaskProgress(20003, taskInfo.config.meiri_points)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards, callBack = function ()
					remote.user:checkTeamUp()
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得每日任务奖励")
			if self:safeCheck() then
				self:_taskInfoUpdate()
			end
		end)
	end
end


function QUIDialogDailyTask:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogDailyTask:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogDailyTask:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogDailyTask:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogDailyTask