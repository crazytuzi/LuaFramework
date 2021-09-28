--TKillMonster.lua
--/*-----------------------------------------------------------------
 --* Module:  TKillMonster.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 杀怪任务目标
 -------------------------------------------------------------------*/

TKillMonster = class(TargetBase)

function TKillMonster:__init(task, context, state)
	self._state = state or 0
	if not self:completed() or self:belongFactionTask() == true then
		self:addWatcher("onMonsterKilled")
	end
end

--杀一个目标怪就加1
function TKillMonster:onMonsterKilled(player, monsterID,mapid, isOnlyMainTask)
	if isOnlyMainTask and self._task:getType()~= TaskType.Main then
		return
	end

	local isTrue = false
	for _,id in pairs(self._context.ID) do
		if tonumber(id) == monsterID then
			isTrue = true
		end
	end

	if mapid and mapid > 0 then
		local sameMap = false
		if player:getMapID() == mapid then
			sameMap = true
		end

		if not sameMap and self._task:getType()~= TaskType.Shared then 
			return 
		end
	end
	if isTrue then

		self:setState(self._state + 1)
		if self:completed() then
			self:removeWatcher("onMonsterKilled")
			self._task:validate()
		end

		self:taskInfoSave()
	end
end

function TKillMonster:completed()
	return self._state >= self._context.count
end

function TKillMonster:doneTarget()
	self:setState(self._context.count)
end