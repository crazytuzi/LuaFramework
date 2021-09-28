CShowInformView = class("CShowInformView", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function CShowInformView:ctor(strTitle, items, parent, callback, pngPath, titleColor)
  self.m_callback = callback
  local z = 10000
  if parent.getChildMaxZ then
    z = parent:getChildMaxZ()
  else
    local p = parent
    if p.m_UINode then
      z = getMaxZ(p.m_UINode)
    end
  end
  if parent.addSubView then
    parent:addSubView({
      subView = self,
      zOrder = z + 1
    })
  else
    local p = parent
    if p.m_UINode then
      p = p.m_UINode
    end
    p:addChild(self, z + 1)
  end
  self.m_TxtX = 255
  local blackH = 130
  local layerC = display.newColorLayer(ccc4(0, 0, 0, 200))
  layerC:setContentSize(CCSize(display.width, blackH))
  self:addNode(layerC, 5)
  layerC:setPosition(ccp(0, 0))
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  if sharedFileUtils:isFileExist(sharedFileUtils:fullPathForFilename(pngPath)) == false then
    pngPath = "xiyou/head/head20034.png"
  end
  self.m_HeadImg = display.newSprite(pngPath)
  self:addNode(self.m_HeadImg, 10)
  local size = self.m_HeadImg:getContentSize()
  self.m_HeadImg:setPosition(ccp(self.m_TxtX / 2, size.height / 2))
  strTitle = strTitle or ""
  titleColor = titleColor or ccc3(255, 196, 98)
  local titleW = display.width - self.m_TxtX - 30
  self.m_TitleTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 28,
    color = titleColor
  })
  self:addChild(self.m_TitleTxt, 10)
  self.m_TitleTxt:addRichText(string.format("%s", strTitle))
  local s = self.m_TitleTxt:getRichTextSize()
  local titleY = blackH - s.height - 5
  self.m_TitleTxt:setPosition(ccp(self.m_TxtX, titleY))
  local itemy = titleY - 5
  items = items or {}
  for index = 1, #items do
    itemy = self:creatKeyValueItem(items[index], self.m_TxtX, itemy)
  end
  g_TouchEvent:registerGlobalTouchEvent(self, handler(self, self.Touch))
  self:setNodeEventEnabled(true)
end
function CShowInformView:creatKeyValueItem(item, px, py)
  local keystr = ui.newTTFLabel({
    text = item[1],
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(221, 139, 29)
  })
  keystr:setAnchorPoint(ccp(0, 1))
  local csize = keystr:getContentSize()
  keystr:setPosition(ccp(px, py))
  self:addNode(keystr, 10)
  local talkW = display.width - self.m_TxtX - 60 - csize.width
  local valuestr = CRichText.new({
    width = talkW,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(255, 255, 255),
    align = ui.TEXT_VALIGN_TOP
  })
  item[2] = item[2] or ""
  valuestr:setAnchorPoint(ccp(0, 1))
  valuestr:addRichText(string.format("%s", item[2]))
  if 0 < csize.width then
    valuestr:setPosition(ccp(px + csize.width + 5, py))
  else
    valuestr:setPosition(ccp(px, py))
  end
  self:addChild(valuestr, 10)
  local y1 = py - csize.height
  local vsize = valuestr:getContentSize()
  local y2 = py - vsize.height
  return math.min(y1, y2)
end
function CShowInformView:Touch(name, x, y, prevX, prevY)
  print(" ====================>..  CShowInformView:Touch ")
  if name == "began" then
    self:onClose()
  end
end
function CShowInformView:onClose()
  if self.m_callback then
    self.m_callback(self)
  end
  self:removeSelf()
end
function CShowInformView:onCleanup()
  print(" =======>.... CShowInformView:onCleanup ")
  self.m_callback = nil
  g_TouchEvent:unRegisterGlobalTouchEvent(self)
end
