TaskBehavior =BaseClass()

function TaskBehavior:__init(taskData)
	self.taskData = taskData
	self.targetType = TaskConst.TaskTargetType.None
	
	self.submitNpcInfo = {}
	self.curPathFindingTargetPos = {}
	self:SetSubmitNPCInfo()
	self.pathTargetDistance = 2
end

function TaskBehavior:Config()
	
end

function TaskBehavior:GetTaskData()
	return self.taskData
end

function TaskBehavior:Behavior()

end

function TaskBehavior:__delete()
	
	GlobalDispatcher:RemoveEventListener(self.handler10)
	GlobalDispatcher:RemoveEventListener(self.handler20)
	GlobalDispatcher:RemoveEventListener(self.handler30)
end

function TaskBehavior:InitEvent()
	
	self.handler10=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ( data )
		self:LoadSceneFinish(data)
	end)
	self.handler20=GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED, function ( data )
		self:LoadMainPlayerFinish(data)
	end)
	self.handler30=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function ( data )
		self:CallbackStopMove(data)
	end)
end

function TaskBehavior:SetTaskTargetType(targetType)
	
	self.targetType = targetType or TaskConst.TaskTargetType.None
end


function TaskBehavior:SetSubmitNPCInfo()
	if TableIsEmpty(self.taskData) then return end
	

	self.submitNpcInfo = self.taskData:GetSubmitNPCInfo()
end

function TaskBehavior:GetPathTargetDist()
	return self.pathTargetDistance
end


--任务完成，跑到npc旁边提交任务
function TaskBehavior:SubmitTask()
	
	local curSceneId = SceneModel:GetInstance().sceneId

	if self.taskData:IsNeedAutoComplete() == true then
		
		self:StartNPCDialog()
	else
		
		self:PathFindingToSubmitNPC()
	end
	
end


function TaskBehavior:PathFindingToSubmitNPC()
	self:SetPathFindingTargetPos()
	if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
		local curSceneId = SceneModel:GetInstance().sceneId
		if curSceneId == self.submitNpcInfo.sceneId then
			local isLocal = true
			self:PathFindingToNPC(isLocal)
		else
			self:ChangeScene()
		end
	elseif self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.WorldPath then
		local isLocal = false
		self:PathFindingToNPC(isLocal)
	end
end

function TaskBehavior:SetPathFindingTargetPos()
	self.curPathFindingTargetPos = self.submitNpcInfo.npcPos or {}
end

function TaskBehavior:ChangeScene()
	if not TableIsEmpty(self.submitNpcInfo) and self.submitNpcInfo.sceneId ~= -1 then
		SceneController:GetInstance():C_EnterScene(self.submitNpcInfo.sceneId, nil)
	end
end

function TaskBehavior:PathFindingToNPC(isLocal)
	if not TableIsEmpty(self.submitNpcInfo) and not TableIsEmpty(self.submitNpcInfo.npcPos) then
		
		local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayer then
			mainPlayer:Reset()
			local pos = Vector3.New(self.submitNpcInfo.npcPos.x, self.submitNpcInfo.npcPos.y, self.submitNpcInfo.npcPos.z + self.pathTargetDistance)
			if isLocal == true then
				GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
				mainPlayer:MoveToPositionByAgent(pos)
			elseif isLocal == false then
				mainPlayer:SetWorldNavigation(self.submitNpcInfo.sceneId, pos)
			end
		end
	end
end

function TaskBehavior:StartNPCDialog()
	local taskNpcBehavior = TaskNPCInteractionFactory:GetInstance():Create(self.taskData)
	if not TableIsEmpty(taskNpcBehavior) then
		taskNpcBehavior:Run()
	end
end

function TaskBehavior:LoadSceneFinish()
	
end

function TaskBehavior:LoadMainPlayerFinish(mainPlayer)
	if mainPlayer then
		--世界寻路公共接口已经实现，屏蔽该功能
		--self:PathFindingToNPC()
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				local isLocal = true
				self:PathFindingToNPC(isLocal)
			end
		end
	end
end

function TaskBehavior:AutoSubmitTask()
	if self.taskData ~= nil and (not TableIsEmpty(self.taskData)) then
		
		TaskController:GetInstance():SubmitTask(self.taskData:GetTaskId())
	end
end

function TaskBehavior:CallbackStopMove()
	local scene = SceneController:GetInstance():GetScene()
	if scene then
		local mainPlayerPos = scene:GetMainPlayerPos()
		if mainPlayerPos and (not TableIsEmpty(self.curPathFindingTargetPos)) and  self.submitNpcInfo.npcPos and MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, self.curPathFindingTargetPos, math.sqrt((self.pathTargetDistance ^ 2) * 2)) then
			self:LookAtNPC(self.submitNpcInfo.npcId)
			self:StartNPCDialog()
		end
	end
end


function TaskBehavior:GetSceneNPCForwardPos(npcId)
	local rtnPos = {}
	if npcId then
		local curSceneView = SceneController:GetInstance():GetScene()
		if curSceneView then
			local npcObj =  curSceneView:GetNpc(npcId)
			if npcObj then	
				rtnPos = Vector3.New(npcObj.transform.position.x, npcObj.transform.position.y, npcObj.transform.position.z + self.pathTargetDistance)
			end
		end
	end
	return rtnPos
end


function TaskBehavior:LookAtNPC(npcId)
	local npcPos = self:GetSceneNPCForwardPos(npcId)
	if not TableIsEmpty(npcPos) then
		local scene = SceneController:GetInstance():GetScene()
		if not TableIsEmpty(scene) then
			local mainPlayer = scene:GetMainPlayer()
			if mainPlayer then
				
				mainPlayer.transform:LookAt(Vector3.New(npcPos.x, npcPos.y, npcPos.z - self.pathTargetDistance))
			end
		end
	end
end

function TaskBehavior:SetTaskState(state)
	if not TableIsEmpty(self.taskData) then
		self.taskData:SetTaskState(state)
	end
end