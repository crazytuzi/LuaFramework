--TEnterCopy.lua
--/*-----------------------------------------------------------------
 --* Module:  TEnterCopy.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 参加副本(只参加即可)
 -------------------------------------------------------------------*/

TEnterCopy=class(TargetBase)

function TEnterCopy:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onEnterCopy")
	end
end

function TEnterCopy:onEnterCopy(player, copyType)
	if not (copyType == self._context.param1) then
		return
	end

	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onEnterCopy")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TEnterCopy:completed()
	return self._state >= self._context.param2
end