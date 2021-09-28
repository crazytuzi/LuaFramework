-- SharingLayer

local SharingLayer = class("SharingLayer", UFCCSModelLayer)

-- layout
SharingLayer.LAYOUT_ACTIVITY_STYLE = "ui_layout/activity_ActivityShareDetailLayer.json"
SharingLayer.LAYOUT_SETTING_STYLE = "ui_layout/common_SettingShareDetailLayer.json"


function SharingLayer.create(layout, ...)
    return SharingLayer.new(layout, ...)
end

function SharingLayer:ctor(_, _, updates)
    
    SharingLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:adapterWithScreen()
    
    -- 通用控件，右上角的关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_close", _onClose)
    self:enableAudioEffectByName("Button_close", false)
    
    for i=1, #updates do
        local update = updates[i]
        self:updateLabel(update[1], update[2])
        self:updateImageView(update[1], update[2])
    end
    
end

function SharingLayer:onLayerEnter()
    
    -- 根据开关调整分享按钮的位置
    -- 这里必须在onLayerEnter里做
    if not (G_Setting:get("open_wechat_share") == "1" and G_Setting:get("open_weibo_share") == "1") then

        local btnWeChat = self:getButtonByName("Button_to_wechat")
        local btnWeibo = self:getButtonByName("Button_to_weibo")

        btnWeChat:setPositionX(0)
        btnWeibo:setPositionX(0)

        btnWeChat:setVisible(G_Setting:get("open_wechat_share") == "1")
        btnWeibo:setVisible(G_Setting:get("open_weibo_share") == "1")

    end
    
end

function SharingLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function SharingLayer:updateLabel(name, params)
    
    local label = self:getLabelByName(name)
    if not label then return end
    
    if params.stroke ~= nil and label.createStroke then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil and label.setColor then
        label:setColor(params.color)
    end
    
    if params.text ~= nil and label.setText then
        label:setText(params.text)
    end
    
    if params.visible ~= nil and label.setVisible then
        label:setVisible(params.visible)
    end

end

function SharingLayer:updateImageView(name, params)
    
    local img = self:getImageViewByName(name)
    if not img then return end
    
    if params.texture ~= nil and img.loadTexture then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil and img.setVisible then
        img:setVisible(params.visible)
    end
    
end

return SharingLayer
