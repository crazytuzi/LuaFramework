
local LegionLevelUpLayer = class("LegionLevelUpLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

require("app.cfg.corps_info")

function LegionLevelUpLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)


    self._levelLabel = self:getLabelByName("Label_levelValue")
    self._maxLabel = self:getLabelByName("Label_maxValue")
    self._levelNextLabel = self:getLabelByName("Label_levelNextValue")
    self._maxNextLabel = self:getLabelByName("Label_maxNextValue")
    self._expLabel = self:getLabelByName("Label_exp")
    self._expValueLabel = self:getLabelByName("Label_expValue")
    self._expLabel:createStroke(Colors.strokeBrown, 1)
    self._expValueLabel:createStroke(Colors.strokeBrown, 1)
    self:registerBtnClickEvent("Button_tech", function(widget) 
        self:onLevelUp()
        end)
end

function LegionLevelUpLayer:onLevelUp()
    local level = G_Me.legionData:getCorpDetail().level
    local exp = G_Me.legionData:getCorpDetail().exp
    local expNeed = corps_info.get(level).exp
    if exp < expNeed then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_LEVEL_MORE_EXP"))
    end

    if not corps_info.get(level+1) then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_LEVEL_MAX"))
    end

    G_HandlersManager.legionHandler:sendCorpUpLevel()
end

function LegionLevelUpLayer.create(...)
    local layer = LegionLevelUpLayer.new("ui_layout/legion_LevelUpLayer.json",require("app.setting.Colors").modelColor,...) 
    layer:updateView()
    return layer
end

function LegionLevelUpLayer:_onRefresh(  )
    self:updateView()
end

function LegionLevelUpLayer:_onClose( data )
    if data.ret == 1 then
        local levelTxt = G_lang:get("LANG_LEGION_LEVEL_UP", {level=data.level})
        G_MovingTip:showMovingTip(levelTxt)
    end
    self:close()
end

function LegionLevelUpLayer:updateView( )
    local level = G_Me.legionData:getCorpDetail().level
    if not corps_info.get(level+1) then
        self:close()
        return
    end
    self._levelLabel:setText(level)
    self._levelNextLabel:setText(level+1)
    self._maxLabel:setText(corps_info.get(level).number)
    self._maxNextLabel:setText(corps_info.get(level+1).number)

    local exp = G_Me.legionData:getCorpDetail().exp
    local expNeed = corps_info.get(level).exp
    self._expValueLabel:setText(exp.."/"..expNeed)
    local txtColor = exp >= expNeed and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01
    self._expValueLabel:setColor(txtColor)
end

function LegionLevelUpLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_LEVEL_BROADCAST, self._onRefresh, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_UPLEVEL, self._onClose, self)
    EffectSingleMoving.run(self:getImageViewByName("Image_click"), "smoving_wait", nil , {position = true} )
end

function LegionLevelUpLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return LegionLevelUpLayer