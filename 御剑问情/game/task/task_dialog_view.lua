TaskDialogView = TaskDialogView or BaseClass(BaseView)

local NUM = 4  -- 奖励栏数量
local DELAY_TIME = 10 -- 自动做任务的时间
local LEVEL_LIMIT = 130 -- 自动做任务的等级
local DISPLAYNAME = {
	[4043001] = "task_dialog_special_1",
	[4045001] = "task_dialog_special_2",
	[4032001] = "task_dialog_special_3",
	[4035001] = "task_dialog_special_4",
	[4052001] = "task_dialog_special_5",
	[4064001] = "task_dialog_special_6"
}

function TaskDialogView:__init()
	self.ui_config = {"uis/views/taskview_prefab", "TaskDialogView"}
	self.play_audio = true
	self.close_mode = CloseMode.CloseVisible

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

	for k,v in pairs(self.reward) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.reward = {}

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
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
	self.reward = nil
	self.time_t = nil
	self.isEmpty = nil
end

function TaskDialogView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClose, self))
	self:ListenEvent("Accept",
		BindTool.Bind(self.HandleAccept, self))
	self:ListenEvent("ClickGoOn",
		BindTool.Bind(self.ClickGoOn, self))
	self:ListenEvent("ClickPanel",
		BindTool.Bind(self.ClickPanel, self))

	self.time_t = self:FindVariable("Time_t")
	self.name = self:FindVariable("Name")
	self.content = self:FindVariable("Content")
	self.button_name = self:FindVariable("ButtonName")
	self.show_time = self:FindVariable("ShowTime")
	self.time = self:FindVariable("Time")
	self.show_npc = self:FindVariable("ShowNpc")
	self.show_btn = self:FindVariable("ShowBtn")
	self.jiang_li = self:FindVariable("JiangLi")
	self.isEmpty = self:FindVariable("isEmpty")
	self.display3D = self:FindObj("Display3D")
	self.display3D2 = self:FindObj("Display3D2")
	--self.title = self:FindObj("Title")
	self.rewards = {}
	self.reward = {}
	for i = 1, NUM do
		self.rewards[i] = {}
		self.rewards[i].obj = self:FindObj("Reward" .. i)
		self.rewards[i].cell = ItemCell.New()
		self.rewards[i].cell:SetInstanceParent(self.rewards[i].obj)
		self.rewards[i].cell:SetIsShowTips(false)
		self.rewards[i].cell:ShowHighLight(false)


		self.reward[i] = {}
		self.reward[i].obj = self:FindObj("Rewar"..i)
		self.reward[i].cell = ItemCell.New()
		self.reward[i].cell:SetInstanceParent(self.reward[i].obj)
		self.reward[i].cell:SetIsShowTips(false)
		self.reward[i].cell:ShowHighLight(false)
	end
	self.is_auto = true
end

function TaskDialogView:OpenCallBack()
	self.show_npc:SetValue(true)
	GuajiCtrl.Instance:PlayNpcVoice(self.npc_obj_id)
end

function TaskDialogView:SpecialNpcModle(modle_id)
	local display_name = "task_dialog_view"
	for k,v in pairs(DISPLAYNAME) do
		if modle_id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

-- 设置NPC模型
function TaskDialogView:SetNpcModel(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New()
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	self.npc_model:SetPanelName(self:SpecialNpcModle(resid))

	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetNpcModel(resid))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end
	self.npc_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.TASKDIALOG], self.last_npc_resid, DISPLAY_PANEL.FULL_PANEL)
end

-- 设置NPC特殊模型(人物)
function TaskDialogView:SetNpcModel2(role_res, weapen_res, mount_res, wing_res, halo_res)
	if not self.npc_model then
		self.npc_model = RoleModel.New()
		self.npc_model:SetWingNeedAction(false)
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)
	end
	self.npc_model:SetPanelName(self:SpecialNpcModle(role_res))

	if self.last_npc_resid ~= role_res then
		self.npc_model:SetMainAsset(ResPath.GetRoleModel(role_res))

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
--	self.npc_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.TASKDIALOG], self.last_npc_resid, DISPLAY_PANEL.FULL_PANEL)
end

-- 设置NPC特殊模型(怪物)
function TaskDialogView:SetNpcModel3(resid)
	if not self.npc_model then
		self.npc_model = RoleModel.New(self:SpecialNpcModle())
		self.npc_model:SetDisplay(self.display3D.ui3d_display, RoleModelType.half_body)

	end
	if self.last_npc_resid ~= resid then
		self.npc_model:SetMainAsset(ResPath.GetMonsterModel(resid))
		self:SetNpcAction()
		self.last_npc_resid = resid
	end

end

function TaskDialogView:SetRoleModel()
	if not self.role_model then
		self.role_model = RoleModel.New("task_dia_view")
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		self.role_model:SetDisplay(self.display3D2.ui3d_display, RoleModelType.half_body)
		self.role_model:SetWingNeedAction(false)
		self.role_model:SetGoddessWingNeedAction(false)
		self.role_model:SetRoleResid(main_role:GetRoleResId())
		self.role_model:SetWeaponResid(main_role:GetWeaponResId())
		self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
		self.role_model:SetWingResid(main_role:GetWingResId())
		self.role_model:SetHaloResid(main_role:GetHaloResId())

		if main_role.vo.prof == ROLE_PROF.PROF_3 then
			--逍遥用idle_n2动作
			self.role_model:SetBool("idle_n2", true)
		else
			self.role_model:SetBool("idle_n2", false)
		end
--		self.npc_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.TASKDIALOG], self.last_npc_resid, DISPLAY_PANEL.FULL_PANEL)
	end
end

function TaskDialogView:SetNpcAction()
	if not self:IsOpen() then
		return
	end
	if self.delay_action then
		return
	end
	self.npc_model:SetTrigger("Action")
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
	-- if self.npc_id == 4000 then
	-- 	self.button_name:SetValue(Language.Task.TiJiaoBaoXiang)
	-- 	return
	-- end
	self:FlushNpcTalk()
	if npc_cfg.role_res == nil or npc_cfg.role_res <= 0 then
		if npc_cfg.monster_res == "" or npc_cfg.monster_res <= 0 then
			self:SetNpcModel(npc_cfg.resid)
		else
			self:SetNpcModel3(npc_cfg.monster_res)
		end
	else
		self:SetNpcModel2(npc_cfg.role_res, npc_cfg.weapen_res, npc_cfg.mount_res, npc_cfg.wing_res, npc_cfg.halo_res)
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

	--精华护送npc
	if self.npc_id == JingHuaHuSongData.Instance:GetCommitNpc() then
		if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
			self:SetTalk(Language.Task.ling_commit)
			self.button_name:SetValue(Language.Task.task_status_word[2])
			self:SetAutoTalkTime(5)
			return
		end
	end

	self.auto_talk = true
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

function TaskDialogView:HandleClose(not_clear_toggle)
	GuajiCtrl.Instance:ClearTaskOperate(not_clear_toggle)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:Close()
end

function TaskDialogView:HandleAccept()
	--精华护送npc
	if self.npc_id == JingHuaHuSongData.Instance:GetCommitNpc() then
		if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
			JingHuaHuSongCtrl.Instance:SendCommitReq()								--提交任务
			self:HandleClose()
			JingHuaHuSongCtrl.Instance:CheckAndOpenContinueMessageBox()				--询问玩家是否回去采集
			return
		end
	end
	if self.task_id ~= 0 then
		if self:IsDailyTaskFb() and self.task_staus ~= TASK_STATUS.COMMIT then
			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DAILY_TASK_FB, task_cfg.c_param1)
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
			TaskCtrl.Instance.SendTaskAccept(self.task_id)

			local task_cfg = TaskData.Instance:GetTaskConfig(self.task_id)

			if nil ~= task_cfg then
				if TASK_ACCEPT_OP.ENTER_FB == task_cfg.accept_op and "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then  -- 进入副本
					local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
					if main_role_vo.level > LEVEL_LIMIT then
						FuBenCtrl.Instance:SendEnterFBReq(task_cfg.a_param1, task_cfg.a_param2)
					end
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
			TaskCtrl.Instance.SendTaskCommit(self.task_id)
			-- TaskData.Instance:SetTaskCompleted(self.task_id)
		elseif self.task_staus == TASK_STATUS.ACCEPT_PROCESS then
			self:HandleClose()
			TaskCtrl.Instance:DoTask(self.task_id)
		end
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
					self.auto_talk = true
					self:SetAutoTalkTime()
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
	self.talk_id = 0
	if (self.npc_status == TASK_STATUS.CAN_ACCEPT or self.npc_status == TASK_STATUS.ACCEPT_PROCESS)then			--有可接任务或者未完成的任务
		if exits_task then
			self.talk_id = exits_task.accept_dialog
		end
	elseif self.npc_status == TASK_STATUS.COMMIT then			--有可提交任务
		if exits_task then
			self.talk_id = exits_task.commit_dialog
		end
	else
		local npc_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[self.npc_id]
		if npc_cfg then
			self.talk_id = npc_cfg.talkid
		end
	end

	if nil ~= exits_task then
		self.task_id = exits_task.task_id
	else
		self.task_id = 0
	end

	self.jiang_li:SetValue("")
	for i = 1, NUM do
		self.rewards[i].obj:SetActive(false)
		self.reward[i].obj:SetActive(false)
		self.isEmpty:SetValue(true)
	end

	local talk_content = Language.Task.DefaultTalk
	local npc_obj = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
	if npc_obj then
		if npc_obj:IsWalkNpc() then
			talk_content = npc_obj:GetRandomStr()
		end
	end
	local talk_cfg = ConfigManager.Instance:GetAutoConfig("npc_talk_list_auto").npc_talk_list[self.talk_id]
	if talk_cfg ~= nil then
		talk_content = talk_cfg.talk_text
		talk_content = CommonDataManager.ParseTagContent(talk_content)
		-- self:FlushRewardList()
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
		self.show_btn:SetValue(true)
		self:FlushRewardList()
		self.content:SetValue(self.talk_table[1])
	end
end

-- 刷新任务奖励列表
function TaskDialogView:FlushRewardList()
	-- 如果是精华护送
	if self.npc_id == JingHuaHuSongData.Instance:GetCommitNpc() then
		if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
			local reward_list = JingHuaHuSongData.Instance:GetRewardItemList()
			if reward_list then
				local count = 0
				for k,v in pairs(reward_list) do
					count = count + 1
					self.rewards[count + 1].obj:SetActive(true)
					self.reward[count + 1].obj:SetActive(true)
					self.isEmpty:SetValue(false)
					self.rewards[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
					self.reward[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
					if count >= NUM - 1 then
						break
					end
				end
			end
			return
		end
	end
	if self.task_id == 0 then return end
	self.jiang_li:SetValue(Language.Task.JiangLi)
	local config = TaskData.Instance:GetTaskConfig(self.task_id)
	if not config then return end
	local reward_list = config["prof_list" .. GameVoManager.Instance:GetMainRoleVo().prof]
	local count = 0
	if reward_list then
		for k,v in pairs(reward_list) do
			count = count + 1
			self.rewards[count + 1].obj:SetActive(true)
			self.reward[count + 1].obj:SetActive(true)
			self.isEmpty:SetValue(false)
			self.rewards[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
			self.reward[count + 1].cell:SetData({item_id = v.item_id, num = v.num})
			if count >= NUM - 1 then
				break
			end
		end
	end
	for i = 2 + count, NUM do
		self.rewards[i].obj:SetActive(false)
		self.reward[i].obj:SetActive(false)
		self.isEmpty:SetValue(true)
	end
	self.rewards[1].obj:SetActive(true)
	self.reward[1].obj:SetActive(true)
	self.isEmpty:SetValue(false)
	local num = tonumber(config.exp)
	-- 如果是运镖
	if config.task_id == YunbiaoData.Instance:GetTaskIdByCamp() then
		local yunbiao_cfg = YunbiaoData.Instance:GetCurExitTaskRewardCfg() or {}
		num = yunbiao_cfg.exp or 0
	end
	local data = {item_id = ResPath.CurrencyToIconId.exp, num = num}
	self.rewards[1].cell:SetData(data)
	self.reward[1].cell:SetData(data)
end

-- 设置自动对话的倒计时
function TaskDialogView:SetAutoTalkTime(delay_time)
	delay_time = delay_time and delay_time or DELAY_TIME
	if self:CheckIsAutoTalk() or self.auto_talk then
		self.auto_talk = false
		self.show_time:SetValue(true)
		self.time:SetValue(string.format(Language.Task.AutoGoOn, ("<color=#30ff00>"..DELAY_TIME.."</color>")))
		self.time_t:SetValue("<color=#00ff06>"..DELAY_TIME.."</color>")
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		local time = self:IsDailyTaskFb() and 5 or delay_time
		self:CountDown(0, time)
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	else
		self.time_t:SetValue("<color=#00ff06>"..DELAY_TIME.."</color>")
		self.show_time:SetValue(false)
	end
end

-- 设置自动对话的倒计时
function TaskDialogView:CountDown(elapse_time, total_time)
	if self.time or self.time_t then
		self.time:SetValue(string.format(Language.Task.AutoGoOn,("<color=#30ff00>"..math.ceil(total_time - elapse_time).."</color>")))
		self.time_t:SetValue(("<color=#00ff06>"..math.ceil(total_time - elapse_time).."</color>"))
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
	self.last_npc_resid = 0
	GlobalEventSystem:Fire(OtherEventType.TASK_WINDOW, 0, self.task_id)
	if self.npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
		if npc_obj then
			if npc_obj:IsWalkNpc() then
				npc_obj:Continue()
			else
				local npc_vo = npc_obj:GetVo()
				if npc_vo then
					local obj = npc_obj:GetRoot()
					if obj then
						obj.transform:DORotate(u3d.vec3(0, npc_vo.rotation_y or 0, 0), 0.5)
					end
				end
			end

		end
	end
	self.npc_obj_id = nil

	if nil ~= self.story_talk_end_callback then
		self.story_talk_end_callback()
		self.story_talk_end_callback = nil
	end
	if self.npc_id and self.npc_id > 0 then
		TaskCtrl.SendTaskTalkToNpc(self.npc_id)
	end
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
	if TaskData.Instance:GetNpcOneExitsTask(self.npc_id) and self.is_auto then
		if main_role_vo.level <= LEVEL_LIMIT or self.npc_id == COMMON_CONSTS.NPC_HUSONG_DONE_ID then
			flag = true
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