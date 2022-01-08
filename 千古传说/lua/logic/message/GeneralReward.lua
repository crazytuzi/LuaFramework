--[[
******礼包信息层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local GeneralReward = class("GeneralReward", BaseLayer)

--CREATE_SCENE_FUN(GeneralReward)
CREATE_PANEL_FUN(GeneralReward)


function GeneralReward:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.message.GeneralReward")
end


function GeneralReward:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok         = TFDirector:getChildByPath(ui, 'btn_ok')
    self.layer_reward   = {}

    for i=1,3 do
        local str = "layer_reward_"..i
        local layer_reward_temp  = TFDirector:getChildByPath(ui, str)
        local layer = require("lua.logic.item.RewardIcon"):new()
        layer_reward_temp:addChild(layer)
        self.layer_reward[i] = layer
    end

    self.btn_ok.logic       = self
end

function GeneralReward:removeUI()
	self.super.removeUI(self)
    self.itemid = nil
    self.btn_ok        = nil
    for i=1,3 do
        self.layer_reward[i]:dispose()
    end
    self.layer_reward  = nil
end


function GeneralReward:setReward( reward )
    local index = 1
    if #reward == 1 then
        index = 1
        self.layer_reward[1]:setVisible(true)
        self.layer_reward[2]:setVisible(false)
        self.layer_reward[3]:setVisible(false)
    else
        index = 2
        self.layer_reward[1]:setVisible(false)
        self.layer_reward[2]:setVisible(true)
        self.layer_reward[3]:setVisible(true)
    end

    for _,v in pairs(reward) do
        self.layer_reward[index]:setReward(v)
        index = index+ 1
    end
end

function GeneralReward.onOpenBtnClickHandle(sender)

    AlertManager:close(AlertManager.TWEEN_1);
end


function GeneralReward:registerEvents()
    self.super.registerEvents(self)
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOpenBtnClickHandle),1)
end


return GeneralReward
