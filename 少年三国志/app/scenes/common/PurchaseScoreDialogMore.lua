local PurchaseScoreDialogMore = class("PurchaseScoreDialogMore",UFCCSModelLayer)
require("app.cfg.shop_score_info")
require("app.const.ShopType")

--该购买弹出框支持三种兑换物品

function PurchaseScoreDialogMore.show(item_id)
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
    local layer =  PurchaseScoreDialogMore.create(item_id)
    uf_sceneManager:getCurScene():addChild(layer)
end


--[[
    item_id: 道具id,参考shop_vip_info
    mode:商店类型,参考
]]
function PurchaseScoreDialogMore.create(item_id)
    local layer = PurchaseScoreDialogMore.new("ui_layout/shop_PurchaseDialogMore.json",require("app.setting.Colors").modelColor,item_id)
    --    layer:adapterLayer()
    return layer
end

--适配写在这里
function PurchaseScoreDialogMore:adapterLayer()
    self:adapterWidgetHeight("","","",0,0)
end


function PurchaseScoreDialogMore:ctor(json,color,item_id)
    self._isAddingNum = true
    self._curTimeCost = 0
    --默认买一个
    self._buyCount = 1
    self.super.ctor(self,json)
    --隶属于商店类型
    self._item = shop_score_info.get(item_id)

    local num_ban_type = self._item["num_ban_type"]
    --获取最大购买数量
    local key = string.format("vip%s_num",G_Me.userData.vip)
    local maxPurchaseNum = self._item[key]
    local purchasedNum = G_Me.shopData:getScorePurchaseNumById(item_id)
    --最大可购买数
    self._PurchasabilityNum = maxPurchaseNum == 0 and 999 or (maxPurchaseNum - purchasedNum)

    self._limitItemIndex = 1  --限制最大可购买数的道具

    local costItemNum = 0

    --增加了兑换类型，所以再比较
    if self._item.extra_type > 0 then

    	self._costGood = G_Goods.convert(self._item.extra_type,self._item.extra_value,self._item.extra_size)

        local ownNum = G_Me.bagData:getNumByTypeAndValue(self._item.extra_type,self._item.extra_value)
        local buyNum = math.floor(ownNum/self._item.extra_size)
        --取较小的那个
        self._PurchasabilityNum = self._PurchasabilityNum < buyNum and self._PurchasabilityNum or buyNum

        if self._costGood then
            costItemNum = costItemNum + 1
        end
    end

    --增加了兑换类型2，所以再比较
    if self._item.extra_type2 > 0 then

    	self._costGood2 = G_Goods.convert(self._item.extra_type2,self._item.extra_value2,self._item.extra_size2)

        local ownNum = G_Me.bagData:getNumByTypeAndValue(self._item.extra_type2,self._item.extra_value2)
        local buyNum = math.floor(ownNum/self._item.extra_size2)
        --取较小的那个
        self._PurchasabilityNum = self._PurchasabilityNum < buyNum and self._PurchasabilityNum or buyNum

        if self._PurchasabilityNum > buyNum then
        	self._limitItemIndex = 2
        end

        if self._costGood2 then
            costItemNum = costItemNum + 1
        end

    end

    --增加了兑换类型3，所以再比较
    if self._item.extra_type3 > 0 then

    	self._costGood3 = G_Goods.convert(self._item.extra_type3,self._item.extra_value3,self._item.extra_size3)

        local ownNum = G_Me.bagData:getNumByTypeAndValue(self._item.extra_type3,self._item.extra_value3)
        local buyNum = math.floor(ownNum/self._item.extra_size3)
        --取较小的那个
        self._PurchasabilityNum = self._PurchasabilityNum < buyNum and self._PurchasabilityNum or buyNum

        if self._PurchasabilityNum > buyNum then
        	self._limitItemIndex = 3
        end

        if self._costGood3 then
            costItemNum = costItemNum + 1
        end

    end


    --调整位置
    local cost_panel = self:getWidgetByName("Panel_tagJinZi")
    local x = cost_panel:getPositionX()
    if costItemNum == 1 then
        cost_panel:setPositionX(x+70)
    elseif costItemNum == 2 then
        cost_panel:setPositionX(x+35)
    else
    end

    self._PurchasabilityNum = (self._PurchasabilityNum > 999) and 999 or self._PurchasabilityNum

    --还可购买次数
    local buyCountLabel = self:getLabelByName("Label_buyCount")
    if num_ban_type == 0 then
        --local parent = self:getWidgetByName("Panel_itemBg")
        --local panel = self:getWidgetByName("Panel_tagJinZi")
        --local x,y = panel:getPosition()
        --panel:setPosition(ccp(parent:getContentSize().width/2-panel:getContentSize().width/2, y))
        self:showWidgetByName("Label_buyCount",false)
     
    else
        --终身购买次数
        if num_ban_type == 1 then
            buyCountLabel:setText(G_lang:get("LANG_PURCHASE_LIFE_AVAILABLE_NUM",{num=(maxPurchaseNum-purchasedNum)}))
        else
            --每日购买次数
            if num_ban_type == 2 and maxPurchaseNum >= 20000000 then
                buyCountLabel:setText("")
            else 
                buyCountLabel:setText( G_lang:get("LANG_PURCHASE_AVAILABLE_NUM",{num=(maxPurchaseNum-purchasedNum)}))

            end
        end
    end



    self:_initWidgets()
    self:_createStrokes()
    self:_initBtnEvent()
    self:showAtCenter(true)
end

function PurchaseScoreDialogMore:_createStrokes()
  
    self:enableLabelStroke("Label_name01", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jian1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia10", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_jia1", Colors.strokeBrown,1)
    self:enableLabelStroke("Label_item_num", Colors.strokeBrown,1)

end

function PurchaseScoreDialogMore:_initWidgets()
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
  
    self:getImageViewByName("ImageView_item"):loadTexture(goods.icon,UI_TEX_TYPE_LOCAL)

    self:_setPrice()

    self:_setOwnNum()
end

function PurchaseScoreDialogMore:_setPrice()

	if self._buyCount <=0 then
        self._buyCount = 1
    end

    self:showWidgetByName("Panel_priceItem",false)
    self:showWidgetByName("Panel_priceItem_2",false)
    self:showWidgetByName("Panel_priceItem_3",false)

	self:getLabelByName("Label_count"):setText(self._buyCount)

    if self._costGood then  
        self:showWidgetByName("Panel_priceItem",true)
        self:getLabelByName("Label_priceItem"):setText(self._costGood.size * self._buyCount)
        self:getImageViewByName("Image_priceItem"):loadTexture(self._costGood.icon_mini,self._costGood.texture_type)
    end

    if self._costGood2 then
		self:showWidgetByName("Panel_priceItem_2",true)
		self:getLabelByName("Label_priceItem2"):setText(self._costGood2.size * self._buyCount)
		self:getImageViewByName("Image_priceItem2"):loadTexture(self._costGood2.icon_mini,self._costGood2.texture_type)
    end

    if self._costGood3 then
        self:showWidgetByName("Panel_priceItem_3",true)
        self:getLabelByName("Label_priceItem3"):setText(self._costGood3.size * self._buyCount)
        self:getImageViewByName("Image_priceItem3"):loadTexture(self._costGood3.icon_mini,self._costGood3.texture_type)
    end

end


function PurchaseScoreDialogMore:_setOwnNum()
    local ownNumLabel = self:getLabelByName("Label_num")
    local _num,name= G_Me.bagData:getNumByTypeAndValue(self._item.type,self._item.value)
    _num = G_GlobalFunc.ConvertNumToCharacter(_num)
    ownNumLabel:setText(G_lang:get("LANG_GOODS_NUM",{num=_num}))

end

function PurchaseScoreDialogMore:_initBtnEvent()
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

        if G_Me.trigramsData:isClose() then
            G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_ITEM_IS_OVER"))
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

        local ownNum, ownNum2, ownNum3 = self:_getOwnNum()

        local price, price2, price3 = self:_getTotalPrice(self._buyCount + 1)
       
        if self._limitItemIndex == 1 and price > ownNum then
            return
        end

        if self._limitItemIndex == 2 and price2 > ownNum2 then
            return
        end

        if self._limitItemIndex == 3 and price2 > ownNum3 then
            return
        end
        
        self._buyCount = self._buyCount + 1
        self:_setPrice()

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
        self:_setPrice()
    end)
    -- 减 10
    self:registerBtnClickEvent("Button_subtract10",function()
        if self._buyCount <= 10 then
            self._buyCount = 1
        else
            self._buyCount = self._buyCount -10
        end
        self:_setPrice()
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

--获取拥有的数量
function PurchaseScoreDialogMore:_getOwnNum()

    local ownNum = 0
    local ownNum2 = 0
    local ownNum3 = 0

    if self._costGood then
        ownNum = G_Me.bagData:getNumByTypeAndValue(self._costGood.type,self._costGood.value)
    end

    if self._costGood2 then
        ownNum2 = G_Me.bagData:getNumByTypeAndValue(self._costGood2.type,self._costGood2.value)
    end

    if self._costGood3 then
        ownNum3 = G_Me.bagData:getNumByTypeAndValue(self._costGood3.type,self._costGood3.value)
    end

    return ownNum, ownNum2, ownNum3
end


--获取价格
function PurchaseScoreDialogMore:_getPrice(times)
    
end

--不考虑打折打情况
function PurchaseScoreDialogMore:_getTotalPrice(count)
    
    local price = 0
    local price2 = 0
    local price3 = 0

    if self._costGood then
        price = self._item.extra_size * count
    end

    if self._costGood2 then
        price2 = self._item.extra_size2 * count
    end

 	if self._costGood3 then
        price3 = self._item.extra_size3 * count
    end

    return price, price2, price3

end



function PurchaseScoreDialogMore:_onBtnTouch( widget, typeValue )
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

function PurchaseScoreDialogMore:_stopSchedule( ... )
    self:unscheduleUpdate()
    self._curTimeCost = 0
end

function PurchaseScoreDialogMore:_onUpdate( dt )
    self._curTimeCost = self._curTimeCost + dt
    
    if self._curTimeCost > 0.2 then 
        self._curTimeCost = self._curTimeCost - 0.2
        self:_doCountChange()
    end    
end

function PurchaseScoreDialogMore:_doCountChange( ... )
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
        
        local ownNum, ownNum2, ownNum3 = self:_getOwnNum()
        
        --预计总价格
        local price, price2, price3 = self:_getTotalPrice(tempCount)
        --钱不够
        local enoughMoney = false

        if self._limitItemIndex == 1 then
        	if price > ownNum then
        		for i=tempCount,self._buyCount,-1 do
	                local tempPrice, tempPrice2, tempPrice3 = self:_getTotalPrice(i)
	                if tempPrice <= ownNum  then
	                    self._buyCount = i
	                    enoughMoney = true
	                    break
	                end
	            end
            else
            	enoughMoney = true
            	self._buyCount= tempCount
            end
        elseif self._limitItemIndex == 2 then
        	if price2 > ownNum2 then
        		for i=tempCount,self._buyCount,-1 do
	                local tempPrice, tempPrice2, tempPrice3 = self:_getTotalPrice(i)
	                if tempPrice2 <= ownNum2  then
	                    self._buyCount = i
	                    enoughMoney = true
	                    break
	                end
	            end
            else
            	enoughMoney = true
            	self._buyCount= tempCount
            end
        else
        	if price3 > ownNum3 then
        		for i=tempCount,self._buyCount,-1 do
	                local tempPrice, tempPrice2, tempPrice3 = self:_getTotalPrice(i)
	                if tempPrice3 <= ownNum3  then
	                    self._buyCount = i
	                    enoughMoney = true
	                    break
	                end
	            end
            else
            	enoughMoney = true
            	self._buyCount= tempCount
            end
        end

        if enoughMoney then
            self:_setPrice()
        end
    else
        if self._buyCount <= 10 then
            self._buyCount = 1
        else
            self._buyCount = self._buyCount -10
        end
        self:_setPrice()
    end
end

function PurchaseScoreDialogMore:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return PurchaseScoreDialogMore

