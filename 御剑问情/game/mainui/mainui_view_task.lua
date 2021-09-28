MainUIViewTask = MainUIViewTask or BaseClass(BaseRender)

local DELAY_TIME = 0.25
local INTERVAL_TIME = 1
local ListViewDelegate = ListViewDelegate
MainUIViewTask.SHOW_GUIDE_ARROW = false
local CAN_SHOW_ZHU_ARROW = false	-- 显示主线箭头
local CAN_SHOW_ZHI_ARROW = true 	-- 显示支线箭头
local CAN_SHOW_GUILD_ARROW = false 	-- 显示公会箭头
local CUR_TASK = 0 					-- 当前任务
local CUR_ZHI_TASK = 99999  		-- 当前支线
local HAS_ZHI_TASK = false 			-- 是否存在支线
local HAS_GUILD_TASK = nil 			-- 是否存在公会任务
local HAS_RI_TASK = false 			-- 是否存在日常任务
local CAN_DO_ZHU_TASK = false 		-- 是否可做主线
local CLICK_EFFECT_TASK = 0 		-- 最后点击的特效任务ID
local ARROW_TASK_ID = 0
local HAS_HUG_TASK = 0 				-- 是否有抱东西任务
function MainUIViewTask:__init()
	self.is_load = true
	self.is_move = false
	self.task_data = {}
	self.cell_list = {}

	self.normal_task = self:FindObj("NormalTask")
	self.chapter_task = self:FindObj("ChapterTask")
	self.normal_task:SetActive(false)

	self.task_list = self:FindObj("TaskList")
	self.guide_arrow = self:FindObj("GuideArrow")

	self.show_down_arrow = self:FindVariable("ShowDownArrow")
	self.guide_arrow:SetActive(false)
	self.toggle_group = self.task_list:GetComponent("ToggleGroup")
	self.toggles = {}

	self.time = self:FindVariable("time")

	self.chapter_name = self:FindVariable("ChapterName")
	self.chapter_progress = self:FindVariable("ChapterProgress")
	self.chapter_progress_txt = self:FindVariable("ChapterProgressTxt")
	self.chapter_step_bar_txt = self:FindVariable("ChapterStepBarTxt")
	self.show_chapter_txt = self:FindVariable("ShowChapterTxt")
	self.task_condition = self:FindVariable("TaskCondition")
	self.task_desc = self:FindVariable("TaskDesc")
	self.task_button_txt = self:FindVariable("TaskButtonTxt")
	self.start_obj = self:FindVariable("start_obj")
	self.end_obj = self:FindVariable("end_obj")

	self:ListenEvent("DoTask", BindTool.Bind(self.OnTouchChapterTask, self))

	self.list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "TaskInfo"), function (prefab)
		if nil == prefab then
			return
		end

		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.enhanced_cell_type = enhanced_cell_type
		self.task_list.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = function()
			return #self.task_data
		end
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
		self.task_list.scroller.scrollerScrollingChanged = function ()
			self:ReSetBtnVisible()
		end
	end)

	-- 监听系统消息
	self:BindGlobalEvent(OtherEventType.TASK_CHANGE,
		BindTool.Bind(self.OnTaskChange, self))
	self:BindGlobalEvent(ObjectEventType.LEVEL_CHANGE,
		BindTool.Bind(self.MainRoleLevelChange, self))
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE,
		BindTool.Bind(self.DayCountChange, self))
	self:BindGlobalEvent(OtherEventType.VIRTUAL_TASK_CHANGE,
		BindTool.Bind(self.VirtualTaskChange, self))
	self:BindGlobalEvent(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))

	self.remind_change = BindTool.Bind(self.VirtualTaskChange, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MoLongMiBao)

	self.player_data_listen = BindTool.Bind(self.PlayerDataListen, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_listen)

	self.delay_sort_task_fun = BindTool.Bind(self.DelaySortTask, self)
	self.last_move_time = 0
	self.auto_zhu_task = true		-- 自动做主线

	-- 初始化
	self:OnTaskChange()

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.get_ui_callback)
	self.move_cell = self:FindObj("MoveCell")
	self.cur_move = self.move_cell:GetComponent(typeof(CurveMove))
	self.item_state = self:FindVariable("Item_state")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.move_cell)
	self.move_cell:SetActive(false)
	-- 修复每日必做消失的bug(暂时没有找到原因，使用的是update检测的办法)
	self:FixDailyBug()
end

function MainUIViewTask:SetTime(time)
	self.time:SetValue(time)
end

function MainUIViewTask:__delete()
	self.item_cell:DeleteMe()

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if nil ~= self.delay_sort_task_timer then
		GlobalTimerQuest:CancelQuest(self.delay_sort_task_timer)
		self.delay_sort_task_timer = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.get_ui_callback)
	end
	self.effect_flag_cfg = nil
	self:RemoveDailyBugCountDown()

	if self.player_data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_listen)
		self.player_data_listen = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewTask:SetAutoTaskState(state)
	if not state and self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	self.auto_zhu_task = state

	if state then
		if PlayerData.Instance:GetRoleVo().level <= 170  -- 131级前恢复时才自动做任务
			and self:IsCanAutoExecuteTask() then
			self:AutoExecuteTask()
		end
	else
		if GuajiCache.guaji_type ~= GuajiType.Auto then
			GuajiCtrl.Instance:StopGuaji()
		end
	end
end

function MainUIViewTask:IsPauseAutoTask()
	return not self.auto_zhu_task
end

function MainUIViewTask:ShowGuideArrow()
	if not MainUIViewTask.SHOW_GUIDE_ARROW then
		self.guide_arrow:SetActive(true)
		MainUIViewTask.SHOW_GUIDE_ARROW  = true
	end
end

--设置按钮是否可见
function MainUIViewTask:ReSetBtnVisible()
	local position = self.task_list.scroller.ScrollPosition
	local disable_height = self.task_list.scroller.ScrollSize						--listview不可见的画布长度
	self.show_down_arrow:SetValue(position < disable_height)
end

--滚动条刷新
function MainUIViewTask:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]

	if cell == nil then
		self.cell_list[cell_view] = MainUIViewTaskInfo.New(cell_view)
		cell = self.cell_list[cell_view]
		cell.sell_view = self
		self.toggles[data_index] = cell.root_node:GetComponent("Toggle")
		cell:SetHandle(self)
		cell:ListenClick(self)
		cell:ListenQuickDone(self)
		cell:SetToggle(self.toggle_group)
	end
	local data = self.task_data[data_index + 1]
	cell.root_node.toggle.isOn = data and CUR_TASK == data.task_id
	cell:SetIndex(data_index + 1)
	cell:SetData(data)
	return cell_view
end

function MainUIViewTask:RefrechCell(task_id)
	local task_data = nil
	for _, v in ipairs(self.task_data) do
		if v.task_id == task_id then
			task_data = v
			break
		end
	end

	if nil == task_data then
		return
	end

	for _, v in pairs(self.cell_list) do
		if v:GetTaskId() == task_id then
			v:SetData(task_data)
			break
		end
	end
end

function MainUIViewTask:GetCellSize(data_index)
	local data = self.task_data[data_index + 1]
	if nil == data then
		return 0
	end
	-- local config = TaskData.Instance:GetTaskConfig(data.task_id)
	-- if config then
	-- 	if config.task_type == TASK_TYPE.RI or config.task_type == TASK_TYPE.GUILD then
	-- 		return 102
	-- 	end
	-- end
	return 75
end

function MainUIViewTask:OnTaskChange(task_event_type, task_id)
	if Scene.Instance:GetSceneId() == 1130 then
		--皇陵探险中不需要这个功能
		return
	end
	if task_event_type == "completed_add" then
		self.last_task_id = task_id
	end

	-- 是否是任务数量型的变化
	local is_num_change_reason = "accepted_update" == task_event_type and not TaskData.Instance:GetTaskIsCanCommint(task_id)

	-- 新手的章节任务
	local chapter_cfg = TaskData.Instance:GetCurrentChapterCfg()
	if nil ~= chapter_cfg then
		self:RefreshChapterTask(chapter_cfg)
	else
		-- 普通任务
		-- if "accepted_update" == task_event_type and not TaskData.Instance:GetTaskIsCanCommint(task_id) then
		-- 	self:RefrechCell(task_id)
		-- else
		--	self:SortTask()
		-- end

		-- 策划反馈有时任务不刷新，先不优化成针对性刷新，而是直接刷新整个list
		self:SortTask()
	end

	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	local auto_if_no_guaji = task_event_type == "accepted_update" and true or false
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHU and self:IsCanAutoExecuteTask(auto_if_no_guaji) then
		self:AutoExecuteTask()
	end

	if task_cfg and ((task_cfg.task_type == TASK_TYPE.HUAN and TASK_HUAN_AUTO) or (task_cfg.task_type == TASK_TYPE.WEEK_HUAN and TASK_WEEK_HUAN_AUTO)) then
		self:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
	end
end

function MainUIViewTask:MainRoleLevelChange()
	self:SortTask()
end

function MainUIViewTask:IsCanAutoExecuteTask(auto_if_no_guaji)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.Common then
			if GuajiCache.guaji_type ~= GuajiType.Auto and (GuajiCache.guaji_type ~= GuajiType.None or auto_if_no_guaji) and self.auto_zhu_task then
				return true
			end
		end
	end
	return false
end

function MainUIViewTask:AutoExecuteTask()
	if not self.auto_zhu_task then return end
	local task_id = TaskData.Instance:GetCurTaskId()
	if not task_id or task_id == 0 then
		if TASK_GUILD_AUTO then
			if TaskData.Instance:GetGuildTaskInfo().task_id then
				task_id = TaskData.Instance:GetGuildTaskInfo().task_id
			end
		elseif TASK_RI_AUTO then
			if TaskData.Instance:GetDailyTaskInfo() then
				task_id = TaskData.Instance:GetDailyTaskInfo().task_id
			end
		elseif TASK_HUAN_AUTO then
			if TaskData.Instance:GetPaohuanTaskInfo() then
				task_id = TaskData.Instance:GetPaohuanTaskInfo().task_id
			end
		elseif TASK_WEEK_HUAN_AUTO then
			if TaskData.Instance:GetWeekPaohuanTaskInfo() then
				task_id = TaskData.Instance:GetWeekPaohuanTaskInfo().task_id
			end
		elseif TaskData.Instance:GetNextZhuTaskConfig() then
			task_id = TaskData.Instance:GetNextZhuTaskConfig().task_id
		end
	end
	if task_id and task_id ~= 0 then
		if TASK_RI_AUTO or TASK_HUAN_AUTO or TASK_WEEK_HUAN_AUTO then
			self.last_task_id = task_id
			local state = TaskData.Instance:GetTaskStatus(task_id)
			if state == TASK_STATUS.COMMIT then
				self:DoTask(task_id, state)
			else
				self:DoTask(task_id, TASK_STATUS.ACCEPT_PROCESS)
			end
		else
			self.last_task_id = task_id
			self:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
		end
	else
		GuajiCtrl.Instance:ClearTaskOperate()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
end

function MainUIViewTask:ClearToggle()
	self.toggle_group:SetAllTogglesOff()
	CUR_TASK = 0
end

--继续护送任务
function MainUIViewTask:ClickGo()
	TaskData.Instance:GoOnHuSong()
end

function MainUIViewTask:OnTaskCellClick(data)
	CUR_TASK = data.task_id
	if data.task_id == -1 then --加入公会任务提示框
		ViewManager.Instance:Open(ViewName.Guild)
		return
	end
	if nil == data then
		print_warning("配置表为空")
		return
	end
	if not Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		print_warning("CantDoMove")
		self:ClearToggle()
		return
	end
	if TaskData.IsZhiTask(data) and data.task_status == TASK_STATUS.COMMIT and self.package_btn then
		if self.count_down == nil then
			self:RewardFlyToBag(data)
			self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self))
		end
		return
	end

	for k,v in pairs(self.cell_list) do
		if v:IsShowArrowEff() then
			v:SetShowArrowEff(false)
			if v.data and v.data.task_type == TASK_TYPE.ZHU then
				CAN_SHOW_ZHU_ARROW = false
			elseif v.data and v.data.task_type == TASK_TYPE.GUILD then
				CAN_SHOW_GUILD_ARROW = false
			else
				CAN_SHOW_ZHI_ARROW = false
			end
		end
	end

	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	if config then
		local role_level = PlayerData.Instance:GetRoleVo().level
		if config.min_level > role_level then -- 如果等级没打达到
			self:ClearToggle()
			if role_level % 100 == 0 then
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_reincarnation)
			else
				-- ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
				-- if OpenFunData.Instance:CheckIsHide("runetowerview") then
				-- 	ViewManager.Instance:Open(ViewName.RuneTowerView)
				-- else
				-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Task.TaskLevelLimit, PlayerData.GetLevelString(config.min_level, true)))
				-- end
				ViewManager.Instance:Open(ViewName.YewaiGuajiView)
			end
			return
		end
		if config.task_type == TASK_TYPE.GUILD then
			TASK_GUILD_AUTO = true
		else
			TASK_GUILD_AUTO = false
		end
		if config.task_type == TASK_TYPE.RI then
			TASK_RI_AUTO = true
		else
			TASK_RI_AUTO = false
		end
		if config.task_type == TASK_TYPE.HUAN then
			TASK_HUAN_AUTO = true
		else
			TASK_HUAN_AUTO = false
		end
		if config.task_type == TASK_TYPE.WEEK_HUAN then
			TASK_WEEK_HUAN_AUTO = true
		else
			TASK_WEEK_HUAN_AUTO = false
		end
	end
	--更新选中状态
	self:OperateTask(data)
end

function MainUIViewTask:OnClickQuickDone(data)
	if nil == data then
		return
	end
	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	local price = 0
	local count = 0
	if config then
		price = TaskData.Instance:GetQuickPrice(config.task_type)
		count = TaskData.Instance:GetTaskCount(tonumber(config.task_type))
	end
	if config.task_type == TASK_TYPE.RI and VipPower.Instance:GetParam(VipPowerId.key_dialy_task) < 1 then
		local limit_level = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.key_dialy_task) or 0
		-- SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Daily.ChengWeiVIP, limit_level))
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.KEY_DIALY_TASK)
		return
	end
	local describe = string.format(Language.Daily.YiJianRenWu, ToColorStr(tostring(price * count), TEXT_COLOR.BLUE_4))
	describe = string.format(describe, price * count)
	-- TipsCtrl.Instance:ShowTwoOptionView(describe, yes_func, nil, "确定", "取消")

	local call_back = function ()
		local gold = PlayerData.Instance:GetRoleVo().gold + PlayerData.Instance:GetRoleVo().bind_gold
		if gold < price * count then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "one_key", data)
	end
	local red_text = Language.Task.DoubleReward
	if config.task_type ~= TASK_TYPE.RI then
		red_text = config.task_type == TASK_TYPE.GUILD and Language.Task.YouXianBindGold or ""
	end

	if config.task_type == TASK_TYPE.HUAN then
		local call_back_two = function ()
			-- TaskCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_PAOHUAN_TASK, -1)
			GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "one_key", data)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back_two, nil, true, nil, nil, red_text)
		return
	end
	if config.task_type == TASK_TYPE.RI then
		describe = describe .. Language.Daily.YiJianRenWu_2
	end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back, nil, true, nil, nil, red_text)
end

function MainUIViewTask:SendQuickDone(task_type, task_id)
	TaskCtrl.Instance:SendQuickDone(task_type, task_id)
end

function MainUIViewTask:OperateTask(data)
	TaskData.Instance:SetCurTaskId(data.task_id)
	self:DoTask(data.task_id, data.task_status, true)
end

--任务排序(各种原因引起的任务变化可能短时间内来好几个，延迟一点时间)
function MainUIViewTask:SortTask()
	if nil ~= self.delay_sort_task_timer then
		return
	end

	self.delay_sort_task_timer = GlobalTimerQuest:AddDelayTimer(self.delay_sort_task_fun, 0.5)
end

local old_can_commit_num = 0
function MainUIViewTask:DelaySortTask()
	self.delay_sort_task_timer = nil

	self.task_data = {}
	local task_cfg = nil
	local task_accepted_info_list = TaskData.Instance:GetTaskAcceptedInfoList()
	local task_can_accept_id_list = TaskData.Instance:GetTaskCapAcceptedIdList()

	--主线任务
	local zhu_task_list = TaskData.Instance:GetTaskListIdByType(TASK_TYPE.ZHU)
	local zhu_task_cfg = TaskData.Instance:GetTaskConfig(zhu_task_list[1])

	--若服务端没发来则自己取下一个主线任务
	if zhu_task_cfg == nil then
		zhu_task_cfg = TaskData.Instance:GetNextZhuTaskConfig()
	end

	-- 没主线任务则出现挂机虚拟任务
	local virtual_guaji_task_cfg = nil
	if nil == zhu_task_cfg then
		virtual_guaji_task_cfg = TaskData.Instance:GetVirtualGuajiTask()
	end

	local virtual_xiulian_task_cfg = nil
	local max_chapter = PersonalGoalsData.Instance:GetMaxChapter()
	local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	if OpenFunData.Instance:CheckIsHide("mieshizhizhan") and cur_chapter < max_chapter then
		virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualXiuLianTask()
	end

	if self:CheckIsShowDailyTask() then
		virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualDaliyTask()
	end

	local virtual_begod_task_cfg = nil
	-- if OpenFunData.Instance:CheckIsHide("molongmibaoview") and MolongMibaoData.Instance:IsShowMolongMibao() then
	-- 	virtual_begod_task_cfg = TaskData.Instance:GetVirtualBeGodTask()
	-- end

	local virtual_wabao_task_cfg = nil
	if WaBaoData.Instance:GetIsShowWaBao() then
		virtual_wabao_task_cfg = WaBaoData.Instance:GetVirtualWaBaoTask()
	end

	local virtual_guajiboss_task_cfg = nil
	if YewaiGuajiData.Instance:IsShowGuaJiBossTask() then
		virtual_guajiboss_task_cfg = TaskData.Instance:GetVirtualGuaJiBossTask()
	end

	local virtual_ling_task_cfg = nil
	if GameVoManager.Instance:GetMainRoleVo().level >= JingHuaHuSongData.Instance:GetRemindLevel() then 	--等级足够才显示精华护送任务
		if not JingHuaHuSongData.Instance:IsAllCommit() and (JingHuaHuSongCtrl.Instance:IsOpen() or JingHuaHuSongCtrl.Instance:HaveJingHuaInScene()) then
			virtual_ling_task_cfg = TaskData.Instance:GetVirtualLingTask()
		end
	end

	HAS_HUG_TASK = false
	--可提交
	local can_commit_list = {}
	for k,v in pairs(task_accepted_info_list) do
		if v.is_complete ~= 0 then
			task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
			if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
				can_commit_list[#can_commit_list + 1] = task_cfg
			end
			if task_cfg and task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then
				HAS_HUG_TASK = true
			end
		end
	end

	local order_list = {}
	--进行中
	for k,v in pairs(task_accepted_info_list) do
		if v.is_complete == 0 then
			task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
			if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
				order_list[#order_list + 1] = task_cfg
			end
			if task_cfg and task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then
				HAS_HUG_TASK = true
			end
		end
	end
	-- 可接
	-- 手动加入护送任务
	task_can_accept_id_list[YunbiaoData.Instance.task_ids] = nil
	local max_count = YunbiaoData.Instance:GetHusongRemainTimes() or 0
	-- local commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
	if max_count > 0 then
		local yunbiao_task_cfg = TaskData.Instance:GetTaskConfig(YunbiaoData.Instance.task_ids)
		if yunbiao_task_cfg then
			if yunbiao_task_cfg.min_level <= GameVoManager.Instance:GetMainRoleVo().level then
				if not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids) then
					task_can_accept_id_list[YunbiaoData.Instance.task_ids] = 1
				end
			end
		end
	end

	for k,v in pairs(task_can_accept_id_list) do
		task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
			order_list[#order_list + 1] = task_cfg
		end
	end

	if virtual_ling_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_ling_task_cfg
	end

	if virtual_guajiboss_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_guajiboss_task_cfg
	end

	if virtual_xiulian_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_xiulian_task_cfg
	end

	if virtual_wabao_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_wabao_task_cfg
	end

	if virtual_begod_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_begod_task_cfg
	end

	if virtual_guaji_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_guaji_task_cfg
	end

	--对可提交进行排序
	if #can_commit_list ~= 0 then
		table.sort(can_commit_list, function(a, b) return self:GetSortIndexByConfig(a) < self:GetSortIndexByConfig(b) end)
	end

	--对其他进行排序order_list
	if #order_list ~= 0 then
		table.sort(order_list, function(a, b) return self:GetSortIndexByConfig(a) < self:GetSortIndexByConfig(b) end)
	end

	--合并连接(主线，可提交，其他)
	--主线任务放最前
	if zhu_task_cfg ~= nil then
		local task_id = zhu_task_cfg.task_id
		local task_status = TaskData.Instance:GetTaskStatus(task_id)
		local progress_num
		local task_info = TaskData.Instance:GetTaskInfo(task_id)
		if task_info then
			progress_num = task_info.progress_num
		end
		if TaskData.Instance:GetCurTaskId() and TaskData.Instance:GetCurTaskId() == 0 and (not TASK_GUILD_AUTO or not TASK_RI_AUTO) then
			if self.last_task_id then
				local config = TaskData.Instance:GetTaskConfig(self.last_task_id)
				if config then
					if config.task_type == TASK_TYPE.ZHU then
						TaskData.Instance:SetCurTaskId(task_id)
					end
				end
			end
		end

		self.task_data[1] = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
	end


	local min_zhi_task_id = 99999
	local old_has_guild_task = HAS_GUILD_TASK

	HAS_RI_TASK = false

	local can_commit_num = 0
	for k,v in pairs(can_commit_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		elseif v.task_type == TASK_TYPE.GUILD then
			HAS_GUILD_TASK = true
		else
			can_commit_num = can_commit_num + 1
		end
	end

	for k,v in pairs(order_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		end
		if v.task_type == TASK_TYPE.GUILD then
			HAS_GUILD_TASK = true
		end
	end

	HAS_GUILD_TASK = not HAS_RI_TASK and HAS_GUILD_TASK

	if old_has_guild_task == false and HAS_GUILD_TASK then
		CAN_SHOW_GUILD_ARROW = true
	end

	-- if CUR_ZHI_TASK ~= 99999 and CUR_ZHI_TASK ~= min_zhi_task_id and self.package_btn then
	-- 	self:RewardFlyToBag()
	-- end
	local old_zhi_task = CUR_ZHI_TASK
	if min_zhi_task_id ~= 99999 then
		CUR_ZHI_TASK = min_zhi_task_id
		local config = TaskData.Instance:GetTaskConfig(CUR_ZHI_TASK)
		local reward_list = config["prof_list" .. GameVoManager.Instance:GetMainRoleVo().prof]
		self.item_cell:SetData(reward_list[0])
		self.item_state:SetValue(false)
	end
	if min_zhi_task_id == 99999 then
		CUR_ZHI_TASK = min_zhi_task_id
	end

	if old_zhi_task ~= CUR_ZHI_TASK then
		CAN_SHOW_ZHI_ARROW = true
	end
	HAS_ZHI_TASK = min_zhi_task_id ~= 99999

	for k,v in ipairs(can_commit_list) do
		local task_id = v.task_id
		local task_status = TASK_STATUS.COMMIT
		local progress_num = TaskData.Instance:GetTaskInfo(task_id).progress_num
		if (v.task_id == min_zhi_task_id and TaskData.IsZhiTask(v)) or not TaskData.IsZhiTask(v) then
			if not HAS_RI_TASK or v.task_type ~= TASK_TYPE.GUILD then
				self.task_data[#self.task_data + 1] = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
			end
		end
	end

	for k,v in ipairs(order_list) do
		local task_id = v.task_id
		local task_status = TaskData.Instance:GetTaskStatus(v.task_id)
		local progress_num
		local info = TaskData.Instance:GetTaskInfo(task_id)
		if info then
			progress_num = info.progress_num
		end
		if v.task_type == TASK_TYPE.LINK or v.task_type == TASK_TYPE.DALIY or v.task_type == TASK_TYPE.LING or v.task_type == TASK_TYPE.GUAJIBOSS then
			self.task_data[#self.task_data + 1] = v
		elseif (v.task_id == min_zhi_task_id and TaskData.IsZhiTask(v)) or not TaskData.IsZhiTask(v) then
			if not HAS_RI_TASK or v.task_type ~= TASK_TYPE.GUILD then
				self.task_data[#self.task_data + 1] = MainUIViewTask.TaskCellInfo(v.task_id, task_status, progress_num)
			end
		end
	end

	self:SortTaskToFirst()
	if self.is_load and nil == TaskData.Instance:GetCurrentChapterCfg() then
		self.normal_task:SetActive(true)
		self.chapter_task:SetActive(false)
		self.show_chapter_txt:SetValue(false)
		if old_can_commit_num < can_commit_num then --可提交数量有变时跳到最上面
			self.task_list.scroller:ReloadData(0)
		else
			self.task_list.scroller:RefreshAndReloadActiveCellViews(true)
		end
		old_can_commit_num = can_commit_num
	end
end

function MainUIViewTask:RewardFlyToBag(data)
	if self.is_move == true then return end
	self.move_cell:SetActive(true)
	if not IsNil(self.item_cell.root_node.gameObject) then
		self.item_cell.root_node.rect.sizeDelta = Vector2(67, 67)
	end

	local UILayer = GameObject.Find("GameRoot/UILayer")

	local old_parent = self.move_cell.transform.parent
	local old_pos = self.move_cell.transform.localPosition
	self.move_cell.transform:SetParent(UILayer.transform, true)

	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.package_btn.transform.position)

	--转换屏幕坐标为本地坐标
	local rect = UILayer:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

	local target_pos = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)

	local close_view = function()
		self.move_cell.transform:SetParent(old_parent.transform, false)
		self.move_cell.transform.localPosition = old_pos
		self.move_cell:SetActive(false)
		self.is_move = false
		-- ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZHIXIAN_TASK_REWARD)
		self:OperateTask(data)
	end
	self.is_move = true
	self.cur_move:MoveTo(target_pos, 1.2, close_view)
end

-- 倒计时函数
function MainUIViewTask:CountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewTask:SetPackage(package_btn)
	self.package_btn = package_btn
end

function MainUIViewTask:RefreshChapterTask(chapter_cfg)
	if nil == chapter_cfg then
		return
	end

	self.normal_task:SetActive(false)
	self.chapter_task:SetActive(true)
	self.show_chapter_txt:SetValue(true)

	local task_cfg = TaskData.Instance:GetZhuTaskConfig()
	local end_task_cfg = TaskData.Instance:GetTaskConfig(chapter_cfg.end_taskid)

	if nil == task_cfg or nil == end_task_cfg or "" == task_cfg.now_index then
		return
	end

	self.chapter_name:SetValue(chapter_cfg.name)
	self.chapter_step_bar_txt:SetValue(CommonDataManager.GetDaXie(chapter_cfg.zhangjie))
	self.task_desc:SetValue(task_cfg.task_desc)

	local percent = (task_cfg.now_index - 1) / end_task_cfg.now_index
	self.chapter_progress:SetValue(percent)
	self.chapter_progress_txt:SetValue(math.floor(percent * 100) .. "%")

	local state = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
	if TASK_STATUS.CAN_ACCEPT == state or TASK_STATUS.NONE == state then
		self.task_condition:SetValue(task_cfg.accept_desc)
		self.task_button_txt:SetValue(Language.Task.task_status[1])

	elseif TASK_STATUS.ACCEPT_PROCESS == state then
		self.task_button_txt:SetValue(Language.Task.task_status[2])

		if(task_cfg.c_param2 == 0) then
			self.task_condition:SetValue(task_cfg.progress_desc)
		else
			local current_count = TaskData.Instance:GetProgressNum(task_cfg.task_id)
			self.task_condition:SetValue(MainUIViewTask.ChangeTaskProgressString(task_cfg.progress_desc, current_count, task_cfg.c_param2))
		end

	elseif TASK_STATUS.COMMIT == state then
		self.task_button_txt:SetValue(Language.Task.task_status[3])
		self.task_condition:SetValue(task_cfg.commit_desc)

	else
		self.task_condition:SetValue("error")
	end
end

function MainUIViewTask:OnTouchChapterTask()
	local task_cfg = TaskData.Instance:GetZhuTaskConfig()
	if nil == task_cfg then
		return
	end

	local task_status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
	self:OperateTask(MainUIViewTask.TaskCellInfo(task_cfg.task_id, task_status, 0))
end

-- 改变任务进程的字符串
local color = "#ffffff"
function MainUIViewTask.ChangeTaskProgressString(old_string, current_count, total_count)
	color = current_count < total_count and TEXT_COLOR.RED or TEXT_COLOR.GREEN
	old_string = string.gsub(old_string, "<per>1", "<color=" .. color .. ">" ..current_count)
	old_string = string.gsub(old_string, "10</per>", total_count .. "</color>")
	return old_string
end


--把转职任务放在第一位
function MainUIViewTask:SortTaskToFirst()
	local zhu_task_data = nil
	if self.task_data[1] and self.task_data[1].task_type == TASK_TYPE.ZHU then
		local config = TaskData.Instance:GetTaskConfig(self.task_data[1].task_id)
		local role_level = PlayerData.Instance:GetRoleVo().level
		if role_level % 100 ~= 0 and config and config.min_level > role_level then
			zhu_task_data = self.task_data[1]
			table.remove(self.task_data, 1)
			if TaskData.Instance:GetTaskCount(TASK_TYPE.RI) > 0 then
				CAN_SHOW_ZHU_ARROW = true
			end
		end
	end

	local zhi_key = nil
	local zhi_task_cfg = nil
	for k, v in pairs(self.task_data) do
		if TaskData.IsZhiTask(v) then
			zhi_key = k
			zhi_task_cfg = v
			break
		end
	end

	if nil ~= zhi_key and nil ~= zhi_task_cfg then
		table.remove(self.task_data, zhi_key)
		table.insert(self.task_data, 1, zhi_task_cfg)
	end

	local daily_virtual_key = nil
	if zhu_task_data then
		for k, v in ipairs(self.task_data) do
			if v.task_type == TASK_TYPE.RI or
				v.task_type == TASK_TYPE.GUILD or
				v.task_type == TASK_TYPE.LINK or
				v.task_type == TASK_TYPE.HUAN or
				v.task_type == TASK_TYPE.DALIY then
				if daily_virtual_key == nil or daily_virtual_key < k then
					daily_virtual_key = k
				end
			end
		end
	end

	if zhu_task_data then
		local index = 0
		if daily_virtual_key then
			index = math.min(daily_virtual_key + 1, #self.task_data + 1)
		else
			index = math.min(2, #self.task_data + 1)
		end
		table.insert(self.task_data, index, zhu_task_data)
	end

	--功能开启,如果未加入公会则增加加入公会一列
	if not HAS_RI_TASK and OpenFunData.Instance:CheckIsHide("guild_task") then
		if GameVoManager.Instance:GetMainRoleVo().guild_id == 0 then
			local data = {}
			data.task_id = -1
			table.insert(self.task_data, data)
		end
	end
end

--为任务增加排序索引，勿模防,
--主线、日常、仙盟、护送、支线
function MainUIViewTask:GetSortIndexByConfig(task_cfg)
	if task_cfg and task_cfg.order_index == nil then
		if task_cfg.task_type == TASK_TYPE.ZHU then     	--主线
			return 1000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.ZHI then  	--支线
			return 6000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.RI then   	--日常
			return 4000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.GUILD then  	--仙盟
			return 5000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.LING then  	--精华护送
			return 9000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.GUAJIBOSS then 	--挂机BOSS
			return 10010000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HU then 		--护送
			return 10000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.CAMP then 	--阵营
			return 2000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HUAN then 	--跑环
			return 8000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.WEEK_HUAN then 	--周常
			return 8100000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.LINK then 	--打开面板
			if task_cfg.task_id == 999996 then
				return 10100000 + task_cfg.task_id 			-- 挂机任务放在最后
			else
				return 7000000 + task_cfg.task_id
			end

		else
			return 0
		end
	end
	return 0
end

-- 停止任务
function MainUIViewTask:StopTask()
	GuajiCtrl.Instance:StopGuaji()
end

-- 执行任务
function MainUIViewTask:DoTask(task_id, task_status, is_active)
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end

	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if nil == task_cfg then
		task_cfg = TaskData.Instance:GetVirtualTaskCfg(task_id)
	end

	if nil == task_cfg then
		return
	end
	CUR_TASK = task_id

	if task_cfg.task_type == TASK_TYPE.LINK then
		ViewManager.Instance:Open(task_cfg.open_panel_name)
		return
	end
	if task_cfg.task_type == TASK_TYPE.LING then
		if JingHuaHuSongData.Instance:GetMainRoleState() == JH_HUSONG_STATUS.NONE then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.JINGHUA_HUSONG)
		else
			JingHuaHuSongCtrl.Instance:ContinueJingHuaHuSong() --进行精华护送
		end
		return
	end

	if task_cfg.task_type == TASK_TYPE.GUAJIBOSS then
		ViewManager.Instance:Open(task_cfg.open_panel_name)
		return
	end

	if task_cfg.task_type == TASK_TYPE.DALIY then
		local daily_data = ZhiBaoData.Instance:GetFirstTask()
		if daily_data then
			if ZhiBaoData.Instance:GetActiveDegreeListByIndex(daily_data.type) >= daily_data.max_times then
				ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
			else
				ActiveDegreeScrollCell.OnGoClick(daily_data)
			end
		else
			ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
		end
		return
	end

	TaskData.Instance:SetCurTaskId(task_id)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if nil == task_cfg then
		print_warning("cfg为空")
		return
	end

	if task_cfg.task_type == TASK_TYPE.ZHU then
		self.guide_arrow:SetActive(false)
		MainUIViewTask.SHOW_GUIDE_ARROW = false
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	if task_cfg.min_level > level then
		-- 做个整百的时候处理打开转生面板
		if level % 100 == 0 or TASK_STATUS.CAN_ACCEPT == task_status then
			if GuajiCache.guaji_type == GuajiType.HalfAuto then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			end
			if level % 100 == 0 then
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_reincarnation)
			end
		end
		return
	end

	local mainr_role = Scene.Instance:GetMainRole()

	if self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	if task_status == TASK_STATUS.CAN_ACCEPT and task_cfg.task_type ~= TASK_TYPE.GUILD then
		-- 护送任务无视vip等级传送
		if task_cfg.task_type == TASK_TYPE.HU then
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
		end
	elseif task_status == TASK_STATUS.ACCEPT_PROCESS or (task_cfg.task_type == TASK_TYPE.GUILD and task_status == TASK_STATUS.CAN_ACCEPT) then
		-- 功能开启副本
		if StoryCtrl.Instance:GetFunOpenFbTypeByTaskId(task_id) > 0 then
			local cfg = StoryCtrl.Instance:GetFbCfg(task_id)
		 	if next(cfg) then
		 		-- 移动到传送门
		 		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
				MoveCache.end_type = MoveEndType.DoNothing
				GuajiCtrl.Instance:MoveToPos(cfg.door_scene_id, cfg.door_x, cfg.door_y, 2, 0)
			end
			return
		end

		if TASK_ACCEPT_OP.ENTER_FB == task_cfg.accept_op and "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then  -- 进入副本
			FuBenCtrl.Instance:SendEnterFBReq(task_cfg.a_param1, task_cfg.a_param2)
			return
		end

		if TASK_ACCEPT_OP.OPEN_GUIDE_FB_ENTRANCE == task_cfg.accept_op then -- 进入引导副本
			StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, task_id)
			return
		end

		if TASK_ACCEPT_OP.OPEN_GUIDE_FB_ENTRANCE == task_cfg.accept_op then -- 进入引导副本
			StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, task_id)
			return
		end

		if TASK_ACCEPT_OP.ENTER_DAILY_TASKFB == task_cfg.accept_op then -- 进入日常任务副本
			self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
			return
		end

		if task_cfg.open_panel_name ~= "" then
			local open_param_t = Split(task_cfg.open_panel_name, "#")
			if open_param_t and open_param_t[1] then
				local index = open_param_t[2] and TabIndex[open_param_t[2]]
				if open_param_t[1]  == ViewName.SpiritView and nil ~= open_param_t[3] then
					SpiritData.Instance:SetOpenParam(open_param_t[3])
				end
				ViewManager.Instance:Open(open_param_t[1], index)
				GuajiCtrl.Instance:PlayerOperation()
				-- self:StopTask()
			end
			return
		end

		if type(task_cfg.target_obj) ~= "table" then
			self:ClearToggle()
			SysMsgCtrl.Instance:ErrorRemind("任务表配置的target_obj是null")
			return
		end
		local first_target = task_cfg.target_obj[1]
		if nil == first_target and task_cfg.condition ~= TASK_COMPLETE_CONDITION.HUG then
			return
		end

		if task_cfg.condition == TASK_COMPLETE_CONDITION.NPC_TALK then			-- 与npc对话任务
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			if task_cfg.accept_op ~= 2 or (task_cfg.commit_npc and task_cfg.commit_npc.scene == Scene.Instance:GetSceneId()) then
				self:MoveToTarget(first_target, MoveEndType.NpcTask, task_id, is_active)
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, first_target, MoveEndType.NpcTask, task_id), 0.5)
			end

		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then			-- 抱东西
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			local list = {}
			local move_end_type = nil
			if task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.GATHER then
				list = ConfigManager.Instance:GetSceneConfig(task_cfg.c_param3).gathers or {}
				move_end_type = MoveEndType.GatherById
			elseif task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
				list = ConfigManager.Instance:GetSceneConfig(task_cfg.c_param3).npcs or {}
				move_end_type = MoveEndType.NpcTask
			end
			local target = {}
			for k,v in pairs(list) do
				if v.id == task_cfg.c_param2 then
					target.id = v.id
					target.scene = task_cfg.c_param3
					target.x = v.x
					target.y = v.y
				end
			end
			if next(target) then
				if task_cfg.c_param3 == Scene.Instance:GetSceneId() then
					self:MoveToTarget(target, move_end_type, task_id, is_active)
				else
					self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, target, move_end_type, task_id), 0.5)
				end
			end
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then	-- 打怪任务
			if GuajiCache.guaji_type == GuajiType.Monster and GuajiCache.monster_id == first_target.id and not is_active then
				return
			end
			local target = Scene.Instance:SelectMinDisMonster(task_cfg.target_obj[1].id, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
			if target then
				local x, y = target:GetLogicPos()
				target = {scene = Scene.Instance:GetSceneId(), x = x, y = y, id = task_cfg.target_obj[1].id}
			else
				target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
			end

			GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
			GuajiCache.monster_id = target.id

			self:MoveToTarget(target, MoveEndType.FightByMonsterId, task_id, is_active)
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.GATHER then		-- 采集任务
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			local target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
			self:MoveToTarget(target, MoveEndType.GatherById, task_id, is_active)
		end
	elseif task_status == TASK_STATUS.COMMIT then
		if task_cfg.task_type == TASK_TYPE.RI and task_cfg.condition ~= TASK_COMPLETE_CONDITION.HUG then
			TaskCtrl.SendTaskCommit(task_id)
			-- ViewManager.Instance:OpenViewByName(ViewName.Daily, TabIndex.daily_renwu)
		elseif task_cfg.commit_npc == "" or task_cfg.commit_npc == 0 or nil == task_cfg.commit_npc.scene then		-- 没配npc直接完成
			TaskCtrl.SendTaskCommit(task_id)
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			if task_cfg.accept_op ~= 2 or (task_cfg.commit_npc and task_cfg.commit_npc.scene == Scene.Instance:GetSceneId()) then
				-- if mainr_role and mainr_role:IsAtk() then
				-- 	mainr_role:ChangeToCommonState()
				-- 	if not self.delay_dotask_timer then
				-- 		local func = function()
				-- 			self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
				-- 			if self.delay_dotask_timer then
				-- 				GlobalTimerQuest:CancelQuest(self.delay_dotask_timer)
				-- 				self.delay_dotask_timer = nil
				-- 			end
				-- 		end
				-- 		self.delay_dotask_timer = GlobalTimerQuest:AddDelayTimer(func, 2)
				-- 	end
				-- else
					self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
				-- end
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active), 0.5)
			end
		end
	end
end

function MainUIViewTask:MoveToTarget(target, end_type, task_id, is_active)
	if is_active then
		local main_role = Scene.Instance:GetMainRole()
		if main_role and main_role:IsMove()
			and (MoveCache.end_type == end_type or (MoveCache.end_type == MoveEndType.ClickNpc and end_type == MoveEndType.NpcTask))
			and MoveCache.task_id == task_id then
			return
		end
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() ~= SceneType.Common then
			self:ClearToggle()
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end
	end

	if nil ~= target and type(target) == "table" then
		GuajiCtrl.Instance:ClearAllOperate()
		GuajiCtrl.Instance:CancelSelect()
		MoveCache.end_type = end_type
		MoveCache.param1 = target.id
		MoveCache.task_id = task_id
		GuajiCache.target_obj_id = target.id
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		KuafuGuildBattleCtrl.Instance:CSReqMonsterGeneraterList(target.scene)
		GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 2, false, scene_key)
	end
end

-- 构造任务数据
function MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	return {
		task_id = task_id,
		task_name = task_cfg and task_cfg.task_name or "",
		task_type = task_cfg and task_cfg.task_type or 0,
		task_status = task_status,
		progress_num = progress_num,
	}
end

function MainUIViewTask:DayCountChange(day_counter_id)
	-- 护送完成次数
	if DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT == day_counter_id or day_counter_id == -1 then
		self:SortTask()
	end
end

function MainUIViewTask:VirtualTaskChange()
	self:SortTask()
end

function MainUIViewTask:GetUiCallBack(ui_name)
	if ui_name == GuideUIName.TaskDailyItem or ui_name == GuideUIName.TaskZhiItem then
		for _, v in pairs(self.cell_list) do
			local task_data = v:GetData() or {}
			if task_data.task_type == TASK_TYPE.RI or task_data.task_type == TASK_TYPE.ZHI then
				if v.root_node.transform.gameObject.activeInHierarchy then
					return v.root_node
				end
			end
		end
	end
	return nil
end

function MainUIViewTask:SetStartPosition()
	if nil == self.start_obj or IsNil(self.start_obj.gameObject) then
		return
	end
	local obj_rect = self.start_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, obj_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

	self.start_position = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
end

function MainUIViewTask:CheckIsShowDailyTask()
	if OpenFunData.Instance:CheckIsHide("daily") and ZhiBaoData.Instance:GetFirstTask() and TaskData.Instance:GetTaskCount(TASK_TYPE.RI) <= 0 then
		return true
	else
		return false
	end
end

-- 修复每日必做消失的bug
--（暂时没有找到原因）
function MainUIViewTask:FixDailyBug()
	self:RemoveDailyBugCountDown()
	self.daily_bug_count_down = CountDown.Instance:AddCountDown(60, 2, BindTool.Bind(self.UpdateFixDailyBug, self))
end

function MainUIViewTask:UpdateFixDailyBug(elapse_time, total_time)
	local has_daily_task = false
	for k,v in pairs(self.task_data) do
		if v.task_type == TASK_TYPE.DALIY then
			has_daily_task = true
			break
		end
	end
	if has_daily_task then
		self:RemoveDailyBugCountDown()
		return
	end
	-- 如果满足每日必做的条件，但是任务列表里面又不存在，则强制刷新任务列表
	if self:CheckIsShowDailyTask() then
		self:SortTask()
	end
end

function MainUIViewTask:RemoveDailyBugCountDown()
	if self.daily_bug_count_down then
		CountDown.Instance:RemoveCountDown(self.daily_bug_count_down)
		self.daily_bug_count_down = nil
	end
end

function MainUIViewTask:PlayerDataListen(attr_name)
	if attr_name == "guild_id" then
		self:SortTask()
	end
end
--------------------------------------------------------------- MainUIViewTaskInfo ------------------------------------------------------------

MainUIViewTaskInfo = MainUIViewTaskInfo or BaseClass(BaseCell)

function MainUIViewTaskInfo:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	-- self.icon = self:FindVariable("Icon")
	self.task_type = self:FindVariable("TaskType")
	self.task_type_color = self:FindVariable("TaskTypeColor")
	self.name = self:FindVariable("Name")
	self.desc = self:FindVariable("Desc")
	self.quick = self:FindVariable("QuickDone")
	self.show_time = self:FindVariable("ShowTime")
	self.time = self:FindVariable("Time")
	self.show_zhuxian_eff = self:FindVariable("ShowZhuxianEff")
	self.guide_effect = self:FindVariable("GuideEffect")
	self.show_arrow_eff = self:FindVariable("ShowArrowEff")
	self.show_item = self:FindVariable("show_item")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.task_type_obj = self:FindObj("TaskType")
	self.task_type_res = self:FindVariable("TaskTypeRes")
	self.has_hug_task = self:FindVariable("HasHugTask")
	self.btn_image = self:FindVariable("TaskButton")
	self.is_show_arrow = false
	self.data_index = 0
	self.effect_task = 0
end

function MainUIViewTaskInfo:__delete()
	self.item_cell:DeleteMe()
	self:RemoveCountDown()
	if self.sell_view then
		self.sell_view = nil
	end
	if self.handler then
		self.handler = nil
	end
end

function MainUIViewTaskInfo:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click",
		function()
			self:SetShowHelpArrowEff(false)
			handler:OnTaskCellClick(self.data)
			if self.effect_task > 0 then
				CLICK_EFFECT_TASK = self.effect_task
			end
			self.guide_effect:SetValue(false)
		end
	)
end

function MainUIViewTaskInfo:ListenQuickDone(handler)
	self:ClearEvent("ClickQuickDone")
	self:ListenEvent("ClickQuickDone", function() handler:OnClickQuickDone(self.data) end)
end

function MainUIViewTaskInfo:SetHandle(handler)
	self.handler = handler
end

function MainUIViewTaskInfo:IsShowArrowEff()
	return self.is_show_arrow
end

function MainUIViewTaskInfo:SetShowArrowEff(is_show)
	if is_show then
		ARROW_TASK_ID = self.data.task_id
	elseif ARROW_TASK_ID == self.data.task_id then
		ARROW_TASK_ID = 0
	end
	if nil == self.data or self.is_show_arrow == is_show then return end
	self.is_show_arrow = is_show
	self.show_arrow_eff:SetValue(is_show)
end

function MainUIViewTaskInfo:SetShowHelpArrowEff(is_show)
	local main_view = ViewManager.Instance:GetView(ViewName.Main)
	if main_view then
		main_view:SetArrowImage(is_show)
	end
end

function MainUIViewTaskInfo:SetIndex(index)
	self.data_index = index
end

function MainUIViewTaskInfo:GetTaskId()
	return nil ~= self.data and self.data.task_id or 0
end

local old_level = 0
function MainUIViewTaskInfo:OnFlush()
	self.quick:SetValue(false)
	self.show_item:SetValue(false)
	self.guide_effect:SetValue(false)
	self:SetTaskEffectFlag()
	if nil == self.data then
		return
	end
	self.btn_image:SetAsset(ResPath.GetMainUITaskButton("quick"))
	local data = self.data
	if data.task_id == -1 then --提示加入公会领取任务
		self.task_type:SetValue(Language.Task.task_type2[4])
		self.task_type_color:SetValue(TEXT_COLOR.WHITE)
		self.task_type_obj.outline.effectColor = MAIN_TASK_TEXT_OUTLINE_COLOR[4]
		self.task_type_res:SetAsset(ResPath.GetMainUITaskType(4))
		self.name:SetValue(Language.Task.task_title[4])
		self.desc:SetValue(Language.Task.JoinGuild)
		return
	end

	self.has_hug_task:SetValue(HAS_HUG_TASK)
	local role_level = PlayerData.Instance:GetRoleVo().level
	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	-- 策划说写死 角色130-200级才开启这个功能(以后的人来优化此功能)
	if role_level >= 130 and role_level <= 200 then
		if config then
			if data.task_type == TASK_TYPE.ZHU then
				if (not TaskData.Instance:GetTaskArrowKazhuxian() or old_level < 130) and config.min_level > role_level then
					self:SetShowHelpArrowEff(true)
				elseif config.min_level <= role_level then
					self:SetShowHelpArrowEff(false)
				end
				TaskData.Instance:SetTaskArrowKazhuxian(config.min_level > role_level)
			else
				self:SetShowHelpArrowEff(false)
			end
		end
	else
		self:SetShowHelpArrowEff(false)
	end
	old_level = role_level
	if role_level <= GameEnum.NOVICE_LEVEL and (ARROW_TASK_ID <= 0 or ARROW_TASK_ID == data.task_id) and
		((data.task_type == TASK_TYPE.ZHU and config and config.min_level <= role_level and CAN_SHOW_ZHU_ARROW)
		or (TaskData.IsArrowZhiTask(data.task_id) and CAN_SHOW_ZHI_ARROW)
		or data.task_type == TASK_TYPE.GUILD and CAN_SHOW_GUILD_ARROW) --第一个支线
		 then
			self:SetShowArrowEff(true)
	else
		self:SetShowArrowEff(false)
	end

	if data.task_type == TASK_TYPE.ZHU then
		if role_level <= GameEnum.NOVICE_LEVEL and CAN_DO_ZHU_TASK and config and config.min_level > role_level then
			TaskData.Instance:SetCurTaskId(0)
			TASK_RI_AUTO = true
			TaskCtrl.Instance:SetAutoTalkState(true)
		end
		CAN_DO_ZHU_TASK = config and config.min_level <= role_level or false
	end

	-- self.show_zhuxian_eff:SetValue(data.task_type == TASK_TYPE.ZHU)
	local cur_task_type = data.task_type == TASK_TYPE.GUAJIBOSS and TASK_TYPE.GUAJI or data.task_type
	self.task_type:SetValue(Language.Task.task_type2[cur_task_type] or Language.Task.task_type2[1])
	self.task_type_color:SetValue(TEXT_COLOR.WHITE)
	self.task_type_obj.outline.effectColor = MAIN_TASK_TEXT_OUTLINE_COLOR[data.task_type] or MAIN_TASK_TEXT_OUTLINE_COLOR[1]
	self.task_type_res:SetAsset(ResPath.GetMainUITaskType(Language.Task.task_type_color[data.task_type] and data.task_type or 1))
	-- 	self.task_type:SetValue(Language.Task.Xiu)
	-- 	self.task_type_color:SetValue(Language.Task.XiuColor)
	-- end
	local task_pre_str = ""
	if data.task_type == TASK_TYPE.RI or data.task_type == TASK_TYPE.GUILD or data.task_type == TASK_TYPE.HUAN or data.task_type == TASK_TYPE.WEEK_HUAN or
	 (data.task_type == TASK_TYPE.HU and not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids)) then
		local commit_count = 0
		local max_count = 0
		if data.task_type == TASK_TYPE.RI then
			max_count = MAX_DAILY_TASK_COUNT
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) + 1, max_count)
			self.btn_image:SetAsset(ResPath.GetMainUITaskButton("two"))
			self.quick:SetValue(true)
		elseif data.task_type == TASK_TYPE.HUAN then
			max_count = TaskData.Instance:GetMaxPaohuanTaskCount()
			commit_count = TaskData.Instance:GetPaohuanTaskInfo().commit_times or 0
			local skip_paohuan_task_limit_level = TaskData.Instance:GetQuickCompletionMinLevel()
			local  level = PlayerData.Instance:GetRoleVo().level
			if max_count - commit_count > 0 and level >= skip_paohuan_task_limit_level then
				self.quick:SetValue(true)
			end
		elseif data.task_type == TASK_TYPE.GUILD then
			max_count = TaskData.Instance:GetMaxGuildTaskCount()
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) + 1, max_count)
			self.quick:SetValue(true)
		elseif data.task_type == TASK_TYPE.WEEK_HUAN then
			max_count = TaskData.Instance:GetMaxWeekPaoHuanTaskCount()
			local paohuan_info = TaskData.Instance:GetWeekPaohuanTaskInfo() or {}
			commit_count = paohuan_info.complete_times or 0
			self.quick:SetValue(false)
		elseif data.task_type == TASK_TYPE.HU then
			max_count = YunbiaoData.Instance:GetHusongRemainTimes() + YunbiaoData.Instance:GetLingQuCishu()
			commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
		end
		task_pre_str = "(<color=#ffffff>" .. commit_count .. "/" .. max_count.. "</color>)"
	end

	if config then
		self.show_item:SetValue(TaskData.IsZhiTask(data))
		if TaskData.IsZhiTask(data) then
			local reward_list = config["prof_list" .. GameVoManager.Instance:GetMainRoleVo().prof]
			self.item_cell:SetData(reward_list[0])
		end
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if config.min_level > role_level then
			self.guide_effect:SetValue(false)
			if ReincarnationData.Instance:GetIsCanZs() and data.task_type == TASK_TYPE.ZHU and role_level % 100 == 0 then
				self.name:SetValue(ToColorStr(Language.Task.ZhuanShengTaskName, "#e8c123"))
				self.desc:SetValue(ToColorStr(Language.Task.RoleZhuanSheng, COLOR.WHITE))
			else
				self.name:SetValue(data.task_name .. task_pre_str)
				self.desc:SetValue(ToColorStr(string.format(Language.Task.GoOn, PlayerData.GetLevelString(config.min_level, true)), COLOR.WHITE))
			end
		else
			self.name:SetValue(data.task_name .. task_pre_str)
			if data.task_type == TASK_TYPE.RI and TaskData.DoDailyTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				local reward_cfg = TaskData.Instance:GetTaskReward(data.task_type)
				local exp = reward_cfg and reward_cfg.exp or 0
				self.desc:SetValue(string.format(Language.Task.FinishExp, CommonDataManager.ConverMoney(exp * MAX_DAILY_TASK_COUNT)))
			elseif data.task_type == TASK_TYPE.GUILD and TaskData.DoGuildTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				local reward_cfg = TaskData.Instance:GetTaskReward(data.task_type)
				local exp = reward_cfg and reward_cfg.exp or 0
				self.desc:SetValue(string.format(Language.Task.FinishExp, CommonDataManager.ConverMoney(exp * TaskData.Instance:GetMaxGuildTaskCount())))
			elseif(data.task_status == TASK_STATUS.CAN_ACCEPT) then
				self.desc:SetValue(config.accept_desc)
			elseif(data.task_status == TASK_STATUS.ACCEPT_PROCESS) then
				if(config.c_param2 == 0) then
					self.desc:SetValue(config.progress_desc)
				else
					local current_count = TaskData.Instance:GetProgressNum(data.task_id)
					local str = MainUIViewTask.ChangeTaskProgressString(config.progress_desc, current_count, config.c_param2)
					self.desc:SetValue(str)
				end
			elseif(data.task_status == TASK_STATUS.COMMIT) then
				local color = data.task_type == TASK_TYPE.ZHI and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				self.desc:SetValue(ToColorStr(config.commit_desc, color))
			else
				self.desc:SetValue(Language.Common.WuFaLingQu)
			end
		end
	else
		if data.task_type == TASK_TYPE.LINK then
			self.task_type:SetValue(Language.Task.link_type[self.data.decs_index])
			self.name:SetValue(Language.Task.link_title[self.data.decs_index])
			self.desc:SetValue(string.format(Language.Task.link_desc[self.data.decs_index], 0 , 0 , 0))
			local cur_chapter, total_num, finish_num = 0, 0, 0
			if self.data.decs_index == 1 then
				cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
				total_num = PersonalGoalsData.Instance:GetCurChapterTotalNum()
				finish_num = PersonalGoalsData.Instance:GetCurchapterFinishNum()
				self.desc:SetValue(ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], cur_chapter + 1 , finish_num , total_num), TEXT_COLOR.WHITE))
			elseif self.data.decs_index == 2 then
				cur_chapter, finish_num, total_num = MolongMibaoData.Instance:GetCurChapterState()
				local chapter_name = MolongMibaoData.Instance:GetMibaoChapterName(cur_chapter)
				self.desc:SetValue(ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], chapter_name, finish_num , total_num), TEXT_COLOR.WHITE))
			elseif self.data.decs_index == 3 then
				local num = 0
				local info = WaBaoData.Instance:GetWaBaoInfo()
				if next(info) then
					num = info.baotu_count
				end
				local format_color = num > 0 and Language.Mount.ShowGreenStr1 or Language.Mount.ShowRedNum
				local num_text = string.format(format_color, num)
				self.desc:SetValue(ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], num_text), TEXT_COLOR.WHITE))
			elseif self.data.decs_index == 4 then
				self.desc:SetValue(ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], num_text), TEXT_COLOR.WHITE))
			end

			if finish_num >= total_num and self.data.decs_index ~= 3 then
				self.desc:SetValue(ToColorStr(Language.Task.link_desc[self.data.decs_index], num_text, TEXT_COLOR.WHITE))
			end
		end
		--精华采集
		if data.task_type == TASK_TYPE.LING then
			if JingHuaHuSongData.Instance:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
				self.name:SetValue(Language.Task.ling_title)
				self.desc:SetValue(Language.Task.ling_find_npc)
				local time = JingHuaHuSongData.Instance:GetRemainTime()						--护送剩余时间
				if time > 0 then
					self.show_time:SetValue(true)
					local rest_of_time = math.ceil(time)
					self.time:SetValue(self:TimeToString(rest_of_time))
					self.sell_view:SetTime(self:TimeToString(rest_of_time))
					self:CountDown(rest_of_time)
				else
					self.show_time:SetValue(false)
				end
			else
				local gather_times = JingHuaHuSongData.Instance:GetGatherTimes()			--当天采集次数
				local gather_day_count = JingHuaHuSongData.Instance:GetGatherDayCount()		--最大采集次数
				local decs = string.format(Language.Task.ling_title_number, gather_day_count - gather_times, gather_day_count)
				self.name:SetValue(decs)
				self.desc:SetValue(Language.Task.ling_decs)
				self.show_time:SetValue(false)
			end
			return
		end

		--挂机BOSS
		if data.task_type == TASK_TYPE.GUAJIBOSS then
			local all_num = GameEnum.GUAJI_BOSS_NEED_COUNT
			local cur_num = YewaiGuajiData.Instance:GetCurHasKillBossCount()
			local decs = string.format(Language.Task.Guaji_Boss_Cur_Num, cur_num, all_num)
			self.name:SetValue(Language.Task.Guaji_Boss_Title)
			self.desc:SetValue(decs)
			return
		end


		if data.task_type == TASK_TYPE.DALIY then
			self.task_type:SetValue(Language.Task.task_type2[self.data.task_type])
			self.name:SetValue(Language.Task.task_title[self.data.task_type])
			local total_num, finish_num = 0, 0
			total_num = self.data.total_num
			finish_num = self.data.finish_num
			self.desc:SetValue(ToColorStr(self.data.des.."("..finish_num.."/"..total_num..")", TEXT_COLOR.WHITE))
			if finish_num >= total_num then
				self.desc:SetValue(ToColorStr(string.format(Language.Task.GetReward), TEXT_COLOR.GREEN))
			end
		end


	end
	self:RemoveCountDown()
	local end_time = TaskData.Instance:GetTaskEndTime(data.task_id)
	if end_time then
		local time = end_time - TimeCtrl.Instance:GetServerTime()
		if time > 0 then
			self.show_time:SetValue(true)
			local rest_of_time = math.ceil(time)
			self.time:SetValue(self:TimeToString(rest_of_time))
			self.sell_view:SetTime(self:TimeToString(rest_of_time))

			self:CountDown(rest_of_time)
		else
			self.show_time:SetValue(false)
		end
	else
		self.show_time:SetValue(false)
	end
end

function MainUIViewTaskInfo:SetToggle(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MainUIViewTaskInfo:CountDown(time)
	if not time or time < 1 then return end
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.UpdateTime, self, nil))
end

function MainUIViewTaskInfo:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewTaskInfo:UpdateTime(callback, elapse_time, total_time)
	local time = math.floor(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end
	self.time:SetValue(self:TimeToString(time))
	self.sell_view:SetTime(self:TimeToString(time))
end

function MainUIViewTaskInfo:TimeToString(time)
	-- 1小时之内
	if time > 3600 then return end
	local min = math.floor(time / 60)
	local sec = time % 60
	if sec < 10 then sec = 0 .. sec end
	if min < 10 then min = 0 .. min end
	return (min .. ":" .. sec)
end

function MainUIViewTaskInfo:GetData()
	return self.data
end

function MainUIViewTaskInfo:SetTaskEffectFlag()
	local effect_flag = false
	self.effect_task = 0
	if self.data then
		if HAS_ZHI_TASK then
			effect_flag = TaskData.IsZhiTask(self.data)
		else
			effect_flag =  self.data.task_type == TASK_TYPE.ZHU
		end
		if effect_flag then
			self.effect_task = self.data.task_id
		end
	end
	if effect_flag then
		self.guide_effect:SetValue(self.effect_task ~= CLICK_EFFECT_TASK or (self.effect_task > 0 and self.data.task_status == TASK_STATUS.COMMIT))
	else
		self.guide_effect:SetValue(false)
	end
end

function MainUIViewTaskInfo:SetToggleSwitch(switch)
	self.root_node.toggle.isOn = switch or false
end