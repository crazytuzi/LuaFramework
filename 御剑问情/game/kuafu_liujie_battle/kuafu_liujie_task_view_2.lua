KuafuGuildTaskDailyView = KuafuGuildTaskDailyView or BaseClass(BaseView)
KuafuGuildTaskDailyView.GatherId = 0
function KuafuGuildTaskDailyView:__init()
	self.active_close = false
	self.view_layer = UiLayer.MainUI
	self.ui_config = {"uis/views/kuafuliujie_prefab","LiuJieSceneView2"}

	self.fight_state_button_handle = nil
end

function KuafuGuildTaskDailyView:ReleaseCallBack()
	self.scroller = nil
	
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

	self.show_panel = nil
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.boss_cell_list) do
		v:DeleteMe()
	end
	self.boss_cell_list = {}
	if self.change_scene then
		GlobalEventSystem:UnBind(self.change_scene)
	end
	self.change_scene  = nil
	self.task_list = nil
	self.select_index = nil

	GlobalEventSystem:UnBind(self.fight_state_button_handle)
	self.fight_state_button_handle = nil
	self.show_task = nil
	self.boss_toggle = nil
	self.task_toggle = nil
end

function KuafuGuildTaskDailyView:LoadCallBack()
	self:InitScroller()
	self:InitBoss()
	self.show_panel = self:FindVariable("ShowPanel")
	self:ListenEvent("TaskToggleChange", BindTool.Bind(self.TaskToggleChange, self))
	self.auto_task_id = nil
	self.select_index = 0

	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.change_scene = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.clear_task_toggle = GlobalEventSystem:Bind(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self:ListenEvent("OnClickTask", BindTool.Bind(self.OnClickTask,self))

	self.fight_state_button_handle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.CheckFightState, self))
	self.task_toggle = self:FindObj("TaskToggle")
	self.boss_toggle = self:FindObj("BOSSToggle")
	self.show_task = self:FindVariable("ShowTask")
end

function KuafuGuildTaskDailyView:CheckFightState(is_on)
	if self.root_node then
		self.root_node:SetActive(not is_on)
	end
end

function KuafuGuildTaskDailyView:OnStopGather()
	self.is_gather = false
	if KuafuGuildTaskDailyView.GatherId > 0 and Scene.Instance:GetMainRole():IsStand() then
		self:AutoDoTask()
	end
end

function KuafuGuildTaskDailyView:OnStartGather()
	self.is_gather = true
end

function KuafuGuildTaskDailyView:CloseCallBack()
	KuafuGuildTaskDailyView.GatherId = 0
end

function KuafuGuildTaskDailyView:OpenCallBack()
	self.select_index = 0
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
	self:ChangeToggleState()
end

function KuafuGuildTaskDailyView:TaskToggleChange(isOn)
	if isOn then
		self:Flush()
	end
end

function KuafuGuildTaskDailyView:ClearToggle()
	if self.auto_task_id then
		local data = self:GetTaskDataByID(self.auto_task_id)
		if data and data.cfg.task_type == 1 or GuajiCache.guaji_type == GuajiType.None then
			self:StopAutoTask()
		end
	end
end

function KuafuGuildTaskDailyView:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
	if is_show then
		self:Flush()
	end
end

function KuafuGuildTaskDailyView:OnSceneChangeComplete()
	-- KuafuGuildBattleCtrl.Instance:CSReqMonsterGeneraterList()
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
	self:ChangeToggleState()
end

function KuafuGuildTaskDailyView:ChangeToggleState()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id ~= 1450 then
		self.task_toggle.toggle.isOn = true
		self.boss_toggle.gameObject:SetActive(false)
		self.show_task:SetValue(true)
		self.task_list.gameObject:SetActive(false)
	else
		self.show_task:SetValue(false)
		self.boss_toggle.gameObject:SetActive(true)
		self.boss_toggle.toggle.isOn = false
		self.task_list.gameObject:SetActive(true)
	end
end

local old_select_id = 0
function KuafuGuildTaskDailyView:TaskClick(task_id, is_auto)
	local data = self:GetTaskDataByID(task_id)
	GuajiCtrl.Instance:StopGuaji()
	if data == nil or data.statu == 1 or (self.auto_task_id == task_id and not is_auto) then
		self:StopAutoTask()
		return
	end

	self.auto_task_id = task_id
	old_select_id = 0
	KuafuGuildBattleData.Instance:NotifyTaskProcessChange(task_id, function ( ... )
		 GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.AutoDoTask,self), 0.1)
	end)
	self:AutoDoTask()

	self.scroller.scroller:ReloadData(0)
end

function KuafuGuildTaskDailyView:StopAutoTask()
	KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
	self.auto_task_id = nil
end

function KuafuGuildTaskDailyView:GetTaskDataByID(task_id)
	local index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
	local data = KuafuGuildBattleData.Instance:GetTaskCfgInfo(index) or {}
	local s_data = data.list or {}
	for k,v in pairs(s_data) do
		if v.cfg.task_id == task_id then
			return v
		end
	end
end

function KuafuGuildTaskDailyView:OnObjDelete(obj)
	if not self.is_gather and obj and obj:IsGather() and obj:GetGatherId() == KuafuGuildTaskDailyView.GatherId then
		GlobalTimerQuest:AddDelayTimer(function ()
			if not self.is_gather then
				self:AutoDoTask()
			end
		end, 0.1)
	end
end

function KuafuGuildTaskDailyView:AutoDoTask()

	local data = self:GetTaskDataByID(self.auto_task_id)

	if data == nil or data.statu == 1 then
		GuajiCtrl.Instance:StopGuaji()
		self.auto_task_id = nil
		local scene_index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		local task_info = KuafuGuildBattleData.Instance:GetTaskCfgInfo(scene_index).list

		if task_info then
			local info = task_info[1]
			if info then
				if not info.statu == 1 then
					self.auto_task_id = info.cfg.task_id
				end
			end
		end
		if self.auto_task_id then
			self:TaskClick(self.auto_task_id, true)
		else
			KuafuGuildTaskDailyView.GatherId = 0
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			KuafuGuildBattleData.Instance:UnNotifyTaskProcessChange()
			self:ClearToggle()
		end
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	local list = nil
	local end_type = nil
	local target = nil

	if data.cfg.task_type == 0 then
		--采集
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end_type = MoveEndType.GatherById
		list = ConfigManager.Instance:GetSceneConfig(scene_id).gathers
		target = Scene.Instance:SelectMinDisGather(data.cfg.task_param)
		KuafuGuildTaskDailyView.GatherId = data.cfg.task_param
	else
		--打怪
		list = ConfigManager.Instance:GetSceneConfig(scene_id).monsters
		end_type = MoveEndType.Auto
		target = Scene.Instance:SelectMinDisMonster(data.cfg.task_param)
		KuafuGuildTaskDailyView.GatherId = 0
	end

	local x, y, id = 0, 0, 0
	if target then
		id = data.cfg.task_param
		x, y = target:GetLogicPos()
	else
		local target_distance = 1000000
		local p_x, p_y = Scene.Instance:GetMainRole():GetLogicPos()
		for k, v in pairs(list) do
			if v.id == data.cfg.task_param  then
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
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 4, 2)
end

local is_first_set = true
function KuafuGuildTaskDailyView:OnFlush()
	self.scroller.scroller:ReloadData(0)
	self.task_list.scroller:ReloadData(0)
end

--滚动条
function KuafuGuildTaskDailyView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self.cell_list = {}

	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		local index =KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		if index == nil then 
			return
		end
		return #KuafuGuildBattleData.Instance:GetTaskCfgInfo(index).list
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local scene_index = KuafuLiuJieSceneId[Scene.Instance:GetSceneId()]
		-- print_error(scene_index)
		if scene_index == nil then 
			return
		end
		local s_data = KuafuGuildBattleData.Instance:GetTaskCfgInfo(scene_index).list
		-- print_error(s_data)
		data_index = data_index + 1
		if self.cell_list[cell] == nil then
			self.cell_list[cell] = KuafuGuidTaskItem.New(cell.gameObject)
			self.cell_list[cell].mother_view =self
			self.cell_list[cell].toggle.group = self.scroller.toggle_group
		end
		local data = s_data[data_index]
		-- print_error(data_index)
		self.cell_list[cell]:SetData(data)
	end
end

function KuafuGuildTaskDailyView:InitBoss()
	self.task_list = self:FindObj("TaskList")
	self.boss_cell_list = {}

	local delegate = self.task_list.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #KuafuGuildBattleData.Instance:GetBossList()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local s_data = KuafuGuildBattleData.Instance:GetBossList()
		-- print_error(s_data)
		data_index = data_index + 1
		if self.boss_cell_list[cell] == nil then
			self.boss_cell_list[cell] = BossLiujieItem.New(cell.gameObject,self)
			self.boss_cell_list[cell].mother_view =self
		end
		self.boss_cell_list[cell]:SetItemIndex(self.boss_cell_list[cell])
		local data = s_data[data_index]
		self.boss_cell_list[cell]:SetData(data)
	end
end

function KuafuGuildTaskDailyView:SetSelectIndex(index)
	self.select_index = index
end

function KuafuGuildTaskDailyView:GetSelectIndex(index)
	return self.select_index
end

function KuafuGuildTaskDailyView:FlushCellHl()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHl()
	end
end

function KuafuGuildTaskDailyView:OnClickTask()
	ViewManager.Instance:Open(ViewName.KuafuTaskRecordView)
end


--滚动条格子------------------------------------------------------
KuafuGuidTaskItem = KuafuGuidTaskItem or BaseClass(BaseRender)

function KuafuGuidTaskItem:__init()
	self.task_name = self:FindVariable("TaskName")
	self.is_gather = self:FindVariable("IsGather")
	self.task_target = self:FindVariable("TaskTarget")
	self.is_finish = self:FindVariable("IsFinish")
	self.reward_text = self:FindVariable("reward_text")
	self.toggle = self.root_node.toggle

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function KuafuGuidTaskItem:__delete()
	self.mother_view = nil
end


function KuafuGuidTaskItem:OnClick()
	self.mother_view:TaskClick(self.data.cfg.task_id)
end

function KuafuGuidTaskItem:OnFlush()
	self.task_name:SetValue(self.data.cfg.name)
	self.is_gather:SetValue((self.data.cfg.task_type == 0))
	local str = self.data.cfg.task_content
	-- print_error(self.data)
	local target_text = "(" ..self.data.record .. "/" .. self.data.cfg.task_count .. ")"
	self.task_target:SetValue("<color=#ffffff>" .. str .. "</color>" .. target_text)
	self.is_finish:SetValue(self.data.statu == 1)
	self.reward_text:SetValue(self.data.cfg.reward_credit)
	self.toggle.isOn = (self.mother_view.auto_task_id == self.data.cfg.task_id)
end

function KuafuGuidTaskItem:SetData(data)
	self.data = data
	self:Flush()
end

BossLiujieItem = BossLiujieItem or BaseClass(BaseRender)

function BossLiujieItem:__init(instance, parent)
	self.parent = parent
	self.desc = self:FindVariable("Desc")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_hl = self:FindVariable("show_hl")
	self.time_color = self:FindVariable("TimeColor")
	self.level_text = self:FindVariable("Level")
	self.index = 0
	self.next_refresh_time = 0
	self:ListenEvent("Click", BindTool.Bind(self.ClickKill, self))
end

function BossLiujieItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
	self.mother_view = nil
end

function BossLiujieItem:ClickKill(is_click)
	
	-- if self.data.next_refresh_time > 0 then
	-- 	return
	-- end
	-- self.parent:SetMonitorBoss(self)
	self:ClickKillCallBack(self.pos_x, self.pos_y)
	
end

function BossLiujieItem:ClickKillCallBack(born_x,born_y)
	if self.data == nil then return end
	self.mother_view:SetSelectIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), born_x, born_y, 10, 10)

	self.mother_view:FlushCellHl()
end

function BossLiujieItem:SetData(data)
	self.data = data
	local scene_id = Scene.Instance:GetSceneId()
	-- print_error(scene_id)
	local list = KuafuGuildBattleData.Instance:GetBossCfg()
	for k,v in pairs(list) do
		if v.boss_id == self.data.boss_id then
			self:SetPos(v.born_x, v.born_y)
		end
	end
	self:Flush()
end

function BossLiujieItem:FlushHl()
	self.show_hl:SetValue(self.index == self.mother_view:GetSelectIndex())
end


function BossLiujieItem:SetItemIndex(index)
	self.index = index
end

function BossLiujieItem:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end
	-- print_error(self.data)

	local boss_data = self.data
	if boss_data then
		self.flush_time = self.data.next_refresh_time
		self.statu = self.data.status
		-- self.time_color:SetValue(self.statu == 1 and TEXT_COLOR.GREEN_3 or "#ff0000ff")
		-- self.next_refresh_time = boss_data.next_refresh_time
		if self.flush_time <= 0 or self.statu == 1 then
			self.time:SetValue(ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN))
		else
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
		-- local reward = BossData.Instance:GetRewardById(self.data.boss_id)
		-- reward = ToColorStr(reward,TEXT_COLOR.GREEN)
		local scene_id = Scene.Instance:GetSceneId()
		local config = ConfigManager.Instance:GetSceneConfig(scene_id)

		local pos = config.name .. "(" .. self.pos_x .. "," .. self.pos_y .. ")"
		self.desc:SetValue(pos)
	end
	self.show_hl:SetValue(self.index == self.mother_view:GetSelectIndex())
end


function BossLiujieItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	self.statu = self.data.status
	if time <= 0 or self.statu == 1 then
		self.time:SetValue(ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN1))
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function BossLiujieItem:SetPos(x, y)
	self.pos_x = x
	self.pos_y = y
end