ShengDiFuBenView = ShengDiFuBenView or BaseClass(BaseView)

function ShengDiFuBenView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","ShengDIFuBenView"}
	self.active_close = false
	self.click_flag = false
	self.view_layer = UiLayer.MainUIHigh
	self.last_remind_time = 0
	self.is_safe_area_adapter = true
end

function ShengDiFuBenView:ReleaseCallBack()
	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.task_panel then
		self.task_panel:DeleteMe()
		self.task_panel = nil
	end

	-- 清理变量和对象
	self.boss_btn = nil
	self.track_info = nil
	self.show_panel = nil
	self.show_boss_tab_hl = nil
	self.show_team_tab_hl = nil

	if self.show_or_hide_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_button)
		self.show_or_hide_button = nil
	end
end

function ShengDiFuBenView:LoadCallBack()
	self.boss_panel = ShengDiBossView.New(self:FindObj("BossPanel"))
	self.task_panel = ShengDiTaskInfo.New(self:FindObj("TeamPanel"))
	self.boss_btn = self:FindObj("boss_btn")
	self.track_info = self:FindObj("track_info")
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss_tab_hl = self:FindVariable("show_boss_tab_hl")
	self.show_team_tab_hl = self:FindVariable("show_team_tab_hl")

	self:ListenEvent("click_info", BindTool.Bind(self.ClickInfo, self))
	self:ListenEvent("click_boss", BindTool.Bind(self.ClickBoss, self))

	self.show_or_hide_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self:Flush()
end

function ShengDiFuBenView:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	end
end

function ShengDiFuBenView:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush("boss_type")
	self:FlushTabHl(true)
end

function ShengDiFuBenView:ClickIcon()
end

function ShengDiFuBenView:CloseTips()
end

function ShengDiFuBenView:FlushTabHl(show_boss)
	self.show_boss_tab_hl:SetValue(show_boss)
	self.show_team_tab_hl:SetValue(not show_boss)
end

function ShengDiFuBenView:OpenCallBack()
	self.boss_panel:Flush()
	self:Flush("open_flush")
	self:Flush("team_type")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
end

function ShengDiFuBenView:CloseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.root_node.gameObject.activeSelf and self.track_info.gameObject.activeSelf then
		self.boss_btn.toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = false

end

function ShengDiFuBenView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function ShengDiFuBenView:PortraitToggleChange(state)
	if state then
		if self.click_flag then
			self:Flush("team_type")
			self:FlushTabHl(false)
		else
			self.boss_panel:Flush("boss_type")
			self:FlushTabHl(true)
		end
	end
end

function ShengDiFuBenView:OnFlush(param_t)
	self.boss_panel:SetCurIndex(0)
	for k, _ in pairs(param_t) do
		if k == "boss_type" then
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.task_panel:Flush()
		elseif k == "open_flush" then
			self.boss_btn.toggle.isOn = true
			self:FlushTabHl(true)
		else
			self.boss_panel:Flush()
		end
	end
end

function ShengDiFuBenView:SwitchButtonState(enable)
	if self.show_panel then
		self.show_panel:SetValue(enable)
	end
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
ShengDiBossView = ShengDiBossView or BaseClass(BaseRender)
function ShengDiBossView:__init()
	-- 获取控件
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self:Flush()
end

function ShengDiBossView:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function ShengDiBossView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function ShengDiBossView:BagRefreshCell(cell, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = ShengDiBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function ShengDiBossView:GetDataList()
	return MarriageData.Instance:GetBossInfoList()
end

function ShengDiBossView:SetCurIndex(index)
	self.cur_index = index
end

function ShengDiBossView:GetCurIndex()
	return self.cur_index
end

function ShengDiBossView:OnFlush()
	if nil ~= next(self.item_t) then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ShengDiBossView:FlushAllHl()
	for _, v in pairs(self.item_t) do
		v:FlushHl()
	end
end

------------------------------------------------------------------------
------------------ShengDiBossItem-------------------------------------
------------------------------------------------------------------------
ShengDiBossItem = ShengDiBossItem or BaseClass(BaseRender)

function ShengDiBossItem:__init(instance, parent)
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

function ShengDiBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ShengDiBossItem:ClickKill(is_click)
	if self.data == nil then return end
	if self.data.pos_x < 1 and self.data.pos_y < 1 then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.secen_id, self.data.pos_x, self.data.pos_y, 10, 10)
	self.parent:FlushAllHl()
	return
end

function ShengDiBossItem:SetData(data)
	self.data = data
	self.secen_id = MarriageData.Instance:GetSceneId()
	self:Flush()
end

function ShengDiBossItem:SetItemIndex(index)
	self.index = index
end

function ShengDiBossItem:Flush()
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

	if self.data then
		self.time_color:SetValue(self.data.next_refresh_time == 0 and TEXT_COLOR.GREEN_3 or "#ff0000ff")
		self.next_refresh_time = self.data.next_refresh_time
		if self.data.next_refresh_time == 0 then
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
				self.time:SetValue(Language.Dungeon.CanKill)
			end
			self.time:SetValue(Language.Dungeon.CanKill)
		else
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnBossUpdate()
		end
	else
		self.time_color:SetValue(TEXT_COLOR.GREEN_3)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(Language.Dungeon.CanKill)
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.secen_id)
	if scene_cfg then
		if self.data.pos_x > 0 and self.data.pos_y > 0 then
			self.desc:SetValue(scene_cfg.name .. "(" .. self.data.pos_x .. "," .. self.data.pos_y .. ")")
		else
			self.desc:SetValue(scene_cfg.name .. "<color='#fb1212ff'>  待刷新</color>")
		end
	end

	self:FlushHl()
end

function ShengDiBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function ShengDiBossItem:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN))
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

-----------------------任务----------------------------------
ShengDiTaskInfo = ShengDiTaskInfo or BaseClass(BaseRender)
function ShengDiTaskInfo:__init()
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list_view")
	self.cur_index = 0
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShengDiTaskInfo:__delete()
	for _, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function ShengDiTaskInfo:GetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function ShengDiTaskInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShengDiTaskCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	local data_list = self:GetDataList() or {}
	contain_cell:SetIndex(cell_index + 1)
	contain_cell:SetData(data_list[cell_index + 1])
	contain_cell:FlushSelectHL()
end

function ShengDiTaskInfo:GetDataList()
	return MarriageData.Instance:GetTaskList()
end

function ShengDiTaskInfo:OnFlush()
	if nil ~= next(self.contain_cell_list) then
		self.list_view.scroller:ReloadData(0)
	end
end

function ShengDiTaskInfo:SetCurIndex(index)
	self.cur_index = index
end

function ShengDiTaskInfo:GetCurIndex()
	return self.cur_index
end

function ShengDiTaskInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ShengDiTaskInfo:GetSelectIndex()
	return self.select_index or 0
end

function ShengDiTaskInfo:FlushAllHl()
	for _, v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end

function ShengDiTaskInfo:FlushAllSelectHL()
	for _, v in pairs(self.contain_cell_list) do
		v:FlushSelectHL(self.select_index)
	end
end
---------------------------------------------------------------
ShengDiTaskCell = ShengDiTaskCell or BaseClass(BaseCell)
function ShengDiTaskCell:__init(instance, parent)
	self.parent = parent
	self.task_num = self:FindVariable("task_num")
	self.task_text = self:FindVariable("task_text")
	self.is_click = self:FindVariable("is_click")
	self.is_show = self:FindVariable("is_show")
	self.show_hl = self:FindVariable("show_hl")

	self.item_cell_list = nil
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("item_1"))
	self.item_cell_list = item

	self.item = self:FindObj("item_1")

	self:ListenEvent("on_click", BindTool.Bind(self.ClickItem, self))
end

function ShengDiTaskCell:__delete()
	self.task_num = nil
	self.task_text = nil
	self.is_show = nil
	self.is_click = nil
	self.item = nil

	self.item_cell_list:DeleteMe()
	self.item_cell_list = {}
end

function ShengDiTaskCell:SetIndex(index)
	self.index = index
end

function ShengDiTaskCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local  task_cfg = MarriageData.Instance:GetOneShengDiTaskById(self.data.task_id)
	self.item_cell_list:SetData(task_cfg.reward_item[0])

	local str = string.format(Language.QingYuanShengDi[task_cfg.task_type], self.data.param, task_cfg.param1)
	self.task_text:SetValue(str)

	self.task_num:SetValue(task_cfg.name_inside)

	if self.data.is_fetched_reward == 0 and self.data.flag == 0 then
		self.task_text:SetValue(Language.QingYuanShengDi.LingQu_2)
	end

	self.is_show:SetValue(self.data.is_fetched_reward == 1 and true or false)

	self:FlushHl()
end

function ShengDiTaskCell:ClickItem()
	--is_fetched_reward为1的时候是已领取奖励, flag为1的时候是还没达成任务条件，0是已达成
	if self.data.is_fetched_reward == 0 and self.data.flag == 0 then
		MarriageCtrl.Instance:SendQingYuanShengDiOperaReq(QYSD_OPERA_TYPE.QYSD_OPERA_TYPE_FETCH_TASK_REWARD,self.data.index)
		self:StartMove()
	elseif self.data.flag == 1 then
		GuajiCtrl.Instance:StopGuaji()
		self.parent:SetCurIndex(self.index)
		self.parent:FlushAllSelectHL()
		--引导去打怪
		local task_cfg = MarriageData.Instance:GetOneShengDiTaskById(self.data.task_id)
		local pos_x, pos_y = MarriageData.Instance:GetShengDiPosByPosType(task_cfg.location_type)
		local end_type = MoveEndType.Auto
		local range, offset_range = 5, 5				--范围(在那个范围内就停下来)
		if task_cfg.location_type == 2 then
			--采集物只能写死一个坐标，因为服务器没有返回该场景内所有采集物的坐标
			--2为采集物（先写死把）
			MoveCache.param1 = 121
			end_type = MoveEndType.GatherById
			range = 1
			offset_range = 1
		elseif task_cfg.location_type ~= 4 then
			-- 小怪固定位置，其他怪不固定（找距离最近的怪）
			local move_info_list = Scene.Instance:GetObjMoveInfoList()
			local moster_list = MarriageData.Instance:GetShengDiMosterList(MarriageData.Instance:GetNowShendiLayer(), task_cfg.location_type)
			if nil == moster_list then
				return
			end
			local min_distance = 100000
			for _, v in pairs(move_info_list) do
				local vo = v:GetVo()
				if vo.obj_type == SceneObjType.Monster then
					if nil ~= moster_list[vo.type_special_id] then
						local logic_x, logic_y = Scene.Instance:GetMainRole():GetLogicPos()
						local distance = GameMath.GetDistance(vo.pos_x, vo.pos_y, logic_x, logic_y, true)
						if distance < min_distance then
							min_distance = distance
							pos_x, pos_y = vo.pos_x, vo.pos_y
						end
					end
				end
			end
		end
		MoveCache.end_type = end_type
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_x, pos_y, range, offset_range)
	end
end

function ShengDiTaskCell:FlushHl()
	if self.data.is_fetched_reward == 0 and self.data.flag == 0 then
		self.is_click:SetValue(true)
	else
		self.is_click:SetValue(false)
	end
end

function ShengDiTaskCell:FlushSelectHL()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function ShengDiTaskCell:StartMove()
	local target_obj = MainUICtrl.Instance.view:GetPackageBtn()
	if nil == target_obj then
		return
	end

	local item_data = self.item_cell_list:GetData()
	TipsCtrl.Instance:OpenMoveItemView(item_data, self.item, target_obj, 1, true, PUT_REASON_TYPE.PUT_REASON_ONLINE_REWARD)

end
