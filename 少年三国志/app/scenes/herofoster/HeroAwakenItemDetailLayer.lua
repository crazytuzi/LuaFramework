-- HeroAwakenItemDetailLayer

local HeroAwakenItemDetailLayer = class("HeroAwakenItemDetailLayer", UFCCSModelLayer)
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local BagConst = require("app.const.BagConst")
-- 觉醒道具三种弹窗样式，1是确认装备，2是装备状态，3是合成状态，4是去获取状态
HeroAwakenItemDetailLayer.STATE_CERTAIN = 1
HeroAwakenItemDetailLayer.STATE_EQUIP = 2
HeroAwakenItemDetailLayer.STATE_COMPOSE = 3
HeroAwakenItemDetailLayer.STATE_GET = 4


function HeroAwakenItemDetailLayer.create(itemId, state, ...)
    return HeroAwakenItemDetailLayer.new("ui_layout/HeroAwakenItemDetailLayer.json", Colors.modelColor, itemId, state, ...)
end

function HeroAwakenItemDetailLayer:ctor(_, _, itemId, state, callback, callbackNowState)
    
    HeroAwakenItemDetailLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    self:adapterWithScreen()
    
    -- 道具id
    self._itemId = itemId
    -- 页面状态，根据不同状态显示略有不同
    self._state = state or HeroAwakenItemDetailLayer.STATE_CERTAIN
    -- 回调通知
    self._callback = callback

    -- 从途径引导返回时可能需要立即返回
    self._callbackNowState = callbackNowState
    
end

function HeroAwakenItemDetailLayer:setState(state)
    self._state = state or self._state
end

function HeroAwakenItemDetailLayer:onLayerEnter()
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
        
    self:updateView()

    if self._callbackNowState then

        self._callback(self._callbackNowState, self)
    end
    
end

function HeroAwakenItemDetailLayer:reloadCheckBox(_flag)
    self:getPanelByName("Panel_checkbox"):setVisible(true)
    self:getCheckBoxByName("CheckBox_select"):setSelectedState(_flag)
end 

function HeroAwakenItemDetailLayer:updateView()
    
    -- 按钮响应
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_close", _onClose)
    self:enableAudioEffectByName("Button_close", false)

    -- 更新界面
    local itemInfo = item_awaken_info.get(self._itemId)
    assert(itemInfo, "Could not find the awaken item with id: "..tostring(self._itemId))
    
    -- 觉醒道具的名称
    self:updateLabel("Label_item_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    -- 背景
    self:updateImageView("Image_bg", {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
    -- icon
    self:updateImageView("Image_icon", {texture=itemInfo.icon})
    -- 描述
    self:updateLabel("Label_item_desc", {text=itemInfo.comment})
    
    --checkbox
    self:updateLabel("Label_select", {text=G_lang:get("LANG_AWAKEN_TAGS_TEXT"),  stroke=Colors.strokeBrown, strokeSize=2})
    self:updateLabel("Label_select_name", {text=itemInfo.name, color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown, strokeSize=2})
    
    -- 道具属性
    self:updateLabel("Label_content_title", {text=G_lang:get("LANG_AWAKEN_ITEM_DETAIL_PROPERTY_DESC"), stroke=Colors.strokeBrown, strokeSize=2})
    
    -- 最多三种属性
    local MergeEquipment = require "app.data.MergeEquipment"
    for i=1, 3 do
        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(itemInfo["str_type_"..i], itemInfo["str_value_"..i])
        self:updateLabel("Label_content"..i, {visible=itemInfo["str_type_"..i] ~= 0, text=strtype.." +"..strvalue})
    end
    
    -- 根据不同状态界面做微调
    self:updateImageView("Image_certain", {visible=(self._state == HeroAwakenItemDetailLayer.STATE_CERTAIN)})
    self:updateImageView("Image_equip", {visible=(self._state == HeroAwakenItemDetailLayer.STATE_EQUIP)})
    self:updateImageView("Image_compose", {visible=(self._state == HeroAwakenItemDetailLayer.STATE_COMPOSE)})
    self:updateImageView("Image_get", {visible=(self._state == HeroAwakenItemDetailLayer.STATE_GET)})
    
    -- 数量也要区分不同状态
    self:updatePanel("Panel_item_amount", {visible=true})
    
    self:updateLabel("Label_item_amount_desc", {text=G_lang:get("LANG_AWAKEN_ITEM_DETAIL_AMOUNT_DESC")})
    self:updateLabel("Label_item_amount", {text=G_Me.bagData:getAwakenItemNumById(self._itemId)})
    
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end
    
    -- 装备按钮有一个特效
    if self._state == HeroAwakenItemDetailLayer.STATE_EQUIP then
        local EffectNode = require "app.common.effects.EffectNode"
        local node = EffectNode.new("effect_around2")
        node:setScale(1.8)
        node:setPositionY(-3)
        node:play()

        local btn = self:getButtonByName("Button_decide")
        btn:removeAllNodes()
        btn:addNode(node)
    end
    
    self:registerBtnClickEvent("Button_decide", function()
        if self._state == HeroAwakenItemDetailLayer.STATE_CERTAIN then
            _onClose()
        elseif self._callback then
            print("hehe")
            -- 打开新的，记得隐藏  白色觉醒道具不隐藏 
            self:getPanelByName("Panel_checkbox"):setVisible(item_awaken_info.get(self._itemId).quality <= BagConst.QUALITY_TYPE.WHITE)
            self._callback(self._state, self)
        end
         
    end)
    
    

    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN_MARK) and item_awaken_info.get(self._itemId).quality < BagConst.QUALITY_TYPE.RED then 
        self:getPanelByName("Panel_checkbox"):setVisible(true)
        -- 先判断是否应该选中
        self:getCheckBoxByName("CheckBox_select"):setSelectedState(G_Me.shopData:isAwakenTags(self._itemId))

        self:registerCheckboxEvent("CheckBox_select", function ( ... )
            self:_onCheckBoxChange(...)
        end)
    else 
        self:getPanelByName("Panel_checkbox"):setVisible(false)
    end 

    -- 另外一个获取按钮只有在合成状态下且觉醒道具是绿色或者蓝色的情况下
    -- 策划说改成都可以去获取
    if self._state == HeroAwakenItemDetailLayer.STATE_COMPOSE then --and (itemInfo.quality == 2 or itemInfo.quality == 3) then
        
        self:updateButton("Button_get", {visible=true})
        
        self:registerBtnClickEvent("Button_get", function()
            if self._callback then
                self._callback(HeroAwakenItemDetailLayer.STATE_GET, self)
            end
        end)
        
        -- 还要摆下位置
        self:getButtonByName("Button_decide"):setPositionX(120)
        self:getButtonByName("Button_get"):setPositionX(-120)
        
    else
        
        self:updateButton("Button_get", {visible=false})
        self:getButtonByName("Button_decide"):setPositionX(0)
    end
end

function HeroAwakenItemDetailLayer:_onCheckBoxChange( checkbox, checkType, isCheck )
    if isCheck then 
        if not G_Me.shopData:canAdd(self._itemId) then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_TAGS_MAX"))
            checkbox:setSelectedState(false)
            return
        end 
        G_HandlersManager.awakenShopHandler:sendAddShopTag(self._itemId)
    else
        G_HandlersManager.awakenShopHandler:sendDelShopTag(self._itemId)
    end 
end

function HeroAwakenItemDetailLayer:updateLabel(name, params)
    
    local label = self:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil and label.createStroke then
        label:createStroke(params.stroke, params.strokeSize or 1)
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

function HeroAwakenItemDetailLayer:updateImageView(name, params)
    
    local img = self:getImageViewByName(name)
    assert(img, "Could not find the image with name: "..name)
    
    if params.texture ~= nil and img.loadTexture then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil and img.setVisible then
        img:setVisible(params.visible)
    end
    
end

function HeroAwakenItemDetailLayer:updateButton(name, params)
    
    local btn = self:getButtonByName(name)
    assert(btn, "Could not find the button with name: "..name)
    
    if params.visible ~= nil and btn.setVisible then
        btn:setVisible(params.visible)
    end
    
end

function HeroAwakenItemDetailLayer:updatePanel(name, params)
    
    local panel = self:getPanelByName(name)
    assert(panel, "Could not find the panel with name: "..name)
    
    if params.visible ~= nil and panel.setVisible then
        panel:setVisible(params.visible)
    end
    
end

return HeroAwakenItemDetailLayer


