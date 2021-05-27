require("scripts/game/role/deify/deify_data")

DeifyCtrl = DeifyCtrl or BaseClass(BaseController)

function DeifyCtrl:__init()
	if DeifyCtrl.Instance then
		ErrorLog("[DeifyCtrl] attempt to create singleton twice!")
		return
	end
	DeifyCtrl.Instance = self

	self.data = DeifyData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function DeifyCtrl:__delete()
	DeifyCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function DeifyCtrl:RecvMainInfoCallBack()
	DeifyCtrl.Instance:SendOfficeReq(1)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeUpGrade)
end

--登记所有协议
function DeifyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOfficeResult, "OnOfficeResul")  -- 官职处理结果
end

----------接收----------

function DeifyCtrl:OnOfficeResul(protocol)
	self.data:SetOfficeResults(protocol)
end

----------发送----------

function DeifyCtrl:SendOfficeReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendOfficeReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

