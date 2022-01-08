--[[
******归隐确认*******

]]
local HermitHelp = class("HermitHelp", BaseLayer);

CREATE_SCENE_FUN(HermitHelp);
CREATE_PANEL_FUN(HermitHelp);

function HermitHelp:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.shop.Help");
end

function HermitHelp:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close             = TFDirector:getChildByPath(ui, 'Button_Help_1');
end

function HermitHelp:onShow()
    self.super.onShow(self)
end

function HermitHelp:removeUI()
   self.super.removeUI(self);
end

--注册事件
function HermitHelp:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
end

function HermitHelp:removeEvents()
    self.super.removeEvents(self)
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
end

return HermitHelp;
