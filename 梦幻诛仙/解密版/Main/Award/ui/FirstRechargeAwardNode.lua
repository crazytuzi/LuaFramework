local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AloneNodeBase = require("Main.Award.ui.AloneNodeBase")
local FirstRechargeAwardNode = Lplus.Extend(AloneNodeBase, CUR_CLASS_NAME)
local FirstRechargeMgr = require("Main.Award.mgr.FirstRechargeMgr")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local Vector = require("Types.Vector")
local def = FirstRechargeAwardNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AloneNodeBase.Init(self, base, node)
  self.awardType = GiftType.FIRST_PAY_AWARD
end
def.override("=>", "boolean").IsOpen = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  return not FirstRechargeMgr.Instance():HasDrawAward()
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return FirstRechargeMgr.Instance():IsHaveNotifyMessage()
end
def.override("=>", ECPanelBase).CreatePanel = function(self)
  self.panel = require("Main.Award.ui.FirstRechargeAwardPanel").Instance()
  self.panel:ShowPanel()
  return self.panel
end
return FirstRechargeAwardNode.Commit()
