
local MonthCardBuyLayer = class("MonthCardBuyLayer", BaseLayer)

function MonthCardBuyLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.CardBuyLayer")
end

function MonthCardBuyLayer:initUI(ui)
    self.super.initUI(self,ui)
    
    -- 
    self.btn_Close     = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_Buy       = TFDirector:getChildByPath(ui, 'btn_buy')

end

function MonthCardBuyLayer:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_Buy:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.BtnClickHandle),1)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_Close)

    TFDirector:addMEGlobalListener("BuyMonthCardPrize", function() self:BuyMonthCardSuccess() end)
end

function MonthCardBuyLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener("BuyMonthCardPrize")
end


function MonthCardBuyLayer.BtnClickHandle(sender)
    PayManager:pay(7)
    -- QiyuManager:BuyMonthCard()
end


function MonthCardBuyLayer:BuyMonthCardSuccess()
    --关闭当前当前窗口
    AlertManager:close()

    -- 进入领取
    AlertManager:addLayerByFile("lua.logic.qiyu.MonthCardGetLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()

    --toastMessage("月卡购买成功")
    toastMessage(localizable.monthCardBuy_buy_suc)
end

return MonthCardBuyLayer