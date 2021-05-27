require("scripts/game/luxury_equip/luxury_equip_tip_data")
require("scripts/game/luxury_equip/luxury_equip_tip_view")
LuxuryEquipTipCtrl = LuxuryEquipTipCtrl or BaseClass(BaseController)

function LuxuryEquipTipCtrl:__init()
    if LuxuryEquipTipCtrl.Instance then
        ErrorLog("[LuxuryEquipTipCtrl]:Attempt to create singleton twice!")
    end
    LuxuryEquipTipCtrl.Instance = self
    
    self.data = LuxuryEquipTipData.New()
    self.view = LuxuryEquipTipView.New(ViewDef.LuxuryEquipTip)
    self:RegisterAllProtocols()
end

function LuxuryEquipTipCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    LuxuryEquipTipCtrl.Instance = nil
end

function LuxuryEquipTipCtrl:RegisterAllProtocols()
    -- self:RegisterProtocol(SCLuxuryEquipTipGuajiInfo, "OnLuxuryEquipTipGuajiInfo")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
end

function LuxuryEquipTipCtrl:OnLuxuryEquipTipGuajiInfo(protocol)
end


function LuxuryEquipTipCtrl.SendLuxuryEquipTipGuajiReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSLuxuryEquipTipGuajiReq)
    protocol:EncodeAndSend()
end

function LuxuryEquipTipCtrl:GetRemindNum(remind_name)
end