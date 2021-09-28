--TKillWorldBoss.lua
--/*-----------------------------------------------------------------
 --* Module:  TKillWorldBoss.lua
 --* Author:  seezon
 --* Modified: 2014年10月8日
 --* Purpose: 杀世界BOSS
 -------------------------------------------------------------------*/

TKillWorldBoss=class(TargetBase)

function TKillWorldBoss:__init(task, context, state)
	self._state = state or 0

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onKillWorldBoss")
	end
end

function TKillWorldBoss:onKillWorldBoss(player)
	self:setState(self._state + 1)
	--self:setState(self:findMatCount(matID))
	if self:completed() then
		self:removeWatcher("onKillWorldBoss")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TKillWorldBoss:completed()
	return self._state >= self._context.param1
end