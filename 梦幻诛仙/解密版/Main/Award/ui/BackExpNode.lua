local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local BackExpNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local BackExpMgr = require("Main.Award.mgr.BackExpMgr")
local backExpMgr = BackExpMgr.Instance()
local def = BackExpNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return backExpMgr:IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return backExpMgr:IsHaveNotifyMessage()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.BackExpPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return BackExpNode.Commit()
