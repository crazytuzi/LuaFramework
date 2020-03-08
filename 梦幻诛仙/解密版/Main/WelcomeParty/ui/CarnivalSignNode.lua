local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local CarnivalSignNode = Lplus.Extend(AloneNodeBase, CarnivalSignNode)
local CarnivalSignMgr = require("Main.WelcomeParty.CarnivalSignMgr")
local def = CarnivalSignNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.WelcomeParty.ui.UICarnivalSign").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  return CarnivalSignMgr.Instance():isOpenCarnivalSign()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return CarnivalSignMgr.Instance():isHaveCarnivalSignAward()
end
return CarnivalSignNode.Commit()
