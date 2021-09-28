--通关副本任务
TaskCopy =BaseClass(TaskBehavior)

function TaskCopy:__init(taskData)
	self.taskData = taskData
	self:InitEvent()
	self:InitData()
end

function TaskCopy:InitEvent()
	--TaskBehavior.InitEvent(self)
	self.handler0=GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function (  )
		self:CallbackStopMove()
	end)
end

function TaskCopy:InitData()
	self.mainCitySceneId = 1001
end

function TaskCopy:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function TaskCopy:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.CopyPass)
	
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		
		self:OpenCopyPanel()
	end
end

function TaskCopy:OpenCopyPanel()
	local copyId = self:GetCopyId()
	if copyId ~= -1  then
		if SceneModel:GetInstance():IsCopy() then
			local tipsContent = GetCfgData("game_exception"):Get(1203)
			if not TableIsEmpty(tipsContent) and tipsContent.exceptionMsg then
				UIMgr.Win_FloatTip(tipsContent.exceptionMsg)
			end
			return
		end
		if self:IsTeamCopy() then
			if ZDModel:GetInstance():GetTeamId() ~= 0 then
				local zdModel = ZDModel:GetInstance()
				local isLeader = zdModel:IsLeader()
				if isLeader then
					--队长判断成员是否在主场景
					local memTab = ZDModel:GetInstance():GetNotInMainMapMember()
					if memTab and #memTab > 0 then
						local nameStr = ZDModel:GetInstance():GetNameTipStr(memTab)
						UIMgr.Win_FloatTip(nameStr)
					else
						GuideController:GetInstance():GotoFB()
					end
				else
					FBController:GetInstance():RequireEnterInstance(copyId)
				end
			else
				GuideController:GetInstance():GotoFB()
			end
		else
			local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
			local fbModel = FBModel:GetInstance()
			local zdModel = ZDModel:GetInstance()
			if fbModel:CheckNeedTransfer(copyId) and mainPlayer then
				if mainPlayer.teamId == 0 or zdModel:GetMemNum() <= 1 then
					local function cb()
						GlobalDispatcher:DispatchEvent(EventName.StopCollect)
						local data = { tType = "enterfb", text = "副本传送中", args = copyId }
						GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, data)
					end
					self:CheckEnter(cb)
				else
					FBController:GetInstance():RequireEnterInstance(copyId)
				end
			else
				local function cb()
					FBController:GetInstance():RequireEnterInstance(copyId)
				end
				self:CheckEnter(cb)
			end
		end
	end
end

function TaskCopy:CheckEnter(cb)
	-- local pkgModel = PkgModel:GetInstance()
	-- local now = #pkgModel:GetOnGrids() or 0
	-- local total = pkgModel.bagGrid or 0
	-- local msg = StringFormat("您的背包快满了( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 请尽快清理", now, total)
	-- if total - now < 8 then
	-- 	UIMgr.Win_Confirm("背包提示", msg, "进入副本", "整理背包", cb, function ()
	-- 		PkgCtrl:GetInstance():Open()
	-- 	end, true)
	-- else
	-- 	cb()
	-- end

	cb()
end

function TaskCopy:GetCopyId()
	local rtnCopyId = -1
	local taskTarget = self.taskData:GetTaskTarget()
	rtnCopyId = taskTarget.targetParam[1] or -1
	return rtnCopyId
end

function TaskCopy:IsTeamCopy()
	local rtnIs = false
	local copyId = self:GetCopyId()
	if copyId ~= -1 then
		local mapCfg = GetCfgData("mapManger"):Get(copyId)
		if mapCfg ~= nil then
			if mapCfg.openTask == 0 then
				rtnIs = true
			end
		end
	end
	return rtnIs
end

function TaskCopy:GetCopyTransferPos()
	local rtnPos = {}
	local mainCitySceneCfg = SceneModel:GetInstance():GetSceneCfg(self.mainCitySceneId)
	if mainCitySceneCfg then
		for transferId , transferInfo in pairs(mainCitySceneCfg.transfer) do
			if transferInfo.toScene == 321 then
				rtnPos = transferInfo.location
				break
			end
		end
	end
	return rtnPos
end

function TaskCopy:CallbackStopMove()
	local mainSceneView = SceneController:GetInstance():GetScene()
	if mainSceneView then
		local mainPlayerPos = mainSceneView:GetMainPlayerPos()
		local copyTransPos = self:GetCopyTransferPos()
		if mainPlayerPos ~= nil 
			and (not TableIsEmpty(copyTransPos))
			and MapUtil.IsNearV3DistanceByXZ(mainPlayerPos, Vector3.New(copyTransPos[1] , copyTransPos[2] , copyTransPos[3]), math.sqrt((self.pathTargetDistance ^ 2) * 2)) then
			FBController:GetInstance():OpenFBPanel()
		end
	end
end