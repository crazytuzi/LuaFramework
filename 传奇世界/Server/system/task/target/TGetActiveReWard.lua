--TGetActiveReWard.lua
--/*-----------------------------------------------------------------
 --* Module:  TGetActiveReWard.lua
 --* Author:  seezon
 --* Modified: 2014年10月31日
 --* Purpose: 领取活跃度奖励
 -------------------------------------------------------------------*/

TGetActiveReWard=class(TargetBase)

function TGetActiveReWard:__init(task, context, state)
	self._state = state or 0
	
	if  self:getTaskPlayer() then
		if g_normalMgr:isReward(self:getTaskPlayer():getID()) then
			self:setState(1)
		end
	end

	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onGetActiveReWard")
	end
end

function TGetActiveReWard:onGetActiveReWard(player, rewardId)
	if (rewardId == self._context.param1) or (rewardId == self._context.param2) or (rewardId == self._context.param3) or (rewardId == self._context.param4)or (rewardId == self._context.param5)then
		self:setState(1)
		if self:completed() then
			self:removeWatcher("onGetActiveReWard")
			self._task:validate()
		end

		self:taskInfoSave()
	end
end

function TGetActiveReWard:completed()
	return self._state >= 1
end