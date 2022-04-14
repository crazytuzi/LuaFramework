---
--- Created by  Administrator
--- DateTime: 2020/3/16 10:53
---
MergeRechargeTarget = MergeRechargeTarget or class("MergeRechargeTarget", SevenDayRechargePanel)
local this = MergeRechargeTarget

function MergeRechargeTarget:ctor(parent_node, parent_panel,actID)


    self.abName = "sevenDayActive"
    self.assetName = "MergeRechargePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 3
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    MergeRechargeTarget.super.Load(self)
end

function MergeRechargeTarget:BeforeLoad()

end

--function MergeRechargeTarget:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end

--function MergeRechargeTarget:LoadCallBack()
--    self.nodes = {
--
--    }
--    self:GetChildren(self.nodes)
--
--    self:InitUI()
--    self:AddEvent()
--end
--
--function MergeRechargeTarget:InitUI()
--
--end
--
--function MergeRechargeTarget:AddEvent()
--
--end