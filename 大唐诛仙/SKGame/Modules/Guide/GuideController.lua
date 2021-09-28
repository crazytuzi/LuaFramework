RegistModules("Guide/GuideModel")
RegistModules("Guide/GuideView")

GuideController =BaseClass(LuaController)

function GuideController:GetInstance()
	if GuideController.inst == nil then
		GuideController.inst = GuideController.New()
	end
	return GuideController.inst
end

function GuideController:__init()
	self.model = GuideModel:GetInstance()
	self.view = nil
	self:InitData()
	self:InitEvent()
	self:RegistProto()
end

function GuideController:InitData()
	self.lastNPCId = -1
end

function GuideController:InitEvent()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.GuideFunctionTrigger, function (data) self:OnGuideFunctionTrigger(data) end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function () self:CallbackStopMove() end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.StopReturnMainCity, function () self:CancelGotoFB() end)
end

function GuideController:OnGuideFunctionTrigger(data)
	local data = GetCfgData("FunctionGuide"):Get(data)
	if data then
		if data.type == 1 then --打开界面
			self:OpenPannel(data.uiid, data.param[1])
		elseif data.type == 2 then --寻路导怪物点
			self:GoToMonster(data.param[1][1], data.param[1][2])
		elseif data.type == 3 then --寻路导怪Npc
			self:GoToNPC(data.param[1][1])
		elseif data.type == 4 then --寻路到副本入口
			self:GotoFB()
		elseif data.type == 5 then --请求进入活动
			self:GotoActivity(data.param[1][1])
		end
	end
end

function GuideController:GotoActivity(activityId)
	local acCfg = GetCfgData("weekActivity"):Get(activityId)
	local mapcfg = nil
	if acCfg and acCfg.mapId and acCfg.mapId > 0 then
		mapcfg = GetCfgData("mapManger"):Get(acCfg.mapId)
	end
	local model = PkgModel:GetInstance()
	local now = #model:GetOnGrids() or 0
	local total = model.bagGrid or 0
	local msg = StringFormat("您的背包快满了( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 请尽快清理", now, total)
	local needBagTip = true
	if mapcfg and mapcfg.rewardType == 0 then
		needBagTip = false
	end

	local function cb()
		local msg = weekactivity_pb.C_EnterActivity()
		msg.id = activityId
		self:SendMsg("C_EnterActivity", msg)
	end

	if total - now < 8 and needBagTip then
		UIMgr.Win_Confirm("背包提示", msg, "进入副本", "整理背包", cb, function()
			PkgCtrl:GetInstance():Open()
		end, true)
	else
		cb()
	end
end

function GuideController:OpenPannel(gui, param)
	if gui == "FBPanel" then
		
	elseif gui == "PkgPanel" then
		local had = false
		for i = 1, #param do
			if PkgModel:GetInstance():GetTotalByBid(param[i]) > 0 then
				had = true
				break
			end
		end
		if had then
			if TaskModel:GetInstance():IsHasHuntingMonsterTask() then
				Message:GetInstance():TipsMsg("请先完成任务列表的猎妖任务")
				return
			end
			PkgCtrl:GetInstance():Open(param)
		else
			Message:GetInstance():TipsMsg("没有猎妖令")
		end
	elseif gui == "TiantiPanel" then
		TiantiController:GetInstance():Open()
	elseif gui == "PlayerCommonPanel" then

	elseif gui == "GodFightRunePanel" then

	elseif gui == "SkillPanel" then

	elseif gui == "MainCityUI" then

	elseif gui == "TradingPanel" then

	elseif gui == "FBPanel" then

	end
end

function GuideController:GoToMonster(mapId, refershId)
	SceneController:GetInstance():GetScene():GetMainPlayer():FindToMonsterPos(mapId, refershId)
end

function GuideController:GoToNPC(npcId)
	if SceneModel:GetInstance():IsInMainCity(npcId) then
		self:BackCityPath2NPC(npcId)
	else
		SceneController:GetInstance():GetScene():GetMainPlayer():FindToNPCPos(npcId)
	end
	self.lastNPCId = npcId
end

function GuideController:CallbackStopMove()
	local sceneView = SceneController:GetInstance():GetScene()
	if sceneView and self.lastNPCId ~= -1 then
		local mainPlayerPos = sceneView:GetMainPlayerPos()
		local lastNpcObj = sceneView:GetNpc(self.lastNPCId)
		if lastNpcObj then
			local lastNpcPos =  lastNpcObj.transform.position or {}
			if (not TableIsEmpty(mainPlayerPos)) and (not TableIsEmpty(lastNpcPos)) then
				if MapUtil.IsNearV3DistanceByXZ(mainPlayerPos , lastNpcPos , 1.5 ) then
					if FunctionModel:GetInstance():GetNPCIdByFun(FunctionConst.FunEnum.dailyTask) == self.lastNPCId then
						if ((TaskModel:GetInstance():IsHasDailyTask() == false) and (DailyTaskModel:GetInstance():IsMaxHasGetCnt() == false)) then
							self:OpenDailyTaskPanel()
						else
							if DailyTaskModel:GetInstance():IsMaxHasGetCnt() then
								UIMgr.Win_FloatTip("你已完成今日每日任务")
							else
								UIMgr.Win_FloatTip("您已领取每日任务")
							end
						end
					end
				end
			end
		end
	end
end

function GuideController:OpenDailyTaskPanel()
	DailyTaskController:GetInstance():OpenDailyTaskPanel()
	if TaskModel:GetInstance():IsHasDailyTask() == false and DailyTaskModel:GetInstance():GetDailyListFlag() == false then
		DailyTaskController:GetInstance():GetDailyTaskList()
		DailyTaskModel:GetInstance():SetGetDailyListFlag(true)		
	else
	end
end

function GuideController:GotoFB()
	self:BackCityPath2NPC(1102)
end

function GuideController:BackCityPath2NPC(npcId)
	if npcId == nil then return end
	if SceneModel:GetInstance():IsInNewBeeScene() == true then
		UIMgr.Win_FloatTip("通关彼岸村后可使用")
		return
	end
	local mapId, pos = SceneModel:GetInstance():GetNPCPos(npcId)

	local function goFBLocal(npcObj)
		local sceneView = SceneController:GetInstance():GetScene()
		npcObj = npcObj or sceneView:GetNpc(npcId)
		local npcBehaviorMgr = NPCBehaviorMgr:GetInstance()
		local mainPlayer = sceneView:GetMainPlayer()
		if mainPlayer and npcObj and npcBehaviorMgr then
			GlobalDispatcher:DispatchEvent(EventName.Player_AutoRun)
			npcBehaviorMgr:Behavior(npcObj, true)
		end
	end
	GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
	if mapId and pos then
		local curMap = SceneModel:GetInstance().sceneId
		if curMap == mapId then
			goFBLocal()
		else
			GlobalDispatcher:DispatchEvent(EventName.StopCollect)
			GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity, "gotofb")
			if not self.gotoFBHandle then
				self.gotoFBHandle = GlobalDispatcher:AddEventListener(EventName.NPC_ENTERSCENE, function(data)
					if data.vo and data.vo.eid == npcId then
						self:CancelGotoFB()
						goFBLocal(data)
					end
				end)
			end
		end
	end
end

-- 协议注册
function GuideController:RegistProto()
	
end

-- 取消前往副本
function GuideController:CancelGotoFB()
	if self.gotoFBHandle then
		GlobalDispatcher:RemoveEventListener(self.gotoFBHandle)
		self.gotoFBHandle = nil
	end
end

function GuideController:__delete()
	self.lastNPCId = -1
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self:CancelGotoFB()
	GuideController.inst = nil
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end
end