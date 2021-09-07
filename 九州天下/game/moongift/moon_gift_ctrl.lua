require("game/moongift/moon_gift_view")
require("game/moongift/moon_gift_data")

MoonGiftCtrl = MoonGiftCtrl or BaseClass(BaseController)
function MoonGiftCtrl:__init()
	if MoonGiftCtrl.Instance then
		print_error("[MoonGiftCtrl] Attemp to create a singleton twice !")
	end
	MoonGiftCtrl.Instance = self

	self.data = MoonGiftData.New()
	self.view = MoonGiftView.New(ViewName.MoonGiftView)

	self:RegisterAllProtocols()
end

function MoonGiftCtrl:__delete()
	MoonGiftCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function MoonGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMyylAllInfo, "OnSCRAMyylAllInfo")
end

function MoonGiftCtrl:OnSCRAMyylAllInfo(protocol)
	self.data:SetRewardInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.MidAutumnMoonGift)
end

function MoonGiftCtrl:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end