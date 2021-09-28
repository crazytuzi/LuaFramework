local FunctionLevelConst = require "app.const.FunctionLevelConst"

local MainRootLayer = class("MainRootLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"

function MainRootLayer.create()
    return MainRootLayer.new("ui_layout/mainscene_MainScene.json")
end

function MainRootLayer:ctor(...)
    self.super.ctor(self, ...)
    self:adapterWithScreen()

end

function MainRootLayer:onLayerEnter()
    local bg = self:getImageViewByName("ImageView_bg")
    if bg then 
        bg:loadTexture(G_GlobalFunc.isNowDaily() and "ui/background/back_mainbt.png" or "ui/background/back_mainhy.png")
    end

    -- 2.0.0版本新特效不需要再额外添加太阳了
    -- if G_GlobalFunc.isNowDaily() then 
        -- self:_startPlaySunshine(3)
    -- end

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        G_GlobalFunc.showDayEffect(G_Path.DAY_NIGHT_EFFECT.MAIN_SCENE, self:getPanelByName("Panel_effect"))
    end

    local img = self:getImageViewByName("ImageView_Circle")
    if img then
        local plate = require("app.scenes.mainscene.KnightTurnplateLayer").new()    
        plate:getRootWidget():setName("plate")
        plate:init(img:getContentSize(), param1 and true or false)
        img:addNode(plate)      

    end

end


function MainRootLayer:_startPlaySunshine(nextPlayTime)  
    if not require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        return 
    end      

    self:_removeSunshineTimer()
    self._sunshineTimter = GlobalFunc.addTimer(nextPlayTime, function() 
        self:_removeSunshineTimer()

        if self._effectSun == nil then
            self._effectSun =EffectNode.new("effect_sunshine", function(event) 
                if event == "finish" then
                    self._effectSun:stop()
                    self:_startPlaySunshine( math.random(0, 1)*20+10)
                end
            end)
            self:getPanelByName("Panel_effect"):addNode(self._effectSun)
        end

      
        self._effectSun:play()  
    end)

end

function MainRootLayer:_removeSunshineTimer()
    if self._sunshineTimter ~= nil then
        GlobalFunc.removeTimer(self._sunshineTimter)
        self._sunshineTimter = nil 
    end 

end

function MainRootLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)

    self:_removeSunshineTimer()
end

return MainRootLayer

