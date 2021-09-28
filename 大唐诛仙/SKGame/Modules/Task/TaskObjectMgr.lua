--任务具体实体（主要包括具体任务行为和具体对话行为）生命周期管理器
TaskObjectMgr =BaseClass()

function TaskObjectMgr:__init()
	self:Config()
	self:InitData()
end

function TaskObjectMgr:Config()

end

function TaskObjectMgr:InitData()
	self.taskBehaviorObjList = {}
	self.npcInteractionObjList = {}
end

function TaskObjectMgr:IsContainTaskBhaviorObj(taskId)
	local rtnIsContain = false
	local rtnTaskBehaviorObj = {}
	for taskIdIndex , objInfo in pairs(self.taskBehaviorObjList) do
		
		if taskIdIndex == taskId then
			rtnTaskBehaviorObj = objInfo
			rtnIsContain = true
			break
		end
	end
	return rtnIsContain, rtnTaskBehaviorObj
end

function TaskObjectMgr:IsContainNPCInteractionObj(taskId)
	local rtnIsContain = false
	local rtnTaskNPCInteractionObj = {}
	for taskIdIndex, objInfo in pairs(self.npcInteractionObjList) do
		
		if taskIdIndex == taskId then
			rtnTaskNPCInteractionObj = objInfo
			rtnIsContain = true
			break
		end
	end
	return rtnIsContain, rtnTaskNPCInteractionObj
end

function TaskObjectMgr:AddTaskBehaviorObj(taskId, taskBehaviorObj)
	if taskId ~= nil then
		self.taskBehaviorObjList[taskId] = {}
		self.taskBehaviorObjList[taskId] = taskBehaviorObj
	end
end

function TaskObjectMgr:PrintTaskBehaviorObjList()
	--zy("======== TaskObjectMgr:taskBehaviorObjList \n" , self.taskBehaviorObjList)
end

function TaskObjectMgr:DestroyBehaviorObj(taskId)
	if taskId ~= nil then
		for taskIdIndex, taskBehaviorObj in pairs(self.taskBehaviorObjList) do
			if taskIdIndex == taskId then
				self.taskBehaviorObjList[taskIdIndex]:Destroy()
				--table.remove(self.taskBehaviorObjList, taskIdIndex)
				self.taskBehaviorObjList[taskIdIndex] = nil
				break
			end
		end
	end
end

function TaskObjectMgr:AddNPCInteractionObj(taskId, npcInteractionObj)
	if taskId ~= nil then
		-- self.npcInteractionObjList[taskId] = {}
		self.npcInteractionObjList[taskId] = npcInteractionObj
	end
end

function TaskObjectMgr:DestroyNPCInteractionObj(taskId)
	if taskId ~= nil then
		for taskIdIndex, npcInteractionObj in pairs(self.npcInteractionObjList) do
			if taskIdIndex == taskId then
				self.npcInteractionObjList[taskIdIndex]:Destroy()
				--table.remove(self.npcInteractionObjList, taskIdIndex)
				self.npcInteractionObjList[taskIdIndex] = nil

			end
		end
	end
end

function TaskObjectMgr:DestroyTaskObjectById(taskId)
	if taskId ~= nil then
		self:DestroyNPCInteractionObj(taskId)
		self:DestroyBehaviorObj(taskId)
	end
end


function TaskObjectMgr:GetInstance()
	if TaskObjectMgr.inst == nil then
		TaskObjectMgr.inst = TaskObjectMgr.New()
	end
	return TaskObjectMgr.inst
end

function TaskObjectMgr:__delete()
	self.taskBehaviorObjList = {}
	self.npcInteractionObjList = {}
	TaskObjectMgr.inst = nil
end
