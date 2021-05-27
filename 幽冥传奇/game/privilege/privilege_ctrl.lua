require("scripts/game/privilege/privilege_data")

PrivilegeCtrl = PrivilegeCtrl or BaseClass(BaseController)

function PrivilegeCtrl:__init()
	if PrivilegeCtrl.Instance ~= nil then
		ErrorLog("[PrivilegeCtrl] attempt to create singleton twice!")
		return
	end
	PrivilegeCtrl.Instance = self

	self.data = PrivilegeData.New()
	self:RegisterAllProtocols()
end

function PrivilegeCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
	PrivilegeCtrl.Instance = nil
end

--请求特权卡操作
function PrivilegeCtrl.SendPrivilegeReq(op_type, view_idx, op_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPrivilegeReq)
	protocol.op_type = op_type
	protocol.view_idx = view_idx
	protocol.op_idx = op_idx
	protocol:EncodeAndSend()
end

--请求特权卡信息
function PrivilegeCtrl.SendPrivilegeInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSPrivilegeReq)
	protocol.op_type = 1
	protocol.view_idx = 0
	protocol.op_idx = 0
	protocol:EncodeAndSend()
end

function PrivilegeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPrivilegeInfo,"OnPrivilegeInfo")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendPrivilegeInfoReq))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.Privilege)
end

function PrivilegeCtrl:GetRemindNum()
	return self.data:GetRemindNum()
end

function PrivilegeCtrl:OnPrivilegeInfo(protocol)
	self.data:SetPrivilegeInfo(protocol)
	RemindManager.Instance:DoRemind(RemindName.Privilege)
end