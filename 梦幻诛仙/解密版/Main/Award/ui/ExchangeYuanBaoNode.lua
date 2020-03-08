local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local ExchangeYuanBaoNode = Lplus.Extend(AloneNodeBase, "ExchangeYuanBaoNode")
local ExchangeYuanBaoMgr = require("Main.Award.mgr.ExchangeYuanBaoMgr")
local def = ExchangeYuanBaoNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  warn("ExchangeYuanBaoPanel CreatePanel", os.clock())
  self.panel = require("Main.Award.ui.ExchangeYuanBaoPanel").Instance()
  if not self.panel:IsShow() then
    self.panel:ShowPanel()
  end
  ExchangeYuanBaoMgr.SetTabNodeClicked(true)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_TAB_NOTIFY_UPDATE, nil)
  return self.panel
end
def.override("=>", "boolean").IsOpen = function(self)
  return ExchangeYuanBaoMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return ExchangeYuanBaoMgr.Instance():IsHaveNotifyMessage()
end
return ExchangeYuanBaoNode.Commit()
