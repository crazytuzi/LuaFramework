require("game/molong/molong_view")
require("game/molong/molong_data")
require("game/magic_card/magic_card_data")
require("game/molong/sword_art_online_data")
require("game/horoscope/horoscope_data")

MoLongCtrl = MoLongCtrl or BaseClass(BaseController)
function MoLongCtrl:__init()
	if MoLongCtrl.Instance then
		print_error("[MoLongCtrl] Attemp to create a singleton twice !")
	end
	MoLongCtrl.Instance = self

	self.molong_data = MoLongData.New()
	self.magic_card_data = MagicCardData.New()
	self.sword_art_online_data = SwordArtOnlineData.New()
	self.horoscope_data = HoroscopeData.New()
	self.molong_view = MoLongView.New(ViewName.MoLong)

	-- self:RegisterAllProtocols() ---------------- 先屏掉
end

function MoLongCtrl:__delete()
	MoLongCtrl.Instance = nil

	if self.molong_view then
		self.molong_view:DeleteMe()
		self.molong_view = nil
	end

	if self.molong_data then
		self.molong_data:DeleteMe()
		self.molong_data = nil
	end

	if self.magic_card_data then
		self.magic_card_data:DeleteMe()
		self.magic_card_data = nil
	end

	if self.sword_art_online_data then
		self.sword_art_online_data:DeleteMe()
		self.sword_art_online_data = nil
	end

	if self.horoscope_data then
		self.horoscope_data:DeleteMe()
		self.horoscope_data = nil
	end
end

function MoLongCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSMitamaOperaReq)
	self:RegisterProtocol(SCMitamaAllInfo, "OnMitamaAllInfo")
	self:RegisterProtocol(SCMitamaSingleInfo, "OnMitamaSingleInfo")
	self:RegisterProtocol(SCMitamaHotSpringScore, "OnMitamaHotSpringScore")

	-- 魔卡
	self:RegisterProtocol(CSMagicCardOperaReq)
	self:RegisterProtocol(SCMagicCardAllInfo, "OnSCMagicCardAllInfo")
	self:RegisterProtocol(SCMagicCardChouCardResult, "OnSCMagicCardChouCardResult")

	-- 刀剑神域
	self:RegisterProtocol(CSCardzuOperaReq)
	self:RegisterProtocol(SCCardzuAllInfo, "OnSCCardzuAllInfo")
	self:RegisterProtocol(SCCardzuChangeNotify, "OnSCCardzuChangeNotify")
	self:RegisterProtocol(SCCardzuChouCardResult, "OnSCCardzuChouCardResult")

	-- 十二星座
	-- self:RegisterProtocol(CSChineseZodiacPromoteXingHun)
	-- self:RegisterProtocol(CSChineseZodiacPromoteEquip)
	-- self:RegisterProtocol(SCChineseZodiacAllInfo, "OnSCChineseZodiacAllInfo")
	-- self:RegisterProtocol(SCChineseZodiacEquipInfo, "OnSCChineseZodiacEquipInfo")
end

-- 魔龙服务器消息 start
function MoLongCtrl:OnMitamaAllInfo(protocol)
	self.molong_data:SetMitamaAllInfo(protocol)
	MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.Show_Collection, true)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("info")
		self.molong_view:Flush("expedition")
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

function MoLongCtrl:OnMitamaSingleInfo(protocol)
	self.molong_data:SetMitamaSingleInfo(protocol)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("info")
		self.molong_view:Flush("expedition")
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

function MoLongCtrl:OnMitamaHotSpringScore(protocol)
	self.molong_data:SetMitamaHotSpringScore(protocol)
end
-- end

-- 魔卡消息 start
function MoLongCtrl:OnSCMagicCardAllInfo(protocol)
	self.magic_card_data:SetMagicCardAllInfo(protocol)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("attr")
		self.molong_view:Flush("card_exchange")
		self.molong_view:Flush("uplevel")
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

function MoLongCtrl:OnSCMagicCardChouCardResult(protocol)
	self.magic_card_data:SetMagicCardChouCardResult(protocol)
	if self.molong_view:IsOpen() then
		local lotto_data = self.magic_card_data:GetLottoData()
		for k,v in pairs(lotto_data) do
			local msg = string.format(Language.MagicCard.GetCard.."%s*%d",v.card_name, v.num)
			TipsFloatingManager.Instance:ShowFloatingTips(msg)
		end
		self.molong_view:Flush("lotto")
	end
end
-- end

-- 刀剑神域消息 start
function MoLongCtrl:OnSCCardzuAllInfo(protocol)
	self.sword_art_online_data:SetCardzuAllInfo(protocol)
	if self.molong_view:IsOpen() then
		if self.sword_art_online_data:GetLingLi() > self.sword_art_online_data:GetOldLingli() then
			local msg = string.format(Language.EquipShen.GetLingLi,self.sword_art_online_data:GetLingLi() - self.sword_art_online_data:GetOldLingli())
			TipsFloatingManager.Instance:ShowFloatingTips(msg)
		end
		self.molong_view:Flush("sword_art_online")
	end
	self.sword_art_online_data:SetOldLingli(protocol.lingli)
end

function MoLongCtrl:OnSCCardzuChangeNotify(protocol)
	self.sword_art_online_data:SetCardzuChangeNotify(protocol)
	if self.molong_view:IsOpen() then
		if self.sword_art_online_data:GetLingLi() > self.sword_art_online_data:GetOldLingli() then
			local msg = string.format(Language.EquipShen.GetLingLi,self.sword_art_online_data:GetLingLi() - self.sword_art_online_data:GetOldLingli())
			TipsFloatingManager.Instance:ShowFloatingTips(msg)
		end
		self.molong_view:Flush("sword_art_online")
	end
	self.sword_art_online_data:SetOldLingli(protocol.lingli)
end

function MoLongCtrl:OnSCCardzuChouCardResult(protocol)
	self.sword_art_online_data:SetCardzuChouCardResult(protocol)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("sword_art_online")
	end
end
-- end

-- 十二星座
function MoLongCtrl:OnSCChineseZodiacAllInfo(protocol)
	self.horoscope_data:SetChineseZodiacAllInfo(protocol)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("horoscope_attr")
		self.molong_view:Flush("horoscope_equip")
		self.molong_view:Flush("star_map")
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

function MoLongCtrl:OnSCChineseZodiacEquipInfo(protocol)
	self.horoscope_data:SetChineseZodiacEquipInfo(protocol)
	if self.molong_view:IsOpen() then
		self.molong_view:Flush("horoscope_attr")
		self.molong_view:Flush("horoscope_equip")
		self.molong_view:Flush("star_map")
	end
	RemindManager.Instance:Fire(RemindName.Collection)
end

-- end

-- 发送魔龙请求
function MoLongCtrl:SendMitamaOperaReq(req_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMitamaOperaReq)
	send_protocol.req_type = req_type
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

-- 发送魔卡请求
function MoLongCtrl:SendMagicCardOperaReq(req_type, param_1, param_2, param_3, param_4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMagicCardOperaReq)
	send_protocol.opera_type = req_type
	send_protocol.reserve = 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol.param_4 = param_4 or 0
	send_protocol:EncodeAndSend()
end

-- 发刀剑神域请求
function MoLongCtrl:SendSwordArtOnlineOperaReq(req_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCardzuOperaReq)
	send_protocol.opera_type = req_type
	send_protocol.reserve_sh = 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

-- 发送十二星座请求
-- 提升星座星魂等级请求
function MoLongCtrl:SendChineseZodiacPromoteXingHun(zodiac_type, is_auto_buy, is_use_promote_item)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChineseZodiacPromoteXingHun)
	send_protocol.zodiac_type = zodiac_type
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.is_use_promote_item = is_use_promote_item or 0
	send_protocol:EncodeAndSend()
end

-- 提升星座装备等级请求
function MoLongCtrl:SendChineseZodiacPromoteEquip(zodiac_type, equip_slot)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChineseZodiacPromoteEquip)
	send_protocol.zodiac_type = zodiac_type
	send_protocol.equip_slot = equip_slot or 0
	send_protocol:EncodeAndSend()
end