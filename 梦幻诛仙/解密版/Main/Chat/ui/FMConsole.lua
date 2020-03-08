local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECApollo = require("ProxySDK.ECApollo")
local FMConsole = Lplus.Extend(ECPanelBase, "FMConsole")
local def = FMConsole.define
def.field("boolean").m_Toggle = true
def.field("table").m_UIGO = nil
local instance
def.static("=>", FMConsole).Instance = function()
  if not instance then
    instance = FMConsole()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FM_CONSOLE_PANEL, GUILEVEL.NORMAL)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_MicSwtichOn" then
    local flag = ECApollo.OpenMic()
    if flag == 0 then
      ECApollo.SetCurrentMicState(true)
      ECApollo.ReportSpeakerMicStatusReq({
        room_type = ECApollo.GetCurrentRoomType(),
        status = 1
      })
      self:Update()
    end
  elseif id == "Btn_MicSwtichOff" then
    local flag = ECApollo.CloseMic()
    if flag == 0 then
      ECApollo.SetCurrentMicState(false)
      ECApollo.ReportSpeakerMicStatusReq({
        room_type = ECApollo.GetCurrentRoomType(),
        status = 0
      })
      self:Update()
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.SwitchOn = self.m_panel:FindDirect("Group_Console/Img_Bg/Btn_MicSwtichOn")
  self.m_UIGO.SwitchOff = self.m_panel:FindDirect("Group_Console/Img_Bg/Btn_MicSwtichOff")
end
def.method().Update = function(self)
  local switchOnGO = self.m_UIGO.SwitchOn
  local switchOffGO = self.m_UIGO.SwitchOff
  local status = ECApollo.GetCurrentMicState()
  GUIUtils.SetActive(switchOnGO, not status)
  GUIUtils.SetActive(switchOffGO, status)
end
return FMConsole.Commit()
