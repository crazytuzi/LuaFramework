local ShopScoreItem = class("ShopScoreItem",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopScoreItem.json")
end)
require("app.const.ShopType")
require("app.cfg.shop_score_info")
require("app.cfg.corps_market_info")

local Colors = require("app.setting.Colors")



function ShopScoreItem:ctor(_type)
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
    self._priceItemLabel = self:getLabelByName("Label_priceItem")


    self._nameLabel:createStroke(Colors.strokeBrown,1)
	self._numLabel:createStroke(Colors.strokeBrown,1)
    -- self._priceLabel:createStroke(Colors.strokeBrown,1)
    -- self._priceTagLabel:createStroke(Colors.strokeBrown,1)

    self._goods = nil
    self._extraGood = nil

    self:registerBtnClickEvent("Button_exchange",function() 
        if self._exchangeFunc ~= nil then
            self._exchangeFunc() 
        end
        --用于新手引导
        self:setClickCell()
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

function ShopScoreItem:_init()
    self._nameLabel:setText("")
    self._priceLabel:setText("")
    self._exchangeNumLabel:setText("")
    self._numLabel:setText("")
    self:showWidgetByName("Panel_own",false)
    self:showWidgetByName("Panel_16",false)
end

function ShopScoreItem:_initWithGood(goods)
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
    self._numLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(goods.size))
    self._numLabel:setVisible(goods.size > 1)
    self._itemImage:loadTexture(goods.icon,UI_TEX_TYPE_LOCAL)
    self._qualityButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality,goods.type))
    self._qualityButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality,goods.type))
end

--额外其他的消耗类型
function ShopScoreItem:_initExtraItem( item )

    --判断消耗type value size的所需

    for i=2, 3 do

    	self:showWidgetByName("Panel_priceItem_"..i,false)
   
    	if item["extra_type"..i] and item["extra_type"..i] > 0 then
	        local _extraGood = G_Goods.convert(item["extra_type"..i],item["extra_value"..i],item["extra_size"..i])
	        if _extraGood then
	            self:showWidgetByName("Panel_priceItem_"..i,true)
	            local ownNum = G_Me.bagData:getNumByTypeAndValue(_extraGood.type, _extraGood.value)
	            local _priceItemImage = self:getImageViewByName("Image_priceItem"..i)
    			local _priceItemLabel = self:getLabelByName("Label_priceItem"..i)
	            
	            if _extraGood.icon_mini then
                    _priceItemImage:setVisible(true)
                    _priceItemImage:loadTexture(_extraGood.icon_mini,_extraGood.texture_type)
                    _priceItemLabel:setText(_extraGood.size)
	            else
	                _priceItemImage:setVisible(false)
	                _priceItemLabel:setText("")
	            end
	            
	            --如果不足颜色显示红色
	            _priceItemLabel:setColor(ownNum < _extraGood.size and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)
	        end
	    end
    end

end


function ShopScoreItem:_initWithItem(item)
    local price = G_Me.shopData:getPrice(item)
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id)   --折扣信息
    if isDiscount then
        price = math.ceil(price * discount / 1000)
    end

    self._priceLabel:setText(price)
    if item.price_type <= 0 then
        self:showWidgetByName("Panel_priceItem",false)
    end

    local path,texture_type = G_Path.getPriceTypeIcon(item.price_type)
    if path then
        self:getImageViewByName("Image_priceTag"):loadTexture(path,texture_type)
    end

    --判断消耗type value size的所需
    if item.extra_type > 0 then
        self._extraGood = G_Goods.convert(item.extra_type,item.extra_value,item.extra_size)
        if self._extraGood then
            --靠价格为0，得往前挪动,太变态了
            local ownNum = G_Me.bagData:getNumByTypeAndValue(self._extraGood.type,self._extraGood.value)
            if item.price_type > 0 then    
                self:showWidgetByName("Panel_priceItem",true)
                if self._extraGood.icon_mini then
                    self._priceItemImage:setVisible(true)
                    self._priceItemImage:loadTexture(self._extraGood.icon_mini,self._extraGood.texture_type)
                    self._priceItemLabel:setText(self._extraGood.size)
                else
                    self._priceItemImage:setVisible(false)
                    self._priceItemLabel:setText("")
                end
                --如果不足颜色显示红色
                self._priceItemLabel:setColor(ownNum < self._extraGood.size and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)
            else
                self:getImageViewByName("Image_priceTag"):loadTexture(self._extraGood.icon_mini,self._extraGood.texture_type)
                self._priceLabel:setText(self._extraGood.size)
                self._priceLabel:setColor(ownNum < self._extraGood.size and Colors.lightColors.TIPS_01 or Colors.lightColors.DESCRIPTION)
            end
        else
            self:showWidgetByName("Panel_priceItem",false)
        end
    else
        self:showWidgetByName("Panel_priceItem",false)
    end

    self:_initExtraItem(item)

end


function ShopScoreItem:updateCell(item)
	if item == nil then
		self:_init()
        self._goods = nil
		return
	end
    local goods = G_Goods.convert(item.type,item.value,item.size)
    self._goods = goods
    if not goods then
        self:_init()
        return
    end
    self:_initWithGood(goods)
    self:_initWithItem(item)
    
    --先判断购买限制是否达到
    local buyEnabled,tips = G_Me.shopData:checkScoreBuyBanType(item.id)
    if not buyEnabled then
        self._buyButton:setTouchEnabled(false)
        self._exchangeNumLabel:setVisible(true)
        self._exchangeNumLabel:setText(tips)
    else
        if item.num_ban_type == 0 then
            --无购买次数限制
            self._buyButton:setTouchEnabled(true)
            self._exchangeNumLabel:setVisible(false)
        else   --有购买次数限制
            self._exchangeNumLabel:setVisible(true)
            local key = string.format("vip%s_num",G_Me.userData.vip)
            local maxNum = item[key]
            local itemNum = G_Me.shopData:getScorePurchaseNumById(item.id)
            --判断是终身限制还是每日限制
            if item.num_ban_type == 1 then
                --终身限制
                if maxNum-itemNum == 0 then
                    -- self._exchangeNumLabel:setText(G_lang:get("此生无缘再买了"))
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_LIFE_REACHED_MAXINUM"))
                    self._buyButton:setTouchEnabled(false)
                else
                    local leftTimes = maxNum - itemNum
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_LIFE_AVAILABLE_NUM",{num=leftTimes}))
                    -- self._exchangeNumLabel:setText("终身限制" .. (maxNum-itemNum) .. "次")
                    self._buyButton:setTouchEnabled(true)
                end
            elseif item.num_ban_type == 2 then
                --每日限制
                if maxNum-itemNum == 0 then
                    self._buyButton:setTouchEnabled(false)
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
                else
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_AVAILABLE_NUM",{num=(maxNum-itemNum)}))
                    self._buyButton:setTouchEnabled(true)
                end
            elseif item.num_ban_type == 3 then
                -- 每周限制
                if maxNum-itemNum == 0 then
                    self._buyButton:setTouchEnabled(false)
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
                else
                    self._exchangeNumLabel:setText(G_lang:get("LANG_PURCHASE_AVAILABLE_NUM_WEEK",{num=(maxNum-itemNum)}))
                    self._buyButton:setTouchEnabled(true)
                end
            end

        end
    end 

    
    if item.discount > 0 then
        local imgMark = self:getImageViewByName("Image_Mark")
        if imgMark then
            -- imgMark:loadTexture(self:getDiscountImagePath(item.discount))
            imgMark:loadTexture(G_Path.getDiscountImage(item.discount))
        end
        self:showWidgetByName("Image_Mark", true)
    else
        self:showWidgetByName("Image_Mark", false)
    end

    -- 需要、急需角标
    if goods.type == G_Goods.TYPE_HERO_SOUL then
        if G_Me.heroSoulData:isSoulNeeded(goods.value) then
            self:showWidgetByName("Image_NeedMark", true)
            local imgNeedMark = self:getImageViewByName("Image_NeedMark")
            if G_Me.heroSoulData:isSoulBadlyNeeded(goods.value) then
                imgNeedMark:loadTexture("ui/text/txt/jixu.png", UI_TEX_TYPE_LOCAL)
            else
                imgNeedMark:loadTexture("ui/text/txt/jzcb_xuyao.png", UI_TEX_TYPE_LOCAL)
            end
        else
            self:showWidgetByName("Image_NeedMark", false)
        end
    else
        self:showWidgetByName("Image_NeedMark", false)
    end
end



function ShopScoreItem:setExchangeFunc(func)
    self._exchangeFunc = func
end

function ShopScoreItem:setItemInfoFunc(func)
    self._itemInfo = func
end

function ShopScoreItem:getDiscountImagePath(szName)
    local szPath = "ui/text/txt/" .. szName .. ".png"
    return szPath
end

return ShopScoreItem

