TombExploreFBView = TombExploreFBView or BaseClass(BaseView)
TombExploreFBView.GatherId = 0
function TombExploreFBView:__init()
	self.ui_config = {"uis/views/tombexplore_prefab","TombExploreFBView"}
	self.last_task_count = 0
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function TombExploreFBView:ReleaseCallBack()
	self.scroller = nil
	GlobalTimerQuest:CancelQuest(self.time_quest)
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.clear_task_toggle ~= nil then
		GlobalEventSystem:UnBind(self.clear_task_toggle)
		self.clear_task_toggle = nil
	end

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.start_gather_event)
		self.start_gather_event = nil
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.boss_toggle = nil
	self.is_boss_spawn = nil
	self.is_having_boss = nil
	self.show_panel = nil
	self.boss_flush_time = nil
	self.boss_name = nil
end

function TombExploreFBView:LoadCallBack()
	self:ListenEvent("ExitClick", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("TeamClick", BindTool.Bind(self.TeamClick, self))
	self:ListenEvent("BOSSClick", BindTool.Bind(self.BOSSClick, self))
	self:ListenEvent("TaskToggleChange", BindTool.Bind(self.TaskToggleChange, self))

	self.left_time = self:FindVariable("LeftTime")
	self.boss_flush_time = self:FindVariable("BOSSFlushTime")
	self.boss_over = self:FindVariable("BOSSOver")
	self.is_having_boss = self:FindVariable("IsHavingBOSS")
	self.is_boss_spawn = self:FindVariable("IsSpawnBOSS")
	-- self.show_victory_panel = self:FindVariable("ShowVictoryPlane")
	self.boss_name = self:FindVariable("BossName")

	-- self.show_victory_panel:SetValue(false)

	self.boss_toggle = self:FindObj("BOSSToggle")

	self.time_count = -100
	self.boss_time_count = 0
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)

	-- self.reward_list = {}
	-- local item_manager = self:FindObj("ItemManger")
	-- local child_number = item_manager.transform.childCount
	-- local count = 1
	-- for i = 0, child_number - 1 do
	-- 	local obj = item_manager.transform:GetChild(i).gameObject
	-- 	if string.find(obj.name, "ItemCell") ~= nil then
	-- 		self.reward_list[count] = ItemCellReward.New(obj)
	-- 		count = count + 1
	-- 	end
	-- end

	self.auto_task_id = nil
	self.item_cell_list = {}
	local items_cfg = TombExploreData.Instance:GetTombActivityOtherCfg().boss_item_id
	for i=1,3 do
		self.item_cell_list[i] = ItemCell.New(self:FindObj("item_"..i))
		local item_data = {}
		item_data.item_id = items_cfg[i-1].item_id
		item_data.num = items_cfg[i-1].num
		item_data.is_bind = items_cfg[i-1].is_bind
		item_data.is_gray = false
		item_data.is_up_arrow = false
		self.item_cell_list[i]:SetData(item_data)
	end

	self:InitScroller()
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.clear_task_toggle = GlobalEventSystem:Bind(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
end

function TombExploreFBView:OnStopGather()
	self.is_gather = false
	if TombExploreFBView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function TombExploreFBView:OnStartGather()
	self.is_gather = true
end

function TombExploreFBView:CloseCallBack()
	TombExploreFBView.GatherId = 0
end

function TombExploreFBView:OpenCallBack()
	local tomb_data = TombExploreData.Instance
	self.boss_name:SetValue(tomb_data:GetBossName(tomb_data:GetBossCfg().boss_id))
end

function TombExploreFBView:TaskToggleChange(isOn)
	if isOn then
		self:Flush()
	end
end

--寻路至BOSS
function TombExploreFBView:BOSSClick()
	local boss_x, boss_y, boss_id = TombExploreData.Instance:GetBOSSInfo()
	local scene_id = Scene.Instance:GetSceneId()

	MoveCache.end_type = MoveEndType.Auto
	MoveCache.param1 = boss_id
	MoveCache.task_id = 0
	GuajiCache.target_obj_id = boss_id
	GuajiCtrl.Instance:MoveToPos(scene_id, boss_x, boss_y, 4, 2)
end

function TombExploreFBView:ClearToggle()
	if self.auto_task_id then
		local data = self:GetTaskDataByID(self.auto_task_id)
		if data.cfg.task_type == 1 or GuajiCache.guaji_type == GuajiType.None then
			self.scroller.toggle_group:SetAllTogglesOff()
			self:StopAutoTask()
		end
	end
end

function TombExploreFBView:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
	if is_show then
		self:Flush()
	end
end

local old_select_id = 0
function TombExploreFBView:TaskClick(task_id, is_auto)
	local data = self:GetTaskDataByID(task_id)
	GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.is_finish or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		return
	end

	self.auto_task_id = task_id
	old_select_id = 0
	TombExploreData.Instance:NotifyTaskProcessChange(task_id, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TombExploreFBView:StopAutoTask()
	TombExploreData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end

function TombExploreFBView:GetTaskDataByID(task_id)
	local data = nil
	local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function TombExploreFBView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == TombExploreFBView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function TombExploreFBView:AutoDoTask()
	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil or data.is_finish then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local task_info = TombExploreData.Instance:GetTombFBTaskInfo()
		if task_info then
			local info = task_info[1]
			if info then
				if not info.is_finish then
					self.auto_task_id = info.cfg.task_id
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.auto_task_id, true)
		else
			TombExploreFBView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			TombExploreData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil

	if data.cfg.task_type == 1 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.param_id)
		TombExploreFBView.GatherId = data.cfg.param_id
	else
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.param_id)
		TombExploreFBView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = data.cfg.param_id
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == data.cfg.param_id  then
				if not AStarFindWay:IsBlock(v.x, v.y) then
					local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
					if distance < target_distance then
						target_distance = distance
						x = v.x
						y = v.y
						id = v.id
					end
				end
			end
		end
	end
	MoveCache.end_type = end_type
	MoveCache.param1 = id
	MoveCache.task_id = 0
	GuajiCache.target_obj_id = id
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 2, 1)
end

local is_first_set = true
function TombExploreFBView:OnFlush()
	if not self:IsLoaded() then
		return
	end
	local fb_info = TombExploreData.Instance:GetTombFBInfo()
	--限时奖励时间
	local tmp_time = math.floor(fb_info.limit_task_time - TimeCtrl.Instance:GetServerTime())
	if tmp_time > 0 then
		self.time_count = tmp_time
	end
	--是否会刷新BOSS
	self.is_boss_spawn:SetValue(TombExploreData.Instance:GetIsSpawnBOSS())
	--是否有BOSS
	self.is_having_boss:SetValue(fb_info.boss_num > 0)
	--BOSS刷新时间
	FuBenCtrl.Instance:SetMonsterInfo(TombExploreData.Instance:GetBossCfg().boss_id)
	local call_back = function()
		self:BOSSClick()
	end
	FuBenCtrl.Instance:SetMonsterClickCallBack(call_back)
	local tmp_time2 = math.floor(fb_info.boss_reflush_time - TimeCtrl.Instance:GetServerTime())
	if tmp_time2 > 0 then
		self.boss_time_count = tmp_time2
		self:SetTime()
		FuBenCtrl.Instance:SetMonsterDiffTime(self.boss_time_count)
		FuBenCtrl.Instance:ShowMonsterHadFlush(false)
	else
		FuBenCtrl.Instance:ShowMonsterHadFlush(true)
	end
	--任务滚动条
	if self.scroller and self.scroller.scroller.isActiveAndEnabled then
		-- print(ToColorStr("##############", TEXT_COLOR.GREEN))
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	--结算面板
	local show_victory = false
	for k,v in pairs(fb_info.item_list) do
		if v.item_id ~= 0 then
			show_victory = true
			break
		end
	end
	if show_victory then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		-- self.show_victory_panel:SetValue(true)
		-- local count = 1
		-- for k,v in pairs(fb_info.item_list) do
		-- 	if v.num > 0 then
		-- 		self.reward_list[count]:SetActive(true)
		-- 		self.reward_list[count]:SetData(v)
		-- 		count = count + 1
		-- 		if count > #self.reward_list then
		-- 			break
		-- 		end
		-- 	end
		-- end
		-- if count <= #self.reward_list then
		-- 	for i=count, #self.reward_list do
		-- 		self.reward_list[i]:SetActive(false)
		-- 	end
		-- end
	end
	--奇遇完成时跳到BOSS
	if TombExploreData.Instance:IsTaskAllDone() and self.boss_toggle.toggle.isActiveAndEnabled then
		if is_first_set then
			is_first_set = false
			self.boss_toggle.toggle.isOn = true
		end
	else
		is_first_set = true
	end
end

--BOSS刷新计时
function TombExploreFBView:Timer()
	if self.time_count ~= -100 then
		if self.time_count > 0 then
			self.time_count = self.time_count - 1
			for k,v in pairs(self.cell_list) do
				v:SetDoubleRewardTime(self.time_count)
			end
		else
			self.time_count = -100
			self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end

	self.boss_time_count = self.boss_time_count - 1
	self:SetTime()
end

--滚动条
function TombExploreFBView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self.cell_list = {}

	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #(TombExploreData.Instance:GetTombFBTaskInfo())
	end
	--大小
	delegate.CellSizeDel = function(dataIndex)
		dataIndex = dataIndex + 1
		local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
		if s_data[dataIndex].is_double_reward and
			not s_data[dataIndex].is_finish and
			self.time_count > 0 then
			return 120
		else
			return 85
		end
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local s_data = TombExploreData.Instance:GetTombFBTaskInfo()
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = TombExploreScrollerCell.New(cell.gameObject)
			self.cell_list[cell].mother_view = self
			self.cell_list[cell].toggle.group = self.scroller.toggle_group
		end
		local data = s_data[data_index]
		data.data_index = data_index
		self.cell_list[cell]:SetData(data)
	end
end

--BOSS时间赋值
function TombExploreFBView:SetTime()
	local boss_time_count_text = ""
	local h2, m2, s2 = WelfareData.Instance:TimeFormat(self.boss_time_count)
	boss_time_count_text = self:TimeWithZero(h2)..":"..self:TimeWithZero(m2)..":"..self:TimeWithZero(s2)
	-- local activity_rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.TOMB_EXPLORE) or 0
	-- if self.boss_time_count > 0 and self.boss_time_count <= activity_rest_time then
	if self.boss_time_count > 0 then
		self.boss_flush_time:SetValue(boss_time_count_text)
	else
		self.boss_flush_time:SetValue("")
		-- FuBenCtrl.Instance:SetMonsterDiffTime(0)
	end
end

--把时间换成"01"格式
function TombExploreFBView:TimeWithZero(num)
	if num < 0 then
		return "00"
	end

	if num >= 10 then
		return num
	else
		return "0"..num
	end
end

function TombExploreFBView:TeamClick()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function TombExploreFBView:ExitClick()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

--滚动条格子------------------------------------------------------
TombExploreScrollerCell = TombExploreScrollerCell or BaseClass(BaseCell)

function TombExploreScrollerCell:__init()
	self.task_name = self:FindVariable("TaskName")
	self.is_gather = self:FindVariable("IsGather")
	self.task_target = self:FindVariable("TaskTarget")
	self.is_double_reward = self:FindVariable("IsDoubleReward")
	self.double_reward_time = self:FindVariable("DoubleRewardTime")
	self.is_finish = self:FindVariable("IsFinish")
	self.toggle = self.root_node.toggle

	self.item = self:FindObj("ItemCell")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item)

	self:ListenEvent("ToggleChange", BindTool.Bind(self.ToggleChange, self))
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function TombExploreScrollerCell:__delete()
	self.mother_view = nil
	self.item = nil
	
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TombExploreScrollerCell:SetDoubleRewardTime(time)
	if self.data.is_double_reward then
		self.double_reward_time:SetValue(time)
	end
end

function TombExploreScrollerCell:ToggleChange(is_On)
	-- if is_On then
	-- 	self.mother_view:TaskClick(self.data.cfg.task_id)
	-- else
	-- 	self.mother_view:StopAutoTask()
	-- end
end

function TombExploreScrollerCell:OnClick()
	self.mother_view:TaskClick(self.data.cfg.task_id)
end

function TombExploreScrollerCell:OnFlush()
	if not self.data and not self.data.cfg.task_id then return end

	local task_cfg = TombExploreData.Instance:GetTaskCfgByID(self.data.cfg.task_id)

	if task_cfg and task_cfg.reward_item then
		self.item_cell:SetData(task_cfg.reward_item[0])
	end
	

	self.task_name:SetValue(self.data.cfg.task_name)
	self.is_gather:SetValue((self.data.cfg.task_type == 1))
	local str = self.data.cfg.task_type == 1 and Language.TombExplore.CHAIJI or Language.TombExplore.Kill
	self.task_target:SetValue("<color=#ffffff>" .. str .. "</color>" .. self.data.target_text)
	self.is_finish:SetValue(self.data.is_finish)

	self.toggle.isOn = (self.mother_view.auto_task_id == self.data.cfg.task_id)

	if self.mother_view.time_count > 0 then
		self.is_double_reward:SetValue(self.data.is_double_reward)
	else
		self.is_double_reward:SetValue(false)
	end
end
