local ArenaResultLayer = class("ArenaResultLayer", BaseLayer);

CREATE_SCENE_FUN(ArenaResultLayer);
CREATE_PANEL_FUN(ArenaResultLayer);

--[[
******群豪榜-个人最佳排名*******

    -- by haidong.gan
    -- 2013/12/27
]]

function ArenaResultLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.arena.ArenaResultLayer");
end

function ArenaResultLayer:loadData(data)
    self.rewardInfo = data;
    
    self:refreshUI();
end

function ArenaResultLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ArenaResultLayer:refreshBaseUI()

end

function ArenaResultLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    
    local str = stringUtils.format(localizable.arenaresultlayer_text1, self.rewardInfo.currentRank + 1, self.rewardInfo.walk)
    self.txt_des:setText(str)
    self.txt_sycee:setText(self.rewardInfo.sycee);

end

function ArenaResultLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_ok');
    self.txt_des        = TFDirector:getChildByPath(ui, 'txt_des');
    self.txt_sycee      = TFDirector:getChildByPath(ui, 'txt_sycee');

    -- self.txt_challengeCount      = TFDirector:getChildByPath(ui, 'txt_challengeCount');
    -- self.txt_challengeCountLeave      = TFDirector:getChildByPath(ui, 'txt_challengeCountLeave');
    -- TFDirector:getChildByPath(ui, 'lb_clearTime'):setText("每天24：00恢复挑战次数！");
    
end


function ArenaResultLayer:removeUI()
    self.super.removeUI(self);
end

function ArenaResultLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    -- self.btn_close:setClickAreaLength(100);
end

function ArenaResultLayer:removeEvents()
    self.super.removeEvents(self);
end

return ArenaResultLayer;
