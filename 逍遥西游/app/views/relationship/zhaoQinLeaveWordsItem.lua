CZhaoQinLeaveWordBoardItem = class("CZhaoQinLeaveWordBoardItem", CcsSubView)
function CZhaoQinLeaveWordBoardItem:ctor(params, isLocal, callbackFun)
  CZhaoQinLeaveWordBoardItem.super.ctor(self, "views/zhaoqinLeaveworditem.json")
  self.m_params = params or {}
  local rtype = params.rtype
  local name = params.name
  local zs = params.zs
  local lv = params.lv
  local msg = params.msg
  self.m_IsLocal = isLocal
  self.m_callbackFun = callbackFun
  if isLocal then
    local bg = self:getNode("bg")
    local x, y = bg:getPosition()
    local ap = bg:getAnchorPoint()
    local p = bg:getParent()
    local z = bg:getZOrder()
    local localBg = display.newSprite("views/common/bg/bg1080.png")
    p:addNode(localBg, z)
    localBg:setAnchorPoint(ccp(ap.x, ap.y))
    localBg:setPosition(ccp(x, y))
  end
  self.headpos = self:getNode("headpos")
  self.headpos:setVisible(false)
  local x, y = self.headpos:getPosition()
  local hsize = self.headpos:getContentSize()
  local headImg = createWidgetFrameHeadIconByRoleTypeID(rtype)
  self:addChild(headImg)
  headImg:setScale(0.5)
  headImg:setPosition(ccp(x + hsize.width / 2, y + hsize.height / 2))
  self:getNode("name"):setText(name)
  local nameColor = NameColor_MainHero[zs]
  if nameColor then
    self:getNode("name"):setColor(nameColor)
  end
  AutoLimitObjSize(self:getNode("name"), 110)
  self:getNode("level"):setText(string.format("%d转%d级", zs, lv))
  self.contentlist = self:getNode("contentlist")
  self:setMsg(msg)
  local size = self:getNode("bg"):getContentSize()
  self:setTouchEnabled(false)
  self:getUINode():setNodeEventEnabled(true)
  self.m_TouchNode = clickwidget.create(size.width, size.height, 0, 0, function(touchNode, event)
    self:OnTouchEvent(event)
  end)
  self:addChild(self.m_TouchNode)
end
function CZhaoQinLeaveWordBoardItem:setMsg(msg)
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
function CZhaoQinLeaveWordBoardItem:getIsLocal()
  return self.m_IsLocal
end
function CZhaoQinLeaveWordBoardItem:getItemInfo()
  return self.m_params
end
function CZhaoQinLeaveWordBoardItem:OnTouchEvent(event)
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
      self:OnClickItem()
      bg:setColor(ccc3(255, 255, 255))
      soundManager.playSound("xiyou/sound/clickbutton_2.wav")
    end
  end
end
function CZhaoQinLeaveWordBoardItem:OnClickItem()
  if self.m_callbackFun then
    self.m_callbackFun(self)
  end
end
function CZhaoQinLeaveWordBoardItem:Clear()
  self.m_callbackFun = nil
end
