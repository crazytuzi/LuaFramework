require("game/rebirth/rebirth_view")
require("game/rebirth/rebirth_data")
require("game/rebirth/rebirth_suit_view")
require("game/rebirth/rebirth_xilian_stuff_view")
RebirthCtrl = RebirthCtrl or BaseClass(BaseController)
function RebirthCtrl:__init()
	if RebirthCtrl.Instance then
		print_error("[RebirthCtrl] Attemp to create a singleton twice !")
	end
	RebirthCtrl.Instance = self
	self.rebirth_data = RebirthData.New()
	self.rebirth_view = RebirthView.New(ViewName.RebirthView)
	self.suit_view = RebirthSuitView.New(ViewName.RebirthSuitView)
	self.rebirth_select_stuff_view = RebirthXiLianStuffView.New(ViewName.RebirthXiLianStuffView)

	self:RegisterAllProtocols()
	RemindManager.Instance:Register(RemindName.RebirthAdvance, BindTool.Bind(self.GetRebirthChangeRemind, self, RemindName.RebirthAdvance))
	RemindManager.Instance:Register(RemindName.RebirthEquip, BindTool.Bind(self.GetRebirthChangeRemind, self, RemindName.RebirthEquip))
end

function RebirthCtrl:__delete()
	RebirthCtrl.Instance = nil

	if self.rebirth_view then
		self.rebirth_view:DeleteMe()
		self.rebirth_view = nil
	end

	if self.rebirth_data then
		self.rebirth_data:DeleteMe()
		self.rebirth_data = nil
	end

	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end

	if self.rebirth_select_stuff_view then
		self.rebirth_select_stuff_view:DeleteMe()
		self.rebirth_select_stuff_view = nil
	end
	
	RemindManager.Instance:UnRegister(RemindName.RebirthAdvance)
	RemindManager.Instance:UnRegister(RemindName.RebirthEquip)
end

function RebirthCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRebirthOpearReq)
	self:RegisterProtocol(SCRebirthAllInfo, "OnSCRebirthAllInfo")
end

-- 请求转生所有信息
function RebirthCtrl:SendReqRebirthAllInfo(opera_type, param_1, param_2, param_3, param_4)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSRebirthOpearReq)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param_1 = param_1 or 0
	protocol_send.param_2 = param_2 or 0
	protocol_send.param_3 = param_3 or 0
	protocol_send.param_4 = param_4 or 0
	protocol_send:EncodeAndSend()
end

function RebirthCtrl:OnSCRebirthAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.RebirthAdvance)
	RemindManager.Instance:Fire(RemindName.RebirthEquip)

	local old_bless = self.rebirth_data:GetCurBless()
	local old_level = self.rebirth_data:GetRebirthLevel()
	if self.rebirth_view:IsOpen() then
		self:ShowFloatingTips(old_bless, protocol.cur_bless,old_level,protocol.zhuansheng_level)
	end

	self.rebirth_data:SetRebirthAllInfo(protocol)
	if self.rebirth_view:IsOpen() then
		self.rebirth_view:Flush()
	end
end

function RebirthCtrl:ShowFloatingTips(old_bless, cur_bless, old_level, cur_level)
	local old_bless = old_bless or 0
	local cur_bless = cur_bless or 0

	local old_level = old_level or 0
	local cur_level = cur_level or 0
	if old_level ~= cur_level then return end
	if cur_bless - old_bless >= 200 then
		TipsCtrl.Instance:ShowFloatingLabel(nil, 0, 0, false, true, ResPath.GetFloatTextRes("WordBaojiUpgrade"))
	end
end

function RebirthCtrl:OnRebirthUpGradeOptResult(result)
	if self.rebirth_view:IsOpen() then
		self.rebirth_view:FlushRebirthUpgrade(result)
	end
end

function RebirthCtrl:GetCurSelectSuit()
	return self.rebirth_view:GetCurSelectSuit()
end

function RebirthCtrl:SetCurSelectSuit(cur_select)
	self.rebirth_view:SetCurSelectSuit(cur_select)
end

function RebirthCtrl:GetCapability()
	return self.rebirth_view:GetCapability()
end

function RebirthCtrl:SetEquipIndex(equip_index)
	self.rebirth_view:SetEquipIndex(equip_index)
end

function RebirthCtrl:FlushRebirthView()
	self.rebirth_view:Flush()
end

function RebirthCtrl:GetRebirthChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.RebirthAdvance then
		if self.rebirth_data:ShowAdvanceRed() then
			flag = 1
		end
	elseif remind_type == RemindName.RebirthEquip then
		if self.rebirth_data:ShowXilianRed() then
			flag = 1
		end
	end

	return flag
end
