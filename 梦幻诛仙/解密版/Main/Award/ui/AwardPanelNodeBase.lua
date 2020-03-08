local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local AwardPanelNodeBase = Lplus.Extend(TabNode, "AwardPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local def = AwardPanelNodeBase.define
def.field("number").nodeId = 0
def.field("number").awardType = 0
def.field("boolean").isFirstDrag = true
def.virtual().InitUI = function(self)
end
def.virtual("table", "table").OnSilverMoneyChanged = function(self)
end
def.virtual("=>", "boolean").IsOpen = function(self)
  return true
end
def.virtual("=>", "boolean").IsHaveNotifyMessage = function(self)
  return false
end
def.method().UpdateNotifyState = function(self)
  if self:IsHaveNotifyMessage() then
    self.m_base:SetTabNotify(self.nodeId, true)
  else
    self.m_base:SetTabNotify(self.nodeId, false)
  end
end
def.method("userdata", "userdata", "number").DragToMakeVisible = function(self, scrollObj, itemObj, strength)
  if not self.isFirstDrag then
    return
  end
  self.isFirstDrag = false
  local uiScrollView = scrollObj:GetComponent("UIScrollView")
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      self.isFirstDrag = true
      if uiScrollView == nil or uiScrollView.isnil then
        return
      end
      uiScrollView:DragToMakeVisible(itemObj.transform, strength)
    end)
  end)
end
return AwardPanelNodeBase.Commit()
