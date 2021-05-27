require("scripts/game/cross_land/cross_land_data")
require("scripts/game/cross_land/cross_land_view")
CrossLandCtrl = CrossLandCtrl or BaseClass(BaseController)

function CrossLandCtrl:__init()
    if CrossLandCtrl.Instance then
        ErrorLog("[CrossLandCtrl]:Attempt to create singleton twice!")
    end
    CrossLandCtrl.Instance = self
    
    self.data = CrossLandData.New()
    self.view = CrossLandView.New(ViewDef.CrossLand)
    self:RegisterAllProtocols()
end

function CrossLandCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    CrossLandCtrl.Instance = nil
end

function CrossLandCtrl:RegisterAllProtocols()
    -- self:RegisterProtocol(SCCrossLandGuajiInfo, "OnCrossLandGuajiInfo")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
end

function CrossLandCtrl:OnCrossLandGuajiInfo(protocol)
end


function CrossLandCtrl.SendCrossLandGuajiReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSCrossLandGuajiReq)
    protocol:EncodeAndSend()
end

function CrossLandCtrl:GetRemindNum(remind_name)
end