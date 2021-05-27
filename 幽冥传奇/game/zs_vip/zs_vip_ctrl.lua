require("scripts/game/zs_vip/zs_vip_data")
require("scripts/game/zs_vip/zs_vip_view")
ZsVipCtrl = ZsVipCtrl or BaseClass(BaseController)

function ZsVipCtrl:__init()
    if ZsVipCtrl.Instance then
        ErrorLog("[ZsVipCtrl]:Attempt to create singleton twice!")
    end
    ZsVipCtrl.Instance = self
    
    self.data = ZsVipData.New()
    self.view = ZsVipView.New(ViewDef.ZsVip)
    self:RegisterAllProtocols()
end

function ZsVipCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    ZsVipCtrl.Instance = nil
end

function ZsVipCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCGetZsVIPLevRewardFlag, "OnGetZsVIPLevRewardFlag")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
    RemindManager.Instance:RegisterCheckRemind(function ()
        return self.data:GetRewardRemind()
    end, RemindName.ZsVip)
end

function ZsVipCtrl:OnGetZsVIPLevRewardFlag(protocol)
    self.data:SetFlag(protocol.zs_reward_flag, protocol.th_reward_flag)
end

function ZsVipCtrl.SendZsVipGetAwardReq(gift_type, gift_level)
    local protocol = ProtocolPool.Instance:GetProtocol(CSGetZsVipAwardReq)
    protocol.gift_type = gift_type
    protocol.gift_level = gift_level
    protocol:EncodeAndSend()
end

function ZsVipCtrl.SendZsVipIntoMapReq(map_idx)
    local protocol = ProtocolPool.Instance:GetProtocol(CSIntoZsVipMapReq)
    protocol.map_idx = map_idx
    protocol:EncodeAndSend()
end

function ZsVipCtrl:GetRemindNum(remind_name)
end