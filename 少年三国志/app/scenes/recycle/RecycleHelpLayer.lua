-- RecycleHelpLayer

local RecycleHelpLayer = class("RecycleHelpLayer", UFCCSModelLayer)

function RecycleHelpLayer.create(...)
    return RecycleHelpLayer.new('ui_layout/recycle_recycleHelpLayer.json', Colors.modelColor, ...)
end

function RecycleHelpLayer:ctor(_, _, title, content)
    
    RecycleHelpLayer.super.ctor(self)
    
    local labelTitle = self:getLabelByName("Label_title")
    labelTitle:setText(title)
    labelTitle:createStroke(Colors.strokeBlack, 1)
    
    local labelContent = self:getLabelByName("Label_content")
    labelContent:setText(content)
    
end

function RecycleHelpLayer:onLayerEnter()
    
    self:adapterWithScreen()
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:closeAtReturn(true)

    -- 绑定关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end
    
    self:registerBtnClickEvent("Button_close", _onClose)
    self:registerBtnClickEvent("Button_close1", _onClose)
    
    self:enableAudioEffectByName("Button_close1", false)
    self:enableAudioEffectByName("Button_close", false)
    
end

return RecycleHelpLayer

