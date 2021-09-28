CDuelMatchingItem = class("CDuelMatchingItem", CcsSubView)
function CDuelMatchingItem:ctor(data)
  CDuelMatchingItem.super.ctor(self, "views/duelmatchingitem.json", {isAutoCenter = true, opacityBg = 100})
  local headBg = self:getNode("head")
  self.m_HeadBg = headBg
  local name = self:getNode("name")
  local race = self:getNode("race")
  local level = self:getNode("level")
  if data ~= nil then
    self.m_PlayerId = data.pid
    name:setVisible(true)
    race:setVisible(true)
    level:setVisible(true)
    headBg:setOpacity(255)
    local p = headBg:getParent()
    local x, y = headBg:getPosition()
    local s = headBg:getScale()
    local rTypeId = data.rtype
    local headObj = createHeadIconByRoleTypeID(rTypeId)
    p:addNode(headObj, 10)
    headObj:setPosition(ccp(x + HEAD_OFF_X * s, y + HEAD_OFF_Y * s))
    headObj:setScale(s)
    name:setText(data.name)
    AutoLimitObjSize(name, 110)
    local raceTxt = data_getRoleCareer(rTypeId)
    race:setText(raceTxt)
    level:setText(string.format("%d转%d级", data.zs or 0, data.lv or 0))
    if data.ready == 1 then
      self:addFightIcon()
    else
      self:removeFightIcon()
    end
    self:getNode("captain"):setVisible(data.cp == 1)
  else
    name:setVisible(false)
    race:setVisible(false)
    level:setVisible(false)
    headBg:setOpacity(102)
    self:getNode("captain"):setVisible(false)
    self:removeFightIcon()
  end
  self:ListenMessage(MsgID_Activity)
end
function CDuelMatchingItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Activity_DuelReady then
    local pid = arg[1]
    local ready = arg[2]
    if pid == self.m_PlayerId then
      if ready == 1 then
        self:addFightIcon()
      else
        self:removeFightIcon()
      end
    end
  end
end
function CDuelMatchingItem:addFightIcon()
  if self.m_HeadBg.__icon == nil then
    local p = self.m_HeadBg:getParent()
    local x, y = self.m_HeadBg:getPosition()
    local icon = display.newSprite("views/mainviews/pic_mission_wartips.png")
    p:addNode(icon, 20)
    icon:setScale(0.8)
    icon:setPosition(ccp(x + 18, y - 10))
    self.m_HeadBg.__icon = icon
  end
end
function CDuelMatchingItem:removeFightIcon()
  if self.m_HeadBg.__icon ~= nil then
    self.m_HeadBg.__icon:removeFromParentAndCleanup(true)
    self.m_HeadBg.__icon = nil
  end
end
function CDuelMatchingItem:Clear()
  print("---->>>CDuelMatchingItem Clear")
end
