MapNpcShape = class("MapNpcShape", CMapRoleShape)
function MapNpcShape:ctor(npcId, shapeId, posChangedListener, opaque, label)
  self.m_NpcId = npcId
  MapNpcShape.super.ctor(self, shapeId, LOGICTYPE_NPC, posChangedListener, opaque)
  self:createNpcLabel(label)
end
function MapNpcShape:createNpcLabel(label)
  local labelPath = data_getNpcLabelPath(label)
  if labelPath ~= nil then
    self.m_NpcLabel = display.newSprite(labelPath)
    self.m_NpcLabel:setAnchorPoint(ccp(0.5, 0))
    self:addNode(self.m_NpcLabel, 9)
    self:setNpcLabelPos()
  end
end
function MapNpcShape:setNpcLabelPos()
  if self.m_NpcLabel == nil then
    return
  end
  self.m_NpcLabel:setPosition(ccp(0, self.m_BodyHeight + 25))
  self.m_NpcLabel:runAction(CCRepeatForever:create(transition.sequence({
    CCMoveBy:create(0.5, ccp(0, 5)),
    CCMoveBy:create(0.5, ccp(0, -5))
  })))
end
function MapNpcShape:addTalkMsg(msg, yy)
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  local parent = self:getParent()
  if parent then
    local x, y = self:getPosition()
    local z = self:getZOrder()
    if g_MapMgr then
      local mapViewIns = g_MapMgr:getMapViewIns()
      if mapViewIns then
        z = mapViewIns.m_ZOrder.role + mapViewIns.m_MapSize.height - y + 100
      end
    end
    self.m_TalkBubbleObj = CMapChatBubble.new(msg, yy, handler(self, self.onTalkBubbleClear))
    parent:addChild(self.m_TalkBubbleObj, z)
    self.m_TalkBubbleObj:setPosition(ccp(x, y + self.m_BodyHeight + 10))
  end
end
function MapNpcShape:getNpcId()
  return self.m_NpcId
end
function MapNpcShape:setDirection(dir)
  dir = 5
  MapNpcShape.super.setDirection(self, dir)
end
