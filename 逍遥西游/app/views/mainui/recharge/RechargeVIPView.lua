RechargeVIPView = class("RechargeVIPView", CcsSubView)
function RechargeVIPView:ctor(para)
  para = para or {}
  local curVIPLv = g_LocalPlayer:getVipLv()
  self.m_InitVIPIndex = para.VIPIndex or curVIPLv
  RechargeVIPView.super.ctor(self, "views/recharge_vip.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:InitPage()
  self:getNode("bg"):setTouchEnabled(true)
  self:getNode("bg"):addTouchEventListener(function(touchObj, event)
    self:OnTouchEvent(touchObj, event)
  end)
end
function RechargeVIPView:InitPage()
  local maxVIP = data_getMaxVIPLv()
  self.m_MinPageNum = 1
  self.m_MaxPageNum = maxVIP
  self.m_MoveLayer = self:getNode("box_layer")
  local x, y = self.m_MoveLayer:getPosition()
  self.m_MoveLayer.m_OriPosXY = ccp(x, y)
  self.m_HasTouchMoved = false
  self:ShowPage(self.m_InitVIPIndex)
end
function RechargeVIPView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function RechargeVIPView:OnBtn_Left(btnObj, touchType)
  self:ShowPrePage()
end
function RechargeVIPView:OnBtn_Right(btnObj, touchType)
  self:ShowNextPage()
end
function RechargeVIPView:ShowPage(pageIndex, showAction)
  if self.m_CurrPageIndex == pageIndex then
    return
  end
  pageIndex = math.max(pageIndex, self.m_MinPageNum)
  pageIndex = math.min(pageIndex, self.m_MaxPageNum)
  self.m_CurrPageIndex = pageIndex
  self:getNode("txt_vipNum"):setText(string.format("%d", pageIndex))
  local dt = 0.5
  for _, name in pairs({
    "txt_vipNum",
    "txt_1",
    "pic_1",
    "pic_vip"
  }) do
    local obj = self:getNode(name)
    if obj then
      obj:setOpacity(0)
      obj:runAction(CCFadeIn:create(dt))
    end
  end
  local tips = data_getVIPDes(self.m_CurrPageIndex)
  local size = self:getNode("box_tips"):getContentSize()
  local x, y = self:getNode("box_tips"):getPosition()
  if self.m_TextBox then
    self.m_TextBox:clearAll()
    self.m_TextBox:addRichText(tips)
  else
    self.m_TextBox = CRichText.new({
      width = size.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 25,
      color = ccc3(255, 255, 255),
      align = nil
    })
    self.m_TextBox:addRichText(tips)
    self.m_MoveLayer:addChild(self.m_TextBox)
  end
  local newSize = self.m_TextBox:getContentSize()
  self.m_TextBox:setPosition(ccp(x, y + size.height - newSize.height))
  self.m_TextBox:FadeIn(dt)
end
function RechargeVIPView:ResetToOriPosXY()
  self.m_MoveLayer:stopAllActions()
  local oriPosXY = self.m_MoveLayer.m_OriPosXY
  self.m_MoveLayer:setPosition(oriPosXY)
end
function RechargeVIPView:DrugCurrPage(offx)
  local del = 50
  local oriPosXY = self.m_MoveLayer.m_OriPosXY
  local dx = offx / 50
  if dx < -del then
    dx = -del
  elseif del < dx then
    dx = del
  end
  self.m_MoveLayer:setPosition(ccp(oriPosXY.x + dx, oriPosXY.y))
end
function RechargeVIPView:ShowPrePage()
  if self.m_CurrPageIndex <= self.m_MinPageNum then
    return false
  end
  self:ShowPage(self.m_CurrPageIndex - 1, true)
  return true
end
function RechargeVIPView:ShowNextPage()
  if self.m_CurrPageIndex >= self.m_MaxPageNum then
    return false
  end
  self:ShowPage(self.m_CurrPageIndex + 1, true)
  return true
end
function RechargeVIPView:DrugAtPos(startPos, endPos)
  local offx = endPos.x - startPos.x
  if offx > 20 then
    if not self:ShowPrePage() then
      self:BackToOriPosXY()
    end
  elseif offx < -20 then
    if not self:ShowNextPage() then
      self:BackToOriPosXY()
    end
  else
    self:BackToOriPosXY()
  end
end
function RechargeVIPView:BackToOriPosXY()
  local oriPosXY = self.m_MoveLayer.m_OriPosXY
  self.m_MoveLayer:stopAllActions()
  self.m_MoveLayer:runAction(CCMoveTo:create(0.3, oriPosXY))
end
function RechargeVIPView:OnTouchEvent(touchObj, event)
  if event == TOUCH_EVENT_BEGAN then
    self:ResetToOriPosXY()
    self.m_HasTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    local startPos = touchObj:getTouchStartPos()
    local movePos = touchObj:getTouchMovePos()
    if not self.m_HasTouchMoved and math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 40 then
      self.m_HasTouchMoved = true
    end
    if self.m_HasTouchMoved then
      self:DrugCurrPage(movePos.x - startPos.x)
    end
  elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
    if self.m_HasTouchMoved then
      local startPos = touchObj:getTouchStartPos()
      local endPos = touchObj:getTouchEndPos()
      self:DrugAtPos(startPos, endPos)
    end
    self:ResetToOriPosXY()
  end
end
