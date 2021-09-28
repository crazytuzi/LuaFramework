require "app.cfg.item_awaken_info"

local AwakenSelectedItem = class("AwakenSelectedItem",function()
    return CCSItemCellBase:create("ui_layout/awaken_SelectedItem.json")
end)

function AwakenSelectedItem:ctor()
end

function AwakenSelectedItem:updateItem(_itemInfo)

    if not _itemInfo or type(_itemInfo) ~= "table" then 
        self:getPanelByName("Panel_3140"):setVisible(false)
        return 
    end

    local itemInfo = _itemInfo

    -- 名称
    G_GlobalFunc.updateLabel(self, "Label_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBlack})
    -- 数量
    G_GlobalFunc.updateLabel(self, "Label_text", {text=G_lang:get("LANG_BAG_ITEM_NUM")})
    G_GlobalFunc.updateLabel(self, "Label_num", {text= G_Me.bagData:getAwakenItemNumById(itemInfo.id) })

    -- icon
    G_GlobalFunc.updateImageView(self, "ImageView_item", {texture=itemInfo.icon, texType=UI_TEX_TYPE_LOCAL})
    -- bg
    G_GlobalFunc.updateImageView(self, "ImageView_item_bg", {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- frame
    local frame = self:getButtonByName("Button_quality")
    frame:loadTextureNormal(G_Path.getEquipColorImage(itemInfo.quality))
    frame:loadTexturePressed(G_Path.getEquipColorImage(itemInfo.quality))
    
end
 
return AwakenSelectedItem
