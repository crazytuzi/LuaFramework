---
--- Created by  Administrator
--- DateTime: 2019/11/29 11:15
---
GodEquipAttrItem = GodEquipAttrItem or class("GodEquipAttrItem", BaseCloneItem)
local this = GodEquipAttrItem

function GodEquipAttrItem:ctor(parent_node, parent_panel)

    GodEquipAttrItem.super.Load(self)
    self.events = {}
end

function GodEquipAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodEquipAttrItem:LoadCallBack()
    self.nodes = {
        "baseAttrtex","baseAttr","upImg"
    }
    self:GetChildren(self.nodes)
    self.baseAttrtex = GetText(self.baseAttrtex)
    self.baseAttr = GetText(self.baseAttr)
    self:InitUI()
    self:AddEvent()
end

function GodEquipAttrItem:InitUI()

end

function GodEquipAttrItem:AddEvent()

end

function GodEquipAttrItem:SetData(data,isShowUp)
    self.data = data
    local type = Config.db_attr_type[self.data[1]].type == 2
    local value = self.data[2]
    if type then
        value = (value / 100).."%"
    end
    self.baseAttrtex.text = enumName.ATTR[self.data[1]]
    self.baseAttr.text = value
    SetVisible(self.upImg,isShowUp)
end