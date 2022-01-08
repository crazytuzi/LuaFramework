local ClimbMountainItembox = class("ClimbMountainItembox", BaseLayer);

CREATE_SCENE_FUN(ClimbMountainItembox);
CREATE_PANEL_FUN(ClimbMountainItembox);


function ClimbMountainItembox:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbMountainItembox");
end


function ClimbMountainItembox:initUI(ui)
    self.super.initUI(self,ui);

    self.img_icon        = TFDirector:getChildByPath(ui, 'img_icon');
end

function ClimbMountainItembox:onShow()
    self.super.onShow(self)
    -- self:refreshBaseUI()
    -- self:refreshUI()
end

function ClimbMountainItembox:refreshBaseUI()

end

function ClimbMountainItembox:refreshUI()

end



function ClimbMountainItembox.onClickShowBox(sender)
    local state = NorthClimbManager:showBox()
end

function ClimbMountainItembox:removeUI()
    self.super.removeUI(self);

end

function ClimbMountainItembox:registerEvents()
    self.super.registerEvents(self);
    self.img_icon:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickShowBox));
    self.ui:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickShowBox));
end

function ClimbMountainItembox:removeEvents()
    self.super.removeEvents(self);
end

return ClimbMountainItembox;
