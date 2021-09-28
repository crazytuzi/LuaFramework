--TUpStarTask.lua
--/*-----------------------------------------------------------------
 --* Module:  TUpStarTask.lua
 --* Author:  seezon
 --* Modified: 2014年10月31日
 --* Purpose: 日常任务奖励升星
 -------------------------------------------------------------------*/

TUpStarTask=class(TargetBase)

function TUpStarTask:__init(task, context, state)
	self._state = state or 0
	
	local hasfinishAll = false

	--行会公共任务
	if  self:getTaskPlayer() then
		local roleId = self:getTaskPlayer():getID()
		local roleInfo = g_taskMgr:getRoleTaskInfo(roleId)
		local dailyTask = roleInfo:getDailyTask()

	
		if dailyTask then
			if dailyTask:getCurrentLoop() >= roleInfo:getMaxDailyLoop() then
				hasfinishAll = true
			end
		else
			hasfinishAll = true
		end
	end

	if hasfinishAll then
		self:setState(self._state + 1)
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUpStarTask")
	end
end

function TUpStarTask:onUpStarTask(player)
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onUpStarTask")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUpStarTask:completed()
	return self._state >= self._context.param1
end