local PurchasePowerDialog = class("PurchasePowerDialog",UFCCSModelLayer)
require("app.cfg.item_info")
require("app.cfg.shop_score_info")
require("app.const.ShopType")
require("app.cfg.shop_price_info")
require("app.cfg.basic_figure_info")
local ShopVipConst = require("app.const.ShopVipConst")
--注意添加json文件

--[[
  在shop_score_info中的ID
	_type = 1 体力
	_type = 2 精力
    _type = 23 出征令
    _type = 7 免战牌大
    _type = 8 免战牌小
]]

--[[在shop_score_info中的Id]]

function PurchasePowerDialog.create(_itemId)
    local layer = PurchasePowerDialog.new("ui_layout/shop_PurchasePowerDialog.json",Colors.modelColor,_itemId)
    layer:adapterLayer()
    return layer
end

--适配写在这里
function PurchasePowerDialog:adapterLayer()
    self:adapterWidgetHeight("","","",0,0)
end

function PurchasePowerDialog:ctor(json,color,_itemId,...)
    self.super.ctor(self,...)
    
    --检查是否进入过VIP商城
    if not G_Me.shopData:checkEnterScoreShop() then
    	G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
    end 
    
    
    self._item = nil 
	self._item = shop_score_info.get(_itemId)
    if self._item == nil then
    	__LogTag(TAG,"表里无此道具")
    	return
    end 
    
    self:_initWidgets()
    self:_createStroke()
    self:_initBtnEvent()
    self:showAtCenter(true)
end



function PurchasePowerDialog:_getUseItemMsg(data)
    if data.ret == 1 then
        __LogTag(TAG,"data.id = %d",data.id)
        local itemInfo = item_info.get(self._item.value)

        if itemInfo ~= nil then
            G_MovingTip:showMovingTip(itemInfo.tips)
        end
        self:_initOwnNum()
    end
end

function PurchasePowerDialog:_getBuyItemMsg(data)
    if data.ret == 1 then
        self:_refreshBuyNum()
        self:_initOwnNum()
        self:_initPrice()
        G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
    end 
end

function PurchasePowerDialog:_getShopInfo(data)
    self:_refreshBuyNum()
    self:_initOwnNum()
    self:_initPrice()
end


function PurchasePowerDialog:_initOwnNum()
    local item = G_Me.bagData.propList:getItemByKey(self._item.value)
    local ownNum = 0
    if item ~= nil then
        ownNum = G_Me.bagData.propList:getItemByKey(self._item.value)["num"]
    end
    __LogTag(TAG,"ownNum = %s",ownNum)
    self._ownNumLabel:setText(ownNum)

    local unitsLabel = self:getLabelByName("Label_numTag")
    local size = self._ownNumLabel:getContentSize()
    unitsLabel:setPosition(ccp(size.width+self._ownNumLabel:getPositionX(),self._ownNumLabel:getPositionY()))
end 

--获取价格
function PurchasePowerDialog:_getPrice()
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(self._item.id) 
    local price = G_Me.shopData:getPrice(self._item)
    return isDiscount and math.ceil(price * discount/1000) or price
end
--初始化价格
function PurchasePowerDialog:_initPrice()
    local price = self:_getPrice()
    self._priceLabel:setText(price)
end


function PurchasePowerDialog:_getMaxBuyNum()
    local vipNum = string.format("vip%s_num",G_Me.userData.vip)
    local maxPurchaseNum = self._item[vipNum]
    return maxPurchaseNum
end 

function PurchasePowerDialog:_initWidgets()
    self._tipsLabel = self:getLabelByName("Label_tips")
    self._itemImage = self:getImageViewByName("ImageView_item")
    self._itemValueLabel = self:getLabelByName("Label_itemValue")
    -- self._priceLabel = self:getLabelBMFontByName("LabelBMFont_price")
    self._priceLabel = self:getLabelByName("Label_price")
    
    --购买次数
    self._buyNumLabel = self:getLabelByName("Label_buyNum")
    self._ownNumLabel = self:getLabelByName("Label_ownNum")
    
    local item = item_info.get(self._item.value)
    if self._item.id == ShopVipConst.TI_LI_DAN then
        self._tipsLabel:setText(G_lang:get("LANG_PURCHASE_POWER_TILI_TIPS"))
    elseif self._item.id == ShopVipConst.JING_LI_DAN then
        self._tipsLabel:setText(G_lang:get("LANG_PURCHASE_POWER_JINGLI_TIPS"))
    elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_DA then
        self._tipsLabel:setText(G_lang:get("LANG_PURCHASE_POWER_MIANZHAN_TIPS"))
    elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_XIAO then
        self._tipsLabel:setText(G_lang:get("LANG_PURCHASE_POWER_MIANZHAN_TIPS"))
    else 
        self._tipsLabel:setText(G_lang:get("LANG_PURCHASE_POWER_CHUZHENGLING_TIPS"))
    end 
    self._itemImage:loadTexture(G_Path.getItemIcon(item.res_id),UI_TEX_TYPE_LOCAL)
    self:getButtonByName("Button_quality"):loadTextureNormal(G_Path.getEquipColorImage(item.quality,G_Goods.TYPE_ITEM))
    self:getButtonByName("Button_quality"):loadTexturePressed(G_Path.getEquipColorImage(item.quality,G_Goods.TYPE_ITEM))
    self:getImageViewByName("ImageView_item_bg"):loadTexture(G_Path.getEquipIconBack(item.quality))

    if self._item.id == ShopVipConst.TI_LI_DAN then
        self._itemValueLabel:setText(G_lang:get("LANG_PURCHASE_ADD_TILI",{num=item.item_value}))
    elseif self._item.id == ShopVipConst.JING_LI_DAN then
        self._itemValueLabel:setText(G_lang:get("LANG_PURCHASE_ADD_JINGLI",{num=item.item_value}))
    elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_DA then
        self._itemValueLabel:setText(G_lang:get("LANG_PURCHASE_ADD_MIANZHAN",{hour=math.floor(item.item_value/3600)}))
    elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_XIAO then
        self._itemValueLabel:setText(G_lang:get("LANG_PURCHASE_ADD_MIANZHAN",{hour=math.floor(item.item_value/3600)}))
    else 
        self._itemValueLabel:setText(G_lang:get("LANG_PURCHASE_ADD_CHUZHENGLING",{num=item.item_value}))
    end 
    --还可购买次数
    self:_refreshBuyNum()
    
    --初始化当前拥有的数量
    self:_initOwnNum()
    --初始化价格
    self:_initPrice()
end


--还可购买次数
function PurchasePowerDialog:_refreshBuyNum()
    local maxNum = self:_getMaxBuyNum()
    if maxNum == 0 then
        --0表示无限购买
        self:showWidgetByName("Panel_buy",false)
    else 
        local hasBuyNum = G_Me.shopData:getScorePurchaseNumById(self._item.id)
        --还可购买次数
        self._buyNumLabel:setText(maxNum-hasBuyNum)
    end 
end

function PurchasePowerDialog:_createStroke()
    self._buyNumLabel:createStroke(Colors.strokeBrown,1)
    self._ownNumLabel:createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_ownTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_numTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_buyTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_buyNumTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_timeTag"):createStroke(Colors.strokeBrown,1)
    self:enableLabelStroke("Label_price", Colors.strokeBrown,1)
end

function PurchasePowerDialog:_initBtnEvent()
    self:registerBtnClickEvent("Button_close",function() 
    	self:animationToClose()
    end)
    --使用
    self:registerBtnClickEvent("Button_use",function() 
        local item = G_Me.bagData.propList:getItemByKey(self._item.value)
        if item == nil then
            G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_ITEM_NOT_ENOUGH",{name=self._item.name}))
            return
        end
        
        local ownNum = item["num"]
        if ownNum == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_ITEM_NOT_ENOUGH",{name=self._item.name}))
            return
        end

        local _localItem = item_info.get(self._item.value)        
        if self._item.id == ShopVipConst.JING_LI_DAN then                     --精力丹
            local max_limit = basic_figure_info.get(2).max_limit
            if G_Me.userData.spirit+_localItem.item_value > max_limit then
                --预判精力是否超出上限了
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SPIRIT_IS_FULL"))
                return
            end         
            self:removeFromParent()
            local itemInfo = item_info.get(self._item.value)   
            require("app.scenes.bag.BagUseItemMultiTimesLayer").show(false, ownNum, itemInfo, G_Me.userData.spirit, max_limit)
            -- G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value, 1)
        elseif self._item.id == ShopVipConst.TI_LI_DAN then
            --体力丹
            local max_limit = basic_figure_info.get(1).max_limit
            if G_Me.userData.vit+_localItem.item_value > max_limit then
                --预判精力是否超出上限了
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_VIT_IS_FULL"))
                return
            end  
            self:removeFromParent()
            local itemInfo = item_info.get(self._item.value)
            require("app.scenes.bag.BagUseItemMultiTimesLayer").show(false, ownNum, itemInfo, G_Me.userData.vit, max_limit)
            -- G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value, 1)
        elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_DA then
            local leftTime = G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time)
            if leftTime > 0 then
                --处于免战状态
                local _format = G_ServerTime:getLeftSecondsString(G_Me.userData.forbid_battle_time)
                MessageBoxEx.showYesNoMessage(nil,G_lang:get("LANG_MIANZHAN_ZHONG",{time=_format}),false,function()
                    G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value)
                end,nil,self)
                return
            end
            G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value)
        elseif self._item.id == ShopVipConst.MIAN_ZHAN_PAI_XIAO then
            local leftTime = G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time)
            if leftTime > 0 then
                --处于免战状态
                local _format = G_ServerTime:getLeftSecondsString(G_Me.userData.forbid_battle_time)
                MessageBoxEx.showYesNoMessage(nil,G_lang:get("LANG_MIANZHAN_ZHONG",{time=_format}),false,function()
                    G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value)
                end,nil,self)
                return
            end
            G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value)
        else
            --出征令
            local max_limit = basic_figure_info.get(3).max_limit
            if G_Me.userData.battle_token+_localItem.item_value > max_limit then
                --预判出征令是否超出上限了
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_CHUZHENGLING_IS_FULL"))
                return
            end  
            self:removeFromParent()
            local itemInfo = item_info.get(self._item.value)
            require("app.scenes.bag.BagUseItemMultiTimesLayer").show(false, ownNum, itemInfo, G_Me.userData.battle_token, max_limit)
            -- G_HandlersManager.bagHandler:sendUseItemInfo(self._item.value)
        end
    end)
    --购买
    self:registerBtnClickEvent("Button_buy",function() 
        -- local price = self:get
        if G_Me.userData.gold < self:_getPrice() then
            require("app.scenes.shop.GoldNotEnoughDialog").show(nil,3)
            return
        end 
        
        if G_Me.shopData:checkScoreMaxPurchaseNumber(self._item.id) == true then
            G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
            return
        end

        G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_SCORE,self._item.id,1)
    end)
    self:registerBtnClickEvent("Button_quality",function()
        require("app.scenes.common.dropinfo.DropInfo").show(self._item.type,self._item.value) 
        end)
end

function PurchasePowerDialog:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._getBuyItemMsg, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._getUseItemMsg, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, self._getShopInfo, self) 
end

function PurchasePowerDialog:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end
return PurchasePowerDialog

