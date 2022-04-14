---
--- Created by  Administrator
--- DateTime: 2020/7/27 11:50
---
ToemsSkillItem = ToemsSkillItem or class("ToemsSkillItem", BaseCloneItem)
local this = ToemsSkillItem

function ToemsSkillItem:ctor(obj, parent_node, parent_panel)
    ToemsSkillItem.super.Load(self)
    self.events = {}
end

function ToemsSkillItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ToemsSkillItem:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function ToemsSkillItem:InitUI()

end

function ToemsSkillItem:AddEvent()

end