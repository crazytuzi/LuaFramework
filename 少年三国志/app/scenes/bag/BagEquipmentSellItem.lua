local BagEquipmentSellItem = class("BagEquipmentSellItem",function()
    return CCSItemCellBase:create("ui_layout/bag_BagEquipmentSellItem.json")
end)

require("app.cfg.equipment_info")
function BagEquipmentSellItem:ctor()
    --复选框选中事件
    self._checkboxFunc = nil
    self._infoFunc = nil
    self._itemImage  = self:getImageViewByName("ImageView_item")
    self._itemName = self:getLabelByName("Label_name")
    self._itemButton = self:getButtonByName("Button_item")
    self._itemBg = self:getImageViewByName("ImageView_item_bg")
    self._priceLabel = self:getLabelByName("Label_price")
    self._levelLabel = self:getLabelByName("Label_level")
    self._levelTagLabel = self:getLabelByName("Label_levelTag")
    self._jinjieLevel = self:getLabelByName("Label_jinjie")

    self._itemCheckBox = self:getCheckBoxByName("CheckBox_selected")
    self:setTouchEnabled(true)
    self:registerBtnClickEvent("Button_item",function() 
        if self._infoFunc then self._infoFunc() end
        end)

    -- self._levelTagLabel:createStroke(Colors.strokeBrown,1)
    -- self._levelLabel:createStroke(Colors.strokeBrown,1)
    self._itemName:createStroke(Colors.strokeBrown,1)
    
end

function BagEquipmentSellItem:setSelectedHandler()
    local selected = self._itemCheckBox:getSelectedState()
    self._itemCheckBox:setSelectedState(not selected)
    if self._checkboxFunc then self._checkboxFunc(not selected) end
end


function BagEquipmentSellItem:updateCell(data)

    local equip = equipment_info.get(data["base_id"])
    self._levelLabel:setText(G_lang:get("LANG_LEVEL_FORMAT_CHN",{levelValue=data["level"]}))

    self._priceLabel:setText(G_lang:get("LANG_BAG_SELL_PRICE",{price=data.money}))
    self._levelLabel:setText(data.level)
    self._itemImage:loadTexture(G_Path.getEquipmentIcon(equip.res_id),UI_TEX_TYPE_LOCAL)
    self._itemBg:loadTexture(G_Path.getEquipIconBack(equip.quality))
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(equip.quality,G_Goods.TYPE_EQUIPMENT))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(equip.quality,G_Goods.TYPE_EQUIPMENT))
    self._itemName:setColor(Colors.qualityColors[equip.quality])
    self._itemName:setText(equip.name)
    self._itemCheckBox:setSelectedState(data["checked"])
end


function BagEquipmentSellItem:setCheckBoxEvent(func)
    self._checkboxFunc = func
end

function BagEquipmentSellItem:setCheckInfoFunc(func)
    self._infoFunc = func
end

return BagEquipmentSellItem
