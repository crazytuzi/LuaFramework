require("scripts/game/meiba_shoutao/meiba_shoutao_data")
require("scripts/game/meiba_shoutao/meiba_shoutao_view")
MeiBaShouTaoCtrl = MeiBaShouTaoCtrl or BaseClass(BaseController)

function MeiBaShouTaoCtrl:__init()
    if MeiBaShouTaoCtrl.Instance then
        ErrorLog("[MeiBaShouTaoCtrl]:Attempt to create singleton twice!")
    end
    MeiBaShouTaoCtrl.Instance = self
    
    self.data = MeiBaShouTaoData.New()
    self.view = MeiBaShouTaoView.New(ViewDef.MeiBaShouTao)
    self:RegisterAllProtocols()
end

function MeiBaShouTaoCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    MeiBaShouTaoCtrl.Instance = nil

    self:DeleteSpareTimer()
end

function MeiBaShouTaoCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCHandAdd, "OnHandAdd")
    self:RegisterProtocol(SCHandCompose, "OnHandCompose")
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.HandCompose)
end

function MeiBaShouTaoCtrl.SendHandAdd(equip_t)
    local protocol = ProtocolPool.Instance:GetProtocol(CSHandAdd)
    protocol.equip_list = equip_t
    protocol:EncodeAndSend()
end

function MeiBaShouTaoCtrl.SendHandCompose()
    local protocol = ProtocolPool.Instance:GetProtocol(CSHandCompose)
    protocol:EncodeAndSend()
end

function MeiBaShouTaoCtrl.SendHandLingqu()
    local protocol = ProtocolPool.Instance:GetProtocol(CSReqHandLingqu)
    protocol:EncodeAndSend()
end

function MeiBaShouTaoCtrl:GetRemindNum(remind_name)
    return self.data:CanLingqu() and 1 or 0
end

function MeiBaShouTaoCtrl:OnHandAdd(protocol)
    self.data:SetAddData{level = protocol.level, exp = protocol.exp}
end

function MeiBaShouTaoCtrl:SpareTimerFunc()
    local time2 = MeiBaShouTaoData.Instance:GetComposeData().end_time - TimeCtrl.Instance:GetServerTime()
    if time2 <= 0 then
        self:DeleteSpareTimer()
        RemindManager.Instance:DoRemindDelayTime(RemindName.HandCompose)
    end
end

function MeiBaShouTaoCtrl:FlushSpareTimer()
    if nil == self.spare_timer and MeiBaShouTaoData.Instance:GetIsComposing() then
        self.spare_timer = GlobalTimerQuest:AddRunQuest(function ()
            self:SpareTimerFunc()
        end, 1)
        self:SpareTimerFunc()
    end
end

function MeiBaShouTaoCtrl:DeleteSpareTimer()
    if self.spare_timer ~= nil then
        GlobalTimerQuest:CancelQuest(self.spare_timer)
        self.spare_timer = nil
    end
end

function MeiBaShouTaoCtrl:OnHandCompose(protocol)
    self.data:SetComposeData{end_time = protocol.end_time, q_idx = protocol.q_idx, i_idx = protocol.i_idx}
    self:FlushSpareTimer()
    -- if self.data:CanLingqu() then
        RemindManager.Instance:DoRemindDelayTime(RemindName.HandCompose)
    -- end
end