KaifuActivityPanelOne = KaifuActivityPanelOne or BaseClass(BaseRender)

function KaifuActivityPanelOne:__init(instance)
	self.cell_list = {}
end

function KaifuActivityPanelOne:LoadCallBack()
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

end

function KaifuActivityPanelOne:__delete()
	self.temp_activity_type = nil
	self.activity_type = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KaifuActivityPanelOne:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetKaifuActivityCfgByType(self.activity_type)
end

function KaifuActivityPanelOne:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = PanelListCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local cfg = KaifuActivityData.Instance:SortList(self.activity_type)

	local grade, jinjie_type, cond = nil, nil, nil
	if KaifuActivityData.Instance:IsAdvanceType(self.activity_type) then
		grade, jinjie_type, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end

	local is_get_reward = KaifuActivityData.Instance:IsGetReward(cfg[data_index + 1].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(cfg[data_index + 1].seq, self.activity_type)

	cell_item:SetData(cfg[data_index + 1], cond, is_get_reward, jinjie_type, is_complete)
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, cfg[data_index + 1].seq))
end

function KaifuActivityPanelOne:OnClickGet(index)
	if KaifuActivityData.Instance:IsComplete(index, self.activity_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
		return
	end

	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function KaifuActivityPanelOne:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelOne:OnFlush()
	local activity_type = self.cur_type
	if KaifuActivityData.Instance:GetActivityInfo(activity_type) == nil then return end

	self.activity_type = activity_type or self.activity_type

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = activity_type
end


PanelListCell = PanelListCell or BaseClass(BaseRender)

local REWARD_NUM = 3
function PanelListCell:__init(instance)
	self.title = self:FindVariable("Title")
	self.show_had_get = self:FindVariable("ShowHad")
	self.show_get_btn = self:FindVariable("ShowGetBtn")

	self.gray_get_button = self:FindObj("GetButton")
	self.show_reward_list = {}
	for i = 0, REWARD_NUM - 1 do
		self.show_reward_list[i] = ItemCell.New()
		self.show_reward_list[i]:SetInstanceParent(self:FindObj("Item_" .. i))
	end
end

function PanelListCell:__delete()
	for i = 0, REWARD_NUM - 1 do
		self.show_reward_list[i]:DeleteMe()
	end
	self.show_reward_list = {}
end

function PanelListCell:SetData(data, cond, is_get_reward, jinjie_type, is_complete)
	if data == nil then return end
	self.data = data
	self.cond = cond
	self.is_get_reward = is_get_reward
	self.jinjie_type = jinjie_type
	self.is_complete = is_complete
	self:Flush()
end

function PanelListCell:OnFlush()
	local data = self.data
	local cond = self.cond
	local is_get_reward = self.is_get_reward
	local jinjie_type = self.jinjie_type
	local is_complete = self.is_complete
	if data == nil then return end
	local grade_index = 0
	local str = string.gsub(data.description, "%[.-%]", function (str)
		local change_str = data[string.sub(str, 2, -2)]
		local cond_index = string.sub(str, -2, -2)
		if jinjie_type and (tonumber(cond_index) == 1) then
			change_str = KaifuActivityData.Instance:GetJinjieTypeShowGrade(jinjie_type, change_str)
			grade_index = change_str
		elseif data.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL then
			local level_befor = math.floor(change_str % 100) ~= 0 and math.floor(change_str % 100) or 100
			local level_behind = math.floor(change_str % 100) ~= 0 and math.floor(change_str / 100) or math.floor(change_str / 100) - 1
			local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
			change_str = level_zhuan
		end
		return change_str
	end)
	if cond then
		if type(cond) == "table" then
			local count_num = tonumber(cond[grade_index] and cond[grade_index].count or 0)
			local count_str = count_num < data.cond2 and string.format(Language.Mount.ShowRedNum, count_num) or string.format(Language.Mount.ShowGreenNum, count_num)
			str = string.format(str, count_str)
		else
			local cond_str = tonumber(cond) < data.cond2 and string.format(Language.Mount.ShowRedNum, tonumber(cond)) or string.format(Language.Mount.ShowGreenNum, tonumber(cond))
 			str = string.format(str,  cond_str)
		end
	else
		str = string.format(str,  tostring(0))
	end
	self.title:SetValue(str)
	if is_get_reward ~= nil then
		self.show_had_get:SetValue(is_get_reward)
		self.show_get_btn:SetValue(not is_get_reward)
	end
	for i = 0, REWARD_NUM - 1 do
		self.show_reward_list[i]:SetData(data.reward_item[i])
	end
	self.gray_get_button.button.interactable = is_complete or false
end

function PanelListCell:ListenClick(handler)
	self:ClearEvent("OnClickGet")
	self:ListenEvent("OnClickGet", handler)
end