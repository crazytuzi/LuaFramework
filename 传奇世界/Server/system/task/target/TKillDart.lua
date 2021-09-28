--TKillDart.lua
--/*-----------------------------------------------------------------
 --* Module:  TKillDart.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 劫镖
 -------------------------------------------------------------------*/

TKillDart=class(TargetBase)

function TKillDart:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onKillDart")
	end
end

function TKillDart:onKillDart(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onKillDart")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TKillDart:completed()
	return self._state >= self._context.param1
end