--TargetBase.lua
--/*-----------------------------------------------------------------
 --* Module:  TargetBase.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 任务目标基础类
 -------------------------------------------------------------------*/

TargetBase = class()
function TargetBase:__init(task, context)
	self._task = task
	self._context = context
	self._isShield = false
	self._interested = {}
end

function TargetBase:__release()
	self:clear()
	g_listHandler:removeListener(self)
	--self._task = nil
	--self._context = nil
end

function TargetBase:clear()
	self:removeWatchers()
end

function TargetBase:getContext()
	return self._context
end

function TargetBase:getTaskPlayer()
	return self._task:getPlayer()
end

--行会公共任务
--获取任务事件监听器
function TargetBase:getEventHandler()
	local taskType = self._task:getType()
	if taskType ~= TaskType.Faction then
		return g_taskMgr:GetTaskEventHandler(self:getTaskPlayer():getID())
	else
		return g_factionMgr:getTaskEventHandler(self._task:getFactionID())
	end
end

--把自己加入目标监听
function TargetBase:addWatcher(eventName)
	local eventHandler = self:getEventHandler()
	if eventHandler then
		eventHandler:addWatcher(eventName, self)
	end	
	self._interested[eventName] = true
end
--把自己移除目标监听
function TargetBase:removeWatcher(eventName, froce)
	--行会任务的不自已移除
	if self._task:getType() == TaskType.Faction then
		if froce ~= true then
			print("FactionTask targets no froce remove!")
			return
		else
			print("FactionTask targets froce remove!")
		end
	end

	local eventHandler = self:getEventHandler()
	if eventHandler then
		eventHandler:removeWatcher(eventName, self)
	end
	self._interested[eventName] = nil
end
--移除全部监听
function TargetBase:removeWatchers()
	for eventName, _ in pairs(self._interested) do
		self:removeWatcher(eventName, true)
	end
end
--获取目标当前状态
function TargetBase:getState()
	return self._state
end
--设置目标当前状态
function TargetBase:setState(state,notNotify)
	if not TASK_OPEN_FALG then
		return
	end
	if self._state ~= state then
		self._state = state
		if not notNotify then self._task:castStates() end
	end
end
--直接完成目标的接口
function TargetBase:doCompleted()
	self:setState(self._context.count)
	self._task:validate()
end

function TargetBase:failed()
	return false
end

function TargetBase:completed()
	return false
end

function TargetBase:onTaskFinished()
	self:clear()
end


function TargetBase:getMonster()
end

function TargetBase:doneTarget()
end
function TargetBase:onTaskDone()
end

--行会公共任务
function TargetBase:taskInfoSave()
	--目标改变需要刷新数据库
	local taskType = self._task:getType()
	if taskType ~= TaskType.Faction and self:getTaskPlayer() then
		local roleId = self:getTaskPlayer():getID()
		local roleInfo = g_taskMgr:getRoleTaskInfo(roleId)
		if roleInfo then
			roleInfo:cast2db()
		end
	end
end

function TargetBase:belongFactionTask()
	return self._task:getType() == TaskType.Faction
end
