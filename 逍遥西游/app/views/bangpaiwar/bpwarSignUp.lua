local bpwarSignUp = class("bpwarSignUp", CcsSubView)
function bpwarSignUp:ctor()
  bpwarSignUp.super.ctor(self, "views/bpsignup.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_sub = {
      listener = handler(self, self.OnBtn_Sub),
      variName = "btn_sub"
    },
    btn_add = {
      listener = handler(self, self.OnBtn_Add),
      variName = "btn_add"
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
  self.money = self:getNode("money")
  self.m_MeonyLeast = 500000
  self.m_Money = self.m_MeonyLeast
  self.m_MoneyPerChange = 100000
  g_TouchEvent:setCanTouch(false)
end
function bpwarSignUp:ShowMoneyText()
  self.money:setText(string.format("%d万", math.floor(self.m_Money / 10000)))
  AutoLimitObjSize(self.money, 70)
end
function bpwarSignUp:OnBtn_Close()
  self:CloseSelf()
end
function bpwarSignUp:OnBtn_Sub()
  if self.m_Money <= self.m_MeonyLeast then
    ShowNotifyTips("报名资金不能少于50万")
  else
    self.m_Money = self.m_Money - self.m_MoneyPerChange
    self:ShowMoneyText()
  end
end
function bpwarSignUp:OnBtn_Add()
  self.m_Money = self.m_Money + self.m_MoneyPerChange
  self:ShowMoneyText()
end
function bpwarSignUp:OnBtn_Cancel()
  self:CloseSelf()
end
function bpwarSignUp:OnBtn_Confirm()
  self:CloseSelf()
  g_BpWarMgr:send_submitMoney(self.m_Money)
end
function bpwarSignUp:Clear()
  g_TouchEvent:setCanTouch(true)
end
function RequestBangPaiWarSignUp()
  local bpPlace = g_BpMgr:getLocalBpPlace()
  if bpPlace ~= BP_PLACE_LEADER and bpPlace ~= BP_PLACE_FULEADER then
    ShowNotifyTips("你不是帮主或副帮主，不能报名帮战")
    return true
  end
  g_BpWarMgr:send_requestSignUp()
  return false
end
function BangPaiWarSignUpMoney()
  getCurSceneView():addSubView({
    subView = bpwarSignUp.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
