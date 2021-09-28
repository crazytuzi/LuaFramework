--AttrTextTip.lua


local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local AttrTextTip = class ("AttrTextTip", function ( ... )
    return display.newNode()
end)


local MergeEquipment = require("app.data.MergeEquipment")


function AttrTextTip:ctor( )
    self._callbackFunc = nil
    self._richText = nil
    self._delayTime = 0
    --self:setCascadeOpacityEnabled(true)

    self._txt =   UFCCSNormalLayer.new("ui_layout/equipment_EquipmentAttrTip.json") 
    self._txt:enableLabelStroke("Label_txt", Colors.strokeBrown, 1)
    self:addChild(self._txt)
   -- local node = display.newNode()
   -- node:addChild(self._txt)
   -- node:retain()
   -- node:setCascadeOpacityEnabled(true)
    self._txt:setCascadeOpacityEnabled(true)

    

    --self.super.ctor(self, "moving_texttip3", 
    --function(key) 
    --    if key == "txt" then
    --        return node
    --    end
    --end,
    --function(event)
    --    if event == "finish" then
    --        self:stop()
    --        self:removeFromParentAndCleanup(true)
	--		node:release()
     --   end
    --end 
    --)
    
end

function AttrTextTip:play(  )
    if not self._txt then 
        return 
    end
    
    local arr = CCArray:create()
    self._txt:setOpacity(0)
    local fadeInAction = CCFadeIn:create(0.8)
    local delayTime = CCDelayTime:create(self._delayTime/30)
    arr:addObject(fadeInAction)
    arr:addObject(delayTime)
    local moveup = CCMoveBy:create(0.5, ccp(0, 150))
    local fadeOutAction = CCFadeOut:create(0.5)
    arr:addObject(CCSpawn:createWithTwoActions(moveup, fadeOutAction))
    arr:addObject(CCCallFunc:create(function (  )
        if self._callbackFunc then 
            self._callbackFunc()
        end

        self._txt:removeFromParentAndCleanup(true)
        self:removeFromParentAndCleanup(true)
        end))
    local seqAction = CCSequence:create(arr)
    self._txt:runAction(seqAction)
end

function AttrTextTip:playWithRichText( text, delayTime, func )
    if type(text) ~= "string" then
        return 
    end

    self._callbackFunc = func
    self._delayTime = delayTime or 0
    local startPos, endPos = string.find(text, "<text")
    if startPos and startPos > 0 then
        local richtextHeight = 60
        local richtextWidth = display.width
        local textCtrl = self._txt:getLabelByName("Label_txt")
        textCtrl:setText("")
        self._richText = CCSRichText:create(richtextWidth, richtextHeight)
        self._richText:setFontName(textCtrl:getFontName())
        self._richText:setFontSize(textCtrl:getFontSize())
        self._richText:setShowTextFromTop(true)
        self._richText:appendContent(text, ccc3(255, 255, 255))
        self._richText:reloadData()
        self._richText:adapterContent()
        local size = self._richText:getSize()
        local posx, posy = self:getPosition()
        self._richText:setPosition(ccp(0, 0))
        local parent = textCtrl:getParent()
        if parent then
           parent:addChild(self._richText, 5)
        end
    else
        local textCtrl = self._txt:getLabelByName("Label_txt")
        textCtrl:setCascadeOpacityEnabled(true)
        if textCtrl then
            textCtrl:setFontSize(30)
            textCtrl:setColor(Colors.uiColors.WHITE)
            textCtrl:setText(text)

        end
    end

    self:play()
end

function AttrTextTip:playWithNameAndDelta(typeName, deltaValue, delayTime, func)
    if not typeName or not deltaValue then
        return 
    end
    
    self._callbackFunc = func
    self._delayTime = delayTime or 0
    local textCtrl = self._txt:getLabelByName("Label_txt")
    textCtrl:setCascadeOpacityEnabled(true)
    local text = nil 
    if deltaValue >= 0 then
    	text = typeName ..  " +" .. deltaValue 
    else
    	text = typeName ..  " " .. deltaValue 
    end
    
    if textCtrl then
        textCtrl:setText(text)
        textCtrl:setFontSize(30)
        textCtrl:setColor(deltaValue >= 0 and Colors.uiColors.GREEN or Colors.uiColors.RED )
    end
    
    self:play()
end

function AttrTextTip:playWithText(text, func )
    if not text then
        return 
    end

    self._callbackFunc = func
    self._txt:getLabelByName("Label_txt"):setText(text)
    self:play()
    
end

return AttrTextTip
