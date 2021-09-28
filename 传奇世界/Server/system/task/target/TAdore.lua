--TAdore.lua
--/*-----------------------------------------------------------------
 --* Module:  TAdore.lua
 --* Author:  seezon
 --* Modified: 2016Äê1ÔÂ18ÈÕ
 --* Purpose: Ä¤°Ý
 -------------------------------------------------------------------*/

TAdore=class(TargetBase)

function TAdore:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onAdore")
	end
end

function TAdore:onAdore(player)
	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onAdore")
		self._task:validate()
	end

	self:taskInfoSave()
	
end

function TAdore:completed()
	return self._state >= self._context.param1
end