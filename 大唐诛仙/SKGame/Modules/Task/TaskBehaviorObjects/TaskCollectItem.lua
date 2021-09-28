TaskCollectItem =BaseClass(TaskBehavior)

function TaskCollectItem:__init(taskData)
	self:InitEvent()
	self:InitData()
end

function TaskCollectItem:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
end

function TaskCollectItem:InitEvent()
	--TaskBehavior.InitEvent(self)
	self.handler1=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ( data )
		self:LoadSceneFinish(data)
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED, function ( data )
		self:LoadMainPlayerFinish(data)
	end)
	self.handler3=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function ( data )
		self:CallbackStopMove(data)
	end)
	self.handler4=GlobalDispatcher:AddEventListener(EventName.StartCollect, function ( data )
		self:StartCollectHandle(data)
	end)
	self.handler5=GlobalDispatcher:AddEventListener(EventName.EndCollect, function ( data )
		self:HandleEndCollect(data)
	end)
	self.handler6=GlobalDispatcher:AddEventListener(EventName.StopCollect, function (  )
		self:HandleStopCollect()
	end)
	self.handler7= GlobalDispatcher:AddEventListener(EventName.MAINROLE_WALKING, function () 
		self:HandleMainPlayerWalking() 
	end)
end

function TaskCollectItem:InitData()
	self.collectCfg = GetCfgData("collect")
	self.submitNpcInfo = {}
	self.curPathFindingTargetPos = {}
	self:SetSubmitNPCInfo()
	self:SetCollectItemInfo()
	self.isOpenCollectUI = false --打开采集进度条的状态
	self.collectItemPanel = nil
	self.isInterrupted = false --任务是否处于打断状态（一旦打断就不可以再次自动触发，只能通过点击任务Item触发）
end

function TaskCollectItem:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.CollectItem)
	self:SetInterruptedState(false)
	if not TableIsEmpty(self.taskData) then
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			self:SubmitTask()
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			self:CollectItem()
		end
	end
end

function TaskCollectItem:SubmitTask()
	local curSceneId = SceneModel:GetInstance().sceneId

	if self.taskData:IsNeedAutoComplete() == true then
		self:StartNPCDialog()
	else
		local isSubmit = true
		self:PathFindingToSubmitNPC(isSubmit)
	end
end

function TaskCollectItem:SetSubmitNPCInfo()
	if TableIsEmpty(self.taskData) then return end
	self.submitNpcInfo = self.taskData:GetSubmitNPCInfo()
end

function TaskCollectItem:PathFindingToSubmitNPC(isSubmit)
	self:SetPathFindingTargetPos()
	if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
		local curSceneId = SceneModel:GetInstance().sceneId
		local isLocal = true
		if curSceneId == self.submitNpcInfo.sceneId then
			self:PathToFindTarget(self.submitNpcInfo.sceneId, isSubmit, isLocal)
			self:StartNPCDialog()
		else
		 	self:ChangeToSumitNPCScene()
		end
	elseif self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.WorldPath then
		local isLocal = false
		self:PathToFindTarget(self.submitNpcInfo.sceneId, isSubmit, isLocal)
		self:StartNPCDialog()
	end
end

function TaskCollectItem:SetPathFindingTargetPos()
	self.curPathFindingTargetPos = self.submitNpcInfo.npcPos or {}
end

function TaskCollectItem:ChangeToSumitNPCScene()
	if not TableIsEmpty(self.submitNpcInfo) and self.submitNpcInfo.sceneId ~= -1 then
		SceneController:GetInstance():C_EnterScene(self.submitNpcInfo.sceneId, nil)
	end
end

function TaskCollectItem:ChangeToCollectScene()
	if self.transferId and self.transferId ~= -1 and not TableIsEmpty(self.collectInfo) then
		SceneController:GetInstance():C_EnterScene(self.collectInfo.mapId , nil)
	end
end


function TaskCollectItem:CollectItem()
	local curSceneId = SceneModel:GetInstance().sceneId
	if not TableIsEmpty(self.collectInfo) then
		if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
			if curSceneId ~= self.collectInfo.mapId then
			 	self:ChangeToCollectScene()
			 else
				local isSubmit = false
				local isLocal = true
				self:PathToFindTarget(self.collectInfo.mapId , isSubmit, isLocal)
			end
		elseif self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.WorldPath then
			local isSubmit =false
			local isLocal = false
			self:PathToFindTarget(self.collectInfo.mapId, isSubmit, isLocal)
		end
	end
	
end


function TaskCollectItem:SetCollectItemInfo()
	local taskDataObj = self:GetTaskData()
	if taskDataObj then
		local taskTarget = taskDataObj:GetTaskTarget() or {}
		if not TableIsEmpty(taskTarget) then
			self.transferId = taskTarget.targetParam[1] or -1
			self.needCollectCnt = taskTarget.targetParam[2] or -1
			self.collectInfo = self.collectCfg:Get(self.transferId) or {}

			if not TableIsEmpty(self.collectInfo.position) then
				self.collectItemPos = Vector3.New(self.collectInfo.position[1] or 0, self.collectInfo.position[2] or 0, self.collectInfo.position[3] or 0)
			end 		
		end
	end
end


function TaskCollectItem:PathToFindTarget(mapId, isSubmit, isLocal)
	if self.collectItemPos and not TableIsEmpty(self.collectItemPos) and mapId ~= nil then
		local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
		if mainPlayerObj then
			local pos = {}
			if isSubmit == true then
				pos = self.submitNpcInfo.npcPos
			else
				pos = self.collectItemPos
			end
			if not TableIsEmpty(pos) then
				mainPlayerObj:Reset()
				local targetPos = Vector3.New(pos.x, pos.y , pos.z + self:GetPathTargetDist())
				if isLocal == true then
					GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
					mainPlayerObj:MoveToPositionByAgent(targetPos)
				elseif isLocal == false then
					mainPlayerObj:SetWorldNavigation(mapId , targetPos)
				end
			end

		end
	end
end



function TaskCollectItem:LoadSceneFinish()
	
end

function TaskCollectItem:LoadMainPlayerFinish(mainPlayerObj)
	if mainPlayerObj then
		--接入公共世界寻路接口，公共寻路接口会处理这个
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			if self.taskData:GetSubmitTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				local isSubmit = true
				-- if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
				-- 	isSubmit = true
				-- end
				local isLocal = true
				self:PathToFindTarget(self.submitNpcInfo.sceneId, isSubmit, isLocal)
			end
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			if self.taskData:GetExecTaskPathMethod() == TaskConst.PathMethod.LocalPath then
				local isSubmit = false
				local isLocal = true
				self:PathToFindTarget(self.collectInfo.mapId, isSubmit, isLocal)
			end
		end
	end
end

function TaskCollectItem:CallbackStopMove()
	local mainSceneView = SceneController:GetInstance():GetScene()
	if mainSceneView then
		local mainPlayerPos = mainSceneView:GetMainPlayerPos()
		if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
			if mainPlayerPos and (not TableIsEmpty(self.curPathFindingTargetPos)) and  self.submitNpcInfo.npcPos and MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, self.curPathFindingTargetPos, math.sqrt((self:GetPathTargetDist() ^ 2) * 2)) then
				self:LookAtNPC(self.submitNpcInfo.npcId)
				self:StartNPCDialog()
			end
		elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			if mainPlayerPos ~= nil and self.collectItemPos ~= nil then 
				if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, self.collectItemPos, math.sqrt((self:GetPathTargetDist() ^ 2) * 2)) then
					local collectInfo = SceneModel:GetInstance():GetCollectByCollectId(self.transferId) --采集点固定的
					if not TableIsEmpty(collectInfo) then
						if self.isOpenCollectUI == false and self.collectItemPanel == nil and self.isInterrupted == false then
							CollectModel:GetInstance():SetCollectVo(collectInfo)
							SceneController:GetInstance():C_StartCollect(collectInfo.playerCollectId)
						else
							self:EndCollectItem()
						end
					else
						if self.isInterrupted == false then
							UIMgr.Win_FloatTip("没有采集物")
						end
					end
				else
					if self.isOpenCollectUI == true and self.collectItemPanel ~= nil then
						self:EndCollectItem()
					end
				end
			end
		end
	end
end


function TaskCollectItem:EndCollectItem()
	if self.transferId ~= nil then
		local collectInfo = SceneModel:GetInstance():GetCollectByCollectId(self.transferId)
		if not TableIsEmpty(collectInfo) then
			SceneController:GetInstance():C_EndCollect(collectInfo.playerCollectId)
			self:CloseLoadingPanel()

			if self.isInterrupted == false then
				UIMgr.Win_FloatTip("采集中断")
			end

			local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
			if mainPlayerObj then
				mainPlayerObj:ShowWeapon()	
			end

			self:SetInterruptedState(true)
		end
	end
end

function TaskCollectItem:HandleStopCollect()
	self:EndCollectItem()
end

function TaskCollectItem:CloseLoadingPanel()
	if self.collectItemPanel ~= nil then
		self.collectItemPanel:Destroy()
		self.collectItemPanel = nil
		self.isOpenCollectUI = false
	end
end

function TaskCollectItem:StartCollectHandle(playerCollectId)
	if playerCollectId ~= nil then
		local collectVo = CollectModel:GetInstance():GetCollectVo()
		
		if not TableIsEmpty(collectVo) and playerCollectId == collectVo.playerCollectId  then
			local curTransferCfg = self.collectCfg:Get(collectVo.collectId)
			if not TableIsEmpty(curTransferCfg) and curTransferCfg.collectTime ~= 0 and collectVo:GetCollectType() == SceneConst.CollectType.Task then
				
				CollectModel:GetInstance():SetCollectData("执行中...", (curTransferCfg.collectTime *0.001) or 0)
				GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
				SceneController:GetInstance():GetScene():StopAutoFight(false)
				self.collectItemPanel =  CollectView:GetInstance():OpenLoadingCollectItemPanel()


				local mainPlayerObj = SceneController:GetInstance():GetScene():GetMainPlayer()
				if mainPlayerObj then
					mainPlayerObj:HideWeapon()
					if collectObj and not ToLuaIsNull(collectObj.transform) then mainPlayerObj.gameObject.transform:LookAt(self.collectItemPos, Vector3.up) end
					mainPlayerObj:GetAnimator():PlayByTime("collecting", curTransferCfg.collectTime * 0.001, function()
						mainPlayerObj:DoStand()
						mainPlayerObj:ShowWeapon()
					end)
				end

				self.isOpenCollectUI = true
			end
		end
	end
end


function TaskCollectItem:StartNPCDialog()
	
	local taskNpcBehavior = TaskNPCInteractionFactory:GetInstance():Create(self.taskData)
	if not TableIsEmpty(taskNpcBehavior) then
		taskNpcBehavior:Run()
	end
end


function TaskCollectItem:HandleEndCollect(isSucc)
	if isSucc == true then
		self:SetInterruptedState(true)
		self:CloseLoadingPanel()
	end
end

function TaskCollectItem:HandleMainPlayerWalking()
	local mainSceneView = SceneController:GetInstance():GetScene()
	if mainSceneView then
		local mainPlayerPos = mainSceneView:GetMainPlayerPos()
		if self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
			if mainPlayerPos ~= nil and self.collectItemPos ~= nil then
				local collectInfo = SceneModel:GetInstance():GetCollectByCollectId(self.transferId) --采集点固定的
				if not TableIsEmpty(collectInfo) then
					if self.isOpenCollectUI == true and self.collectItemPanel ~= nil then
						self:EndCollectItem()
					end
				end
			end
		end
	end
end

function TaskCollectItem:SetInterruptedState(bl)
	if bl ~= nil then
		self.isInterrupted = bl
	end
end
