local ClimbHomeLayer = class("ClimbHomeLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbHomeLayer);
CREATE_PANEL_FUN(ClimbHomeLayer);

--[[
******无量山-欢迎界面*******

    -- by haidong.gan
    -- 2013/12/27
]]

function ClimbHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbHomeLayer");
end

function ClimbHomeLayer:loadHomeData(data)
    self.homeInfo = data
    self:refreshUI()
end

function ClimbHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ClimbHomeLayer:refreshBaseUI()

end

function ClimbHomeLayer:refreshUI()

end

function ClimbHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_go         = TFDirector:getChildByPath(ui, 'btn_go');
end

--填充主页信息
function ClimbHomeLayer:loadHomeInfo()

end


function ClimbHomeLayer.onGoClickHandle(sender)
   local self = sender.logic;
   ClimbManager:showMountainLayer();
end

function ClimbHomeLayer:removeUI()
    self.super.removeUI(self);

end

function ClimbHomeLayer:registerEvents()
    self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    -- self.btn_close:setClickAreaLength(100);
    
    self.btn_go.logic    = self;   
    self.btn_go:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGoClickHandle),1);

    -- self.updateHomeInfoCallBack = function(event)
    --     self:loadHomeData(event.data[1]);
    -- end;
    -- TFDirector:addMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack ) ;

end

function ClimbHomeLayer:removeEvents()
    -- TFDirector:removeMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack);
    self.super.removeEvents(self);
end

return ClimbHomeLayer;
