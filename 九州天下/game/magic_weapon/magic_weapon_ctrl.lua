require("game/magic_weapon/magic_weapon_data")
require("game/magic_weapon/magic_weapon_view")
MagicWeaponCtrl = MagicWeaponCtrl or BaseClass(BaseController)

function MagicWeaponCtrl:__init()
	if MagicWeaponCtrl.Instance then
		print_error("[MagicWeaponCtrl] Attemp to create a singleton twice !")
	end
	MagicWeaponCtrl.Instance = self

	self.data = MagicWeaponData.New()
	self.view = MagicWeaponView.New(ViewName.MagicWeaponView)
	self:RegisterAllProtocols()

end

function MagicWeaponCtrl:__delete()
	MagicWeaponCtrl.Instance = nil
	self.data:DeleteMe()

	self.view:DeleteMe()
	self.view = nil
end

function MagicWeaponCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShenzhouWeapondAllInfo, "OnMagicWeaponInfo")
	self:RegisterProtocol(SCShenzhouWeaponIdentifyResult, "OnIdentifyResult")

	self:RegisterProtocol(CSSHenzhouWeaponOperaReq)
end

function MagicWeaponCtrl:OnMagicWeaponInfo(protocol)
	self.data:OnMagicWeaponInfo(protocol)

	if self.view:IsOpen() then
		MagicContentView.Instance:FlushMagicWeaponInfo(MagicContentView.Instance.index or 0)
		MagicContentView.Instance:FlushRecycleView()
		MagicContentView.Instance:FlushBagView()
		IdentifyContentView.Instance:FlushAppraisalView()
		self.view:PlayerDataChangeCallback("gold")
		self.view:PlayerDataChangeCallback("bind_gold")
	end
end

function MagicWeaponCtrl:OnIdentifyResult(protocol)
	self.data:OnIdentifyResult(protocol)

end

--发送操作请求
function MagicWeaponCtrl:SendMagicLevelUpReq(type, param_1, param_2, param_3 )
	local protocol = ProtocolPool.Instance:GetProtocol(CSSHenzhouWeaponOperaReq)
	protocol.opera_type = type
	protocol.reserve = 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end