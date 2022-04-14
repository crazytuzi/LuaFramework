---
--- Created by  Administrator
--- DateTime: 2019/9/9 16:50
---
GodOrderAttr = GodOrderAttr or class("GodOrderAttr", BaseCloneItem)
local this = GodOrderAttr

function GodOrderAttr:ctor(obj, parent_node, parent_panel)
    GodOrderAttr.super.Load(self)
    self.events = {}
end

function GodOrderAttr:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodOrderAttr:LoadCallBack()
    self.nodes = {
        "baseAttr","baseAttrtex",
    }
    self:GetChildren(self.nodes)
    self.baseAttr = GetText(self.baseAttr)
    self.baseAttrtex = GetText(self.baseAttrtex)
    self:InitUI()
    self:AddEvent()
end

function GodOrderAttr:InitUI()

end

function GodOrderAttr:AddEvent()

end

function GodOrderAttr:SetData(attrName,attr)
  --  self.data = data
    self.baseAttrtex.text = attrName
    self.baseAttr.text = attr
end