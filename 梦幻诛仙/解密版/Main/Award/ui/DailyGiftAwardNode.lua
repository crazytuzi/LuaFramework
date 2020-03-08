local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local DailyGiftAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local Vector = require("Types.Vector")
local DailyGiftMgr = require("Main.Award.mgr.DailyGiftMgr")
local def = DailyGiftAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  local ignoreEvaluation = false
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    ignoreEvaluation = true
  end
  if not ignoreEvaluation and GameUtil.IsEvaluation() then
    return false
  end
  return DailyGiftMgr.Instance():IsOpen()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return DailyGiftMgr.Instance():GetNotifyMessageCount() > 0
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.DailyGiftAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return DailyGiftAwardNode.Commit()
