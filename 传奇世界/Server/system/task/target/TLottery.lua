--TLottery.lua
--/*-----------------------------------------------------------------
 --* Module:  TLottery.lua
 --* Author:  seezon
 --* Modified: 2014Äê10ÔÂ8ÈÕ
 --* Purpose: ³é½±
 -------------------------------------------------------------------*/

TLottery=class(TargetBase)

function TLottery:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onLottery")
	end
end

function TLottery:onLottery(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onLottery")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TLottery:completed()
	return self._state >= self._context.param1
end