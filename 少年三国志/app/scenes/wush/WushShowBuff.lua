require("app.cfg.dead_battle_info")

local WushShowBuff = class("WushShowBuff", UFCCSModelLayer)
-- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WushShowBuff:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    self:setClickClose(true)
    self:playAnimation("AnimationAlpha",function() 
    end)
    require("app.common.effects.EffectSingleMoving").run(self:getImageViewByName("Image_10"), "smoving_wait", nil , {position = true} )
    -- self:enableAudioEffectByName("Button_close", false)

    -- self:registerBtnClickEvent("Button_close", function()
    --     self:animationToClose()
    --             local soundConst = require("app.const.SoundConst")
    --             G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    -- end)

end

function WushShowBuff:onLayerEnter( )
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self:closeAtReturn(true)
end

function WushShowBuff:init()
    local WushBuffChoose = require("app.scenes.wush.WushBuffChoose")
    WushShowBuff.initBuffTable(self:getPanelByName("Panel_buffList"))
end

function WushShowBuff.initBuffTable(panel)
    -- local panel = self:getPanelByName("Panel_buffList")
    local itemWidth = 200
    local itemHeight = 45
    local index = 0
    local offsetx = 10
    local offsety = 130
    local list = G_Me.wushData:getBuffList()
    for k,v in pairs(list) do
        local x = (index%2)*itemWidth + offsetx
        local y = offsety - math.floor(index/2)*itemHeight
        WushShowBuff.addBuff(index,{type=k,value=v},panel,x,y)
        index = index + 1
    end
end

function WushShowBuff.addBuff(id,buffData,_panel,x,y)
    local btn = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/wush_buffCell2.json")
    _panel:addChild(btn)
    btn:setTag(id)
    btn:setPosition(ccp(x,y))
    -- local desc = G_lang.getGrowthTypeName(buffData.type)
    -- local value = G_lang.getGrowthValue(buffData.type,buffData.value)
    -- print(buffData.type.." "..buffData.value.." "..desc.." "..value)
    local desc,value = G_Me.wushData.convertAttrTypeAndValue(buffData.type,buffData.value)
    local descLabel = btn:getChildByName("Label_desc")
    if descLabel then
        descLabel = tolua.cast(descLabel,"Label")
        descLabel:setText(desc)
    end
    local valueLabel = btn:getChildByName("Label_value")
    if valueLabel then
        valueLabel = tolua.cast(valueLabel,"Label")
        valueLabel:setText("+"..value)
    end
end

function WushShowBuff:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushShowBuff:onLayerUnload( ... )

end

return WushShowBuff
