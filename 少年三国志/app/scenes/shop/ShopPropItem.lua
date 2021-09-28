local ShopPropItem = class("ShopPropItem",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopPropItem.json")
end)

require("app.cfg.item_info")
require("app.cfg.fragment_info")
require("app.cfg.shop_score_info")
require("app.cfg.shop_price_info")
local Colors = require("app.setting.Colors")

function ShopPropItem:ctor()
    self._buyFunc = nil
    self._itemInfoFunc = nil

    --普通item
    self._itemImage = self:getImageViewByName("ImageView_item")             --道具icon
    self._nameLabel = self:getLabelByName("Label_name")                    --道具名称
    self._buycountLabel = self:getLabelByName("Label_buyTimes")            --还可购买次数
    self._qualityButton = self:getButtonByName("Button_item")              --品质框按钮
    self._descLabel = self:getLabelByName("Label_description")             --道具描述
    self._priceTagImage = self:getImageViewByName("ImageView_priceTag")    --价格图片，元宝or银两
    self._priceLabel = self:getLabelByName("Label_price")                  --道具价格
    self._buttonTexture = self:getImageViewByName("ImageView_buttonText")  --按钮上的文字图片
    self._itemBg = self:getImageViewByName("ImageView_item_bg")                 --背景图片
    --竞拍Item
    self._maxPrice = self:getLabelByName("Label_maxPrice")                 --当前最高价格
    self._leftTime = self:getLabelByName("Label_leftTime")                 --剩余时间
    self._startPrice = self:getLabelByName("Label_startPrice")             --起始价格
    self._addPrice = self:getLabelByName("Label_addPrice")                 --加价

    -- self:enableLabelStroke("Label_price", Colors.strokeBrown,1)

    self:registerBtnClickEvent("Button_buy", function ( widget )
        if self._buyFunc ~= nil then
            self:setClickCell()
            self._buyFunc() 
        end
    end)
    self:registerBtnClickEvent("Button_item", function ( widget )
        if self._itemInfoFunc ~= nil then self._itemInfoFunc() end
    end)

    self._nameLabel:createStroke(Colors.strokeBrown,1)
end

function ShopPropItem:setBuyButtonEvent(func)
    self._buyFunc = func
end

function ShopPropItem:setCheckItemInfoButtonEvent(func)
    self._itemInfoFunc = func
end


--突发事件时候，初始化一些widget
function ShopPropItem:_init()
    self:getLabelByName("Label_zhekou"):setText("")
    self:getLabelByName("Label_buyTimes"):setText("")
    self:getLabelByName("Label_description"):setText("")
    self:getLabelByName("Label_price"):setText("")
    self:getLabelByName("Label_name"):setText("")

    self:showWidgetByName("ImageView_tuijian",false)
    self:showWidgetByName("Label_endTime",false)
end

function ShopPropItem:updateCell(item)
    
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
    self._priceTagImage:loadTexture(G_Path.getPriceTypeIcon(item.price_type),UI_TEX_TYPE_PLIST)
    self._priceLabel:setColor(Colors.lightColors.TITLE_02)

    --item背景图
    self._itemBg:loadTexture(G_Path.getEquipIconBack(goods.quality))

    -- self._priceLabel:setText(item.price)
    local price = G_Me.shopData:getPrice(item)
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id)   --折扣信息
    if isDiscount then
        self:showWidgetByName("ImageView_tuijian",true)
        self:getImageViewByName("ImageView_tuijian"):loadTexture(G_Path.getTextPath("sc_youhui.png"))
        self:showWidgetByName("Label_zhekou",true)
        local zhekou = 0
        if discount % 100 == 0 then
            zhekou = tostring(math.ceil(discount / 100))
        else
            zhekou = string.format("%2.1f",discount/100)
        end
        local label = self:getLabelByName("Label_zhekou")
        if tonumber(zhekou) == 0 then
            --运营配错了
            self:_init()
        else
            label:setText(G_lang:get("LANG_ACTIVITY_ITEM_DISCOUNT",{num=zhekou}))
        end
        
        price = math.ceil(price * discount / 1000)
    else
        self:showWidgetByName("ImageView_tuijian",false)
        self:showWidgetByName("Label_zhekou",false)
    end
    self._priceLabel:setText(price)
    self._buycountLabel:setColor(Colors.lightColors.TIPS_01)
--购买次数
    local vipKey = string.format("vip%s_num",G_Me.userData.vip)
    local info = shop_score_info.get(item.id)
    local maxNum = info and info[vipKey] or 0
    if maxNum ==0 then
        self._buycountLabel:setVisible(false)
    else
        self._buycountLabel:setVisible(true)
        local itemNum = G_Me.shopData:getScorePurchaseNumById(item.id)

        -- self._buycountLabel:setText(string.format("还可购买:%d次",maxNum - itemNum))
        if maxNum-itemNum == 0 then
            self._buycountLabel:setText(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
        else
            self._buycountLabel:setText(G_lang:get("LANG_PURCHASE_AVAILABLE_NUM",{num=(maxNum-itemNum)}))
        end
    end
    self._itemImage:loadTexture(G_Goods.convert(item.type, item.value).icon,UI_TEX_TYPE_LOCAL);
    

    --判断是否是限时的道具
    if item.sell_open_time > 0 and item.sell_close_time > 0 and item.sell_close_time > item.sell_open_time then
        self:showWidgetByName("Label_endTime",true)
        self:getImageViewByName("ImageView_tuijian"):loadTexture(G_Path.getTextPath("sc_xianshi.png"))
        self:showWidgetByName("ImageView_tuijian",true)
        local timeFormat = G_ServerTime:getEndSellDateFormat(item.sell_close_time)
        self:showTextWithLabel("Label_endTime", timeFormat)
    else
        self:showWidgetByName("Label_endTime",false)
        -- self:showWidgetByName("ImageView_tuijian",false)
    end

end

return ShopPropItem
 
