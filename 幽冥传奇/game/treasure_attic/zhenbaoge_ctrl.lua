require("scripts/game/treasure_attic/zhenbaoge_data")
require("scripts/game/treasure_attic/zhenbaoge_view")
ZhenBaoGeCtrl = ZhenBaoGeCtrl or BaseClass(BaseController)

function ZhenBaoGeCtrl:__init()
    if ZhenBaoGeCtrl.Instance then
        ErrorLog("[ZhenBaoGeCtrl]:Attempt to create singleton twice!")
    end
    ZhenBaoGeCtrl.Instance = self
    
    self.data = ZhenBaoGeData.New()
    --self.view = ZhenBaoGeView.New(ViewDef.TreasureAttic.ZhenBaoGe)
    self:RegisterAllProtocols()
end

function ZhenBaoGeCtrl:__delete()
    
    self.data:DeleteMe()
    self.data = nil
    
    ZhenBaoGeCtrl.Instance = nil
end

function ZhenBaoGeCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCZhenBaoGeInfo, "OnZhenBaoGeInfo")
    self:RegisterProtocol(SCDiceResult, "OnDiceResult")
    self:RegisterProtocol(SCStepRewardResult, "OnStepRewardResult")
    self:RegisterProtocol(SCLayerRewardResult, "OnLayerRewardResult")
end

function ZhenBaoGeCtrl:OnZhenBaoGeInfo(protocol)
    self.data:SetZhenBaoGeInfo(protocol)
end

function ZhenBaoGeCtrl:OnDiceResult(protocol)
    self.data:SetDiceResult(protocol)
    --self.view:RoleMove()
end

function ZhenBaoGeCtrl:OnStepRewardResult(protocol)
    self.data:SetStepRewardResult(protocol)
    --self.view:UpdateInfo()
end

function ZhenBaoGeCtrl:OnLayerRewardResult(protocol)
    self.data:SetLayerRewardResult(protocol)

end




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ZhenBaoGeCtrl.ReqThrowDice(type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSThrowDice)
    protocol.opt_type = type
    protocol:EncodeAndSend()
end

function  ZhenBaoGeCtrl.ReqStepReward()
    local protocol = ProtocolPool.Instance:GetProtocol(CSZhenBaoGeStepReward)
    protocol:EncodeAndSend()
end

function ZhenBaoGeCtrl.ReqLayerReward(reward_index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSZhenBaoGeLayerReward)
    protocol.index = reward_index
    protocol:EncodeAndSend()
end


--开始物品飞行
function ZhenBaoGeCtrl:StartFlyItem(item_id)
    local fly_to_target = ViewManager.Instance:GetUiNode("TreasureAttic#ZhenBaoGe", "lbl_color_stone")
    local path = ""
    local item_cfg = ItemData.Instance:GetItemConfig(item_id)

    if nil ~= item_cfg and item_cfg.icon and item_cfg.icon > 0 then
        path = ResPath.GetItem(item_cfg.icon) --物品图标路径
    end
    
    if "" == path or nil == fly_to_target then return end

    local screen_w = HandleRenderUnit:GetWidth()        --得到显示屏的宽
    local screen_h = HandleRenderUnit:GetHeight()       --得到显示屏的高
    local fly_icon = XUI.CreateImageView(0, 0, path, false)

    fly_icon:setAnchorPoint(0, 0)
    HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)  --添加ui
    local world_pos = fly_icon:convertToWorldSpace(cc.p(0,0))
    fly_icon:setPosition(screen_w / 2, screen_h / 2)

    local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
    local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x-100, fly_to_pos.y-100))
    local spawn = cc.Spawn:create(move_to)
    local callback = cc.CallFunc:create(BindTool.Bind(self.ItemFlyEnd, self, fly_icon))
    local action = cc.Sequence:create(spawn, callback)
    fly_icon:runAction(action)
end

--物品飞行结束回调
function ZhenBaoGeCtrl:ItemFlyEnd(fly_icon)
    if fly_icon then
        fly_icon:removeFromParent()     --从父节点中删除
    end
end
