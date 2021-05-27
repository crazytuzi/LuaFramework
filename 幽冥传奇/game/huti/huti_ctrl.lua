-- require("scripts/game/huti/huti_data")
require("scripts/game/huti/huti_view")
HutiCtrl = HutiCtrl or BaseClass(BaseController)
function HutiCtrl:__init()
	if	HutiCtrl.Instance then
		ErrorLog("[HutiCtrl]:Attempt to create singleton twice!")
	end
	HutiCtrl.Instance = self
	self.view = HutiView.New(ViewName.Huti)
	self:RegisterAllProtocols()
end

function HutiCtrl:__delete()
	HutiCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

end

function HutiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGoldHudun, "OnGoldHudun")
end

function HutiCtrl:OnGoldHudun(protocol)
end



-----------------请求begin----------------
-- 护体神盾 
function HutiCtrl:ShendunReq(hudun_state)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendGoldHudunReq)
	protocol.hudun_state = hudun_state
	protocol:EncodeAndSend()
end
------------------请求end-------------------