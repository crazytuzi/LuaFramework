LeiJiRewardView =  LeiJiRewardView or BaseClass(BaseRender)

function LeiJiRewardView:__init()
	self.contain_cell_list = {}
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_CHARGE_REPAYMENT_OPERA_TYPE_QUERY_INFO)
	end
end

function LeiJiRewardView:__delete()

end

function LeiJiRewardView:OpenCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT)
	self.rest_time:SetValue(self:SetTime(rest_time))
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self.rest_time:SetValue(self:SetTime(rest_time))
        end)

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self.rank_levle = self:FindVariable("rank_levle")

	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetLeiJiChargeValue())

	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	self.reward_list = KaifuActivityData.Instance:GetLeiJiChargeRewardCfg()
end

function LeiJiRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function LeiJiRewardView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LeiJiRewardView:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetLeiJiChargeRewardCfg()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetLeiJiChargeValue())
	end
end

function LeiJiRewardView:SetTime(time)
	local left_day = math.floor(time / 86400)
	time_str = ""
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(time, 8)
	else
		time_str = TimeUtil.FormatSecond(time)
	end
	return time_str
end

function LeiJiRewardView:GetNumberOfCells()
	return #self.reward_list
end

function LeiJiRewardView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then    --没有的时候才创建，节省空间
		contain_cell = LeiJiChargeLevelCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell:SetCostData()
	contain_cell:Flush()
end

----------------------------LeiJiChargeLevelCell---------------------------------
LeiJiChargeLevelCell = LeiJiChargeLevelCell or BaseClass(BaseCell)

function LeiJiChargeLevelCell:__init()
	self.reward_data = {}
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self.text1 = self:FindVariable("text1")

	self.btn_name = self:FindVariable("BtnName")
	self.is_active = self:FindVariable("is_active")
	self.can_get = self:FindVariable("can_get")
	self.is_get = self:FindVariable("is_get")

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	-- for i = 1, 3 do
	self.item_cell_obj_list[1] = self:FindObj("item_1")
	item_cell = ItemCell.New()
	self.item_cell_list[1] = item_cell
	item_cell:SetInstanceParent(self.item_cell_obj_list[1])
	-- end
end

function LeiJiChargeLevelCell:__delete()
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.text1 = nil
	self.btn_name = nil
	self.is_active = nil
	self.can_get = nil
	self.is_get = nil
end

function LeiJiChargeLevelCell:OnClickGet()
	local is_active = KaifuActivityData.Instance:GetLeiJiChargeRewardIsActive(self.reward_data.seq)
	local is_fench = KaifuActivityData.Instance:GetLeiJiChargeRewardIsFetch(self.reward_data.seq)
	if is_active == 0 then
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHARGE_REPALMENT, RA_CHARGE_REPAYMENT_OPERA_TYPE.RA_CHARGE_REPAYMENT_OPERA_TYPE_FETCH_REWARD, self.reward_data.seq)
end

function LeiJiChargeLevelCell:SetItemData(data)
	self.reward_data = data
end

function LeiJiChargeLevelCell:SetCostData()
	local chongzhi_count = KaifuActivityData.Instance:GetLeiJiChargeValue()
	local color = chongzhi_count >= self.reward_data.charge_value and "#0000f1" or "#e40000"
	self.text1:SetValue(string.format(Language.Activity.LeiJiXiaoFei, color, chongzhi_count, self.reward_data.charge_value))
end

function LeiJiChargeLevelCell:OnFlush()
	self.item_cell_list[1]:SetData(self.reward_data.reward_item)
	local is_active = KaifuActivityData.Instance:GetLeiJiChargeRewardIsActive(self.reward_data.seq)
	local is_fench = KaifuActivityData.Instance:GetLeiJiChargeRewardIsFetch(self.reward_data.seq)
	self.is_active:SetValue(is_active == 1 and is_fench == 0)
	self.can_get:SetValue(is_active == 1 and is_fench == 0)
	local str = ""
	if is_active == 0 and is_fench == 0 then
		str = Language.Common.WEIDACHENG
	elseif is_active == 1 and is_fench == 0 then
		str = Language.Common.LingQu
	elseif is_active == 1 and is_fench == 1 then
		str = Language.Common.YiLingQu
	end
	self.btn_name:SetValue(str)
	self.is_get:SetValue(is_fench == 1)
end