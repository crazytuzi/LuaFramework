local Lplus = require("Lplus")
local WingsSubNodeBase = Lplus.Class("WingsSubNodeBase")
local WingsPanel = Lplus.ForwardDeclare("WingsPanel")
local def = WingsSubNodeBase.define
def.field(WingsPanel).m_base = nil
def.field("userdata").m_node = nil
def.field("boolean").isShow = false
def.virtual(WingsPanel, "userdata").Init = function(self, base, node)
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
def.virtual().OnWingsSchemaChanged = function(self)
end
def.virtual("table", "table").OnSyncWingsInfo = function(self, params, context)
end
return WingsSubNodeBase.Commit()
