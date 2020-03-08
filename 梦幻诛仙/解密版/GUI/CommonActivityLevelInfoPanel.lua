local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonActivityLevelInfoPanel = Lplus.Extend(ECPanelBase, "CommonActivityLevelInfoPanel")
local def = CommonActivityLevelInfoPanel.define
def.field("string").m_ActivityName = ""
def.field("string").m_Level = ""
def.field("table").m_UINodes = nil
local instance
def.static("=>", CommonActivityLevelInfoPanel).Instance = function()
  if nil == instance then
    instance = CommonActivityLevelInfoPanel()
  end
  return instance
end
def.method("string", "string").ShowPanel = function(self, acticityName, level)
  self.m_ActivityName = acticityName
  self.m_Level = level
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_HUANYUE_LEVEL_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  self.m_UINodes = {}
  self.m_UINodes.Bg = self.m_panel:FindDirect("Img_Bg0")
  self.m_UINodes.ActivityLabel = self.m_UINodes.Bg:FindDirect("Label_ActivityName")
  self.m_UINodes.LevelLabel = self.m_UINodes.Bg:FindDirect("Label_LevelNumber")
end
def.method().UpdateUI = function(self)
  self.m_UINodes.ActivityLabel:GetComponent("UILabel"):set_text(self.m_ActivityName)
  self.m_UINodes.LevelLabel:GetComponent("UILabel"):set_text(self.m_Level)
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self.m_ActivityName = ""
  self.m_Level = ""
  self.m_UINodes = nil
end
CommonActivityLevelInfoPanel.Commit()
return CommonActivityLevelInfoPanel
