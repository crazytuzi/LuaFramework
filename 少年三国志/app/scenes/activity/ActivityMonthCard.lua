local ActivityMonthCard = class("ActivityMonthCard",UFCCSNormalLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.month_card_info")
function ActivityMonthCard.create()
    local layer = ActivityMonthCard.new("ui_layout/activity_ActivityMonthCard.json")
    return layer
end

function ActivityMonthCard:ctor(...)
    self.super.ctor(self,...)
    if month_card_info.getLength() ~= 2 then
      --不止两张月卡了
      return
    end
    self:getLabelByName("Label_tips"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_25tips"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_50tips"):createStroke(Colors.strokeBrown,1)

    self:_initEvent()
    self:updatePage()
end

function ActivityMonthCard:onLayerEnter()
  uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USE_MONTHCARD_INFO, self._useMonthCard, self) 
  uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_RECHARGE_INFO, self.updatePage, self)

end

function ActivityMonthCard:onLayerExit()
  uf_eventManager:removeListenerWithTarget(self)
end

function ActivityMonthCard:_useMonthCard(data)
  if data.ret == 1 then
    self:updatePage()
    --红点刷新
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
  end
end


--根据月卡状态刷新
function ActivityMonthCard:updatePage()
    -- 过12点了，手动刷新月卡信息
    if G_Me.shopData:isNeedRequestMonthCardData() then
        G_HandlersManager.shopHandler:sendRechargeInfo()
        return
    end

  --25元月卡
  if G_Me.shopData:monthCardPurchasability(2) then
    --可购买
    self:showWidgetByName("Button_buy25",true)
    self:showWidgetByName("Image_25yilingqu",false)
    self:getLabelByName("Label_25tips"):setColor(Colors.darkColors.DESCRIPTION)
    self:getImageViewByName("Image_19"):loadTexture(G_Path.getMiddleBtnTxt("qianwanggoumai.png"))
  else
    local leftDay = G_Me.shopData:getMonthCardLeftDay(2)
    self:getLabelByName("Label_25tips"):setText(G_lang:get("LANG_RECHARGE_MONTH_CARD_LEFT_DAY_HUO_DONG",{days=leftDay}))
    self:getLabelByName("Label_25tips"):setColor(Colors.darkColors.TIPS_01)
    if G_Me.shopData:useEnabled(2) then
      --可用
      self:showWidgetByName("Button_buy25",true)
      self:showWidgetByName("Image_25yilingqu",false)
      self:getImageViewByName("Image_19"):loadTexture(G_Path.getMiddleBtnTxt("lingqu.png"))
    else
      --不可用
      self:showWidgetByName("Button_buy25",false)
      self:showWidgetByName("Image_25yilingqu",true)
    end
  end


  --50元月卡
  if G_Me.shopData:monthCardPurchasability(1) then
    --可购买
    self:showWidgetByName("Button_buy50",true)
    self:showWidgetByName("Image_50yilingqu",false)
    self:getLabelByName("Label_50tips"):setColor(Colors.darkColors.DESCRIPTION)
    self:getImageViewByName("Image_21"):loadTexture(G_Path.getMiddleBtnTxt("qianwanggoumai.png"))
  else
    local leftDay = G_Me.shopData:getMonthCardLeftDay(1)
    self:getLabelByName("Label_50tips"):setText(G_lang:get("LANG_RECHARGE_MONTH_CARD_LEFT_DAY_HUO_DONG",{days=leftDay}))
    self:getLabelByName("Label_50tips"):setColor(Colors.darkColors.TIPS_01)
    if G_Me.shopData:useEnabled(1) then
      --可用
      self:showWidgetByName("Button_buy50",true)
      self:showWidgetByName("Image_50yilingqu",false)
      self:getImageViewByName("Image_21"):loadTexture(G_Path.getMiddleBtnTxt("lingqu.png"))
    else
      --不可用
      self:showWidgetByName("Button_buy50",false)
      self:showWidgetByName("Image_50yilingqu",true)
    end
  end

  --红点刷新
  uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
end

function ActivityMonthCard:_initEvent()
  self:registerBtnClickEvent("Button_buy50",function()
    if G_Me.shopData:monthCardPurchasability(1) then
      --去购买
      require("app.scenes.shop.recharge.RechargeLayer").show()
    else
      if G_Me.shopData:useEnabled(1) then
        --可用
        G_HandlersManager.shopHandler:sendUseMonthCard(1)
      else
        --不可用
      end
    end
    
    end)
  self:registerBtnClickEvent("Button_buy25",function()
    if G_Me.shopData:monthCardPurchasability(2) then
      --去购买
      require("app.scenes.shop.recharge.RechargeLayer").show()
    else
      if G_Me.shopData:useEnabled(2) then
        --可用
        G_HandlersManager.shopHandler:sendUseMonthCard(2)
      else
        --不可用
      end
    end
    end)
end

function ActivityMonthCard:adapterLayer()
    self:adapterWidgetHeight("Panel_16","","",100,0)
end
return ActivityMonthCard

