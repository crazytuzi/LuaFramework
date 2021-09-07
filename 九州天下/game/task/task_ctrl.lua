require("game/task/task_data")
require("game/task/task_dialog_view")
require("game/task/task_slide_view")
require("game/task/task_chapter_view")
require("game/task/kill_task_view")
require("game/task/task_weather_eff")
require("game/famous_general/taste_famous_general_view")

-- 任务
TaskCtrl = TaskCtrl or BaseClass(BaseController)
function TaskCtrl:__init()
	if TaskCtrl.Instance then
		print_error("[TaskCtrl] Attemp to create a singleton twice !")
	end
	TaskCtrl.Instance = self

	self.task_data = TaskData.New()
	self.task_dialog_view = TaskDialogView.New(ViewName.TaskDialog)
	self.task_slide_view = TaskSlideView.New(ViewName.TaskSlide)
	self.task_chapter_view = TaskChapterView.New(ViewName.TaskChapter)
	self.kill_task_view = KillTaskView.New(ViewName.TaskKillView)
	self.task_weather_eff = TaskWeatherEff.New()
	self.taste_famous_general_view = TasteFamousGeneralView.New(ViewName.TasteFamousGeneralView)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.VIEW_CLOSE, BindTool.Bind(self.HasViewClose, self))
end

function TaskCtrl:__delete()
	TaskCtrl.Instance = nil

	if self.task_dialog_view then
		self.task_dialog_view:DeleteMe()
		self.task_dialog_view = nil
	end

	if self.kill_task_view then
		self.kill_task_view:DeleteMe()
		self.kill_task_view = nil
	end

	if self.task_data then
		self.task_data:DeleteMe()
		self.task_data = nil
	end

	if self.task_slide_view then
		self.task_slide_view:DeleteMe()
		self.task_slide_view = nil
	end

	if self.task_chapter_view then
		self.task_chapter_view:DeleteMe()
		self.task_chapter_view = nil
	end
	
	if self.task_weather_eff then
		self.task_weather_eff:DeleteMe()
		self.task_weather_eff = nil
	end

	if self.taste_famous_general_view then
		self.taste_famous_general_view:DeleteMe()
		self.taste_famous_general_view = nil
	end

	self:RemoveDelayTime()
end

function TaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTaskListAck, "OnTaskListAck")
	self:RegisterProtocol(SCTaskInfo, "OnTaskInfo")
	self:RegisterProtocol(SCTaskRecorderList, "OnTaskRecorderList")
	self:RegisterProtocol(SCTaskRecorderInfo, "OnTaskRecorderInfo")
	self:RegisterProtocol(SCAccpetableTaskList, "OnAccpetableTaskList")
	self:RegisterProtocol(SCTuMoTaskInfo, "OnTuMoTaskInfo")
	self:RegisterProtocol(SCGuildTaskInfo, "OnGuildTaskInfo")
	self:RegisterProtocol(SCKillRoleScoreInfo, "OnKillRoleScoreInfo")

	-- self:RegisterProtocol(CSTaskListReq)
	self:RegisterProtocol(CSTaskGiveup)
	self:RegisterProtocol(CSFlyByShoe)
	self:RegisterProtocol(CSTaskAccept)
	self:RegisterProtocol(CSTaskCommit)
	self:RegisterProtocol(CSTumoFetchCompleteAllReward)
end

-- 设置日常任务信息
function TaskCtrl:OnTuMoTaskInfo(protocol)
	self.task_data:SetDailyTaskInfo(protocol)
end

-- 设置公会任务信息
function TaskCtrl:OnGuildTaskInfo(protocol)
	self.task_data:SetGuildTaskInfo(protocol)
end

-- 请求已接任务列表返回
function TaskCtrl:OnTaskListAck(protocol)
	self.task_data:SetTaskAcceptedInfoList(protocol.task_accepted_list)
end

-- 单条已接任务信息
function TaskCtrl:OnTaskInfo(protocol)
	self.task_data:SetTaskInfo(protocol)
	-- if protocol.task_id == TASK_ID.YUNBIAO then 	--设置nil是为了可以点护送进行任务
	-- 	TaskData.Instance:SetCurTaskId(nil)
	-- end
	if self.task_dialog_view:IsOpen() then
		self.task_dialog_view:Flush()
	end
	if TaskData.Instance:GetMingJiangTask(protocol.task_id) then
		Scene.Instance:GetMainRole():ChangeMingJiang(protocol.task_id)
	end
end

function TaskCtrl:OpenChapterView()
	local task_info = TaskData.Instance:GetTaskAcceptedInfoList()
	local task_cfg = {}
	if task_info == nil or next(task_info) == nil then return end

	for k,v in pairs(task_info) do
		task_cfg = self.task_data:GetTaskConfig(v.task_id)
		if task_cfg and task_cfg.accept_op and task_cfg.accept_op == TASK_ACCEPT_OP.NEW_CHAPTER then
			break
		end
		task_cfg = {}
	end

	if next(task_cfg) == nil then return end
	local data = {}
	data.chapter = task_cfg.a_param1
	data.title = task_cfg.a_param2
	data.content = task_cfg.a_param3
	data.task_id = task_cfg.task_id
	self.task_chapter_view:SetChapterData(data)
end

-- 打开名将体验面板
function TaskCtrl:OpenTasteFamousGeneralView(bs_id)
	self.taste_famous_general_view:SetBianShenID(seq)
end


-- 已完成任务列表返回
function TaskCtrl:OnTaskRecorderList(protocol)
	self.task_data:SetTaskCompletedIdList(protocol.task_completed_id_list)
end

-- 任务记录列表数据改变
function TaskCtrl:OnTaskRecorderInfo(protocol)
	self.task_data:SetTaskCompleted(protocol.completed_task_id)
end

-- 返回可接受列表
function TaskCtrl:OnAccpetableTaskList(protocol)
	self.task_data:SetTaskCapAcceptedIdList(protocol.task_can_accept_id_list)
end

function TaskCtrl:OnKillRoleScoreInfo(protocol)
	self.task_data:SetKillRoleScoreInfo(protocol)
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
end

-- 放弃任务
function TaskCtrl.SendTaskGiveup(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskGiveup)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 接任务
function TaskCtrl.SendTaskAccept(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskAccept)
	protocol.task_id = task_id
	protocol:EncodeAndSend()

	FlowersCtrl.Instance:PlayerTaskEffect2("effects2/prefab/ui/ui_rwtq_prefab","UI_rwtq")
end

-- 交任务
function TaskCtrl.SendTaskCommit(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskCommit)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 飞行到某地
function TaskCtrl.SendFlyByShoe(scene_id, pos_x, pos_y, scene_key, ignore_shot, not_clear_jump_cache, auto_buy)
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
		return
	end
	local fly_shot = MapData.Instance:GetFlyShoeId() or 0
	-- if not ignore_shot and VipPower.Instance:GetParam(VipPowerId.scene_fly) < 1 and ItemData.Instance:GetItemNumInBagById(fly_shot) < 1 then
	-- 	TipsCtrl.Instance:ShowLockVipView(VIPPOWER.SCENE_FLY)
	-- 	return
	-- end
	if not not_clear_jump_cache then
		Scene.Instance:GetMainRole():ClearJumpCache()
	end

	if not BossData.Instance:CheckIsCanEnterFuLi(scene_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NeedLeaveScene)
		return
	end

	-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFlyByShoe)
	protocol.scene_id = scene_id
	protocol.scene_key = scene_key or -1
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol.item_index = (auto_buy or TipsCommonBuyView.AUTO_LIST[fly_shot])and 1 or 0
	protocol.is_force = ignore_shot and 1 or 0
	protocol:EncodeAndSend()
end

local cache_npc_obj_id = nil
local cache_npc_id = nil
function TaskCtrl:HasViewClose(npc_obj_id, npc_id)
	if cache_npc_obj_id and cache_npc_id and not ViewManager.Instance:HasOpenView() then
		self:SendNpcTalkReq(cache_npc_obj_id, cache_npc_id)
		cache_npc_obj_id = nil
		cache_npc_id = nil
	end
end

function TaskCtrl:SendNpcTalkReq(npc_obj_id, npc_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo_camp = PlayerData.Instance.role_vo.camp
	local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local yingjiu_info = NationalWarfareData.Instance:GetYingJiuInfo()

	if nil ~= npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(npc_obj_id)
		if npc_obj then
			local npc_vo = npc_obj:GetVo()
			if npc_vo then
				npc_id = npc_vo.npc_id
			end
			if Scene.Instance:GetSceneType() == SceneType.HunYanFb and npc_vo.npc_type and npc_vo.npc_type == SceneObjType.FakeNpc and MarriageData.Instance:GetCurQuestionIdx() == npc_vo.npc_idx then
				MarriageCtrl.Instance:SetQuestionViewData(npc_vo.npc_idx)
				return
			end
			Scene.Instance:GetMainRole():SetDirectionByXY(npc_obj:GetLogicPos())

			-- 点击非目标国家的砖块弹出对应提示
			local npc_list = NationalWarfareData.Instance:GetBanZhuanOtherCampNpc(banzhuan_list.task_aim_camp)
			for k, v in pairs(npc_list) do
				if v == npc_id then
					if banzhuan_list.task_aim_camp == 0 then
						SysMsgCtrl.Instance:ErrorRemind(Language.NationalWarfare.BanZhuanPrompt1)
						return
					else
						SysMsgCtrl.Instance:ErrorRemind(Language.NationalWarfare.BanZhuanPrompt2)
						return
					end
				end
			end

			-- 点击目标国家的砖块不转动npc
			local npc = NationalWarfareData.Instance:GetBanZhuanRefreshNpc(banzhuan_list.task_aim_camp)
			if npc ~= npc_id then
				local obj = npc_obj:GetRoot()
				if obj then
					local towards = Scene.Instance:GetMainRole():GetRoot().transform.position
					towards = u3d.vec3(towards.x, obj.transform.position.y, towards.z)
					obj.transform:DOLookAt(towards, 0.5)
				end
			end
		end
	end

	if nil ~= npc_id then
		--结婚NPC
		if npc_id == 208 then
			-- ViewManager.Instance:Open(ViewName.Church)
			return
		end
		--护送NPC
		if NationalWarfareData.Instance:GetIsYunBiaoNPC(npc_id) then
			ViewManager.Instance:Open(ViewName.YunbiaoView)
			return
		end
		-- 刺探NPC
		if NationalWarfareData.Instance:GetCiTanNpc(npc_id, role_vo_camp, true) then
			self:SendTalkTask(npc_id)
			if citan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then
				ViewManager.Instance:Open(ViewName.CiTanCompleteView)
			else
				ViewManager.Instance:Open(ViewName.StartCiTanView)
			end
			return
		end
		-- 刺探NPC
		if NationalWarfareData.Instance:GetCiTanNpc(npc_id, citan_list.task_aim_camp, false) then
			self:SendTalkTask(npc_id)
			if not ViewManager.Instance:IsOpen(ViewName.CiTanColorView) then
				ViewManager.Instance:Open(ViewName.CiTanColorView, nil, "start", {index = 1})
			end
			return
		end
		if NationalWarfareData.Instance:GetBanZhuanNpc(npc_id, role_vo_camp, true) then
			self:SendTalkTask(npc_id)
			if banzhuan_list.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then
				ViewManager.Instance:Open(ViewName.BanZhuanCompleteView)
			else
				ViewManager.Instance:Open(ViewName.StartBanZhuanView)
			end
			return
		end
		if NationalWarfareData.Instance:GetBanZhuanNpc(npc_id, banzhuan_list.task_aim_camp, false) then
			self:SendTalkTask(npc_id)
			if not ViewManager.Instance:IsOpen(ViewName.BanZhuanColorView) then
				ViewManager.Instance:Open(ViewName.BanZhuanColorView, nil, "start", {index = 1})
			end
			return
		end
		--领土战NPC
		if ClashTerritoryData.Instance:IsTerritoryWarNpc(npc_id) then
			ViewManager.Instance:Open(ViewName.ClashTerritoryShop)
			return
		end
		-- 营救npc
		if NationalWarfareData.Instance:IsYingJiuTaskAcceptNpc(npc_id, main_role_vo.camp) and CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID == yingjiu_info.task_phase then
			NationalWarfareCtrl.Instance:OpenYingJiuTaskView()
			return 
		end
		-- 拯救美人
		if TaskData.Instance:IsYingjiuMeirenTaskAcceptNpc(npc_id) then
			ViewManager.Instance:Open(ViewName.TaskSlide, nil, "zhuxian_meiren", {task_id = 0})
			return
		elseif TaskData.Instance:IsOtherYingjiuMeirenTaskAcceptNpc(npc_id) then
			ViewManager.Instance:Open(ViewName.TaskSlide, nil, "zhixian_meiren", {task_id = 1})
			return 
		end
		-- 青楼npc
		if npc_id == 6102 or npc_id == 6105 then 	-- 张婆婆6102,玉婆婆6105
			local vo = GameVoManager.Instance:GetMainRoleVo()	
			if nil == vo then return end
			if (npc_id == 6102 and vo.server_group == 0) or
		       (npc_id == 6105 and vo.server_group == 1) then
				ViewManager.Instance:Open(ViewName.BrothelView)
				return
			end
		end

		if ViewManager.Instance:HasOpenView() then
			cache_npc_obj_id = npc_obj_id
			cache_npc_id = npc_id
			return
		end
		self.task_dialog_view:SetNpcId(npc_id, npc_obj_id)
		self.task_dialog_view:Open()
		GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	end
end

--取消正在执行的任务
function TaskCtrl:CancelTask()
	local task_id = TaskData.Instance:GetCurTaskId()
	TaskData.Instance:SetCurTaskId(nil)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if nil ~= task_id then
		MainUICtrl.Instance:OnTaskRefreshActiveCellViews()
	end
end

function TaskCtrl:SendQuickDone(task_type, task_id)
	if not task_type then
		return
	end
	if task_type == TASK_TYPE.GUILD then
		local protocol = ProtocolPool.Instance:GetProtocol(CSFinishAllGuildTask)
		protocol:EncodeAndSend()
	elseif task_type == TASK_TYPE.RI then
		if not task_id then
			return
		end
		local protocol = ProtocolPool.Instance:GetProtocol(CSTumoCommitTask)
		protocol.commit_all = 1
		protocol.task_id = task_id
		protocol.is_force_max_star = 0
		protocol:EncodeAndSend()

		DayCounterCtrl.Instance:LockOpenTaskRewardPanel(true)
	end
end

function TaskCtrl:SetAutoTalkState(state)
	self:RemoveDelayTime()
	local function func()
		if MainUICtrl.Instance.view and MainUICtrl.Instance.view.task_view then
			MainUICtrl.Instance.view.task_view:SetAutoTaskState(state)
			if self.task_dialog_view then
				self.task_dialog_view:SetAutoDoTask(state)
			end
		end
	end
	if state then
		--当调用自动做任务时延迟0.5秒后做任务（防止任务比引导快）
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			func()
			if PlayerData.Instance:GetRoleVo().level < COMMON_CONSTS.AUTO_TASK_LEVEL_LIMIT or TASK_GUILD_AUTO or TASK_RI_AUTO then
				self:DoTask()
			end
		end, 0.5)
	else
		func()
	end
end

function TaskCtrl:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function TaskCtrl:CloseWindow()
	if self.task_dialog_view then
		self.task_dialog_view:HandleClose()
	end
end

function TaskCtrl:DoTask(task_id)
	if task_id then
		TaskData.Instance:SetCurTaskId(task_id)
	end
	if MainUICtrl.Instance.view and MainUICtrl.Instance.view.task_view then
		-- GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		MainUICtrl.Instance.view.task_view:AutoExecuteTask()
		-- MainUICtrl.Instance.view.task_view:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
	end
end

function TaskCtrl:SendGetTaskReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTumoFetchCompleteAllReward)
	protocol:EncodeAndSend()
end

function TaskCtrl:SendTalkTask(npc_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskTalkToNpc)
	protocol.npc_id = npc_id or 0
	protocol:EncodeAndSend()
end

function TaskCtrl:YingJiuTalkChange(enabled)
	self.send_yingjiu = enabled
end

function TaskCtrl:GetYingJiuSendFlag()
	return self.send_yingjiu or false
end

function TaskCtrl:OpenKillTaskView()
	self.kill_task_view:Open()
end