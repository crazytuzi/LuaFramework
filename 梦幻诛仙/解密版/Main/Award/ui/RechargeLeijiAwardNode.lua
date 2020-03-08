local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local RechargeLeijiAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local Vector = require("Types.Vector")
local RechargeLeijiMgr = require("Main.Award.mgr.RechargeLeijiMgr")
local def = RechargeLeijiAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  return RechargeLeijiMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return RechargeLeijiMgr.Instance():GetNotifyMessageCount() > 0
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.RechargeLeijiAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return RechargeLeijiAwardNode.Commit()
