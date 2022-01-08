local BloodyHomeLayer = class("BloodyHomeLayer", BaseLayer);

CREATE_SCENE_FUN(BloodyHomeLayer);
CREATE_PANEL_FUN(BloodyHomeLayer);

--[[
血战
]]

function BloodyHomeLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodyHomeLayer");
end

function BloodyHomeLayer:loadHomeData(data)
    self.homeInfo = data;
    self:refreshUI();
end

function BloodyHomeLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function BloodyHomeLayer:refreshBaseUI()

end

function BloodyHomeLayer:refreshUI()
    if not self.isShow then
        return;
    end

end

function BloodyHomeLayer:initUI(ui)
    self.super.initUI(self,ui);
    -- self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_go         = TFDirector:getChildByPath(ui, 'btn_go');
end

--填充主页信息
function BloodyHomeLayer:loadHomeInfo()

end


function BloodyHomeLayer.onGoClickHandle(sender)
    local self = sender.logic;

    -- local openLevel = 13
    -- local guideInfo = PlayerGuideData:objectByID(1601)
    -- if guideInfo then
    --     openLevel = guideInfo.open_lev
    -- end

    -- local openLevel = PlayerGuideManager:GetBloodFightOpenLevel()
    local openLevel = FunctionOpenConfigure:getOpenLevel(501)
    if MainPlayer:getLevel() < openLevel then
        --toastMessage("血战将在"..openLevel.."级开放")
        toastMessage(stringUtils.format(localizable.bloodHomeLayer_text1 , openLevel))
        return
    end

    BloodFightManager:EnterBlood()
end

function BloodyHomeLayer:removeUI()
    self.super.removeUI(self);

end

function BloodyHomeLayer:registerEvents()
    self.super.registerEvents(self);

    self.btn_go.logic    = self;   
    self.btn_go:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGoClickHandle),1);

end

function BloodyHomeLayer:removeEvents()
    self.super.removeEvents(self);
    -- TFDirector:removeMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack);
end

return BloodyHomeLayer;
