local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RomanticDanceRulePanel = Lplus.Extend(ECPanelBase, "RomanticDanceRulePanel")
local GUIUtils = require("GUI.GUIUtils")
local def = RomanticDanceRulePanel.define
local instance
def.static("=>", RomanticDanceRulePanel).Instance = function()
  if instance == nil then
    instance = RomanticDanceRulePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_DANCE_RULE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, RomanticDanceRulePanel.OnEnterRomanticDanceGame)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, RomanticDanceRulePanel.OnEnterRomanticDanceGame)
end
def.method().InitUI = function(self)
  local description = self.m_panel:FindDirect("Img_Bg0/Group_Left/Img_Bg2/Scroll View/Label_1")
  local desc = require("Main.Common.TipsHelper").GetHoverTip(constant.CRomanticDanceConsts.game_introduce_tips)
  GUIUtils.SetText(description, desc)
  local Btn_GoHome = self.m_panel:FindDirect("Img_Bg0/Group_Common/Btn_GoHome")
  local Btn_Follow = self.m_panel:FindDirect("Img_Bg0/Group_Common/Btn_Follow")
  local teamData = require("Main.Team.TeamData").Instance()
  GUIUtils.SetActive(Btn_GoHome, teamData:MeIsCaptain())
  GUIUtils.SetActive(Btn_Follow, teamData:MeIsCaptain())
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Btn_GoHome" then
    self:OnBtnCloseClick()
  elseif id == "Btn_Follow" then
    self:OnBtnStarClick()
  end
end
def.method().OnBtnCloseClick = function(self)
  self:DestroyPanel()
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():CloseTeamMemerRulePanel()
end
def.method().OnBtnStarClick = function(self)
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():OpenRomanticChooseModePanel()
end
def.static("table", "table").OnEnterRomanticDanceGame = function(p1, p2)
  instance:DestroyPanel()
end
RomanticDanceRulePanel.Commit()
return RomanticDanceRulePanel
