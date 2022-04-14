---
--- Created by  Administrator
--- DateTime: 2020/3/14 14:27
---
MergeSerRushBuy = MergeSerRushBuy or class("SevenDayRushBuyPanel", SevenDayRushBuyPanel)
local this = MergeSerRushBuy

function MergeSerRushBuy:ctor(parent_node, parent_panel,actID)
    self.abName = "sevenDayActive"
    self.assetName = "MergeSerRushBuy"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.rewardItems = {}
    self.isActOver = false
    -- self.items = {}
    self.model = SevenDayActiveModel:GetInstance()
    self.actID = actID
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    MergeSerRushBuy.super.Load(self)
end

function MergeSerRushBuy:BeforeLoad()

end

--function MergeSerRushBuy:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end
--
--function MergeSerRushBuy:LoadCallBack()
--    self.nodes = {
--
--    }
--    self:GetChildren(self.nodes)
--
--    self:InitUI()
--    self:AddEvent()
--end
--
--function MergeSerRushBuy:InitUI()
--
--end
--
--function MergeSerRushBuy:AddEvent()
--
--end