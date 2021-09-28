local ShopGiftbagItem = class("ShopGiftbagItem",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopGiftBagItem.json")
end)

require("app.cfg.item_info")
require("app.cfg.shop_score_info")
local Colors = require("app.setting.Colors")

function ShopGiftbagItem:ctor()
    self._buyFunc = nil
    self._itemFunc = nil
    --普通item
    self._itemImage = self:getImageViewByName("ImageView_item")            --道具icon
    self._nameLabel = self:getLabelByName("Label_name")                    --道具名称
    self._buyVipLabel = self:getLabelByName("Label_buyVip")            	   --购买Vip限制
    self._qualityButton = self:getButtonByName("Button_item")              --品质框按钮
    self._descLabel = self:getLabelByName("Label_description")             --道具描述

    self._startPriceLabel = self:getLabelByName("Label_startPrice")                  --原价
    self._currentPriceLabel = self:getLabelByName("Label_currentPrice")                  --现价

    self._buttonTexture = self:getImageViewByName("ImageView_buttonText")  --按钮上的文字图片
    self._itemBg = self:getImageViewByName("ImageView_bg")                 --背景图片

    self:enableLabelStroke("Label_name", Colors.strokeBrown,1)
    
    self:registerBtnClickEvent("Button_buy", function ( widget )
        if self._buyFunc ~= nil then self._buyFunc() end
    end)
    self:registerBtnClickEvent("Button_item", function ( widget )
        if self._itemFunc ~= nil then self._itemFunc() end
    end)
end

function ShopGiftbagItem:setBuyButtonEvent(func)
    self._buyFunc = func
end
function ShopGiftbagItem:setCheckItemInfoFunc(func)
    self._itemFunc = func
end

function ShopGiftbagItem:_init()
    self:getLabelByName("Label_zhekou"):setText("")
    self:getLabelByName("Label_buyVip"):setText("")
    self:getLabelByName("Label_description"):setText("")
    self:getLabelByName("Label_name"):setText("")

    self:getLabelByName("Label_currentPrice"):setText("")
    self:getLabelByName("Label_startPrice"):setText("")
    
    self:showWidgetByName("ImageView_tuijian",false)
end
function ShopGiftbagItem:updateCell(item)
    if not item then
        self:_init()
        return
    end
    local goods =G_Goods.convert(item.type, item.value)
    if not goods then
        self:_init()
        return
    end
    self._nameLabel:setColor(Colors.getColor(goods.quality))
    self._nameLabel:setText(item.name)
    self._qualityButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality,goods.type))
    self._qualityButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality,goods.type))
    self._descLabel:setText(item.direction)
    self._startPriceLabel:setText(item.pre_price)

    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id) 
    if isDiscount then
        self:showWidgetByName("Label_zhekou",true)
        self:showWidgetByName("ImageView_tuijian",true)
        self._currentPriceLabel:setText(math.ceil(item.price * discount / 1000))
    else
        self._currentPriceLabel:setText(item.price)
        self:showWidgetByName("Label_zhekou",false)
        self:showWidgetByName("ImageView_tuijian",false)
    end
    --先隐藏掉
    self._itemImage:loadTexture(G_Goods.convert(item.type, item.value).icon,UI_TEX_TYPE_LOCAL);
    local touchEnable = false
    local purchaseEnabled,vipLimit,texture= G_Me.shopData:checkGiftItemPurchaseEnabled(item)
    self:showWidgetByName("Label_buyVip",vipLimit ~= nil)
    self:getButtonByName("Button_buy"):setTouchEnabled(purchaseEnabled)
    if vipLimit ~= nil then
        self:getLabelByName("Label_buyVip"):setText(G_lang:get("LANG_PURCHASE_VIP_PURCHASE",{vip=vipLimit}))
    end
    self:getImageViewByName("ImageView_buttonText"):loadTexture(texture,UI_TEX_TYPE_LOCAL)
end

return ShopGiftbagItem

