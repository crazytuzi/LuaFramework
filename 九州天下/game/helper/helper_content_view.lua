HelperContentView = HelperContentView or BaseClass(BaseRender)

function HelperContentView:__init(instance)
	HelperContentView.Instance = self
	self.helper_upgrade_cell_list = {}
	self:InitListView()
	self.current_helper_type = 0
	FuBenCtrl.Instance:SendGetExpFBInfoReq()
end

function HelperContentView:__delete()
	for k,v in pairs(self.helper_upgrade_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.helper_upgrade_cell_list = {}

	HelperContentView.Instance = nil
end

function HelperContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HelperContentView:GetNumberOfCells()
	return #(HelperData.Instance:GetHelperListByType(self.current_helper_type))
end

function HelperContentView:RefreshCell(cell, cell_index)
	local helper_upgrade_cell = self.helper_upgrade_cell_list[cell]
	if helper_upgrade_cell == nil then
		helper_upgrade_cell = HelperUpgradeItem.New(cell.gameObject, self)
		self.helper_upgrade_cell_list[cell] = helper_upgrade_cell
	end
	cell_index = cell_index + 1
	helper_upgrade_cell:SetGridIndex(cell_index)
end

function HelperContentView:SetCurrentHelperType(current_helper_type)
	self.current_helper_type = current_helper_type
	self.list_view.scroller:ReloadData(0)
end

function HelperContentView:GetCurrentHelperType()
	return self.current_helper_type
end
---------------------------------------------------------------
HelperUpgradeItem = HelperUpgradeItem or BaseClass(BaseCell)

function HelperUpgradeItem:__init()
	self.icon_image = self:FindVariable("icon_image")
	-- self.desc_text = self:FindVariable("desc_text")
	self.btn_text = self:FindVariable("btn_text")
	self.remain_text = self:FindVariable("remain_text")
	self.show_challenge = self:FindVariable("show_challenge")
	self.show_completed = self:FindVariable("show_completed")
	self.show_remain_text = self:FindVariable("show_remain_text")
	self.title_name_text = self:FindVariable("title_name_text")
	self.show_star_list = {}
	for i=1, 5 do
		self.show_star_list[i] = self:FindVariable("show_star_" .. i)
	end
	self:ListenEvent("go_to_click", BindTool.Bind(self.OnGoToClick, self))
	self.grid_index = 0
end

function HelperUpgradeItem:SetGridIndex(grid_index)
	self.grid_index = grid_index
	self:OnFlush()
end

function HelperUpgradeItem:OnFlush()
	local cfg = HelperData.Instance:GetHelperListByType(HelperContentView.Instance:GetCurrentHelperType())[self.grid_index]
	if cfg.with_button then
		self.show_challenge:SetValue(cfg.with_button == 1 and  true or false)
	end
	self.icon_image:SetAsset(ResPath.GetHelperIcon(cfg.icon))	
	-- self.desc_text:SetValue(cfg.desc)
	self.btn_text:SetValue(cfg.btn_name)
	self.title_name_text:SetValue(cfg.title)
	for i=1,5 do
		self.show_star_list[i]:SetValue(i <= cfg.star_num1)
	end
	--任务剩余次数
	if cfg.condiction == "" then
		self.show_remain_text:SetValue(false)
	else
		self.show_remain_text:SetValue(true)
		local count = 0
		if cfg.remind_id == "daily_task" then
			count = TaskData.Instance:GetTaskCount(TASK_TYPE.RI) or 0
		elseif cfg.remind_id == "yunbiao_task" then
			count = TaskData.Instance:GetCampTaskResTimes(CAMP_TASK_TYPE.CAMP_TASK_TYPE_YUNBIAO) or 0
		elseif cfg.remind_id == "exp_task" then
			count = TaskData.Instance:GetFuBenTasksTimes() or 0
		elseif cfg.remind_id == "chitan_task" then
			count = TaskData.Instance:GetCampTaskResTimes(CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN) or 0
		elseif cfg.remind_id == "save_task" then
			count = TaskData.Instance:GetCampTaskResTimes(CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU) or 0
		elseif cfg.remind_id == "banzhuan_task" then
			count = TaskData.Instance:GetCampTaskResTimes(CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN) or 0						
		end

		if tonumber(count) ~= nil and tonumber(count) > 0 then
			-- local remain_desc_list = Split(cfg.condiction, "#")
			local remain_desc_list = cfg.condiction
			count = ToColorStr(count, TEXT_COLOR.GREEN)
			-- local remain_desc = remain_desc_list[1] .. count .. remain_desc_list[2]
			local remain_desc = remain_desc_list .. count
			self.remain_text:SetValue(remain_desc)
		else
			finish_desc = ToColorStr(cfg.finish_desc, TEXT_COLOR.GREEN)
			self.remain_text:SetValue(finish_desc)
		end
	end
end

function HelperUpgradeItem:OnGoToClick()
	local cfg = HelperData.Instance:GetHelperListByType(HelperContentView.Instance:GetCurrentHelperType())[self.grid_index]
	--根据操作类型不同执行各自的点击事件
	if cfg.execute == HELPER_EXECUTE_TYPE.TO_NPC then
		local the_list = Split(cfg.param_1, "#")
		GuajiCtrl.Instance:MoveToNpc(tonumber(the_list[2]), nil, tonumber(the_list[1]))
	elseif cfg.execute == HELPER_EXECUTE_TYPE.OPEN_PANEL then
		local the_list = Split(cfg.param_1, "#")
		local name = ""
		local index_name = ""
		if #the_list == 2 then
			name = the_list[1]
			index_name = the_list[2]
		else
			name = cfg.param_1
		end
		ViewManager.Instance:Open(ViewName[name], TabIndex[index_name])
	elseif cfg.execute == HELPER_EXECUTE_TYPE.DO_TASK then
		if cfg.param_1 == "daily_task" then
			local count = TaskData.Instance:GetTaskCount(TASK_TYPE.RI)
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			if count ~= 0 and task_id == 0 then																--不满足做日常任务的条件是可做日常任务数量为满的
				local cfg = TaskData.Instance:GetTaskInfoByType(TASK_TYPE.RI)
				local show_tips = string.format(Language.Common.ShowDailyTaskCondition, cfg.min_level)
				TipsCtrl.Instance:ShowSystemMsg(show_tips)
				return
			elseif count == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.Common.DailyTaskFinished)
				return
			else
				TaskCtrl.Instance:DoTask(task_id)
			end
		end
	elseif cfg.execute == HELPER_EXECUTE_TYPE.OPEN_ACTIVITY	then
		ActivityCtrl.Instance:ShowDetailView(cfg.param_1)
	elseif cfg.execute == HELPER_EXECUTE_TYPE.MOVE_UPGRADE_PO then
		local pos_cfg = HelperData.Instance:GetUpgradePosByLevel()
		if pos_cfg ~= nil then
			GuajiCtrl.Instance:MoveToPos(pos_cfg.scene_id, pos_cfg.x, pos_cfg.y)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	end
	HelperCtrl.Instance:GetView():Close()
end
