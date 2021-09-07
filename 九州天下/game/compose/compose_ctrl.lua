require("game/compose/compose_data")
require("game/compose/compose_view")
ComposeCtrl = ComposeCtrl or BaseClass(BaseController)

function ComposeCtrl:__init()
	if ComposeCtrl.Instance then
		print_error("[ComposeCtrl] Attemp to create a singleton twice !")
	end
	ComposeCtrl.Instance = self

	self.data = ComposeData.New()
	self.view = ComposeView.New(ViewName.Compose)
end

function ComposeCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	ComposeCtrl.Instance = nil
end

function ComposeCtrl:SendItemCompose(product_seq, num, compose_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSItemCompose)
	send_protocol.product_seq = product_seq
	send_protocol.num = num
	send_protocol.compose_type = compose_type
	send_protocol:EncodeAndSend()
end