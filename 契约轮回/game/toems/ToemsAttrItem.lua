---
--- Created by  Administrator
--- DateTime: 2020/7/27 14:30
---
ToemsAttrItem = ToemsAttrItem or class("ToemsAttrItem", BaseCloneItem)
local this = ToemsAttrItem

function ToemsAttrItem:ctor(obj, parent_node, parent_panel)
    ToemsAttrItem.super.Load(self)
    self.events = {}
end

function ToemsAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ToemsAttrItem:LoadCallBack()
    self.nodes = {
        "name","value",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.value = GetText(self.value)
    self:InitUI()
    self:AddEvent()
end

function ToemsAttrItem:InitUI()

end

function ToemsAttrItem:AddEvent()

end

function ToemsAttrItem:SetData(key,value, propValue)
    self.name.text = PROP_ENUM[key].label .. ":";
    if key >= 13 then
        self.value.text = math.ceil(tonumber(value) / 100) .. propValue .. "%";
    else
        self.value.text = tostring(value) .. propValue;
    end
end