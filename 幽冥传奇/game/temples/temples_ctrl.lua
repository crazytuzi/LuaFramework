require("scripts/game/temples/temples_data")
require("scripts/game/temples/temples_view")
TemplesCtrl = TemplesCtrl or BaseClass(BaseController)

function TemplesCtrl:__init()
    if TemplesCtrl.Instance then
        ErrorLog("[TemplesCtrl]:Attempt to create singleton twice!")
    end
    TemplesCtrl.Instance = self
    
    self.data = TemplesData.New()
    self.view = TemplesView.New(ViewDef.Temples)
    self:RegisterAllProtocols()
end

function TemplesCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    TemplesCtrl.Instance = nil
end

function TemplesCtrl:RegisterAllProtocols()
     self:RegisterProtocol(SCCrossTemplesInfo, "OnTemplesInfo")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
end

function TemplesCtrl:OnTemplesInfo(protocol)
    self.view:Flush(nil, nil, {count = protocol.count})
    self.data:SetData({count = protocol.count, buy_times = protocol.buy_times})
end


function TemplesCtrl.SendTemplesReq(req_type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSCrossTemplesReq)
    protocol.req_type = req_type
    protocol:EncodeAndSend()
end

function TemplesCtrl:GetRemindNum(remind_name)
end