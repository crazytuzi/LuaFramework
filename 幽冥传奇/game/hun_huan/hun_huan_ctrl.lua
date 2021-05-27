require("scripts/game/hun_huan/hun_huan_data")
require("scripts/game/hun_huan/hun_huan_view")
HunHuanCtrl = HunHuanCtrl or BaseClass(BaseController)

function HunHuanCtrl:__init()
    if HunHuanCtrl.Instance then
        ErrorLog("[HunHuanCtrl]:Attempt to create singleton twice!")
    end
    HunHuanCtrl.Instance = self
    
    self.data = HunHuanData.New()
    self.view = HunHuanView.New(ViewDef.HunHuan)
    self:RegisterAllProtocols()
end

function HunHuanCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    HunHuanCtrl.Instance = nil
end

function HunHuanCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCHunHuanData, "OnHunHuanData")
    RemindManager.Instance:RegisterCheckRemind(function ()
        return self.data:GetRewardRemind()
    end, RemindName.HunHuan)
end

function HunHuanCtrl:OnHunHuanData(protocol)
    self.data:setFlag(protocol.flag)
end


function HunHuanCtrl.SendHunHuanBuy(idx)
    local protocol = ProtocolPool.Instance:GetProtocol(CSHunHuanReq)
    protocol.idx = idx
    protocol:EncodeAndSend()
end

function HunHuanCtrl:GetRemindNum(remind_name)
end