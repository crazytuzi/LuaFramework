local ShopScoreJunTuanItem = class("ShopScoreJunTuanItem",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopScoreJunTuanItem.json")
end)
require("app.const.ShopType")
require("app.cfg.shop_score_info")
require("app.cfg.corps_market_info")

local Colors = require("app.setting.Colors")

function ShopScoreJunTuanItem:ctor(_type)
    self._type = _type
    self._exchangeFunc = nil
    self._itemInfo = nil
	self._nameLabel = self:getLabelByName("Label_name")
	self._priceLabel = self:getLabelByName("Label_price")
	self._exchangeNumLabel = self:getLabelByName("Label_exchangeNum")
	self._itemImage = self:getImageViewByName("ImageView_item")
	self._numLabel = self:getLabelByName("Label_num")  --数量
	self._qualityButton = self:getButtonByName("Button_quality")
    self._buyButton = self:getButtonByName("Button_exchange")
    self._itemBg = self:getImageViewByName("ImageView_item_bg")

	--消耗的type_value_size
    self._priceItemImage = self:getImageViewByName("Image_priceItem")
    self._priceItemImageBg = self:getImageViewByName("Image_priceItemBg")
    self._priceButton = self:getButtonByName("Button_priceItem")
    self._priceItemLabel = self:getLabelByName("Label_priceItem")
    self._discountLabel = self:getLabelByName("Label_discount")

    self._nameLabel:createStroke(Colors.strokeBrown,1)
	self._numLabel:createStroke(Colors.strokeBrown,1)
    self._discountLabel:createStroke(Colors.strokeBrown,1)
    -- self._priceLabel:createStroke(Colors.strokeBrown,1)
    -- self._priceTagLabel:createStroke(Colors.strokeBrown,1)

    self._goods = nil
    self._extraGood = nil

    self:registerBtnClickEvent("Button_exchange",function() 
        self:_initEvent()
        end)
    self:registerBtnClickEvent("Button_quality",function() 
        if not self._goods then
            return
        end
        require("app.scenes.common.dropinfo.DropInfo").show(self._goods.type, self._goods.value,
                GlobalFunc.sceneToPack("app.scenes.shop.score.ShopScoreScene", {self._type})) 
        end)
    -- self:registerBtnClickEvent("Button_priceItem",function()
    --     if not self._extraGood then
    --         return
    --     end
    --     require("app.scenes.common.dropinfo.DropInfo").show(self._extraGood.type, self._extraGood.value,
    --             GlobalFunc.sceneToPack("app.scenes.shop.score.ShopScoreScene", {self._type})) 
    --     end)
    self:attachImageTextForBtn("Button_exchange","ImageView_buy")
end

function ShopScoreJunTuanItem:updateJunTuanItem(item)
    self._item = item
    local info = nil
    if item == nil then
        self:_init()
        self._goods = nil
        return
    else
        info = corps_market_info.get(item.id)
        if not info then
            self:_init()
            self._goods = nil
            return
        end
    end
    local goods = G_Goods.convert(info.item_type,info.item_id,info.item_num)
    self._goods = goods
    if not goods then
        self:_init()
        return
    end
    self:_initWithGood(goods)
    self:_initWithItem(info)
    self._priceLabel:setText(info.price)
    if item.num > 0 then
        self:getLabelByName("Label_juntuanshengyu"):setText(G_lang:get("LANG_JUN_TUAN_PURCHASE_LIFE_AVAILABLE_NUM",{num=item.num}))
        self._buyButton:setTouchEnabled(true)
    else
        self._buyButton:setTouchEnabled(false)
        self:getLabelByName("Label_juntuanshengyu"):setText(G_lang:get("LANG_JUN_TUAN_PURCHASE_LIFE_AVAILABLE_NUM",{num=0}))
    end

    --是否已购买
    if item.bought then
        self._buyButton:setTouchEnabled(false)
        self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
    else
        self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_LIFE_AVAILABLE_NUM",{num=1}))
        self._buyButton:setTouchEnabled(true)
    end

end

function ShopScoreJunTuanItem:_init()
    self._nameLabel:setText("")
    self._priceLabel:setText("")
    self._exchangeNumLabel:setText("")
    self._numLabel:setText("")
    self:showWidgetByName("Panel_own",false)
    self:showWidgetByName("Panel_16",false)
end

function ShopScoreJunTuanItem:_initWithGood(goods)
    if goods.type == G_Goods.TYPE_FRAGMENT then
        --武将或装备碎片
        self:showWidgetByName("Panel_own",true)
        local ownNum = G_Me.bagData:getFragmentNumById(goods.value)
        local info = fragment_info.get(goods.value)
        if info then
            self:getLabelByName("Label_ownnum"):setText(string.format("(%d/%d)",ownNum,info.max_num))
        else
            --表错误不显示了
            self:showWidgetByName("Panel_own",false)
        end
    else
        self:showWidgetByName("Panel_own",false)
    end
    self._nameLabel:setColor(Colors.qualityColors[goods.quality])
    self._nameLabel:setText(goods.name)
    self._itemBg:loadTexture(G_Path.getEquipIconBack(goods.quality))
    self._numLabel:setText("x" .. goods.size)
    self._numLabel:setVisible(goods.size > 1)
    self._itemImage:loadTexture(goods.icon,UI_TEX_TYPE_LOCAL)

    self._qualityButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality,goods.type))
    self._qualityButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality,goods.type))
end

function ShopScoreJunTuanItem:_initWithItem(item)
    local path,texture_type = G_Path.getPriceTypeIcon(item.price_type)
    if path then
        self:getImageViewByName("Image_priceTag"):loadTexture(path,texture_type)
        self:showWidgetByName("Image_priceTag",true)
        self:showWidgetByName("Label_price",true)
    else
        self:showWidgetByName("Image_priceTag",false)
        self:showWidgetByName("Label_price",false)
    end

    --判断消耗type value size的所需
    if item.extra_type > 0 then
        self._extraGood = G_Goods.convert(item.extra_type,item.extra_value,item.extra_size)
        if self._extraGood then
            self:showWidgetByName("Panel_priceItem",true)
            if self._extraGood.icon_mini then
                self._priceItemImage:loadTexture(self._extraGood.icon_mini,self._extraGood.texture_type)
                self._priceItemLabel:setText(self._extraGood.size)
            else
                --配错了
                self:showWidgetByName("Panel_priceItem",false)
            end

            --如果不足颜色显示红色
            local ownNum = G_Me.bagData:getNumByTypeAndValue(self._extraGood.type,self._extraGood.value)
            if ownNum < self._extraGood.size then
                --不足
                self._priceItemLabel:setColor(Colors.lightColors.TIPS_01)
            else
                self._priceItemLabel:setColor(Colors.lightColors.DESCRIPTION)
            end

        else
            self:showWidgetByName("Panel_priceItem",false)
        end
    else
        self:showWidgetByName("Panel_priceItem",false)
    end
    --判断price_type是否足


    -- 加一个原价

    if item.original_price ~= nil and item.original_price > 0 then
        self:showWidgetByName("Panel_Orig", true)
        local labelOrigPrice = self:getLabelByName("Label_OrigPriceValue")
        if labelOrigPrice then
            local nOrigPrice = item.original_price
            labelOrigPrice:setText(nOrigPrice)
            local labelOrigPriceLine = self:getLabelByName("Label_OrigPriceLine")
            if labelOrigPriceLine then
                local tSize = labelOrigPrice:getSize()
                local nRate = (tSize.width + 20) / 12
                labelOrigPriceLine:setScaleX(nRate)
                labelOrigPriceLine:setPositionX(labelOrigPriceLine:getPositionX() - 13)
            end
        end
    else
        self:showWidgetByName("Panel_Orig", false)
    end
    
    if item.discount and item.discount > 0 then
        self._discountLabel:setVisible(true)
        self._discountLabel:setText((item.discount/10)..G_lang:get("LANG_GROUP_BUY_AWARD_OFF"))
        self._discountLabel:setColor(item.discount>=70 and Colors.qualityColors[3] or Colors.qualityColors[7])
    else
        self._discountLabel:setVisible(false)
    end
    
end


function ShopScoreJunTuanItem:setExchangeFunc(func)
    self._exchangeFunc = func
end

function ShopScoreJunTuanItem:setItemInfoFunc(func)
    self._itemInfo = func
end


function ShopScoreJunTuanItem:_initEvent()
    if not self._item or not self._goods then 
        return 
    end
    if self._item.num <= 0 then   --可购买次数为0
        G_MovingTip:showMovingTip(G_lang:get("LANG_JUNTUAN_LEFT_ZERO"))
        return
    end
    if self._item.bought then   --已购买
        G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_SELL_BUY_ALREADY"))
        return
    end
    local info = corps_market_info.get(self._item.id)
    if not info then
        return
    end
    if info.price > G_Me.userData.gold then   --元宝不足
        -- G_MovingTip:showMovingTip(G_lang:get("LANG_JUN_TUAN_GONGXIAN_NOT_ENOUGH"))
        require("app.scenes.shop.GoldNotEnoughDialog").show()
        return
    end
    --判断道具数量是否足
    if info.extra_type > 0 then
        local ownNum = G_Me.bagData:getNumByTypeAndValue(info.extra_type,info.extra_value)
        if ownNum < info.extra_size then
            local good = G_Goods.convert(info.extra_type,info.extra_value,info.extra_size)
            --需要消耗的道具数量不足
            if good then
                G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT",{item_name=good.name}))
            end
            return
        end
    end

    -- G_HandlersManager.shopHandler:sendCorpSpecialShopping(self._item.id)
    require("app.scenes.shop.score.ShopJuntuanDialog").show(self._item.id)
end

return ShopScoreJunTuanItem

