---
--- Created by  Administrator
--- DateTime: 2019/11/13 14:32
---
BabyToysAttrItem = BabyToysAttrItem or class("BabyToysAttrItem", BaseCloneItem)
local this = BabyToysAttrItem

function BabyToysAttrItem:ctor(obj, parent_node, parent_panel)
    BabyToysAttrItem.super.Load(self)
    self.events = {}
end

function BabyToysAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function BabyToysAttrItem:LoadCallBack()
    self.nodes = {
        "baseAttrtex","baseAttr","upImg"
    }
    self:GetChildren(self.nodes)
    self.baseAttrtex = GetText(self.baseAttrtex)
    self.baseAttr = GetText(self.baseAttr)
    self:InitUI()
    self:AddEvent()
end

function BabyToysAttrItem:InitUI()

end

function BabyToysAttrItem:AddEvent()

end

function BabyToysAttrItem:SetData(data,isShowUp)
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