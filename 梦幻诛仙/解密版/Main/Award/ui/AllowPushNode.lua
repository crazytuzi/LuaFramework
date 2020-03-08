local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local AllowPushNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local def = AllowPushNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsAllowPushOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsAllowPushRed()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.AllowPushPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return AllowPushNode.Commit()
