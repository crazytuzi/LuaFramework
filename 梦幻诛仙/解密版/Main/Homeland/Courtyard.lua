local MODULE_NAME = (...)
local Lplus = require("Lplus")
local Courtyard = Lplus.Class(MODULE_NAME)
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = Courtyard.define
def.field("number").m_level = 1
def.field("dynamic").m_maxLevel = nil
def.field("number").m_cleanness = 0
def.field("number").m_dayCleanCount = 0
def.field("number").m_beauty = 0
def.method("=>", "number").GetLevel = function(self)
  return self.m_level
end
def.method("=>", "number").GetCleanness = function(self)
  return self.m_cleanness
end
def.method("=>", "number").GetDayCleanCount = function(self)
  return self.m_dayCleanCount
end
def.method("=>", "number").GetBeauty = function(self)
  return self.m_beauty
end
def.method("=>", "number").GetMaxBeauty = function(self)
  local level = self:GetLevel()
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(level)
  return courtyardCfg and courtyardCfg.maxBeauty or 1
end
def.method("=>", "number").GetMaxLevel = function(self)
  if self.m_maxLevel == nil then
    self.m_maxLevel = HomelandUtils.GetCourtyardCfgNums()
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
  local courtyardLevel = self:GetLevel()
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(courtyardLevel)
  return courtyardCfg.maxCleanness
end
def.method("=>", "boolean").IsCleannessReachMax = function(self)
  local maxCleanness = self:GetMaxCleanness()
  local cleanness = self:GetCleanness()
  return maxCleanness <= cleanness
end
def.method("=>", "string").GetCleannessShowName = function(self)
  local cleannessCfg = HomelandUtils.GetCourtyardCleanlinessCfg(self.m_cleanness)
  return cleannessCfg and cleannessCfg.showName or "none"
end
def.method("=>", "string").GetBeautyShowName = function(self)
  local beautyCfg = HomelandUtils.GetCourtyardBeautyCfg(self.m_beauty)
  return beautyCfg and beautyCfg.showName or "none"
end
def.method("=>", "table").GetCurLevelCourtyardCfg = function(self)
  local courtyardLevel = self:GetLevel()
  return HomelandUtils.GetCourtyardCfg(courtyardLevel)
end
def.method("number").SetLevel = function(self, level)
  self.m_level = level
end
def.method("number").SetCleanness = function(self, cleanness)
  local cleanness = math.max(0, cleanness)
  self.m_cleanness = cleanness
end
def.method("number").SetDayCleanCount = function(self, dayCleanCount)
  self.m_dayCleanCount = dayCleanCount
end
def.method("number").SetBeauty = function(self, beauty)
  self.m_beauty = beauty
end
return Courtyard.Commit()
