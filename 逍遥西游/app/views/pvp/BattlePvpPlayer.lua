CBattlePvpPlayer = class("CBattlePvpPlayer", CcsSubView)
function CBattlePvpPlayer:ctor(pid, ltype, pname, zs, lv, rank, clickListener)
  CBattlePvpPlayer.super.ctor(self, "views/battle_oneperson.json")
  self.m_PlayerId = pid
  self.m_ClickListener = clickListener
  self.imgbox = self:getNode("imgbox")
  local parent = self.imgbox:getParent()
  local x, y = self.imgbox:getPosition()
  local headIcon = createHeadIconByRoleTypeID(ltype)
  parent:addNode(headIcon, 10)
  headIcon:setPosition(ccp(x, y + 7))
  self.name = self:getNode("name")
  self.name:setText(pname)
  AutoLimitObjSize(self.name, 104)
  color = NameColor_MainHero[zs]
  if color ~= nil then
    self.name:setColor(color)
  end
  self.level = self:getNode("level")
  self.level:setText(string.format("%d转%d级", zs, lv))
  self.m_Rank = rank
  self.rank = self:getNode("rank")
  self.rank:setText(tostring(rank))
  local rsize = self.rank:getContentSize()
  local maxW = 50
  if maxW < rsize.width then
    self.rank:setScale(maxW / rsize.width)
  end
  self.bg = self:getNode("bg")
  self.m_UINode:setTouchEnabled(true)
  self.m_UINode:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      self.m_HasTouchMoved = false
      self:SetSelected(true)
    elseif t == TOUCH_EVENT_MOVED then
      if not self.m_HasTouchMoved then
        local startPos = self.m_UINode:getTouchStartPos()
        local movePos = self.m_UINode:getTouchMovePos()
        if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 10 then
          self.m_HasTouchMoved = true
          self:SetSelected(false)
        end
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if not self.m_HasTouchMoved and self.m_ClickListener then
        self.m_ClickListener(self.m_PlayerId, self.m_Rank)
      end
      self:SetSelected(false)
    end
  end)
end
function CBattlePvpPlayer:SetSelected(iSel)
  if iSel then
    self.bg:setScale(1.05)
  else
    self.bg:setScale(1)
  end
end
function CBattlePvpPlayer:Clear()
end
