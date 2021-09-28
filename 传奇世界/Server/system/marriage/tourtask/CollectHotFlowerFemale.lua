--CollectHotFlowerFemale.lua
--/*-----------------------------------------------------------------
 --* Module:  CollectHotFlowerFemale.lua
 --* Author:  goddard
 --* Modified: 2016年8月17日
 --* Purpose: 浇灌炙热之花
 -------------------------------------------------------------------*/

CollectHotFlowerFemale = class()
function CollectHotFlowerFemale:__init(info, count, config, status)
	self._info = info
	self._config = config
	self._count = count
	self._status = status
end

function CollectHotFlowerFemale:onCollect()
	self._count = self._count + 1
	if self:completed() then
		self._info:notifyFinishTask(self._config.q_taskid, self._config.q_next)
		self._status = 1
		local tour = self._info:getTour()
		if not tour then
			return
		end
		tour:recvTaskProc()
	end
end

function CollectHotFlowerFemale:completed()
	return self._count >= self._config.q_total_count
end

function CollectHotFlowerFemale:getNextTaskID()
	return self._config.q_next
end