--TLevelUp.lua
--/*-----------------------------------------------------------------
 --* Module:  TLevelUp.lua
 --* Author:  seezon
 --* Modified: 2014年10月31日
 --* Purpose: 升级目标
 -------------------------------------------------------------------*/

TLevelUp=class(TargetBase)

function TLevelUp:__init(task, context, state)
	self._state = state or 0

	--行会公共任务
	if  self:getTaskPlayer() then
		local roleId = self:getTaskPlayer():getID()
		local player = g_entityMgr:getPlayer(roleId)

		if player then
			self:setState(player:getLevel())
		end
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onLevelUp")
	end
end

function TLevelUp:onLevelUp(player, level)
	self:setState(level)
	if self:completed() then
		self:removeWatcher("onLevelUp")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TLevelUp:completed()
	return self._state >= self._context.param1
end