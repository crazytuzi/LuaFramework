local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ActivityInterface = require("Main.activity.ActivityInterface")
local GUIUtils = require("GUI.GUIUtils")
local SharePhotoPanel = Lplus.Extend(ECPanelBase, "SharePhotoPanel")
local def = SharePhotoPanel.define
def.field("number").m_ActiveID = 0
def.field("table").m_ShowParams = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", SharePhotoPanel).Instance = function()
  if not instance then
    instance = SharePhotoPanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST2
  end
  return instance
end
def.method("table").ShowPanel = function(self, data)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_ActiveID = data.id
  self.m_ShowParams = data.params
  self:CreatePanel(RESPATH.PREFAB_SHARE_BIG_TU_PANEL, GUILEVEL.NORMAL)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self.m_bCanMoveBackward = true
end
def.override().OnDestroy = function(self)
  self.m_ActiveID = 0
  self.m_UIGO = nil
end
def.method("string").onClick = function(self, id)
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  if self.m_ActiveID == 0 then
    warn("There is no activity id")
    return
  end
  self.m_UIGO = {}
  self.m_UIGO.Label_Name = self.m_panel:FindDirect("Container/Group_Info/Label_Name")
  self.m_UIGO.Label_Minute = self.m_panel:FindDirect("Container/Group_Info/Label_Minute")
  self.m_UIGO.Label_Second = self.m_panel:FindDirect("Container/Group_Info/Label_Second")
  self.m_UIGO.Label_Info = self.m_panel:FindDirect("Container/Label_Info")
  local cfg = ActivityInterface.GetActivityCfgById(self.m_ActiveID)
  local str = ""
  if cfg.personMax == cfg.personMin then
    if cfg.personMax == 1 then
      str = string.format(textRes.activity[62], cfg.personMin)
    else
      str = string.format(textRes.activity[64], cfg.personMin)
    end
  else
    str = string.format(textRes.activity[65], cfg.personMin, cfg.personMax)
  end
  local desc = cfg.timeDes .. "\n"
  desc = desc .. str .. "\n"
  desc = desc .. string.format(textRes.activity[63], cfg.levelMin) .. "\n"
  desc = desc .. cfg.activityDes
  GUIUtils.SetTexture(self.m_UIGO.Label_Name:FindDirect("Texture"), cfg.activityIcon)
  GUIUtils.SetText(self.m_UIGO.Label_Name, cfg.activityName)
  GUIUtils.SetText(self.m_UIGO.Label_Info, desc)
  if self.m_ShowParams and self.m_ShowParams.seconds then
    local min = math.floor(self.m_ShowParams.seconds / 60)
    local seconds = math.fmod(self.m_ShowParams.seconds, 60)
    GUIUtils.SetText(self.m_UIGO.Label_Minute, tostring(min))
    GUIUtils.SetText(self.m_UIGO.Label_Second, tostring(seconds))
  end
end
return SharePhotoPanel.Commit()
