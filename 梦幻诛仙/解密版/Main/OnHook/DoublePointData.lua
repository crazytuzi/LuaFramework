local Lplus = require("Lplus")
local DoublePointData = Lplus.Class("DoublePointData")
local instance
local def = DoublePointData.define
def.field("number").frozenPoolPointNum = 0
def.field("number").getingPoolPointNum = 0
def.field("number").dayCanUseCount = 0
def.field("number").weekCanUseCount = 0
def.field("table").useDoublePoint = nil
def.static("=>", DoublePointData).Instance = function()
  if nil == instance then
    instance = DoublePointData()
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.frozenPoolPointNum = 0
  self.getingPoolPointNum = 0
end
def.method("number").SetFrozenPoolPointNum = function(self, num)
  self.frozenPoolPointNum = num
end
def.method("number").SetGetingPoolPointNum = function(self, num)
  self.getingPoolPointNum = num
end
def.method("number", "number").SetDoubleItemUseCount = function(self, dayCanUseCount, weekCanUseCount)
  self.dayCanUseCount = dayCanUseCount
  self.weekCanUseCount = weekCanUseCount
end
def.method("number", "boolean").SetIsUseDoublePoint = function(self, type, bUse)
  if not self.useDoublePoint then
    self.useDoublePoint = {}
  end
  self.useDoublePoint[type] = bUse
end
def.method("=>", "number").GetFrozenPoolPointNum = function(self)
  return self.frozenPoolPointNum
end
def.method("=>", "number").GetGetingPoolPointNum = function(self)
  return self.getingPoolPointNum
end
def.method("=>", "number").GetWeekCanUseCount = function(self)
  return self.weekCanUseCount
end
def.method("=>", "number").GetDayCanUseCount = function(self)
  return self.dayCanUseCount
end
def.method("number", "=>", "boolean").GetIsUseDoublePoint = function(self, type)
  local bUse = true
  if self.useDoublePoint and self.useDoublePoint[type] ~= nil then
    bUse = self.useDoublePoint[type]
  end
  return bUse
end
DoublePointData.Commit()
return DoublePointData
