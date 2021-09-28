--NPC对话交互任务
TaskNPCDialog =BaseClass(TaskBehavior)

function TaskNPCDialog:__init(taskData)

	self.taskData = taskData or {}
	self.npcCfg = GetCfgData("npc")
	self.npcInfo = {}
	
	self:InitData()
	self:Config()
	self:InitEvent()
	
end

function TaskNPCDialog:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
end

function TaskNPCDialog:InitEvent()
	
	
	self.handler1=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH,function ( data )
		self:LoadSceneFinish(data)
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED,function ( data )
		self:LoadMainPlayerFinish(data)
	end)
	self.handler3=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK,function ( data )
		self:CallbackStopMove(data)
	end)

end

function TaskNPCDialog:InitData()
	self.pathTargetDistance = 2
end

function TaskNPCDialog:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.NPCInteraction)
	if not TableIsEmpty(self.taskData) then
		local npcId  = -1
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			
			npcId = self.taskData:GetSubmitNPCId() or -1
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			
			local targetInfo = self.taskData:GetTaskTarget()
			if #targetInfo.targetParam > 0 then
				
				npcId = targetInfo.targetParam[1] or -1
				
			end
		end

		self:ChangeToNPCScene(npcId)
	end
end

function TaskNPCDialog:Config()
	TaskBehavior.Config(self)
end

--寻路至npc旁边
function TaskNPCDialog:ChangeToNPCScene(npcId)

	if npcId ~= nil and npcId ~= -1 then
		local curNPCInfo = {}
		local curNpcCfg =  self.npcCfg:Get(npcId) or nil
		local npcSceneId = -1

		self.npcInfo = {}
		self.npcInfo.npcId = npcId

		if curNpcCfg then
			npcSceneId = curNpcCfg.inScene 
			self.npcInfo.sceneId = curNpcCfg.inScene 
			
			if npcSceneId ~= -1 then
				local mapCfg = SceneModel:GetInstance():GetSceneCfg(npcSceneId)
				if mapCfg then
					for npcIdIndex, npcInfo in pairs(mapCfg.npcs) do
						
						if npcIdIndex == npcId then
							curNPCInfo = npcInfo
							break
						end
					end
				end
			end
		end

		

		if not TableIsEmpty(curNPCInfo) then
			self.npcInfo.npcPos = {}

			self.npcInfo.npcPos = Vector3.New(curNPCInfo.location[1] or 0, curNPCInfo.location[2] or 0, curNPCInfo.location[3] or 0) 

		
			if npcSceneId ~= -1 then
				local curSceneId = SceneModel:GetInstance().sceneId

				if self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
					--嵌套的判断确实有点多，不好意思，暂时先这样写，任务的逻辑确实有点打乱我的程序结构
					if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
						if self.npcInfo.sceneId ~= curSceneId then	
							self:ChangeScene()
						else
							
							local isLocal = true
							self:PathFindingToNPC(isLocal)
						end
					elseif self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.WorldPath then
						
						local isLocal = false
						self:PathFindingToNPC(isLocal)
					else
						
					end

				elseif self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
					if self.taskData:IsNeedAutoComplete() == true then
						self:StartNPCDialog()
					else
						if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
							
							if self.npcInfo.sceneId ~= curSceneId then
								self:ChangeScene()
							else
								
								local isLocal = true
								self:PathFindingToNPC(isLocal)
							end
						elseif self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.WorldPath then
							
							local isLocal = false
							self:PathFindingToNPC(isLocal)
						else
							
						end
					end
				end
				
			end
		end

	end
end



function TaskNPCDialog:LoadSceneFinish()

	
end

function TaskNPCDialog:LoadMainPlayerFinish(mainPlayerObj)
	if mainPlayerObj then
		--世界寻路已经做了该处理
		if self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				
				local isLocal = true
				self:PathFindingToNPC(isLocal)
			end		
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				
				local isLocal = true
				self:PathFindingToNPC(isLocal)
			end
		end	
		
	end
end

function TaskNPCDialog:PathFindingToNPC(isLocal)
	if self.npcInfo.npcPos and not TableIsEmpty(self.npcInfo.npcPos) then
		local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayerObj then
			mainPlayerObj:Reset()
			local pos = Vector3.New(self.npcInfo.npcPos.x, self.npcInfo.npcPos.y, self.npcInfo.npcPos.z + self.pathTargetDistance)
			if isLocal == true then
				GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
				mainPlayerObj:MoveToPositionByAgent(pos)
			elseif isLocal == false then
				mainPlayerObj:SetWorldNavigation(self.npcInfo.sceneId, pos)
			end	
		end
	end
end




function TaskNPCDialog:StartNPCDialog()
	local taskNpcBehavior = TaskNPCInteractionFactory:GetInstance():Create(self.taskData)
	if not TableIsEmpty(taskNpcBehavior) then
		taskNpcBehavior:Run()
	end
end


function TaskNPCDialog:ChangeScene()
	if self.npcInfo.sceneId then
		SceneController:GetInstance():C_EnterScene(self.npcInfo.sceneId, nil)

	end
end

function TaskNPCDialog:CallbackStopMove()
	
	local mainSceneView = SceneController:GetInstance():GetScene()
	if mainSceneView then
		local mainPlayerPos = mainSceneView:GetMainPlayerPos()
		if mainPlayerPos ~= nil and (not TableIsEmpty(self.npcInfo)) and self.npcInfo.npcPos ~= nil and  MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, self.npcInfo.npcPos, math.sqrt((self.pathTargetDistance ^ 2) * 2)) then
			local curSceneId = SceneModel:GetInstance():GetSceneId()
			if curSceneId ~= 0 and self.npcInfo.sceneId ~= nil and curSceneId == self.npcInfo.sceneId then
				self:LookAtNPC(self.npcInfo.npcId)
				if TaskModel:GetInstance():IsCanShowSubmitDialog() then
					self:StartNPCDialog()
				end
				
			end
		end
	end
end