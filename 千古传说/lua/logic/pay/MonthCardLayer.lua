--[[
******大小月卡*******

    -- by quanhuan
    -- 2015-10-9 15:19:43
    1.小月卡
    2.大月卡
]]
local MonthCardLayer = class("MonthCardLayer", BaseLayer);

function MonthCardLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.pay.Card");
end

function MonthCardLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.Btn_Close = TFDirector:getChildByPath(ui, 'Btn_Close')

    self.Card1 = TFDirector:getChildByPath(ui, 'Card1')
    self.Img_jihuo1 = TFDirector:getChildByPath(self.Card1, 'Img_jihuo')
    self.txt_day1 = TFDirector:getChildByPath(self.Card1, 'txt_day')
    self.Btn_get1 = TFDirector:getChildByPath(self.Card1, 'Btn_get')
    self.Btn_got1 = TFDirector:getChildByPath(self.Card1, 'Btn_got')
    self.Btn_buy1 = TFDirector:getChildByPath(self.Card1, 'Btn_buy')
    self.Btn_chongzhi1 = TFDirector:getChildByPath(self.Card1, 'Btn_chongzhi')
    self.price_down1 = TFDirector:getChildByPath(self.Card1, 'txt_price')
    self.Img_morepay1 = TFDirector:getChildByPath(self.Card1, 'Img_morepay')
    self.Label_Card_1 = TFDirector:getChildByPath(self.Card1, 'Label_Card_1')
    self.Btn_xufei1   = TFDirector:getChildByPath(self.Card1, 'btn_xufei')

    self.Card2 = TFDirector:getChildByPath(ui, 'Card2')
    self.Img_jihuo2 = TFDirector:getChildByPath(self.Card2, 'Img_jihuo')
    self.txt_day2 = TFDirector:getChildByPath(self.Card2, 'txt_day')
    self.Btn_get2 = TFDirector:getChildByPath(self.Card2, 'Btn_get')
    self.Btn_got2 = TFDirector:getChildByPath(self.Card2, 'Btn_got')
    self.Btn_buy2 = TFDirector:getChildByPath(self.Card2, 'Btn_buy')
    self.Btn_chongzhi2 = TFDirector:getChildByPath(self.Card2, 'Btn_chongzhi')
    self.price_down2 = TFDirector:getChildByPath(self.Card2, 'txt_price')
    self.Img_morepay2 = TFDirector:getChildByPath(self.Card2, 'Img_morepay')
    self.Label_Card_2 = TFDirector:getChildByPath(self.Card2, 'Label_Card_1')
    self.Btn_xufei2   = TFDirector:getChildByPath(self.Card2, 'btn_xufei')

    self.Btn_chongzhi1:setVisible(false)
    self.Btn_chongzhi2:setVisible(false)

    self.Btn_xufei1:setVisible(false)
    self.Btn_xufei2:setVisible(false)

    self.Btn_got1:setTouchEnabled(false)
    self.Btn_got2:setTouchEnabled(false)

    local cardInfo1 = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_1 ) 
    self.price_down1:setText(cardInfo1.RMB)
    self.YB_1 = cardInfo1.YB
    self.Label_Card_1:setText(cardInfo1.RMB*10)

    local cardInfo2 = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_2 ) 
    self.price_down2:setText(cardInfo2.RMB)
    self.YB_2 = cardInfo2.YB
    self.Label_Card_2:setText(cardInfo2.RMB*10)

    self.isShow = true

    Public:addBtnWaterEffect(self.Btn_buy1, true,1)
    Public:addBtnWaterEffect(self.Btn_buy2, true,1)

end

function MonthCardLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
end

function MonthCardLayer:refreshUI()

    if self.isShow then
        self:refreshCard_1()
        self:refreshCard_2()
    end
end

--注册事件
function MonthCardLayer:registerEvents()
    self.super.registerEvents(self);

    self.onCloseClickHandle = function ()
        AlertManager:close()
    end    
    self.Btn_Close:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onCloseClickHandle),1)

    self.onBuyClickHandle_1 = function ()
        MonthCardManager:chongzhi(MonthCardManager.CARD_TYPE_1)
    end
    self.Btn_buy1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyClickHandle_1),1)

    self.Btn_xufei1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyClickHandle_1),1)

    self.onBuyClickHandle_2 = function ()
        MonthCardManager:chongzhi(MonthCardManager.CARD_TYPE_2)
    end
    self.Btn_buy2:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyClickHandle_2),1)

    self.Btn_xufei2:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyClickHandle_2),1)

    self.onGetClickHandle_1 = function ()
        MonthCardManager:lingqu(MonthCardManager.CARD_TYPE_1)
    end
    self.Btn_get1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGetClickHandle_1),1)

    self.onGetClickHandle_2 = function ()
        MonthCardManager:lingqu(MonthCardManager.CARD_TYPE_2)
    end
    self.Btn_get2:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGetClickHandle_2),1)

    self.onLingquComlete = function( event )
        play_chongzhichenggong()
        local data = event.data[1]
         if data[1] == 1 then
            --toastMessage("已领取"..self.YB_1.."元宝")
            toastMessage(stringUtils.format(localizable.common_get_gold,self.YB_1))
        else
            --toastMessage("已领取"..self.YB_2.."元宝")
            toastMessage(stringUtils.format(localizable.common_get_gold,self.YB_2))
        end
    end
    TFDirector:addMEGlobalListener(MonthCardManager.MONTH_CARD_LINGQU_COMPELTE, self.onLingquComlete)


    self.onWindowUpdate = function ()
        self:onShow()
    end
    TFDirector:addMEGlobalListener(MonthCardManager.MONTH_CARD_INFO_UPDATE, self.onWindowUpdate)

end

function MonthCardLayer:removeEvents()

    self.Btn_Close:removeMEListener(TFWIDGET_CLICK)
    self.Btn_buy1:removeMEListener(TFWIDGET_CLICK)
    self.Btn_buy2:removeMEListener(TFWIDGET_CLICK)
    self.Btn_get1:removeMEListener(TFWIDGET_CLICK)
    self.Btn_get2:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(MonthCardManager.MONTH_CARD_LINGQU_COMPELTE, self.onLingquComlete)
    TFDirector:removeMEGlobalListener(MonthCardManager.MONTH_CARD_INFO_UPDATE, self.onWindowUpdate)

end

function MonthCardLayer:removeUI()
   self.super.removeUI(self);
end


function MonthCardLayer:refreshCard_1()

    local btnInfo = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_1 ) 
    local status = btnInfo.btnStatus

    if status == MonthCardManager.BTN_STATUS_PAY then
        self.txt_day1:setVisible(true)
        --self.txt_day1:setText("持续 30 天")
        self.txt_day1:setText(stringUtils.format(localizable.MonthCardLayer_text1,30))

        self.Btn_get1:setVisible(false)
        self.Btn_got1:setVisible(false)
        self.Btn_buy1:setVisible(true)
        self.Btn_xufei1:setVisible(false)
        self.Img_jihuo1:setVisible(false)
        self.Img_morepay1:setVisible(true)
    elseif status == MonthCardManager.BTN_STATUS_GET then
        self.txt_day1:setVisible(true)
        --self.txt_day1:setText("持续 "..btnInfo.day.." 天")
        self.txt_day1:setText(stringUtils.format(localizable.MonthCardLayer_text1,btnInfo.day))

        self.Btn_get1:setVisible(true)
        self.Btn_got1:setVisible(false)
        self.Btn_buy1:setVisible(false)
        self.Btn_xufei1:setVisible(true)
        self.Img_jihuo1:setVisible(true)
        self.Img_morepay1:setVisible(false)
    else
        self.txt_day1:setVisible(true)
        --self.txt_day1:setText("持续 "..btnInfo.day.." 天")
        self.txt_day1:setText(stringUtils.format(localizable.MonthCardLayer_text1,btnInfo.day))

        self.Btn_get1:setVisible(false)
        self.Btn_got1:setVisible(true)
        self.Btn_buy1:setVisible(false)
        self.Btn_xufei1:setVisible(true)
        self.Img_jihuo1:setVisible(true)
        self.Img_morepay1:setVisible(false)
    end

end

function MonthCardLayer:refreshCard_2()

    local btnInfo = MonthCardManager:getBtnStatus( MonthCardManager.CARD_TYPE_2 ) 
    local status = btnInfo.btnStatus
    
    self.YB_2 = btnInfo.YB
    if status == MonthCardManager.BTN_STATUS_PAY then
        self.txt_day2:setVisible(true)
        --self.txt_day2:setText("持续 30 天")
        self.txt_day2:setText(stringUtils.format(localizable.MonthCardLayer_text1, 30))

        self.Btn_get2:setVisible(false)
        self.Btn_got2:setVisible(false)
        self.Btn_buy2:setVisible(true)
        self.Btn_xufei2:setVisible(false)
        self.Img_jihuo2:setVisible(false)
        self.Img_morepay2:setVisible(true)
    elseif status == MonthCardManager.BTN_STATUS_GET then
        self.txt_day2:setVisible(true)
        --self.txt_day2:setText("持续 "..btnInfo.day.." 天")
        self.txt_day2:setText(stringUtils.format(localizable.MonthCardLayer_text1,btnInfo.day))
        self.Btn_get2:setVisible(true)
        self.Btn_got2:setVisible(false)
        self.Btn_buy2:setVisible(false)
        self.Btn_xufei2:setVisible(true)
        self.Img_jihuo2:setVisible(true)
        self.Img_morepay2:setVisible(false)
    else
        self.txt_day2:setVisible(true)
        --self.txt_day2:setText("持续 "..btnInfo.day.." 天")
        self.txt_day2:setText(stringUtils.format(localizable.MonthCardLayer_text1,btnInfo.day))
        self.Btn_get2:setVisible(false)
        self.Btn_got2:setVisible(true)
        self.Btn_buy2:setVisible(false)
        self.Btn_xufei2:setVisible(true)
        self.Img_jihuo2:setVisible(true)
        self.Img_morepay2:setVisible(false)
    end
end

return MonthCardLayer;
