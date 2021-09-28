CLeaveWordBoardItem = class("CLeaveWordBoardItem", CcsSubView)
function CLeaveWordBoardItem:ctor(lType, name, zs, lv, msg, isLocal)
  CLeaveWordBoardItem.super.ctor(self, "views/leaveworditem.json")
  self.m_IsLocal = isLocal
  if isLocal then
    local bg = self:getNode("bg")
    local x, y = bg:getPosition()
    local ap = bg:getAnchorPoint()
    local p = bg:getParent()
    local z = bg:getZOrder()
    local localBg = display.newSprite("views/common/bg/bg1071.png")
    p:addNode(localBg, z)
    localBg:setAnchorPoint(ccp(ap.x, ap.y))
    localBg:setPosition(ccp(x, y))
  end
  self.headpos = self:getNode("headpos")
  self.headpos:setVisible(false)
  local x, y = self.headpos:getPosition()
  local hsize = self.headpos:getContentSize()
  local headImg = createWidgetFrameHeadIconByRoleTypeID(lType)
  self:addChild(headImg)
  headImg:setScale(0.5)
  headImg:setPosition(ccp(x + hsize.width / 2, y + hsize.height / 2))
  self:getNode("name"):setText(name)
  local nameColor = NameColor_MainHero[zs]
  if nameColor then
    self:getNode("name"):setColor(nameColor)
  end
  self:getNode("level"):setText(string.format("%d转%d级", zs, lv))
  self.contentlist = self:getNode("contentlist")
  self:setMsg(msg)
end
function CLeaveWordBoardItem:setMsg(msg)
  if self.m_IsLocal and string.len(msg) <= 0 then
    msg = "（你还没有留言哟）"
  end
  self.contentlist:removeAllItems()
  local size = self.contentlist:getContentSize()
  local msgBox = CRichText.new({
    width = size.width,
    color = ccc3(132, 40, 21),
    fontSize = 20
  })
  msgBox:addRichText(msg)
  self.contentlist:pushBackCustomItem(msgBox)
end
function CLeaveWordBoardItem:getIsLocal()
  return self.m_IsLocal
end
function CLeaveWordBoardItem:Clear()
end
