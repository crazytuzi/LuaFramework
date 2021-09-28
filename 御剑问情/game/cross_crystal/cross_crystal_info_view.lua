
CrossCrastalInfoView = CrossCrastalInfoView or BaseClass(BaseView)

function CrossCrastalInfoView:__init()
	self.ui_config = {"uis/views/crosscrystalview_prefab","CrossCrastalInfoView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function CrossCrastalInfoView:__delete()
	self.cur_task_id = -1
end

function CrossCrastalInfoView:LoadCallBack()
	self.cur_task_id = -1
	self.score_info = CrossCrystalScoreInfoView.New(self:FindObj("ScorePerson"))
	self.shrink_button_toggle = self:FindObj("ShrinkButton").toggle
	self.task_parent = self:FindObj("TaskParent")
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
	self.move_click_event = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK,
		BindTool.Bind(self.MoveByClick, self))
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE,
		BindTool.Bind(self.OnLevelChange, self))

	self.task_cell_list = {}
	self:InitTask()
	self:FlushTask()
end

function CrossCrastalInfoView:ReleaseCallBack()
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	if self.stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.stop_gather_event)
		self.stop_gather_event = nil
	end

	if self.start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.start_gather_event)
		self.start_gather_event = nil
	end

	if self.move_click_event ~= nil then
		GlobalEventSystem:UnBind(self.move_click_event)
		self.move_click_event = nil
	end

	if self.level_change_event ~= nil then
		GlobalEventSystem:UnBind(self.level_change_event)
		self.level_change_event = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.task_cell_list then
		for k,v in pairs(self.task_cell_list) do
			v:DeleteMe()
		end
	end
	self.task_cell_list = {}

	self.task_parent = nil
	self.scroller = nil
	self.shrink_button_toggle = nil
end

function CrossCrastalInfoView:OpenCallBack()
	self.is_auto = false
	local info = CrossCrystalData.Instance:GetCrystalInfo()
	if info.next_time ~= 0 then
		FuBenCtrl.Instance:SetCountDownByTotalTime(info.next_time - TimeCtrl.Instance:GetServerTime())
	end
	MainUICtrl.Instance.view:SetViewState(false)
	self:Flush()
end

function CrossCrastalInfoView:MoveByClick()
	if self.cur_task_id ~= -1 then
		self.is_auto = false
		self.cur_task_id = -1
		self:FlushAllHl()
	end
end

function CrossCrastalInfoView:OnLevelChange()
	self:Flush()
end

function CrossCrastalInfoView:OnStartGather(role_obj_id, gather_obj_id)
	self.cur_obj_id = gather_obj_id
	self.is_gather = true
end

function CrossCrastalInfoView:OnStopGather()
	self.is_gather = false
end

--延时0.5是因为 OnObjDelete比OnStopGather早来
function CrossCrastalInfoView:OnObjDelete(obj)
	if self.is_gather == true and obj and obj:IsGather() and obj:GetObjId() == self.cur_obj_id then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.time_quest = GlobalTimerQuest:AddDelayTimer(function ()
			if self.is_gather == false then
				if self.is_auto == true then
					self:MoveToGather()
				end
			end
		end, 0.5)
	end
end

function CrossCrastalInfoView:MoveToGather(task_id)
	if task_id then
		self.index = task_id + 1
	end
	local task_id = task_id or CrossCrystalData.Instance:GetNextTaskId(self.cur_task_id)
	if task_id ~= -1 then
		self.cur_task_id = task_id
		local gather_id = CrossCrystalData.Instance:GetMinGatherId(task_id)
		if gather_id ~= 0 then
			self.cur_gather_id = gather_id
			local target_obj = Scene.Instance:SelectMinDisGather(gather_id)
			if target_obj then
				MoveCache.end_type = MoveEndType.Gather
				GuajiCtrl.Instance:MoveToObj(target_obj)
			else  --视野内找不到采集物, 发送请求全图采集物协议
				local scene_id = Scene.Instance:GetSceneId()
				CrossCrystalCtrl.SendReqGatherGeneraterList(scene_id)
			end
		end
	else
		self.is_auto = false
		self.cur_task_id = -1
		GuajiCtrl.Instance:StopGuaji()
	end
	self:FlushAllHl()
end

function CrossCrastalInfoView:SetAutoTask(is_auto)
	self.is_auto = is_auto
end

function CrossCrastalInfoView:GetCurTaskId()
	return self.cur_task_id
end

function CrossCrastalInfoView:CloseCallBack()
	self.is_auto = false
	MainUICtrl.Instance.view:SetViewState(true)
end

--协议下发全图采集物后,移动到视野外采集
function CrossCrastalInfoView:GoOutOfSignToGather()
	local gather_info_list = CrossCrystalData.Instance:GetMinDistGatherPos(self.cur_task_id)
	if gather_info_list and gather_info_list.gather_id then
		MoveCache.param1 = gather_info_list.gather_id
		MoveCache.end_type = MoveEndType.GatherById
		local scene_id = Scene.Instance:GetSceneId()
		GuajiCtrl.Instance:MoveToPos(scene_id, gather_info_list.pos_x, gather_info_list.pos_y)
	else
		self.cur_task_id = -1
	end
end

function CrossCrastalInfoView:ActivityCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.SHUIJING then
		if status == ACTIVITY_STATUS.OPEN then
			FuBenCtrl.Instance:SetCountDownByTotalTime(next_time - TimeCtrl.Instance:GetServerTime())
		else
			FuBenCtrl.Instance:SetCountDownByTotalTime(0)
		end
	end
end

function CrossCrastalInfoView:MianUIOpenComlete()
	MainUICtrl.Instance.view:SetViewState(false)
	self:Flush()
end
function CrossCrastalInfoView:OnFlush(param_t)
	self.score_info:Flush()
	self:FlushTask()
end

function CrossCrastalInfoView:SwitchButtonState(enable)
	-- if self.shrink_button_toggle and self:IsOpen() then
	-- 	self.shrink_button_toggle.isOn = not enable
	-- end
	self.task_parent:SetActive(enable)
end


function CrossCrastalInfoView:InitTask()
	self.scroller = self:FindObj("Scroller")

	local list_delegate = self.scroller.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function CrossCrastalInfoView:GetNumberOfCells()
	return CrossCrystalData.Instance:GetCrystalTaskInfo().task_num
end

function CrossCrastalInfoView:RefreshCell(cell, data_index, cell_index)
	local task_cell = self.task_cell_list[cell]
	if task_cell == nil then
		task_cell = CrossCrystalScrollerCell.New(cell.gameObject, self)
		self.task_cell_list[cell] = task_cell
	end
	data_index = data_index + 1
	task_cell:SetIndex(data_index)
	task_cell:Flush()
end

function CrossCrastalInfoView:SetCurGatherId(cur_gather_id)
	self.cur_gather_id = cur_gather_id
end

function CrossCrastalInfoView:SetCurIndex(index)
	self.index = index
end

function CrossCrastalInfoView:FlushTask()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end

function CrossCrastalInfoView:FlushAllHl()
	for k,v in pairs(self.task_cell_list) do
		v:FlushHl()
	end
end

----------------------View----------------------
CrossCrystalScoreInfoView = CrossCrystalScoreInfoView or BaseClass(BaseRender)
function CrossCrystalScoreInfoView:__init()
	self.count = self:FindVariable("Count")
	self.bind_gold = self:FindVariable("BindGold")
	self.mojing = self:FindVariable("Mojing")
	self.honor = self:FindVariable("Honor")
	self.buff_time = self:FindVariable("BuffTime")
	self.supper_crastal = self:FindVariable("SupperCrastal")
	self:Flush()
end

function CrossCrystalScoreInfoView:__delete()
end

function CrossCrystalScoreInfoView:Flush()
	local crystal_info =  CrossCrystalData.Instance:GetCrystalInfo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1]
	self.count:SetValue(other_cfg.gather_max_times - crystal_info.cur_gather_times)
	self.bind_gold:SetValue(crystal_info.total_bind_gold)
	self.mojing:SetValue(crystal_info.total_mojing)
	self.honor:SetValue(crystal_info.total_shengwang)
	self.supper_crastal:SetValue(crystal_info.big_shuijing_num)
end

--滚动条格子------------------------------------------------------
CrossCrystalScrollerCell = CrossCrystalScrollerCell or BaseClass(BaseCell)

function CrossCrystalScrollerCell:__init(instance, view)
	self.parent = view
	self.task_name = self:FindVariable("TaskName")
	self.reward = self:FindVariable("Reward")
	self.is_finish = self:FindVariable("IsFinish")
	self.max_gathered = self:FindVariable("Max")
	self.gathered = self:FindVariable("Gathered")
	self.show_hl = self:FindVariable("ShowHl")
	self.toggle = self.root_node.toggle
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function CrossCrystalScrollerCell:__delete()
	self.parent = nil
end

function CrossCrystalScrollerCell:OnClick()
	local task_id = CrossCrystalData.Instance:GetTaskIdByIndex()[self.index]
	if not CrossCrystalData.Instance:GetTaskIsCompelete(task_id) then
		self.parent:SetAutoTask(true)
		self.parent:MoveToGather(task_id)
	end
end

function CrossCrystalScrollerCell:OnFlush(param_t)
	local shuijing_data = CrossCrystalData.Instance
	local task_id = shuijing_data:GetTaskIdByIndex()[self.index]
	local task_data = shuijing_data:GetCrystalTaskInfo()
	local show_gather_count = shuijing_data:GetCurGatherCount(task_id)
	if show_gather_count > task_data.task_gather_count[task_id + 1] then
		show_gather_count = task_data.task_gather_count[task_id + 1]
	end
	self.task_name:SetValue(Language.Shuijing.TaskName[task_id])
	local num = CommonDataManager.ConverNum(shuijing_data:GetShuijingExp(task_id))
	self.reward:SetValue(num)
	self.max_gathered:SetValue(task_data.task_gather_count[task_id + 1])
	self.gathered:SetValue(show_gather_count)
	self.is_finish:SetValue(shuijing_data:CheckIsComplete(task_id))
	self.show_hl:SetValue(self.parent:GetCurTaskId() == task_id)
end

function CrossCrystalScrollerCell:FlushHl()
	local task_id = CrossCrystalData.Instance:GetTaskIdByIndex()[self.index]
	self.show_hl:SetValue(self.parent:GetCurTaskId() == task_id)
end