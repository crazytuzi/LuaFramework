--TStone.lua
--/*-----------------------------------------------------------------
 --* Module:  TStone.lua
 --* Author:  seezon
 --* Modified: 2016Äê1ÔÂ18ÈÕ
 --* Purpose: ÍÚ¿ó
 -------------------------------------------------------------------*/

TStone=class(TargetBase)

function TStone:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onStone")
	end
end

function TStone:onStone(player)
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onStone")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TStone:completed()
	return self._state >= self._context.param1
end