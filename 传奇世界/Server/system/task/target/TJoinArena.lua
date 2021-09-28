--TJoinArena.lua
--/*-----------------------------------------------------------------
 --* Module:  TJoinArena.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 参加竞技场
 -------------------------------------------------------------------*/

TJoinArena=class(TargetBase)

function TJoinArena:__init(task, context, state)
	self._state = state or 0
	
	if not self._context.param2 then
		self._context.param2 = 0
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onJoinArena")
	end
end

function TJoinArena:onJoinArena(player, win)
	if self._context.param2 == 1 and not win then
		return
	end

	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onJoinArena")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TJoinArena:completed()
	return self._state >= self._context.param1
end