local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECApollo = Lplus.ForwardDeclare("ECApollo")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local FMShow = Lplus.Extend(ECPanelBase, "FMShow")
local def = FMShow.define
def.field("boolean").m_Status = true
def.field("table").m_UIGO = nil
local instance
def.static("=>", FMShow).Instance = function()
  if not instance then
    instance = FMShow()
    instance:SetDepth(GUIDEPTH.BOTTOM)
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_FM_PANEL, GUILEVEL.NORMAL)
end
def.static("table", "table").OnJoinGlobalLargeRoom = function(p)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:Update()
  end
end
def.static("table", "table").OnToggle = function(p)
  if not instance.m_panel or instance.m_panel.isnil then
    return
  end
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  local toggleState = require("Main.MainUI.ui.MainUIChat").Instance():GetToggleState()
  if setting.isEnabled and ECApollo.IsOpen() and not toggleState then
    GUIUtils.SetActive(instance.m_panel, p.switch)
    if p.switch then
      instance:Update()
    end
  else
    GUIUtils.SetActive(instance.m_panel, false)
  end
  ECApollo.DestroyGuidPanel()
end
def.static("table", "table").OnNotifySpeakerStatus = function(p)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:Update()
  end
end
def.static("table", "table").OnMainUIExpand = function(p)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:Expand(p.isExpand)
  end
end
def.override("boolean").OnShow = function(self, show)
  if not instance.m_panel or instance.m_panel.isnil then
    return
  end
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  local toggleState = require("Main.MainUI.ui.MainUIChat").Instance():GetToggleState()
  if setting.isEnabled and ECApollo.IsOpen() and not toggleState then
    GUIUtils.SetActive(self.m_panel, show)
    if show then
      instance:Update()
    end
  else
    GUIUtils.SetActive(self.m_panel, false)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, FMShow.OnToggle)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Join_Global_Large_Room, FMShow.OnJoinGlobalLargeRoom)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.ON_EXPAND, FMShow.OnMainUIExpand)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifySpeakerStatus, FMShow.OnNotifySpeakerStatus)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  GUIUtils.SetActive(self.m_panel, setting.isEnabled and ECApollo.IsOpen())
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, FMShow.OnToggle)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Join_Global_Large_Room, FMShow.OnJoinGlobalLargeRoom)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.ON_EXPAND, FMShow.OnMainUIExpand)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifySpeakerStatus, FMShow.OnNotifySpeakerStatus)
end
def.method().OpenChannel = function(self)
  if not ECApollo.IsJoinRoom() then
    Toast(textRes.Chat[44])
    return
  end
  if ECApollo.IsSpeaker(ECApollo.GetCurrentRoomType()) then
    local FmConsole = require("Main.Chat.ui.FMConsole")
    FmConsole.Instance():ShowPanel()
  else
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(2, 8)
  end
end
def.method("string").onClick = function(self, id)
  warn(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Img_Bg" then
    self:OpenChannel()
  elseif id == "Btn_SwtichOn" then
    if ECApollo.IsJoinRoom() then
      Toast(textRes.Chat[48])
      return
    end
    ECApollo.ApolloEnterGlobalLargeRoomReq({
      room_type = ECApollo.GetCurrentRoomType()
    })
  elseif id == "Btn_SwtichOff" then
    local ret = ECApollo.QuitBigRoom()
    if ret == 0 then
      Toast(textRes.Chat[41])
      ECApollo.Instance().m_Status = 0
      local FmConsole = require("Main.Chat.ui.FMConsole")
      FmConsole:Instance().m_Toggle = true
      FmConsole:Instance():DestroyPanel()
      self:Update()
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.APOLLOSTATUS, {2})
    end
  end
  ECApollo.DestroyGuidPanel()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Name = self.m_panel:FindDirect("Group_Console/Img_Bg/Label_Name")
  self.m_UIGO.ImgOn = self.m_panel:FindDirect("Group_Console/Img_Bg/Btn_SwtichOn")
  self.m_UIGO.ImgOff = self.m_panel:FindDirect("Group_Console/Img_Bg/Btn_SwtichOff")
end
def.method().Update = function(self)
  local nameGO = self.m_UIGO.Name
  local imgOnGO = self.m_UIGO.ImgOn
  local imgOffGO = self.m_UIGO.ImgOff
  local desc = ""
  local onoff = ECApollo.IsJoinRoom()
  local speakerInfo = ECApollo.GetSpeakerInfo(ECApollo.GetCurrentRoomType())
  if speakerInfo then
    local hasSpeak = false
    for k, v in pairs(speakerInfo) do
      if v.is_open_mic == 1 then
        desc = desc .. GetStringFromOcts(v.nickname) .. " "
        hasSpeak = true
      end
    end
    if hasSpeak then
      desc = textRes.Chat[45] .. desc
    else
      desc = textRes.Chat[46]
    end
  end
  if not onoff then
    desc = textRes.Chat[47]
  end
  GUIUtils.SetActive(imgOnGO, not onoff)
  GUIUtils.SetActive(imgOffGO, onoff)
  GUIUtils.SetText(nameGO, desc)
end
def.method("boolean").Expand = function(self, isExpand)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local tweenAlpha = self.m_panel:GetComponent("TweenAlpha")
  if tweenAlpha == nil then
    local Vector = require("Types.Vector")
    tweenAlpha = self.m_panel:AddComponent("TweenAlpha")
    tweenAlpha.from = 1
    tweenAlpha.to = 0
    tweenAlpha.duration = 0.4
    tweenAlpha.steeperCurves = true
  end
  if isExpand then
    if self.m_panel.activeInHierarchy then
      tweenAlpha:PlayReverse()
    else
      self.m_panel:GetComponent("UIPanel").alpha = tweenAlpha.from
    end
  elseif self.m_panel.activeInHierarchy then
    tweenAlpha:PlayForward()
  else
    self.m_panel:GetComponent("UIPanel").alpha = tweenAlpha.to
  end
end
return FMShow.Commit()
