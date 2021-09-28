--TSingleKillMonster.lua
--/*-----------------------------------------------------------------
 --* Module:  TSingleKillMonster.lua
 --* Author:  goddard
 --* Modified: 2016年5月22日
 --* Purpose: 单人杀怪任务目标
 -------------------------------------------------------------------*/

TSingleKillMonster = class(TargetBase)

function TSingleKillMonster:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then
		self:addWatcher("SingleKilledMonster")
		self:addWatcher("SingleKillMonsterFreshBoss")
		self:addWatcher("onSwitchScene")
	end
end

function TSingleKillMonster:SingleKilledMonster(player, monId)
	if self:completed() then
		return
	end
	local monInfo = g_taskMgr:getMonsterInfoByRoleId(self._task:getRoleID())
	if not monInfo then
		return
	end
	if monId == monInfo.monId then
		self:setState(self._state + 1)
	end
	if self:completed() then
		self:removeWatcher("SingleKilledMonster")
		self:removeWatcher("SingleKillMonsterFreshBoss")
		self:removeWatcher("onSwitchScene")
		g_taskMgr:delMonsterInfoByRoleId(self._task:getRoleID())
		self._task:validate()
	end
end

function TSingleKillMonster:onSwitchScene(player, mapID, lastMapID)
	local monInfo = g_taskMgr:getMonsterInfoByRoleId(self._task:getRoleID())
	if monInfo then
		local mon = g_entityMgr:getMonster(monInfo.monId)
		if mon then
			local bindHostile = mon:getBindHostile()
			if bindHostile then
				local roleName = self:getTaskPlayer():getName()
				if bindHostile == roleName then
					g_taskMgr:delMonsterInfoByRoleId(self._task:getRoleID())
					g_entityMgr:destoryEntity(mon:getID())
				end
			end
		end
	end
	g_taskMgr:mainTaskFail(player, self._task)
end

function TSingleKillMonster:completed()
	return self._state >= 1
end

function TSingleKillMonster:SingleKillMonsterFreshBoss()
	local scene = g_sceneMgr:getPublicScene(self._context.param3)
	if not scene then
		return
	end
	local monInfo = g_taskMgr:getMonsterInfoByRoleId(self._task:getRoleID())
	if monInfo then
		local mon = g_entityMgr:getMonster(monInfo.monId)
		if mon then
			local bindHostile = mon:getBindHostile()
			if bindHostile then
				local roleName = self:getTaskPlayer():getName()
				if bindHostile == roleName then
					return
				end
			end
		end
	end
	local mapX = 0
	local mapY = 0
	mapX,mapY = g_LuoxiaMgr:getMonsterInfoPos(self._context.param2)
	local mon = g_entityMgr:getFactory():createMonster(self._context.param1)
	if mon and scene:addMonsterInfoByID(mon, self._context.param2) then
		mon:changeAIRule(10)
		mon:setBindHostile(self:getTaskPlayer():getName())
		mon:setName(mon:getName()..'('..self:getTaskPlayer():getName()..')')
		if g_sceneMgr:enterPublicScene(mon:getID(), self._context.param3, mapX, mapY, self:getTaskPlayer():getLine() % 100) then
			scene:addMonster(mon)
			self._boss = mon
			g_taskMgr:setMonsterInfo(self._task:getRoleID(), mon:getID())
		else
			print("----1TSingleKillMonster SingleKillMonsterFreshBoss failed:", mon and mon:getSerialID())
			g_entityMgr:destoryEntity(mon:getID())
		end
	else
		print("----2TSingleKillMonster SingleKillMonsterFreshBoss failed:", mon and mon:getSerialID())
		if mon then
			g_entityMgr:destoryEntity(mon:getID())
		end
	end
end