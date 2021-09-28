-- RichShopItemSellLayer

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

local RichShopItemSellLayer = class("RichShopItemSellLayer", UFCCSModelLayer)

function RichShopItemSellLayer.create(...)
    return RichShopItemSellLayer.new("ui_layout/dafuweng_ShopPurchaseDialog.json", Colors.modelColor, ...)
end

function RichShopItemSellLayer:ctor(_, _, typeId,value,size, priceType, priceUnit,maxLimit, callback)
    
    RichShopItemSellLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:showAtCenter(true)

    self:getLabelByName("Label_times"):setVisible(false)
    
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
    
    local good = G_Goods.convert(typeId,value,size)
    -- 名称
    _updateLabel(self, "Label_name01", {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
    -- icon
    _updateImageView(self, "ImageView_item", {texture=good.icon})
    -- 数量
    _updateLabel(self, "Label_numCount", {text="x"..good.size,stroke=Colors.strokeBrown})
    -- local has = G_Me.bagData:getPropCount(value)

    -- 物品的品质背景
    self:getImageViewByName("ImageView_item"):setZOrder(1)
    self:getLabelByName("Label_numCount"):setZOrder(2)
    local imgColorBg = ImageView:create()
    imgColorBg:loadTexture(G_Path.getEquipIconBack(good.quality))
    self:getImageViewByName("Image_7"):addChild(imgColorBg)

    local has = 0
    if typeId == G_Goods.TYPE_ITEM then 
        has = G_Me.bagData:getItemCount(value)
    elseif typeId == G_Goods.TYPE_FRAGMENT then
        has = G_Me.bagData:getFragmentNumById(value)
    elseif typeId == G_Goods.TYPE_GOLD then
        has = G_Me.userData.gold
    elseif typeId == G_Goods.TYPE_MONEY then
        has = G_Me.userData.money
    elseif typeId == G_Goods.TYPE_KNIGHT then
        has = G_Me.bagData:getKnightNumByBaseId(value)
    elseif typeId == G_Goods.TYPE_EQUIPMENT then
        has = G_Me.bagData:getEquipmentNumByBaseId(value)
    elseif typeId == G_Goods.TYPE_TREASURE then
        has = G_Me.bagData:getTreasureNumByBaseId(value)
    elseif typeId == G_Goods.TYPE_TREASURE_FRAGMENT then
        has = G_Me.bagData:getTreasureFragmentNumById(value)
    elseif typeId == G_Goods.TYPE_WUHUN then
        has = G_Me.userData.essence
    elseif typeId == G_Goods.TYPE_CHUANGUAN then 
        has = G_Me.userData.tower_score
    elseif typeId == G_Goods.TYPE_SHENGWANG then 
        has = G_Me.userData.prestige
    elseif typeId == G_Goods.TYPE_MOSHEN then 
        has = G_Me.userData.medal
    elseif typeId == G_Goods.TYPE_CORP_DISTRIBUTION then
        has = G_Me.userData.corp_point
    elseif typeId == G_Goods.TYPE_AWAKEN_ITEM then 
        has = G_Me.bagData:getAwakenItemNumById(value)
    elseif typeId == G_Goods.TYPE_SHENHUN then 
        has = G_Me.userData.god_soul
    elseif typeId == G_Goods.TYPE_PET_SCORE then
        has = G_Me.userData.pet_points
    end

    _updateLabel(self, "Label_num", {text=G_lang:get("LANG_GOODS_NUM",{num=has})})
    -- 品级框
    local frame = self:getButtonByName("Button_item")
    frame:loadTextureNormal(G_Path.getEquipColorImage(good.quality,typeId))

    self:registerBtnClickEvent("Button_item", function()
        require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
    end)
    
    _updateLabel(self, "Label_jia1", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jian1", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jia10", {stroke=Colors.strokeBrown})
    _updateLabel(self, "Label_jian10", {stroke=Colors.strokeBrown})
    
    -- 分解获得神魂
    _updateLabel(self, "Label_priceTag", {text=G_lang:get("LANG_FU_PRICEDESC")})
    
    -- 价格类型
    self:getPanelByName("Panel_tagJinZi"):setVisible(priceType>0)
    if priceType > 0 then
        local _texture, _texType = G_Path.getPriceTypeIcon(priceType)
        _updateImageView(self, "ImageView_priceTag", {texture=_texture, texType=_texType})
    end
    
    -- 更新出售数量和价格
    local count = 1
    local function _updateCount(amount)
        -- 数量
        count = math.max(1, math.min(count + (amount or 0), maxLimit))
        _updateLabel(self, "Label_count", {text=count})
        _updateLabel(self, "Label_numCount", {text="x"..count*good.size})
        
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
        if G_Me.userData.gold < priceUnit * count then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        if callback then
            callback(count, self)
        end
    end)
    
    
end

function RichShopItemSellLayer:showCount(count)
    self:getLabelByName("Label_times"):setVisible(true)
    self:getLabelByName("Label_times"):setText(G_lang:get("LANG_ACTIVITY_DUI_HUAN_CI_SHU",{num=count}))
end

return RichShopItemSellLayer
