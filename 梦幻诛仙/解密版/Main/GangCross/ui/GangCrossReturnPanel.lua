local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GangCrossReturnPanel = Lplus.Extend(ECPanelBase, "GangCrossReturnPanel")
local def = GangCrossReturnPanel.define
local instance
def.field("table").uiTbl = nil
def.static("=>", GangCrossReturnPanel).Instance = function()
  if not instance then
    instance = GangCrossReturnPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_RETURN, -1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
end
def.method().UpdateUI = function(self)
end
def.method().HidePanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
end
return GangCrossReturnPanel.Commit()
