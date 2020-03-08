local Lplus = require("Lplus")
local ModuleBase = Lplus.Class("ModuleBase")
local def = ModuleBase.define
def.field("number").m_moduleId = 0
def.field("boolean").m_isInited = false
def.method("=>", "number").GetModuleId = function(self)
  return self.m_moduleId
end
def.method("=>", "boolean").IsInited = function(self)
  return self.m_isInited
end
def.virtual().Init = function(self)
  self.m_isInited = true
end
def.virtual().LateInit = function(self)
end
def.method().Reset = function(self)
  self:OnReset()
end
def.virtual().OnReset = function(self)
end
ModuleBase.Commit()
return ModuleBase
