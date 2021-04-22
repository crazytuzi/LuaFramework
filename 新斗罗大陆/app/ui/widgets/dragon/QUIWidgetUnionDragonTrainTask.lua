
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainTask = class("QUIWidgetUnionDragonTrainTask", QUIWidget)

local QNotificationCenter = import("....controllers.QNotificationCenter")

local QUIWidgetUnionDragonTrainTaskBall = import("...widgets.dragon.QUIWidgetUnionDragonTrainTaskBall")

function QUIWidgetUnionDragonTrainTask:ctor(options)
	local ccbFile = "ccb/Widget_Society_Dragon_Task.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTask", callback = handler(self, self._onTriggerTask)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerReceive", callback = handler(self, self._onTriggerReceive)},
		{ccbCallbackName = "onTriggerChest", callback = handler(self, self._onTriggerChest)},
	}
	QUIWidgetUnionDragonTrainTask.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._taskBallList = {}
	self._btnReceiveCount = 0
	self._isAni = false

	self:_init()
end

function QUIWidgetUnionDragonTrainTask:onEnter()
	QUIWidgetUnionDragonTrainTask.super.onEnter(self)

	self:_updateTaskBall()

	self._dragonProxy = cc.EventProxy.new(remote.dragon)
    self._dragonProxy:addEventListener(remote.dragon.NEW_DAY, handler(self, self._dragonProxyHandler))
    self._dragonProxy:addEventListener(remote.dragon.TASK_COMPLETE, handler(self, self._dragonProxyHandler))
    self._dragonProxy:addEventListener(remote.dragon.TASK_END, handler(self, self._dragonProxyHandler))
    self._dragonProxy:addEventListener(remote.dragon.TASK_REWARD_SHOW_END, handler(self, self._dragonProxyHandler))
    self._dragonProxy:addEventListener(remote.dragon.TASK_INFO_UPDATE, handler(self, self._dragonProxyHandler))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

	remote.dragon:openTaskRewardDialog()
end

function QUIWidgetUnionDragonTrainTask:onExit()
	QUIWidgetUnionDragonTrainTask.super.onExit(self)

    if self._countDownScheduler then
		scheduler.unscheduleGlobal(self._countDownScheduler)
		self._countDownScheduler = nil
	end
	
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

	self._dragonProxy:removeAllEventListeners()
end

function QUIWidgetUnionDragonTrainTask:exitFromBattleHandler()
	if remote.dragon.isSelectedTask and remote.dragon.selectTaskId == remote.dragon.FIGHT and not remote.dragon:getTaskCompleteState() then
		app.tip:floatTip("差一点就坚持到最后啦，再努力尝试一下吧")
	end
end

function QUIWidgetUnionDragonTrainTask:_dragonProxyHandler(event)
	if event.name == remote.dragon.NEW_DAY then
		self:_updateTaskBall()
		self:_updateBtnState()
		self:_updateInfo()
		self:_updateBoxState()
    elseif event.name == remote.dragon.TASK_COMPLETE then
    	self:_updateTaskBall()
		self:_updateBtnState()
		self:_updateInfo()
    elseif event.name == remote.dragon.TASK_END then
    	self:_updateTaskBall()
    	self:_updateBtnState()
    	self:_updateBoxState()
	elseif event.name == remote.dragon.TASK_REWARD_SHOW_END then
    	self:_updateBoxState()
	elseif event.name == remote.dragon.TASK_INFO_UPDATE then
		self:_updateTaskBall()
		self:_updateInfo()
    end
end

function QUIWidgetUnionDragonTrainTask:_resetAll()
	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			node:removeAllChildren()
			node:setVisible(true)
			index = index + 1
		else
			break
		end
	end
	-- index = 1
	-- while true do
	-- 	local btn = self._ccbOwner["btn_task_"..index]
	-- 	if btn then
	-- 		btn:setVisible(false)
	-- 		index = index + 1
	-- 	else
	-- 		break
	-- 	end
	-- end
	self._ccbOwner.btn_chest:setVisible(true)

	self._ccbOwner.node_chest:removeAllChildren()

	self._ccbOwner.node_doing:setVisible(false)
	self._ccbOwner.tf_explain:setVisible(false)
	index = 1
	while true do
		local node = self._ccbOwner["node_receive"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end
	self._btnReceiveCount = index - 1
	self._ccbOwner.node_go:setVisible(false)
	self._ccbOwner.node_task:setVisible(true)
	self._ccbOwner.node_end:setVisible(false)
	self._ccbOwner.ccb_box_effect:setVisible(false)
	self._ccbOwner.sp_go_tips:setVisible(false)
	self._ccbOwner.tf_tips:setVisible(true)
end

function QUIWidgetUnionDragonTrainTask:_init()
	self:_resetAll()

	self:_initTaskBall()
	self:_initBtnInfo()
	self:_initInfo()
	self:_updateBoxState()
end

function QUIWidgetUnionDragonTrainTask:_initTaskBall()
	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			local widgetBall = QUIWidgetUnionDragonTrainTaskBall.new({id = index})
			node:addChild(widgetBall)
			table.insert(self._taskBallList, widgetBall)
			index = index + 1
		else
			break
		end
	end
	self:_updateTaskBall()
end

function QUIWidgetUnionDragonTrainTask:_updateTaskBall()
	if not self._taskBallList or #self._taskBallList == 0 then return end

	for _, ball in ipairs(self._taskBallList) do
		ball:update()
	end
end

function QUIWidgetUnionDragonTrainTask:_initBtnInfo()
	for i = 1, self._btnReceiveCount, 1 do
		local taskMultipleInfo = remote.dragon:getTaskMultipleInfoByIndex(i)
		if taskMultipleInfo then 
			if taskMultipleInfo.multiple and taskMultipleInfo.multiple > 1 then
				self._ccbOwner["tf_receive"..i]:setString("领取"..taskMultipleInfo.multiple.."倍")
			else
				self._ccbOwner["tf_receive"..i]:setString("领 取")
			end
			if taskMultipleInfo.consume and taskMultipleInfo.consume > 0 then
				self._ccbOwner["node_consume"..i]:setVisible(true)
				self._ccbOwner["tf_consume"..i]:setString(taskMultipleInfo.consume)
			else
				self._ccbOwner["node_consume"..i]:setVisible(false)
			end
		else
			self._ccbOwner["tf_receive"..i]:setString("领 取")
			self._ccbOwner["node_consume"..i]:setVisible(false)
		end
	end
	self:_updateBtnState()
end

function QUIWidgetUnionDragonTrainTask:_updateBtnState()
	if remote.dragon:getTaskEndState() then
		self._ccbOwner.node_task:setVisible(false)
		self._ccbOwner.node_end:setVisible(true)
	else
		self._ccbOwner.node_task:setVisible(true)
		self._ccbOwner.node_end:setVisible(false)

		local index = 1
		-- while true do
		-- 	local btn = self._ccbOwner["btn_task_"..index]
		-- 	if btn then
		-- 		btn:setVisible(not remote.dragon.isSelectedTask)
		-- 		index = index + 1
		-- 	else
		-- 		break
		-- 	end
		-- end

		-- index = 1
		-- while true do
		-- 	local node = self._ccbOwner["node_receive"..index]
		-- 	if node then
		-- 		node:setVisible(remote.dragon:getTaskCompleteState())
		-- 		index = index + 1
		-- 	else
		-- 		break
		-- 	end
		-- end

		if remote.dragon.isSelectedTask then
			if remote.dragon:getTaskCompleteState() then
				self._ccbOwner.tf_tips:setVisible(false)
				self._ccbOwner.tf_go:setString("领 奖")
				self._ccbOwner.sp_go_tips:setVisible(true)
			else
				self._ccbOwner.tf_tips:setVisible(true)
				self._ccbOwner.tf_go:setString("前 往")
				self._ccbOwner.sp_go_tips:setVisible(false)
			end
		else
			self._ccbOwner.tf_go:setString("选 择")
			self._ccbOwner.sp_go_tips:setVisible(true)
			self._ccbOwner.tf_tips:setVisible(true)
		end
		self._ccbOwner.node_go:setVisible(true)
		-- self._ccbOwner.node_go:setVisible(not remote.dragon:getTaskCompleteState())
	end
end

function QUIWidgetUnionDragonTrainTask:_initInfo()
	local strExplain = remote.dragon:getTaskExplain()
	self._ccbOwner.tf_explain:setString(strExplain)
	self._ccbOwner.tf_explain:setVisible(true)

	self:_updateInfo()
end

function QUIWidgetUnionDragonTrainTask:_updateInfo()
	if remote.dragon.isSelectedTask and not remote.dragon:getTaskCompleteState() and not remote.dragon:getTaskEndState() then
		self._ccbOwner.node_doing:setVisible(true)
		self._ccbOwner.tf_explain:setVisible(false)
		if remote.dragon.selectTaskId == remote.dragon.TIME then
			self._ccbOwner.tf_doing_title:setString("打扫底座中，剩余时间：")
			-- 和时间有关的数据
			self:_updateCountDown()
			if self._countDownScheduler then
				scheduler.unscheduleGlobal(self._countDownScheduler)
				self._countDownScheduler = nil
			end
			self._countDownScheduler = scheduler.scheduleGlobal(function ()
				self:_updateCountDown()
			end, 1)
		elseif remote.dragon.selectTaskId == remote.dragon.QA then
			self._ccbOwner.tf_doing_title:setString("仙草培育中，还需培育：")
			local myTaskInfo = remote.dragon:getMyTaskInfo()
			local num = tonumber(remote.dragon:getTaskCompleteRequirementById(remote.dragon.selectTaskId)) - myTaskInfo.correctCount
			self._ccbOwner.tf_countdown:setString(num.."次")
		elseif remote.dragon.selectTaskId == remote.dragon.FIGHT then
			self._ccbOwner.tf_doing_title:setString("武魂试炼中，需要存活：")
			self._ccbOwner.tf_countdown:setString(remote.dragon:getTaskCompleteRequirementById(remote.dragon.selectTaskId).."秒")
		end
	else
		self._ccbOwner.node_doing:setVisible(false)
		self._ccbOwner.tf_explain:setVisible(true)
	end
end

function QUIWidgetUnionDragonTrainTask:_updateCountDown()
	local isStart, isComplete, countDownStr = remote.dragon:updateTimeByStartAt()
	if isStart and isComplete then
		if self._countDownScheduler then
			scheduler.unscheduleGlobal(self._countDownScheduler)
			self._countDownScheduler = nil
		end
		self._ccbOwner.node_doing:setVisible(false)
		remote.dragon:setTaskCompleteState(true)
	else
		self._ccbOwner.node_doing:setVisible(true)
		self._ccbOwner.tf_countdown:setString(countDownStr)
	end
end

function QUIWidgetUnionDragonTrainTask:_updateBoxState()
	local path = remote.dragon:getChestImgPath()
	self._boxImg = CCSprite:create(path)
	if self._boxImg then
		self._ccbOwner.node_chest:removeAllChildren()
		self._ccbOwner.node_chest:addChild(self._boxImg)
	end
	if remote.dragon:checkTaskBoxRedTips() then
		self._ccbOwner.ccb_box_effect:setVisible(true)
	else
		self._ccbOwner.ccb_box_effect:setVisible(false)
	end
end

function QUIWidgetUnionDragonTrainTask:_onTriggerTask(event, target)
	if app.sound ~= nil then
    	app.sound:playSound("common_small")
    end

    if remote.dragon.isSelectedTask and remote.dragon.selectTaskId > 0 then
    	local btn = self._ccbOwner["btn_task_"..remote.dragon.selectTaskId]
    	if btn ~= target then
    		app.tip:floatTip("魂师大人今天已经选择过任务了，要专心哦~")
    		return
    	end
    end
    
    if remote.dragon.isSelectedTask or remote.dragon:getTaskCompleteState() or remote.dragon:getTaskEndState() then return end

	local index = 1
	while true do
		local btn = self._ccbOwner["btn_task_"..index]
		if btn then
			if btn == target then
				-- print("QUIWidgetUnionDragonTrainTask:_onTriggerTask remote.dragon.selectTaskId = ", index)
				remote.dragon.selectTaskId = index
				break
			end
			index = index + 1
		else
			break
		end
	end

	self:_updateTaskBall()
end

function QUIWidgetUnionDragonTrainTask:_onTriggerGo(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_go) == false then return end
	if self._isAni then return end
	if app.sound ~= nil then
    	app.sound:playSound("common_small")
    end
	-- if remote.dragon:getTaskCompleteState() or remote.dragon:getTaskEndState() then return end
	if remote.dragon:getTaskEndState() then return end

	if not remote.dragon.selectTaskId or remote.dragon.selectTaskId == 0 then 
		app.tip:floatTip("请选择一个任务")
		return 
	end
	if not remote.dragon.isSelectedTask then
		remote.dragon:consortiaChooseTaskdRequest(remote.dragon.selectTaskId, function()
				remote.dragon:openTaskDialogByTaskId()
				self:_updateBtnState()
			end)
	else

		if remote.dragon:getTaskCompleteState() then
			remote.dragon:openTaskRewardDialog()
		else
			remote.dragon:openTaskDialogByTaskId()
		end
	end
end

function QUIWidgetUnionDragonTrainTask:_onTriggerReceive(event, target)
	-- if app.sound ~= nil then
 --    	app.sound:playSound("common_small")
 --    end
	-- if not remote.dragon:getTaskCompleteState() or remote.dragon:getTaskEndState() then return end

	-- local index = 1
	-- while true do
	-- 	local btn = self._ccbOwner["btn_receive"..index]
	-- 	if btn then
	-- 		if btn == target then
	-- 			remote.dragon:consortiaDragonGetTaskProgressRequest(index, false, function(data)
	-- 					if data and data.error == "NO_ERROR" then
	-- 						if data.prizes then
	-- 							if data.consortiaGetDragonInfoResponse and data.consortiaGetDragonInfoResponse.dragonExp then
	-- 								local tbl = string.split(data.consortiaGetDragonInfoResponse.dragonExp, "^")
	-- 								table.insert(data.prizes, {id = remote.dragon.EXP_RESOURCE_ID, type = remote.dragon.EXP_RESOURCE_TYPE, count = tonumber(tbl[2])})
	-- 							end
	-- 							remote.dragon:showRewardForDialog(data.prizes)
	-- 						else
	-- 							remote.dragon:dispatchTaskRewardShowEndEvent()
	-- 						end
	-- 					end
	-- 				end)
	-- 			break
	-- 		end
	-- 		index = index + 1
	-- 	else
	-- 		break
	-- 	end
	-- end
end

function QUIWidgetUnionDragonTrainTask:_onTriggerChest(event)
	if q.buttonEventShadow(event, self._boxImg) == false then return end
	if self._isAni then return end
	remote.dragon:openTaskBoxDialog()
end

function QUIWidgetUnionDragonTrainTask:setIsAnimation(isAni)
	self._isAni = isAni
end

return QUIWidgetUnionDragonTrainTask