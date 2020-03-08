local Lplus = require("Lplus")
local PetQuality = Lplus.Class("PetQuality")
local def = PetQuality.define
def.field("table").aptMap = nil
def.field("table").aptLimitMap = nil
def.method("table").RawSet = function(self, data)
  self.aptMap = data.aptMap or {}
  self.aptLimitMap = data.aptLimitMap or {}
end
def.method("number", "=>", "dynamic").GetQuality = function(self, qualityType)
  return self.aptMap[qualityType]
end
def.method("number", "=>", "dynamic").GetMaxQuality = function(self, qualityType)
  return self.aptLimitMap[qualityType]
end
def.method("number", "number").AddValue = function(self, qualityType, value)
  if self.aptMap[qualityType] == nil then
    warn(string.format("Add PetQuality value error, the qualityType \"%d\" does not exist.", qualityType))
  end
  self.aptMap[qualityType] = self.aptMap[qualityType] + value
end
def.method("=>", "number").GetQualitySum = function(self)
  local value = 0
  for k, v in pairs(self.aptMap) do
    value = value + v
  end
  return value
end
return PetQuality.Commit()
