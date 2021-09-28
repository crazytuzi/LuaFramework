local BagKnightSellItem = class("BagKnightSellItem",function()
    return CCSItemCellBase:create("ui_layout/bag_BagKnightSellItem.json")
end)
require("app.cfg.knight_info")

function BagKnightSellItem:ctor()
    --复选框选中事件
    self._checkboxFunc = nil
    self._infoFunc = nil
    self._itemImage  = self:getImageViewByName("ImageView_item")
    self._itemName = self:getLabelByName("Label_name")
    self._itemButton = self:getButtonByName("Button_item")
    self._itemBg = self:getImageViewByName("ImageView_item_bg")
    self._priceLabel = self:getLabelByName("Label_price")
    self._levelLabel = self:getLabelByName("Label_level")
    self._jinjieLevel = self:getLabelByName("Label_jinjie")
    self._itemCheckBox = self:getCheckBoxByName("CheckBox_selected")
    self:setTouchEnabled(true)
    self:registerBtnClickEvent("Button_item",function() 
        if self._infoFunc then self._infoFunc() end
        end)

    -- self._jinjieLevel:createStroke(Colors.strokeBrown,1)
    self._itemName:createStroke(Colors.strokeBrown,1)
    -- self._levelLabel:createStroke(Colors.strokeBrown,1)
end

function BagKnightSellItem:setSelectedHandler()
    local selected = self._itemCheckBox:getSelectedState()
    self._itemCheckBox:setSelectedState(not selected)
    if self._checkboxFunc then self._checkboxFunc(not selected) end
end

function BagKnightSellItem:updateCell(data)
    local kni = knight_info.get(data["base_id"])
    self._itemName:setColor(Colors.qualityColors[kni.quality])
    self._itemName:setText(kni.name)
    self._itemBg:loadTexture(G_Path.getEquipIconBack(kni.quality))
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(kni.quality,G_Goods.TYPE_KNIGHT))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(kni.quality,G_Goods.TYPE_KNIGHT))
    self._levelLabel:setText(data.level)
    self._jinjieLevel:setText(kni.advanced_level)
    self._priceLabel:setText(G_lang:get("LANG_BAG_SELL_PRICE",{price=data.money}))
    self._itemImage:loadTexture(G_Path.getKnightIcon(kni.res_id),UI_TEX_TYPE_LOCAL)
    self._itemCheckBox:setSelectedState(data["checked"])
end


function BagKnightSellItem:setCheckBoxEvent(func)
    self._checkboxFunc = func
end

function BagKnightSellItem:setCheckInfoFunc(func)
    self._infoFunc = func
end

return BagKnightSellItem
