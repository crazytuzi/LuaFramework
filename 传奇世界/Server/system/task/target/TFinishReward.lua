--TFinishReward.lua
--/*-----------------------------------------------------------------
 --* Module:  TFinishReward.lua
 --* Author:  seezon
 --* Modified: 2016年1月18日
 --* Purpose: 完成悬赏任务
 -------------------------------------------------------------------*/

TFinishReward=class(TargetBase)

function TFinishReward:__init(task, context, state)
	self._state = state or 0
	
	if not self:completed() or self:belongFactionTask() == true then	
		self:addWatcher("onFinishReward")
	end
end

function TFinishReward:onFinishReward(player)
	self:setState(self:getState() + 1)
	if self:completed() then
		self:removeWatcher("onFinishReward")
		self._task:validate()
	end

	self:taskInfoSave()
end

function TFinishReward:completed()
	return self._state >= self._context.param1
end