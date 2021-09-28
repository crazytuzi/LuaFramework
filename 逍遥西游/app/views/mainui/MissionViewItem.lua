local color_1 = ccc3(253, 246, 157)
local color_2 = ccc3(92, 69, 39)
MissionViewItem = class("MissionViewItem", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  return widget
end)
function MissionViewItem:ctor(itemTxt, itemType, idxInData, extParam)
  self.m_ItemType = itemType
  self.m_ItemTxt = itemTxt
  self.m_IndexInData = idxInData
  self.m_ExtParam = extParam
  self:setTouchEnabled(true)
  self:setNodeEventEnabled(true)
  local bgPngPath, color, mSize
  local off = 0
  local y = 0
  if itemType == 1 then
    bgPngPath = "views/market/btn_kind1.png"
    color = color_1
    mSize = 26
    off = 2
  else
    bgPngPath = "views/mission/btn_mission_item01.png"
    color = color_2
    mSize = 24
    off = 4
    y = 2
  end
  local bg = display.newSprite(bgPngPath)
  self:addNode(bg)
  local s = bg:getContentSize()
  self:setSize(CCSize(s.width, s.height + off))
  bg:setPosition(ccp(s.width / 2, s.height / 2 + y))
  self.m_BgNormal = bg
  self.m_ActionObj = nil
  self.m_NormalTitleTxt = CRichText.new({
    width = s.width,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = mSize,
    color = color,
    align = CRichText_AlignType_Center
  })
  self:addChild(self.m_NormalTitleTxt)
  self.m_NormalTitleTxt:addRichText(itemTxt)
  local txtSize = self.m_NormalTitleTxt:getRichTextSize()
  self.m_NormalTitleTxt:setPosition(ccp(0, (s.height - txtSize.height) / 2))
end
function MissionViewItem:getItemData()
  return self.m_ItemType, self.m_IndexInData, self.m_ExtParam
end
function MissionViewItem:setItemChoosed(flag)
  if flag then
    if self.m_BgChoosed == nil then
      self.m_BgChoosed = display.newSprite("views/mission/btn_mission_item02.png")
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
function MissionViewItem:setTouchStatus(isTouch)
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
    actionObj:setScaleX(0.9)
    actionObj:setScaleY(0.9)
  else
    actionObj:setScaleX(1)
    actionObj:setScaleY(1)
    actionObj:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1.1, 1.1),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function MissionViewItem:onCleanup()
  self.m_ExtParam = nil
  self.m_ActionObj = nil
end
