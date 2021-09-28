--TJoinFac.lua
--/*-----------------------------------------------------------------
 --* Module:  TJoinFac.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 加入行会
 -------------------------------------------------------------------*/

TJoinFac=class(TargetBase)

function TJoinFac:__init(task, context, state)
	self._state = state or 0
	if self:getTaskPlayer():getFactionID() > 0 then
		self._state = 1
	end
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onJoinFac")
	end
end

function TJoinFac:onJoinFac(player)
	self._state = 1
	if self:completed() then
		self:removeWatcher("onJoinFac")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TJoinFac:completed()
	return self._state >= 1
end