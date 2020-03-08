local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GrowGuideNodeBase = Lplus.Extend(TabNode, CUR_CLASS_NAME)
local def = GrowGuideNodeBase.define
def.field("number").nodeId = 0
def.field("table").onShowParams = nil
def.virtual("table").ShowWithParams = function(self, params)
  self.onShowParams = params
  self:Show()
end
def.virtual("=>", "boolean").IsUnlock = function(self)
  return true
end
def.virtual("string", "boolean").onToggle = function(self, id, isActive)
end
def.virtual("=>", "boolean").HaveNotifyMessage = function(self)
  return false
end
def.method().UpdateNotifyBadge = function(self)
  if self:HaveNotifyMessage() then
    self.m_base:SetTabNotify(self.nodeId, true)
  else
    self.m_base:SetTabNotify(self.nodeId, false)
  end
end
return GrowGuideNodeBase.Commit()
