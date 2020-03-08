local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DragonBoatRaceRulePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local TeamData = require("Main.Team.TeamData")
local DragonBoatRaceModule = require("Main.DragonBoatRace.DragonBoatRaceModule")
local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
local def = DragonBoatRaceRulePanel.define
def.field("table").m_UIGOs = nil
local instance
def.static("=>", DragonBoatRaceRulePanel).Instance = function()
  if instance == nil then
    instance = DragonBoatRaceRulePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  local respath = self:GetPanelResPath()
  self:CreatePanel(respath, 1)
end
def.method("=>", "string").GetPanelResPath = function(self)
  local raceCfgId = DragonBoatRaceModule.Instance():GetPreviewRaceId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceCfgId)
  local resIconId = raceCfg.previewGUIId
  local respath = _G.GetIconPath(resIconId)
  if respath == "" then
    error(string.format("No respath found for raceCfgId=%d, resIconId=%d", raceCfgId, resIconId))
  end
  return respath
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.StartRace, DragonBoatRaceRulePanel.OnStartRace)
  Event.RegisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.CancelRace, DragonBoatRaceRulePanel.OnCancelRace)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.StartRace, DragonBoatRaceRulePanel.OnStartRace)
  Event.UnregisterEvent(ModuleId.DRAGON_BOAT_RACE, gmodule.notifyId.DragonBoatRace.CancelRace, DragonBoatRaceRulePanel.OnCancelRace)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Then" then
    self:OnClickBtnThen()
  elseif id == "Btn_Start" then
    self:OnClickBtnStart()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_Left = self.m_UIGOs.Img_Bg0:FindDirect("Group_Left")
  self.m_UIGOs.Group_Common = self.m_UIGOs.Img_Bg0:FindDirect("Group_Common")
end
def.method().UpdateUI = function(self)
  self:UpdateTips()
  self:UpdateBtns()
end
def.method().UpdateTips = function(self)
  local Label_1 = self.m_UIGOs.Group_Left:FindDirect("Img_Bg2/Scroll View/Label_1")
  local TipsHelper = require("Main.Common.TipsHelper")
  local DragonBoatRaceUtils = require("Main.DragonBoatRace.DragonBoatRaceUtils")
  local raceId = DragonBoatRaceModule.Instance():GetPreviewRaceId()
  local raceCfg = DragonBoatRaceUtils.GetRaceCfg(raceId)
  local tipId = raceCfg and raceCfg.hoverTipsId or 0
  local tip = TipsHelper.GetHoverTip(tipId)
  GUIUtils.SetText(Label_1, tip)
end
def.method().UpdateBtns = function(self)
  local meIsCaptain = TeamData.Instance():MeIsCaptain()
  local Btn_Then = self.m_UIGOs.Group_Common:FindDirect("Btn_Then")
  local Btn_Start = self.m_UIGOs.Group_Common:FindDirect("Btn_Start")
  GUIUtils.SetActive(Btn_Then, meIsCaptain)
  GUIUtils.SetActive(Btn_Start, meIsCaptain)
end
def.method().OnClickBtnThen = function(self)
  DragonBoatRaceModule.Instance():CancelRace()
end
def.method().OnClickBtnStart = function(self)
  DragonBoatRaceModule.Instance():StartRace()
end
def.static("table", "table").OnStartRace = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnCancelRace = function(params, context)
  instance:DestroyPanel()
end
return DragonBoatRaceRulePanel.Commit()
