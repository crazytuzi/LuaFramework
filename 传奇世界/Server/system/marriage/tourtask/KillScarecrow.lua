--KillScarecrow.lua
--/*-----------------------------------------------------------------
 --* Module:  KillScarecrow.lua
 --* Author:  goddard
 --* Modified: 2016年8月15日
 --* Purpose: 击杀稻草人任务
 -------------------------------------------------------------------*/

KillScarecrow = class()

function KillScarecrow:__init(info, count, config, status)
	self._info = info
	self._config = config
	self._count = count
	self._status = status
	info:addWatcher("onMonsterKill", self)
end

--杀一个目标怪就加1
function KillScarecrow:onMonsterKill(monSID, roleID, monID, mapID)
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
		tour:recvTaskProc()
	end
end

function KillScarecrow:completed()
	return self._count >= self._config.q_total_count
end


function KillScarecrow:getNextTaskID()
	return self._config.q_next
end

function KillScarecrow:__release()
	self._info:removeWatcher("onMonsterKill", self)
end