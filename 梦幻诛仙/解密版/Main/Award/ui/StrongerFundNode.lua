local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local StrongerFundNode = Lplus.Extend(AwardPanelNodeBase, CUR_CLASS_NAME)
local GrowFundInfo = require("Main.award.ui.GrowFundInfo")
local GrowFundMgr = require("Main.Award.mgr.GrowFundMgr")
local def = StrongerFundNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  GrowFundInfo.Instance():ShowGrowFund(GrowFundMgr.StrongerFundActivityId, self.m_node)
end
def.override().OnHide = function(self)
  GrowFundInfo.Instance():HideGrowFund()
end
def.override("=>", "boolean").IsOpen = function(self)
  return GrowFundMgr.Instance():StrongerFundIsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  GrowFundInfo.Instance():onClickObj(obj)
  return
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return GrowFundMgr.Instance():IsHaveStrongerFundNotifyMessage()
end
def.override().InitUI = function(self)
end
return StrongerFundNode.Commit()
