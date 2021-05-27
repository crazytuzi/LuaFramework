require("scripts/game/treasure_attic/treasure_attic_data")
require("scripts/game/treasure_attic/treasure_attic_view")
require("scripts/game/treasure_attic/dragon_ball_suit_attr_view")

TreasureAtticCtrl = TreasureAtticCtrl or BaseClass(BaseController)

function TreasureAtticCtrl:__init()
    if TreasureAtticCtrl.Instance then
        ErrorLog("[TreasureAtticCtrl]:Attempt to create singleton twice!")
    end
    TreasureAtticCtrl.Instance = self
    
    self.data = TreasureAtticData.New()
    self.view = TreasureAtticView.New(ViewDef.TreasureAttic)
    self.dragon_ball_suit_attr_view = DragonBallSuitAttrView.New(ViewDef.TreasureAttic.DragonBall.SuitAttr)
    self:RegisterAllProtocols()
end

function TreasureAtticCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    TreasureAtticCtrl.Instance = nil
end

function TreasureAtticCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCDragonBallInfo, "OnDragonBallInfo")
    self:RegisterProtocol(SCDragonBallResult, "OnDragonBallResult")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)
end

function TreasureAtticCtrl.SendTreasureAtticGuajiReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSTreasureAtticGuajiReq)
    protocol:EncodeAndSend()
end

function TreasureAtticCtrl:GetRemindNum(remind_name)
end

-- 接收龙珠所有数据
function TreasureAtticCtrl:OnDragonBallInfo(protocol)
    self.data:SetDragonBallData(protocol)
end

-- 接收提炼与吸收操作结果
function TreasureAtticCtrl:OnDragonBallResult(protocol)
    self.data:SetDragonBallResult(protocol)
end

-- 龙珠提炼(返回71 2)
function TreasureAtticCtrl.SendDragonBallAbsorbReq(type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSDragonBallAbsorbReq)
    protocol.type = type
    protocol:EncodeAndSend()
end

-- 龙珠吸收(返回71 2)
function TreasureAtticCtrl.SendDragonBallRefiningReq(type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSDragonBallRefiningReq)
    protocol.type = type
    protocol:EncodeAndSend()
end