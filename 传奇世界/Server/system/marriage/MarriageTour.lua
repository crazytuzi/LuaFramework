--MarriageTour.lua
--/*-----------------------------------------------------------------
 --* Module:  MarriageTour.lua
 --* Author:  goddard
 --* Modified: 2016年8月12日
 --* Purpose: 婚姻巡礼任务
 -------------------------------------------------------------------*/

require ("system.marriage.TourTaskHelper")
require ("system.marriage.MarriageConstant")

MarriageTour = class()

function MarriageTour:__init(info)
	self._info = info
	self._curTaskId = 0
	self._status = MarriageTaskStep.UnFinish
	self._target = nil
	self._ceremonyBit = 0
end

function MarriageTour:clear()
	self._curTaskId = 0
	self._status = MarriageTaskStep.UnFinish
	if self._target then
		release(self._target)
	end
	self._target = nil
end

function MarriageTour:setCurTaskID(id)
	self._curTaskId = id
	if self._target then
		release(self._target)
	end
	self._target = TourTaskHelper.createTarget(self._info, id, 0, 0)
end

function MarriageTour:getCurTaskID()
	return self._curTaskId
end

function MarriageTour:recvTask()
	if 0 == self._curTaskId then
		self:setCurTaskID(1)
		return true, self._curTaskId
	end
	if not self._target then
		return false
	end
	if not self:curTaskFini() then
		return true, self._curTaskId
	end
	local taskId = self._target:getNextTaskID()
	if 0 == taskId then
		self._target = nil
		return false
	end
	self:setCurTaskID(taskId)
	self._info:saveData()
	return true, taskId
end

function MarriageTour:setStatus(s)
	self._status = s
end

function MarriageTour:getStatus()
	return self._status
end

function MarriageTour:tourOpt(player, taskId, step)
	if MarriageTourTaskStep.Start == step then
		local scene = g_sceneMgr:getPublicScene(player:getMapID())
		if scene then
			local ret = {}
			ret.taskId = taskId
			ret.step = step
			ret.id = player:getID()
			boardSceneProtoMessage(scene:getID(), MARRIAGE_SC_TOUR_OPT_BROADCAST, 'MarriageTourOptBroadCast', ret)
		end
	end
	if MarriageTourTaskStep.Finish == step then
		if 2 == taskId then
			if taskId == self._curTaskId then
				if self._target then
					self._target:onCollect()
				end
			end
		elseif 7 == taskId then
			if taskId == self._curTaskId then
				if self._target then
					self._target:onCollect()
				end
			end
		elseif 3 == taskId then
			if taskId == self._curTaskId then
				if self._target then
					self._target:onCollect()
				end
			end
		elseif 5 == taskId then
			if taskId == self._curTaskId then
				if self._target then
					self._target:onCollect()
				end
			end
		elseif 6 == taskId then
			if taskId == self._curTaskId then
				if self._target then
					self._target:onCollect()
				end
			end
		end
	end
end

function MarriageTour:teamClose()
	slef:clear()
end

function MarriageTour:curTaskID()
	return true, self._curTaskId
end

function MarriageTour:giveUpTask()
	self:clear()
end

function MarriageTour:checkTaskGenderValid(roleID, q_who)
	local maleID = nil
	local male = self._info:getMale()
	if male then
		maleID = male:getID()
	end
	local femaleID = nil
	local female = self._info:getFemale()
	if female then
		femaleID = female:getID()
	end
	if 0 == q_who then
		if roleID == maleID or roleID == femaleID then
			return true
		end
	elseif 1 == q_who then
		if maleID == roleID then
			return true
		end
	elseif 2 == q_who then
		if femaleID == roleID then
			return true
		end
	end
	return false
end

function MarriageTour:notifyUpdateTaskStatus(count)
	local ret = {}
	ret.count = count
	local male = self._info:getMale()
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_TOUR_TASK_UPDATE_STATUS, 'MarriageTourTaskUpdateStatus', ret)
	end
	local female = self._info:getFemale()
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_TOUR_TASK_UPDATE_STATUS, 'MarriageTourTaskUpdateStatus', ret)
	end
end

function MarriageTour:curTaskFini()
	if self._target then
		return self._target:completed()
	end
	return true
end

function MarriageTour:serializeBuf()
	local tour = {}
	tour.taskStatus = self:getStatus()
	return tour
end

function MarriageTour:recvTaskProc()
	if self._target then
		local last_config = self._target._config
		if last_config and last_config.q_auto then
			self:recvTask()			--会改变 self._target
			local config = self._target._config
			local ret = {}
			ret.taskType = config.q_type
			ret.taskStep = config.q_step
			local male = self._info:getMale()
			if male then
				fireProtoMessage(male:getID(), MARRIAGE_SC_TASK, 'MarriageSCTask', ret)
			end
			local female = self._info:getFemale()
			if female then
				fireProtoMessage(female:getID(), MARRIAGE_SC_TASK, 'MarriageSCTask', ret)
			end
		end
	end
end

function MarriageTour:taskFinish()
	if self._target then
		self._target = nil
	end
	local ret = {}
	local male = self._info:getMale()
	if male then
		fireProtoMessage(male:getID(), MARRIAGE_SC_TOUR_TASK_FINISH, 'MarriageSCTourTaskFinish', ret)
	end
	local female = self._info:getFemale()
	if female then
		fireProtoMessage(female:getID(), MARRIAGE_SC_TOUR_TASK_FINISH, 'MarriageSCTourTaskFinish', ret)
	end
	self:setStatus(MarriageTaskStep.AllFinish)
	self:setCurTaskID(0)
	self._info:saveData()
end

function MarriageTour:allTaskFini()
	return MarriageTaskStep.AllFinish == self:getStatus()
end

function MarriageTour:answerEnterCeremony(value)
	self._ceremonyBit = bit_or(self._ceremonyBit, value)
	if MarriageCeremonyBit.MaleAgreeValue == bit_and(self._ceremonyBit, MarriageCeremonyBit.MaleAgreeValue) 
		and MarriageCeremonyBit.FemaleAgreeValue == bit_and(self._ceremonyBit, MarriageCeremonyBit.FemaleAgreeValue) then
		local ret = {}
		ret.res = 0
		local male = self._info:getMale()
		if male then
			fireProtoMessage(male:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
		end
		local female = self._info:getFemale()
		if female then
			fireProtoMessage(female:getID(), MARRIAGE_SC_ENTER_CEREMONY, 'MarriageSCEnterCeremony', ret)
		end
		if male and female then
			local pos = {}
			pos.x = 18
			pos.y = 40
			g_marriageMgr:transmitTo(male, MARRIAGE_CEREMONY_MAP_ID, pos)
			pos.x = 20
			pos.y = 40
			g_marriageMgr:transmitTo(female, MARRIAGE_CEREMONY_MAP_ID, pos)
			self._info:addWatcher("onPlayerMoveInCeremony", self._info)
		end
		return false
	else
		return true
	end
end

function MarriageTour:clearEnterCeremony()
	self._ceremonyBit = 0
end

function MarriageTour:printinfo( ... )
	print("222222:", self._info)
end