--[[
******微信*******

]]
local ShowFirstPayLayer = class("ShowFirstPayLayer", BaseLayer);

CREATE_SCENE_FUN(ShowFirstPayLayer);
CREATE_PANEL_FUN(ShowFirstPayLayer);


function ShowFirstPayLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.showFirstpay");
end

function ShowFirstPayLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_goto   = TFDirector:getChildByPath(ui, 'btn_close');
    self.button_close   = TFDirector:getChildByPath(ui, 'btn_close_1');
    local img   = TFDirector:getChildByPath(ui, 'img');
    img:setTexture("ui_new/guide/img1.png")



end

function ShowFirstPayLayer:onShow()
    self.super.onShow(self)
end


function ShowFirstPayLayer:removeUI()
   self.super.removeUI(self);
end

function ShowFirstPayLayer.btnClick( sender )
    AlertManager:close()
    PayManager:showPayLayer(nil,nil,true)
end

--注册事件
function ShowFirstPayLayer:registerEvents()
    self.super.registerEvents(self);
    self.btn_goto:addMEListener(TFWIDGET_CLICK,self.btnClick)
    self.button_close:addMEListener(TFWIDGET_CLICK,function()
        AlertManager:close()
    end)
end

function ShowFirstPayLayer:removeEvents()

end
return ShowFirstPayLayer;