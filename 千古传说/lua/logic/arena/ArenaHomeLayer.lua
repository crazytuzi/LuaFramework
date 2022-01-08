local ArenaHomeLayer = class("ArenaHomeLayer", BaseLayer);

CREATE_SCENE_FUN(ArenaHomeLayer);
CREATE_PANEL_FUN(ArenaHomeLayer);

--[[
******群豪榜-欢迎界面*******

    -- by haidong.gan
    -- 2013/12/27
]]

function ArenaHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.arena.ArenaHomeLayer");
end

function ArenaHomeLayer:loadHomeData(data)
    self.homeInfo = data;
    
    self:refreshUI();
end

function ArenaHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function ArenaHomeLayer:refreshBaseUI()
    -- self.txt_challengeCount:setText(self.homeInfo.challengeCountOneDay - self.homeInfo.challengeCountToDay);
    -- self.txt_challengeCountLeave:setText(self.homeInfo.challengeCountToDay); 
end

function ArenaHomeLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
end

function ArenaHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_go         = TFDirector:getChildByPath(ui, 'btn_go');
    -- self.txt_challengeCount      = TFDirector:getChildByPath(ui, 'txt_challengeCount');
    -- self.txt_challengeCountLeave      = TFDirector:getChildByPath(ui, 'txt_challengeCountLeave');
    -- TFDirector:getChildByPath(ui, 'lb_clearTime'):setText("每天24：00恢复挑战次数！");
    
end

function ArenaHomeLayer.onGoClickHandle(sender)
   local self = sender.logic;
    local teamLev = MainPlayer:getLevel()
    --local openLev = PlayerGuideManager:getFunctionOpenLevelByName("群豪谱")
    local openLev = PlayerGuideManager:getFunctionOpenLevelByName(localizable.arenafightreport_rank)
    if teamLev < openLev then
        local str = stringUtils.format(localizable.common_function_openlevel, openLev)
        toastMessage(str)
        return
    end
   ArenaManager:showArenaLayer();
end

function ArenaHomeLayer:removeUI()
    self.super.removeUI(self)
end

function ArenaHomeLayer:registerEvents()
    self.super.registerEvents(self)
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    -- self.btn_close:setClickAreaLength(100);
    
    self.btn_go.logic    = self
    self.btn_go:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGoClickHandle),1)

    -- self.updateHomeInfoCallBack = function(event)
    --     self:loadHomeData(event.data[1])
    -- end
    -- TFDirector:addMEGlobalListener(ArenaManager.updateHomeInfo ,self.updateHomeInfoCallBack)

end

function ArenaHomeLayer:removeEvents()
    -- TFDirector:removeMEGlobalListener(ArenaManager.updateHomeInfo ,self.updateHomeInfoCallBack)
    self.super.removeEvents(self)
end

return ArenaHomeLayer;
