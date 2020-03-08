local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECGame = Lplus.ForwardDeclare("ECGame")
local DlgLogin = Lplus.Extend(ECPanelBase, "DlgLogin")
local def = DlgLogin.define
local dlg
local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
local LoginUtility = require("Main.Login.LoginUtility")
local DeviceUtility = require("Utility.DeviceUtility")
def.field("table").m_UIGO = nil
def.field("boolean").m_FirstCreate = true
def.field("boolean").hasExcuteQuickLaunch = false
def.static("=>", DlgLogin).Instance = function()
  if dlg == nil then
    dlg = DlgLogin()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, DlgLogin.Reset)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, DlgLogin.OnLoginSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ERROR, DlgLogin.OnLoginError)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_TYPE_CHANGE, DlgLogin.OnLoginTypeChange)
  if self.m_FirstCreate then
    self.m_FirstCreate = false
    do
      local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
      local ECGame = require("Main.ECGame")
      if UpdateNoticeModule.Instance().autoShow and ECGame.Instance():GetHistoryGameState(-1) == _G.GameState.None then
        UpdateNoticeModule.OpenNoticePanel(UpdateNoticeModule.NoticeSceneType.LoginAlert, function()
          UpdateNoticeModule.Instance().autoShow = false
        end)
      end
    end
  end
  ECGame.Instance():StartRefreshDirTimer()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.ImgBg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGO.Btn_Loading = self.m_panel:FindDirect("Btn_Loading")
  self.m_UIGO.BtnGroup = self.m_panel:FindDirect("BtnGroup")
  self.m_UIGO.Btn_Tourist = self.m_UIGO.BtnGroup:FindDirect("Btn_Tourist")
  self.m_UIGO.Btn_Wechat = self.m_UIGO.BtnGroup:FindDirect("Btn_Wechat")
  self.m_UIGO.Btn_QQ = self.m_UIGO.BtnGroup:FindDirect("Btn_QQ")
  self.m_UIGO.Btn_WechatSao = self.m_UIGO.BtnGroup:FindDirect("Btn_WechatSao")
  self.m_UIGO.BtnGroup_AllPlatform = self.m_panel:FindDirect("BtnGroup_AllPlatform")
  local isTGP = DeviceUtility.IsTGP()
  local simulatorTip = self.m_panel:FindDirect("Label_HealthTips/Label")
  if simulatorTip ~= nil and isTGP or SystemInfo.processorCount > 1 or SystemInfo.systemMemorySize <= 2000 then
    simulatorTip:SetActive(false)
  end
  local programVersion, versionName, version3 = GameUtil.GetProgramCurrentVersionInfo()
  local version = versionName
  version = version .. "."
  version = version .. string.format("%d", ECGame.Instance():getClientVersion())
  self.m_panel:FindDirect("Group_VersionNum/Label_Num"):GetComponent("UILabel").text = version
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  LoginUtility.CreateLoginBackground()
  self:CreatePanel(RESPATH.DLGLOGIN_UI_RES, 1)
  require("Main.ECGame").Instance():SetGameState(_G.GameState.LoginAccount)
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, DlgLogin.Reset)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, DlgLogin.OnLoginSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ERROR, DlgLogin.OnLoginError)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_TYPE_CHANGE, DlgLogin.OnLoginTypeChange)
end
def.static("table", "table").Reset = function()
  if dlg.m_panel then
    dlg.m_panel:FindChild("Btn_Loading"):GetComponent("UIButton"):set_isEnabled(true)
  end
end
def.method("=>", "boolean").IsQuickLaunch = function(self)
  return ECGame.Instance():IsQuickLaunch()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Loading" then
    local panel = self.m_UIGO.ImgBg
    local userName = panel:FindChild("Img_Id"):GetComponent("UIInput"):get_value()
    local password = panel:FindChild("Img_Password"):GetComponent("UIInput"):get_value()
    if not self:ValidateAccount(userName, password) then
      return
    end
    require("Main.ECGame").Instance():SetUserName(userName, password, "", 0)
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, nil)
    self:Hide()
  elseif id == "Btn_Tourist" then
    local loginTipsPanel = require("Main.Login.ui.LoginTipsPanel")
    loginTipsPanel.Instance():ShowPanel()
  elseif id == "Btn_Wechat" then
    self:LoginWithWechat()
  elseif id == "Btn_QQ" then
    self:LoginWithQQ()
  elseif id == "Btn_WechatSao" then
    ECMSDK.QRCodeLogin(MSDK_LOGIN_PLATFORM.WX)
  elseif id == "Btn_Wechat_Ios" then
    self:OnClickWechatIOSBtn()
  elseif id == "Btn_Wechat_Android" then
    self:OnClickWechatAndroidBtn()
  elseif id == "Btn_QQ_Ios" then
    self:OnClickQQIOSBtn()
  elseif id == "Btn_QQ_Android" then
    self:OnClickQQAndroidBtn()
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local imgBgGO = self.m_UIGO.ImgBg
  local btnGO = self.m_UIGO.Btn_Loading
  local btnGroupGO = self.m_UIGO.BtnGroup
  local btnAllPlatformGroupGO = self.m_UIGO.BtnGroup_AllPlatform
  local isAccountPwdLogin = self:IsAccountPwdLogin()
  local isMSDK = ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK
  GUIUtils.SetActive(imgBgGO, isAccountPwdLogin)
  GUIUtils.SetActive(btnGO, isAccountPwdLogin)
  GUIUtils.SetActive(btnGroupGO, not isAccountPwdLogin and isMSDK)
  GUIUtils.SetActive(btnAllPlatformGroupGO, not isAccountPwdLogin and isMSDK)
  if self:IsAccountPwdLogin() then
    local ECGame = require("Main.ECGame").Instance()
    local lastUserName = LoginUtility.Instance():GetLastUserName()
    if lastUserName == "" then
      lastUserName = ECGame.m_UserName
    end
    GUIUtils.SetUIInputValue(imgBgGO:FindDirect("Img_Id"), lastUserName)
    GUIUtils.SetUIInputValue(imgBgGO:FindDirect("Img_Password"), ECGame.m_Password)
  elseif isMSDK then
    local isTGP = DeviceUtility.IsTGP()
    GUIUtils.SetActive(btnGroupGO, not isTGP)
    GUIUtils.SetActive(btnAllPlatformGroupGO, isTGP)
    if isTGP and btnAllPlatformGroupGO then
      local guestBtnGO = btnAllPlatformGroupGO:FindDirect("Btn_Tourist")
      local wxSaoBtnGO = btnAllPlatformGroupGO:FindDirect("Btn_WechatSao")
      GUIUtils.SetActive(guestBtnGO, false)
      GUIUtils.SetActive(wxSaoBtnGO, false)
    else
      local wxBtnGO = btnGroupGO:FindDirect("Btn_Wechat")
      local guestBtnGO = btnGroupGO:FindDirect("Btn_Tourist")
      local wxSaoBtnGO = btnGroupGO:FindDirect("Btn_WechatSao")
      GUIUtils.SetActive(wxBtnGO, platform == 1 and ECMSDK.IsPlatformInstalled(MSDK_LOGIN_PLATFORM.WX) or platform == 2)
      GUIUtils.SetActive(guestBtnGO, platform == 1)
      GUIUtils.SetActive(wxSaoBtnGO, false)
    end
  end
  if self:IsQuickLaunch() and not self.hasExcuteQuickLaunch then
    if self:IsAccountPwdLogin() then
      self:onClick("Btn_Loading")
    end
    self.hasExcuteQuickLaunch = true
  end
end
local timerId = 0
local TIMEOUT_SECONDS = 5
def.method("boolean").EnableLoginBtns = function(self, isEnabled)
  if self.m_UIGO == nil then
    return
  end
  if timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(timerId)
    timerId = 0
  end
  if not isEnabled then
    timerId = GameUtil.AddGlobalTimer(TIMEOUT_SECONDS, true, function()
      timerId = 0
      self:EnableLoginBtns(true)
    end)
  end
  if self.m_UIGO.BtnGroup:get_activeSelf() then
    GUIUtils.EnableButton(self.m_UIGO.Btn_Tourist, isEnabled)
    GUIUtils.EnableButton(self.m_UIGO.Btn_Wechat, isEnabled)
    GUIUtils.EnableButton(self.m_UIGO.Btn_QQ, isEnabled)
    GUIUtils.EnableButton(self.m_UIGO.Btn_WechatSao, false)
  elseif self.m_UIGO.BtnGroup_AllPlatform and self.m_UIGO.BtnGroup_AllPlatform:get_activeSelf() then
    local BtnGroup_AllPlatform = self.m_UIGO.BtnGroup_AllPlatform
    GUIUtils.EnableButton(BtnGroup_AllPlatform:FindDirect("Btn_Wechat_Ios"), isEnabled)
    GUIUtils.EnableButton(BtnGroup_AllPlatform:FindDirect("Btn_Wechat_Android"), isEnabled)
    GUIUtils.EnableButton(BtnGroup_AllPlatform:FindDirect("Btn_QQ_Ios"), isEnabled)
    GUIUtils.EnableButton(BtnGroup_AllPlatform:FindDirect("Btn_QQ_Android"), isEnabled)
  end
end
def.static("table", "table").OnLoginSuccess = function()
  dlg:Hide()
end
def.static("table", "table").OnLoginError = function()
  dlg:EnableLoginBtns(true)
end
def.static("table", "table").OnLoginTypeChange = function()
  dlg:OnShow(true)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string", "string", "=>", "boolean").ValidateAccount = function(self, userName, password)
  if #userName == 0 then
    Toast(textRes.Login[1])
    return false
  end
  userName = string.upper(userName)
  if password ~= "123456" then
    Toast(textRes.Login[4])
    return false
  end
  return true
end
def.method("=>", "boolean").IsAccountPwdLogin = function(self)
  if platform == 0 or loginModule:IsNoAuthcLogin() then
    return true
  end
  return false
end
def.override("=>", "boolean").OnMoveBackward = function(self)
  return false
end
def.method().OnClickWechatIOSBtn = function(self)
  loginModule:SetLoginPlatform(Platform.ios)
  self:LoginWithWechat()
end
def.method().OnClickWechatAndroidBtn = function(self)
  loginModule:SetLoginPlatform(Platform.android)
  self:LoginWithWechat()
end
def.method().OnClickQQIOSBtn = function(self)
  loginModule:SetLoginPlatform(Platform.ios)
  self:LoginWithQQ()
end
def.method().OnClickQQAndroidBtn = function(self)
  loginModule:SetLoginPlatform(Platform.android)
  self:LoginWithQQ()
end
def.method().LoginWithWechat = function(self)
  self:EnableLoginBtns(false)
  if ECMSDK.IsPlatformInstalled(MSDK_LOGIN_PLATFORM.WX) then
    ECMSDK.Login(MSDK_LOGIN_PLATFORM.WX)
    ECMSDK.ReportEvent("login", "10", true)
    ECMSDK.SetGSDKEvent(3, true, "WX")
  else
    ECMSDK.QRCodeLogin(MSDK_LOGIN_PLATFORM.WX)
  end
end
def.method().LoginWithQQ = function(self)
  self:EnableLoginBtns(false)
  ECMSDK.Login(MSDK_LOGIN_PLATFORM.QQ)
  ECMSDK.ReportEvent("login", "11", true)
  ECMSDK.SetGSDKEvent(3, true, "QQ")
end
DlgLogin.Commit()
return DlgLogin
