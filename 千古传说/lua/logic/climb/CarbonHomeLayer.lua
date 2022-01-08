local CarbonHomeLayer = class("CarbonHomeLayer", BaseLayer);

CREATE_SCENE_FUN(CarbonHomeLayer);
CREATE_PANEL_FUN(CarbonHomeLayer);

--[[
******战魂副本-欢迎界面*******

    -- by haidong.gan
    -- 2013/12/27
]]

function CarbonHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.CarbonHomeLayer");
end

function CarbonHomeLayer:loadHomeData(data)
    self.homeInfo = data;
    self:refreshUI();
end

function CarbonHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function CarbonHomeLayer:refreshBaseUI()

end

function CarbonHomeLayer:refreshUI()
    if not self.isShow then
        return;
    end

end

function CarbonHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_go         = TFDirector:getChildByPath(ui, 'btn_go');
end

--填充主页信息
function CarbonHomeLayer:loadHomeInfo()

end


function CarbonHomeLayer.onGoClickHandle(sender)
   local self = sender.logic;
   ClimbManager:showCarbonListLayer();
end

function CarbonHomeLayer:removeUI()
    self.super.removeUI(self);

end

function CarbonHomeLayer:registerEvents()
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

function CarbonHomeLayer:removeEvents()
    -- TFDirector:removeMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack);
    self.super.removeEvents(self);
end

return CarbonHomeLayer;
