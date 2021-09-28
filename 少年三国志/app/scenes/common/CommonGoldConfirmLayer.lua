-- CommonGoldConfirmLayer

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the img with name: "..name)
    
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
end


local CommonGoldConfirmLayer = class("CommonGoldConfirmLayer", UFCCSModelLayer)

function CommonGoldConfirmLayer.create(...)
    return CommonGoldConfirmLayer.new('ui_layout/secretshop_GoldConfirmLayer.json', Colors.modelColor, ...)
end

-- callback为确认按钮回调
-- cancelCallback为取消回调
function CommonGoldConfirmLayer:ctor(_, _, good, price, callback, cancelCallback)
    
    CommonGoldConfirmLayer.super.ctor(self)
        
    self:adapterWithScreen()
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:closeAtReturn(true)

    local function _onClose()
        if cancelCallback then
            cancelCallback()
        end
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_no", _onClose)
    self:registerBtnClickEvent("Button_close", _onClose)

    self:enableAudioEffectByName("Button_ok", false)
    self:enableAudioEffectByName("Button_close", false)
    
    -- 商品名称
    _updateLabel(self, "Label_content_desc", {text=good.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[good.quality]})
    -- "花费："
    _updateLabel(self, "Label_price_desc", {text=G_lang:get("LANG_SECRET_SHOP_GOLD_TIP_PRICE_DESC")})
    -- 价格
    _updateLabel(self, "Label_price", {text=price})
    -- 数量
    _updateLabel(self, "Label_item_amount", {text="x"..good.size, stroke=Colors.strokeBrown, color=Colors.darkColors.DESCRIPTION})

    -- 头像
    _updateImageView(self, "ImageView_head", {texture=good.icon, texType=UI_TEX_TYPE_LOCAL})
    -- 品质框
    _updateImageView(self, "ImageView_headframe", {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})

    
    self:registerBtnClickEvent("Button_yes", function()
        if callback then 
            callback(self, good, price)
        end
    end)
end

return CommonGoldConfirmLayer



