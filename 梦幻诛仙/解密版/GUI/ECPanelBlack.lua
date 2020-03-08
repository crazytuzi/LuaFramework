local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBlack = Lplus.Extend(ECPanelBase, "ECPanelBlack")
local def = ECPanelBlack.define
local instance
def.static("=>", ECPanelBlack).Instance = function()
  if not instance then
    instance = ECPanelBlack()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_BLACK, 0)
end
def.override().OnCreate = function(self)
end
def.method("string").onClick = function(self, id)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
end
return ECPanelBlack.Commit()
