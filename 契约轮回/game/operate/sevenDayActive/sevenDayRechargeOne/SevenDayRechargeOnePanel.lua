---
--- Created by  Administrator
--- DateTime: 2019/4/20 15:40
---
SevenDayRechargeOnePanel = SevenDayRechargeOnePanel or class("SevenDayRechargeOnePanel", SevenDayRechargePanel)
local this = SevenDayRechargeOnePanel

function SevenDayRechargeOnePanel:ctor(parent_node, parent_panel,actID)

    self.abName = "sevenDayActive"
    self.assetName = "SevenDayRechargeOnePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 2
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    --self.events = {}
    --self.rewardItems = {}
   -- SevenDayRechargeOnePanel.super.Load(self)
end

--function SevenDayRechargeOnePanel:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end
--
--function SevenDayRechargeOnePanel:LoadCallBack()
--    self.nodes = {
--
--    }
--    self:GetChildren(self.nodes)
--
--    self:InitUI()
--    self:AddEvent()
--end
--
--function SevenDayRechargeOnePanel:InitUI()
--    dump(self.data)
--end
--
--function SevenDayRechargeOnePanel:AddEvent()
--
--end