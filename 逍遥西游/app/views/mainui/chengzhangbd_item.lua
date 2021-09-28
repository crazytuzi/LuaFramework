BDsubButton = class("BDsubButton", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function BDsubButton:ctor(imgpath, callback, txt)
  self.m_callback = callback
  self.bg = display.newSprite(imgpath)
  self:addNode(self.bg)
  local msize = self.bg:getContentSize()
  self:setSize(msize)
  self.bg:setPosition(ccp(msize.width / 2, msize.height / 2))
  if txt then
    self.text = CRichText.new({
      width = msize.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 24,
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Center
    })
    self.text:addRichText(txt)
    self:addChild(self.text)
    local fntsize = self.text:getRichTextSize()
    self.text:setPosition(ccp(0, (msize.height - fntsize.height) / 2))
  end
  self:setTouchEnabled(true)
  self:setNodeEventEnabled(true)
  self:addTouchEventListener(function(obj, t)
    self:onTouch(obj, t)
  end)
end
function BDsubButton:onTouch(obj, t)
  if t == TOUCH_EVENT_BEGAN then
    self:setTouchStatus(true)
  elseif t == TOUCH_EVENT_ENDED then
    if self.m_callback and type(self.m_callback) == "function" then
      self.m_callback()
    end
    self:setTouchStatus(false)
  elseif t == TOUCH_EVENT_CANCELED then
    self:setTouchStatus(false)
  end
end
function BDsubButton:setTouchStatus(isTouch)
  if self.bg then
    self.bg:stopAllActions()
    if isTouch then
      self.bg:setScaleX(0.95)
      self.bg:setScaleY(0.95)
    else
      self.bg:setScaleX(1)
      self.bg:setScaleY(1)
      self.bg:runAction(transition.sequence({
        CCScaleTo:create(0.1, 1.05, 1.05),
        CCScaleTo:create(0.1, 1, 1)
      }))
    end
  end
end
function BDsubButton:onCleanup()
  self.bg = nil
end
ChengZhangBD_Item = class("ChengZhangBD_Item", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function ChengZhangBD_Item:ctor(index, txt, btnlCallback, btnrCallback)
  self.m_index = index
  local btL = BDsubButton.new("views/common/bg/bg1029.png", btnlCallback, txt)
  local btR = BDsubButton.new("views/common/btn/btn_help.png", btnrCallback)
  local btLsize = btL:getContentSize()
  local btRsize = btR:getContentSize()
  self:setSize(CCSizeMake(btLsize.width + 8 + btRsize.width, btLsize.height))
  self:addChild(btL)
  self:addChild(btR)
  btR:setPosition(ccp(btLsize.width + 8, (btLsize.height - btRsize.height) / 2))
end
function ChengZhangBD_Item:Clear()
end
