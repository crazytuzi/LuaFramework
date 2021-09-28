require("game/task/task_data")
require("game/task/task_dialog_view")
require("game/task/task_weather_eff")

-- 任务
TaskCtrl = TaskCtrl or BaseClass(BaseController)
function TaskCtrl:__init()
	if TaskCtrl.Instance then
		print_error("[TaskCtrl] Attemp to create a singleton twice !")
	end
	TaskCtrl.Instance = self

	self.task_data = TaskData.New()
	self.task_weather_eff = TaskWeatherEff.New()
	self.task_dialog_view = TaskDialogView.New(ViewName.TaskDialog)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.VIEW_CLOSE,
		BindTool.Bind(self.HasViewClose, self))
end

function TaskCtrl:__delete()
	TaskCtrl.Instance = nil

	self.task_dialog_view:DeleteMe()
	self.task_dialog_view = nil

	self.task_data:DeleteMe()
	self.task_data = nil

	self.task_weather_eff:DeleteMe()
	self.task_weather_eff = nil

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
	self:RegisterProtocol(SCPaohuanTaskInfo, "OnPaohuanTaskInfo")
	self:RegisterProtocol(SCTaskRollReward, "OnTaskRollInfo")
	self:RegisterProtocol(SCWeekPaohuanTaskInfo, "OnWeekPaohuanTaskInfo")

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


-- 设置跑环任务信息
function TaskCtrl:OnPaohuanTaskInfo(protocol)
	self.task_data:SetPaohuanTaskInfo(protocol)
end

function TaskCtrl:OnTaskRollInfo(protocol)
	self.task_data:SetRewardRollInfo(protocol)
	if protocol.is_finish ~= 0 then
		local list = TaskData.Instance:GetRewardRollList(protocol.list[1].type)
		ItemData.Instance:SetNormalRewardList(list)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE)
	end
end

--周常任务返回
function TaskCtrl:OnWeekPaohuanTaskInfo(protocol)
	self.task_data:SetWeekPaohuanTaskInfo(protocol)
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, protocol.notify_reason, TASK_TYPE.WEEK_HUAN)
end

-- 请求已接任务列表返回
function TaskCtrl:OnTaskListAck(protocol)
	self.task_data:SetTaskAcceptedInfoList(protocol.task_accepted_list)
end

-- 单条已接任务信息
function TaskCtrl:OnTaskInfo(protocol)
	self.task_data:SetTaskInfo(protocol)
	if self.task_dialog_view:IsOpen() then
		self.task_dialog_view:Flush()
	end
end

-- 已完成任务列表返回
function TaskCtrl:OnTaskRecorderList(protocol)
	self.task_data:SetTaskCompletedIdList(protocol.task_completed_id_list)
	--刷新一下主界面图标（功能开启相关）
	GlobalEventSystem:Fire(MainUIEventType.INIT_ICON_LIST)
end

-- 任务记录列表数据改变
function TaskCtrl:OnTaskRecorderInfo(protocol)
	self.task_data:SetTaskCompleted(protocol.completed_task_id)
end

-- 返回可接受列表
function TaskCtrl:OnAccpetableTaskList(protocol)
	self.task_data:SetTaskCapAcceptedIdList(protocol.task_can_accept_id_list)
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
end

-- 交任务
function TaskCtrl.SendTaskCommit(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskCommit)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 飞行到某地
function TaskCtrl.SendFlyByShoe(scene_id, pos_x, pos_y, scene_key, ignore_shot, not_clear_jump_cache, auto_buy)
	local fly_shot = MapData.Instance:GetFlyShoeId() or 0
	if not not_clear_jump_cache then
		Scene.Instance:GetMainRole():ClearJumpCache()
	end
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
	if SceneType.Common == Scene.Instance:GetSceneType() and cache_npc_obj_id and cache_npc_id and not ViewManager.Instance:HasOpenView() then
		self:SendNpcTalkReq(cache_npc_obj_id, cache_npc_id)
		cache_npc_obj_id = nil
		cache_npc_id = nil
	end
end

function TaskCtrl:SendNpcTalkReq(npc_obj_id, npc_id)
	--npc_id = npc_id
	if nil ~= npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(npc_obj_id)
		if npc_obj then
			local npc_vo = npc_obj:GetVo()
			if npc_vo then
				npc_id = npc_vo.npc_id
			end
			local obj = npc_obj:GetRoot()
			if obj then
				local towards = Scene.Instance:GetMainRole():GetRoot().transform.position
				towards = u3d.vec3(towards.x, obj.transform.position.y, towards.z)
				obj.transform:DOLookAt(towards, 0.5)
			end
			if Scene.Instance:GetSceneType() == SceneType.HunYanFb and npc_vo.npc_type and npc_vo.npc_type == SceneObjType.FakeNpc and MarriageData.Instance:GetCurQuestionIdx() == npc_vo.npc_idx then
				MarriageCtrl.Instance:SetQuestionViewData(npc_vo.npc_idx)
				return
			end

			Scene.Instance:GetMainRole():SetDirectionByXY(npc_obj:GetLogicPos())

			if npc_obj:IsWalkNpc() then
				npc_obj:Stop()
			end
		end
	end

	if nil ~= npc_id then
		if npc_id == COMMON_CONSTS.NPC_MARRY_ID then
			ViewManager.Instance:Open(ViewName.MarryNpcMe)
			return
		end
		--护送NPC
		if npc_id == COMMON_CONSTS.NPC_HUSONG_RECEIVE_ID then
			ViewManager.Instance:Open(ViewName.YunbiaoView)
			return
		end
		--领土战NPC
		if ClashTerritoryData.Instance:IsTerritoryWarNpc(npc_id) then
			ViewManager.Instance:Open(ViewName.ClashTerritoryShop)
			return
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

--通知服务端与NPC对话
function TaskCtrl.SendTaskTalkToNpc(npc_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskTalkToNpc)
	protocol.npc_id = npc_id
	protocol:EncodeAndSend()
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
	end
end

function TaskCtrl:AutoDoTaskState(state)
	if MainUICtrl.Instance.view and MainUICtrl.Instance.view.task_view then
		MainUICtrl.Instance.view.task_view:SetAutoTaskState(state)
		if self.task_dialog_view then
			self.task_dialog_view:SetAutoDoTask(state)
		end
	end
end

function TaskCtrl:SetAutoTalkState(state)
	self:RemoveDelayTime()
	if state then
		--当调用自动做任务时延迟0.5秒后做任务（防止任务比引导快）
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			self:AutoDoTaskState(state)
			if PlayerData.Instance:GetRoleVo().level <= 170 or TASK_GUILD_AUTO or TASK_RI_AUTO or TASK_HUAN_AUTO or TASK_WEEK_HUAN_AUTO then
				self:DoTask()
			end
		end, 0.5)
	else
		self:AutoDoTaskState(state)
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
	end
end

function TaskCtrl:SendGetTaskReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTumoFetchCompleteAllReward)
	protocol:EncodeAndSend()
end

--一键完成
function TaskCtrl:SendCSSkipReq(type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSkipReq)
	protocol.type = type
	protocol.param = param or -1
	protocol:EncodeAndSend()
end