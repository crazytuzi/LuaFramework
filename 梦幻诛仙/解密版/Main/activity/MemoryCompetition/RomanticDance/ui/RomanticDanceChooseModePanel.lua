local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RomanticDanceChooseModePanel = Lplus.Extend(ECPanelBase, "RomanticDanceChooseModePanel")
local GUIUtils = require("GUI.GUIUtils")
local def = RomanticDanceChooseModePanel.define
local instance
def.field("table").uiObjs = nil
def.static("=>", RomanticDanceChooseModePanel).Instance = function()
  if instance == nil then
    instance = RomanticDanceChooseModePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_DANCE_MODE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, RomanticDanceChooseModePanel.OnEnterRomanticDanceGame)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.MINI_GAME, gmodule.notifyId.MiniGame.MEMORY_GAME_START, RomanticDanceChooseModePanel.OnEnterRomanticDanceGame)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Tap_Easy = self.m_panel:FindDirect("Img_Bg0/Tap_Easy")
  self.uiObjs.Tap_Hard = self.m_panel:FindDirect("Img_Bg0/Tap_Hard")
  self.uiObjs.Tap_Easy:GetComponent("UIToggle").value = true
  local Label_Easy = self.m_panel:FindDirect("Img_Bg0/Easy/Scroll View/Label_Tips")
  local Label_Hard = self.m_panel:FindDirect("Img_Bg0/Hard/Scroll View/Label_Tips")
  local easyDesc = require("Main.Common.TipsHelper").GetHoverTip(constant.CRomanticDanceConsts.first_hard_des_tips)
  local hardDesc = require("Main.Common.TipsHelper").GetHoverTip(constant.CRomanticDanceConsts.second_hard_des_tips)
  GUIUtils.SetText(Label_Easy, easyDesc)
  GUIUtils.SetText(Label_Hard, hardDesc)
  local Btn_Start = self.m_panel:FindDirect("Img_Bg0/Btn_Start")
  local teamData = require("Main.Team.TeamData").Instance()
  GUIUtils.SetActive(Btn_Start, teamData:MeIsCaptain())
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:OnBtnCloseClick()
  elseif id == "Tap_Easy" then
    self:OnBtnEasyClick()
  elseif id == "Tap_Hard" then
    self:OnBtnHardClick()
  elseif id == "Btn_Start" then
    self:OnBtnStarClick()
  end
end
def.method().OnBtnCloseClick = function(self)
  self:DestroyPanel()
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():CloseTeamMemerChooseModePanel()
end
def.method().OnBtnEasyClick = function(self)
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():ClickRomanceDanceMode(0)
end
def.method().OnBtnHardClick = function(self)
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():ClickRomanceDanceMode(1)
end
def.method().OnBtnStarClick = function(self)
  local mode = self:GetSelectMode()
  if mode < 0 then
    return
  end
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():AttendRomanticDance(mode)
end
def.method("=>", "number").GetSelectMode = function(self)
  if self.uiObjs.Tap_Easy:GetComponent("UIToggle").value then
    return 0
  elseif self.uiObjs.Tap_Hard:GetComponent("UIToggle").value then
    return 1
  else
    return -1
  end
end
def.method("number").SelectMode = function(self, mode)
  if self.m_panel == nil or self.uiObjs == nil then
    return
  end
  if mode == 0 then
    self.uiObjs.Tap_Easy:GetComponent("UIToggle").value = true
  elseif mode == 1 then
    self.uiObjs.Tap_Hard:GetComponent("UIToggle").value = true
  end
end
def.static("table", "table").OnEnterRomanticDanceGame = function(p1, p2)
  instance:DestroyPanel()
end
RomanticDanceChooseModePanel.Commit()
return RomanticDanceChooseModePanel
