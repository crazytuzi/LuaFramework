RegisterNmg = class("RegisterNmg", CcsSubView)
function RegisterNmg:ctor()
  RegisterNmg.super.ctor(self, "views/testview_reg.json")
  local btnBatchListener = {
    btn_reg = {
      listener = handler(self, self.Btn_Reg),
      variName = "m_Btn_Reg"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "m_BtnCancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  print("------------>>m_Btn_Reg:", self.m_Btn_Reg:getName(), self.m_Btn_Reg:getWidgetType())
  print("------------>>m_BtnCancel:", self.m_BtnCancel:getName(), self.m_BtnCancel:getWidgetType())
  self.m_Account = self:getNode("input_account")
  self.m_Pwd = self:getNode("input_pw")
  self.m_Pwd_C = self:getNode("input_pw_com")
  self.bg = self:getNode("bg")
  local size = self.bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("bg"):setSize(CCSize(display.width, display.height))
  end
  TextFieldEmoteExtend.extend(self.m_Account)
  TextFieldEmoteExtend.extend(self.m_Pwd)
  TextFieldEmoteExtend.extend(self.m_Pwd_C)
  self.m_Account:SetEnableChinese(false)
  self.m_Pwd:SetEnableChinese(false)
  self.m_Pwd_C:SetEnableChinese(false)
  self.m_Pwd:SetnablePassWord(true)
  self.m_Pwd_C:SetnablePassWord(true)
  if device.platform == "mac" then
    self.m_Account = CreateEditBoxForMac({}, self.m_Account, self)
    self.m_Pwd = CreateEditBoxForMac({}, self.m_Pwd, self)
    self.m_Pwd_C = CreateEditBoxForMac({}, self.m_Pwd_C, self)
  end
  self:getNode("corpright"):setVisible(false)
  soundManager.playLoginMusic()
  self:ListenMessage(MsgID_Connect)
end
function RegisterNmg:Btn_Reg(obj, t)
  print("==>>RegisterNmg:Btn_Reg")
  local account = self.m_Account:GetFieldText()
  local pwd = self.m_Pwd:GetFieldText()
  local pwdc = self.m_Pwd_C:GetFieldText()
  if pwd == nil or account == nil or string.len(pwd) <= 0 or string.len(account) <= 0 then
    return false
  end
  if pwdc ~= pwd then
    device.showAlert("错误", "两次密码不一致", {"确定"}, nil)
    return
  end
  if string.find(account, " ") ~= nil then
    ShowNotifyTips("用户名不能包含空格")
    return
  end
  if string.find(pwd, " ") ~= nil then
    ShowNotifyTips("密码不能包含空格")
    return
  end
  print("===>>> 注册:", account, pwd)
  getCurSceneView():ShowWaitingView()
  g_DataMgr:registerToDataServerWithNmg(account, pwd)
end
function RegisterNmg:Btn_Cancel(obj, t)
  print("==>>RegisterNmg:Btn_Cancel")
  self:CloseSelf()
end
function RegisterNmg:OnMessage(msgSID, ...)
  print("RegisterNmg:OnMessage:", msgSID, ...)
  if msgSID == MsgID_RegResult then
    getCurSceneView():HideWaitingView()
    local p = {
      ...
    }
    local isSucceed = p[1]
    local info = p[2]
    if info == nil then
      info = "请稍后重试"
    end
    if isSucceed ~= true then
      device.showAlert("注册失败", tostring(info), {"确定"}, nil)
    else
      self:CloseSelf()
    end
  elseif msgSID == MsgID_DataServer_ConnFailed or msgSID == MsgID_DataServer_ConnLost then
    self:CloseSelf()
  end
end
function RegisterNmg:Clear()
  self.m_Account:CloseTheKeyBoard()
  self.m_Account:ClearTextFieldExtend()
  self.m_Pwd:CloseTheKeyBoard()
  self.m_Pwd:ClearTextFieldExtend()
  self.m_Pwd_C:CloseTheKeyBoard()
  self.m_Pwd_C:ClearTextFieldExtend()
end
