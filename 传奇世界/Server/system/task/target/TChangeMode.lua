--TChangeMode.lua
--/*-----------------------------------------------------------------
 --* Module:  TChangeMode.lua
 --* Author:  seezon
 --* Modified: 2016年5月27日
 --* Purpose: 变身任务
 -------------------------------------------------------------------*/

TChangeMode=class(TargetBase)

function TChangeMode:__init(task, context, state)
	self._state = state or 0
	self:addWatcher("onChangeModeFail")
	local buffId = self._context.param4
	local buffmgr = self:getTaskPlayer():getBuffMgr()
	local buff = buffmgr:addBuff(buffId)
	local petID = self:getTaskPlayer():getPetID()
	if petID > 0 then
		g_entityMgr:destoryEntity(petID)
	end
	g_rideMgr:offRide(self:getTaskPlayer():getSerialID())

	g_listHandler:addListener(self)
end

function TChangeMode:onChangeModeFail(player)
	local buffId = self._context.param4
	local buffmgr = player:getBuffMgr()
	if buffmgr:isExist(buffId) then
		buffmgr:delBuff(buffId)
	end

	self:removeWatcher("onChangeModeFail")
	g_taskMgr:mainTaskFail(player, self._task)
end

function TChangeMode:onThreeSecond()
	--每3秒检测一下玩家身上的BUFF还在不在，不在就失败了
	local buffId = self._context.param4
	local buffmgr = self:getTaskPlayer():getBuffMgr()
	if self._task:getStatus() ~= TaskStatus.Finished and self._task:getStatus() ~= TaskStatus.Fail and not buffmgr:isExist(buffId) then
		self:onChangeModeFail(self:getTaskPlayer())
		self._task:setStatus(TaskStatus.Fail)
	end
end

--结束的时候，恢复正常
function TargetBase:onTaskFinished()
	local buffId = self._context.param4
	local buffmgr = self:getTaskPlayer():getBuffMgr()
	if buffmgr:isExist(buffId) then
		buffmgr:delBuff(buffId)
	end
	self:removeWatcher("onChangeModeFail")
	g_listHandler:removeListener(self)
end

function TChangeMode:completed()
	return self._state >= 0
end