--[[
******奖励预览列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local GiftListMessage = class("GiftListMessage", BaseLayer);

CREATE_SCENE_FUN(GiftListMessage);
CREATE_PANEL_FUN(GiftListMessage);

function GiftListMessage:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.common.GiftListMessage");
end

function GiftListMessage:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close        = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_ok           = TFDirector:getChildByPath(ui, 'btn_ok');

    self.node_reward    = TFDirector:getChildByPath(ui, 'node_reward');

    self.btn_ok.logic   = self
end

function GiftListMessage:loadData(rewardId,isEnable,callback)
    self.rewardId = rewardId;
    self.isEnable = isEnable;
    self.callback = callback;
end

function GiftListMessage:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function GiftListMessage:refreshBaseUI()

end

function GiftListMessage:refreshUI()
    if not self.isShow then
        return;
    end
    self.node_reward:removeAllChildren();
    local rewardList = RewardConfigureData:GetRewardItemListById(self.rewardId);

    for reward in rewardList:iterator() do
        local index = rewardList:indexOf(reward);

        local reward_item =  Public:createIconNameNumNode(reward);
        if rewardList:length() > 5 then
            reward_item:setScale(0.7);
            reward_item:setPosition(ccp(30 + (index - 1)*90, 20));
        else
            reward_item:setScale(1);
            reward_item:setPosition(ccp(30 + (index - 1)*130, 20));
        end
        self.node_reward:addChild(reward_item);
    end

    self.btn_ok:setVisible(self.isEnable);
end

function GiftListMessage:removeUI()
   self.super.removeUI(self);
end

--注册事件
function GiftListMessage:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_ok);
    self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function(sender)
        local self      = sender.logic
        local callback  = self.callback
        AlertManager:close()
        if callback then
            callback()
        end
    end),1)
end

function GiftListMessage:removeEvents()

end
return GiftListMessage;
