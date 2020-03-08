local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local DouDouGiftNode = Lplus.Extend(AloneNodeBase, "DouDouGiftNode")
local def = DouDouGiftNode.define
local DouDouGiftMgr = require("Main.WelcomeParty.DoudouGiftMgr")
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.WelcomeParty.ui.UIDoudouGift").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  if not DouDouGiftMgr.IsFeatureOpen() or not DouDouGiftMgr.IsLvEnough() or DouDouGiftMgr.IsExpired() then
    return false
  end
  return true
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  if not self:IsOpen() then
    return false
  end
  return DouDouGiftMgr.IsShowRedDot()
end
return DouDouGiftNode.Commit()
