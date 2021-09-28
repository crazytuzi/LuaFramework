--TPersonalEscort.lua
--/*-----------------------------------------------------------------
 --* Module:  TPersonalEscort.lua
 --* Author:  goddard
 --* Modified: 2016年5月25日
 --* Purpose: 飙车任务目标
 -------------------------------------------------------------------*/

TPersonalEscort=class(TargetBase)

function TPersonalEscort:__init(task, context, state, loadDB)
	self._state = state or 0
	if not self:completed() then	
		self:addWatcher("onEscortSucc")
		self:addWatcher("onEscortFail")
		g_taskMgr:setPersonalEscortInfo(self._task:getRoleID(), 0)

		if not loadDB then
			local player = g_entityMgr:getPlayer(self._task:getRoleID())
			if player then
				if not g_ConvoyMgr:startConvoy(player:getSerialID(), self._context.param1) then
					self:onEscortFail(player)
				end
			end
		end
	end
end

function TPersonalEscort:onEscortSucc(player)
	if self:completed() then
		return
	end

	self:setState(self._state + 1)
	if self:completed() then
		self:removeWatcher("onEscortSucc")
		self:removeWatcher("onEscortFail")
		self._task:validate()
	end


	self:taskInfoSave()
end

function TPersonalEscort:onEscortFail(player)
	g_taskMgr:mainTaskFail(player, self._task)
end

function TPersonalEscort:completed()
	return self._state >= 1
end