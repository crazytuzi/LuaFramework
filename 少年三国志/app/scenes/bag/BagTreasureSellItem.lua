local BagTreasureSellItem = class("BagTreasureSellItem",function()
    return CCSItemCellBase:create("ui_layout/bag_BagEquipmentSellItem.json")
end)

require("app.cfg.treasure_info")
function BagTreasureSellItem:ctor()
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
    self:setTouchEnabled(true)
    self._itemCheckBox = self:getCheckBoxByName("CheckBox_selected")
    self:registerBtnClickEvent("Button_item",function() 
        if self._infoFunc then self._infoFunc() end
        end)

    -- self._levelTagLabel:createStroke(Colors.strokeBrown,1)
    -- self._levelLabel:createStroke(Colors.strokeBrown,1)
    self._itemName:createStroke(Colors.strokeBrown,1)
    
end

function BagTreasureSellItem:setSelectedHandler()
    local selected = self._itemCheckBox:getSelectedState()
    self._itemCheckBox:setSelectedState(not selected)
    if self._checkboxFunc then self._checkboxFunc(not selected) end
end


function BagTreasureSellItem:updateCell(data)
    local treasure = treasure_info.get(data["base_id"])
    self._levelLabel:setText(G_lang:get("LANG_LEVEL_FORMAT_CHN",{levelValue=data["level"]}))

    __LogTag("wkj","-------data.refining_level  = %s",data.refining_level )
    --精炼X阶
    if data.refining_level > 0 then
        self:showWidgetByName("ImageView_jieshu",true)
        self:getLabelByName("Label_jieshu"):setText(G_lang:get("LANG_JING_LIAN", {level = data.refining_level}))
    else
        self:showWidgetByName("ImageView_jieshu",false)
    end

    self._priceLabel:setText(G_lang:get("LANG_BAG_SELL_PRICE",{price=data.money}))
    self._levelLabel:setText(data.level)
    self._itemImage:loadTexture(G_Path.getTreasureIcon(treasure.res_id),UI_TEX_TYPE_LOCAL)
    self._itemBg:loadTexture(G_Path.getEquipIconBack(treasure.quality))
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(treasure.quality,G_Goods.TYPE_TREASURE))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(treasure.quality,G_Goods.TYPE_TREASURE))
    self._itemName:setColor(Colors.qualityColors[treasure.quality])
    self._itemName:setText(treasure.name)
    self._itemCheckBox:setSelectedState(data["checked"])
end


function BagTreasureSellItem:setCheckBoxEvent(func)
    self._checkboxFunc = func
end

function BagTreasureSellItem:setCheckInfoFunc(func)
    self._infoFunc = func
end

return BagTreasureSellItem
