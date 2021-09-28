-- BagAwakenItemSellDetailLayer

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
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
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

local BagAwakenItemSellDetailLayer = class("BagAwakenItemSellDetailLayer", UFCCSModelLayer)

function BagAwakenItemSellDetailLayer.create(...)
    return BagAwakenItemSellDetailLayer.new("ui_layout/shop_AwakenItemSellDetailLayer.json", Colors.modelColor, ...)
end

function BagAwakenItemSellDetailLayer:ctor(_, _, good, priceType, priceUnit, callback)
    
    BagAwakenItemSellDetailLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:showAtCenter(true)
    
    -- 通用控件，右上角的关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_close", _onClose)
    self:enableAudioEffectByName("Button_close", false)
    
    self:registerBtnClickEvent("Button_cancel", _onClose)
    self:enableAudioEffectByName("Button_cancel", false)
    
    -- 名称
    _updateLabel(self, "Label_name01", {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
    -- icon
    _updateImageView(self, "ImageView_item", {texture=good.icon})
    -- icon背景
    _updateImageView(self, "ImageView_item_bg01", {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
    -- 数量
    _updateLabel(self, "Label_num", {text=good.size})
    -- 品级框
    local frame = self:getButtonByName("Button_item")
    frame:loadTextureNormal(G_Path.getEquipColorImage(good.quality))
    frame:loadTexturePressed(G_Path.getEquipColorImage(good.quality))

    self:registerBtnClickEvent("Button_item", function()
        require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
    end)
    
    _updateLabel(self, "Label_jia1", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jian1", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jia10", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jian10", {stroke=Colors.strokeBrown})
    
    -- 分解获得神魂
    _updateLabel(self, "Label_priceTag", {text=G_lang:get("LANG_BAG_AWAKEN_ITEM_SELL_DETAIL_PRICE_DESC")})
    
    -- 价格类型
    local _texture, _texType = G_Path.getPriceTypeIcon(priceType)
    _updateImageView(self, "ImageView_priceTag", {texture=_texture, texType=_texType})
    
    -- 更新出售数量和价格
    local count = 1
    local function _updateCount(amount)
        -- 数量
        count = math.max(1, math.min(count + (amount or 0), good.size))
        _updateLabel(self, "Label_count", {text=count})
        
        -- 价格
        _updateLabel(self, "Label_price", {text=priceUnit * count})
    end
    
    -- 更新出售数量和价格
    _updateCount()
    
    -- 按钮响应
    self:registerBtnClickEvent("Button_add01", function()
        _updateCount(1)
    end)
    
    self:registerBtnClickEvent("Button_subtract01", function()
        _updateCount(-1)
    end)
    
    self:registerBtnClickEvent("Button_add10", function()
        _updateCount(10)
    end)
    
    self:registerBtnClickEvent("Button_subtract10", function()
        _updateCount(-10)
    end)
    
    self:registerBtnClickEvent("Button_buy", function()
        if callback then
            callback(count, self)
        end
    end)
    
    
end

return BagAwakenItemSellDetailLayer
