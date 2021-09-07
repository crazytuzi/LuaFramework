KaifuActivityPanelThree = KaifuActivityPanelThree or BaseClass(BaseRender)
function KaifuActivityPanelThree:__init(instance)
	self.cell_list = {}
	self.button_list = {}
	self.red_point_list = {}
	self.button_text = {}
	self.cur_index = 1
	self.cur_cond = 1
end

function KaifuActivityPanelThree:LoadCallBack()
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	for i = 1, 3 do
		self.button_list[i] = self:FindObj("Button"..i)
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
		self.button_text[i] = self:FindVariable("BtnText"..i)
	end
end

function KaifuActivityPanelThree:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.button_list = {}
	self.red_point_list = {}
	self.button_text = {}
	self.cur_index = nil
	self.cur_cond = nil
end

function KaifuActivityPanelThree:GetNumberOfCells()
	return #self:GetShowCfgList(self.cur_cond)
end

function KaifuActivityPanelThree:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelListCell.New(cell.gameObject)
	end

	local temp1, cond = nil, nil
	if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
		temp1, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end
	local type_list = KaifuActivityData.Instance:SortList(self.activity_type, self:GetShowCfgList(self.cur_cond))

	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[data_index + 1].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[data_index + 1].seq, self.activity_type)

	cell_item:SetData(type_list[data_index + 1], cond, is_get_reward, nil, is_complete)
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, type_list[data_index + 1].seq))
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
	self.cur_cond = cond
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

function KaifuActivityPanelThree:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelThree:OnFlush()
	local activity_type = self.cur_type
	self.activity_type = activity_type or self.activity_type
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(activity_type)
	if activity_info == nil then return end

	local activity_list = KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
	local temp_list = {}
	local cond_list = {}
	for k, v in pairs(activity_list) do
		if not temp_list[v.cond2] then
			temp_list[v.cond2] = v.cond2
			table.insert(cond_list, v.cond2)
		end
	end

	table.sort(cond_list, function(a, b)
		return a < b
	end)

	if self.temp_activity_type ~= activity_type then
		for k, v in pairs(cond_list) do
			self:ClearEvent("OnClickBtn"..k)
			self:ListenEvent("OnClickBtn"..k, BindTool.Bind(self.OnClickBtn, self, k, v))
		end
	end

	for k, v in pairs(self.button_text) do
		if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
			v:SetValue(string.format(Language.Activity.FirstGroupBuy, cond_list[k]))
		end
	end

	self.cur_cond = cond_list[self.cur_index]
	self.button_list[self.cur_index].toggle.isOn = true

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for k, v in pairs(self.red_point_list) do
		v:SetValue(false)
	end
	for k, v in pairs(cond_list) do
		local list = self:GetShowCfgList(v)
		for i , j in ipairs(list) do
			if not KaifuActivityData.Instance:IsGetReward(j.seq, self.activity_type) and
				KaifuActivityData.Instance:IsComplete(j.seq, self.activity_type) then
				self.red_point_list[k]:SetValue(true)
				break
			end
		end
	end

	self:FlushListView()
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