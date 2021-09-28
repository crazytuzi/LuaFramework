SafetylockSetPwd = class("SafetylockSetPwd", CcsSubView)
SafetylockSetPwd.__g_viewIns = nil
function SafetylockSetPwd:ctor()
  SafetylockSetPwd.super.ctor(self, "views/lock_set_password.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  SafetylockSetPwd.__g_viewIns = self
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
  local pos_tips = self:getNode("pos_tips")
  local size = pos_tips:getSize()
  local tipsText = CRichText.new({
    width = size.width,
    fontSize = 19,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Left
  })
  self:addChild(tipsText)
  local text = string.format("#<IRP>##<r:94,g:211,b:207>输入6到8位数字密码，用于保  护你的贵重物品#", i)
  tipsText:addRichText(text)
  local h = tipsText:getContentSize().height
  local x, y = pos_tips:getPosition()
  tipsText:setPosition(ccp(x, y + size.height - h))
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
end
function SafetylockSetPwd:Clear()
  if SafetylockSetPwd.__g_viewIns == self then
    SafetylockSetPwd.__g_viewIns = nil
  end
end
function SafetylockSetPwd:OnBtn_Confirm(obj, t)
  local pwdString1 = self.m_InputPwd1:GetFieldText()
  local pwdString2 = self.m_InputPwd2:GetFieldText()
  print("pwdString1:", pwdString1)
  print("pwdString2:", pwdString2)
  if checkStringIsLegalForSafetylock(pwdString1) == false then
    AwardPrompt.addPrompt("需要输入6~8位的数字密码")
    return
  end
  if pwdString2 ~= pwdString1 then
    AwardPrompt.addPrompt("两次输入的密码不一致，请重新输入")
    return
  end
  netsend.netsafetylock.setPwd(pwdString1, pwdString2)
  CloseSafetylockSetPwdView()
end
function SafetylockSetPwd:OnBtn_Cancel(obj, t)
  SendMessage(MsgID_SafetySetPwdViewCancel)
  CloseSafetylockSetPwdView()
end
function ShowSafetylockSetPwdView()
  getCurSceneView():addSubView({
    subView = SafetylockSetPwd.new(),
    zOrder = MainUISceneZOrder.popSafetylock
  })
end
function CloseSafetylockSetPwdView()
  if SafetylockSetPwd.__g_viewIns ~= nil then
    SafetylockSetPwd.__g_viewIns:CloseSelf()
  end
end
function safetylock_testCheckFunction()
  local check = function(text)
    local result = checkStringIsLegalForSafetylock(text)
    print("checkStringIsLegalForSafetylock:", result, text)
  end
  check("123")
  check("123*-")
  check("123*-123")
  check("123123e")
  check("12312e./;")
  check("985da236")
  check("1231239")
  check("123123")
  check("12312300")
  check("985236")
end
