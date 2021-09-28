CPresentFriendItem = class("CPresentFriendItem", CcsSubView)
function CPresentFriendItem:ctor(pid, info, clickHeadListener)
  CPresentFriendItem.super.ctor(self, "views/presentview_frienditem.json")
  self.m_ClickHeadListener = clickHeadListener
  self.m_playerId = pid
  self.txt_haoyouzhi = self:getNode("txt_haoyouzhi")
  self.m_ImageJieHun = self:getNode("Image_jiehun")
  self.m_ImageJieQi = self:getNode("Image_jieqi")
  local youhao_value = info.fValue or 0
  self.txt_haoyouzhi:setText(string.format("友好：%s", youhao_value))
  self.m_friendName = info.name
  self:setHeadIcon(info)
  self.bg_image = self:getNode("bg")
  local size = self:getNode("Panel_18"):getContentSize()
  self.m_IsTouchMoved = false
  self:setTouchEnabled(false)
  self:getUINode():setNodeEventEnabled(true)
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
  self:ListenMessage(MsgID_Friends)
  self:setJieHunJieQiIcon()
end
function CPresentFriendItem:OnTouchEvent(event)
  local bg = self:getNode("bg")
  if event == TOUCH_EVENT_BEGAN then
    bg:setColor(ccc3(200, 200, 200))
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        bg:setColor(ccc3(255, 255, 255))
      end
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if bg == nil then
      return
    end
    if not self.m_IsTouchMoved then
      self:SetItemChoosed(true)
      self:OnClickItem()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function CPresentFriendItem:OnClickItem()
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener(self)
  end
end
function CPresentFriendItem:OnClickHead(...)
end
function CPresentFriendItem:setJieHunJieQiIcon()
  self.m_ImageJieHun:setVisible(false)
  self.m_ImageJieQi:setVisible(false)
  if g_FriendsMgr:getIsBanLv(self.m_playerId) then
    self.m_ImageJieHun:setVisible(true)
  end
  if g_FriendsMgr:getIsJiYou(self.m_playerId) then
    self.m_ImageJieQi:setVisible(true)
  end
end
function CPresentFriendItem:setTouchState(flag)
  if flag then
    self.bg_image:setColor(ccc3(200, 200, 200))
  else
    self.bg_image:setColor(ccc3(255, 255, 255))
  end
end
function CPresentFriendItem:setHeadIcon(info)
  local name = info.name
  local txt_name = self:getNode("txt_friendsname")
  local nameColor = NameColor_MainHero[info.zs] or ccc3(255, 0, 0)
  txt_name:setText(name)
  AutoLimitObjSize(txt_name, 120)
  if info.rtype ~= nil then
    if self.m_HeadIcon ~= nil then
      self.m_HeadIcon:removeFromParentAndCleanup(true)
      self.m_HeadIcon = nil
    end
    self.headbg = self:getNode("headbg")
    local parent = self.headbg:getParent()
    local x, y = self.headbg:getPosition()
    local size = self.headbg:getContentSize()
    local zOrder = self.headbg:getZOrder()
    self.m_HeadIcon = createClickHead({
      roleTypeId = info.rtype,
      clickListener = handler(self, self.OnClickHead)
    })
    parent:addChild(self.m_HeadIcon, zOrder + 1)
    self.m_HeadIcon:setPosition(ccp(x - size.width / 2, y - size.height / 2))
    self.m_HeadIcon:setTouchEnabled(false)
  end
end
function CPresentFriendItem:SetItemChoosed(isel)
  if isel then
    if self._SelectObjList then
      for _, obj in pairs(self._SelectObjList) do
        obj:setVisible(true)
      end
    else
      local bgSize = self:getSize()
      local temp1 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp2 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp3 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp4 = display.newSprite("views/pic/pic_selectcorner.png")
      local del = 5
      local w = bgSize.width / 2
      local h = bgSize.height / 2
      self:addNode(temp1, 20)
      temp1:setPosition(ccp(-del, -del))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      self:addNode(temp2, 20)
      temp2:setPosition(ccp(-del, 2 * h + del))
      temp2:setAnchorPoint(ccp(0, 1))
      self:addNode(temp3, 20)
      temp3:setPosition(ccp(2 * w + del, -del))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      self:addNode(temp4, 20)
      temp4:setPosition(ccp(2 * w + del, 2 * h + del))
      temp4:setAnchorPoint(ccp(0, 1))
      temp4:setScaleX(-1)
      self._SelectObjList = {
        temp1,
        temp2,
        temp3,
        temp4
      }
    end
  elseif self._SelectObjList then
    for _, obj in pairs(self._SelectObjList) do
      obj:setVisible(false)
    end
  end
end
function CPresentFriendItem:setYouHaoValue()
  local info = g_FriendsMgr:getPlayerInfo(self.m_playerId)
  self.txt_haoyouzhi:setText(string.format("友好：%s", info.fValue))
end
function CPresentFriendItem:getPlayerId()
  return self.m_playerId
end
function CPresentFriendItem:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Friends_UpdateFirend then
    local pid = arg[1]
    self:setYouHaoValue()
  elseif msgSID == MsgID_Friends_FlushBanLv then
    local BanLvId = arg[1]
    self.m_ImageJieHun:setVisible(false)
    self.m_ImageJieQi:setVisible(false)
    if BanLvId == self.m_playerId then
      if g_FriendsMgr:getIsBanLv(BanLvId) then
        self.m_ImageJieHun:setVisible(true)
      elseif g_FriendsMgr:getIsJiYou(BanLvId) then
        self.m_ImageJieQi:setVisible(true)
      end
    end
  end
end
function CPresentFriendItem:Clear()
  print("CPresentFriendItem:Clear")
  self.m_ClickHeadListener = nil
end
