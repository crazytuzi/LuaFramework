require("game/reincarnation/reincarnation_data")
require("game/reincarnation/reincarnation_view")

ReincarnationCtrl = ReincarnationCtrl or BaseClass(BaseController)
function ReincarnationCtrl:__init()
	if ReincarnationCtrl.Instance then
		print_error("[ReincarnationCtrl] Attemp to create a singleton twice !")
	end
	ReincarnationCtrl.Instance = self

	self.reincarnation_data = ReincarnationData.New()
	self.reincarnation_view = ReincarnationView.New(ViewName.Reincarnation)
	self:RegisterAllProtocols()
end

function ReincarnationCtrl:__delete()
	ReincarnationCtrl.Instance = nil

	if self.reincarnation_data then
		self.reincarnation_data:DeleteMe()
	end

	if self.reincarnation_view then
		self.reincarnation_view:DeleteMe()
	end
end

function ReincarnationCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRoleZhuanSheng)
end

function ReincarnationCtrl:SendRoleZhuanShengReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRoleZhuanSheng)

	send_protocol:EncodeAndSend()
end