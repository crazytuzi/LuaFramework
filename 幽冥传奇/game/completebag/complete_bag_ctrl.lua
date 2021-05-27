require("scripts/game/completebag/complete_bag_data")
require("scripts/game/completebag/complete_bag_view")

CompleteBagCtrl = CompleteBagCtrl or BaseClass(BaseController)

function CompleteBagCtrl:__init()
	if CompleteBagCtrl.Instance then
		ErrorLog("[CompleteBagCtrl]:Attempt to create singleton twice!")
	end
	CompleteBagCtrl.Instance = self
	self.data = CompleteBagData.New()
	self.view = CompleteBagView.New(ViewName.CompleteBag)
end

function CompleteBagCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	CompleteBagCtrl.Instance = nil
end

function CompleteBagCtrl:SendFinishDownload()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBoolUseLanderLoadingReq)
	protocol.bool_use = 1
	protocol:EncodeAndSend()
end
