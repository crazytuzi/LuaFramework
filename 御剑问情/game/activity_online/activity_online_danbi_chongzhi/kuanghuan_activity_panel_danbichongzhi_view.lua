require("game/activity_online/activity_online_item_cell")
KuanHuanActivityPanelDanBiChongZhiView = KuanHuanActivityPanelDanBiChongZhiView or BaseClass(BaseRender)
function KuanHuanActivityPanelDanBiChongZhiView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
	self.act_id = 0
end

function KuanHuanActivityPanelDanBiChongZhiView:__delete()
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
end

function KuanHuanActivityPanelDanBiChongZhiView:OpenCallBack()
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local end_time = ActivityOnLineData.Instance:GetRestTime(self.act_id)
	self.reward_list = KuanHuanActivityPanelDanBiChongZhiData.Instance:GetSingleCfgInfo(self.act_id)

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	end_time = end_time - TimeCtrl.Instance:GetServerTime() 
	self:SetTime(end_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(end_time, 1, function ()
			end_time = end_time - 1
            self:SetTime(end_time)
        end)
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())

	self.danbi_charge = self:FindVariable("ShowDesc")

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
end

function KuanHuanActivityPanelDanBiChongZhiView:SetActId(act_id)
	self.act_id = act_id
end

function KuanHuanActivityPanelDanBiChongZhiView:PanelClick()
	KuanHuanActivityPanelDanBiChongZhiData.Instance:SetIsOpen(true)
	RemindManager.Instance:Fire(RemindName.OnLineDanBi)
end

function KuanHuanActivityPanelDanBiChongZhiView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KuanHuanActivityPanelDanBiChongZhiView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KuanHuanActivityPanelDanBiChongZhiView:GetNumberOfCells()
	return GetListNum(self.reward_list)
end

function KuanHuanActivityPanelDanBiChongZhiView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = KuanHuanDanBiChongZhiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	
	local cfg = KuanHuanActivityPanelDanBiChongZhiData.Instance:GetSingleInfoById(self.act_id)
	if nil == cfg then
		return
	end

	local reward_type = KuanHuanActivityPanelDanBiChongZhiData.Instance:GetRewardType(self.act_id)

	local reward_time = KuanHuanActivityPanelDanBiChongZhiData.Instance:GetSingleRewardTime(self.act_id, cell_index)
	self.danbi_charge:SetValue(reward_type)
	contain_cell:SetType(reward_type)

	contain_cell:SetRewardTime(reward_time)
	contain_cell:SetData(self.reward_list[cell_index])

	cell_index = cell_index + 1
end

function KuanHuanActivityPanelDanBiChongZhiView:SetTime(rest_time)
	local time_str = ""
	local left_day = math.floor(rest_time / 86400)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 8)
	else
		time_str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(time_str)
end

function KuanHuanActivityPanelDanBiChongZhiView:OnFlush(param_t)
	self.reward_list = KuanHuanActivityPanelDanBiChongZhiData.Instance:GetSingleCfgInfo(self.act_id)
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.list_view then
				self.list_view.scroller:ReloadData(0)
			end
		elseif k == "danbi" then
			self.list_view.scroller:RefreshActiveCellViews()
		end
	end

	if self.chongzhi_count then
		self.chongzhi_count:SetValue(KaifuActivityData.Instance:GetDayChongZhiCount())
	end
end

------------------------------KuanHuanDanBiChongZhiCell-------------------------------------
KuanHuanDanBiChongZhiCell = KuanHuanDanBiChongZhiCell or BaseClass(BaseCell)
function KuanHuanDanBiChongZhiCell:__init()
	self.tips = self:FindVariable("tips")
	self.tips_2 = self:FindVariable("tips_2")
	self.reward_type = 0
	self.show_reward_time = self:FindVariable("ShowRewardTime")
	self.reward_time = self:FindVariable("RewardTime")
	self.list_view = self:FindObj("ListView")

	self.cfg = nil
	self.cell_list = {}
	local list_delegate = self.list_view.list_simple_delegate

	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	
end

function KuanHuanDanBiChongZhiCell:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.cell_list = {}
	end

	self.tips = nil
	self.tips_2 = nil
	self.cfg = nil
end

function KuanHuanDanBiChongZhiCell:SetType(reward_type)
	self.reward_type = reward_type
end

function KuanHuanDanBiChongZhiCell:SetRewardTime(reward_time)
	self.reward_time_num = reward_time
end

function KuanHuanDanBiChongZhiCell:OnFlush()
	if nil == self.data then
		return
	end

	self.show_reward_time:SetValue(self.reward_type)
	self.reward_time:SetValue(self.reward_time_num)

	self.list_view.scroller:ReloadData(0)

	local str = string.format(Language.Activity.DanBiChongZhiTips, ToColorStr(self.data.charge_value, COLOR.BLUE_4))
	self.tips:SetValue(str)
	if self.reward_type then
		self.tips_2:SetValue(Language.Activity.ChongZhiDesc2)
	else
		self.tips_2:SetValue(Language.Activity.ChongZhiDesc)
	end
end

function KuanHuanDanBiChongZhiCell:GetNumberOfCells()
	local reward_item = self.data.reward_item
	self.cfg = ItemData.Instance:GetGiftItemListByProf(reward_item.item_id)
	local num = GetListNum(self.cfg)
	return num
end

function KuanHuanDanBiChongZhiCell:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local list_cell = self.cell_list[cell]
	if nil == list_cell then
		list_cell = KuanHuanDanBiChongZhiItem.New(cell)
		self.cell_list[cell] = list_cell
	end

	list_cell:SetData(self.cfg[data_index])
end

function KuanHuanDanBiChongZhiCell:OnClickGet()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

------------------------------KuanHuanDanBiChongZhiItem---------------
