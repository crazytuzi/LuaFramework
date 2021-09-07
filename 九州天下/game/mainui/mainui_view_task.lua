MainUIViewTask = MainUIViewTask or BaseClass(BaseRender)

local DELAY_TIME = 0.25
local INTERVAL_TIME = 1
local ListViewDelegate = ListViewDelegate
MainUIViewTask.SHOW_GUIDE_ARROW = false
local CAN_SHOW_ZHU_ARROW = false	-- 显示主线箭头
local CAN_SHOW_ZHI_ARROW = true 	-- 显示支线箭头
local CUR_TASK = 0 					-- 当前任务
local CUR_ZHI_TASK = 99999  		-- 当前支线
local HAS_ZHI_TASK = false 			-- 是否存在支线
local HAS_RI_TASK = false 			-- 是否存在日常任务
local CAN_DO_ZHU_TASK = false 		-- 是否可做主线
local CLICK_EFFECT_TASK = 0 		-- 最后点击的特效任务ID
local SHOW_MSG_FLAG = true 			-- 只弹一次错误码
local BUG_TASK_LIST = {
	[690] = true,
	[5690] = true,
	[10690] = true,
}
function MainUIViewTask:__init()
	self.is_load = true
	self.is_move = false
	self.is_has_quick_done = false
	self.task_data = {}
	self.cell_list = {}
	self.arrow_type = {}

	self.normal_task = self:FindObj("NormalTask")
	self.chapter_task = self:FindObj("ChapterTask")
	self.normal_task:SetActive(false)

	self.task_list = self:FindObj("TaskList")
	self.guide_arrow = self:FindObj("GuideArrow")

	self.show_down_arrow = self:FindVariable("ShowDownArrow")
	self.guide_arrow:SetActive(false)
	--self.toggle_group = self.task_list:GetComponent("ToggleGroup")
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
	self.is_chapter = self:FindVariable("IsChapter")

	self:ListenEvent("DoTask", BindTool.Bind(self.OnTouchChapterTask, self))

	-- self.list_view_delegate = ListViewDelegate()

	-- PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "TaskInfo"), function (prefab)
	-- 	if nil == prefab then
	-- 		return
	-- 	end

	-- 	local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
	-- 	PrefabPool.Instance:Free(prefab)

	-- 	self.enhanced_cell_type = enhanced_cell_type
	-- 	self.task_list.scroller.Delegate = self.list_view_delegate

	-- 	self.list_view_delegate.numberOfCellsDel = function()
	-- 		return #self.task_data
	-- 	end
	-- 	self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
	-- 	self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	-- 	self.task_list.scroller.scrollerScrollingChanged = function ()
	-- 		self:ReSetBtnVisible()
	-- 	end
	-- end)

	local list_view_delegate = self.task_list.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = function()
		return #self.task_data
	end

	list_view_delegate.CellRefreshDel = BindTool.Bind(self.GetCellView, self)
	self.task_list.scroller.scrollerScrollingChanged = function ()
		self:ReSetBtnVisible()
	end
	-- self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
	-- self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	--self.task_list.scroller.scrollerScrollingChanged = function ()
		--self:ReSetBtnVisible()
	--end

	-- 监听系统消息
	self:BindGlobalEvent(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
	self:BindGlobalEvent(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DayCountChange, self))
	self:BindGlobalEvent(OtherEventType.VIRTUAL_TASK_CHANGE, BindTool.Bind(self.VirtualTaskChange, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE, BindTool.Bind(self.ClearToggle, self))

	self.player_data_listen = BindTool.Bind(self.PlayerDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_listen)

	self.remind_change = BindTool.Bind(self.VirtualTaskChange, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MoLongMiBao)

	self.delay_sort_task_fun = BindTool.Bind(self.DelaySortTask, self)
	self.last_move_time = 0
	self.auto_zhu_task = true		-- 自动做主线

	self.move_time_interval = 0

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
	self.select_index = nil
end

function MainUIViewTask:SetTaskSelect(index)
	if index ~= nil then
		self.select_index = index

		if self.cell_list ~= nil then
			for k,v in pairs(self.cell_list) do
				if v ~= nil then
					v:CheckIsSelect(self.select_index)
				end
			end
		end
	end
end

function MainUIViewTask:SetTime(time)
	self.time:SetValue(time)
end

function MainUIViewTask:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end

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
end

function MainUIViewTask:SetAutoTaskState(state)
	if not state and self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	self.auto_zhu_task = state
	if state then
		if PlayerData.Instance:GetRoleVo().level < COMMON_CONSTS.AUTO_TASK_LEVEL_LIMIT  -- 50级前恢复时才自动做任务
			and self:IsCanAutoExecuteTask() then
			self:AutoExecuteTask()
		end
	else
		if GuajiCache.guaji_type == GuajiType.HalfAuto then
			GuajiCtrl.Instance:StopGuaji()
		end
		-- Scene.Instance:GetMainRole():StopMove()
	end
end

-- 自动做任务接口，上面的接口有等级限制
function MainUIViewTask:SetTaskAutoState(state)
	if not state and self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	self.auto_zhu_task = state
	if state then
		self:AutoExecuteTask()
	else
		GuajiCtrl.Instance:StopGuaji()
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
-- function MainUIViewTask:GetCellView(scroller, data_index, cell_index)
-- 	--local cell_view = scroller:GetCellView(self.enhanced_cell_type)
-- 	local cell = self.cell_list[cell_view]

-- 	if cell == nil then
-- 		self.cell_list[cell_view] = MainUIViewTaskInfo.New(cell_view)
-- 		cell = self.cell_list[cell_view]
-- 		cell.sell_view = self
-- 		self.toggles[data_index] = cell.root_node:GetComponent("Toggle")
-- 		cell:SetHandle(self)
-- 		--cell:ListenClick(self)
-- 		cell:ListenQuickDone(self)
-- 		--cell:SetToggle(self.toggle_group)
-- 	end
-- 	local data = self.task_data[data_index + 1]
-- 	cell:SetHandle(self)
-- 	--cell.root_node.toggle.isOn = data and CUR_TASK == data.task_id
-- 	if data and CUR_TASK == data.task_id then
-- 		self:SetTaskSelect(data_index + 1)
-- 	end
	
-- 	cell:SetToggleSwitch(data and CUR_TASK == data.task_id)
-- 	cell:SetIndex(data_index + 1)
-- 	--cell:CheckIsSelect(self.select_index)
-- 	cell:SetData(data)
-- 	return cell_view
-- end

function MainUIViewTask:GetCellView(cell, data_index, cell_index)
	-- local cell_obj = self.cell_list[cell]

	-- if cell_obj == nil then
	-- 	cell_obj = MainUIViewTaskInfo.New(cell.gameObject)
	-- 	--cell = self.cell_list[cell_view]
	-- 	--cell.sell_view = self
	-- 	--self.toggles[data_index] = cell.root_node:GetComponent("Toggle")
	-- 	cell_obj:SetHandle(self)
	-- 	--cell:ListenClick(self)
	-- 	cell_obj:ListenQuickDone(self)
	-- 	--cell:SetToggle(self.toggle_group)
	-- 	self.cell_list[data_index] = cell_obj
	-- end
	-- local data = self.task_data[data_index + 1]
	-- cell_obj:SetHandle(self)
	-- --cell.root_node.toggle.isOn = data and CUR_TASK == data.task_id
	-- if data and CUR_TASK == data.task_id then
	-- 	self:SetTaskSelect(data_index + 1)
	-- end
	
	--cell_obj:SetToggleSwitch(data and CUR_TASK == data.task_id)
	--cell_obj:SetIndex(data_index + 1)
	--cell:CheckIsSelect(self.select_index)
	--cell_obj:SetData(data)
	--return cell_view

	local icon_cell = self.cell_list[cell]
	if icon_cell == nil then
		icon_cell = MainUIViewTaskInfo.New(cell.gameObject)
		icon_cell:SetHandle(self)
		icon_cell:ListenQuickDone(self)
		self.cell_list[cell] = icon_cell
	end

	local data = self.task_data[data_index + 1]  
	icon_cell:SetHandle(self)
	--cell.root_node.toggle.isOn = data and CUR_TASK == data.task_id
	if data and CUR_TASK == data.task_id then
		self:SetTaskSelect(data_index + 1)
	end

	icon_cell:SetToggleSwitch(data and CUR_TASK == data.task_id)
	icon_cell:SetIndex(data_index + 1)
	--cell:CheckIsSelect(self.select_index)
	icon_cell:SetData(data)
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
	return 72
end

function MainUIViewTask:OnTaskChange(task_event_type, task_id)
	if Scene.Instance:GetSceneId() == 1130 then
		--皇陵探险中不需要这个功能
		return
	end
	if task_event_type == "completed_add" then
		self.last_task_id = task_id
		self:CompletedSceneEventLogic(task_id)
	elseif task_event_type == "hold_beauty" then
		self:AutoExecuteTask()
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
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHU and self:IsCanAutoExecuteTask() then
		self:AutoExecuteTask()
	end

	if TaskData.Instance:GetTaskIsAccepted(TaskData.Instance:GetHoldMeirenTaskId()) then
		Scene.Instance:ShieldNpc(TaskData.Instance:GetHoldMeirenNpcId(), true)
	end
end

function MainUIViewTask:MainRoleLevelChange()
	self:SortTask()
end

function MainUIViewTask:IsCanAutoExecuteTask()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.Common then
			if GuajiCache.guaji_type ~= GuajiType.Auto and GuajiCache.guaji_type ~= GuajiType.None and self.auto_zhu_task then
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
		elseif TaskData.Instance:GetNextZhuTaskConfig() then
			task_id = TaskData.Instance:GetNextZhuTaskConfig().task_id
		end
	end
	if task_id and task_id ~= 0 then
		self.last_task_id = task_id
		if TASK_RI_AUTO then
			if TaskData.Instance:GetIsHoldBeautyTask(task_id) then
				self:DoTask(task_id, TASK_STATUS.COMMIT)
			else
				self:DoTask(task_id, TASK_STATUS.ACCEPT_PROCESS)
			end
		else
			self:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
		end
	else
		GuajiCtrl.Instance:ClearTaskOperate()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
end

function MainUIViewTask:ClearToggle()
	if TaskData.Instance:IsDailyTask(CUR_TASK) and TASK_RI_AUTO then
		return
	end
	--self.toggle_group:SetAllTogglesOff()

	-- if self.toggles ~= nil then
	-- 	for k,v in pairs(self.toggles) do
	-- 		if v ~= nil then
	-- 			v.isOn = false
	-- 		end
	-- 	end
	-- end

	if self.cell_list ~= nil then
		for k,v in pairs(self.cell_list) do
			if v ~= nil then
				v:SetToggleSwitch(false)
			end
		end
	end

	self.select_index = nil
	CUR_TASK = 0
end

function MainUIViewTask:PlayerDataChange(attr_name)
	if attr_name == "vip_level" then
		self:SortTask()
	end
end

--继续护送任务
function MainUIViewTask:ClickGo()
	if CUR_TASK == TASK_ID.YUNBIAO then
		return
	end

	TaskData.Instance:GoOnHuSong()
end

function MainUIViewTask:OnTaskCellClick(data)
	if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 and not TaskData.GetTaskIsBeautyTask(data.task_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[1])
		return
	end
	
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
		-- self:RewardFlyToBag(data)
		self:OperateTask(data)
		return
	end
	if data.task_type == TASK_TYPE.ZHIBAO then
		ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao)
		return
	end

	for k,v in pairs(self.cell_list) do
		if v:IsShowArrowEff() then
			v:SetShowArrowEff(false)
			if v.data and v.data.task_type == TASK_TYPE.ZHU then
				CAN_SHOW_ZHU_ARROW = false
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
				ViewManager.Instance:Open(ViewName.Reincarnation)
			else
				-- ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
				if OpenFunData.Instance:CheckIsHide("runetowerview") then
					ViewManager.Instance:Open(ViewName.RuneTowerView)
				else

					-- 等级不足的时候不再弹提示而是改为弹出军印界面
					-- SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Task.TaskLevelLimit, PlayerData.GetLevelString(config.min_level, true)))
					ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao)
				end
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
	end

	if data.task_type == TASK_TYPE.JUN and data.task_status == TASK_STATUS.CAN_ACCEPT then
		if TaskData.JunXianTaskLimit() then return end
		MilitaryRankCtrl.Instance:OpenDecreeView(DECREE_SHOW_TYPE.ACCEPT_TASK)
		return
	end

	--更新选中状态
	self:OperateTask(data)
end

function MainUIViewTask:SetArrowTips(type, is_active)
	self.arrow_type[type] = is_active
end

function MainUIViewTask:GetArrowTips(type)
	return self.arrow_type[type] or nil
end

function MainUIViewTask:OnClickQuickDone(data)
	if nil == data then
		return
	end
	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	local price = 0
	local count = 0
	if config then
		price = TaskData.Instance:GetDailyDoubleGold()
		count = TaskData.Instance:GetTaskCount(tonumber(config.task_type))
	end
	local describe = string.format(Language.Daily.YiJianRenWu, ToColorStr(tostring(price * count), TEXT_COLOR.YELLOW))
	describe = string.format(describe, price * count)
	-- TipsCtrl.Instance:ShowTwoOptionView(describe, yes_func, nil, "确定", "取消")

	local call_back = function ()
		local gold = PlayerData.Instance:GetRoleVo().gold + PlayerData.Instance:GetRoleVo().bind_gold
		if gold < price * count then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		TaskCtrl.Instance:SendQuickDone(config.task_type, data.task_id)
		--GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_DAILY_TASK_DRAW)
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_DAILY_TASK_DRAW)
		--GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, GuildData.Instance:GetRewardSeq() == 0)
		self:DelaySortTask()
		
	end
	local red_text = Language.Task.QuickDoneRedText
	TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back, nil, true, nil, nil, red_text)
end

function MainUIViewTask:OperateTask(data)
	if data ~= nil then
		TaskData.Instance:SetCurTaskId(data.task_id)
		self:DoTask(data.task_id, data.task_status, true, data)
	end
end

--任务排序(各种原因引起的任务变化可能短时间内来好几个，延迟一点时间)
function MainUIViewTask:SortTask()
	if nil ~= self.delay_sort_task_timer then
		return
	end

	self.delay_sort_task_timer = GlobalTimerQuest:AddDelayTimer(self.delay_sort_task_fun, 0.5)
end

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

	local virtual_guaji_task_cfg = nil
	-- if PlayerData.Instance:GetRoleVo().level >= 160 and
	-- 	(nil == zhu_task_cfg or PlayerData.Instance.role_vo.level < zhu_task_cfg.min_level)
	-- 	and TaskData.Instance:GetTaskCount(TASK_TYPE.RI) <= 0
	-- 	and TaskData.Instance:GetTaskCount(TASK_TYPE.GUILD) <= 0 then
	-- 	virtual_guaji_task_cfg = TaskData.Instance:GetVirtualGuajiTask()
	-- end

	local virtual_xiulian_task_cfg = nil
	local max_chapter = PersonalGoalsData.Instance:GetMaxChapter()
	local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	if OpenFunData.Instance:CheckIsHide("mieshizhizhan") and cur_chapter < max_chapter then
		virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualXiuLianTask()
	end

	-- if self:CheckIsShowDailyTask() then
	-- 	virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualDaliyTask()
	-- end

	local virtual_begod_task_cfg = nil
	-- if OpenFunData.Instance:CheckIsHide("molongmibaoview") and MolongMibaoData.Instance:IsShowMolongMibao() then
	-- 	virtual_begod_task_cfg = TaskData.Instance:GetVirtualBeGodTask()
	-- end

	-- local virtual_wabao_task_cfg = nil
	-- if WaBaoData.Instance:GetIsShowWaBao() then
	-- 	virtual_wabao_task_cfg = WaBaoData.Instance:GetVirtualWaBaoTask()
	-- end

	local virtual_ling_task_cfg = nil
	if PlayerData.Instance:GetRoleVo().jinghua_husong_status > 0 then
		virtual_ling_task_cfg = TaskData.Instance:GetVirtualLingTask()
	end

	local virtual_yingjiu_task_cfg = NationalWarfareData.Instance:GetYingJiuInfo()
	if virtual_yingjiu_task_cfg.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then
		virtual_yingjiu_task_cfg = nil
	end

	local banzhuan_task_cfg = NationalWarfareData.Instance:GetBanZhuanTaskCfg()
	local citan_task_cfg = NationalWarfareData.Instance:GetCitanTaskCfg()

	local kill_task_cfg = TaskData.Instance:GetKillTaskInfo()

	--可提交
	local can_commit_list = {}
	for k,v in pairs(task_accepted_info_list) do
		if v.is_complete ~= 0 then
			task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
			if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
				can_commit_list[#can_commit_list + 1] = task_cfg
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
		end
	end
	-- 可接

	-- 国战项目护送任务不显示在任务栏上
	-- -- 手动加入护送任务
	-- task_can_accept_id_list[YunbiaoData.Instance.task_ids] = nil
	-- local max_count = YunbiaoData.Instance:GetHusongRemainTimes() or 0
	-- -- local commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
	-- if max_count > 0 then
	-- 	local yunbiao_task_cfg = TaskData.Instance:GetTaskConfig(YunbiaoData.Instance.task_ids)
	-- 	if yunbiao_task_cfg then
	-- 		if yunbiao_task_cfg.min_level <= GameVoManager.Instance:GetMainRoleVo().level then
	-- 			if not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids) then
	-- 				task_can_accept_id_list[YunbiaoData.Instance.task_ids] = 1
	-- 			end
	-- 		end
	-- 	end
	-- end

	for k,v in pairs(task_can_accept_id_list) do
		task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
			order_list[#order_list + 1] = task_cfg
		end
	end

	if virtual_xiulian_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_xiulian_task_cfg
	end

	-- if virtual_wabao_task_cfg ~= nil then
	-- 	order_list[#order_list + 1] = virtual_wabao_task_cfg
	-- end

	if virtual_begod_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_begod_task_cfg
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

	if virtual_yingjiu_task_cfg then
		self.task_data[#self.task_data + 1] = virtual_yingjiu_task_cfg
	end

	if banzhuan_task_cfg ~= nil then
		self.task_data[#self.task_data + 1] = banzhuan_task_cfg
	end

	if citan_task_cfg ~= nil then
		self.task_data[#self.task_data + 1] = citan_task_cfg
	end

	local kill_task_info = TaskData.Instance:GetkillRoleFetchIntegration()
	if PlayerData.Instance.role_vo.level >= kill_task_info[1].need_level then
		if kill_task_cfg and next(kill_task_cfg) then
			self.task_data[#self.task_data + 1] = kill_task_cfg
		end
	end

	if virtual_guaji_task_cfg ~= nil then
		local has_add_guaji = false
		if PlayerData.Instance.role_vo.level < 240 then
			for i,v in ipairs(order_list) do
				if v.task_id == 999997 then
					has_add_guaji = true
					table.insert(order_list, i + 1, virtual_guaji_task_cfg)
					break
				end
			end
		end
		if not has_add_guaji then
			self.task_data[#self.task_data + 1] = virtual_guaji_task_cfg
		end
	end

	if virtual_ling_task_cfg ~= nil then
		self.task_data[#self.task_data + 1] = virtual_ling_task_cfg
	end

	local min_zhi_task_id = 99999
	HAS_RI_TASK = false

	for k,v in pairs(can_commit_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		end
	end

	for k,v in pairs(order_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		end
	end

	-- if CUR_ZHI_TASK ~= 99999 and CUR_ZHI_TASK ~= min_zhi_task_id and self.package_btn then
	-- 	self:RewardFlyToBag()
	-- end

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
		if v.task_type == TASK_TYPE.LINK or v.task_type == TASK_TYPE.GUAJI or v.task_type == TASK_TYPE.DALIY then
			self.task_data[#self.task_data + 1] = v
		elseif (v.task_id == min_zhi_task_id and TaskData.IsZhiTask(v)) or not TaskData.IsZhiTask(v) then
			if not HAS_RI_TASK or v.task_type ~= TASK_TYPE.GUILD then
				self.task_data[#self.task_data + 1] = MainUIViewTask.TaskCellInfo(v.task_id, task_status, progress_num)
			end
		end
	end

	if ZhiBaoData.Instance:GetZhiBaoActiveRemind(true) > 0 and OpenFunData.Instance:CheckIsHide("baoju") then
		local cfg = ZhiBaoData.Instance:GetZhiBaoTaskCfg()
		self.task_data[#self.task_data + 1] = cfg
	end

	for i, v in pairs(self.arrow_type) do
		if self.arrow_type[i] then
			self.arrow_type[i] = false
		end
	end

	self:SortTaskToFirst()
	if self.is_load and nil == TaskData.Instance:GetCurrentChapterCfg() then
		self.normal_task:SetActive(true)
		self.chapter_task:SetActive(false)
		self.show_chapter_txt:SetValue(false)
		self.task_list.scroller:RefreshAndReloadActiveCellViews(true)
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
	self.cur_move:MoveTo(target_pos, 1.7, close_view)
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
	local end_task_cfg = TaskData.Instance:GetTaskConfig(TaskData.Instance:GetTaskId(chapter_cfg.end_taskid))
	if nil == task_cfg or nil == end_task_cfg or "" == task_cfg.now_index then
		return
	end
	if chapter_cfg.zhangjie == 1 then
		self.is_chapter:SetValue(false)
	else
		self.is_chapter:SetValue(true)
	end
	-- self.chapter_name:SetValue(chapter_cfg.name)
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
	-- 割绳子任务断了点任务寻路特殊处理
	local target = TaskData.Instance:GetBeautyRoadCfg(task_cfg.task_id)
	if target then
		self:MoveToTarget(target, MoveEndType.NpcTask, task_cfg.task_id, false)
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
	if string.find(old_string, "10</per>") then
		old_string = string.gsub(old_string, "10</per>", total_count .. "</color>")
	else
		old_string = string.gsub(old_string, total_count .. "</per>", total_count .. "</color>")
	end
	return old_string
end


--把转职任务放在第一位
function MainUIViewTask:SortTaskToFirst()
	local zhu_task_data = nil
	local is_have_zhu = false
	if self.task_data[1] and self.task_data[1].task_type == TASK_TYPE.ZHU then
		local config = TaskData.Instance:GetTaskConfig(self.task_data[1].task_id)
		local role_level = PlayerData.Instance:GetRoleVo().level
		is_have_zhu = true
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

	local task_seq = zhu_task_data and 1 or 2
	task_seq = TaskData.Instance:GetZhuTaskConfig() and task_seq or 1

	if nil ~= zhi_key and nil ~= zhi_task_cfg then
		table.remove(self.task_data, zhi_key)
		table.insert(self.task_data, task_seq, zhi_task_cfg)
	end

	local daily_virtual_key = nil
	if zhu_task_data then
		for k, v in ipairs(self.task_data) do
			if v.task_type == TASK_TYPE.RI or
				v.task_type == TASK_TYPE.GUILD or
				v.task_type == TASK_TYPE.LINK or
				v.task_type == TASK_TYPE.DALIY then
				daily_virtual_key = k
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

	--国家战事任务
	local guojia_task = {}
	for i = #self.task_data, 1, -1 do
		if self.task_data[i].task_type == TASK_TYPE.YINGJIU or 
			self.task_data[i].task_type == TASK_TYPE.CITAN or
			self.task_data[i].task_type == TASK_TYPE.BANZHUAN then
			local task_data = table.remove(self.task_data, i)
			table.insert(guojia_task, task_data)
		end
	end
	local guojia_seq = is_have_zhu and 2 or 1
	if next(guojia_task) then
		for k, v in ipairs(guojia_task) do
			table.insert(self.task_data, guojia_seq, v)
		end
	end

	--军衔
	for k, v in pairs(self.task_data) do
		if v.task_type == TASK_TYPE.JUN then
			local jun_task = v
			table.remove(self.task_data, k)
			table.insert(self.task_data, 1, jun_task)
		end
	end




	--功能开启,如果未加入公会则增加加入公会一列
	-- if not HAS_RI_TASK and OpenFunData.Instance:CheckIsHide("guild_task") then
	-- 	if GameVoManager.Instance:GetMainRoleVo().guild_id == 0 then
	-- 		local data = {}
	-- 		data.task_id = -1
	-- 		table.insert(self.task_data, data)
	-- 	end
	-- end
end

--为任务增加排序索引，勿模防,
--主线、日常、仙盟、护送、支线
function MainUIViewTask:GetSortIndexByConfig(task_cfg)
	if task_cfg and task_cfg.order_index == nil then
		if task_cfg.task_type == TASK_TYPE.ZHU then      --主线
			return 1000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.ZHI then  --支线
			return 8000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.RI then   --日常
			return 4000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.GUILD then  --仙盟
			return 6000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HU then 	--护送
			return 9000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.CAMP then 	--阵营
			return 2000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HUAN then 	--跑环
			return 5000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.LINK then 	--打开面板
			return 7000000 + task_cfg.task_id
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
function MainUIViewTask:DoTask(task_id, task_status, is_active, data)
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
	if TASK_CG_MOUNT_DOWN[task_id] then
		--这个任务时强制下坐骑,解决cg播放有坐骑顽固问题,其他人勿学
		MountCtrl.Instance:SendGoonMountReq(0)
	end

	-- 如果正在抱美人，不让做其他任务
	-- if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 and TASK_ACCEPT_OP.HOLD_BEAUTY ~= task_cfg.accept_op then
	-- 	local task_id = TaskData.Instance:GetTaskAcceptedIsBeauty(true)
	-- 	if task_id then
	-- 		TaskCtrl.Instance:DoTask(task_id)
	-- 		return
	-- 	end
	-- end
		
	if task_cfg.task_type == TASK_TYPE.KILLROLE then
		TaskCtrl.Instance:OpenKillTaskView()
		return
	end

	if task_cfg.task_type == TASK_TYPE.YINGJIU then
		if task_cfg.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then 
			CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_COMMIT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU)
			return 
		end
		local cur_task_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq(task_cfg.task_seq)
		if not cur_task_cfg then return end

		-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local param1 = cur_task_cfg["camp" .. task_cfg.task_aim_camp .. "_param1"]
		local param2 = cur_task_cfg["camp" .. task_cfg.task_aim_camp .. "_param2"]
		local scene_id = cur_task_cfg["scene_id_" .. task_cfg.task_aim_camp]

		local target_cfg = {}
		local end_type = MoveEndType.Normal
		local target_type = ""
		
		if cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_TOUCH_NPC then 						-- 同NPC对话
			target_type = "npcs"
			guaji_type = GuajiType.HalfAuto
			end_type = MoveEndType.NpcTask
			TaskData.Instance:YingJiuTalkChange(true)

		elseif cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AMI_GATHER then 						-- 采集物品
			target_type = "gathers"
			guaji_type = GuajiType.HalfAuto
			end_type = MoveEndType.GatherById
			target_cfg = Scene.Instance:SelectMinDisGather(param1, nil, true)
			if target_cfg then
				target_cfg = target_cfg.vo
				target_cfg.x = target_cfg.pos_x
				target_cfg.y = target_cfg.pos_y
			end

		elseif cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_KILL_MONSTER then					-- 杀怪
			target_type = "monsters"
			guaji_type = GuajiType.Monster
			GuajiCache.monster_id = param1
			end_type = MoveEndType.FightByMonsterId
		end

		if not target_cfg or not next(target_cfg) then
			target_cfg = MainUIViewTaskInfo.GetTargetCfg(scene_id, target_type, param1)
		end	
		if not target_cfg or not next(target_cfg) then return end

		GuajiCtrl.Instance:SetGuajiType(guaji_type)
		MoveCache.end_type = end_type
		MoveCache.param1 = param1
		MoveCache.task_id = task_cfg.task_id
		GuajiCache.target_obj_id = param1
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		GuajiCtrl.Instance:MoveToPos(scene_id, target_cfg.x, target_cfg.y, 4, 2, false, scene_key, true)

		return
	end

	if task_cfg.task_type == TASK_TYPE.CITAN then
		local npc_cfg = NationalWarfareData.Instance:GetCiTanNpcCfg()
		local citan_info = NationalWarfareData.Instance:GetCampCitanStatus()
		if task_cfg.task_aim == 1 or citan_info.get_qingbao_color <= 0 then --拿到任务物品，就可以提交任务
			NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, task_cfg.task_aim_camp)
		else
			NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
		end
		return
	end

	if task_cfg.task_type == TASK_TYPE.BANZHUAN then
		local npc_cfg = NationalWarfareData.Instance:GetBanZhuanNpcCfg()
		local banzhuan_info = NationalWarfareData.Instance:GetCampBanzhuanStatus()
		if task_cfg.task_aim == 1 or banzhuan_info.get_color <= 0 then --拿到任务物品，就可以提交任务
			NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, task_cfg.task_aim_camp)
		else
			NationalWarfareData.Instance:MoveTaskNpc(npc_cfg, GameVoManager.Instance:GetMainRoleVo().camp)
		end
		return
	end

	if task_cfg.task_type == TASK_TYPE.GUAJI then
		ViewManager.Instance:Open(ViewName.RuneTowerView)
		return
	end

	if task_cfg.task_type == TASK_TYPE.LINK then
		ViewManager.Instance:Open(task_cfg.open_panel_name)
		return
	end

	if task_cfg.task_type == TASK_TYPE.DALIY then
		local daily_data = ZhiBaoData.Instance:GetFirstTask()
		if daily_data then
			if ZhiBaoData.Instance:GetActiveDegreeListByIndex(daily_data.type) >= daily_data.max_times then
				ViewManager.Instance:Open(ViewName.BaoJu)
			else
				ActiveDegreeScrollCell.OnGoClick(daily_data)
			end
		else
			ViewManager.Instance:Open(ViewName.BaoJu)
		end
		return
	end

	if task_cfg.task_type == TASK_TYPE.JUN and task_status == TASK_STATUS.CAN_ACCEPT then
		if TaskData.JunXianTaskLimit() then return end
		TaskCtrl.SendFlyByShoe(task_cfg.accept_npc.scene, task_cfg.accept_npc.x, task_cfg.accept_npc.y, 0, 0)
		self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
		return
	end

	-- 去做日常任务的日常副本任务（找NPC对话）
	if (task_cfg.task_type == TASK_TYPE.RI 
		and task_status == TASK_STATUS.ACCEPT_PROCESS
		and task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB
		and task_cfg.c_param1 == GameEnum.FB_CHECK_TYPE.FBCT_DAILY_TASK_FB) then

		self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
		return
	end
	if(task_cfg.task_type == TASK_TYPE.RI and task_cfg.condition == TASK_COMPLETE_CONDITION.NOTHING) and task_cfg.accept_npc.id then
		self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
		return
	end
	-- if(task_cfg.task_type == TASK_TYPE.RI)
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
				ViewManager.Instance:Open(ViewName.Reincarnation)
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
			-- StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, task_id)	 --需要和npc对话确认
			StoryCtrl.Instance:OpenGuideEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, task_id) --直接进入
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
				ViewManager.Instance:Open(open_param_t[1], index)
				self:StopTask()
			end
			return
		end

		if type(task_cfg.target_obj) ~= "table" then
			self:ClearToggle()
			SysMsgCtrl.Instance:ErrorRemind("任务表配置的target_obj是null")
			return
		end

		local first_target = task_cfg.target_obj[1]
		-- 多个对话NPC任务
		if task_cfg.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then
			local task_info = TaskData.Instance:GetTaskInfo(task_cfg.task_id)
			if not task_info then return end
			first_target = TaskData.Instance:GetMultiTalkNpcTask(task_cfg, task_info.progress_num)
		end
		if TaskData.Instance:GetTaskTargetConfig(task_id) ~= nil then
			task_cfg.target_obj = TaskData.Instance:GetTaskTargetConfig(task_id)
			first_target = task_cfg.target_obj[1]
		end

		if nil == first_target then
			-- 3个比较特殊的任务 引导中掉线无法继续任务 强制重新引导
			local cur_guilde_cfg = FunctionGuide.Instance:GetGuideCfgByTrigger(GuideTriggerType.AcceptTask, task_id)
			local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
			if hold_beauty_npcid > 0 then
				if SHOW_MSG_FLAG then
					SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[1])
					SHOW_MSG_FLAG = false
				end
				return 
			end
			if cur_guilde_cfg and BUG_TASK_LIST[task_id] then
				FunctionGuide.Instance:SetCurrentGuideCfg(cur_guilde_cfg)
			end
			return
		end

		local scene_id = Scene.Instance:GetSceneId()
		if task_cfg.condition == TASK_COMPLETE_CONDITION.NPC_TALK then			-- 与npc对话任务
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			if task_cfg.accept_op ~= 2 or (task_cfg.commit_npc and task_cfg.commit_npc.scene == scene_id) then
				self:MoveToTarget(first_target, MoveEndType.NpcTask, task_id, is_active)
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, first_target, MoveEndType.NpcTask, task_id), 0.5)
			end
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then	-- 打怪任务
			if GuajiCache.guaji_type == GuajiType.Monster and GuajiCache.monster_id == first_target.id and not is_active and AtkCache.is_valid then
				return
			end
			local target = Scene.Instance:SelectMinDisMonster(task_cfg.target_obj[1].id, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
			if target then
				local x, y = target:GetLogicPos()
				target = {scene = scene_id, x = x, y = y, id = task_cfg.target_obj[1].id}
			else
				target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
			end

			GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
			GuajiCache.monster_id = target.id

			self:MoveToTarget(target, MoveEndType.FightByMonsterId, task_id, is_active)
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.GATHER then			-- 采集任务
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			local target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
			self:MoveToTarget(target, MoveEndType.GatherById, task_id, is_active)

		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then	-- 和多个NPC对话
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			if task_cfg.c_param1 and task_cfg.c_param1 == scene_id then
				self:MoveToTarget(first_target, MoveEndType.NpcTask, task_id, is_active)
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, first_target, MoveEndType.NpcTask, task_id), 0.5)
			end
		end
	elseif task_status == TASK_STATUS.COMMIT then
		if TASK_ACCEPT_OP.HOLD_BEAUTY == task_cfg.accept_op and "" ~= task_cfg.a_param1 then
			local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
			if hold_beauty_npcid > 0 then			-- 完成抱美人任务
				-- 玩家移动结束回调事件
				if not self.role_pos_change then
					self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChange, self))
				end
				if "" ~= task_cfg.a_param2 then
					local scene_data = Split(task_cfg.a_param2, "#")
					local scene_id = tonumber(scene_data[1] or 0)
					local x = tonumber(scene_data[2] or 0)
					local y = tonumber(scene_data[3] or 0)
					if self.move_time_interval <= Status.NowTime then
						self.move_time_interval = Status.NowTime + 3
						if scene_id > 0 and x > 0 and y > 0 and self.role_pos_change then
							GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
						end
					end
				end
			else			-- 抱起美人
				if task_cfg.task_type == TASK_TYPE.RI then
					local scene_data = Split(task_cfg.a_param3, "#")
					local task_pos = {
						id = task_cfg.a_param1,
						scene = tonumber(scene_data[1] or 0),
						x = tonumber(scene_data[2] or 0),
						y = tonumber(scene_data[3] or 0)
					}
					self:MoveToTarget(task_pos, MoveEndType.NpcTask, task_id, is_active)
				else
					PlayerCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_HOLD_BEAUTY, task_cfg.a_param1)
				end
			end
			return
		end
		if task_cfg.task_type == TASK_TYPE.RI then
			-- TaskCtrl.SendTaskCommit(task_id)
			self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
			-- ViewManager.Instance:OpenViewByName(ViewName.Daily, TabIndex.daily_renwu)
		elseif task_cfg.commit_npc == "" or task_cfg.commit_npc == 0 or not next(task_cfg.commit_npc) then		-- 没配npc直接完成
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

	if nil ~= target and type(target) == "table" and next(target) ~= nil then
		GuajiCtrl.Instance:ClearAllOperate()
		GuajiCtrl.Instance:CancelSelect()
		MoveCache.end_type = end_type
		MoveCache.param1 = target.id
		MoveCache.task_id = task_id
		GuajiCache.target_obj_id = target.id
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		local is_speed_up = YunbiaoData.Instance.task_ids ~= task_id 	--运镖不加速
		
		local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
		if hold_beauty_npcid <= 0 then
			Scene.Instance:GetMainRole():ChangeToCommonState()
		end
		GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 2, false, scene_key, is_speed_up)
		--GuajiCtrl.Instance:DoMoveByClick(target.x, target.y, target.scene, 4, 2, false, scene_key, is_speed_up, true)
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
	if OpenFunData.Instance:CheckIsHide("daily") and TaskData.Instance:GetTaskCount(TASK_TYPE.RI) <= 0 then
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

function MainUIViewTask:OnMainRolePosChange(role_x, role_y)
	local task_info_list = TaskData.Instance:GetTaskAcceptedInfoList()
	for k,v in pairs(task_info_list) do
		local task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
		if task_cfg then
			if TASK_ACCEPT_OP.HOLD_BEAUTY == task_cfg.accept_op and "" ~= task_cfg.a_param2 then
				local scene_data = Split(task_cfg.a_param2, "#")
				local scene_id = tonumber(scene_data[1] or 0)
				local x = tonumber(scene_data[2] or 0)
				local y = tonumber(scene_data[3] or 0)
				local w = tonumber(scene_data[4] or 0)
				local h = tonumber(scene_data[5] or 0)
				
				local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0

				local role_scene_id = Scene.Instance:GetSceneId()
				if role_scene_id == scene_id and GameMath.IsInRect(role_x, role_y, x, y, w, h) and hold_beauty_npcid > 0 then
					if GameMath.IsInRect(role_x, role_y, x, y, w, h) then
						if self.role_pos_change then
							GlobalEventSystem:UnBind(self.role_pos_change)
							self.role_pos_change = nil
						end
						TaskCtrl.SendTaskCommit(task_cfg.task_id)
						IS_HUN_BEAUTY = false
					end
				end
				break
			end
		end
	end
end

function MainUIViewTask:CompletedSceneEventLogic(task_id)
	local task_vo = TaskData.Instance:GetDiaoQiaoTask(PlayerData.Instance.role_vo.camp)
	if task_vo and task_id == task_vo.task_id then
		Scene.Instance:SceneEventLogic(Scene.Instance:GetSceneId())
	end
end

--------------------------------------------------------------- MainUIViewTaskInfo ------------------------------------------------------------

MainUIViewTaskInfo = MainUIViewTaskInfo or BaseClass(BaseCell)

function MainUIViewTaskInfo:__init()
	--self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

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
	self.is_show_arrow = false
	self.data_index = 0
	self.effect_task = 0

	self.is_zhuxian = self:FindVariable("IsZhuXian")
	self.is_richang = self:FindVariable("IsRiChang")
	self.is_yunbiao = self:FindVariable("IsYunBiao")
	self.is_yingjiu = self:FindVariable("IsYingJiu")
	self.is_citan = self:FindVariable("IsCiTan")
	self.is_banzhuan = self:FindVariable("IsBanZhuan")
	self.is_junxian = self:FindVariable("IsJunXian")
	self.is_zhong = self:FindVariable("IsZhong")
	self.is_select = self:FindVariable("IsSelect")

	-- self:ListenEvent("OnClickListen", BindTool.Bind(self.OnClickListen, self))
	self:AddClickEventListener(BindTool.Bind(self.OnClickListen, self))
end

function MainUIViewTaskInfo:__delete()
	self:RemoveCountDown()

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

-- function MainUIViewTaskInfo:ListenClick(handler)
-- 	self:ClearEvent("Click")
-- 	self:ListenEvent("Click",
-- 		function()
-- 			self.guide_effect:SetValue(false)
-- 			self:SetShowHelpArrowEff(false)
-- 			handler:OnTaskCellClick(self.data)
-- 			if self.effect_task > 0 then
-- 				CLICK_EFFECT_TASK = self.effect_task
-- 			end
-- 		end
-- 	)
-- end

function MainUIViewTaskInfo:OnClickListen()
	self.guide_effect:SetValue(false)
	self:SetShowHelpArrowEff(false)

	if self.handler ~= nil then
		self.handler:OnTaskCellClick(self.data)
		if self.data_index ~= nil then
			self.handler:SetTaskSelect(self.data_index)
		end
	end
	
	if self.effect_task > 0 then
		CLICK_EFFECT_TASK = self.effect_task
	end	
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

function MainUIViewTaskInfo:CheckIsSelect(index)
	if index ~= nil and self.data_index ~= nil then
		self:SetToggleSwitch(index == self.data_index)
	end
end

function MainUIViewTaskInfo:SetShowArrowEff(is_show)
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

function MainUIViewTaskInfo:SetItemData(data)
	if self.item_cell == nil then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	end

	self.item_cell:SetData(data)
end

local old_level = 0
function MainUIViewTaskInfo:OnFlush()
	self.quick:SetValue(false)
	self.show_item:SetValue(false)
	self.guide_effect:SetValue(false)
	self.is_zhuxian:SetValue(false)
	self.is_richang:SetValue(false)
	self.is_yunbiao:SetValue(false)
	self.is_yingjiu:SetValue(false)
	self.is_citan:SetValue(false)
	self.is_banzhuan:SetValue(false)
	self.is_junxian:SetValue(false)
	self.is_zhong:SetValue(false)
	self:SetTaskEffectFlag()
	if nil == self.data then
		return
	end

	local data = self.data
	--self.quick:SetValue(data.task_type == TASK_TYPE.ZHIBAO)
	self.is_zhuxian:SetValue(data.task_type == TASK_TYPE.ZHU)
	self.is_richang:SetValue(data.task_type == TASK_TYPE.RI or data.task_type == TASK_TYPE.ZHIBAO)
	self.is_yunbiao:SetValue(data.task_type == TASK_TYPE.HU)
	self.is_yingjiu:SetValue(data.task_type == TASK_TYPE.YINGJIU)
	self.is_citan:SetValue(data.task_type == TASK_TYPE.CITAN)
	self.is_banzhuan:SetValue(data.task_type == TASK_TYPE.BANZHUAN)
	self.is_junxian:SetValue(data.task_type == TASK_TYPE.JUN)
	self.is_zhong:SetValue(data.task_type == TASK_TYPE.KILLROLE)
	-- if data.task_id == -1 then --提示加入公会领取任务
	-- 	self.task_type:SetValue(Language.Task.task_type2[4])
	-- 	self.task_type_color:SetValue(Language.Task.task_type_color[4])
	-- 	self.name:SetValue(Language.Task.task_title[4])
	-- 	self.desc:SetValue(Language.Task.JoinGuild)
	-- 	return
	-- end

	if data.task_type == TASK_TYPE.RI and TASK_RI_AUTO and TaskData.Instance:GetCurTaskId() and TaskData.Instance:GetTaskConfig(TaskData.Instance:GetCurTaskId()).task_type ~= TASK_TYPE.ZHU then
		self:SetToggleSwitch(true)

		if self.handler ~= nil and self.data_index ~= nil then
			self.handler:SetTaskSelect(self.data_index)
		end
	end

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
	-- if role_level <= GameEnum.NOVICE_LEVEL and PlayerData.Instance.role_vo.hold_beauty_npcid <= 0 and
	-- 	((data.task_type == TASK_TYPE.ZHU and config and config.min_level <= role_level and CAN_SHOW_ZHU_ARROW and self.data.task_id <= 15000) 
	-- 	or (self.data.task_type == TASK_TYPE.JUN and self.data.task_id >= 29000 and self.data.task_id <= 30000 and SceneType.JunXian ~= Scene.Instance:GetSceneType()))
	-- 	 then
	-- 		self:SetShowArrowEff(true)
	-- else
	-- 	self:SetShowArrowEff(false)
	-- end

	if role_level >= GameEnum.MIN_NOVICE_LEVEL and role_level <= GameEnum.NOVICE_LEVEL and PlayerData.Instance.role_vo.hold_beauty_npcid <= 0 then
		if self.data.task_type == TASK_TYPE.JUN and self.data.task_id >= 29000 and self.data.task_id <= 30000 and SceneType.JunXian ~= Scene.Instance:GetSceneType() then
			self:SetShowArrowEff(true)
			self.handler:SetArrowTips(TASK_TYPE.JUN, true)
		elseif not self.handler:GetArrowTips(TASK_TYPE.JUN) and data.task_type == TASK_TYPE.ZHU and config and config.min_level <= role_level and CAN_SHOW_ZHU_ARROW and self.data.task_id <= 15000 then
			self:SetShowArrowEff(true)
			self.handler:SetArrowTips(TASK_TYPE.ZHU, true)
		else
			self:SetShowArrowEff(false)
		end
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

	self.show_zhuxian_eff:SetValue(data.task_type == TASK_TYPE.ZHU)

	self.task_type:SetValue(Language.Task.task_type2[data.task_type] or Language.Task.task_type2[1])
	self.task_type_color:SetValue(Language.Task.task_type_color[data.task_type] or Language.Task.task_type_color[1])
	if TaskData.IsXiuLianTask(data.task_id) then
		self.task_type:SetValue(Language.Task.Xiu)
		self.task_type_color:SetValue(Language.Task.XiuColor)
	end
	local task_pre_str = ""
	if data.task_type == TASK_TYPE.RI or data.task_type == TASK_TYPE.GUILD or
	 (data.task_type == TASK_TYPE.HU and not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids)) then
		local commit_count = 0
		local max_count = 0
		if data.task_type == TASK_TYPE.RI then
			max_count = MAX_DAILY_TASK_COUNT
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) + 1, max_count)
			self.quick:SetValue(true)
		elseif data.task_type == TASK_TYPE.GUILD then
			max_count = TaskData.Instance:GetMaxGuildTaskCount()
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) + 1, max_count)
			--self.quick:SetValue(true)
		elseif data.task_type == TASK_TYPE.HU then
			max_count = YunbiaoData.Instance:GetHusongRemainTimes() + YunbiaoData.Instance:GetLingQuCishu()
			commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
		end
		task_pre_str = "(<color=#ffffff>" .. commit_count .. "/" .. max_count.. "</color>)"
	end

	if config then
		if TaskData.IsZhiTask(data) then
			local reward_list = config["prof_list" .. GameVoManager.Instance:GetMainRoleVo().prof]
			--self.item_cell:SetData(reward_list[0])
			self:SetItemData(reward_list[0])
			self.show_item:SetValue(nil ~= reward_list[0])
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
				self.desc:SetValue(string.format(Language.Task.FinishExp, CommonDataManager.ConverMoney(exp)))
			elseif data.task_type == TASK_TYPE.GUILD and TaskData.DoGuildTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				local reward_cfg = TaskData.Instance:GetTaskReward(data.task_type)
				local exp = reward_cfg and reward_cfg.exp or 0
				self.desc:SetValue(string.format(Language.Task.FinishExp, CommonDataManager.ConverMoney(exp * TaskData.Instance:GetMaxGuildTaskCount())))
			elseif(data.task_status == TASK_STATUS.CAN_ACCEPT) then
				-- 多NPC对话
				if config.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then
					local desc_t = Split(config.accept_desc or "", "|")
					if #desc_t > 0 then
						desc_t[0] = table.remove(desc_t, 1)
						local accept_desc = desc_t[data.progress_num] or ""
						self.desc:SetValue(accept_desc)
					end
				else
					self.desc:SetValue(config.accept_desc)
				end
			elseif data.task_status == TASK_STATUS.ACCEPT_PROCESS then
				-- 多NPC对话
				if config.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then
					local desc_t = Split(config.progress_desc or "", "|")
					if #desc_t > 0 then
						desc_t[0] = table.remove(desc_t, 1)
						local progress_desc = desc_t[data.progress_num] or ""
						local current_count = TaskData.Instance:GetProgressNum(data.task_id)
						local str = MainUIViewTask.ChangeTaskProgressString(progress_desc, current_count, config.c_param2)
						self.desc:SetValue(str)
					end
				else
					if(config.c_param2 == 0) then
						self.desc:SetValue(config.progress_desc)
					else
						local current_count = TaskData.Instance:GetProgressNum(data.task_id)
						local str = MainUIViewTask.ChangeTaskProgressString(config.progress_desc, current_count, config.c_param2)
						self.desc:SetValue(str)
					end
				end
			elseif(data.task_status == TASK_STATUS.COMMIT) then
				local color = data.task_type == TASK_TYPE.ZHI and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				-- 多NPC对话
				if config.condition == TASK_COMPLETE_CONDITION.MULTI_TALK_NPC then
					local desc_t = Split(config.commit_desc or "", "|")
					if #desc_t > 0 then
						desc_t[0] = table.remove(desc_t, 1)
						local commit_desc = desc_t[data.progress_num] or ""
						self.desc:SetValue(commit_desc)
					end
				elseif config.accept_op == TASK_ACCEPT_OP.HOLD_BEAUTY then
					local num = PlayerData.Instance.role_vo.hold_beauty_npcid > 0 and 1 or 0
					local str = MainUIViewTask.ChangeTaskProgressString(config.commit_desc, num, 1)
					self.desc:SetValue(ToColorStr(str, color))
				else
					self.desc:SetValue(ToColorStr(config.commit_desc, color))
				end
			else
				self.desc:SetValue(Language.Common.WuFaLingQu)
			end
		end
	else
		if data.task_type == TASK_TYPE.GUAJI then
			self.name:SetValue(Language.Task.GuaJiTaskName)
			local desc = Language.Task.GuaJiTaskDesc
			self.desc:SetValue(desc)
		end

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
				local format_color = num > 0 and Language.Mount.ShowGreenNum or Language.Mount.ShowRedNum
				local num_text = string.format(format_color, num)
				self.desc:SetValue(ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], num_text), TEXT_COLOR.WHITE))
			end
			if finish_num >= total_num and self.data.decs_index ~= 3 then
				self.desc:SetValue(ToColorStr(string.format(Language.Task.GetReward), TEXT_COLOR.GREEN))
			end
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

		if data.task_type == TASK_TYPE.YINGJIU then
			if data.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then
				self.name:SetValue(Language.NationalWarfare.YingJiuTitle)
				self.desc:SetValue(Language.NationalWarfare.YingJiuComplete)
			end
			local cur_task_cfg = NationalWarfareData.Instance:GetYingJiuTaskInfoBySeq(data.task_seq)
			if not cur_task_cfg then return end
			self.name:SetValue(cur_task_cfg.task_name)
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local param1 = cur_task_cfg["camp" .. main_role_vo.camp .. "_param1"]				-- aim 1:2:3 = npc_id : 采集物id : 怪物id
			local param2 = cur_task_cfg["camp" .. main_role_vo.camp .. "_param2"]				-- aim 1:2:3 = 无意义 : 采集次数 : 杀怪数量
			local desc_str = ""
			local target_cfg = {}

			if cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_TOUCH_NPC then
				target_cfg = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list[param1]
			elseif cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AMI_GATHER then
				target_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[param1]
			elseif cur_task_cfg.aim == CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_KILL_MONSTER then
				target_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[param1]
			end

			if not target_cfg or not next(target_cfg) then
				return 
			end
			local target_desc = string.format(cur_task_cfg.task_story, target_cfg.show_name or target_cfg.name)
			if param2 > 1 then
				target_desc = target_desc .. "(" .. data.param1 .. "/" .. param2 .. ")"
			end
			self.desc:SetValue(target_desc)
		end
		if data.task_type == TASK_TYPE.BANZHUAN then
			self.name:SetValue(data.task_name)
			self.desc:SetValue(data.task_info)
		elseif data.task_type == TASK_TYPE.CITAN then
			self.name:SetValue(data.task_name)
			self.desc:SetValue(data.task_info)
		elseif data.task_type == TASK_TYPE.KILLROLE then
			self.name:SetValue(data.task_name)
			self.desc:SetValue(data.task_desc)
		end

		if data.task_type == TASK_TYPE.ZHIBAO then
			self.quick:SetValue(false)
			self.name:SetValue(Language.Task.MeiRiBiZuoTask[1])
			self.desc:SetValue(Language.Task.MeiRiBiZuoTask[2])
			self.guide_effect:SetValue(false)
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
			-- self.sell_view:SetTime(self:TimeToString(rest_of_time))

			self:CountDown(rest_of_time)
		else
			self.show_time:SetValue(false)
		end
	else
		self.show_time:SetValue(false)
	end
end

function MainUIViewTaskInfo:SetToggle(toggle_group)
	--self.root_node.toggle.group = toggle_group
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
	-- self.sell_view:SetTime(self:TimeToString(time))
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
		self.guide_effect:SetValue(self.effect_task ~= CLICK_EFFECT_TASK)
	else
		self.guide_effect:SetValue(false)
	end
end

function MainUIViewTaskInfo:SetToggleSwitch(switch)
	--self.root_node.toggle.isOn = switch or false
	if self.is_select ~= nil then
		self.is_select:SetValue(switch or false)
	end
end

function MainUIViewTaskInfo.GetTargetCfg(scene_id, target_type, target_id)
	if not scene_id or not target_type or "" == target_type then return end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	local targe_obj_list = {}
	for k,v in pairs(scene_cfg[target_type]) do
		if v.id == target_id then
			return v
			-- table.insert(targe_obj_list, v)		
		end
	end
	-- local target = targe_obj_list[math.floor(math.random(1, #targe_obj_list))]
	-- return target
end
