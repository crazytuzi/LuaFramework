---
--- Created by  Administrator
--- DateTime: 2019/6/10 10:40
---
MarryPageItem = MarryPageItem or class("MarryPageItem", BaseCloneItem)
local this = MarryPageItem

function MarryPageItem:ctor(obj, parent_node, parent_panel)
    MarryPageItem.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
end

function MarryPageItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function MarryPageItem:LoadCallBack()
    self.nodes = {
        "selelct","bg","name"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    self:AddEvent()

    self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(609, 187)
    
end

function MarryPageItem:InitUI()

end

function MarryPageItem:AddEvent()
    local function call_back()
        self.model:Brocast(MarryEvent.ClickMarryPageItem,self.data.id)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function MarryPageItem:SetData(data)
    self.data = data
    self:InitInfo()
end

function MarryPageItem:InitInfo()
    self.name.text = self.data.text
end

function MarryPageItem:SetSelect(isShow)
    SetVisible(self.selelct,isShow)
end

function MarryPageItem:SetRedPoint(isShow)
    self.red:SetRedDotParam(isShow)
end