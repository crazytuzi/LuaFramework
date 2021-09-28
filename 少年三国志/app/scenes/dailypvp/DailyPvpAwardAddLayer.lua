
local DailyPvpAwardAddLayer = class("DailyPvpAwardAddLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function DailyPvpAwardAddLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)
end

function DailyPvpAwardAddLayer.create(...)
    local layer = DailyPvpAwardAddLayer.new("ui_layout/dailypvp_AwardAddLayer.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function DailyPvpAwardAddLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, self.updateView, self)

    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )

    self:updateView()
end

function DailyPvpAwardAddLayer:updateView()
    self:getLabelByName("Label_player_value"):setText(G_Me.dailyPvpData:getOnlineBuff().."%")
    self:getLabelByName("Label_friend_value"):setText(G_Me.dailyPvpData:getFriendBuff().."%")
    self:getLabelByName("Label_legion_value"):setText(G_Me.dailyPvpData:getCorpBuff().."%")
    self:getLabelByName("Label_totalAdd"):setText(G_Me.dailyPvpData:getTotalBuff().."%")
end

function DailyPvpAwardAddLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return DailyPvpAwardAddLayer