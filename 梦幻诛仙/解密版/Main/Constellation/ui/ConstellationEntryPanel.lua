local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ConstellationEntryPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ConstellationUtils = import("..ConstellationUtils")
local ConstellationModule = import("..ConstellationModule")
local def = ConstellationEntryPanel.define
local instance
def.static("=>", ConstellationEntryPanel).Instance = function()
  if instance == nil then
    instance = ConstellationEntryPanel()
  end
  return instance
end
def.field("table").m_uiObjs = nil
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_12CONSTELLATIONS_ENTRY, 0)
  self:SetDepth(_G.GUIDEPTH.BOTTOM)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_uiObjs = nil
end
def.override("boolean").OnShow = function(self, s)
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.Btn = self.m_panel:FindDirect("Btn_ZhengBa")
end
def.method("string").onClick = function(self, id)
  if id == "Btn_ZhengBa" then
    self:OnEntryBtnClick()
  end
end
def.method().UpdateUI = function(self)
end
def.method().OnEntryBtnClick = function(self)
  local success = ConstellationModule.Instance():ShowLuck12ConstellationPanel()
end
return ConstellationEntryPanel.Commit()
