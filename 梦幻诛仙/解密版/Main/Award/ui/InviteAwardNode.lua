local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local InviteAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local def = InviteAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsInviteOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return require("Main.CustomActivity.CustomActivityInterface").Instance():IsInviteAwardHasThing()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  require("Main.RelationShipChain.RelationShipChainMgr").GetInviteFriendsInfo({})
  self.panel = require("Main.Award.ui.InviteAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return InviteAwardNode.Commit()
