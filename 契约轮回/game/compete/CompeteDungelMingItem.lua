---
--- Created by  Administrator
--- DateTime: 2019/11/26 16:14
---
CompeteDungelMingItem = CompeteDungelMingItem or class("CompeteDungelMingItem", BaseCloneItem)
local this = CompeteDungelMingItem

function CompeteDungelMingItem:ctor(obj, parent_node, parent_panel)
    CompeteDungelMingItem.super.Load(self)
    self.events = {}
end

function CompeteDungelMingItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteDungelMingItem:LoadCallBack()
    self.nodes = {
        "head","noHead"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function CompeteDungelMingItem:InitUI()

end

function CompeteDungelMingItem:AddEvent()

end

function CompeteDungelMingItem:SetData(index)
    self.index = index
    SetVisible(self.noHead,false)
end

function CompeteDungelMingItem:UpdateInfo(isShow)
    if isShow then
        SetVisible(self.head,true)
        SetVisible(self.noHead,false)
    else
        SetVisible(self.head,false)
        SetVisible(self.noHead,true)
    end
end