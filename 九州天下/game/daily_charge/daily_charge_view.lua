DailyChargeView = DailyChargeView or BaseClass(BaseView)

function DailyChargeView:__init()
	self.ui_config = {"uis/views/dailychargeview","DailyChargeView"}
	self:SetMaskBg()
	self.full_screen = false
	self.item_list = {}
	self.the_cell_list = {}
	self.reward_cfg = {}
	self.need_chongzhi = 0
end

function DailyChargeView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.Close, self))
	self:ListenEvent("chongzhi_click_1", BindTool.Bind(self.ChongZhiClick1, self))
	self:ListenEvent("chongzhi_click_2", BindTool.Bind(self.ChongZhiClick2, self))
	self:ListenEvent("chong_zhi", BindTool.Bind(self.OnChongZhiClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self:ListenEvent("select_reward_click", BindTool.Bind(self.OnSelectRewardClick, self))
	self.show_charge = self:FindVariable("show_charge")
	self.show_reward = self:FindVariable("show_reward")
	self.reward_btn = self:FindObj("reward_btn")
	self.reward_btn_img = self:FindVariable("reward_btn_img")
	self.reward_gray = self:FindObj("RewardGray")

	self.show_left_red_point = self:FindVariable("ShowLeftRedPoint")
	self.show_right_red_point = self:FindVariable("ShowRightRedPoint")

	self.btn_1 = self:FindVariable("btn_1")
	self.btn_2 = self:FindVariable("btn_2")

	self.model_display = self:FindObj("Display")
	self.model = RoleModel.New("daily_charge_item")
	self.model:SetDisplay(self.model_display.ui3d_display)

	self.select_item_id = 1
	self.select_item_info = {}

	for i=1,6 do
		local handler = function()
			local close_call_back = function()
				self:CancelHighLight()
			end
			self.item_list[i]:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		end
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
		self.item_list[i]:ListenClick(handler)
	end


	self.charge_toggle_10 = self:FindObj("charge_toggle_10")
	self.charge_toggle_99 = self:FindObj("charge_toggle_99")

	self:InitListView()
end

function DailyChargeView:ReleaseCallBack()
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

	self.reward_gray = nil
	self.show_charge = nil
	self.show_reward = nil
	self.reward_btn = nil
	self.reward_btn_img = nil
	self.show_left_red_point = nil
	self.show_right_red_point = nil
	self.btn_1 = nil
	self.btn_2 = nil
	self.model_display = nil
	self.charge_toggle_10 = nil
	self.charge_toggle_99 = nil
	self.list_view = nil
	self.reward_gray = nil
	self.reward_cfg = {}

end

function DailyChargeView:GetNumberOfCells()
	return #(DailyChargeData.Instance:GetDailyChongzhiTimesRewardAuto() or {})
end

function DailyChargeView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local week = TimeCtrl.Instance:GetTheDayWeek()							--当前周几
	local kaifu_time = TimeCtrl.Instance:GetCurOpenServerDay()				--当前开服天数
	local kaifu_day = 0
	if kaifu_time <= 6 then
		kaifu_day = 7
	else
		kaifu_day = 9999
	end
	-- self.reward_cfg = DailyChargeData.Instance:GetDailyChongzhiHuiKui(kaifu_day, DailyChargeData.Instance:GetDayIndex(), self.need_chongzhi)
	self.reward_cfg	= DailyChargeData.Instance:GetDayItemList(self.need_chongzhi)
	if self.reward_cfg then
		self:SetModel(self.reward_cfg)
	end
end

function DailyChargeView:SetModel(res_cfg)
	if not res_cfg or not next(res_cfg) then return end
	self.model:ResetRotation()
	self.model:SetMainAsset(res_cfg.path, res_cfg.model_id)
end

function DailyChargeView:RefreshCell(cell, cell_index)
	local the_cell = self.the_cell_list[cell]
	if the_cell == nil then
		the_cell = AccumulateChargeItem.New(cell.gameObject, self)
		self.the_cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	the_cell:SetIndex(cell_index)
	the_cell:SetNeedValue(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
	the_cell:Flush()
end

function DailyChargeView:OpenCallBack()
	local list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward_flag_list
	if list and list[32] == 1 and list[31] ~= 1 then
		--self.charge_toggle_99.toggle.isOn = true
		--self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99).select_reward_item[0]
	else
		--self.charge_toggle_10.toggle.isOn = true
		--self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self.select_item_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10).select_reward_item[0]
	end
	self:SetBtnText()
	self:FlushRedPoints()
	-- self.list_view.scroller:ReloadData(0)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("daily_charge_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.DailyCharge)
	end

	local list = DailyChargeData.Instance:GetFetchFlagInfo()
	self:FlushChongzhiItem(list[1])
	if list[32] == 0 then
		self.charge_toggle_10.toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
	else
		self.charge_toggle_99.toggle.isOn = true
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
	end
	self:FlushBtnStates()
	DailyChargeData.Instance:GetDailyChargeOpen()
end

function DailyChargeView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.btn_1:SetValue(reward_cfg[1].need_total_chongzhi)
	self.btn_2:SetValue(reward_cfg[2].need_total_chongzhi)
end

function DailyChargeView:ChongZhiClick1(is_click)
	if is_click then
		self.need_chongzhi = 0
		self:FlushChongzhiItem(0)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self:FlushBtnStates()
		self:InitListView()
	end
end

function DailyChargeView:ChongZhiClick2(is_click)
	if is_click then
		self.need_chongzhi = 1
		self:FlushChongzhiItem(1)
		self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
		self:FlushBtnStates()
		self:InitListView()
	end
end

function DailyChargeView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	ViewManager.Instance:Close(ViewName.DailyChargeView)
end

function DailyChargeView:OnRewardClick()
	local seq = DailyChargeData.Instance:GetDayRewardSeq(self.chongzhi_state)
	RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILYWEEK, seq, 1)
end


function DailyChargeView:OnSelectRewardClick()
	--local item_info_list = DailyChargeData.Instance:GetChongZhiReward(self.chongzhi_state).select_reward_item
	-- local sure_call_back = function(buy_num)

	-- end
	TipsCtrl.Instance:ShowDailySelectItemView(item_info_list,function(select_item_id)
		self.select_item_id = select_item_id
		-- self.item_list[9]:SetData(item_info_list[self.select_item_id-1])
	end)
end

function DailyChargeView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetDayItemList(chongzhi_state).reward_item
	if item_info_list == nil then return end 
	for i=1,6 do
		self.item_list[i]:SetData(item_info_list[i-1])
	end
end

function DailyChargeView:OnFlush()
	self:FlushRedPoints()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function DailyChargeView:FlushRedPoints()
	local reward_flag_list = DailyChargeData.Instance:GetFetchFlagInfo()
	local recharge = DailyChargeData.Instance.chongzhi_num
	if self.show_left_red_point then
		self.show_left_red_point:SetValue(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and (next(reward_flag_list) and reward_flag_list[32 - 0] == 0))
	end

	if self.show_right_red_point then
		self.show_right_red_point:SetValue(recharge >= CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 and (next(reward_flag_list) and reward_flag_list[32 - 1] == 0))
	end
end

function DailyChargeView:FlushBtnStates()
	local reward_flag_list = DailyChargeData.Instance:GetFetchFlagInfo()
	local recharge = DailyChargeData.Instance.chongzhi_num
	if recharge < self.chongzhi_state then
		self.show_charge:SetValue(true)
		self.show_reward:SetValue(false)
	else
		self.show_charge:SetValue(false)
		self.show_reward:SetValue(true)
	end
	local index = DailyChargeData.Instance:GetDayRewardSeq(self.chongzhi_state)
	if reward_flag_list[32 - index] == 0 then
		self.reward_btn.button.interactable = true
		self.reward_btn.grayscale.GrayScale = 0
		self.reward_gray.grayscale.GrayScale = 0
		self.reward_btn_img:SetAsset("uis/images", "Button_7Login")
	else
		self.reward_btn.button.interactable = false
		self.reward_btn.grayscale.GrayScale = 255
		self.reward_gray.grayscale.GrayScale = 255
		self.reward_btn_img:SetAsset("uis/images", "Button_7Login01")
	end
	self:OnFlushCellBtn()
end

function DailyChargeView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function DailyChargeView:OnFlushCellBtn()
	for k,v in pairs(self.the_cell_list) do
		v:OnFlushBtn()
	end
end
-------------------------------------------------------------------
AccumulateChargeItem = AccumulateChargeItem or BaseClass(BaseCell)
function AccumulateChargeItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self:ListenEvent("reward_btn", BindTool.Bind(self.RewardOnClick, self))
	self.fixed_days_text = self:FindVariable("fixed_days")
	self.current_days_text = self:FindVariable("current_days")
	self.chongzhi_value_text = self:FindVariable("chongzhi_value")
	self.reward_btn = self:FindObj("reward_btn")
	self.show_button = self:FindVariable("ShowBtn")
	self.is_btn_gray = self:FindVariable("IsBtnGray")
end

function AccumulateChargeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AccumulateChargeItem:SetNeedValue(chongzhi_value)
	self.chongzhi_value = chongzhi_value or 0
end

function AccumulateChargeItem:OnFlush()
	local cfg = DailyChargeData.Instance:GetChongzhiTimesCfg(self.index)
	if cfg == nil then return end

	local current_days = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_complete_days
	self.fixed_days_text:SetValue(cfg.complete_days)
	self.chongzhi_value_text:SetValue(self.chongzhi_value)
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







