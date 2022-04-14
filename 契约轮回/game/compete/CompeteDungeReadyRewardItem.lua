---
--- Created by  Administrator
--- DateTime: 2019/11/25 14:47
---
CompeteDungeReadyRewardItem = CompeteDungeReadyRewardItem or class("CompeteDungeReadyRewardItem", BaseCloneItem)
local this = CompeteDungeReadyRewardItem

function CompeteDungeReadyRewardItem:ctor(obj, parent_node, parent_panel)
    CompeteDungeReadyRewardItem.super.Load(self)
    self.events = {}
end

function CompeteDungeReadyRewardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteDungeReadyRewardItem:LoadCallBack()
    self.nodes = {
        "diamondIcon","diamondText",
    }
    self:GetChildren(self.nodes)
    self.diamondIcon = GetImage(self.diamondIcon)
    self.diamondText = GetText(self.diamondText)
    self:InitUI()
    self:AddEvent()
end

function CompeteDungeReadyRewardItem:InitUI()

end

function CompeteDungeReadyRewardItem:AddEvent()

end

function CompeteDungeReadyRewardItem:SetData(id,number)
    local iconName = Config.db_item[id].icon
    GoodIconUtil:CreateIcon(self, self.diamondIcon, iconName, true)
    self.diamondText.text = number
end