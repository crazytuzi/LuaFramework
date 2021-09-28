--TPickReward.lua
--/*-----------------------------------------------------------------
 --* Module:  TPickReward.lua
 --* Author:  seezon
 --* Modified: 2016年8月29日
 --* Purpose: 领取悬赏奖励
 -------------------------------------------------------------------*/

TPickReward=class(TargetBase)

function TPickReward:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onTPickReward")
	end
end

function TPickReward:onTPickReward(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onTPickReward")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TPickReward:completed()
	return self._state >= self._context.param1
end