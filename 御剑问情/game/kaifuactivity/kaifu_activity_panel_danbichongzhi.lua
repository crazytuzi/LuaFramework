KaifuActivityPanelDanBiChongZhi = KaifuActivityPanelDanBiChongZhi or BaseClass(BaseRender)
function KaifuActivityPanelDanBiChongZhi:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function KaifuActivityPanelDanBiChongZhi:__delete()
	-- body
end

function KaifuActivityPanelDanBiChongZhi:OpenCallBack()
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DANBI_CHONGZHI)
	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	self.reward_list, self.charge_list = KaifuActivityData.Instance:GetDanBiChongZhiRankInfoListByDay(opengameday)

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

end

function KaifuActivityPanelDanBiChongZhi:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KaifuActivityPanelDanBiChongZhi:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KaifuActivityPanelDanBiChongZhi:GetNumberOfCells()
	return #self.reward_list
end

function KaifuActivityPanelDanBiChongZhi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = DanBiChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:SetChargeValue(self.charge_list[cell_index])
	contain_cell:Flush()
end

function KaifuActivityPanelDanBiChongZhi:SetTime(rest_time)
	local time_str = ""
	local left_day = math.floor(rest_time / 86400)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 8)
	else
		time_str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(time_str)
end

function KaifuActivityPanelDanBiChongZhi:OnFlush()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())
	end
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

------------------------------DanBiChongZhiCell-------------------------------------
DanBiChongZhiCell = DanBiChongZhiCell or BaseClass(BaseCell)
function DanBiChongZhiCell:__init()
	self.tips = self:FindVariable("tips")
	self.tips_2 = self:FindVariable("tips_2")
	self.charge_value = 0
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self.item_state_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		self.item_state_list[i] = self:FindVariable("is_show_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
	end

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function DanBiChongZhiCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.tips = nil
	self.tips_2 = nil
	self.item_cell_obj_list = nil
end

function DanBiChongZhiCell:SetChargeValue(value)
	self.charge_value = value
end

function DanBiChongZhiCell:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		local reward_list = ItemData.Instance:GetItemConfig(self.data.item_id)
		if nil == reward_list.item_1_id then
			self.item_cell_list[1]:SetData({item_id = reward_list.id , num = 1, is_bind = 1})
			self.item_state_list[1]:SetValue(true)
			for i = 2, 4 do
				self.item_state_list[i]:SetValue(false)
			end
		else
			local reward_item_list = {}
			for i = 1, 4 do
				self.item_state_list[i]:SetValue(true)
				reward_item_list[i] = {
				item_id = reward_list["item_"..i.."_id"],
				num = reward_list["item_"..i.."_num"],
				is_bind = reward_list["is_bind_"..i],}
				self.item_cell_list[i]:SetData(reward_item_list[i])
			end
		end
	end
	local str = string.format(Language.Activity.DanBiChongZhiTips, self.charge_value)
	self.tips:SetValue(str)
	self.tips_2:SetValue(Language.Activity.DanBiChongZhiTips2)
end

function DanBiChongZhiCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end