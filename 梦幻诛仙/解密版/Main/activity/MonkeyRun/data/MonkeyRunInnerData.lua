local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local MonkeyRunInnerData = Lplus.Class(CUR_CLASS_NAME)
local def = MonkeyRunInnerData.define
def.field("number").ticketCount = 0
def.field("table").hitIndexes = nil
def.method("table").RawSet = function(self, p)
  self:SetCurrentTicketCount(p.ticketCount)
  self:SetAwardHitIndexes(p.hitIndexes)
end
def.method("number").SetCurrentTicketCount = function(self, ticketCount)
  self.ticketCount = ticketCount
end
def.method("=>", "number").GetCurrentTicketCount = function(self)
  return self.ticketCount
end
def.method("table").SetAwardHitIndexes = function(self, hitIndexes)
  self.hitIndexes = {}
  for idx, hitIndex in pairs(hitIndexes) do
    self.hitIndexes[hitIndex] = 1
  end
end
def.method("number").SetAwradHited = function(self, index)
  if self.hitIndexes == nil then
    return
  end
  self.hitIndexes[index] = 1
end
def.method("number", "=>", "boolean").IsAwardIndexHited = function(self, luaAwardIndex)
  if self.hitIndexes == nil then
    return false
  end
  return self.hitIndexes[luaAwardIndex - 1] == 1
end
return MonkeyRunInnerData.Commit()
