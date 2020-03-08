local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECQQEC = require("ProxySDK.ECQQEC")
local ECLuaString = require("Utility.ECFilter")
local ECReplayKit = require("ProxySDK.ECReplayKit")
local IOSLivePanel = Lplus.Extend(ECPanelBase, "IOSLivePanel")
local def = IOSLivePanel.define
def.field("table").m_UIGO = nil
local instance
def.static("=>", IOSLivePanel).Instance = function()
  if not instance then
    instance = IOSLivePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_IOS_LIVE_PANEL, GUILEVEL.NORMAL)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_CloseZhi" then
    ECReplayKit.StopBroadcast()
    self:DestroyPanel()
  elseif id == "Btn_CloseShe" then
    ECReplayKit.SetupCamera(false)
    self:UpdateCameraBtnStatus(true)
  elseif id == "Btn_CloseMai" then
    ECReplayKit.SetupMicrophone(false)
    self:UpdateMicBtnStatus(true)
  elseif id == "Btn_OpenShe" then
    ECReplayKit.SetupCamera(true)
    self:UpdateCameraBtnStatus(false)
  elseif id == "Btn_OpenMai" then
    ECReplayKit.SetupMicrophone(true)
    self:UpdateMicBtnStatus(false)
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Btn_CloseShe = self.m_panel:FindDirect("Img_Bg/Img_Bg2/Group_Btn/Btn_CloseShe")
  self.m_UIGO.Btn_CloseMai = self.m_panel:FindDirect("Img_Bg/Img_Bg2/Group_Btn/Btn_CloseMai")
  self.m_UIGO.Btn_OpenShe = self.m_panel:FindDirect("Img_Bg/Img_Bg2/Group_Btn/Btn_OpenShe")
  self.m_UIGO.Btn_OpenMai = self.m_panel:FindDirect("Img_Bg/Img_Bg2/Group_Btn/Btn_OpenMai")
  self:UpdateCameraBtnStatus(false)
  self:UpdateMicBtnStatus(false)
end
def.method("boolean").UpdateCameraBtnStatus = function(self, status)
  local closeSheBtn = self.m_UIGO.Btn_CloseShe
  local openSheBtn = self.m_UIGO.Btn_OpenShe
  GUIUtils.SetActive(openSheBtn, status)
  GUIUtils.SetActive(closeSheBtn, not status)
end
def.method("boolean").UpdateMicBtnStatus = function(self, status)
  local closeMaiBtn = self.m_UIGO.Btn_CloseMai
  local openMainBtn = self.m_UIGO.Btn_OpenMai
  GUIUtils.SetActive(openMainBtn, status)
  GUIUtils.SetActive(closeMaiBtn, not status)
end
return IOSLivePanel.Commit()
