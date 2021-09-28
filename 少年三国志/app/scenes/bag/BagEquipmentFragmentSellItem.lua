-- 装备碎片出售cell

local BagEquipmentFragmentSellItem = class("BagEquipmentFragmentSellItem",function()
    return CCSItemCellBase:create("ui_layout/bag_BagEquipmentFragmentSellItem.json")
end)

BagEquipmentFragmentSellItem.KNIGHT_FRAGMENT = 1

require("app.cfg.fragment_info")
function BagEquipmentFragmentSellItem:ctor()
    --复选框选中事件
    self._checkboxFunc = nil
    self._infoFunc = nil
    self._itemImage  = self:getImageViewByName("ImageView_item")
    self._itemName = self:getLabelByName("Label_Name")
    self._itemButton = self:getButtonByName("Button_item")
    self._itemBg = self:getImageViewByName("ImageView_item_bg")
    self._priceLabel = self:getLabelByName("Label_Price")
    self._numLabel = self:getLabelByName("Label_Num")
    self._onLineLabel = self:getLabelByName("Label_On_Line")

    self._itemCheckBox = self:getCheckBoxByName("CheckBox_Selected")
    self:setTouchEnabled(true)
    self:registerBtnClickEvent("Button_item",function() 
        if self._infoFunc then self._infoFunc() end
        end)

    self._itemName:createStroke(Colors.strokeBrown,1)
    
end

function BagEquipmentFragmentSellItem:setSelectedHandler()
    local selected = self._itemCheckBox:getSelectedState()
    self._itemCheckBox:setSelectedState(not selected)
    if self._checkboxFunc then self._checkboxFunc(not selected) end
end


function BagEquipmentFragmentSellItem:updateCell(data)
    local fragmentInfo = fragment_info.get(data.id)

    self._onLineLabel:setVisible(false)    
    self._priceLabel:setText(G_lang:get("LANG_BAG_SELL_PRICE",{price=fragmentInfo.sale_num * data.num}))
    if fragmentInfo.fragment_type == BagEquipmentFragmentSellItem.KNIGHT_FRAGMENT then
        self._itemImage:loadTexture(G_Path.getKnightIcon(fragmentInfo.res_id),UI_TEX_TYPE_LOCAL)
        if G_Me.formationData:getKnightTeamIdByFragment(fragmentInfo.fragment_value) == 1 then 
            self._onLineLabel:setVisible(true)
        end
    else
        self._itemImage:loadTexture(G_Path.getEquipmentIcon(fragmentInfo.res_id),UI_TEX_TYPE_LOCAL)    
    end
    
    self._itemBg:loadTexture(G_Path.getEquipIconBack(fragmentInfo.quality))
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(fragmentInfo.quality,G_Goods.TYPE_FRAGMENT))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(fragmentInfo.quality,G_Goods.TYPE_FRAGMENT))
    self._itemName:setColor(Colors.qualityColors[fragmentInfo.quality])
    self._itemName:setText(fragmentInfo.name)

    self._numLabel:setText(data.num .. "/" .. fragmentInfo.max_num)

    if data.num >= fragmentInfo.max_num then
        self._numLabel:setColor(Colors.lightColors.ATTRIBUTE)
    else 
        self._numLabel:setColor(Colors.lightColors.DESCRIPTION)
    end

    self._itemCheckBox:setSelectedState(data["checked"])
end


function BagEquipmentFragmentSellItem:setCheckBoxEvent(func)
    self._checkboxFunc = func
end

function BagEquipmentFragmentSellItem:setCheckInfoFunc(func)
    self._infoFunc = func
end

return BagEquipmentFragmentSellItem
