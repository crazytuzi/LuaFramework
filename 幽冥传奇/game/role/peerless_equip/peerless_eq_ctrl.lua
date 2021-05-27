require("scripts/game/role/peerless_equip/peerless_eq_data")
require("scripts/game/role/peerless_equip/peerless_eq_view")

PeerlessEqCtrl = PeerlessEqCtrl or BaseClass(BaseController)
function PeerlessEqCtrl:__init()
	if PeerlessEqCtrl.Instance then
		ErrorLog("[PeerlessEqCtrl] attempt to create singleton twice!")
		return
	end
	PeerlessEqCtrl.Instance = self

	self.data = PeerlessEqData.New()

	self:RegisterAllProtocols()
end

function PeerlessEqCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	PeerlessEqCtrl.Instance = nil
end	

function PeerlessEqCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCIssuePeerlessEqData, "OnIssuePeerlessEqData")
end

--下发祈求数据
-- function PeerlessEqCtrl:OnIssuePeerlessEqData(protocol)
	
-- end