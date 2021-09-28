CBpContribute = class("CBpContribute", CcsSubView)
function CBpContribute:ctor()
  CBpContribute.super.ctor(self, "views/bpcontribute.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_10 = {
      listener = handler(self, self.OnBtn_10),
      variName = "btn_10"
    },
    btn_100 = {
      listener = handler(self, self.OnBtn_100),
      variName = "btn_100"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.img_selected = self:getNode("img_selected")
  self.txt_total = self:getNode("txt_total")
  self.txt_curr = self:getNode("txt_curr")
  self:SetTotalContribute()
  self:SetTotalContributeLeft()
  self:OnBtn_10()
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_PlayerInfo)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpContribute:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_LocalInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.i_offer ~= nil then
      self:SetTotalContribute()
    end
  elseif msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  elseif msgSID == MsgID_BpOfferUpdate then
    self:SetTotalContributeLeft()
  end
end
function CBpContribute:SetTotalContribute()
  self.txt_total:setText(tostring(g_BpMgr:getLocalPlayerOffer()))
end
function CBpContribute:SetTotalContributeLeft()
  self.txt_curr:setText(tostring(g_LocalPlayer:getBpConstruct()))
end
function CBpContribute:OnBtn_10()
  local x, y = self.btn_10:getPosition()
  self.img_selected:setPosition(ccp(x + 18, y + 8))
  self.m_SelectOffer = 100000
end
function CBpContribute:OnBtn_100()
  local x, y = self.btn_100:getPosition()
  self.img_selected:setPosition(ccp(x + 18, y + 8))
  self.m_SelectOffer = 1000000
end
function CBpContribute:OnBtn_Close()
  self:CloseSelf()
end
function CBpContribute:OnBtn_Confirm()
  local offerLimit = 30000000
  local totalOffer = g_BpMgr:getLocalPlayerOffer()
  if offerLimit <= totalOffer then
    ShowNotifyTips("已达捐献上限3000万了，不能再捐献了")
    return
  end
  local myOffer = g_LocalPlayer:getBpConstruct()
  local needOffer = math.min(self.m_SelectOffer, offerLimit - totalOffer)
  if myOffer >= needOffer then
    g_BpMgr:send_contributeOffer(self.m_SelectOffer)
  else
    self:setDlgShow(false)
    CBpContributeLack.new(myOffer, needOffer, handler(self, self.OnBtn_Close), handler(self, self.ReShowDlg))
  end
end
function CBpContribute:ReShowDlg()
  self:setDlgShow(true)
end
function CBpContribute:setDlgShow(iShow)
  self:setEnabled(iShow)
  self._auto_create_opacity_bg_ins:setEnabled(iShow)
end
function CBpContribute:Clear()
end
CBpContributeLack = class("CBpContributeLack", CcsSubView)
function CBpContributeLack:ctor(myOffer, needOffer, closeListener, cancelListener)
  CBpContributeLack.super.ctor(self, "views/bpcontributelack.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseListener = closeListener
  self.m_CancelListener = cancelListener
  self.m_NeedOffer = needOffer
  local layertip = self:getNode("layertip")
  layertip:setVisible(false)
  local parent = layertip:getParent()
  local x, y = layertip:getPosition()
  local size = layertip:getContentSize()
  local tipBox = CRichText.new({
    width = size.width,
    color = ccc3(255, 255, 255),
    fontSize = 20
  })
  parent:addChild(tipBox)
  local lackOffer = needOffer - myOffer
  local tip = string.format("你的帮派贡献度不足%d，还需要%d，是否使用#<IR1>#%d抵扣？", needOffer, lackOffer, lackOffer)
  tipBox:addRichText(tip)
  local tipSize = tipBox:getRichTextSize()
  tipBox:setPosition(ccp(x, y + size.height - tipSize.height))
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpContributeLack:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  end
end
function CBpContributeLack:OnBtn_Close()
  if self.m_CloseListener then
    self.m_CloseListener()
    self:ClearListeners()
  end
  self:CloseSelf()
end
function CBpContributeLack:OnBtn_Cancel()
  if self.m_CancelListener then
    self.m_CancelListener()
    self:ClearListeners()
  end
  self:CloseSelf()
end
function CBpContributeLack:OnBtn_Confirm()
  self:OnBtn_Cancel()
  g_BpMgr:send_contributeOffer(self.m_NeedOffer)
end
function CBpContributeLack:ClearListeners()
  self.m_CancelListener = nil
  self.m_CloseListener = nil
end
function CBpContributeLack:Clear()
  if self.m_CloseListener then
    self:m_CloseListener()
  end
  self:ClearListeners()
end
