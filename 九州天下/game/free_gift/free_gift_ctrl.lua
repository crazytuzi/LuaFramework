require("game/free_gift/free_gift_data")
require("game/free_gift/free_gift_view")
FreeGiftCtrl = FreeGiftCtrl or BaseClass(BaseController)

function FreeGiftCtrl:__init()
	if FreeGiftCtrl.Instance then
		print_error("[FreeGiftCtrl] Attemp to create a singleton twice !")
	end
	FreeGiftCtrl.Instance = self
	self.data = FreeGiftData.New()
	self.view = FreeGiftView.New(ViewName.FreeGiftView)
	self:RegisterAllProtocols()
end

function FreeGiftCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	FreeGiftCtrl.Instance = nil
end

function FreeGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCZeroGiftInfo, "OnZeroGiftInfo")
end

function FreeGiftCtrl:OnZeroGiftInfo(protocol)
	self.data:SetXeroGiftInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.ZeroGift)
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "zero_gift")
end

function FreeGiftCtrl.SendZeroGiftOperate(operate_type, param_1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSZeroGiftOperate)
	send_protocol.operate_type = operate_type
	send_protocol.param_1 = param_1 or 0
	send_protocol:EncodeAndSend()
end