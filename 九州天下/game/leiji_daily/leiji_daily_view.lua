LeiJiDailyView = LeiJiDailyView or BaseClass(BaseView)

function LeiJiDailyView:__init()
	self.ui_config = {"uis/views/leijirechargeview","LeiJiDailyView"}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg()
	self.reward_cell_list = {}
	self.frist_reward_cell_list = {}
end

function LeiJiDailyView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ChongZhi", BindTool.Bind(self.OnChongZhi, self))
	self:ListenEvent("GetFristReward", BindTool.Bind(self.GetFristReward, self))

	self.chongzhi_value = self:FindVariable("ChongzhiValue")
	self.next_chongzhi_value = self:FindVariable("NextChongzhi")
	self.show_chongzhi_value = self:FindVariable("ShowNextChongzhi")
	self.is_frist_recharge = self:FindVariable("IsFristRecharge")

	local reward_cfg = DailyChargeData.Instance:GetHuikuiRewardList()
	self.reward_data = reward_cfg
	self.reward_list = self:FindObj("List")
	local reward_view_delegate = self.reward_list.list_simple_delegate
	--生成数量
	reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	--刷新函数
	reward_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRewardListView, self)

	--self.is_frist_recharge:SetValue(true)

	-- for i = 1, 3 do
	-- 	local item_cell = ItemCell.New()
	-- 	item_cell:SetInstanceParent(self:FindObj("Item" .. i))
	-- 	self.frist_reward_cell_list[i] = item_cell
	-- 	self.frist_reward_cell_list[i]:SetData(frist_reward_cfg[1].reward_item[i - 1])
	-- end
end

function LeiJiDailyView:ReleaseCallBack()
	for k,v in pairs(self.reward_cell_list ) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}

	self.chongzhi_value = nil
	self.next_chongzhi_value = nil
	self.reward_list = nil
	self.show_chongzhi_value = nil
	self.is_frist_recharge = nil

	for i, v in ipairs(self.frist_reward_cell_list) do
		v:DeleteMe()
	end
	self.frist_reward_cell_list = {}
end

function LeiJiDailyView:OpenCallBack()
	self:Flush()
	KaiFuChargeData.Instance:LeiJiOpen()
end

function LeiJiDailyView:OnClickClose()
	self:Close()
end

function LeiJiDailyView:OnChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	ViewManager.Instance:Close(ViewName.DailyChargeView)
end

function LeiJiDailyView:GetFristReward()
	RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAHUIKUI, 0, 0)
end

function LeiJiDailyView:OnFlush()
	local today_recharge = KaiFuChargeData.Instance:GetChongZhiDaHuiKuiNun() or 0
	local next_cfg = DailyChargeData.Instance:GetNextRewardCfg(today_recharge)

	self.chongzhi_value:SetValue(today_recharge)
	if next_cfg then
		self.show_chongzhi_value:SetValue(true)
		self.next_chongzhi_value:SetValue(next_cfg.need_chongzhi - today_recharge)
	else
		self.show_chongzhi_value:SetValue(false)
	end
	if self.reward_list.scroller.isActiveAndEnabled then
		self.reward_list.scroller:RefreshAndReloadActiveCellViews(true)
	end

	local flag = KaiFuChargeData.Instance:GetChongZhiFlag(1)
	self.is_frist_recharge:SetValue(flag == 0)
end

function LeiJiDailyView:RefreshRewardListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = LeijiRewardItem.New(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end

	reward_cell:SetIndex(data_index)
	local reward_cfg = DailyChargeData.Instance:GetHuikuiRewardList()
	self.reward_data = reward_cfg
	reward_cell:SetData(self.reward_data[data_index])
end

function LeiJiDailyView:GetNumberOfCells()
	local reward_cfg = DailyChargeData.Instance:GetHuikuiRewardList()
	return #reward_cfg or 0
end


------------------------------------------------
-------------LeijiRewardItem
------------------------------------------------
LeijiRewardItem = LeijiRewardItem or BaseClass(BaseCell)
function LeijiRewardItem:__init(instance)
	self:ListenEvent("OnRewardBtn", BindTool.Bind(self.OnRewardBtn, self))
	self.cur_value = self:FindVariable("CurValue")
	self.kelingqu = self:FindVariable("KeLingQu")
	self.weidadao = self:FindVariable("WeiDaDao")
	self.yilingqu = self:FindVariable("YiLingQu")

	self.item_list = {}
	for i=0,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end
end

function LeijiRewardItem:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function LeijiRewardItem:OnFlush()
	if nil == self.data then return end	
	for i=0,2 do
		local item_data = self.data.reward_item[i]
		if item_data == nil then
			self.item_list[i]:SetItemActive(false)
		else
			self.item_list[i]:SetItemActive(true)
			self.item_list[i]:SetData(item_data)
		end
	end
	self.cur_value:SetValue(self.data.need_chongzhi)

	local today_recharge = KaiFuChargeData.Instance:GetChongZhiDaHuiKuiNun() or 0
	-- local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge or 0
	if today_recharge >= self.data.need_chongzhi then
		local flag = KaiFuChargeData.Instance:GetChongZhiFlag(self.data.seq + 1)
		if flag == 1 then
			self.weidadao:SetValue(false)
			self.kelingqu:SetValue(false)
			self.yilingqu:SetValue(true)
		else
			self.weidadao:SetValue(false)
			self.kelingqu:SetValue(true)
			self.yilingqu:SetValue(false)
		end
	else
			self.weidadao:SetValue(true)
			self.kelingqu:SetValue(false)
			self.yilingqu:SetValue(false)
	end
end	

function LeijiRewardItem:OnRewardBtn()
	if nil == self.data then return end
	RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAHUIKUI, self.data.seq, 0)
end