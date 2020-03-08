local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local LoginQueuePanel = Lplus.Extend(ECPanelBase, "LoginQueuePanel")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local LoginQueueMgr = Lplus.ForwardDeclare("LoginQueueMgr")
local def = LoginQueuePanel.define
def.field("table").uiObjs = nil
local instance
def.static("=>", LoginQueuePanel).Instance = function()
  if not instance then
    instance = LoginQueuePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:UpdateQueueInfo()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_LOGIN_QUEUE_PANEL, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  self:InitUI()
  self:UpdateServerName()
  self:UpdateQueueInfo()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, LoginQueuePanel.OnLoginRoleSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, LoginQueuePanel.OnResetUI)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, LoginQueuePanel.OnResetUI)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Server_Name = self.uiObjs.Img_Bg0:FindDirect("Label_Name")
  self.uiObjs.Label_Num = self.uiObjs.Img_Bg0:FindDirect("Label_Num")
  self.uiObjs.Label_SumNum = self.uiObjs.Img_Bg0:FindDirect("Label_SumNum")
  self.uiObjs.Label_Time = self.uiObjs.Img_Bg0:FindDirect("Label_Time")
  self.uiObjs.Container = self.uiObjs.Img_Bg0:FindDirect("Container")
  self.uiObjs.Slider_Bg = self.uiObjs.Container:FindDirect("Slider_Bg")
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, LoginQueuePanel.OnLoginRoleSuccess)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, LoginQueuePanel.OnResetUI)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, LoginQueuePanel.OnResetUI)
  self.uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Quite" then
    self:DestroyPanel()
    LoginModule.Instance():Back2Login()
  end
end
def.method().UpdateServerName = function(self)
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local cfg = ServerListMgr.Instance():GetSelectedServerCfg()
  local text = "unknow server"
  if cfg then
    local serverName = cfg.name
    text = string.format(textRes.Login[47], serverName)
  end
  GUIUtils.SetText(self.uiObjs.Label_Server_Name, text)
end
def.method().UpdateQueueInfo = function(self)
  local loginQueueMgr = LoginQueueMgr.Instance()
  local pos = loginQueueMgr.numBeforeMe
  local text = string.format(textRes.Login[48], pos)
  GUIUtils.SetText(self.uiObjs.Label_Num, text)
  local text = string.format(textRes.Login[49], loginQueueMgr.totalNum)
  GUIUtils.SetText(self.uiObjs.Label_SumNum, text)
  local text = textRes.Login[50]
  local remainTime = loginQueueMgr.remainTime
  local remainSec = remainTime.remainSec
  if remainSec < 60 then
    text = textRes.Login[51]
  elseif remainSec <= 7200 then
    local minute = math.floor(remainSec / 60)
    text = string.format(textRes.Login[52], minute)
  else
    text = textRes.Login[53]
  end
  GUIUtils.SetText(self.uiObjs.Label_Time, text)
  local val = 1 - (pos - 1) / loginQueueMgr.totalNum
  GUIUtils.SetProgress(self.uiObjs.Slider_Bg, "UISlider", val)
end
def.static("table", "table").OnLoginRoleSuccess = function(...)
  instance:DestroyPanel()
end
def.static("table", "table").OnResetUI = function(...)
  instance:DestroyPanel()
end
return LoginQueuePanel.Commit()
