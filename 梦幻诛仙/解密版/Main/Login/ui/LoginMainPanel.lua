local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local LoginMainPanel = Lplus.Extend(ECPanelBase, "LoginMainPanel")
local def = LoginMainPanel.define
local instance
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
local LoginUtility = require("Main.Login.LoginUtility")
local ServerListMgr = require("Main.Login.ServerListMgr")
local LoginHistoryMgr = require("Main.Login.LoginHistoryMgr")
local UpdateNoticeModule = Lplus.ForwardDeclare("UpdateNoticeModule")
local LoginUIMgr = Lplus.ForwardDeclare("LoginUIMgr")
local ECGame = Lplus.ForwardDeclare("ECGame")
local RealNameAuthMgr = require("Main.RealNameAuth.RealNameAuthMgr")
def.const("table").Action = {
  NONE = 0,
  UPDATE_LOGIN_INFO = 1,
  SELECT_SERVER = 2,
  SELECT_ROLE = 3,
  LOGIN = 4,
  ON_DOWNLOAD_SERVER_LIST = 5
}
def.field("number").lastAction = 0
def.field("boolean").isLoginRole = false
def.field("boolean").isLogining = false
def.field("boolean").hasExcuteQuickLaunch = false
def.field("table").actionQueue = nil
def.field("table").uiObjs = nil
def.static("=>", LoginMainPanel).Instance = function()
  if instance == nil then
    instance = LoginMainPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  LoginUtility.CreateLoginBackground()
  self:CreatePanel(RESPATH.PREFAB_LOGIN_MAIN_PANEL_RES, 1)
  require("Main.ECGame").Instance():SetGameState(_G.GameState.LoginMain)
end
def.override().OnCreate = function(self)
  self:InitData()
  LoginUtility.StartAuroraSdk()
  self:InitUI()
  self.isLogining = false
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, LoginMainPanel.OnLoginAccountSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, LoginMainPanel.OnLoginServerSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, LoginMainPanel.OnLoginRoleSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, LoginMainPanel.OnResetUI)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.CACHED_ROLE_NOT_EXIST, LoginMainPanel.OnCachedRoleNotExist)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_RESUME, LoginMainPanel.OnResumeGame)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_LIST_UPDATE, LoginMainPanel.OnServerListUpdate)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_ERROR, LoginMainPanel.OnLoginRoleError)
  self:UpdateUI()
  ECGame.Instance():StartRefreshDirTimer()
end
def.override().OnDestroy = function(self)
  require("GUI.WaitingTip").HideTip()
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, LoginMainPanel.OnLoginAccountSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, LoginMainPanel.OnLoginServerSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, LoginMainPanel.OnLoginRoleSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, LoginMainPanel.OnResetUI)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.CACHED_ROLE_NOT_EXIST, LoginMainPanel.OnCachedRoleNotExist)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_RESUME, LoginMainPanel.OnResumeGame)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_LIST_UPDATE, LoginMainPanel.OnServerListUpdate)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_ERROR, LoginMainPanel.OnLoginRoleError)
  self.lastAction = LoginMainPanel.Action.NONE
end
def.override("=>", "boolean").OnMoveBackward = function(self)
  return false
end
def.method().InitData = function(self)
  self.actionQueue = {
    self.CheckNotice,
    self.CheckRealNameAuthInfo,
    self.UpdateServerListInfo
  }
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Img_BgServer = self.uiObjs.Img_Bg0:FindDirect("Img_BgServer")
  self.uiObjs.Img_BgName = self.uiObjs.Img_Bg0:FindDirect("Img_BgName")
  self.uiObjs.Btn_LoadIn = self.uiObjs.Img_Bg0:FindDirect("Btn_LoadIn")
  self.uiObjs.Img_Bg2 = self.uiObjs.Img_Bg0:FindDirect("Img_Bg2")
  self:ShowPreparingUI()
  self:SetPrepareInfo("")
  GUIUtils.SetActive(self.uiObjs.Img_Bg0:FindDirect("Btn_Help"), ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK and _G.LoginPlatform ~= MSDK_LOGIN_PLATFORM.GUEST and not ClientCfg.IsOtherChannel())
  local programVersion, versionName, version3 = GameUtil.GetProgramCurrentVersionInfo()
  local version = versionName
  version = version .. "."
  version = version .. string.format("%d", ECGame.Instance():getClientVersion())
  self.m_panel:FindDirect("Img_Bg0/Group_VersionNum/Label_Num"):GetComponent("UILabel").text = version
end
def.method("string").onClick = function(self, id)
  if id == "Btn_LoadIn" then
    self:OnLoginButtonClick()
  elseif id == "Img_BgName" then
    self:OnSelectRoleButtonClick()
  elseif id == "Img_BgServer" then
    self:OnSelectServerButtonClick()
  elseif id == "Btn_Change" then
    self:OnChangeAccountButtonClick()
  elseif id == "Btn_Notice" then
    self:OnNoticeButtonClick()
  elseif id == "Btn_Help" then
    local url = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf2248"
    if platform == 1 then
      url = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf2284"
    end
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.OpenURL(url)
  end
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method().UpdateUI = function(self)
  if self.m_panel == nil then
    return
  end
  self:PerformNextAction()
end
def.method().PerformNextAction = function(self)
  local action = self.actionQueue[1]
  if action then
    table.remove(self.actionQueue, 1)
    action(self)
  end
end
def.method().CheckNotice = function(self)
  if UpdateNoticeModule.Instance().autoShow and not self:NeedQuickLaunch() then
    self:SetPrepareUpdateNoticeInfo()
    self:OpenNoticePanel(function(ret)
      UpdateNoticeModule.Instance().autoShow = false
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      self:PerformNextAction()
    end)
  else
    self:PerformNextAction()
  end
end
def.method().CheckRealNameAuthInfo = function(self)
  if not RealNameAuthMgr.Instance():IsEnabled() or RealNameAuthMgr.Instance():HasAuthorizeHistory() then
    self:PerformNextAction()
    return
  end
  self:SetPrepareRealNameAuthInfo()
  local realNameAuthTimerId
  local TIMEOUT_TIME = 5
  realNameAuthTimerId = GameUtil.AddGlobalTimer(TIMEOUT_TIME, true, function()
    if not self:IsLoaded() then
      return
    end
    if realNameAuthTimerId == nil then
      return
    end
    realNameAuthTimerId = nil
    self:PerformNextAction()
  end)
  RealNameAuthMgr.Instance():CheckFirstRegInfo(function(info)
    if not self:IsLoaded() then
      return
    end
    if realNameAuthTimerId == nil then
      return
    end
    if realNameAuthTimerId then
      GameUtil.RemoveGlobalTimer(realNameAuthTimerId)
      realNameAuthTimerId = nil
    end
    if info and info.needPop then
      RealNameAuthMgr.Instance():PopAuthMessage(function()
        if not self:IsLoaded() then
          return
        end
        self:PerformNextAction()
      end)
    else
      self:PerformNextAction()
    end
  end)
end
def.method().UpdateServerListInfo = function(self)
  local serverList = ServerListMgr.Instance():GetServerList()
  if serverList == nil then
    self:SetPrepareServerListInfo()
    ServerListMgr.Instance():DownloadServerList(LoginMainPanel.OnDownloadServerListCallback)
  else
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SetGSDKEvent(5, true, "success")
    self:UpdateLoginInfo(true)
  end
end
def.static("table").OnDownloadUpdateNoticeCallback = function(ret)
  local self = instance
  if not UpdateNoticeModule.Instance():HasRead() then
    self:OpenNoticePanel(function()
      self:UpdateUI()
    end)
  else
    self:UpdateUI()
  end
end
def.static("table").OnDownloadServerListCallback = function(ret)
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if ret == nil then
    self:ShowDownloadServerListErr()
    return
  end
  self:UpdateLoginInfo(false)
  local success = loginModule:SDKLoginDone()
  if not success then
    self.lastAction = LoginMainPanel.Action.ON_DOWNLOAD_SERVER_LIST
    return
  end
  local lastServerCfg = ServerListMgr.Instance():GetSelectedServerCfg()
  if lastServerCfg == nil then
    self:HidePanel()
    LoginUIMgr.Instance():ShowChooseServerUI()
  else
    self:UpdateLoginInfo(false)
  end
end
def.method().ShowDownloadServerListErr = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Login[100], textRes.Login[108], textRes.Login[105], textRes.Login[106], 1, 10, function(i, tag)
    if i == 1 then
      self:UpdateUI()
    else
      gmodule.moduleMgr:GetModule(ModuleId.LOGIN):ReLogin()
      return
    end
  end, {id = self})
end
def.method().ShowPreparingUI = function(self)
  self.uiObjs.Img_BgServer:SetActive(false)
  self.uiObjs.Img_BgName:SetActive(false)
  self.uiObjs.Btn_LoadIn:SetActive(false)
  self.uiObjs.Img_Bg2:SetActive(true)
end
def.method().ShowReadyUI = function(self)
  self.uiObjs.Img_BgServer:SetActive(true)
  self.uiObjs.Img_BgName:SetActive(true)
  self.uiObjs.Btn_LoadIn:SetActive(true)
  self.uiObjs.Img_Bg2:SetActive(false)
end
def.method("=>", "boolean").NeedQuickLaunch = function(self)
  if ECGame.Instance():IsQuickLaunch() and not self.hasExcuteQuickLaunch then
    return true
  else
    return false
  end
end
def.method("boolean").UpdateLoginInfo = function(self, needLogin)
  self:ShowReadyUI()
  self:SetServerInfo()
  self:SetRoleInfo()
  if needLogin then
    local success = loginModule:SDKLoginDone()
    if success then
      if self:NeedQuickLaunch() then
        self.hasExcuteQuickLaunch = true
        self:OnLoginButtonClick()
      end
    else
      self.lastAction = LoginMainPanel.Action.UPDATE_LOGIN_INFO
    end
  end
end
local _timerId
def.method().SetServerInfo = function(self)
  local serverCfg = ServerListMgr.Instance():GetSelectedServerCfg()
  local label_serverName = self.m_panel:FindDirect("Img_Bg0/Img_BgServer/Label_Server"):GetComponent("UILabel")
  if serverCfg == nil then
    local ret = false
    if ret == false then
      serverCfg = self:SelectRecommendServer()
    else
      local TIMEOUT_TIME = 2
      _timerId = GameUtil.AddGlobalTimer(TIMEOUT_TIME, true, function()
        _timerId = nil
        if self.m_panel == nil or self.m_panel.isnil then
          return
        end
        self:SelectRecommendServer()
        self:UpdateLoginInfo(false)
      end)
    end
  end
  if serverCfg then
    label_serverName:set_text(serverCfg.name)
    if _timerId then
      GameUtil.RemoveGlobalTimer(_timerId)
      _timerId = nil
    end
  else
    label_serverName:set_text(textRes.Login[21])
  end
end
def.method("=>", "table").SelectRecommendServer = function(self)
  local servers = ServerListMgr.Instance():GetRecommendServers(1)
  local serverCfg = servers[1]
  if serverCfg then
    loginModule.selectedServerNo = serverCfg.no
  end
  return serverCfg
end
def.method().SetRoleInfo = function(self)
  local role = loginModule:GetLastLoginRole()
  local text = ""
  if role ~= nil then
    local occupationName = GetOccupationName(role.basic.occupation)
    text = string.format("%s %s", occupationName, tostring(role.basic.name))
  end
  self.m_panel:FindChild("Label_Name"):GetComponent("UILabel"):set_text(text)
end
def.method().SetPrepareServerListInfo = function(self)
  self:ShowPreparingUI()
  self:SetPrepareInfo(textRes.Login[29])
end
def.method().SetPrepareUpdateNoticeInfo = function(self)
  self:ShowPreparingUI()
  self:SetPrepareInfo(textRes.Login[31])
end
def.method().SetPrepareRealNameAuthInfo = function(self)
  self:ShowPreparingUI()
  self:SetPrepareInfo(textRes.Login[67])
end
def.method("string").SetPrepareInfo = function(self, text)
  self.uiObjs.Img_Bg2:FindDirect("Label"):GetComponent("UILabel").text = text
end
def.method().OnLoginButtonClick = function(self)
  TraceHelper.trace("ClickEnterGame")
  local success = loginModule:SDKLoginDone()
  if not success then
    self.lastAction = LoginMainPanel.Action.LOGIN
    return
  end
  local serverCfg = ServerListMgr.Instance():GetSelectedServerCfg()
  if serverCfg == nil then
    Toast(textRes.Login[22])
    self:HidePanel()
    LoginUIMgr.Instance():ShowChooseServerUI()
    return
  end
  self.m_panel:FindDirect("Img_Bg0/Btn_LoadIn"):GetComponent("UIButton"):set_isEnabled(false)
  self:LoginReq()
end
def.method().LoginReq = function(self)
  if self.isLogining then
    return
  end
  local cachedRoleList = loginModule:GetCachedRoleList()
  local success = false
  if cachedRoleList and #cachedRoleList > 0 then
    success = loginModule:LoginServerAndRole()
  else
    success = loginModule:LoginServer()
  end
  if not success then
    return
  end
  require("GUI.WaitingTip").ShowTip(textRes.Login[23])
  self.isLogining = true
end
def.method().LoginRole = function(self)
  local role = loginModule:GetLastLoginRole()
  if role == nil then
    self:SelectRoleReq()
    return
  end
  local roleId = role.roleid
  local result = loginModule:LoginRole(roleId)
  if result == LoginModule.CResult.ROLE_ARE_DELETING then
    LoginUIMgr.Instance():ShowSelectRoleUI()
    self:HidePanel()
  elseif result == LoginModule.CResult.ROLE_ARE_BANNED then
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    gmodule.network.disConnect()
  elseif result == LoginModule.CResult.ROLE_NOT_EXIST then
    warn("***ROLE_NOT_EXIST***", debug.traceback())
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    gmodule.network.disConnect()
  end
end
def.method().OnSelectRoleButtonClick = function(self)
  local success = loginModule:SDKLoginDone()
  if not success then
    self.lastAction = LoginMainPanel.Action.SELECT_ROLE
    return
  end
  if loginModule.selectedServerNo == 0 then
    Toast(textRes.Login[22])
    self:HidePanel()
    LoginUIMgr.Instance():ShowChooseServerUI()
    return
  end
  self:SelectRoleReq()
end
def.method().SelectRoleReq = function(self)
  if _G.IsConnected() then
    if loginModule:IsRoleListEmpty() then
      LoginUIMgr.Instance():ShowCreateRoleUI()
    else
      LoginUIMgr.Instance():ShowSelectRoleUI()
    end
    self:HidePanel()
  else
    if self.isLogining then
      return
    end
    local success = loginModule:LoginServer()
    if success then
      require("GUI.WaitingTip").ShowTip(textRes.Login[23])
      self.isLogining = true
    end
  end
end
def.method().OnSelectServerButtonClick = function(self)
  local success = loginModule:SDKLoginDone()
  if not success then
    self.lastAction = LoginMainPanel.Action.SELECT_SERVER
    return
  end
  self:HidePanel()
  LoginUIMgr.Instance():ShowChooseServerUI()
end
def.method().OnChangeAccountButtonClick = function(self)
  self:HidePanel()
  loginModule:ReLogin()
end
def.method().OnNoticeButtonClick = function(self)
  self:OpenNoticePanel(function(ret)
    if ret == false then
      Toast(textRes.UpdateNotice[1])
    end
  end)
end
def.method("function").OpenNoticePanel = function(self, onClose)
  UpdateNoticeModule.OpenNoticePanel(UpdateNoticeModule.NoticeSceneType.LoginAlert, onClose)
end
def.method().OpenScrollNotice = function(self)
  UpdateNoticeModule.OpenScrollNotice(UpdateNoticeModule.NoticeSceneType.LoginScroll)
end
def.static("table", "table").OnLoginAccountSuccess = function()
  GameUtil.AddGlobalLateTimer(0, true, function()
    local self = instance
    if not self:IsShow() then
      return
    end
    local action = self.lastAction
    self.lastAction = LoginMainPanel.Action.NONE
    if action == LoginMainPanel.Action.UPDATE_LOGIN_INFO then
      self:UpdateLoginInfo(true)
    elseif action == LoginMainPanel.Action.SELECT_SERVER then
      self:OnSelectServerButtonClick()
    elseif action == LoginMainPanel.Action.SELECT_ROLE then
      self:OnSelectRoleButtonClick()
    elseif action == LoginMainPanel.Action.LOGIN then
      self:OnLoginButtonClick()
    elseif action == LoginMainPanel.Action.ON_DOWNLOAD_SERVER_LIST then
      LoginMainPanel.OnDownloadServerListCallback({})
    end
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.MSDK then
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.GSDKSetUserName()
    end
  end)
end
def.static("table", "table").OnLoginServerSuccess = function()
  if require("Main.Login.CrossServerLoginMgr").Instance():IsCrossingServer() then
    return
  end
  if loginModule.loginTarget == LoginModule.LoginTarget.Role then
    instance:LoginRole()
  else
    instance:HidePanel()
  end
end
def.static("table", "table").OnLoginRoleSuccess = function()
  instance:HidePanel()
end
def.static("table", "table").OnResetUI = function()
  local self = instance
  self:ResetUI()
end
def.method().ResetUI = function(self)
  self.isLogining = false
  self.m_panel:FindDirect("Img_Bg0/Btn_LoadIn"):GetComponent("UIButton"):set_isEnabled(true)
  require("GUI.WaitingTip").HideTip()
end
def.static("table", "table").OnCachedRoleNotExist = function()
  instance:HidePanel()
end
def.static("table", "table").OnResumeGame = function()
  local self = instance
  if ECGame.Instance():IsQuickLaunch() then
    self.hasExcuteQuickLaunch = false
    self:OnLoginButtonClick()
  end
end
def.static("table", "table").OnServerListUpdate = function()
  local self = instance
  self:UpdateLoginInfo(false)
end
def.static("table", "table").OnLoginRoleError = function()
  local self = instance
  LoginUIMgr.Instance():ShowSelectRoleUI()
  self:DestroyPanel()
end
return LoginMainPanel.Commit()
