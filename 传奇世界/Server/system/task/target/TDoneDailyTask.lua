--TDoneDailyTask.lua
--/*-----------------------------------------------------------------
 --* Module:  TDoneDailyTask.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 完成日常任务
 -------------------------------------------------------------------*/

TDoneDailyTask=class(TargetBase)

function TDoneDailyTask:__init(task, context, state)
	self._state = state or 0

	--行会公共任务
	if  self:getTaskPlayer() then
		local curLoop = g_taskMgr:getDailyTaskLoop(self:getTaskPlayer())
		self:setState(curLoop - 1)
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onDoneDailyTask")
	end
end

function TDoneDailyTask:onDoneDailyTask(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onDoneDailyTask")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TDoneDailyTask:completed()
	return self._state >= self._context.param1
end