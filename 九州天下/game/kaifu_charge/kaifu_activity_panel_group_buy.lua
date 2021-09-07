KaiFuGroupBuy = KaiFuGroupBuy or BaseClass(BaseRender)


function KaiFuGroupBuy:__init(instance)
	self.ui_config = {"uis/views/kaifuchargeview","FirstChargeGroupBuy"}
	self.cur_index = 1
	self.cur_cond = 1
	self.cell_list = {}
end

function KaiFuGroupBuy:__delete()
	self.temp_activity_type = nil
	self.activity_type = 2136

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	
	self.cur_index = nil
	self.cur_cond = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaiFuGroupBuy:LoadCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	self:ListenEvent("OnRecharBtn", BindTool.Bind(self.OnRecharBtn, self))
	self.list = self:FindObj("ListView")
	self.list_delegate = self.list.list_simple_delegate

	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.button_list = {}
	self.red_point_list = {}
	self.button_text = {}
	self.show_button = {}
	for i = 1, 6 do
		self.button_list[i] = self:FindObj("Button"..i)
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
		self.button_text[i] = self:FindVariable("BtnText"..i)
		self.show_button[i] = self:FindVariable("Showbutton"..i)
	end

	self.chongzhi_day = self:FindVariable("ChongzhiDay")
	self.time = self:FindVariable("time")
	self.chongzhi_person_Num = self:FindVariable("ChongzhiPersonNum")
	local cur_day = string.format(Language.Activity.CurOpenServerDay, TimeCtrl.Instance:GetCurOpenServerDay())
	self.chongzhi_day:SetValue(cur_day)
	self:Flush()
end

function KaiFuGroupBuy:GetNumberOfCells()
	return #self:GetShowCfgList(self.cur_cond)
end

function KaiFuGroupBuy:RefreshCell(cell, data_index)
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = ChongzhiItemCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end

	local temp1, cond = nil, nil
	if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) then
		temp1, cond = KaifuActivityData.Instance:GetCondByType(self.activity_type)
	end
	local type_list = KaifuActivityData.Instance:SortList(self.activity_type, self:GetShowCfgList(self.cur_cond))
	if next(type_list) == nil then return end 
	local is_get_reward = KaifuActivityData.Instance:IsGetReward(type_list[data_index + 1].seq, self.activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(type_list[data_index + 1].seq, self.activity_type)
	cell_item:SetData(type_list[data_index + 1], cond, is_get_reward, is_complete)
	cell_item:SetRoleCount(cond)
	self.chongzhi_person_Num:SetValue(cond)
	cell_item:ListenClick(BindTool.Bind(self.OnClickGet, self, type_list[data_index + 1].seq))
end

function KaiFuGroupBuy:OnClickGet(index)
	if KaifuActivityData.Instance:IsComplete(index, self.activity_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH, index)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoComplete)
end

function KaiFuGroupBuy:OnClickBtn(index, cond)
	self.cur_index = index
	self.cur_cond = cond
	self:FlushListView()
	self:Flush()
end

function KaiFuGroupBuy:GetShowCfgList(cond)
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

function KaiFuGroupBuy:OnFlush(activity_type)
	self.activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIRST_CHARGE_TUAN or self.activity_type
	local activity_info = KaifuActivityData.Instance:GetActivityInfo(self.activity_type)
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

	if self.temp_activity_type ~= self.activity_type then
		for k, v in pairs(cond_list) do
			self:ClearEvent("OnClickBtn"..k)
			self:ListenEvent("OnClickBtn"..k, BindTool.Bind(self.OnClickBtn, self, k, v))
		end
	end

	for i = 1, 6 do
		if KaifuActivityData.Instance:IsChongzhiType(self.activity_type) and cond_list[i] then
			self.button_text[i]:SetValue(string.format(Language.Activity.FirstGroupBuy, cond_list[i]))
			self.show_button[i]:SetValue(false)
		else
			self.show_button[i]:SetValue(true)
		end
	end

	self.cur_cond = cond_list[self.cur_index]
	self.button_list[self.cur_index].toggle.isOn = true


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

	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local reset_time_s = 24 * 3600 - cur_time
	self:SetRestTime(reset_time_s)
	self:FlushListView()
end

function KaiFuGroupBuy:SetRestTime(diff_time)
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
			self.time:SetValue(TimeUtil.FormatSecond(diff_time, 3))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end

function KaiFuGroupBuy:FlushListView()
	if self.activity_type == self.temp_activity_type then
		self.list.scroller:RefreshActiveCellViews()
	else
		if self.list.scroller.isActiveAndEnabled then
			self.list.scroller:ReloadData(0)
		end
	end
	self.temp_activity_type = self.activity_type
end

function KaiFuGroupBuy:OnRecharBtn()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

local REWARD_NUM = 3
ChongzhiItemCell = ChongzhiItemCell or BaseClass(PanelListCell)
function ChongzhiItemCell:__init(instance)
	self.title = self:FindVariable("TitleDescride")
	self.description = self:FindVariable("Descride")
	self.show_had_get = self:FindVariable("ShowHad")
	self.show_get_btn = self:FindVariable("ShowGetBtn")
	self.gray_get_button = self:FindObj("GetButton")
	self.reward_list = {}
	for i = 0, REWARD_NUM - 1 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("Item_" .. i))
	end
	self.rechange_role_count = self:FindVariable("RechangeRoleCount")
end

function ChongzhiItemCell:__delete()
	for i = 0, REWARD_NUM - 1 do
		self.reward_list[i]:DeleteMe()
	end
	self.reward_list = {}
end

function ChongzhiItemCell:SetData(data, cond, is_get_reward, is_complete)
	if data == nil then return end
	local title_description = string.gsub(data.description, "%[.-%]", function (title_description)
			local change_str = data[string.sub(title_description, 2, -2)]
			return change_str
		end)

	local description = string.format(Language.Activity.TodayGroupBuy, data.cond2)

	title_description = string.format(title_description, cond)
	self.title:SetValue(description)
	self.description:SetValue(title_description)
	if is_get_reward ~= nil then
		self.show_had_get:SetValue(is_get_reward)
		self.show_get_btn:SetValue(not is_get_reward)
	end
	for i = 0, REWARD_NUM - 1 do
		self.reward_list[i]:SetData(data.reward_item[i])
	end
	self.gray_get_button.button.interactable = is_complete or false
end



function ChongzhiItemCell:SetRoleCount(cond)
	if cond == nil then return end
	self.rechange_role_count:SetValue(cond)
end
