--TUseIngot.lua
--/*-----------------------------------------------------------------
 --* Module:  TUseIngot.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 在商城使用元宝
 -------------------------------------------------------------------*/

TUseIngot=class(TargetBase)

function TUseIngot:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onUseIngot")
	end
end

function TUseIngot:onUseIngot(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onUseIngot")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TUseIngot:completed()
	return self._state >= self._context.param1
end