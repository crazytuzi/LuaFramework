require("scripts/game/meridians/meridians_data")
require("scripts/game/meridians/meridians_view")

--------------------------------------------------------
-- 经脉
--------------------------------------------------------
MeridiansCtrl = MeridiansCtrl or BaseClass(BaseController)

function MeridiansCtrl:__init()
	if	MeridiansCtrl.Instance then
		ErrorLog("[MeridiansCtrl]:Attempt to create singleton twice!")
	end
	MeridiansCtrl.Instance = self

	self.data = MeridiansData.New()
	self.view = MeridiansView.New(ViewDef.Meridians)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function MeridiansCtrl:__delete()
	MeridiansCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

end

function MeridiansCtrl:RecvMainInfoCallBack()
	--MeridiansCtrl.Instance:SendMeridiansReq(1)
end

--登记所有协议
function MeridiansCtrl:RegisterAllProtocols()
	--self:RegisterProtocol(SCMeridiansResult, "OnMeridiansResult")	--经脉处理结果
end

----------协议----------

-- 接收经脉处理结果
function MeridiansCtrl:OnMeridiansResult(protocol)
	self.data:SetData(protocol)
end

-- 发送经脉处理
function MeridiansCtrl:SendMeridiansReq(index)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSSendMeridiansReq)
	-- protocol.index = index
	-- protocol:EncodeAndSend()
end

----------end----------
