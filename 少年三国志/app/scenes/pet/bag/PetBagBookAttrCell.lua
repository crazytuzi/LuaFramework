-- PetBagBookAttrCell.lua

local MergeEquipment = require("app.data.MergeEquipment")

local PetBagBookAttrCell = class("PetBagBookAttrCell",function()
    return CCSItemCellBase:create("ui_layout/petbag_BookAttrCell.json")
end)

function PetBagBookAttrCell:ctor()

    self._typeLabel = self:getLabelByName("Label_attrType")
    self._valueLabel = self:getLabelByName("Label_attrValue")

    self:setTouchEnabled(false)
end

function PetBagBookAttrCell:update(type,value)
    
    local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(type, value)
   
    self._typeLabel:createStroke(Colors.strokeBrown, 1)
    self._valueLabel:createStroke(Colors.strokeBrown, 1)
    self._typeLabel:setText(strtype)
    self._valueLabel:setText(strvalue)
end

return PetBagBookAttrCell
