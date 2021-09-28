
local WheelHelp = class("WheelHelp", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WheelHelp:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)
    for i = 1, 3 do 
        self:getLabelByName("Label_title"..i):setText(G_lang:get("LANG_WHEEL_HELPTITLE"..i))
        self:getLabelByName("Label_title"..i):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_txt"..i):setText(G_lang:get("LANG_WHEEL_HELP"..i,{num=G_Me.wheelData.jyRankScore}))
    end

    -- self:registerBtnClickEvent("Button_close", function ( ... )
    --     self:animationToClose()
    -- end)
end

function WheelHelp.create(...)
    local layer = WheelHelp.new("ui_layout/wheel_Help.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function WheelHelp:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )
end

return WheelHelp

