--TKillOther.lua
--/*-----------------------------------------------------------------
 --* Module:  TKillOther.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 击杀玩家
 -------------------------------------------------------------------*/

TKillOther=class(TargetBase)

function TKillOther:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onKillOther")
	end
end

function TKillOther:onKillOther(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onKillOther")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TKillOther:completed()
	return self._state >= self._context.param1
end