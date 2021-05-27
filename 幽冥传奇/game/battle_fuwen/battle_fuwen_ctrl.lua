require("scripts/game/battle_fuwen/battle_fuwen_data")
require("scripts/game/battle_fuwen/battle_fuwen_view")
require("scripts/game/battle_fuwen/battle_fuwen_decompose_view")
require("scripts/game/battle_fuwen/battle_fuwen_replace_view")
require("scripts/game/battle_fuwen/battle_fuwen_show_all_view")
require("scripts/game/battle_fuwen/battle_fuwen_exchange_view")
BattleFuwenCtrl = BattleFuwenCtrl or BaseClass(BaseController)

function BattleFuwenCtrl:__init()
    if BattleFuwenCtrl.Instance then
        ErrorLog("[BattleFuwenCtrl]:Attempt to create singleton twice!")
    end
    BattleFuwenCtrl.Instance = self
    
    self.data = BattleFuwenData.New()
    self.view = BattleFuwenView.New(ViewDef.BattleFuwen)
    self.decompose_view = DecomposeZhanwenView.New(ViewDef.DecomposeZhanwen)
    self.replace_view = ReplaceZhanwenView.New(ViewDef.ReplaceZhanwen)
    self.showAll_view = ShowAllZhanwenView.New(ViewDef.ShowAllZhanwen)
    self.exchange_view = ExchageZhanwenView.New(ViewDef.ExchangeZhanwen)

    self:RegisterAllProtocols()
end

function BattleFuwenCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil

    self.decompose_view:DeleteMe()
    self.decompose_view = nil

    self.replace_view:DeleteMe()
    self.replace_view = nil
    
    self.exchange_view:DeleteMe()
    self.exchange_view = nil

    self.showAll_view:DeleteMe()
    self.showAll_view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    BattleFuwenCtrl.Instance = nil
end

function BattleFuwenCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCBattleFuwenInfo, "OnBattleFuwenInfo")
    self:RegisterProtocol(SCClothBattleFuwenInfo, "OnClothBattleFuwenInfo")
    self:RegisterProtocol(SCUpLevelBattleFuwenInfo, "OnUpLevelBattleFuwenInfo")
    self:RegisterProtocol(SCUnClothBattleFuwenInfo, "OnUnClothBattleFuwenInfo")
    self:RegisterProtocol(SCDecomposeBattleFuwenInfo, "OnDecomposeBattleFuwenInfo")
    self:RegisterProtocol(SCBattleFuwenJingHuaInfo, "OnBattleFuwenJingHuaInfo")
    self:RegisterProtocol(SCReplaceBattleFuwenInfo, "OnReplaceBattleFuwenInfo")
end

--下发 1数据 2装备 3升级 4脱下 5分解 6精华数量 7替换
function BattleFuwenCtrl:OnBattleFuwenInfo(protocol)
    self.data:SetZhanwenData(protocol.info)
end

function BattleFuwenCtrl:OnClothBattleFuwenInfo(protocol)
    self.data:UpdateZhanwenData(protocol.slot, protocol.item_data, "cloth")
end

function BattleFuwenCtrl:OnUpLevelBattleFuwenInfo(protocol)
    self.data:UpdateZhanwenData(protocol.slot, protocol.level, "uplevel")
end

function BattleFuwenCtrl:OnUnClothBattleFuwenInfo(protocol)
end

function BattleFuwenCtrl:OnDecomposeBattleFuwenInfo(protocol)
    BattleFuwenData.Instance:ClearDecomseData()
end

function BattleFuwenCtrl:OnBattleFuwenJingHuaInfo(protocol)
    self.data:SetZhanwenJinghuaNum(protocol.zw_jinghua)
end

function BattleFuwenCtrl:OnReplaceBattleFuwenInfo(protocol)
    self.data:UpdateZhanwenData(protocol.slot, protocol.item_data, "cloth")
end

--请求 装备 升级 脱下 分解 替换
function BattleFuwenCtrl.SendBattleFuwenClothReq(uid, slot)
    local protocol = ProtocolPool.Instance:GetProtocol(CSClothBattleFuwenReq)
    protocol.uid = uid
    protocol.slot = slot
    protocol:EncodeAndSend()
end

function BattleFuwenCtrl.SendUpLevelBattleFuwenReq(slot)
    local protocol = ProtocolPool.Instance:GetProtocol(CSUpLevelBattleFuwenReq)
    protocol.slot = slot
    protocol:EncodeAndSend()
end

function BattleFuwenCtrl.SendUnClothBattleFuwenReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSUnClothBattleFuwenReq)
    protocol:EncodeAndSend()
end

function BattleFuwenCtrl.SendDecomposeBattleFuwenReq(decompose_item_list)
    local protocol = ProtocolPool.Instance:GetProtocol(CSDecomposeBattleFuwenReq)
    protocol.decompose_item_list = decompose_item_list
    protocol:EncodeAndSend()
end

function BattleFuwenCtrl.SendBattleFuwenReplaceReq(uid, slot)
    local protocol = ProtocolPool.Instance:GetProtocol(CSReplaceBattleFuwenReq)
    protocol.uid = uid
    protocol.slot = slot
    protocol:EncodeAndSend()
end