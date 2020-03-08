local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local NewDailySignNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local def = NewDailySignNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.NewDailySignInPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return NewDailySignNode.Commit()
