---
--- Created by  Administrator
--- DateTime: 2019/12/26 10:29
---
MachineArmorEquipAttrItem = MachineArmorEquipAttrItem or class("MachineArmorEquipAttrItem", BaseCloneItem)
local this = MachineArmorEquipAttrItem

function MachineArmorEquipAttrItem:ctor(parent_node, parent_panel)

    MachineArmorEquipAttrItem.super.Load(self)
    self.events = {}
end

function MachineArmorEquipAttrItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MachineArmorEquipAttrItem:LoadCallBack()
    self.nodes = {
        "baseAttrtex","baseAttr","upImg","upAttr"
    }
    self:GetChildren(self.nodes)
    self.baseAttrtex = GetText(self.baseAttrtex)
    self.baseAttr = GetText(self.baseAttr)
    self.upAttr = GetText(self.upAttr)
    self:InitUI()
    self:AddEvent()
end

function MachineArmorEquipAttrItem:InitUI()

end

function MachineArmorEquipAttrItem:AddEvent()

end
function MachineArmorEquipAttrItem:SetData(data,nextData,isMax)
    self.data = data
    local type = Config.db_attr_type[self.data[1]].type == 2
    local value = self.data[2]
    if type then
        value = (value / 100)
        self.baseAttr.text = value.."%"
    else
        self.baseAttr.text = value
    end
    self.baseAttrtex.text = enumName.ATTR[self.data[1]]


    if isMax then
        self.upAttr.text = "max"
        SetVisible(self.upImg,true)
    else

        local nextValue = nextData[2]
        local upValue
        if type then
            nextValue = (nextValue / 100)
            upValue = string.format("%.2f", nextValue - value)
        else
            upValue =  tostring(nextValue - value)
        end
        local isShowUp = true
        --  string.format("%.2", nextValue - value)
        -- local upValue =   string.format("%.2f", nextValue - value)
        --local upValue = tostring(nextValue - value)
        if nextValue - value == 0 then
            upValue = ""
            isShowUp = false
        end
        if type then
            self.upAttr.text = upValue.."%"
        else
            self.upAttr.text = upValue
        end

        SetVisible(self.upImg,isShowUp)
    end



    --SetVisible(self.upImg,isShowUp)
end