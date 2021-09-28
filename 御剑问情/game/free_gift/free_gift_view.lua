
FreeGiftView = FreeGiftView or BaseClass(BaseView)
local DISPLAYNAME = {
	[0004] = "free_gift_panel_1",
}
function FreeGiftView:__init()
	self.ui_config = {"uis/views/freegiftview_prefab","FreeGiftView"}
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
	self.day = 1
end

function FreeGiftView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))
	self.time_text = self:FindVariable("TimeText")
	self.time_text_1 = self:FindVariable("TimeText1")
	self.gold_need = self:FindVariable("GoldNeed")
	self.btn_enble = self:FindVariable("BtnEnble")
	self.btn_text = self:FindVariable("BtnText")
	self.text_been_gray = self:FindVariable("TextBeenGray")
	self.word_img = self:FindVariable("WordImg")
	self.gold_img = self:FindVariable("GoldImg")
	self.toggle_text1 = self:FindVariable("ToggleText1")
	self.toggle_text2 = self:FindVariable("ToggleText2")
	self.toggle_text3 = self:FindVariable("ToggleText3")
	self.remind1 = self:FindVariable("Remind1")
	self.remind2 = self:FindVariable("Remind2")
	self.remind3 = self:FindVariable("Remind3")
	self.Remind_day1 = self:FindVariable("Remind_day1")
	self.Remind_day2 = self:FindVariable("Remind_day2")
	self.Remind_day3 = self:FindVariable("Remind_day3")
	self.show_need = self:FindVariable("ShowNeed")
	self.need_gold = self:FindVariable("NeedGold")
	self.show_model_eff = self:FindVariable("ShowModelEff")
	self.level_limit = self:FindVariable("LevelLimit")
	self.show_free_text = self:FindVariable("ShowFreeText")
	self.fight_power = self:FindVariable("FightPower")
	self.display = self:FindObj("Display")
	self.toggle_list = {}
	self.day_list = {}
	for i = 1, 3 do
		self.toggle_list[i] = self:FindObj("Toggle" .. i)
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, i))

		self.day_list[i] = self:FindObj("Day" .. i)
		self.day_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleDay,self, i))
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
	self.time_text_1 = nil
	self.gold_need = nil
	self.display = nil
	self.toggle_list = {}
	self.day_list = {}
	self.item_list = {}
	self.btn_enble = nil
	self.text_been_gray = nil
	self.btn_text = nil
	if self.model then
		self.model:DeleteMe()
	end
	self.model = nil
	self.word_img = nil
	self.gold_img = nil
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
	self.Remind_day1 = nil
	self.Remind_day2 = nil
	self.Remind_day3 = nil
	self.fight_power = nil

	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
	self.seq = 0
	self.next_time = 0
	self.cur_state = 0
	self.day = 1
end

function FreeGiftView:OpenCallBack()
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if nil ~= zero_gift_info then
		local reward_flag = bit:d2b(zero_gift_info.reward_flag)
		for i = 1, 3 do
			if reward_flag[32 - i + 1] == 0 then
				self.day = i
				self:FlushDayToggle(i)
				break
			end
		end
	end
end

function FreeGiftView:OnToggleChange(index, isOn)
	if isOn and self.seq ~= index - 1 then
		self.seq = index - 1
		self.day = 1
		for k, v in pairs(self.day_list) do
			if k == 1 then
				v.toggle.isOn = true
			else
				v.toggle.isOn = false
			end
		end
	end
	self:Flush()
end

function FreeGiftView:OnToggleDay(index, isOn)
	if isOn and self.day ~= index then
		self.day = index
		self:Flush()
	end
end

function FreeGiftView:FlushDayToggle(day)
	local now_day = day
	if day > 3 then
		now_day = 3
	end
	for k, v in pairs(self.day_list) do
		if k == now_day then
			self.day = now_day
			v.toggle.isOn = true
		else
			v.toggle.isOn = false
		end
	end
	self:Flush()
end

function FreeGiftView:SetModel(model_show)
	if self.model == nil then
		self.model = RoleModel.New("free_gift_panel")
		self.model:SetDisplay(self.display.ui3d_display)
	end
	local open_day_list = Split(model_show, ",")
	local bundle, asset = open_day_list[1], open_day_list[2]
	local display_name = "free_gift_panel"
	for k,v in pairs(DISPLAYNAME) do
		local id = tonumber(asset)
		if id == k then
			display_name = v
			break
		end
	end
	self.model:SetPanelName(display_name)
	self.model:SetMainAsset(bundle, asset)
	if string.find(bundle, "goddess") ~= nil then
		self.model:SetTrigger("show_idle_1")
	elseif string.find(bundle, "mount") ~= nil then
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	end
end

function FreeGiftView:CloseCallBack()

end

function FreeGiftView:OnClickReward()
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if zero_gift_info.state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or zero_gift_info.state == ZERO_GIFT_STATE.ACTIVE_STATE then
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_BUY, self.seq, self.day - 1)
	else
		FreeGiftCtrl.SendZeroGiftOperate(ZERO_GIFT_OPERATE_TYPE.ZERO_GIFT_FETCH_REWARD_ITEM, self.seq, self.day - 1)
		self:FlushDayToggle(self.day + 1)
	end
end

function FreeGiftView:OnFlush(param)
	self.show_free_text:SetValue(self.seq == 0)					--第一档显示免费文本
	for i = 1, 3 do
		self["remind" .. i]:SetValue(FreeGiftData.Instance:GetZeroGiftRemindBySeq(i - 1))
	end
	local zero_gift_info = FreeGiftData.Instance:GetXeroGiftInfo(self.seq)
	if nil == zero_gift_info then return end
	local zero_gift_cfg = FreeGiftData.Instance:GetZeroGiftCfg(self.seq)
	if nil == zero_gift_cfg then return end
	local zero_gift_model_cfg = FreeGiftData.Instance:GetZeroGiftModelCfg(self.seq, self.day - 1)
	if nil == zero_gift_model_cfg then return end
	local gift = {}
	if self.day == 1 then
		gift = zero_gift_cfg.reward_item_list_0[0]
	elseif self.day == 2 then
		gift = zero_gift_cfg.reward_item_list_1[0]
	elseif self.day == 3 then
		gift = zero_gift_cfg.reward_item_list_2[0]
	end

	local gift_list = ItemData.Instance:GetGiftItemList(gift.item_id or 0)
	local effect_list = Split(zero_gift_model_cfg.effect_index, ",")
	for k,v in pairs(self.item_list) do
		local item_cfg = gift_list[k]
		v:Reset()
		if item_cfg then
			v:SetGiftItemId(gift.item_id)
			v:SetData(item_cfg)
		end
	end
	for k,v in pairs(effect_list) do
		if self.item_list[tonumber(v)] then
			self.item_list[tonumber(v)]:SetActivityEffect(false)
		end
	end
	self.next_time = TimeCtrl.Instance:GetServerTime() - zero_gift_info.timestamp
	self.cur_state = zero_gift_info.state
	if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
		self.next_time = zero_gift_info.timestamp - TimeCtrl.Instance:GetServerTime()
	end

	local data = CommonStruct.ItemDataWrapper()
	data.item_id = gift_list[1].item_id
	data.param = CommonStruct.ItemParamData()
	if gift.item_id and ForgeData.Instance:GetEquipIsNotRandomGift(data.item_id, gift.item_id)  then
		data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift.item_id)
	end
	local cur_equip_cap = EquipData.Instance:GetEquipLegendFightPowerByData(data, false, true)
	self.fight_power:SetValue(cur_equip_cap)

	local now_time = 0
	local last_time = 0
	if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) then
		now_time = self.next_time
		last_time = self.next_time
	else
		now_time = (self.day - 1) * 86400 - self.next_time
		last_time = 3 * 86400 - self.next_time
	end

	local reward_flag = bit:d2b(zero_gift_info.reward_flag)
	local can_reward = false
	if reward_flag[32 - self.day + 1] == 0 then
		can_reward = true
	elseif reward_flag[32 - self.day + 1] == 1 then
		can_reward = false
	end
	for i = 1, 3 do
		if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE)
		 and reward_flag[32 - i + 1] == 0 and self.next_time >= (i - 1) * 86400 then

			self["Remind_day" .. i]:SetValue(true)
		else
			self["Remind_day" .. i]:SetValue(false)
		end
	end

	self.btn_enble:SetValue(true)
	self.text_been_gray:SetValue(true)
	if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE and self.next_time < (self.day - 1) * 86400) or not can_reward
		 or self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE
		 or (self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and now_time > 0)
		 or (self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and not can_reward) then
		self.btn_enble:SetValue(false)
		self.text_been_gray:SetValue(false)
	end
	self.word_img:SetAsset(ResPath.GetZeroGiftBg(self.seq))
	local str = zero_gift_cfg.is_bind_gold == 1 and "bind_diamon" or "diamon"
	local asset, bundle = ResPath.GetImages(str, "icon_atlas")
	self.gold_img:SetAsset(asset, bundle)
	self.need_gold:SetValue(zero_gift_cfg.buy_gold)
	local show_need = zero_gift_cfg.buy_gold > 0 and (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE)
	self.show_need:SetValue(show_need)
	local level_limit = zero_gift_cfg.level_limit
	local role_level = PlayerData.Instance:GetRoleVo().level
	local color = role_level < level_limit and "fe3030" or "ffe500"
	self.level_limit:SetValue(zero_gift_cfg.buy_gold == 0 and string.format(Language.ZeroGift.LevelLimitText, color, PlayerData.GetLevelString(level_limit)) or "")
	self.show_model_eff:SetValue(zero_gift_model_cfg.model_effect == 1)
	self.time_text_1:SetValue(Language.ZeroGift.TimeText2)
	self:SetModel(zero_gift_model_cfg.model_show)

	self.btn_text:SetValue(Language.ZeroGift.BtnText[zero_gift_info.state] or Language.ZeroGift.BtnText[0])

	if not can_reward then
		self.btn_text:SetValue(Language.ZeroGift.BtnText[3])
	end

	if self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE and can_reward then
		self.btn_text:SetValue(Language.ZeroGift.BtnText[2])
	end
	if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and  zero_gift_cfg.buy_gold <= 0 then
		self.btn_text:SetValue(Language.ZeroGift.BtnTextFree)
	end
	self:FlushNextTime(now_time, last_time)

end

function FreeGiftView:FlushNextTime(now_time, last_time)
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
	local time = now_time
	if now_time < 0 then
		time = 0
	end
	local function diff_time_func (elapse_time, total_time)
		local left_time = total_time - elapse_time + 0.5
		if left_time <= 0.5 then
			if last_time < 0 and (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) then
				self.time_text:SetValue(Language.ZeroGift.TimeText3)
			else
				self.time_text:SetValue("")
			end
				self.time_text_1:SetValue("")
				self:RemoveCountDown()
				return
		end
		if (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) and left_time > 0 then
			local string = Language.ZeroGift.TimeText
			if self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE then
				string = Language.ZeroGift.TimeText2
			end
			self.time_text:SetValue(string.format(string, TimeUtil.FormatSecond2Str(left_time)))

		elseif (self.cur_state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.cur_state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) and left_time <= 0 then
			self.time_text:SetValue("")
			self.time_text_1:SetValue("")
		end

		if (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and left_time < 0 then
			self.time_text:SetValue(Language.ZeroGift.TimeText3)
			self.time_text_1:SetValue("")
		elseif (self.cur_state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or self.cur_state == ZERO_GIFT_STATE.ACTIVE_STATE) and left_time >= 0 then
			local string = Language.ZeroGift.TimeText2
			self.time_text:SetValue(string.format(string, TimeUtil.FormatSecond2Str(left_time)))
			self.time_text_1:SetValue("")
		end
	end

	diff_time_func(0, time)
	self.montser_count_down_list = CountDown.Instance:AddCountDown(time, 0.5, diff_time_func)
end

function FreeGiftView:RemoveCountDown()
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
end
