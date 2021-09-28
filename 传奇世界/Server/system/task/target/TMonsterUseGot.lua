--TMonsterUseGot.lua
--/*-----------------------------------------------------------------
 --* Module:  TMonsterUseGot.lua
 --* Author:  goddard
 --* Modified: 2016年5月25日
 --* Purpose: 使用道具任务目标
 -------------------------------------------------------------------*/

TMonsterUseGot=class(TargetBase)

function TMonsterUseGot:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onMonsterUseGot")
	end
end

function TMonsterUseGot:onMonsterUseGot(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onMonsterUseGot")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TMonsterUseGot:completed()
	local b = (self._state >= 1)
	return self._state >= 1
end