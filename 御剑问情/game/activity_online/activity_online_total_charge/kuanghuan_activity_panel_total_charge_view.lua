require("game/activity_online/activity_online_item_cell")
KuangHuanTotalChargeView =  KuangHuanTotalChargeView or BaseClass(BaseRender)

function KuangHuanTotalChargeView:__init()
	self.contain_cell_list = {}
	self.act_id = 0
	self.count_num = 0
end

function KuangHuanTotalChargeView:__delete()
	self:CloseCallBack()

	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.contain_cell_list = {}
	end

	self.list_view = nil
	self.rest_time = nil
	self.contain_cell_list = nil
	self.chongzhi_count = nil
end

function KuangHuanTotalChargeView:SetActId(value)
	self.act_id = value
end

function KuangHuanTotalChargeView:PanelClick()
	KuanHuanActivityTotalChargeData.Instance:SetIsOpen(true)
	RemindManager.Instance:Fire(RemindName.OffLineTotalCharge)
end

function KuangHuanTotalChargeView:OpenCallBack()
    self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.show_desc = self:FindVariable("ShowDesc")
	self.rest_time = self:FindVariable("rest_time")	
	self.chongzhi_count = self:FindVariable("xiaofei_count")

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local end_time = ActivityOnLineData.Instance:GetRestTime(self.act_id) - TimeCtrl.Instance:GetServerTime()	

	self:SetTime(0, end_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(end_time, 1, BindTool.Bind(self.SetTime, self))

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

	self.reward_list = KuanHuanActivityTotalChargeData.Instance:GetSingleCfgInfo(self.act_id)
	self:Flush()
end

function KuangHuanTotalChargeView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KuangHuanTotalChargeView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KuangHuanTotalChargeView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self.reward_list = KuanHuanActivityTotalChargeData.Instance:GetSingleCfgInfo(self.act_id)
			local num = GetListNum(self.reward_list)
			if self.count_num ~= num and self.list_view then
				self.count_num = num
				self.list_view.scroller:ReloadData(0)
			end
		elseif k == "totalcharge" then
			self.list_view.scroller:RefreshActiveCellViews()
		end
	end	

	if self.chongzhi_count and self.reward_list then
		self.chongzhi_count:SetValue(KuanHuanActivityTotalChargeData.Instance:GetChargeValue(self.act_id))
	end
end

function KuangHuanTotalChargeView:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)

	local time_str = ""
	local day_second = 24 * 60 * 60         -- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 7)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	self.rest_time:SetValue(time_str)
end

function KuangHuanTotalChargeView:GetNumberOfCells()
	return self.count_num
end

function KuangHuanTotalChargeView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = KuanHuanTotalChargeCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	local reward_type = KuanHuanActivityTotalChargeData.Instance:GetRewardType(self.act_id)
	self.show_desc:SetValue(reward_type)
	contain_cell:SetType(reward_type)
	contain_cell:SetData(self.reward_list[cell_index])
	cell_index = cell_index + 1
end

----------------------------KuanHuanTotalChargeCell---------------------------------
KuanHuanTotalChargeCell = KuanHuanTotalChargeCell or BaseClass(BaseCell)

function KuanHuanTotalChargeCell:__init()
	self.tips = self:FindVariable("tips")
	self.tips_2 = self:FindVariable("tips_2")
	self.show_reward_time = self:FindVariable("ShowRewardTime")
	self.reward_time = self:FindVariable("RewardTime")

	self.cfg = nil
	self.cell_list = {}
	self.reward_type = false
	self.count_num = 0

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate

	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function KuanHuanTotalChargeCell:__delete()
	self.cfg = nil

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.cell_list = nil
	end
end

function KuanHuanTotalChargeCell:SetType(reward_type)
	self.reward_type = reward_type
end

function KuanHuanTotalChargeCell:OnFlush()
	if self.data == nil then return end

	if nil == self.cfg then
		local reward_item = self.data.reward_item[0]
		self.cfg = ItemData.Instance:GetGiftItemListByProf(reward_item.item_id)
	end

	local num = #self.cfg
	if self.count_num ~= #self.cfg then
		self.count_num = num
		self.list_view.scroller:ReloadData(0)
	end

	self.tips:SetValue(ToColorStr(self.data.need_chongzhi_num, COLOR.BLUE_4))
	if self.reward_type then
		self.tips_2:SetValue(Language.Activity.ChongZhiDesc2)
	else
		self.tips_2:SetValue(Language.Activity.ChongZhiDesc)
	end
end

function KuanHuanTotalChargeCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KuanHuanTotalChargeCell:GetNumberOfCells()
	return self.count_num
end

function KuanHuanTotalChargeCell:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local list_cell = self.cell_list[cell]
	if nil == list_cell then
		list_cell = KuanHuanDanBiChongZhiItem.New(cell)
		self.cell_list[cell] = list_cell
	end

	list_cell:SetData(self.cfg[data_index])
end
