require("game/god_drop_gift/god_drop_gift_view")
require("game/god_drop_gift/god_drop_gift_data")

GodDropGiftCtrl = GodDropGiftCtrl or BaseClass(BaseController)

function GodDropGiftCtrl:__init()
	if GodDropGiftCtrl.Instance then
		print_error("[GodDropGiftCtrl] Attemp to create a singleton twice !")
	end
	GodDropGiftCtrl.Instance = self
	self.view = GodDropGiftView.New(ViewName.GodDropGiftView)
	self.data = GodDropGiftData.New()

	self:RegisterProtocol(SCRAGodDropGiftInfo, "OnRAGodDropGiftInfo")
end

function GodDropGiftCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	self.data:DeleteMe()
	self.data = nil
	GodDropGiftCtrl.Instance = nil
end

function GodDropGiftCtrl:OnRAGodDropGiftInfo(protocol)
	self.data:SetGodDropGiftActivityInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.GodDropGift)
end

function GodDropGiftCtrl:SendFetchRewardInfo(operate_type,param1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	send_protocol.rand_activity_type = 2168
	send_protocol.opera_type = operate_type or 0
	send_protocol.param_1 = param1 or 0
	send_protocol:EncodeAndSend()
end