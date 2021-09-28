--TDrink.lua
--/*-----------------------------------------------------------------
 --* Module:  TDrink.lua
 --* Author:  seezon
 --* Modified: 2016Äê1ÔÂ18ÈÕ
 --* Purpose: ÏÉÎÌ´Í¾Æ
 -------------------------------------------------------------------*/

TDrink=class(TargetBase)

function TDrink:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onDrink")
	end
end

function TDrink:onDrink(player)
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onDrink")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TDrink:completed()
	return self._state >= self._context.param1
end