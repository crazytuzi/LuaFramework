local ShowSecondDayLayer = class("ShowSecondDayLayer", BaseLayer);

CREATE_SCENE_FUN(ShowSecondDayLayer);
CREATE_PANEL_FUN(ShowSecondDayLayer);


function ShowSecondDayLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.showFirstpay");
end

function ShowSecondDayLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
    local img   = TFDirector:getChildByPath(ui, 'img');
    img:setTexture("ui_new/guide/img2.png")

    self.button_close   = TFDirector:getChildByPath(ui, 'btn_close_1');
    -- self.button_close:setVisible(false)
end

function ShowSecondDayLayer:onShow()
    self.super.onShow(self)
end


function ShowSecondDayLayer:removeUI()
   self.super.removeUI(self);
end

function ShowSecondDayLayer.onCloseClickHandle(sender)
    AlertManager:close();
    SevenDaysManager:enterSevenDaysLayer()
end

--注册事件
function ShowSecondDayLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.button_close);
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle))
    
end

function ShowSecondDayLayer:removeEvents()

end
return ShowSecondDayLayer;