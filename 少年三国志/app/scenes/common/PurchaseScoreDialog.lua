local PurchaseScoreDialog = class("PurchaseScoreDialog",UFCCSModelLayer)
require("app.cfg.shop_score_info")
require("app.const.ShopType")

function PurchaseScoreDialog.show(item_id)
    local purchasedNum = G_Me.shopData:getScorePurchaseNumById(item_id)
    local key = string.format("vip%s_num",G_Me.userData.vip)
    local item = shop_score_info.get(item_id)
    if item == nil then
        G_MovingTip:showMovingTip(G_lang:get("LANG_NO_THIS_ITEM"))
        return
    end
    local maxPurchaseNum = item[key]
    if maxPurchaseNum ~= 0 and maxPurchaseNum <= purchasedNum then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
        return
    end
    local layer =  PurchaseScoreDialog.create(item_id)
    uf_sceneManager:getCurScene():addChild(layer)
end


--[[
    item_id: 道具id,参考shop_vip_info
    mode:商店类型,参考
]]
function PurchaseScoreDialog.create(item_id)
    local layer = PurchaseScoreDialog.new("ui_layout/shop_PurchaseDialog.json",require("app.setting.Colors").modelColor,item_id)
    --    layer:adapterLayer()
    return layer
end

--适配写在这里
function PurchaseScoreDialog:adapterLayer()
    self:adapterWidgetHeight("","","",0,0)
end


function PurchaseScoreDialog:ctor(json,color,item_id)
    self._isAddingNum = true
    self._curTimeCost = 0
    --默认买一个
    self._buyCount = 1
    self.super.ctor(self,json)
    --隶属于商店类型
    self._item = shop_score_info.get(item_id)
    --货币类型
    self._priceType = self._item.price_type
    local num_ban_type = self._item["num_ban_type"]
    --获取最大购买数量
    local key = string.format("vip%s_num",G_Me.userData.vip)
    local maxPurchaseNum = self._item[key]
    local purchasedNum = G_Me.shopData:getScorePurchaseNumById(item_id)
    --最大可购买数
    self._PurchasabilityNum = maxPurchaseNum == 0 and 999 or (maxPurchaseNum - purchasedNum)
    --增加了兑换类型，所以再比较
    if self._item.extra_type > 0 then
        local ownNum = G_Me.bagData:getNumByTypeAndValue(self._item.extra_type,self._item.extra_value)
        local buyNum = math.floor(ownNum/self._item.extra_size)
        --取较小的那个
        self._PurchasabilityNum = self._PurchasabilityNum < buyNum and self._PurchasabilityNum or buyNum
    end

    self._PurchasabilityNum = (self._PurchasabilityNum > 999) and 999 or self._PurchasabilityNum
    --还可购买次数
    local buyCountLabel = self:getLabelByName("Label_buyCount")
    if num_ban_type == 0 then
        local parent = self:getWidgetByName("Panel_itemBg")
        local panel = self:getWidgetByName("Panel_tagJinZi")
        local x,y = panel:getPosition()
        panel:setPosition(ccp(parent:getContentSize().width/2-panel:getContentSize().width/2, y))

        self:showWidgetByName("Label_buyCount",false)
        self:getLabelByName("Label_price"):setText(self:_getPrice(1))
    else
        --终身购买次数
        if self._item["num_ban_type"] == 1 then
            buyCountLabel:setText(G_lang:get("LANG_PURCHASE_LIFE_AVAILABLE_NUM",{num=(maxPurchaseNum-purchasedNum)}))
        else
            --每日购买次数
            if self._item["num_ban_type"] == 2 and maxPurchaseNum >= 20000000 then
                buyCountLabel:setText("")
            else 
                buyCountLabel:setText( G_lang:get("LANG_PURCHASE_AVAILABLE_NUM",{num=(maxPurchaseNum-purchasedNum)}))

            end
        end
        self:getLabelByName("Label_price"):setText(self:_getPrice(1))

    end
    
    self:_initWidgets()
    self:_createStrokes()
    self:_initBtnEvent()
    self:showAtCenter(true)
end

function PurchaseScoreDialog:_createStrokes()
    -- self:enableLabelStroke("Label_price", Colors.strokeBrown,1)
    -- self:enableLabelStroke("Label_priceTag_0", Colors.strokeBrown,1)
    -- self:enableLabelStroke("Label_price_0", Colors.strokeBrown,1)
    -- self:enableLabelStroke("Label_priceTag", Colors.strokeBrown,1)
    -- self:enableLabelStroke("Label_num", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_name01", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_item_num", Colors.strokeBrown,1)

    -- self:enableLabelStroke("Label_buyCount", Colors.strokeBrown,1)
end

function PurchaseScoreDialog:_initWidgets()
    self:showWidgetByName("Label_buyTips",self._item.price_add_id > 0)
    self:showTextWithLabel("Label_buyTips",G_lang:get("LANG_SHOP_PRICE_ADD_TIPS"))
    local nameLabel = self:getLabelByName("Label_name01")
    local itemButton = self:getButtonByName("Button_item")

    nameLabel:setText(self._item.name)
    local goods = G_Goods.convert(self._item.type, self._item.value, self._item.size)
    nameLabel:setColor(Colors.qualityColors[goods.quality])
    self:getImageViewByName("ImageView_item_bg01"):loadTexture(G_Path.getEquipIconBack(goods.quality))
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality,self._item.type))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality,self._item.type))
    self:getLabelByName("Label_item_num"):setText(goods.size > 1 and "x" .. goods.size or "")
    --[[
        因为使用PurchaseScoreDialog的布局....所以做些特殊处理
    ]]

    local priceTagImage = self:getImageViewByName("ImageView_priceTag")

    local path,texture_type = G_Path.getPriceTypeIcon(self._item.price_type) 
    if path then
        priceTagImage:loadTexture(path,texture_type)
    end
    self:getImageViewByName("ImageView_item"):loadTexture(goods.icon,UI_TEX_TYPE_LOCAL)

    if self._item.price_type > 0 then
        --有其他消耗物品
        if self._item.extra_type > 0 then
            local extraGood = G_Goods.convert(self._item.extra_type,self._item.extra_value,self._item.extra_size)
            if not extraGood then
                --一般情况是不会执行，策划2了才会走到
                self:showWidgetByName("Panel_priceItem",false)
            else
                self:showWidgetByName("Panel_priceItem",true)
                self:getLabelByName("Label_priceItem"):setText(extraGood.size)
                if extraGood.icon_mini then
                    self:getImageViewByName("Image_priceItem"):loadTexture(extraGood.icon_mini,extraGood.texture_type)
                else
                    --一般情况是不会执行，策划2了才会走到
                    self:showWidgetByName("Image_priceItem",false)
                end
            end 
        else
            self:showWidgetByName("Panel_priceItem",false)
        end
    else
        self:showWidgetByName("Panel_priceItem",false)
        if self._item.extra_type > 0 then
            local extraGood = G_Goods.convert(self._item.extra_type,self._item.extra_value,self._item.extra_size)
            if not extraGood then
                --一般情况是不会执行，策划2了才会走到
                priceTagImage:setVisible(false)
                self:showWidgetByName("Label_price",false)
            else
                priceTagImage:setVisible(true)
                self:showWidgetByName("Label_price",true)
                if extraGood.icon_mini then
                    priceTagImage:loadTexture(extraGood.icon_mini,extraGood.texture_type)
                    self:showTextWithLabel("Label_price",extraGood.size)
                else
                    --一般情况是不会执行，策划2了才会走到
                    priceTagImage:setVisible(false)
                    self:showWidgetByName("Label_price",false)
                end
            end
        else
            self:showWidgetByName("Panel_priceItem",false)
        end
    end

    self:_setOwnNum()
end
function PurchaseScoreDialog:_setOwnNum()
    local ownNumLabel = self:getLabelByName("Label_num")
    local _num,name= G_Me.bagData:getNumByTypeAndValue(self._item.type,self._item.value)
    _num = G_GlobalFunc.ConvertNumToCharacter(_num)
    if not name then
        --name为空，使用默认单位"个"
        ownNumLabel:setText(G_lang:get("LANG_GOODS_NUM",{num=_num}))
    else
        ownNumLabel:setText(_num .. name)
    end


    -- local unitsLabel = self:getLabelByName("Label_units")
    -- local size = ownNumLabel:getContentSize()
    -- unitsLabel:setPosition(ccp(size.width+ownNumLabel:getPositionX()+2,unitsLabel:getPositionY()))
end

function PurchaseScoreDialog:_initBtnEvent()
    self:registerBtnClickEvent("Button_item",function()
        if self._item ~= nil then
            require("app.scenes.common.dropinfo.DropInfo").show(self._item.type,self._item.value)
        end
    end)
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    self:enableAudioEffectByName("Button_cancel", false)
    self:registerBtnClickEvent("Button_cancel",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    --购买
    self:registerBtnClickEvent("Button_buy",function()
        
        local CheckFunc = require("app.scenes.common.CheckFunc")
        local isFull = CheckFunc.checkDiffByType(self._item.type,self._buyCount)
        if isFull == true then
           
            return
        end

        --检查积分是否足够
        G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_SCORE,self._item.id,self._buyCount)
        self:animationToClose()
    end)
    -- 加 1
    self:registerBtnClickEvent("Button_add01",function()
        if self._PurchasabilityNum > 0 and self._buyCount == self._PurchasabilityNum then
            return
        end
        --预计总金额
        local price = self:getTotalPrice(self._buyCount + 1)
        --比较金钱数量
        if price > self:_getOwnScore() then
            return
        end
        
        self._buyCount = self._buyCount + 1
        self:setText()
    end)
    -- 加 10
    self:registerBtnClickEvent("Button_add10",function()
        self._isAddingNum = true
        self:_doCountChange() 
    end)
    -- 减 1
    self:registerBtnClickEvent("Button_subtract01",function()
        if self._buyCount == 1 then
            return
        end
        self._buyCount = self._buyCount -1
        self:setText()
    end)
    -- 减 10
    self:registerBtnClickEvent("Button_subtract10",function()
        if self._buyCount <= 10 then
            self._buyCount = 1
        else
            self._buyCount = self._buyCount -10
        end
        self:setText()
    end)
    -- 减 10
     self:registerBtnClickEvent("Button_subtract10",function()
        self._isAddingNum = false
        self:_doCountChange()    
     end)
     self:registerWidgetTouchEvent("Button_add10", function ( widget, typeValue )
         self._isAddingNum = true
         self:_onBtnTouch(widget, typeValue)
     end)
     self:registerWidgetTouchEvent("Button_subtract10", function ( widget, typeValue )
         self._isAddingNum = false
         self:_onBtnTouch(widget, typeValue)
     end)
end

--获取拥有的积分
function PurchaseScoreDialog:_getOwnScore()
    --居然price_type可以为0
    if self._item.price_type <= 0 then
        local extraGood = G_Goods.convert(self._item.extra_type,self._item.extra_value,self._item.extra_size)
        if not extraGood then
            return 0
        end
        local ownNum = G_Me.bagData:getNumByTypeAndValue(extraGood.type,extraGood.value)
        return ownNum
    end
    if self._item.price_type == 1 then  --银两
        return G_Me.userData.money
    elseif self._item.price_type == 2 then --元宝
        return G_Me.userData.gold
    elseif self._item.price_type == 3 then --竞技场积分
        return G_Me.userData.prestige
    elseif self._item.price_type == 4 then --魔神积分
        return G_Me.userData.medal
    elseif self._item.price_type == 5 then --闯关积分
        return G_Me.userData.tower_score
    elseif self._item.price_type == 6 then --武魂
        --暂时没有
        return G_Me.userData.essence
    elseif self._item.price_type == 7 then --体力
        return G_Me.userData.vit
    elseif self._item.price_type == 8 then --精力
        return G_Me.userData.spirit
    elseif self._item.price_type == 9 then -- 军团贡献
        return G_Me.userData.corp_point
    elseif self._item.price_type == 10 then --转盘积分
        return G_Me.wheelData.score
    elseif self._item.price_type == 12 then --演武勋章
        return G_Me.userData.contest_point
    elseif self._item.price_type == 13 then --演武勋章
        return G_Me.userData.invitor_score
    elseif self._item.price_type == 17 then --奇遇点
    	return G_Me.userData.qiyu_point
    else
    end
end




--获取价格
function PurchaseScoreDialog:_getPrice(times)
    local price = G_Me.shopData:getPrice(self._item,times)
    --判断是否有打折
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(self._item.id)   --折扣信息
    return isDiscount and math.ceil(price * discount / 1000) or price
end
function PurchaseScoreDialog:getTotalPrice(count)
    return G_Me.shopData:getTotalPrice(self._item,count)

    -- local price = 0
    -- if self._item.price_add_id == 0 then
    --     -- price = self._item.price * count
    --     --价格不变，所以getPrice碎片传入一个数字
    --     -- price = self:_getPrice(1)*count
    --     local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(self._item.id) 
    --     if isDiscount then
    --         return math.ceil(self._item.price * count * discount / 1000)
    --     else
    --         return self._item.price * count
    --     end
    -- else
    --     for i=1,count do
    --         price = price + self:_getPrice(i)
    --     end
    -- end
    -- return price
end

function PurchaseScoreDialog:setText()
    local label = self:getLabelByName("Label_count")
    if self._buyCount <=0 then
        self._buyCount = 1
    end
    label:setText(self._buyCount)
    local labelPrice = self:getLabelByName("Label_price")
    local price = self:getTotalPrice(self._buyCount)
    if self._item.price_type > 0 then
        labelPrice:setText(price)
        if self._item.extra_type > 0 then
            --有兑换物
            self:getLabelByName("Label_priceItem"):setText(self._item.extra_size * self._buyCount)
        end
    else
        labelPrice:setText(self._item.extra_size * self._buyCount)
    end
end


function PurchaseScoreDialog:_onBtnTouch( widget, typeValue )
    if TOUCH_EVENT_BEGAN == typeValue then 
        self:scheduleUpdate(handler(self, self._onUpdate), 0)
    elseif TOUCH_EVENT_MOVED == typeValue then 
        if not widget then 
            self:_stopSchedule()
        end
        local curPt = widget:getTouchMovePos()
        if not widget:hitTest(curPt) then 
            self:_stopSchedule()
        end
    elseif TOUCH_EVENT_ENDED == typeValue then 
        self:_stopSchedule()
    elseif TOUCH_EVENT_CANCELED == typeValue then 
        self:_stopSchedule()
    end
end

function PurchaseScoreDialog:_stopSchedule( ... )
    self:unscheduleUpdate()
    self._curTimeCost = 0
end

function PurchaseScoreDialog:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt
    
    if self._curTimeCost > 0.2 then 
        self._curTimeCost = self._curTimeCost - 0.2
        self:_doCountChange()
    end    
end

function PurchaseScoreDialog:_doCountChange( ... )
    if self._isAddingNum then 
        local tempCount = 0
        if self._PurchasabilityNum == 0 then
            if self._buyCount == 1 then
                tempCount = 10
            else
                tempCount = self._buyCount + 10
            end
        else
            if self._buyCount == 1 then
                tempCount = 10>self._PurchasabilityNum and self._PurchasabilityNum or 10
            else
                tempCount = (self._buyCount+10)>self._PurchasabilityNum and self._PurchasabilityNum or (self._buyCount + 10)
            end
        end
        --确定比较的是银两还是元宝
        local money = self:_getOwnScore()
        
        --预计总金额
        local price = self:getTotalPrice(tempCount)
        --钱不够
        local enoughMoney = false 
        if price > money then
            for i=tempCount,self._buyCount,-1 do
                local tempPrice = self:getTotalPrice(i)
                if tempPrice <= money  then
                    self._buyCount = i
                    enoughMoney = true
                    break
                end
            end
        else
            enoughMoney = true
            self._buyCount= tempCount
        end
        if enoughMoney then
            self:setText()
        end
    else
        if self._buyCount <= 10 then
            self._buyCount = 1
        else
            self._buyCount = self._buyCount -10
        end
        self:setText()
    end
end

function PurchaseScoreDialog:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return PurchaseScoreDialog

