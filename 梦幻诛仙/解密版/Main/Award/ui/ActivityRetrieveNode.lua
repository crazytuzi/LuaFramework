local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local ActivityRetrieveNode = Lplus.Extend(AloneNodeBase, MODULE_NAME)
local Cls = ActivityRetrieveNode
local def = Cls.define
local ActivityRetrieveMgr = require("Main.Award.mgr.ActivityRetrieveMgr")
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.ActivityRetrievePnl").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  return ActivityRetrieveMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return ActivityRetrieveMgr.Instance():IsHaveNotifyMessage()
end
return Cls.Commit()
