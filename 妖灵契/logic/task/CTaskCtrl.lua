local CTaskCtrl = class("CTaskCtrl", CCtrlBase)

CTaskCtrl.DailyCultivateTaskID = 500		--历练任务ID
CTaskCtrl.LocalTaskID = 999999				--客户端本地临时任务
CTaskCtrl.TeachTaskId = 39999				--教学任务通用Id
CTaskCtrl.PartnerAccectTaskId = 999998		--伙伴支线领取任务Id
CTaskCtrl.ShiMenAccectTaskId = 999997		--师门任务本地交互Id
CTaskCtrl.CaiQuanID = 5000					--宝图猜拳副本


CTaskCtrl.AutoGoToDoStoryTaskTime = 30
CTaskCtrl.AutoGoToDoStoryTaskLevel = 15

CTaskCtrl.m_NpcMarkSprName = {
	"task_npcaccept",--可接
	"task_npcfinishnot",--进行中
	"task_npcfinish",--可提交
}

--寻路模式，接任务，提交任务
CTaskCtrl.PathFindMode = {
	AcceptTask = 1,
	SubmitTask = 2,
	FindTraceNpc = 3,
}

CTaskCtrl.AutoSM = {
	None = 1, 
	Continue = 2,
	DelayContinue = 3,	
}

CTaskCtrl.AutoDoingSM = {
	Time = 2,
}

function CTaskCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTaskCtrl.ResetCtrl(self)
	
	if self.m_RefreshTimerUI then
		Utils.DelTimer(self.m_RefreshTimerUI)
		self.m_RefreshTimerUI = nil
	end

	if self.m_RefreshTimerMark then
		Utils.DelTimer(self.m_RefreshTimerMark)
		self.m_RefreshTimerMark = nil
	end
	self.m_NpcMarkDic = {}
	self.m_DynamicNpcList = {}
	self.m_EscortNpcList = {} --护送类NPC
	self.m_TraceNpcList = {} --跟踪类NPC
	self.m_TaskChapterNpc = {} --任务战役Npc
	self.m_PickItemList = {}
	self.m_TaskDataDic = {}
	self.m_TaskTypeDic = {}
	self.m_PartnerTaskDataDic = {}
	self.m_ShiMenTaskStatue = 0
	self.m_AutoDoNextTask = 0
	for _,v in pairs(define.Task.TaskType) do
		self.m_TaskTypeDic[v] = {}
	end

	-- UI
	self.m_RecordTaskPageTab = 1
	self.m_RecordTask = {
		menu = {
			[1] = {name = "current"},
			[2] = {name = "accept"},
			[3] = {name = "story"},
		},
	}
	for _,v in ipairs(self.m_RecordTask.menu) do
		v.mainMenu = 0
		v.subMenu = 0
	end
	-- DATA
	self.m_RecordLogic = {
		oTask = nil,
	}

	--主角跟踪对象
	self.m_HeroTracingTarget = nil
	self.m_TraceSwitchMap = false --仅用于跟踪时，传送地图

	--是否能否自动寻路任务(目前只有小萌请求)
	self.m_CanAutoTask = false

	if self.m_TaskBarrageTimer then
		Utils.DelTimer(self.m_TaskBarrageTimer)
		self.m_TaskBarrageTimer = nil
	end
	self.m_BarrageId = nil
	self.m_BarrageIdx = 1
	if self.m_PatrolTaskTimer then
		Utils.DelTimer(self.m_PatrolTaskTimer)
		self.m_PatrolTaskTimer = nil
	end	

	self.m_AutoShiMen = nil
	if self.m_AutoShiMenCheckTimer then
		Utils.DelTimer(self.m_AutoShiMenCheckTimer)
		self.m_AutoShiMenCheckTimer = nil	
	end
	if self.m_AutoShiMenContinueTimer then
		Utils.DelTimer(self.m_AutoShiMenContinueTimer)
		self.m_AutoShiMenContinueTimer = nil	
	end
	self.m_AutoDoingShimen = false

	self.m_ClickTaskLastTime = 0
	self.m_ClickTaskId = 0

	self.m_IsWalkingTask = nil
	if self.m_IsWalkingTaskCheckTimer then
		Utils.DelTimer(self.m_IsWalkingTaskCheckTimer)
		self.m_IsWalkingTaskCheckTimer = nil
	end

	self.m_GotoDoTaskInMainMenuTime = 0
	if self.m_GotoDoTaskInMainMenuViewTimer then
		Utils.DelTimer(self.m_GotoDoTaskInMainMenuViewTimer)
		self.m_GotoDoTaskInMainMenuViewTimer = nil
	end

	if self.m_DoNextRoundShiMenTimer then
		Utils.DelTimer(self.m_DoNextRoundShiMenTimer)
		self.m_DoNextRoundShiMenTimer = nil
	end

	self.m_IsOpenLoginRewardView = false
end

--记录点击任务(切地图会在点击任务)
function CTaskCtrl.SetRecordLogic(self, oTask)
	self.m_RecordLogic.oTask = oTask
end

function CTaskCtrl.GS2CLoginTask(self, taskList, shimenStatus)
	self.m_ShiMenTaskStatue = shimenStatus or 0
	if taskList then
		local t = {}
		for _,v in ipairs(taskList) do
			 local oTask = CTask.New(v)
			 t[v.taskid] = oTask

			printc("login task")
			table.print(oTask)

			self.m_TaskTypeDic[v.tasktype] = self.m_TaskTypeDic[v.tasktype] or {}
			self.m_TaskTypeDic[v.tasktype][v.taskid] = oTask
		end

		self.m_TaskDataDic = t

		--重置任务的信息
		self:CheckTaskStatus()
		self:CheckTaskEndTime()

		-- 刷新导航UI
		self:RefreshUI()

		if g_MapCtrl.m_MapLoding == false then
			-- Npc标识放在最后检查
		 	self:CheckNpcMark()
		 	self:CheckTaskThing()
		end
	end
	if self.m_ShiMenTaskStatue == 3 then
		local cb = function ()
			CTaskCompleteView:ShowView(function (oView)
				oView:SetType(CTaskCompleteView.Type.ShiMen)
			end)
		end
		Utils.AddTimer(cb, 0, 1)
	end

	--登录的时候，自动检测
	--暂时注释
	self:CheckGoToDoStoryTaskInMainMenuView()
end

function CTaskCtrl.GS2CAddTask(self, task)
	if self.m_TaskDataDic[task.taskid] then
		printc("任务增 >>> 已存在任务ID:", task.taskid)
		return
	end
	local oTask = CTask.New(task)

	self.m_TaskDataDic[task.taskid] = oTask
	self.m_TaskTypeDic[task.tasktype] = self.m_TaskTypeDic[task.tasktype] or {}
	self.m_TaskTypeDic[task.tasktype][task.taskid] = oTask

	self:CheckTaskStatus(oTask)
	self:CheckTaskEndTime(oTask)
	self:RefreshUI()

	printc("add task ")
	table.print(oTask)
	--延时一帧处理任务刷新
	Utils.AddTimer(callback(self, "AddTaskProcress", oTask), 0, 0)
end

function CTaskCtrl.AddTaskProcress(self, oTask)
	if not oTask then
		return
	end
	-- 检查动态Npc、护送Npc、跟踪Npc、PickModel
	self:DoCheckDynamicNpc(oTask, true)
	self:DoCheckEscortNpc(oTask)
	self:DoCheckTraceNpc(oTask)
	self:DoCheckPickModel(oTask, true)
	self:RefreshTaskModel()
	self:CheckNpcMark()
	if oTask:GetValue("tasktype") == define.Task.TaskType.TASK_TEACH then
		self:OnEvent(define.Task.Event.ReceiveNewTeachTask)
	end
	
	-- if oTask:GetValue("taskid") == 10038 then
	-- 	if g_AttrCtrl.grade < 13 then
	-- 		--g_GuideCtrl:ReqCustomGuideFinish("HuoyueduGuide_Open")	
	-- 		g_GuideCtrl:TriggerCheck("view")
	-- 	else
	-- 		g_GuideCtrl:ReqCustomGuideFinish("ScheduleView")	
	-- 	end	
	-- end

	--如果是小萌请求任务，则弹出提示(第一次不弹提示)
	if oTask:IsMissMengTask() then
		if g_GuideCtrl:IsCustomGuideFinishByKey("Tips_XiaoMengQingQiu") then
			--暂时不显示小萌请求任务
			--CTaskAddTipsView:ShowView()
		else
			g_GuideCtrl:ReqCustomGuideFinish("Tips_XiaoMengQingQiu")
		end
	end

	if oTask:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
		local cb = function ()
			self:ChekcAutoShimen(CTaskCtrl.AutoSM.Continue)
		end
		Utils.AddTimer(cb, 0, 0)		
	end

	--先检测任务是否带小剧场
	local acceptcallplot = oTask:GetValue("acceptcallplot")
	if acceptcallplot and acceptcallplot ~= 0 then
		--10509是开篇动画，在enterscene的时候才开始播放
		if acceptcallplot ~= 10509 then
			g_DialogueAniCtrl:InsetUnPlayList(acceptcallplot)	
		end

	--不带小剧情在检测开篇动画
	else
		self:StartStoryTask(oTask)
	end	
end

--重置任务信息
function CTaskCtrl.GS2CRefreshTaskInfo(self, task)
	--若已经缓存了该任务，则先删除，在添加
	if self.m_TaskDataDic[task.taskid] then
		if self.m_TaskDataDic[task.taskid]:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
			self:ChekcAutoShimen(CTaskCtrl.AutoSM.DelayContinue)
		end		
		self:GS2CDelTask(task.taskid)
	end
	self:GS2CAddTask(task)
end

function CTaskCtrl.GS2CDelTask(self, taskid, done)
	local oTask = self.m_TaskDataDic[taskid]
	if not oTask then
		printc("任务删 >>> 不存在任务ID:", taskid)
		return
	end
	g_DialogueCtrl:CacheTaskOpenBtn()

	--删除的任务设置为删除状态
	oTask:SetStatus(define.Task.TaskStatus.Del)

	-- 删除动态npc
	self:DoCheckDynamicNpc(oTask, false)
	self:DoCheckEscortNpc(oTask)
	self:DoCheckTraceNpc(oTask)
	self:DoCheckPickModel(oTask, false)

	if done == 1 then
		if oTask:GetValue("type")  == define.Task.TaskCategory.STORY.ID then
			local submitcallplot = oTask:GetValue("submitcallplot")
			if submitcallplot and submitcallplot ~= 0 then		
				g_DialogueAniCtrl:InsetUnPlayList(submitcallplot)		
			end

			--自动接下一个任务处理
			self.m_AutoDoNextTask = oTask:GetValue("autoDoNextTask")
		end

		if oTask:GetValue("taskid") == 10002 then
			g_GuideCtrl:ReqCustomGuideFinish("Complete_Task_10002")
			g_GuideCtrl:TriggerAll()
		end				
			
		if oTask:GetValue("taskid") == 10033 then
			g_GuideCtrl:ReqCustomGuideFinish("Complete_Task_10033")
			g_GuideCtrl:TriggerAll()
		end				
	end

	self:DelTaskTypeTable(oTask)
	self.m_TaskDataDic[taskid] = nil
	self:RefreshUI()
	self:CheckNpcMark()

	--更新护送跟随
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:UpdateTaskNpcFollowers()
	end
end

function CTaskCtrl.CheckTaskThing(self)
	self:CheckTaskModel()	
	if self.m_RecordLogic.oTask then
		-- 自动寻路
		--TODO 延时1秒，等npc加载完成	
		Utils.AddTimer(function ()			
			if self.m_RecordLogic.oTask then
				g_TaskCtrl:ClickTaskLogic(self.m_RecordLogic.oTask, nil, {clickTask = self:IsWalingTask()})
			end			
		end, 0, 1)			
	end
end

function CTaskCtrl.CheckTaskModel(self)
	self.m_DynamicNpcList = {}
	self.m_PickItemList = {}
	self.m_EscortNpcList = {}
	self.m_TraceNpcList = {}
	self.m_TaskChapterNpc = {}
	for _,v in pairs(self.m_TaskDataDic) do
		self:DoCheckDynamicNpc(v, true)
		self:DoCheckPickModel(v, true)
		self:DoCheckEscortNpc(v)
		self:DoCheckTraceNpc(v)
	end
	self:RefreshTaskModel()
end

function CTaskCtrl.DoCheckDynamicNpc(self, task, addDyNpc)
	-- if task:GetValue("tasktype") == define.Task.TaskType.TASK_TRACE then
	-- 	return
	-- end
	--如果是虚拟场景，暂时不生成NPc
	if not g_MapCtrl:GetSceneID() or g_MapCtrl:IsVirtualScene() then
		return 
	end
	local curMapID = g_MapCtrl:GetMapID()
	local clientnpcList = task:GetValue("clientnpc")

	--如果有战役NPC则不刷新
	local isChapterFbNpc = false	
	if self:CheckChapterFbNpc(task, curMapID, addDyNpc) then
		addDyNpc = false
		isChapterFbNpc = true
	end

	if clientnpcList and #clientnpcList > 0 then
		for _,v in ipairs(clientnpcList) do
			local isAdd = addDyNpc
			--跟踪类任务根据任务状态来添加动态NPC
			if task:GetValue("tasktype") == define.Task.TaskType.TASK_TRACE then
				local traceinfo = task:GetValue("traceinfo")
				if traceinfo and traceinfo.npctype == v.npctype then
					local status = task:GetValue("status")
					if status == define.Task.TaskStatus.Accept and not isChapterFbNpc then
						isAdd = true
					else
						isAdd = false
					end					
				end									
			end
			if isAdd then
				if v.map_id == curMapID then
					local existInList = false
					for _,npc in ipairs(self.m_DynamicNpcList) do
						if v.npcid == npc.npcid then
							existInList = true
							break
						end
					end

					if not existInList then
						table.insert(self.m_DynamicNpcList, v)
					end
				end
			else
				for i,npc in ipairs(self.m_DynamicNpcList) do
					if v.npcid == npc.npcid then
						g_MapCtrl:DelDynamicNpc(v.npcid)
						v = nil
						table.remove(self.m_DynamicNpcList, i)
						break
					end
				end
			end
		end
	end
end

function CTaskCtrl.DoCheckEscortNpc(self, task)
	--如果是虚拟场景，暂时不生成NPc
	if not g_MapCtrl:GetSceneID() or g_MapCtrl:IsVirtualScene() then
		return 
	end
	if task:GetValue("tasktype") ~= define.Task.TaskType.TASK_ESCORT then
		return
	end
	local curMapID = g_MapCtrl:GetMapID()
	local traceinfo = task:GetValue("traceinfo")
	local clientnpcList = task:GetValue("clientnpc")
	local status = task:GetStatus()
	if traceinfo and next(traceinfo) ~= nil then
		local addEsNpc = false
		if traceinfo.status == 1 and status ~= define.Task.TaskStatus.Del then
			addEsNpc = true
		end		

		if addEsNpc then
			local existInList = false
			for _,npc in ipairs(self.m_EscortNpcList) do
				if traceinfo.npctype == npc.npctype then
					existInList = true
					break
				end
			end
			if not existInList then
				local taskNpcInfo = self:GetTaskNpc(traceinfo.npctype)	
				if taskNpcInfo then
					local pos
					if clientnpcList and #clientnpcList > 0 then
						for k, v in ipairs(clientnpcList) do
							if v.npctype == traceinfo.npctype then
								pos = v.pos_info
								break
							end
						end
					end
					if not pos then
						if traceinfo.pos_x > 1000 then
							pos = {x = traceinfo.pos_x, y = traceinfo.pos_y}	
						else
							pos = {x = traceinfo.pos_x * 1000, y = traceinfo.pos_y * 1000}	
						end						
					end
					local mode = {scale = 1, shape = taskNpcInfo.modelId}
					local npc = 
					{
						map_id = traceinfo.mapid,
						npctype = traceinfo.npctype,
						name = taskNpcInfo.name,
						model_info = mode,
						pos_info = pos,
					}				
					table.insert(self.m_EscortNpcList, npc)
				end
				
			end
		else		
			for i,npc in ipairs(self.m_EscortNpcList) do
				--local npcType = g_MapCtrl:GetNpcTypeByNpcId(npc.npcid)
				if traceinfo.npctype == npc.npctype then
					g_MapCtrl:DelEscortNpc(traceinfo.npctype)
					table.remove(self.m_EscortNpcList, i)
					break
				end
			end
		end
	end
end

function CTaskCtrl.DoCheckTraceNpc(self, task)
	--如果是虚拟场景，暂时不生成NPc
	if not g_MapCtrl:GetSceneID() or g_MapCtrl:IsVirtualScene() then
		return 
	end
	if task:GetValue("tasktype") ~= define.Task.TaskType.TASK_TRACE then
		return
	end	
	local traceinfo = task:GetValue("traceinfo")
	local curMapID = g_MapCtrl:GetMapID()
	table.print(traceinfo)
	local clientnpcList = task:GetValue("clientnpc")
	if traceinfo and next(traceinfo) and clientnpcList and next(clientnpcList) then
		local addTrNpc = false
		if task:GetValue("status") == define.Task.TaskStatus.Doing then
			addTrNpc = true
		end	
		if addTrNpc then
			local existInList = false
			for _,npc in ipairs(self.m_TraceNpcList) do
				if traceinfo.npctype == npc.npctype then
					existInList = true
					break
				end
			end
			if not existInList then
				local taskNpcInfo = self:GetTaskNpc(traceinfo.npctype)	
				if taskNpcInfo then
					local mode = {scale = 1, shape = taskNpcInfo.modelId}
					local npc = 
					{
						taskId = task:GetValue("taskid"),
						npctype = traceinfo.npctype,
						name = taskNpcInfo.name,
						model_info = mode,
					}
					local clientInfo 
					for k, v in ipairs(clientnpcList) do
						if v.npctype == traceinfo.npctype then
							clientInfo = v
							break
						end
					end
					--当前坐标解析
					local pos_info = {}				
					pos_info.map_id = traceinfo.cur_mapid or 0
					pos_info.x = traceinfo.cur_posx or 0
					pos_info.y = traceinfo.cur_posy or 0
					--目的坐标
					local target_pos = {}
					target_pos.pos_info = {}
					target_pos.map_id = traceinfo.mapid
					target_pos.pos_info.x = traceinfo.pos_x
					target_pos.pos_info.y = traceinfo.pos_y
					if pos_info.map_id ~= 0 then
						npc.map_id = pos_info.map_id
						npc.pos_info = pos_info
					elseif clientInfo then
						npc.map_id = clientInfo.map_id
						npc.pos_info = clientInfo.pos_info
					end
					--如果该跟踪的对象不再此地图，则忽略
					if npc.map_id ~= g_MapCtrl:GetMapID() then
						return
					end
					--坐标系同步
					if not (target_pos.pos_info.x > 1000) then
						target_pos.pos_info.x = target_pos.pos_info.x * 1000
						target_pos.pos_info.y = target_pos.pos_info.y * 1000
					end	
					npc.target = target_pos			
					--坐标系同步
					if not (npc.pos_info.x > 1000) then
						npc.pos_info.x = npc.pos_info.x * 1000 
						npc.pos_info.y = npc.pos_info.y * 1000
					end				
					table.insert(self.m_TraceNpcList, npc)							
				end				
			end
		else
			for i,npc in ipairs(self.m_TraceNpcList) do
				if traceinfo.npctype == npc.npctype then
					g_MapCtrl:DelTraceNpc(traceinfo.npctype)
					table.remove(self.m_TraceNpcList, i)
					break
				end
			end
		end
	end
end

function CTaskCtrl.DoCheckPickModel(self, oTask, addPick)
	--如果是虚拟场景，暂时不生成NPc
	if not g_MapCtrl:GetSceneID() or g_MapCtrl:IsVirtualScene() then
		return 
	end
	if oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_PICK) then
		-- print(string.format("<color=#00FFFF> >>> .%s | %s </color>", "DoCheckPickModel", "检查采集类型任务Model"))
		if oTask.m_Finish then
			return
		end

		--printc(" DoCheckPickModel  ...", addPick)

		local pickThing = oTask:GetProgressThing() 
		--table.print(pickThing)
		if pickThing then
			if addPick then
				if g_MapCtrl:IsCurMap(pickThing.map_id) then
					local existInList = false
					for _,pick in ipairs(self.m_PickItemList) do
						if pickThing.pickid == pick.pickid then
							existInList = true
							break
						end
					end

					if not existInList then
						table.insert(self.m_PickItemList, pickThing)
					end
				end
			else
				for i,pick in ipairs(self.m_PickItemList) do
					if pickThing.pickid == pick.pickid then
						g_MapCtrl:DelTaskPickItem(pickThing.pickid)
						pickThing = nil
						table.remove(self.m_PickItemList, i)
						break
					end
				end
			end
		end
	end
end

function CTaskCtrl.DelTaskTypeTable(self, task)
	if task then
		local tasktype = task:GetValue("tasktype")
		local taskid = task:GetValue("taskid")
		local tTasks = self.m_TaskTypeDic[tasktype]
		if tTasks and tTasks[taskid] then
			tTasks[taskid] = nil
		end
	end
end

function CTaskCtrl.GS2CRefreshTask(self, taskid, target, name, statusinfo, accepttime)

	local oTask = self.m_TaskDataDic[taskid]
	if not oTask then
		printc("任务刷新 >>> 不存在任务ID:", taskid)
		return
	end
	if target then
		oTask.m_SData.target = target
	end
	if name then
		oTask.m_SData.name = name		
	end
	if accepttime then
		oTask.m_SData.accepttime = accepttime		
	end

	if statusinfo and oTask.m_SData.statusinfo ~= statusinfo then
		oTask.m_SData.statusinfo = statusinfo
		self:RefreshUI()
	else
		self:RefreshSpecityBoxUI({task = oTask})
	end

	--更新人物标志
	self:CheckTaskStatus(oTask)
	self:CheckNpcMark()

	if oTask:GetValue("taskid") == 10031 then
		if not g_GuideCtrl:IsCustomGuideFinishByKey("Complete_Task_10031") then
			g_GuideCtrl:ReqCustomGuideFinish("Complete_Task_10031")
			g_GuideCtrl:TriggerCheck("view")
		end			
	end

	local taskType = oTask:GetValue("tasktype")

	if taskType == define.Task.TaskType.TASK_ESCORT then
		self:DoCheckDynamicNpc(oTask, true)
		self:DoCheckEscortNpc(oTask)
		self:RefreshDynamicNpc()
		self:RefreshEscortNpc()
	elseif taskType == define.Task.TaskType.TASK_TRACE then
		--如果任务失败，导致重新刷新任务，重置跟踪的当前坐标
		if oTask:GetValue("status") == define.Task.TaskStatus.Accept then
			self:ResetTraceTaskTraceinfo(oTask)
		end
		self:DoCheckDynamicNpc(oTask, true)
		self:DoCheckTraceNpc(oTask)
		self:RefreshDynamicNpc()
		self:RefreshTraceNpc()		
	elseif taskType == define.Task.TaskType.TASK_PICK then
		self:DoCheckPickModel(oTask, oTask:GetValue("status") == define.Task.TaskStatus.Doing)
		self:RefreshPickItem()
	end		
end

function CTaskCtrl.GS2CRemoveTaskNpc(self, npcid, taskid, target)
	g_MapCtrl:DelDynamicNpc(npcid)

	local oTask = self.m_TaskDataDic[taskid]
	if oTask then

		local clientnpcList = oTask:GetValue("clientnpc")
		if clientnpcList then
			for i, npc in ipairs(clientnpcList) do
				if npc.npcid == npcid then
					table.remove(clientnpcList, i)
					break
				end
			end
		else
			print("not has clientnpcList")
		end
	end

	for i,npc in ipairs(self.m_DynamicNpcList) do
		if npc.npcid == npcid then			
			npc = nil
			table.remove(self.m_DynamicNpcList, i)
			break
		end
	end
	-- self:DoCheckDynamicNpc(oTask, false)
	-- self:RefreshDynamicNpc()
end

-- [[界面刷新]]
function CTaskCtrl.RefreshUI(self)
	if self.m_RefreshTimerUI then
		Utils.DelTimer(self.m_RefreshTimerUI)
		self.m_RefreshTimerUI = nil
	end
	local function update()
		self:OnEvent(define.Task.Event.RefreshAllTaskBox)
		return false
	end
	self.m_RefreshTimerUI = Utils.AddTimer(update, 0.3, 0.3)
end

function CTaskCtrl.RefreshMark(self)
	if self.m_RefreshTimerMark then
		Utils.DelTimer(self.m_RefreshTimerMark)
		self.m_RefreshTimerMark = nil
	end
	local function update()
		if not CDialogueMainView:GetView() then
			g_MapCtrl:RefreshTaskNpcMark()
		end		
		return false
	end
	self.m_RefreshTimerMark = Utils.AddTimer(update, 0.3, 0.3)
end

-- arg = {taskid = a, task = b}
function CTaskCtrl.RefreshSpecityBoxUI(self, arg)
	local taskid = arg.taskid
	if not taskid then
		if not arg.task then
			return
		end
		taskid = arg.task:GetValue("taskid")
	end

	-- 任务信息事件Fire
	self:OnEvent(define.Task.Event.RefreshSpecificTaskBox, taskid)
end

function CTaskCtrl.RefreshTaskModel(self)
	self:RefreshDynamicNpc()
	self:RefreshEscortNpc()
	self:RefreshTraceNpc()
	self:RefreshPickItem()
	self:RefreshChapterFbNpc()
end

function CTaskCtrl.RefreshDynamicNpc(self)
	for _,v in ipairs(self.m_DynamicNpcList) do
		g_MapCtrl:AddDynamicNpc(v)
	end	
end

function CTaskCtrl.RefreshEscortNpc(self)
	for _,v in ipairs(self.m_EscortNpcList) do
		g_MapCtrl:AddEscortNpc(v)
	end
end

function CTaskCtrl.RefreshTraceNpc(self)
	for _,v in ipairs(self.m_TraceNpcList) do
		g_MapCtrl:AddTraceNpc(v)
	end
end

function CTaskCtrl.RefreshPickItem(self)
	for _,v in ipairs(self.m_PickItemList) do
		g_MapCtrl:AddTaskPickItem(v)
	end
end

function CTaskCtrl.RefreshChapterFbNpc(self)
	for _,v in ipairs(self.m_TaskChapterNpc) do
		g_MapCtrl:AddTaskChapterNpcNpc(v)		
	end
end

-- [[数据获取]]
function CTaskCtrl.GetTaskDataList(self)
	return self.m_TaskDataDic
end

function CTaskCtrl.GetTaskDataListWithSort(self)
	local list = {}
	for _,v in pairs(self.m_TaskDataDic) do
		table.insert(list, v)
	end

	--如果当前可以触发伙伴支线，则添加伙伴支线领取跳转任务
	if self:GetPartnerTaskProgressStatue() == 1 then
		local oTask = self:LocalNewPartnerAccetpTask()
		table.insert(list, oTask)
	end

	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shimen.open_grade and self.m_ShiMenTaskStatue == 1 then
		local oTask = self:LocalNewShiMenTask(self.m_ShiMenTaskStatue)
		table.insert(list, oTask)
	end

	local function GetMenuShowIndex(type, isSort)
		local index = 0
		local d = data.taskdata.TASKTYPE[type]

		if d then
			if isSort then
				index = d.menu_show_index_sort
			else
				index = d.menu_show_index
			end
		end
		if index == 0 then
			index = 999
		end
		return index
	end
	local function sortfunc(v1, v2)
		local sidx1 = GetMenuShowIndex(v1:GetValue("type"))
		local sidx2 = GetMenuShowIndex(v2:GetValue("type"))
		if sidx1 == sidx2 then
			local _sidx1 = GetMenuShowIndex(v1:GetValue("type"), true)
			local _sidx2 = GetMenuShowIndex(v2:GetValue("type"), true)
			if _sidx1 == _sidx2 then
				return v1:GetValue("taskid") < v2:GetValue("taskid")
			else
				return _sidx1 < _sidx2
			end			
		else
			return sidx1 < sidx2
		end
	end
	table.sort(list, sortfunc)
	return list
end

function CTaskCtrl.GetTaskById(self, taskid)
	local oTask = self.m_TaskDataDic[taskid]
	return oTask
end

function CTaskCtrl.GetTaskListByType(self, taskType)
	return self.m_TaskTypeDic[taskType]
end

--获取任务数据菜单，返回 Table:
function CTaskCtrl.GetTaskMenuTable(self)
	local taskMenu = 
	{
		[1] = {tab = 1, taskList = {}},	 --已接
		[2] = {tab = 2, taskList = {}},	 --可接
		[3] = {tab = 3, taskList = {}},  --剧情
	}	
	local isAddTeachTask = false

	for _,task in pairs(self.m_TaskDataDic) do		
		local type = task:GetValue("type") or define.Task.TaskCategory.TEST.ID
		local acceptGrade = task:GetValue("acceptgrade")		
		if type ~= define.Task.TaskCategory.STORY.ID or g_AttrCtrl.grade >= acceptGrade then

			if type ~= define.Task.TaskCategory.TEACH.ID then
				local status = task:GetValue("status") or define.Task.TaskStatus.Accept

				--任务都是进行中任务
				taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
				table.insert(taskMenu[1].taskList[type], task)	

				--按照可接和进行中分类
				-- if status == define.Task.TaskStatus.Accept then
				-- 	taskMenu[2].taskList[type] = taskMenu[2].taskList[type] or {}
				-- 	table.insert(taskMenu[2].taskList[type], task)				
				-- else
				-- 	taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
				-- 	table.insert(taskMenu[1].taskList[type], task)				
				-- end	

			elseif (type == define.Task.TaskCategory.TEACH.ID and isAddTeachTask == false )  then
				isAddTeachTask = true
				local oTask = self:LocalNewTeachTask()				
				--任务都是进行中任务
				taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
				table.insert(taskMenu[1].taskList[type], oTask)	

			end
	
		end
	end
	if not isAddTeachTask and g_TeachCtrl:IsNeedToShow() then
		local oTask = self:LocalNewTeachTask()
		local type = define.Task.TaskCategory.TEACH.ID
		taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
		table.insert(taskMenu[1].taskList[type], oTask)
	end

	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shimen.open_grade and self.m_ShiMenTaskStatue == 1 then
		local oTask = self:LocalNewShiMenTask(self.m_ShiMenTaskStatue)
		local type = define.Task.TaskCategory.SHIMEN.ID
		taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
		table.insert(taskMenu[1].taskList[type], oTask)	
	end

	--如果当前可以触发伙伴支线，则添加伙伴支线领取跳转任务
	if self:GetPartnerTaskProgressStatue() == 1 then
		local oTask = self:LocalNewPartnerAccetpTask()
		local type = define.Task.TaskCategory.PARTNER.ID
		taskMenu[1].taskList[type] = taskMenu[1].taskList[type] or {}
		table.insert(taskMenu[1].taskList[type], oTask)		
	end

	table.print(taskMenu)
	return taskMenu
end

-- [[逻辑处理]]
-- 获取指定Npc相关任务
function CTaskCtrl.GetNpcAssociatedTaskList(self, npcid)
	local taskList = {}
	if npcid and npcid > 0 then
		for _,v in pairs(self.m_TaskDataDic) do
			if v:GetValue("taskid") ~= CTaskCtrl.DailyCultivateTaskID then
				local associated = v:AssociatedNpc(npcid)
				if associated then
					table.insert(taskList, v)
				end
			end			
		end
	end

	return taskList
end

-- 获取指定Pick相关任务
function CTaskCtrl.GetPickAssociatedTaskList(self, pickid)
	local taskList = {}
	if pickid and pickid > 0 then
		for _,v in pairs(self.m_TaskDataDic) do
			local associated = v:AssociatedPick(pickid)
			if associated then
				table.insert(taskList, v)
			end
		end
	end
	return taskList
end

-- [[检查Npc头顶标识]]
function CTaskCtrl.CheckNpcMark(self)
	self.m_NpcMarkDic = {}
	-- 已存在的任务检查
	if not g_MapCtrl:IsVirtualScene() then
		for _,oTask in pairs(self.m_TaskDataDic) do
			if oTask:GetValue("type") ~= define.Task.TaskCategory.ACHIEVE.ID then
				self:RecheckTaskNpcMark(oTask)
			end
		end
	end
	self:RefreshMark()
end

function CTaskCtrl.RecheckTaskNpcMark(self, oTask, refRealTime)
	local isTaskFight = oTask:IsTaskSpecityAction(define.Task.TaskType.TASK_NPC_FIGHT)
	local isTaskStory = oTask:IsTaskSpecityCategory(define.Task.TaskCategory.STORY)
	local targetNpcId = oTask:GetValue("target")
	local submitNpcId = oTask:GetValue("submitNpcId")
	local npcMarkEnum = enum.Task.NpcMark
	local npcTypeList = {}
	if targetNpcId == submitNpcId then
		npcTypeList = {targetNpcId}
	else
		npcTypeList = {
			targetNpcId,
			-- submitNpcId,
		}
	end
	for _,npcType in ipairs(npcTypeList) do
		local mark = npcMarkEnum.Nothing
		local status = oTask:GetValue("status")		
		if status == define.Task.TaskStatus.Accept then
			mark = npcMarkEnum.Accept

		elseif status == define.Task.TaskStatus.Doing then
			mark = npcMarkEnum.Doing

		elseif status == define.Task.TaskStatus.Done then
			mark = npcMarkEnum.Done
		end
		
		local curMark = self.m_NpcMarkDic[npcType]
		if not curMark or curMark < mark then
			self.m_NpcMarkDic[npcType] = mark
		end

		if refRealTime then
			g_MapCtrl:RefreshSpecityTaskNpcMark(npcType, mark)
		end
	end
end

-- 获取指定Npc头顶状态
function CTaskCtrl.GetNpcAssociatedTaskMark(self, npcid)
	-- printc("寻找Npc头顶标识：NpcID", npcid)
	local markID = self.m_NpcMarkDic[npcid]
	return self:GetNpcMarkSprName(markID)
end

function CTaskCtrl.GetNpcMarkSprName(self, markID)
	if markID and markID > 0 then
		-- printc("标识名称", CTaskCtrl.m_NpcMarkSprName[markID])
		return CTaskCtrl.m_NpcMarkSprName[markID]
	end
end

--todo
function CTaskCtrl.IsDoingEscortTask(self)
	return g_MapCtrl.m_EscortNpcs ~= nil and next(g_MapCtrl.m_EscortNpcs) ~= nil
end

function CTaskCtrl.IsDoingTraceTask(self)
	return self.m_HeroTracingTarget
end

function CTaskCtrl.SetDoingTraceTask(self, npcType)
	self.m_HeroTracingTarget = npcType
end

function CTaskCtrl.SetTraceSwitchMap(self, b)
	self.m_TraceSwitchMap = b
end

function CTaskCtrl.IsTraceSwitchMap(self)
	return self.m_TraceSwitchMap == true
end

--接受任务
function CTaskCtrl.C2GSAcceptTask(self, taskId)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAcceptTask"]) then
		nettask.C2GSAcceptTask(taskId)	
	end
end

--提交任务
function CTaskCtrl.C2GSCommitTask( self, taskId )
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSCommitTask"]) then
		nettask.C2GSCommitTask(taskId)
	end
end

--放弃任务
function CTaskCtrl.C2GSAbandonTask( self, taskId )
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAbandonTask"]) then
		nettask.C2GSAbandonTask(taskId)
	end
end

-- 获取任务奖励
function CTaskCtrl.GetTaskRewardList(self, oTask)
	local itemList = {}
	if oTask then

		--如果是成就支线任务则另外解析
		if oTask:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
			return self:GetAchieveTaskItemList(oTask)
		end

		local rewardIDList = oTask:GetValue("submitRewardStr")
		-- printc(" submitRewardStr ", rewardIDList)
		-- table.print(rewardIDList)

		if rewardIDList then
			local category = CTaskHelp.GetTaskCategory(oTask)

			-- printc(" category ", category, oTask:GetValue("type"))
			-- table.print(category)

			if category then
				local coinId = tonumber(data.globaldata.GLOBAL.attr_coin_itemid.value)  --金币id
				local expId= tonumber(data.globaldata.GLOBAL.attr_exp_itemid.value) --经验id
				local goldCoinId = tonumber(data.globaldata.GLOBAL.attr_goldcoin_itemid.value) --水晶id
				local partnerId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)--伙伴奖励道具id

				local sidList = {}

				local function AnalysisRewardInfo(RewardInfo)
					-- printc("AnalysisRewardInfo  ")
					-- table.print(RewardInfo)

					if RewardInfo.task_reward and #RewardInfo.task_reward > 0 then
						for _,v in ipairs(RewardInfo.task_reward) do									
							if v.equip_reward and v.equip_reward ~= "" then
								--装备副本的解析装备函数
								local equipList = g_EquipFubenCtrl:DecodeReward(v.equip_reward)
								if equipList and next(equipList) then
									for i = 1, #equipList do
										sidList[equipList[i].sid] = sidList[equipList[i].sid] or 0
										sidList[equipList[i].sid] = sidList[equipList[i].sid] + v.amount
									end
								end

							elseif v.sid and v.sid ~= "" then
								local list = string.split(v.sid, ",")
								if list and #list > 0 then
									for i = 1, #list do
										if string.find(list[i], "value") then
											local sid, value = g_ItemCtrl:SplitSidAndValue(list[i])
											sidList[sid] = sidList[sid] or 0
											sidList[sid] = sidList[sid] + value
									
										elseif string.find(list[i], "partner") then
											local sid, parId = g_ItemCtrl:SplitSidAndValue(list[i])
											sidList[sid] = sidList[sid] or {}	
											sidList[sid][parId] = sidList[sid][parId] or {}											
											sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount or 0
											sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount + v.amount

										else
											local sid = tonumber(list[i])
											sidList[sid] = sidList[sid] or 0
											sidList[sid] = sidList[sid] + v.amount
										end
									end
								end
							end							
						end
					end					

					if RewardInfo.coin and tonumber(RewardInfo.coin) and tonumber(RewardInfo.coin) > 0 then
						sidList[coinId] = sidList[coinId] or 0
						sidList[coinId] = sidList[coinId] + tonumber(RewardInfo.coin)
					end

					if RewardInfo.exp and tonumber(RewardInfo.exp) and tonumber(RewardInfo.exp) > 0 then
						sidList[expId] = sidList[expId] or 0
						sidList[expId] = sidList[expId] + tonumber(RewardInfo.exp)
					end	
				end

				for _,s in ipairs(rewardIDList) do
					local r = string.find(s, 'R')
					if r == 1 then
						local id = string.sub(s, 2)
						local rewardInfo = DataTools.GetReward(category.NAME, id)
						if rewardInfo then
							AnalysisRewardInfo(rewardInfo)
						end
					end
				end

				for sid, v in pairs(sidList) do					
				
					local localSid = tonumber(sid)										
					if localSid == partnerId then
						if v and next(v) ~= nil then
							for parid, partner in pairs(v) do
								local d = {}
								d.sid = localSid
								d.partnerId = parid
								d.amount = partner.partner_amount								
								table.insert(itemList, d)
							end	
						end						
					else
						local d = {}
						d.sid = localSid
						d.amount = v
						table.insert(itemList, d)
					end				
				end

				table.sort(itemList, function (a, b)
					return a.sid > b.sid
				end)

			end
		end
	end
	return itemList
end

-- 客户端点击任务逻辑处理（领取任务，寻路，提交等）
-- continuTask 不进行，特殊场景判断
function CTaskCtrl.ClickTaskLogic(self, oTask, continuTask, config)
	table.print(oTask)
	self:SetRecordLogic(nil)
	
	config = config or {}
	config.m_IsClickTask = config.clickTask == nil and false or config.clickTask

	if not oTask then
		printc("无效的任务参数")
		return false
	end

	local taskType = oTask:GetValue("tasktype")
	local taskId = oTask:GetValue("taskid")
	local status = oTask:GetValue("status")
	local acceptGrade = oTask:GetValue("acceptgrade")
	local type = oTask:GetValue("type")
	local isMissMengTask = oTask:IsMissMengTask()

	--如果在队伍，并且不是队长，也没有暂离则点击任务，直接忽略
	if g_TeamCtrl:IsJoinTeam() then
		if not g_TeamCtrl:IsLeader() and g_TeamCtrl:IsInTeam() then
			--只有是成就直线，并且完成的情况下，可以直接领取
			if type ~= define.Task.TaskCategory.ACHIEVE.ID or status ~= define.Task.TaskStatus.Done then
				g_NotifyCtrl:FloatMsg("请先暂离队伍")
				self.m_ClickTaskId  = 0
				return false					
			end
		end
	end

	--如果当前在特殊场景，点击任务特殊处理
	--local specilaMapTable = 
	--{
	--	["传说伙伴幻境"] = false,
	--}	
	--if specilaMapTable[g_MapCtrl:GetSceneName()] == false and continuTask == nil then
	--虚拟场景里面点击任务面板
	if g_MapCtrl:IsVirtualScene() and continuTask == nil then
		local sceneId = g_MapCtrl:GetSceneID()
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTaskInScene"]) then
			nettask.C2GSClickTaskInScene(sceneId, taskId)
		end
		return false
	end


	--如果是每日历练任务,则由服务端处理
	if taskId == CTaskCtrl.DailyCultivateTaskID then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
			nettask.C2GSClickTask(taskId)
		end

	elseif taskId == CTaskCtrl.TeachTaskId then
		g_TeachCtrl:OpenTeach()

	elseif taskId == CTaskCtrl.PartnerAccectTaskId then
		g_ItemCtrl:ItemUseSwitchTo(nil, "map_book_partner_book")

	elseif taskId == CTaskCtrl.ShiMenAccectTaskId then
		self:CheckWalkingTask(config.m_IsClickTask, taskId)
		self:PathFindTask(oTask, CTaskCtrl.PathFindMode.AcceptTask)

	--如果是小萌请求任务，则打开任务主界面
	elseif isMissMengTask == true then		
		if self.m_CanAutoTask then
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
				nettask.C2GSClickTask(taskId)
			end
		else		
			if not CTaskMainView:GetView() then
				CTaskMainView:ShowView(function (oView)
					oView:ShowDefaultTask(taskId)
				end)	
			end		
		end
	else
		--每日修正任务检测
		if g_ActivityCtrl:ClickTargetCheck(CActivityCtrl.DCClickEnum.Task, taskId, true) then
			return false
		end

		--点击成就支线处理
		if type == define.Task.TaskCategory.ACHIEVE.ID then
			return self:ClickBranchTaskLogic(oTask)
		end

		if g_AttrCtrl.grade < acceptGrade then
			--g_NotifyCtrl:FloatMsg("等级不足，看看冒险里有什么活动参加吧")			
			g_ScheduleCtrl:C2GSOpenScheduleUI(define.Schedule.Tag.Right1, define.Schedule.Tag.Top1)

		elseif self:CheckOpenChapterTask(oTask) then
			--跳转剧情副本
		else
			self:CheckWalkingTask(config.m_IsClickTask, taskId)	
			if status == define.Task.TaskStatus.Accept then
				self:PathFindTask(oTask, CTaskCtrl.PathFindMode.AcceptTask)

			else		
				if taskType == define.Task.TaskType.TASK_FIND_NPC then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
						nettask.C2GSClickTask(taskId)
					end

				elseif taskType == define.Task.TaskType.TASK_PICK then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
						nettask.C2GSClickTask(taskId)
					end

				elseif taskType == define.Task.TaskType.TASK_ITEM_USE then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
						nettask.C2GSClickTask(taskId)
					end

				elseif taskType == define.Task.TaskType.TASK_TRACE then					
					self:PathFindTask(oTask, CTaskCtrl.PathFindMode.FindTraceNpc)

				elseif taskType == define.Task.TaskType.TASK_ESCORT then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then					
						nettask.C2GSClickTask(taskId)
					end
				elseif taskType == define.Task.TaskType.TASK_PATROL then
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
						nettask.C2GSClickTask(taskId)
					end
				else
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickTask"]) then
						nettask.C2GSClickTask(taskId)
					end
				end
			end
		end
	end
	return true
end

--客户端任务寻路相关开始
function CTaskCtrl.PathFindTask(self, oTask, mode)
	if oTask then
		local npcType = nil 
		if mode == CTaskCtrl.PathFindMode.SubmitTask then			
			npcType = oTask:GetValue("submitNpcId")
		elseif mode == CTaskCtrl.PathFindMode.FindTraceNpc then
			npcType = oTask:GetValue("traceNpcType")
		else
			npcType = oTask:GetValue("acceptnpc")
		end

		local npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
		local npc = g_MapCtrl:GetGlobalNpc(npcType)
		local findPathCb = oTask:GetValue("findPathCb")
		if findPathCb then
			npcId = nil
		end
		
		--跟踪对象
		if mode == CTaskCtrl.PathFindMode.FindTraceNpc then
			local status = oTask:GetValue("status")
			if status == define.Task.TaskStatus.Doing then
				local traceinfo = oTask:GetValue("traceinfo")
				if not g_MapCtrl:IsCurMap(traceinfo.cur_mapid) then
					local oHero = g_MapCtrl:GetHero()
					if oHero then					
						if oTask:GetValue("autotype") == 1 then
							netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, traceinfo.cur_mapid)
							self:SetRecordLogic(oTask)
						else
							local curMapId = g_MapCtrl:GetMapID()
							local t = g_MapCtrl:GetMapAToMapBPath(curMapId, traceinfo.cur_mapid)
							if #t > 1 then
								local function switchMap()												
									netscene.C2GSTransfer(g_MapCtrl:GetSceneID(), oHero.m_Eid, t[1].transferId)																				
								end
								self:SetRecordLogic(oTask)
								oHero:AddBindObj("auto_find")
								oHero:WalkToAndSyncPos(t[1].x, t[1].y, switchMap)									
							end
						end
					end
				else
					local pos = {}
					pos.x = traceinfo.cur_posx
					pos.y = traceinfo.cur_posy
					pos.z = 0			
					g_MapTouchCtrl:WalkToPos(pos, nil, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function()						
						--如果走到NPC之前还没加载地图，走到目的地，在触发一次点击NPC							
						local oNpc = g_MapCtrl:GetTraceNpc(npcType)
						if oNpc then
							oNpc:Trigger()
						end									
						self:SetRecordLogic(nil)				
					end)		
				end
			end
		--常驻NPC
		elseif npc then		
			if not g_MapCtrl:IsCurMap(npc.sceneId) then
				local oHero = g_MapCtrl:GetHero()
				if oHero then					
					if oTask:GetValue("autotype") == 1 then
						netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, npc.sceneId)
						self:SetRecordLogic(oTask)
					else
						local curMapId = g_MapCtrl:GetMapID()
						local t = g_MapCtrl:GetMapAToMapBPath(curMapId, npc.map_id or npc.sceneId)
						if #t > 1 then
							local function switchMap()												
								netscene.C2GSTransfer(g_MapCtrl:GetSceneID(), oHero.m_Eid, t[1].transferId)																				
							end
							self:SetRecordLogic(oTask)
							oHero:AddBindObj("auto_find")
							oHero:WalkToAndSyncPos(t[1].x, t[1].y, switchMap)									
						end
					end
				end
			else
				local pos = {}
				pos.x = npc.x
				pos.y = npc.y
				pos.z = npc.z				
				g_MapTouchCtrl:WalkToPos(pos, npcId, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function()
					--如果走到NPC之前还没加载地图，走到目的地，在触发一次点击NPC
					--如果有寻路结束回调
					if findPathCb then
						findPathCb()						
					elseif npcId == nil then
						npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
						if npcId then
							local oNpc = g_MapCtrl:GetNpc(npcId)
							if oNpc then
								oNpc:Trigger()
							end
						end
					end					
					self:SetRecordLogic(nil)				
				end)		
			end
		--动态NPC
		else
			local clientNpcs = oTask:GetValue("clientnpc")
			if clientNpcs and #clientNpcs > 0 then				
				for i = 1 , #clientNpcs do
					npc = clientNpcs[i]					
					if npcType == npc.npctype then					
						if not g_MapCtrl:IsCurMap(npc.map_id) then
							local oHero = g_MapCtrl:GetHero()
							if oHero then							
								if oTask:GetValue("autotype") == 1 then
									netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, npc.map_id)
									self:SetRecordLogic(oTask)
								else
									local curMapId = g_MapCtrl:GetMapID()
									local t = g_MapCtrl:GetMapAToMapBPath(curMapId, npc.map_id)
									if #t > 1 then
										local function switchMap()												
											netscene.C2GSTransfer(g_MapCtrl:GetSceneID(), oHero.m_Eid, t[1].transferId)																				
										end
										self:SetRecordLogic(oTask)
										oHero:AddBindObj("auto_find")
										oHero:WalkToAndSyncPos(t[1].x, t[1].y, switchMap)									
									end
								end
							end													
						else
							local pos = {}
							if npc.pos_info.x > 1000 then
								pos.x = npc.pos_info.x / 1000
								pos.y = npc.pos_info.y / 1000
								pos.z = npc.pos_info.z or 0
							else
								pos.x = npc.pos_info.x
								pos.y = npc.pos_info.y
								pos.z = npc.pos_info.z or 0
							end				
							g_MapTouchCtrl:WalkToPos(pos, npcId, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function()
								--如果走到NPC之前还没加载地图，走到目的地，在触发一次点击NPC
								--如果有寻路结束回调
								if findPathCb then
									findPathCb()									
								elseif npcId == nil then
									npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
									local oNpc = nil
									--动态NPC
									if npcId then
										oNpc = g_MapCtrl:GetDynamicNpc(npcId)
										if oNpc then
											oNpc:Trigger()
										end
									end	
									--活动生成的动态NPC
									if not npcId or not oNpc and npcType then
										oNpc = g_MapCtrl:GetNpc(npcType)										
										if oNpc then
											oNpc:Trigger()
										end										
									end
								end											
								self:SetRecordLogic(nil)
							end)	
						end
						break
					end
				end
			end
		end
	end
end
--客户端任务寻路相关结束

function CTaskCtrl.CheckTaskItemAmount(self, sid)
	if sid then
		local t = {}
		for k, v in pairs(self.m_TaskDataDic) do
			local taskId = v:GetValue("taskid")
			local needItem = v:GetValue("needitem")			
			if needItem then
				for _, oItem in pairs(needItem) do
					if oItem.itemid == sid then
						local d = {taskid = taskId, sid = oItem.itemid}
						table.insert(t, d)
						break
					end
				end
			end
		end

		if next(t) ~= nil then
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskItemChange"]) then
				nettask.C2GSTaskItemChange(t)
			end
		end
	end
end

--获取任务的标题(导航上的任务标题和对话显示的任务标题)（任务类型和任务名称连起来）
function CTaskCtrl.GetTaskTitleDesc(self, oTask, isNavigation)
	local prefix = oTask.m_TaskType.name .. ":"
	local suffix = oTask:GetValue("name")
	local progress = ""
	if oTask:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
		local shimenInfo = oTask:GetValue("shimeninfo")
		if shimenInfo then
			progress = string.format("%s(%d/%d)", data.colordata.COLORINDARK["#R"], shimenInfo.cur_times, shimenInfo.max_times)
		end
	end
	--任务标题颜色控制
	if isNavigation == true then
		--暂时不显示任务类型
		return string.format("[FAE7B9]%s%s", suffix, progress)			
	else
		return string.format("%s%s", prefix, suffix)
	end 
end


--获取任务的标题(委托详情界面标题)
function CTaskCtrl.GetTaskDetailTitle(self, oTask)
	local prefix = oTask.m_TaskType.name .. "-"
	local suffix = oTask:GetValue("name")
	return string.format("%s%s", prefix, suffix)
end

--获取任务的描述
function CTaskCtrl.GetTargetDesc(self, oTask, isNavigation)
	local clor1 = "[FAE7B9]"
	local clor2 = "[654A33]"
	local targetDesc = ""
	local baseClolor = clor1
	if isNavigation == false then
		baseClolor = clor2
	end
	--成就支线任务
	if oTask:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
		if oTask:GetStatus() == define.Task.TaskStatus.Done then
			targetDesc = string.format("%s%s([4ddc75]%d[4ddc75]/%d%s)", baseClolor, oTask:GetValue("targetdesc"), oTask:GetValue("degree"), oTask:GetValue("target"), baseClolor)
		else
			targetDesc = string.format("%s%s([ff6868]%d[4ddc75]/%d%s)", baseClolor, oTask:GetValue("targetdesc"), oTask:GetValue("degree"), oTask:GetValue("target"), baseClolor)
		end	

	--日常任务
	elseif oTask:GetValue("type") == define.Task.TaskCategory.DAILY.ID then
		if isNavigation == false then
			targetDesc = string.format("%s%s", clor2, oTask:GetValue("detaildesc"))
		else
			targetDesc = string.format("%s%s", baseClolor, oTask:GetValue("targetdesc"))	
		end
	--主线
	elseif oTask:GetValue("type") == define.Task.TaskCategory.STORY.ID then
		if isNavigation == false then
			targetDesc = string.format("%s%s", clor2, oTask:GetValue("detaildesc"))
		else
			targetDesc = string.format("%s%s", baseClolor, oTask:GetValue("targetdesc"))
		end
	--其他
	else
		targetDesc = string.format("%s%s", baseClolor, oTask:GetValue("targetdesc"))
	end
	
	return targetDesc
end

--获取任务的npc
function CTaskCtrl.GetTaskNpc(self, npctype)
	local taskData = data.taskdata.TASK
	for k,v in pairs(taskData) do
		if v and v.NPC and v.NPC[npctype] then
			return v.NPC[npctype]
		end
	end
	local npc = data.npcdata.NPC.GLOBAL_NPC[npctype]
	if npc then
		return {modelId = npc.modelId, name = npc.name, rotateY = npc.rotateY, model_info = npc.model_info}
	end
	return {
		name = '未导表任务Npc:' .. npctype,
		id = npctype,
		model_info = {}
	}
end

--任务接受，刷新，还有登陆时，根据本地状况刷新状态(主要用于寻人，寻物, 寻地)
--若otask为nil 则表示刷新所有任务
function CTaskCtrl.CheckTaskStatus(self, oTask)		
	self:CheckTaskStatusFindNpc(oTask)
	self:CheckTaskStatusFindItem(oTask)
end

--寻人类任务检测
function CTaskCtrl.CheckTaskStatusFindNpc(self, oTask)		
	local taskList = {}
	if oTask then
		if oTask:GetValue("tasktype") == define.Task.TaskType.TASK_FIND_NPC then
			taskList[1] = oTask
		end
	else
		taskList = self.m_TaskTypeDic[define.Task.TaskType.TASK_FIND_NPC] or {}
	end
	if taskList and next(taskList) ~= nil then
		for k, v in pairs(taskList) do 
			local status = v:GetValue("status")
			if status == define.Task.TaskStatus.Doing then
				v:SetStatus(define.Task.TaskStatus.Done)
				self:RefreshUI()
			end
		end
	end
end

--寻物任务检测
function CTaskCtrl.CheckTaskStatusFindItem(self, oTask)		
	local taskList = {}
	if oTask then
		if oTask:GetValue("tasktype") == define.Task.TaskType.TASK_FIND_ITEM then
			taskList[1] = oTask
		end
	else
		taskList = self.m_TaskTypeDic[define.Task.TaskType.TASK_FIND_ITEM] or {}
	end
	if taskList and next(taskList) ~= nil then
		for k, v in pairs(taskList) do 
			local status = v:GetValue("status")
			if status == define.Task.TaskStatus.Doing then
				local t = {}
				local needItem = v:GetValue("needitem")		
				if needItem and next(needItem) ~= nil then
					for _, oItem in pairs(needItem) do
						local count = g_ItemCtrl:GetTargetItemCountBySid(oItem.itemid)
						if count > 0 then
							local taskId = v:GetValue("taskId")
							local d = {taskid = taskId, sid = oItem.itemid}
							table.insert(t, d)			
						end
					end	
					if next(t) ~= nil then
						if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTaskItemChange"]) then
							nettask.C2GSTaskItemChange(t)
						end
					end
				end				
			end
		end
	end
end

--重置任务的结束时间
function CTaskCtrl.CheckTaskEndTime(self, oTask)		
	if oTask then
		oTask:ResetEndTime()
	else
		for _, oTask in pairs(self.m_TaskDataDic) do
			oTask:ResetEndTime()
		end
	end		
end

--获取最后接受的任务
function CTaskCtrl.GetLastAcceptTask(self)
	local task = nil
	local accpetTime = nil	

	--只有显示在任务主界面上的任务，才会假如判断
	local taskMask = {}
	local d = data.taskdata.TASKTYPE
	for i = 1, #d do
		if d[i].menu_index ~= 0 then
			taskMask[d[i].id ] = d[i].menu_index
		end
	end

	for _, oTask in pairs(self.m_TaskDataDic) do
		--现在暂时任务都是已经接受的		
		--if oTask:GetValue("status") ~= define.Task.TaskStatus.Accept and oTask:GetValue("taskid") ~= CTaskCtrl.DailyCultivateTaskID  then	
		if oTask:GetValue("taskid") ~= CTaskCtrl.DailyCultivateTaskID and taskMask[oTask:GetValue("type")] ~= nil then	
			local time = oTask:GetValue("accepttime") or 0   --如果任务没有接受，默认时间为0
			if time then
				if task == nil then
					task = oTask
					accpetTime = time
				elseif time >= accpetTime then
					task = oTask
					accpetTime = time
				end
			end
		end
	end

	if not task and self.m_ShiMenTaskStatue == 1 or self.m_ShiMenTaskStatue == 3 then
		task = self:LocalNewPartnerAccetpTask(self.m_ShiMenTaskStatue)
	end

	--如果没有最后接受的任务，则看看是否有本地生成的任务
	if not task then
		if self:GetPartnerTaskProgressStatue( ) == 1 then
			task = self:LocalNewPartnerAccetpTask()
		end
	end
	return task
end

--获取每日历练任务
function CTaskCtrl.GetDailyCultivateTask(self)
	local task = nil
	for _,v in pairs(self.m_TaskDataDic) do
		if v:GetValue("taskid") == CTaskCtrl.DailyCultivateTaskID then
			task = v
			break
		end
	end
	return task
end

--获取奖励列表
function CTaskCtrl.GetRewardList(self, rewardData, ids)
	local reward = {}
	for k,v in pairs(ids) do
		local list = rewardData[k].reward
		for k1,v1 in pairs(list) do
			
		end
	end
	return reward
end

--服务器返回执行点击任务逻辑
function CTaskCtrl.CtrlGS2CContinueClickTask(self, taskId)
	local oTask	= self:GetTaskById(taskId)
	if oTask then
		self:ClickTaskLogic(oTask, true)
	end
end

--对话完毕后，让护送npc跟随主角
function CTaskCtrl.EscortNpcFollowHero(self)
	for k, npc in pairs(g_MapCtrl.m_EscortNpcs) do
		if npc.m_IsFollowHero == false then
			npc.m_IsCanFollowHero = true
			npc:DelayCall(0, "RefreshNpcVisible")
		end
	end
end

--延迟检测是否有主线章节动画任务
function CTaskCtrl.CheckStartStoryTask(self)
	if self.m_StartStoryTask then		
		g_DialogueCtrl:PlayStartStory(self.m_StartStoryTask:GetValue("playid"))
		self.m_StartStoryTask = nil
		self.m_IsCheckLoginCacheGuide = true
	else	
		if not g_GuideCtrl:TriggerCacheGuide() then
			g_GuideCtrl:TriggerCheck("grade")
			g_GuideCtrl:TriggerCheck("view")
		end	
	end
end

--播放主线章节动画任务
function CTaskCtrl.StartStoryTask(self, oTask)
	if oTask and oTask:GetValue("playid") ~= 0 then
		if g_MapCtrl:GetHero() ~= nil then	
			g_DialogueCtrl:PlayStartStory(oTask:GetValue("playid"))
		else
			self.m_StartStoryTask = oTask
		end
	end
end

function CTaskCtrl.LocalNewTeachTask(self)
	local teackTask = nil
	local submitTable = {}
	local status = define.Task.TaskStatus.Doing
	for _,task in pairs(self.m_TaskDataDic) do		
		local type = task:GetValue("type")
		if type == define.Task.TaskCategory.TEACH.ID then
			submitTable = task:GetValue("submitRewardStr")
			if task:GetValue("status") == define.Task.TaskStatus.Done then
				status = define.Task.TaskStatus.Done
			end			
		end
	end
	if g_TeachCtrl:CanGetProgressReward() then
		status = define.Task.TaskStatus.Done
	end


	local taskData = 
	{	
		taskid = CTaskCtrl.TeachTaskId,
		name = "引导教学",
		detaildesc = string.format("任务进程 (%d/%d)",g_TeachCtrl:GetProgress(), g_TeachCtrl:GetMaxProgress()),
		targetdesc = string.format("任务进程[FFA704] (%d/%d)",g_TeachCtrl:GetProgress(), g_TeachCtrl:GetMaxProgress()),
		type = define.Task.TaskCategory.TEACH.ID,
		submitRewardStr = submitTable,
		status = status,		
	}
	return  CTask.NewByData(taskData)
end

function CTaskCtrl.LocalNewPartnerAccetpTask(self)
	local teackTask = nil
	local submitTable = {}
	local status = define.Task.TaskStatus.Accept
	local taskData = 
	{	
		taskid = CTaskCtrl.PartnerAccectTaskId,
		name = "伙伴的故事",
		detaildesc = string.format("(点击前往图鉴)"),
		targetdesc = string.format("(点击前往图鉴)"),
		type = define.Task.TaskCategory.PARTNER.ID,
		submitRewardStr = submitTable,
		status = status,		
	}
	return  CTask.NewByData(taskData)
end

function CTaskCtrl.LocalNewShiMenTask(self, shimenStatus)
	local teackTask = nil
	local submitTable = {}
	local status = define.Task.TaskStatus.Accept
	local title = "杂务巡查"
	local detail = "完成杂务巡查获得大量经验和钱"
	local target = "完成杂务"
	if shimenStatus == 1 then
		target = "可领取新的任务"
	elseif shimenStatus == 3 then
		target = "可领取任务奖励"
	end
	local taskData = 
	{	
		taskid = CTaskCtrl.ShiMenAccectTaskId,
		name = title,
		detaildesc = detail,
		targetdesc = target,
		type = define.Task.TaskCategory.SHIMEN.ID,
		submitRewardStr = submitTable,
		acceptnpc = 5001,
		status = status,		
	}
	return  CTask.NewByData(taskData)
end

--是否是挑战Npc
function CTaskCtrl.IsFightNpc(self, npcId)
	local b = false
	--挑战Npc都是常驻Npc
	local npc = g_MapCtrl:GetNpc(npcId)
	if npc then
		local d = data.npcdata.NPC.GLOBAL_NPC[npc.m_NpcAoi.npctype]
		if d then
			b = d.fight ~= 0
		end
	end	
	return b
end

--请求执行挑战Npc的协议
function CTaskCtrl.DoFightNpc(self, npcId)
	nethuodong.C2GSNpcFight(npcId)
end

--请求开始播放剧情弹幕 
function CTaskCtrl.CtrlC2GSGetTaskBarrage(self, stroyId)
	if self.m_BarrageId ~= stroyId then
		nettask.C2GSGetTaskBarrage(stroyId)
	end
end

--发送任务剧情弹幕
function CTaskCtrl.CtrlC2GSSetTaskBarrage(self, stroyId, msg)	
	nettask.C2GSSetTaskBarrage(stroyId, msg)
end

function CTaskCtrl.CtrlGS2CSendTaskBarrage(self, barrage, stroyId)	

	local function IsContainSpecialWord(str)
		local t = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
		local d = string.getutftable(str)
		for i,v in ipairs(d) do
			for _i, _v in ipairs(t) do
				if v == _v then
					return true
				end
			end
		end
		return false
	end
	if self.m_BarrageId ~= stroyId then
		self.m_BarrageIdx = 1
		self.m_BarrageId = stroyId
	else
		--在观看剧情时，发送的弹幕
		if barrage and next(barrage) then
			for i,v in ipairs(barrage) do
				local oMsg = {}	
				oMsg.send_id = 0
				oMsg.content = v.msg		
				if v.sender and v.sender == g_AttrCtrl.pid then
					oMsg.send_id = g_AttrCtrl.pid		
					self:OnEvent(define.Task.Event.AddTaskBullet, oMsg)	
				else
					if not IsContainSpecialWord(v.msg) then
						self:OnEvent(define.Task.Event.AddTaskBullet, oMsg)	
					end
				end
			end
		end
		return
	end
	
	--开始播放剧情的弹幕，处理
	if self.m_TaskBarrageTimer then
		Utils.DelTimer(self.m_TaskBarrageTimer)
		self.m_TaskBarrageTimer = nil
	end
	local cb = function ()
		if not barrage or #barrage == 0 or self.m_BarrageIdx > #barrage then
			return false
		end
		local info = barrage[self.m_BarrageIdx]
		if not info then
			return false
		end
		local oMsg = {}	
		oMsg.send_id = 0
		oMsg.content = info.msg		
		if info.sender and info.sender == g_AttrCtrl.pid then
			oMsg.send_id = g_AttrCtrl.pid		
			self:OnEvent(define.Task.Event.AddTaskBullet, oMsg)	
		else
			if not IsContainSpecialWord(info.msg) then
				self:OnEvent(define.Task.Event.AddTaskBullet, oMsg)	
			end
		end
		self.m_BarrageIdx = self.m_BarrageIdx + 1
		return true
	end
	self.m_TaskBarrageTimer = Utils.AddTimer(cb, 0, 0.3)
end

function CTaskCtrl.CheckTaskTypeOpenToggle(self, oTask)
	if data.globalcontroldata.GLOBAL_CONTROL.task.is_open == "n" then
		return false
	end
	local b = true
	if oTask then
		local type = oTask:GetValue("tasktype")
		if type == define.Task.TaskType.TASK_TEACH then
			if data.globalcontroldata.GLOBAL_CONTROL.dailytask.is_open == "n" then
				b = false
			end
		end
	end
	return b
end

function CTaskCtrl.TaskProcressWhenMapLoadDone(self)
	if self:IsTraceSwitchMap() then
		self:SetTraceSwitchMap(false)

	else
		local traceTarget =  self:IsDoingTraceTask()
		if traceTarget then
			local oTrace = g_MapCtrl:GetTraceNpc()
			if oTrace then
				oTrace:SyncPosWhenOtherSwitchMap()
			end
			self:SetDoingTraceTask()
		end
	end
end

--当跟踪任务失败时，重置跟踪任务的坐标信息
function CTaskCtrl.ResetTraceTaskTraceinfo(self, task)
	if task then
		local traceinfo = task:GetValue("traceinfo")
		local taskId = task:GetValue("taskid")
		if traceinfo and taskId then
			traceinfo.cur_mapid = 0
			traceinfo.cur_posx = 0
			traceinfo.cur_posy = 0		
			nettask.C2GSSyncTraceInfo(taskId, 0, 0, 0)
		end
	end	
end

function CTaskCtrl.GetCaiQuanFuBenTask(self)
	return self.m_TaskDataDic[CTaskCtrl.CaiQuanID]
end

function CTaskCtrl.GetMissMengTask(self)
	local oTask
	for k, v in pairs(self.m_TaskDataDic) do
		if v:IsMissMengTask() then
			oTask = v
			break
		end
	end
	return oTask
end

--当前是否有前36个任务
function CTaskCtrl.HaveNvTipsGuide(self)
	local b = false
	for k, v in pairs(self.m_TaskDataDic) do
		local id = v:GetValue("taskid")		
		if id >= 10001 and id <= 10036 or self.m_ShiMenTaskStatue == 1 then
			return true
		end
	end
	return b
end

function CTaskCtrl.HaveLiLianTask(self)
	local b = false
	for _, v in pairs(self.m_TaskDataDic) do		
		if v:GetValue("taskid") == CTaskCtrl.DailyCultivateTaskID  then
			b = true		
			break
		end
	end
	return b
end

function CTaskCtrl.CtrlGS2CRefreshPartnerTask(self, list, refreshType)
	list = list or {}
	if not next(list) then
		return
	end
	if refreshType == 0 then
		self.m_PartnerTaskDataDic = {}
		self:RefreshUI()
	end
	for k, v in pairs(list) do
		self.m_PartnerTaskDataDic[v.parid] = v
		if refreshType ~= 0 then
			self:OnEvent(define.Task.Event.RefreshPartnerTaskBox, v.parid)
		end
	end	

end

function CTaskCtrl.C2GSAcceptSideTask(self, parId)
	local t = self.m_PartnerTaskDataDic[parId] 
	if t and t.status == 1 then
		nettask.C2GSAcceptSideTask(t.taskid)
	end
end

function CTaskCtrl.GetPartnerTaskProgressData(self, parId)
	return self.m_PartnerTaskDataDic[parId]
end

 --返回值:0表示不需要显示任务，1表示显示前往图鉴，2显示具体任务
function CTaskCtrl.GetPartnerTaskProgressStatue(self)
	local status = 0
	local isTrigger = false
	local isAccect = false
	for k, v in pairs(self.m_PartnerTaskDataDic) do
		if v.status == 2 then
			isAccect = true
		end
		if v.status == 1 then
			isTrigger = true
		end
	end

	if isAccect then
		status = 2
	elseif isTrigger then
		status = 1
	end
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade then
		status = 0
	end
	return status
end

function CTaskCtrl.IsHavePartnerTask(self)
	local b = false
	for k,v in pairs(self.m_TaskDataDic) do
		if v:GetValue("type") == define.Task.TaskCategory.PARTNER.ID then
			b = true
			break
		end
	end
	return b
end

function CTaskCtrl.CtrlGS2CLoginAchieveTask(self, info)
	if info then
		for i, v in ipairs(info) do
			local oTask = self:CreateBranchTaskLocal(v)
			self.m_TaskDataDic[v.taskid] = oTask
			local taskType = define.Task.TaskCategory.ACHIEVE.ID
			self.m_TaskTypeDic[taskType] = self.m_TaskTypeDic[taskType] or {}
			self.m_TaskTypeDic[taskType][v.taskid] = oTask
		end
		-- 刷新导航UI
		self:RefreshUI()
	end
end

function CTaskCtrl.CtrlGS2CAddAchieveTask(self, info)
	if info then
		local oTask	= self:CreateBranchTaskLocal(info)
		local taskType = define.Task.TaskCategory.ACHIEVE.ID
		self.m_TaskDataDic[info.taskid] = oTask
		self.m_TaskTypeDic[taskType] = self.m_TaskTypeDic[taskType] or {}
		self.m_TaskTypeDic[taskType][info.taskid] = oTask
		self:RefreshUI()
	end
end

function CTaskCtrl.CtrlGS2CRefreshAchieveTask(self, info)
	if info then
		if not self.m_TaskDataDic[info.taskid] then
			printc("刷新任务 >>> 不存在任务ID:", info.taskid)
			return
		end
		local oTask	= self:CreateBranchTaskLocal(info)
		local taskType = define.Task.TaskCategory.ACHIEVE.ID
		self.m_TaskTypeDic[taskType] = self.m_TaskTypeDic[taskType] or {}
		self.m_TaskTypeDic[taskType][info.taskid] = oTask
		self.m_TaskDataDic[info.taskid] = oTask
		self:RefreshUI()
	end
end

function CTaskCtrl.CreateBranchTaskLocal(self, info)
	if info then
		local t = table.copy(info)
		t.tasktype = define.Task.TaskType.TASK_ACHIEVE
		t.statusinfo = {note = "CreateTask", status=1}
		t.targetdesc = t.describe or ""
		t.detaildesc = t.describe or ""
		t.name = t.name or ""
		t.degree = t.degree or 0
		t.target = t.target or 0
		return CTask.New(t)
	end
end

function CTaskCtrl.CtrlGS2CDelAchieveTask(self, taskid)
	local oTask = self.m_TaskDataDic[taskid]
	if not oTask then
		printc("任务删 >>> 不存在任务ID:", taskid)
		return
	end
	self:DelTaskTypeTable(oTask)
	self.m_TaskDataDic[taskid] = nil
	self:RefreshUI()
end

--点击成就支线处理
function CTaskCtrl.ClickBranchTaskLogic(self, oTask)
	if oTask and oTask:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
		local degree = oTask:GetValue("degree")
		local target = oTask:GetValue("target")
		local taskId = oTask:GetValue("taskid")
		if degree >= target then
			nettask.C2GSGetAchieveTaskReward(taskId)
		else
			local open_id = oTask:GetValue("open_id")
			g_OpenUICtrl:OpenUI(open_id)
		end
	end
	return true
end

function CTaskCtrl.StartPatrolTask(self, taskId)
	local oTask = self:GetTaskById(taskId)
	local oHero	= g_MapCtrl:GetHero()
	if self.m_PatrolTaskTimer then
		Utils.DelTimer(self.m_PatrolTaskTimer)
		self.m_PatrolTaskTimer = nil
	end	
	if oTask and oHero then
		local patrolinfo = oTask:GetValue("patrolinfo") or patrolinfo
		if not g_MapCtrl:IsCurMap(patrolinfo.mapid) then
			netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, patrolinfo.mapid)
			self:SetRecordLogic(oTask)		
		else
			oHero:StartPatrol(true)
			self.m_PatrolTaskTimer = Utils.AddTimer(callback(self, "StartPatrolFight", taskId), 0, table.randomvalue({3, 4, 5})) 
		end	
	end	
end

function CTaskCtrl.StartPatrolFight(self, taskId)
	local oHero	= g_MapCtrl:GetHero()
	if oHero then
		oHero:StopPatrol()
		oHero:StopWalk()
	end
	nettask.C2GSTriggerPatrolFight(taskId)
end

function CTaskCtrl.StopPatrolTask(self)
	if self.m_PatrolTaskTimer then
		Utils.DelTimer(self.m_PatrolTaskTimer)
		self.m_PatrolTaskTimer = nil
	end
end

function CTaskCtrl.CtrlGS2CUpdateShimenStatus(self, shimenStatus)
	if self.m_ShiMenTaskStatue == 1 and shimenStatus == 2 then
		self:StartAutoDoingShiMen(true)
	end
	self.m_ShiMenTaskStatue = shimenStatus or 0
	self:RefreshUI()
	if self.m_ShiMenTaskStatue == 3 then
		self:StartAutoDoingShiMen(false)
		CTaskCompleteView:ShowView(function (oView)
			oView:SetType(CTaskCompleteView.Type.ShiMen)
		end)
	end
end

function CTaskCtrl.CheckOpenChapterTask(self, oTask)	
	local b = false
	if oTask then
		if oTask:GetValue("type") == define.Task.TaskCategory.STORY.ID then
			local chapterData = oTask:GetChaptetFubenData()
			if chapterData then
				if tonumber(chapterData[1]) <= g_ChapterFuBenCtrl:GetCurMaxChapter(define.ChapterFuBen.Type.Simple) then
					if not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, chapterData[1], chapterData[2]) then									
						if g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Simple, chapterData[1], chapterData[2]) then
							if not self:ShowTaskChatperFubenTips(oTask:GetValue("taskid"), chapterData[1], chapterData[2]) then
								g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Simple, chapterData[1], chapterData[2], true)	
							end								
						else
							local lastChapter, lastLevel = g_ChapterFuBenCtrl:GetFinalChapterLevel(define.ChapterFuBen.Type.Simple)		
							if not self:ShowTaskChatperFubenTips(oTask:GetValue("taskid"), lastChapter, lastLevel) then
								g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Simple, lastChapter, lastLevel, true)	
							end											
						end		
						b = true
					end
				end			
			end
		end
	end
	return b
end

function CTaskCtrl.GetValueByTaskIdAndKey(self, taskId, key)
	local t = nil
	local task = data.taskdata.TASK
	for _,v in pairs(task) do
		if v.TASK and v.TASK[taskId] then
			t = v.TASK[taskId][key]
			break
		end
	end	
	return t
end

function CTaskCtrl.GetLastStoryTaskId(self)
	local id = 0
	if self.m_TaskDataDic then
		for k, v in pairs(self.m_TaskDataDic) do
			if v:GetValue("type") == define.Task.TaskCategory.STORY.ID then
				if not id then
					id = v:GetValue("taskid")
				else
					if v:GetValue("taskid") > id then
						id = v:GetValue("taskid") 
					end
				end
			end
		end
	end
	return id
end

function CTaskCtrl.GetAchieveTaskItemList(self, oTask)
	local itemList = {}
	if oTask and oTask:GetValue("type") == define.Task.TaskCategory.ACHIEVE.ID then
		local rewardIDList = oTask:GetValue("submitRewardStr")
		local coinId = tonumber(data.globaldata.GLOBAL.attr_coin_itemid.value)  --金币id
		local expId= tonumber(data.globaldata.GLOBAL.attr_exp_itemid.value) --经验id
		local goldCoinId = tonumber(data.globaldata.GLOBAL.attr_goldcoin_itemid.value) --水晶id
		local partnerId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)--伙伴奖励道具id		
		local sidList = {}
		for i,v in ipairs(rewardIDList) do
			local str = tostring(v.sid)
			local number = tonumber(v.num)
			
			if string.find(tostring(v.sid), "value") then
				local sid, value = g_ItemCtrl:SplitSidAndValue(str)
				sidList[sid] = sidList[sid] or 0
				sidList[sid] = sidList[sid] + value
		
			elseif string.find(str, "partner") then
				local sid, parId = g_ItemCtrl:SplitSidAndValue(str)
				sidList[sid] = sidList[sid] or {}	
				sidList[sid][parId] = sidList[sid][parId] or {}											
				sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount or 0
				sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount + number

			else
				local sid = tonumber(str)
				sidList[sid] = sidList[sid] or 0
				sidList[sid] = sidList[sid] + number
			end
		end

		for sid, v in pairs(sidList) do					
			local localSid = tonumber(sid)										
			if localSid == partnerId then
				if v and next(v) ~= nil then
					for parid, partner in pairs(v) do
						local d = {}
						d.sid = localSid
						d.partnerId = parid
						d.amount = partner.partner_amount								
						table.insert(itemList, d)
					end	
				end						
			else
				local d = {}
				d.sid = localSid
				d.amount = v
				table.insert(itemList, d)
			end				
		end
		table.sort(itemList, function (a, b)
			return a.sid > b.sid
		end)		
	end
	return itemList 
end

function CTaskCtrl.ChekcAutoShimen(self, status)

	if status == CTaskCtrl.AutoSM.DelayContinue then

		self.m_AutoShiMen = status
		local cb = function ()
			--printc(" >>>>>>>>>>>>>>> DelayContinue  ")
			self:ClickShiMenTask()
			self.m_AutoShiMen = CTaskCtrl.AutoSM.None
		end
		if self.m_AutoShiMenCheckTimer then
			Utils.DelTimer(self.m_AutoShiMenCheckTimer)
			self.m_AutoShiMenCheckTimer = nil
		end		
		self.m_AutoShiMenCheckTimer = Utils.AddTimer(cb, 0, 1)
	elseif status == CTaskCtrl.AutoSM.Continue then
		if self.m_AutoShiMen ~= CTaskCtrl.AutoSM.DelayContinue then
			self.m_AutoShiMen = status
		end
	end
end


function CTaskCtrl.ClickShiMenTask(self)
	for k, v in pairs(self.m_TaskDataDic) do
		if v:GetValue("type") == define.Task.TaskCategory.SHIMEN.ID then
			self:ClickTaskLogic(v)
			return
		end
	end
end

function CTaskCtrl.ContinuShimen(self)
	if self.m_AutoShiMen == CTaskCtrl.AutoSM.Continue then
		if self.m_AutoShiMenContinueTimer then
			Utils.DelTimer(self.m_AutoShiMenContinueTimer)
			self.m_AutoShiMenContinueTimer = nil
		end
		local cb  = function ()
			if CDialogueMainView:GetView() == nil then
				self.m_AutoShiMen = CTaskCtrl.AutoSM.None
				local oView = CGuideView:GetView()
				if oView == nil then
					self:ClickShiMenTask()
				end				
			end
		end
		self.m_AutoShiMenContinueTimer = Utils.AddTimer(cb, 0, 0.5)		
	end
end

function CTaskCtrl.IsAutoDoingShiMen(self)
	return self.m_AutoDoingShimen
end

function CTaskCtrl.StartAutoDoingShiMen(self, b)
	if b == true then
		self.m_AutoDoingShimen = true
		g_WarCtrl:SetLockPreparePartner(define.War.Type.ShiMen, true)
	else
		self.m_AutoDoingShimen = false	
		g_WarCtrl:SetLockPreparePartner(define.War.Type.ShiMen, false)
	end
	g_GuideCtrl:TriggerAll()
end

--当对话完之后，收到服务器跟踪Npc操作
function CTaskCtrl.StartTraceNpc(self, taskId)
	local oTask = self.m_TaskDataDic[taskId]
	if oTask and oTask:GetValue("tasktype") == define.Task.TaskType.TASK_TRACE then
		self:ClickTaskLogic(oTask)
	end		
end

--自动接收下一个主线任务操作
function CTaskCtrl.AutoDoNextTask(self)
	if self.m_AutoDoNextTask and self.m_AutoDoNextTask ~= 0 then
		local b = true
		--处理一些特殊情况是不能自动接师门的操作
		local list = {"CGuideView", "CLoginRewardView"}
		for i, v in ipairs(list) do
			if g_ViewCtrl:GetViewByName(v) then
				b = false
				break
			end
		end		
		if b == true then
			local oTask = self.m_TaskDataDic[self.m_AutoDoNextTask]
			if oTask then
				self:ClickTaskLogic(oTask)			
			end
		end
		self.m_AutoDoNextTask = 0
	end
end

function CTaskCtrl.CheckClickTaskInterval(self, taskId)
	local currentTime = g_TimeCtrl:GetTimeS()
	if taskId ~= self.m_ClickTaskId then
		self.m_ClickTaskLastTime = currentTime
		self.m_ClickTaskId = taskId
		return true
	else
		if currentTime - self.m_ClickTaskLastTime > 1 then
			self.m_ClickTaskLastTime = currentTime
			self.m_ClickTaskId = taskId
			return true
		else
			g_NotifyCtrl:FloatMsg("操作频繁，请稍后再试")
			return false
		end
	end
end

--检测是否正跑任务 
function CTaskCtrl.CheckWalkingTask(self, isClickTaskNv, id)
	if self.m_IsWalkingTaskCheckTimer then
		Utils.DelTimer(self.m_IsWalkingTaskCheckTimer)
		self.m_IsWalkingTaskCheckTimer = nil
	end
	local taskId = id
	local cb = function ()
		local oHero	= g_MapCtrl:GetHero()
		if oHero and oHero:IsWalking() then
			self.m_IsWalkingTask = taskId
			self:ShowTsakWalkingTips(true, taskId)
		else
			self.m_IsWalkingTask = nil
		end
	end
	self.m_IsWalkingTaskCheckTimer = Utils.AddTimer(cb, 0, 0.3)
end

function CTaskCtrl.ShowTsakWalkingTips(self, b, taskId)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		local isShow = false
		local list = nil
		local oTask = self:GetTaskById(taskId)
		if oTask then
			local status = oTask:GetValue("status")
			local info = oTask:GetValue("taskWalkingTips")
			if info and info ~= "" then
				local main = string.split(info, ";")
				if main and #main == 3 then
					local sub = ""
					if status == define.Task.TaskStatus.Accept and main[1] ~= "none" then
						sub = main[1]
					elseif status == define.Task.TaskStatus.Doing and main[2] ~= "none" then
						sub = main[2]
					elseif status == define.Task.TaskStatus.Done and main[3] ~= "none" then
						sub = main[3]
					end					
					if sub and sub ~= "" then
						list = string.split(sub, ",")
						if list then
							isShow = true
						end						
					end				
				end
			end
		end
		if isShow and list then	
			oHero:SetTaskChatHud(true, list)
		else
			oHero:SetTaskChatHud(false)	
		end
	end
end

--停止跑任务标志 
function CTaskCtrl.StopWalingTask(self)
	self.m_IsWalkingTask = nil
	self:ShowTsakWalkingTips(false)
end

--是否正在进行任务寻路
function CTaskCtrl.IsWalingTask(self)
	return self.m_IsWalkingTask ~= nil
end

function CTaskCtrl.CheckGoToDoStoryTaskInMainMenuView(self)
	if g_AttrCtrl.grade <= CTaskCtrl.AutoGoToDoStoryTaskLevel then
		self.m_GotoDoTaskInMainMenuViewTimer = Utils.AddTimer(callback(self, "UpdateCheckGoToDoStoryTask"), 2, 0)
	end
end

function CTaskCtrl.GetOneStoryTask(self)
	local oTask = nil
	for k, v in pairs(self.m_TaskDataDic) do
		if v:GetValue("type")  == define.Task.TaskCategory.STORY.ID then
			oTask = v
			break
		end
	end
	return oTask
end

--打开快捷菜单白名单界面
function CTaskCtrl.OpenCheckGoToDoStoryTaskViewContion()
	local b = true
	local contion = 
	{
		"CMainMenuView",
		"CNotifyView",
		"CGmView",
		"CLoadingView",
		"CBottomView",
	}
	for k,v in pairs(g_ViewCtrl.m_Views) do
		if v:GetActive() and table.index(contion, v.classname) == nil then
			b = false
		end
	end
	return b
end

function CTaskCtrl.UpdateCheckGoToDoStoryTask(self)
	if g_AttrCtrl.grade > CTaskCtrl.AutoGoToDoStoryTaskLevel then
		self.m_GotoDoTaskInMainMenuTime = 0 
		return false
	end
	local oHero	 = g_MapCtrl:GetHero()
	if oHero and not g_WarCtrl:IsWar() then
		local oTask = self:GetOneStoryTask()
		if not g_MapCtrl:IsVirtualScene() and oTask and not oHero:IsWalking() and self:OpenCheckGoToDoStoryTaskViewContion() and (not g_TeamCtrl:IsJoinTeam() or ( g_TeamCtrl:IsLeader() or not g_TeamCtrl:IsInTeam())) and g_ActivityCtrl:ActivityBlockContrl("task", false) then
			self.m_GotoDoTaskInMainMenuTime = self.m_GotoDoTaskInMainMenuTime + 2
			--间隔一段时间后，自动跑任务
			if self.m_GotoDoTaskInMainMenuTime >= CTaskCtrl.AutoGoToDoStoryTaskTime then
				self:ClickTaskLogic(oTask)
				self.m_GotoDoTaskInMainMenuTime = 0
			end		
		else
			self.m_GotoDoTaskInMainMenuTime = 0 
		end	
	else
		self.m_GotoDoTaskInMainMenuTime = 0 	
	end		
	return true
end

function CTaskCtrl.ReCheckGoToDoStoryTask(self)
	if self.m_GotoDoTaskInMainMenuViewTimer then
		self.m_GotoDoTaskInMainMenuTime = 0
	end
end

function CTaskCtrl.StopGoToDoStoryTaskInMainMenuView( self )
	self.m_GotoDoTaskInMainMenuTime = 0
	if self.m_GotoDoTaskInMainMenuViewTimer then
		Utils.DelTimer(self.m_GotoDoTaskInMainMenuViewTimer)
		self.m_GotoDoTaskInMainMenuViewTimer = nil
	end
end

function CTaskCtrl.DoNextRoundShimenTask(self )
	local function cb()
		if CGuideView:GetView() then
			return true
		end
		if not g_MainMenuCtrl:GetMainmenuViewActive() or not g_ViewCtrl:NoBehideLayer() then
			return false
		end
		if self.m_ShiMenTaskStatue == 1 then
			local d = {}
			local dialog ={}
			dialog[1] = 
			{
				content = "你完成了此次委托，是否继续过来接受委托？",
				next = "0",
				pre_id_list = "0",
				status = 2,
				subid = 1,
				type = 2,
				ui_mode = define.Dialogue.Mode.Dialogue,
				voice = 0,
				hide_back_jump = true,
				last_action = 
				{
					[1] = 
					{
						content = "立即接受",
						event = "continue",
						callback = function ()							
							nettask.C2GSAcceptShimenTask()
							self:StartAutoDoingShiMen(true)
						end,
					},
					[2] = 
					{
						content = "考虑一下",
						callback = function ()							
						end,
					}
				},
			}			
			d.dialog = dialog
			d.dialog_id = CDialogueCtrl.DIALOUGE_ACCEPT_SHIMEN_TASK_ID
			d.npcid = 0
			d.npc_name = "市政执行官"
			d.shape = 306
			CDialogueMainView:ShowView(function (oView)
				oView:SetContent(d)
				g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
			end)					
		end
		return false
	end
	if self.m_DoNextRoundShiMenTimer then
		Utils.DelTimer(self.m_DoNextRoundShiMenTimer)
		self.m_DoNextRoundShiMenTimer = nil
	end
	self.m_DoNextRoundShiMenTimer = Utils.AddTimer(cb, 1, 1)
end

function CTaskCtrl.ShowTaskChatperFubenTips(self, taskId, chapter, level)
	local t = data.taskdata.TASK.STORY.DIALOG[taskId]
	if not t then		
		return false
	end
	local cpData = nil
	for i, v in ipairs(t) do
		if v.is_chapter_dialogue ~= 0 then
			cpData = v
			break
		end
	end
	if not cpData then		
		return false
	end
	local info = string.split(cpData.chapter_last_action, ",")

	local d = {}
	local dialog ={}
	dialog[1] = 
	{
		content = cpData.content,
		next = "0",
		pre_id_list = cpData.pre_id_list,
		status = 2,
		subid = cpData.subid,
		type = cpData.type,
		ui_mode = define.Dialogue.Mode.Dialogue,
		voice = 0,
		hide_back_jump = true,
		last_action = 
		{
			[1] = 
			{
				content = info[1] or "挑战他",
				event = "F",
				callback = function ()							
					--临时处理，发普通战役类型define.ChapterFuBen.Type.Simple
					nethuodong.C2GSFightChapterFb(chapter, level, define.ChapterFuBen.Type.Simple)
				end,
			},
			[2] = 
			{
				content = info[2] or "考虑一下",
				callback = function ()							
				end,
			}
		},
	}			
	d.dialog = dialog
	d.dialog_id = taskId
	d.npcid = 0
	d.npc_name = "市政执行官"
	d.shape = 306
	CDialogueMainView:ShowView(function (oView)
		oView:SetContent(d)
		g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
	end)	
	return true				
end

function CTaskCtrl.GetPracticeTask(self)
	local oTask = nil
	for k,v in pairs(self.m_TaskDataDic) do
		if v:GetValue("type") == define.Task.TaskCategory.PRACTICE.ID then
			oTask = v
			break
		end
	end
	return oTask
end

function CTaskCtrl.CheckChapterFbNpc(self, oTask, mapid, addNpc)
	local b = false
	if oTask:GetValue("type") == define.Task.TaskCategory.STORY.ID then
		if not addNpc then
			self.m_TaskChapterNpc = {}
			g_MapCtrl:DelAllTaskChapterFbNpc()
			return b
		end
		local t = oTask:GetChaptetFubenData()
		if t and #t >= 2 then
			self.m_TaskChapterNpc = {}
			g_MapCtrl:DelAllTaskChapterFbNpc()
			local chapter = tonumber(t[1])
			local level = tonumber(t[2])
			local isShow = false
			if chapter <= g_ChapterFuBenCtrl:GetCurMaxChapter(define.ChapterFuBen.Type.Simple) then
				if not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, chapter, level) and 									
					g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Simple, chapter, level) then							
					isShow = true					
				end			
			end	
			if not isShow then				
				return b
			end
			local d
			local config = data.npcdata.TASKCHAPTERNPC
			for k, v in pairs(config) do
				if v.chapter == chapter and v.level == level then
					d = v
				end
			end		
			if d then
				self.m_TaskChapterNpc = {}
				for k,v in pairs(d.npc_group) do
					local tempNpc = data.npcdata.NPC.TEMP_NPC[v]
					if tempNpc then						
						if tempNpc.sceneId == mapid then
							local mode = {scale = 1, shape = tempNpc.modelId}
							local npc = 
							{
								taskId = oTask:GetValue("taskid"),
								chapter = chapter,
								level = level,
								npctype = tempNpc.id,
								name = tempNpc.name,
								model_info = mode,
								rotateY = tempNpc.rotateY,
								dialog_id = d.dialogue_group[k],
							}
							local pos_info = {}				
							pos_info.map_id = mapid
							pos_info.x = tempNpc.x
							pos_info.y = tempNpc.y
							npc.pos_info = pos_info
							if not (npc.pos_info.x > 1000) then
								npc.pos_info.x = npc.pos_info.x * 1000 
								npc.pos_info.y = npc.pos_info.y * 1000
							end	
							for _, npcType in pairs(d.npc_main) do
								if npcType == v then
									npc.IsMain = true
								end
							end							
							table.insert(self.m_TaskChapterNpc, npc)
						end
					end
				end
				if #self.m_TaskChapterNpc > 0 then
					b = true
				end
			end
		end
	end
	return b
end


return CTaskCtrl