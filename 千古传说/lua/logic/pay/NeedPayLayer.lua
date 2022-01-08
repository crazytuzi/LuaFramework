--[[
******普通元宝不足（非首充）*******

    -- by haidong.gan
    -- 2013/11/27
]]
local NeedPayLayer = class("NeedPayLayer", BaseLayer);

CREATE_SCENE_FUN(NeedPayLayer);
CREATE_PANEL_FUN(NeedPayLayer);


function NeedPayLayer:ctor(data)
    self.super.ctor(self,data);

    self:init("lua.uiconfig_mango_new.pay.NeedPayLayer");
end

function NeedPayLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_cancel     = TFDirector:getChildByPath(ui, 'btn_cancel');
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_pay     = TFDirector:getChildByPath(ui, 'btn_pay');
end


function NeedPayLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function NeedPayLayer:refreshBaseUI()

end

function NeedPayLayer:removeUI()
    self.super.removeUI(self);
end


function NeedPayLayer.onPayClickHandle(sender)
    local self = sender.logic;
    PayManager:showPayLayer(nil,AlertManager.NONE);
    AlertManager:closeLayer(self);   
end

--注册事件
function NeedPayLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_cancel);
    self.btn_close:setClickAreaLength(100);

    self.btn_pay.logic=self;
    self.btn_pay:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onPayClickHandle),1);
end

function NeedPayLayer:removeEvents()

end
return NeedPayLayer;
