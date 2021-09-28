DailyChargeContentView = DailyChargeContentView or BaseClass(BaseRender)

function DailyChargeContentView:__init(instance)
	DailyChargeContentView.Instance = self
	self:ListenEvent("chongzhi_click_1", BindTool.Bind(self.ChongZhiClick1, self))
	self:ListenEvent("chongzhi_click_2", BindTool.Bind(self.ChongZhiClick2, self))
	self:ListenEvent("chong_zhi", BindTool.Bind(self.OnChongZhiClick, self))
	-- self:ListenEvent("accumulative_reward_click", BindTool.Bind(self.OnAccumulativeRewardClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self:ListenEvent("select_reward_click", BindTool.Bind(self.OnSelectRewardClick, self))
	self.show_charge = self:FindVariable("show_charge")
	self.show_reward = self:FindVariable("show_reward")
	self.reward_btn = self:FindObj("reward_btn")
	self.reward_btn_img = self:FindVariable("reward_btn_img")
	self.reward_text_change = self:FindVariable("reward_text_change")
	self.been_gray = self:FindVariable("been_gray")

	self.show_left_red_point = self:FindVariable("ShowLeftRedPoint")
	self.show_right_red_point = self:FindVariable("ShowRightRedPoint")

	self.btn_1 = self:FindVariable("btn_1")
	self.btn_2 = self:FindVariable("btn_2")

	self.model_display = self:FindObj("Display")
	self.model = RoleModel.New("daily_charge_content_panel")
	self.model:SetDisplay(self.model_display.ui3d_display)
	-- self.model:SetMainAsset("actors/monster/2002", "2002001")

	self.select_item_id = 1
	self.item_list = {}
	self.select_item_info = {}

	for i=1,6 do
		local handler = function()
			local close_call_back = function()
				self:CancelHighLight()
			end
			self.item_list[i]:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		end
		self.item_list[i] = ItemCell.New(self:FindObj("item_" .. i))
		self.item_list[i]:ListenClick(handler)
	end


	self.charge_toggle_10 = self:FindObj("charge_toggle_10")
	self.charge_toggle_99 = self:FindObj("charge_toggle_99")

	self.the_cell_list = {}
	self:InitListView()

end

function DailyChargeContentView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.the_cell_list) do
		v:DeleteMe()
	end
	self.the_cell_list = {}

	self.reward_text_change = nil
	self.been_gray = nil
	DailyChargeContentView.Instance = nil
end

function DailyChargeContentView:GetNumberOfCells()
	return #(DailyChargeData.Instance:GetDailyChongzhiTimesRewardAuto() or {})
end

function DailyChargeContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()[1]



	if reward_cfg then
		self:SetModel(reward_cfg.queen_show_item1)
	end
end

function DailyChargeContentView:SetModel(res)
	
	self.model:ResetRotation()
	self.model:SetPanelName("daily_charge_content_panel")
	self.model:SetMainAsset(ResPath.GetPifengModel(res))
	-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.DAILY_CHARGE], res, DISPLAY_PANEL.HUAN_HUA)
end

function DailyChargeContentView:RefreshCell(cell, cell_index)
	local the_cell = self.the_cell_list[cell]
	if the_cell == nil then
		the_cell = AccumulateChargeItem.New(cell.gameObject, self)
		self.the_cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	the_cell:OnFlush(cell_index, CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
end

function DailyChargeContentView:OpenCallBack()
	local list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward_flag_list
	if list and list[32] == 1 and list[31] ~= 1 then
		self.charge_toggle_99.toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99).select_reward_item[0]
	else
		self.charge_toggle_10.toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10).select_reward_item[0]
	end
	self:FlushBtnState()
	self:SetBtnText()
	self:FlushRedPoints()
	-- self.list_view.scroller:ReloadData(0)
end

function DailyChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.btn_1:SetValue(reward_cfg[1].need_total_chongzhi)
	self.btn_2:SetValue(reward_cfg[2].need_total_chongzhi)
end

function DailyChargeContentView:JumpToNextReward()
	local recharge_cfg = DailyChargeData.Instance:GetChongZhiInfo()
	if nil == recharge_cfg or nil == next(recharge_cfg) then return end

	local recharge = recharge_cfg.daily_chongzhi_value
	local reward_flag_list = recharge_cfg.daily_chongzhi_fetch_reward_flag_list

	if nil == recharge or nil== reward_flag_list then return end

	if recharge < self.chongzhi_state then return end

	if reward_flag_list[32] == 1 and reward_flag_list[31] ~= 1 and not self.charge_toggle_99.toggle.isOn then
		self.charge_toggle_99.toggle.isOn = true
		self:ChongZhiClick2(true)
	elseif reward_flag_list[31] == 1 and reward_flag_list[32] ~= 1 and not self.charge_toggle_10.toggle.isOn then
		self.charge_toggle_10.toggle.isOn = true
		self:ChongZhiClick1(true)
	end
end

function DailyChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self:FlushBtnState()
	end
end

function DailyChargeContentView:ChongZhiClick2(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self:FlushBtnState()
	end
end

function DailyChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function DailyChargeContentView:OnRewardClick()
	local seq = DailyChargeData.Instance:GetRewardSeq(self.chongzhi_state)
	RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY, seq, 1)
end


function DailyChargeContentView:OnSelectRewardClick()
	local item_info_list = DailyChargeData.Instance:GetChongZhiReward(self.chongzhi_state).select_reward_item
	-- local sure_call_back = function(buy_num)

	-- end
	TipsCtrl.Instance:ShowDailySelectItemView(item_info_list,function(select_item_id)
		self.select_item_id = select_item_id
		-- self.item_list[9]:SetData(item_info_list[self.select_item_id-1])
	end)
end

function DailyChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetDailyGiftInfoList(chongzhi_state)
	for i=1,6 do
		self.item_list[i]:SetData(item_info_list[i])
	end
	local select_item_list = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).select_reward_item

	-- self.item_list[9]:SetData(select_item_list[self.select_item_id-1])
end

function DailyChargeContentView:OnFlush()
	self:FlushRedPoints()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
	self:JumpToNextReward()
end

function DailyChargeContentView:FlushRedPoints()
	local recharge_cfg = DailyChargeData.Instance:GetChongZhiInfo()
	local recharge = recharge_cfg.daily_chongzhi_value or 0
	local reward_flag_list = recharge_cfg.daily_chongzhi_fetch_reward_flag_list or {}

	if self.show_left_red_point then
		self.show_left_red_point:SetValue(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and (next(reward_flag_list) and reward_flag_list[32 - 0] == 0))
	end

	if self.show_right_red_point then
		self.show_right_red_point:SetValue(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 and (next(reward_flag_list) and reward_flag_list[32 - 1] == 0))
	end
end

function DailyChargeContentView:FlushBtnState()
	local recharge_cfg = DailyChargeData.Instance:GetChongZhiInfo()
	local recharge = recharge_cfg.daily_chongzhi_value
	local reward_flag_list = recharge_cfg.daily_chongzhi_fetch_reward_flag_list
	if recharge < self.chongzhi_state then
		if self.show_charge then
			self.show_charge:SetValue(true)
		end
		if self.show_reward then
			self.show_reward:SetValue(false)
		end
	else
		if self.show_charge then
			self.show_charge:SetValue(false)
		end
		if self.show_reward then
			self.show_reward:SetValue(true)
		end

		local index = 0
		if self.chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
			index = 0
		elseif self.chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
			index = 1
		end
		if reward_flag_list[32 - index] == 0 then
			self.reward_btn.button.interactable = true
			self.reward_btn.grayscale.GrayScale = 0
			self.reward_btn_img:SetAsset("uis/images_atlas", "btn_06")
			self.reward_text_change:SetValue(Language.FirstCharge.ButtonText2)
			self.been_gray:SetValue(true)
		else
			self.reward_btn.button.interactable = false
			self.reward_btn.grayscale.GrayScale = 255
			self.reward_text_change:SetValue(Language.FirstCharge.ButtonText)
			self.been_gray:SetValue(false)
		end
	end

	self:OnFlushCellBtn()
end

function DailyChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end


function DailyChargeContentView:OnFlushCellBtn()
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
	self.show_button = self:FindVariable("ShowBtn")
	self.is_btn_gray = self:FindVariable("IsBtnGray")
	self.index = 0
end

function AccumulateChargeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AccumulateChargeItem:OnFlush(index, chongzhi_value)
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(index)
	if cfg == nil then return end
	self.index = index
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
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
	self.show_button:SetValue(list[32 - self.index] ~= 1)
	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(self.index)

	-- self.reward_btn.button.interactable = current_days >= cfg.complete_days
	-- self.reward_btn.grayscale.GrayScale = current_days >= cfg.complete_days and 0 or 255
	self.is_btn_gray:SetValue(current_days >= cfg.complete_days)

	-- if list[32 - self.index] == 1 then
	-- 	self.reward_btn.button.interactable = false
	-- 	self.reward_btn.grayscale.GrayScale = 255
	-- else
	-- 	self.reward_btn.button.interactable = true
	-- 	self.reward_btn.grayscale.GrayScale = 0
	-- end
end







