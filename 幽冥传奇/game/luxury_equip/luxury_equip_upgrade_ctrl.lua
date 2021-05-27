require("scripts/game/luxury_equip/luxury_equip_upgrade_data")
require("scripts/game/luxury_equip/luxury_equip_upgrade_view")
LuxuryEquipUpgradeCtrl = LuxuryEquipUpgradeCtrl or BaseClass(BaseController)

function LuxuryEquipUpgradeCtrl:__init()
    if LuxuryEquipUpgradeCtrl.Instance then
        ErrorLog("[LuxuryEquipUpgradeCtrl]:Attempt to create singleton twice!")
    end
    LuxuryEquipUpgradeCtrl.Instance = self
    
    self.data = LuxuryEquipUpgradeData.New()
    self.view = LuxuryEquipUpgradeView.New(ViewDef.LuxuryEquipUpgrade)

    
    self:RegisterAllProtocols()
end

function LuxuryEquipUpgradeCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    LuxuryEquipUpgradeCtrl.Instance = nil
    if self.delay_timer then
        GlobalTimerQuest:CancelQuest(self.delay_timer)
        self.delay_timer = nil
    end
end

function LuxuryEquipUpgradeCtrl:RegisterAllProtocols()
    -- self:RegisterProtocol(SCLuxuryEquipUpgradeGuajiInfo, "OnLuxuryEquipUpgradeGuajiInfo")
    -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuajiReward)

    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.WanHaoCanCompose)
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.JinHaoCanCompose)
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.XiongHaoCanCompose)
   -- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ShengShouCanup)

    EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))

    self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo))
end

function LuxuryEquipUpgradeCtrl:OnRecvMainRoleInfo( ... )
    RemindManager.Instance:DoRemindDelayTime(RemindName.WanHaoCanCompose)
    RemindManager.Instance:DoRemindDelayTime(RemindName.JinHaoCanCompose)
    RemindManager.Instance:DoRemindDelayTime(RemindName.XiongHaoCanCompose)
end

function LuxuryEquipUpgradeCtrl:OnLuxuryEquipUpgradeGuajiInfo(protocol)
end


function LuxuryEquipUpgradeCtrl.SendLuxuryEquipUpgrade(pos)
    local protocol = ProtocolPool.Instance:GetProtocol(CSLuxuryEquipUpgradeReq)
    protocol.pos = pos
    protocol:EncodeAndSend()
end

function LuxuryEquipUpgradeCtrl:GetRemindNum(remind_name)
    if RemindName.WanHaoCanCompose == remind_name then
        return self.data:GetCanUpIndex(1)
    elseif RemindName.JinHaoCanCompose == remind_name then
        return self.data:GetCanUpIndex(2)
    elseif RemindName.XiongHaoCanCompose == remind_name then
        return self.data:GetCanUpIndex(3)
    end
end


function LuxuryEquipUpgradeCtrl:ItemDataListChangeCallback()
  if self.delay_timer then
        GlobalTimerQuest:CancelQuest(self.delay_timer)
        self.delay_timer = nil
    end
    -- self:InitComposeData()
    self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
            RemindManager.Instance:DoRemindDelayTime(RemindName.WanHaoCanCompose)
            RemindManager.Instance:DoRemindDelayTime(RemindName.JinHaoCanCompose)
            RemindManager.Instance:DoRemindDelayTime(RemindName.XiongHaoCanCompose)
            if self.delay_timer then
                GlobalTimerQuest:CancelQuest(self.delay_timer)
                self.delay_timer = nil
            end
    end, 0.3)
end


function LuxuryEquipUpgradeCtrl:RoleDataChangeCallback(vo)
    if vo.key == OBJ_ATTR.ACTOR_COIN  then
        RemindManager.Instance:DoRemindDelayTime(RemindName.WanHaoCanCompose)
        RemindManager.Instance:DoRemindDelayTime(RemindName.JinHaoCanCompose)
        RemindManager.Instance:DoRemindDelayTime(RemindName.XiongHaoCanCompose)
    end
end