--[[
******跨服个人战-奖励信息*******

    -- by ChiKui Peng
    -- 2016/4/18
    
]]

local KuaFuRewardLayer = class("KuaFuRewardLayer",BaseLayer)

function KuaFuRewardLayer:ctor(data)

    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuReward")
end

function KuaFuRewardLayer:initUI( ui )

    self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')

    self.txtList_Reward = {}
    for i=1,8 do
        self.txtList_Reward[i] = {}
        local page = TFDirector:getChildByPath(ui, 'bg_'..i)
        self.txtList_Reward[i].honor = TFDirector:getChildByPath(page, 'txt1')
        self.txtList_Reward[i].tongbi = TFDirector:getChildByPath(page, 'txt2')
    end
    self:setReward()
end

function KuaFuRewardLayer:setReward()
    local rewardList = ChampionsAwardData:getAllRewardDataByType(5)
    print("ChampionsAwardData:getAllRewardDataByType(5) = ",rewardList)
    for i=1,8 do
        local reward = rewardList[i]:getReward()
        self.txtList_Reward[i].honor:setText(reward[1].number)
        self.txtList_Reward[i].tongbi:setText(reward[2].number)
    end
end

function KuaFuRewardLayer:removeUI()
    self.super.removeUI(self)
end

function KuaFuRewardLayer:onShow()
    self.super.onShow(self)
end

function KuaFuRewardLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
end

function KuaFuRewardLayer:removeEvents()
    self.super.removeEvents(self)
end

return KuaFuRewardLayer