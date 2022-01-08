--[[
******兑换码列表*******

]]
local ExchangeLayer = class("ExchangeLayer", BaseLayer);

CREATE_SCENE_FUN(ExchangeLayer);
CREATE_PANEL_FUN(ExchangeLayer);

ExchangeLayer.LIST_ITEM_HEIGHT = 90; 

function ExchangeLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.duihuanma");
end

function ExchangeLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.txt_input   = TFDirector:getChildByPath(ui, 'txt_input');
    self.txt_input:setCursorEnabled(true)
    self.btn_change  = TFDirector:getChildByPath(ui, 'Button_duihuanma_1');
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
    self.bg_niantie  = TFDirector:getChildByPath(ui, 'bg_niantie');

    self.bg_niantie:setVisible(false)
end

function ExchangeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ExchangeLayer:refreshBaseUI()

end

function ExchangeLayer:removeUI()
    self.super.removeUI(self);
end


function ExchangeLayer.onBtnChangeClickHandle(sender)
    local self = sender.logic;
    local str = self.txt_input:getText()
    if str == "" then
        --toastMessage("请输入礼包码")
        toastMessage(localizable.exchangeLayer_code)
        return
    end
    showLoading();
    local Msg = 
    {
        str,
    }
    TFDirector:send(c2s.REQUEST_EXCHANGE_GIFTS,Msg)

end

--注册事件
function ExchangeLayer:registerEvents()
    self.super.registerEvents(self);


    self.btn_change.logic=self;

    self.btn_change:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnChangeClickHandle),1);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    -- self.btn_close:setClickAreaLength(100);

    TFDirector:addProto(s2c.EXCHANGE_RESULT, self, self.ExchangeResult)
    
        --添加输入账号时输入框上移逻辑
    local function onTextFieldAttachHandle(input)
        -- self.txt_input:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
        self.bg_niantie:setVisible(true)
        if self.showPasteTimer == nil then
            self.showPasteTimer = TFDirector:addTimer(3000, -1, nil, 
                function() 
                    self:hidePasteButton()
                end)
        end
    end
    self.txt_input:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)


    self.bg_niantie.logic=self;
    self.bg_niantie:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickPaste),1);
end

function ExchangeLayer:ExchangeResult( event )
    hideLoading();
    local str = self.txt_input:getText()
    if HeitaoSdk then
        HeitaoSdk.onUseGiftCode(str)
    end
    
    self.txt_input:setText("");
end

function ExchangeLayer:removeEvents()
    TFDirector:removeProto(s2c.EXCHANGE_RESULT, self, self.ExchangeResult)

    self:hidePasteButton()
end

function ExchangeLayer:hidePasteButton()
    if self.showPasteTimer then
        TFDirector:removeTimer(self.showPasteTimer)
        self.showPasteTimer = nil
    end

    self.bg_niantie:setVisible(false)
end

function ExchangeLayer.onClickPaste(sender)
    local self = sender.logic

    self:hidePasteButton()

    local content = TFDeviceInfo:getClipBoardText()
    if content then
        self.txt_input:setText(TFDeviceInfo:getClipBoardText())
    end
end

return ExchangeLayer;