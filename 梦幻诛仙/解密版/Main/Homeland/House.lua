local MODULE_NAME = (...)
local Lplus = require("Lplus")
local House = Lplus.Class(MODULE_NAME)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = House.define
def.field("number").m_level = 0
def.field("dynamic").m_maxLevel = nil
def.field("number").m_cleanness = 0
def.field("number").m_geomancy = 0
def.field("number").m_dayCleanCount = 0
def.method("=>", "number").GetLevel = function(self)
  return self.m_level
end
def.method("=>", "number").GetCleanness = function(self)
  return self.m_cleanness
end
def.method("=>", "number").GetGeomancy = function(self)
  return self.m_geomancy
end
def.method("=>", "number").GetDayCleanCount = function(self)
  return self.m_dayCleanCount
end
def.method("=>", "number").GetMaxLevel = function(self)
  if self.m_maxLevel == nil then
    self.m_maxLevel = HomelandUtils.GetHouseCfgNums()
  end
  return self.m_maxLevel
end
def.method("=>", "number").GetNextLevel = function(self)
  if self:IsReachMaxLevel() then
    return self.m_level
  else
    return self.m_level + 1
  end
end
def.method("=>", "boolean").IsReachMaxLevel = function(self)
  return self:GetLevel() >= self:GetMaxLevel()
end
def.method("=>", "number").GetMaxCleanness = function(self)
  local houseLevel = self:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  return houseCfg.maxCleanliness
end
def.method("=>", "boolean").IsCleannessReachMax = function(self)
  local maxCleanliness = self:GetMaxCleanness()
  local cleanness = self:GetCleanness()
  return maxCleanliness <= cleanness
end
def.method("=>", "number").GetMaxGeomancy = function(self)
  local houseLevel = self:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  return houseCfg.maxFengShui
end
def.method("=>", "boolean").IsGeomancyReachMax = function(self)
  local maxGeomancy = self:GetMaxGeomancy()
  local geomancy = self:GetGeomancy()
  return maxGeomancy <= geomancy
end
def.method("number").SetLevel = function(self, level)
  self.m_level = level
end
def.method("number").SetCleanness = function(self, cleanness)
  local cleanness = math.max(0, cleanness)
  self.m_cleanness = cleanness
end
def.method("number").SetGeomancy = function(self, geomancy)
  self.m_geomancy = geomancy
end
def.method("number").SetDayCleanCount = function(self, dayCleanCount)
  self.m_dayCleanCount = dayCleanCount
end
return House.Commit()
