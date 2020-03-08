local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local DailySignInDelegateNode = Lplus.Extend(AwardPanelNodeBase, "DailySignInDelegateNode")
local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
local NewDailySignInMgr = require("Main.Award.mgr.NewDailySignInMgr")
local DailySignInNode = require("Main.Award.ui.DailySignInNode")
local NewDailySignInNode = require("Main.Award.ui.NewDailySignInNode")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local DailySignInType = {
  None = 0,
  GeneralSignIn = 1,
  PreciousSignin = 2
}
local def = DailySignInDelegateNode.define
def.field("table").dailySignInNode = nil
def.field("number").dailySignInType = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.SIGN_GIFT
  self.dailySignInType = DailySignInType.None
end
def.override().OnShow = function(self)
  self.m_node:SetActive(false)
  if self:NeedCreateNewDailySignNode() then
    if self.dailySignInNode ~= nil then
      self.dailySignInNode:Hide()
      self.dailySignInNode = nil
    end
    self.dailySignInNode, self.dailySignInType = self:CreateDailySignNode()
  end
  if self.dailySignInNode ~= nil then
    self.dailySignInNode:Show()
  end
end
def.override().OnHide = function(self)
  if self.dailySignInNode ~= nil then
    self.dailySignInNode:Hide()
  end
  self:Clear()
end
def.method().UpdateUI = function(self)
  if self.dailySignInNode ~= nil and self.dailySignInType == DailySignInType.GeneralSignIn then
    self.dailySignInNode:UpdateUI()
  end
end
def.override("=>", "boolean").IsOpen = function(self)
  return DailySignInMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  if self.dailySignInNode ~= nil then
    self.dailySignInNode:onClickObj(obj)
  end
end
def.override("string").onClick = function(self, id)
  if self.dailySignInNode ~= nil then
    self.dailySignInNode:onClick(id)
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return DailySignInMgr.Instance():IsHaveNotifyMessage() or NewDailySignInMgr.Instance():IsHaveNotifyMessage()
end
def.method("=>", "boolean").NeedCreateNewDailySignNode = function(self)
  if not NewDailySignInMgr.Instance():IsOpen() then
    return self.dailySignInType ~= DailySignInType.GeneralSignIn
  else
    return self.dailySignInType ~= DailySignInType.PreciousSignin
  end
end
def.method("=>", "table", "number").CreateDailySignNode = function(self)
  local node
  local signInType = DailySignInType.None
  if not NewDailySignInMgr.Instance():IsOpen() then
    node = DailySignInNode()
    node:Init(self.m_base, self.m_node)
    signInType = DailySignInType.GeneralSignIn
  else
    local fakeRefNode = self.m_base.m_panel:FindDirect("Img_Bg0/Group_AsyncRoot")
    node = NewDailySignInNode()
    node:Init(self.m_base, fakeRefNode)
    signInType = DailySignInType.PreciousSignin
  end
  return node, signInType
end
def.method().Clear = function(self)
  self.dailySignInNode = nil
  self.dailySignInType = DailySignInType.None
end
return DailySignInDelegateNode.Commit()
