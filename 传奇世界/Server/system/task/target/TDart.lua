--TDart.lua
--/*-----------------------------------------------------------------
 --* Module:  TDart.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 运镖
 -------------------------------------------------------------------*/

TDart=class(TargetBase)

function TDart:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onDart")
	end
end

function TDart:onDart(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onDart")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TDart:completed()
	return self._state >= self._context.param1
end