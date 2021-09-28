--升到某级任务
TaskUpgradeLevel =BaseClass(TaskBehavior)

function TaskUpgradeLevel:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.UpgradeLevel)
	local rtnIsTaskFinish, playerLimitLevel = self:IsTaskFinish()
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		self:SubmitTask()
		self:ClearEvent()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		self:PopUpUpgradeLevelTips(playerLimitLevel)
	end
end

function TaskUpgradeLevel:__init(taskData)
	self:InitEvent()
end

function TaskUpgradeLevel:InitEvent()
	TaskBehavior.InitEvent(self)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) self:HandlePlayerLevChange(key ,value , pre) end)
end

function TaskUpgradeLevel:ClearEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function TaskUpgradeLevel:__delete()
	self:ClearEvent()
end

function TaskUpgradeLevel:HandlePlayerLevChange(key ,value , pre)
	if key == "level" then
		local rtnIsTaskFinish, playerLimitLevel = self:IsTaskFinish()
		if rtnIsTaskFinish == true then
			self:SubmitTask()
			self:ClearEvent()
		end
	end
end

function TaskUpgradeLevel:IsTaskFinish()
	local rtnIsTaskFinish = false
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	local curPlayerLevel = -1
	local playerLimitLevel = -1
	if mainPlayer then
		curPlayerLevel = mainPlayer.level
	end

	local taskDataObj = self:GetTaskData()
	if taskDataObj then
		local taskTarget =  taskDataObj:GetTaskTarget() or {}
		if not TableIsEmpty(taskTarget) then
			playerLimitLevel = taskTarget.targetParam[1]
		end
	end
	if curPlayerLevel ~= -1 and playerLimitLevel ~= -1 then
		if curPlayerLevel >= playerLimitLevel then
			rtnIsTaskFinish = true
		end
	end
	
	return rtnIsTaskFinish, playerLimitLevel
end

function TaskUpgradeLevel:PopUpUpgradeLevelTips(limitLev)
	if limitLev == 100 then
		local taskDataObj = self:GetTaskData()
		if taskDataObj then
			UIMgr.Win_FloatTip(taskDataObj:GetTaskContent())
		end
	else
		UIMgr.Win_FloatTip(string.format("请将等级升到%s", limitLev))
	end
end
