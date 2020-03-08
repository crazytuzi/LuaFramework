local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local LotteryAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local Vector = require("Types.Vector")
local def = LotteryAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
end
def.override("=>", "boolean").IsOpen = function(self)
  return false
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return false
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.LotteryAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return LotteryAwardNode.Commit()
