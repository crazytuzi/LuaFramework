local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CurrencyBase = Lplus.Class(CUR_CLASS_NAME)
local def = CurrencyBase.define
def.final("=>", CurrencyBase).New = function()
  local instance = CurrencyBase()
  return instance
end
def.virtual("=>", "string").GetName = function(self)
  return ""
end
def.virtual("=>", "string").GetDescription = function(self)
  return ""
end
def.virtual("=>", "string").GetSpriteName = function(self)
  return ""
end
def.virtual("=>", "number").GetIconId = function(self)
  return 0
end
def.virtual("=>", "userdata").GetHaveNum = function(self)
  return Int64.new(0)
end
def.virtual("function").RegisterCurrencyChangedEvent = function(self, func)
end
def.virtual("function").UnregisterCurrencyChangedEvent = function(self, func)
end
def.virtual().Acquire = function(self)
  self:OnAcquire()
end
def.virtual().AcquireWithQuery = function(self)
end
def.virtual().OnAcquire = function(self)
end
return CurrencyBase.Commit()
