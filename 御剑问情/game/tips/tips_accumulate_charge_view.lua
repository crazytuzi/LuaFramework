TipAccumulateChargeView = TipAccumulateChargeView or BaseClass(BaseView)
function TipAccumulateChargeView:__init()
	self.ui_config = {"uis/views/tips/accumulaterechargetips_prefab", "AccumulateRechargeView"}
	self.chongzhi_value = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
	--self.is_open = false
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipAccumulateChargeView:__delete()

end

function TipAccumulateChargeView:LoadCallBack()
	self.the_cell_list = {}
	self:ListenEvent("Close", BindTool.Bind(self.CloseOnClick, self))
	self:InitListView()
end

function TipAccumulateChargeView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipAccumulateChargeView:GetNumberOfCells()
	return 3
end

function TipAccumulateChargeView:OpenCallBack()
	--self.is_open = true
	self.list_view.scroller:ReloadData(0)
end

function TipAccumulateChargeView:CloseCallBack()
	--self.is_open = false
end

function TipAccumulateChargeView:GetIsOpen()
	return self.is_open
end

function TipAccumulateChargeView:RefreshCell(cell, cell_index)
	local the_cell = self.the_cell_list[cell]
	if the_cell == nil then
		the_cell = AccumulateChargeItem.New(cell.gameObject, self)
		self.the_cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	the_cell:OnFlush(cell_index, self.chongzhi_value)
end


function TipAccumulateChargeView:CloseOnClick()
	self:Close()
end

function TipAccumulateChargeView:OnFlushCellBtn()
	for k,v in pairs(self.the_cell_list) do
		v:OnFlushBtn()
	end
end

-------------------------------------------------------------------
AccumulateChargeItem = AccumulateChargeItem or BaseClass(BaseCell)
function AccumulateChargeItem:__init()
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self:ListenEvent("reward_btn", BindTool.Bind(self.RewardOnClick, self))
	self.fixed_days_text = self:FindVariable("fixed_days")
	self.current_days_text = self:FindVariable("current_days")
	self.chongzhi_value_text = self:FindVariable("chongzhi_value")
	self.reward_btn = self:FindObj("reward_btn")
	self.index = 0
end

function AccumulateChargeItem:OnFlush(index, chongzhi_value)
	self.index = index
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(index)
	self.fixed_days_text:SetValue(cfg.complete_days)
	self.chongzhi_value_text:SetValue(chongzhi_value)
	if current_days >= cfg.complete_days then
		current_days = cfg.complete_days
	end
	self.current_days_text:SetValue(current_days)
	self.item_cell:SetData(cfg.reward_item)
	self:OnFlushBtn()
end

function AccumulateChargeItem:RewardOnClick()
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(self.index)
	if current_days >= cfg.complete_days then
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY_TIMES, self.index, 0)
	else
		TipsCtrl.Instance:ShowSystemMsg("累积天数不足")
	end
end

function AccumulateChargeItem:SetToggleGroup(toggle_group)
	self.item_cell:SetToggleGroup(toggle_group)
end

function AccumulateChargeItem:OnFlushBtn()
	local list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_times_fetch_reward_flag_list
	if list[32 - self.index] == 1 then
		self.reward_btn.button.interactable = false
		self.reward_btn.grayscale.GrayScale = 255
	else
		self.reward_btn.button.interactable = true
		self.reward_btn.grayscale.GrayScale = 0
	end
end

