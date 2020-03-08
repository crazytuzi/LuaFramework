local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local GrowFundNode = Lplus.Extend(AwardPanelNodeBase, "GrowFundNode")
local ProductServiceType = require("consts.mzm.gsp.qingfu.confbean.ProductServiceType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GrowFundMgr = require("Main.Award.mgr.GrowFundMgr")
local Vector = require("Types.Vector")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local PayNode = require("Main.Pay.ui.PayNode")
local PayData = require("Main.Pay.PayData")
local PayModule = require("Main.Pay.PayModule")
local def = GrowFundNode.define
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local GrowFundInfo = require("Main.award.ui.GrowFundInfo")
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table").catchedAwardList = nil
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  GrowFundInfo.Instance():ShowGrowFund(GrowFundMgr.GrowFundActivityId, self.m_node)
end
def.override().OnHide = function(self)
  GrowFundInfo.Instance():HideGrowFund()
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  if GameUtil.IsEvaluation() then
    return false
  end
  return GrowFundMgr.Instance():GrowFundIsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  GrowFundInfo.Instance():onClickObj(obj)
  return
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return GrowFundMgr.Instance():IsHaveGrowFundNotifyMessage()
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.awardType = GiftType.GROW_FUND_AWARD
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
return GrowFundNode.Commit()
