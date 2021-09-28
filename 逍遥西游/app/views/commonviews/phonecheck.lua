phonecheckView = class("phonecheckView", CcsSubView)
function phonecheckView:ctor()
  phonecheckView.super.ctor(self, "views/tel_check.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_cancel = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_cancel",
      param = {3}
    },
    btn_ok = {
      listener = handler(self, self.OnBtn_OK),
      variName = "btn_ok"
    },
    btn_get = {
      listener = handler(self, self.OnBtn_Get),
      variName = "btn_get"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_InputTel = self:getNode("input_tel")
  local size = self.m_InputTel:getContentSize()
  TextFieldEmoteExtend.extend(self.m_InputTel, nil, {
    width = size.width,
    align = CRichText_AlignType_Left
  })
  self.m_InputTel:SetFieldText("")
  self.m_InputTel:SetFiledPlaceHolder("请输入手机号码", {
    color = ccc3(206, 187, 151)
  })
  self.m_InputTel:setMaxLengthEnabled(true)
  self.m_InputTel:setMaxLength(20)
  self.m_InputMsg = self:getNode("input_msg")
  size = self.m_InputMsg:getContentSize()
  TextFieldEmoteExtend.extend(self.m_InputMsg, nil, {
    width = size.width,
    align = CRichText_AlignType_Left
  })
  self.m_InputMsg:SetFieldText("")
  self.m_InputMsg:SetFiledPlaceHolder("请输入验证码", {
    color = ccc3(206, 187, 151)
  })
  self.m_InputMsg:setMaxLengthEnabled(true)
  self.m_InputMsg:setMaxLength(20)
end
function phonecheckView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Message_PhoneCheckSuccess then
    self:removeFromParent()
  end
end
function phonecheckView:Clear()
  if self.m_CallBack then
    self.m_CallBack()
  end
end
function phonecheckView:CheckIsMobile(str)
  return string.match(str, "[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str
end
function phonecheckView:OnBtn_Close(btnObj, touchType)
  self:removeFromParent()
end
function phonecheckView:OnBtn_OK(btnObj, touchType)
  local code = self.m_InputMsg:GetFieldText()
  if string.len(code) < 6 then
    ShowNotifyTips("请输入正确的验证码")
    return
  end
  netsend.netmessage.sendCheckPhone2(code)
end
function phonecheckView:OnBtn_Get(obj, t)
  local phone = self.m_InputTel:GetFieldText()
  if self:CheckIsMobile(phone) == false then
    ShowNotifyTips("请输入正确的手机号码")
    return
  end
  netsend.netmessage.sendCheckPhone1(phone)
  ShowNotifyTips("验证码已经发送，请留意您的手机")
end
