TaskDialogView = TaskDialogView or BaseClass(BaseView)

local NUM = 4  -- 奖励栏数量
local DELAY_TIME = 10 -- 自动做任务的时间
local LEVEL_LIMIT = 50 -- 自动做任务的等级

function TaskDialogView:__init()
	self.ui_config = {"uis/views/taskview", "TaskDialogView"}
	self.play_audio = true

	self.npc_id = 0
	self.task_id = 0
	self.talk_id = 0
	self.is_auto = true

	self.talk_table = nil
	self.cur_index = 0
	self.last_npc_resid = 0
	self.auto_do_task = true
	self.auto_talk = false

	self.active_close = false
	self.story_talk_end_callback = nil
end

function TaskDialogView:ReleaseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end

	self.story_talk_end_callback = nil

	for k,v in pairs(self.rewards) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.rewards = {}

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.time_count_down then
		CountDown.Instance:RemoveCountDown(self.time_count_down)
		self.time_count_down = nil
	end

	-- 清理变量和对象
	self.name = nil
	self.content = nil
	self.button_name = nil
	self.show_time = nil
	self.time = nil
	self.show_npc = nil
	self.show_btn = nil
	self.jiang_li = nil
	self.display3D = nil
	self.display3D2 = nil
	self.rewards = nil
	self.is_show_btn = nil
	self.show_finger = nil
	self.time_daoji = nil
	self.show_open_btn = nil
end

function TaskDialogView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.ClickGoOn, self))
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("Accept", BindTool.Bind(self.HandleAccept, self))
	self:ListenEvent("ClickGoOn", BindTool.Bind(self.ClickGoOn, self))
	self:ListenEvent("ClickPanel", BindTool.Bind(self.ClickPanel, self))

	self.name = self:FindVariable("Name")
	self.content = self:FindVariable("Content")
	self.button_name = self:FindVariable("ButtonName")
	self.show_time = self:FindVariable("ShowTime")
	self.time = self:FindVariable("Time")
	self.show_npc = self:FindVariable("ShowNpc")
	self.show_btn = self:FindVariable("ShowBtn")
	self.show_finger = self:FindVariable("Show_Finger")
	self.jiang_li = self:FindVariable("JiangLi")
	self.is_show_btn = self:FindVariable("Is_Show_Btn")
	self.time_daoji = self:FindVariable("TimeDaoJi")

	self.display3D = self:FindObj("Display3D")
	self.display3D2 = self:FindObj("Display3D2")
	--self.title = self:FindObj("Title")
	self.rewards = {}
	for i = 1, NUM do
		self.rewards[i] = {}
		self.rewards[i].obj = self:FindObj("Reward" .. i)
		self.rewards[i].cell = ItemCell.New()
		self.rewards[i].cell:SetInstanceParent(self.rewards[i].obj)
	end
	self.rewards[1].cell:ShowHighLight(false)
	self.is_auto = true

	self.show_open_btn = self:FindVariable("ShowOpenBtn")
	self:ListenEvent("OpenView", BindTool.Bind(self.OpenView, self))
end

function TaskDialogView:OpenCallBack()
	self.show_npc:SetValue(true)
	GuajiCtrl.Instance:PlayNpcVoice(self.npc_obj_id)
end

-- 设置NPC模型
function TaskDialogView:SetNpcModel(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New("task_dialog_panel")
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetNpcModel(resid))
		self.npc_model:SetModelScale(Vector3(1, 1, 1))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

-- 设置NPC特殊模型(人物)
function TaskDialogView:SetNpcModel2(role_res, weapen_res, mount_res, wing_res, halo_res)
	if not self.npc_model then
		self.npc_model = RoleModel.New("task_dialog_panel")
		self.npc_model:SetWingNeedAction(false)
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	if self.last_npc_resid ~= role_res then
		self.npc_model:SetMainAsset(ResPath.GetRoleModel(role_res))
		self.npc_model:SetModelScale(Vector3(1, 1, 1))
		if weapen_res > 0 then
			self.npc_model:SetWeaponResid(weapen_res)
			-- 如果是枪手模型
			if math.floor(role_res / 1000) % 1000 == 3 then
				self.npc_model:SetWeapon2Resid(weapen_res + 1)
			end
		end
		if mount_res > 0 then
			self.npc_model:SetMountResid(mount_res)
		end
		if wing_res > 0 then
			self.npc_model:SetWingResid(wing_res)
		end
		if halo_res > 0 then
			self.npc_model:SetHaloResid(halo_res)
		end
		self:SetNpcAction()
		self.last_npc_resid = role_res
	end
end

-- 设置NPC特殊模型(怪物)
function TaskDialogView:SetNpcModel3(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New("task_dialog_panel")
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetMonsterModel(resid))
		self.npc_model:SetModelScale(Vector3(1, 1, 1))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

-- 设置NPC特殊模型(名将)
function TaskDialogView:SetNpcModelGeneral(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New("task_dialog_panel")
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetMingJiangRes(resid))
		self.npc_model:SetModelScale(Vector3(0.6, 0.6, 0.6))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

-- 设置NPC特殊模型(美人)
function TaskDialogView:SetNpcModelBeauty(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New("task_dialog_panel")
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
		self.npc_model:SetWingNeedAction(false)
	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetGoddessNotLModel(resid))
		self.npc_model:SetModelScale(Vector3(1, 1, 1))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
end

function TaskDialogView:SetRoleModel()
	if not self.role_model then
		self.role_model = RoleModel.New("task_dialog_panel")
		self.role_model:SetWingNeedAction(false)
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		self.role_model:SetDisplay(self.display3D2.ui3d_display, RoleModelType.half_body)
		self.role_model:SetRoleResid(main_role:GetRoleResId())
		self.role_model:SetWeaponResid(main_role:GetWeaponResId())
		self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
		self.role_model:SetWingResid(main_role:GetWingResId())
		self.role_model:SetHaloResid(main_role:GetHaloResId())
	end
end

function TaskDialogView:SetNpcAction()
	if not self:IsOpen() then
		return
	end
	if self.delay_action then
		return
	end

	-- 不知道是不是策划还是美术改了默认播放动作了，所以这里就不再设置一次动作播放
	-- self.npc_model:SetTrigger("Action")
	self.delay_action = GlobalTimerQuest:AddDelayTimer(function()
		self:SetNpcAction()
		self.delay_action = nil
	end, 10)
end

function TaskDialogView:OnFlush(param_list)
	if self.npc_id == nil then
		return
	end

	local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.npc_id]
	if npc_cfg == nil then
		return
	end

	self.npc_name = npc_cfg.show_name
	self.name:SetValue(self.npc_name)
	
	self:FlushNpcTalk()
	if npc_cfg.role_res == nil or npc_cfg.role_res <= 0 then
		if npc_cfg.monster_res ~= "" and npc_cfg.monster_res > 0 then
			self:SetNpcModel3(npc_cfg.monster_res)
		elseif npc_cfg.general_res ~= "" and npc_cfg.general_res > 0 then
			self:SetNpcModelGeneral(npc_cfg.general_res)
		elseif npc_cfg.beauty_res ~= "" and npc_cfg.beauty_res > 0 then
			self:SetNpcModelBeauty(npc_cfg.beauty_res)
		else
			self:SetNpcModel(npc_cfg.resid)
		end
	else
		self:SetNpcModel2(npc_cfg.role_res, npc_cfg.weapen_res, npc_cfg.mount_res, npc_cfg.wing_res, npc_cfg.halo_res)
	end

	-- 连服密道npc
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(vo.server_group)
	if self.npc_id == cfg.midao_npc then
		local midao_data = LianFuDailyData.Instance:GetMiDaoIsOpen()
		local is_open = midao_data[vo.server_group + 1]
		if is_open == 1 then
			self.button_name:SetValue(Language.Task.EnterMiDao)
		else
			self.button_name:SetValue(Language.Task.OpenMiDao)
		end
		self.show_btn:SetValue(false)
		self.show_finger:SetValue(false)
		self.is_show_btn:SetValue(true)
		return
	end

	-- 公会争霸npc
	if self.npc_id == GuildFightData.Instance.npc_id then
		if Scene.Instance:GetMainRole().vo.special_param > 0 then
			self.button_name:SetValue(Language.Task.CommitBox)
			self.auto_talk = true
			self:SetAutoTalkTime(5)
			return
		end
	end

	-- 营救npc(滑动救美人)
	local yingjiu_info = NationalWarfareData.Instance:GetYingJiuInfo()
	for k, v in pairs(NationalWarfareData.YingJiuNpcId) do
		if self.npc_id == v then
			if yingjiu_info.task_seq == 2 then
				self.button_name:SetValue(Language.Task.QianWangJiuYuan)
				return
			end
		end
	end
	if self.npc_id == NationalWarfareData.YingJiuLastPhaseNpcId and yingjiu_info.task_seq == 4 then
		self.button_name:SetValue(Language.Common.LingQuJiangLi)
		return
	end

	-- 是否抱美人任务
	local is_hold_beauty_task = TaskData.Instance:GetIsHoldBeautyTask(self.task_id)
	if is_hold_beauty_task == 1 then
		self.button_name:SetValue(Language.Task.task_status_word[1])
		self:SetAutoTalkTime()
		return
	end

	self:SetAutoTalkTime()
	self.task_staus = TaskData.Instance:GetTaskStatus(self.task_id)
	if(self.task_staus == TASK_STATUS.CAN_ACCEPT) then
		self.button_name:SetValue(Language.Task.task_status_word[1])
	elseif(self.task_staus == TASK_STATUS.COMMIT) then
		self.button_name:SetValue(Language.Task.task_status_word[2])
	elseif(self.task_staus == TASK_STATUS.ACCEPT_PROCESS) then
		self.button_name:SetValue(Language.Task.task_status_word[4])
	else
		self.button_name:SetValue(Language.Task.task_status_word[3])
	end

	local check_flag = false
	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1]
	if cfg ~= nil and cfg.change_camp_npc_id ~= nil then
		if self.npc_id ~= nil and self.npc_id == cfg.change_camp_npc_id then
			check_flag = true
		end
	end

	if self.show_open_btn ~= nil then
		self.show_open_btn:SetValue(check_flag)
	end
end

function TaskDialogView:SetNpcId(npc_id, npc_obj_id)
	if self.npc_id ~= npc_id and self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end
	self.npc_id = npc_id
	self.npc_obj_id = npc_obj_id
	self:Flush()
end

function TaskDialogView:SetStoryNpcId(npc_id, story_talk_end_callback)
	if self.npc_id ~= npc_id and self.delay_action then
		GlobalTimerQuest:CancelQuest(self.delay_action)
		self.delay_action = nil
	end

	self.auto_talk = true
	self.npc_id = npc_id
	self.npc_obj_id = nil
	self.story_talk_end_callback = story_talk_end_callback
	self:Flush()
end

function TaskDialogView:ClickPanel()
	self:HandleAccept()
	self:Close()
end

function TaskDialogView:OnClose()
	-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	-- TaskCtrl.Instance:SetAutoTalkState(true)
	-- self:HandleClose()
	self:HandleAccept()
end

function TaskDialogView:CloseView()
	self.time_daoji:SetValue("")
	self:Close()
	TaskCtrl.Instance:SetAutoTalkState(false)
	if self.time_count_down then
		CountDown.Instance:RemoveCountDown(self.time_count_down)
		self.time_count_down = nil
	end
end

function TaskDialogView:HandleClose(not_clear_toggle)
	GuajiCtrl.Instance:ClearTaskOperate(not_clear_toggle)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:Close()
end

function TaskDialogView:HandleAccept()
	if self.task_id > 0 and TaskData.Instance:GetIsHoldBeautyTask(self.task_id) then	-- 抱起美人
		local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
		if task_cfg and TASK_ACCEPT_OP.HOLD_BEAUTY == task_cfg.accept_op and "" ~= task_cfg.a_param1 then
			local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
			if hold_beauty_npcid <= 0 then
				IS_HUN_BEAUTY = true
				PlayerCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_HOLD_BEAUTY, task_cfg.a_param1)
				self:HandleClose()
				return
			else
				self:HandleClose()
				return
			end
		end
	end

	if TaskData.Instance:GetYingJiuSendFlag() then
		TaskCtrl.Instance:SendTalkTask(self.npc_id)
		TaskData.Instance:YingJiuTalkChange(false)
	end


	if TaskData.Instance:CheckIsMultiTalkNpc(self.npc_id) then		
		TaskCtrl.Instance:SendTalkTask(self.npc_id)
	end

	local role_vo_camp = PlayerData.Instance.role_vo.camp
	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local npc_info = TaskData.Instance:GetRiChangFbNpcCfg()

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local xycity_cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(vo.server_group)

	if self.task_id ~= 0 then
		local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
		if (self:IsDailyTaskFb() or task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB) and self.task_staus ~= TASK_STATUS.COMMIT then
			if task_cfg.task_type == TASK_TYPE.RI then
				FuBenCtrl.Instance:SendEnterFBReq(task_cfg.c_param1, task_cfg.c_param2)
				self:HandleClose()
				return
			end
		end

		if self.task_staus == TASK_STATUS.ACCEPT_PROCESS and task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB then
			FuBenCtrl.Instance:SendEnterFBReq(task_cfg.c_param1, task_cfg.c_param2)
			self:HandleClose()
			return
		end

		if(GuajiCache.guaji_type == GuajiType.None) then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		end
		if self.task_staus == TASK_STATUS.CAN_ACCEPT then
			if not self:IsShouldKeepWindow() then
				self:HandleClose(true)
			else
				GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id, true)
			end
			TaskCtrl.SendTaskAccept(self.task_id)

			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)

			if nil ~= task_cfg then
				if TASK_ACCEPT_OP.ENTER_FB == task_cfg.accept_op and "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then  -- 进入副本
					FuBenCtrl.Instance:SendEnterFBReq(task_cfg.a_param1, task_cfg.a_param2)
				end

				if TASK_ACCEPT_OP.OPEN_GUIDE_FB_ENTRANCE == task_cfg.accept_op then -- 进入引导副本
					StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, self.task_id)
				end
			end

		elseif self.task_staus == TASK_STATUS.COMMIT then
			if self:IsShouldKeepWindow() then
				GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id, true)
			else
				self:HandleClose()
			end
			TaskCtrl.SendTaskCommit(self.task_id)
			-- TaskData.Instance:SetTaskCompleted(self.task_id)
		elseif self.task_staus == TASK_STATUS.ACCEPT_PROCESS then
			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
			if task_cfg.condition == TASK_COMPLETE_CONDITION.NPC_TALK then
				TaskCtrl.Instance:SendTalkTask(self.npc_id)
			end
			self:HandleClose()
			GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "task_go_on", self.task_id)
		end
	elseif self.npc_id == GuildFightData.Instance:GetNpcId() then
		GuildFightCtrl.Instance:SendGBRoleCalcSubmitReq()
		self:HandleClose()
	elseif self.npc_id == npc_info[1].id then
		local task_info = TaskData.Instance:GetDailyTaskInfo()
		local task_cfg = TaskData.Instance:GetTaskConfig(task_info.task_id)
		if task_cfg 
			and task_cfg.task_type == TASK_TYPE.RI 
			and task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB 
			and task_cfg.c_param1 == GameEnum.FB_CHECK_TYPE.FBCT_DAILY_TASK_FB then
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DAILY_TASK_FB)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
		self:HandleClose()
	elseif self.npc_id == xycity_cfg.midao_npc then
		local midao_data = LianFuDailyData.Instance:GetMiDaoIsOpen()
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local is_open = midao_data[role_vo.server_group + 1]

		if is_open == 1 then
			LianFuDailyCtrl.Instance:SendCrossXYCityReq(CROSS_XYCITY_REQ_TYPE.OP_MIDAO_TRANSPORT)
		else
			local cfg = LianFuDailyData.Instance:GetCrossXYCityCfg()
			if cfg and next(cfg) then
				local reward_item = cfg.other[1].accept_midao_task_rewards
				if reward_item and next(reward_item) then
					local item_name = ItemData.Instance:GetItemName(reward_item[0].item_id) or Language.LianFuDaily.KaiQiMiDaoReward
					local ok_fun = function ()
						LianFuDailyCtrl.Instance:SendCrossXYCityReq(CROSS_XYCITY_REQ_TYPE.OP_ACCEPT_MIDAO_TASK)
					end
					TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.LianFuDaily.KaiQiMiDao, cfg.other[1].accept_midao_task_need_gold, item_name))
				end
			end
		end
		self:HandleClose()
	else
		self:HandleClose()
	end
end

function TaskDialogView:IsShouldKeepWindow()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg and self.auto_do_task then
		if task_cfg.task_type == TASK_TYPE.ZHU then
			local next_task_cfg = TaskData.Instance:GetNextZhuTaskConfigById(self.task_id)
			if next_task_cfg then
				if self.task_staus == TASK_STATUS.COMMIT then
					if next_task_cfg.accept_npc and type(next_task_cfg.accept_npc) == "table"
						and next_task_cfg.accept_npc.id == self.npc_id
						and next_task_cfg.min_level <= GameVoManager.Instance:GetMainRoleVo().level then
						return true
					end
				elseif self.task_staus == TASK_STATUS.CAN_ACCEPT then
					if task_cfg.condition == TASK_COMPLETE_CONDITION.NOTHING and task_cfg.commit_npc
						and type(task_cfg.commit_npc) == "table" and task_cfg.commit_npc.id == self.npc_id then
						return true
					end
				end
			end
		end
	end
	return false
end

function TaskDialogView:ClickGoOn()
	if self.talk_table then
		self.cur_index = self.cur_index + 1
		if self.cur_index > #self.talk_table then
			self:HandleAccept()
			return
		end
		self:SetAutoTalkTime()
		if self.cur_index == #self.talk_table then
			self.show_btn:SetValue(true)
			self:FlushRewardList()
		else
			self.show_btn:SetValue(false)
		end
		local content = self.talk_table[self.cur_index]
		if content then
			self.show_npc:SetValue(true)
			self.name:SetValue(self.npc_name)
			local i, j = string.find(content, "{npc}")
			if not i or not j then
				i, j = string.find(content, "{plr}")
				if i and j then
					self.show_npc:SetValue(false)
					self:SetRoleModel()
					self.name:SetValue(GameVoManager.Instance:GetMainRoleVo().name)
				end
			end
			if i and j then
				content = string.sub(content, j + 1, -1)
			end
			self.content:SetValue(content)
		end
	end
end

-- 刷新NPC对话内容
function TaskDialogView:FlushNpcTalk()
	local task_id = TaskData.Instance:GetCurTaskId()
	local exits_task = TaskData.Instance:GetNpcOneExitsTask(self.npc_id)
	self.npc_status = TaskData.Instance:GetNpcTaskStatus(self.npc_id)
	local national_state = NationalWarfareData.Instance:CheckIsTalkNpc(self.npc_id)
	self.talk_id = 0
	if TaskData.Instance:CheckIsMultiTalkNpc(self.npc_id) then
		self.talk_id = TaskData.Instance:GetMultiTalkId()
	elseif (self.npc_status == TASK_STATUS.CAN_ACCEPT or self.npc_status == TASK_STATUS.ACCEPT_PROCESS)then			--有可接任务或者未完成的任务
		if exits_task then
			self.talk_id = exits_task.accept_dialog
		end
	elseif self.npc_status == TASK_STATUS.COMMIT then			--有可提交任务
		if exits_task then
			self.talk_id = exits_task.commit_dialog
		end
	elseif national_state then
		local yingjiu_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq()
		self.talk_id = yingjiu_cfg.talk_id
	else
		local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.npc_id]
		if npc_cfg then
			self.talk_id = npc_cfg.talkid
		end
	end

	if nil ~= exits_task then
		self.task_id = exits_task.task_id
		if exits_task.task_type == TASK_TYPE.RI and exits_task.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then
			self.task_id = 0
		end
	else
		self.task_id = 0
	end

	self.jiang_li:SetValue("")
	for i = 1, NUM do
		self.rewards[i].obj:SetActive(false)
	end

	local talk_content = Language.Task.DefaultTalk
	local talk_cfg = ConfigManager.Instance:GetAutoConfig("npc_talk_list_auto").npc_talk_list[self.talk_id]
	if talk_cfg ~= nil then
		talk_content = talk_cfg.talk_text
		talk_content = CommonDataManager.ParseTagContent(talk_content)
		self.task_is_show_btn = TaskData.Instance:GetTaskIsShowBtn(self.task_id,self.npc_id)
		self.is_show_btn:SetValue(self.task_is_show_btn)
		self.show_btn:SetValue(not(self.task_is_show_btn))
		self.show_finger:SetValue(not(self.task_is_show_btn))
	end
	self:SetTalk(talk_content)
	-- self.content:SetValue(talk_content)
	GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 1, self.task_id)
end

function TaskDialogView:SetTalk(talk_content)
	if not talk_content then return end
	self.talk_table = Split(talk_content, "|")
	if #self.talk_table > 1 then
		self.show_btn:SetValue(false)
		self.cur_index = 0
		self:ClickGoOn()
	elseif #self.talk_table == 1 then
		self.cur_index = 1
		self.show_npc:SetValue(true)
		if TaskData.Instance:GetIsHoldBeautyTask(self.task_id) == 2 then
			self.show_btn:SetValue(false)
		else
			self.show_btn:SetValue(true)
		end
		self:FlushRewardList()
		self.content:SetValue(self.talk_table[1])
	end
end

-- 刷新任务奖励列表
function TaskDialogView:FlushRewardList()
	if self.task_id == 0 then 
		self.is_show_btn:SetValue(false)
		return 
	end
	for i = 1, NUM do
		self.rewards[i].obj:SetActive(false)
	end
	self.jiang_li:SetValue(Language.Task.JiangLi)
	local config = TaskData.Instance:GetTaskConfig(self.task_id)
	if not config or config.accept_op == TASK_ACCEPT_OP.HOLD_BEAUTY then return end
	local reward_list = {}
	if next(config.item_list) then
		reward_list = config.item_list
	else
		reward_list = config["prof_list" .. GameVoManager.Instance:GetMainRoleVo().prof]
	end
	
	-- 如果是运镖
	if config.task_id == YunbiaoData.Instance:GetTaskIdByCamp() then
		local color = YunbiaoData.Instance:GetHuSongPreColor()
		local give_times = YunbiaoData.Instance:GetHuSongGiveTimes()
		reward_list = NationalWarfareData.Instance:GetYunBiaoRewardByIndex(color, give_times)
	end

	local count = 0
	if reward_list then
		for k,v in pairs(reward_list) do
			count = count + 1
			self.rewards[count + 1].obj:SetActive(true)
			self.rewards[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
			if count >= NUM then
				break
			end
		end
	end
	-- 如果是日常任务副本
	self.task_is_show_btn = TaskData.Instance:GetTaskIsShowBtn(self.task_id,self.npc_id)
	self.is_show_btn:SetValue(self.task_is_show_btn)
	self.show_btn:SetValue(not(self.task_is_show_btn))
	self.show_finger:SetValue(not(self.task_is_show_btn))
	if self.task_is_show_btn then
		local dialy_exp, gongxian = DailyTaskFbData.Instance:DayRiChangFbReward()
		self.rewards[1].obj:SetActive(true)
		self.rewards[2].obj:SetActive(true)
		-- self.rewards[3].obj:SetActive(false)
		-- self.rewards[4].obj:SetActive(false)
		self.rewards[1].cell:SetData({item_id = ResPath.CurrencyToIconId.exp, num = dialy_exp})
		self.rewards[2].cell:SetData({item_id = ResPath.CurrencyToIconId.guild_gongxian, num = gongxian})
		self:SetTimeAutoTalk()
	elseif config.task_id ~= YunbiaoData.Instance:GetTaskIdByCamp() then
		-- for i = 2 + count, NUM do
		-- 	self.rewards[i].obj:SetActive(false)
		-- end
		self.rewards[1].obj:SetActive(true)
		local num = config.exp ~= "" and config.exp or nil
		local data = {item_id = ResPath.CurrencyToIconId.exp, num = num}
		self.rewards[1].cell:SetData(data)
	end
end

-- 设置倒计时
function TaskDialogView:SetTimeAutoTalk()
	self.time_daoji:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(10, TEXT_COLOR.GREEN)))
	if self.time_count_down then
		CountDown.Instance:RemoveCountDown(self.time_count_down)
		self.time_count_down = nil
	end
	self.time_count_down = CountDown.Instance:AddCountDown(10, 1, BindTool.Bind(self.TimeCountDown, self))
end

-- 倒计时函数
function TaskDialogView:TimeCountDown(elapse_time, total_time)
	self.time_daoji:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.GREEN)))
	if elapse_time >= total_time then
		self:HandleAccept()
	end
end

-- 设置自动对话的倒计时
function TaskDialogView:SetAutoTalkTime(delay_time)
	delay_time = delay_time and delay_time or DELAY_TIME
	if self:CheckIsAutoTalk() or self.auto_talk then
		self.auto_talk = false
		self.show_time:SetValue(true)
		self.time:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(DELAY_TIME, TEXT_COLOR.GREEN)))
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		local time = self:IsDailyTaskFb() and 5 or delay_time
		self:CountDown(0, time)
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	else
		self.show_time:SetValue(false)
	end
end

-- 设置自动对话的倒计时
function TaskDialogView:CountDown(elapse_time, total_time)
	if self.time then
		self.time:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.GREEN)))
		if elapse_time >= total_time then
			self:ClickGoOn()
		end
	end
end

function TaskDialogView:SetAutoTalkState(state)
	self.is_auto = state
	if self:IsOpen() then
		if state and not self.count_down then
			self:SetAutoTalkTime()
		elseif not state then
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
				self.show_time:SetValue(false)
			end
		end
	end
end

function TaskDialogView:CloseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end

	self.last_npc_resid = 0
	GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id)
	if self.npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
		if npc_obj then
			local npc_vo = npc_obj:GetVo()
			if npc_vo then
				local obj = npc_obj:GetRoot()
				if obj then
					obj.transform:DORotate(u3d.vec3(0, npc_vo.rotation_y or 0, 0), 0.5)
				end
			end
		end
	end
	self.npc_obj_id = nil

	if nil ~= self.story_talk_end_callback then
		self.story_talk_end_callback()
		self.story_talk_end_callback = nil
	end

	if self.time_count_down then
		CountDown.Instance:RemoveCountDown(self.time_count_down)
		self.time_count_down = nil
	end
	self.task_is_show_btn = false
end

function TaskDialogView:SetAutoDoTask(switch)
	self.auto_do_task = switch
	if not switch then
		self:Close()
	end
end


-- 是否自动对话
function TaskDialogView:CheckIsAutoTalk()
	local flag = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_dialy_task_cfg = TaskData.Instance:GetCurLevelDialyCfg()
	if TaskData.Instance:GetNpcOneExitsTask(self.npc_id) and self.is_auto then
		if main_role_vo.level <= LEVEL_LIMIT or self.npc_id == COMMON_CONSTS.NPC_HUSONG_DONE_ID then
			flag = true
		-- 如果是日常任务的多对话NPC
		elseif cur_dialy_task_cfg and cur_dialy_task_cfg.task_type == TASK_TYPE.RI then
			if cur_dialy_task_cfg.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC or cur_dialy_task_cfg.accept_op == TASK_ACCEPT_OP.HOLD_BEAUTY then
				flag = true
			end
		end
	end
	if self:IsDailyTaskFb() then
		flag = true
	end
	return flag
end

function TaskDialogView:IsDailyTaskFb()
	local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
	if task_cfg and TASK_ACCEPT_OP.ENTER_DAILY_TASKFB == task_cfg.accept_op then
		return true
	end
	return false
end

function TaskDialogView:OpenView()
	ViewManager.Instance:Open(ViewName.CampChangeView)
	self:Close()
end