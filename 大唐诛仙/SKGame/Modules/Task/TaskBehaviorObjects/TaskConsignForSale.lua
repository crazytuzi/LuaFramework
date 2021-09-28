TaskConsignForSale = BaseClass(TaskBehavior)

function TaskConsignForSale:__init(taskData)
	self.taskData = taskData
	self:InitEvent()
	self:InitData()
end

function TaskConsignForSale:__delete()
	self:ClearEvent()
	self:ClearData()
end

function TaskConsignForSale:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK , function ()
		self:CallbackStopMove()
	end)
end

function TaskConsignForSale:ClearEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function TaskConsignForSale:InitData()
	self:InitConsignForSaleNPCInfo()
	self:InitPathDistance()
	self:InitPosState()
end

function TaskConsignForSale:InitConsignForSaleNPCInfo()
	self.saleNPCInfo = nil

	local cosignForSaleNPCID = TaskModel:GetInstance():GetConsignForSaleNPCID()
	local mapId,pos = SceneModel:GetInstance():GetNPCPos(cosignForSaleNPCID)
	if mapId and pos then
		self.saleNPCInfo = {}
		self.saleNPCInfo.npcId = cosignForSaleNPCID
		self.saleNPCInfo.sceneId = mapId
		self.saleNPCInfo.location = pos
	end

end

function TaskConsignForSale:ClearConsignForSaleNPCInfo()
	self.saleNPCInfo = nil
end

function TaskConsignForSale:InitPathDistance()
	self.pathTargetDistance = 2
end

function TaskConsignForSale:ClearPathDistance()
	self.pathTargetDistance = nil
end

function TaskConsignForSale:InitPosState()
	self.isNear = false
end

function TaskConsignForSale:ClearPosState()
	self.isNear = nil
end

function TaskConsignForSale:ResetPosState()
	self.isNear = false
end

function TaskConsignForSale:ClearData()
	self:ClearPathDistance()
	self:ClearConsignForSaleNPCInfo()

end

function TaskConsignForSale:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.ConsignForSale)

	self:ResetPosState()

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		self:GotoCosignForSaleNPC() --走到寄售NPC旁边，当玩家停下来，触发点击该NPC行为，弹出包含寄售入口按钮的NPC对话界面
	else

	end
end

function TaskConsignForSale:GotoCosignForSaleNPC()
	if self.saleNPCInfo and self.saleNPCInfo.location  then
		local curSceneId = SceneModel:GetInstance().sceneId
		local isLocal
		if curSceneId and self.saleNPCInfo.sceneId and curSceneId == self.saleNPCInfo.sceneId then
			isLocal = true
		else
			isLocal = false
		end

		self:PathFindingToNPC(isLocal)
	end
end

function TaskConsignForSale:PathFindingToNPC(isLocal)
	if self.saleNPCInfo.location and not TableIsEmpty(self.saleNPCInfo.location) then
		local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayerObj then
			mainPlayerObj:Reset()
			local pos = Vector3.New(self.saleNPCInfo.location.x, self.saleNPCInfo.location.y, self.saleNPCInfo.location.z + self.pathTargetDistance)
			if isLocal == true then
				GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
				mainPlayerObj:MoveToPositionByAgent(pos)
			elseif isLocal == false then
				mainPlayerObj:SetWorldNavigation(self.saleNPCInfo.sceneId, pos)
			end	
		end
	end
end

function TaskConsignForSale:CallbackStopMove()
	local mainSceneView = SceneController:GetInstance():GetScene()
	if mainSceneView then
		local mainPlayerPos = mainSceneView:GetMainPlayerPos()
		if mainPlayerPos ~= nil and (not TableIsEmpty(self.saleNPCInfo)) and self.saleNPCInfo.location ~= nil and  MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, self.saleNPCInfo.location, math.sqrt((self.pathTargetDistance ^ 2) * 2)) then
			local curSceneId = SceneModel:GetInstance():GetSceneId()
			if curSceneId ~= 0 and self.saleNPCInfo.sceneId ~= nil and curSceneId == self.saleNPCInfo.sceneId then
				self:LookAtNPC(self.saleNPCInfo.npcId)
				local npcObj = self:GetConsignForSaleNPCObj()
				if npcObj and self.isNear == false then
					zy("CallbackStopMove 111")
					self.isNear = true
					NPCBehaviorMgr:GetInstance():Behavior(npcObj)
					
					--TradingController:GetInstance():Open(TradingConst.tabType.stall , nil , nil , nil , nil , TradingConst.stallTabType.sell , nil)
				end
			end
		end
	end
end

function TaskConsignForSale:GetConsignForSaleNPCObj()
	local rtnNPCObj = nil
	if self.saleNPCInfo and self.saleNPCInfo.npcId then
		local curSceneView = SceneController:GetInstance():GetScene()
		if curSceneView then
			local npcObj = curSceneView:GetNpc(self.saleNPCInfo.npcId)
			if npcObj then
				rtnNPCObj = npcObj
			end
		end
	end
	return rtnNPCObj
end
