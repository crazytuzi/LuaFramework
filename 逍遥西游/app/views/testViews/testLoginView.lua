CTestLoginView = class("CTestLoginView", CcsSceneView)
function CTestLoginView:ctor(isAutoLogin)
  CTestLoginView.super.ctor(self, "views/testview_login.json")
  local btnBatchListener = {
    btn_login = {
      listener = handler(self, self.Btn_Login),
      variName = "m_BtnLogin"
    },
    btn_reg = {
      listener = handler(self, self.Btn_Reg),
      variName = "m_BtnReg"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_IsAutoLogin = isAutoLogin
  self.m_Account = self:getNode("input_account")
  self.m_Pwd = self:getNode("input_pw")
  TextFieldOpenCloseExtend.extend(self.m_Account)
  TextFieldOpenCloseExtend.extend(self.m_Pwd)
  self.m_Account:SetEnableChinese(false)
  self.m_Pwd:SetEnableChinese(false)
  self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  self:getUINode():setSize(CCSize(display.width, display.height))
  local a, p = getLoginAccountAndPwd()
  self.m_Account:setText(a)
  self.m_Pwd:setText(p)
  if device.platform == "mac" then
    self.m_Account = CreateEditBoxForMac({}, self.m_Account, self)
    self.m_Pwd = CreateEditBoxForMac({}, self.m_Pwd, self)
  end
  soundManager.playLoginMusic()
end
function CTestLoginView:onEnterTransitionFinish()
  if self.m_IsAutoLogin == true then
    self:StartLogin()
  end
end
function CTestLoginView:StartLogin()
  local account = self.m_Account:getStringValue()
  local pwd = self.m_Pwd:getStringValue()
  print("===>>> Login:", account, pwd)
  if account == nil or string.len(account) <= 0 then
    ShowNotifyTips("请输入账号")
    return false
  end
  if pwd == nil or string.len(pwd) <= 0 then
    ShowNotifyTips("请输入密码")
    return false
  end
  g_NetConnectMgr:ConnectSvrAndLogin(account, pwd)
end
function CTestLoginView:Btn_Login(obj, t)
  print("==>>CTestLoginView:Btn_Login")
  self:StartLogin()
end
function CTestLoginView:Btn_Reg(obj, t)
  print("==>>CTestLoginView:Btn_Reg")
  CTestRegView:new():Show()
end
