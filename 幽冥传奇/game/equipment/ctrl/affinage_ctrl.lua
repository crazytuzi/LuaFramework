require("scripts/game/equipment/data/affinage_data")

AffinageCtrl = AffinageCtrl or BaseClass(BaseController)
function AffinageCtrl:__init()
	if AffinageCtrl.Instance then
		ErrorLog("[AffinageCtrl]:Attempt to create singleton twice!")
	end
	AffinageCtrl.Instance = self
	self.data = AffinageData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function AffinageCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
    AffinageCtrl.Instance = nil
end

function AffinageCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCAffinageResult, "OnAffinageResult")
	self:RegisterProtocol(SCAffinageInfo, "OnAffinageInfo")
	self:RegisterProtocol(SCOneKeyAffinageInfo, "OnOneKeyAffinageInfo")
end

function AffinageCtrl:OnRecvMainRoleInfo()
	self.SendEquipAffinageInfoReq()
end

function AffinageCtrl.SendEquipAffinageInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetApotheosisInfo)
	protocol:EncodeAndSend()
end

function AffinageCtrl:OnAffinageInfo(protocol)
	self.data:SetAffinageLevelList(protocol.affinage_lv_list)
end

function AffinageCtrl:OnOneKeyAffinageInfo(protocol)
	if next(protocol.affinage_lv_list) then
		self.data:SetAffinageLevelList(protocol.affinage_lv_list)
		GlobalEventSystem:Fire(AffinageData.AFFINAGE_UP_SUCCED)
	end
end

function AffinageCtrl.SendEquipAffinageReq(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAffinageReq)
	protocol.slot = slot
	protocol:EncodeAndSend()
end

function AffinageCtrl:OnAffinageResult(protocol)
	self.data:ChangeAffinageLevel(protocol.slot, protocol.affinage_lv)
end

function AffinageCtrl.SendOneKeyEquipAffinageReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOneKeyAffinageReq)
	protocol:EncodeAndSend()
end