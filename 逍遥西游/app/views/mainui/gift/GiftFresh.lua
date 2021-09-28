local CGiftFreshView = class("CGiftFreshView", CcsSubView)
function CGiftFreshView:ctor(giftId)
  CGiftFreshView.super.ctor(self, "views/giftfreshview.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_Ok),
      variName = "btn_ok"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_Txt = self:getNode("txt1")
  self.m_TxtTime = self:getNode("time")
  self:ListenMessage(MsgID_Gift)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.updateTimeData))
  self:scheduleUpdate()
  self:updateTimeData()
  self:setItems()
end
function CGiftFreshView:updateTimeData()
  local showTxtFlag = true
  if gift.special:hasGetFreshGift() then
    showTxtFlag = false
  end
  if gift.special:canGetFreshGift() then
    showTxtFlag = false
  end
  self.m_Txt:setVisible(showTxtFlag)
  self.m_TxtTime:setVisible(showTxtFlag)
  if showTxtFlag then
    local ct = gift.special:getFreshGiftRestTime()
    local h, m, s = getHMSWithSeconds(ct)
    if h > 0 then
      self.m_TxtTime:setText(string.format("%02d:%02d:%02d", h, m, s))
    else
      self.m_TxtTime:setText(string.format("%02d:%02d", m, s))
    end
  end
end
function CGiftFreshView:setItems()
  if data_GiftOfSpecial[1] == nil then
    return
  end
  local items = data_GiftOfSpecial[1].items
  if items == nil then
    return
  end
  local index = 1
  for k, v in pairs(items) do
    if index > 3 then
      break
    end
    local pos = self:getNode(string.format("box%d", index))
    local x, y = pos:getPosition()
    local obj = createClickItem({
      itemID = k,
      autoSize = nil,
      num = v,
      LongPressTime = 0,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
    obj:setPosition(ccp(x, y))
    self:addChild(obj)
    index = index + 1
  end
end
function CGiftFreshView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Gift_FreshGiftUpdate then
    self:updateTimeData()
  end
end
function CGiftFreshView:OnBtn_Ok(btnObj, touchType)
  if gift.special:hasGetFreshGift() then
    ShowNotifyTips("不能重复领取")
    return
  end
  if gift.special:canGetFreshGift() == false then
    ShowNotifyTips("未到达领取时间")
    return
  end
  netsend.netgift.reqGetGiftOfFresh()
  self:CloseSelf()
end
function CGiftFreshView:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CGiftFreshView:Clear()
end
function ShowFreshGiftView()
  local dlg = CGiftFreshView.new()
  getCurSceneView():addSubView({
    subView = dlg,
    zOrder = MainUISceneZOrder.menuView
  })
end
