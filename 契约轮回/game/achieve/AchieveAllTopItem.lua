---
--- Created by  Administrator
--- DateTime: 2019/4/2 17:53
---
AchieveAllTopItem = AchieveAllTopItem or class("AchieveAllTopItem", BaseCloneItem)
local this = AchieveAllTopItem

function AchieveAllTopItem:ctor(obj, parent_node, parent_panel)
    AchieveAllTopItem.super.Load(self)
    self.model = AchieveModel:GetInstance()
    self.events = {}
end

function AchieveAllTopItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function AchieveAllTopItem:LoadCallBack()
    self.nodes = {
        "num","name","ItemSlider",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.name = GetText(self.name)
    self.ItemSlider = GetSlider(self.ItemSlider)
    self:InitUI()
    self:AddEvent()
end

function AchieveAllTopItem:InitUI()

end

function AchieveAllTopItem:AddEvent()

end
function AchieveAllTopItem:SetData(data)
    self.data = data
    self:UpdateInfo()
end
function AchieveAllTopItem:UpdateInfo()
    self.name.text = self.data.name
    local allPoint = self.model:GetAllPointByGroup(self.data.id)
    local curPoint =  self.model:GetOnePointByGroup(self.data.id)
    self.num.text = string.format("%s/%s",curPoint,allPoint)
    self.ItemSlider.value = tonumber(curPoint)/tonumber(allPoint)
end