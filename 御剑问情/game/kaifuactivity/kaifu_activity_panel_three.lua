KaifuActivityPanelThree = KaifuActivityPanelThree or BaseClass(BaseRender)


function KaifuActivityPanelThree:__init(instance)
	self.button_list = {}
	self.red_point_list = {}
	self.button_text = {}
	for i = 1, 6 do
		self.button_list[i] = self:FindObj("Button"..i)
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
		self.button_text[i] = self:FindVariable("BtnText"..i)
	end

	-- self.chongzhi_day = self:FindVariable("ChongzhiDay")
	self.time = self:FindVariable("time")
	self.chongzhi_person_Num = self:FindVariable("ChongzhiPersonNum")
	-- self.chongzhi_day:SetValue(TimeCtrl.Instance:GetCurOpenServerDay())
	self.cell_list = {}
	self.cur_chongzhi_diamonds = self:FindVariable("CurDiamonds")

	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate

	self.cur_index = 1
	self.cur_cond = 1

	self:ListenEvent("Chongzhi", BindTool.Bind(self.OnClickChongzhi, self))
end

function KaifuActivityPanelThree:OnClickChongzhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	ViewManager.Instance:Close(ViewName.KaifuActivityView)
end

function KaifuActivityPanelThree:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.cur_index = 1
	self.cur_cond = 1
	self.cond_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.cur_chongzhi_diamonds = nil
end

function KaifuActivityPanelThree:GetNumberOfCells()
	return #self:GetShowCfgList(self.cur_cond)
end

function KaifuActivityPanelThree:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = RechanageCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local temp1, cond = nil, nil
	if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
		temp1, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end
	local type_list = KaifuActivityData.Instance:SortList(self.activity_type, self:GetShowCfgList(self.cur_cond))
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[data_index + 1].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[data_index + 1].seq, self.activity_type)

	cell_item:SetData(type_list[data_index + 1], cond, is_get_reward, is_complete)
	cell_item:SetRoleCount(cond)
	self.chongzhi_person_Num:SetValue(cond)
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, type_list[data_index + 1].seq))
	self.cur_chongzhi_diamonds:SetValue(temp1)
end

function KaifuActivityPanelThree:OnClickGet(index)
	if KaifuActivityData.Instance:IsComplete(index, self.activity_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function KaifuActivityPanelThree:OnClickBtn(index, cond)
	self.cur_index = index
	self.cur_cond = self.cond_list[index] or self.cur_cond
	self.list.scroller:ReloadData(0)
	self:FlushListView()
end

function KaifuActivityPanelThree:GetShowCfgList(cond)
	local list = {}
	if not cond then return list end

	local activity_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	for k, v in pairs(activity_list) do
		if v.cond2 == cond then
			table.insert(list, v)
		end
	end
	return list
end

function KaifuActivityPanelThree:Flush(activity_type)
	self.activity_type = activity_type or self.activity_type
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)
	if activity_info == nil then return end

	local activity_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local temp_list = {}
	self.cond_list = {}
	for k, v in pairs(activity_list) do
		if not temp_list[v.cond2] then
			temp_list[v.cond2] = v.cond2
			table.insert(self.cond_list, v.cond2)
		end
	end

	table.sort(self.cond_list, function(a, b)
		return a < b
	end)

	if self.temp_activity_type ~= activity_type then
		for k, v in pairs(self.cond_list) do
			self:ClearEvent("OnClickBtn"..k)
			self:ListenEvent("OnClickBtn"..k, BindTool.Bind(self.OnClickBtn, self, k))
		end
	end

	for k, v in pairs(self.button_text) do
		if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) and self.cond_list[k] then
			v:SetValue(string.format(Language.Activity.FirstGroupBuy, self.cond_list[k]))
		end
	end

	self.cur_cond = self.cond_list[self.cur_index]
	self.button_list[self.cur_index].toggle.isOn = true

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for k, v in pairs(self.red_point_list) do
		v:SetValue(false)
	end
	for k, v in pairs(self.cond_list) do
		local list = self:GetShowCfgList(v)
		for i , j in ipairs(list) do
			if not KaifuActivityData.Instance:IsGetReward(j.seq, self.activity_type) and
				KaifuActivityData.Instance:IsComplete(j.seq, self.activity_type) then
				self.red_point_list[k]:SetValue(true)
				break
			end
		end
	end

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time + (7 - TimeCtrl.Instance:GetCurOpenServerDay()) * 24 * 3600
	self:SetRestTime(reset_time_s)

	self:FlushListView()
end

function KaifuActivityPanelThree:SetRestTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local diff_time = math.floor(diff_time - elapse_time + 0.5)
			if diff_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local time_str = ""
			local left_day = math.floor(diff_time / 86400)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(diff_time, 7)
			elseif diff_time < 86400 then
				if math.floor(diff_time / 3600) > 0 then
					time_str = TimeUtil.FormatSecond(diff_time, 1)
				else
					time_str = TimeUtil.FormatSecond(diff_time, 2)
				end
			end
			self.time:SetValue(time_str)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function KaifuActivityPanelThree:FlushListView()
	if self.activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type
end



RechanageCell = RechanageCell or BaseClass(PanelListCell)

function RechanageCell:__init(instance)
	self.title = self:FindVariable("TitleDescride")
	self.description = self:FindVariable("Descride")
	self.show_had_get = self:FindVariable("ShowHad")
	self.show_get_btn = self:FindVariable("ShowGetBtn")
	self.been_gray = self:FindVariable("BeenGray")
	self.gray_get_button = self:FindObj("GetButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.rechange_role_count = self:FindVariable("RechangeRoleCount")
end

function RechanageCell:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function RechanageCell:SetData(data, cond, is_get_reward, is_complete)
	if data == nil then return end
	local title_description = string.gsub(data.description, "%[.-%]", function (title_description)
			local change_str = data[string.sub(title_description, 2, -2)]
			return change_str
		end)
	local description = ""
	if data.cond1 == 0 then
		description = data.description_1
	else
		description = string.gsub(data.description_1, "%[.-%]", function (description)
			local change_str = data[string.sub(description, 2, -2)]
			return change_str
		end)
	end
	title_description = string.format(title_description,cond)
	self.title:SetValue(description)
	self.description:SetValue(title_description)
	if is_get_reward ~= nil then
		self.show_had_get:SetValue(is_get_reward)
		self.show_get_btn:SetValue(not is_get_reward)
	end
	self.item:SetData(data.reward_item[0])
	self.gray_get_button.button.interactable = is_complete or false
	self.been_gray:SetValue(is_complete)
end



function RechanageCell:SetRoleCount(cond)
	if cond == nil then return end
	self.rechange_role_count:SetValue(cond)
end
