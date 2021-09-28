
local InputLayer = class ("InputLayer", UFCCSNormalLayer)

function InputLayer.create(maxLength,defaultTxt, func )   
    local layer = InputLayer.new("ui_layout/createrole_InputNameLayer.json") 
    layer:_setCallBack(func)
    layer:_setMaxLength(maxLength)
    layer:_setDefaultTxt(defaultTxt)
    return layer
end

function InputLayer:ctor( ... )
    self.super.ctor(self, ...)

    local textField = self:getTextFieldByName("TextField_input")
    if textField then 
      textField:setText("")
      textField:setFontColor(ccc3(255, 255, 153))
      self:registerTextfieldEvent("TextField_input",function ( textfield, eventType )
        if eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
          self:_getText()
        end
      end)
    end

end

function InputLayer:onBackKeyEvent( ... )
    self:animationToClose()
    return true
end

function InputLayer:onLayerEnter( ... )
  require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
  local textfield = self:getTextFieldByName("TextField_input")
  if textfield then 
    textfield:setMaxLengthEnabled(true)
    textfield:setMaxLength(self._maxLength)
    textfield:setText(self._defaultTxt)
    textfield:setReturnType(kCCSKeyboardReturnTypeDone)
  end
  -- self:getTextFieldByName("TextField_input"):openKeyboard()
  self:callAfterFrameCount(5, function ( ... )
    self:updateView()  
  end)

  uf_keypadHandler:registerBackKeyHandler(function ( ... )
    if self.close then 
      self:animationToClose()
    end
    return true
  end, self)
end

function InputLayer:onLayerExit( ... )
  uf_keypadHandler:unregisterKeyHandler(self)
end

function InputLayer:updateView( )
    self:getTextFieldByName("TextField_input"):openKeyboard()
end

function InputLayer:_setCallBack(func)
  self._func = func
end

function InputLayer:_setMaxLength(length)
  self._maxLength = length
end

function InputLayer:_setDefaultTxt(defaultTxt)
  self._defaultTxt = defaultTxt
end

function InputLayer:_getText( event )
    if self._func then 
      self._func(self:getTextFieldByName("TextField_input"):getStringValue())
    end
    self:callAfterFrameCount(1, function ( ... )
      if self.close then
        self:animationToClose()
      end
    end)    
end

return InputLayer
