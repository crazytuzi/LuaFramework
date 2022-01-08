local ClimbOpenBox = class("ClimbOpenBox", BaseLayer);

CREATE_SCENE_FUN(ClimbOpenBox);
CREATE_PANEL_FUN(ClimbOpenBox);


function ClimbOpenBox:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbOpenBox");
end


function ClimbOpenBox:initUI(ui)
    self.super.initUI(self,ui);

    self.img_icon        = TFDirector:getChildByPath(ui, 'img_icon');
end

function ClimbOpenBox:onShow()
    self.super.onShow(self)
    -- self:refreshBaseUI()
    -- self:refreshUI()
end

function ClimbOpenBox:refreshBaseUI()

end

function ClimbOpenBox:refreshUI()

end



function ClimbOpenBox.onClickShowBox(sender)
    -- AlertManager:close()
    NorthClimbManager:requestGetCaveChestReward()
end

function ClimbOpenBox:removeUI()
    self.super.removeUI(self);

end

function ClimbOpenBox:registerEvents()
    self.super.registerEvents(self);
    -- self.img_icon:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickShowBox));
    self.ui:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickShowBox));
end

function ClimbOpenBox:removeEvents()
    self.super.removeEvents(self);
end

return ClimbOpenBox;
