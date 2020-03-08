local Lplus = require("Lplus")
local MembersTabSonNode = Lplus.Class("MembersTabSonNode")
local HaveGangPanel = Lplus.ForwardDeclare("HaveGangPanel")
local def = MembersTabSonNode.define
def.field(HaveGangPanel).m_base = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.virtual(HaveGangPanel, "userdata").Init = function(self, base, node)
  self.m_base = base
  self.m_node = node
end
def.method().Show = function(self)
  self:OnShow()
  self.m_node:SetActive(true)
  self.isShow = true
end
def.virtual().OnShow = function(self)
end
def.method().Hide = function(self)
  self:OnHide()
  self.m_node:SetActive(false)
  self.isShow = false
end
def.virtual().OnHide = function(self)
end
def.virtual("string").onClick = function(self, id)
end
def.virtual("string", "userdata").onSubmit = function(self, id, ctrl)
end
def.virtual("userdata").onClickObj = function(self, clickobj)
end
def.virtual("string", "string", "number").onSelect = function(self, id, selected, index)
end
def.virtual("string").onDragStart = function(self, id)
end
def.virtual("string").onDragEnd = function(self, id)
end
def.virtual("string", "number", "number").onDrag = function(self, id, dx, dy)
end
MembersTabSonNode.Commit()
return MembersTabSonNode
