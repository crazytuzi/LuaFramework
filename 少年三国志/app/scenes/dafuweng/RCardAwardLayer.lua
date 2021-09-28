
local RCardAwardLayer = class("RCardAwardLayer", UFCCSModelLayer)
local RCardSprite = require("app.scenes.dafuweng.RCardSprite")
require("app.cfg.recharge_card_info")

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function RCardAwardLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._awardPanel = self:getPanelByName("Panel_award")
    self._cards = {}

    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)
end

function RCardAwardLayer.show(id)
    local layer = RCardAwardLayer.new("ui_layout/dafuweng_RCardAward.json",require("app.setting.Colors").modelColor) 
    layer:setId(id)
    uf_sceneManager:getCurScene():addChild(layer)
end

function RCardAwardLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    EffectSingleMoving.run(self, "smoving_bounce")
end

function RCardAwardLayer:onBackKeyEvent( ... )
    self:animationToClose()
    return true
end

function RCardAwardLayer:setId(id)
    id = id or 1
    local edge = 0
    local width = 500
    local height = 550
    local yOffset = 0
    local info = recharge_card_info.get(id)
    for i = 1, 8 do 
        local card = RCardSprite:new()
        self._cards[i] = card
        card:setIndex(i)
        local data = {type=info["type_"..i],value=info["value_"..i],size=info["size_"..i],light=info["if_effect_"..i]}
        card:updateAward(id,data)
        self._awardPanel:addChild(card.node,2)
        card:registerTouchEvent(self,function ( )
            require("app.scenes.common.dropinfo.DropInfo").show(info["type_"..i], info["value_"..i])  
        end)
        card:setBasePositionXY(edge+(width-edge*2)/6*(((i-1)%3)*2+1),yOffset + height/6*((2-math.floor((i-1)/3))*2+1))
    end
end


return RCardAwardLayer

