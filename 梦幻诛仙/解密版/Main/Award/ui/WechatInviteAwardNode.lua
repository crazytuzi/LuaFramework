local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local WechatInviteAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local WechatInviteAwardMgr = require("Main.Award.mgr.WechatInviteAwardMgr")
local def = WechatInviteAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return WechatInviteAwardMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return WechatInviteAwardMgr.Instance():GetNotifyMessageCount() > 0
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.WechatInviteAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return WechatInviteAwardNode.Commit()
