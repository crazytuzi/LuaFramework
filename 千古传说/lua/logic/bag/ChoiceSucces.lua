local ChoiceSucces = class("ChoiceSucces", BaseLayer);

function ChoiceSucces:ctor()
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.bag.BagPieceMergeResult");
end

function ChoiceSucces:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
end


function ChoiceSucces:removeUI()
   self.super.removeUI(self);
end


--注册事件
function ChoiceSucces:registerEvents()
   self.super.registerEvents(self)
   ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);
end

function ChoiceSucces:removeEvents()
    self.super.removeEvents(self)
end


return ChoiceSucces;