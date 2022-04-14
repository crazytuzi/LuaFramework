---
--- Created by  Administrator
--- DateTime: 2019/4/23 11:40
---
SevenDayTargetPanel = SevenDayTargetPanel or class("SevenDayTargetPanel", SevenDayRechargePanel)
local this = SevenDayTargetPanel

function SevenDayTargetPanel:ctor(parent_node, parent_panel,actID)


    self.abName = "sevenDayActive"
    self.assetName = "SevenDayTargetPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 3
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    dump(data)
end



--function SevenDayTargetPanel:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end
--
--function SevenDayTargetPanel:LoadCallBack()
--    self.nodes = {
--        "SevenDayTargetItem"
--    }
--    self:GetChildren(self.nodes)
--end
----
--function SevenDayTargetPanel:InitUI()
--
--end
--
--function SevenDayTargetPanel:AddEvent()
--
--end