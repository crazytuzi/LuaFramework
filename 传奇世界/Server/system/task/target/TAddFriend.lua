--TAddFriend.lua
--/*-----------------------------------------------------------------
 --* Module:  TAddFriend.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 增加好友
 -------------------------------------------------------------------*/

TAddFriend=class(TargetBase)

function TAddFriend:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onAddFriend")
	end
end

function TAddFriend:onAddFriend(player)
	self:setState(self:getState() + 1)

	if self:completed() then
		self:removeWatcher("onAddFriend")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TAddFriend:completed()
	return self._state >= self._context.param1
end