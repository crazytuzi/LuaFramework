
local WushBuyLayer = class("WushBuyLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.dead_battle_buy_info")

function WushBuyLayer:ctor(jsonFile, _, startPt)
    self.super.ctor(self, jsonFile)
    if startPt then
        self._startPt = startPt or self._startPt
    else
        local winSize = CCDirector:sharedDirector():getWinSize()
        self._startPt = ccp(winSize.width/2, winSize.height/2)
    end    

    --self:showAtCenter(true)

    self:getLabelByName("Label_txt1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_txt2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_txt3"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_star"):createStroke(Colors.strokeBrown, 1)

    self:registerBtnClickEvent("Button_get", function()
        if self._price and self._price > G_Me.userData.gold then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        self:showBuy()
    end)

end

function WushBuyLayer.create(...)
    local layer = WushBuyLayer.new("ui_layout/wush_finishBuy.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function WushBuyLayer:onLayerEnter( )
    self:closeAtReturn(true)
    self:setClickClose(true)
    self:showAnimation(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BUY, self._onBuyRsp, self)
    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )
    self:updateView()
end

function WushBuyLayer:onBackKeyEvent( ... )
    --self:animationToClose()
    self:showAnimation(false)
    return true
end

function WushBuyLayer:_onBuyRsp( data)
    if data.ret == 1 then
        self:updateView()
        G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
    end
end


function WushBuyLayer:updateView()
    -- local item = G_Goods.convert(3, 49)
    -- self:getImageViewByName("Image_icon"):loadTexture(item.icon)
    self:getLabelByName("Label_star"):setText(G_Me.wushData:getStarTotal())
    local id = G_Me.wushData._buyId
    if id > 0 then
        local info = dead_battle_buy_info.get(id)
        self._price = info.discount
        local g = G_Goods.convert(info.item_type, info.item_id)
        self:getLabelByName("Label_name"):setText(g.name)
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[g.quality])
        self:getImageViewByName("Image_icon"):loadTexture(g.icon)
        self:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(g.quality))
        self:getImageViewByName("Image_border"):loadTexture(G_Path.getEquipColorImage(g.quality,info.item_type))
        self:getLabelByName("Label_num"):setText("x"..info.item_num)
        self:getLabelByName("Label_num"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_money1"):setText(info.price)
        self:getLabelByName("Label_money2"):setText(info.discount)
        if info.price == info.discount then
            self:getLabelByName("Label_money3"):setText(info.price)
            self:getPanelByName("Panel_normal"):setVisible(false)
            self:getPanelByName("Panel_special"):setVisible(true)
        else
            self:getPanelByName("Panel_normal"):setVisible(true)
            self:getPanelByName("Panel_special"):setVisible(false)
        end
    end
    if G_Me.wushData._bought then
        self:getButtonByName("Button_get"):setVisible(false)
        self:getImageViewByName("Image_got"):setVisible(true)
    else
        self:getButtonByName("Button_get"):setVisible(true)
        self:getImageViewByName("Image_got"):setVisible(false)
    end
end

local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if color then
        label:setColor(color)
    end
    
    label:setText(text)

    if stroke then
        label:createStroke(stroke, 1)
    end
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the img with name: "..name)
    img:loadTexture(texture, texType)
    
end

function WushBuyLayer:showBuy( )

    local id = G_Me.wushData._buyId
    if id > 0 then
        local info = dead_battle_buy_info.get(id)
        local goods = G_Goods.convert(info.item_type, info.item_id, info.item_num)
        local newPrice = info.discount
        
        -- 元宝购买提示
        local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(goods, newPrice, function(_layer)

            _layer:animationToClose()
            self:showAnimation(false)
            G_HandlersManager.wushHandler:sendBuy()
            
        end)

        uf_sceneManager:getCurScene():addChild(layer)
        
    end

end


function WushBuyLayer:showAnimation( show )
    show = show or false
    local startScale = 1
    local endScale = 1
    local startPos = ccp(0,0)
    local endPos = ccp(0,0)
    local _size = self:getContentSize()
    if show then
        startScale = 0.2
        endScale = 1
        startPos = self._startPt
        endPos = ccp(_size.width/2,_size.height/2)
    else
        startScale = 1
        endScale = 0.2
        startPos = ccp(_size.width/2,_size.height/2)
        endPos = self._startPt
    end
    local img = self:getImageViewByName("Image_5")
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2,endPos))
    array:addObject(CCScaleTo:create(0.2,endScale))
    local sequence = transition.sequence({CCSpawn:create(array),
    CCCallFunc:create(
        function()
            if not show then
                self:close() 
            end
        end),
})
    img:runAction(sequence)
end

function WushBuyLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushBuyLayer:onClickClose( ... )
    self:showAnimation(false)
    return true
end

function WushBuyLayer:onLayerUnload( ... )

end

return WushBuyLayer
