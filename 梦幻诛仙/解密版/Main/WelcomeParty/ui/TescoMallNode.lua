local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local TescoMallNode = Lplus.Extend(AloneNodeBase, TescoMallNode)
local def = TescoMallNode.define
local TescoMallMgr = require("Main.WelcomeParty.TescoMallMgr")
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.WelcomeParty.ui.UITescoMall").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  if not TescoMallMgr.IsFeatureOpen() or TescoMallMgr.IsExpired() or not TescoMallMgr.IsLvEnough() then
    return false
  end
  return true
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if not self:IsOpen() then
    return false
  end
  return TescoMallMgr.IsShowRedDot()
end
return TescoMallNode.Commit()
