require("scripts/game/office/office_data")
require("scripts/game/office/office_view")

--------------------------------------------------------
-- 官职
--------------------------------------------------------

OfficeCtrl = OfficeCtrl or BaseClass(BaseController)

function OfficeCtrl:__init()
    if OfficeCtrl.Instance then
		ErrorLog("[OfficeCtrl]:Attempt to create singleton twice!")
	end
	OfficeCtrl.Instance = self

    self.data = OfficeData.New()
    self.view = OfficeView.New(ViewDef.Office)
    --self:RegisterAllProtocols()

	--self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end


function OfficeCtrl:__delete()
    OfficeCtrl.Instance = nil

    if self.view then
        self.view:DeleteMe()
        self.view = nil
    end

    if self.data then
        self.data:DeleteMe()
        self.data = nil
    end

end

function OfficeCtrl:RecvMainInfoCallBack()
	OfficeCtrl.Instance:SendOfficeReq(1)
end

--登记所有协议
function OfficeCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCOfficeResult, "OnOfficeResul")  -- 官职处理结果
end

----------接收----------

function OfficeCtrl:OnOfficeResul(protocol)
    self.data:SetOfficeResults(protocol)
end

----------发送----------

function OfficeCtrl:SendOfficeReq(index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSSendOfficeReq)
    protocol.index = index
    protocol:EncodeAndSend()
end