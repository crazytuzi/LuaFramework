require("game/molong/molong_info_view")
require("game/molong/expedition_view")
require("game/molong/sword_art_online_view")
require("game/magic_card/magic_card_attr_view")
require("game/magic_card/magic_card_uplevel_view")
require("game/magic_card/magic_card_lotto_view")
require("game/magic_card/magic_card_exchange_view")
require("game/horoscope/horoscope_attr_view")
require("game/horoscope/horoscope_equip_view")
require("game/horoscope/horoscope_starmap_view")

MoLongView = MoLongView or BaseClass(BaseView)

function MoLongView:__init()
	self.ui_config = {"uis/views/molong","MoLongView"}
	MoLongView.Instance = self
	self.full_screen = true
	self.play_audio = true
end

function MoLongView:ReleaseCallBack()
	if self.molong_info_view ~= nil then
		self.molong_info_view:DeleteMe()
		self.molong_info_view = nil
	end

	if self.expedition_view ~= nil then
		self.expedition_view:DeleteMe()
		self.expedition_view = nil
	end

	if self.magic_card_attr_view ~= nil then
		self.magic_card_attr_view:DeleteMe()
		self.magic_card_attr_view = nil
	end

	if self.magic_card_uplevel_view ~= nil then
		self.magic_card_uplevel_view:DeleteMe()
		self.magic_card_uplevel_view = nil
	end

	if self.magic_card_lotto_view ~= nil then
		self.magic_card_lotto_view:DeleteMe()
		self.magic_card_lotto_view = nil
	end

	if self.magic_card_exchange_view ~= nil then
		self.magic_card_exchange_view:DeleteMe()
		self.magic_card_exchange_view = nil
	end

	if self.sword_art_online_view ~= nil then
		self.sword_art_online_view:DeleteMe()
		self.sword_art_online_view = nil
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function MoLongView:LoadCallBack()
	self.bg01 = self:FindObj("Bg01")
	self.bg02 = self:FindObj("Bg02")
	self.bg03 = self:FindObj("Bg03")
	self.bg04 = self:FindObj("Bg04")
	self.left_molong_bt = self:FindObj("LeftMoLongBt")
	self.left_magic_card_bt = self:FindObj("LeftMagicCardBt")
	self.left_horoscope_bt = self:FindObj("LeftHoroscopeBt")
	self.left_sao_bt = self:FindObj("LeftSwordArtOnlineBt")

	self:ListenEvent("left_molong_toggle",BindTool.Bind(self.OnLeftMoLongToggle, self))
	self:ListenEvent("horoscope_left_toggle",BindTool.Bind(self.OnLeftHoroscopeToggle, self))
	self:ListenEvent("left_magic_toggle",BindTool.Bind(self.OnLeftMagicCardToggle, self))
	self:ListenEvent("sword_art_online_toggle",BindTool.Bind(self.SwordArtOnlineToggle, self))
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView,self))

	self.molong_red_point = self:FindVariable("molong_red_point")
	self.expedition_red_point = self:FindVariable("expedition_red_point")
	self.magic_card_red_point = self:FindVariable("magic_card_red_point")
	self.sword_red_point = self:FindVariable("sword_red_point")
	self.horoscope_attr_red_point = self:FindVariable("horoscope_attr_red_point")
	self.horoscope_equip_red_point = self:FindVariable("horoscope_equip_red_point")
	self.horoscope_starmap_red_point = self:FindVariable("horoscope_starmap_red_point")

	-- 功能开启
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))

	-- 魔龙
	self.molong_bt = self:FindObj("MoLongBt")
	self.expedition_bt = self:FindObj("ExpeditionBt")
	self.exchange_bt = self:FindObj("ExchangeBt")
	self.molong_info_view = MoLongInfoView.New(self:FindObj("molong_panel"))
	self.expedition_view = ExpeditionView.New(self:FindObj("expedition_panel"))

	self:ListenEvent("molong_toggle",BindTool.Bind(self.OnMolongToggle, self))
	self:ListenEvent("expedition_toggle",BindTool.Bind(self.OnExpeditionToggle, self))

	-- 魔卡
	self.magic_card_attr_view = MaGicCardAttrView.New(self:FindObj("magiccard_attributepanel"))
	self.magic_card_uplevel_view = MagicCardUpView.New(self:FindObj("magiccard_uplevelpanel01"))
	self.magic_card_lotto_view = MagicCardLottoView.New(self:FindObj("magiccard_lottopanel"))
	self.magic_card_exchange_view = MaGicCardExChangeView.New(self:FindObj("magiccard_exchangepanel"))

	self.magiccard_attribute_bt = self:FindObj("magiccard_attributebt")
	self.magiccard_uplevel_bt = self:FindObj("magiccard_uplevelbt")
	self.magiccard_lotto_bt = self:FindObj("magiccard_lottobt")
	self.magiccard_exchange_bt = self:FindObj("magiccard_exchangebt")

	self:ListenEvent("up_mcattr_toggle",BindTool.Bind(self.OnUpMcAttrToggle, self))
	self:ListenEvent("up_mcuplevel_toggle",BindTool.Bind(self.OnUpMcUpLevelToggle, self))
	self:ListenEvent("up_mclotto_toggle",BindTool.Bind(self.OnUpMcLottoToggle, self))
	self:ListenEvent("up_mcexchange_toggle",BindTool.Bind(self.OnUpMcExChangeToggle, self))

	-- 十二星座
	self.horoscope_attr_view = HoroscopeAttrView.New(self:FindObj("horoscope_attr_panel"))
	self.horoscope_equip_view = HoroscopeEquipView.New(self:FindObj("equip_panel"))
	self.horoscope_starmap_view = HoroscopeStarMapView.New(self:FindObj("starmap_panel"))

	self.horoscope_attr_bt = self:FindObj("horoscope_attr_bt")
	self.horoscope_equip_bt = self:FindObj("horoscope_equip_bt")
	self.horoscope_starmap_bt = self:FindObj("horoscope_starmap_bt")

	self:ListenEvent("horoscope_attr_toggle",BindTool.Bind(self.OnHoroscopeAttrToggle, self))
	self:ListenEvent("horoscope_equip_toggle",BindTool.Bind(self.OnEquipToggle, self))
	self:ListenEvent("horoscope_starmap_toggle",BindTool.Bind(self.OnStarMapToggle, self))

	-- 刀剑神域
	self.sword_art_online_view = SwordArtOnlineView.New(self:FindObj("sword_art_onlinepanel"))
	self.sword_art_online_bt = self:FindObj("LeftSwordArtOnlineBt")
end

function MoLongView:ShowOrHideTab()
	if self:IsOpen() then
		local show_list = {}
		local open_fun_data = OpenFunData.Instance
		show_list.left_molong_bt = open_fun_data:CheckIsHide("yu_hun")
		show_list.left_magic_card_bt = open_fun_data:CheckIsHide("magic_card")
		show_list.left_horoscope_bt = open_fun_data:CheckIsHide("horoscope")
		show_list.left_sao_bt = open_fun_data:CheckIsHide("sword_art_online")

		self.left_molong_bt:SetActive(show_list.left_molong_bt)
		self.left_magic_card_bt:SetActive(show_list.left_magic_card_bt)
		self.left_horoscope_bt:SetActive(show_list.left_horoscope_bt)
		self.left_sao_bt:SetActive(show_list.left_sao_bt)
	end
end

-- 红点
function MoLongView:MoLongShowRedPoint(is_show)
	self.molong_red_point:SetValue(is_show)
end

function MoLongView:ExpeditionShowRedPoint(is_show)
	self.expedition_red_point:SetValue(is_show)
end

function MoLongView:MagicCardShowRedPoint(is_show)
	self.magic_card_red_point:SetValue(is_show)
end

function MoLongView:SwordArtOnlineShowRedPoint(is_show)
	self.sword_red_point:SetValue(is_show)
end

function MoLongView:HoroscopeAttrShowRedPoint(is_show)
	self.horoscope_attr_red_point:SetValue(is_show)
end

function MoLongView:HoroscopeEquipShowRedPoint(is_show)
	self.horoscope_equip_red_point:SetValue(is_show)
end

function MoLongView:HoroscopeStarMapShowRedPoint(is_show)
	self.horoscope_starmap_red_point:SetValue(is_show)
end
-- end

function MoLongView:FlushRedPoint()
	if MagicCardData.Instance:GetCardCanActive() then
		self:MagicCardShowRedPoint(true)
	else
		self:MagicCardShowRedPoint(false)
	end

	self.sword_art_online_view:FlushSwordRedPt()
end

function MoLongView:OnUpMcAttrToggle()
	self.magic_card_attr_view:FlushInfoView()
	self.bg02:SetActive(false)
end

function MoLongView:OnUpMcUpLevelToggle()
	self.bg02:SetActive(false)
	self.magic_card_uplevel_view:SetCurIndex(self.magic_card_attr_view:GetCurIndex())
	self.magic_card_uplevel_view:FlushInfoView()
	self.magiccard_uplevel_bt.toggle.isOn = true
end

function MoLongView:OnUpMcLottoToggle()
	self.magiccard_lotto_bt.toggle.isOn = true
	self.bg02:SetActive(true)
	self.magic_card_lotto_view:FlushInfoView()
end

function MoLongView:OnUpMcExChangeToggle()
	self.bg02:SetActive(true)
	self.magic_card_exchange_view:FlushInfoView()
end

function MoLongView:OnLeftMoLongToggle()
	self.bg02:SetActive(false)
	self.bg03:SetActive(false)
	if self.molong_bt.toggle.isOn then
		self.bg04:SetActive(false)
		self.molong_info_view:FlushInfoView()
	elseif self.expedition_bt.toggle.isOn then
		self.bg04:SetActive(true)
		self.expedition_view:FlushExpeditionView()
	--elseif self.exchange_bt.toggle.isOn then
	end
end

function MoLongView:OnLeftHoroscopeToggle()
	self.left_horoscope_bt.toggle.isOn = true
	self.bg03:SetActive(true)
	self.bg04:SetActive(false)
	if self.horoscope_attr_bt.toggle.isOn then
		self.horoscope_attr_view:FlushInfoView()
	elseif self.horoscope_equip_bt.toggle.isOn then
		self.horoscope_equip_view:FlushInfoView()
	elseif self.horoscope_starmap_bt.toggle.isOn then
		self.horoscope_starmap_view:FlushInfoView()
	end
end

function MoLongView:FlushHoroscopeEffect()
	self.horoscope_starmap_view:FlushEffect()
end

function MoLongView:OnLeftMagicCardToggle()
	self.left_magic_card_bt.toggle.isOn = true
	self.bg03:SetActive(false)
	self.bg04:SetActive(false)
	if self.magiccard_attribute_bt.toggle.isOn then
		self.bg02:SetActive(false)
		self.magic_card_attr_view:FlushInfoView()
	elseif self.magiccard_uplevel_bt.toggle.isOn then
		self.bg02:SetActive(false)
		self.magic_card_uplevel_view:FlushInfoView()
	elseif self.magiccard_lotto_bt.toggle.isOn then
		self.bg02:SetActive(true)
		self.magic_card_lotto_view:FlushInfoView()
	elseif self.magiccard_exchange_bt.toggle.isOn then
		self.bg02:SetActive(true)
		self.magic_card_exchange_view:FlushInfoView()
	end
end

function MoLongView:OnMolongToggle()
	self.bg04:SetActive(false)
end

function MoLongView:OnExpeditionToggle()
	self.bg04:SetActive(true)
	self.expedition_view:FlushExpeditionView()
end

function MoLongView:SwordArtOnlineToggle()
	self.bg02:SetActive(false)
	self.bg03:SetActive(false)
	self.bg04:SetActive(false)
	self.sword_art_online_view:FlushInfoView()
	self.sword_art_online_view:HideRect()
end

function MoLongView:OnHoroscopeAttrToggle()
	self.horoscope_attr_bt.toggle.isOn = true
	self.horoscope_attr_view:FlushInfoView()
end

function MoLongView:OnEquipToggle()
	self.horoscope_equip_bt.toggle.isOn = true
	self.horoscope_equip_view:FlushInfoView()
	HoroscopeEquipView.Instance:SetRoleData()
end

function MoLongView:OnStarMapToggle()
	self.horoscope_starmap_bt.toggle.isOn = true
	self.horoscope_starmap_view:FlushInfoView()
end

function MoLongView:OpenCallBack()
	self:ShowOrHideTab()
	if self.left_molong_bt.toggle.isOn then
		if self.molong_bt.toggle.isOn then
			self.molong_info_view:FlushInfoView()
		elseif self.expedition_bt.toggle.isOn then
			self.expedition_view:FlushExpeditionView()
		end
	elseif self.left_magic_card_bt.toggle.isOn then
		if self.magiccard_attribute_bt.toggle.isOn then
			self.magic_card_attr_view:FlushInfoView()
		elseif self.magiccard_uplevel_bt.toggle.isOn then
			self.magic_card_uplevel_view:FlushInfoView()
		elseif self.magiccard_lotto_bt.toggle.isOn then
			self.magic_card_lotto_view:FlushInfoView()
		elseif self.magiccard_exchange_bt.toggle.isOn then
			self.magic_card_exchange_view:FlushInfoView()
		end
	elseif self.sword_art_online_bt.toggle.isOn then
		self.sword_art_online_view:FlushInfoView()
	elseif self.left_horoscope_bt.toggle.isOn then
		if self.horoscope_attr_bt.toggle.isOn then
			self.horoscope_attr_view:FlushInfoView()
		elseif self.horoscope_equip_bt.toggle.isOn then
			self.horoscope_equip_view:FlushInfoView()
		elseif self.horoscope_starmap_bt.toggle.isOn then
			self.horoscope_starmap_view:FlushInfoView()
		end
	end

	self:FlushRedPoint()
end

function MoLongView:ShowIndexCallBack(index)
	if index == TabIndex.magic_lottery then
		self:OnLeftMagicCardToggle()
		self:OnUpMcLottoToggle()
	elseif index == TabIndex.horoscope_attr then
		self:OnLeftHoroscopeToggle()
		self:OnHoroscopeAttrToggle()
	elseif index == TabIndex.horoscope_equip then
		self:OnLeftHoroscopeToggle()
		self:OnEquipToggle()
	elseif index == TabIndex.horoscope_starmap then
		self:OnLeftHoroscopeToggle()
		self:OnStarMapToggle()
	end
end

function MoLongView:CloseCallBack()
	MoLongData.Instance:ShowMolongInfoRedpt()
	MoLongData.Instance:ShowExpdetionRedpt()
	if MagicCardData.Instance:GetCardCanActive() then
		MoLongData.Instance:SetMagicCardRedpt(true)
	else
		MoLongData.Instance:SetMagicCardRedpt(false)
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

function MoLongView:CloseView()
	self:Close()
end

function MoLongView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "info" and self.molong_bt.toggle.isOn then
			self.molong_info_view:FlushInfoView()
		elseif k == "expedition" and self.expedition_bt.toggle.isOn then
			self.expedition_view:FlushExpeditionView()
		elseif k == "attr" and self.magiccard_attribute_bt.toggle.isOn then
			self.magic_card_attr_view:FlushInfoView()
		elseif k == "uplevel" and self.magiccard_uplevel_bt.toggle.isOn then
			self.magic_card_uplevel_view:FlushInfoView()
		elseif k == "lotto" and self.magiccard_lotto_bt.toggle.isOn then
			self.magic_card_lotto_view:FlushInfoView()
		elseif k == "card_exchange" and self.magiccard_exchange_bt.toggle.isOn then
			self.magic_card_exchange_view:FlushInfoView()
		elseif k == "sword_art_online" and self.sword_art_online_bt.toggle.isOn then
			self.sword_art_online_view:FlushInfoView()
		elseif k == "horoscope_attr" and self.horoscope_attr_bt.toggle.isOn then
			self.horoscope_attr_view:FlushEffect()
			self.horoscope_attr_view:FlushInfoView()
		elseif k == "horoscope_equip" and self.horoscope_equip_bt.toggle.isOn then
			self.horoscope_equip_view:FlushInfoView()
		elseif k == "star_map" and self.horoscope_starmap_bt.toggle.isOn then
			self.horoscope_starmap_view:FlushInfoView()
		end
	end

	self:FlushRedPoint()
end