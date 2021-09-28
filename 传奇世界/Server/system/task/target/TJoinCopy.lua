--TJoinCopy.lua
--/*-----------------------------------------------------------------
 --* Module:  TJoinCopy.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 参加副本
 -------------------------------------------------------------------*/

TJoinCopy=class(TargetBase)

function TJoinCopy:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onJoinCopy")
	end
end

function TJoinCopy:onJoinCopy(player, copyType)
	if not (copyType == self._context.param1) then
		return
	end

	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onJoinCopy")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TJoinCopy:completed()
	return self._state >= self._context.param2
end