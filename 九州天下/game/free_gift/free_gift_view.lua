require("game/go_pawn/go_pawn_content_view")
FreeGiftView = FreeGiftView or BaseClass(BaseView)

function FreeGiftView:__init()
	self.ui_config = {"uis/views/freegiftview","FreeGiftView"}
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
	self:SetMaskBg()
end

function FreeGiftView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))
	self.time_text = self:FindVariable("TimeText")
	self.gold_need = self:FindVariable("GoldNeed")
	self.btn_enble = self:FindVariable("BtnEnble")
	self.btn_text = self:FindVariable("BtnText")
	self.word_img = self:FindVariable("WordImg")
	self.toggle_text1 = self:FindVariable("ToggleText1")
	self.toggle_text2 = self:FindVariable("ToggleText2")
	self.toggle_text3 = self:FindVariable("ToggleText3")
	self.remind1 = self:FindVariable("Remind1")
	self.remind2 = self:FindVariable("Remind2")
	self.remind3 = self:FindVariable("Remind3")
	self.show_need = self:FindVariable("ShowNeed")
	self.need_gold = self:FindVariable("NeedGold")
	self.show_model_eff = self:FindVariable("ShowModelEff")
	self.level_limit = self:FindVariable("LevelLimit")
	self.show_free_text = self:FindVariable("ShowFreeText")
	self.display = self:FindObj("Display")
	self.toggle_list = {}
	self.is_toggle_hl = {}
	for i = 1, 3 do
		self.is_toggle_hl[i] = self:FindVariable("ToggleHL" .. i)
		self.toggle_list[i] = self:FindObj("Toggle" .. i)
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, i))
		local cfg = FreeGiftData.Instance:GetZeroGiftCfg(i - 1)
		if cfg then
			self["toggle_text" .. i]:SetValue(cfg.name)
		end
	end
	self.item_list = {}
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end
end

function FreeGiftView:__delete()

end

function FreeGiftView:ReleaseCallBack()
	self.time_text = nil
	self.gold_need = nil
	self.display = nil
	self.toggle_list = {}

	for i=1, 3 do
		self.is_toggle_hl[i] = nil
	end
	self.is_toggle_hl = {}

	self.item_list = {}
	self.btn_enble = nil
	self.btn_text = nil
	if self.model then
		self.model:DeleteMe()
	end
	self.model = nil
	self.word_img = nil
	self.toggle_text1 = nil
	self.toggle_text2 = nil
	self.toggle_text3 = nil
	self.remind1 = nil
	self.remind2 = nil
	self.remind3 = nil
	self.need_gold = nil
	self.show_need = nil
	self.level_limit = nil
	self.show_model_eff = nil
	self.show_free_text = nil
	if self.reward_timer then
		GlobalTimerQuest:CancelQuest(self.reward_timer)
		self.reward_timer = nil
	end
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
end

function FreeGiftView:OpenCallBack()
	if self.toggle_list then
		local index = FreeGiftData.Instance:GetAutoIndex()
		if self.toggle_list[index] then
			self.toggle_list[index].toggle.isOn = true
		end
		if index == 1 then
			self:Flush()
		end
	end

end

function FreeGiftView:OnToggleChange(index, isOn)
	if isOn then
		for i=1, 3 do
			self.is_toggle_hl[i]:SetValue(i == index)
		end
		self.seq = index - 1
		self:Flush()
	end
end

function FreeGiftView:SetModel(model_show)
	if self.model == nil then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.display.ui3d_display)
	end
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	self.model:SetMainAsset(bundle, asset)
	self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ZEROGIFT], asset, 1)
end

function FreeGiftView:CloseCallBack()

end

function FreeGiftView:OnClickReward()
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if zero_gift_info.state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or zero_gift_info.state == ZERO_GIFT_STATE.ACTIVE_STATE then
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_BUY, self.seq)
	else
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_FETCH_REWARD_GOLD, self.seq)
	end
end

function FreeGiftView:OnFlush()
	self.show_free_text:SetValue(self.seq == 0)					--第一档显示免费文本
	for i = 1, 3 do
		self["remind" .. i]:SetValue(FreeGiftData.Instance:GetZeroGiftRemindBySeq(i - 1))
	end
	local zero_gift_cfg = FreeGiftData.Instance:GetZeroGiftCfg(self.seq)
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if nil == zero_gift_info then return end
	local gift = zero_gift_cfg.gift_item[0] or {}
	local gift_list = ItemData.Instance:GetGiftItemList(gift.item_id or 0)
	local effect_list = Split(zero_gift_cfg.effect_index, ",")
	for k,v in pairs(self.item_list) do
		local item_cfg = gift_list[k]
		v:Reset()
		if item_cfg then
			v:SetData(item_cfg)
		end
	end
	for k,v in pairs(effect_list) do
		if self.item_list[tonumber(v)] then
			self.item_list[tonumber(v)]:SetActivityEffect(false)
		end
	end
	self.next_time = zero_gift_info.timestamp
	self.cur_state = zero_gift_info.state
	self.btn_enble:SetValue(true)
	if ((self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and self.next_time <= TimeCtrl.Instance:GetServerTime())
	or (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE and self.next_time > TimeCtrl.Instance:GetServerTime())
	or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE then
		self.btn_enble:SetValue(false)
	end
	self.gold_need:SetValue(zero_gift_cfg.reward_gold)
	self.word_img:SetAsset(ResPath.GetZeroGiftBg(self.seq))
	self.need_gold:SetValue(Language.ZeroGift.BuyText .. zero_gift_cfg.buy_gold)
	local show_need = zero_gift_cfg.buy_gold > 0 and (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE)
	self.show_need:SetValue(show_need)
	local level_limit = zero_gift_cfg.level_limit
	local role_level = PlayerData.Instance:GetRoleVo().level
	self.level_limit:SetValue(zero_gift_cfg.buy_gold == 0 and string.format(Language.ZeroGift.LevelLimitText, PlayerData.GetLevelString(level_limit)) or "")
	self.show_model_eff:SetValue(zero_gift_cfg.model_effect == 1)
	self:FlushNextTime()
	self:SetModel(zero_gift_cfg.model_show)
	if self.reward_timer == nil then
		self.reward_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	self.btn_text:SetValue(Language.ZeroGift.BtnText[zero_gift_info.state] or Language.ZeroGift.BtnText[0])
	if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and  zero_gift_cfg.buy_gold <= 0 then
		self.btn_text:SetValue(Language.ZeroGift.BtnTextFree)
	end
end

function FreeGiftView:FlushNextTime()
	local time = self.next_time - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		local string = Language.ZeroGift.TimeText
		if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
			string = Language.ZeroGift.TimeText2
		end
		self.time_text:SetValue(string.format(string, TimeUtil.FormatSecond2Str(time)))
	else
		if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
			self.time_text:SetValue(Language.ZeroGift.TimeText3)
		else
			self.time_text:SetValue("")
		end
		if self.reward_timer then
			GlobalTimerQuest:CancelQuest(self.reward_timer)
			self.reward_timer = nil
		end
	end
end
