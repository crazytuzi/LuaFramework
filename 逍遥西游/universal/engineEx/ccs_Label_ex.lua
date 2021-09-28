if Label.__func__setFontName == nil then
  Label.__func__setFontName = Label.setFontName
end
function Label:setFontName(...)
  Label.__func__setFontName(self, ...)
  self:FlushTxtBold()
end
if Label.__func__setFontSize == nil then
  Label.__func__setFontSize = Label.setFontSize
end
function Label:setFontSize(...)
  Label.__func__setFontSize(self, ...)
  self:FlushTxtBold()
end
if Label.__func__setText == nil then
  Label.__func__setText = Label.setText
end
function Label:setText(...)
  Label.__func__setText(self, ...)
  self:FlushTxtBold()
end
if Label.__func__setFontName == nil then
  Label.__func__setFontName = Label.setFontName
end
function Label:setFontName(...)
  Label.__func__setFontName(self, ...)
  self:FlushTxtBold()
end
if Label.__func__setAnchorPoint == nil then
  Label.__func__setAnchorPoint = Label.setAnchorPoint
end
function Label:setAnchorPoint(...)
  Label.__func__setAnchorPoint(self, ...)
  self:FlushTxtBold()
end
function Label:setNodeEventEnabled(enabled, listener)
  local handle
  if enabled then
    listener = listener or function(event)
      local name = event.name
      if name == "enter" then
        self:onEnterEvent()
      elseif name == "exit" then
        self:onExitEvent()
      elseif name == "enterTransitionFinish" then
        self:onEnterTransitionFinishEvent()
      elseif name == "exitTransitionStart" then
        self:onExitTransitionStartEvent()
      elseif name == "cleanup" then
        self:Clear_Extend()
        self:onCleanup()
      end
    end
    handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  else
    self:removeNodeEventListener(handle)
  end
  return self
end
function Label:enableBoldLua(enable, boldType)
  local ttfNode = tolua.cast(self:getVirtualRenderer(), "CCLabelTTF")
  if ttfNode == nil then
    printLog("ERROR", "标题文字还没有创建")
    return
  end
  self._isEnalbleShadowLua = enable
  if self._isEnalbleShadowLua == true then
    self.__title_txt_bold_type = boldType
    self:setNodeEventEnabled(true)
    if device.platform ~= "android" and self.__title_txt_bold_ins == nil then
      self.__title_txt_bold_ins = CCLabelTTF:create(ttfNode:getString(), ttfNode:getFontName(), ttfNode:getFontSize())
      ttfNode:addChild(self.__title_txt_bold_ins, -1)
      self:FlushTxtBold()
    end
  elseif self.__title_txt_bold_ins then
    self.__title_txt_bold_ins:removeSelf()
    self.__title_txt_bold_ins = nil
  end
end
function Label:delTitleFontSize(delSize)
  if delSize == 0 then
    return
  end
  local ttfNode = tolua.cast(self:getVirtualRenderer(), "CCLabelTTF")
  local curFontSize = ttfNode:getFontSize()
  ttfNode:setFontSize(curFontSize - delSize)
  self:setFontSize(curFontSize - delSize)
  self:FlushTxtBold()
end
function Label:FlushTxtBold()
  if self.__title_txt_bold_ins == nil then
    return
  end
  local ttfNode = tolua.cast(self:getVirtualRenderer(), "CCLabelTTF")
  if ttfNode == nil then
    printLog("Label ERROR", "标题文字还没有创建")
    return
  end
  local text = self:getStringValue()
  if self.__title_txt_bold_ins:getString() ~= text then
    self.__title_txt_bold_ins:setString(text)
  end
  local fontName = self:getFontName()
  if self.__title_txt_bold_ins:getFontName() ~= fontName then
    self.__title_txt_bold_ins:setFontName(fontName)
  end
  local fontSize = self:getFontSize()
  if self.__title_txt_bold_ins:getFontSize() ~= fontSize then
    self.__title_txt_bold_ins:setFontSize(fontSize)
  end
  local color = ttfNode:getColor()
  local _color = self.__title_txt_bold_ins:getColor()
  if color.r ~= _color.r or color.g ~= _color.g or color.b ~= _color.b then
    self.__title_txt_bold_ins:setColor(color)
  end
  local alignW = self:getTextVerticalAlignment()
  if self.__title_txt_bold_ins:getVerticalAlignment() ~= alignW then
    self.__title_txt_bold_ins:setVerticalAlignment(alignW)
  end
  local alignH = self:getTextHorizontalAlignment()
  if self.__title_txt_bold_ins:getHorizontalAlignment() ~= alignH then
    self.__title_txt_bold_ins:setHorizontalAlignment(alignH)
  end
  local d = ttfNode:getDimensions()
  local _d = self.__title_txt_bold_ins:getDimensions()
  if d.width ~= _d.width or d.height ~= _d.height then
    self.__title_txt_bold_ins:setDimensions(d)
  end
  local anchorPoint = ttfNode:getAnchorPoint()
  self.__title_txt_bold_ins:setAnchorPoint(anchorPoint)
  local size = ttfNode:getContentSize()
  local sx = ttfNode:getScaleX()
  local sy = ttfNode:getScaleY()
  if self.__title_txt_bold_type == 2 then
    self.__title_txt_bold_ins:setPosition(math.floor(anchorPoint.x * size.width * sx) + 2, anchorPoint.y * size.height * sy + 1)
  else
    self.__title_txt_bold_ins:setPosition(math.floor(anchorPoint.x * size.width * sx) + 1, anchorPoint.y * size.height * sy)
  end
end
function Label:Clear_Extend()
  if self.__title_txt_bold_ins then
    self.__title_txt_bold_ins:removeSelf()
    self.__title_txt_bold_ins = nil
  end
end
