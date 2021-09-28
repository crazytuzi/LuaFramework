--NPC行为管理类
NPCBehaviorMgr =BaseClass()

function NPCBehaviorMgr:__init()
	self:InitData()
	self:InitEvent()
end

function NPCBehaviorMgr:__delete()
	self:CleanEvent()
	self:CleanData()
	NPCBehaviorMgr.inst = nil
end

function NPCBehaviorMgr:InitEvent()
	self.handler1=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK,function ()
		self:CallbackStopMove()
	end)
end

function NPCBehaviorMgr:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function NPCBehaviorMgr:InitData()
	self.npcObj = nil
end

function NPCBehaviorMgr:CleanData()
	self.npcObj = nil
end

function NPCBehaviorMgr:GetInstance()
	if NPCBehaviorMgr.inst == nil then
		NPCBehaviorMgr.inst = NPCBehaviorMgr.New()
	end
	return NPCBehaviorMgr.inst
end

function NPCBehaviorMgr:SetNPCObj(npcObj)
	self.npcObj = npcObj or nil
end

function NPCBehaviorMgr:PathToNPC()
	local mainPlayerObj =  self:GetMainPlayerObj()
	if mainPlayerObj then
		if self.npcObj then
			local mainPlayerPos = mainPlayerObj:GetPosition()
			local npcPos = self.npcObj:GetPosition()
			if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos , npcPos , 3) then
				self:CallbackStopMove()
			else
				mainPlayerObj:MoveToPositionByAgent( Vector3.New(npcPos.x , npcPos.y , npcPos.z + 1.5 ))
			end

		end
	end
end

function NPCBehaviorMgr:CallbackStopMove()
	if self.npcObj and self.npcObj.eid then
		local mainPlayerObj = self:GetMainPlayerObj()
		if mainPlayerObj then
			local mainPlayerPos = mainPlayerObj:GetPosition()
			local npcPos = self.npcObj:GetPosition()
			if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, npcPos, 3) then
				mainPlayerObj.transform:LookAt(self.npcObj.transform.position)
				self.npcObj:PlayAction("talk", -1)

				local npcId = self.npcObj.eid
				local taskModel = TaskModel:GetInstance()
				local submitTaskDataList = taskModel:GetTaskListBySubmitNPC(npcId)
				local execTaskDataList = taskModel:GetTaskListByExecNPC(npcId)
				local funId = taskModel:GetFunIdByNPCId(npcId)

				if not TableIsEmpty(submitTaskDataList) then
					if submitTaskDataList[1] then
						self:TaskBehavior(submitTaskDataList[1])
					end
					return
				end
				
				if execTaskDataList then
					if npcId == 1102 and self.isClickBtn then -- 点击副本按钮寻路过来的就直接打开副本界面
						FBController:GetInstance():OpenFBPanel()
					elseif npcId == 1108 then
						ClanCtrl:GetInstance():C_GetGuildFightData()--获取城战面板状态数据
					elseif npcId == 1701 then
						ClanCtrl:GetInstance():C_GetManorData()--获取领地面板数据
					elseif npcId == 1 then
						ClanCtrl:GetInstance():C_GetRevenueData() -- 获取税收面板数据
					else
						NPCDialogController:GetInstance():OpenNPCDialogPanelByNPC(npcId, execTaskDataList, funId)
					end
				end
			end
		end
	end
	self.npcObj = nil
end

--[[触发行为先后顺序（由先往后）
	交付任务（完成的任务）
	执行功能指向该npc的任务（未完成的任务）
	触发该npc的功能（比如打开每日任务界面）
	触发npc自己的对话]]
function NPCBehaviorMgr:Behavior(npcObj, isClickBtn)
	if npcObj then
		self:SetNPCObj(npcObj)
		self:PathToNPC()
		self.isClickBtn = isClickBtn
	end
end

function NPCBehaviorMgr:TaskBehavior(taskDataObj)
	if taskDataObj then
		local taskBehaviorObj = TaskBehaviorFactory:GetInstance():Create(taskDataObj)
		if not TableIsEmpty(taskBehaviorObj) then
			local taskModel = TaskModel:GetInstance()
			taskModel:SetShowSubmitDialog(true)
			SceneModel:GetInstance():CleanPathingFlag()
			taskModel:SetLastSubmitTaskNPCInfo(taskDataObj:GetTaskId() , taskDataObj:GetSubmitNPCId())
			taskBehaviorObj:Behavior()
		end
	end
end

function NPCBehaviorMgr:GetMainPlayerObj()
	local rtnMainPlayerObj = nil
	local curSceneView = SceneController:GetInstance():GetScene()
	if curSceneView then
		rtnMainPlayerObj = curSceneView:GetMainPlayer()
	end
	return rtnMainPlayerObj
end
