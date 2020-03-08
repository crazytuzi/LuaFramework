local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local StartWorkBenefitsNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local def = StartWorkBenefitsNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsStartWorkBenefitsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsStartWorkHasThing()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.StartWorkBenefitsPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return StartWorkBenefitsNode.Commit()
