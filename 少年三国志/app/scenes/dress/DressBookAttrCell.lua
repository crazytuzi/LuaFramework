local DressBookAttrCell = class("DressBookAttrCell",function()
    return CCSItemCellBase:create("ui_layout/dress_BookAttrCell.json")
end)

local MergeEquipment = require("app.data.MergeEquipment")

function DressBookAttrCell:ctor()

        self:setTouchEnabled(false)

end


function DressBookAttrCell:update(type,value)
    
    local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(type, value)
    local typeLabel = self:getLabelByName("Label_attrType")
    local valueLabel =self:getLabelByName("Label_attrValue")
    typeLabel:createStroke(Colors.strokeBrown, 1)
    valueLabel:createStroke(Colors.strokeBrown, 1)
    typeLabel:setText(strtype)
    valueLabel:setText(strvalue)
end

function DressBookAttrCell:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end

return DressBookAttrCell
