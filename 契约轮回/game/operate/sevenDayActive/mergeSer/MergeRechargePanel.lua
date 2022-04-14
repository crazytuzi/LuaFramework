---
--- Created by  Administrator
--- DateTime: 2020/3/16 10:45
---
MergeRechargePanel = MergeRechargePanel or class("MergeRechargePanel", SevenDayRechargePanel)
local this = MergeRechargePanel

function MergeRechargePanel:ctor(parent_node, parent_panel,actID)
    self.abName = "sevenDayActive"
    self.assetName = "MergeRechargePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 1
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    -- dump(self.data)
    self.events = {}
    self.mEvents = {}
    self.rewardItems = {}
    MergeRechargePanel.super.Load(self)
end

function MergeRechargePanel:BeforeLoad()

end

function MergeRechargePanel:UpdateRewards(tab)
    local rewards = tab
    self.rewardItems = self.rewardItems or {}

    table.sort(rewards, function(a,b)
        local r
        if a.state == b.state then
            r = a.level < b.level
        else
            r = a.state < b.state
        end
        return r
    end)

    for i = 1, #rewards do
        local item = self.rewardItems[i]
        if not item then
            item  =   MergeRechargeItem(self.SevenDayRechargeItem.gameObject,self.rewardContent,"UI")
            self.rewardItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(rewards[i],self.actID,self.stype,self.StencilId)
    end
    for i = #tab + 1,#self.rewardItems do
        local Item = self.rewardItems[i]
        Item:SetVisible(false)
    end

end
