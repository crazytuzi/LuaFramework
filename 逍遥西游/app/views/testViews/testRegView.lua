CTestRegView = class("CTestRegView", CcsSceneView)
function CTestRegView:ctor()
  CTestRegView.super.ctor(self, "views/testview_reg.json")
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
  self:getNode("bg"):setSize(CCSize(display.width, display.height))
  self:getUINode():setSize(CCSize(display.width, display.height))
  TextFieldOpenCloseExtend.extend(self.m_Account)
  TextFieldOpenCloseExtend.extend(self.m_Pwd)
  TextFieldOpenCloseExtend.extend(self.m_Pwd_C)
  self.m_Account:SetEnableChinese(false)
  self.m_Pwd:SetEnableChinese(false)
  self.m_Pwd_C:SetEnableChinese(false)
  if device.platform == "mac" then
    self.m_Account = CreateEditBoxForMac({}, self.m_Account, self)
    self.m_Pwd = CreateEditBoxForMac({}, self.m_Pwd, self)
    self.m_Pwd_C = CreateEditBoxForMac({}, self.m_Pwd_C, self)
  end
  self:ListenMessage(MsgID_Connect)
  soundManager.playLoginMusic()
  g_NetConnectMgr:ConnectSvr()
end
function CTestRegView:Btn_Reg(obj, t)
  print("==>>CTestRegView:Btn_Reg")
  local account = self.m_Account:getStringValue()
  local pwd = self.m_Pwd:getStringValue()
  local pwdc = self.m_Pwd_C:getStringValue()
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
  g_NetConnectMgr:ConnectSvrAndRegister(account, pwd)
end
function CTestRegView:Btn_Cancel(obj, t)
  print("==>>CTestRegView:Btn_Cancel")
  ShowLoginView()
end
function CTestRegView:OnMessage(msgSID, ...)
  print("CTestRegView:OnMessage:", msgSID, ...)
  if msgSID == MsgID_RegResult then
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
      ShowLoginView(false)
    end
  end
end
