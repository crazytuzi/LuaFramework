require("game/diedmail/died_mail_data")
require("game/diedmail/died_mail_pop")

DiedMailCtrl = DiedMailCtrl or BaseClass(BaseController)

function DiedMailCtrl:__init()
	if DiedMailCtrl.Instance then
		print_error("[DiedMailCtrl]:Attempt to create singleton twice!")
	end
	DiedMailCtrl.Instance = self
	self.pop_view = DiedMailPop.New(ViewName.DiedMailPop)
	self.data = DiedMailData.New()
	self:RegisterAllProtocol()
	self.is_first_open = true
end

function DiedMailCtrl:RegisterAllProtocol()
	self:RegisterProtocol(SCRoleDeathTrackInfo,"OnSCRoleDeathTrackInfo")
end

function DiedMailCtrl:OnSCRoleDeathTrackInfo(protocol)
	self.data:SetDieMailData(protocol)
	if self.pop_view:IsOpen() then
		self.pop_view:Flush()
	end
	if protocol ~= nil and protocol.yesterday_killer_item_list[1].uid > 0 then
		ViewManager.Instance:Open(ViewName.DiedMailPop)
	end
end