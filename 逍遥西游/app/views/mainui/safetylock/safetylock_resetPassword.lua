SafetylockResetPwd = class("SafetylockResetPwd", CcsSubView)
function SafetylockResetPwd:ctor()
  SafetylockResetPwd.super.ctor(self, "views/lock_reset_password.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "m_Btn_Confirm"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "m_Btn_Cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_InputPwd1 = self:getNode("input_pw1")
  local size = self.m_InputPwd1:getSize()
  TextFieldEmoteExtend.extend(self.m_InputPwd1, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_InputPwd2 = self:getNode("input_pw2")
  local size = self.m_InputPwd2:getSize()
  TextFieldEmoteExtend.extend(self.m_InputPwd2, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_InputPwd3 = self:getNode("input_pw3")
  local size = self.m_InputPwd3:getSize()
  TextFieldEmoteExtend.extend(self.m_InputPwd3, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
end
function SafetylockResetPwd:Clear()
end
function SafetylockResetPwd:OnBtn_Confirm(obj, t)
  local pwdString1 = self.m_InputPwd1:GetFieldText()
  local pwdString2 = self.m_InputPwd2:GetFieldText()
  local pwdString3 = self.m_InputPwd3:GetFieldText()
  print("pwdString1:", pwdString1)
  print("pwdString2:", pwdString2)
  print("pwdString3:", pwdString3)
  if checkStringIsLegalForSafetylock(pwdString1) == false then
    AwardPrompt.addPrompt("输入正确的密码")
    return
  end
  if checkStringIsLegalForSafetylock(pwdString2) == false then
    AwardPrompt.addPrompt("需要输入6~8位的新数字密码")
    return
  end
  if pwdString2 ~= pwdString3 then
    AwardPrompt.addPrompt("两次输入的密码不一致，请重新输入")
    return
  end
  netsend.netsafetylock.resetPwd(pwdString1, pwdString2, pwdString3)
  self:CloseSelf()
end
function SafetylockResetPwd:OnBtn_Cancel(obj, t)
  self:CloseSelf()
end
function ShowSafetylockResetPwdView()
  getCurSceneView():addSubView({
    subView = SafetylockResetPwd.new(),
    zOrder = MainUISceneZOrder.popSafetylock
  })
end
