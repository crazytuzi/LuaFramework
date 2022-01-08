local MiningHomeLayer = class("MiningHomeLayer", BaseLayer);

CREATE_SCENE_FUN(MiningHomeLayer);
CREATE_PANEL_FUN(MiningHomeLayer);

function MiningHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.mining.miningHomeLayer");
end

function MiningHomeLayer:loadHomeData(data)
    self.homeInfo = data;
    self:refreshUI();
end

function MiningHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function MiningHomeLayer:refreshBaseUI()

end

function MiningHomeLayer:refreshUI()
    if not self.isShow then
        return;
    end

end

function MiningHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_go         = TFDirector:getChildByPath(ui, 'btn_go');
end

--填充主页信息
function MiningHomeLayer:loadHomeInfo()

end


function MiningHomeLayer.onGoClickHandle(sender)
    local self = sender.logic;

    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2101)
    if teamLev < openLev then
        --toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel,openLev))
        return
    end

    MiningManager:requestMiningInfo()
end

function MiningHomeLayer:removeUI()
    self.super.removeUI(self);

end

function MiningHomeLayer:registerEvents()
    self.super.registerEvents(self);

    self.btn_go.logic    = self;   
    self.btn_go:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGoClickHandle),1);

end

function MiningHomeLayer:removeEvents()
    self.super.removeEvents(self);
    -- TFDirector:removeMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack);
end

return MiningHomeLayer;
