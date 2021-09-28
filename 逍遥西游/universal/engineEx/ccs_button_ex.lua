if Button.__func__setTitleText == nil then
  Button.__func__setTitleText = Button.setTitleText
end
function Button:setTitleText(...)
  Button.__func__setTitleText(self, ...)
  self:FlushTxtBold()
  self:FlushTitleDeltaPos()
end
if Button.__func__setTitleColor == nil then
  Button.__func__setTitleColor = Button.setTitleColor
end
function Button:setTitleColor(...)
  Button.__func__setTitleColor(self, ...)
  self:FlushTxtBold()
  self:FlushTitleDeltaPos()
end
if Button.__func__setTitleFontSize == nil then
  Button.__func__setTitleFontSize = Button.setTitleFontSize
end
function Button:setTitleFontSize(...)
  Button.__func__setTitleFontSize(self, ...)
  self:FlushTxtBold()
  self:FlushTitleDeltaPos()
end
if Button.__func__setTitleFontName == nil then
  Button.__func__setTitleFontName = Button.setTitleFontName
end
function Button:setTitleFontName(...)
  Button.__func__setTitleFontName(self, ...)
  self:FlushTxtBold()
  self:FlushTitleDeltaPos()
end
if Button.__func__loadTextureNormal == nil then
  Button.__func__loadTextureNormal = Button.loadTextureNormal
end
function Button:loadTextureNormal(...)
  Button.__func__loadTextureNormal(self, ...)
  self:FlushTxtBold()
  self:FlushTitleDeltaPos()
end
function Button:setNodeEventEnabled(enabled, listener)
  local handle
  if enabled then
    listener = listener or function(event)
      local name = event.name
      if name == "enter" then
        self:onEnterEvent()
        self:Enten_Extend()
        self:FlushTitleDeltaPos()
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
function Button:Enten_Extend()
  self:DetectTitleTxtBold()
end
function Button:Clear_Extend()
  if self.__title_txt_bold_ins then
    self.__title_txt_bold_ins = nil
  end
end
function Button:enableTitleTxtBold(enable)
  if self._isEnableTitleTxtBold == nil then
    self:setNodeEventEnabled(true)
  end
  self._isEnableTitleTxtBold = enable
  self:DetectTitleTxtBold()
end
function Button:DetectTitleTxtBold()
  if self._isEnableTitleTxtBold then
    local ttfNode = tolua.cast(self:getTitleRender(), "CCLabelTTF")
    if ttfNode == nil then
      printLog("ERROR", "标题文字还没有创建")
      return
    end
    if self.__title_txt_bold_ins == nil then
      self.__title_txt_bold_ins = CCLabelTTF:create(ttfNode:getString(), ttfNode:getFontName(), ttfNode:getFontSize())
      ttfNode:addChild(self.__title_txt_bold_ins, -1)
      self.__title_txt_bold_ins:setPosition(0, 0)
      self.__title_txt_bold_ins:setAnchorPoint(ccp(0.5, 0.5))
    end
    self.__title_txt_bold_ins:setVisible(true)
    self:FlushTxtBold()
  elseif self.__title_txt_bold_ins then
    self.__title_txt_bold_ins:setVisible(false)
  end
end
function Button:FlushTxtBold()
  if self._isEnableTitleTxtBold == nil then
    return
  end
  if self.__title_txt_bold_ins == nil then
    return
  end
  local ttfNode = tolua.cast(self:getTitleRender(), "CCLabelTTF")
  if ttfNode == nil then
    printLog("Button ERROR", "标题文字还没有创建")
    return
  end
  local text = ttfNode:getString()
  if self.__title_txt_bold_ins:getString() ~= text then
    self.__title_txt_bold_ins:setString(text)
  end
  local fontName = ttfNode:getFontName()
  if self.__title_txt_bold_ins:getFontName() ~= fontName then
    self.__title_txt_bold_ins:setFontName(fontName)
  end
  local fontSize = ttfNode:getFontSize()
  if self.__title_txt_bold_ins:getFontSize() ~= fontSize then
    self.__title_txt_bold_ins:setFontSize(fontSize)
  end
  local color = self:getTitleSaveColor()
  local _color = self.__title_txt_bold_ins:getColor()
  if color.r ~= _color.r or color.g ~= _color.g or color.b ~= _color.b then
    self.__title_txt_bold_ins:setColor(color)
  end
  local alignW = ttfNode:getVerticalAlignment()
  if self.__title_txt_bold_ins:getVerticalAlignment() ~= alignW then
    self.__title_txt_bold_ins:setVerticalAlignment(alignW)
  end
  local alignH = ttfNode:getHorizontalAlignment()
  if self.__title_txt_bold_ins:getHorizontalAlignment() ~= alignH then
    self.__title_txt_bold_ins:setHorizontalAlignment(alignH)
  end
  local d = ttfNode:getDimensions()
  local _d = self.__title_txt_bold_ins:getDimensions()
  if d.width ~= _d.width or d.height ~= _d.height then
    self.__title_txt_bold_ins:setDimensions(d)
  end
  local anchorPoint = ttfNode:getAnchorPoint()
  local size = ttfNode:getContentSize()
  local s = ttfNode:getScale()
  self.__title_txt_bold_ins:setPosition(anchorPoint.x * size.width * s + 1, anchorPoint.y * size.height * s)
end
function Button:setTitleDeltaPos(dx, dy)
  self._isSetTitleDeltaPos = true
  self._titleDeltaPos = {dx, dy}
  self:setNodeEventEnabled(true)
  self:FlushTitleDeltaPos()
end
function Button:delTitleFontSize(delSize)
  if delSize == 0 then
    return
  end
  local ttfNode = tolua.cast(self:getTitleRender(), "CCLabelTTF")
  local curFontSize = ttfNode:getFontSize()
  ttfNode:setFontSize(curFontSize - delSize)
  self:FlushTitleDeltaPos()
end
function Button:FlushTitleDeltaPos()
  if self._isSetTitleDeltaPos then
    self:setAnchorPoint(self:getAnchorPoint())
    local ttfNode = tolua.cast(self:getTitleRender(), "CCLabelTTF")
    if ttfNode == nil then
      printLog("Button ERROR", "标题文字还没有创建")
      return
    end
    local x, y = ttfNode:getPosition()
    ttfNode:setPosition(ccp(x + self._titleDeltaPos[1], y + self._titleDeltaPos[2]))
  end
end
