PinkEquipView = PinkEquipView or BaseClass(BaseRender)
function PinkEquipView:__init()

end

function PinkEquipView:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.reward_item ~= nil then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
end

function PinkEquipView:LoadCallBack()
	self.btn_text = self:FindVariable("BtnText")
	self.desc = self:FindVariable("Desc")
	self.end_time = self:FindVariable("EndTime")
	self.times = self:FindVariable("Times")
	self.show_red = self:FindVariable("ShowRedPoint")
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("ItemCell"))
	self:ListenEvent("OnClickCharge", BindTool.Bind(self.OnClickCharge, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_DAILY_TOTAL_CHONGZHI, 
		RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE.RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_ALL_INFO)
	self:UpdateActiveTime()
	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateActiveTime, self), 1)
	end

	local today_config = KaiFuChargeData.Instance:GetTodayConfig()[1] or {}
	if today_config.reward_item then
		local gift_reward_list = ItemData.Instance:GetGiftItemListByProf(today_config.reward_item[0].item_id)
		self.reward_item:SetGiftItemId(today_config.reward_item[0].item_id)
		if gift_reward_list then
			self.reward_item:SetData(gift_reward_list[1])
		end	
	end
end

function PinkEquipView:OnFlush()
	local can_get, param, can_get_times = KaiFuChargeData.Instance:CanGetReward()
	local charge_num = KaiFuChargeData.Instance:GetDailyCHongZhiNum()
	local need_gold = can_get and 0 or param
	self.desc:SetValue(string.format(Language.PinkEquip.Desc, charge_num, need_gold))
	local btn_str = can_get and Language.PinkEquip.BtnGet or Language.PinkEquip.BtnCharge
	self.btn_text:SetValue(btn_str)
	local today_config = KaiFuChargeData.Instance:GetTodayConfig()[1]
	local max_times = KaiFuChargeData.Instance:GetPinkMaxTimes()
	if can_get then
		local now_get_num =  KaiFuChargeData.Instance:GetFetchTimesBySeq(param)
		if now_get_num >= max_times then
			can_get_times = 0
		end
		if now_get_num + can_get_times > max_times then
			can_get_times = max_times - now_get_num
		end
	end
	self.times:SetValue(can_get_times)
	self.show_red:SetValue(can_get_times > 0)
end

function PinkEquipView:UpdateActiveTime()
	local active_end_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_DAILY_TOTAL_CHONGZHI)
	self.end_time:SetValue(TimeUtil.FormatTable2HMS(TimeUtil.Format2TableDHMS(active_end_time)))
end

function PinkEquipView:OnClickCharge()
	local can_get, param = KaiFuChargeData.Instance:CanGetReward()
	if can_get then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_DAILY_TOTAL_CHONGZHI, 
			RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE.RA_SUPER_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD, param)
	else
		ViewManager.Instance:Open(ViewName.RechargeView)
	end
end

function PinkEquipView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(232)
end