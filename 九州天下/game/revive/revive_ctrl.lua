require("game/revive/revive_data")
require("game/revive/revive_view")

ReviveCtrl = ReviveCtrl or BaseClass(BaseController)

function ReviveCtrl:__init()
	if ReviveCtrl.Instance ~= nil then
		print_error("[ReviveCtrl] Attemp to create a singleton twice !")
		return
	end

	ReviveCtrl.Instance = self

	self.revive_data = ReviveData.New()
	self.revive_view = ReviveView.New(ViewName.ReviveView)

	self:RegisterAllProtocols()
end

function ReviveCtrl:__delete()
	if self.revive_view then
		self.revive_view:DeleteMe()
		self.revive_view = nil
	end

	if self.revive_data then
		self.revive_data:DeleteMe()
		self.revive_data = nil
	end

	ReviveCtrl.Instance = nil
end


function ReviveCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRoleReAliveCostType, "OnRoleReAliveCostType")
	self:RegisterProtocol(SCHuguozhiliInfo, "OnHuguozhiliInfo")
	self:RegisterProtocol(CSHuguozhiliReq)
end

-- 返回国家复活次数
function ReviveCtrl:OnRoleReAliveCostType(protocol)
	self.revive_data:SetRoleReAliveCostType(protocol)
	self.revive_view:Flush()
end

function ReviveCtrl:SendHuguozhiliReq(req_type, param1, param2)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSHuguozhiliReq)
	protocol_send.req_type = req_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param1 or 0
	protocol_send:EncodeAndSend()
end

function ReviveCtrl:OnHuguozhiliInfo(protocol)
	self.revive_data:SetHuguozhiliInfo(protocol)
	self.revive_view:Flush()
end

function ReviveCtrl:PauseTimer()
	if self.revive_view ~= nil and self.revive_view:IsOpen() then
		self.revive_view:PauseTimer()
		
	end
end

function ReviveCtrl:FlushView()
	if self.revive_view ~= nil and self.revive_view:IsOpen() then
		self.revive_view:Flush()
	end
end