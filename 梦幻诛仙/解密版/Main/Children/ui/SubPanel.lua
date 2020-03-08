local Lplus = require("Lplus")
local SubPanel = Lplus.Class("SubPanel")
local def = SubPanel.define
def.field("userdata").m_node = nil
def.virtual("userdata").Create = function(self, uiGo)
  self.m_node = uiGo
end
def.method("=>", "boolean").IsShow = function(self)
  if self.m_node and not self.m_node.isnil then
    return self.m_node:get_activeInHierarchy()
  else
    return false
  end
end
def.virtual().Hide = function(self)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(false)
  end
end
def.virtual("table").Show = function(self, data)
  if not self.m_node or not self.m_node.isnil then
  end
end
def.virtual().Destroy = function(self)
end
def.virtual("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    return false
  else
    return false
  end
end
def.virtual("string", "boolean", "=>", "boolean").onToggle = function(self, id, active)
  if self:IsShow() then
    return false
  else
    return false
  end
end
def.virtual("string", "=>", "boolean").onDragStart = function(self, id)
  return false
end
def.virtual("string", "=>", "boolean").onDragEnd = function(self, id)
  return false
end
def.virtual("string", "number", "number", "=>", "boolean").onDrag = function(self, id, dx, dy)
  return false
end
SubPanel.Commit()
return SubPanel
