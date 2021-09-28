--TNPCUseGot.lua
--/*-----------------------------------------------------------------
 --* Module:  TNPCUseGot.lua
 --* Author:  goddard
 --* Modified: 2016年5月25日
 --* Purpose: 使用道具任务目标
 -------------------------------------------------------------------*/

TNPCUseGot=class(TargetBase)

function TNPCUseGot:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onNPCUseGot")
	end
end

function TNPCUseGot:onNPCUseGot(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onNPCUseGot")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TNPCUseGot:completed()
	local b = (self._state >= 1)
	return self._state >= 1
end