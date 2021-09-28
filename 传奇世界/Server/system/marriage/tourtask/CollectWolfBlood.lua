--CollectWolfBlood.lua
--/*-----------------------------------------------------------------
 --* Module:  CollectWolfBlood.lua
 --* Author:  goddard
 --* Modified: 2016年8月17日
 --* Purpose: 采集狼血任务
 -------------------------------------------------------------------*/

CollectWolfBlood = class()
function CollectWolfBlood:__init(info, count, config, status)
	self._info = info
	self._config = config
	self._count = count
	self._status = status
	info:addWatcher("onMonsterKill", self)
end

function CollectWolfBlood:onMonsterKill(monSID, roleID, monID, mapID)
	local tour = self._info:getTour()
	if not tour then
		return
	end
	local isValid = false
	isValid = tour:checkTaskGenderValid(roleID, self._config.q_who)
	if not isValid then
		return
	end
	if tonumber(self._config.q_monster_id) ~= monSID then
		return
	end
	self._count = self._count + 1
	tour:notifyUpdateTaskStatus(self._count)
	if self:completed() then
		self._info:removeWatcher("onMonsterKill", self)
		self._info:notifyFinishTask(self._config.q_taskid, self._config.q_next)
		self._status = 1
		local tour = self._info:getTour()
		if not tour then
			return
		end
		tour:recvTaskProc()
	end
end

function CollectWolfBlood:completed()
	return self._count >= self._config.q_total_count
end

function CollectWolfBlood:getNextTaskID()
	return self._config.q_next
end

function CollectWolfBlood:__release()
	self._info:removeWatcher("onMonsterKill", self)
end