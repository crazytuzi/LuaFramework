LoginNmg = class("LoginNmg", CcsSubView)
function LoginNmg:ctor(parent, isAutoLogin)
  LoginNmg.super.ctor(self, "views/testview_login.json")
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
  TextFieldEmoteExtend.extend(self.m_Account)
  TextFieldEmoteExtend.extend(self.m_Pwd)
  self.m_Account:SetEnableChinese(false)
  self.m_Pwd:SetEnableChinese(false)
  self.pic_bg = self:getNode("pic_bg")
  local size = self.pic_bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  end
  local a, p = getLoginAccountAndPwd()
  self.m_Account:SetFieldText(a)
  self.m_Pwd:SetnablePassWord(true)
  self.m_Pwd:SetFieldText(p)
  if device.platform == "mac" then
    self.m_Account = CreateEditBoxForMac({}, self.m_Account, self)
    self.m_Pwd = CreateEditBoxForMac({}, self.m_Pwd, self)
  end
  self.m_Parent = parent
  self:getNode("corpright"):setVisible(false)
  soundManager.playLoginMusic()
  do
    local function clickListener()
      print("-->>:", clickListener)
      self:CloseSelf()
    end
    local clickObj = TestcreateTxtClickObj(self:getUINode(), display.width - 50, display.height - 50, "取消", clickListener, ccc3(255, 0, 0), 255, 99)
  end
  self:ListenMessage(MsgID_Connect)
end
function LoginNmg:OnMessage(msgSID, ...)
  if msgSID == MsgID_Momo_LoginSucceed then
    self:CloseSelf()
  elseif msgSID == MsgID_LoginResult then
    local arg = {
      ...
    }
    if arg[1] == LOGIN_SUCCEED then
      self:CloseSelf()
      startClientService()
    end
  elseif msgSID == MsgID_RegResult then
    print("LoginNmg: 注册成功")
    local a, p = g_DataMgr:getNmgAccount()
    self.m_Account:SetFieldText(a)
    self.m_Pwd:SetFieldText(p)
    if a and p then
      self:StartLogin()
    end
  elseif msgSID == MsgID_DataServer_ConnFailed or msgSID == MsgID_DataServer_ConnLost then
    self:CloseSelf()
  end
end
function LoginNmg:onEnterTransitionFinish()
  if self.m_IsAutoLogin == true then
    self:StartLogin()
  end
end
function LoginNmg:StartLogin()
  local account = self.m_Account:GetFieldText()
  local pwd = self.m_Pwd:GetFieldText()
  print("===>>> Login:", account, pwd)
  if account == nil or string.len(account) <= 0 then
    ShowNotifyTips("请输入账号")
    return false
  end
  if pwd == nil or string.len(pwd) <= 0 then
    ShowNotifyTips("请输入密码")
    return false
  end
  getCurSceneView():ShowWaitingView()
  g_DataMgr:loginToDataServerWithNmg(account, pwd)
end
function LoginNmg:Btn_Login(obj, t)
  print("==>>LoginNmg:Btn_Login")
  self:StartLogin()
end
function LoginNmg:Btn_Reg(obj, t)
  print("==>>LoginNmg:Btn_Reg")
  if self.m_Parent then
    self.m_Parent:addSubView({
      subView = RegisterNmg.new(),
      zOrder = 100
    })
  end
end
function LoginNmg:Clear()
  self.m_Account:CloseTheKeyBoard()
  self.m_Account:ClearTextFieldExtend()
  self.m_Pwd:CloseTheKeyBoard()
  self.m_Pwd:ClearTextFieldExtend()
  self.m_Parent = nil
end
