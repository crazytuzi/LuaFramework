local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local AloneNodeBase = Lplus.Extend(AwardPanelNodeBase, CUR_CLASS_NAME)
local Vector = require("Types.Vector")
local def = AloneNodeBase.define
def.field("table").uiObjs = nil
def.field("table").panel = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, AloneNodeBase.OnPanelCreated, {self})
  self:InitUI()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, AloneNodeBase.OnPanelCreated)
  self:Clear()
end
def.override().InitUI = function(self)
  local isInited = true
  if self.uiObjs == nil then
    isInited = false
  end
  self.uiObjs = {}
  GameUtil.AddGlobalLateTimer(0, true, function(...)
    if self.uiObjs == nil then
      return
    end
    self:CreatePanel()
  end)
end
def.virtual("=>", ECPanelBase).CreatePanel = function(self)
  return nil
end
def.static("table", "table").OnPanelCreated = function(context, params)
  local panelName = params[1]
  local panel = params[2]
  local self = context[1]
  if self.panel == nil or self.panel ~= panel then
    return
  end
  if self.uiObjs == nil then
    panel:DestroyPanel()
  else
    if self.m_base == nil or self.m_base.m_panel == nil or self.m_base.m_panel.isnil then
      panel:DestroyPanel()
      return
    end
    if self.panel == nil or self.panel.m_panel == nil or self.panel.m_panel.isnil then
      return
    end
    local parent = self.m_base.m_panel
    local depth = parent:GetComponent("UIPanel").depth
    self.panel.m_panel:BringUIPanelTopDepth(depth)
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  if self.panel then
    self.panel:DestroyPanel()
  end
  self.panel = nil
end
return AloneNodeBase.Commit()
