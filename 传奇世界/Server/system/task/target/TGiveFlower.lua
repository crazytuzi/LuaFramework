--TGiveFlower.lua
--/*-----------------------------------------------------------------
 --* Module:  TGiveFlower.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 赠花
 -------------------------------------------------------------------*/

TGiveFlower=class(TargetBase)

function TGiveFlower:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onGiveFlower")
	end
end

function TGiveFlower:onGiveFlower(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onGiveFlower")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TGiveFlower:completed()
	return self._state >= self._context.param1
end