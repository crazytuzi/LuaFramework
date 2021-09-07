OpenActTotalChongZhi = OpenActTotalChongZhi or BaseClass(BaseRender)

function OpenActTotalChongZhi:__init()
	self.contain_cell_list = {}
end

function OpenActTotalChongZhi:__delete()
	self.list_view = nil
	self.rest_time = nil

	if self.contain_cell_list then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
	
	self.contain_cell_list = {}
	self.cur_type = nil
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
end

function OpenActTotalChongZhi:LoadCallBack()
	self:OpenCallBack()
end

function OpenActTotalChongZhi:OpenCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetTime(rest_time)
		end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:Flush()
end

function OpenActTotalChongZhi:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function OpenActTotalChongZhi:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function OpenActTotalChongZhi:OnFlush()
	--self.reward_list = KaiFuChargeData.Instance:GetLeijiChongZhiFlagCfg()
	self.reward_list = KaiFuChargeData.Instance:GetOpenActTotalChongZhiReward()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	--local info = KaifuActivityData.Instance:GetRATotalChongZhiGoldInfo()
	local info = KaiFuChargeData.Instance:GetLeiJiChongZhiInfo()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(info.total_charge_value or 0)
	end
end

function OpenActTotalChongZhi:FlushTotalConsume()
	self:Flush()
end

function OpenActTotalChongZhi:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end

function OpenActTotalChongZhi:GetNumberOfCells()
	return #self.reward_list or 0
end

function OpenActTotalChongZhi:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function OpenActTotalChongZhi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = OpenActTotalChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------OpenActTotalChongZhiCell---------------------------------
OpenActTotalChongZhiCell = OpenActTotalChongZhiCell or BaseClass(BaseCell)

function OpenActTotalChongZhiCell:__init()
	self.data = {}
	self.total_value = self:FindVariable("total_value")
	self.cur_value = self:FindVariable("cur_value")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.total_consume_tip = self:FindVariable("total_consume_tip")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.show_red = self:FindVariable("show_red")
	self.color = self:FindVariable("color")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function OpenActTotalChongZhiCell:__delete()
	self.total_value = nil
	self.cur_value = nil
	self.show_text = nil
	self.show_interactable = nil
	self.total_consume_tip = nil
	self.can_lingqu = nil
	self.color = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function OpenActTotalChongZhiCell:SetData(data)
	self.data = data
end

function OpenActTotalChongZhiCell:OnFlush()
	--local info = KaifuActivityData.Instance:GetRATotalChongZhiGoldInfo()
	local info = KaiFuChargeData.Instance:GetLeiJiChongZhiInfo()
	local cur_value = info.need_chognzhi or 0
	local color = cur_value >= self.data.need_chognzhi and COLOR.GREEN or COLOR.RED
	self.color:SetValue(color)
	self.total_value:SetValue(self.data.need_chognzhi)
	self.cur_value:SetValue(cur_value)
	self.total_consume_tip:SetValue(string.format(Language.Activity.TotalChongZhiTip, self.data.need_chognzhi))
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)

	for i = 1, 4 do
		if reward_list[i] then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local reward_has_fetch_flag = self.data.reward_has_fetch_flag == 1
	local str = reward_has_fetch_flag and Language.Common.YiLingQu or (cur_value >= self.data.need_chognzhi and Language.Common.LingQu or Language.Common.WEIDACHENG)
	self.show_text:SetValue(str)
	self.show_interactable:SetValue(not reward_has_fetch_flag)
	--self.can_lingqu:SetValue(not reward_has_fetch_flag and cur_value >= self.data.need_chognzhi)
	self.can_lingqu:SetValue(reward_has_fetch_flag)
	self.show_red:SetValue(not reward_has_fetch_flag and info.total_charge_value >= self.data.need_chognzhi)

end

function OpenActTotalChongZhiCell:OnClickGet()
	--KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_TOTAL_CONSUME_GOLD, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SEVEN_TOTAL_CHARGE, RA_TOTAL_CHARGE_OPERA_TYPE_KAIFU.RA_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end