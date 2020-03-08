local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PointsRaceMatchingPanel = Lplus.Extend(ECPanelBase, "PointsRaceMatchingPanel")
local def = PointsRaceMatchingPanel.define
local instance
def.static("=>", PointsRaceMatchingPanel).Instance = function()
  if instance == nil then
    instance = PointsRaceMatchingPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.static().ShowPanel = function()
  if PointsRaceMatchingPanel.Instance():IsShow() then
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_POINTS_RACE_MATCHING_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
  else
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
PointsRaceMatchingPanel.Commit()
return PointsRaceMatchingPanel
