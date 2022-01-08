--[[
******微信*******

]]
local WeixinLayer = class("WeixinLayer", BaseLayer);

CREATE_SCENE_FUN(WeixinLayer);
CREATE_PANEL_FUN(WeixinLayer);

WeixinLayer.LIST_ITEM_HEIGHT = 90; 

function WeixinLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.WeiXin");
end

function WeixinLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
end

function WeixinLayer:onShow()
    self.super.onShow(self)
end


function WeixinLayer:removeUI()
   self.super.removeUI(self);
end


--注册事件
function WeixinLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   -- self.btn_close:setClickAreaLength(100);

end

function WeixinLayer:removeEvents()

end
return WeixinLayer;