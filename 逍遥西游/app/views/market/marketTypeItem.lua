local color_1 = ccc3(254, 198, 89)
local color_2 = ccc3(58, 34, 5)
CMainTypeListItem = class("CMainTypeListItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CMainTypeListItem:ctor(mainType, itemTxt, path, fontSize, color, off)
  self.m_MainType = mainType
  self.m_ItemTxt = itemTxt
  fontSize = fontSize or 26
  color = color or ccc3(253, 246, 157)
  off = off or 2
  self:setTouchEnabled(true)
  self:setNodeEventEnabled(true)
  self.m_BgPath = path or "views/market/btn_kind1.png"
  local bg = display.newSprite(self.m_BgPath)
  self:addNode(bg)
  local s = bg:getContentSize()
  self:setSize(CCSize(s.width, s.height + off))
  bg:setPosition(ccp(s.width / 2, s.height / 2))
  self.m_BgNormal = bg
  self.m_NormalTitleTxt = CRichText.new({
    width = s.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = fontSize,
    color = color,
    align = CRichText_AlignType_Center
  })
  self:addChild(self.m_NormalTitleTxt)
  self.m_NormalTitleTxt:addRichText(itemTxt)
  local txtSize = self.m_NormalTitleTxt:getRichTextSize()
  self.m_NormalTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function CMainTypeListItem:resetItemTxt(itemTxt)
  self.m_NormalTitleTxt:clearAll()
  self.m_NormalTitleTxt:addRichText(itemTxt)
  local txtSize = self.m_NormalTitleTxt:getRichTextSize()
  local s = self.m_BgNormal:getContentSize()
  self.m_NormalTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function CMainTypeListItem:getMainType()
  return self.m_MainType
end
function CMainTypeListItem:setTouchStatus(isTouch)
  self.m_BgNormal:stopAllActions()
  if isTouch then
    self.m_BgNormal:setScaleX(0.95)
    self.m_BgNormal:setScaleY(0.95)
  else
    self.m_BgNormal:setScaleX(1)
    self.m_BgNormal:setScaleY(1)
    self.m_BgNormal:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1.05, 1.05),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function CMainTypeListItem:onCleanup()
end
CSubTypeListItem = class("CSubTypeListItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function CSubTypeListItem:ctor(mainType, subType, itemTxt, path, selectedPath, off)
  self.m_MainType = mainType
  self.m_SubType = subType
  self.m_ItemTxt = itemTxt
  off = off or 4
  self:setTouchEnabled(true)
  self:setNodeEventEnabled(true)
  self.m_BgPath = path or "views/market/btn_kind2.png"
  self.m_BgSelectedPath = selectedPath or "views/market/btn_kind2_sel.png"
  local bg = display.newSprite(self.m_BgPath)
  self:addNode(bg)
  local s = bg:getContentSize()
  self:setSize(CCSize(s.width, s.height + off))
  bg:setPosition(ccp(s.width / 2, s.height / 2 + off / 2))
  self.m_BgNormal = bg
  self.m_ActionObj = nil
  self.m_NormalTitleTxt = CRichText.new({
    width = s.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = ccc3(92, 69, 39),
    align = CRichText_AlignType_Center
  })
  self:addChild(self.m_NormalTitleTxt)
  self.m_NormalTitleTxt:addRichText(itemTxt)
  local txtSize = self.m_NormalTitleTxt:getRichTextSize()
  self.m_NormalTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function CSubTypeListItem:resetItemTxt(itemTxt)
  self.m_NormalTitleTxt:clearAll()
  self.m_NormalTitleTxt:addRichText(itemTxt)
  local txtSize = self.m_NormalTitleTxt:getRichTextSize()
  local s = self.m_BgNormal:getContentSize()
  self.m_NormalTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function CSubTypeListItem:getMainType()
  return self.m_MainType
end
function CSubTypeListItem:getSubType()
  return self.m_SubType
end
function CSubTypeListItem:setItemChoosed(flag)
  if flag then
    if self.m_BgChoosed == nil then
      self.m_BgChoosed = display.newSprite(self.m_BgSelectedPath)
      self:addNode(self.m_BgChoosed)
      local x, y = self.m_BgNormal:getPosition()
      self.m_BgChoosed:setPosition(ccp(x, y))
    end
    if self.m_ChooseTitleTxt == nil then
      local s = self:getSize()
      self.m_ChooseTitleTxt = CRichText.new({
        width = s.width,
        verticalSpace = 0,
        font = KANG_TTF_FONT,
        fontSize = 24,
        color = ccc3(255, 255, 255),
        align = CRichText_AlignType_Center
      })
      self:addChild(self.m_ChooseTitleTxt)
      self.m_ChooseTitleTxt:addRichText(self.m_ItemTxt)
      local txtSize = self.m_ChooseTitleTxt:getRichTextSize()
      self.m_ChooseTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
    end
    self.m_BgNormal:setVisible(false)
    self.m_BgChoosed:setVisible(true)
    self.m_ChooseTitleTxt:setEnabled(true)
  else
    self.m_BgNormal:setVisible(true)
    if self.m_BgChoosed then
      self.m_BgChoosed:setVisible(false)
    end
    if self.m_ChooseTitleTxt then
      self.m_ChooseTitleTxt:setEnabled(false)
    end
  end
end
function CSubTypeListItem:setTouchStatus(isTouch)
  local actionObj = self.m_ActionObj
  if actionObj == nil then
    if self.m_BgChoosed and self.m_BgNormal:isVisible() == false then
      actionObj = self.m_BgChoosed
    else
      actionObj = self.m_BgNormal
    end
    self.m_ActionObj = actionObj
  end
  actionObj:stopAllActions()
  if isTouch then
    actionObj:setScaleX(0.95)
    actionObj:setScaleY(0.95)
  else
    actionObj:setScaleX(1)
    actionObj:setScaleY(1)
    actionObj:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1.05, 1.05),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function CSubTypeListItem:onCleanup()
  self.m_ActionObj = nil
end
