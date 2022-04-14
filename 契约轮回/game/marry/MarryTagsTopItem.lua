---
--- Created by  Administrator
--- DateTime: 2019/6/5 14:59
---
MarryTagsTopItem = MarryTagsTopItem or class("MarryTagsTopItem", BaseCloneItem)
local this = MarryTagsTopItem

function MarryTagsTopItem:ctor(obj, parent_node, parent_panel)
    MarryTagsTopItem.super.Load(self)
    self.model = MarryModel:GetInstance()
    self.events = {}
end

function MarryTagsTopItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MarryTagsTopItem:LoadCallBack()
    self.nodes = {
        "name","select","btn"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()
end

function MarryTagsTopItem:InitUI()

end

function MarryTagsTopItem:AddEvent()
    local function call_back()
        self.model:Brocast(MarryEvent.ClickMarryTagsTopItem,self.groupId)
    end
    AddClickEvent(self.btn.gameObject,call_back)
end

function MarryTagsTopItem:SetData(data,groupId)
    self.data = data
    self.groupId = groupId
    self.name.text = self.model:GetTagName(groupId)
end

function MarryTagsTopItem:SetShow(isShow)
    SetVisible(self.select,isShow)
end




