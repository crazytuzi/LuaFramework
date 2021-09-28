
local WheelGold = class("WheelGold", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WheelGold:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)
    self._id = 1
end

function WheelGold.create(id,...)
    local layer = WheelGold.new("ui_layout/wheel_Gold.json",require("app.setting.Colors").modelColor,...) 
    layer:setId(id)
    return layer
end

function WheelGold:setId(id)
    self._id = id
    if id == 1 then
        self:getImageViewByName("Image_title"):loadTexture("ui/text/txt/xylp_putongjiangchi.png")
        self:getImageViewByName("Image_alotgold"):loadTexture("ui/wheel/jiangchi_putong.png")
        self:getLabelByName("Label_txt"):setText(G_lang:get("LANG_WHEEL_GOLD",{num=1})) 
    else
        self:getImageViewByName("Image_title"):loadTexture("ui/text/txt/xylp_haohuajiangchi.png")
        self:getImageViewByName("Image_alotgold"):loadTexture("ui/wheel/jiangchi_haohua.png")
        self:getLabelByName("Label_txt"):setText(G_lang:get("LANG_WHEEL_GOLD",{num=10})) 
    end
end

function WheelGold:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_INFO, self._onWheelInfoRsp, self)
    G_HandlersManager.wheelHandler:sendWheelInfo()
    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )
end

function WheelGold:_onWheelInfoRsp(data)
    self:getLabelByName("Label_yuanbao"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_yuanbaonum"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_yuanbaonum"):setText(self._id == 1 and G_Me.wheelData.pool or G_Me.wheelData.pool2)
end

function WheelGold:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return WheelGold

