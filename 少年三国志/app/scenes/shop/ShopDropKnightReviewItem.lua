local ShopDropKnightReviewItem = class("ShopDropKnightReviewItem",function()
	--记得修改json
    return CCSItemCellBase:create("ui_layout/shop_ShopDropKnightReviewItem.json")
end)
--require("app.cfg.knight_info")
local Colors = require("app.setting.Colors")


function ShopDropKnightReviewItem:ctor(...)
    self._name01Label = self:getLabelByName("Label_name01")
    self._name02Label = self:getLabelByName("Label_name02")
    self._name03Label = self:getLabelByName("Label_name03")
    self._name04Label = self:getLabelByName("Label_name04")
    
    self._button01 = self:getButtonByName("Button_knightitem01")
    self._button02 = self:getButtonByName("Button_knightitem02")
    self._button03 = self:getButtonByName("Button_knightitem03")
    self._button04 = self:getButtonByName("Button_knightitem04")
    
    self._ImageView_knight01 = self:getImageViewByName("ImageView_knight01")
    self._ImageView_knight02 = self:getImageViewByName("ImageView_knight02")
    self._ImageView_knight03 = self:getImageViewByName("ImageView_knight03")
    self._ImageView_knight04 = self:getImageViewByName("ImageView_knight04")

    self._name01Label:createStroke(Colors.strokeBrown,1)
    self._name02Label:createStroke(Colors.strokeBrown,1)
    self._name03Label:createStroke(Colors.strokeBrown,1)
    self._name04Label:createStroke(Colors.strokeBrown,1)
end

function ShopDropKnightReviewItem:update(knigth01,knigth02,knigth03,knigth04)
    if knigth01 ~= nil then
        self._ImageView_knight01:loadTexture(G_Path.getKnightIcon(knigth01.res_id),UI_TEX_TYPE_LOCAL)
        self._name01Label:setColor(Colors.getColor(knigth01.quality))
        self._name01Label:setText(knigth01.name)
        self._button01:loadTextureNormal(G_Path.getEquipColorImage(knigth01.quality,G_Goods.TYPE_KNIGHT))
        self._button01:loadTexturePressed(G_Path.getEquipColorImage(knigth01.quality,G_Goods.TYPE_KNIGHT))
    end
    
    if knigth02 ~= nil then
        self._ImageView_knight02:loadTexture(G_Path.getKnightIcon(knigth02.res_id),UI_TEX_TYPE_LOCAL)
        self._name02Label:setColor(Colors.getColor(knigth02.quality))
        self._name02Label:setText(knigth02.name)
        self._button02:loadTextureNormal(G_Path.getEquipColorImage(knigth02.quality,G_Goods.TYPE_KNIGHT))
        self._button02:loadTexturePressed(G_Path.getEquipColorImage(knigth02.quality,G_Goods.TYPE_KNIGHT))
    end
    
    if knigth03 ~= nil then
        self._ImageView_knight03:loadTexture(G_Path.getKnightIcon(knigth03.res_id),UI_TEX_TYPE_LOCAL)
        self._name03Label:setColor(Colors.getColor(knigth03.quality))
        self._name03Label:setText(knigth03.name)
        self._button03:loadTextureNormal(G_Path.getEquipColorImage(knigth03.quality,G_Goods.TYPE_KNIGHT))
        self._button03:loadTexturePressed(G_Path.getEquipColorImage(knigth03.quality,G_Goods.TYPE_KNIGHT))
    end
    
    if knigth04 ~= nil then
        self._ImageView_knight04:loadTexture(G_Path.getKnightIcon(knigth04.res_id),UI_TEX_TYPE_LOCAL)
        self._name04Label:setColor(Colors.getColor(knigth04.quality))
        self._name04Label:setText(knigth04.name)
        self._button04:loadTextureNormal(G_Path.getEquipColorImage(knigth04.quality,G_Goods.TYPE_KNIGHT))
        self._button04:loadTexturePressed(G_Path.getEquipColorImage(knigth04.quality,G_Goods.TYPE_KNIGHT))
    end
    self:showWidgetByName("ImageView_knight_bg01",knigth01 ~= nil)
    self:showWidgetByName("ImageView_knight_bg02",knigth02 ~= nil)
    self:showWidgetByName("ImageView_knight_bg03",knigth03 ~= nil)
    self:showWidgetByName("ImageView_knight_bg04",knigth04 ~= nil)

    self._name01Label:setVisible(knigth01 ~= nil)
    self._name02Label:setVisible(knigth02 ~= nil)
    self._name03Label:setVisible(knigth03 ~= nil)
    self._name04Label:setVisible(knigth04 ~= nil)
    self:_initEvents(knigth01,knigth02,knigth03,knigth04)
end

function ShopDropKnightReviewItem:_initEvents(knigth01,knigth02,knigth03,knigth04)
    self:registerBtnClickEvent("Button_knightitem01",function() 
        if knigth01 == nil then return end
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knigth01.id) 
        end)
    self:registerBtnClickEvent("Button_knightitem02",function() 
        if knigth02 == nil then return end
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knigth02.id) 
        end)
    self:registerBtnClickEvent("Button_knightitem03",function() 
        if knigth03 == nil then return end
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knigth03.id) 
        end)
    self:registerBtnClickEvent("Button_knightitem04",function() 
        if knigth04 == nil then return end
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knigth04.id) 
        end)
end

function ShopDropKnightReviewItem:showWidget(index)
    
end

return ShopDropKnightReviewItem
	
