--[[
******元宝不足（首冲）*******

    -- by haidong.gan
    -- 2013/11/27
]]
local NeedFirstPayLayer = class("NeedFirstPayLayer", BaseLayer);

CREATE_SCENE_FUN(NeedFirstPayLayer);
CREATE_PANEL_FUN(NeedFirstPayLayer);


function NeedFirstPayLayer:ctor(data)
    self.super.ctor(self,data);

    self:init("lua.uiconfig_mango_new.pay.NeedFirstPayLayer");
end

function NeedFirstPayLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close 		  = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_cancel       = TFDirector:getChildByPath(ui, 'btn_cancel');
    self.btn_pay          = TFDirector:getChildByPath(ui, 'btn_pay');
    self.btn_vip        = TFDirector:getChildByPath(ui, 'btn_vip');
    self.btn_get        = TFDirector:getChildByPath(ui, 'btn_get');

    self.panel_rewardArr          = {};

    for i=1,6 do
        self.panel_rewardArr[i] = TFDirector:getChildByPath(ui, 'panel_reward' .. i);
    end

    -- self.node_reward    = TFDirector:getChildByPath(ui, 'node_reward');

    self:AddResEffect(self.panel_rewardArr[1],"firstPay_buttom",69,70,0,0)
    self:AddResEffect(self.panel_rewardArr[1],"firstPay_top",69,70,0,10)
end

function NeedFirstPayLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function NeedFirstPayLayer:refreshBaseUI()

end

function NeedFirstPayLayer:refreshUI()
    if not self.isShow then
        return;
    end

    local rewardList = PayManager:getRewardListForFirstPay();

    local index = 1;
    for reward in rewardList:iterator() do
        Public:loadIconNode(self.panel_rewardArr[index],reward);
        index = index + 1;
    end



    -- if PayManager:IsUserFirstPay()


    -- true 可领取  false不可以领取
    if PayManager:getFirstChargeState() then
        self.btn_pay:setVisible(false)
        self.btn_get:setVisible(true)
    else
        self.btn_pay:setVisible(true)
        self.btn_get:setVisible(false)
    end
end


function NeedFirstPayLayer:AddResEffect(widget, effName, posX, posY, index,zOrder)
  TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/"..effName..".xml")
  local effect = TFArmature:create(effName.."_anim")
  if effect == nil then
    return
  end

  effect:playByIndex(index, -1, -1, 1)
  effect:setPosition(ccp(posX, posY))
  effect:setZOrder(zOrder)
  widget:addChild(effect)
end

function NeedFirstPayLayer:removeUI()
    self.super.removeUI(self);
end


function NeedFirstPayLayer.onPayClickHandle(sender)
    local self = sender.logic;
    PayManager:showPayHomeLayer(AlertManager.NONE)
    -- AlertManager:closeLayer(self);
end

function NeedFirstPayLayer.onVipClickHandle(sender)
   local self = sender.logic;
   PayManager:showVipLayer(AlertManager.NONE);
   AlertManager:closeLayer(self);
end

function NeedFirstPayLayer.onclikFirstPayReward(sender)
   local self = sender.logic;

   PayManager:requestFirstChargeReward()
   AlertManager:closeLayer(self);
end

--注册事件
function NeedFirstPayLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_cancel);
    self.btn_close:setClickAreaLength(100);

    self.btn_pay.logic=self;
    self.btn_pay:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onPayClickHandle),1);

    self.btn_vip.logic=self;
    self.btn_vip:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onVipClickHandle),1);



    self.btn_get.logic=self;
    self.btn_get:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onclikFirstPayReward),1);

        TFAudio.playEffect("sound/effect/chuangong-hunpoyidong.mp3",false)
    -- self.soundTimer = TFDirector:addTimer(1000,-1,nil,function ( )
    -- end)
end

function NeedFirstPayLayer:removeEvents()
    -- if self.soundTimer then
    --     TFDirector:removeTimer(self.soundTimer)
    --     self.soundTimer = nil
    -- end
end
return NeedFirstPayLayer;
