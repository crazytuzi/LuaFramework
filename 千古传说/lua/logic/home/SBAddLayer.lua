--[[
******微信*******

]]
local SBAddLayer = class("SBAddLayer", BaseLayer);

CREATE_SCENE_FUN(SBAddLayer);
CREATE_PANEL_FUN(SBAddLayer);


function SBAddLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.showFirstpay");
end

function SBAddLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_goto   = TFDirector:getChildByPath(ui, 'btn_close');
    self.button_close   = TFDirector:getChildByPath(ui, 'btn_close_1');
    local img   = TFDirector:getChildByPath(ui, 'img');
    img:setTexture("ui_new/guide/img5.png")


    self.btn_goto:setVisible(false)
end

function SBAddLayer:onShow()
    self.super.onShow(self)
end


function SBAddLayer:removeUI()
   self.super.removeUI(self);
end

function SBAddLayer.btnClick( sender )
    AlertManager:close()
    OperationActivitiesManager:openHomeLayer()
end

--注册事件
function SBAddLayer:registerEvents()
    self.super.registerEvents(self);
    self.btn_goto:addMEListener(TFWIDGET_CLICK,self.btnClick)
    self.button_close:addMEListener(TFWIDGET_CLICK,function()
        AlertManager:close()
    end)
end

function SBAddLayer:removeEvents()

end
return SBAddLayer;