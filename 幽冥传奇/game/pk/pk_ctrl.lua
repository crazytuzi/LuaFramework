require("scripts/game/pk/pk_data")

PkCtrl = PkCtrl or BaseClass(BaseController)
function PkCtrl:__init()
	if PkCtrl.Instance then
		ErrorLog("[PkCtrl] attempt to create singleton twice!")
		return
	end
	PkCtrl.Instance = self

	self.data = PkData.New()
	self:RegisterAllProtocols()
end

function PkCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	
	PkCtrl.Instance = nil
end	

function PkCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPKModeChange, "OnPKModeChange")
end

function PkCtrl:OnPKModeChange(protocol)
	self.data:SetPKMode(protocol.mode)
end

function PkCtrl.SendSetAttackMode(mode)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetPKMode)
	protocol.mode = mode
	protocol:EncodeAndSend()
end
