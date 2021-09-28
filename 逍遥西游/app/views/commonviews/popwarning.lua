CPopWarning = class("CPopWarning", CcsSubView)
PopWarningClickCancel = 1
PopWarningClickOK = 2
PopWarningClickClose = 3
function CPopWarning:ctor(para)
  CPopWarning.super.ctor(self, "views/pop_warning.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local title = para.title
  local text = para.text
  local confirmFunc = para.confirmFunc
  local cancelFunc = para.cancelFunc
  local closeFunc = para.closeFunc
  local confirmText = para.confirmText or "确定"
  local cancelText = para.cancelText or "取消"
  local clearFunc = para.clearFunc
  local confirmCloseFlag = para.confirmCloseFlag
  local emptyLineH = para.emptyLineH
  self.m_Align = para.align or CRichText_AlignType_Center
  self.m_AutoConfirmTime = para.autoConfirmTime
  self.m_AutoCancelTime = para.autoCancelTime
  self.m_HideInWar = para.hideInWar
  self.m_SetZOrder = para.zOrder or MainUISceneZOrder.popZView
  self.m_LackList = para.lackList
  if confirmCloseFlag == nil then
    confirmCloseFlag = true
  end
  self.m_ConfirmFunc = confirmFunc
  self.m_CancelFunc = cancelFunc
  self.m_CloseFunc = closeFunc
  self.m_ClearFunc = clearFunc
  self.m_ConfirmCloseFlag = confirmCloseFlag
  self.m_ConfirmText = confirmText
  self.m_CancelText = cancelText
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:setConfirmBtnText(confirmText)
  self:setCancelBtnText(cancelText)
  if title == nil then
    self:getNode("title"):setVisible(false)
  else
    self:getNode("title"):setText(title)
  end
  self:resetText(text, emptyLineH)
  local scene = getCurSceneView()
  if scene then
    scene:addSubView({
      subView = self,
      zOrder = self.m_SetZOrder
    })
  else
    print("--->>>>>   CPopWarning    scene == nil")
    if clearFunc then
      clearFunc(self)
    end
  end
  if self.m_AutoConfirmTime ~= nil then
    local totalTime = math.floor(self.m_AutoConfirmTime)
    if totalTime > 0 then
      self:setConfirmBtnText(string.format("%s(%ds)", self.m_ConfirmText, totalTime))
      local actList = {}
      for i = totalTime - 1, 1, -1 do
        do
          local time = i
          actList[#actList + 1] = CCDelayTime:create(1)
          actList[#actList + 1] = CCCallFunc:create(function()
            self:setConfirmBtnText(string.format("%s(%ds)", self.m_ConfirmText, time))
          end)
        end
      end
      actList[#actList + 1] = CCDelayTime:create(1)
      actList[#actList + 1] = CCCallFunc:create(function()
        self:OnBtn_Confirm()
      end)
      self:runAction(transition.sequence(actList))
    end
  elseif self.m_AutoCancelTime ~= nil then
    local totalTime = math.floor(self.m_AutoCancelTime)
    if totalTime > 0 then
      self:setCancelBtnText(string.format("%s(%ds)", self.m_CancelText, totalTime))
      local actList = {}
      for i = totalTime - 1, 1, -1 do
        do
          local time = i
          actList[#actList + 1] = CCDelayTime:create(1)
          actList[#actList + 1] = CCCallFunc:create(function()
            self:setCancelBtnText(string.format("%s(%ds)", self.m_CancelText, time))
          end)
        end
      end
      actList[#actList + 1] = CCDelayTime:create(1)
      actList[#actList + 1] = CCCallFunc:create(function()
        self:OnBtn_Cancel()
      end)
      self:runAction(transition.sequence(actList))
    end
  end
  if self.m_HideInWar then
    if JudgeIsInWar() then
      self:ShowWarning(false)
    else
      self:ShowWarning(true)
    end
    self:ListenMessage(MsgID_Scene)
  else
    self:ShowWarning(true)
  end
  if self.m_LackList then
    self:SetLackItems()
  end
  return self
end
function CPopWarning:SwallowTouchEvent(flag)
  if self.m_SwallowTouch == flag then
    return
  end
  if g_TouchEvent then
    self.m_SwallowTouch = flag
    g_TouchEvent:setCanTouch(not flag)
  end
end
function CPopWarning:OnMessage(msgSID, ...)
  if msgSID == MsgID_Scene_War_Enter then
    self:ShowWarning(false)
  elseif msgSID == MsgID_Scene_War_Exit then
    self:ShowWarning(true)
  end
end
function CPopWarning:setTitleColor(color)
  self:getNode("title"):setColor(color)
end
function CPopWarning:ShowWarning(iShow)
  self:setEnabled(iShow)
  self._auto_create_opacity_bg_ins:setEnabled(iShow)
  if iShow then
    self:resumeSchedulerAndActions()
  else
    self:pauseSchedulerAndActions()
  end
  self:SwallowTouchEvent(iShow)
end
function CPopWarning:SetLackItems()
  if self.m_LackList == nil then
    return
  end
  local itemNum = 0
  for tType, num in pairs(self.m_LackList) do
    itemNum = itemNum + 1
  end
  local tempNum = 0
  for tType, num in pairs(self.m_LackList) do
    local item = createClickItem({
      itemID = tType,
      autoSize = nil,
      num = 0,
      LongPressTime = 0,
      clickListener = function()
      end,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = nil
    })
    local numLabel = CCLabelTTF:create(string.format("%s", num), KANG_TTF_FONT, 23)
    local size = item:getContentSize()
    numLabel:setAnchorPoint(ccp(1, 0))
    numLabel:setPosition(ccp(size.width - 5, 5))
    numLabel:setColor(ccc3(255, 0, 0))
    item:addNode(numLabel)
    self:addChild(item)
    local mSize = item:getContentSize()
    local w = mSize.width
    local delW = 10
    local allW = itemNum * w + (itemNum - 1) * delW
    local x, y = self:getNode("bg"):getPosition()
    local x = x - allW / 2 + tempNum * (w + delW)
    item:setPosition(ccp(x, y + 20))
    tempNum = tempNum + 1
  end
  local size = self:getNode("list_text"):getContentSize()
  local x, y = self:getNode("list_text"):getPosition()
  local delY = 100
  self:getNode("list_text"):setSize(CCSize(size.width, size.height - delY))
end
function CPopWarning:resetText(text, emptyLineH)
  self:getNode("list_text"):removeAllItems()
  self.m_TextBox = nil
  local textSize = self:getNode("list_text"):getSize()
  if text == nil then
    self:getNode("list_text"):setVisible(false)
  else
    self.m_TextBox = CRichText.new({
      width = textSize.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 22,
      color = ccc3(255, 255, 255),
      align = self.m_Align,
      emptyLineH = emptyLineH
    })
    self.m_TextBox:addRichText(text)
    self:getNode("list_text"):pushBackCustomItem(self.m_TextBox)
  end
end
function CPopWarning:getTextBox()
  return self.m_TextBox
end
function CPopWarning:setConfirmBtnText(confirmText)
  if confirmText then
    self.m_Btn_Confirm:setTitleText(confirmText)
    self:checkBtnTextSize(self.m_Btn_Confirm)
  end
end
function CPopWarning:setCancelBtnText(cancelText)
  if cancelText then
    self.m_Btn_Cancel:setTitleText(cancelText)
    self:checkBtnTextSize(self.m_Btn_Cancel)
  end
end
function CPopWarning:checkBtnTextSize(btn)
  local maxWith = 100
  local defaultSize = 24
  local btnStr = btn:getTitleText()
  local ft = btn:getTitleFontName()
  for ftSize = defaultSize, 1, -1 do
    local temp = CCLabelTTF:create(btnStr, ft, ftSize)
    local size = temp:getContentSize()
    if maxWith > size.width then
      btn:setTitleFontSize(ftSize)
      break
    end
  end
end
function CPopWarning:OnBtn_Confirm(obj, t)
  if self.m_ConfirmFunc then
    self.m_ConfirmFunc(PopWarningClickOK)
  end
  if self.m_ConfirmCloseFlag == true then
    self:OnClose()
  end
end
function CPopWarning:OnBtn_Cancel(obj, t)
  if self.m_CancelFunc then
    self.m_CancelFunc(PopWarningClickCancel)
  end
  self:OnClose()
end
function CPopWarning:OnBtn_Close(obj, t)
  self:OnClose()
end
function CPopWarning:OnClose()
  if self.m_CloseFunc then
    self.m_CloseFunc(PopWarningClickClose)
  end
  self:removeFromParent()
end
function CPopWarning:Clear()
  self.m_ConfirmFunc = nil
  self.m_CancelFunc = nil
  self.m_CloseFunc = nil
  if self.m_ClearFunc then
    self.m_ClearFunc(self)
  end
  self:SwallowTouchEvent(false)
end
function CPopWarning:OnlyShowConfirmBtn()
  self.m_Btn_Cancel:setVisible(false)
  self.m_Btn_Cancel:setTouchEnabled(false)
  local _, y = self.m_Btn_Confirm:getPosition()
  local x, _ = self:getNode("bg"):getPosition()
  self.m_Btn_Confirm:setPosition(ccp(x, y))
end
function CPopWarning:OnlyShowCancelBtn()
  self.m_Btn_Confirm:setVisible(false)
  self.m_Btn_Confirm:setTouchEnabled(false)
  local _, y = self.m_Btn_Cancel:getPosition()
  local x, _ = self:getNode("bg"):getPosition()
  self.m_Btn_Cancel:setPosition(ccp(x, y))
end
function CPopWarning:ShowCloseBtn(flag)
  self.m_Btn_Close:setVisible(flag)
  self.m_Btn_Close:setTouchEnabled(flag)
end
