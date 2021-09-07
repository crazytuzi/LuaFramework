KaifuActivityPanelSeven = KaifuActivityPanelSeven or BaseClass(BaseRender)

function KaifuActivityPanelSeven:__init(instance)
	self.cell_list = {}
end

function KaifuActivityPanelSeven:KaifuActivityPanelSeven()
	self.list = self:FindObj("ListView")
	list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.activity_change = BindTool.Bind(self.ActiviChange, self)
	KaifuActivityData.Instance:NotifyActChangeCallback(self.activity_change)
end

function KaifuActivityPanelSeven:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.activity_change ~= nil then
		KaifuActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end
end

function KaifuActivityPanelSeven:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetBattleTitleCfg()
end

function KaifuActivityPanelSeven:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelSevenListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local title_cfg = KaifuActivityData.Instance:GetBattleTitleCfg() or {}
	cell_item:SetData(title_cfg[data_index + 1])
end

function KaifuActivityPanelSeven:ActiviChange()
	if self.list.scroller.isActiveAndEnabled then
		self.list.scroller:RefreshActiveCellViews()
	end
end

function KaifuActivityPanelSeven:CloseCallBack()
	for k, v in pairs(self.cell_list) do
		v:RemoveCountDown()
	end
end

function KaifuActivityPanelSeven:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelSeven:OnFlush(activity_type)
	local activity_type = self.cur_type
	if not KaifuActivityData.Instance:IsZhengBaType(activity_type) then return end
	KaifuActivityData.Instance:SetZhengBaRedPointState(false)

	-- self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end

	self.temp_activity_type = activity_type
end


PanelSevenListCell = PanelSevenListCell or BaseClass(BaseRender)

function PanelSevenListCell:__init(instance)
	self:ListenEvent("OnClickTitle", BindTool.Bind(self.OnClickTitle, self))

	self.display = self:FindObj("Display")
	if not self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.display.ui3d_display)
	end

	self.title_root = self:FindObj("TitleRoot")

	self.cur_hour = self:FindVariable("CurHour")
	self.cur_min = self:FindVariable("CurMin")
	self.cur_sec = self:FindVariable("CurSec")

	self.activity_name = self:FindVariable("ActivityName")
	self.next_day = self:FindVariable("NextDay")
	self.first_name = self:FindVariable("FirstName")

	self.show_model = self:FindVariable("ShowModel")
	self.show_next_day = self:FindVariable("ShowNextDay")
	self.show_end = self:FindVariable("ShowEnd")
	self.show_opening = self:FindVariable("ShowHadOpen")

	self.is_loading = false

	self.title_effect = nil
	self.had_role_model = false
	self.cur_item_id = 0

	self.activity_states = {}

end

function PanelSevenListCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_loading = nil
	if self.title_effect then
		GameObject.Destroy(self.title_effect)
		self.title_effect = nil
	end
	self.cur_item_id = nil
	self.activity_states = {}
	self.cur_day = nil

	self.had_role_model = false

	self.act_sep = nil
end

function PanelSevenListCell:OnClickTitle()
	if not self.cur_item_id then return end
	local data = {item_id = self.cur_item_id}
	TipsCtrl.Instance:OpenItem(data)
end

function PanelSevenListCell:RemoveCountDown()
	self.activity_states = {}
	self.cur_day = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function PanelSevenListCell:SetData(data)
	if not data then return end

	if not self.title_effect and not self.is_loading then
		self.is_loading = true
		self.cur_item_id = data.item_id
		local bundle, asset = ResPath.GetTitleModel(data.title_id)
		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				
				local transform = obj.transform
				transform:SetParent(self.title_root.transform, false)
				self.title_effect = obj.gameObject
				self.is_loading = false
			end
		end)
	end

	local activity_info = KaifuActivityData.Instance:GetActivityStatuByType(BattleActivityId[data.act_sep])
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.activity_name:SetValue(data.act_name)

	if cur_day - data.act_sep < 0 then
		self.next_day:SetValue(data.act_sep)
	end

	if activity_info and activity_info.next_time then
		self.show_next_day:SetValue(cur_day - data.act_sep < 0 and activity_info.status ~= ACTIVITY_STATUS.OPEN)
		local diff_tiem = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
		local diff_hour = diff_tiem / 3600
		local format_time = os.date("*t", TimeCtrl.Instance:GetServerTime())

		self.show_end:SetValue(data.act_sep - cur_day < 0 or (data.act_sep - cur_day == 0 and diff_hour + format_time.hour > 24))
		self.show_opening:SetValue(data.act_sep - cur_day == 0 and activity_info and activity_info.status == ACTIVITY_STATUS.OPEN)
		self:SetRestTime(activity_info.next_time, activity_info and activity_info.status ~= ACTIVITY_STATUS.OPEN,
						self.activity_states[activity_info.type] ~= activity_info.status or self.cur_day ~= cur_day)

		self.cur_day = cur_day
		self.activity_states[activity_info.type] = activity_info.status
	end

	local battle_role_info = KaifuActivityData.Instance:GetBattleRoleInfo()[data.act_sep]
	self.show_model:SetValue(nil ~= battle_role_info)

	if battle_role_info and not self.had_role_model and self.act_sep ~= data.act_sep then
		self.had_role_model = true
		self.act_sep = data.act_sep
		if self.model then
			self.model:SetModelResInfo(battle_role_info, false, false, true)
		end
		self.first_name:SetValue(battle_role_info.role_name or "")
	end
end

function PanelSevenListCell:SetRestTime(diff_time, is_not_open, is_remove_count_down)
	local diff_time = diff_time - TimeCtrl.Instance:GetServerTime()
	if not is_not_open or is_remove_count_down then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
	end
	if self.count_down == nil and is_not_open then
		local function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time)
			if left_time <= 0.5 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.cur_hour:SetValue(left_hour)
			self.cur_min:SetValue(left_min)
			self.cur_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end