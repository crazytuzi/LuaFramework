local Lplus = require("Lplus")
local TabNode = Lplus.Class("TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local def = TabNode.define
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_panel = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.virtual(ECPanelBase, "userdata").Init = function(self, base, node)
  self.m_base = base
  self.m_panel = self.m_base.m_panel
  self.m_node = node
end
def.method().Show = function(self)
  self.m_node:SetActive(true)
  self.isShow = true
  self:OnShow()
end
def.virtual().OnShow = function(self)
end
def.method().Hide = function(self)
  self.m_node:SetActive(false)
  self.isShow = false
  self:OnHide()
end
def.virtual().OnHide = function(self)
end
def.virtual("string").onClick = function(self, id)
end
def.virtual("string", "userdata").onSubmit = function(self, id, ctrl)
end
def.virtual("string", "boolean").onPress = function(self, id, state)
end
def.virtual("string", "userdata").onDragOut = function(self, id, go)
end
def.virtual("string", "userdata").onDragOver = function(self, id, go)
end
def.virtual("string").onDragStart = function(self, id)
end
def.virtual("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.virtual("string").onDragEnd = function(self, id, go)
end
def.virtual("userdata").onClickObj = function(self, clickobj)
end
def.virtual("userdata", "boolean").onPressObj = function(self, clickobj, bPress)
end
def.virtual("string").onLongPress = function(self, id)
end
def.virtual("string", "string", "number").onSelect = function(self, id, selected, index)
end
def.virtual("string", "string").onTextChange = function(self, id, val)
end
def.virtual("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
end
def.virtual("string").onDoubleClick = function(self, id)
end
TabNode.Commit()
return TabNode
