TaskKillMonster =BaseClass(TaskBehavior)

function TaskKillMonster:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.KillMonster)
	
	if not TableIsEmpty(self.taskData) then
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			
			self:SubmitTask()
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			
			self:SetMonseterInfo()
			self:ChangeToMonsterScene()
			
		end
	end

end

function TaskKillMonster:__init(taskData)
	self:InitEvent()
	self.npcCfg = GetCfgData("npc")
end

function TaskKillMonster:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskKillMonster:__delete()
end

function TaskKillMonster:ChangeToMonsterScene()
	if self.mapId and self.mapId ~= -1 then
		if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
			local curSceneId = SceneModel:GetInstance().sceneId 
			local isLocal = true
			if curSceneId ~= self.mapId then
				SceneController:GetInstance():C_EnterScene(self.mapId , nil)
			else
				self:PathToMonster(isLocal)
			end
		elseif self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.WorldPath then
			local isLocal = false
			self:PathToMonster(isLocal)
		end
	end
end


function TaskKillMonster:SetMonseterInfo()
	local taskDataObj = self:GetTaskData()
	if taskDataObj then
		local taskTarget = taskDataObj:GetTaskTarget() or {}
		if not TableIsEmpty(taskTarget) then
			self.mapId = taskTarget.targetParam[1] or -1
			self.monsterId = taskTarget.targetParam[2] or -1
			self.monsterCnt = taskTarget.targetParam[3] or -1
			self.monsterRefershId = taskTarget.targetParam[4] or -1

			self.monsterRefershPos = {}

			self:SetMonsterRefershPos()
		end
	end
end

function TaskKillMonster:SetMonsterRefershPos()
	if self.monsterRefershId ~= -1 and self.mapId ~= -1 then
		local sceneCfg = SceneModel:GetSceneCfg(self.mapId)
		if sceneCfg then
			for refershId, refershInfo in pairs(sceneCfg.monsterSpawn)  do
				if refershId == self.monsterRefershId then

					self.monsterRefershPos = Vector3.New(refershInfo.location[1], refershInfo.location[2], refershInfo.location[3]) 
					break
				end
			end
		end
	end
end

function TaskKillMonster:GetMonsterRefershPos()
	return self.monsterRefershPos
end

function TaskKillMonster:LoadMainPlayerHandle(eventContext)
	
	local mainPlayerObj = eventContext.data
	if mainPlayerObj and self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		--世界寻路接口已经做了该处理
		if self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			local isLocal = false
			if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.WorldPath then
				isLocal = false
			elseif self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				isLocal = true
			end
			self:PathToMonster(isLocal)
		end
	end
end

function TaskKillMonster:PathToMonster(isLocal)
	if not TableIsEmpty(self.monsterRefershPos) then
		local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayerObj  and (not TableIsEmpty(self.monsterRefershPos)) and self.mapId ~= nil then
			mainPlayerObj:Reset()
			if isLocal == true then
				GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
				mainPlayerObj:MoveToPositionByAgent(self.monsterRefershPos)
			
			elseif isLocal == false then
				mainPlayerObj:SetWorldNavigation(self.mapId, self.monsterRefershPos)
			end
		end
	end
end

function TaskKillMonster:GetNearestMonsterPos()
	local nearestMonsterPos = {}
	local nearestDistance = 100000
	local rtnMonsterList = self:GetSceneMonsterList()

	if not TableIsEmpty(rtnMonsterList) then
		
		local mainSceneView = SceneController:GetInstance():GetScene()
		if mainSceneView then
			local mainPlayerPos = mainSceneView:GetMainPlayerPos()
			if not TableIsEmpty(mainPlayerPos) then
				
				for index, monsterInfo in pairs(rtnMonsterList) do
					local monsterDistance = Vector3.Distance(mainPlayerPos, monsterInfo.position)
					
					if nearestDistance > monsterDistance then
						nearestDistance = monsterDistance
						nearestMonsterPos = Vector3.New(monsterInfo.position.x, monsterInfo.position.y, monsterInfo.position.z)
						
					end
				end
			end
		end
	end
	return nearestMonsterPos
end


--获取场景目标怪物列表
function TaskKillMonster:GetSceneMonsterList()
	local rtnMonsterList = {}
	local monsterList =  SceneModel:GetInstance():GetMonListById(self.monsterId)
	if not TableIsEmpty(monsterList) then
			rtnMonsterList = monsterList
	end
	return rtnMonsterList
end