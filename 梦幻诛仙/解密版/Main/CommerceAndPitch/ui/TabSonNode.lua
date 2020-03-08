local Lplus = require("Lplus")
local TabSonNode = Lplus.Class("TabSonNode")
local CommercePitchPanel = Lplus.ForwardDeclare("CommercePitchPanel")
local ECPanelBase = require("GUI.ECPanelBase")
local def = TabSonNode.define
def.field(CommercePitchPanel).m_base = nil
def.field("userdata").m_panel = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.virtual(CommercePitchPanel, "userdata").Init = function(self, base, node)
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
def.virtual("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
end
def.virtual("string").onDragStart = function(self, id)
end
def.virtual("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.virtual("string").onDragEnd = function(self, id)
end
TabSonNode.Commit()
return TabSonNode
